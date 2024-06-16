/***********************************************************************************
* Creació de les taules de les bases de dades, així com les seves claus primàries, *
* foranes, índexs i seqüències.                                                    *
* IMPORTANT : Aquest script ha de ser executat amb l'usuari MRIERAMAR pwd 12345678   *
***********************************************************************************/



/*******************************************************************************
DROPS de totes les taules i seq�encies i disparadors.
********************************************************************************/

DROP SEQUENCE SEQDEP;
DROP TRIGGER TRIG_DEP;
DROP TABLE DEPARTAMENT CASCADE CONSTRAINTS;

DROP SEQUENCE SEQEMPL;
DROP TRIGGER TRIG_EMPL;
DROP TABLE EMPLEAT CASCADE CONSTRAINTS;

DROP SEQUENCE SEQCAT;
DROP TRIGGER TRIG_CAT;
DROP TABLE CATEGORIA CASCADE CONSTRAINTS;

DROP SEQUENCE SEQINSPEC;
DROP TRIGGER TRIG_INSPEC;
DROP TABLE INSPECCIO CASCADE CONSTRAINTS;

DROP TABLE AUTOAVALUACIO CASCADE CONSTRAINTS;
DROP TABLE AUDITORIAINTERNA CASCADE CONSTRAINTS;
DROP TABLE AUDITORIAEXTERNA CASCADE CONSTRAINTS;

DROP SEQUENCE SEQCAM;
DROP TRIGGER TRIG_CAM;
DROP TABLE CAMPANYA CASCADE CONSTRAINTS;

DROP SEQUENCE SEQRISC;
DROP TRIGGER TRIG_RISC;
DROP TABLE RISC CASCADE CONSTRAINTS;

DROP SEQUENCE SEQACCIO;
DROP TRIGGER TRIG_ACCIO;
DROP TABLE ACCIOMITIGADORA CASCADE CONSTRAINTS;

DROP SEQUENCE SEQMOS;
DROP TRIGGER TRIG_MOS;
DROP TABLE MOSTREIG CASCADE CONSTRAINTS;

DROP SEQUENCE SEQLOG;
DROP TRIGGER TRIG_LOG;
DROP TABLE LOG CASCADE CONSTRAINTS;

/*******************************************************************************
Creacio de la taula DEPARTAMENT, aixi com la sequencia autoincremental de la clau
i un trigger que cada cop que afegeixi una fila li insereixi el valor actual
********************************************************************************/
--Creacio taula departament--

CREATE TABLE DEPARTAMENT (
    depId NUMBER(*,0) NOT NULL,
    depNom VARCHAR(150) NOT NULL UNIQUE,
    nombreRiscsAE NUMBER(*,0) DEFAULT 0,
    totalRiscs NUMBER(*,0) DEFAULT 0,
    estat VARCHAR2(10) DEFAULT 'ALTA' CHECK (estat IN ('ALTA', 'BAIXA'))
)
LOGGING
TABLESPACE Data_RISC_CONTROL
PCTFREE 10 
INITRANS 1 
STORAGE 
( 
  INITIAL 65536 
  NEXT 1048576 
  MINEXTENTS 1 
  MAXEXTENTS UNLIMITED 
  BUFFER_POOL DEFAULT 
) 
NOPARALLEL;

--Creacio index per a la clau principal--

CREATE UNIQUE INDEX INDEXDEP ON DEPARTAMENT (depId ASC) 
LOGGING 
TABLESPACE Data_RISC_CONTROL 
PCTFREE 10 
INITRANS 2 
STORAGE 
( 
  INITIAL 65536 
  NEXT 1048576 
  MINEXTENTS 1 
  MAXEXTENTS UNLIMITED 
  BUFFER_POOL DEFAULT 
) 
NOPARALLEL;

--Creacio clau primaria--

ALTER TABLE DEPARTAMENT
ADD CONSTRAINT DEPARTAMENT_PK PRIMARY KEY 
(
  depId 
)
USING INDEX INDEXDEP
ENABLE;

--Creacio sequencia--

CREATE SEQUENCE SEQDEP
START WITH 1
INCREMENT BY 1;

--Creacio disparador inserci� de id--
CREATE TRIGGER TRIG_DEP
BEFORE INSERT ON DEPARTAMENT
FOR EACH ROW
BEGIN
SELECT SEQDEP.NEXTVAL INTO :NEW.depId FROM DUAL;
END;

/

/*******************************************************************************
Creacio de la taula EMPLEAT, aixi com la sequencia autoincremental de la clau
i un trigger que cada cop que afegeixi una fila li insereixi el valor actual
********************************************************************************/
--Creacio taula empleat--

