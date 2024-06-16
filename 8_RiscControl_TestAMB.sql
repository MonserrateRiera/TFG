/*********************************************************************************************
JOCS DE PROVES DELS PROCEDIMENTS ABM.
EXECUTAR AMB user: MRIERAMAR password: 12345678
**********************************************************************************************/
SET SERVEROUTPUT ON SIZE 100000;
DECLARE
   resposta Varchar2(150);
BEGIN

DBMS_OUTPUT.PUT_LINE('************************************************************************************************************');
DBMS_OUTPUT.PUT_LINE('********************          PROVES PROCEDIMENTS AMB             ******************************************');
DBMS_OUTPUT.PUT_LINE('************************************************************************************************************');
   
    /**************************************************************************************
        PROVES DE AMB DEPARTAMENT
    *************************************************************************************/
    --Prova de donar d'alta un departament
    DBMS_OUTPUT.PUT_LINE('-------ALTES DEPARTAMENT---------');
    P_Alta_Departament('Recursos Humans', resposta);
    P_Alta_Departament('Comptabilitat', resposta);
    P_Alta_Departament('Informatica', resposta);
    P_Alta_Departament('Producció', resposta);
    P_Alta_Departament('Transport', resposta);

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------MODIFICACIO DEPARTAMENT---------');
    DBMS_OUTPUT.PUT_LINE('');
    --Prova de modificar un departament
    P_MODIFICACIO_DEPARTAMENT(2,'Modificat', resposta);
    --Prova de donar de baixa un departament.
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------BAIXES DEPARTAMENT---------');
    DBMS_OUTPUT.PUT_LINE('');
    P_BAIXA_DEPARTAMENT(2, resposta);

    --Proves d'error controlades
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------Proves d''error controlades---------');
    DBMS_OUTPUT.PUT_LINE('');
    --Introduir valor null
    P_Alta_Departament(null, resposta);
    --Introduir un departament amb el mateix nom
    P_Alta_Departament('Informatica', resposta);
    --Donar de baixa un departament que ja hi esta.
    P_BAIXA_DEPARTAMENT(2, resposta);

    /**************************************************************************************
        PROVES DE AMB Empleat
    *************************************************************************************/
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------ALTES EMPLEAT---------');
    DBMS_OUTPUT.PUT_LINE('');
    --Prova de donar d'alta un empleat
    P_Alta_EMPLEAT(1,'Juan', 'Palomo', '12345678A', 666666666, 'juanpa@gmail.com', resposta);
    P_Alta_EMPLEAT(3,'Paco', 'Martinez', '12345678B', 666666667, 'pacoma@gmail.com', resposta);
    P_Alta_EMPLEAT(1,'Pep', 'Misto', '12345678C', 666666665, 'pepmi@gmail.com', resposta);
    P_Alta_EMPLEAT(3,'Dolores', 'Fuertes', '12345678D', 666666660, 'doloresFu@gmail.com', resposta);
    P_Alta_EMPLEAT(5,'Maria', 'Ramis', '12345678E', 666666680, 'mara@gmail.com', resposta);
    P_Alta_EMPLEAT(3,'Toni', 'Meco', '12345678F', 666666683, 'tome@gmail.com', resposta);
    P_Alta_EMPLEAT(4,'Kerry', 'Coche', '1234563D', 166666660, 'kerrica@gmail.com', resposta);
    P_Alta_EMPLEAT(1,'Mariano', 'Fuertes', '13345678D', 666666621, 'marianofu@gmail.com', resposta);

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------Baixes EMPLEAT---------');
    DBMS_OUTPUT.PUT_LINE('');

    --Prova de donar de baixa un empleat
    P_BAIXA_EMPLEAT(1, resposta);

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------MODIFICACIO EMPLEAT---------');
    DBMS_OUTPUT.PUT_LINE('');

    --Prova de modificar un empleat
    DBMS_OUTPUT.PUT_LINE('');
    P_MODIFICACIO_EMPLEAT(2, 1, 'Modificat', 'Modificat', 'modificat', 666666667, 'modificat@gmail.com', resposta);

    DBMS_OUTPUT.PUT_LINE('-------Proves d''error controlades---------');
    DBMS_OUTPUT.PUT_LINE('');
    
    --DNI duplicat
    P_Alta_EMPLEAT(1,'Juan', 'Palomo', '12345678A', 666666666, 'juanpa@gmail.com', resposta);
    --departament no existeix
    P_Alta_EMPLEAT(50,'Juan', 'Palomo', '12345678A', 666666666, 'juanpa@gmail.com', resposta);
    --valor null
    P_Alta_EMPLEAT(1,NULL, 'Palomo', '12345678A', 666666666, 'juanpa@gmail.com', resposta);
    --Ja esta de baixa
    P_BAIXA_EMPLEAT(1, resposta);
    --Baixa sent responsable d'una accio mitigadora.
   -- P_BAIXA_EMPLEAT(11, resposta);
    --Baixa sent lider d'una campanya
    --P_BAIXA_EMPLEAT(9, resposta);
    --Baixa amb id que no exiteix
    P_BAIXA_EMPLEAT(100, resposta);
    --Modificacio amb id que no existeix
    P_MODIFICACIO_EMPLEAT(100, 1, 'Paco', 'Merte', '12345678B', 666666667, 'pacomerte@gmail.com', resposta);
    --Modificacio de baixa
    P_MODIFICACIO_EMPLEAT(1, 1, 'Juanito', 'Palomillo', '123452678B', 6666666267, 'juanillopalomillo@gmail.com', resposta);

    /**************************************************************************************
        PROVES DE AMB CATEGORIA
    *************************************************************************************/
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------ALTES CATEGORIA---------');
    DBMS_OUTPUT.PUT_LINE('');
    --Prova de donar d'alta una categoria
    P_Alta_Cat(3, 'CATEGORIA TEST','Molt important', resposta);
    P_Alta_Cat(4, 'CATEGORIA TEST2','Poc important', resposta);
    P_Alta_Cat(5, 'Ciberseguretat','Molt important', resposta);
    P_Alta_Cat(3, 'Seguretat fisica d''instalacions','Important', resposta);
    P_Alta_Cat(4, 'Aplicacions informatiques','Molt important', resposta);
    P_Alta_Cat(8, 'Finances','Poc important', resposta);

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------MODIFICACIO CATEGORIA---------');
    DBMS_OUTPUT.PUT_LINE('');

    --Prova de modificar una categoria
    P_MODIFICACIO_CAT(1, 5, 'Modifica test','Poc important', resposta);
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------BAIXES CATEGORIA---------');
    DBMS_OUTPUT.PUT_LINE('');
    --Prova de donar de baixa una categoria
    P_BAIXA_CAT(1, resposta);
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------Proves d''error controlades---------');
    DBMS_OUTPUT.PUT_LINE('');

    --Prova de donar d'alta una categoria amb un empleat que no existeix
    P_Alta_Cat(50, 'CATEGORIA TEST23','Molt important', resposta);
    --Prova de donar d'alta una categoria amb el mateix nom
    P_Alta_CAT(4, 'Ciberseguretat','Molt important', resposta);
    --Prova de donar d'alta una categoria amb un nom null
    P_Alta_CAT(7, null,'Molt important', resposta);
    --Prova de donar de baixa una categoria que no exiteix
    P_BAIXA_CAT(50, resposta);
    --Prova de donar de baixa una categoria que ja esta de baixa    
    P_BAIXA_CAT(1, resposta);
    --Prova de modificar una categoria amb un tipus incorrecte
    P_MODIFICACIO_CAT(2, 2, 'CATEGORIA TEST222','qweqwe', resposta);

    
    /**************************************************************************************
        PROVES DE AMB AUTOAVALUACIO
    *************************************************************************************/
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------ALTES AUTOAVALUACIO---------');
    DBMS_OUTPUT.PUT_LINE('');
    --Prova de donar d'alta una autoavaluacio
    P_Alta_AUTOAVALUACIO('Alta autoavaluacio1', TO_DATE ('01-01-2021', 'DD-MM-YYYY'), TO_DATE('10-06-2021', 'DD-MM-YYYY'), 'Ningun risc trobat', resposta);
    P_Alta_AUTOAVALUACIO('Alta autoavaluaciod2',TO_DATE( '25-12-2021', 'DD-MM-YYYY'), TO_DATE('10-06-2022', 'DD-MM-YYYY'), 'Ningun risc trobat', resposta);
    P_Alta_AUTOAVALUACIO('Alta autoavaluacio3', TO_DATE('07-03-2023', 'DD-MM-YYYY'), TO_DATE('10-06-2024', 'DD-MM-YYYY'), 'Ningun risc trobat', resposta);

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------MODIFICACIO AUTOAVALUACIO---------');
    DBMS_OUTPUT.PUT_LINE('');

    --Prova de modificar una autoavaluacio
    P_MODIFICACIO_AUTOAVALUACIO(1,'Moficiacio de la bbdd', '01-01-2021', '10-06-2021', 'Perfecte',resposta);

    --Prova de donar de baixa una autoavaluacio
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------BAIXES AUTOAVALUACIO---------');
    DBMS_OUTPUT.PUT_LINE('');
    P_BAIXA_AUTOAVALUACIO(1, resposta);

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------Proves d''error controlades---------');
    DBMS_OUTPUT.PUT_LINE('');

    --Prova de donar d'alta una autoavaluacio amb un nom null
    P_Alta_AUTOAVALUACIO(null, '01-01-2021', '10-06-2021', 'Ningun risc trobat', resposta);
    --Prova de donar d'alta una autoavaluacio amb una data incorrecta
    P_Alta_AUTOAVALUACIO('Alta amb data incorrecte', '01-01-2021', '10-06-2020', 'Ningun risc trobat', resposta);
    --Prova de donar de baixa una autoavaluacio que no existeix
    P_BAIXA_AUTOAVALUACIO(500, resposta);
    --Prova de donar de baixa una autoavaluacio que t� campanyes associades.
    --P_BAIXA_AUTOAVALUACIO(1, resposta);
    --Prova de modificar una autoavaluacio amb un id que no existeix
    P_MODIFICACIO_AUTOAVALUACIO(500,'modicicacio id inex.', '24-04-2024', '01-06-2024',  'Perfecte',resposta);
    --Prova de modificar una autoavaluacio amb un id que ja esta de baixa
     P_BAIXA_AUTOAVALUACIO(1, resposta);
     
    /**************************************************************************************
        PROVES DE AMB CAMPANYA
    *************************************************************************************/
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------ALTES CAMPANYA---------');
    DBMS_OUTPUT.PUT_LINE('');
    P_Alta_CAMPANYA(2,4, '26-12-2021', '09-06-2022', 'Alta CAMPANYA TEST 1', resposta);
    P_Alta_CAMPANYA(3,2, '08-03-2023', '09-06-2024', 'Alta CAMPANYA TEST 2', resposta);
    P_Alta_CAMPANYA(2,3, '26-12-2021', '09-06-2022', 'Alta CAMPANYA TEST 3', resposta);

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------MODIFICACIO CAMPANYA---------');
    DBMS_OUTPUT.PUT_LINE('');

    --Prova de modificar una campanya
    P_MODIFICACIO_CAMPANYA(1,3,4, '28-03-2023', '08-06-2024', 'Moficicacio d''una campanya', resposta);

    --Prova de donar de baixa una autoavaluacio
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------BAIXES CAMPANYA---------');
    DBMS_OUTPUT.PUT_LINE('');
    P_BAIXA_CAMPANYA(1, resposta);

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------Proves d''error controlades---------');
    DBMS_OUTPUT.PUT_LINE('');
    --Id de inspeccio no existeix.
    P_Alta_CAMPANYA(50, 4, '01-01-2021', '10-06-2021', 'CAMPANYA TEST per provar les exepcions procediments', resposta);
    --id de l'empleat no existeix
    P_Alta_CAMPANYA(2, 50, '01-01-2021', '10-06-2021', 'CAMPANYA TEST per provar les exepcions procediments', resposta);
    --data incorrecta
    P_Alta_CAMPANYA(2, 4, '01-01-2021', '10-06-2019', 'CAMPANYA TEST per provar les exepcions procediments', resposta);
    --id de la campanya no existeix
    P_BAIXA_CAMPANYA(50, resposta);
    --id de la campanya ja esta de baixa
    P_BAIXA_CAMPANYA(1, resposta);
    --id de la campanya no existeix
    P_MODIFICACIO_CAMPANYA(50,4,1, '24-04-2024', '01-06-2024', 'Moficicacio d''una campanya', resposta);
    


    /**************************************************************************************
        PROVES DE AMB AUDITORIAEXTERNA
    *************************************************************************************/
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------ALTES AUDITORIAEXTERNA---------');
    DBMS_OUTPUT.PUT_LINE('');

    P_Alta_AUDITORIAEXTERNA('Corsoft',5000, '01-01-2024', '02-05-2024',  'Creant auditoria externa1', resposta);
    P_Alta_AUDITORIAEXTERNA('Manasoft',3000, '01-05-2024', '14-06-2024', 'Creant auditoria externa2', resposta);
    P_Alta_AUDITORIAEXTERNA('PEPEsoft',3020, '01-05-2024', '14-06-2024', 'Creant auditoria externa3', resposta);
    P_Alta_AUDITORIAEXTERNA('Limit',30002, '01-05-2024', '14-06-2024',   'Creant auditoria externa4', resposta);

    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------MODIFICACIO AUDITORIAEXTERNA---------');
    DBMS_OUTPUT.PUT_LINE('');
    
    P_MODIFICACIO_AUDITORIAEXTERNA(5, '01-01-2024', '02-05-2024', 'Provant els procediments', 'TestSoft',10000,  resposta);

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------BAIXES AUDITORIAEXTERNA---------');
    DBMS_OUTPUT.PUT_LINE('');
    
    P_BAIXA_AUDITORIAEXTERNA(5, resposta);

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------Proves d''error controlades---------');
    DBMS_OUTPUT.PUT_LINE('');

    --Prova de donar d'alta una auditoriaexterna amb un nom null
    P_Alta_AUDITORIAEXTERNA(null,5000, '01-01-2024', '02-05-2024', 'alta amb null', resposta);
    --Prova de donar d'alta una autoavaluacio amb una data incorrecta
    P_Alta_AUDITORIAEXTERNA('Data incorrecte',5000, '01-01-2026', '02-05-2024', 'alta amb data incorrecte', resposta);
    --Prova de donar de baixa una autoavaluacio que no existeix
    P_BAIXA_AUDITORIAEXTERNA(500, resposta);

