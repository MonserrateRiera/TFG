/******************************************************************************
Creaci� del tablespace i de l'usuari amb els seus permisos per 
treballar la base de dades.
IMPORTANT: ES NECESSARI TENIR PERMISOS D'AMINISTRADOR PER EXECUTAR AQUEST SCRIPT
*******************************************************************************/

CREATE TABLESPACE Data_RISC_CONTROL DATAFILE 'C:\app\Risc_control.dat' 
size 150M;

/******************************************************************************
Creaci� d'usuari per treballar amb la base de dades i assignació del tablespace
*******************************************************************************/
/*Ha estat necessari executar aix� primer:*/
alter session set "_ORACLE_SCRIPT"=true;

CREATE USER MRIERAMAR IDENTIFIED BY 12345678
	DEFAULT TABLESPACE Data_RISC_CONTROL
	QUOTA UNLIMITED ON Data_RISC_CONTROL
	TEMPORARY TABLESPACE Temp;

/******************************************************************************
        Assignacio de permisos a l'usuari                  
******************************************************************************/

GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE TRIGGER, CREATE PROCEDURE, CREATE VIEW, CREATE TYPE TO MRIERAMAR;

