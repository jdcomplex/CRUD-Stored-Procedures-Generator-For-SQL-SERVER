SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
-- ================================================
-- CRUD script generater writtern by Kamal Khanal
-- http://programerzone.blogspot.com
-- ================================================
-- EXEC [dbo].[usp_GenerateCRUD] 'HumanResources.Employee','Kamal Khanal' -- table name and author name
-- EXEC [dbo].[usp_GenerateCRUD] 'HumanResources.Employee','tbl_', 'Kamal Khanal' --table name, prefix and author name
-- EXEC [dbo].[usp_GenerateCRUD] 'HumanResources.Employee','', 'Kamal Khanal',0 --table name, prefix, author name with nolock hint
-- EXEC [dbo].[usp_GenerateCRUD] 'HumanResources.Employee','', 'Kamal Khanal',0,1 --table name, prefix, author name with nolock hint and execute
-- EXEC [dbo].[usp_GenerateCRUD] 'HumanResources.Employee_Temporal', '', 'Kamal Khanal'

DROP PROCEDURE IF EXISTS [dbo].[usp_GenerateCRUD]
GO

CREATE PROCEDURE [dbo].[usp_GenerateCRUD]
    @TableName NVARCHAR(256) = NULL, --table name
    @Prefix NVARCHAR(5) = NULL, --table name
    @AuthorName NVARCHAR(256) = '', -- author name
    @IsAddNoLockHint BIT = 1, -- add nolock hint to select default 1
    @IsExecute BIT = 0 -- execute or print only default 0
AS
BEGIN
    SET NOCOUNT ON;
    PRINT '-- ================================================';
    PRINT '-- CRUD script generater writtern by Kamal Khanal';
    PRINT '-- http://programerzone.blogspot.com';
    PRINT '-- ================================================';
    PRINT '

'   ;
    DECLARE @SchemaName sysname = 'dbo',
			@InsertSelectblName NVARCHAR(256),
            @NolockHint NVARCHAR(50) = N'';

        IF CHARINDEX('.', @TableName) > 0
        BEGIN
            SET @SchemaName = REPLACE(REPLACE(SUBSTRING(@TableName, 0, CHARINDEX('.', @TableName)), '[', ''), ']', '');
            SET @TableName
                = REPLACE(
                             REPLACE(SUBSTRING(@TableName, CHARINDEX('.', @TableName) + 1, LEN(@TableName)), '[', ''),
                             ']',
                             ''
                         );
        END;
        ELSE
            SET @TableName = REPLACE(REPLACE(@TableName, '[', ''), ']', '');

    IF (@IsAddNoLockHint = 1)
        SET @NolockHint = N'(NOLOCK)';
		
	declare icursor cursor
    for select [name] from sys.objects where type = 'u' and [name] <> 'sysdiagrams' and ([name] = @TableName or [name] like @Prefix + '%')
	open icursor
		fetch next from icursor into @TableName
		while @@fetch_status = 0
		begin
		    -- begin loop tables

	SELECT @InsertSelectblName = @TableName; --name of the table to generated crud script

    IF OBJECT_ID('tempdb..#tmptablcol') IS NOT NULL
        DROP TABLE #tmptablcol;

    SELECT c.COLUMN_NAME,
           DATA_TYPE,
           CHARACTER_MAXIMUM_LENGTH,
           IS_NULLABLE,
           ISNULL(is_identity, 0) AS is_identity,
           ISNULL(is_computed, 0) AS is_computed,
		   ISNULL(generated_always_type,0) AS generated_always_type,
           c.DATETIME_PRECISION AS scale,
           c.NUMERIC_PRECISION AS NPRECISION,
           c.NUMERIC_SCALE AS Nscale
    INTO #tmptablcol
    FROM INFORMATION_SCHEMA.COLUMNS c
        LEFT JOIN
        (
            SELECT name,
                   is_identity,
                   is_computed,
				   generated_always_type
            FROM sys.columns
            WHERE object_id = OBJECT_ID('' + @SchemaName + '' + '.' + '' + @InsertSelectblName)
        ) const
            ON const.name = c.COLUMN_NAME
    WHERE c.TABLE_SCHEMA = @SchemaName
          AND c.TABLE_NAME = @InsertSelectblName;

    DECLARE @column_name NVARCHAR(256),
            @data_type NVARCHAR(256),
            @character_maximum_length INT,
            @is_nullable NCHAR(5),
            @is_identity BIT,
            @is_computed BIT,
			@generated_always_type TINYINT,
            @scale INT,
            @NPRECISION INT,
            @Nscale INT;

    DECLARE @insertcolumn_sql NVARCHAR(MAX) = N'';
    DECLARE @UpdateSelectpdatecolumn_sql NVARCHAR(MAX) = N'';
    DECLARE @select_sql NVARCHAR(MAX) = N'';
    DECLARE @insert_sql NVARCHAR(MAX) = N'';
    DECLARE @insertupdate_sql NVARCHAR(MAX) = N'';
    DECLARE @selectlist_sql NVARCHAR(MAX) = N'';
    DECLARE @update_sql NVARCHAR(MAX) = N'';
    DECLARE @delete_sql NVARCHAR(MAX) = N'';
    DECLARE @identity_col NVARCHAR(256) = N'';
    DECLARE @where_col NVARCHAR(256) = N'';
    DECLARE @IsNumeric BIT = 0;

    DECLARE db_cursor CURSOR FOR SELECT * FROM #tmptablcol;
	OPEN db_cursor;
    FETCH NEXT FROM db_cursor
    INTO @column_name,
         @data_type,
         @character_maximum_length,
         @is_nullable,
         @is_identity,
         @is_computed,
		 @generated_always_type,
         @scale,
         @NPRECISION,
         @Nscale;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF (@is_identity = 1)
        BEGIN
            SELECT @identity_col = @column_name,
                   @where_col = @column_name;
            SELECT @UpdateSelectpdatecolumn_sql += N'
        @' +    @column_name + N' ' + @data_type;
            IF (@character_maximum_length IS NOT NULL)
                SELECT @UpdateSelectpdatecolumn_sql += N'(' + CAST(@character_maximum_length AS NVARCHAR) + N')';
            SELECT @UpdateSelectpdatecolumn_sql += N' = NULL,';

            IF (@data_type IN ( 'bigint', 'int', 'smallint', 'tinyint', 'decimal', 'numeric', 'money', 'smallmoney',
                                'float', 'real'
                              )
               )
                SET @IsNumeric = 1;
        END;
        ELSE
        BEGIN
            IF (ISNULL(@where_col, '') = '' AND @is_computed = 0 AND @generated_always_type =0)
            BEGIN
                SELECT @where_col = @column_name;

                SELECT @UpdateSelectpdatecolumn_sql += N'
        @' +        @column_name + N' ' + @data_type;
                IF (@character_maximum_length IS NOT NULL)
                    SELECT @UpdateSelectpdatecolumn_sql += N'(' + CAST(@character_maximum_length AS NVARCHAR) + N')';
                SELECT @UpdateSelectpdatecolumn_sql += N' = NULL,';

                IF (@data_type IN ( 'bigint', 'int', 'smallint', 'tinyint', 'decimal', 'numeric', 'money',
                                    'smallmoney', 'float', 'real'
                                  )
                   )
                    SET @IsNumeric = 1;
            END;

            IF (@is_computed = 0 AND @generated_always_type =0)
            BEGIN

                IF (
                       (
                           ISNULL(@scale, 0) = 0
                           OR @data_type = 'datetime'
                       )
                       AND @data_type NOT IN ( 'datetime2', 'decimal' )
                   )
                    SELECT @insertcolumn_sql += N'