/**************************************************************************************
        PROVES DE AMB AUDITORIAINTERNA
*************************************************************************************/
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------ALTES AUDITORIAINTERNA---------');
    DBMS_OUTPUT.PUT_LINE('');

    P_Alta_AUDITORIAINTERNA('Test auditoriainterna', '01-01-2024', '02-05-2024',  'Creant auditories internes1', resposta);
    P_Alta_AUDITORIAINTERNA('Test auditoriainterna2', '01-05-2024', '14-06-2024', 'Creant auditories internes2', resposta);
    P_Alta_AUDITORIAINTERNA('Test auditoriainterna3', '01-05-2024', '14-06-2024', 'Creant auditories internes3', resposta);
    P_Alta_AUDITORIAINTERNA('Test auditoriainterna4', '01-05-2024', '14-06-2024', 'Creant auditories internes4', resposta);

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------MODIFICACIO AUDITORIAINTERNA---------');
    DBMS_OUTPUT.PUT_LINE('');
    
    P_MODIFICACIO_AUDITORIAINTERNA(10, '01-01-2024', '02-05-2024', 'Tot ok modificant', 'Modificant auditoriainterna', resposta);

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------BAIXES AUDITORIAINTERNA---------');
    DBMS_OUTPUT.PUT_LINE('');
    
    P_BAIXA_AUDITORIAINTERNA(10, resposta);

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------Proves d''error controlades---------');
    DBMS_OUTPUT.PUT_LINE('');

    --Prova de donar d'alta una auditoriainterna amb un nom null
    P_Alta_AUDITORIAINTERNA(null, '01-01-2024', '02-05-2024', 'PROBLEMES', resposta);
    --Prova de donar d'alta una auditoriainterna amb una data incorrecta
    P_Alta_AUDITORIAINTERNA(null, '01-01-2026', '02-05-2024', 'PROBLEMES', resposta);
    --Prova de donar de baixa una auditoriainterna que no existeix
    P_BAIXA_AUDITORIAINTERNA(500, resposta);
    --Prova de donar de baixa una auditoriainterna que ja hi està
    P_BAIXA_AUDITORIAINTERNA(10, resposta);

