#!/bin/bash
# ==============================================================================
# PADUA - Entrypoint para contenedor Docker
# Inicia Xvfb (pantalla virtual) y ejecuta el script de automatización
# ==============================================================================

set -e

echo "============================================================"
echo " PADUA - POD Automation (Docker Container)"
echo " $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "============================================================"

# --------------------------------------------------------------------------
# 1. Verificar que los volúmenes estén montados correctamente
# --------------------------------------------------------------------------
echo ""
echo "[1/4] Verificando volúmenes montados..."

if [ ! -f "/app/WEBSITE/GUIAS.xlsx" ]; then
    echo "⚠ ERROR: No se encontró /app/WEBSITE/GUIAS.xlsx"
    echo "   Asegúrate de montar el volumen correctamente:"
    echo "   docker run -v /ruta/host/WEBSITE:/app/WEBSITE ..."
    exit 1
fi

echo "  ✓ /app/WEBSITE/GUIAS.xlsx encontrado"
echo "  ✓ /app/DESCARGA/ listo para escritura"

# Verificar permisos de escritura
if ! touch /app/DESCARGA/.write_test 2>/dev/null; then
    echo "⚠ ERROR: No se puede escribir en /app/DESCARGA/"
    echo "   Verifica los permisos del volumen montado."
    exit 1
fi
rm -f /app/DESCARGA/.write_test
echo "  ✓ Permisos de escritura verificados"

# --------------------------------------------------------------------------
# 2. Iniciar Xvfb (X Virtual Framebuffer)
# --------------------------------------------------------------------------
echo ""
echo "[2/4] Iniciando Xvfb (pantalla virtual ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x${DISPLAY_DEPTH})..."

# Limpiar lock files previos (por si el contenedor se reinicia)
rm -f /tmp/.X99-lock

# Iniciar Xvfb en segundo plano
Xvfb ${DISPLAY} -screen 0 ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x${DISPLAY_DEPTH} \
    -ac +extension GLX +render -noreset &

XVFB_PID=$!
sleep 2

# Verificar que Xvfb esté corriendo
if kill -0 $XVFB_PID 2>/dev/null; then
    echo "  ✓ Xvfb iniciado correctamente (PID: $XVFB_PID, DISPLAY=${DISPLAY})"
else
    echo "⚠ ERROR: Xvfb no se pudo iniciar"
    exit 1
fi

# --------------------------------------------------------------------------
# 3. Verificar componentes
# --------------------------------------------------------------------------
echo ""
echo "[3/4] Verificando componentes..."

echo "  Chrome:       $(google-chrome --version 2>/dev/null || echo 'NO DISPONIBLE')"
echo "  ChromeDriver: $(chromedriver --version 2>/dev/null || echo 'NO DISPONIBLE')"
echo "  Python:       $(python --version 2>/dev/null)"
echo "  Display:      ${DISPLAY}"
echo "  Timezone:     $(date +%Z) ($(date +%z))"

# --------------------------------------------------------------------------
# 4. Ejecutar script de automatización
# --------------------------------------------------------------------------
echo ""
echo "[4/4] Ejecutando script de automatización..."
echo "============================================================"
echo ""

# Ejecutar el script Python con salida sin buffer (-u)
# Capturar el código de salida
EXIT_CODE=0
python -u /app/test_selenium_browser.py 2>&1 | tee /app/logs/padua_$(date +%Y%m%d_%H%M%S).log || EXIT_CODE=$?

echo ""
echo "============================================================"
echo " Script finalizado con código de salida: $EXIT_CODE"
echo " $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "============================================================"

# --------------------------------------------------------------------------
# Cleanup: Detener Xvfb
# --------------------------------------------------------------------------
if kill -0 $XVFB_PID 2>/dev/null; then
    kill $XVFB_PID
    echo "  ✓ Xvfb detenido"
fi

exit $EXIT_CODE
