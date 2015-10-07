--
-- Retrieve database info in XML format
--

SELECT 
DB_NAME() '@name', 
(
    -- Storage information
    SELECT 
    -- File groups
    (
        SELECT
            [filegroup].name 'name', 
            [file].name 'name', 
            CONVERT(NVARCHAR(50), ([file].[size] / 128)) + N'MB' 'size', 
            CASE
                WHEN [file].[growth] = 0 THEN N'0'
                ELSE
                CASE
                    WHEN is_percent_growth = 0 THEN CONVERT(NVARCHAR(50), ([file].[growth] / 128)) + N'MB'
                    ELSE
                    CONVERT(NVARCHAR(50), [file].[growth]) + N'%'
                END
            END 'growth', 
            CASE
                WHEN [file].[max_size] <> -1 THEN CONVERT(NVARCHAR(50), ([file].[max_size] / 128)) + N'MB'
                ELSE N'UNLIMITED'
            END 'maxsize', 
            [file].[physical_name] 'filename'
        FROM 
            sys.filegroups [filegroup]
        INNER JOIN 
            sys.database_files [file]
        ON 
            [file].[data_space_id] = [filegroup].[data_space_id]
        ORDER BY
            [filegroup].name
        FOR XML AUTO, ROOT('filegroups'), TYPE
    ), 
    -- Logs
    (
        SELECT
            [file].name '@name', 
            CONVERT(NVARCHAR(50), ([file].[size] / 128)) + N'MB' '@size', 
            CASE
                WHEN [file].[growth] = 0 THEN N'0'
                ELSE
                CASE
                    WHEN is_percent_growth = 0 THEN CONVERT(NVARCHAR(50), ([file].[growth] / 128)) + N'MB'
                    ELSE
                    CONVERT(NVARCHAR(50), [file].[growth]) + N'%'
                END
            END '@growth', 
            CONVERT(NVARCHAR(50), ([file].[max_size] / 128)) + N'MB' '@maxsize', 
            [file].[physical_name] '@filename'
        FROM 
            sys.database_files [file]
        WHERE
            [file].[type] = 1 -- log files only
        FOR XML PATH('file'), ROOT('logs'), TYPE
    ), 
    -- Functions
    (
        SELECT 
            [function].[name] '@name', 
            CASE 
                WHEN [function].[boundary_value_on_right] = 1 THEN 'RIGHT'
                ELSE 'LEFT'
            END '@type', 
            [systype].[name] '@valuetype', 
            (
                -- Function values
                SELECT 
                    [rangevalue].[value]
                FROM
                    sys.partition_range_values [rangevalue]
                WHERE
                    [rangevalue].[function_id] = [function].[function_id]
                ORDER BY
                    [rangevalue].[value]
                FOR XML PATH(''), ROOT('values'), TYPE
            ), 
            (
                -- Schemes
                SELECT
                    [scheme].[name] '@name', 
                    (
                        -- Bondaries
                        SELECT 
                            ([destination].[destination_id]) '@id', 
                            ([dataspace].[name]) '@filegroup', 
                            ([rangevalue].[value]) '@value'
                        FROM
                            sys.destination_data_spaces [destination]
                        LEFT JOIN 
                            sys.partition_range_values [rangevalue]
                        ON
                            [destination].[destination_id] = [rangevalue].[boundary_id]
                            AND
                            [rangevalue].[function_id] = [scheme].[function_id]
                        LEFT JOIN
                            sys.data_spaces [dataspace]
                        ON
                            [destination].[data_space_id] = [dataspace].[data_space_id]
                        WHERE
                            [destination].[partition_scheme_id] = [scheme].[data_space_id]
                        ORDER BY
                            [destination].[destination_id]
                        FOR XML PATH ('boundary'), TYPE
                    )
                FROM
                    sys.partition_schemes [scheme]
                WHERE
                    [scheme].[function_id] = [function].[function_id]        

                FOR XML PATH('scheme'), ROOT('schemes'), TYPE
            )
        FROM
            sys.partition_functions [function]
        INNER JOIN 
            sys.partition_parameters [parameter]
        ON
            [function].[function_id] = [parameter].[function_id]
        INNER JOIN
            sys.types [systype]
        ON
            [systype].[system_type_id] = [parameter].[system_type_id]
        FOR XML PATH('function'), ROOT ('functions'), TYPE
    )
    FOR XML PATH(''), ROOT('storage'), TYPE
),
(
    -- Table information
    SELECT
        -- Is this a HEAP or CLUSTERED table
        [index_space].[type_desc] '@type', 
        [table].[name] '@name',
        OBJECT_SCHEMA_NAME([table].[object_id]) '@schema', 
        [index].[name] '@keyname', 
        [dataspace].[name] '@dsname', 
        [dataspace].[type] '@dstype', 
        -- Columns
        (
            SELECT 
                [column].[name] '@name', 
                CASE 
                    WHEN [indexcol].[column_id] IS NOT NULL THEN 1
                    ELSE NULL
                END '@key', 

                -- Is it identity
                CASE [column].[is_identity]
                    WHEN 1 THEN 1
                    ELSE NULL
                END '@identity', 

                -- Does it allow NULL
                [type].[name] '@type', 
                CASE
                    WHEN [column].[is_nullable] <> 0 THEN 1
                    ELSE NULL
                END '@nullable', 
            
                [column].[max_length] '@length', 
                -- Foreign key references
                (
                    SELECT 
                        OBJECT_NAME([fkc].[referenced_object_id]) '@tablename', 
                        OBJECT_SCHEMA_NAME([fkc].[referenced_object_id]) '@schema', 
                        COL_NAME([fkc].[referenced_object_id], [fkc].[referenced_column_id]) '@columnname'
                    FROM
                        sys.foreign_key_columns fkc
                    WHERE
                        [fkc].[parent_object_id] = [table].[object_id]
                        AND
                        [fkc].[parent_column_id] = [column].[column_id]
                    FOR XML PATH('keyref'), TYPE
                ) 'keyrefs'
            FROM 
                sys.columns [column]
            INNER JOIN 
                sys.types [type]
            ON
                [column].[user_type_id] = [type].[user_type_id]
            LEFT JOIN 
                sys.index_columns [indexcol]
            ON
                [indexcol].[object_id] = [table].[object_id]
                AND
                [indexcol].[index_id] = [index].[index_id]
                AND
                [indexcol].[column_id] = [column].[column_id]
            WHERE
                -- Take only columns for current table
                [column].[object_id] = [table].[object_id] 
            FOR XML PATH('column'), TYPE
        ) 'columns'
    FROM 
        sys.tables [table]
    LEFT JOIN
        sys.indexes [index]
    ON
        [index].[object_id] = [table].[object_id] AND [index].[is_primary_key] = 1
    INNER JOIN
        sys.indexes [index_space]
    ON
        [index_space].[object_id] = [table].[object_id] AND [index_space].[index_id] IN (0, 1) -- heap or clustered
    LEFT JOIN 
        sys.data_spaces [dataspace]
    ON
        [index_space].[data_space_id] = [dataspace].[data_space_id]
    FOR XML PATH('table'), ROOT ('tables'), TYPE
)
FOR XML PATH('database')



