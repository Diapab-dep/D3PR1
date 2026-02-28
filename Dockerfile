# ==============================================================================
# PADUA - Automatización de descarga de POD
# Dockerfile para Azure VM (Linux Ubuntu)
# ==============================================================================
# Requiere: Xvfb (display virtual), Chrome, ChromeDriver, PyAutoGUI
# ==============================================================================

FROM python:3.12-slim

LABEL maintainer="Latin Logistics Colombia SAS - IT Director"
LABEL project="PADUA - POD Automation"
LABEL version="1.0"

# ------------------------------------------------------------------------------
# 1. Variables de entorno
# ------------------------------------------------------------------------------
ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:99 \
    DISPLAY_WIDTH=1920 \
    DISPLAY_HEIGHT=1080 \
    DISPLAY_DEPTH=24 \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=utf-8 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=America/Bogota

# ------------------------------------------------------------------------------
# 2. Dependencias del sistema (optimizado con cache de capas)
# ------------------------------------------------------------------------------
# Instalar dependencias en una sola capa para mejor cacheo
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Herramientas base
    wget \
    curl \
    unzip \
    gnupg2 \
    ca-certificates \
    apt-transport-https \
    software-properties-common \
    # Xvfb - X Virtual Framebuffer (pantalla virtual)
    xvfb \
    x11-utils \
    xdg-utils \
    # Dependencias de PyAutoGUI / GUI
    python3-tk \
    python3-dev \
    scrot \
    xdotool \
    xclip \
    # Fuentes y rendering
    fonts-liberation \
    fonts-noto-color-emoji \
    libfontconfig1 \
    libnss3 \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    libgbm1 \
    libasound2 \
    libxss1 \
    libappindicator3-1 \
    libindicator3-7 \
    libxrandr2 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libcups2 \
    libdrm2 \
    libpango-1.0-0 \
    libcairo2 \
    # Timezone
    tzdata \
    && ln -sf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

# ------------------------------------------------------------------------------
# 3. Instalar Google Chrome (última versión estable) - Optimizado
# ------------------------------------------------------------------------------
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
       > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends google-chrome-stable \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && google-chrome --version

# ------------------------------------------------------------------------------
# 4. Instalar ChromeDriver (versión compatible con Chrome instalado) - Optimizado
# ------------------------------------------------------------------------------
RUN CHROME_VERSION=$(google-chrome --version | grep -oP '\d+\.\d+\.\d+') \
    && echo "Chrome version: $CHROME_VERSION" \
    && CHROME_MAJOR=$(echo $CHROME_VERSION | cut -d. -f1) \
    && echo "Chrome major version: $CHROME_MAJOR" \
    # Obtener la URL de ChromeDriver desde el JSON de versiones
    && CHROMEDRIVER_URL=$(curl -s "https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json" \
       | python3 -c "
import json, sys
data = json.load(sys.stdin)
target = '$CHROME_VERSION'
best = None
for v in data['versions']:
    if v['version'].startswith('$CHROME_MAJOR.'):
        if 'chromedriver' in v.get('downloads', {}):
            for d in v['downloads']['chromedriver']:
                if d['platform'] == 'linux64':
                    best = d['url']
if best:
    print(best)
else:
    # Fallback: usar LATEST_RELEASE
    sys.exit(1)
") \
    && echo "ChromeDriver URL: $CHROMEDRIVER_URL" \
    && wget -q "$CHROMEDRIVER_URL" -O /tmp/chromedriver.zip \
    && unzip -o /tmp/chromedriver.zip -d /tmp/chromedriver_extract \
    && find /tmp/chromedriver_extract -name "chromedriver" -type f -exec mv {} /usr/local/bin/chromedriver \; \
    && chmod +x /usr/local/bin/chromedriver \
    && rm -rf /tmp/chromedriver.zip /tmp/chromedriver_extract /tmp/* \
    && chromedriver --version

# ------------------------------------------------------------------------------
# 5. Directorio de trabajo y dependencias Python
# ------------------------------------------------------------------------------
WORKDIR /app

COPY requirements.txt .
# Optimizado: usar pip cache y actualizar en una sola capa
RUN pip install --no-cache-dir --upgrade pip setuptools wheel \
    && pip install --no-cache-dir -r requirements.txt \
    && pip cache purge || true

# ------------------------------------------------------------------------------
# 6. Copiar código fuente
# ------------------------------------------------------------------------------
COPY test_selenium_browser.py .
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# ------------------------------------------------------------------------------
# 7. Crear directorios de datos (serán montados como volúmenes)
# ------------------------------------------------------------------------------
RUN mkdir -p /app/WEBSITE /app/DESCARGA /app/logs

# ------------------------------------------------------------------------------
# 8. Entrypoint
# ------------------------------------------------------------------------------
ENTRYPOINT ["/app/entrypoint.sh"]
