# CRUD-Stored-Procedures-Generator-For-SQL-SERVER
Generate create, read, update, delete stored procedure for table in SQL SEREVR.
This stored procedure generate six stored procedure for specified table.
Insert Only
Update Only
Select Only (All or By ID)
Delete Only
Insert/Update in one stored procedue
Get List (with pagination)

EXEC [dbo].[usp_GenerateCRUD] 'HumanResources.Employee','Kamal Khanal' -- table name and author name

EXEC [dbo].[usp_GenerateCRUD] 'HumanResources.Employee','Kamal Khanal',0 --table name, author name with nolock hint

EXEC [dbo].[usp_GenerateCRUD] 'HumanResources.Employee','Kamal Khanal',0,1 --table name, author name with nolock hint and execute

EXEC [dbo].[usp_GenerateCRUD] 'HumanResources.Employee_Temporal','Kamal Khanal'
