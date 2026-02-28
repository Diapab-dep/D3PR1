#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de prueba para verificar dependencias y estructura del proyecto PADUA
"""

import sys
import os

def test_imports():
    """Verifica que todas las dependencias estén instaladas"""
    print("=" * 60)
    print("VERIFICANDO DEPENDENCIAS")
    print("=" * 60)
    
    dependencies = {
        'selenium': 'selenium',
        'openpyxl': 'openpyxl',
        'pyautogui': 'pyautogui',
        'requests': 'requests',
        'urllib': 'urllib (built-in)',
        'datetime': 'datetime (built-in)',
        'os': 'os (built-in)',
        'sys': 'sys (built-in)',
        'time': 'time (built-in)',
        're': 're (built-in)',
        'shutil': 'shutil (built-in)',
    }
    
    missing = []
    for module_name, display_name in dependencies.items():
        try:
            __import__(module_name)
            print(f"[OK] {display_name}")
        except ImportError:
            print(f"[FAIL] {display_name} - NO INSTALADO")
            missing.append(display_name)
    
    if missing:
        print(f"\n[WARNING] Faltan {len(missing)} dependencia(s): {', '.join(missing)}")
        print("Instálalas con: pip install -r requirements.txt")
        return False
    else:
        print("\n[OK] Todas las dependencias están instaladas")
        return True

def test_structure():
    """Verifica la estructura de directorios"""
    print("\n" + "=" * 60)
    print("VERIFICANDO ESTRUCTURA DE DIRECTORIOS")
    print("=" * 60)
    
    base_dir = os.path.dirname(os.path.abspath(__file__))
    required_dirs = [
        ('WEBSITE', os.path.join(base_dir, 'WEBSITE')),
        ('DESCARGA', os.path.join(base_dir, 'DESCARGA')),
    ]
    
    all_ok = True
    for name, path in required_dirs:
        if os.path.exists(path):
            print(f"[OK] {name}/ existe")
        else:
            print(f"[FAIL] {name}/ NO existe - Creando...")
            try:
                os.makedirs(path, exist_ok=True)
                print(f"  [OK] {name}/ creado")
            except Exception as e:
                print(f"  [FAIL] Error creando {name}/: {e}")
                all_ok = False
    
    # Verificar archivo Excel
    excel_path = os.path.join(base_dir, 'WEBSITE', 'GUIAS.xlsx')
    if os.path.exists(excel_path):
        print(f"[OK] GUIAS.xlsx existe")
    else:
        print(f"[WARNING] GUIAS.xlsx NO existe (se creará automáticamente o debe subirse)")
    
    return all_ok

def test_script_syntax():
    """Verifica la sintaxis del script principal"""
    print("\n" + "=" * 60)
    print("VERIFICANDO SINTAXIS DEL SCRIPT")
    print("=" * 60)
    
    script_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'test_selenium_browser.py')
    
    if not os.path.exists(script_path):
        print(f"[FAIL] test_selenium_browser.py NO existe")
        return False
    
    try:
        with open(script_path, 'r', encoding='utf-8') as f:
            code = f.read()
        
        compile(code, script_path, 'exec')
        print("[OK] Sintaxis del script es valida")
        return True
    except SyntaxError as e:
        print(f"[FAIL] Error de sintaxis en linea {e.lineno}: {e.msg}")
        if e.text:
            print(f"  {e.text.strip()}")
        return False
    except Exception as e:
        print(f"[FAIL] Error al verificar sintaxis: {e}")
        return False

def test_chrome_driver():
    """Verifica si ChromeDriver está disponible"""
    print("\n" + "=" * 60)
    print("VERIFICANDO CHROMEDRIVER")
    print("=" * 60)
    
    try:
        import chromedriver_autoinstaller
        print("[OK] chromedriver-autoinstaller esta instalado")
        print("  ChromeDriver se instalara automaticamente si es necesario")
        return True
    except ImportError:
        print("[WARNING] chromedriver-autoinstaller NO esta instalado")
        print("  El script intentara buscar ChromeDriver manualmente")
        return False

def main():
    """Función principal de pruebas"""
    print("\n" + "=" * 60)
    print("PADUA - SCRIPT DE PRUEBA")
    print("=" * 60)
    print()
    
    results = {
        'imports': test_imports(),
        'structure': test_structure(),
        'syntax': test_script_syntax(),
        'chromedriver': test_chrome_driver(),
    }
    
    print("\n" + "=" * 60)
    print("RESUMEN")
    print("=" * 60)
    
    all_passed = all(results.values())
    
    for test_name, passed in results.items():
        status = "[PASS]" if passed else "[FAIL]"
        print(f"{status} - {test_name}")
    
    if all_passed:
        print("\n[OK] Todas las verificaciones pasaron")
        print("\nEl script esta listo para ejecutarse con:")
        print("  python test_selenium_browser.py")
        return 0
    else:
        print("\n[WARNING] Algunas verificaciones fallaron")
        print("Corrige los problemas antes de ejecutar el script principal")
        return 1

if __name__ == "__main__":
    sys.exit(main())
