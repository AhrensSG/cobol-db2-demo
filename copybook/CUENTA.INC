      *-----------------------------------------------------------------
      * COPYBOOK: CUENTA.INC
      * Descripción: Estructura de datos de una cuenta de cliente
      * para el programa de consulta de saldos (Proyecto DB2 + COBOL).
      * Se usa con COPY CUENTA.
      *-----------------------------------------------------------------
       01  WS-CUENTA-RECORD.
           05 WS-CUENTA-ID            PIC 9(10).       *> Id interno de la cuenta
           05 WS-CUENTA-NUM           PIC X(20).       *> Número de cuenta IBAN
           05 WS-CUENTA-TITULAR       PIC X(60).       *> Nombre del titular
           05 WS-CUENTA-SALDO         PIC S9(13)V99.   *> Saldo con signo y 2 dec.
           05 WS-CUENTA-DIVISA        PIC X(3).        *> Código ISO 4217 (EUR, USD)
           05 WS-CUENTA-ESTADO        PIC X(1).        *> A=Activa I=Inactiva C=Cerrada
           05 WS-CUENTA-FECHA-ALTA    PIC X(10).       *> Fecha alta AAAAMMDD
