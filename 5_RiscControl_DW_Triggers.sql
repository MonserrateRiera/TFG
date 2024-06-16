/***************************************************************************************************************
* CREACIO DE TRIGGERS I PROCEDIMENTS PER LES DADES DEL DATAWAREHOUSE                                            *
* IMPORTANT : Aquest script ha de ser executat amb l'usuari MRIERAMAR pwd 12345678                               *
***************************************************************************************************************/

/***************************************************************************************************************
* CU-11: Percentatge de riscs no corregits amb impacte <4 
***************************************************************************************************************/

--Procediment que calcula el percentatge de riscos no corregits amb impacte <4 mitjansant la taula DW_PERCRISC

CREATE OR REPLACE PROCEDURE P_PERCENTATGEIMPACTE4
    IS
        v_totalRiscos number;
        v_numRiscos number;
        v_percentatge FLOAT;
    BEGIN
        --Obtenim el total de riscos
        SELECT totalRisc INTO v_totalRiscos FROM DW_PERCRISC;
        --Obtenim el total de riscos amb impacte <4
        select numRiscos INTO v_numRiscos from DW_PERCRISC;
        --Calculem el percentatge
        v_percentatge := (v_numRiscos/v_totalRiscos)*100;
        --Actualitzem la taula
        UPDATE DW_PERCRISC SET percentatge = v_percentatge;
    END;
    /
--Trigger que crida al procediment PERCENTATGEIMPACTE4 quan s'inserta o es modifica una fila a la taula RISC
CREATE OR REPLACE TRIGGER TRIG_PERCENTATGEIMPACTE4
    AFTER INSERT OR UPDATE ON RISC
    REFERENCING OLD AS OLD NEW AS NEW
    FOR EACH ROW
    DECLARE
        v_totalRiscos number;
        v_numRiscos number;
        v_impacte RISC.impacte%TYPE;
        v_estatRisc RISC.estatRisc%TYPE;
        v_impacteAntic RISC.impacte%TYPE;
    BEGIN
        v_impacte := :NEW.impacte;
        v_estatRisc := :NEW.estatRisc;
        --Comprovam si estam inserint nova informació
        IF INSERTING THEN
            --Comprovam si el risc introduit es d'impacte <4 (així com ho he implementat que sigui Impacte catastrofic, Impacte crític, Impacte alt) i que el seu estat sigui Obert
            IF v_impacte IN ('Impacte catastrofic',' Impacte critic', 'Impacte alt') AND v_estatRisc = 'Obert' THEN
                --Comprovam que la taula del data warehouse tingui registres. En cas de no tenir registres, inicialitzaré la taula, en cas contrari la actualitzaré.
                SELECT COUNT(*) INTO v_totalRiscos FROM DW_PERCRISC;
                IF v_totalRiscos = 0 THEN
                    INSERT INTO DW_PERCRISC(totalRisc, numRiscos, percentatge) VALUES (1,1,100);
                ELSIF v_totalRiscos > 0 THEN    
                    --Actualitzam el nombre de riscos de la taula DW_PERCRISC
                UPDATE DW_PERCRISC SET totalRisc = totalRisc+1, numRiscos = numRiscos+1;
                END IF;
            ELSE
                --Actualitzam el comptador total de riscos de la taula DW_PERCRISC. Comprovam en primer lloc si està inicialitzada i sino afegim un registre. Si ja hi ha registres, simplement augmentam un 1.
                SELECT COUNT(*) INTO v_totalRiscos FROM DW_PERCRISC;
                IF v_totalRiscos = 0 THEN
                    INSERT INTO DW_PERCRISC(totalRisc, numRiscos, percentatge) VALUES (1,0,0);
                ELSE
                    UPDATE DW_PERCRISC SET totalRisc = totalRisc +1;
                END IF;    
            END IF;    
        END IF;
        
        --Comprovam si estam actualitzant una fila
        IF UPDATING THEN
            v_impacteAntic:= :OLD.impacte;
            --Comprovar si estam donant el registre de BAIXA. 
            IF :NEW.estat = 'BAIXA' THEN
                --Decrementam el total de riscos de la taula DW_PERCRISC
                UPDATE DW_PERCRISC SET totalRisc = totalRisc-1;
                --Comprovam si el risc que estam donant de baixa era d'impacte <4 i si ho era, decrementam el comptador de riscos de la taula DW_PERCRISC
                IF v_impacteAntic IN ('Impacte catastrofic',' Impacte critic', 'Impacte alt') AND :OLD.estatrisc = 'Obert' THEN
                --Si era un dels riscs que complien les condicions, també el decrementaré.
                    UPDATE DW_PERCRISC SET numRiscos = numRiscos-1;
                    END IF;
            ELSE
                    --Si l'impacte és diferent, comprovaré si el risc modificat ara és d'impacte <4 (així com ho he implementat que sigui Impacte catastrofic, Impacte crític, Impacte alt) i que el seu estat sigui Obert
                IF v_impacte IN ('Impacte catastrofic','Impacte critic', 'Impacte alt') AND :NEW.estatRisc = 'Obert' THEN 
                        --Actualitzaré la taula DW_PERCRISC
                    IF :OLD.estatRisc != 'Obert' OR :OLD.impacte NOT IN ('Impacte catastrofic','Impacte critic', 'Impacte alt') THEN    
                        UPDATE DW_PERCRISC SET numRiscos = numRiscos+1;
                    END IF;
                ELSIF v_impacteAntic IN ('Impacte catastrofic','Impacte critic', 'Impacte alt') OR :OLD.estatRisc = 'Obert' THEN       
                        UPDATE DW_PERCRISC SET numRiscos = numRiscos-1;   
                END IF;
            END IF;
        END IF;  
    --Es crida al procediment per actualitzar el percentatge.
    P_PERCENTATGEIMPACTE4;
        

    END;
/
/***************************************************************************************************************
* CU-12: Per un any en concret, nombre total de riscos amb impacte 1 per aquell any.
***************************************************************************************************************/
--Trigger que actualitza el nombre de riscs amb impacte 1 (Impacte catastrofic) de la taula DW_Impacte1 per un any concret quant s'inserta o es modifica una fila a la taula RISC
CREATE OR REPLACE TRIGGER TRIG_RISCIMPACTE1PERANY
    AFTER INSERT OR UPDATE ON RISC
    REFERENCING OLD AS OLD NEW AS NEW
    FOR EACH ROW
    DECLARE
        v_any number;
        v_numRiscos number;
        v_impacte RISC.impacte%TYPE;
        v_impacteAntic RISC.impacte%TYPE;
        v_numregistres number;
    BEGIN
        v_impacte := :NEW.impacte;
        --Obtenim l'any de la data de la nova fila
        SELECT EXTRACT(YEAR FROM :NEW.dataCreacio) INTO v_any FROM DUAL;
        --En cas de inserir noves dades, es comprova si el nou risc és d'impacte 1 i si ho és, s'actualitza la taula DW_Impacte1
        IF INSERTING THEN
            IF v_impacte = 'Impacte catastrofic' THEN
            --Comprovam si la taula del DW_Impacte1 tingui registres per l'any que hem indicat. En cas contrari, insertaré la informació per aquell any.
                SELECT COUNT(*) INTO v_numregistres FROM DW_Impacte1 WHERE anyo = v_any;
                IF v_numregistres = 0 THEN
                    INSERT INTO DW_Impacte1 (anyo, nombreImpacte1) VALUES (v_any, 1);
                ELSE
                    --En cas de tenir registres, actualitzaré el nombre de riscos amb impacte 1 per aquell any.
                    UPDATE DW_Impacte1 SET nombreImpacte1 = nombreImpacte1 + 1 WHERE anyo = v_any;
                END IF;
            END IF;
        END IF;
        --Si estam actualitzant, comprovare que el nou impacte sigui diferent i si escau, actualitzaré la taula. Si tenen el mateix, no actualitzaré la taula.
        IF UPDATING THEN
              v_impacteAntic:= :OLD.impacte;
            --Si es una BAIXA, decrementaré el comptador de riscos amb impacte 1 per l'any corresponent.
            IF :NEW.estat = 'BAIXA' THEN
                IF v_impacteAntic = 'Impacte catastrofic' THEN
                    UPDATE DW_Impacte1 SET nombreImpacte1 = nombreImpacte1 - 1 WHERE anyo = v_any;
                END IF;
            END IF;
            --Si l'impacte no ha canviat, no actualitzaré la taula.
            IF v_impacte = v_impacteAntic THEN
                RETURN;    
            END IF;
           IF v_impacte = 'Impacte catastrofic' THEN
            --Comprovam si la taula del DW_Impacte1 tingui registres per l'any que hem indicat. En cas contrari, insertaré la informació per aquell any.
                SELECT COUNT(anyo) INTO v_numregistres FROM DW_Impacte1 WHERE anyo = v_any;
                IF v_numregistres = 0 THEN
                    INSERT INTO DW_Impacte1 (anyo, nombreImpacte1) VALUES (v_any, 1);
                ELSE
                    --En cas de tenir registres, actualitzaré el nombre de riscos amb impacte 1 per aquell any.
                    UPDATE DW_Impacte1 SET nombreImpacte1 = nombreImpacte1 + 1 WHERE anyo = v_any;
                END IF;
            ELSE 
            --En cas de que el valor antic fos d'impacte 1, decrementaré el comptador
                IF v_impacteAntic = 'Impacte catastrofic' THEN
                    UPDATE DW_Impacte1 SET nombreImpacte1 = nombreImpacte1 - 1 WHERE anyo = v_any;
                END IF;
            END IF;
        END IF;
    END;
