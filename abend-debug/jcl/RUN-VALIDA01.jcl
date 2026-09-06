//RUN-VALIDA01 JOB (COBOL),'EJECUTA VALIDA01',CLASS=A,MSGCLASS=X,REGION=0M
//*
//* PROYECTO MES 4: version corregida. Los registros no numericos se
//* rechazan en MALOS y el proceso no abenda (fin normal, RC 0).
//*
//RUN    EXEC PGM=VALIDA01,TIME=(0,5)
//STEPLIB DD DSN=USER.LOADLIB,DISP=SHR
//SYSOUT  DD SYSOUT=*
//ENTRADA DD DSN=USER.DATA.ENTRADA,DISP=SHR   *> data/entrada.txt
//BUENOS  DD SYSOUT=*
//MALOS   DD SYSOUT=*