CREATE TABLE EMPLEAT (
    empleatId NUMBER(*,0) NOT NULL,
    depId NUMBER(*,0) NOT NULL,
    nom VARCHAR(150) NOT NULL,
    llinatges VARCHAR(150) NOT NULL,
    dni VARCHAR(50) NOT NULL UNIQUE,
    telefon NUMBER NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,
    comptadorAccions NUMBER(*,0) DEFAULT 0,
    estat VARCHAR2(10) DEFAULT 'ALTA' CHECK (estat IN ('ALTA', 'BAIXA'))
)
LOGGING
TABLESPACE Data_RISC_CONTROL
PCTFREE 10 
INITRANS 1 
STORAGE 
( 
  INITIAL 65536 
  NEXT 1048576 
  MINEXTENTS 1 
  MAXEXTENTS UNLIMITED 
  BUFFER_POOL DEFAULT 
) 
NOPARALLEL;

--Creacio index per a la clau principal--

CREATE UNIQUE INDEX INDEXEMPLEAT ON EMPLEAT (empleatId ASC) 
LOGGING 
TABLESPACE Data_RISC_CONTROL 
PCTFREE 10 
INITRANS 2 
STORAGE 
( 
  INITIAL 65536 
  NEXT 1048576 
  MINEXTENTS 1 
  MAXEXTENTS UNLIMITED 
  BUFFER_POOL DEFAULT 
) 
NOPARALLEL;

--Creacio clau primaria--

ALTER TABLE EMPLEAT
ADD CONSTRAINT EMPLEAT_PK PRIMARY KEY 
(
  empleatId 
)
USING INDEX INDEXEMPLEAT
ENABLE;

-- Creació de la clau forana --

ALTER TABLE EMPLEAT
ADD CONSTRAINT EMPLEAT_FK1 FOREIGN KEY
(
  depId 
)
REFERENCES DEPARTAMENT
(
  depId 
)
ENABLE;

--Creacio sequencia--

CREATE SEQUENCE SEQEMPL
START WITH 1
INCREMENT BY 1;

--Creacio disparador inserció de id--
CREATE TRIGGER TRIG_EMPL
BEFORE INSERT ON EMPLEAT
FOR EACH ROW
BEGIN
SELECT SEQEMPL.NEXTVAL INTO :NEW.empleatId FROM DUAL;
END;

/

/*******************************************************************************
Creacio de la taula CATEGORIA, aixi com la sequencia autoincremental de la clau
i un trigger que cada cop que afegeixi una fila li insereixi el valor actual
********************************************************************************/
--Creacio taula categoria--

CREATE TABLE CATEGORIA (
    catId NUMBER(*,0) NOT NULL,
    empleatId NUMBER(*,0) NOT NULL,
    nom VARCHAR(150) NOT NULL UNIQUE,
    dataCreacio DATE NOT NULL,
    importancia VARCHAR(50) CHECK (importancia IN ('Molt important', 'Important', 'Poc important')),
    estat VARCHAR2(10) DEFAULT 'ALTA' CHECK (estat IN ('ALTA', 'BAIXA'))
)
LOGGING
TABLESPACE Data_RISC_CONTROL
PCTFREE 10 
INITRANS 1 
STORAGE 
( 
  INITIAL 65536 
  NEXT 1048576 
  MINEXTENTS 1 
  MAXEXTENTS UNLIMITED 
  BUFFER_POOL DEFAULT 
) 
NOPARALLEL;

--Creacio index per a la clau principal--

CREATE UNIQUE INDEX INDEXCATEGORIA ON CATEGORIA (catId ASC) 
LOGGING 
TABLESPACE Data_RISC_CONTROL 
PCTFREE 10 
INITRANS 2 
STORAGE 
( 
  INITIAL 65536 
  NEXT 1048576 
  MINEXTENTS 1 
  MAXEXTENTS UNLIMITED 
  BUFFER_POOL DEFAULT 
) 
NOPARALLEL;

--Creacio clau primaria--

ALTER TABLE CATEGORIA
ADD CONSTRAINT CATEGORIA_PK PRIMARY KEY 
(
  catId 
)
USING INDEX INDEXCATEGORIA
ENABLE;

-- Creació de la clau forana --

ALTER TABLE CATEGORIA
ADD CONSTRAINT CATEGORIA_FK1 FOREIGN KEY
(
  empleatId 
)
REFERENCES EMPLEAT
(
  empleatId 
)
ENABLE;

--Creacio sequencia--

CREATE SEQUENCE SEQCAT
START WITH 1
INCREMENT BY 1;

