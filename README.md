# CRUD-Stored-Procedures-Generator-For-SQL-SERVER
Generate create, read, update, delete stored procedure for table in SQL SEREVR.
This stored procedure generate six stored procedure for specified table.
Insert Only,
Update Only,
Select Only (All or By ID),
Delete Only,
Insert/Update in one stored procedue,
Get List (with pagination)

Examples

EXEC [dbo].[usp_GenerateCRUD] 'HumanResources.Employee','Kamal Khanal' -- table name and author name

EXEC [dbo].[usp_GenerateCRUD] 'HumanResources.Employee','Kamal Khanal',1 --table name, author name with nolock hint

EXEC [dbo].[usp_GenerateCRUD] 'HumanResources.Employee','Kamal Khanal',1,1 --table name, author name with nolock hint and execute

EXEC [dbo].[usp_GenerateCRUD] 'HumanResources.Employee','Kamal Khanal'

![image](https://user-images.githubusercontent.com/28916183/229113446-15958740-9aa1-40fe-8e5b-cf6f5d3b8bb2.png)

