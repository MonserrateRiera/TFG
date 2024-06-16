/*********************************************************************************************
JOCS DE PROVES DELS PROCEDIMENTS DE CONSULTA.
EXECUTAR AMB user: usuari1 MRIERAMAR: 12345678
**********************************************************************************************/

SET SERVEROUTPUT ON SIZE 100000;
DECLARE
   resposta Varchar2(150);
   num_registres number;
   num_registres2 number;
   v_percentatge float;
   v_accioNom varchar2(100);
   v_cursor SYS_REFCURSOR;
   v_esigual boolean;
   CURSOR c_acciomitigadora IS
        SELECT nom 
        FROM ACCIOMITIGADORA 
        WHERE dataimplementacio IS NOT NULL 
        AND EXTRACT(YEAR FROM DATAIMPLEMENTACIO) = 2023
        ORDER BY dataImplementacio - dataCreacio DESC 
        FETCH FIRST 3 ROWS ONLY; 
    CURSOR c_cat IS
        SELECT catId, nom FROM CATEGORIA WHERE ESTAT = 'ALTA';       
BEGIN
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('************************************************************************************************************');
DBMS_OUTPUT.PUT_LINE('********************      PROVES PROCEDIMENTS DE CONSULTA         ******************************************');
DBMS_OUTPUT.PUT_LINE('************************************************************************************************************');
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('');
/**************************************************************************************
        PROVA P_CU11
*************************************************************************************/
--Execucic� del procediment
    P_CU11(resposta);
--Consulta manual 
SELECT COUNT (*) INTO num_registres FROM RISC WHERE ESTAT = 'ALTA';
SELECT COUNT (*) INTO num_registres2 FROM RISC WHERE ESTAT = 'ALTA' AND IMPACTE IN ('Impacte catastrofic',' Impacte critic', 'Impacte alt') AND estatRisc = 'Obert';
v_percentatge := (num_registres2/num_registres)*100; 
    DBMS_OUTPUT.PUT_LINE('-------------------------Prova P_CU11:---------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Resultat esperat: '||v_percentatge);
    DBMS_OUTPUT.PUT_LINE('Resultat obtingut: '||resposta);
    IF TRUNC(v_percentatge, 2) = TRUNC(resposta, 2) THEN
        DBMS_OUTPUT.PUT_LINE('RESULTAT TEST P_CU11-------------CORRECTE');
    ELSE
        DBMS_OUTPUT.PUT_LINE('RESULTAT TEST P_CU11-------------INCORRECTE');
    END IF;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('');
    
/**************************************************************************************
        PROVA P_CU12
*************************************************************************************/    
--Execucic� del procediment
    P_CU12(2024, resposta);
--Consulta manual 
    SELECT COUNT(riscId) INTO num_registres FROM RISC WHERE ESTAT = 'ALTA'
        AND EXTRACT(YEAR FROM dataCreacio) = 2024
        AND impacte = 'Impacte catastrofic';

    DBMS_OUTPUT.PUT_LINE('Prova P_CU12: ');
    DBMS_OUTPUT.PUT_LINE('Resultat esperat: '||num_registres);
    DBMS_OUTPUT.PUT_LINE('Resultat obtingut: '||resposta);
    IF num_registres = resposta THEN
        DBMS_OUTPUT.PUT_LINE('RESULTAT TEST P_CU12-------------CORRECTE');
    ELSE
        DBMS_OUTPUT.PUT_LINE('RESULTAT TEST P_CU12-------------INCORRECTE');
    END IF;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('');
/**************************************************************************************
        PROVA P_CU13
*************************************************************************************/     
   --Execuci� del procediment
    P_CU13(resposta);
    --Consulta manual
    SELECT COUNT(*) INTO num_registres
    FROM RISC
    WHERE ESTATRISC = 'Obert' AND ESTAT = 'ALTA' AND EXTRACT(YEAR FROM DATACREACIO) = 2023;
      
    
    DBMS_OUTPUT.PUT_LINE('Prova P_CU13: ');
    DBMS_OUTPUT.PUT_LINE('Resultat esperat: '||num_registres);
    DBMS_OUTPUT.PUT_LINE('Resultat obtingut: '||resposta);
    IF num_registres = resposta THEN
        DBMS_OUTPUT.PUT_LINE('RESULTAT TEST P_CU13-------------CORRECTE');
    ELSE
        DBMS_OUTPUT.PUT_LINE('RESULTAT TEST P_CU13-------------INCORRECTE');
    END IF;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('');

