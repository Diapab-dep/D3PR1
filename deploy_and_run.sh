#!/bin/bash
# ==============================================================================
# PADUA - Script de despliegue y ejecución automática
# ==============================================================================
# Este script:
#   1. Construye la imagen Docker (si es necesario)
#   2. Ejecuta el contenedor con los volúmenes montados
#   3. Captura logs con timestamp
#   4. Limpia contenedores detenidos
#
# Uso manual:
#   chmod +x deploy_and_run.sh
#   ./deploy_and_run.sh
#
# Uso con crontab (todos los días a las 6:00 AM hora Colombia):
#   0 6 * * * /opt/padua/deploy_and_run.sh >> /opt/padua/data/logs/cron.log 2>&1
# ==============================================================================

set -euo pipefail

# --------------------------------------------------------------------------
# Configuración (AJUSTAR SEGÚN TU AZURE VM)
# --------------------------------------------------------------------------
PROJECT_DIR="/opt/padua"                          # Donde está el código fuente
DATA_DIR="/opt/padua/data"                        # Datos persistentes en el host
IMAGE_NAME="padua-pod"                            # Nombre de la imagen Docker
IMAGE_TAG="latest"                                # Tag de la imagen
CONTAINER_NAME="padua-pod-run-$(date +%Y%m%d_%H%M%S)"  # Nombre único por ejecución
LOG_DIR="${DATA_DIR}/logs"                        # Directorio de logs
MAX_LOG_DAYS=30                                   # Días de retención de logs

