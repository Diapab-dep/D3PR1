# -*- coding: utf-8 -*-
"""Obtener logs actuales del contenedor POD."""
import paramiko

client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect("20.102.51.145", username="pdiaz", password="dF62(5PR7U54", timeout=15)

# Estado y logs
for cmd, desc in [
    ("docker ps -a --filter ancestor=padua-pod:latest", "Estado contenedores"),
    ("docker logs --tail 800 padua-pod-run 2>&1", "Logs (últimas 800 líneas)"),
]:
    print(f"\n=== {desc} ===\n")
    stdin, stdout, stderr = client.exec_command(cmd)
    out = stdout.read().decode("utf-8", errors="replace")
    out = out.encode("ascii", errors="replace").decode("ascii")
    print(out)

client.close()