--Creacio disparador inserció de id--
CREATE TRIGGER TRIG_CAT
BEFORE INSERT ON CATEGORIA
FOR EACH ROW
BEGIN
SELECT SEQCAT.NEXTVAL INTO :NEW.catId FROM DUAL;
END;

/

/*******************************************************************************
Creacio de la taula INSPECCIO, aixi com la sequencia autoincremental de la clau
i un trigger que cada cop que afegeixi una fila li insereixi el valor actual.
********************************************************************************/
--Creacio taula inspeccio--

CREATE TABLE INSPECCIO (
    inspeccioId NUMBER(*,0) NOT NULL,
    dataInici DATE NOT NULL,
    dataFi DATE NOT NULL,
    resultat VARCHAR(150),
    estat VARCHAR2(10) DEFAULT 'ALTA' CHECK (estat IN ('ALTA', 'BAIXA'))
)
LOGGING
TABLESPACE Data_RISC_CONTROL
PCTFREE 10 
INITRANS 1 
STORAGE 
( 
  INITIAL 65536 
  NEXT 1048576 
  MINEXTENTS 1 
  MAXEXTENTS UNLIMITED 
  BUFFER_POOL DEFAULT 
) 
NOPARALLEL;

--Creacio index per a la clau principal--

CREATE UNIQUE INDEX INDEXINSPECCIO ON INSPECCIO (inspeccioId ASC) 
LOGGING 
TABLESPACE Data_RISC_CONTROL 
PCTFREE 10 
INITRANS 2 
STORAGE 
( 
  INITIAL 65536 
  NEXT 1048576 
  MINEXTENTS 1 
  MAXEXTENTS UNLIMITED 
  BUFFER_POOL DEFAULT 
) 
NOPARALLEL;

--Creacio clau primaria--

ALTER TABLE INSPECCIO
ADD CONSTRAINT INSPECCIO_PK PRIMARY KEY 
(
  inspeccioId 
)
USING INDEX INDEXINSPECCIO
ENABLE;

--Creacio sequencia--

CREATE SEQUENCE SEQINSPEC
START WITH 1
INCREMENT BY 1;

--Creacio disparador inserció de id--
CREATE TRIGGER TRIG_INSPEC
BEFORE INSERT ON INSPECCIO
FOR EACH ROW
BEGIN
SELECT SEQINSPEC.NEXTVAL INTO :NEW.inspeccioId FROM DUAL;
END;

/

/*******************************************************************************
Creacio de la taula AUTOAVALUACIO.
Aquesta taula �s una subclasse de la taula inspeccio, per tant referenciara el
contingut de l'altre taula mitjan�ant la clau primaria.
********************************************************************************/

--Creacio taula inspeccio--

CREATE TABLE AUTOAVALUACIO (
    inspeccioId NUMBER(*,0) NOT NULL,
    descripcio VARCHAR(150) NOT NULL,
    nombreCyber NUMBER(*,0) DEFAULT 0,
    estat VARCHAR2(10) DEFAULT 'ALTA' CHECK (estat IN ('ALTA', 'BAIXA'))
)
LOGGING
TABLESPACE Data_RISC_CONTROL
PCTFREE 10 
INITRANS 1 
STORAGE 
( 
  INITIAL 65536 
  NEXT 1048576 
  MINEXTENTS 1 
  MAXEXTENTS UNLIMITED 
  BUFFER_POOL DEFAULT 
) 
NOPARALLEL;

--Creacio index per a la clau principal--

CREATE UNIQUE INDEX INDEXAUTO ON AUTOAVALUACIO (inspeccioId ASC) 
LOGGING 
TABLESPACE Data_RISC_CONTROL 
PCTFREE 10 
INITRANS 2 
STORAGE 
( 
  INITIAL 65536 
  NEXT 1048576 
  MINEXTENTS 1 
  MAXEXTENTS UNLIMITED 
  BUFFER_POOL DEFAULT 
) 
NOPARALLEL;

--Creacio clau primaria--

ALTER TABLE AUTOAVALUACIO
ADD CONSTRAINT AUTOAVALUACIO_PK PRIMARY KEY 
(
  inspeccioId 
)
USING INDEX INDEXAUTO
ENABLE;

--Creacio clau forana --

ALTER TABLE AUTOAVALUACIO
ADD CONSTRAINT AUTOAVALUACIO_FK1 FOREIGN KEY
(
  inspeccioId 
)
REFERENCES INSPECCIO
(
  inspeccioId 
)
ENABLE;

/

/*******************************************************************************
Creacio de la taula CAMPANYA, aixi com la sequencia autoincremental de la clau
i un trigger que cada cop que afegeixi una fila li insereixi el valor actual.
Tindra les claus foranes inspecioId, per fer referencia a l'inspeccio a la que esta
lligada, empleat id que es el lider de la campanya.
********************************************************************************/

