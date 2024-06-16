/******************************************************************************************************************************************************************
* Script amb tots els procediments d'alta, baixa i modificacio de la base de dades. Aixi com els procediments per calcular l'impacte dels riscos.                 *
* IMPORTANT : Aquest script ha de ser executat amb l'usuari MRIERAMAR pwd 12345678                                                                                  *
*******************************************************************************************************************************************************************/


/*Fare un procediment per calcular l'impacte, d'aquesta manera en crear un risc, o en modificarne un de existent (o la categoria) es podra recalcukar i es modificara el risc.*/

CREATE OR REPLACE PROCEDURE P_calculImpacte(
    PCRITICITAT IN RISC.criticitat%TYPE,
    PIMPORTANCIA IN CATEGORIA.importancia%TYPE,
    PIMPACTE OUT RISC.impacte%TYPE)
IS
BEGIN 
    CASE 
        WHEN PCRITICITAT = 'Risc critic' AND PIMPORTANCIA = 'Molt important' THEN PIMPACTE:= 'Impacte catastrofic';--1
        WHEN PCRITICITAT = 'Risc critic' AND PIMPORTANCIA = 'Important' THEN PIMPACTE:= 'Impacte critic';--2
        WHEN PCRITICITAT = 'Risc critic' AND PIMPORTANCIA = 'Poc important' THEN PIMPACTE:= 'Impacte alt';--3
        WHEN PCRITICITAT = 'Risc moderat' AND PIMPORTANCIA = 'Molt important' THEN PIMPACTE:='Impacte critic';--2
        WHEN PCRITICITAT = 'Risc moderat' AND PIMPORTANCIA = 'Important' THEN PIMPACTE:='Impacte moderat';--4
        WHEN PCRITICITAT = 'Risc moderat' AND PIMPORTANCIA = 'Poc important' THEN PIMPACTE:='Impacte baix';--6
        WHEN PCRITICITAT = 'Risc baix' AND PIMPORTANCIA = 'Molt important' THEN PIMPACTE:='Impacte alt';--3
        WHEN PCRITICITAT = 'Risc baix' AND PIMPORTANCIA = 'Important' THEN PIMPACTE:='Impacte baix';--6
        WHEN PCRITICITAT = 'Risc baix' AND PIMPORTANCIA = 'Poc important' THEN PIMPACTE:='Impacte molt baix'; --9
    END CASE;
END;

/

/***********************************************************************************************************************************************************
TRIGGER PER ACTUALIZAR L'impacte dels riscs quan es modifica una categoria
**********************************************************************************************************************************************************/

CREATE OR REPLACE PROCEDURE P_actualizar_risc(
    PCATID CATEGORIA.catId%TYPE)
    IS
        v_impacte risc.impacte%TYPE;
        v_importancia categoria.importancia%TYPE;
    BEGIN
        --Obtenim la importància de la categoria.
        SELECT importancia INTO v_importancia FROM categoria WHERE catId = PCATID;
        --Feim un bucle amb tots els riscs que pertanyen a la categoria i els actualitzam.

        FOR r IN (SELECT riscId, criticitat
                    FROM risc
                    WHERE catid = PCATID)
        LOOP
        --Obtenim l'impacte nou i canviam el valor de limpacte al risc.
            P_calculImpacte(r.criticitat, v_importancia, v_impacte);
            UPDATE risc SET impacte = v_impacte where riscId = r.riscId;        
        END LOOP;
    END;
/
/******************************************************************************
Procediments ABM taula DEPARTAMENT
*******************************************************************************/  
----------------------------- ALTA ---------------------------------------------

CREATE OR REPLACE PROCEDURE P_Alta_Departament(
    PNOMDEP IN DEPARTAMENT.depNom%TYPE,
    PRESPOSTA OUT VARCHAR2) 
    IS 
        valor_NULL   exception;
        PRAGMA EXCEPTION_INIT(valor_NULL, -1400);
        v_codi_error  Integer;
        v_nompro VARCHAR2(100);
        num_registres Integer;
        nom_duplicat EXCEPTION;
    
    BEGIN
        v_nomPro := $$PLSQL_UNIT;
        --Comprovam de que el nom del departament ja existeix
        SELECT COUNT(DEPNOM) INTO num_registres FROM DEPARTAMENT WHERE DEPNOM = PNOMDEP;
        IF num_registres > 0 THEN
            RAISE nom_duplicat;
        END IF;
        --Insertam el departament
        INSERT INTO DEPARTAMENT (depNom) VALUES (PNOMDEP);
        --Generam la resposta i la mostram per pantalla
        PRESPOSTA:='OK';
        Dbms_output.Put_line(PRESPOSTA);
        INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,PNOMDEP, PRESPOSTA, SYSDATE);
        Commit;
        
    -- Control errors--    
    EXCEPTION
    --Valor null--
        WHEN valor_NULL THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: El nom del departament no pot ser NULL ' || v_codi_error ||' ' || SQLERRM ,1,100);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, PNOMDEP, PRESPOSTA, SYSDATE);
            Commit;
    --Nom duplicat
        WHEN nom_duplicat THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: El nom del departament ja existeix ' || v_codi_error ||' ' || SQLERRM ,1,100);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, PNOMDEP, PRESPOSTA, SYSDATE);
            Commit;        
    --Index duplicat--
        WHEN DUP_VAL_ON_INDEX THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,PNOMDEP, PRESPOSTA, SYSDATE);
            COMMIT;
                
    -- Tipus incorrecte--    
      WHEN ROWTYPE_MISMATCH THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,PNOMDEP, PRESPOSTA, SYSDATE);
            Commit;
            
    --Altres--    
      WHEN Others THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,PNOMDEP, PRESPOSTA, SYSDATE);
            Commit;        
    END;
/

----------------------------- BAIXA ---------------------------------------------

CREATE OR REPLACE PROCEDURE P_BAIXA_DEPARTAMENT(
    PDEPID IN DEPARTAMENT.DEPID%TYPE,
    PRESPOSTA Out Varchar2)
    IS
        param_input Varchar2(150);
        num_reg Integer;
        num_reg_empleat Integer;
        v_codi_error Integer;
        baixa_existent EXCEPTION;
        id_inexistent EXCEPTION;
        empleats_asociats EXCEPTION;
        v_nompro VARCHAR2(50);
    
    BEGIN
       
      -- Guardar els parametres d'entrada para insertarlo al LOG
        param_input := 'ID DEPARTAMENT=' || PDEPID;
        v_nomPro := TO_CHAR($$PLSQL_UNIT);
      -- Comprobar si el departament existeix
        SELECT count(depId) INTO num_reg FROM DEPARTAMENT WHERE depId = PDEPID;
        IF num_reg = 0 THEN
            raise id_inexistent;
        END IF;
         -- Comprobar si el departamet ja esta de baixa.
        SELECT count(depId) INTO num_reg FROM DEPARTAMENT WHERE depId = PDEPID AND estat = 'BAIXA';
        IF num_reg = 1 THEN
            raise baixa_existent;
        END IF;
        
        SELECT count(depId) INTO num_reg_empleat FROM EMPLEAT WHERE depId = PDEPID AND estat = 'ALTA';
        IF num_reg_empleat <> 0 THEN
            raise empleats_asociats;
        END IF;  
      -- donar de baixa el departament si esta d'alta
        UPDATE DEPARTAMENT SET ESTAT = 'BAIXA' WHERE depId = PDEPID AND estat = 'ALTA';
    
        PRESPOSTA := 'OK';
        DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
        INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
        COMMIT;

    EXCEPTION
    
        WHEN baixa_existent THEN
            PRESPOSTA := 'ERROR: El Departament amb la id '||PDEPID||' ja ha estat donat de baixa anteriorment';
            DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;
            
        WHEN id_inexistent THEN
            PRESPOSTA := 'ERROR: El Departament amb la id '||PDEPID||' no existeix';
            DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;    
            
        WHEN empleats_asociats THEN
            PRESPOSTA := 'ERROR: El Departament amb la id '||PDEPID||' t� empleats dalta asociats';
            DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;
            
        -- Tipus incorrecte--    
        WHEN ROWTYPE_MISMATCH THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            COMMIT;    
    
        WHEN OTHERS THEN
            v_codi_error := SQLCODE;
            PRESPOSTA := 'ERROR: ' || SQLERRM;
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            -- Insertar registre d'error al LOG
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;
    End;
    /

-------------------------------- MODIFICACIO------------------------------------

create or replace Procedure P_MODIFICACIO_DEPARTAMENT(
    PDEPID In DEPARTAMENT.depId%type,
    PDEPNOM In DEPARTAMENT.depNom%type,
    PRESPOSTA Out Varchar2)
    IS
        param_input Varchar2(300);
        num_reg Integer;
        v_codi_error Integer;
        id_inexistent EXCEPTION;
        estat_baixa EXCEPTION;
        v_nompro VARCHAR2(50);

    
    BEGIN
        v_nomPro := $$PLSQL_UNIT;
    --Posam els valors d'entrada dins l'input--
        param_input := 'ID DEPARTAMENT=' || PDEPID || ', NOM DEPARTAMENT: '||PDEPNOM;
    --Comprovaci� de que el departament existeix i est� d'alta--     
        SELECT count(depid) INTO num_reg FROM DEPARTAMENT  WHERE depId = PDEPID;
        IF num_reg = 0 THEN
            RAISE id_inexistent;
        END IF;
    --Modificacio de les dades     
        UPDATE DEPARTAMENT SET depNom = PDEPNOM WHERE depId = PDEPID AND estat='ALTA';
        IF SQL%ROWCOUNT = 0 THEN
            v_codi_error := SQLCODE;
            RAISE estat_baixa;
        END IF;
        PRESPOSTA:='OK';
        INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
        Dbms_output.Put_line(PRESPOSTA);
        COMMIT;
        EXCEPTION
        
            WHEN id_inexistent THEN
                PRESPOSTA := 'ERROR: El Departament amb la id '||PDEPID||' no existeix';
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;    
            WHEN estat_baixa THEN
                PRESPOSTA := 'ERROR: El Departament amb la id '||PDEPID||' esta donat de baixa';
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;
                
            WHEN ROWTYPE_MISMATCH THEN
                v_codi_error := SQLCODE;
                PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nompro,param_input, PRESPOSTA, SYSDATE);
                Commit;    
   
            WHEN OTHERS THEN
                v_codi_error := SQLCODE;
                PRESPOSTA := 'ERROR: ' || SQLERRM;
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                -- Insertar registre d'error al LOG
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;    
            
    END;                 

/
/******************************************************************************
Procediments ABM taula EMPLEAT
*******************************************************************************/ 
    
CREATE OR REPLACE PROCEDURE P_Alta_EMPLEAT(
    PDEPID IN EMPLEAT.DEPID%TYPE,
    PNOM IN EMPLEAT.NOM%TYPE,
    PLLINATGES IN EMPLEAT.LLINATGES%TYPE,
    PDNI IN EMPLEAT.DNI%TYPE,
    PTELEFON IN EMPLEAT.TELEFON%TYPE,
    PEMAIL IN EMPLEAT.EMAIL%TYPE,
    PRESPOSTA OUT VARCHAR2) 
    IS 
        valor_NULL   exception;
        PRAGMA EXCEPTION_INIT(valor_NULL, -1400);
        departament_inexistent EXCEPTION;
        PRAGMA EXCEPTION_INIT(departament_inexistent, -20001);
        departament_baixa EXCEPTION;
        PRAGMA EXCEPTION_INIT(departament_baixa, -20002);
        v_codi_error  Integer;
        v_nompro VARCHAR2(100);
        param_input Varchar2(150);
        num_registres Integer;
    
    BEGIN
    --Volcam dades dins variables per imprimir al log
        v_nomPro := $$PLSQL_UNIT;
        param_input:= 'PDEPID = '||PDEPID|| ' PNOM = '||PNOM||' PLLINATGES = '||PLLINATGES||' PDNI = '||PDNI||' PTELEFON = '||PTELEFON||' PEMAIL = '||PEMAIL;
        --Comprovaci� de que el departament existeix
        SELECT COUNT(DEPID) INTO num_registres FROM DEPARTAMENT WHERE DEPID = PDEPID;
        IF num_registres = 0 THEN
            RAISE departament_inexistent;
        ELSE
        --Comprovacio de que el departament esta d'alta
            SELECT COUNT(DEPID) INTO num_registres FROM DEPARTAMENT WHERE DEPID = PDEPID AND estat = 'ALTA';
            IF num_registres = 0 THEN
            RAISE departament_baixa;
            END IF;
        END IF;    
        INSERT INTO EMPLEAT (depId, nom, llinatges, dni, telefon, email) VALUES
            (PDEPID, PNOM, PLLINATGES, PDNI, PTELEFON, PEMAIL);
        PRESPOSTA:='OK';
        Dbms_output.Put_line(PRESPOSTA);
        INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
        Commit;
        
    -- Control errors--    
    EXCEPTION
    --Valor null--
        WHEN valor_NULL THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: el valor no pot ser null NULL ' || v_codi_error ||' ' || SQLERRM ,1,100);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;
        --Si el departament no existeix
        WHEN departament_inexistent THEN
        v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: el departament no existeix ' || v_codi_error ||' ' || SQLERRM ,1,100);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;
        --Si el departament esta de baixa    
        WHEN departament_baixa THEN
        v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: el departament esta de baixa ' || v_codi_error ||' ' || SQLERRM ,1,100);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;            
    --Index duplicat--
        WHEN DUP_VAL_ON_INDEX THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            COMMIT;
                
    -- Tipus incorrecte--    
      WHEN ROWTYPE_MISMATCH THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            Commit;
            
    --Altres--    
      WHEN Others THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            Commit;        
    END;
