/************************************************************************************************
* CREACIO DE PROCEDIMENTS DE CONSULTA                                                           *
* IMPORTANT : Aquest script ha de ser executat amb l'usuari MRIERAMAR pwd 12345678                *
************************************************************************************************/




/************************************************************************************************
- P_CU-11
- Obtenció Percentatge de riscs no corregits amb impacte <4 
************************************************************************************************/
CREATE OR REPLACE PROCEDURE P_CU11(
    PRESPOSTA OUT VARCHAR2
)
IS
    param_input varchar(200);
    v_percentatge FLOAT;
    codi_error number;
    v_nompro varchar(50);
    v_resultat varchar(200);
    
    BEGIN
    v_nomPro:= TO_CHAR($$PLSQL_UNIT);
    param_input:= ' ';
    SELECT percentatge INTO v_percentatge FROM DW_PERCRISC;

    dbms_output.put_line('----------------------------------------------------------------------');
    dbms_output.put_line('Percentatge de riscs no corregits amb impacte <4 ');
    dbms_output.put_line('----------------------------------------------------------------------');
    dbms_output.put_line('');
    dbms_output.put_line('Percentatge ' || v_percentatge|| ' %');
    dbms_output.put_line('');
    dbms_output.put_line('***********************************************************************');
    PRESPOSTA:= v_percentatge;
    v_resultat:='OK';
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resultat, SYSDATE);
    Commit;
    -- tractament de les excepcions
    Exception
    WHEN NO_DATA_FOUND THEN
        codi_error := SQLCODE;
        v_resultat:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(PRESPOSTA);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resultat, SYSDATE);
        Commit;
    WHEN Others THEN
        codi_error := SQLCODE;
        v_resultat:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(PRESPOSTA);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resultat, SYSDATE);
        Commit;
    End;
    /
/************************************************************************************************
- P_CU-12
- Per un any en concret, nombre total de riscos amb impacte 1 per aquell any.
************************************************************************************************/
CREATE OR REPLACE PROCEDURE P_CU12(
    PANY IN NUMBER,
    PRESPOSTA OUT VARCHAR2
)
IS
    param_input varchar(200);
    v_riscs NUMBER;
    codi_error number;
    v_nompro varchar(50);
    v_resposta varchar(200);
    
    BEGIN
    v_nomPro:= TO_CHAR($$PLSQL_UNIT);
    param_input:= 'any: '||PANY;

    SELECT nombreImpacte1 INTO v_riscs FROM DW_Impacte1 where anyo = PANY;
    dbms_output.put_line('----------------------------------------------------------------------');
    dbms_output.put_line('Nombre total de riscos amb impacte 1 per l''any '||PANY);
    dbms_output.put_line('----------------------------------------------------------------------');
    dbms_output.put_line('');
    dbms_output.put_line('Riscs: ' || v_riscs);
    dbms_output.put_line('');
    dbms_output.put_line('');
    dbms_output.put_line('***********************************************************************');
    v_resposta:='OK';
    PRESPOSTA:= v_riscs;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);


    Commit;
    -- tractament de les excepcions
    Exception
    WHEN NO_DATA_FOUND THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    WHEN Others THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    End;
    /

/************************************************************************************************
- P_CU-13
- Per l'any anterior, nombre total de riscos que estan en estat 'obert'
************************************************************************************************/
CREATE OR REPLACE PROCEDURE P_CU13(
    PRESPOSTA OUT VARCHAR2
)
IS
    param_input varchar(200);
    v_riscs NUMBER;
    codi_error number;
    v_nompro varchar(50);
    v_resposta varchar(200);
    
    BEGIN
    v_nomPro:= TO_CHAR($$PLSQL_UNIT);
    param_input:= ' ';

    SELECT numRiscsOberts INTO v_riscs FROM DW_RiscsOberts;

    dbms_output.put_line('Nombre total de riscos que estan en estat obert');
    dbms_output.put_line('----------------------------------------------------------------------');
    dbms_output.put_line('');
    dbms_output.put_line('Riscs en estat obert: ' || v_riscs);
    dbms_output.put_line('');
    dbms_output.put_line('');
    dbms_output.put_line('***********************************************************************');
    PRESPOSTA:= v_riscs;
    v_resposta:= 'OK';
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);


    Commit;
    -- tractament de les excepcions
    Exception
    WHEN NO_DATA_FOUND THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    WHEN Others THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    End;
