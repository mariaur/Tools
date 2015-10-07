function Usage()
{
    WScript.Echo();
    WScript.Echo("Usage: xslt.js <xml> <xslt> <output> [p1=v1 [p2=v2 [...]]]");
    WScript.Echo();

    WScript.Quit(1);
}

function checkXmlError (xmlDoc)
{
    if (xmlDoc.parseError.errorCode != 0)    
    {
        WScript.Echo();
        WScript.Echo (" xslt.js (error) --> " + xmlDoc.parseError.reason);
        WScript.Echo();
        WScript.Quit(1);
    }
}

try
{
    if (WScript.Arguments.Length < 3)
    {
        Usage();
    }

    var xmlFile = WScript.Arguments.Item(0);
    var xslFile = WScript.Arguments.Item(1);
    var outputFile = WScript.Arguments.Item(2);

    var xsltParams = new Array();

    if (WScript.Arguments.Length > 3)
    {
        for (var n = 0; n < WScript.Arguments.Length - 3; n++)
        {
            var name = WScript.Arguments.Item(3 + n);

            var value = "1";

            var sep = name.indexOf("=");

            if (sep != -1)
            {
                value = name.substring(sep + 1, name.length);

                name = name.substring(0, sep);
            }

            xsltParams.push({ name: name, value: value });
        }
    }

    WScript.Echo();
    
    var srcTree = new ActiveXObject("Msxml2.FreeThreadedDOMDocument.6.0");
    srcTree.async=false;

    WScript.Echo("(MSXML) Loading xml -> " + xmlFile + " ...");
    srcTree.load(xmlFile); 
    checkXmlError(srcTree);

    var xsltTree= new ActiveXObject("Msxml2.FreeThreadedDOMDocument.6.0");
    xsltTree.async = false;
    xsltTree.resolveExternals = true;
    xsltTree.setProperty("AllowXsltScript", true);
    xsltTree.setProperty("AllowDocumentFunction", true);
    
    WScript.Echo("(MSXML) Loading xslt -> " + xslFile + " ...");
    xsltTree.load(xslFile);
    checkXmlError(xsltTree);

    var xslTemplate = new ActiveXObject("Msxml2.XSLTemplate.6.0");
    xslTemplate.stylesheet = xsltTree;
    var xsltProcessor = xslTemplate.createProcessor();

    xsltProcessor.input = srcTree;

    if (xsltParams.length > 0)
    {
        for (var n = 0; n < xsltParams.length; n++)
        {
            xsltProcessor.addParameter(xsltParams[n].name, xsltParams[n].value);
        }
    }

    var stream = WScript.createObject("ADODB.Stream");
    stream.open();
    stream.type = 1;

    xsltProcessor.output=stream;

    xsltProcessor.transform();

    WScript.Echo("(MSXML) Saving file -> " + outputFile + " ...");
    stream.saveToFile(outputFile, 2);
    stream.close();

    WScript.Quit(0);
}
catch (e)
{
    WScript.Echo();
    WScript.Echo (" xslt.js (error) --> " + e.description)
    WScript.Quit(1);
}