/

----------------------------- BAIXA ---------------------------------------------

CREATE OR REPLACE PROCEDURE P_BAIXA_EMPLEAT(
    PEMPLEATID IN EMPLEAT.EMPLEATID%TYPE,
    PRESPOSTA Out Varchar2)
    IS
        param_input Varchar2(150);
        num_reg Integer;
        v_codi_error Integer;
        baixa_existent EXCEPTION;
        id_inexistent EXCEPTION;
        empleat_responsable EXCEPTION;
        empleat_lider EXCEPTION;
        empleat_accio EXCEPTION;
        empleat_risc EXCEPTION;
        v_nompro VARCHAR2(50);
    
    BEGIN
       
      -- Guardar els parametres d'entrada para insertarlo al LOG
        param_input := 'ID EMPLEAT = ' || PEMPLEATID;
        v_nomPro := TO_CHAR($$PLSQL_UNIT);
      -- Comprovar si l'exmpleat existeix
        SELECT count(empleatid) INTO num_reg FROM EMPLEAT WHERE empleatId = PEMPLEATID;
        IF num_reg = 0 THEN
            raise id_inexistent;
        END IF;
         -- Comprovar si el l'empleat ja esta de baixa.
        SELECT count(empleatid) INTO num_reg FROM EMPLEAT WHERE empleatId = PEMPLEATID AND estat = 'BAIXA';
        IF num_reg = 1 THEN
            raise baixa_existent;
        END IF;
        --Comprovar si l'empleat es responsable d'alguna categoria que estigui d'alta:
        SELECT count (empleatId) INTO num_reg FROM CATEGORIA WHERE empleatId = PEMPLEATID AND estat = 'ALTA';
         IF num_reg = 1 THEN
            raise empleat_responsable;
        END IF;
        --Comprovar si l'empleat eslider d'alguna campanya que estigui d'alta:
         SELECT count (empleatId) INTO num_reg FROM CAMPANYA WHERE empleatId = PEMPLEATID AND estat = 'ALTA';
         IF num_reg >= 1 THEN
            raise empleat_lider;
        END IF;
         SELECT count (empleatId) INTO num_reg FROM RISC WHERE empleatId = PEMPLEATID;
         IF num_reg >= 1 THEN
            raise empleat_risc;
        END IF;
        SELECT count (empleatId) INTO num_reg FROM ACCIOMITIGADORA WHERE empleatId = PEMPLEATID;
         IF num_reg >= 1 THEN
            raise empleat_accio;
        END IF;
        
      -- Donar de baixa l'empleat si te l'estat 'ALTA'
        UPDATE EMPLEAT SET ESTAT = 'BAIXA' WHERE empleatId = PempleatId AND estat = 'ALTA';
    
        PRESPOSTA := 'OK';
        Dbms_output.Put_line(PRESPOSTA);
        INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
        COMMIT;

    EXCEPTION
    
        WHEN baixa_existent THEN
            PRESPOSTA := 'ERROR: Lempleat amb la id '||PEMPLEATID||' ja ha estat donat de baixa anteriorment';
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;
            
        WHEN id_inexistent THEN
            PRESPOSTA := 'ERROR: Lempleat amb la id '||PEMPLEATID||' no existeix';
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;    
        
        WHEN empleat_responsable THEN
            PRESPOSTA := 'ERROR: Lempleat amb la id '||PEMPLEATID||'es responsable duna categoria';
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;        
        
        WHEN empleat_lider THEN
            PRESPOSTA := 'ERROR: Lempleat amb la id '||PEMPLEATID||' es el lider duna campanya';
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;          
            
        WHEN empleat_accio THEN
            PRESPOSTA := 'ERROR: Lempleat amb la id '||PEMPLEATID||' es el responsable d''una accio';
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;                    

        WHEN empleat_risc THEN
            PRESPOSTA := 'ERROR: Lempleat amb la id '||PEMPLEATID||' es el responsable d''un risc';
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;                                    
        -- Tipus incorrecte--    
        WHEN ROWTYPE_MISMATCH THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            COMMIT;    
    
        WHEN OTHERS THEN
            v_codi_error := SQLCODE;
            PRESPOSTA := 'ERROR: ' || SQLERRM;
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;
    End;
    /

-------------------------------- MODIFICACIO------------------------------------

create or replace Procedure P_MODIFICACIO_EMPLEAT(
    PEMPLEATID IN EMPLEAT.EMPLEATID%TYPE,
    PDEPID IN EMPLEAT.DEPID%TYPE,
    PNOM IN EMPLEAT.NOM%TYPE,
    PLLINATGES IN EMPLEAT.LLINATGES%TYPE,
    PDNI IN EMPLEAT.DNI%TYPE,
    PTELEFON IN EMPLEAT.TELEFON%TYPE,
    PEMAIL IN EMPLEAT.EMAIL%TYPE,
    PRESPOSTA Out Varchar2)
    IS
        param_input Varchar2(300);
        num_reg Integer;
        v_codi_error Integer;
        id_inexistent EXCEPTION;
        estat_baixa EXCEPTION;
        v_nompro VARCHAR2(50);

    
    BEGIN
        v_nomPro := $$PLSQL_UNIT;
    --Posam els valors d'entrada dins l'input--
        param_input := 'PEMPLEATID = '||PEMPLEATID||'PDEPID = '||PDEPID|| ' PNOM = '||PNOM||' PLLINATGES = '||PLLINATGES||' PDNI = '||PDNI||' PTELEFON = '||PTELEFON||' PEMAIL = '||PEMAIL;
    --Comprovaci� de que l'empleat existeix i est� d'alta--     
        SELECT count(empleatId) INTO num_reg FROM EMPLEAT  WHERE empleatId = PEMPLEATID;
        IF num_reg = 0 THEN
            RAISE id_inexistent;
        END IF;
    --Modificacio de les dades     
        UPDATE EMPLEAT SET depId = PDEPID, nom = PNOM, llinatges =PLLINATGES, dni = PDNI , telefon=PTELEFON, email = PEMAIL WHERE empleatid = Pempleatid AND estat='ALTA';
        IF SQL%ROWCOUNT = 0 THEN
            v_codi_error := SQLCODE;
            RAISE estat_baixa;
        END IF;
        PRESPOSTA:='OK';
        INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
        Dbms_output.Put_line(PRESPOSTA);
        COMMIT;
        EXCEPTION
        
            WHEN id_inexistent THEN
                PRESPOSTA := 'ERROR: l''empleat  amb la id '||PDEPID||' no existeix';
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;    

            WHEN estat_baixa THEN
                PRESPOSTA := 'ERROR: l''empleat amb la id '||PDEPID||' esta donat de baixa';
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;
                
            WHEN ROWTYPE_MISMATCH THEN
                v_codi_error := SQLCODE;
                PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nompro,param_input, PRESPOSTA, SYSDATE);
                Commit;    
   
            WHEN OTHERS THEN
                v_codi_error := SQLCODE;
                PRESPOSTA := 'ERROR: ' || SQLERRM;
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;    
            
    END;                 

/
/******************************************************************************
Procediments ABM taula CATEGORIA
*******************************************************************************/ 
    
CREATE OR REPLACE PROCEDURE P_Alta_CAT(
    PEMPLEATID IN CATEGORIA.empleatId%TYPE,
    PNOM IN CATEGORIA.nom%TYPE ,
    PIMPORTANCIA IN CATEGORIA.importancia%TYPE,
    PRESPOSTA OUT VARCHAR2) 
    IS 
        valor_NULL   exception;
        PRAGMA EXCEPTION_INIT(valor_NULL, -1400);
        EMPLEAT_inexistent EXCEPTION;
        PRAGMA EXCEPTION_INIT(EMPLEAT_inexistent, -20001);
        EMPLEAT_baixa EXCEPTION;
        PRAGMA EXCEPTION_INIT(EMPLEAT_baixa, -20002);
        importancia_incorrecta EXCEPTION;
        v_codi_error  Integer;
        v_nompro VARCHAR2(100);
        param_input Varchar2(150);
        num_registres Integer;
        nom_duplicat EXCEPTION;
    
    BEGIN
    --Volcam dades dins variables per imprimir al log
        v_nomPro := $$PLSQL_UNIT;
        param_input:= 'PEMPLEATID = '||PEMPLEATID|| ' PNOM = '||PNOM||' PIMPORTANCIA = '||PIMPORTANCIA;
        --Comprovaci� de que L'EMPLEAT responsable existeix
        SELECT COUNT(empleatid) INTO num_registres FROM empleat WHERE empleatid = PEMPLEATID;
        IF num_registres = 0 THEN
            RAISE EMPLEAT_inexistent;
        ELSE
        --Comprovacio de que L'EMPLEAT responsable esta d'alta
            SELECT COUNT(empleatid) INTO num_registres FROM empleat WHERE empleatid = PEMPLEATID AND estat = 'ALTA';
            IF num_registres = 0 THEN
            RAISE EMPLEAT_baixa;
            END IF;
        END IF;
        --Comprovam que importancia és del valors esperats
        IF pimportancia NOT IN ('Molt important', 'Important', 'Poc important') THEN
            RAISE importancia_incorrecta;
        END IF;    
        --Comprovam de que el nom del departament ja existeix
        SELECT COUNT(nom) INTO num_registres FROM CATEGORIA WHERE NOM = PNOM;
        IF num_registres > 0 THEN
            RAISE nom_duplicat;
        END IF;
        
        INSERT INTO CATEGORIA (empleatId, nom, dataCreacio, importancia) VALUES
            (PEMPLEATID, PNOM, SYSDATE, PIMPORTANCIA);
        PRESPOSTA:='OK';
        Dbms_output.Put_line(PRESPOSTA);
        INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
        Commit;
        
    -- Control errors--    
    EXCEPTION
    --Valor null--
        WHEN valor_NULL THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: el valor no pot ser null NULL ' || v_codi_error ||' ' || SQLERRM ,1,100);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;
        --Si lempleat no existeix
        WHEN EMPLEAT_inexistent THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: el empleat responsable no existeix ' || v_codi_error ||' ' || SQLERRM ,1,100);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;
        WHEN nom_duplicat THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: El nom introduit ja esta donat d''alta ' || v_codi_error ||' ' || SQLERRM ,1,100);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;
        WHEN importancia_incorrecta THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: la importancia no esta dins els tipus esperats' || v_codi_error ||' ' || SQLERRM ,1,100);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;    
        --Si lempleat esta de baixa    
        WHEN EMPLEAT_baixa THEN
        v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: el empleat responsable te estat baixa ' || v_codi_error ||' ' || SQLERRM ,1,100);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;            
    --Index duplicat--
        WHEN DUP_VAL_ON_INDEX THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            COMMIT;
                
    -- Tipus incorrecte--    
      WHEN ROWTYPE_MISMATCH THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            Commit;
            
    --Altres--    
      WHEN Others THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            Commit;        
    END;
/