/
/*************************************************************************************************************************************************************
* CU-13: Per l'any anterior, nombre total de riscos que estan en estat 'obert'. Interpret que els riscs creats a l'any anterior que encara tenen l'estat obert.
**************************************************************************************************************************************************************/    
--Trigger que si es crea un risc amb data amb l'any anterior al actual, actualitza la taula DW_RISCOSOBERTS amb el nou valor
CREATE OR REPLACE TRIGGER TRIG_RISCSOBERTSANYANTERIOR
    AFTER INSERT OR UPDATE ON RISC
    REFERENCING OLD AS OLD NEW AS NEW
    FOR EACH ROW
    DECLARE
        v_anyanterior number;
        v_numregistres number;
    BEGIN
        --Obtenim l'any anterior
        SELECT EXTRACT(YEAR FROM SYSDATE)-1 INTO v_anyanterior FROM DUAL;
        --Comprovam si la nova fila té l'any anterior al actual i si l'estat del risc és 'Obert'
        IF INSERTING THEN
            IF EXTRACT(YEAR FROM :NEW.dataCreacio) = v_anyanterior AND :NEW.estatRisc = 'Obert' THEN
                --Comprovam si la taula del DW_RISCOSOBERTS té registres. Si en té actualitzaré la taula. En cas contrari, inicialitzaré la taula.
                SELECT COUNT(*) INTO v_numregistres FROM DW_RiscsOberts;
                IF v_numregistres = 0 THEN
                    INSERT INTO DW_RiscsOberts (numRiscsOberts) VALUES (1);
                ELSE
                    UPDATE DW_RiscsOberts SET numRiscsOberts = numRiscsOberts + 1;
                END IF;
            END IF;
        END IF;
        IF UPDATING THEN
            --Comprovam si l'estat del risc ha canviat a 'Obert'.
            IF :OLD.estatRisc != 'Obert' AND :NEW.estatRisc = 'Obert' AND EXTRACT(YEAR FROM :NEW.dataCreacio) = v_anyanterior AND :NEW.estat = 'ALTA' THEN
                --Comprovam si la taula del DW_RISCOSOBERTS té registres. Si en té actualitzaré la taula. En cas contrari, inicialitzaré la taula.
                SELECT COUNT(*) INTO v_numregistres FROM DW_RiscsOberts;
                IF v_numregistres = 0 THEN
                    INSERT INTO DW_RiscsOberts (numRiscsOberts) VALUES (1);
                ELSE
                    UPDATE DW_RiscsOberts SET numRiscsOberts = numRiscsOberts + 1;
                END IF;      
                --Si l'estat canvia de obert a tancat decrementaré el comptador.
            ELSIF  :OLD.estatRisc = 'Obert' AND :NEW.estatRisc != 'Obert' AND EXTRACT(YEAR FROM :OLD.dataCreacio) = v_anyanterior AND :NEW.estat = 'ALTA' THEN
                UPDATE DW_RiscsOberts SET numRiscsOberts = numRiscsOberts - 1;
            END IF;
            --Si es dona de baixa un risc i compleix amb les condicions, decrementaré el comptador.
            IF :NEW.estat = 'BAIXA' AND EXTRACT(YEAR FROM :OLD.dataCreacio) = v_anyanterior AND :OLD.estatRisc = 'Obert' THEN
                UPDATE DW_RiscsOberts SET numRiscsOberts = numRiscsOberts - 1;
            END IF;
        END IF;  
    END;
/    

/***************************************************************************************************************
* CU-14: Obtenir el departament amb major nombre de riscos detectats amb auditories externes.
***************************************************************************************************************/   
--Procediment que comprova si el departament és el que té mes riscos detectats amb auditories externes.
CREATE OR REPLACE PROCEDURE P_MAXAE
    IS
        v_departament Departament.depId%TYPE;
    BEGIN
    --Obtenim la id del deparament que estigui d'alta amb el major nombre de riscos
        SELECT depId INTO v_departament FROM DEPARTAMENT WHERE nombreRiscsAE = (SELECT MAX(nombreRiscsAE) FROM DEPARTAMENT) AND ROWNUM = 1;
    --Actualitzam la taula DW_DepartamentMaxAE amb el nou valor
        UPDATE DW_DepartamentMaxAE SET depId = v_departament;
    END;        
/    
--Trigger que actualitza el comptador de riscos detectats amb auditories externes de la taula departament i crida al procediment PRO_MAXAE
-- que actualitza la taula DW_DepartamentMaxAE si escau.
CREATE OR REPLACE TRIGGER TRIG_MAXAE
    AFTER INSERT OR UPDATE ON RISC
    REFERENCING OLD AS OLD NEW AS NEW
    FOR EACH ROW
    DECLARE
        v_inspeccioId Inspeccio.inspeccioId%TYPE;
        num_registres NUMBER;
        v_depId Departament.depId%TYPE;
        v_estat RISC.estat%TYPE;
    BEGIN
        v_depId := :NEW.depId;
        v_inspeccioId := :NEW.inspeccioId;

        IF INSERTING THEN
            --Comprovació de que el risc introduit es d'auditoria externa
            SELECT COUNT(inspeccioId) INTO num_registres FROM AUDITORIAEXTERNA WHERE inspeccioId = v_inspeccioId AND estat = 'ALTA';
            IF num_registres = 1 THEN
                --Actualitzam el comptador dels riscs detectats amb auditories externes al departament-
                UPDATE DEPARTAMENT SET nombreRiscsAE = nombreRiscsAE + 1 WHERE depId = v_depId;
                --Comprovam si la taula de DW_DepartamentMaxAE està inicialitzada, i si no hi està, inserim el primer registre.
                SELECT COUNT(*) INTO num_registres FROM DW_DepartamentMaxAE;
                IF num_registres = 0 THEN
                    INSERT INTO DW_DepartamentMaxAE (depId) VALUES (v_depId);   
                END IF;
            END IF;    
        END IF;

        IF UPDATING THEN
            v_estat := :NEW.estat;
            --Comprovació de si estam donant l'acció de BAIXA
            IF v_estat = 'BAIXA' THEN
                --Comprovació de que el risc es d'auditoria externa
                SELECT COUNT(inspeccioId) INTO num_registres FROM AUDITORIAEXTERNA WHERE inspeccioId = v_inspeccioId AND estat = 'ALTA';
                IF num_registres = 1 THEN
                --Decrementam el comptador del departament
                    UPDATE DEPARTAMENT SET nombreRiscsAE = nombreRiscsAE - 1 WHERE depId = v_depId;
                END IF;
            END IF;
        END IF;
        P_MAXAE;
    END;
