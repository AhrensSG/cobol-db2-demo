IDENTIFICATION DIVISION.
       PROGRAM-ID. S322.
       AUTHOR. GUILLERMO AHRENS.
      *-----------------------------------------------------------------
      * DEMO ABEND S322 (STEP TIME EXCEEDED)
      *
      * Bucle que tarda muchisimo mas del tiempo asignado al paso.
      * En produccion un S322 suele venir de un READ sin salida (nunca
      * se llega a AT END) o de una condicion de bucle que nunca se
      * cumple. Aqui simulamos eso con un contador que necesitaria
      * decenas de minutos en terminar.
      *
      * Para verlo sin esperar, el JCL RUN-S322 limita el paso a un
      * minuto (TIME=(0,1)) y el sistema abenda con S322.
      *-----------------------------------------------------------------
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-COUNT PIC 9(8) VALUE 0.
       PROCEDURE DIVISION.
       MAIN.
           PERFORM UNTIL WS-COUNT = 99999999
              ADD 1 TO WS-COUNT
           END-PERFORM.
           DISPLAY 'FIN DEL BUCLE: ' WS-COUNT.
           GOBACK.