----------------------------- BAIXA ---------------------------------------------
CREATE OR REPLACE PROCEDURE P_BAIXA_CAT(
    PCATID IN CATEGORIA.CATID%TYPE,
    PRESPOSTA Out Varchar2)
    IS
        param_input Varchar2(150);
        num_reg Integer;
        v_codi_error Integer;
        baixa_existent EXCEPTION;
        id_inexistent EXCEPTION;
        ricss_asociats EXCEPTION;
        v_nompro VARCHAR2(50);
    
    BEGIN
       
      -- Guardar els parametres d'entrada para insertarlo al LOG
        param_input := 'ID PCATID = ' || PCATID;
        v_nomPro := TO_CHAR($$PLSQL_UNIT);
      -- Comprovar si la categoria existeix
        SELECT count(catId) INTO num_reg FROM CATEGORIA WHERE catId = PCATID;
        IF num_reg = 0 THEN
            raise id_inexistent;
        END IF;
         -- Comprovar si la categoria ja esta de baixa.
        SELECT count(catId) INTO num_reg FROM CATEGORIA WHERE catId = PCATID AND estat = 'BAIXA';
        IF num_reg = 1 THEN
            raise baixa_existent;
        END IF;
        --Comprovar si te riscs asociats
        SELECT count(catId) INTO num_reg FROM RISC WHERE catId = PCATID AND estat = 'ALTA';
        IF num_reg >= 1 THEN
            raise ricss_asociats;
        END IF;
      -- Donar de baixa la categoria si te l'estat 'ALTA'
        UPDATE CATEGORIA SET ESTAT = 'BAIXA' WHERE catId = PCATID AND estat = 'ALTA';
    
        PRESPOSTA := 'OK';
        DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
        INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
        COMMIT;

    EXCEPTION
    
        WHEN baixa_existent THEN
            PRESPOSTA := 'ERROR: La categoria amb la id '||PCATID||' ja ha estat donat de baixa anteriorment';
            DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;
            
        WHEN id_inexistent THEN
            PRESPOSTA := 'ERROR: La categoria amb la id '||PCATID||' no existeix';
            DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;    
        
        WHEN ricss_asociats THEN
            PRESPOSTA := 'ERROR: La categoria amb la id '||PCATID||' te riscs asociats';
            DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;        
        -- Tipus incorrecte--    
        WHEN ROWTYPE_MISMATCH THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            COMMIT;    
    
        WHEN OTHERS THEN
            v_codi_error := SQLCODE;
            PRESPOSTA := 'ERROR: ' || SQLERRM;
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;
    End;
    /

-------------------------------- MODIFICACIO------------------------------------

create or replace Procedure P_MODIFICACIO_CAT(
    PCATID IN CATEGORIA.catId%TYPE,
    PEMPLEATID IN CATEGORIA.empleatId%TYPE,
    PNOM IN CATEGORIA.nom%TYPE ,
    PIMPORTANCIA IN CATEGORIA.importancia%TYPE,
    PRESPOSTA Out Varchar2)
    IS
        param_input Varchar2(300);
        num_reg Integer;
        v_codi_error Integer;
        id_inexistent EXCEPTION;
        estat_baixa EXCEPTION;
        v_nompro VARCHAR2(50);
        EMPLEAT_inexistent EXCEPTION;
        nom_duplicat EXCEPTION;
        importancia_incorrecta EXCEPTION;
        num_registres NUMBER;

    
    BEGIN
        v_nomPro := $$PLSQL_UNIT;
    --Posam els valors d'entrada dins l'input--
        param_input := 'PCATID = '||PCATID||'PEMPLEATID = '||PEMPLEATID|| ' PNOM = '||PNOM||' PIMPORTANCIA = '||PIMPORTANCIA;
    --Comprovaci� de que la categoria existeix i est� d'alta--     
        SELECT count(catId) INTO num_reg FROM CATEGORIA  WHERE catID = PCATID;
        IF num_reg = 0 THEN
            RAISE id_inexistent;
        END IF;
        --comprovacio de que l'empleat existeix i esta d'alta
        SELECT COUNT(empleatid) INTO num_reg FROM empleat WHERE empleatid = PEMPLEATID AND estat = 'ALTA';
        IF num_reg = 0 THEN
            RAISE EMPLEAT_inexistent;
        End IF;
        --Comprovam la nova importancia
        IF PIMPORTANCIA NOT IN ('Molt important', 'Important', 'Poc important') THEN
            RAISE importancia_incorrecta;
        END IF;    
        --Comprovam de que el nom del departament ja existeix
        SELECT COUNT(nom) INTO num_registres FROM CATEGORIA WHERE NOM = PNOM AND catId != PCATID;
        IF num_registres > 0 THEN
            RAISE nom_duplicat;
        END IF;
    --Modificacio de les dades     
        UPDATE CATEGORIA SET empleatId=PempleatId, nom = PNOM, importancia=pimportancia  WHERE catId = PCATID AND estat='ALTA';
        IF SQL%ROWCOUNT = 0 THEN
            v_codi_error := SQLCODE;
            RAISE estat_baixa;
        END IF;
        --Actualitzam l'impacte dels riscs per la categoria modificada.
        P_actualizar_risc(PCATID);
        PRESPOSTA:='OK';
        INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
        Dbms_output.Put_line(PRESPOSTA);
        COMMIT;
        EXCEPTION
        
            WHEN id_inexistent THEN
                PRESPOSTA := 'ERROR: registre amb la id '||PCATID||' no existeix';
                DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;    
            WHEN estat_baixa THEN
                PRESPOSTA := 'ERROR: registre amb la id '||PCATID||' esta donat de baixa';
                DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;
            WHEN empleat_inexistent THEN
                PRESPOSTA := 'ERROR: lempleat amb la id '||PEMPLEATID||' no existeix o esta de baixa';
                DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;        
            WHEN ROWTYPE_MISMATCH THEN
                v_codi_error := SQLCODE;
                PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nompro,param_input, PRESPOSTA, SYSDATE);
                Commit;    
            WHEN nom_duplicat THEN
                v_codi_error := SQLCODE;
                PRESPOSTA:= SUBSTR('ERROR: El nom introduit ja esta donat d''alta ' || v_codi_error ||' ' || SQLERRM ,1,100);
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
                Commit;
                
            WHEN importancia_incorrecta THEN
                v_codi_error := SQLCODE;
                PRESPOSTA:= SUBSTR('ERROR: la importancia no esta dins els tipus esperats' || v_codi_error ||' ' || SQLERRM ,1,100);
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
                Commit;    
            WHEN OTHERS THEN
                v_codi_error := SQLCODE;
                PRESPOSTA := 'ERROR: ' || SQLERRM;
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;    
            
    END;                 

/

/******************************************************************************
Procediments ABM taula AUTOAVALUACIO
*******************************************************************************/ 

CREATE OR REPLACE PROCEDURE P_Alta_AUTOAVALUACIO(

    PDESCRIPCIO IN AUTOAVALUACIO.DESCRIPCIO%TYPE,
    PDATAINICI IN INSPECCIO.dataInici%TYPE,
    PdataFi IN INSPECCIO.dataFi%TYPE ,
    presultat IN INSPECCIO.resultat%TYPE,
    PRESPOSTA OUT VARCHAR2) 
    IS 
        valor_NULL exception;
        PRAGMA EXCEPTION_INIT(valor_NULL, -1400);
        v_codi_error  Integer;
        v_nompro VARCHAR2(100);
        param_input Varchar2(150);
        v_inspeccioId INSPECCIO.inspeccioId%TYPE;
        data_incorrecta EXCEPTION;
    
    BEGIN
    --Volcam dades dins variables per imprimir al log
        v_nomPro := $$PLSQL_UNIT;
        param_input:= 'PDESCRIPCIO = '||PDESCRIPCIO||' PDATAINICI = '||PDATAINICI||' PdataFi = '||PdataFi||' presultat = '||presultat;
        --Comprovar que la dataFi és posterior a la dataInici
        IF PdataFi < PDATAINICI THEN
            RAISE data_incorrecta;
        END IF;
        --Es fa l'inser a la taula inspeccio, es recupera la id ies fa l'insert a la taula autoavaluacio.
        INSERT INTO INSPECCIO (dataInici, dataFi, resultat) VALUES (PDATAINICI, PdataFi, presultat) RETURNING inspeccioId INTO v_inspeccioId;
        INSERT INTO AUTOAVALUACIO(inspeccioId, descripcio) VALUES (v_inspeccioId, PDESCRIPCIO);

        PRESPOSTA:='OK';
        Dbms_output.Put_line(PRESPOSTA);
        INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
        Commit;
        
    -- Control errors--    
    EXCEPTION
    --Valor null--
        WHEN valor_NULL THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: el valor no pot ser null NULL ' || v_codi_error ||' ' || SQLERRM ,1,100);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;

        WHEN data_incorrecta THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= 'ERROR: La data de finalització no pot ser anterior a la data actual';
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;
    --Index duplicat--
        WHEN DUP_VAL_ON_INDEX THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            COMMIT;
                
    -- Tipus incorrecte--    
      WHEN ROWTYPE_MISMATCH THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            Commit;
            
    --Altres--    
      WHEN Others THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            Commit;        
    END;
/

----------------------------- BAIXA ---------------------------------------------
CREATE OR REPLACE PROCEDURE P_BAIXA_AUTOAVALUACIO(
    PINSPECCIOID IN INSPECCIO.inspeccioId%TYPE,
    PRESPOSTA Out Varchar2)
    IS
        param_input Varchar2(150);
        num_reg Integer;
        v_codi_error Integer;
        baixa_existent EXCEPTION;
        id_inexistent EXCEPTION;
        campanya_asociada EXCEPTION;
        v_nompro VARCHAR2(50);
    
    BEGIN
       
      -- Guardar els parametres d'entrada para insertarlo al LOG
        param_input := 'ID PINSPECCIOID = ' || PINSPECCIOID;
        v_nomPro := TO_CHAR($$PLSQL_UNIT);
      -- Comprovar si existeix a la taula pare i a la filla.
       SELECT count(inspeccioId) INTO num_reg FROM AUTOAVALUACIO WHERE inspeccioId = pinspeccioId;
        IF num_reg = 0 THEN
            raise id_inexistent;
        END IF;
        SELECT count(inspeccioId) INTO num_reg FROM INSPECCIO WHERE inspeccioId = pinspeccioId;
        IF num_reg = 0 THEN
            raise id_inexistent;
        END IF;
         -- Comprovar si ja esta de baixa a ambdues taules.
        SELECT count(inspeccioId) INTO num_reg FROM INSPECCIO WHERE inspeccioId = pinspeccioId AND estat = 'BAIXA';
        IF num_reg = 1 THEN
            raise baixa_existent;
        END IF;
        SELECT count(inspeccioId) INTO num_reg FROM AUTOAVALUACIO WHERE inspeccioId = pinspeccioId AND estat = 'BAIXA';
        IF num_reg = 1 THEN
            raise baixa_existent;
        END IF;
        --Comprovar si te campanyes en estat alta
        SELECT count(inspeccioId) INTO num_reg FROM CAMPANYA WHERE inspeccioId = pinspeccioId AND estat = 'ALTA';
        IF num_reg >= 1 THEN
            raise campanya_asociada;
        END IF;
      -- Donar de baixa si te l'estat 'ALTA'
        UPDATE INSPECCIO SET ESTAT = 'BAIXA' WHERE INSPECCIOID = PINSPECCIOID AND estat = 'ALTA';
        UPDATE AUTOAVALUACIO SET ESTAT = 'BAIXA' WHERE INSPECCIOID = PINSPECCIOID AND estat = 'ALTA';
    
        PRESPOSTA := 'OK';
        DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
        INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
        COMMIT;

    EXCEPTION
    
        WHEN baixa_existent THEN
            PRESPOSTA := 'ERROR: Lautoavaluacio amb la id '||PINSPECCIOID||' ja ha estat donat de baixa anteriorment';
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;
            
        WHEN id_inexistent THEN
            PRESPOSTA := 'ERROR: Lautoavaluacio amb la id '||PINSPECCIOID||' no existeix';
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;    
        WHEN campanya_asociada THEN
            PRESPOSTA := 'ERROR:Lautoavaluacio amb la id '||PINSPECCIOID||' te campanyes associades alta.';
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;    
        -- Tipus incorrecte--    
        WHEN ROWTYPE_MISMATCH THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            COMMIT;    
    
        WHEN OTHERS THEN
            v_codi_error := SQLCODE;
            PRESPOSTA := 'ERROR: ' || SQLERRM;
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;
    End;
    /

-------------------------------- MODIFICACIO------------------------------------

