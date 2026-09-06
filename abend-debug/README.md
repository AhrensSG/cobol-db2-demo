# Abends (S0C7, S322) y debugging con XPEDITER (proyecto personal)

Guión práctico de autoformación: **reconocer, reproducir y corregir los fallos clásicos de un proceso batch** mainframe, y depurarlo como en producción con **XPEDITER**.

## Qué contiene

| Fichero | Descripción |
|---------|-------------|
| `src/S0C7.cbl` | Programa que dispara **data exception (S0C7)**: suma un campo `9(15)V99` recibiendo datos no numéricos → abend |
| `src/S322.cbl` | Programa con bucle sin salida que **excede el tiempo del paso (S322)** |
| `src/VALIDA01.cbl` | **Versión corregida**: valida con `IS NUMERIC` antes de operar y rechaza los registros malos sin abendar |
| `jcl/CMPL03.jcl` | Compila y linkea los tres programas (IGYCRCTL + IEWL) |
| `jcl/RUN-S0C7.jcl` | Ejecuta el abend S0C7 (esperado: terminación anormal + SYSUDUMP) |
| `jcl/RUN-S322.jcl` | Ejecuta S322 con `TIME=(0,1)` para cortar el bucle en 1 minuto |
| `jcl/RUN-VALIDA01.jcl` | Ejecuta la versión corregida (fin normal, código 0) |
| `jcl/XPDTR01.jcl` | Sesión batch de debug con XPEDITER sobre `VALIDA01` |
| `data/entrada.txt` | Datos de prueba (la fila `xx.99` es la culpable) |

## Los abends más típicos en COBOL batch

### S0C7 — Data exception

- **Síntoma**: el paso termina con `IEA995I ... 0C7-00` y se genera un syso **SYSUDUMP/SYSABEND**.
- **Causa**: una operación aritmética (o un `MOVE` a un `PIC 9`) recibe bytes que no son dígitos/decimal válidos. Pasa muchísimo con ficheros de proveedores o textos convertidos.
- **Cómo encontrarlo**: en el SYSUDUMP, las PSW + los registros marcan la instrucción exacta; en el `SYSIN`, el registro que se estaba procesando.
- **Ejercicio**: `RUN-S0C7.jcl` con `data/entrada.txt` (fila `xx.99`).
- **Solución**: `VALIDAR-REGISTRO` en `VALIDA01.cbl` — comprobar `IF WS-FIELD IS NUMERIC` antes de cualquier operación y mandar el registro inválido a un fichero de rechazos.

### S322 — Step time exceeded

- **Síntoma**: `IEF450I ... JOB TERMINATED` por superar el tiempo del paso (o del job).
- **Causa**: un bucle que no avanza — típicamente un `PERFORM UNTIL` cuya condición nunca se cumple, o un `READ` en el que nunca se alcanza `AT END` y por eso la bandera de fin no se pone.
- **Cómo encontrarlo**: `SYSOUT` del paso, `SYSMDUMP` si lo generas; en XPEDITER se ve la instrucción donde está "dando vueltas".
- **Ejercicio**: `RUN-S322.jcl` con `TIME=(0,1)` (el bucle necesitaría varios minutos de CPU; el sistema lo corta con S322).
- **Solución**: revisar la condición del bucle y garantizar siempre una salida (p. ej. `AT END MOVE 'S' TO WS-EOF`); poner contadores de seguridad.

## Debugging con XPEDITER

`jcl/XPDTR01.jcl` ejecuta `VALIDA01` bajo **XPEDITER batch (`XPEDBATB`)**, que permite lo mismo que un depurador de CICS/TSO pero en lote:

- `SET BREAKPOINT ON PARA VALIDAR-REGISTRO`: se para en cada registro.
- `WATCH ON WS-TOTAL`: observa la variable del acumulado.
- `LIST ON VALIDA01`: muestra el fuente sobre el que se ejecuta.
- `TRACE AGE`, `DISPLAY WS-FIELD`: inspección en tiempo real.
- También se puede usar **FileAID** sobre los ficheros `ENTRADA/BUENOS/MALOS` para comparar el antes-después del procesamiento.

> La sintaxis de los comandos depende de la versión de Compuware XPEDITER; los del ejemplo son los usados habitualmente en entornos bancarios.

## Aviso

Proyecto personal de formación autodidacta. Demuestra el manejo práctico de los fallos más preguntados en entrevistas de COBOL/mainframe junior, no experiencia laboral previa en banca.

---

*Complementa los otros proyectos del repo: COBOL + SQL embebido (`../src` + `../db`) y CICS + BMS (`../cics-bms`).*