/    

/***************************************************************************************************************
* CU-15: Nombre d'accions en curs en l'any actual
***************************************************************************************************************/ 
--Trigger que actualitza el nombre d'accions en curs de la taula DW_AccionsCurs en l'any actual
CREATE OR REPLACE TRIGGER TRIG_ACCIONSCURS
    AFTER INSERT OR UPDATE ON ACCIOMITIGADORA
    REFERENCING OLD AS OLD NEW AS NEW
    FOR EACH ROW
    DECLARE
        v_any number;
        v_numAccions number;
        v_estatAccio ACCIOMITIGADORA.estatAccio%TYPE;
        v_estatAnterior ACCIOMITIGADORA.estatAccio%TYPE;
    BEGIN
        --Obtenim l'any actual
        SELECT EXTRACT(YEAR FROM SYSDATE) INTO v_any FROM DUAL;
        v_estatAccio:= :NEW.estatAccio;
        
        IF INSERTING THEN
            --Comprovam si la nova acció té l'estat 'En curs' i creats en l'any actual
            IF v_estatAccio = 'En curs' AND EXTRACT(YEAR FROM (:NEW.dataCreacio)) = v_any THEN
            --Comprovam si la taula té registres. En cas de no tenir-ne, inicialitzaré la taula, en cas contrari, actualitzaré el valor.
                SELECT COUNT(*) INTO v_numAccions FROM DW_AccionsCurs;
                IF v_numAccions = 0 THEN
                    INSERT INTO DW_AccionsCurs (nombreAccionsCurs) VALUES (1);
                ELSE
                    UPDATE DW_AccionsCurs SET nombreAccionsCurs = nombreAccionsCurs + 1;
                END IF;
            END IF;
        END IF;
        IF UPDATING THEN
        v_estatAnterior:= :OLD.estatAccio;
        --Comprovació de si estam donant l'acció de BAIXA
            IF :NEW.estat = 'BAIXA' THEN
            --Comprovam si l'accio complia les condicions, en cas afirmatiu, decrementar el comptador
                IF v_estatAnterior = 'En curs' AND EXTRACT(YEAR FROM (:NEW.dataCreacio)) = v_any THEN
                    UPDATE DW_AccionsCurs SET nombreAccionsCurs = nombreAccionsCurs - 1;
                END IF;
            END IF;
        --Comprovació de si l'estat ha canviat amb l'update. Si és igual no canviarà res, si es diferent es comprova si hem de incrementar o decrementar el comptador.
            IF v_estatAccio = 'En curs' AND EXTRACT(YEAR FROM (:NEW.dataCreacio)) = v_any THEN
                IF v_estatAnterior != 'En curs' THEN
                    UPDATE DW_AccionsCurs SET nombreAccionsCurs = nombreAccionsCurs + 1;
                END IF;
            ELSIF v_estatAccio != 'En curs' AND EXTRACT(YEAR FROM (:NEW.dataCreacio)) = v_any THEN
                IF v_estatAnterior = 'En curs' THEN
                    UPDATE DW_AccionsCurs SET nombreAccionsCurs = nombreAccionsCurs - 1;
                END IF;
            END IF;    
        END IF;
    END;   
/    

/***************************************************************************************************************
* CU-16: Donat un any, diferència de riscos detectats amb auditories internes i externes
***************************************************************************************************************/ 
--Procediment que realitza el calcul mitjançant les dades DW_DiferenciaInternaExterna
CREATE OR REPLACE PROCEDURE P_DIFERENCIAINTERNAEXTERNA(
    PANY IN number)

    IS
        v_any number;
        v_numRiscsAI number;
        v_numRiscsAE number;
        v_diferencia number;
    BEGIN
        --Obtenim el nombre de riscos detectats amb auditories internes i externes per l'any
        SELECT numRiscAI INTO v_numRiscsAI FROM DW_DiferenciaInternaExterna WHERE anyo = PANY;
        SELECT numRiscAE INTO v_numRiscsAE FROM DW_DiferenciaInternaExterna WHERE anyo = PANY;
        --Calculem la diferencia
        v_diferencia := v_numRiscsAI - v_numRiscsAE;
        --Actualitzem la taula
        UPDATE DW_DiferenciaInternaExterna SET diferencia = ABS(v_diferencia)  WHERE anyo = PANY;
    END;
/
--Trigger que actualitza les dades de la taula DW_DiferenciaInternaExterna quan s'inserta o es modifica una fila a la taula RISC
CREATE OR REPLACE TRIGGER TRIG_DIFERENCIAINTERNAEXTERNA
    AFTER INSERT OR UPDATE ON RISC
    REFERENCING OLD AS OLD NEW AS NEW
    FOR EACH ROW
    DECLARE
        v_any number;
        v_inspeccioId Inspeccio.inspeccioId%TYPE;
        num_registres NUMBER;
        num_registres_externa NUMBER;
        num_registres_interna NUMBER;

        v_estat RISC.estat%TYPE;
    BEGIN  
        v_inspeccioId := :NEW.inspeccioId;
        v_estat := :NEW.estat;
        v_any := EXTRACT(YEAR FROM :NEW.dataCreacio);

        IF INSERTING THEN
         --Es comprova que la taula estigui DW_DiferenciaInternaExterna inicialitzada. Si no hi està l'inicialitzam.
            SELECT COUNT(*) INTO num_registres FROM DW_DiferenciaInternaExterna WHERE anyo = v_any;
            IF num_registres = 0 THEN
                INSERT INTO DW_DiferenciaInternaExterna (anyo, numRiscAI, numRiscAE, diferencia) VALUES (v_any,0,0,0);
            END IF;

         --comprovam si el risc introduït és d'auditoria interna o externa si actualitzam si escau.
            SELECT COUNT(v_inspeccioId) INTO num_registres_externa FROM AUDITORIAEXTERNA WHERE inspeccioId = v_inspeccioId;
            IF num_registres_externa = 1 THEN
                --Actualitzam el nombre de riscs per auditories externes
                UPDATE DW_DiferenciaInternaExterna SET numRiscAE = numRiscAE + 1 WHERE anyo = v_any;
            END IF;
            SELECT COUNT(v_inspeccioId) INTO num_registres_interna FROM AUDITORIAINTERNA WHERE inspeccioId = v_inspeccioId;
            IF num_registres_interna = 1 THEN
                --Actualitzam el nombre de riscs per auditories internes
                UPDATE DW_DiferenciaInternaExterna SET numRiscAI = numRiscAI + 1 WHERE anyo = v_any;
            END IF;    
        END IF;
        --Si estam actualitzant, comprovam si el risc ha estat donat de baixa.
        IF UPDATING THEN
            v_estat := :NEW.estat;
            IF v_estat = 'BAIXA' THEN
                --Comprovam si el risc introduït és d'auditoria interna o externa si actualitzam si escau.
                SELECT COUNT(v_inspeccioId) INTO num_registres_externa FROM AUDITORIAEXTERNA WHERE inspeccioId = v_inspeccioId;
                IF num_registres_externa = 1 THEN
                    --Actualitzam el nombre de riscs per auditories externes
                    UPDATE DW_DiferenciaInternaExterna SET numRiscAE = numRiscAE - 1 WHERE anyo = v_any;
                END IF;
                SELECT COUNT(v_inspeccioId) INTO num_registres_interna FROM AUDITORIAINTERNA WHERE inspeccioId = v_inspeccioId;
                IF num_registres_interna = 1 THEN
                    --Actualitzam el nombre de riscs per auditories internes
                    UPDATE DW_DiferenciaInternaExterna SET numRiscAI = numRiscAI - 1 WHERE anyo = v_any;
                END IF;   
            END IF;    
            --Comprovam si la id de la inspecció ha canviat. Si ha canviat, comprovam si hem de decrementar o incrementar comptadors.
            IF :NEW.inspeccioId != :OLD.inspeccioId THEN
                SELECT COUNT(v_inspeccioId) INTO num_registres_interna FROM AUDITORIAINTERNA WHERE inspeccioId = v_inspeccioId;
                IF num_registres_interna = 1 THEN
                    UPDATE DW_DiferenciaInternaExterna SET numRiscAI = numRiscAI + 1 WHERE anyo = v_any;
                    SELECT COUNT(v_inspeccioId) INTO num_registres_externa FROM AUDITORIAEXTERNA WHERE inspeccioId = :OLD.inspeccioId;
                    IF num_registres_externa = 1 THEN
                        UPDATE DW_DiferenciaInternaExterna SET numRiscAE = numRiscAE - 1 WHERE anyo = v_any;
                    END IF;
                END IF;
                SELECT COUNT(v_inspeccioId) INTO num_registres_externa FROM AUDITORIAEXTERNA WHERE inspeccioId = v_inspeccioId;
                IF num_registres_externa = 1 THEN
                    UPDATE DW_DiferenciaInternaExterna SET numRiscAE = numRiscAE + 1 WHERE anyo = v_any;
                    SELECT COUNT(v_inspeccioId) INTO num_registres_interna FROM AUDITORIAINTERNA WHERE inspeccioId = :OLD.inspeccioId;
                    IF num_registres_interna = 1 THEN
                        UPDATE DW_DiferenciaInternaExterna SET numRiscAI = numRiscAI - 1 WHERE anyo = v_any;
                    END IF;
                END IF;
            END IF;     
        END IF;

        --Cridam al procediment PROC_DIFERENCIAINTERNAEXTERNA per recalcula la diferencia
        P_DIFERENCIAINTERNAEXTERNA(v_any);
    END;
    /

