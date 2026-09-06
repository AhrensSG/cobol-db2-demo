# COBOL + DB2 — Proyecto (consulta de cuentas)

Proyecto de **autoaprendizaje** del mejor plan de estudio COBOL + Mainframe.
Demuestra trabajo con IBM Enterprise COBOL y SQL embebido en DB2 para z/OS.

## Qué hace

Programa `CTA0001` que:

1. Lee números de cuenta desde un fichero de entrada (`SYSIN`).
2. Para cada cuenta ejecuta un `SELECT` con SQL embebido (DB2) usando un cursor.
3. Distingue por `SQLCODE` si la cuenta **existe** (0), **no existe** (100) o hay un **error** (otro).
4. Escribe el resultado en un fichero de salida y controla abends.

Cubre los conceptos base del plan:
- Divisiones COBOL (`IDENTIFICATION`, `ENVIRONMENT`, `DATA`, `PROCEDURE`).
- `COPY` de copybook (`CUENTA.INC`).
- Manejo de ficheros secuenciales (SELECT, FD, OPEN/READ/WRITE/CLOSE).
- SQL embebido en DB2: `DECLARE CURSOR`, `OPEN`, `FETCH`, `CLOSE`, `SQLCA`, `SQLCODE`.
- JCL de compilación/ejecución con `IGYCRCTL` + `IEWL` y `IKJEFT01`/`DSN`.

## Estructura

```
cobol-demo/
├── copybook/
│   └── CUENTA.INC        # Definición de estructura de la cuenta
├── db/
│   └── DDL_CUENTA.sql    # Creación e inserción de la tabla CUENTA (DB2)
├── jcl/
│   ├── CMPL01.jcl        # Compila + linka (IGYCRCTL + IEWL)
│   ├── RUN01.jcl         # Ejecuta en DB2 (IKJEFT01 + DSN)
│   └── entrada.txt       # Números de cuenta de prueba
└── src/
    └── CTA0001.cbl       # Programa principal
```

## Cómo ejecutarlo

Requisitos: entorno IBM Enterprise COBOL + DB2 for z/OS (p. ej. **IBM Z Xplore**, gratuito).

1. Crea la tabla e inserta datos:
   ```sql
   -- Ejecutar DDL_CUENTA.sql en el subsistema DB2
   ```
2. Pon el copybook en `MILLER.COBOL.COPYLIB` y el fuente en `MILLER.COBOL.SRC(CTA0001)`.
3. Compila y linka con `CMPL01.jcl`.
4. Ejecuta con `RUN01.jcl` (se invoca el plan `CTA0001PLAN`).
5. Salida esperada en `SALIDA`:

```
CONSULTA DE SALDOS - PROYECTO COBOL + DB2
CUENTA: ES46 0019 0020 1234 5678 9012 | TITULAR: ANA MARTINEZ RUIZ   | SALDO: +001520.75 EUR
CUENTA: ES91 2100 0418 4502 0005 1332 | TITULAR: LUCAS FERNANDEZ GIL | SALDO: +000320.40 EUR
CUENTA NO ENCONTRADA
```

## Siguientes pasos del plan (roadmap)

- [x] Mes 1: COBOL base (divisiones, PIC, ficheros, COPY) + JCL
- [x] Mes 2: SQL embebido DB2, cursors, SQLCODE → **este proyecto**
- [ ] Mes 3: CICS + BMS maps (transacción online de consulta en pantalla 3270)
- [ ] Mes 3/4: manejo de abends (S0C7, S322), debug con XPEDITER

## Autor

Guillermo Ahrens — proyecto personal de formación en stack legacy (COBOL/DB2/Mainframe).
Ver blog/portfolio en https://grupo-start.vercel.app/portfolio