/**************************************************************************************
        PROVA P_CU14
*************************************************************************************/     
   --Execuci� del procediment
    P_CU14(resposta);
    --Consulta manual del departament amb m�s riscos detectats amb auditories externes.
    SELECT depId  INTO num_registres 
        FROM (SELECT r.depId, COUNT(r.depId) 
        FROM risc r
        JOIN auditoriaexterna ae ON ae.inspeccioid = r.inspeccioId
        GROUP BY r.depId
        ORDER BY COUNT(r.depId) DESC ) 
        WHERE ROWNUM = 1;
    
      
    
    DBMS_OUTPUT.PUT_LINE('Prova P_CU14: ');
    DBMS_OUTPUT.PUT_LINE('Resultat esperat: '||num_registres);
    DBMS_OUTPUT.PUT_LINE('Resultat obtingut: '||resposta);
    IF num_registres = resposta THEN
        DBMS_OUTPUT.PUT_LINE('RESULTAT TEST P_CU14-------------CORRECTE');
    ELSE
        DBMS_OUTPUT.PUT_LINE('RESULTAT TEST P_CU14-------------INCORRECTE');
    END IF;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('');

/**************************************************************************************
        PROVA P_CU15
*************************************************************************************/     
   --Execuci� del procediment
    P_CU15(resposta);
    --Consulta manual del Nombre d'accions en curs en l'any actual.
    SELECT COUNT(*) INTO num_registres FROM ACCIOMITIGADORA
        WHERE estatAccio = 'En curs' AND EXTRACT(YEAR FROM dataCreacio) = 2024 AND estat = 'ALTA';  
    
      
    
    DBMS_OUTPUT.PUT_LINE('Prova P_CU15: ');
    DBMS_OUTPUT.PUT_LINE('Resultat esperat: '||num_registres);
    DBMS_OUTPUT.PUT_LINE('Resultat obtingut: '||resposta);
    IF num_registres = resposta THEN
        DBMS_OUTPUT.PUT_LINE('RESULTAT TEST P_CU15-------------CORRECTE');
    ELSE
        DBMS_OUTPUT.PUT_LINE('RESULTAT TEST P_CU15-------------INCORRECTE');
    END IF;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('');

/**************************************************************************************
        PROVA P_CU16
*************************************************************************************/     
   --Execuci� del procediment
    P_CU16(2022, resposta);

    -- consultes manual per trobar la diferència de riscos detectats amb auditories internes i externes
    SELECT COUNT(r.riscId) INTO num_registres FROM RISC r, auditoriaexterna a
    WHERE a.inspeccioId=r.inspeccioId AND EXTRACT(YEAR FROM r.dataCreacio) = 2022 AND r.estat = 'ALTA';
    SELECT COUNT(r.riscId)  INTO num_registres2 FROM RISC r, auditoriainterna a
    WHERE a.inspeccioId=r.inspeccioId AND EXTRACT(YEAR FROM r.dataCreacio) = 2022 AND r.estat = 'ALTA';
    num_registres := ABS(num_registres - num_registres2);
      
    
    DBMS_OUTPUT.PUT_LINE('Prova P_CU16: ');
    DBMS_OUTPUT.PUT_LINE('Resultat esperat: '||num_registres);
    DBMS_OUTPUT.PUT_LINE('Resultat obtingut: '||resposta);
    IF num_registres = resposta THEN
        DBMS_OUTPUT.PUT_LINE('RESULTAT TEST P_CU16-------------CORRECTE');
    ELSE
        DBMS_OUTPUT.PUT_LINE('RESULTAT TEST P_CU16-------------INCORRECTE');
    END IF;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('');    
    