/***************************************************************************************************************
* CU-17: En el moment d’executar la consulta, persona de l’empresa que té més accions
obertes (en estat d’en curs o de definida) assignades. Utilitzare la taula DW_EmpleatMesAccions,
***************************************************************************************************************/     
--PROCEDIMENT QUE ACTUALITZA LA TAULA DW_EmpleatMesAccions
CREATE OR REPLACE PROCEDURE P_EMPLEATMESACCIONS
    IS
        v_empleatId Empleat.empleatId%TYPE;
    BEGIN
        --Obtenim la id de l'empleat amb mes accions obertes
        SELECT empleatId INTO v_empleatId FROM EMPLEAT WHERE comptadorAccions = (SELECT MAX(comptadorAccions) FROM EMPLEAT) AND ROWNUM = 1;
        --Actualitzam la taula DW_EmpleatMesAccions amb el nou valor
        UPDATE DW_EmpleatMesAccions SET empleatId = v_empleatId;
    END;
/
--Trigger que quant afegim un accio actalitza el comptador d'accions de l'empleat i crida al procediment PRO_EMPLEATMESACCIONS per a cerca l'empleat amb més accions.
CREATE OR REPLACE TRIGGER TRIG_EMPLEATMESACCIONS
    AFTER INSERT OR UPDATE ON ACCIOMITIGADORA
    REFERENCING OLD AS OLD NEW AS NEW
    FOR EACH ROW
    DECLARE
        v_empleatId Empleat.empleatId%TYPE;
        v_accioId ACCIOMITIGADORA.accioId%TYPE;
        v_estatAccio ACCIOMITIGADORA.estatAccio%TYPE;
        v_numregistres number;
    BEGIN
        v_accioId := :NEW.accioId;
        v_empleatId := :NEW.empleatId;
        v_estatAccio := :NEW.estatAccio;

        IF INSERTING THEN
            --Comprovarem l'estat de l'accio, si es en curs o definida, incrementarem el comptador d'accions de l'empleat
            IF v_estatAccio IN ('En curs', 'Definida') THEN
                UPDATE EMPLEAT SET comptadorAccions = comptadorAccions + 1 WHERE empleatId = v_empleatId;
                --Si la taula del magatzem no està inicialitzada, la inicialitzarem
                SELECT COUNT(*) INTO v_numregistres FROM DW_EmpleatMesAccions;
                IF v_numregistres = 0 THEN
                    INSERT INTO DW_EmpleatMesAccions (empleatId) VALUES (v_empleatId);
                END IF;
            END IF;
        END IF;
        IF UPDATING THEN
            --Comprovarem que no s'hagui donat de baixa l'accio
            IF :NEW.estat = 'BAIXA' AND :OLD.estatAccio IN('En curs', 'Definida') THEN
                UPDATE EMPLEAT SET comptadorAccions = comptadorAccions - 1 WHERE empleatId = v_empleatId;
            END IF;
            --Si l'accio ha canviat d'estat, actualitzarem el comptador d'accions de l'empleat com calgui
            IF v_estatAccio IN ('En curs', 'Definida') AND :OLD.estatAccio NOT IN ('En curs', 'Definida') THEN
                UPDATE EMPLEAT SET comptadorAccions = comptadorAccions + 1 WHERE empleatId = v_empleatId;
                --Si hem canviat d'empleat amb l'update llavors decrementarem el comptador de l'empleat anterior
                IF :OLD.empleatId != :NEW.empleatId THEN
                    UPDATE EMPLEAT SET comptadorAccions = comptadorAccions - 1 WHERE empleatId = :OLD.empleatId;
                END IF;
            END IF;
            IF v_estatAccio NOT IN ('En curs', 'Definida') AND :OLD.estatAccio IN ('En curs', 'Definida') THEN
                --Si l'accio ha canviat d'estat a un estat que no sigui 'En curs' o 'Definida', decrementarem el comptador d'accions de l'empleat anterior (si es canviàs l'empleat, el decrementariem a l'antic.)
                UPDATE EMPLEAT SET comptadorAccions = comptadorAccions - 1 WHERE empleatId = :OLD.empleatId;

            END IF;
        END IF;
        P_EMPLEATMESACCIONS;
    END;
/

/***************************************************************************************************************
* CU-18: Nombre mitjà de mostrejos fets per any sense considerar l’any actual
***************************************************************************************************************/     
--Procediment que calcula el nombre mitjà de mostrejos fets per any sense considerar l’any actual
CREATE OR REPLACE PROCEDURE P_MOSTREJOSMITJA
    IS
        v_any number;
        v_numMostrejos number;
        v_numAnys number;
        v_numMitja float;
        v_numregistres number;
    BEGIN
        --Obtenim el nombre de anys
        SELECT COUNT(anyo) INTO v_numAnys FROM DW_MosrejosAny;
        --Obtenim el total de mostrejos per tots els anys
        SELECT SUM(numMostrejos) INTO v_numMostrejos FROM DW_MosrejosAny;
        --Calculem la mitja
        v_numMitja := v_numMostrejos/v_numAnys;
        --Actualitzam la taula. Si no te valors li inserim
        SELECT COUNT(*) INTO v_numregistres FROM DW_MitjaMostrejos;
        IF v_numregistres = 0 THEN
            INSERT INTO DW_MitjaMostrejos (mitja) VALUES (v_numMitja);
        ELSE
        UPDATE DW_MitjaMostrejos SET mitja = v_numMitja;
        END IF;
    END;
/