create or replace Procedure P_MODIFICACIO_AUTOAVALUACIO(
    PINSPECCIOID IN INSPECCIO.inspeccioId%TYPE,
    PDESCRIPCIO IN AUTOAVALUACIO.DESCRIPCIO%TYPE,
    PDATAINICI IN INSPECCIO.dataInici%TYPE,
    PdataFi IN INSPECCIO.dataFi%TYPE ,
    presultat IN INSPECCIO.resultat%TYPE,
    PRESPOSTA Out Varchar2)
    IS
        param_input Varchar2(300);
        num_reg Integer;
        v_codi_error Integer;
        id_inexistent EXCEPTION;
        estat_baixa EXCEPTION;
        v_nompro VARCHAR2(50);

    
    BEGIN
        v_nomPro := $$PLSQL_UNIT;
    --Posam els valors d'entrada dins l'input--
        param_input := 'PINSPECCIOID = '||PINSPECCIOID||' PDATAINICI = '||PDATAINICI|| ' PdataFi = '||PdataFi;
    --Comprovaci� de que existeix i est� d'alta--     
        SELECT count(INSPECCIOID) INTO num_reg FROM AUTOAVALUACIO  WHERE INSPECCIOID = PINSPECCIOID;
        IF num_reg = 0 THEN
            RAISE id_inexistent;
        END IF;
        SELECT count(INSPECCIOID) INTO num_reg FROM AUTOAVALUACIO  WHERE INSPECCIOID = PINSPECCIOID AND estat = 'ALTA';
        IF num_reg = 0 THEN
            RAISE estat_baixa;
        END IF;
    --Modificacio de les dades     
        UPDATE INSPECCIO SET DATAINICI = PDATAINICI, DATAFI = PDATAFI, RESULTAT = PRESULTAT  WHERE INSPECCIOID = PINSPECCIOID AND estat='ALTA';
        IF SQL%ROWCOUNT = 0 THEN
            v_codi_error := SQLCODE;
            RAISE estat_baixa;
        END IF;
        UPDATE autoavaluacio SET DESCRIPCIO = PDESCRIPCIO WHERE INSPECCIOID = PINSPECCIOID AND estat='ALTA';
        IF SQL%ROWCOUNT = 0 THEN
            v_codi_error := SQLCODE;
            RAISE estat_baixa;
        END IF;
        PRESPOSTA:='OK';
        INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
        Dbms_output.Put_line(PRESPOSTA);
        COMMIT;
        EXCEPTION
        
            WHEN id_inexistent THEN
                PRESPOSTA := 'ERROR: registre amb la id '||PINSPECCIOID||' no existeix';
                DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;    
            WHEN estat_baixa THEN
                PRESPOSTA := 'ERROR: registre amb la id '||PINSPECCIOID||' esta donat de baixa';
                DBMS_OUTPUT.PUT_LINE(PRESPOSTA);

                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;
                
            WHEN ROWTYPE_MISMATCH THEN
                v_codi_error := SQLCODE;
                PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nompro,param_input, PRESPOSTA, SYSDATE);
                Commit;    
   
            WHEN OTHERS THEN
                v_codi_error := SQLCODE;
                PRESPOSTA := 'ERROR: ' || SQLERRM;
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;    
            
    END;                 

/

/******************************************************************************
Procediments ABM taula CAMPANYA
*******************************************************************************/ 

CREATE OR REPLACE PROCEDURE P_Alta_CAMPANYA(

    PINSPECCIOID IN CAMPANYA.INSPECCIOID%TYPE,
    PEMPLEATID IN CAMPANYA.EMPLEATID%TYPE,
    PDATAINICI IN CAMPANYA.dataInici%TYPE,
    PdataFi IN CAMPANYA.dataFi%TYPE ,
    presultatS IN CAMPANYA.resultats%TYPE,
    PRESPOSTA OUT VARCHAR2) 
    IS 
        valor_NULL exception;
        PRAGMA EXCEPTION_INIT(valor_NULL, -1400);
        v_codi_error  Integer;
        v_nompro VARCHAR2(100);
        param_input Varchar2(150);
        empleat_inexistent exception;
        inspeccio_inexistent exception;
        data_incorrecta exception;
        v_datainici INSPECCIO.dataInici%TYPE;
        v_dataFi INSPECCIO.dataFi%TYPE;
        num_reg Integer;
    BEGIN
    --Volcam dades dins variables per imprimir al log
        v_nomPro := $$PLSQL_UNIT;
        param_input:= 'PINSPECCIOID = '||PINSPECCIOID||' PEMPLEATID = '||PEMPLEATID||' PDATAINICI = '||PDATAINICI||' PdataFi = '||PdataFi||' presultat = '||presultats;
        --Es comprova l'existència de l'empeat lider i de la inspeccio.
        SELECT COUNT(PEMPLEATID) INTO num_reg FROM EMPLEAT  WHERE EMPLEATID = PEMPLEATID AND estat = 'ALTA';
        IF num_reg = 0 THEN
            RAISE empleat_inexistent;    
        END IF;    
        SELECT COUNT(INSPECCIOID) INTO num_reg FROM AUTOAVALUACIO WHERE INSPECCIOID = PINSPECCIOID AND estat = 'ALTA';
        IF num_reg = 0 THEN
            RAISE inspeccio_inexistent;    
        END IF;
        --Comrpovacio de que les dates són correctes i estàn dins les dates de la inspecció.
        SELECT dataInici, dataFi INTO v_datainici, v_dataFi FROM INSPECCIO WHERE INSPECCIOID = PINSPECCIOID;
        IF PdataFi < PDATAINICI OR PDATAINICI < v_datainici OR PdataFi > v_dataFi THEN
            RAISE data_incorrecta;
        END IF;    
        INSERT INTO CAMPANYA (inspeccioId, empleatid, dataInici, dataFi, resultats) VALUES (PINSPECCIOID,PEMPLEATID, PDATAINICI, PdataFi, presultats);

        PRESPOSTA:='OK';
        Dbms_output.Put_line(PRESPOSTA);
        INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
        Commit;
        
    -- Control errors--    
    EXCEPTION
        WHEN inspeccio_inexistent THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= 'ERROR: lautoavaluacio amb la id '||PINSPECCIOID||' no existeix o esta de baixa';
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;
        WHEN empleat_inexistent THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= 'ERROR: lempleat amb la id '||PEMPLEATID||' no existeix o esta de baixa';
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;
        WHEN data_incorrecta THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= 'ERROR: les dates introduides no son correctes';
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;   
    --Valor null--
        WHEN valor_NULL THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: el valor no pot ser null NULL ' || v_codi_error ||' ' || SQLERRM ,1,100);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;
        
    --Index duplicat--
        WHEN DUP_VAL_ON_INDEX THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            COMMIT;
                
    -- Tipus incorrecte--    
      WHEN ROWTYPE_MISMATCH THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            Commit;
            
    --Altres--    
      WHEN Others THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            Commit;        
    END;
/

----------------------------- BAIXA ---------------------------------------------
CREATE OR REPLACE PROCEDURE P_BAIXA_CAMPANYA(
    PCAMPANYAID IN CAMPANYA.campanyaId%TYPE,
    PRESPOSTA Out Varchar2)
    IS
        param_input Varchar2(150);
        num_reg Integer;
        v_codi_error Integer;
        baixa_existent EXCEPTION;
        id_inexistent EXCEPTION;
        v_nompro VARCHAR2(50);
    
    BEGIN
       
      -- Guardar els parametres d'entrada para insertarlo al LOG
        param_input := 'ID PCAMPANYAID = ' || PCAMPANYAID;
        v_nomPro := TO_CHAR($$PLSQL_UNIT);
      -- Comprovar si existeix a la taula pare i a la filla.
       SELECT count(campanyaId) INTO num_reg FROM CAMPANYA WHERE campanyaId = PCAMPANYAID;
        IF num_reg = 0 THEN
            raise id_inexistent;
        END IF;
         -- Comprovar si ja esta de baixa a ambdues taules.
        SELECT count(campanyaId) INTO num_reg FROM CAMPANYA WHERE campanyaId = PCAMPANYAID AND estat = 'BAIXA';
        IF num_reg = 1 THEN
            raise baixa_existent;
        END IF;
        
      -- Donar de baixa si te l'estat 'ALTA'
        UPDATE CAMPANYA SET ESTAT = 'BAIXA' WHERE campanyaId = PCAMPANYAID AND estat = 'ALTA';    
        PRESPOSTA := 'OK';
        DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
        INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
        COMMIT;

    EXCEPTION
    
        WHEN baixa_existent THEN
            PRESPOSTA := 'ERROR: LA CAMPANYA amb la id '||PCAMPANYAID||' ja ha estat donat de baixa anteriorment';
            DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;
            
        WHEN id_inexistent THEN
            PRESPOSTA := 'ERROR: La CAMPANYA amb la id '||PCAMPANYAID||' no existeix';
            DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;    
        
        -- Tipus incorrecte--    
        WHEN ROWTYPE_MISMATCH THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            COMMIT;    
    
        WHEN OTHERS THEN
            v_codi_error := SQLCODE;
            PRESPOSTA := 'ERROR: ' || SQLERRM;
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;
    End;
    /

-------------------------------- MODIFICACIO------------------------------------

create or replace Procedure P_MODIFICACIO_CAMPANYA(
    PCAMPANYAID IN CAMPANYA.campanyaId%TYPE,
    PINSPECCIOID IN CAMPANYA.INSPECCIOID%TYPE,
    PEMPLEATID IN CAMPANYA.EMPLEATID%TYPE,
    PDATAINICI IN CAMPANYA.dataInici%TYPE,
    PdataFi IN CAMPANYA.dataFi%TYPE,
    presultatS IN CAMPANYA.resultats%TYPE,
    PRESPOSTA Out Varchar2)
    IS
        param_input Varchar2(300);
        num_reg Integer;
        v_codi_error Integer;
        id_inexistent EXCEPTION;
        estat_baixa EXCEPTION;
        data_incorrecta EXCEPTION;
        v_datainici INSPECCIO.dataInici%TYPE;
        v_dataFi INSPECCIO.dataFi%TYPE;
        v_nompro VARCHAR2(50);

    
    BEGIN
        v_nomPro := $$PLSQL_UNIT;
    --Posam els valors d'entrada dins l'input--
        param_input := 'PCAMPANYAID = '||PCAMPANYAID||'PINSPECCIOID = '||PINSPECCIOID||' PEMPLEATID = '||PEMPLEATID||'PDATAINICI = '||PDATAINICI|| ' PdataFi = '||PdataFi||'presultatS'|| presultatS;
    --Comprovaci� de que existeix i est� d'alta--     
        SELECT count(campanyaId) INTO num_reg FROM campanya  WHERE campanyaId = pcampanyaId;
        IF num_reg = 0 THEN
            RAISE id_inexistent;
        END IF;
        SELECT dataInici, dataFi INTO v_datainici, v_dataFi FROM inspeccio WHERE inspeccioId = PINSPECCIOID;
        IF PdataFi < PDATAINICI OR PDATAINICI < v_datainici OR PdataFi > v_dataFi THEN
            RAISE data_incorrecta;
        END IF;
    --Modificacio de les dades     
        UPDATE CAMPANYA SET INSPECCIOID = PINSPECCIOID, EMPLEATID = PEMPLEATID, DATAINICI = PDATAINICI, DATAFI = PDATAFI, RESULTATS = PRESULTATS  WHERE CAMPANYAID = PCAMPANYAID AND estat='ALTA';
        IF SQL%ROWCOUNT = 0 THEN
            v_codi_error := SQLCODE;
            RAISE estat_baixa;
        END IF;
        PRESPOSTA:='OK';
        Dbms_output.Put_line(PRESPOSTA);
        INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
        COMMIT;
        EXCEPTION

            WHEN data_incorrecta THEN
                PRESPOSTA := 'ERROR: les dates introduides no son correctes';
                DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;

            WHEN id_inexistent THEN
                PRESPOSTA := 'ERROR: registre amb la id '||PCAMPANYAID||' no existeix';
                DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;    

            WHEN estat_baixa THEN
                PRESPOSTA := 'ERROR: registre amb la id '||PCAMPANYAID||' esta donat de baixa';
                DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;
                
            WHEN ROWTYPE_MISMATCH THEN
                v_codi_error := SQLCODE;
                PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nompro,param_input, PRESPOSTA, SYSDATE);
                Commit;    
   
            WHEN OTHERS THEN
                v_codi_error := SQLCODE;
                PRESPOSTA := 'ERROR: ' || SQLERRM;
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;    
            
    END;                 

/



/******************************************************************************
Procediments ABM taula AUDITORIAEXTERNA
*******************************************************************************/ 

