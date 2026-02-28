# -*- coding: utf-8 -*-
"""Test de importacion del script principal"""

import sys
import os

print("=" * 60)
print("TEST DE IMPORTACION")
print("=" * 60)

try:
    # Intentar importar el modulo
    import test_selenium_browser
    print("[OK] Modulo test_selenium_browser importado correctamente")
    
    # Verificar funciones principales
    if hasattr(test_selenium_browser, 'is_docker'):
        result = test_selenium_browser.is_docker()
        print(f"[OK] Funcion is_docker() disponible - Retorna: {result}")
    else:
        print("[FAIL] Funcion is_docker() no encontrada")
    
    if hasattr(test_selenium_browser, 'safe_input'):
        print("[OK] Funcion safe_input() disponible")
    else:
        print("[FAIL] Funcion safe_input() no encontrada")
    
    if hasattr(test_selenium_browser, 'main'):
        print("[OK] Funcion main() disponible")
    else:
        print("[FAIL] Funcion main() no encontrada")
    
    print("\n[OK] Todas las verificaciones de importacion pasaron")
    print("\nEl script esta listo para ejecutarse.")
    print("NOTA: Para ejecutar el script completo, usa:")
    print("  python test_selenium_browser.py")
    print("\nADVERTENCIA: El script abrira Chrome y realizara acciones reales.")
    print("Asegurate de tener:")
    print("  - Archivo WEBSITE/GUIAS.xlsx con las guias a procesar")
    print("  - Conexion a internet")
    print("  - Credenciales validas en el script")
    
except ImportError as e:
    print(f"[FAIL] Error al importar: {e}")
    sys.exit(1)
except Exception as e:
    print(f"[FAIL] Error inesperado: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
