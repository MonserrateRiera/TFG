/************************************************************************************************************************
* Creació de les taules del Data Warehouse, amb les seves claus primàries i foranes si escau.                           *
* IMPORTANT : Aquest script ha de ser executat amb l'usuari MRIERAMAR pwd 12345678                                        *
*************************************************************************************************************************/

/************************************************************************************************************************
* Creació de les taules del Data Warehouse
*************************************************************************************************************************/
DROP TABLE DW_PERCRISC CASCADE CONSTRAINTS;
DROP TABLE DW_Impacte1 CASCADE CONSTRAINTS;
DROP TABLE DW_RiscsOberts CASCADE CONSTRAINTS;
DROP TABLE DW_DepartamentMaxAE CASCADE CONSTRAINTS;
DROP TABLE DW_AccionsCurs CASCADE CONSTRAINTS;
DROP TABLE DW_DiferenciaInternaExterna CASCADE CONSTRAINTS;
DROP TABLE DW_EmpleatMesAccions CASCADE CONSTRAINTS;
DROP TABLE DW_MitjaMostrejos CASCADE CONSTRAINTS;
DROP TABLE DW_MosrejosAny CASCADE CONSTRAINTS;
DROP TABLE DW_CiberAutoAv CASCADE CONSTRAINTS;
DROP TABLE DW_costMitja CASCADE CONSTRAINTS;
DROP TABLE DW_AccionsAny CASCADE CONSTRAINTS;
DROP TABLE DW_MaxAny CASCADE CONSTRAINTS;
DROP TABLE DW_Top3TempsObert CASCADE CONSTRAINTS;
DROP TABLE DW_AccioTemps CASCADE CONSTRAINTS;
DROP TABLE DW_RiscCat1 CASCADE CONSTRAINTS;
DROP TABLE DW_PerAccionnsDescartades CASCADE CONSTRAINTS;
DROP TABLE DW_PitjorDepartament CASCADE CONSTRAINTS;
DROP TABLE DW_PercentatgeCat CASCADE CONSTRAINTS;
/************************************************************************************************************************
* DW_PERCRISC
*************************************************************************************************************************/
CREATE TABLE DW_PERCRISC(
    totalRisc NUMBER(*,0) NOT NULL,
    numRiscos NUMBER(*,0) NOT NULL,
    percentatge FLOAT NOT NULL
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

/************************************************************************************************************************
* DW_Impacte1
*************************************************************************************************************************/
CREATE TABLE DW_Impacte1(
    anyo NUMBER(4) NOT NULL,
    nombreImpacte1 NUMBER (*,0) NOT NULL
)LOGGING
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

CREATE UNIQUE INDEX indexImpacte1 ON DW_Impacte1 (anyo ASC) 
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

ALTER TABLE DW_Impacte1 ADD CONSTRAINT PK_Impacte1 PRIMARY KEY (anyo) USING INDEX indexImpacte1
ENABLE;

/************************************************************************************************************************
* DW_RiscsOberts
*************************************************************************************************************************/
CREATE TABLE DW_RiscsOberts(
    numRiscsOberts NUMBER (*,0) NOT NULL
)LOGGING
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

/************************************************************************************************************************
* DW_DepartamentMaxAE
*************************************************************************************************************************/
CREATE TABLE DW_DepartamentMaxAE(
    depId NUMBER (*,0) NOT NULL
)LOGGING
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
ALTER TABLE DW_DepartamentMaxAE ADD CONSTRAINT PK_DepartamentMaxAE PRIMARY KEY (DEPID);
ALTER TABLE DW_DepartamentMaxAE ADD CONSTRAINT FK_DepartamentMaxAE FOREIGN KEY (DEPID) REFERENCES DEPARTAMENT (DEPID) ENABLE;

/************************************************************************************************************************
* DW_AccionsCurs
*************************************************************************************************************************/
CREATE TABLE DW_AccionsCurs(
    nombreAccionsCurs NUMBER (*,0) NOT NULL
)LOGGING
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

/************************************************************************************************************************
* DW_DiferenciaInternaExterna
*************************************************************************************************************************/
CREATE TABLE DW_DiferenciaInternaExterna(
    anyo NUMBER(4) NOT NULL,
    numRiscAI NUMBER (*,0) NOT NULL,
    numRiscAE NUMBER (*,0) NOT NULL,
    diferencia NUMBER (*,0) NOT NULL
)LOGGING
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

CREATE UNIQUE INDEX DW_DiferenciaInternaExterna ON DW_DiferenciaInternaExterna (anyo ASC) 
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

ALTER TABLE DW_DiferenciaInternaExterna ADD CONSTRAINT PK_DiferenciaInternaExterna PRIMARY KEY (anyo) USING INDEX DW_DiferenciaInternaExterna ENABLE;

/************************************************************************************************************************
* DW_EmpleatMesAccions
*************************************************************************************************************************/
CREATE TABLE DW_EmpleatMesAccions(
    empleatId NUMBER (*,0) NOT NULL
)LOGGING
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

ALTER TABLE DW_EmpleatMesAccions ADD CONSTRAINT PK_EmpleatMesAccions PRIMARY KEY (EMPLEATID);
ALTER TABLE DW_EmpleatMesAccions ADD CONSTRAINT FK_EmpleatMesAccions FOREIGN KEY (EMPLEATID) REFERENCES EMPLEAT (EMPLEATID) ENABLE;

/************************************************************************************************************************
* CU 18: 
-DW_MitjaMostrejos
-DW_MosrejosAny
*************************************************************************************************************************/
CREATE TABLE DW_MitjaMostrejos(
    mitja FLOAT NOT NULL
)LOGGING
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

CREATE TABLE DW_MosrejosAny(
    anyo NUMBER(4) NOT NULL,
    numMostrejos NUMBER (*,0) NOT NULL
)LOGGING
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

ALTER TABLE DW_MosrejosAny ADD CONSTRAINT PK_MosrejosAny PRIMARY KEY (anyo);
/************************************************************************************************************************
* DW_CiberAutoAv
*************************************************************************************************************************/
CREATE TABLE DW_CiberAutoAv(
    totalCyber NUMBER (*,0) NOT NULL
)LOGGING
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

/************************************************************************************************************************
* DW_costMitja
*************************************************************************************************************************/
CREATE TABLE DW_costMitja(
    costTotal FLOAT DEFAULT 0,
    nombreAE NUMBER (*,0) DEFAULT 0,
    costMitja FLOAT DEFAULT 0
)LOGGING
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


/************************************************************************************************************************
* DW_AccionsAny
*************************************************************************************************************************/
CREATE TABLE DW_AccionsAny(
    anyo NUMBER(4) NOT NULL,
    comptaAccions NUMBER (*,0) NOT NULL
)LOGGING
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

ALTER TABLE DW_AccionsAny ADD CONSTRAINT PK_AccionsAny PRIMARY KEY (anyo);


/************************************************************************************************************************
* DW_MaxAny
*************************************************************************************************************************/
CREATE TABLE DW_MaxAny(
    anyo NUMBER(4) NOT NULL
)LOGGING
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



/************************************************************************************************************************
* DW_Top3TempsObert
*************************************************************************************************************************/
CREATE TABLE DW_Top3TempsObert(
    accioId NUMBER (*,0),
    accioNom varchar2(50),
    tempsObert NUMBER (*,0)
)LOGGING
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
ALTER TABLE DW_Top3TempsObert ADD CONSTRAINT PK_Top3TempsObert PRIMARY KEY (accioId);
ALTER TABLE DW_Top3TempsObert ADD CONSTRAINT FK_Top3TempsObert FOREIGN KEY (accioId) REFERENCES ACCIOMITIGADORA (ACCIOID) ENABLE;

/*************************************************************************************************************************
*Accio-TempsObert
**************************************************************************************************************************/
CREATE TABLE DW_AccioTemps(
    accioId NUMBER (*,0),
    accioNom varchar2(50),
    tempsObert NUMBER (*,0)
)LOGGING
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
/************************************************************************************************************************
* DW_RiscCat1
*************************************************************************************************************************/
CREATE TABLE DW_RiscCat1(
    nombreRisc NUMBER(*,0) NOT NULL
)LOGGING
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

/************************************************************************************************************************
* DW_PerAccionnsDescartades
*************************************************************************************************************************/
CREATE TABLE DW_PerAccionnsDescartades(
    anyo NUMBER(4) NOT NULL,
    nombreAccions NUMBER(*,0) NOT NULL,
    accionsDescartades NUMBER(*,0) NOT NULL,
    percentatge NUMBER(*,2) NOT NULL

)LOGGING
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

alter table DW_PerAccionnsDescartades add constraint PK_PerAccionnsDescartades primary key (anyo);

/************************************************************************************************************************
* DW_PitjorDepartament
*************************************************************************************************************************/
CREATE TABLE DW_PitjorDepartament(
    depId NUMBER (*,0) NOT NULL,
    nom varchar2(50) NOT NULL
)LOGGING
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

alter table DW_PitjorDepartament add constraint PK_PitjorDepartament primary key (depId);
ALTER TABLE DW_PitjorDepartament ADD CONSTRAINT FK_PitjorDepartament FOREIGN KEY (DEPID) REFERENCES DEPARTAMENT (DEPID) ENABLE;

/************************************************************************************************************************
* DW_PercentatgeCat
*************************************************************************************************************************/
CREATE TABLE DW_PercentatgeCat(
    catId NUMBER (*,0) NOT NULL,
    nom varchar2(50) NOT NULL,
    percentatge NUMBER(*,2) NOT NULL,
    numRiscs NUMBER(*,0) NOT NULL
)LOGGING
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
ALTER TABLE DW_PercentatgeCat ADD CONSTRAINT PK_PercentatgeCat PRIMARY KEY (catId);
ALTER TABLE DW_PercentatgeCat ADD CONSTRAINT FK_PercentatgeCat FOREIGN KEY (CATID) REFERENCES CATEGORIA (CATID) ENABLE;