/**************************************************************************************
        PROVES DE AMB RISC
*************************************************************************************/
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------ALTES RISC---------');
    DBMS_OUTPUT.PUT_LINE('');

    P_Alta_RISC(2, 3, 1, 2, 'Risc critic', 'Obert', 'Risc de prova1', resposta);
    P_Alta_RISC(6, 3, 3, 3, 'Risc critic', 'Corregit', 'Risc de prova2', resposta);
    P_Alta_RISC(11, 4, 4, 4, 'Risc moderat', 'Obert', 'Risc de prova3', resposta);
    P_Alta_RISC(3, 5, 5, 5, 'Risc critic', 'Obert', 'Risc de prova4', resposta);
    P_Alta_RISC(7, 3, 1, 6, 'Risc baix', 'Mitigat', 'Risc de prova5', resposta);
    P_Alta_RISC(12, 3, 3, 7, 'Risc critic', 'Corregit', 'Risc de prova6', resposta);
    P_Alta_RISC(8, 4, 4, 8, 'Risc baix', 'Obert', 'Risc de prova7', resposta);
    P_Alta_RISC(13, 5, 5, 7, 'Risc moderat', 'Mitigat', 'Risc de prova8', resposta);
    P_Alta_RISC(7, 6, 1, 6, 'Risc critic', 'Obert', 'Risc de prova9', resposta);
    P_Alta_RISC(11, 6, 3, 5, 'Risc moderat', 'Obert', 'Risc de prova10', resposta);

    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------MODIFICACIO RISC---------');
    DBMS_OUTPUT.PUT_LINE('');
    
    P_MODIFICACIO_RISC(1,3,3,1,3,'Risc moderat', 'Corregit', 'Risc de prova1 modificat', resposta);
   

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------BAIXES RISC---------');
    DBMS_OUTPUT.PUT_LINE('');
    P_BAIXA_RISC(1, resposta);
   

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------Proves d''error controlades---------');
    DBMS_OUTPUT.PUT_LINE('');

    --Alta amb un inspeccio que no existeix
    P_Alta_RISC(50, 3, 1, 3, 'Risc critic', 'Obert', 'Risc error inspeccio ', resposta);
    --Alta amb una categoria que no existeix
    P_Alta_RISC(3, 50, 1, 3, 'Risc critic', 'Obert', 'Risc error cat', resposta);
    --Alta amb un departament que no existeix
    P_Alta_RISC(3, 3, 50, 3, 'Risc critic', 'Obert', 'Risc error dep', resposta);
    --Alta amb un empleat que no existeix
    P_Alta_RISC(3, 3, 1, 50, 'Risc critic', 'Obert', 'Risc error emp', resposta);
    --Alta amb una criticitat incorrecta
    P_Alta_RISC(3, 3, 1, 3, 'Risc cr', 'Obert', 'Risc error crit', resposta);
    --Alta amb un estat incorrecte
    P_Alta_RISC(3, 3, 1, 3, 'Risc critic', 'Obertt', 'Risc error estat', resposta);

