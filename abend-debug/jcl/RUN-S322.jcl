//RUN-S322 JOB (COBOL),'EJECUTA S322',CLASS=A,MSGCLASS=X,REGION=0M
//*
//* PROYECTO MES 4: ejecuta el bucle sin salida del programa S322.
//* El paso tiene un limite de tiempo de 1 minuto (TIME=(0,1));
//* al superarlo el sistema termina el paso con S322.
//*
//RUN    EXEC PGM=S322,TIME=(0,1)
//STEPLIB DD DSN=USER.LOADLIB,DISP=SHR
//SYSOUT  DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*