/**************************************************************************************
        PROVA P_CU17
*************************************************************************************/     
   --Execuci� del procediment
    P_CU17(resposta);

    -- consultes manual per trobar la id de la persona amb més accions assingades
    SELECT EMPLEATID INTO num_registres
        FROM ACCIOMITIGADORA
        WHERE ESTATACCIO IN ('En curs', 'Definida') AND ESTAT = 'ALTA'
        GROUP BY EMPLEATID ORDER BY COUNT(ACCIOID) DESC FETCH FIRST 1 ROWS ONLY;
      
    
    DBMS_OUTPUT.PUT_LINE('Prova P_CU17: ');
    DBMS_OUTPUT.PUT_LINE('Resultat esperat: '||num_registres);
    DBMS_OUTPUT.PUT_LINE('Resultat obtingut: '||resposta);
    IF num_registres = resposta THEN
        DBMS_OUTPUT.PUT_LINE('RESULTAT TEST P_CU17-------------CORRECTE');
    ELSE
        DBMS_OUTPUT.PUT_LINE('RESULTAT TEST P_CU17-------------INCORRECTE');
    END IF;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('');    
    


/**************************************************************************************
        PROVA P_CU18
*************************************************************************************/     
   --Execuci� del procediment
    P_CU18(resposta);

    -- consultes manual per trobar Nombre mitjà de mostrejos fets per any sense considerar l’any actual

    SELECT COUNT(mostreigId) INTO num_registres FROM mostreig WHERE ESTAT = 'ALTA' AND EXTRACT(YEAR FROM dataMostreig) != 2024;
    SELECT COUNT(DISTINCT EXTRACT(YEAR FROM (dataMostreig))) INTO num_registres2 FROM MOSTREIG WHERE EXTRACT(YEAR FROM (dataMostreig)) != 2024 AND ESTAT='ALTA';
    num_registres := num_registres/num_registres2;

    DBMS_OUTPUT.PUT_LINE('Prova P_CU18: ');
    DBMS_OUTPUT.PUT_LINE('Resultat esperat: '||num_registres);
    DBMS_OUTPUT.PUT_LINE('Resultat obtingut: '||resposta);
    IF num_registres = resposta THEN
        DBMS_OUTPUT.PUT_LINE('RESULTAT TEST P_CU18-------------CORRECTE');
    ELSE
        DBMS_OUTPUT.PUT_LINE('RESULTAT TEST P_CU18-------------INCORRECTE');
    END IF;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('');    


/**************************************************************************************
        PROVA P_CU19
*************************************************************************************/     
   --Execuci� del procediment
    P_CU19(resposta);

    -- consultes manual per trobar Tenint en compte l’any en curs i l’anterior, nombre de riscos de ciberseguretat
    --detectats per autoavaluació dels departaments
    SELECT catId INTO num_registres2 FROM CATEGORIA WHERE NOM = 'Ciberseguretat';

    SELECT COUNT(r.riscId) INTO num_registres 
        FROM RISC r, autoavaluacio a
        WHERE a.inspeccioId = r.inspeccioId AND r.catid = num_registres2
            AND (EXTRACT(YEAR FROM r.dataCreacio) = 2023 OR EXTRACT(YEAR FROM r.dataCreacio) = 2024) 
            AND r.estat = 'ALTA';    
    

    DBMS_OUTPUT.PUT_LINE('Prova P_CU19: ');
    DBMS_OUTPUT.PUT_LINE('Resultat esperat: '||num_registres);
    DBMS_OUTPUT.PUT_LINE('Resultat obtingut: '||resposta);
    IF num_registres = resposta THEN
        DBMS_OUTPUT.PUT_LINE('RESULTAT TEST P_CU19-------------CORRECTE');
    ELSE
        DBMS_OUTPUT.PUT_LINE('RESULTAT TEST P_CU19-------------INCORRECTE');
    END IF;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('');      

