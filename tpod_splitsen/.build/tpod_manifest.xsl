<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="xs" version="2.0">
  <xsl:output method="xml" version="1.0" indent="yes" encoding="UTF-8" standalone="yes"/>

  <xsl:variable name="basis" select="fn:document('manifest.xml')"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="element()">
    <xsl:element name="{name()}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="document/naam">
    <xsl:variable name="check" select="parent::document/checksum"/>
    <xsl:copy-of select="($basis//document[checksum=$check]/naam,.)[1]"/>
  </xsl:template>

  <xsl:template match="document/omgevingswetbesluit">
    <xsl:variable name="check" select="parent::document/checksum"/>
    <xsl:copy-of select="($basis//document[checksum=$check]/omgevingswetbesluit,.)[1]"/>
  </xsl:template>

  <xsl:template match="afbeelding/naam">
    <xsl:variable name="check" select="parent::afbeelding/checksum"/>
    <xsl:copy-of select="($basis//afbeelding[checksum=$check]/naam,.)[1]"/>
  </xsl:template>

  <xsl:template match="afbeelding/omgevingswetbesluit">
    <xsl:variable name="check" select="parent::afbeelding/checksum"/>
    <xsl:copy-of select="($basis//afbeelding[checksum=$check]/omgevingswetbesluit,.)[1]"/>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:apply-templates select="normalize-space(.)"/>
  </xsl:template>

</xsl:stylesheet>