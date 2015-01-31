<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:msxsl="urn:schemas-microsoft-com:xslt"
  xmlns:csext="urn:csext"
  version="1.0"
  >

  <!-- Import common functions -->
  <xsl:include href="common.xslt"/>
  
  <xsl:output method="text" encoding="utf-8" />

  <!-- Various flags, controlling the verbosity of the output -->
  <xsl:param name="inputFileName" select="''" />
  <xsl:param name="outputXPath" select="false()" />
  <xsl:param name="outputContentAttribute" select="false()" />
  <xsl:param name="outputContentElement" select="false()" />

  <!-- Index on element/attribute full names, content -->
  <xsl:key match="*" name="elementNameIndex" use="concat(local-name(), namespace-uri())"/>
  <xsl:key match="@*" name="attributeNameIndex" use="concat(local-name(), namespace-uri())"/>
  
  <xsl:key match="text()" name="contentIndexElement" use="normalize-space(.)"/>
  <xsl:key match="@*" name="contentIndexAttribute" use="normalize-space(.)"/>

  <msxsl:script language="CSharp" implements-prefix="csext">
    <msxsl:using namespace="System.Collections.Generic" />
    <msxsl:using namespace="System.Security.Cryptography" />
    <![CDATA[

    private string XPathNavigator_GetPath(XPathNavigator navigator)
    {
      StringBuilder path = new StringBuilder();
      
      foreach (var p in navigator.SelectAncestors(XPathNodeType.All, true))
      {
        var parent = p as XPathNavigator;
        
        if (!String.IsNullOrEmpty(parent.Name))
        {
          int position = 1;
        
          string name = parent.Name, localName = parent.LocalName, 
            namespaceUri = parent.NamespaceURI;
        
          while (parent.MoveToPrevious())
          {
            if (parent.LocalName.Equals(localName) && 
                parent.NamespaceURI.Equals(namespaceUri))
            {
              position++;
            }
          }
        
          path.Insert(0, String.Format("/{0}[{1}]", name, position));
        }
        else if (path.Length == 0)
        {
          path.Append('/');
        }
      }

      return path.ToString();
    }

    public string getNodeSetSignature(XPathNodeIterator nodeSet)
    {
      List<string> nodes = new List<string> ();
      
      foreach (var node in nodeSet)
      {
        nodes.Add(XPathNavigator_GetPath(node as XPathNavigator));
      }
      
      nodes.Sort();

      byte[] hash;
      
      using (MD5CryptoServiceProvider md5 = new MD5CryptoServiceProvider())
      {
        foreach (var s in nodes)
        {
          var bytes = Encoding.Unicode.GetBytes(s);

          md5.TransformBlock(bytes, 0, bytes.Length, bytes, 0);
        }

        md5.TransformFinalBlock(new byte[] {}, 0, 0);
        
        hash = md5.Hash;
      }
      
      StringBuilder sb = new StringBuilder();
      
      if (nodes.Count > 0)
      {
        sb.Append(nodes[0] + ", ");
      }
      
      for (int n = 0; n < hash.Length; n++)
      {
        sb.Append(hash[n].ToString("x2", 
          System.Globalization.CultureInfo.InvariantCulture));
      }
      
      return sb.ToString();
    }
    ]]>
  </msxsl:script>
  
  <!-- Declare nodesets with distinct element/attribute names and content -->
  <xsl:variable
    name="distinctElementNames"
    select="//*[generate-id(.)=generate-id(key('elementNameIndex', concat(local-name(), namespace-uri()))[1])]"
    />
  
  <xsl:variable
    name="distinctAttributeNames"
    select="//*/@*[generate-id(.)=generate-id(key('attributeNameIndex', concat(local-name(), namespace-uri()))[1])]"
    />

  <xsl:variable
    name="distinctContentElement"
    select="//text()[generate-id(.)=generate-id(key('contentIndexElement', normalize-space(.))[1])]"
    />

  <xsl:variable
    name="distinctContentAttribute"
    select="//@*[generate-id(.)=generate-id(key('contentIndexAttribute', normalize-space(.))[1])]"
    />

  <!-- Output underline -->
  <xsl:template name="underline">
    <xsl:param name="length" />
    <xsl:choose>
      <xsl:when test="number($length)>0">
        <xsl:text>-</xsl:text>
        <xsl:call-template name="underline">
          <xsl:with-param name="length" select="number($length)-1" />
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <!-- Begin Summary -->
  <xsl:template name="outputSummaryStart">
    <xsl:param name="title" />
    <xsl:param name="nodeSet" />
    
    <xsl:value-of select="$title"/>
    <xsl:text> (</xsl:text>
    <xsl:value-of select="count($nodeSet)"/>
    <xsl:text>)&#xa;</xsl:text>
    <xsl:call-template name="underline">
      <xsl:with-param name="length" select="string-length($title)" />
    </xsl:call-template>
  </xsl:template>
  
  <!-- End Summary -->
  <xsl:template name="outputSummaryEnd">
    <xsl:text>] -> </xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:if test="namespace-uri()!=''">
      <xsl:text>{</xsl:text>
      <xsl:value-of select="namespace-uri()"/>
      <xsl:text>}</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="elementOrAttributeSummary">
    <!-- Input parameters -->
    <xsl:param name="title" />
    <xsl:param name="indexName" />
    <xsl:param name="nodeSet" />
    <xsl:param name="prefix" />
    
    <!-- Start summary -->
    <xsl:call-template name="outputSummaryStart">
      <xsl:with-param name="nodeSet" select="$nodeSet" />
      <xsl:with-param name="title" select="$title" />
    </xsl:call-template>
    <!-- Summary -->
    <xsl:for-each select="$nodeSet" >
      <xsl:sort order="descending" select="count(key($indexName, concat(local-name(), namespace-uri())))" data-type="number" />
      <xsl:sort select="concat(local-name(), namespace-uri())"/>
      <xsl:text>&#xa;  </xsl:text>
      <xsl:if test="$outputXPath">
        <!--<xsl:call-template name="getPath" />-->
        <xsl:value-of select="csext:getNodeSetSignature(key($indexName, concat(local-name(), namespace-uri())))"/>
        <xsl:text>&#xa;  </xsl:text>
      </xsl:if>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="$prefix" />
      <xsl:value-of select="format-number(count(key($indexName, concat(local-name(), namespace-uri()))), '00000')"/>
      <xsl:call-template name="outputSummaryEnd" />
    </xsl:for-each>
  </xsl:template>

  <!-- Element summary -->
  <xsl:template name="elementSummary">
    <xsl:call-template name="elementOrAttributeSummary">
      <xsl:with-param name="title" select="'ELEMENT SUMMARY'" />
      <xsl:with-param name="indexName" select="'elementNameIndex'" />
      <xsl:with-param name="nodeSet" select="$distinctElementNames" />
      <xsl:with-param name="prefix" select="'E:'" />
    </xsl:call-template>
  </xsl:template>
  
  <!-- Attribute summary -->
  <xsl:template name="attributeSummary">
    <xsl:call-template name="elementOrAttributeSummary">
      <xsl:with-param name="title" select="'ATTRIBUTE SUMMARY'" />
      <xsl:with-param name="indexName" select="'attributeNameIndex'" />
      <xsl:with-param name="nodeSet" select="$distinctAttributeNames" />
      <xsl:with-param name="prefix" select="'A:'" />
    </xsl:call-template>
  </xsl:template>

  <!-- Content summary -->
  <xsl:template name="contentSummary">
    <xsl:param name="distinctContent" />
    <xsl:param name="indexName" />
    <xsl:param name="title" />
    <xsl:param name="prefix" />
    <xsl:call-template name="outputSummaryStart">
      <xsl:with-param name="nodeSet" select="$distinctContent" />
      <xsl:with-param name="title" select="$title" />
    </xsl:call-template>
    <xsl:for-each select="$distinctContent" >
      <xsl:sort order="descending" select="count(key($indexName, normalize-space(.)))" data-type="number" />
      <xsl:sort select="normalize-space(.)"/>
      <xsl:text>&#xa;  </xsl:text>
      <xsl:if test="$outputXPath">
        <!--<xsl:call-template name="getPath" />-->
        <xsl:value-of select="csext:getNodeSetSignature(key($indexName, normalize-space(.)))"/>
        <xsl:text>&#xa;  </xsl:text>
      </xsl:if>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="$prefix"/>
      <xsl:value-of select="format-number(count(key($indexName, normalize-space(.))), '00000')"/>
      <xsl:text>] -> {</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>}</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <!-- Entry point -->
  <xsl:template match="/">
    <xsl:if test="$inputFileName!=''">
      <xsl:variable name="summaryTitle">
        <xsl:text>XML DOCUMENT SUMMARY - "</xsl:text>
        <xsl:value-of select="$inputFileName"/>
        <xsl:text>"</xsl:text>
      </xsl:variable>
      <xsl:value-of select="$summaryTitle"/>
      <xsl:text>&#xa;</xsl:text>
      <xsl:call-template name="underline">
        <xsl:with-param name="length" select="string-length($summaryTitle)"/>
      </xsl:call-template>
      <xsl:text>&#xa;&#xa;</xsl:text>
    </xsl:if>
    
    <xsl:call-template name="elementSummary" />
    <xsl:text>&#xa;&#xa;</xsl:text>
    <xsl:call-template name="attributeSummary" />
    <xsl:if test="$outputContentAttribute">
      <xsl:text>&#xa;&#xa;</xsl:text>
      <xsl:call-template name="contentSummary">
        <xsl:with-param name="distinctContent" select="$distinctContentAttribute" />
        <xsl:with-param name="indexName" select="'contentIndexAttribute'" />
        <xsl:with-param name="title" select="'ATTRIBUTE CONTENT SUMMARY'" />
        <xsl:with-param name="prefix" select="'AC:'" />
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$outputContentElement">
      <xsl:text>&#xa;&#xa;</xsl:text>
      <xsl:call-template name="contentSummary">
        <xsl:with-param name="distinctContent" select="$distinctContentElement" />
        <xsl:with-param name="indexName" select="'contentIndexElement'" />
        <xsl:with-param name="title" select="'ELEMENT CONTENT SUMMARY'" />
        <xsl:with-param name="prefix" select="'EC:'" />
      </xsl:call-template>
    </xsl:if>
    <xsl:text>&#xa;&#xa;</xsl:text>
  </xsl:template>
  
</xsl:stylesheet>

