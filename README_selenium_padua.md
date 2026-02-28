<style>
    /* Forzar salto de página antes de los títulos grandes */
    h1 { page-break-before: always; }
    /* Estilo de código más limpio para PDF */
    pre { background-color: #f0f0f0; border: 1px solid #ccc; }
</style>

## Automatización de login en Padua (Alertran) con Selenium

Este archivo documenta los análisis realizados y el script creado para automatizar el inicio de sesión en Padua (Alertran) y, posteriormente, apoyar la descarga de POD.

---

### 1. Análisis del manual de descarga de POD

Fuente: `Manual descarga POD.pdf`.

- **Aplicativos involucrados**:
  - Padua (Alertran): descarga individual de POD por número de guía (menú 7.8).
  - Conecta2 (C2): descarga masiva de POD por cliente y rango de fechas.
- **Flujo en Padua (Alertran)**:
  - Ingreso al sistema y navegación al menú **7.8**.
  - En el campo **Envío** se digita el número de guía.
  - Si aparece la sigla **VA (Ver guía de entrega)**:
    - La guía tiene POD asociada.
    - Se puede:
      - Hacer clic en **VA** para ver la POD, o
      - Entrar al detalle de la guía y en la última pestaña **POD** visualizar la prueba de entrega.
  - Si NO aparece **VA**, la guía no tiene POD adjunta.
- **Flujo en Conecta2 (descarga masiva)**:
  - Ingreso a Conecta2.
  - Menú izquierdo → opción **Descarga masiva POD**.
  - Seleccionar **cliente** y **rango de fechas**.
  - El sistema genera y descarga un archivo comprimido (por ejemplo, ZIP) con todas las POD que cumplen el filtro.
  - Al descomprimir ese archivo se visualizan las POD individuales.

Conclusión: el modelo de descarga se basa en:
- Descarga individual por identificador único (guía) con indicador de disponibilidad (VA).
- Descarga masiva filtrada por cliente y fechas, empaquetando los archivos en un comprimido.

---

### 2. Análisis de la URL de login de Padua

URL: `https://alertran.latinlogistics.com.co/padua/inicio.do`

La página observada presenta:
- Un formulario de inicio de sesión con:
  - Campo de **Usuario**.
  - Campo de **Contraseña**.
  - Botón **Aceptar**.
- Mensajes de validación posibles:
  - "Usuario incorrecto."
  - "Contraseña incorrecta."
  - "Usuario bloqueado. Número máximo de intentos de ingreso superado. Contacte al administrador."
  - "Usuario en proceso de actualización. Inténtelo mas tarde."
  - "Validando usuario..."
- Enlace de recuperación: "¿Olvidaste o bloqueaste tu contraseña?"

Este comportamiento confirma que:
- El acceso a funcionalidades como el menú 7.8 (descarga de POD) requiere autenticación.
- La automatización debe:
  - Completar usuario y contraseña.
  - Hacer clic en "Aceptar".
  - Esperar la respuesta de la aplicación (éxito o mensaje de error).

---

### 3. Diseño del script de automatización con Selenium

Archivo creado: `test_selenium_browser.py`
Ubicación: carpeta `Documents` del usuario (`C:\Users\PabloAndresDiazMurci\Documents\test_selenium_browser.py`).

#### 3.1. Objetivo del script

- Abrir un navegador (Chrome) usando Selenium.
- Navegar a la URL de login de Padua: `https://alertran.latinlogistics.com.co/padua/inicio.do`
- Rellenar automáticamente:
  - Usuario: `A52805062`
  - Contraseña: `Liam2020++`
- Hacer clic en el botón "Aceptar".
- Verificar el resultado del login (éxito o mensajes de error).
- Mantener el navegador abierto para verificación manual.

#### 3.2. Detalles técnicos principales

- **Gestión de ChromeDriver**:
  - Uso de `chromedriver-autoinstaller` para descarga automática de ChromeDriver.
  - Si no está disponible, busca ChromeDriver en ubicaciones comunes del sistema.
  - Evita problemas con SeleniumManager que pueden causar timeouts.

- **Configuración de Chrome**:
  - Ventana maximizada.
  - Opciones para ignorar errores de certificado SSL (útil en entornos corporativos).
  - Deshabilitación de logging innecesario.

- **Localización de elementos del formulario de login**:
  - **Campo de usuario**: Busca usando múltiples estrategias:
    - Por atributo `name="usuario"` o `id="usuario"`
    - Por atributo `name="username"` o `id="username"`
    - Por tipo `input[type='text']`
    - Método alternativo: busca cualquier input de texto disponible
  - **Campo de contraseña**: Busca usando múltiples estrategias:
    - Por atributo `name="contraseña"` o `name="password"`
    - Por tipo `input[type='password']` (método más confiable)
  - **Botón de ingreso**: Busca usando múltiples estrategias:
    - `input[type='submit']` o `button[type='submit']`
    - Por valor `value="Aceptar"`
    - Por texto del botón que contenga "Aceptar", "Ingresar" o "Login"
    - Por `id="aceptar"` o `name="aceptar"`
    - Método alternativo: primer botón o input submit disponible

- **Manejo del flujo de login**:
  - Usa `WebDriverWait` y `expected_conditions` para esperar a que los elementos estén presentes.
  - Limpia los campos antes de escribir (por si tienen valores por defecto).
  - Agrega pequeñas pausas (`time.sleep`) entre acciones para simular comportamiento humano.
  - Después del clic, espera 3 segundos para que el servidor procese la solicitud.

- **Verificación del resultado**:
  - Detecta cambios en la URL (indicador de login exitoso).
  - Busca mensajes de error comunes en el HTML de la página:
    - "usuario incorrecto"
    - "contraseña incorrecta"
    - "usuario bloqueado"
    - "usuario en proceso de actualización"
    - "validando usuario"
  - Muestra el resultado en la consola para que el usuario pueda verificar.

- **Manejo de errores**:
  - Captura `TimeoutException` cuando los elementos no aparecen a tiempo.
  - Captura `NoSuchElementException` cuando no se encuentran elementos.
  - Muestra mensajes descriptivos y sugerencias de solución.
  - Mantiene el navegador abierto en caso de error para inspección manual.

#### 3.3. Requisitos para ejecutar el script

- **Python** 3.8 o superior.
- Paquetes Python necesarios:
  ```bash
  pip install selenium
  pip install chromedriver-autoinstaller
  ```
- Navegador **Google Chrome** instalado.

#### 3.4. Ejecución del script

Para ejecutar el script:

```bash
cd C:\Users\PabloAndresDiazMurci\Documents
python test_selenium_browser.py
```

El script mostrará mensajes informativos en la consola durante todo el proceso:
- Estado de la configuración de ChromeDriver
- Progreso de la carga de la página
- Localización de cada campo del formulario
- Resultado del intento de login
- Instrucciones para cerrar el navegador

#### 3.5. Análisis del proceso de login realizado

**Estrategia de búsqueda de elementos**:
- Se implementó una estrategia de "múltiples intentos" para encontrar los campos del formulario, ya que diferentes versiones de la aplicación pueden usar diferentes atributos HTML.
- Esto hace el script más robusto ante cambios menores en la estructura de la página.

**Mensajes de error detectables**:
- El script puede identificar automáticamente los mensajes de error más comunes que muestra la aplicación Padua.
- Esto permite al usuario saber inmediatamente si el login falló y por qué razón.

**Consideraciones de seguridad**:
- Las credenciales están hardcodeadas en el script. En un entorno de producción, deberían:
  - Leerse desde variables de entorno.
  - O desde un archivo de configuración cifrado.
  - O solicitarse de forma interactiva al usuario.

---

### 4. Próximos pasos posibles

- Extender el script para:
  - Navegar al menú 7.8 dentro de Padua.
  - Automatizar la búsqueda de la guía en el campo Envío.
  - Detectar si aparece la sigla VA.
  - Abrir o descargar la POD asociada.
- Crear un segundo script orientado a Conecta2 para:
  - Realizar descarga masiva de POD por cliente y rango de fechas.
  - Administrar la descarga y descompresión de los archivos de manera automatizada.

Este README se puede ir actualizando con cada nuevo análisis (nuevos flujos, mejoras del script, consideraciones de seguridad, etc.).