@' +                    @column_name + N' ' + @data_type;
                ELSE IF (@data_type = 'decimal')
                    SELECT @insertcolumn_sql += N'
@' +                    @column_name + N' ' + @data_type + N'(' + CAST(@NPRECISION AS NVARCHAR) + N','
                                                + CAST(@Nscale AS NVARCHAR) + N')';
                ELSE
                    SELECT @insertcolumn_sql += N'
@' +                    @column_name + N' ' + @data_type + N'(' + CAST(@scale AS NVARCHAR) + N')';


                IF (@data_type <> 'hierarchyid' AND @character_maximum_length IS NOT NULL)
                    SELECT @insertcolumn_sql += N'(' + CASE
                                                           WHEN @character_maximum_length > 0 THEN
                                                               CAST(@character_maximum_length AS NVARCHAR)
                                                           ELSE
                                                               'MAX'
                                                       END + N')';

                IF (@is_nullable = 'YES')
                    SELECT @insertcolumn_sql += N' = NULL,';
                ELSE
                    SELECT @insertcolumn_sql += N',';
            END;
        END;
        FETCH NEXT FROM db_cursor
        INTO @column_name,
             @data_type,
             @character_maximum_length,
             @is_nullable,
             @is_identity,
             @is_computed,
			 @generated_always_type,
             @scale,
             @NPRECISION,
             @Nscale;
	END
    CLOSE db_cursor
    DEALLOCATE db_cursor

	SELECT @insertcolumn_sql = SUBSTRING(@insertcolumn_sql, 1, LEN(@insertcolumn_sql) - 1);

    DECLARE @GetSelect NVARCHAR(MAX);
    DECLARE @InsertSelect NVARCHAR(MAX);
    DECLARE @InsertSelectVal NVARCHAR(MAX);
    DECLARE @UpdateSelect NVARCHAR(MAX);

    SELECT @GetSelect = COALESCE(@GetSelect + ',', '') + N'[' + COLUMN_NAME + N']'
    FROM #tmptablcol;

    SELECT @InsertSelect = COALESCE(@InsertSelect + ',', '') + N'[' + COLUMN_NAME + N']'
    FROM #tmptablcol
    WHERE is_identity = 0
          AND is_computed = 0
		  AND generated_always_type=0

    SELECT @InsertSelectVal = COALESCE(@InsertSelectVal + ',', '') + N'@' + COLUMN_NAME
    FROM #tmptablcol
    WHERE is_identity = 0
          AND is_computed = 0
		   AND generated_always_type=0

    SELECT @UpdateSelect = COALESCE(@UpdateSelect + ',', '') + N'[' + COLUMN_NAME + N'] = @' + COLUMN_NAME
    FROM #tmptablcol
    WHERE is_identity = 0
          AND is_computed = 0
		   AND generated_always_type=0

    SELECT @insert_sql = N'-- =============================================
-- Author:		' + @AuthorName + N'
-- Create date: ' + CAST(CAST(GETDATE() AS DATE) AS NVARCHAR(25)) + N'
-- Description:	Add data to ' + +@InsertSelectblName + N'
-- =============================================';

    SELECT @insert_sql += N'
DROP PROCEDURE IF EXISTS [' + @SchemaName + N'].[usp_Add' + @InsertSelectblName + N']
GO'
    SELECT @insert_sql += N'
CREATE PROCEDURE [' + @SchemaName + N'].[usp_Add' + @InsertSelectblName + N']
' +     @insertcolumn_sql + N',
@Output INT OUTPUT 
AS
BEGIN
       SET NOCOUNT ON;
       
       SELECT @Output = 0
       INSERT INTO ' + N'[' + @SchemaName + N'].[' + @InsertSelectblName + N']' + N'(' + @InsertSelect
                          + N')
       VALUES(' + @InsertSelectVal + N')' + N'
       IF @@ROWCOUNT>0
        SELECT @Output = 1
END
GO
'   ;
    SELECT @update_sql += N'-- =============================================
-- Author:		' + @AuthorName + N'
-- Create date: ' + CAST(CAST(GETDATE() AS DATE) AS NVARCHAR(25)) + N'
-- Description:	update data to ' + +@InsertSelectblName + N'
-- =============================================';

    SELECT @update_sql += N'
DROP PROCEDURE IF EXISTS [' + @SchemaName + N'].[usp_Update' + @InsertSelectblName + N']
GO'
    SELECT @update_sql += N'
CREATE PROCEDURE [' + @SchemaName + N'].[usp_Update' + @InsertSelectblName + N']
' +     IIF(@identity_col <> '', @UpdateSelectpdatecolumn_sql, '') + @insertcolumn_sql
                          + N',
@Output INT OUTPUT    
AS
BEGIN
       SET NOCOUNT ON;
       
       SELECT @Output = 0
       UPDATE ' + N'[' + @SchemaName + N'].[' + @InsertSelectblName + N']' + N' SET ' + @UpdateSelect
                          + N'
       WHERE [' + @where_col + N'] =@' + @where_col
                          + N'
       
       IF @@ROWCOUNT>0
        SELECT @Output = 1
END
GO
'   ;
    SELECT @select_sql += N'-- =============================================
-- Author:		' + @AuthorName + N'
-- Create date: ' + CAST(CAST(GETDATE() AS DATE) AS NVARCHAR(25)) + N'
-- Description:	Get data from ' + +@InsertSelectblName + N'
-- =============================================';

    SELECT @select_sql += N'
DROP PROCEDURE IF EXISTS [' + @SchemaName + N'].[usp_Get' + @InsertSelectblName + N']
GO'
    SELECT @select_sql += N'
CREATE PROCEDURE [' + @SchemaName + N'].[usp_Get' + @InsertSelectblName + N']
' +     SUBSTRING(@UpdateSelectpdatecolumn_sql, 1, LEN(@UpdateSelectpdatecolumn_sql) - 1)
                          + N'    
AS
BEGIN
       SET NOCOUNT ON;
       SELECT ' + @GetSelect + N' FROM [' + @SchemaName + N'].[' + @InsertSelectblName + N']' + @NolockHint
                          + N'
       WHERE ([' + @where_col + N'] =@' + @where_col + N' OR @' + @where_col + N' IS NULL)' + N'
END
GO
'   ;
    SELECT @delete_sql += N'-- =============================================
-- Author:		' + @AuthorName + N'
-- Create date: ' + CAST(CAST(GETDATE() AS DATE) AS NVARCHAR(25)) + N'
-- Description:	Delete data from ' + +@InsertSelectblName + N'
-- =============================================';

    SELECT @delete_sql += N'
DROP PROCEDURE IF EXISTS [' + @SchemaName + N'].[usp_Delete' + @InsertSelectblName + N']
GO'
    SELECT @delete_sql += N'
CREATE PROCEDURE [' + @SchemaName + N'].[usp_Delete' + @InsertSelectblName + N']
' +     SUBSTRING(@UpdateSelectpdatecolumn_sql, 1, LEN(@UpdateSelectpdatecolumn_sql) - 1)
                          + N',
@Output INT OUTPUT   
AS
BEGIN
       SET NOCOUNT ON;
       
       SELECT @Output = 0
       DELETE FROM ' + N'[' + @SchemaName + N'].[' + @InsertSelectblName + N']' + N'         
       WHERE [' + @where_col + N'] =@' + @where_col
                          + N'
       
       IF @@ROWCOUNT>0
        SELECT @Output = 1
END
GO
'   ;

    SELECT @insertupdate_sql = N'-- =============================================
-- Author:		' + @AuthorName + N'
-- Create date: ' + CAST(CAST(GETDATE() AS DATE) AS NVARCHAR(25)) + N'
-- Description:	Add Update data to ' + +@InsertSelectblName + N'
-- =============================================';

    SELECT @insertupdate_sql += N'
DROP PROCEDURE IF EXISTS [' + @SchemaName + N'].[usp_AddUpdate' + @InsertSelectblName + N']
GO'
    SELECT @insertupdate_sql += N'
CREATE PROCEDURE [' + @SchemaName + N'].[usp_AddUpdate' + @InsertSelectblName + N']
' +     IIF(@identity_col <> '', @UpdateSelectpdatecolumn_sql, '') + @insertcolumn_sql
                                + N',
@Output INT OUTPUT    
AS
BEGIN
       SET NOCOUNT ON;
       
       SELECT @Output = 0
       
       IF(@' + @where_col + N' = ' + CASE @IsNumeric
                                         WHEN 1 THEN
                                             '0'
                                         ELSE
                                             ''''''
                                     END + N')
       BEGIN
       INSERT INTO ' + N'[' + @SchemaName + N'].[' + @InsertSelectblName + N']' + N'(' + @InsertSelect
                                + N')
       VALUES(' + @InsertSelectVal + N')'
                                + N'
      
       SELECT @Output = 1
       END
       ELSE
       BEGIN
       	  UPDATE ' + N'[' + @SchemaName + N'].[' + @InsertSelectblName + N']' + N' SET ' + @UpdateSelect
                                + N'
       WHERE [' + @where_col + N'] =@' + @where_col
                                + N'
       
       	 SELECT @Output = 2
       	 
       END
END
GO
'   ;

    SELECT @selectlist_sql += N'-- =============================================
-- Author:		' + @AuthorName + N'
-- Create date: ' + CAST(CAST(GETDATE() AS DATE) AS NVARCHAR(25)) + N'
-- Description:	Get data from ' + +@InsertSelectblName
                              + N' with pagination
-- =============================================';

    SELECT @selectlist_sql += N'
DROP PROCEDURE [' + @SchemaName + N'].[usp_Get' + @InsertSelectblName + N'List]
GO'
    SELECT @selectlist_sql += N'
CREATE PROCEDURE [' + @SchemaName + N'].[usp_Get' + @InsertSelectblName
                              + N'List]
@offset INT,
@limit INT 
-- extra parameter as needed
AS
BEGIN
       SET NOCOUNT ON;
       
       DECLARE @RowTotal INT
       
       SELECT @RowTotal = COUNT(1) FROM [' + @SchemaName + N'].[' + @InsertSelectblName + N']' + @NolockHint
                              + N' 
       -- WHERE extra condition here
       SELECT @RowTotal AS RowTotal, ' + @GetSelect + N' FROM [' + @SchemaName + N'].[' + @InsertSelectblName + N']'
                              + @NolockHint + N'
        -- WHERE extra condition here
       ORDER BY [' + @where_col + N'] OFFSET (@offset-1) ROWS FETCH NEXT @limit ROWS ONLY 


END
GO
'   ;

    IF (@IsExecute = 1)
    BEGIN
        EXEC (@insert_sql);
        EXEC (@update_sql);
        EXEC (@select_sql);
        EXEC (@delete_sql);
        EXEC (@insertupdate_sql);
        EXEC (@selectlist_sql);
    END;
    ELSE
    BEGIN
        PRINT @insert_sql;
        PRINT @update_sql;
        PRINT @select_sql;
        PRINT @delete_sql;
        PRINT @insertupdate_sql;
        PRINT @selectlist_sql;
    END;

-- end loop tables
			fetch next from icursor into @TableName
		end
    CLOSE icursor
    DEALLOCATE icursor
END
GO