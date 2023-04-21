# CRUD-Stored-Procedures-Generator-For-SQL-SERVER
Generate create, read, update, delete stored procedure for single table/table with prefix/schema in SQL SEREVR.
This stored procedure generate six stored procedure for specified table.
Insert Only,
Update Only,
Select Only (All or By ID),
Delete Only,
Insert/Update in one stored procedue,
Get List (with pagination)

Examples

EXEC [dbo].[usp_GenerateCRUD] 'HumanResources.Employee','','Kamal Khanal' -- table name and author name

EXEC [dbo].[usp_GenerateCRUD] '','HumanResources', 'Kamal Khanal' --table name, prefix (all schema/table name start with HumanResources) and author name

EXEC [dbo].[usp_GenerateCRUD] 'HumanResources.Employee','', 'Kamal Khanal',1 --table name, prefix, author name with nolock hint

EXEC [dbo].[usp_GenerateCRUD] 'HumanResources.Employee','', 'Kamal Khanal',0,1 --table name, prefix, author name and execute

EXEC [dbo].[usp_GenerateCRUD] 'HumanResources.Employee_Temporal', '', 'Kamal Khanal'

![image](https://user-images.githubusercontent.com/28916183/233596325-bfe54956-9b40-4621-8461-ed78445fb35a.png)

![image](https://user-images.githubusercontent.com/28916183/233595809-741a5239-0051-4501-b87c-9afd4104948f.png)


