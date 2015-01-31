<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0"
  >

  <xsl:output method="xml" encoding="utf-8" indent="yes"/>

  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*">
        <xsl:sort order="ascending" select="name()" data-type="text" />
      </xsl:apply-templates>
      <xsl:if test="normalize-space(text())!=''">
        <xsl:value-of select="text()" />
      </xsl:if>
      <xsl:apply-templates select="*" >
        <xsl:sort order="ascending" select="name()" data-type="text" />
      </xsl:apply-templates>
    </xsl:copy>  
  </xsl:template>
  
  <xsl:template match="/">
    <xsl:apply-templates select="*">
        <xsl:sort order="ascending" select="name()" data-type="text" />
    </xsl:apply-templates>
  </xsl:template>
    
  <xsl:template match="@*">
    <xsl:copy />
  </xsl:template>
    
</xsl:stylesheet>

