IDENTIFICATION DIVISION.
       PROGRAM-ID. CUST001.
       AUTHOR. GUILLERMO AHRENS.
      *-----------------------------------------------------------------
      * PROYECTO MES 3 - CICS + BMS
      *
      * Mini aplicacion online de cuentas (pantallas 3270) que lee y
      * escribe en DB2 directamente desde CICS:
      *
      *   PF4  -> CONSULTA de saldo de una cuenta
      *   PF2  -> ALTA de cuenta (INSERT en DB2, saldo inicial 0)
      *   PF3  -> BAJA de cuenta (DELETE en DB2)
      *
      * Combina EXEC CICS (RECEIVE/SEND MAP, HANDLE AID, HANDLE ABEND)
      * con SQL embebido en DB2. El mapa BMS es CUST (ver maps/CUST.map)
      * y el copybook simbolico generado se copia con "COPY CUST".
      *-----------------------------------------------------------------
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-RESP         PIC S9(8) COMP VALUE 0.
       01 WS-EOF          PIC X     VALUE 'N'.
       01 WS-MSG          PIC X(52).

       EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01 DB2-NUM-CUENTA  PIC X(24).
       01 DB2-TITULAR     PIC X(60).
       01 DB2-SALDO       PIC S9(15)V99.
       01 DB2-DIVISA      PIC X(3).
       EXEC SQL END DECLARE SECTION END-EXEC.

       EXEC SQL INCLUDE SQLCA END-EXEC.

      * Mapa simbolico BMS generado al ensamblar maps/CUST.map
       COPY CUST.

       LINKAGE SECTION.
       01 DFHCOMMAREA     PIC X.

       PROCEDURE DIVISION.
       INICIO.
      *-> Si el programa falla, controlamos el abend y salimos limpio
           EXEC CICS HANDLE ABEND PROGRAM(CUST001-ABEND) END-EXEC.

      *-> Presenta el mapa en blanco (ERASE limpia la pantalla)
           EXEC CICS SEND MAP('M1') MAPSET('CUST') ERASE END-EXEC.

      *-> Las teclas de funcion deciden la operacion; el resto consulta
           EXEC CICS HANDLE AID
                PF2(ALTA-PARA)
                PF3(BAJA-PARA)
                DEFAULT(CONSULTA-PARA)
           END-EXEC.

           EXEC CICS RECEIVE MAP('M1') MAPSET('CUST')
                RESP(WS-RESP)
           END-EXEC.

           IF WS-RESP NOT = 0
              MOVE 'FORMATO DE PANTALLA INVALIDO' TO M1ERRORO
              PERFORM ENVIAR-MAPA
           END-IF.

      * El HANDLE AID deriva el control; nunca se llega aqui por abajo.
           GOBACK.

      *---------------------------------------------------------------
      * PF4: CONSULTA DE SALDO
      *---------------------------------------------------------------
       CONSULTA-PARA.
           MOVE SPACES TO M1TITOO
                          M1SALOO
                          M1DIVIO
                          M1ERRORO.
           MOVE M1ACCOO   TO DB2-NUM-CUENTA.
           EXEC SQL
                SELECT TITULAR, SALDO, DIVISA
                INTO   :DB2-TITULAR, :DB2-SALDO, :DB2-DIVISA
                FROM CUENTA
                WHERE NUM_CUENTA = :DB2-NUM-CUENTA
           END-EXEC.
           EVALUATE SQLCODE
               WHEN 0
                  MOVE DB2-TITULAR TO M1TITOO
                  MOVE DB2-SALDO   TO M1SALOO
                  MOVE DB2-DIVISA  TO M1DIVIO
                  MOVE 'CUENTA CONSULTADA: OK' TO M1ERRORO
               WHEN 100
                  MOVE 'CUENTA NO ENCONTRADA'  TO M1ERRORO
               WHEN OTHER
                  MOVE 'ERROR AL CONSULTAR DB2' TO M1ERRORO
           END-EVALUATE.
           PERFORM ENVIAR-MAPA.
           GOBACK.

      *---------------------------------------------------------------
      * PF2: ALTA DE CUENTA (INSERT con saldo inicial 0 y divisa EUR)
      *---------------------------------------------------------------
       ALTA-PARA.
           MOVE SPACES TO M1SALOO
                          M1DIVIO
                          M1ERRORO.
           MOVE M1ACCOO   TO DB2-NUM-CUENTA.
           MOVE M1TITOO   TO DB2-TITULAR.
           IF DB2-NUM-CUENTA = SPACES OR DB2-TITULAR = SPACES
              MOVE 'INDICA NUMERO DE CUENTA Y TITULAR' TO M1ERRORO
              PERFORM ENVIAR-MAPA
              GOBACK
           END-IF.
           MOVE 0       TO DB2-SALDO.
           MOVE 'EUR'   TO DB2-DIVISA.
           EXEC SQL
                INSERT INTO CUENTA
                (NUM_CUENTA, TITULAR, SALDO, DIVISA, ESTADO, FECHA_ALTA)
                VALUES (:DB2-NUM-CUENTA, :DB2-TITULAR,
                        :DB2-SALDO, :DB2-DIVISA, 'A', '20260906')
           END-EXEC.
           EVALUATE SQLCODE
               WHEN 0
                  MOVE 'ALTA REGISTRADA' TO M1ERRORO
               WHEN -803
                  MOVE 'LA CUENTA YA EXISTE' TO M1ERRORO
               WHEN OTHER
                  MOVE 'ERROR AL DAR DE ALTA' TO M1ERRORO
           END-EVALUATE.
           PERFORM ENVIAR-MAPA.
           GOBACK.

      *---------------------------------------------------------------
      * PF3: BAJA DE CUENTA (DELETE)
      *---------------------------------------------------------------
       BAJA-PARA.
           MOVE SPACES TO M1TITOO
                          M1SALOO
                          M1DIVIO
                          M1ERRORO.
           MOVE M1ACCOO TO DB2-NUM-CUENTA.
           EXEC SQL
                DELETE FROM CUENTA
                WHERE NUM_CUENTA = :DB2-NUM-CUENTA
           END-EXEC.
           EVALUATE SQLCODE
               WHEN 0
                  MOVE 'CUENTA ELIMINADA' TO M1ERRORO
               WHEN 100
                  MOVE 'CUENTA NO ENCONTRADA' TO M1ERRORO
               WHEN OTHER
                  MOVE 'ERROR AL DAR DE BAJA' TO M1ERRORO
           END-EVALUATE.
           PERFORM ENVIAR-MAPA.
           GOBACK.

      *---------------------------------------------------------------
      * Rutina comun: reenvia el mapa y retorna al terminal
      *---------------------------------------------------------------
       ENVIAR-MAPA.
           EXEC CICS SEND MAP('M1') MAPSET('CUST') ERASE END-EXEC.
           EXEC CICS RETURN END-EXEC.

      *---------------------------------------------------------------
      * Abend handler: mensaje generico y salida controlada
      *---------------------------------------------------------------
       CUST001-ABEND.
           MOVE 'ERROR INTERNO - CONTACTAR OPERADOR' TO WS-MSG.
           EXEC CICS SEND TEXT FROM(WS-MSG) LENGTH(52) ERASE END-EXEC.
           EXEC CICS RETURN END-EXEC.