<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:my="functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xpath-default-namespace="http://schemas.openxmlformats.org/package/2006/relationships">
   <xsl:output method="xml" version="1.0" indent="no" encoding="UTF-8"/>

   <xsl:param name="base.dir" select="string('C:\Werkbestanden\Geonovum\Beheer\tpod_samenvoegen')"/>

   <!-- gebruikte directories -->
   <xsl:param name="temp.dir" select="fn:string-join((fn:tokenize($base.dir,'\\'),'temp'),'/')"/>

   <!-- gebruikte relations -->
   <xsl:param name="rels">
      <xsl:for-each-group select="collection(concat('file:/',$temp.dir,'/fragmenten?select=document.xml.rels;recurse=yes'))//Relationship[(tokenize(@Type,'/')[last()] ne 'image')]" group-by="@Target">
         <xsl:sequence select="."/>
      </xsl:for-each-group>
   </xsl:param>
   <xsl:param name="media">
      <xsl:sequence select="collection(concat('file:/',$temp.dir,'/fragmenten?select=document.xml.rels;recurse=yes'))//Relationship[(tokenize(@Type,'/')[last()] eq 'image')]"/>
   </xsl:param>

   <!-- bouw het document op -->

   <xsl:template match="/">
      <xsl:element name="Relationships" namespace="http://schemas.openxmlformats.org/package/2006/relationships">
         <xsl:for-each select="$rels/Relationship">
            <xsl:copy-of select="."/>
         </xsl:for-each>
         <xsl:for-each select="$media/Relationship">
            <xsl:element name="Relationship" namespace="http://schemas.openxmlformats.org/package/2006/relationships">
               <xsl:attribute name="Id" select="fn:string-join(('eId',position()))"/>
               <xsl:attribute name="Type" select="@Type"/>
               <xsl:attribute name="Target" select="@Target"/>
            </xsl:element>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>

   <!-- algemene templates -->

   <xsl:template match="element()">
      <xsl:element name="{name()}">
         <xsl:apply-templates select="namespace::*|@*|node()"/>
      </xsl:element>
   </xsl:template>

   <xsl:template match="namespace::*">
      <xsl:copy-of select="."/>
   </xsl:template>

   <xsl:template match="@*">
      <xsl:copy-of select="."/>
   </xsl:template>

   <xsl:template match="text()">
      <xsl:copy-of select="."/>
   </xsl:template>

   <xsl:template match="comment()|processing-instruction()">
      <xsl:copy-of select="."/>
   </xsl:template>

</xsl:stylesheet>