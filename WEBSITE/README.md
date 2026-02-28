# PADUA - Automatización de Descarga de POD (Proof of Delivery)

## Descripción General

Script de automatización con Selenium WebDriver para el sistema **ALERTRAN - Padua** de Latin Logistics. Automatiza el proceso completo desde el login hasta la descarga de imágenes y archivos PDF asociados a una guía de envío, consultando el histórico de envíos (menú 7.8).

**Archivo principal:** `C:\Users\PabloAndresDiazMurci\Documents\test_selenium_browser.py`

---

## Contexto del Proyecto

### ¿Qué hace el script?

El script realiza una automatización end-to-end del portal web ALERTRAN-Padua, un sistema de logística que opera con una interfaz web legacy basada en **framesets HTML**. El flujo completo es:

1. Abre Chrome con Selenium
2. Hace login automático en el portal
3. Navega al módulo "7.8 Consulta a Histórico"
4. Busca una guía de envío específica
5. Accede a la sección P.O.D. (Proof of Delivery)
6. Descarga todas las imágenes y PDFs asociados a esa guía

### ¿Por qué es complejo?

- El portal ALERTRAN usa **framesets HTML** (no iframes modernos), lo que obliga a navegar entre frames constantemente con `driver.switch_to.frame()`.
- Los enlaces son mayormente **JavaScript** (`href="javascript:..."`, `onclick="..."`), no URLs directas.
- Cada interacción puede abrir **ventanas popup** que deben ser detectadas y gestionadas.
- Se implementan **múltiples estrategias de respaldo** (JavaScript + Selenium) para cada paso, ya que la interfaz es impredecible.

---

## Arquitectura del Script

### Estructura General

```
main()
├── Configuración de Chrome (líneas 24-101)
├── Login automático (líneas 108-301)
├── Verificación de login (líneas 234-301)
├── Flujo principal - Login exitoso (líneas 302-3712)
│   ├── PASO 1: Buscar campo de búsqueda (líneas 376-706)
│   ├── PASO 2: Seleccionar "7.8 Consulta a Histórico" (líneas 765-964)
│   ├── PASO 3: Escribir número de guía en campo "nenvio" (líneas 1173-1683)
│   ├── PASO 4: Clic en botón "BUSCAR" (líneas 1684-2203)
│   ├── PASO 5: Clic en enlace "VA" (Ver guía Entrega) (líneas 2205-2362)
│   ├── PASO 6: Clic en menú "P.O.D." (líneas 2369-2507)
│   └── PASO 7: Descarga de archivos (líneas 2508-3711)
│       ├── PASO 7.1: Descarga de imágenes (líneas 2523-2931)
│       └── PASO 7.2: Descarga de PDFs (líneas 2939-3711)
├── Flujo alternativo - Login no confirmado (líneas 3718-3794)
└── Cierre y limpieza (líneas 3796-3821)
```

### Función principal: `main()`

Todo el código está contenido en una única función `main()` que ejecuta el flujo secuencialmente.

---

## Flujo Detallado por Pasos

### Configuración de Chrome (líneas 24-101)

- Configura Chrome con opciones: `--start-maximized`, `--ignore-certificate-errors`, `--ignore-ssl-errors`, `--disable-web-security`
- **Método 1:** Usa `chromedriver-autoinstaller` para configurar automáticamente el ChromeDriver.
- **Método 2 (fallback):** Busca `chromedriver.exe` en rutas comunes del sistema.

### Login Automático (líneas 108-228)

- **URL:** `https://alertran.latinlogistics.com.co/padua/inicio.do`
- **Credenciales:** Usuario `A023863399`, Contraseña `*0P52ryr74g!`
- Busca campos de login usando múltiples selectores (name, id, XPath).
- Envía el formulario mediante `form.submit()` vía JavaScript, con fallback a `Keys.ENTER`.

### Verificación de Login (líneas 234-301)

Tres métodos de verificación:
1. **Cambio de URL** (si ya no contiene "inicio.do")
2. **Elementos post-login** (busca clases como `pui-button-text`, `ui-menuitem-text`, elementos de menú/nav/sidebar)
3. **Desaparición de campos de login** (si el campo password ya no existe)

### PASO 1: Buscar Campo de Búsqueda (líneas 376-706)

- Cambia al frame `"menu"` (el portal usa framesets).
- Busca el campo `funcionalidad_codigo` (campo de búsqueda del menú superior).
- Estrategias de búsqueda ordenadas por prioridad:
  1. `name="funcionalidad_codigo"` (más confiable)
  2. Clases CSS con "codigo"
  3. Proximidad al texto "ALERTRAN - Padua"
  4. Inputs genéricos en la parte superior (`Y < 200px`)
  5. JavaScript para buscar elementos interactivos cerca de "ALERTRAN"
- Escribe **"7.8"** y presiona ENTER.

### PASO 2: Seleccionar "7.8 Consulta a Histórico" (líneas 765-964)

