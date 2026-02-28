# -*- coding: utf-8 -*-
"""Script para reemplazar caracteres Unicode problemáticos en Windows"""

import re

# Leer el archivo
with open('test_selenium_browser.py', 'r', encoding='utf-8') as f:
    content = f.read()

# Reemplazar caracteres Unicode
content = content.replace('\u2713', '[OK]')  # ✓
content = content.replace('\u2717', '[FAIL]')  # ✗
content = content.replace('\u26a0', '[WARNING]')  # ⚠

# Reemplazar también en strings con escape
content = re.sub(r'\\u2713', '[OK]', content)
content = re.sub(r'\\u2717', '[FAIL]', content)
content = re.sub(r'\\u26a0', '[WARNING]', content)

# Guardar el archivo
with open('test_selenium_browser.py', 'w', encoding='utf-8') as f:
    f.write(content)

print("Caracteres Unicode reemplazados correctamente")