-- Creacio de la taula--

CREATE TABLE CAMPANYA (
    campanyaId  NUMBER(*,0) NOT NULL,
    inspeccioId  NUMBER(*,0) NOT NULL,
    empleatId  NUMBER(*,0) NOT NULL,
    dataInici DATE NOT NULL,
    dataFi DATE NOT NULL,
    resultats VARCHAR(150) NOT NULL,
    estat VARCHAR2(10) DEFAULT 'ALTA' CHECK (estat IN ('ALTA', 'BAIXA'))
)
LOGGING
TABLESPACE Data_RISC_CONTROL
PCTFREE 10 
INITRANS 1 
STORAGE 
( 
  INITIAL 65536 
  NEXT 1048576 
  MINEXTENTS 1 
  MAXEXTENTS UNLIMITED 
  BUFFER_POOL DEFAULT 
) 
NOPARALLEL;

--Creacio index per a la clau principal--

CREATE UNIQUE INDEX INDEXCAMPANYA ON CAMPANYA (campanyaId ASC) 
LOGGING 
TABLESPACE Data_RISC_CONTROL 
PCTFREE 10 
INITRANS 2 
STORAGE 
( 
  INITIAL 65536 
  NEXT 1048576 
  MINEXTENTS 1 
  MAXEXTENTS UNLIMITED 
  BUFFER_POOL DEFAULT 
) 
NOPARALLEL;

--Creacio clau primaria--

ALTER TABLE CAMPANYA
ADD CONSTRAINT CAMPANYA_PK PRIMARY KEY 
(
  campanyaId 
)
USING INDEX INDEXCAMPANYA
ENABLE;

--Creacio claus secundaries--

ALTER TABLE CAMPANYA
ADD CONSTRAINT CAMPANYA_FK1 FOREIGN KEY
(
  inspeccioId
)
REFERENCES INSPECCIO
(
  inspeccioId 
)
ENABLE;

ALTER TABLE CAMPANYA
ADD CONSTRAINT CAMPANYA_FK2 FOREIGN KEY
(
  empleatId
)
REFERENCES EMPLEAT
(
  empleatId 
)
ENABLE;

--Creacio sequencia--

CREATE SEQUENCE SEQCAM
START WITH 1
INCREMENT BY 1;

--Creacio disparador inserció de id--

CREATE TRIGGER TRIG_CAM
BEFORE INSERT ON CAMPANYA
FOR EACH ROW
BEGIN
SELECT SEQCAM.NEXTVAL INTO :NEW.campanyaId FROM DUAL;
END;

/

/*******************************************************************************
Creacio de la taula AuditoriaInterna, i el seu �ndex.
Aquesta taula �s una subclasse de INSPECCIO
********************************************************************************/
--Creacio taula AuditoriaInterna--

CREATE TABLE AUDITORIAINTERNA (
    inspeccioId NUMBER(*,0) NOT NULL,
    objectiu VARCHAR(150) NOT NULL,
    estat VARCHAR2(10) DEFAULT 'ALTA' CHECK (estat IN ('ALTA', 'BAIXA'))
)
LOGGING
TABLESPACE Data_RISC_CONTROL
PCTFREE 10 
INITRANS 1 
STORAGE 
( 
  INITIAL 65536 
  NEXT 1048576 
  MINEXTENTS 1 
  MAXEXTENTS UNLIMITED 
  BUFFER_POOL DEFAULT 
) 
NOPARALLEL;

--Creacio index per a la clau principal--

CREATE UNIQUE INDEX INDEXAINTERNA ON AUDITORIAINTERNA (inspeccioId ASC) 
LOGGING 
TABLESPACE Data_RISC_CONTROL 
PCTFREE 10 
INITRANS 2 
STORAGE 
( 
  INITIAL 65536 
  NEXT 1048576 
  MINEXTENTS 1 
  MAXEXTENTS UNLIMITED 
  BUFFER_POOL DEFAULT 
) 
NOPARALLEL;

--Creacio clau primaria--

ALTER TABLE AUDITORIAINTERNA
ADD CONSTRAINT AUDITORIAINTERNA_PK PRIMARY KEY 
(
  inspeccioId 
)
USING INDEX INDEXAINTERNA
ENABLE;

--Creacio clau forana --

ALTER TABLE AUDITORIAINTERNA
ADD CONSTRAINT AUDITORIAINTERNA_FK1 FOREIGN KEY
(
  inspeccioId 
)
REFERENCES INSPECCIO
(
  inspeccioId 
)
ENABLE;

/