--Trigger que actualitza el nombre mitjà de mostrejos fets per any sense considerar l’any actual quan s'inserta o es modifica una fila a la taula MOSTREIG
CREATE OR REPLACE TRIGGER TRIG_MOSTREJOSMITJA
    AFTER INSERT OR UPDATE ON MOSTREIG
    REFERENCING OLD AS OLD NEW AS NEW
    FOR EACH ROW
    DECLARE
        v_any number;
        v_numregistres number;
        v_anyMostreig number;
    BEGIN
        --Obtenim l'any actual i el de les dades introduides, i si són iguals, no actualitzarem la taula
        SELECT EXTRACT(YEAR FROM SYSDATE) INTO v_any FROM DUAL;
        v_anyMostreig := EXTRACT(YEAR FROM :NEW.dataMostreig);
        IF v_anyMostreig = v_any THEN
            RETURN;
        END IF;

        IF INSERTING THEN
            --Comprovam si la taula del magatzem té registres per l'any. En cas contrari, inicialitzarem la taula.
            SELECT COUNT(*) INTO v_numregistres FROM DW_MosrejosAny where anyo = v_anyMostreig;
            IF v_numregistres = 0 THEN
                INSERT INTO DW_MosrejosAny (anyo, numMostrejos) VALUES (v_anyMostreig, 1);
            ELSE
                --En cas de tenir registres, incrementarem el nombre de mostrejos per aquell any.
                UPDATE DW_MosrejosAny SET numMostrejos = numMostrejos + 1 WHERE anyo = v_anyMostreig;
            END IF;
        END IF;
        IF UPDATING THEN
        --Comprovam si hem donat el mostreig de baixa, i si és així decrementam el comptador de mostrejos per aquell any.
            IF :NEW.estat = 'BAIXA' THEN
                UPDATE DW_MosrejosAny SET numMostrejos = numMostrejos - 1 WHERE anyo = v_anyMostreig;
            END IF;
        END IF;
        --Cridam al procediment PRO_MOSTREJOSMITJA per recalcula la mitja
        P_MOSTREJOSMITJA;
    END;
/
/***************************************************************************************************************
CU-19: Tenint en compte l’any en curs i l’anterior, nombre de riscos de ciberseguretat
detectats per autoavaluació dels departaments
***************************************************************************************************************/ 
-- Creacio d'un trigger, que al crear un risc de tipus ciberseguretat i autoavaluacio, actualitza el comptador de autoavaluacio. LLavors
-- actualitza la taula DW_CiberAutoAv.
CREATE OR REPLACE TRIGGER TRIG_CIBERAUTOAV
    AFTER INSERT OR UPDATE ON RISC
    REFERENCING OLD AS OLD NEW AS NEW
    FOR EACH ROW
    DECLARE
        v_any number;
        v_numregistres number;
        v_idcyber number;
        v_regAutoAvaluacio number;
        v_regAutoAvaluacioAntic number;
    BEGIN
        --Obtenim l'any actual
        SELECT EXTRACT(YEAR FROM SYSDATE) INTO v_any FROM DUAL;
        --obtenim la id del tipus de risc ciberseguretat
        SELECT catId INTO v_idcyber FROM CATEGORIA WHERE nom = 'Ciberseguretat';
        
        IF INSERTING THEN
            IF EXTRACT(YEAR FROM :NEW.dataCreacio) = v_any OR EXTRACT(YEAR FROM :NEW.dataCreacio) = v_any-1 THEN
                SELECT COUNT(*) INTO v_regAutoAvaluacio FROM AUTOAVALUACIO WHERE inspeccioId = :NEW.inspeccioId;
                --Comprovam que les dades inserides siguin d'autoavaluació i ciberseguretat
                IF :NEW.catId = v_idcyber AND v_regAutoAvaluacio = 1 THEN
                    --Comprovam si la taula del magatzem té registres per l'any. En cas contrari, inicialitzarem la taula.
                    SELECT COUNT(*) INTO v_numregistres FROM DW_CiberAutoAv;
                    IF v_numregistres = 0 THEN
                        INSERT INTO DW_CiberAutoAv (totalCyber) VALUES (1);
                    ELSE
                        --En cas de tenir registres, incrementarem el nombre de riscos de ciberseguretat detectats per autoavaluació per l'any actual i l'anterior.
                        UPDATE DW_CiberAutoAv SET totalCyber = totalCyber + 1;
                    END IF;
                END IF;
            END IF;
        END IF;

        IF UPDATING THEN
            --Comprovam que estigui dins els anys que ens interessen
            IF EXTRACT(YEAR FROM :NEW.dataCreacio) = v_any OR  EXTRACT(YEAR FROM :NEW.dataCreacio) = v_any-1  THEN
            --Comprovam si les dades noves coincideixen amb la categoria de ciberseguretat i autoavaluació
                SELECT COUNT(*) INTO v_regAutoAvaluacio FROM AUTOAVALUACIO WHERE inspeccioId = :NEW.inspeccioId;
                SELECT COUNT(*) INTO v_regAutoAvaluacioAntic FROM AUTOAVALUACIO WHERE inspeccioId = :OLD.inspeccioId;

                --Comprovam si les dades noves coincideixen amb la categoria de ciberseguretat i autoavaluació
                IF :NEW.catId = v_idcyber  AND v_regAutoAvaluacio = 1 AND :NEW.estat = 'ALTA' THEN
                    --En aquest cas comprovam que abans alguna no les complia, i si es així incrementam el comptador
                    IF :OLD.catId != v_idcyber OR v_regAutoAvaluacioAntic = 0 THEN
                         --Comprovam si la taula del magatzem té registres per l'any. En cas contrari, inicialitzarem la taula.
                        SELECT COUNT(*) INTO v_numregistres FROM DW_CiberAutoAv;
                        IF v_numregistres = 0 THEN
                            INSERT INTO DW_CiberAutoAv (totalCyber) VALUES (1);
                        ELSE
                                --En cas de tenir registres, incrementarem el nombre de riscos de ciberseguretat detectats per autoavaluació per l'any actual i l'anterior.
                            UPDATE DW_CiberAutoAv SET totalCyber = totalCyber + 1;                                          
                        END IF;
                    END IF;
                ELSE
                    --Comprovam si les dades antigues si que complien i decrementam el comptador si escau
                    IF :OLD.catId = v_idcyber AND v_regAutoAvaluacioAntic = 1 AND :NEW.estat = 'BAIXA' THEN
                        UPDATE DW_CiberAutoAv SET totalCyber = totalCyber - 1;
                    ELSIF :OLD.catId = v_idcyber AND v_regAutoAvaluacioAntic = 1 AND :NEW.estat = 'ALTA' THEN
                            UPDATE DW_CiberAutoAv SET totalCyber = totalCyber - 1;
                    END IF;        
                END IF;
            END IF;
        END IF;

    END;
/
/***************************************************************************************************************
CU-20: En el darrer any, cost mitjà de totes les auditories externes realitzades. He interpretat que es refereix a l'any anterior.
***************************************************************************************************************/ 
--Creacio dun procedure que calcula el cost mitja de les auditories externes realitzades en l'any anterior
CREATE OR REPLACE PROCEDURE P_COSTMITJA
    IS
        v_costTotal number;
        v_numAuditories number;
        v_mitja number;
    BEGIN
    --Obtenció de les dades de la taula DW_costMitja
        SELECT costTotal INTO v_costTotal FROM DW_costMitja;
        SELECT nombreAE INTO v_numAuditories FROM DW_costMitja;
        --Calcul del cost mitja
        v_mitja:= v_costTotal/v_numAuditories;
        --Actualització de la taula
        UPDATE DW_costMitja SET costMitja = v_mitja;
    END;
