# -*- coding: utf-8 -*-
"""Script temporal para validar logs del Docker remoto. NO COMMITEAR."""
import paramiko
import sys

HOST = "20.102.51.145"
USER = "pdiaz"
PASS = "dF62(5PR7U54"

def run_ssh(client, cmd, desc=""):
    stdin, stdout, stderr = client.exec_command(cmd)
    out = stdout.read().decode("utf-8", errors="replace")
    err = stderr.read().decode("utf-8", errors="replace")
    if desc:
        print(f"\n=== {desc} ===")
    print(out if out else err or "(vacío)")
    return out, err

def main():
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        print(f"Conectando a {USER}@{HOST}...")
        client.connect(HOST, username=USER, password=PASS, timeout=15)
        print("[OK] Conectado.\n")

        # 1. Docker: contenedores y logs
        run_ssh(client, "docker ps -a 2>&1", "CONTENEDORES DOCKER")
        run_ssh(client, "docker ps -q 2>/dev/null | head -1", "")
        stdin, stdout, stderr = client.exec_command("docker ps -q 2>/dev/null | head -1")
        cid = stdout.read().decode().strip()
        if cid:
            run_ssh(client, f"docker logs --tail 300 {cid} 2>&1", f"LOGS DOCKER (últimas 300 líneas) - {cid[:12]}")
        else:
            run_ssh(client, f"echo '{PASS}' | sudo -S docker ps -a 2>&1", "DOCKER CON SUDO")
            stdin, stdout, stderr = client.exec_command(f"echo '{PASS}' | sudo -S docker ps -aq 2>/dev/null | head -1")
            cid = stdout.read().decode().strip()
            if cid:
                run_ssh(client, f"echo '{PASS}' | sudo -S docker logs --tail 300 {cid} 2>&1", f"LOGS DOCKER (sudo) - {cid[:12]}")

        # 2. Logs del sistema (si hay acceso)
        run_ssh(client, "tail -100 /var/log/syslog 2>/dev/null || echo 'Sin acceso a syslog'", "SYSLOG (últimas 100)")
        run_ssh(client, "journalctl -n 50 --no-pager 2>/dev/null || echo 'Sin acceso a journalctl'", "JOURNALCTL (últimas 50)")
        run_ssh(client, "dmesg | tail -30 2>/dev/null || echo 'Sin acceso a dmesg'", "KERNEL (dmesg)")

        # 3. Procesos y recursos
        run_ssh(client, "ps aux | grep -E 'docker|python|chrome' | grep -v grep | head -20", "PROCESOS RELEVANTES")

        client.close()
        print("\n[OK] Validación completada.")
    except Exception as e:
        print(f"[FAIL] Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