CREATE OR REPLACE PROCEDURE P_Alta_AUDITORIAEXTERNA(

    PEMPRESA IN AUDITORIAEXTERNA.EMPRESA%TYPE,
    PCOST IN AUDITORIAEXTERNA.COST%TYPE,
    PDATAINICI IN INSPECCIO.dataInici%TYPE,
    PdataFi IN INSPECCIO.dataFi%TYPE ,
    presultat IN INSPECCIO.resultat%TYPE,
    PRESPOSTA OUT VARCHAR2) 
    IS 
        valor_NULL exception;
        PRAGMA EXCEPTION_INIT(valor_NULL, -1400);
        v_codi_error  Integer;
        v_nompro VARCHAR2(100);
        param_input Varchar2(150);
        v_inspeccioId INSPECCIO.inspeccioId%TYPE;
        data_incorrecta EXCEPTION;
    
    BEGIN
    --Volcam dades dins variables per imprimir al log
        v_nomPro := $$PLSQL_UNIT;
        param_input:= 'PEMPRESA = '||PEMPRESA||' PCOST = '||PCOST||' PDATAINICI = '||PDATAINICI||' PdataFi = '||PdataFi||' presultat = '||presultat;
        --Es comprova que les dates siguin vàlides
        IF PdataFi < PDATAINICI THEN
            RAISE data_incorrecta;
        END IF;
        --Es fa l'inser a la taula inspeccio, es recupera la id ies fa l'insert a la taula AUDITORIAEXTERNA.
        INSERT INTO INSPECCIO (dataInici, dataFi, resultat) VALUES (PDATAINICI, PdataFi, presultat) RETURNING inspeccioId INTO v_inspeccioId;
        INSERT INTO AUDITORIAEXTERNA(inspeccioId, empresa, cost) VALUES (v_inspeccioId, PEMPRESA, PCOST);

        PRESPOSTA:='OK';
        Dbms_output.Put_line(PRESPOSTA);
        INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
        Commit;
        
    -- Control errors--    
    EXCEPTION
        WHEN data_incorrecta THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= 'ERROR: La data de finalització no pot ser anterior a la data actual';
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;

    --Valor null--
        WHEN valor_NULL THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: el valor no pot ser null NULL ' || v_codi_error ||' ' || SQLERRM ,1,100);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;
        
    --Index duplicat--
        WHEN DUP_VAL_ON_INDEX THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            COMMIT;
                
    -- Tipus incorrecte--    
      WHEN ROWTYPE_MISMATCH THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            Commit;
            
    --Altres--    
      WHEN Others THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            Commit;        
    END;
/

----------------------------- BAIXA ---------------------------------------------
CREATE OR REPLACE PROCEDURE P_BAIXA_AUDITORIAEXTERNA(
    PINSPECCIOID IN INSPECCIO.inspeccioId%TYPE,
    PRESPOSTA Out Varchar2)
    IS
        param_input Varchar2(150);
        num_reg Integer;
        v_codi_error Integer;
        baixa_existent EXCEPTION;
        id_inexistent EXCEPTION;
        v_nompro VARCHAR2(50);
    
    BEGIN
       
      -- Guardar els parametres d'entrada para insertarlo al LOG
        param_input := 'ID PINSPECCIOID = ' || PINSPECCIOID;
        v_nomPro := TO_CHAR($$PLSQL_UNIT);
      -- Comprovar si existeix a la taula pare i a la filla.
       SELECT count(inspeccioId) INTO num_reg FROM AUDITORIAEXTERNA WHERE inspeccioId = pinspeccioId;
        IF num_reg = 0 THEN
            raise id_inexistent;
        END IF;
        SELECT count(inspeccioId) INTO num_reg FROM INSPECCIO WHERE inspeccioId = pinspeccioId;
        IF num_reg = 0 THEN
            raise id_inexistent;
        END IF;
         -- Comprovar si ja esta de baixa a ambdues taules.
        SELECT count(inspeccioId) INTO num_reg FROM INSPECCIO WHERE inspeccioId = pinspeccioId AND estat = 'BAIXA';
        IF num_reg = 1 THEN
            raise baixa_existent;
        END IF;
        SELECT count(inspeccioId) INTO num_reg FROM AUDITORIAEXTERNA WHERE inspeccioId = pinspeccioId AND estat = 'BAIXA';
        IF num_reg = 1 THEN
            raise baixa_existent;
        END IF;
        
      -- Donar de baixa si te l'estat 'ALTA'
        UPDATE INSPECCIO SET ESTAT = 'BAIXA' WHERE INSPECCIOID = PINSPECCIOID AND estat = 'ALTA';
        UPDATE AUDITORIAEXTERNA SET ESTAT = 'BAIXA' WHERE INSPECCIOID = PINSPECCIOID AND estat = 'ALTA';
    
        PRESPOSTA := 'OK';
        DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
        INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
        COMMIT;

    EXCEPTION
    
        WHEN baixa_existent THEN
            PRESPOSTA := 'ERROR: LA INSPECCIO amb la id '||PINSPECCIOID||' ja ha estat donat de baixa anteriorment';
            DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;
            
        WHEN id_inexistent THEN
            PRESPOSTA := 'ERROR: La inspeccio amb la id '||PINSPECCIOID||' no existeix';
            DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;    
        
        -- Tipus incorrecte--    
        WHEN ROWTYPE_MISMATCH THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            COMMIT;    
    
        WHEN OTHERS THEN
            v_codi_error := SQLCODE;
            PRESPOSTA := 'ERROR: ' || SQLERRM;
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;
    End;
    /

-------------------------------- MODIFICACIO------------------------------------

create or replace Procedure P_MODIFICACIO_AUDITORIAEXTERNA(
    PINSPECCIOID IN INSPECCIO.inspeccioId%TYPE,
    PDATAINICI IN INSPECCIO.dataInici%TYPE,
    PdataFi IN INSPECCIO.dataFi%TYPE ,
    presultat IN INSPECCIO.resultat%TYPE,
    PEMPRESA IN AUDITORIAEXTERNA.EMPRESA%TYPE,
    PCOST IN AUDITORIAEXTERNA.COST%TYPE,
    PRESPOSTA Out Varchar2)
    IS
        param_input Varchar2(300);
        num_reg Integer;
        v_codi_error Integer;
        id_inexistent EXCEPTION;
        estat_baixa EXCEPTION;
        v_nompro VARCHAR2(50);
        data_incorrecta EXCEPTION;

    
    BEGIN
        v_nomPro := $$PLSQL_UNIT;
    --Posam els valors d'entrada dins l'input--
        param_input := 'PINSPECCIOID = '||PINSPECCIOID||'PDATAINICI = '||PDATAINICI|| ' PdataFi = '||PdataFi||' PEMPRESA = '||PEMPRESA||' PCOST = '||PCOST;
    --Comprovaci� de que existeix i est� d'alta--     
        SELECT count(INSPECCIOID) INTO num_reg FROM INSPECCIO  WHERE INSPECCIOID = PINSPECCIOID;
        IF num_reg = 0 THEN
            RAISE id_inexistent;
        END IF;
        --Comprovam les dates
        IF PdataFi < PDATAINICI THEN
            RAISE data_incorrecta;
        END IF;
    --Modificacio de les dades     
        UPDATE INSPECCIO SET DATAINICI = PDATAINICI, DATAFI = PDATAFI, RESULTAT = PRESULTAT  WHERE INSPECCIOID = PINSPECCIOID AND estat='ALTA';
        IF SQL%ROWCOUNT = 0 THEN
            v_codi_error := SQLCODE;
            RAISE estat_baixa;
        END IF;
        UPDATE AUDITORIAEXTERNA SET EMPRESA = PEMPRESA, COST = PCOST WHERE INSPECCIOID = PINSPECCIOID AND estat='ALTA';
        IF SQL%ROWCOUNT = 0 THEN
            v_codi_error := SQLCODE;
            RAISE estat_baixa;
        END IF;
        PRESPOSTA:='OK';
        INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
        Dbms_output.Put_line(PRESPOSTA);
        COMMIT;
        EXCEPTION
            WHEN data_incorrecta THEN
                PRESPOSTA := 'ERROR: les dates introduides no son correctes';
                DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;

            WHEN id_inexistent THEN
                PRESPOSTA := 'ERROR: registre amb la id '||PINSPECCIOID||' no existeix';
                DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;    
            WHEN estat_baixa THEN
                PRESPOSTA := 'ERROR: registre amb la id '||PINSPECCIOID||' esta donat de baixa';
                DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;
                
            WHEN ROWTYPE_MISMATCH THEN
                v_codi_error := SQLCODE;
                PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nompro,param_input, PRESPOSTA, SYSDATE);
                Commit;    
   
            WHEN OTHERS THEN
                v_codi_error := SQLCODE;
                PRESPOSTA := 'ERROR: ' || SQLERRM;
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;    
            
    END;                 

/
/******************************************************************************
Procediments ABM taula AUDITORIAINTERNA
*******************************************************************************/ 

CREATE OR REPLACE PROCEDURE P_Alta_AUDITORIAINTERNA(

    POBJECTIU IN AUDITORIAINTERNA.objectiu%TYPE,
    PDATAINICI IN INSPECCIO.dataInici%TYPE,
    PdataFi IN INSPECCIO.dataFi%TYPE ,
    presultat IN INSPECCIO.resultat%TYPE,
    PRESPOSTA OUT VARCHAR2) 
    IS 
        valor_NULL exception;
        PRAGMA EXCEPTION_INIT(valor_NULL, -1400);
        v_codi_error  Integer;
        v_nompro VARCHAR2(100);
        param_input Varchar2(150);
        v_inspeccioId INSPECCIO.inspeccioId%TYPE;
        data_incorrecta EXCEPTION;
    
    BEGIN
    --Volcam dades dins variables per imprimir al log
        v_nomPro := $$PLSQL_UNIT;
        param_input:= 'POBJECTIU = '||POBJECTIU||'PDATAINICI = '||PDATAINICI||' PdataFi = '||PdataFi||' presultat = '||presultat;
        --Es comprova que les dates siguin vàlides
        IF PdataFi < PDATAINICI THEN
            RAISE data_incorrecta;
        END IF;
        --Es fa l'inser a la taula inspeccio, es recupera la id ies fa l'insert a la taula autoavaluacio.
        INSERT INTO INSPECCIO (dataInici, dataFi, resultat) VALUES (PDATAINICI, PdataFi, presultat) RETURNING inspeccioId INTO v_inspeccioId;
        INSERT INTO AUDITORIAINTERNA(inspeccioId, objectiu) VALUES (v_inspeccioId, POBJECTIU);

        PRESPOSTA:='OK';
        Dbms_output.Put_line(PRESPOSTA);
        INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
        Commit;
        
    -- Control errors--    
    EXCEPTION
        WHEN data_incorrecta THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= 'ERROR: La data de finalització no pot ser anterior a la data actual';
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;
    --Valor null--
        WHEN valor_NULL THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: el valor no pot ser null NULL ' || v_codi_error ||' ' || SQLERRM ,1,100);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;
        
    --Index duplicat--
        WHEN DUP_VAL_ON_INDEX THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            COMMIT;
                
    -- Tipus incorrecte--    
      WHEN ROWTYPE_MISMATCH THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            Commit;
            
    --Altres--    
      WHEN Others THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            Commit;        
    END;
/

----------------------------- BAIXA ---------------------------------------------
CREATE OR REPLACE PROCEDURE P_BAIXA_AUDITORIAINTERNA(
    PINSPECCIOID IN INSPECCIO.inspeccioId%TYPE,
    PRESPOSTA Out Varchar2)
    IS
        param_input Varchar2(150);
        num_reg Integer;
        v_codi_error Integer;
        baixa_existent EXCEPTION;
        id_inexistent EXCEPTION;
        v_nompro VARCHAR2(50);
    
    BEGIN
       
      -- Guardar los par�metros de entrada para insertarlos en la tabla LOG
        param_input := 'ID PINSPECCIOID = ' || PINSPECCIOID;
        v_nomPro := TO_CHAR($$PLSQL_UNIT);
      -- Comprovar si existeix a la taula pare i a la filla.
       SELECT count(inspeccioId) INTO num_reg FROM AUDITORIAINTERNA WHERE inspeccioId = pinspeccioId;
        IF num_reg = 0 THEN
            raise id_inexistent;
        END IF;
        SELECT count(inspeccioId) INTO num_reg FROM INSPECCIO WHERE inspeccioId = pinspeccioId;
        IF num_reg = 0 THEN
            raise id_inexistent;
        END IF;
         -- Comprovar si ja esta de baixa a ambdues taules.
        SELECT count(inspeccioId) INTO num_reg FROM INSPECCIO WHERE inspeccioId = pinspeccioId AND estat = 'BAIXA';
        IF num_reg = 1 THEN
            raise baixa_existent;
        END IF;
        SELECT count(inspeccioId) INTO num_reg FROM AUDITORIAINTERNA WHERE inspeccioId = pinspeccioId AND estat = 'BAIXA';
        IF num_reg = 1 THEN
            raise baixa_existent;
        END IF;
        
      -- Donar de baixa si te l'estat 'ALTA'
        UPDATE INSPECCIO SET ESTAT = 'BAIXA' WHERE INSPECCIOID = PINSPECCIOID AND estat = 'ALTA';
        UPDATE AUDITORIAINTERNA SET ESTAT = 'BAIXA' WHERE INSPECCIOID = PINSPECCIOID AND estat = 'ALTA';
    
        PRESPOSTA := 'OK';
        INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
        DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
        COMMIT;

    EXCEPTION
    
        WHEN baixa_existent THEN
            PRESPOSTA := 'ERROR: LA INSPECCIO amb la id '||PINSPECCIOID||' ja ha estat donat de baixa anteriorment';
            DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;
            
        WHEN id_inexistent THEN
            PRESPOSTA := 'ERROR: La inspeccio amb la id '||PINSPECCIOID||' no existeix';
            DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;    
        
        -- Tipus incorrecte--    
        WHEN ROWTYPE_MISMATCH THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            COMMIT;    
    
        WHEN OTHERS THEN
            v_codi_error := SQLCODE;
            PRESPOSTA := 'ERROR: ' || SQLERRM;
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;
    End;
    /

