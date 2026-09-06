IDENTIFICATION DIVISION.
       PROGRAM-ID. S0C7.
       AUTHOR. GUILLERMO AHRENS.
      *-----------------------------------------------------------------
      * DEMO ABEND S0C7 (DATA EXCEPTION)
      *
      * Lee un fichero de saldos y va sumando. La linea "xx.99" del
      * fichero lleva caracteres no numericos: al hacer ADD sobre un
      * campo numerico se dispara el abend S0C7 (data exception).
      *
      * Objetivo del ejercicio: ver el abend, leer el SYSUDUMP/SYSOUT
      * y aplicar la solucion (programa VALIDA01, que valida con la
      * condicion de clase IS NUMERIC antes de sumar).
      *-----------------------------------------------------------------
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ENT-FILE ASSIGN TO ENTRADA
                  ORGANIZATION IS SEQUENTIAL.
           SELECT SAL-FILE ASSIGN TO SALIDA
                  ORGANIZATION IS SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD ENT-FILE.
       01 ENT-REC PIC X(12).
       FD SAL-FILE.
       01 SAL-REC PIC X(40).
       WORKING-STORAGE SECTION.
       01 WS-EOF      PIC X VALUE 'N'.
       01 WS-SALDO    PIC 9(15)V99.
       01 WS-TOTAL    PIC 9(15)V99 VALUE 0.
       01 WS-TOTAL-X  PIC X(26).
       PROCEDURE DIVISION.
       MAIN.
           OPEN INPUT ENT-FILE
                OUTPUT SAL-FILE.
           PERFORM UNTIL WS-EOF = 'S'
              READ ENT-FILE
                 AT END
                    MOVE 'S' TO WS-EOF
                 NOT AT END
                    MOVE ENT-REC TO WS-SALDO
                    ADD WS-SALDO TO WS-TOTAL
              END-READ
           END-PERFORM.
           MOVE WS-TOTAL TO WS-TOTAL-X.
           WRITE SAL-REC FROM WS-TOTAL-X.
           CLOSE ENT-FILE SAL-FILE.
           GOBACK.