/*******************************************************************************
Creacio de la taula AUDITORIAEXTERNA i el seu index
Aquesta taula �s una subclasse de INSPECCIO
********************************************************************************/
--Creacio taula AUDITORIAEXTERNA--

CREATE TABLE AUDITORIAEXTERNA (
    inspeccioId NUMBER(*,0) NOT NULL,
    empresa VARCHAR(150) NOT NULL,
    cost FLOAT(126),
    estat VARCHAR2(10) DEFAULT 'ALTA' CHECK (estat IN ('ALTA', 'BAIXA'))
)
LOGGING
TABLESPACE Data_RISC_CONTROL
PCTFREE 10 
INITRANS 1 
STORAGE 
( 
  INITIAL 65536 
  NEXT 1048576 
  MINEXTENTS 1 
  MAXEXTENTS UNLIMITED 
  BUFFER_POOL DEFAULT 
) 
NOPARALLEL;

--Creacio index per a la clau principal--

CREATE UNIQUE INDEX INDEXAEXTERNA ON AUDITORIAEXTERNA (inspeccioId ASC) 
LOGGING 
TABLESPACE Data_RISC_CONTROL 
PCTFREE 10 
INITRANS 2 
STORAGE 
( 
  INITIAL 65536 
  NEXT 1048576 
  MINEXTENTS 1 
  MAXEXTENTS UNLIMITED 
  BUFFER_POOL DEFAULT 
) 
NOPARALLEL;

--Creacio clau primaria--

ALTER TABLE AUDITORIAEXTERNA
ADD CONSTRAINT AUDITORIAEXTERNA_PK PRIMARY KEY 
(
  inspeccioId 
)
USING INDEX INDEXAEXTERNA
ENABLE;

--Creacio clau forana --

ALTER TABLE AUDITORIAEXTERNA
ADD CONSTRAINT AUDITORIAEXTERNA_FK1 FOREIGN KEY
(
  inspeccioId 
)
REFERENCES INSPECCIO
(
  inspeccioId 
)
ENABLE;

/

/********************************************************************************
Creacio de la taula RISC, aixi com la sequencia autoincremental de la clau
i un trigger que cada cop que afegeixi una fila li insereixi el valor actual.
Tindra les claus foranes inspecioId, per fer referencia a l'inspeccio a la que esta
lligada, catId que es la categoria del risc.

********************************************************************************/

-- Creacio taula risc --
CREATE TABLE RISC (
    riscId NUMBER (*,0) NOT NULL,
    inspeccioId NUMBER (*,0) NOT NULL,
    catId NUMBER (*,0) NOT NULL,
    depId NUMBER (*,0) NOT NULL,
    empleatId NUMBER (*,0) NOT NULL,
    criticitat VARCHAR (50) CHECK (criticitat IN ('Risc critic', 'Risc moderat', 'Risc baix')),
    impacte VARCHAR (50) CHECK (impacte IN ('Impacte catastrofic', 'Impacte critic', 'Impacte alt', 'Impacte moderat', 'Impacte baix', 'Impacte molt baix')),
    estatRisc VARCHAR(100) CHECK (estatRisc IN ('Corregit','Mitigat','Obert')),
    dataCreacio DATE NOT NULL,
    descripcio VARCHAR(150) NOT NULL,
    estat VARCHAR2(10) DEFAULT 'ALTA' CHECK (estat IN ('ALTA', 'BAIXA'))
)
LOGGING
TABLESPACE Data_RISC_CONTROL
PCTFREE 10 
INITRANS 1 
STORAGE 
( 
  INITIAL 65536 
  NEXT 1048576 
  MINEXTENTS 1 
  MAXEXTENTS UNLIMITED 
  BUFFER_POOL DEFAULT 
) 
NOPARALLEL;

-- Creacio de l'index

CREATE UNIQUE INDEX INDEXRISC ON RISC (riscId ASC) 
LOGGING 
TABLESPACE Data_RISC_CONTROL 
PCTFREE 10 
INITRANS 2 
STORAGE 
( 
  INITIAL 65536 
  NEXT 1048576 
  MINEXTENTS 1 
  MAXEXTENTS UNLIMITED 
  BUFFER_POOL DEFAULT 
) 
NOPARALLEL;

--Creacio clau primaria--

ALTER TABLE RISC
ADD CONSTRAINT RISC_PK PRIMARY KEY 
(
  riscId 
)
USING INDEX INDEXRISC
ENABLE;

--Creacio claus secundaries--

ALTER TABLE RISC
ADD CONSTRAINT RISC_FK1 FOREIGN KEY
(
  inspeccioId
)
REFERENCES INSPECCIO
(
  inspeccioId 
)
ENABLE;