/    
/************************************************************************************************
- P_CU-14
- Obtenir el departament amb major nombre de riscos detectats amb auditories externes.
************************************************************************************************/
CREATE OR REPLACE PROCEDURE P_CU14(
    PRESPOSTA OUT VARCHAR2
)
IS
    param_input varchar(200);
    v_departament NUMBER;
    codi_error number;
    v_nompro varchar(50);
    v_resposta varchar(200);
    
    BEGIN
    v_nomPro:= TO_CHAR($$PLSQL_UNIT);
    param_input:= ' ';

    SELECT depId INTO v_departament FROM DW_DepartamentMaxAE;

    dbms_output.put_line('Departament amb major nombre de riscos detectats amb auditories externes');
    dbms_output.put_line('----------------------------------------------------------------------');
    dbms_output.put_line('');
    dbms_output.put_line('Id del departament: ' || v_departament);
    dbms_output.put_line('');
    dbms_output.put_line('');
    dbms_output.put_line('***********************************************************************');
    v_resposta:='OK';
    PRESPOSTA:= v_departament;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);

    Dbms_output.Put_line(v_resposta);

    Commit;
    -- tractament de les excepcions
    Exception
    WHEN NO_DATA_FOUND THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    WHEN Others THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    End;
/    

/************************************************************************************************
- P_CU-15
- Nombre d'accions en curs en l'any actual
************************************************************************************************/
CREATE OR REPLACE PROCEDURE P_CU15(
    PRESPOSTA OUT VARCHAR2
)
IS
    param_input varchar(200);
    v_accions NUMBER;
    codi_error number;
    v_nompro varchar(50);
    v_resposta varchar(200);
    
    BEGIN
    v_nomPro:= TO_CHAR($$PLSQL_UNIT);
    param_input:= ' ';

    SELECT nombreAccionsCurs INTO v_accions FROM DW_AccionsCurs;

    dbms_output.put_line('Nombre daccions en curs en lany actual');
    dbms_output.put_line('----------------------------------------------------------------------');
    dbms_output.put_line('');
    dbms_output.put_line('N. accions: ' || v_accions);
    dbms_output.put_line('');
    dbms_output.put_line('');
    dbms_output.put_line('***********************************************************************');
    PRESPOSTA:= v_accions;
    v_resposta:= 'OK';
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);

    Dbms_output.Put_line(PRESPOSTA);

    Commit;
    -- tractament de les excepcions
    Exception
    WHEN NO_DATA_FOUND THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    WHEN Others THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    End;
/    

/************************************************************************************************
- P_CU-16
- Donat un any, diferència de riscos detectats amb auditories internes i externes
************************************************************************************************/
CREATE OR REPLACE PROCEDURE P_CU16(
    PANY IN NUMBER,
    PRESPOSTA OUT VARCHAR2
)
IS
    param_input varchar(200);
    v_riscos NUMBER;
    codi_error number;
    v_nompro varchar(50);
    v_resposta varchar(200);
    
    BEGIN
    v_nomPro:= TO_CHAR($$PLSQL_UNIT);
    param_input:= 'Any: '||PANY;

    SELECT diferencia INTO v_riscos FROM DW_DiferenciaInternaExterna WHERE ANYO = PANY;

    dbms_output.put_line('Diferencia entre auditories internes i externes per a lany '||PANY);
    dbms_output.put_line('----------------------------------------------------------------------');
    dbms_output.put_line('');
    dbms_output.put_line('N. accions: ' || v_riscos);
    dbms_output.put_line('');
    dbms_output.put_line('');
    dbms_output.put_line('***********************************************************************');
    v_resposta:='OK';
    PRESPOSTA:= v_riscos;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);

    Dbms_output.Put_line(PRESPOSTA);

    Commit;
    -- tractament de les excepcions
    Exception
    WHEN NO_DATA_FOUND THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    WHEN Others THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    End;
/    