-------------------------------- MODIFICACIO------------------------------------

create or replace Procedure P_MODIFICACIO_AUDITORIAINTERNA(
    PINSPECCIOID IN INSPECCIO.inspeccioId%TYPE,
    PDATAINICI IN INSPECCIO.dataInici%TYPE,
    PdataFi IN INSPECCIO.dataFi%TYPE ,
    presultat IN INSPECCIO.resultat%TYPE,
    POBJECTIU IN AUDITORIAINTERNA.objectiu%TYPE,
    PRESPOSTA Out Varchar2)
    IS
        param_input Varchar2(300);
        num_reg Integer;
        v_codi_error Integer;
        id_inexistent EXCEPTION;
        estat_baixa EXCEPTION;
        v_nompro VARCHAR2(50);
        data_incorrecta EXCEPTION;
    
    BEGIN
        v_nomPro := $$PLSQL_UNIT;
    --Posam els valors d'entrada dins l'input--
        param_input := 'PINSPECCIOID = '||PINSPECCIOID||'PDATAINICI = '||PDATAINICI|| ' PdataFi = '||PdataFi||' POBJECTIU '|| POBJECTIU;
    --Comprovaci� de que existeix i est� d'alta--     
        SELECT count(INSPECCIOID) INTO num_reg FROM INSPECCIO  WHERE INSPECCIOID = PINSPECCIOID;
        IF num_reg = 0 THEN
            RAISE id_inexistent;
        END IF;
        --Comprovam les dates
        IF PdataFi < PDATAINICI THEN
            RAISE data_incorrecta;
        END IF;
    --Modificacio de les dades     
        UPDATE INSPECCIO SET DATAINICI = PDATAINICI, DATAFI = PDATAFI, RESULTAT = PRESULTAT  WHERE INSPECCIOID = PINSPECCIOID AND estat='ALTA';
        IF SQL%ROWCOUNT = 0 THEN
            v_codi_error := SQLCODE;
            RAISE estat_baixa;
        END IF;
        UPDATE AUDITORIAINTERNA SET objectiu = POBJECTIU WHERE INSPECCIOID = PINSPECCIOID AND estat='ALTA';
        IF SQL%ROWCOUNT = 0 THEN
            v_codi_error := SQLCODE;
            RAISE estat_baixa;
        END IF;
        PRESPOSTA:='OK';
        INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
        Dbms_output.Put_line(PRESPOSTA);
        COMMIT;
        EXCEPTION
            WHEN data_incorrecta THEN
                PRESPOSTA := 'ERROR: les dates introduides no son correctes';
                DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;

            WHEN id_inexistent THEN
                PRESPOSTA := 'ERROR: registre amb la id '||PINSPECCIOID||' no existeix';
                DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;    
            WHEN estat_baixa THEN
                PRESPOSTA := 'ERROR: registre amb la id '||PINSPECCIOID||' esta donat de baixa';
                DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;
                
            WHEN ROWTYPE_MISMATCH THEN
                v_codi_error := SQLCODE;
                PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nompro,param_input, PRESPOSTA, SYSDATE);
                Commit;    
   
            WHEN OTHERS THEN
                v_codi_error := SQLCODE;
                PRESPOSTA := 'ERROR: ' || SQLERRM;
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;    
            
    END;                 

/

/******************************************************************************
Procediments ABM taula RISC
*******************************************************************************/ 

CREATE OR REPLACE PROCEDURE P_Alta_RISC(

    PINSPECCIOID IN RISC.INSPECCIOID%TYPE,
    PCATID IN RISC.CATID%TYPE,
    PDEPID IN RISC.DEPID%TYPE,
    PEMPLEATID IN RISC.EMPLEATID%TYPE,
    Pcriticitat IN RISC.criticitat%TYPE,
    PESTATRISC IN RISC.estatRisc%TYPE,
    PDESCRIPCIO IN RISC.DESCRIPCIO%TYPE,
    PRESPOSTA OUT VARCHAR2) 
    IS 
        valor_NULL exception;
        PRAGMA EXCEPTION_INIT(valor_NULL, -1400);
        v_codi_error  Integer;
        v_nompro VARCHAR2(100);
        param_input Varchar2(150);
        categoria_inexistent exception;
        inspeccio_inexistent exception;
        departament_inexistent exception;
        empleat_inexistent exception;
        criticitat_incorrecta exception;
        estatrisc_incocorrecte exception;
        num_reg Integer;
        v_importancia CATEGORIA.importancia%TYPE;
        v_impacte RISC.impacte%TYPE;
    BEGIN
    --Volcam dades dins variables per imprimir al log
        v_nomPro := $$PLSQL_UNIT;
        param_input:= 'PINSPECCIOID = '||PINSPECCIOID||' PCATID = '||PCATID||' PDEPID = '||PDEPID||' Pcriticitat = '||Pcriticitat||' PESTATRISC = '||PESTATRISC||' PDESCRIPCIO '||PDESCRIPCIO;
        --Es comprova l'existència de la inspeccio i la categoria i el deparament i l'empleat.
        SELECT COUNT(catid) INTO num_reg FROM categoria  WHERE catid = pcatid AND estat = 'ALTA';
        IF num_reg = 0 THEN
            RAISE categoria_inexistent;    
        END IF;    
        SELECT COUNT(INSPECCIOID) INTO num_reg FROM INSPECCIO WHERE INSPECCIOID = PINSPECCIOID AND estat = 'ALTA';
        IF num_reg = 0 THEN
            RAISE inspeccio_inexistent;    
        END IF;    
        SELECT COUNT(depId) INTO num_reg FROM DEPARTAMENT WHERE depId = PDEPID AND estat = 'ALTA';
        IF num_reg = 0 THEN
            RAISE departament_inexistent;    
        END IF;    
        SELECT COUNT(empleatId) INTO num_reg FROM EMPLEAT WHERE empleatId = PEMPLEATID AND estat = 'ALTA';
        IF num_reg = 0 THEN
            RAISE empleat_inexistent;    
        END IF;    
        --Es comprova que la criticitat sigui correcte
        IF PCRITICITAT NOT IN ('Risc critic', 'Risc moderat', 'Risc baix') THEN
            RAISE criticitat_incorrecta;
        END IF;
        --Es comprova que l'estat sigui correcte
        IF PESTATRISC NOT IN ('Corregit','Mitigat','Obert') THEN
            RAISE estatrisc_incocorrecte;
        END IF;


        --Es calcula l'impacte
        SELECT importancia into v_importancia FROM CATEGORIA WHERE catID = PCATID;
        P_calculImpacte(PCRITICITAT, v_importancia, v_impacte);
        INSERT INTO RISC (inspeccioId, catID, depId, empleatId, criticitat,impacte,estatRisc, dataCreacio,descripcio) VALUES (PINSPECCIOID,PCATID, PDEPID, PEMPLEATID, Pcriticitat, v_impacte, PESTATRISC, SYSDATE ,PDESCRIPCIO);

        PRESPOSTA:='OK';
        Dbms_output.Put_line(PRESPOSTA);
        INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
        Commit;
        
    -- Control errors--    
    EXCEPTION
        WHEN inspeccio_inexistent THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= 'ERROR: La inspeccio amb la id '||PINSPECCIOID||' no existeix o esta de baixa';
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;
        WHEN categoria_inexistent THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= 'ERROR: la categoria amb la id '||PCATID||' no existeix o esta de baixa';
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;
         WHEN departament_inexistent THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= 'ERROR: el departament amb la id '||PDEPID||' no existeix o esta de baixa';
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;    
        WHEN empleat_inexistent THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= 'ERROR: l empleat amb la id '||PEMPLEATID||' no existeix o esta de baixa';
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;    
        WHEN criticitat_incorrecta THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= 'ERROR: la criticitat no es correcta';
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;    
        WHEN estatrisc_incocorrecte THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= 'ERROR: l estat del risc no es correcte';
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;    
    --Valor null--
        WHEN valor_NULL THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: el valor no pot ser null NULL ' || v_codi_error ||' ' || SQLERRM ,1,100);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;
        
    --Index duplicat--
        WHEN DUP_VAL_ON_INDEX THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            COMMIT;
                
    -- Tipus incorrecte--    
      WHEN ROWTYPE_MISMATCH THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            Commit;
            
    --Altres--    
      WHEN Others THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            Commit;        
    END;
/

----------------------------- BAIXA ---------------------------------------------
CREATE OR REPLACE PROCEDURE P_BAIXA_RISC(
    PRISCID IN RISC.RISCID%TYPE,
    PRESPOSTA Out Varchar2)
    IS
        param_input Varchar2(150);
        num_reg Integer;
        v_codi_error Integer;
        baixa_existent EXCEPTION;
        id_inexistent EXCEPTION;
        v_nompro VARCHAR2(50);
    
    BEGIN
       
      -- Guardar els parametres d'entrada para insertarlo al LOG
        param_input := 'ID PRISCID = ' || PRISCID;
        v_nomPro := TO_CHAR($$PLSQL_UNIT);
      -- Comprovar si existeix a la taula.
       SELECT count(RISCID) INTO num_reg FROM RISC WHERE riscId = PRISCID;
        IF num_reg = 0 THEN
            raise id_inexistent;
        END IF;
         -- Comprovar si ja esta de baixa.
        SELECT count(RISCID) INTO num_reg FROM RISC WHERE riscId = PRISCID AND estat = 'BAIXA';
        IF num_reg = 1 THEN
            raise baixa_existent;
        END IF;
        
      -- Donar de baixa si te l'estat 'ALTA'
        UPDATE RISC SET ESTAT = 'BAIXA' WHERE riscId = PRISCID AND estat = 'ALTA';    
        PRESPOSTA := 'OK';
        Dbms_output.Put_line(PRESPOSTA);
        INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
        COMMIT;

    EXCEPTION
    
        WHEN baixa_existent THEN
            PRESPOSTA := 'ERROR: el risc amb la id '||PRISCID||' ja ha estat donat de baixa anteriorment';
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;
            
        WHEN id_inexistent THEN
            PRESPOSTA := 'ERROR: el risc amb la id '||PRISCID||' no existeix';
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;    
        
        -- Tipus incorrecte--    
        WHEN ROWTYPE_MISMATCH THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            COMMIT;    
    
        WHEN OTHERS THEN
            v_codi_error := SQLCODE;
            PRESPOSTA := 'ERROR: ' || SQLERRM;
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;
    End;
    /

-------------------------------- MODIFICACIO------------------------------------

