# Manual Técnico - Automatización POD (Prueba de Entrega)

**Versión:** 1.0  
**Sistema:** ALERTRAN - Padua (Latin Logistics)  
**Fecha:** Marzo 2026

---

## 1. Arquitectura del sistema

### 1.1 Componentes principales

```
┌─────────────────────────────────────────────────────────────────┐
│                     CAPA DE EJECUCIÓN                            │
├─────────────────────────────────────────────────────────────────┤
│  Local (Windows)              │  Remoto (Docker/Linux)           │
│  test_selenium_browser.py     │  Contenedor padua-pod:latest     │
│  + Chrome + ChromeDriver      │  + Xvfb + Chrome headless        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     CAPA DE DATOS                                │
├─────────────────────────────────────────────────────────────────┤
│  WEBSITE/GUIAS.xlsx  (entrada)  │  DESCARGA/YYYYMMDD/guia/ (salida) │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     APLICACIÓN EXTERNA                           │
│  https://alertran.latinlogistics.com.co/padua/inicio.do          │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 Estructura de archivos del proyecto

```
POD/
├── test_selenium_browser.py   # Script principal de automatización
├── run_docker_remote.py       # Lanza ejecución en Docker remoto
├── get_docker_logs.py         # Obtiene logs del contenedor vía SSH
├── check_docker_logs.py       # Utilidad de diagnóstico Docker
├── requirements.txt           # Dependencias Python
├── Dockerfile                 # Imagen Docker
├── docker-compose.yml         # Orquestación (opcional)
├── entrypoint.sh              # Script de arranque del contenedor
├── WEBSITE/
│   ├── GUIAS.xlsx             # Entrada: guías a procesar
│   └── GUIAS_PRUEBA.xlsx      # Fallback si GUIAS.xlsx está bloqueado
├── DESCARGA/                  # Salida: PDFs e imágenes por guía
│   └── YYYYMMDD/
│       └── {numero_guia}/
└── docs/
    ├── MANUAL_USUARIO.md
    ├── MANUAL_TECNICO.md
    └── README_selenium_padua.md
```

### 1.3 Flujo de ejecución

```
1. Inicio
2. Configurar Chrome (opciones, ChromeDriver)
3. Cargar URL Padua
4. Login (usuario/contraseña)
5. Navegar a menú 7.8 (Consulta a Histórico)
6. Para cada guía en GUIAS.xlsx:
   a. Buscar campo nenvio, escribir guía
   b. Clic en BUSCAR
   c. Clic en enlace VA (Ver guía de entrega)
   d. Clic en menú P.O.D.
   e. Descargar PDFs e imágenes
   f. Re-navegar al formulario (para guía siguiente)
7. Actualizar Excel con resultados
8. Cerrar navegador
```

---

## 2. Dependencias técnicas

### 2.1 Python

- **Versión:** 3.8 o superior (recomendado 3.12)
- **Paquetes:** Ver `requirements.txt`

```txt
selenium>=4.15.0
openpyxl>=3.1.2
pyautogui>=0.9.54
chromedriver-autoinstaller>=0.6.3
PyVirtualDisplay>=3.0
Pillow>=10.0.0
python-xlib>=0.33
requests>=2.31.0
```

### 2.2 Para ejecución local

- Google Chrome instalado
- `chromedriver-autoinstaller` descarga ChromeDriver compatible con la versión de Chrome

### 2.3 Para ejecución en Docker

- Imagen: `padua-pod:latest`
- Base: Linux + Xvfb + Chrome + ChromeDriver
- Variables de entorno: `RUNNING_IN_DOCKER=true`

### 2.4 Para `run_docker_remote.py`

- `paramiko` (SSH/SFTP)
- Acceso SSH al servidor: `pdiaz@20.102.51.145`

---

## 3. Detalles del script principal

### 3.1 Función `is_docker()`

```python
def is_docker():
    return os.environ.get("RUNNING_IN_DOCKER", "").lower() == "true"