/**************************************************************************************
        PROVES DE AMB ACCIOMITIGADORA
*************************************************************************************/
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------ALTES ACCIOMITIGADORA---------');
    DBMS_OUTPUT.PUT_LINE('');

    P_Alta_ACCIOMITIGADORA(2, 8, 'En curs', 'Accio de prova1',  'descripcio de l''accio','01-01-2024', '01-06-2024', resposta);
    P_Alta_ACCIOMITIGADORA(3, 7, 'Definida', 'Accio de prova2', 'descripcio de l''accio', '01-01-2023', '01-06-2023', resposta);
    P_Alta_ACCIOMITIGADORA(4, 6, 'Definida', 'Accio de prova3', 'descripcio de l''accio', '01-01-2022', '01-06-2022', resposta);
    P_Alta_ACCIOMITIGADORA(5, 5, 'Definida', 'Accio de prova4', 'descripcio de l''accio', '01-01-2024', '01-06-2024', resposta);
    P_Alta_ACCIOMITIGADORA(6, 4, 'En curs', 'Accio de prova5',  'descripcio de l''accio','01-01-2023', '01-06-2023', resposta);
    P_Alta_ACCIOMITIGADORA(7, 3, 'Definida', 'Accio de prova6', 'descripcio de l''accio', '01-01-2021', '01-06-2021', resposta);
    P_Alta_ACCIOMITIGADORA(8, 2, 'En curs', 'Accio de prova7',  'descripcio de l''accio','01-01-2023', '01-06-2023', resposta);
    P_Alta_ACCIOMITIGADORA(9, 3, 'Definida', 'Accio de prova8', 'descripcio de l''accio', '01-01-2022', '01-06-2022', resposta);
    P_Alta_ACCIOMITIGADORA(10, 4, 'En curs', 'Accio de prova9', 'descripcio de l''accio', '01-01-2023', '01-06-2023', resposta);
    P_Alta_ACCIOMITIGADORA(3, 5, 'En curs', 'Accio de prova10', 'descripcio de l''accio', '01-01-2022', '01-06-2022', resposta);
    P_Alta_ACCIOMITIGADORA(3, 6, 'Definida', 'Accio de prova11','descripcio de l''accio', '01-01-2024', '01-06-2024', resposta);

   /* P_Alta_ACCIOMITIGADORA(
    PRISCID IN ACCIOMITIGADORA.RISCID%TYPE,
    PEMPLEATID IN ACCIOMITIGADORA.EMPLEATID%TYPE,
    PestatAccio IN ACCIOMITIGADORA.estatAccio%TYPE,
    Pdescripcio IN ACCIOMITIGADORA.descripcio%TYPE,
    PDataCreacio IN ACCIOMITIGADORA.dataCreacio%TYPE,
    PdataEstimada IN ACCIOMITIGADORA.dataEstimada%TYPE,
   */
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------MODIFICACIO ACCIOMITIGADORA---------');
    DBMS_OUTPUT.PUT_LINE('');
    
    P_MODIFICACIO_ACCIOMITIGADORA(1, 2, 8, 'En curs', 'Modificacio de l''accio', '01-01-2024',null, resposta);
    --Canviam varis estat a descartada, implementada i corregida
    P_MODIFICACIO_ACCIOMITIGADORA(2, 2, 8, 'Descartada', 'Modificacio a descartada', '01-02-2024',null, resposta);
    P_MODIFICACIO_ACCIOMITIGADORA(3, 2, 8, 'Implementada amb el risc corregit', 'Modificacio de l''accio', '01-01-2024','01-01-2024', resposta);
    P_MODIFICACIO_ACCIOMITIGADORA(4, 2, 8, 'Implementada amb el risc mitigat', 'Modificacio de l''accio', '01-01-2024','01-01-2024', resposta);
    P_MODIFICACIO_ACCIOMITIGADORA(5, 2, 8, 'Descartada', 'Modificacio de l''accio', '01-01-2024',null, resposta);
    P_MODIFICACIO_ACCIOMITIGADORA(6, 2, 8, 'Implementada amb el risc mitigat', 'Modificacio de l''accio', '01-01-2024','01-01-2024', resposta);
    P_MODIFICACIO_ACCIOMITIGADORA(7, 2, 8, 'Implementada amb el risc corregit', 'Modificacio de l''accio', '01-01-2024','01-01-2024', resposta);
    /*
    P_MODIFICACIO_ACCIOMITIGADORA(
    PaccioId IN ACCIOMITIGADORA.accioId%TYPE,
    PRISCID IN ACCIOMITIGADORA.RISCID%TYPE,
    PEMPLEATID IN ACCIOMITIGADORA.EMPLEATID%TYPE,
    PestatAccio IN ACCIOMITIGADORA.estatAccio%TYPE,
    Pdescripcio IN ACCIOMITIGADORA.descripcio%TYPE,
    PdataEstimada IN ACCIOMITIGADORA.dataEstimada%TYPE,
    PRESPOSTA Out Varchar2)
*/
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------BAIXES ACCIOMITIGADORA---------');
    DBMS_OUTPUT.PUT_LINE('');
    --Haure de donar el risc de baixa ja que sino no puc donar-hi l'accio
    P_BAIXA_RISC(2, resposta);
    P_BAIXA_ACCIOMITIGADORA(1, resposta);
   


    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------Proves d''error controlades---------');
    DBMS_OUTPUT.PUT_LINE('');
    --donar de baixa una accio amb un risc d'alta
    P_BAIXA_ACCIOMITIGADORA(10, resposta);
    --alta amb un risc que no existeix
    P_Alta_ACCIOMITIGADORA(50, 3, 'En curs', 'errada id risc',  'descripcio de l''accio','01-01-2024', '01-06-2024', resposta);
    --alta amb un empleat que no existeix
    P_Alta_ACCIOMITIGADORA(2, 50, 'En curs', 'errada id empleat',  'descripcio de l''accio','01-01-2024', '01-06-2024', resposta);
    --alta amb un estat incorrecte
    P_Alta_ACCIOMITIGADORA(2, 3, 'En curss', 'Errada estat',  'descripcio de l''accio','01-01-2024', '01-06-2024', resposta);
    --alta amb una data incorrecta
    P_Alta_ACCIOMITIGADORA(2, 3, 'En curs', 'Errada data',  'descripcio de l''accio','01-01-2024', '01-06-2023', resposta);
    --alta amb un nom null
    P_Alta_ACCIOMITIGADORA(2, 3, 'En curs', null,  'descripcio de l''accio','01-01-2024', '01-06-2024', resposta);
    --errada implementacio
    P_MODIFICACIO_ACCIOMITIGADORA(3, 2, 8, 'Implementada amb el risc corregit', 'Modificacio erronea de l''accio', '01-01-2024',null, resposta);