- Busca en los resultados de búsqueda el texto que contenga "7.8" y "Histórico".
- Localiza el elemento clickeable (puede ser `<a>`, `<li>`, `<button>` o un padre clickeable).
- Hace clic y gestiona si se abre una nueva ventana popup.
- Busca el formulario "CONSULTA AL HISTÓRICO DE ENVÍOS" en todos los frames disponibles.

### PASO 3: Escribir Número de Guía (líneas 1173-1683)

- **Guía de prueba:** `999093684611`
- **Método principal:** JavaScript recursivo que busca `input[name="nenvio"]` en todos los frames anidados, escribe el valor y dispara eventos `input`/`change`.
- **Método de respaldo:** Selenium con búsqueda en todas las ventanas y frames, usando selectores priorizados.
- **Validación importante:** Verifica que el campo encontrado NO sea `funcionalidad_codigo` (buscador del menú).
- Acepta campos con `maxlength="12"` como alternativa al nombre exacto.

### PASO 4: Clic en Botón "BUSCAR" (líneas 1684-2203)

- **Elemento objetivo:** `<button class="btn3" id="find" onclick="javascript: seleccionar_busqueda(event);">Buscar</button>`
- **Método principal:** JavaScript recursivo que busca por `id="find"`, luego por `class="btn3"`, luego por texto "Buscar".
- **Método de respaldo:** Selenium en todas las ventanas/frames.
- **Último recurso:** Envía `ENTER` al elemento activo si no se encuentra el botón.

### PASO 5: Clic en Enlace "VA" (líneas 2205-2362)

- **Elemento objetivo:** `<a class="btn2" href="javascript:goPOD('...');" title="Ver guía Entrega">VA</a>`
- Busca enlaces con clase `btn2` y texto "VA".
- Ejecuta `goPOD()` para abrir la vista de la POD (Proof of Delivery).

### PASO 6: Clic en Menú "P.O.D." (líneas 2369-2507)

- **Elemento objetivo:** `<a onclick="javascript:cambiar_contenido('t11', 't11base');">P.O.D.</a>`
- Busca enlace con texto "P.O.D." y `onclick` que contenga `cambiar_contenido`.
- Cambia la vista interna para mostrar la sección de documentos POD.

### PASO 7: Descarga de Archivos (líneas 2508-3711)

#### Estructura de carpetas de descarga

```
~/Downloads/DESCARGA/
└── YYYYMMDD/                  (fecha de descarga)
    └── 999093684611/          (número de guía)
        ├── imagen_1.jpg
        ├── imagen_2.png
        ├── DFIR_999093684611_..._15024.pdf
        └── DFIR_999093684611_..._15023.pdf
```

#### PASO 7.1: Descarga de Imágenes (líneas 2523-2931)

- Busca la sección `<td colspan="5">Imágenes disponibles</td>` en la tabla.
- Detecta imágenes descargables: enlaces (`<a>` con extensiones .jpg/.png/.gif/.pdf), imágenes directas (`<img src>`), y botones de descarga.
- Para cada imagen:
  - **URL directa:** Descarga con `urllib.request.urlretrieve()`.
  - **Enlace JavaScript:** Hace clic, detecta nueva pestaña, busca imagen en ella, descarga y cierra la pestaña.
  - Determina la extensión del archivo automáticamente.

#### PASO 7.2: Descarga de PDFs (líneas 2939-3711) *(anteriormente PASO 7.3, reescrito)*

- Busca `<td>` que contengan el número de guía Y extensión `.pdf` en su texto.
- También busca enlaces `<a>` con el número de guía que apunten a PDFs.
- Navega por **todas las ventanas**, **todos los frames** y **sub-frames** para encontrarlos.
- Elimina duplicados comparando textos.
- Para cada PDF encontrado:
  - **Estrategia 1:** Si tiene `onclick`, extrae URL del onclick con regex, descarga con cookies del navegador, valida header `%PDF-`.
  - **Estrategia 2:** Si tiene `href` HTTP directo, descarga con cookies.
  - **Estrategia 3:** Hace clic en el enlace, espera nueva pestaña, descarga desde la URL de la nueva pestaña.
  - **Estrategia 4 (fila):** Busca enlaces `<a>` en la misma fila (`<tr>`) del `<td>` con el nombre del PDF.
  - **Estrategia 5 (clic en td):** Hace clic directamente en el `<td>`.
  - **Detección de descargas automáticas:** Monitorea la carpeta de descargas de Chrome para detectar archivos nuevos y moverlos a la carpeta organizada.
- **Respaldo con JavaScript recursivo:** Si Selenium no encuentra PDFs, ejecuta JS recursivo en todos los frames.

---

## Dependencias

### Requeridas
| Paquete | Uso |
|---------|-----|
| `selenium` | Automatización del navegador Chrome |
| `chromedriver-autoinstaller` | Configuración automática de ChromeDriver |

### Opcionales
| Paquete | Uso |
|---------|-----|
| `pyautogui` | Escritura directa donde está el cursor (fallback) |