ALTER TABLE RISC
ADD CONSTRAINT RISC_FK2 FOREIGN KEY
(
  catId
)
REFERENCES CATEGORIA
(
  catId 
)
ENABLE;

ALTER TABLE RISC
ADD CONSTRAINT RISC_FK3 FOREIGN KEY
(
  depId
)
REFERENCES DEPARTAMENT
(
  depId
)
ENABLE;

ALTER TABLE RISC
ADD CONSTRAINT RISC_FK4 FOREIGN KEY
(
  empleatId
)
REFERENCES EMPLEAT
(
  empleatId
)
ENABLE;
--Creacio sequencia--

CREATE SEQUENCE SEQRISC
START WITH 1
INCREMENT BY 1;

--Creacio disparador inserció de id--

CREATE TRIGGER TRIG_RISC
BEFORE INSERT ON RISC
FOR EACH ROW
BEGIN
SELECT SEQRISC.NEXTVAL INTO :NEW.riscId FROM DUAL;
END;

/

/********************************************************************************
Creacio de la taula ACCIOMITIGADORA, aixi com la sequencia autoincremental de la clau
i un trigger que cada cop que afegeixi una fila li insereixi el valor actual.
********************************************************************************/
-- Creacio taula --

CREATE TABLE ACCIOMITIGADORA (
    accioId NUMBER (*,0) NOT NULL,
    riscId NUMBER (*,0) NOT NULL,
    empleatId NUMBER (*,0) NOT NULL,
    estatAccio VARCHAR (100) CHECK (estatAccio IN ('Definida', 'En curs', 'Implementada amb el risc corregit', 'Implementada amb el risc mitigat', 'Descartada')) NOT NULL,
    nom VARCHAR(100) NOT NULL,
    descripcio VARCHAR(150) NOT NULL,
    dataCreacio DATE NOT NULL,
    dataEstimada DATE NOT NULL,
    dataImplementacio DATE DEFAULT NULL,
    estat VARCHAR2(10) DEFAULT 'ALTA' CHECK (estat IN ('ALTA', 'BAIXA'))
)
LOGGING
TABLESPACE Data_RISC_CONTROL
PCTFREE 10 
INITRANS 1 
STORAGE 
( 
  INITIAL 65536 
  NEXT 1048576 
  MINEXTENTS 1 
  MAXEXTENTS UNLIMITED 
  BUFFER_POOL DEFAULT 
) 
NOPARALLEL;

-- Creacio de l'index

CREATE UNIQUE INDEX INDEXACCIO ON ACCIOMITIGADORA (accioId ASC) 
LOGGING 
TABLESPACE Data_RISC_CONTROL 
PCTFREE 10 
INITRANS 2 
STORAGE 
( 
  INITIAL 65536 
  NEXT 1048576 
  MINEXTENTS 1 
  MAXEXTENTS UNLIMITED 
  BUFFER_POOL DEFAULT 
) 
NOPARALLEL;

--Creacio clau primaria--

ALTER TABLE ACCIOMITIGADORA
ADD CONSTRAINT ACCIOMITIGADORA_PK PRIMARY KEY 
(
  accioId 
)
USING INDEX INDEXACCIO
ENABLE;

--Creacio de les claus foranes--
ALTER TABLE ACCIOMITIGADORA
ADD CONSTRAINT ACCIOMITIGADORA_FK1 FOREIGN KEY
(
  empleatId
)
REFERENCES EMPLEAT
(
  empleatId 
)
ENABLE;

ALTER TABLE ACCIOMITIGADORA
ADD CONSTRAINT ACCIOMITIGADORA_FK2 FOREIGN KEY
(
  riscId
)
REFERENCES RISC
(
  riscId 
)
ENABLE;
--Creacio sequencia--

CREATE SEQUENCE SEQACCIO
START WITH 1
INCREMENT BY 1;

--Creacio disparador inserció de id--

CREATE TRIGGER TRIG_ACCIO
BEFORE INSERT ON ACCIOMITIGADORA
FOR EACH ROW
BEGIN
SELECT SEQACCIO.NEXTVAL INTO :NEW.accioId FROM DUAL;
END;

/

/********************************************************************************
Creacio de la taula MOSTREIGC, aixi com la sequencia autoincremental de la clau
i un trigger que cada cop que afegeixi una fila li insereixi el valor actual.
Tindra les claus foranes inspecioId, per fer referencia a l'inspeccio a la que esta
lligada.
********************************************************************************/

--creacio de la taula --