/    
-- Creacio d'un trigger, que al crear una auditoria externa, actualitza el cost total de les auditories externes i el nombre d'auditories externes
CREATE OR REPLACE TRIGGER TRIG_COSTMITJA
    AFTER INSERT OR UPDATE ON AUDITORIAEXTERNA
    REFERENCING OLD AS OLD NEW AS NEW
    FOR EACH ROW
    DECLARE
        v_any number;
        v_cost number;
        v_costAntic number;
        v_numAuditories number;
        v_inspeccioId Inspeccio.inspeccioId%TYPE;
        v_anyInspeccio number;
        v_numregistres number;
    BEGIN
      --Obtenim l'any actual
        SELECT EXTRACT(YEAR FROM SYSDATE) INTO v_any FROM DUAL;
        v_any := v_any - 1;
      --Es comprova que sigui de l'any anterior
        v_inspeccioId := :NEW.INSPECCIOID;

        SELECT EXTRACT(YEAR FROM DATAINICI) INTO v_anyInspeccio FROM INSPECCIO WHERE INSPECCIOID = v_inspeccioId; 
        IF v_anyInspeccio != v_any THEN
        --Si no és de l'any anterior, llavors el trigger no actualitza res.
            RETURN;
        END IF;    
    --Comprovam si es una inserció
        IF INSERTING THEN
            v_cost := :NEW.cost;
            --Es comprova que ja hi hagui registres:
            SELECT COUNT(*) INTO v_numregistres FROM DW_costMitja;
            IF v_numregistres = 0 THEN
                --Si no n'hi ha, incialitzam la taula
                INSERT INTO DW_costMitja (costTotal, nombreAE, costMitja) VALUES (v_cost, 1, v_cost);
            ELSE    
                --Si hi ha registres, actualitzam les dades
                UPDATE DW_costMitja SET costTotal = costTotal + v_cost, nombreAE = nombreAE + 1;
                --Recalculam la mitja
                P_COSTMITJA;
            END IF;
           
        END IF;
        --Si estam actualitzant, llavors restam el cost anterior de les auditories i sumam el nou.
        IF UPDATING THEN
            IF :NEW.estat = 'BAIXA' THEN
                --Si l'auditoria ha estat donada de baixa, decrementam el cost total i el nombre d'auditories
                UPDATE DW_costMitja SET costTotal = costTotal - :OLD.cost, nombreAE = nombreAE - 1;
            --Si no, comprovam si ha canviat el cost. En aquest cas actualitzam el cost total.    
            ELSIF :OLD.cost != :NEW.cost THEN
                v_costAntic := :OLD.cost;
                v_cost := :NEW.cost;
                UPDATE DW_costMitja SET costTotal = costTotal + v_cost - v_costAntic;
            END IF;
            --Recalculam la mitja
            P_COSTMITJA;
        END IF;
    END;

/
/***************************************************************************************************************
    CU-21: Tenint en compte totes les dades de què es disposa, any amb un nombre major
d’accions que al final de l’any en qüestió estaven en estat d’implementada amb el risc
mitigat
***************************************************************************************************************/     
--Procediment que comprova l'any amb més accions implementades i actualitza la taula DW_MaxAny
CREATE OR REPLACE PROCEDURE P_ANYMAXACCIONSIMPLEMENTADES
    IS
        v_any number;
        v_numAccions number;
    BEGIN
        --Comprovam si la taula té registres. Si no en té sortirem del procediment.
        SELECT COUNT(*) INTO v_numAccions FROM DW_AccionsAny;
        IF v_numAccions = 0 THEN
            RETURN;
        END IF;
        --Obtenim l'any amb més accions implementades
        SELECT anyo INTO v_any FROM DW_AccionsAny WHERE comptaAccions = (SELECT MAX(comptaAccions) FROM DW_AccionsAny) AND ROWNUM = 1;
        --Comprovam si la taula està incialitzada. Si no hi està, faré el primer insert, si no, actualitzaré el valor.
        SELECT COUNT(*) INTO v_numAccions FROM DW_MaxAny;
        IF v_numAccions = 0 THEN
            INSERT INTO DW_MaxAny (anyo) VALUES (v_any);
        ELSE
            UPDATE DW_MaxAny SET anyo = v_any;
        END IF;
    END;
/
-- Trigger que comprova si una acció que s'inserta o es modifica esta  implementada, i actualitza el comptador d'accions implementades per aquell any.
CREATE OR REPLACE TRIGGER TRIG_ANYMAXACCIONSIMPLEMENTADES
    AFTER INSERT OR UPDATE ON ACCIOMITIGADORA
    REFERENCING OLD AS OLD NEW AS NEW
    FOR EACH ROW
    DECLARE
        v_any number;
        v_numAccions number;
    BEGIN
        --Obtenim l'any de la data de la implementació de la nova fila. Si no hi ha data, no fem res.
        IF(:NEW.dataImplementacio IS NOT NULL) THEN
            SELECT EXTRACT(YEAR FROM :NEW.dataImplementacio) INTO v_any FROM DUAL;
        ELSE
            RETURN;
        END IF;

        IF INSERTING THEN
            --Comprovam si la nova accio té l'esat 'Implementada amb el risc mitigat'
            IF :NEW.estatAccio = 'Implementada amb el risc mitigat' THEN
                --Comprovam si la taula té registres. En cas de no tenir-ne, inicialitzaré la taula, en cas contrari, actualitzaré el valor.
                SELECT COUNT(*) INTO v_numAccions FROM DW_AccionsAny WHERE anyo = v_any;
                IF v_numAccions = 0 THEN
                    INSERT INTO DW_AccionsAny (anyo, comptaAccions) VALUES (v_any, 1);
                ELSE
                    UPDATE DW_AccionsAny SET comptaAccions = comptaAccions + 1 WHERE anyo = v_any;
                END IF;
            END IF;
        END IF;
        IF UPDATING THEN
            --Comprovam si l'accio ha canviat d'estat a 'Implementada amb el risc mitigat'
            IF :NEW.estatAccio = 'Implementada amb el risc mitigat' AND :OLD.estatAccio != 'Implementada amb el risc mitigat' THEN
                --Comprovam si la taula té registres. En cas de no tenir-ne, inicialitzaré la taula, en cas contrari, actualitzaré el valor.
                SELECT COUNT(*) INTO v_numAccions FROM DW_AccionsAny WHERE anyo = v_any;
                IF v_numAccions = 0 THEN
                    INSERT INTO DW_AccionsAny (anyo, comptaAccions) VALUES (v_any, 1);
                ELSE
                    UPDATE DW_AccionsAny SET comptaAccions = comptaAccions + 1 WHERE anyo = v_any;
                END IF;
            ELSIF :NEW.estatAccio != 'Implementada amb el risc mitigat' AND :OLD.estatAccio = 'Implementada amb el risc mitigat' THEN
                    UPDATE DW_AccionsAny SET comptaAccions = comptaAccions - 1 WHERE anyo = v_any;
            END IF;
            --Comprovam si han donat l'accio de baixa
            IF :NEW.estat = 'BAIXA' AND :OLD.estatAccio = 'Implementada amb el risc mitigat' THEN
                --Decrementam el comptador
                UPDATE DW_AccionsAny SET comptaAccions = comptaAccions - 1 WHERE anyo = v_any;
            END IF;
        END IF;
        --Cridam al procediment P_ANYMAXACCIONSIMPLEMENTADES per actualitzar la taula DW_MaxAny
        P_ANYMAXACCIONSIMPLEMENTADES;
    END;
/
/***************************************************************************************************************
CU-22: Tenint en compte només el darrer any finalitzat, Top3 d’accions definides tenint en
compte el temps que van estar obertes (des de la seva creació fins que passen a un dles
estats d’implementada). Cal indicar el nom de les 3 accions que van estar més temps
obertes
***************************************************************************************************************/     
--Procediment que comprova el valor de temps obert de la acció que hem modificat i l'insereix a la taula DW_Top3TempsObert.
CREATE OR REPLACE PROCEDURE P_CALCULTOP3 
    IS
    CURSOR cursor_top3 IS   
        SELECT accioId, accioNom, tempsObert FROM DW_AccioTemps 
        ORDER BY (tempsObert) DESC FETCH FIRST 3 ROWS ONLY;  

BEGIN
    --Eliminam els registres anteriors
    DELETE FROM DW_Top3TempsObert;
    --Inserim els nous registres
    FOR reg IN cursor_top3 LOOP
        INSERT INTO DW_Top3TempsObert (accioId, accioNom, tempsObert) VALUES (reg.accioId, reg.accioNom, reg.tempsObert);
    END LOOP;    
END;
/