/************************************************************************************************
- P_CU-17
-  En el moment d’executar la consulta, persona de l’empresa que té més accions
obertes (en estat d’en curs o de definida) assignades
************************************************************************************************/
CREATE OR REPLACE PROCEDURE P_CU17(
    PRESPOSTA OUT VARCHAR2
)
IS
    param_input varchar(200);
    v_empleat NUMBER;
    codi_error number;
    v_nompro varchar(50);
    v_resposta varchar(200);
    
    BEGIN
    v_nomPro:= TO_CHAR($$PLSQL_UNIT);
    param_input:= ' ';

    SELECT empleatId INTO v_empleat FROM DW_EmpleatMesAccions;

    dbms_output.put_line('Empleat amb més accions obertes');
    dbms_output.put_line('----------------------------------------------------------------------');
    dbms_output.put_line('');
    dbms_output.put_line('Id de lempleat: ' || v_empleat);
    dbms_output.put_line('');
    dbms_output.put_line('');
    dbms_output.put_line('***********************************************************************');
    v_resposta:='OK';
    PRESPOSTA:= v_empleat;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);

    Dbms_output.Put_line(PRESPOSTA);

    Commit;
    -- tractament de les excepcions
    Exception
    WHEN NO_DATA_FOUND THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    WHEN Others THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    End;
/    

/************************************************************************************************
- P_CU-18
-  Nombre mitjà de mostrejos fets per any sense considerar l’any actual
************************************************************************************************/
CREATE OR REPLACE PROCEDURE P_CU18(
    PRESPOSTA OUT VARCHAR2
)
IS
    param_input varchar(200);
    v_mostrejos NUMBER;
    codi_error number;
    v_nompro varchar(50);
    v_resposta varchar(200);
    
    BEGIN
    v_nomPro:= TO_CHAR($$PLSQL_UNIT);
    param_input:= ' ';

    SELECT mitja INTO v_mostrejos FROM DW_MitjaMostrejos;

    dbms_output.put_line('Nombre mitjà de mostrejos fets per any sense considerar l’any actual');
    dbms_output.put_line('----------------------------------------------------------------------');
    dbms_output.put_line('');
    dbms_output.put_line('Nombre mitjà: ' || v_mostrejos);
    dbms_output.put_line('');
    dbms_output.put_line('');
    dbms_output.put_line('***********************************************************************');
    v_resposta:='OK';
    PRESPOSTA:= v_mostrejos;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);

    Dbms_output.Put_line(PRESPOSTA);

    Commit;
    -- tractament de les excepcions
    Exception
    WHEN NO_DATA_FOUND THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    WHEN Others THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    End;
/    
/************************************************************************************************
- P_CU-19
-  Tenint en compte l’any en curs i l’anterior, nombre de riscos de ciberseguretat
detectats per autoavaluació dels departaments
************************************************************************************************/
CREATE OR REPLACE PROCEDURE P_CU19(
    PRESPOSTA OUT VARCHAR2
)
IS
    param_input varchar(200);
    v_riscos NUMBER;
    codi_error number;
    v_nompro varchar(50);
    v_resposta varchar(200);
    
    BEGIN
    v_nomPro:= TO_CHAR($$PLSQL_UNIT);
    param_input:= ' ';

    SELECT totalCyber INTO v_riscos FROM DW_CiberAutoAv;

    dbms_output.put_line('Nombre de riscos de ciberseguretat detectats per autoavaluació dels departaments');
    dbms_output.put_line('----------------------------------------------------------------------');
    dbms_output.put_line('');
    dbms_output.put_line('Nombre riscos: ' || v_riscos);
    dbms_output.put_line('');
    dbms_output.put_line('');
    dbms_output.put_line('***********************************************************************');
    v_resposta:='OK';   
    PRESPOSTA:= v_riscos;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);

    Dbms_output.Put_line(PRESPOSTA);

    Commit;
    -- tractament de les excepcions
    Exception
    WHEN NO_DATA_FOUND THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    WHEN Others THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    End;
/    
/************************************************************************************************
- P_CU-20
-  En el darrer any, cost mitjà de totes les auditories externes realitzades
************************************************************************************************/
CREATE OR REPLACE PROCEDURE P_CU20(
    PRESPOSTA OUT VARCHAR2
)
IS
    param_input varchar(200);
    v_cost NUMBER;
    codi_error number;
    v_nompro varchar(50);
    v_resposta varchar(200);

    
    BEGIN
    v_nomPro:= TO_CHAR($$PLSQL_UNIT);
    param_input:= ' ';

    SELECT costMitja INTO v_cost FROM DW_costMitja;

    dbms_output.put_line('Cost mitjà de totes les auditories externes realitzades');
    dbms_output.put_line('----------------------------------------------------------------------');
    dbms_output.put_line('');
    dbms_output.put_line('Cost mitjà: ' || v_cost);
    dbms_output.put_line('');
    dbms_output.put_line('');
    dbms_output.put_line('***********************************************************************');
    v_resposta:='OK';
    PRESPOSTA:=v_cost;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);

    Dbms_output.Put_line(PRESPOSTA);

    Commit;
    -- tractament de les excepcions
    Exception
    WHEN NO_DATA_FOUND THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    WHEN Others THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    End;