```

Permite adaptar el comportamiento (timeouts, opciones de Chrome, re-navegación) según el entorno.

### 3.2 Estrategias de navegación

| Paso | Objetivo | Método principal | Fallback |
|------|----------|------------------|----------|
| Login | Enviar formulario | `form.submit()` (JS) | `Keys.ENTER` |
| Ir a 7.8 | Menú | Escribir "7.8" + Enter | Clic en resultado autocomplete |
| Campo nenvio | Escribir guía | JS recursivo en frames | Selenium + múltiples frames |
| Botón BUSCAR | Ejecutar búsqueda | JS `id="find"` | Selenium, ENTER |
| Enlace VA | Ver POD | JS `class="btn2"` | Selenium |
| Menú P.O.D. | Cambiar pestaña | JS texto "P.O.D." | Selenium |

### 3.3 Re-navegación entre guías (Docker)

Tras procesar cada guía, el script debe volver al formulario de búsqueda. Estrategias en orden:

1. **driver.back()** – Volver atrás en el historial (prioritario en Docker)
2. **Recarga + menú 7.8** – `driver.get(url_principal)`, escribir 7.8, ActionChains (ARROW_DOWN + ENTER)
3. **Clic directo** – Buscar elemento "7.8 Consulta a Histórico" y clic vía JS
4. **buscarYClick78** – JS recursivo que busca y hace clic en el resultado

### 3.4 Navegación de frames

Padua usa framesets HTML. Secuencia típica:

```python
driver.switch_to.default_content()
driver.switch_to.frame("menu")    # Campo búsqueda, menú 7.8
# ...
driver.switch_to.default_content()
driver.switch_to.frame("contenido")  # Formulario nenvio, resultados
```

### 3.5 Descarga de PDFs

1. Buscar `<td>` con número de guía + ".pdf"
2. Extraer URL de `onclick` o `href`
3. Descargar con cookies del navegador (`requests` o `urllib`)
4. Validar cabecera `%PDF-`
5. Guardar en `DESCARGA/YYYYMMDD/{guia}/`

---

## 4. Configuración Docker

### 4.1 Dockerfile (resumen)

- Imagen base con Python, Chrome, ChromeDriver
- Xvfb para display virtual
- Volúmenes: `WEBSITE`, `DESCARGA`
- `entrypoint.sh` inicia Xvfb y ejecuta `test_selenium_browser.py`

### 4.2 Ejecución del contenedor

```bash
docker run -d --name padua-pod-run \
  -e RUNNING_IN_DOCKER=true \
  -v /home/pdiaz/WEBSITE:/app/WEBSITE \
  -v /home/pdiaz/DESCARGA:/app/DESCARGA \
  -v /home/pdiaz/test_selenium_browser.py:/app/test_selenium_browser.py:ro \
  padua-pod:latest
```

### 4.3 Servidor remoto

- **Host:** 20.102.51.145
- **Usuario:** pdiaz
- **Carpetas:** `/home/pdiaz/WEBSITE`, `/home/pdiaz/DESCARGA`

---

## 5. Configuración y credenciales

### 5.1 Variables en el código

| Variable | Ubicación aprox. | Descripción |
|----------|------------------|-------------|
| `usuario` | ~línea 228 | Usuario Padua |
| `contraseña` | ~línea 229 | Contraseña Padua |
| `url_principal_app` | Capturada en runtime | URL tras login |
| `GUIAS` | run_docker_remote.py | Lista de guías para Docker |

### 5.2 Seguridad

- Las credenciales están en el código fuente
- Recomendación: usar variables de entorno o archivo de configuración cifrado
- Ejemplo con variables de entorno:

```python
usuario = os.environ.get("PADUA_USER", "default")
contraseña = os.environ.get("PADUA_PASS", "")
```

---

## 6. Elementos HTML de referencia (Padua)

| Elemento | Selector | Uso |
|----------|----------|-----|
| Campo búsqueda menú | `input[name="funcionalidad_codigo"]` | Escribir "7.8" |
| Campo guía | `input[name="nenvio"]` | Número de guía |
| Botón BUSCAR | `button#find` o `btn3` | Ejecutar búsqueda |
| Enlace VA | `a.btn2` texto "VA" | Ver guía de entrega |
| Menú P.O.D. | Enlace con texto "P.O.D." | Cambiar a pestaña POD |
| Nombres PDF | `td` con guía + ".pdf" | Identificar PDFs a descargar |

---

## 7. Diagnóstico y logs

### 7.1 Logs locales

- Salida en consola (stdout)
- Mensajes con prefijos: `[OK]`, `[WARNING]`, `[FAIL]`

### 7.2 Logs Docker

```bash
docker logs padua-pod-run
docker logs --tail 500 padua-pod-run
docker logs -f padua-pod-run   # Seguir en vivo
```

### 7.3 Obtener logs vía script

```bash
python get_docker_logs.py
```

Usa Paramiko para SSH y ejecuta `docker logs` en el servidor.

### 7.4 Errores habituales

| Error | Causa probable | Acción |
|-------|----------------|--------|
| `element not interactable` | Elemento oculto o en otro frame | Usar `execute_script("click")` |
| `TimeoutException` | Página lenta o cambio de estructura | Aumentar tiempo de espera |
| `nenvio no encontrado` | Contexto en frame incorrecto | `driver.switch_to.default_content()` |
| `No such element` | Cambio en HTML de Padua | Revisar selectores y estrategias |

---

## 8. Mantenimiento y evolución

### 8.1 Si cambia la interfaz de Padua

1. Revisar selectores en el script
2. Ajustar XPath y atributos (`name`, `id`, `class`)
3. Probar en local antes de Docker
4. Actualizar este manual con los nuevos elementos

### 8.2 Mejoras futuras sugeridas

- Extraer credenciales a configuración externa
- Soporte para rango de fechas o filtros adicionales
- Cola de trabajos para procesar guías en paralelo
- Notificaciones (email, Slack) al finalizar
- Interfaz web o API para lanzar procesos

---

## 9. Referencias

- **URL Padua:** https://alertran.latinlogistics.com.co/padua/inicio.do
- **Selenium:** https://www.selenium.dev/documentation/
- **ChromeDriver:** https://chromedriver.chromium.org/
- **Repositorio:** https://github.com/Diapab-dep/Deprisa (si está publicado)

---

*Manual técnico - Proyecto POD - Latin Logistics Colombia*
