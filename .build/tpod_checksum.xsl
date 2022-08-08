<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="xs" version="2.0">
   <xsl:output method="xml" version="1.0" indent="yes" encoding="UTF-8" standalone="yes"/>

   <xsl:param name="base.dir" select="string('C:\Werkbestanden\Geonovum\Beheer\tpod_splitsen')"/>
   <xsl:param name="file.name"/>
   <xsl:param name="file.fullname"/>
   <xsl:param name="file.type" select="tokenize($file.name,'\.')[last()]"/>
   <xsl:param name="file.checksum"/>

   <!-- verwijzingen naar gebruikte directories -->
   <xsl:param name="word.dir" select="fn:string-join((fn:tokenize($base.dir,'\\'),'temp','template','word'),'/')"/>
   <xsl:param name="media.dir" select="fn:string-join((fn:tokenize($base.dir,'\\'),'temp','template','word','media'),'/')"/>
   <xsl:param name="checksum.dir" select="fn:string-join((fn:tokenize($base.dir,'\\'),'temp','checksum'),'/')"/>

   <!-- verwijzingen naar gebruikte documenten -->
   <xsl:param name="comments" select="fn:string-join(('file:',$word.dir,'comments.xml'),'/')"/>
   <xsl:param name="endnotes" select="fn:string-join(('file:',$word.dir,'endnotes.xml'),'/')"/>
   <xsl:param name="footnotes" select="fn:string-join(('file:',$word.dir,'footnotes.xml'),'/')"/>
   <xsl:param name="numbering" select="fn:string-join(('file:',$word.dir,'numbering.xml'),'/')"/>
   <xsl:param name="relations" select="fn:string-join(('file:',$word.dir,'_rels/document.xml.rels'),'/')"/>
   <xsl:param name="settings" select="fn:string-join(('file:',$word.dir,'settings.xml'),'/')"/>
   <xsl:param name="styles" select="fn:string-join(('file:',$word.dir,'styles.xml'),'/')"/>

   <!-- checksum maakt een tijdelijk bestand met informatie over afbeeldingen die in tpod_splitsen wordt gebruikt -->

   <xsl:template match="/">
      <xsl:element name="file">
         <xsl:variable name="relationship" select="(document($relations,.)//Relationship[contains(@Target,$file.name)],null)[1]" xpath-default-namespace="http://schemas.openxmlformats.org/package/2006/relationships"/>
         <xsl:if test="$relationship">
            <xsl:element name="id">
               <xsl:value-of select="$relationship/@Id"/>
            </xsl:element>
            <xsl:element name="target">
               <xsl:value-of select="$relationship/@Target"/>
            </xsl:element>
         </xsl:if>
         <xsl:element name="name">
            <xsl:value-of select="$file.name"/>
         </xsl:element>
         <xsl:element name="fullname">
            <xsl:value-of select="fn:string-join(tokenize($file.fullname,'\\'),'/')"/>
         </xsl:element>
         <xsl:element name="type">
            <xsl:value-of select="$file.type"/>
         </xsl:element>
         <xsl:element name="rename">
            <xsl:value-of select="concat('image_',$file.checksum,'.',$file.type)"/>
         </xsl:element>
         <xsl:element name="checksum">
            <xsl:value-of select="$file.checksum"/>
         </xsl:element>
      </xsl:element>
   </xsl:template>

   <xsl:template match="*">
      <xsl:element name="{name()}">
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates select="node()"/>
      </xsl:element>
   </xsl:template>

</xsl:stylesheet>