/    
/************************************************************************************************
- P_CU-21
-  Tenint en compte totes les dades de què es disposa, any amb un nombre major
d’accions que al final de l’any en qüestió estaven en estat d’implementada amb el risc
mitigat
************************************************************************************************/
CREATE OR REPLACE PROCEDURE P_CU21(
    PRESPOSTA OUT VARCHAR2
)
IS
    param_input varchar(200);
    v_any NUMBER;
    codi_error number;
    v_nompro varchar(50);
    v_resposta varchar(200);
    
    BEGIN
    v_nomPro:= TO_CHAR($$PLSQL_UNIT);
    param_input:= ' ';

    SELECT anyo INTO v_any FROM DW_MaxAny;

    dbms_output.put_line('Any amb un nombre major d’accions que al final de l’any en qüestió estaven en estat d’implementada amb el risc mitigat');
    dbms_output.put_line('----------------------------------------------------------------------');
    dbms_output.put_line('');
    dbms_output.put_line('Any: ' || v_any);
    dbms_output.put_line('');
    dbms_output.put_line('');
    dbms_output.put_line('***********************************************************************');
    PRESPOSTA:= v_any;
    v_resposta:= 'OK';
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);

    Dbms_output.Put_line(PRESPOSTA);

    Commit;
    -- tractament de les excepcions
    Exception
    WHEN NO_DATA_FOUND THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    WHEN Others THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    End;
/    
/************************************************************************************************
- P_CU-22
-  Tenint en compte només el darrer any finalitzat, Top3 d’accions definides tenint en
compte el temps que van estar obertes (des de la seva creació fins que passen a un dles
estats d’implementada). Cal indicar el nom de les 3 accions que van estar més temps
obertes
************************************************************************************************/
CREATE OR REPLACE PROCEDURE P_CU22(
    PRESPOSTA OUT SYS_REFCURSOR
)
IS
    param_input varchar(200);
    codi_error number;
    v_nompro varchar(50);
    v_resposta varchar(200);
    CURSOR cur_top3 IS
     SELECT accioNom FROM DW_Top3TempsObert ORDER BY tempsObert DESC;

    BEGIN
    v_nomPro:= TO_CHAR($$PLSQL_UNIT);
    param_input:= ' ';

    dbms_output.put_line('Top3 d’accions definides tenint en compte el temps que van estar obertes');
    dbms_output.put_line('----------------------------------------------------------------------');
    dbms_output.put_line('');
    dbms_output.put_line('');
    dbms_output.put_line('***********************************************************************');
    OPEN PRESPOSTA FOR SELECT accioNom FROM DW_Top3TempsObert ORDER BY tempsObert DESC;
    
    FOR i in cur_top3 LOOP
        dbms_output.put_line('Nom accio: '||i.accioNom);
    END LOOP;

    dbms_output.put_line('');
    v_resposta:='OK';
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);

    --Dbms_output.Put_line(PRESPOSTA);

    Commit;
    -- tractament de les excepcions
    Exception
    WHEN NO_DATA_FOUND THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    WHEN Others THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    End;
/    
/************************************************************************************************
- P_CU-23
-  En el moment d’executar la consulta, nombre de riscos de categoria 1 (en qualsevol estat) (interpret que es impacte1)
************************************************************************************************/
CREATE OR REPLACE PROCEDURE P_CU23(
    PRESPOSTA OUT VARCHAR2
)
IS
    param_input varchar(200);
    v_risc NUMBER;
    codi_error number;
    v_nompro varchar(50);
    v_resposta varchar(200);
    
    BEGIN
    v_nomPro:= TO_CHAR($$PLSQL_UNIT);
    param_input:= ' ';

    SELECT nombreRisc INTO v_risc FROM DW_RiscCat1;

    dbms_output.put_line('Nombre de riscos de categoria 1');
    dbms_output.put_line('----------------------------------------------------------------------');
    dbms_output.put_line('');
    dbms_output.put_line('Nombre riscos: ' || v_risc);
    dbms_output.put_line('');
    dbms_output.put_line('');
    dbms_output.put_line('***********************************************************************');
    v_resposta:='OK';
    PRESPOSTA:= v_risc;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);

    Dbms_output.Put_line(v_resposta);

    Commit;
    -- tractament de les excepcions
    Exception
    WHEN NO_DATA_FOUND THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    WHEN Others THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    End;