--Creacio d'un trigger que quan actualitzam el valor d'accio, calcula el temps que ha estat obert (en dies) en el darrer any finalitzat.
CREATE OR REPLACE TRIGGER TRIG_TOP3ACCIONS
    AFTER INSERT OR UPDATE ON ACCIOMITIGADORA
    REFERENCING OLD AS OLD NEW AS NEW
    FOR EACH ROW
    DECLARE
        v_any number;
        v_numregistres number;
    BEGIN
    --Obtenim l'any anterior. Utilitzare la data de creació per determinar a quin any pertany.
    v_any := EXTRACT(YEAR FROM SYSDATE) - 1;
    IF INSERTING THEN
        --Comprovam si la fila inserida té valor diferent de null a dataimplementacio i si ha estat implementada l'any anterior .
        IF :NEW.dataImplementacio IS NOT NULL AND EXTRACT(YEAR FROM :NEW.dataImplementacio) = v_any THEN
            --Afegim les dades a la taula DW_AccioTemps
            INSERT INTO DW_AccioTemps (accioId, accioNom, tempsObert) VALUES (:NEW.accioId, :NEW.nom, :NEW.dataImplementacio - :NEW.dataCreacio);
        END IF;
    END IF;

    IF UPDATING THEN
        --Comprovam si la fila modificada té valor diferent de null a dataimplementacio i si ha estat implementada l'any anterior .
        IF :NEW.dataImplementacio IS NOT NULL AND EXTRACT(YEAR FROM :NEW.dataImplementacio) = v_any THEN
            --Comprovam si ja estava a la taula, si no hi era, l'afegim, si ja hi era, actualitzam el valor.
            Select COUNT (*) INTO v_numregistres FROM DW_AccioTemps WHERE accioId = :NEW.accioId;
            IF v_numregistres = 0 THEN
                INSERT INTO DW_AccioTemps (accioId, accioNom, tempsObert) VALUES (:NEW.accioId, :NEW.nom, :NEW.dataImplementacio - :NEW.dataCreacio);
            ELSE
                UPDATE DW_AccioTemps SET tempsObert = :NEW.dataImplementacio - :NEW.dataCreacio WHERE accioId = :NEW.accioId;
            END IF;      
        END IF;
        --Si el donam de baixa, comprovaré si l'acció esta en el top i l'eliminaré.
        IF :NEW.estat = 'BAIXA' THEN
            DELETE FROM DW_AccioTemps WHERE accioId = :NEW.accioId;
        END IF;
    END IF;
        P_CALCULTOP3;
    END;

/
/***************************************************************************************************************
    CU-23: En el moment d’executar la consulta, nombre de riscos de categoria 1 (en qualsevol estat) (interpret que es importancia 1)
***************************************************************************************************************/ 
--Creacio dun trigger que actualitza el valor de DW_RiscCat1.
CREATE OR REPLACE TRIGGER TRIG_RISCCAT1
    AFTER INSERT OR UPDATE ON RISC
    REFERENCING OLD AS OLD NEW AS NEW
    FOR EACH ROW
    DECLARE
        v_catId RISC.catId%TYPE;
        v_numregistres number;
        v_importancia CATEGORIA.importancia%TYPE;
        v_importanciaAntiga CATEGORIA.importancia%TYPE;
    BEGIN
        v_catId := :NEW.catId;
        --Obtenim la importancia de la categoria del risc
        SELECT (importancia) INTO v_importancia FROM CATEGORIA WHERE CATID = v_catId;
        --Comprovam si és una nova inserció
        IF INSERTING THEN
            --Comprovam si la importancia de la categoria és 1 (Molt important)
            IF v_importancia = 'Molt important' THEN
                --Comprovam si la taula del magatzem té registres per l'any. En cas contrari, inicialitzarem la taula.
                SELECT COUNT(*) INTO v_numregistres FROM DW_RiscCat1;
                IF v_numregistres = 0 THEN
                    INSERT INTO DW_RiscCat1 (nombreRisc) VALUES (1);
                ELSE
                    --En cas de tenir registres, incrementarem el nombre de riscos de categoria 1
                    UPDATE DW_RiscCat1 SET nombreRisc = nombreRisc + 1;
                END IF;
            END IF;
        END IF;
        --Comprovam si estam actualitzant
        IF UPDATING THEN
            --Comprovam si la importancia de la categoria nova és 1 (molt important) i que la antiga no ho fos
            SELECT (importancia) INTO v_importanciaAntiga FROM CATEGORIA WHERE CATID = :OLD.catId;
            IF v_importancia = 'Molt important' AND v_importanciaAntiga != 'Molt important' THEN
                --Comprovam si la taula del magatzem té registres per l'any. En cas contrari, inicialitzarem la taula.
                SELECT COUNT(*) INTO v_numregistres FROM DW_RiscCat1;
                IF v_numregistres = 0 THEN
                    INSERT INTO DW_RiscCat1 (nombreRisc) VALUES (1);
                ELSE
                    --En cas de tenir registres, incrementarem el nombre de riscos de categoria 1
                    UPDATE DW_RiscCat1 SET nombreRisc = nombreRisc + 1;
                END IF;
            END IF;
            --Comprovam si la importancia de la categoria nova no és 1 (molt important) i que la antiga ho fos
            IF v_importancia != 'Molt important' AND v_importanciaAntiga = 'Molt important' THEN
                    UPDATE DW_RiscCat1 SET nombreRisc = nombreRisc - 1;
            END IF;      
            --Si han canviat l'estat a baixa, decrementam el comptador
            IF :NEW.estat = 'BAIXA' AND v_importanciaAntiga = 'Molt important' THEN
                UPDATE DW_RiscCat1 SET nombreRisc = nombreRisc - 1;
            END IF;
        END IF;

    END;
/    
/***************************************************************************************************************
CU-24: Donat un any en concret, percentatge d’accions descartades.
***************************************************************************************************************/ 
--Creacio d'un procediment que fa el calcul del percentatge d'accioons descartades per un any concret.
CREATE OR REPLACE PROCEDURE P_PERCENTATGEACCIONSDESCARTADES(
    PANY IN number)
    IS
        v_totalAccions number;
        v_numAccionsDescartades number;
        v_percentatge FLOAT;
    BEGIN
        --Obtenim el total d'accions
        SELECT nombreAccions INTO v_totalAccions FROM DW_PerAccionnsDescartades WHERE anyo = PANY;
        --Obtenim el total d'accions descartades
        SELECT accionsDescartades INTO v_numAccionsDescartades FROM DW_PerAccionnsDescartades WHERE anyo = PANY;
        --Calculem el percentatge si no hi ha cap acció, el percentatge serà 0
        IF v_totalAccions = 0 THEN
            v_percentatge := 0;
        ELSE
            v_percentatge := (v_numAccionsDescartades/v_totalAccions)*100;
        END IF;
        --Actualitzem la taula
        UPDATE DW_PerAccionnsDescartades SET percentatge = v_percentatge WHERE anyo = PANY;
    END;
/
    --Crecio d'un trigger que cada cop que es modifica una accio, actualitza el nombre d'accions descartades i crida al procediment PRO_PERCENTATGEACCIONSDESCARTADES