CREATE TABLE MOSTREIG(
    mostreigId NUMBER (*,0) NOT NULL,
    inspeccioId NUMBER (*,0) NOT NULL,
    objectiu VARCHAR (150) NOT NULL,
    resultat VARCHAR (150) NOT NULL,
    dataMostreig DATE NOT NULL,
    estat VARCHAR2(10) DEFAULT 'ALTA' CHECK (estat IN ('ALTA', 'BAIXA'))
)
LOGGING
TABLESPACE Data_RISC_CONTROL
PCTFREE 10 
INITRANS 1 
STORAGE 
( 
  INITIAL 65536 
  NEXT 1048576 
  MINEXTENTS 1 
  MAXEXTENTS UNLIMITED 
  BUFFER_POOL DEFAULT 
) 
NOPARALLEL;

-- Creacio de l'index

CREATE UNIQUE INDEX INDEXMOSTREIG ON MOSTREIG (mostreigId ASC) 
LOGGING 
TABLESPACE Data_RISC_CONTROL 
PCTFREE 10 
INITRANS 2 
STORAGE 
( 
  INITIAL 65536 
  NEXT 1048576 
  MINEXTENTS 1 
  MAXEXTENTS UNLIMITED 
  BUFFER_POOL DEFAULT 
) 
NOPARALLEL;

--Creacio clau primaria--

ALTER TABLE MOSTREIG
ADD CONSTRAINT MOSTREIG_PK PRIMARY KEY 
(
  mostreigId 
)
USING INDEX INDEXMOSTREIG
ENABLE;

--Creacio claus secundaries--

ALTER TABLE MOSTREIG
ADD CONSTRAINT MOSTREIG_FK1 FOREIGN KEY
(
  inspeccioId
)
REFERENCES INSPECCIO
(
  inspeccioId 
)
ENABLE;

--Creacio sequencia--

CREATE SEQUENCE SEQMOS
START WITH 1
INCREMENT BY 1;

--Creacio disparador inserció de id--

CREATE TRIGGER TRIG_MOS
BEFORE INSERT ON MOSTREIG
FOR EACH ROW
BEGIN
SELECT SEQMOS.NEXTVAL INTO :NEW.mostreigId FROM DUAL;
END;

/

-- /********************************************************************************
-- Creacio de la taula EMPLEATACCIORISC, es tracta d'una taula que emmagatzema
-- la relaci� entre empleat accio i risc.
-- ********************************************************************************/
-- CREATE TABLE EMPLEATACCIORISC (
--     riscId NUMBER (*,0) NOT NULL,
--     accioId NUMBER (*,0) NOT NULL,
--     empleatId NUMBER (*,0) NOT NULL,
--     estat VARCHAR2(10) DEFAULT 'ALTA' CHECK (estat IN ('ALTA', 'BAIXA'))
-- )
-- LOGGING
-- TABLESPACE Data_RISC_CONTROL
-- PCTFREE 10 
-- INITRANS 1 
-- STORAGE 
-- ( 
--   INITIAL 65536 
--   NEXT 1048576 
--   MINEXTENTS 1 
--   MAXEXTENTS UNLIMITED 
--   BUFFER_POOL DEFAULT 
-- ) 
-- NOPARALLEL;

-- -- Creacio de l'index

-- CREATE UNIQUE INDEX INDEXEMPLEATACCIORISC ON EMPLEATACCIORISC (riscId ASC, accioId ASC) 
-- LOGGING 
-- TABLESPACE Data_RISC_CONTROL 
-- PCTFREE 10 
-- INITRANS 2 
-- STORAGE 
-- ( 
--   INITIAL 65536 
--   NEXT 1048576 
--   MINEXTENTS 1 
--   MAXEXTENTS UNLIMITED 
--   BUFFER_POOL DEFAULT 
-- ) 
-- NOPARALLEL;

-- --Creacio clau primaria--

-- ALTER TABLE EMPLEATACCIORISC
-- ADD CONSTRAINT EMPLEATACCIORISC_PK PRIMARY KEY 
-- (
--   riscId, 
--   accioId 
-- )
-- USING INDEX INDEXEMPLEATACCIORISC
-- ENABLE;

-- --Creacio claus secundaries--

-- ALTER TABLE EMPLEATACCIORISC
-- ADD CONSTRAINT DEMPLEATACCIORISC_FK1 FOREIGN KEY
-- (
--   empleatId
-- )
-- REFERENCES EMPLEAT
-- (
--   empleatId 
-- )
-- ENABLE;

-- ALTER TABLE EMPLEATACCIORISC
-- ADD CONSTRAINT EMPLEATACCIORISC_FK2 FOREIGN KEY
-- (
--   riscId
-- )
-- REFERENCES RISC
-- (
--   riscId 
-- )
-- ENABLE;
-- ALTER TABLE EMPLEATACCIORISC
-- ADD CONSTRAINT EMPLEATACCIORISC_FK3 FOREIGN KEY
-- (
--   accioId
-- )
-- REFERENCES ACCIOMITIGADORA
-- (
--   accioId 
-- )
-- ENABLE;

