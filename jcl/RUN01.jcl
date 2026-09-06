//CTA0001R JOB (COBOL),'EJECUTA CTA0001',CLASS=A,MSGCLASS=X,
//             NOTIFY=&SYSUID
//*
//* Ejecuta el programa CTA0001 (consulta de saldos en DB2).
//* Entrada: números de cuenta. Salida: informe. 
//*
//* Observación: la tabla CUENTA debe existir en la BD 'DBBANK'.
//*              Se enlaza con el subsistema DB2 vía IKJEFT01 + DSN.
//*
//RUN      EXEC PGM=IKJEFT01,DYNAMNBR=20
//STEPLIB  DD    DSN=MILLER.COBOL.LOAD,DISP=SHR
//         DD    DSN=DB2.SDSNLOAD,DISP=SHR
//SYSTSPRT DD    SYSOUT=*
//SYSTSIN  DD    *
  DSN SYSTEM(DBBANK)
  RUN PROGRAM(CTA0001) PLAN(CTA0001PLAN)
  END
/*
//ENTRADA  DD    DSN=MILLER.COBOL.DATA.ENTRADA,DISP=SHR
//SALIDA   DD    SYSOUT=*
//SYSUDUMP DD    SYSOUT=*