# --------------------------------------------------------------------------
# Colores para output
# --------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() { echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"; }
log_ok() { echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] ✓${NC} $1"; }
log_warn() { echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] ⚠${NC} $1"; }
log_error() { echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ✗${NC} $1"; }

# --------------------------------------------------------------------------
# 0. Pre-checks
# --------------------------------------------------------------------------
log "============================================================"
log " PADUA - Despliegue Automatizado"
log "============================================================"

# Verificar Docker
if ! command -v docker &>/dev/null; then
    log_error "Docker no está instalado. Instálalo primero."
    exit 1
fi

# Verificar que Docker daemon esté corriendo
if ! docker info &>/dev/null; then
    log_error "Docker daemon no está corriendo. Inícialo con: sudo systemctl start docker"
    exit 1
fi

log_ok "Docker disponible: $(docker --version)"

# --------------------------------------------------------------------------
# 1. Crear estructura de directorios en el host
# --------------------------------------------------------------------------
log ""
log "[1/5] Verificando estructura de directorios..."

mkdir -p "${DATA_DIR}/WEBSITE"
mkdir -p "${DATA_DIR}/DESCARGA"
mkdir -p "${LOG_DIR}"

# Verificar que exista el Excel de entrada
if [ ! -f "${DATA_DIR}/WEBSITE/GUIAS.xlsx" ]; then
    log_error "No se encontró ${DATA_DIR}/WEBSITE/GUIAS.xlsx"
    log_error "Sube el archivo antes de ejecutar."
    exit 1
fi

log_ok "Estructura de directorios verificada"
log "  Input:  ${DATA_DIR}/WEBSITE/GUIAS.xlsx"
log "  Output: ${DATA_DIR}/DESCARGA/"
log "  Logs:   ${LOG_DIR}/"

# --------------------------------------------------------------------------
# 2. Construir imagen Docker (solo si cambió el código)
# --------------------------------------------------------------------------
log ""
log "[2/5] Verificando imagen Docker..."

cd "${PROJECT_DIR}"

# Verificar si la imagen existe
if docker image inspect "${IMAGE_NAME}:${IMAGE_TAG}" &>/dev/null; then
    # Verificar si hay cambios en el código fuente
    IMAGE_DATE=$(docker image inspect "${IMAGE_NAME}:${IMAGE_TAG}" --format='{{.Created}}' 2>/dev/null)
    log "  Imagen existente creada: ${IMAGE_DATE}"

    # Reconstruir si el Dockerfile o el script cambiaron
    NEEDS_REBUILD=false
    for f in Dockerfile requirements.txt test_selenium_browser.py entrypoint.sh; do
        if [ -f "$f" ] && [ "$f" -nt ".last_build" ] 2>/dev/null; then
            NEEDS_REBUILD=true
            break
        fi
    done

    if [ "$NEEDS_REBUILD" = true ]; then
        log_warn "Archivos fuente cambiaron. Reconstruyendo imagen..."
        docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" . 2>&1 | tail -5
        touch .last_build
        log_ok "Imagen reconstruida exitosamente"
    else
        log_ok "Imagen actualizada, no requiere reconstrucción"
    fi
else
    log "  Imagen no encontrada. Construyendo por primera vez..."
    docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" . 2>&1 | tail -20
    touch .last_build
    log_ok "Imagen construida exitosamente"
fi

# --------------------------------------------------------------------------
# 3. Limpiar contenedores anteriores
# --------------------------------------------------------------------------
log ""
log "[3/5] Limpiando contenedores anteriores..."

# Detener y eliminar contenedores padua previos
STOPPED=$(docker ps -a --filter "name=padua-pod-run" --filter "status=exited" -q)
if [ -n "$STOPPED" ]; then
    docker rm $STOPPED &>/dev/null || true
    log_ok "Contenedores anteriores limpiados"
else
    log "  No hay contenedores anteriores para limpiar"
fi

# --------------------------------------------------------------------------
# 4. Ejecutar contenedor
# --------------------------------------------------------------------------
log ""
log "[4/5] Ejecutando contenedor: ${CONTAINER_NAME}..."
log "============================================================"

LOG_FILE="${LOG_DIR}/padua_$(date +%Y%m%d_%H%M%S).log"

docker run \
    --name "${CONTAINER_NAME}" \
    --rm \
    --shm-size=2g \
    -e DISPLAY=:99 \
    -e TZ=America/Bogota \
    -e RUNNING_IN_DOCKER=true \
    -e PYTHONUNBUFFERED=1 \
    -e PYTHONIOENCODING=utf-8 \
    -v "${DATA_DIR}/WEBSITE:/app/WEBSITE" \
    -v "${DATA_DIR}/DESCARGA:/app/DESCARGA" \
    -v "${LOG_DIR}:/app/logs" \
    --memory=4g \
    --cpus=2 \
    "${IMAGE_NAME}:${IMAGE_TAG}" \
    2>&1 | tee "${LOG_FILE}"

EXIT_CODE=${PIPESTATUS[0]}

log ""
log "============================================================"

# --------------------------------------------------------------------------
# 5. Reporte de resultado
# --------------------------------------------------------------------------
log ""
log "[5/5] Resultado de la ejecución..."

if [ $EXIT_CODE -eq 0 ]; then
    log_ok "Ejecución completada exitosamente"

    # Contar archivos descargados hoy
    TODAY=$(date +%Y%m%d)
    if [ -d "${DATA_DIR}/DESCARGA/${TODAY}" ]; then
        TOTAL_GUIAS=$(ls -d "${DATA_DIR}/DESCARGA/${TODAY}"/*/ 2>/dev/null | wc -l)
        TOTAL_PDFS=$(find "${DATA_DIR}/DESCARGA/${TODAY}" -name "*.pdf" 2>/dev/null | wc -l)
        log_ok "Guías procesadas: ${TOTAL_GUIAS}"
        log_ok "PDFs descargados: ${TOTAL_PDFS}"
    fi
else
    log_error "Ejecución falló con código: ${EXIT_CODE}"
    log_error "Revisa el log: ${LOG_FILE}"
fi

# --------------------------------------------------------------------------
# 6. Limpieza de logs antiguos
# --------------------------------------------------------------------------
log ""
log "Limpiando logs mayores a ${MAX_LOG_DAYS} días..."
find "${LOG_DIR}" -name "padua_*.log" -mtime +${MAX_LOG_DAYS} -delete 2>/dev/null || true
log_ok "Limpieza completada"

log ""
log "Log de esta ejecución: ${LOG_FILE}"
log "============================================================"

exit $EXIT_CODE
