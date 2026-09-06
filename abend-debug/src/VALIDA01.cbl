IDENTIFICATION DIVISION.
       PROGRAM-ID. VALIDA01.
       AUTHOR. GUILLERMO AHRENS.
      *-----------------------------------------------------------------
      * VERSION CORREGIDA del programa S0C7.
      *
      * Antes de usar un campo numerico se valida con la condicion de
      * clase IS NUMERIC. Los registros invalidos no abendan: se escriben
      * en el fichero MALOS y el proceso continua con el resto.
      *
      * Tambien se usa como candidato de la sesion de depuracion con
      * XPEDITER (ver jcl/XPDTR01.jcl).
      *-----------------------------------------------------------------
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ENT-FILE ASSIGN TO ENTRADA
                  ORGANIZATION IS SEQUENTIAL.
           SELECT BUENOS   ASSIGN TO BUENOS
                  ORGANIZATION IS SEQUENTIAL.
           SELECT MALOS    ASSIGN TO MALOS
                  ORGANIZATION IS SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD ENT-FILE.
       01 ENT-REC PIC X(12).
       FD BUENOS.
       01 BUEN-REC PIC X(40).
       FD MALOS.
       01 MAL-REC PIC X(40).
       WORKING-STORAGE SECTION.
       01 WS-EOF   PIC X VALUE 'N'.
       01 WS-FIELD PIC X(12).
       01 WS-SALDO PIC 9(15)V99.
       01 WS-TOTAL PIC 9(15)V99 VALUE 0.
       01 WS-LINEA PIC X(40).
       PROCEDURE DIVISION.
       MAIN.
           OPEN INPUT ENT-FILE
                OUTPUT BUENOS MALOS.
           PERFORM UNTIL WS-EOF = 'S'
              READ ENT-FILE INTO WS-FIELD
                 AT END
                    MOVE 'S' TO WS-EOF
                 NOT AT END
                    PERFORM VALIDAR-REGISTRO
              END-READ
           END-PERFORM.
           MOVE WS-TOTAL TO WS-LINEA.
           WRITE BUEN-REC FROM WS-LINEA.
           CLOSE ENT-FILE BUENOS MALOS.
           GOBACK.
       VALIDAR-REGISTRO.
      *-> Solo se opera con datos numericos validos
           IF WS-FIELD IS NUMERIC
              MOVE WS-FIELD TO WS-SALDO
              ADD WS-SALDO TO WS-TOTAL
              WRITE BUEN-REC FROM WS-FIELD
           ELSE
              MOVE SPACES TO WS-LINEA
              STRING 'RECHAZADO NO NUMERICO: ' DELIMITED BY SIZE
                     WS-FIELD  DELIMITED BY SIZE
                     INTO WS-LINEA
              END-STRING
              WRITE MAL-REC FROM WS-LINEA
           END-IF.