<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:output method="text" />

  <xsl:include href="common.xslt"/>

  <xsl:param name="dataOnly" select="false()" />

  <!-- XML Generation SQL (table info) - tableinfo.sql -->

  <!-- Fully qualified table name -->
  <xsl:template name="tableFullName">
    <xsl:text>[</xsl:text>
    <xsl:value-of select="@schema" />
    <xsl:text>].[</xsl:text>
    <xsl:value-of select="@name" />
    <xsl:text>]</xsl:text>
  </xsl:template>

  <!-- Entry point -->
  <xsl:template match="/">

    <xsl:call-template name="sqlComment">
      <xsl:with-param name="commentText" select="'Autogenerated by tabledata.xslt'" />
    </xsl:call-template>

    <!-- Comment section -->
    <xsl:for-each select="//tables/table">
      <xsl:text>-- </xsl:text>
      <xsl:call-template name="tableFullName" />
      <xsl:text>&#xa;</xsl:text>
    </xsl:for-each>
    <xsl:text>&#xa;</xsl:text>

    <!-- Summary section -->
    <xsl:if test="not($dataOnly)">
      <xsl:call-template name="sqlComment">
        <xsl:with-param name="commentText" select="'TABLE DATA SUMMARY (ROW COUNT)'" />
      </xsl:call-template>
      <xsl:apply-templates select="//tables" mode="tableDataCount" />
      <xsl:text>&#xa;</xsl:text>
    </xsl:if>

    <!-- SELECT section -->
    <xsl:call-template name="sqlComment">
      <xsl:with-param name="commentText" select="'SELECT TABLE DATA (XML)'" />
    </xsl:call-template>
    <xsl:apply-templates select="//tables" mode="getTableSelectStmt" />
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <!-- Select all data in all tables (as XML) -->
  <xsl:template match="tables" mode="getTableSelectStmt">
    <xsl:for-each select="table">
      <xsl:if test="position()!=1">
        <xsl:text>&#xa;UNION ALL&#xa;</xsl:text>
      </xsl:if>
      <xsl:text>SELECT ( SELECT '</xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:text>' AS '@name', '</xsl:text>
      <xsl:value-of select="@schema"/>
      <xsl:text>' AS '@schema', (SELECT * FROM </xsl:text>
      <xsl:call-template name="tableFullName" />
      <xsl:text> [row] FOR XML PATH, BINARY BASE64, TYPE) FOR XML PATH('table'), TYPE)</xsl:text>
    </xsl:for-each>
    <xsl:text>&#xa;</xsl:text>
    <xsl:text>FOR XML PATH(''), ROOT('tables')</xsl:text>
  </xsl:template>
  
  <!-- Table data count (summary) -->
  <xsl:template match="tables" mode="tableDataCount">
    <xsl:text>WITH Tables AS (&#xa;</xsl:text>
    <xsl:for-each select="table">
      <xsl:if test="position()!=1">
        <xsl:text>  UNION ALL&#xa;</xsl:text>
      </xsl:if>
      <xsl:text>  SELECT COUNT(*) [Count], N'</xsl:text>
      <xsl:call-template name="tableFullName" />
      <xsl:text>' [Table] FROM </xsl:text>
      <xsl:call-template name="tableFullName" />
      <xsl:text>&#xa;</xsl:text>
    </xsl:for-each>
    <xsl:text>)&#xa;</xsl:text>
    <xsl:text>SELECT * FROM Tables&#xa;</xsl:text>
    <xsl:text>UNION ALL&#xa;</xsl:text>
    <xsl:text>SELECT SUM([Count]), N'[All Tables]' FROM Tables&#xa;</xsl:text>
    <xsl:text>ORDER BY [Count] DESC&#xa;</xsl:text>
  </xsl:template>

</xsl:stylesheet>  
