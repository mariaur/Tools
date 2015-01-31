<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:DTS="www.microsoft.com/SqlServer/Dts"  
  version="1.0"
  >

  <!-- Import common functions -->
  <xsl:include href="{{{THISPATH}}}common.xslt"/>
  
  <xsl:strip-space elements="*"/>
  <xsl:output method="xml" encoding="utf-8" indent="yes" />

  <xsl:param name="xpath" select="{{{XPATH}}}" />
  <xsl:param name="includeXPathAttribute" select="false()" />

  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>  
  </xsl:template>
  
  <xsl:template match="/">
    <xsl:element name="pick">
      <xsl:attribute name="nodes">
        <xsl:value-of select="count($xpath)"/>
      </xsl:attribute>
      <xsl:for-each select="$xpath" >
        <xsl:element name="node{position()}">
          <xsl:apply-templates select="." />
          <xsl:if test="$includeXPathAttribute">
            <xsl:attribute name="xpath">
              <xsl:call-template name="getPath" />
            </xsl:attribute>
          </xsl:if>
        </xsl:element>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>