-- /

-- /********************************************************************************
-- Creacio de la taula DEPARTAMENTINSPECCIO, que emmagatzema la relacio entre els departament
-- i les inspeccionss
-- ********************************************************************************/
-- CREATE TABLE DEPARTAMENTINSPECCIO (
--     depId NUMBER (*,0) NOT NULL,
--     inspeccioId NUMBER (*,0) NOT NULL,
--     estat VARCHAR2(10) DEFAULT 'ALTA' CHECK (estat IN ('ALTA', 'BAIXA'))
-- )
-- LOGGING
-- TABLESPACE Data_RISC_CONTROL
-- PCTFREE 10 
-- INITRANS 1 
-- STORAGE 
-- ( 
--   INITIAL 65536 
--   NEXT 1048576 
--   MINEXTENTS 1 
--   MAXEXTENTS UNLIMITED 
--   BUFFER_POOL DEFAULT 
-- ) 
-- NOPARALLEL;

-- -- Creacio de l'index

-- CREATE UNIQUE INDEX INDEXDEPARTAMENTINSPECCIO ON DEPARTAMENTINSPECCIO (depId ASC, inspeccioId ASC) 
-- LOGGING 
-- TABLESPACE Data_RISC_CONTROL 
-- PCTFREE 10 
-- INITRANS 2 
-- STORAGE 
-- ( 
--   INITIAL 65536 
--   NEXT 1048576 
--   MINEXTENTS 1 
--   MAXEXTENTS UNLIMITED 
--   BUFFER_POOL DEFAULT 
-- ) 
-- NOPARALLEL;

-- --Creacio clau primaria--

-- ALTER TABLE DEPARTAMENTINSPECCIO
-- ADD CONSTRAINT DEPARTAMENTINSPECCIO_PK PRIMARY KEY 
-- (
--   depId, 
--   inspeccioId
-- )
-- USING INDEX INDEXDEPARTAMENTINSPECCIO
-- ENABLE;

-- --Creacio claus secundaries--

-- ALTER TABLE DEPARTAMENTINSPECCIO
-- ADD CONSTRAINT DEPARTAMENTINSPECCIO_FK1 FOREIGN KEY
-- (
--   depId
-- )
-- REFERENCES DEPARTAMENT
-- (
--   depId 
-- )
-- ENABLE;

-- ALTER TABLE DEPARTAMENTINSPECCIO
-- ADD CONSTRAINT DEPARTAMENTINSPECCIO_FK2 FOREIGN KEY
-- (
--   inspeccioId
-- )
-- REFERENCES INSPECCIO
-- (
--   inspeccioId 
-- )
-- ENABLE;


-- /


/********************************************************************************
Creacio de la taula LOG,aixi com la sequencia autoincremental de la clau
i un trigger que cada cop que afegeixi una fila li insereixi el valor actual.
********************************************************************************/

CREATE TABLE LOG (
    logId NUMBER(*,0) NOT NULL,
    nomPro VARCHAR(50) NOT NULL,
    entrada VARCHAR(150),
    sortida VARCHAR(150) NOT NULL,
    dataRegistre DATE NOT NULL
)
LOGGING
TABLESPACE Data_RISC_CONTROL
PCTFREE 10 
INITRANS 1 
STORAGE 
( 
  INITIAL 65536 
  NEXT 1048576 
  MINEXTENTS 1 
  MAXEXTENTS UNLIMITED 
  BUFFER_POOL DEFAULT 
) 
NOPARALLEL;

CREATE UNIQUE INDEX INDEXLOG ON LOG (logId ASC) 
LOGGING 
TABLESPACE Data_RISC_CONTROL 
PCTFREE 10 
INITRANS 2 
STORAGE 
( 
  INITIAL 65536 
  NEXT 1048576 
  MINEXTENTS 1 
  MAXEXTENTS UNLIMITED 
  BUFFER_POOL DEFAULT 
) 
NOPARALLEL;

--Creacio clau primaria--

ALTER TABLE LOG
ADD CONSTRAINT LOG_PK PRIMARY KEY 
(
  logId
)
USING INDEX INDEXLOG
ENABLE;
--Creacio sequencia--

CREATE SEQUENCE SEQLOG
START WITH 1
INCREMENT BY 1;

--Creacio disparador inserció de id--

CREATE TRIGGER TRIG_LOG
BEFORE INSERT ON LOG
FOR EACH ROW
BEGIN
SELECT SEQLOG.NEXTVAL INTO :NEW.logId FROM DUAL;
END;