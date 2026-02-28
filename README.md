# Automatización de Descarga de POD - Padua (Alertran)

Proyecto de automatización con Selenium para realizar login en Padua (Alertran) y descargar Pruebas de Entrega (POD) de forma automática.

## 📋 Descripción

Este sistema automatiza el proceso de:
- Inicio de sesión en Padua (Alertran)
- Navegación al menú 7.8 (Consulta de POD)
- Búsqueda de guías desde archivo Excel
- Descarga automática de archivos POD
- Generación de reportes de éxito/error

## 🚀 Características

- ✅ Login automático en Padua
- ✅ Procesamiento masivo de guías desde Excel
- ✅ Detección automática de POD disponibles (indicador VA)
- ✅ Descarga y organización de archivos
- ✅ Manejo robusto de errores
- ✅ Logs detallados del proceso
- ✅ Soporte para ejecución en Docker

## 📦 Requisitos

### Software necesario:
- **Python 3.8+**
- **Google Chrome** (navegador)
- **Git** (para clonar el repositorio)

### Dependencias Python:
```bash
pip install -r requirements.txt
```

Paquetes principales:
- `selenium` - Automatización web
- `openpyxl` - Lectura/escritura de Excel
- `pyautogui` - Automatización de interfaz
- `chromedriver-autoinstaller` - Gestión automática de ChromeDriver

## 🛠️ Instalación

### 1. Clonar el repositorio
```bash
git clone https://github.com/TU_USUARIO/POD-Automation.git
cd POD-Automation
```

### 2. Instalar dependencias
```bash
pip install -r requirements.txt
```

### 3. Configurar credenciales
Edita `test_selenium_browser.py` y actualiza las credenciales:
```python
USUARIO = "tu_usuario"
PASSWORD = "tu_contraseña"
```

⚠️ **IMPORTANTE**: No compartas tus credenciales. En producción usa variables de entorno.

### 4. Preparar archivo de guías
Coloca tu archivo Excel con las guías en:
```
WEBSITE/GUIAS.xlsx
```

El formato debe tener una columna con los números de guía.

## 🎯 Uso

### Validar instalación
```bash
python test_script.py
```

Este comando verifica:
- ✅ Dependencias instaladas
- ✅ Estructura de carpetas
- ✅ Sintaxis del script
- ✅ ChromeDriver disponible

### Ejecutar automatización
```bash
python test_selenium_browser.py
```

El script:
1. Abrirá Chrome automáticamente
2. Navegará a Padua
3. Realizará el login
4. Procesará las guías del Excel
5. Descargará los POD disponibles
6. Generará reporte en consola

## 📁 Estructura del Proyecto

```
POD/
├── test_selenium_browser.py    # Script principal de automatización
├── test_script.py               # Validador de instalación
├── test_import.py               # Test de importación de módulos
├── requirements.txt             # Dependencias Python
├── README.md                    # Este archivo
├── README_selenium_padua.md     # Documentación técnica detallada
├── .gitignore                   # Archivos a ignorar en Git
├── Dockerfile                   # Imagen Docker (opcional)
├── docker-compose.yml           # Orquestación Docker (opcional)
├── WEBSITE/
│   ├── GUIAS.xlsx              # Archivo de entrada (no versionado)
│   └── README.md               # Documentación de formato
└── DESCARGA/                    # Carpeta de salida (no versionada)
    └── (archivos POD descargados)
```

## 🐳 Docker (Opcional)

Para ejecutar en contenedor Docker:

```bash
# Construir imagen
docker-compose build

# Ejecutar
docker-compose up
```

## 📝 Configuración

### Variables de entorno (recomendado para producción)
```bash
export PADUA_USER="tu_usuario"
export PADUA_PASS="tu_contraseña"
```

### Personalizar comportamiento
Edita las constantes en `test_selenium_browser.py`:
- `TIMEOUT`: Tiempo de espera para elementos (default: 20s)
- `DOWNLOAD_PATH`: Ruta de descarga
- `EXCEL_PATH`: Ruta del archivo de guías

## 🧪 Testing

```bash
# Test de importación
python test_import.py

# Validación completa
python test_script.py
```

## 📊 Formato del Excel de Guías

El archivo `WEBSITE/GUIAS.xlsx` debe tener:
- **Columna A**: Número de guía
- Sin encabezados (o el script los salta automáticamente)

Ejemplo:
```
123456789
987654321
555666777
```

## ⚠️ Consideraciones de Seguridad

1. **NO** subas credenciales al repositorio
2. Usa variables de entorno en producción
3. El archivo `.gitignore` excluye:
   - Credenciales (`.env`, `credentials.json`)
   - Datos sensibles (`GUIAS.xlsx`)
   - Archivos descargados (`DESCARGA/`)

## 🐛 Solución de Problemas

### Error: ChromeDriver no encontrado
```bash
pip install chromedriver-autoinstaller
```

### Error: pyautogui no instalado
```bash
pip install pyautogui
```

### El navegador no se abre
- Verifica que Chrome esté instalado
- Revisa que no haya otro proceso de Chrome bloqueando

### Error de login
- Verifica credenciales en el script
- Comprueba conectividad con Padua
- Revisa si tu usuario está bloqueado

## 📖 Documentación Adicional

- [README_selenium_padua.md](README_selenium_padua.md) - Análisis técnico completo
- [install.md](install.md) - Guía de instalación detallada
- [Manual descarga POD.pdf](Manual%20descarga%20POD.pdf) - Manual original del proceso

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add: nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📜 Licencia

Este proyecto es de uso interno de **Latin Logistics Colombia SAS**.

## 👤 Autor

**Director IT - Latin Logistics Colombia SAS**

## 📅 Historial de Versiones

- **v1.0** (Feb 2026) - Versión inicial con login automático y descarga de POD

---

**Nota**: Este proyecto automatiza procesos internos. Usa las credenciales de forma responsable y segura.