/**************************************************************************************
        PROVA P_CU20
*************************************************************************************/     
   --Execuci� del procediment
    P_CU20(resposta);

    -- consultes manual per trobar el cost mitjà de les auditories externes per el darrer any.
    SELECT AVG(ae.COST) INTO num_registres FROM AUDITORIAEXTERNA ae, inspeccio i WHERE i.inspeccioId = ae.inspeccioId AND EXTRACT(YEAR FROM i.dataInici) = 2023 ;

    

    DBMS_OUTPUT.PUT_LINE('Prova P_CU20: ');
    DBMS_OUTPUT.PUT_LINE('Resultat esperat: '||num_registres);
    DBMS_OUTPUT.PUT_LINE('Resultat obtingut: '||resposta);
    IF num_registres = resposta THEN
        DBMS_OUTPUT.PUT_LINE('RESULTAT TEST P_CU20-------------CORRECTE');
    ELSE
        DBMS_OUTPUT.PUT_LINE('RESULTAT TEST P_CU20-------------INCORRECTE');
    END IF;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('');      

/**************************************************************************************
        PROVA P_CU21
*************************************************************************************/     
   --Execuci� del procediment
    P_CU21(resposta);

    -- consultes manual per trobar any amb un nombre major d’accions que al final de l’any en qüestió estaven en estat d’implementada amb el risc mitigat
    SELECT EXTRACT(YEAR FROM dataImplementacio) INTO num_registres FROM ACCIOMITIGADORA 
        WHERE ESTATACCIO = 'Implementada amb el risc mitigat' GROUP BY EXTRACT(YEAR FROM dataImplementacio) ORDER BY COUNT(ACCIOID) DESC FETCH FIRST 1 ROWS ONLY;

    DBMS_OUTPUT.PUT_LINE('Prova P_CU21: ');
    DBMS_OUTPUT.PUT_LINE('Resultat esperat: '||num_registres);
    DBMS_OUTPUT.PUT_LINE('Resultat obtingut: '||resposta);
    IF num_registres = resposta THEN
        DBMS_OUTPUT.PUT_LINE('RESULTAT TEST P_CU21-------------CORRECTE');
    ELSE
        DBMS_OUTPUT.PUT_LINE('RESULTAT TEST P_CU21-------------INCORRECTE');
    END IF;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('');      

/**************************************************************************************
        PROVA P_CU22
*************************************************************************************/     
   --Execuci� del procediment
   

    -- consultes manual per trobar top 3 accoins que han estat més temps obertes-
    -- SELECT nom FROM ACCIOMITIGADORA 
    --     WHERE dataimplementacio IS NOT NULL AND EXTRACT(YEAR FROM DATAIMPLEMENTACIO)=2023
    --     ORDER BY dataImplementacio - dataCreacio DESC FETCH FIRST 3 ROWS ONLY;
    P_CU22(v_cursor);
    DBMS_OUTPUT.PUT_LINE('Prova P_CU22: ');
    DBMS_OUTPUT.PUT_LINE('Resultat esperat: ');
    FOR i in c_acciomitigadora LOOP
        dbms_output.put_line('Nom acció: '|| i.nom);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Resultat obtingut: ');
    LOOP
        FETCH v_cursor INTO v_accioNom;
        EXIT WHEN v_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Accio: ' || v_accioNom);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('');      

/**************************************************************************************
        PROVA P_CU23
*************************************************************************************/     
   --Execuci� del procediment
    P_CU23(resposta);

    -- consultes manual per trobar nombre de riscos de categoria 1 (en qualsevol estat) interpret que es impacte1
    SELECT COUNT(r.riscId) INTO num_registres FROM RISC r, categoria c WHERE c.importancia = 'Molt important' AND c.catid = r.catid AND r.estat = 'ALTA' AND c.estat = 'ALTA';

    DBMS_OUTPUT.PUT_LINE('Prova P_CU23: ');
    DBMS_OUTPUT.PUT_LINE('Resultat esperat: '||num_registres);
    DBMS_OUTPUT.PUT_LINE('Resultat obtingut: '||resposta);
    IF num_registres = resposta THEN
        DBMS_OUTPUT.PUT_LINE('RESULTAT TEST P_CU23-------------CORRECTE');
    ELSE
        DBMS_OUTPUT.PUT_LINE('RESULTAT TEST P_CU23-------------INCORRECTE');
    END IF;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('');      

