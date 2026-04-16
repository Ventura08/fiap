#!/bin/bash
set -e

SQLCMD=/opt/mssql-tools18/bin/sqlcmd

echo ">>> Criando banco agnello..."
$SQLCMD -S sqlserver -U sa -P "$SA_PASSWORD" -C -b \
  -Q "IF NOT EXISTS (SELECT name FROM sys.databases WHERE name='agnello') CREATE DATABASE agnello;"

echo ">>> Executando DDL..."
$SQLCMD -S sqlserver -U sa -P "$SA_PASSWORD" -C -b -d agnello -i /sql/DDL.sql

echo ">>> Inserindo dados iniciais (DML)..."
$SQLCMD -S sqlserver -U sa -P "$SA_PASSWORD" -C -b -d agnello -i /sql/DML.sql

echo ">>> Banco pronto!"