### Estándar de Python (incluidas)
| Módulo | Uso |
|--------|-----|
| `os` | Manejo de rutas y carpetas |
| `sys` | Sistema |
| `time` | Esperas y pausas |
| `datetime` | Fecha para carpetas de descarga |
| `urllib.request` | Descarga de archivos |
| `urllib.parse` | Construcción de URLs |
| `re` | Expresiones regulares (extracción de URLs de onclick) |
| `shutil` | Mover archivos descargados |

### Instalación

```bash
pip install selenium chromedriver-autoinstaller pyautogui
```

---

## Configuración

### Credenciales (líneas 121-122)

```python
usuario = "A023863399"
contraseña = "*0P52ryr74g!"
```

### Guía de prueba (línea 307)

```python
guia_prueba = "999093684611"
```

### URL del sistema (línea 109)

```
https://alertran.latinlogistics.com.co/padua/inicio.do
```

---

## Patrones Técnicos Recurrentes

### 1. Búsqueda Dual (JavaScript + Selenium)

Casi todos los pasos siguen este patrón:
1. **Primero:** JavaScript recursivo que recorre `document` y todos los frames/iframes anidados.
2. **Segundo (respaldo):** Selenium con `WebDriverWait` + múltiples selectores ordenados por prioridad.

### 2. Navegación de Frames

```python
# Patrón típico de búsqueda en frames
driver.switch_to.default_content()          # Volver al frame raíz
driver.switch_to.frame("menu")              # Cambiar al frame del menú
# ... hacer operaciones ...
driver.switch_to.default_content()          # Volver al frame raíz
driver.switch_to.frame("contenido")         # Cambiar a otro frame
```

### 3. Detección de Nuevas Ventanas

```python
ventanas_antes = set(driver.window_handles)
# ... hacer clic ...
ventanas_despues = set(driver.window_handles)
nuevas_ventanas = ventanas_despues - ventanas_antes
if nuevas_ventanas:
    driver.switch_to.window(list(nuevas_ventanas)[0])
```

### 4. Descarga Autenticada

```python
cookies = driver.get_cookies()
opener = urllib.request.build_opener()
cookie_str = '; '.join([f"{c['name']}={c['value']}" for c in cookies])
opener.addheaders = [('Cookie', cookie_str)]
response = opener.open(url)
```

---

## Historial de Cambios

### 2026-02-18
- **PASO 7.2 original (búsqueda exhaustiva genérica de PDFs):** ELIMINADO. Encontraba 128 elementos duplicados (solo 2 archivos reales) y no lograba descargarlos.
- **PASO 7.3 original → renombrado a PASO 7.2:** Reescrito completamente. Ahora:
  - Usa Selenium directamente en frames (en vez de JavaScript desde `document`).
  - Busca específicamente `<td>` con el número de guía + `.pdf` en el texto.
  - Navega por sub-frames anidados.
  - Elimina duplicados antes de procesar.
  - Múltiples estrategias de descarga (onclick URL extraction, HTTP directo, clic + nueva pestaña, detección de descargas automáticas de Chrome).
  - Respaldo con JavaScript recursivo si Selenium no encuentra resultados.

---

## Elementos HTML Clave del Portal ALERTRAN

| Elemento | Selector | Descripción |
|----------|----------|-------------|
| Campo búsqueda menú | `input[name="funcionalidad_codigo"]` | Buscador en la barra superior del menú |
| Campo guía envío | `input[name="nenvio"]` (maxlength=12) | Campo para ingresar número de guía |
| Botón Buscar | `button#find.btn3` | Botón que ejecuta `seleccionar_busqueda(event)` |
| Enlace VA | `a.btn2` (texto "VA") | Enlace que ejecuta `goPOD('id')` |
| Menú P.O.D. | `a` (onclick con `cambiar_contenido('t11','t11base')`) | Pestaña de documentos POD |
| Sección imágenes | `td[colspan="5"]` (texto "Imágenes disponibles") | Encabezado de la sección de imágenes |
| Nombres de PDF | `td` (texto contiene guía + ".pdf") | Celdas con nombres como `DFIR_999093684611_...pdf` |

---

## Ejecución

```bash
cd C:\Users\PabloAndresDiazMurci\Documents
py test_selenium_browser.py
```

El script abrirá Chrome, ejecutará todo el flujo automáticamente y al finalizar esperará a que el usuario presione ENTER para cerrar el navegador.

---

## Notas Importantes

1. **El script requiere interacción mínima:** Solo pide ENTER al final para cerrar el navegador.
2. **Credenciales hardcoded:** Las credenciales están escritas directamente en el código. En producción deberían externalizarse.
3. **Guía hardcoded:** El número de guía `999093684611` está hardcoded. Para buscar otra guía, modificar la variable `guia_prueba`.
4. **Tolerancia a fallos:** Cada paso tiene múltiples estrategias de respaldo. Si un método falla, intenta el siguiente.
5. **Tiempos de espera:** Se usan `time.sleep()` abundantemente por la naturaleza legacy del portal. Algunos han sido optimizados.
6. **La carpeta de descargas** se crea automáticamente en `~/Downloads/DESCARGA/YYYYMMDD/numero_guia/`.