create or replace Procedure P_MODIFICACIO_RISC(
    PRISCID IN RISC.RISCID%TYPE,
    PINSPECCIOID IN RISC.INSPECCIOID%TYPE,
    PCATID IN RISC.CATID%TYPE,
    PDEPID IN RISC.DEPID%TYPE,
    PEMPLEATID IN RISC.EMPLEATID%TYPE,
    Pcriticitat IN RISC.criticitat%TYPE,
    PESTATRISC IN RISC.estatRisc%TYPE,
    PDESCRIPCIO IN RISC.DESCRIPCIO%TYPE,
    PRESPOSTA Out Varchar2)
    IS
        param_input Varchar2(300);
        num_reg Integer;
        v_codi_error Integer;
        id_inexistent EXCEPTION;
        estat_baixa EXCEPTION;
        v_nompro VARCHAR2(50);
        v_importancia CATEGORIA.importancia%TYPE;
        v_impacte RISC.impacte%TYPE;
        inspeccio_inexistent EXCEPTION;
        categoria_inexistent EXCEPTION;
        departament_inexistent EXCEPTION;
        empleat_inexistent EXCEPTION;
        estatrisc_incocorrecte EXCEPTION;
        criticitat_incorrecta EXCEPTION;

    
    BEGIN
        v_nomPro := $$PLSQL_UNIT;
    --Posam els valors d'entrada dins l'input--
        param_input := 'PRISCID = '||PRISCID||'PINSPECCIOID = '||PINSPECCIOID||' PCATID = '||PCATID||'Pcriticitat = '||Pcriticitat|| ' PESTATRISC = '||PESTATRISC||' PDESCRIPCIO '||PDESCRIPCIO;
    --Comprovaci� de que existeix i est� d'alta--     
        SELECT count(riscId) INTO num_reg FROM RISC  WHERE RISCID = PRISCID AND estat = 'ALTA';
        IF num_reg = 0 THEN
            RAISE id_inexistent;
        END IF;
    --comprovacio existeix inspeccio i esta d'alta
        SELECT count(inspeccioId) INTO num_reg FROM INSPECCIO  WHERE inspeccioId = PINSPECCIOID AND estat = 'ALTA';
            IF num_reg = 0 THEN
                RAISE inspeccio_inexistent;
            END IF;
        --comprovacio existeix categoria i esta d'alta
        SELECT count(catId) INTO num_reg FROM CATEGORIA  WHERE catid = PCATID AND estat = 'ALTA';
            IF num_reg = 0 THEN
                RAISE categoria_inexistent;
            END IF;
         --comprovacio existeix departament i esta d'alta
        SELECT count(depId) INTO num_reg FROM DEPARTAMENT  WHERE depId = PDEPID AND estat = 'ALTA';
            IF num_reg = 0 THEN
                RAISE departament_inexistent;
            END IF;    
        SELECT count(empleatId) INTO num_reg FROM EMPLEAT  WHERE empleatId = PEMPLEATID AND estat = 'ALTA';
            IF num_reg = 0 THEN
                RAISE empleat_inexistent;
            END IF;        
        --Es comprova que la criticitat sigui correcte
        IF PCRITICITAT NOT IN ('Risc critic', 'Risc moderat', 'Risc baix') THEN
            RAISE criticitat_incorrecta;
        END IF;
        --Es comprova que l'estat sigui correcte
        IF PESTATRISC NOT IN ('Corregit','Mitigat','Obert') THEN
            RAISE estatrisc_incocorrecte;
        END IF;
    
        --recalcul del impacte
        SELECT importancia into v_importancia FROM CATEGORIA WHERE catID = PCATID;
        P_calculImpacte(PCRITICITAT, v_importancia, v_impacte);
        --Modificacio de les dades  
   
        UPDATE RISC SET INSPECCIOID = PINSPECCIOID, catID = PCATID, depId = PDEPID, empleatId = PEMPLEATID, criticitat = pcriticitat, impacte = v_impacte, estatRisc = PESTATRISC, 
        descripcio = PDESCRIPCIO  WHERE riscId = PRISCID AND estat='ALTA';
        IF SQL%ROWCOUNT = 0 THEN
            v_codi_error := SQLCODE;
            RAISE estat_baixa;
        END IF;

        PRESPOSTA:='OK';
        INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
        Dbms_output.Put_line(PRESPOSTA);
        COMMIT;
        EXCEPTION
        
            WHEN id_inexistent THEN
                PRESPOSTA := 'ERROR: registre amb la id '||PRISCID||' no existeix';
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;    
            WHEN estat_baixa THEN
                PRESPOSTA := 'ERROR: registre amb la id '||PRISCID||' esta donat de baixa';
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;
            WHEN inspeccio_inexistent THEN
                v_codi_error := SQLCODE;
                PRESPOSTA:= 'ERROR: La inspeccio amb la id '||PINSPECCIOID||' no existeix o esta de baixa';
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
                Commit;
            WHEN categoria_inexistent THEN
                v_codi_error := SQLCODE;
                PRESPOSTA:= 'ERROR: la categoria amb la id '||PCATID||' no existeix o esta de baixa';
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
                Commit;    
            WHEN departament_inexistent THEN
                v_codi_error := SQLCODE;
                PRESPOSTA:= 'ERROR: el departament amb la id '||PDEPID||' no existeix o esta de baixa';
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
                Commit;  
            WHEN empleat_inexistent THEN
                v_codi_error := SQLCODE;
                PRESPOSTA:= 'ERROR: l empleat amb la id '||PEMPLEATID||' no existeix o esta de baixa';
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
                Commit;    
            WHEN criticitat_incorrecta THEN
                v_codi_error := SQLCODE;
                PRESPOSTA:= 'ERROR: la criticitat no es correcta';
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
                Commit;    
            WHEN estatrisc_incocorrecte THEN
                v_codi_error := SQLCODE;
                PRESPOSTA:= 'ERROR: l estat del risc no es correcte';
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
                Commit;    
            WHEN ROWTYPE_MISMATCH THEN
                v_codi_error := SQLCODE;
                PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nompro,param_input, PRESPOSTA, SYSDATE);
                Commit;    
   
            WHEN OTHERS THEN
                v_codi_error := SQLCODE;
                PRESPOSTA := 'ERROR: ' || SQLERRM;
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;    
            
    END;                 
/
/******************************************************************************
Procediments ABM taula ACCIOMITIGADORA
*******************************************************************************/ 

CREATE OR REPLACE PROCEDURE P_Alta_ACCIOMITIGADORA(
    PRISCID IN ACCIOMITIGADORA.RISCID%TYPE,
    PEMPLEATID IN ACCIOMITIGADORA.EMPLEATID%TYPE,
    PestatAccio IN ACCIOMITIGADORA.estatAccio%TYPE,
    PNOM IN ACCIOMITIGADORA.nom%TYPE,
    Pdescripcio IN ACCIOMITIGADORA.descripcio%TYPE,
    PDataCreacio IN ACCIOMITIGADORA.dataCreacio%TYPE,
    PdataEstimada IN ACCIOMITIGADORA.dataEstimada%TYPE,
    PRESPOSTA OUT VARCHAR2) 
    IS 
        valor_NULL exception;
        PRAGMA EXCEPTION_INIT(valor_NULL, -1400);
        v_codi_error  Integer;
        v_nompro VARCHAR2(100);
        param_input Varchar2(150);
        num_reg Integer;
        risc_inexistent exception;
        empleat_inexistent exception;
        estat_incorrecte exception;
        data_incorrecta exception;
    BEGIN
    --Volcam dades dins variables per imprimir al log
        v_nomPro := $$PLSQL_UNIT;
        param_input:= 'PRISCID '|| PRISCID ||' PEMPLEATID '||PEMPLEATID||' PestatAccio = '||PestatAccio||' Pdescripcio = '||Pdescripcio||' PDataCreacio = '||PDataCreacio||' PdataEstimada = '||PdataEstimada;
        --Es comprova l'existència del risc i de l'empleat
        SELECT COUNT(riscid) INTO num_reg FROM risc  WHERE riscid = PRISCID AND estat = 'ALTA';
        IF num_reg = 0 THEN
            RAISE risc_inexistent;    
        END IF;
        SELECT COUNT(empleatid) INTO num_reg FROM empleat WHERE empleatid = PEMPLEATID AND estat = 'ALTA';
        IF num_reg = 0 THEN
            RAISE empleat_inexistent;    
        END IF;
        --Es comprova que l'estat sigui correcte. NO contempl la possibilitat de crear una acció ja implementada o descartada.
        IF PestatAccio NOT IN ('Definida', 'En curs') THEN
            RAISE estat_incorrecte;
        END IF;
        --Comprovam les dates
        IF PdataEstimada < PDataCreacio THEN
            RAISE data_incorrecta;
        END IF;
        INSERT INTO ACCIOMITIGADORA (riscId, empleatId, estatAccio, nom, descripcio, dataCreacio,dataEstimada) VALUES (PRISCID, PEMPLEATID, PestatAccio, PNOM, Pdescripcio, PDataCreacio, PdataEstimada);

        PRESPOSTA:='OK';
        Dbms_output.Put_line(PRESPOSTA);
        INSERT INTO LOG ( nomPro, entrada, sortida, dataRegistre) VALUES( v_nomPro,param_input, PRESPOSTA, SYSDATE);
        Commit;
        
    -- Control errors--    
    EXCEPTION
        WHEN risc_inexistent THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= 'ERROR: el risc amb la id '||PRISCID||' no existeix o esta de baixa';
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;
        WHEN data_incorrecta THEN
            PRESPOSTA := 'ERROR: les dates introduides no son correctes';
            DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;

        WHEN empleat_inexistent THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= 'ERROR: l empleat amb la id '||PEMPLEATID||' no existeix o esta de baixa';
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;
        WHEN estat_incorrecte THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= 'ERROR: l estat de l accio no es correcte';
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;
    --Valor null--
        WHEN valor_NULL THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: el valor no pot ser null NULL ' || v_codi_error ||' ' || SQLERRM ,1,100);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;  
    --Index duplicat--
        WHEN DUP_VAL_ON_INDEX THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            COMMIT;
                
    -- Tipus incorrecte--    
      WHEN ROWTYPE_MISMATCH THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            Commit;
            
    --Altres--    
      WHEN Others THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            Commit;        
    END;
/

----------------------------- BAIXA ---------------------------------------------
CREATE OR REPLACE PROCEDURE P_BAIXA_ACCIOMITIGADORA(
    PaccioId IN ACCIOMITIGADORA.accioId%TYPE,
    PRESPOSTA Out Varchar2)
    IS
        param_input Varchar2(150);
        num_reg Integer;
        v_codi_error Integer;
        baixa_existent EXCEPTION;
        id_inexistent EXCEPTION;
        risc_alta EXCEPTION;
        v_nompro VARCHAR2(50);
    
    BEGIN
       
      -- Guardar els parametres d'entrada para insertarlo al LOG
        param_input := 'ID PaccioId = ' || PaccioId;
        v_nomPro := TO_CHAR($$PLSQL_UNIT);
      -- Comprovar si existeix a la taula.
       SELECT count(accioId) INTO num_reg FROM ACCIOMITIGADORA WHERE accioId = PaccioId;
        IF num_reg = 0 THEN
            raise id_inexistent;
        END IF;
         -- Comprovar si ja esta de baixa.
        SELECT count(accioId) INTO num_reg FROM ACCIOMITIGADORA WHERE accioId = PaccioId AND estat = 'BAIXA';
        IF num_reg = 1 THEN
            raise baixa_existent;
        END IF;
        --Comprovar si te el risc en estat alta
        SELECT COUNT(riscId) INTO num_reg FROM RISC WHERE riscid = (SELECT riscid from ACCIOMITIGADORA WHERE accioId = PaccioId) AND estat = 'ALTA';
        IF num_reg = 1 THEN
            raise risc_alta;
        END IF;
      -- Donar de baixa si te l'estat 'ALTA'
        UPDATE ACCIOMITIGADORA SET ESTAT = 'BAIXA' WHERE accioId = PaccioId AND estat = 'ALTA';    
        PRESPOSTA := 'OK';
        DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
        INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
        COMMIT;

    EXCEPTION
    
        WHEN baixa_existent THEN
            PRESPOSTA := 'ERROR: laccio amb la id '||PaccioId||' ja ha estat donat de baixa anteriorment';
            DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;
            
        WHEN id_inexistent THEN
            PRESPOSTA := 'ERROR: laccio amb la id '||PaccioId||' no existeix';
            DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;    
        WHEN risc_alta THEN
            PRESPOSTA := 'ERROR: laccio amb la id '||PaccioId||' te riscs dalta asociats';
            DBMS_OUTPUT.PUT_LINE(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;    
                
        -- Tipus incorrecte--    
        WHEN ROWTYPE_MISMATCH THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            COMMIT;    
    
        WHEN OTHERS THEN
            v_codi_error := SQLCODE;
            PRESPOSTA := 'ERROR: ' || SQLERRM;
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;
    End;
    /

-------------------------------- MODIFICACIO------------------------------------

create or replace Procedure P_MODIFICACIO_ACCIOMITIGADORA(
    PaccioId IN ACCIOMITIGADORA.accioId%TYPE,
    PRISCID IN ACCIOMITIGADORA.RISCID%TYPE,
    PEMPLEATID IN ACCIOMITIGADORA.EMPLEATID%TYPE,
    PestatAccio IN ACCIOMITIGADORA.estatAccio%TYPE,
    Pdescripcio IN ACCIOMITIGADORA.descripcio%TYPE,
    PdataEstimada IN ACCIOMITIGADORA.dataEstimada%TYPE,
    PDATAIMPLEMENTACIO IN ACCIOMITIGADORA.dataImplementacio%TYPE,
    PRESPOSTA Out Varchar2)
    IS
        param_input Varchar2(4000);
        num_reg Integer;
        v_codi_error Integer;
        id_inexistent EXCEPTION;
        estat_baixa EXCEPTION;
        empleat_inexistent EXCEPTION;
        risc_inexistent EXCEPTION;
        estat_incorrecte EXCEPTION;
        implmentacio_incorrecte EXCEPTION;
        data_incorrecta EXCEPTION;
        v_dataCreacio ACCIOMITIGADORA.dataCreacio%TYPE;
        v_nompro VARCHAR2(50);

    
    BEGIN
        v_nomPro := $$PLSQL_UNIT;
    --Posam els valors d'entrada dins l'input--
        param_input := 'PaccioId = '||PaccioId||'PestatAccio = '||PestatAccio||' Pdescripcio = '||Pdescripcio||' PdataEstimada = '||PdataEstimada;
    --Comprovaci� de que existeix i est� d'alta--     
        SELECT count(accioId) INTO num_reg FROM ACCIOMITIGADORA  WHERE accioId = PaccioId AND estat = 'ALTA';
        IF num_reg = 0 THEN
            RAISE id_inexistent;
        END IF;
        --Comprovacio de si el risc i l'empeleat existeixen
        SELECT count(riscId) INTO num_reg FROM RISC  WHERE riscId = (SELECT riscId FROM ACCIOMITIGADORA WHERE accioId = PaccioId) AND estat = 'ALTA';
        IF num_reg = 0 THEN
            RAISE risc_inexistent;
        END IF;
        SELECT count(empleatId) INTO num_reg FROM EMPLEAT  WHERE empleatId = (SELECT empleatId FROM ACCIOMITIGADORA WHERE accioId = PaccioId) AND estat = 'ALTA';
        IF num_reg = 0 THEN
            RAISE empleat_inexistent;
        END IF;
        --Comprovació de l'estat 
        IF PestatAccio NOT IN ('Definida', 'En curs', 'Implementada amb el risc corregit', 'Implementada amb el risc mitigat', 'Descartada') THEN
            RAISE estat_incorrecte;
        END IF;
        --Comprovació si té data d'implementació i si l'estat és 'Implementada amb el risc corregit' o 'Implementada amb el risc mitigat', o al contrari.
        IF PDATAIMPLEMENTACIO IS NOT NULL AND PestatAccio NOT IN ('Implementada amb el risc corregit', 'Implementada amb el risc mitigat') THEN
            RAISE estat_incorrecte;
        ELSIF PDATAIMPLEMENTACIO IS NULL AND PestatAccio IN ('Implementada amb el risc corregit', 'Implementada amb el risc mitigat') THEN
            RAISE implmentacio_incorrecte;    
        END IF; 
        --Comprovam dates
        SELECT dataCreacio INTO v_dataCreacio FROM ACCIOMITIGADORA WHERE accioId = PaccioId;
        IF v_dataCreacio > PdataEstimada THEN
            RAISE data_incorrecta;
        ELSIF PDATAIMPLEMENTACIO IS NOT NULL AND PDATAIMPLEMENTACIO < v_dataCreacio THEN
            RAISE data_incorrecta;    
        END IF;
       
        --Modificacio de les dades  
        UPDATE ACCIOMITIGADORA SET estatAccio = PestatAccio, descripcio = Pdescripcio, dataEstimada = PdataEstimada, dataImplementacio = PDATAIMPLEMENTACIO
            WHERE accioId = PaccioId AND estat='ALTA';
        IF SQL%ROWCOUNT = 0 THEN
            v_codi_error := SQLCODE;
            RAISE estat_baixa;
        END IF;

        PRESPOSTA:='OK';
        INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
        Dbms_output.Put_line(PRESPOSTA);
        COMMIT;
        EXCEPTION
            WHEN implmentacio_incorrecte THEN
                v_codi_error := SQLCODE;
                PRESPOSTA:= 'ERROR: l accio no te data d implementacio o l estat no es correcte';
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
                Commit;

            WHEN data_incorrecta THEN
                v_codi_error := SQLCODE;
                PRESPOSTA:= 'ERROR: la data d implementacio no pot ser anterior a la data d inici o la data estimada';
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
                Commit;
            WHEN risc_inexistent THEN
                v_codi_error := SQLCODE;
                PRESPOSTA:= 'ERROR: el risc amb la id '||PRISCID||' no existeix o esta de baixa';
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
                Commit;
            WHEN empleat_inexistent THEN
                v_codi_error := SQLCODE;
                PRESPOSTA:= 'ERROR: l empleat amb la id '||PEMPLEATID||' no existeix o esta de baixa';
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
                Commit;
            WHEN estat_incorrecte THEN
                v_codi_error := SQLCODE;
                PRESPOSTA:= 'ERROR: l estat de l accio no es correcte';
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
                Commit;
            WHEN id_inexistent THEN
                PRESPOSTA := 'ERROR: registre amb la id '||PaccioId||' no existeix';
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;    
            WHEN estat_baixa THEN
                PRESPOSTA := 'ERROR: registre amb la id '||PaccioId||' esta donat de baixa';
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;
            WHEN ROWTYPE_MISMATCH THEN
                v_codi_error := SQLCODE;
                PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nompro,param_input, PRESPOSTA, SYSDATE);
                Commit;    
   
            WHEN OTHERS THEN
                v_codi_error := SQLCODE;
                PRESPOSTA := 'ERROR: ' || SQLERRM;
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;    
    END;                 
