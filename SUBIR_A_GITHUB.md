# 🚀 Guía para Subir el Proyecto a GitHub

## ✅ Estado Actual

El repositorio Git local ya está **configurado y listo**:
- ✅ Git instalado
- ✅ Repositorio inicializado
- ✅ Todos los archivos agregados
- ✅ Commit inicial creado
- ✅ `.gitignore` configurado (protege credenciales)

**Commit creado:**
```
Initial commit: Automatización POD Padua con Selenium
16 archivos, 5388 líneas de código
```

---

## 📝 Opción 1: Subir usando GitHub.com (MÁS FÁCIL)

### Paso 1: Crear el repositorio en GitHub

1. Ve a: **https://github.com/new**
2. Completa el formulario:
   - **Repository name**: `POD-Automation-Padua` (o el nombre que prefieras)
   - **Description**: `Automatización de descarga de POD desde Padua (Alertran) usando Selenium`
   - **Visibilidad**: 
     - ✅ **Private** (recomendado - solo tú lo ves)
     - ⚠️ Public (cualquiera puede verlo)
   - ⚠️ **NO marques** "Add a README file"
   - ⚠️ **NO marques** "Add .gitignore"
   - ⚠️ **NO marques** "Choose a license"
3. Haz clic en **"Create repository"**

### Paso 2: Conectar y subir

GitHub te mostrará una página con instrucciones. **IGNORA esas instrucciones** y usa estas:

#### A. Si quieres repositorio PRIVADO:

Abre PowerShell en esta carpeta y ejecuta:

```powershell
# Refrescar entorno para usar Git
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Cambiar a la carpeta del proyecto
cd 'c:\Users\PabloAndresDiazMurci\OneDrive - Latin Logistics Colombia SAS\Documentos\DIRECTOR IT\AUTOMATIZACIONES\POD'

# Agregar repositorio remoto (REEMPLAZA TU_USUARIO con tu nombre de usuario de GitHub)
git remote add origin https://github.com/TU_USUARIO/POD-Automation-Padua.git

# Renombrar rama a main (estándar actual de GitHub)
git branch -M main

# Subir todo a GitHub
git push -u origin main
```

GitHub te pedirá **autenticarte**:
- Opción 1: Usará GitHub Desktop si lo tienes instalado
- Opción 2: Te abrirá el navegador para autenticarte
- Opción 3: Te pedirá crear un Personal Access Token

### Paso 3: Verificar

Ve a `https://github.com/TU_USUARIO/POD-Automation-Padua` y verás todos tus archivos.

---

## 📝 Opción 2: Usar GitHub Desktop (INTERFAZ GRÁFICA)

### Paso 1: Instalar GitHub Desktop

1. Descarga desde: **https://desktop.github.com/**
2. Instala y abre la aplicación
3. Inicia sesión con tu cuenta de GitHub

### Paso 2: Publicar el repositorio

1. En GitHub Desktop: **File → Add Local Repository**
2. Selecciona la carpeta:
   ```
   c:\Users\PabloAndresDiazMurci\OneDrive - Latin Logistics Colombia SAS\Documentos\DIRECTOR IT\AUTOMATIZACIONES\POD
   ```
3. GitHub Desktop detectará que ya existe un repositorio Git
4. Haz clic en **"Publish repository"** (botón azul arriba)
5. Configura:
   - **Name**: `POD-Automation-Padua`
   - **Description**: `Automatización de descarga de POD desde Padua`
   - ✅ Marca **"Keep this code private"** (recomendado)
6. Haz clic en **"Publish repository"**

¡Listo! GitHub Desktop subirá todo automáticamente.

---

## 📝 Opción 3: Script Automático (AVANZADO)

Si tienes instalado GitHub CLI correctamente, ejecuta:

```powershell
# Refrescar entorno
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Cambiar a carpeta del proyecto
cd 'c:\Users\PabloAndresDiazMurci\OneDrive - Latin Logistics Colombia SAS\Documentos\DIRECTOR IT\AUTOMATIZACIONES\POD'

# Autenticarse (solo la primera vez)
gh auth login

# Crear repositorio privado y subirlo
gh repo create POD-Automation-Padua --private --source=. --remote=origin --push
```

---

## 🔐 Seguridad: Verificar que NO se suben credenciales

El `.gitignore` ya está configurado para **excluir**:
- ❌ `WEBSITE/GUIAS.xlsx` (contiene datos de guías)
- ❌ `DESCARGA/` (archivos POD descargados)
- ❌ `.env`, `credentials.json` (credenciales)
- ❌ `*.log` (logs con posible info sensible)

**IMPORTANTE**: Las credenciales están hardcodeadas en `test_selenium_browser.py`.

### Antes de subir, puedes:

1. **Mover credenciales a variables de entorno** (recomendado)
2. **O al menos verificar** que no compartas contraseñas reales

Para verificar qué archivos se subirán:
```powershell
git status
git log --stat
```

---

## 📊 Resumen de Archivos que se Subirán

✅ **Archivos incluidos (16 archivos):**
- `test_selenium_browser.py` - Script principal
- `test_script.py` - Validador
- `test_import.py` - Test de importación
- `README.md` - Documentación principal
- `README_selenium_padua.md` - Análisis técnico
- `requirements.txt` - Dependencias
- `.gitignore` - Configuración de archivos a ignorar
- `Dockerfile`, `docker-compose.yml` - Docker
- `entrypoint.sh`, `deploy_and_run.sh` - Scripts de despliegue
- `fix_unicode.py` - Utilidad
- `install.md` - Guía de instalación
- `WEBSITE/README.md` - Documentación de carpeta

❌ **Archivos EXCLUIDOS (protegidos):**
- `WEBSITE/GUIAS.xlsx` - Datos de guías
- `DESCARGA/*` - Archivos POD descargados
- `__pycache__/`, `*.pyc` - Cache de Python

---

## 🎯 Próximos Pasos Después de Subir

1. **Configurar secretos en GitHub** (si usas GitHub Actions):
   - Settings → Secrets → New repository secret
   - Agregar `PADUA_USER` y `PADUA_PASSWORD`

2. **Invitar colaboradores** (si es privado):
   - Settings → Collaborators → Add people

3. **Crear branches para desarrollo**:
   ```bash
   git checkout -b development
   git push -u origin development
   ```

4. **Configurar GitHub Actions** (CI/CD automático):
   - Ejecutar tests automáticamente
   - Validar código con linters

---

## ❓ Preguntas Frecuentes

**P: ¿Puedo cambiar de privado a público después?**
R: Sí, en Settings → Change visibility

**P: ¿Cómo actualizo el repositorio después de hacer cambios?**
R: 
```bash
git add .
git commit -m "Descripción de cambios"
git push
```

**P: ¿Cómo bajo cambios si trabajo desde otra computadora?**
R:
```bash
git pull
```

**P: Cometí un error, ¿cómo lo deshago?**
R:
```bash
# Ver historial
git log --oneline

# Volver a commit anterior
git reset --hard COMMIT_ID
```

---

## 📞 Soporte

Si tienes problemas:
1. Verifica que tu usuario de GitHub tenga permisos
2. Asegúrate de estar autenticado correctamente
3. Revisa los logs de error en PowerShell

**Usuario configurado actualmente:**
- Nombre: `Pablo Diaz`
- Email: `pablo.diaz@latinlogistics.com.co`

Para cambiar el usuario:
```bash
git config user.name "Nuevo Nombre"
git config user.email "nuevo@email.com"
```

---

**¡Éxito con tu proyecto! 🚀**
