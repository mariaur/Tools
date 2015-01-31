<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />
  
  <!-- 
    Filter out the storage node only and preserve the following attributes - 
    name, type, valuetype, filegroup, start, count; can be used as a starting
    point for partitions.xslt (storage SQL script generation)
  -->

  <xsl:template match="@*" />

  <!-- 
    Assume all partition schemes will use the same FG for all partitions 
    (comment out, if this is not the case) 
  -->
  <xsl:template match="scheme">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:attribute name="filegroup">
        <xsl:value-of select="*/@filegroup" />
      </xsl:attribute>
    </xsl:copy>
  </xsl:template>
                
  <xsl:template match="@name | @type | @valuetype | @filegroup | @start | @count">
    <xsl:attribute name="{local-name()}" namespace="{namespace-uri()}">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="* | comment() | text()">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" />
    </xsl:copy>  
  </xsl:template>
  
  <xsl:template match="/database">
    <xsl:copy>
      <xsl:apply-templates select="storage | @*" />
    </xsl:copy>
  </xsl:template>
               
</xsl:stylesheet>