/

/******************************************************************************
Procediments ABM taula MOSTREIG
*******************************************************************************/ 
CREATE OR REPLACE PROCEDURE P_Alta_MOSTREIG(
    PINSPECCIOID IN MOSTREIG.inspeccioId%TYPE,
    POBJECTIU IN MOSTREIG.objectiu%TYPE,
    PRESULTAT IN MOSTREIG.resultat%TYPE,
    PRESPOSTA OUT VARCHAR2) 
    IS 
        valor_NULL exception;
        PRAGMA EXCEPTION_INIT(valor_NULL, -1400);
        v_codi_error  Integer;
        v_nompro VARCHAR2(100);
        param_input Varchar2(150);
        num_reg Integer;
        inspeccio_inexistent EXCEPTION;

    BEGIN
    --Volcam dades dins variables per imprimir al log
        v_nomPro := $$PLSQL_UNIT;
        param_input:= 'PINSPECCIOID = '||PINSPECCIOID||' POBJECTIU = '||POBJECTIU||' PRESULTAT = '||PRESULTAT;
        --Es comprova l'existència de la inspeccio
        SELECT COUNT(INSPECCIOID) INTO num_reg FROM INSPECCIO WHERE INSPECCIOID = PINSPECCIOID AND estat = 'ALTA';
            IF num_reg = 0 THEN
                RAISE inspeccio_inexistent;    
            END IF;    
        INSERT INTO MOSTREIG (inspeccioId,objectiu,resultat, dataMostreig) VALUES (PINSPECCIOID, POBJECTIU,PRESULTAT, SYSDATE);

        PRESPOSTA:='OK';
        Dbms_output.Put_line(PRESPOSTA);
        INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
        Commit;
        
    -- Control errors--    
    EXCEPTION
        WHEN inspeccio_inexistent THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= 'ERROR: la inspeccio amb la id '||PINSPECCIOID||' no existeix o esta de baixa';
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;
    --Valor null--
        WHEN valor_NULL THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: el valor no pot ser null NULL ' || v_codi_error ||' ' || SQLERRM ,1,100);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
            Commit;
        
    --Index duplicat--
        WHEN DUP_VAL_ON_INDEX THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            COMMIT;
                
    -- Tipus incorrecte--    
      WHEN ROWTYPE_MISMATCH THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            Commit;
            
    --Altres--    
      WHEN Others THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= SUBSTR('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            Commit;        
    END;
/

----------------------------- BAIXA ---------------------------------------------
CREATE OR REPLACE PROCEDURE P_BAIXA_MOSTREIG(
    PMOSTREIGID IN MOSTREIG.mostreigId%TYPE,
    PRESPOSTA Out Varchar2)
    IS
        param_input Varchar2(150);
        num_reg Integer;
        v_codi_error Integer;
        baixa_existent EXCEPTION;
        id_inexistent EXCEPTION;
        v_nompro VARCHAR2(50);
    
    BEGIN
       
      -- Guardar els parametres d'entrada para insertarlo al LOG
        param_input := 'ID PMOSTREIGID = ' || PMOSTREIGID;
        v_nomPro := TO_CHAR($$PLSQL_UNIT);
      -- Comprovar si existeix a la taula.
       SELECT count(mostreigId) INTO num_reg FROM MOSTREIG WHERE mostreigId = pmostreigId;
        IF num_reg = 0 THEN
            raise id_inexistent;
        END IF;
         -- Comprovar si ja esta de baixa.
        SELECT count(mostreigId) INTO num_reg FROM MOSTREIG WHERE mostreigId = pmostreigId AND estat = 'BAIXA';
        IF num_reg = 1 THEN
            raise baixa_existent;
        END IF;
      -- Donar de baixa si te l'estat 'ALTA'
        UPDATE MOSTREIG SET ESTAT = 'BAIXA' WHERE mostreigId = pmostreigId AND estat = 'ALTA';    
        PRESPOSTA := 'OK';
        Dbms_output.Put_line(PRESPOSTA);
        INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
        COMMIT;

    EXCEPTION
    
        WHEN baixa_existent THEN
            PRESPOSTA := 'ERROR: el mostreig amb la id '||PMOSTREIGID||' ja ha estat donat de baixa anteriorment';
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;
            
        WHEN id_inexistent THEN
            PRESPOSTA := 'ERROR: el mostreig amb la id '||PMOSTREIGID||' no existeix';
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;    
                
        -- Tipus incorrecte--    
        WHEN ROWTYPE_MISMATCH THEN
            v_codi_error := SQLCODE;
            PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro,param_input, PRESPOSTA, SYSDATE);
            COMMIT;    
    
        WHEN OTHERS THEN
            v_codi_error := SQLCODE;
            PRESPOSTA := 'ERROR: ' || SQLERRM;
            Dbms_output.Put_line(PRESPOSTA);
            Rollback;
            INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nomPro, param_input, PRESPOSTA, SYSDATE);
            COMMIT;
    End;
    /

-------------------------------- MODIFICACIO------------------------------------

create or replace Procedure P_MODIFICACIO_MOSTREIG(
    PMOSTREIGID IN MOSTREIG.mostreigId%TYPE,
    PINSPECCIOID IN MOSTREIG.inspeccioId%TYPE,
    POBJECTIU IN MOSTREIG.objectiu%TYPE,
    PRESULTAT IN MOSTREIG.resultat%TYPE,
    PRESPOSTA Out Varchar2)
    IS
        param_input Varchar2(300);
        num_reg Integer;
        v_codi_error Integer;
        id_inexistent EXCEPTION;
        estat_baixa EXCEPTION;
        v_nompro VARCHAR2(50);
        inspeccio_inexistent EXCEPTION;

    
    BEGIN
        v_nomPro := $$PLSQL_UNIT;
    --Posam els valors d'entrada dins l'input--
        param_input := 'PMOSTREIGID = '||PMOSTREIGID||'PINSPECCIOID = '||PINSPECCIOID||' POBJECTIU = '||POBJECTIU||'PRESULTAT = '||PRESULTAT;
    --Comprovaci� de que existeix i est� d'alta--     
        SELECT count(mostreigId) INTO num_reg FROM MOSTREIG WHERE mostreigId = pmostreigId AND estat = 'ALTA';
        IF num_reg = 0 THEN
            RAISE id_inexistent;
        END IF;
        --comprovacio de que existeix la inspeccio
        SELECT count(inspeccioId) INTO num_reg FROM INSPECCIO WHERE inspeccioId = PinspeccioId AND estat = 'ALTA';
        IF num_reg = 0 THEN
            RAISE inspeccio_inexistent;
        END IF;
        --Modificacio de les dades  
        UPDATE MOSTREIG SET INSPECCIOID = PINSPECCIOID, OBJECTIU = POBJECTIU, RESULTAT = PRESULTAT WHERE mostreigId = PMOSTREIGID AND estat='ALTA';
        IF SQL%ROWCOUNT = 0 THEN
            v_codi_error := SQLCODE;
            RAISE estat_baixa;
        END IF;

        PRESPOSTA:='OK';
        INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
        Dbms_output.Put_line(PRESPOSTA);
        COMMIT;
        EXCEPTION
        
            WHEN id_inexistent THEN
                PRESPOSTA := 'ERROR: registre amb la id '||PmostreigId||' no existeix';
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;    
            WHEN inspeccio_inexistent THEN
                v_codi_error := SQLCODE;
                PRESPOSTA:= 'ERROR: la inspeccio amb la id '||PINSPECCIOID||' no existeix o esta de baixa';
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG( nomPro, entrada, sortida, dataRegistre) VALUES(v_nomPro, param_input, PRESPOSTA, SYSDATE);
                Commit;                
            WHEN ROWTYPE_MISMATCH THEN
                v_codi_error := SQLCODE;
                PRESPOSTA:= Substr('ERROR: ' || v_codi_error ||' ' || SQLERRM ,1,50);
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES(v_nompro,param_input, PRESPOSTA, SYSDATE);
                Commit;    
   
            WHEN OTHERS THEN
                v_codi_error := SQLCODE;
                PRESPOSTA := 'ERROR: ' || SQLERRM;
                Dbms_output.Put_line(PRESPOSTA);
                Rollback;
                INSERT INTO LOG (nomPro, entrada, sortida, dataRegistre) VALUES (v_nompro, param_input, PRESPOSTA, SYSDATE);
                Commit;    
            
    END;                 
/
