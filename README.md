# ⚠️ Destructive Payload Module (C2-Triggered)

## Overview

Este repositorio documenta un **payload destructivo de endpoint** diseñado para ser ejecutado de forma remota por un sistema de comando y control (C2).

El payload corresponde a la categoría de **wiper malware**, cuyo objetivo es provocar **daño irreversible en el sistema operativo**, incluyendo corrupción de datos, agotamiento de recursos y sabotaje del arranque.

> ⚠️ Este módulo está pensado únicamente para análisis, simulación o investigación en entornos controlados.

---

## Architecture Context

Este componente **no es standalone**. Forma parte de una arquitectura mayor:

```
[C2 Server] ---> [Agent / Dropper] ---> [Payload Execution (este script)]
```

### Flujo lógico

1. El C2 autentica/agrega contexto (nonce/token)
2. El agente descarga el payload
3. El payload se ejecuta localmente en el host objetivo
4. Se inicia destrucción multi-vector en paralelo
5. El sistema queda inutilizable

---

## Payload Objective

El propósito del payload es:

- Destruir integridad del sistema
- Impedir recuperación automática
- Saturar recursos para bloquear intervención
- Forzar estado no recuperable tras reinicio

---

## Execution Model

El script utiliza ejecución concurrente mediante:

- `start /b` → multiproceso en background
- `cmd /c` → invocación recursiva
- PowerShell → ejecución intensiva y evasiva

Esto permite lanzar múltiples vectores simultáneamente.

---

## Attack Vectors

### 1. Resource Exhaustion (CPU / RAM)

- Creación masiva de procesos
- Ejecución de loops infinitos en PowerShell
- Intentos de asignación de memoria en grandes bloques

**Resultado:**
- Sistema congelado
- OOM (Out Of Memory)
- Scheduler colapsado

---

### 2. Disk Saturation & File Destruction

- Creación masiva de archivos grandes (`fsutil`)
- Llenado completo del disco
- Eliminación de archivos críticos del sistema

Targets:
- `System32\config`
- `System32\drivers`

**Resultado:**
- Corrupción del sistema operativo
- Fallo de servicios esenciales

---

### 3. Boot Manipulation

- Modificación de `autoexec.bat`
- Desactivación de recuperación (`bcdedit`)
- Alteración del MBR (`bootrec`)

**Resultado:**
- Sistema no booteable
- Recuperación limitada o imposible

---

### 4. Registry Wipe

Eliminación de claves críticas:

- `HKLM\SYSTEM`
- `HKLM\SAM`
- `HKLM\SOFTWARE`
- `HKU`

**Resultado:**
- Sistema inconsistente
- Fallos de autenticación y servicios

---

### 5. Service Disruption

- Interferencia con servicios del sistema
- Configuración de servicios inválidos
- Terminación indirecta de procesos críticos

---

### 6. Fork Bomb / Process Explosion

- Generación recursiva de procesos
- Jobs infinitos en PowerShell

**Resultado:**
- Saturación total del sistema
- Inestabilidad crítica

---

### 7. Forced Reboot

- Reinicio inmediato forzado

**Resultado final:**
- Sistema inutilizable tras reinicio

---

## Classification

- **Primary:**
  - Wiper Malware

- **Secondary behaviors:**
  - Fork Bomb
  - Resource Exhaustion Attack
  - Disk Wiper
  - Registry Corruption
  - Boot Disruption

---

## Detection Considerations (Blue Team)

Indicadores clave:

- Creación masiva de procesos `cmd.exe` / `powershell.exe`
- Uso intensivo de `fsutil`
- Eliminación de claves críticas del registro
- Cambios en BCD / MBR
- Uso anómalo de CPU/RAM
- Actividad destructiva en `System32`

---

## C2 Integration Notes (Conceptual)

Este payload está diseñado para:

- Ser entregado bajo demanda
- Ejecutarse rápidamente sin dependencia externa
- Maximizar impacto en corto tiempo
- Reducir ventana de respuesta del sistema

No incluye:
- Persistencia avanzada
- Exfiltración de datos
- Comunicación post-ejecución

Es un payload de tipo **"fire-and-forget destructive"**.

---

## Safe Usage (Lab Only)

⚠️ Recomendado:

- Ejecutar solo en máquinas virtuales desechables
- Sin acceso a red o infraestructura real
- Con snapshots previos
- En entornos de análisis controlado (sandbox)

---

## Recovery

Si este payload se ejecuta:

1. Aislar el host inmediatamente
2. Intentar recuperación desde medios externos
3. En la mayoría de casos:
   - Reinstalación completa del sistema
4. Restaurar desde backups confiables

---

## Disclaimer

Este repositorio tiene fines educativos, de investigación y simulación en ciberseguridad.  
El uso indebido de este tipo de herramientas puede causar daños irreversibles.

---