/**************************************************************************************
        PROVES DE AMB MOSTREIG
*************************************************************************************/
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------ALTES MOSTREIG---------');
    DBMS_OUTPUT.PUT_LINE('');

    P_Alta_MOSTREIG(2, 'Mostreig de prova 1', 'En curs', resposta);
    P_Alta_MOSTREIG(6, 'Mostreig de prova 1', 'En curs', resposta);
    P_Alta_MOSTREIG(11, 'Mostreig de prova 1', 'En curs', resposta);

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------MODIFICACIO MOSTREIG---------');
    DBMS_OUTPUT.PUT_LINE('');

    P_MODIFICACIO_MOSTREIG( 1, 2, 'Mostreig de prova 1 modificat', 'En curs', resposta);


    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------BAIXES MOSTREIG---------');
    DBMS_OUTPUT.PUT_LINE('');
    
    P_BAIXA_MOSTREIG(1, resposta);


    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-------Proves d''error controlades---------');
    DBMS_OUTPUT.PUT_LINE('');
   --alta d'un mostreig amb una inspeccio que no existeix
   P_Alta_MOSTREIG(50, 'Mostreig errada id no existeix', 'En curs', resposta);
   --Alta mostreig nom null
    P_Alta_MOSTREIG(2, null, 'En curs', resposta);

END;
/
