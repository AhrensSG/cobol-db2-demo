//RUN-S0C7 JOB (COBOL),'EJECUTA S0C7',CLASS=A,MSGCLASS=X,REGION=0M
//*
//* PROYECTO MES 4: ejecuta el programa que provoca el abend
//* S0C7 (data exception) por falta de validacion numerica.
//* Esperado: terminacion anormal 0C7 con mensaje IEA995I y SYSUDUMP.
//*
//RUN    EXEC PGM=S0C7,TIME=(0,5)
//STEPLIB DD DSN=USER.LOADLIB,DISP=SHR
//SYSOUT  DD SYSOUT=*
//ENTRADA DD DSN=USER.DATA.ENTRADA,DISP=SHR   *> data/entrada.txt
//SALIDA  DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*