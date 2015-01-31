SELECT 
    1 Tag, 
    0 Parent, 

    o.[name] 'module!1!name', 
    RTRIM(LTRIM(o.type)) 'module!1!type', 
    s.[name] 'module!1!schema', 
    CHAR(13) + CHAR(10) + m.[definition] 'module!1!!CDATA'
FROM 
    sys.sql_modules m 
INNER JOIN 
    sys.objects o ON m.[object_id] = o.[object_id]
INNER JOIN 
    sys.schemas s ON o.[schema_id] = s.[schema_id]
FOR XML EXPLICIT, ROOT('modules')

