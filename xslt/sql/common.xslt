<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" 
                xmlns:msxsl="urn:schemas-microsoft-com:xslt">

  <!-- Render SQL comment -->
  <xsl:template name="sqlComment">
    <xsl:param name="commentText" />
    <xsl:text>--&#xa;</xsl:text>
    <xsl:text>-- </xsl:text>
    <xsl:value-of select="$commentText" />
    <xsl:text>&#xa;--&#xa;</xsl:text>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <!-- Generic loop template (with callback) -->
  <xsl:template name="loopNumbers">
    <xsl:param name="start"/>
    <xsl:param name="end"/>
    <xsl:param name="callback" />
    <xsl:param name="context" />

    <xsl:if test="not($start > $end)">
      <xsl:choose>
        <xsl:when test="$start = $end">
          <xsl:variable name="callbackNode">
            <xsl:element name="{$callback}">
              <xsl:copy-of select="$context" />
            </xsl:element>
          </xsl:variable>
          <xsl:apply-templates select="msxsl:node-set($callbackNode)/*" mode="loopCallback">
            <xsl:with-param name="number" select="$start" />
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="mid" select="floor(($start + $end) div 2)"/>
          <xsl:call-template name="loopNumbers">
            <xsl:with-param name="start" select="$start"/>
            <xsl:with-param name="end" select="$mid"/>
            <xsl:with-param name="callback" select="$callback" />
            <xsl:with-param name="context" select="$context" />
          </xsl:call-template>
          <xsl:call-template name="loopNumbers">
            <xsl:with-param name="start" select="$mid+1"/>
            <xsl:with-param name="end" select="$end"/>
            <xsl:with-param name="callback" select="$callback" />
            <xsl:with-param name="context" select="$context" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- Helper for replacing one string with another -->
  <xsl:template name="replaceString">
    <xsl:param name="text"/>
    <xsl:param name="replace"/>
    <xsl:param name="with"/>
    <xsl:param name="escapeXml" />
    <xsl:choose>
      <xsl:when test="contains($text,$replace)">

        <!-- 
          Pattern found; take the first part of the input, then the replacement, 
          then proceed with the rest of the string. 
        -->
        <xsl:choose>
          <xsl:when test="$escapeXml">
            <xsl:value-of select="substring-before($text,$replace)" disable-output-escaping="no"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="substring-before($text,$replace)" disable-output-escaping="yes"/>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:value-of select="$with" />
        <xsl:call-template name="replaceString">
          <xsl:with-param name="text" select="substring-after($text,$replace)"/>
          <xsl:with-param name="replace" select="$replace"/>
          <xsl:with-param name="with" select="$with"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <!-- No pattern found -->
        <xsl:choose>
          <xsl:when test="$escapeXml">
            <xsl:value-of select="$text" disable-output-escaping="no"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$text" disable-output-escaping="yes"/>
          </xsl:otherwise>
        </xsl:choose>

      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>  
