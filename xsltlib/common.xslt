<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0"
  >

  <xsl:template name="getPath">
    <xsl:param name="prevPath"/>
    <xsl:variable name="currPath" select="concat('/',name(),'[',
      count(preceding-sibling::*[name() = name(current())])+1,']',$prevPath)"/>
    <xsl:for-each select="parent::*">
      <xsl:call-template name="getPath">
        <xsl:with-param name="prevPath" select="$currPath"/>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:if test="not(parent::*)">
      <xsl:value-of select="$currPath"/>      
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>

