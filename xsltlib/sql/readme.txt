This directory contains some useful scripts and XSLT transforms
to obtain database schema for SQL database in XML format. XSLT can 
then be used to obtain data info from tables as well as the actual 
data in XML format. In addition to that, SQL script can be generated 
back from the XML data that can be used to load data back to the 
database. 

Note that SQLCMD breaks the XML output into multiple lines, which 
can be fixed with the following helper script command - 

sqlcmd_xml.cmd <xml file>.xml <xml file>.xml

Below are the details on the steps that can 
be performed to achieve these tasks - 

1) Obtain (subset) of database schema (for example msdb) in XML format - 

sqlcmd -i sqlcmd_xml.sql -S localhost -d msdb -v InputFile=tableinfo.sql -o _database.xml
sqlcmd_xml.cmd _tables.xml _tables.xml

Now the schema is in _database.xml. It contains all the tables with 
their columns (+ type info, etc.), as well as PK and FK info as well 
as storage info. 

2) Generate table data scripts. For this step, we need the output from
   the previous step (_tables.xml), which will be transformed with tabledata.xslt
   to obtain SQL scripts for table data (summary and actual data (SELECT stmts)). 

xslt _database.xml tabledata.xslt _gettabledata.sql

At this point, _gettabledata.sql contains SQL scripts for getting table data
summary (row counts) as well as getting all data from all tables as XML (second
part of the script). 

We can focus now on the second part of the script in _gettabledata.sql. We will 
assume that only that part left in the file at this point (cut the summary info). 
Also, dataOnly parameter can be used to generate only the data XML. 

Then we can proceed to the next step - 

3) Retrieve all data from database as XML, based on generated script (_gettabledata.sql)

sqlcmd -i sqlcmd_xml.sql -S localhost -d msdb -v InputFile=_gettabledata.sql -o _tabledata.xml
sqlcmd_xml.cmd _tabledata.xml _tabledata.xml

_tabledata.xml now contains all the data from the database. We may now want to generate 
INSERT statements for the same data. This can be done by using _tabledata.xml and _database.xml
input for tableins.xslt XSLT transform. 

4) Generate INSERT statements for database data (note that tableins.xslt depends in the 
   _database.xml file name!) - 

xslt _tabledata.xml tableins.xslt _tabledata.sql


_tabledata.sql now contains the INSERT statements for all data in the database. 


