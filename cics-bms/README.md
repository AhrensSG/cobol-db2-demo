# CICS + BMS — mini app online de cuentas (proyecto personal)

Mini aplicación **online en pantallas 3270** desarrollada con **CICS** y **BMS**, conectada a **DB2** en tiempo real. Forma parte de mi estudio autodidacta de COBOL/Mainframe: una transacción de banca con **alta / consulta / baja de cuentas** desde un terminal.

## Qué hace

Un terminal 3270 muestra un mapa (`M1` del mapset `CUST`) con los datos de una cuenta. Según la tecla de función que pulse el operador:

| Tecla | Operación | SQL embebido |
|-------|-----------|--------------|
| **PF4** | Consulta de saldo | `SELECT` (una fila) |
| **PF2** | Alta de cuenta (saldo inicial 0, divisa EUR) | `INSERT` |
| **PF3** | Baja de cuenta | `DELETE` |

El programa distingue por `SQLCODE` los casos **existe / no existe / error DB2** y por `-803` el **duplicado** en el alta. Además controla errores de pantalla (`RESP`) y de programa con **`HANDLE ABEND`**.

## Estructura

```
cics-bms/
├── maps/
│   └── CUST.map           # Mapset BMS (pantalla 3270) con el mapa M1
├── cics/
│   └── CUST001.cob        # Programa CICS + DB2 (RECEIVE/SEND MAP, HANDLE AID)
├── jcl/
│   ├── ASMMAP01.jcl       # Ensambla el mapset BMS (ASMA90) -> load + copybook
│   ├── LINKMAP.jcl        # Linkea el objeto del mapa a la LOADLIB
│   └── CMPLCICS.jcl       # Traductor CICS + precompilador DB2 + COBOL + LINK
└── README.md
```

La tabla `CUENTA` es la misma del proyecto principal de consulta de cuentas (`../db/DDL_CUENTA.sql`).

## Conceptos que cubre

- **BMS**: macros `DFHMSD` / `DFHMDI` / `DFHMDF`, atributos de campo (`UNPROT`, `ASKIP`, `IC`, `BRT`), generación del **copybook simbólico** (`COPY CUST`).
- **CICS**: `SEND MAP`, `RECEIVE MAP`, `HANDLE AID` (teclas de función), `HANDLE ABEND`, `SEND TEXT`, `RESP` para validar respuestas.
- **CICS + DB2**: SQL embebido desde un programa CICS (precompilado con `DSNHPC`, linkeado con `DFHELII` + `DSNHLI`).
- **Pipeline de compilación** CICS → DB2 → COBOL → LINK.

## Cómo montarlo

1. **Base de datos**: ejecuta `db/DDL_CUENTA.sql` (véase raíz del repo) en DB2.
2. **Ensambla el mapa**: `ASMMAP01.jcl` genera el load module `CUST` y el copybook simbólico `CUST`.
3. **Linkea el mapa**: `LINKMAP.jcl` a la LOADLIB de CICS.
4. **Compila el programa**: `CMPLCICS.jcl` produce `CUST001` en la LOADLIB y un **DBRM** por el precompilador.
5. **Bind del DBRM** en DB2 (conexión CICS↔DB2):
   ```
   BIND PLAN(CUSTPLAN) MEMBER(CUST001) ACT(REP) ISO(CS)
   ```
6. **Define la transacción y el programa** en el CSD con **CEDA** (grupo `GRPCUST`):
   ```
   CEDA DEFINE PROGRAM(CUST001) GROUP(GRPCUST) LANGUAGE(COBOL) DATAFILE(YES)
   CEDA DEFINE TRANSACTION(CU01) PROGRAM(CUST001) GROUP(GRPCUST)
   CEDA INSTALL GROUP(GRPCUST)
   ```
7. Lanza en el terminal 3270 la transacción `CU01`, escribe un número de cuenta y pulsa **PF4** para consultar.

## Aviso

Proyecto personal de formación autodidacta en CICS/BMS. No representa experiencia laboral previa en entornos mainframe; demuestra iniciativa para perfiles junior en consultoras y banca.

---

*Complementa el otro proyecto del repo: abends (S0C7, S322) y debug con XPEDITER — ver `../abend-debug/`.*