/    
/************************************************************************************************
- P_CU-24
-  Donat un any en concret, percentatge d’accions descartades.
************************************************************************************************/
CREATE OR REPLACE PROCEDURE P_CU24(
    PANY IN NUMBER,
    PRESPOSTA OUT VARCHAR2
)
IS
    param_input varchar(200);
    v_accions NUMBER;
    codi_error number;
    v_nompro varchar(50);
    v_resposta varchar(200);
    
    BEGIN
    v_nomPro:= TO_CHAR($$PLSQL_UNIT);
    param_input:= PANY;

    SELECT percentatge INTO v_accions FROM DW_PerAccionnsDescartades WHERE anyo = PANY;

    dbms_output.put_line('Percentatge d''accions descartades');
    dbms_output.put_line('----------------------------------------------------------------------');
    dbms_output.put_line('');
    dbms_output.put_line('Percentatge: ' || v_accions|| ' %');
    dbms_output.put_line('');
    dbms_output.put_line('');
    dbms_output.put_line('***********************************************************************');
    PRESPOSTA:= v_accions;
    v_resposta := 'OK';
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);

    Dbms_output.Put_line(v_resposta);

    Commit;
    -- tractament de les excepcions
    Exception
    WHEN NO_DATA_FOUND THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    WHEN Others THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    End;
/    

/************************************************************************************************
- P_CU-25
-  Departament amb més riscs.
************************************************************************************************/
CREATE OR REPLACE PROCEDURE P_CU25(
    PRESPOSTA OUT VARCHAR2
)
IS
    param_input varchar(200);
    v_depId NUMBER;
    v_nom varchar(50);
    codi_error number;
    v_nompro varchar(50);
    v_resposta varchar(200);
    
    BEGIN
    v_nomPro:= TO_CHAR($$PLSQL_UNIT);
    param_input:= ' ';

    SELECT depId, nom INTO v_depId, v_nom FROM DW_PitjorDepartament;

    dbms_output.put_line('Departament amb més riscs');
    dbms_output.put_line('----------------------------------------------------------------------');
    dbms_output.put_line('');
    dbms_output.put_line('El pijtor departament es: ' ||v_nom|| ' amb la id: '|| v_depId);
    dbms_output.put_line('');
    dbms_output.put_line('');
    dbms_output.put_line('***********************************************************************');
    PRESPOSTA:= v_depId;
    v_resposta := 'OK';
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);

    Dbms_output.Put_line(v_resposta);

    Commit;
    -- tractament de les excepcions
    Exception
    WHEN NO_DATA_FOUND THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    WHEN Others THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    End;
/    

/************************************************************************************************
- P_CU-26
-  Percentatges de riscos per categoria
************************************************************************************************/
CREATE OR REPLACE PROCEDURE P_CU26(
    PRESPOSTA OUT SYS_REFCURSOR
)
IS
    param_input varchar(200);
    v_depId NUMBER;
    v_nom varchar(50);
    codi_error number;
    v_nompro varchar(50);
    v_resposta varchar(200);
    CURSOR cur_percentatge IS
     SELECT catId, nom, percentatge FROM DW_PercentatgeCat ORDER BY catId ASC;
    
    BEGIN
    v_nomPro:= TO_CHAR($$PLSQL_UNIT);
    param_input:= ' ';


    dbms_output.put_line('Percentatges de riscos per categoria');
    dbms_output.put_line('----------------------------------------------------------------------');
    dbms_output.put_line('');

    FOR i in cur_percentatge LOOP
        dbms_output.put_line('CatId: '||i.catId||' nom: '||i.nom||' percentatge: '||i.percentatge);
    END LOOP;
    dbms_output.put_line('');
    dbms_output.put_line('');
    dbms_output.put_line('***********************************************************************');
    OPEN PRESPOSTA FOR SELECT catId, nom, percentatge FROM DW_PercentatgeCat;
    v_resposta := 'OK';
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);

    Dbms_output.Put_line(v_resposta);

    Commit;
    -- tractament de les excepcions
    Exception
    WHEN NO_DATA_FOUND THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    WHEN Others THEN
        codi_error := SQLCODE;
        v_resposta:= Substr('ERROR: ' || codi_error ||' ' || SQLERRM ,1,50);
        Dbms_output.Put_line(v_resposta);
        Rollback;
    INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, v_resposta, SYSDATE);
        Commit;
    End;
/    