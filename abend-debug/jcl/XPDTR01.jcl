//XPDTR01 JOB (COBOL),'XPEDITER BATCH VALIDA01',CLASS=A,MSGCLASS=X,REGION=0M
//*
//* PROYECTO MES 4: sesion de depuracion por lotes con XPEDITER.
//* Ejecuta VALIDA01 bajo control de XPEDITER con puntos de ruptura y
//* observacion de la variable de total. Los comandos son un ejemplo;
//* la sintaxis exacta depende de la version de Compuware XPEDITER.
//*
//XPDT   EXEC PGM=XPEDBATB,REGION=0M
//STEPLIB DD DSN=COMPUWARE.XPEDITER.LOADLIB,DISP=SHR
//        DD DSN=USER.LOADLIB,DISP=SHR          *> VALIDA01
//XPEDPARM DD *
//BKUPDDT DD UNIT=SYSDA,SPACE=(CYL,(10,1))
//SYSPRINT DD SYSOUT=*
//SYSMDUMP DD SYSOUT=*
//ENTRADA  DD DSN=USER.DATA.ENTRADA,DISP=SHR    *> data/entrada.txt
//BUENOS   DD SYSOUT=*
//MALOS    DD SYSOUT=*
//SYSIN    DD *
   RESET PROGRAM VALIDA01
*  Se para en cada registro antes de decidir si es numerico
   SET BREAKPOINT ON PARA VALIDAR-REGISTRO
*  Se muestra el valor del total en cada parada
   WATCH ON WS-TOTAL
*  Primera parada, luego se ejecuta paso a paso / se continua
   GO
*  Ejemplo de comandos utiles en produccion:
*  LIST ON VALIDA01 (ver fuentes), TRACE AGE, DISPLAY WS-FIELD
//*