CREATE OR REPLACE TRIGGER TRIG_PERCENTATGEACCIONSDESCARTADES
    AFTER INSERT OR UPDATE ON ACCIOMITIGADORA
    REFERENCING OLD AS OLD NEW AS NEW
    FOR EACH ROW
    DECLARE
        v_any number;
        v_numAccions number;
        v_acciosDescartades number;
    BEGIN
        --Obtenim l'any de la data de la nova fila
        SELECT EXTRACT(YEAR FROM :NEW.dataCreacio) INTO v_any FROM DUAL;
        --Inicialitzam el registre si està buit per l'any amb tot a 0
         
        SELECT COUNT(*) INTO v_numAccions FROM DW_PerAccionnsDescartades WHERE anyo = v_any;
        IF v_numAccions = 0 THEN
            INSERT INTO DW_PerAccionnsDescartades (anyo, nombreAccions, accionsDescartades, percentatge) VALUES (v_any, 0, 0, 0);
        END IF;

        IF INSERTING THEN
            --Si estam inserint una nova fila afegim 1 al nombre d'accions
            UPDATE DW_PerAccionnsDescartades SET nombreAccions = nombreAccions + 1 WHERE anyo = v_any;  
            --Comprovam si la acció té l'estat 'Descartada'
            IF :NEW.estatAccio = 'Descartada' THEN
                -- Actualitzam el comptador de accions descartades.
                UPDATE DW_PerAccionnsDescartades SET  accionsDescartades = accionsDescartades + 1 WHERE anyo = v_any;
            END IF;
        END IF;

        IF UPDATING THEN
            --Comprovam si han donat l'accio de baixa i estava descartada.
            IF :NEW.estat = 'BAIXA' AND :OLD.estatAccio = 'Descartada' THEN
                --Decrementam el comptador
                UPDATE DW_PerAccionnsDescartades SET accionsDescartades = accionsDescartades - 1, nombreAccions = nombreAccions -1 WHERE anyo = v_any;
            --Comprovam si l'accio ha canviat d'estat a 'Descartada'
            ELSIF :NEW.estatAccio = 'Descartada' AND :OLD.estatAccio != 'Descartada' THEN
                --Comprovam si el registre està actualitzat
                UPDATE DW_PerAccionnsDescartades SET accionsDescartades = accionsDescartades + 1 WHERE anyo = v_any;
             --Comprovam si li han canviat l'estat de descartada a un altre
            ELSIF :NEW.estatAccio != 'Descartada' AND :OLD.estatAccio = 'Descartada' THEN
                --Decrementam el comptador
                UPDATE DW_PerAccionnsDescartades SET accionsDescartades = accionsDescartades - 1 WHERE anyo = v_any;   
            END IF;
        END IF;
        P_PERCENTATGEACCIONSDESCARTADES(v_any);
    END;
/    
/***************************************************************************************************************
CU-25: Obtenir el departament amb més riscos
***************************************************************************************************************/
--Procediment que comprova el departament amb més riscos i actualitza la taula DW_DepartamentMesRiscos
CREATE OR REPLACE PROCEDURE P_PitjorDepartament
    IS
        v_depId Departament.depId%TYPE;
        v_depNom Departament.depNom%TYPE;
        v_numregistres number;

    BEGIN
    --Obtenim el departament amb el comptador de riscs més alt
    SELECT depId, depNom INTO v_depId, v_depNom FROM DEPARTAMENT ORDER BY totalRiscs DESC FETCH FIRST 1 ROWS ONLY;
    --Comprovam si la taula està incialitzada. Si no hi està, faré el primer insert, si no, actualitzaré el valor.
    SELECT COUNT(*) INTO v_numregistres FROM DW_PitjorDepartament;
    IF v_numregistres = 0 THEN  
        INSERT INTO DW_PitjorDepartament (depId, nom) VALUES (v_depId, v_depNom);
    ELSE
        UPDATE DW_PitjorDepartament SET depId = v_depId, nom = v_depNom;
    END IF;
END;
/

--Trigger per actualitzar el comptador de riscs per un departament.
CREATE OR REPLACE TRIGGER TRIG_pITJORDEPARTAMENT
    AFTER INSERT OR UPDATE ON RISC
    REFERENCING OLD AS OLD NEW AS NEW
    FOR EACH ROW
    DECLARE
        v_depId Departament.depId%TYPE;
        v_depNom Departament.depNom%TYPE;
        v_numregistres number;
    BEGIN
        v_depId := :NEW.depId;

        IF INSERTING THEN
            --Actualitzam el comptador de riscs del departament
            UPDATE DEPARTAMENT SET totalRiscs = totalRiscs + 1 WHERE depId = v_depId;
        END IF;

        IF UPDATING THEN
            --Comprovam si han donat l'accio de baixa
            IF :NEW.estat = 'BAIXA' THEN
                --Decrementam el comptador
                UPDATE DEPARTAMENT SET totalRiscs = totalRiscs - 1 WHERE depId = v_depId;
            END IF;
            --Comprovam si han canviat el departament
            IF v_depId != :OLD.depId THEN
                --Decrementam el comptador de l'antic departament
                UPDATE DEPARTAMENT SET totalRiscs = totalRiscs - 1 WHERE depId = :OLD.depId;
                --Incrementam el comptador del nou departament
                UPDATE DEPARTAMENT SET totalRiscs = totalRiscs + 1 WHERE depId = v_depId;
            END IF;
        END IF;
        P_PitjorDepartament;
    END;
    /
/***************************************************************************************************************
CU-26: Obtenir el percentatge del nombre de riscs per categoria.
***************************************************************************************************************/
--Crecio d'un procediment que calcula el percentatge de riscs per categoria.
CREATE OR REPLACE PROCEDURE P_PercentatgeCat
IS
    v_totalRiscs number;
    v_numRiscsCat number;
    v_percentatge FLOAT;
    v_catId RISC.catId%TYPE;
    v_nomCat CATEGORIA.nom%TYPE;
    v_numregistres number;
BEGIN
    --Obtenim el total de riscs
    SELECT SUM(numRiscs) INTO v_totalRiscs FROM DW_PercentatgeCat;
    --Per cada categoria, calculam el percentatge de riscs
    FOR reg IN (SELECT catId, nom, percentatge, numRiscs FROM DW_PercentatgeCat) LOOP
        v_catId := reg.catId;
        v_nomCat := reg.nom;
        --Obtenim el nombre de riscs per categoria
       
        reg.percentatge := (reg.numRiscs/v_totalRiscs)*100;
        --Actualitzam la taula
        UPDATE DW_PercentatgeCat SET percentatge = reg.percentatge WHERE catId = v_catId;
    END LOOP;
END;

/
CREATE OR REPLACE TRIGGER P_PercentatgeCat
AFTER INSERT OR UPDATE ON RISC
REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE
    v_numregistres number;
    v_numregistres2 number;
BEGIN

    IF INSERTING THEN
        --Comprovam si la taula del magatzem té registres. Si no en té l'actualitzaré.
        SELECT COUNT(*) INTO v_numregistres FROM DW_PercentatgeCat;
        IF (v_numregistres = 0) THEN
            INSERT INTO DW_PercentatgeCat (catId, nom, percentatge, numRiscs) VALUES (:NEW.catId, (SELECT nom FROM CATEGORIA WHERE catId = :NEW.catId), 0, 1);
        ELSE
            --Si ja tenim la categoria introduida, incrementam el nombre de riscs, sinó, insertam la nova categoria.
            SELECT COUNT (*) INTO v_numregistres FROM DW_PercentatgeCat WHERE catId = :NEW.catId;
            IF v_numregistres = 0 THEN
                INSERT INTO DW_PercentatgeCat (catId, nom, percentatge, numRiscs) VALUES (:NEW.catId, (SELECT nom FROM CATEGORIA WHERE catId = :NEW.catId), 0, 1);
            ELSE
                UPDATE DW_PercentatgeCat SET numRiscs = numRiscs + 1 WHERE catId = :NEW.catId;
            END IF;
        END IF;   
    END IF;
    IF UPDATING THEN
        --Si el nou estat es baixa, decrementam el comptador corresponent
        IF :NEW.estat = 'BAIXA' THEN
            UPDATE DW_PercentatgeCat SET numRiscs = numRiscs - 1 WHERE catId = :NEW.catId;
        ELSIF :OLD.catId != :NEW.catId THEN
            --Si s'ha modificat la categoria decremetnaré el comptador de la antiga i incrementaré el de la nova.
            UPDATE DW_PercentatgeCat SET numRiscs = numRiscs - 1 WHERE catId = :OLD.catId;
            UPDATE DW_PercentatgeCat SET numRiscs = numRiscs + 1 WHERE catId = :NEW.catId;    
        END IF;
    END IF;
    P_PercentatgeCat;
END;
/