/**************************************************************************************
        PROVA P_CU24
*************************************************************************************/     
   --Execuci� del procediment
    P_CU24(2023, resposta);

    -- consultes manual per trobar Donat un any en concret, percentatge d’accions descartades.
    SELECT COUNT(ACCIOID)
    INTO num_registres
    FROM ACCIOMITIGADORA
    WHERE ESTATACCIO = 'Descartada'
    AND estat = 'ALTA'
    AND EXTRACT(YEAR FROM DATACREACIO) = 2023;

    SELECT COUNT(ACCIOID)
    INTO num_registres2
    FROM ACCIOMITIGADORA
    WHERE estat = 'ALTA'
    AND EXTRACT(YEAR FROM DATACREACIO) = 2023;
    
    v_percentatge := (num_registres/num_registres2)*100;    


    DBMS_OUTPUT.PUT_LINE('Prova P_CU24: ');
    DBMS_OUTPUT.PUT_LINE('Resultat esperat: '||v_percentatge);
    DBMS_OUTPUT.PUT_LINE('Resultat obtingut: '||resposta);
    IF TRUNC(v_percentatge, 1) = TRUNC(resposta, 1) THEN
        DBMS_OUTPUT.PUT_LINE('RESULTAT TEST P_CU24-------------CORRECTE');
    ELSE
        DBMS_OUTPUT.PUT_LINE('RESULTAT TEST P_CU24-------------INCORRECTE');
    END IF;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('');      

/**************************************************************************************
        PROVA P_CU25
*************************************************************************************/     
   --Execuci� del procediment
    P_CU25(resposta);

    -- consultes manual per trobar el departament amb el major nombre de riscos.
    SELECT depId INTO num_registres FROM RISC
        GROUP BY depId
        ORDER BY COUNT(riscId) DESC
        FETCH FIRST 1 ROWS ONLY;


    DBMS_OUTPUT.PUT_LINE('Prova P_CU25: ');
    DBMS_OUTPUT.PUT_LINE('Resultat esperat: '||num_registres);
    DBMS_OUTPUT.PUT_LINE('Resultat obtingut: '||resposta);
    IF num_registres = resposta THEN
        DBMS_OUTPUT.PUT_LINE('RESULTAT TEST P_CU25-------------CORRECTE');
    ELSE
        DBMS_OUTPUT.PUT_LINE('RESULTAT TEST P_CU25-------------INCORRECTE');
    END IF;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('');      

/**************************************************************************************
        PROVA P_CU26
*************************************************************************************/     
    DBMS_OUTPUT.PUT_LINE('Prova P_CU26: ');
    --Execuci� del procediment
    P_CU26(v_cursor);

    DBMS_OUTPUT.PUT_LINE('Resultat esperat: ');
    SELECT COUNT(*) INTO num_registres FROM RISC WHERE ESTAT = 'ALTA';
    FOR reg in c_cat LOOP
        SELECT COUNT(*) INTO num_registres2 FROM RISC WHERE CATID = reg.catId;    
        IF num_registres2 > 0 THEN
                v_percentatge := (num_registres2/num_registres)*100;
                DBMS_OUTPUT.PUT_LINE('CatId: '||reg.catId||' nom: '||reg.nom||' percentatge: '||ROUND(v_percentatge, 2));        
        END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Resultat obtingut: ');
    LOOP
        FETCH v_cursor INTO num_registres, v_accioNom, v_percentatge;
        EXIT WHEN v_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('CatId: '||num_registres||' nom: '||v_accioNom||' percentatge: '||ROUND(v_percentatge, 2));
    END LOOP;
END;

/
               
    

--select * from risc;