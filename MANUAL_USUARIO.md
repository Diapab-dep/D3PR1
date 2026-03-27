# Manual de Usuario - Automatización POD (Prueba de Entrega)

**Versión:** 1.0  
**Sistema:** ALERTRAN - Padua (Latin Logistics)  
**Fecha:** Marzo 2026

---

## 1. Introducción

### 1.1 ¿Qué es este sistema?

La **automatización POD** permite descargar de forma masiva las Pruebas de Entrega (Proof of Delivery) asociadas a guías de envío en el sistema Padua (Alertran) de Latin Logistics.

En lugar de consultar cada guía manualmente en el portal, el sistema:

- Lee una lista de números de guía desde un archivo Excel
- Inicia sesión automáticamente en Padua
- Busca cada guía en el módulo "7.8 Consulta a Histórico"
- Descarga todos los PDFs e imágenes de POD asociados
- Organiza los archivos en carpetas por fecha y número de guía

### 1.2 Requisitos previos

- Conexión a internet
- Acceso autorizado al portal Padua (Alertran)
- Navegador Google Chrome instalado (si ejecuta en modo local)

---

## 2. Preparación de datos

### 2.1 Archivo de guías (Excel)

El sistema usa un archivo Excel llamado **`GUIAS.xlsx`** ubicado en la carpeta `WEBSITE`.

**Estructura del archivo:**

| Columna A | Columna B (opcional) |
|-----------|----------------------|
| Guia | Estado (se llena automáticamente) |
| 999093915503 | OK / ERROR / SIN ARCHIVOS |
| 999094087086 | |

- **Columna A:** Número de guía (una por fila, a partir de la fila 2)
- **Columna B:** El sistema la actualiza con el resultado (OK, ERROR, SIN ARCHIVOS, etc.)

### 2.2 Nombres de guía válidos

- Solo números
- Longitud típica: 12 dígitos (ejemplo: 999093915503)
- Una guía por fila

### 2.3 Ejemplo de archivo

```
A              | B
---------------|-------------
Guia           |
999093915503   |
999094087086   |
```

---

## 3. Ejecución en modo local (Windows)

### 3.1 Ubicación del proyecto

```
POD\
├── WEBSITE\
│   └── GUIAS.xlsx       <- Coloque aquí las guías
├── DESCARGA\            <- Aquí se guardan los PDFs
├── test_selenium_browser.py
└── ...
```

### 3.2 Pasos para ejecutar

1. **Prepare el archivo `GUIAS.xlsx`** con los números de guía en la columna A.

2. **Abra una terminal** (PowerShell o CMD) en la carpeta del proyecto.

3. **Ejecute:**
   ```bash
   python test_selenium_browser.py
   ```

4. **El navegador se abrirá automáticamente** y realizará:
   - Login en Padua
   - Navegación al menú 7.8
   - Búsqueda y descarga de cada guía

5. **Al finalizar**, presione **ENTER** en la terminal para cerrar el navegador.

### 3.3 Salida esperada

Los archivos se guardan en:

```
DESCARGA\
└── YYYYMMDD\              (ejemplo: 20260306)
    ├── 999093915503\
    │   ├── DFIR_999093915503_....pdf
    │   └── ...
    └── 999094087086\
        └── ...
```

- `YYYYMMDD`: fecha del día de descarga
- Cada subcarpeta corresponde a una guía procesada

---

## 4. Ejecución en Docker (servidor remoto)

### 4.1 ¿Cuándo usar Docker?

Use el modo Docker cuando:

- Necesite ejecutar el proceso en un servidor sin intervención manual
- Quiera procesar muchas guías de forma programada
- El servidor esté configurado con la imagen Docker del proyecto

### 4.2 Cómo ejecutar

1. **Edite el archivo `run_docker_remote.py`** y modifique la variable `GUIAS` con los números de guía:

   ```python
   GUIAS = ["999093915503", "999094087086", "123456789012"]
   ```

2. **Ejecute en su máquina:**
   ```bash
   python run_docker_remote.py
   ```

3. El script:
   - Se conecta al servidor remoto
   - Actualiza `GUIAS.xlsx` con las guías indicadas
   - Lanza el contenedor Docker
   - Muestra los logs al cabo de unos segundos

### 4.3 Ver la ejecución en vivo

En una **terminal adicional**, conecte al servidor y siga los logs:

```bash
ssh pdiaz@20.102.51.145
docker logs -f padua-pod-run
```

Presione **Ctrl+C** para dejar de seguir los logs.

### 4.4 Obtener logs completos sin SSH

Ejecute localmente:

```bash
python get_docker_logs.py
```

Esto mostrará el estado del contenedor y los últimos registros del proceso.

### 4.5 Recuperar archivos descargados

Los PDFs se guardan en la carpeta `DESCARGA` del servidor:

- Servidor: `/home/pdiaz/DESCARGA`
- Estructura: `DESCARGA/YYYYMMDD/numero_guia/archivos.pdf`

Use SCP o SFTP para copiar los archivos a su equipo si es necesario.

---

## 5. Interpretación de resultados

### 5.1 Mensajes en consola

| Mensaje | Significado |
|---------|-------------|
| [OK] GUÍA XXXXX - OK | Guía procesada correctamente, archivos descargados |
| [OK] GUÍA XXXXX - SIN ARCHIVOS | Guía procesada pero no tenía POD asociada |
| [FAIL] GUÍA XXXXX - ERROR | No se pudo completar el proceso para esa guía |

### 5.2 Resumen final

Al terminar verá algo como:

```
RESUMEN DESCARGA MASIVA DE GUÍAS
Total guías procesadas: 5
Guías exitosas (OK):    4
Guías con error:        1
```

### 5.3 Archivo Excel actualizado

El archivo `GUIAS.xlsx` se actualiza automáticamente con el resultado de cada guía en la columna B:

- **OK** - Descarga completada
- **SIN ARCHIVOS** - Sin POD disponibles
- **SIN DATOS** - No se creó carpeta de descarga
- **ERROR** - Fallo durante el proceso

---

## 6. Solución de problemas frecuentes

### 6.1 "No se encontró el campo de usuario"

- Compruebe la conexión a internet
- Verifique que la URL de Padua esté accesible
- Posible cambio en el portal; contacte a TI

### 6.2 "Campo nenvio no encontrado"

- Suele ocurrir al procesar varias guías seguidas
- En Docker el sistema aplica correcciones automáticas
- Si persiste, ejecute de nuevo con menos guías

### 6.3 "No se pudieron descargar PDFs"

- Los PDFs pueden detectarse pero no descargarse por restricciones de red
- Verifique permisos de escritura en la carpeta DESCARGA
- En Docker, revise que el volumen esté montado correctamente

### 6.4 "GUIAS.xlsx bloqueado"

- Cierre el archivo si está abierto en Excel
- El script intentará usar GUIAS_PRUEBA.xlsx si existe

### 6.5 Chrome/ChromeDriver no inicia

- En local: instale Chrome y ejecute `pip install chromedriver-autoinstaller`
- En Docker: la imagen ya incluye Chrome y ChromeDriver

---

## 7. Contacto y soporte

Para problemas técnicos o solicitudes de cambio, contacte al área de TI o al responsable del proyecto.

---

Documento generado para el proyecto POD - Latin Logistics Colombia
