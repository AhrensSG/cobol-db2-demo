*-----------------------------------------------------------------
      * PROGRAMA: CTA0001
      * Autor:     Guillermo Ahrens (proyecto de autoaprendizaje)
      * Fecha:     2026
      *
      * Descripción:
      *   Programa COBOL con SQL embebido (DB2) que consulta el saldo
      *   de una cuenta de cliente. Es el "Proyecto 1" del plan de
      *   estudio COBOL + Mainframe:
      *     - Lee un número de cuenta desde un fichero de entrada (SYSIN)
      *     - Realiza un SELECT en la tabla CUENTA con SQL embebido (DB2)
      *     - Maneja el SQLCODE para distinguir fila encontrada/no
      *     - Escribe el resultado en un fichero de salida
      *     - Control de errores ante fallo grave
      *
      * Tecnología: COBOL + Embedded SQL (DB2) + JCL
      *
      * NOTA: proyecto de aprendizaje personal. No representa experiencia
      *       laboral ni está orientado a producción bancaria real.
      *-----------------------------------------------------------------
       IDENTIFICATION DIVISION.
       PROGRAM-ID.  CTA0001.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICH-ENTRADA ASSIGN TO ENTRADA
              ORGANIZATION IS SEQUENTIAL
              FILE STATUS IS WS-FS-ENTRADA.
           SELECT FICH-SALIDA  ASSIGN TO SALIDA
              ORGANIZATION IS SEQUENTIAL
              FILE STATUS IS WS-FS-SALIDA.

       DATA DIVISION.
       FILE SECTION.
       FD  FICH-ENTRADA.
       01  REG-ENTRADA                PIC X(20).
       FD  FICH-SALIDA.
       01  REG-SALIDA                 PIC X(120).

       WORKING-STORAGE SECTION.

      *  Estados de fichero (FILE STATUS)
       01  WS-FS-ENTRADA              PIC X(2).
       01  WS-FS-SALIDA               PIC X(2).

      *  Copia la estructura de una cuenta
           COPY CUENTA.

      *  Variables utilitarias
       01  WS-INPUT-RECORD.
           05 WS-IN-NUM-CUENTA        PIC X(20).
       01  WS-EOF                     PIC X(1) VALUE 'N'.
           88 WS-FIN                  VALUE 'S'.
       01  WS-OUT-LINE                PIC X(120).
       01  WS-MSG                     PIC X(80).
       01  WS-SQLCODE-TEXT            PIC -(7).

      *  SQLCA: área de comunicación SQL de DB2
           EXEC SQL
              INCLUDE SQLCA
           END-EXEC.

      *  DECLARE CURSOR para lectura de cuentas
           EXEC SQL
              DECLARE C1 CURSOR FOR
                 SELECT NUM_CUENTA, TITULAR, SALDO,
                        DIVISA, ESTADO, FECHA_ALTA
                   FROM CUENTA
                  WHERE NUM_CUENTA = :WS-IN-NUM-CUENTA
              FOR READ ONLY
           END-EXEC.

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           PERFORM ABRIR-FICHEROS
           PERFORM LEER-ENTRADA
           PERFORM UNTIL WS-FIN
              PERFORM CONSULTAR-CUENTA
              PERFORM LEER-ENTRADA
           END-PERFORM
           PERFORM CERRAR-FICHEROS
           GOBACK.

       ABRIR-FICHEROS.
           OPEN INPUT  FICH-ENTRADA
                OUTPUT FICH-SALIDA
           PERFORM ESCRIBIR-CABECERA.

       LEER-ENTRADA.
           READ FICH-ENTRADA INTO WS-INPUT-RECORD
              AT END
                 MOVE 'S' TO WS-EOF
           END-READ.

       CONSULTAR-CUENTA.
      *  Abrimos el cursor, ejecutamos la consulta y leemos la fila
           EXEC SQL
              OPEN C1
           END-EXEC
           EVALUATE SQLCODE
              WHEN 0
                 EXEC SQL
                    FETCH C1 INTO :WS-CUENTA-NUM,
                                  :WS-CUENTA-TITULAR,
                                  :WS-CUENTA-SALDO,
                                  :WS-CUENTA-DIVISA,
                                  :WS-CUENTA-ESTADO,
                                  :WS-CUENTA-FECHA-ALTA
                 END-EXEC
                 EVALUATE SQLCODE
                    WHEN 0
                       PERFORM ESCRIBIR-CUENTA
                    WHEN 100
                       MOVE 'CUENTA NO ENCONTRADA' TO WS-MSG
                       PERFORM ESCRIBIR-MENSAJE
                    WHEN OTHER
                       PERFORM GESTIONAR-ERROR-SQL
                 END-EVALUATE
              WHEN 100
                 MOVE 'CUENTA NO ENCONTRADA' TO WS-MSG
                 PERFORM ESCRIBIR-MENSAJE
              WHEN OTHER
                 PERFORM GESTIONAR-ERROR-SQL
           END-EVALUATE
           EXEC SQL
              CLOSE C1
           END-EXEC.

       ESCRIBIR-CUENTA.
           STRING 'CUENTA: '       DELIMITED BY SIZE
                  WS-CUENTA-NUM    DELIMITED BY SIZE
                  ' | TITULAR: '   DELIMITED BY SIZE
                  WS-CUENTA-TITULAR DELIMITED BY SIZE
                  ' | SALDO: '     DELIMITED BY SIZE
                  WS-CUENTA-SALDO  DELIMITED BY SIZE
                  ' ' WS-CUENTA-DIVISA DELIMITED BY SIZE
             INTO WS-OUT-LINE
           END-STRING
           WRITE REG-SALIDA FROM WS-OUT-LINE.

       ESCRIBIR-MENSAJE.
           WRITE REG-SALIDA FROM WS-MSG.

       ESCRIBIR-CABECERA.
           MOVE 'CONSULTA DE SALDOS - PROYECTO COBOL + DB2'
             TO WS-OUT-LINE
           WRITE REG-SALIDA FROM WS-OUT-LINE.

       GESTIONAR-ERROR-SQL.
           MOVE SQLCODE TO WS-SQLCODE-TEXT
           STRING 'ERROR SQLCODE=' WS-SQLCODE-TEXT
                  ' EN CONSULTA DE CUENTA' DELIMITED BY SIZE
             INTO WS-OUT-LINE
           END-STRING
           WRITE REG-SALIDA FROM WS-OUT-LINE
           PERFORM CERRAR-FICHEROS
           GOBACK.

       CERRAR-FICHEROS.
           CLOSE FICH-ENTRADA
                 FICH-SALIDA.