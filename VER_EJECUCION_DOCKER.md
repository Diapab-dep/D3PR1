# Cómo ver la ejecución del proyecto POD en Docker

## Opción 1: Ver logs en vivo (recomendado)

1. **Abre una terminal nueva** (PowerShell o CMD)
2. **Conecta al servidor:**
   ```
   ssh pdiaz@20.102.51.145
   ```
   (Contraseña: la configurada para pdiaz)

3. **Sigue los logs en tiempo real:**
   ```
   docker logs -f padua-pod-run
   ```
   - `-f` = follow (muestra la salida en vivo)
   - Presiona **Ctrl+C** para dejar de seguir

## Opción 2: Ver logs ya generados

```
ssh pdiaz@20.102.51.145
docker logs padua-pod-run
```

Para ver solo las últimas 500 líneas:
```
docker logs --tail 500 padua-pod-run
```

## Opción 3: Desde el script local

Ejecuta en tu máquina:
```
python get_docker_logs.py
```

## Guías configuradas actualmente

El archivo `GUIAS.xlsx` en el servidor contiene:
- 999093732869
- 121483818
- 999093732870

Para cambiar las guías, edita la variable `GUIAS` en `run_docker_remote.py` y vuelve a ejecutar.
