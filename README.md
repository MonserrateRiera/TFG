# TFG

PL/SQL code for my TFG (Treball de Final de Grau) coursework at the UOC (Universitat Oberta de Catalunya). The project consists of two main objectives:

    -Creating a database to gather data about the risks of a company due to the future implementation of an ERM (Enterprise Risk Manager).
    -Creating a data warehouse to perform statistical queries with the objective of making informed decisions.

All variables and comments are in Catalan. I'll update this readme with all the design steps of the database once I can make it public.

I chose ORACLE as the DBMS.

Here's a brief description of each file:

#### 1_RiscControl_Tablespace

Creating a tablespace for the project and creating a user with the permissions to develop it.
#### 2_RiscControl_DB_CreacioTaules.sql

Creating the tables, indexes, PK, and FK. Since Oracle doesn't have auto-increment values, I used a sequence and a trigger for each table to auto-insert the ID attribute.
#### 3_RiscControl_DW_CreacioTaules.sql

Creating all the tables for the data warehouse.
#### 4_RiscControl_DB_Procediments.sql

Creating a set of CRUD procedures for each table.
#### 5_RiscControl_DW_Triggers.sql

Creating a set of triggers to update the DW tables. I used a trigger for each piece of data we need to update, with the intention of following best practices.
#### 6_RiscControl_DW_Consultes.sql

Creating a set of queries to retrieve data from the DW.
#### 7_RiscControl_CreacioRols.sql

Creating the roles identified in the design.
#### 8_RiscControl_TestAMB.sql

Set of tests to check the CRUD procedures.
#### 9_RiscControl_Inserts.sql

Inserting data into the tables.
#### 10_RiscControl_TestConsulta.sql

Set of tests checking the results of the statistical procedures.
