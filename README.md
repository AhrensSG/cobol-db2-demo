# COBOL + Mainframe — proyecto personal de formación

Tres proyectos de un plan de 4 meses en el stack mainframe: **COBOL + SQL embebido en DB2**, **CICS + BMS** (transacciones online en pantallas 3270) y **abends + debugging con XPEDITER**.

El proyecto principal (raíz del repo) es un programa en **IBM Enterprise COBOL** con **SQL embebido en DB2** que consulta los saldos de cuentas bancarias usando un cursor, maneja `SQLCODE` (encontrado / no encontrado / error) y lee/escribe ficheros secuenciales con su JCL de compilación y ejecución.

## Por qué estoy aprendiendo COBOL

Soy desarrollador backend con experiencia en **TypeScript, Node.js y NestJS** (microservicios, APIs REST/GraphQL, PostgreSQL, testing). Decidí sumar COBOL/mainframe a mi perfil por dos razones:

1. **Demanda real**: consultoras y banca (BBVA, entidades similares) buscan de forma constante perfiles junior en formación para sostener y modernizar sistemas legacy. Son posiciones con sueldo competitivo, estabilidad y oportunidades de migración a stack moderno.
2. **Aprendizaje de base**: tocar COBOL y SQL embebido me está haciendo mejor ingeniero — me obliga a pensar en precisión de datos, layout de registros, control de condiciones y procesos por lotes de una manera que no aparece en el mundo web.

No presento esto como experiencia laboral en banca: es un **proyecto personal de aprendizaje** que demuestra iniciativa y que cuento con la base para crecer dentro de un equipo mainframe.

## Mi experiencia con COBOL hasta ahora

Estoy siguiendo un plan de 4 meses. Lo que llevo hecho y lo que me toca:

- [x] **Mes 1 — COBOL base + JCL**
  Divisiones del lenguaje, `PIC`, trabajo con ficheros secuenciales, `COPY` de copybooks y JCL de compilación/ejecución.
- [x] **Mes 2 — SQL embebido en DB2**
  Este repositorio. `DECLARE CURSOR`, `OPEN`/`FETCH`/`CLOSE`, comunicación con DB2 vía `SQLCA` y manejo de resultados por `SQLCODE`.
- [x] **Mes 3 — CICS + BMS**
  Mini aplicación online de cuentas (alta/consulta/baja) en pantallas 3270 con maps BMS — ver `cics-bms/`.
- [x] **Mes 4 — Abends y debugging**
  Reproducción y corrección de `S0C7`/`S322` y depuración con XPEDITER — ver `abend-debug/`.

Lo que más me está aportando esta experiencia: leer un registro como bytes con una máscara exacta, validar cada condición de retorno de SQL y entender el flujo completo de compilación → linkeo → ejecución en z/OS.

## Qué hace este programa

Un programa de ejemplo (`CTA0001`) que:

1. Lee números de cuenta desde un fichero de entrada.
2. Para cada cuenta ejecuta un `SELECT` con SQL embebido en DB2 usando un cursor.
3. Distingue si la cuenta **existe** (`SQLCODE 0`), **no existe** (`SQLCODE 100`) o hay un **error**.
4. Escribe los resultados en un fichero de salida y controla terminación anormal (abend).

Cubre: copybooks con `COPY CUENTA`, ficheros secuenciales (`OPEN`/`READ`/`WRITE`/`CLOSE`), SQL embebido con `SQLCA`/`SQLCODE`, y JCL completo (`IGYCRCTL` + `IEWL` para compilar, `IKJEFT01`/`DSN` para ejecutar).

## Estructura

El repo contiene los **tres proyectos del plan**:

```
├── src/                  # Mes 2 — COBOL + SQL embebido DB2 (consulta de cuentas)
│   ├── copybook/
│   │   └── CUENTA.INC        # Copybook de la cuenta
│   ├── db/
│   │   └── DDL_CUENTA.sql    # Creación de la tabla CUENTA + datos (DB2)
│   ├── jcl/
│   │   ├── CMPL01.jcl        # Compilación + linkeo (IGYCRCTL + IEWL)
│   │   ├── RUN01.jcl         # Ejecución en DB2 (IKJEFT01 + DSN)
│   │   └── entrada.txt       # Números de cuenta de prueba
│   └── src/
│       └── CTA0001.cbl       # Programa principal en COBOL
├── cics-bms/             # Mes 3 — CICS + BMS (aplicación online 3270)
└── abend-debug/          # Mes 4 — Abends (S0C7, S322) + debugging XPEDITER
```

Cada proyecto tiene su propio README con la explicación y cómo desplegarlo/ejecutarlo.

## Cómo ejecutarlo

Requisitos: un entorno IBM Enterprise COBOL + DB2 for z/OS. La vía más accesible es **IBM Z Xplore** (gratuito).

1. Crear la tabla e insertar los datos: ejecutar `db/DDL_CUENTA.sql` en el subsistema DB2.
2. Colocar el fuente en la librería de fuentes y el copybook en la copylib de tu usuario (ajusta los nombres de `MILLER.*` en los JCL a tu TSO ID).
3. Compilar y linkear con `jcl/CMPL01.jcl`.
4. Ejecutar con `jcl/RUN01.jcl` (usa el plan `CTA0001PLAN`).
5. Salida esperada en `SALIDA`:

```
CONSULTA DE SALDOS - PROYECTO COBOL + DB2
CUENTA: ES46 0019 0020 1234 5678 9012 | TITULAR: ANA MARTINEZ RUIZ   | SALDO: +001520.75 EUR
CUENTA: ES91 2100 0418 4502 0005 1332 | TITULAR: LUCAS FERNANDEZ GIL | SALDO: +000320.40 EUR
CUENTA NO ENCONTRADA
```

## Sobre mí

**Guillermo Ahrens** — Desarrollador backend (TypeScript, Node.js, NestJS, Next.js) ampliando su perfil hacia el ecosistema mainframe.

- Portfolio: https://gahrens-portfolio.vercel.app
- GitHub: https://github.com/AhrensSG
- Email: guillermoahrens@gmail.com