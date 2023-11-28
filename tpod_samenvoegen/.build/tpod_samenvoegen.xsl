<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:my="functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:digest="java:org.apache.commons.codec.digest.DigestUtils" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:a14="http://schemas.microsoft.com/office/drawing/2010/main" xmlns:aink="http://schemas.microsoft.com/office/drawing/2016/ink" xmlns:am3d="http://schemas.microsoft.com/office/drawing/2017/model3d" xmlns:asvg="http://schemas.microsoft.com/office/drawing/2016/SVG/main" xmlns:cx="http://schemas.microsoft.com/office/drawing/2014/chartex" xmlns:cx1="http://schemas.microsoft.com/office/drawing/2015/9/8/chartex" xmlns:cx2="http://schemas.microsoft.com/office/drawing/2015/10/21/chartex" xmlns:cx3="http://schemas.microsoft.com/office/drawing/2016/5/9/chartex" xmlns:cx4="http://schemas.microsoft.com/office/drawing/2016/5/10/chartex" xmlns:cx5="http://schemas.microsoft.com/office/drawing/2016/5/11/chartex" xmlns:cx6="http://schemas.microsoft.com/office/drawing/2016/5/12/chartex" xmlns:cx7="http://schemas.microsoft.com/office/drawing/2016/5/13/chartex" xmlns:cx8="http://schemas.microsoft.com/office/drawing/2016/5/14/chartex" xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math" xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:oel="http://schemas.microsoft.com/office/2019/extlst" xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:w10="urn:schemas-microsoft-com:office:word" xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml" xmlns:w15="http://schemas.microsoft.com/office/word/2012/wordml" xmlns:w16="http://schemas.microsoft.com/office/word/2018/wordml" xmlns:w16cex="http://schemas.microsoft.com/office/word/2018/wordml/cex" xmlns:w16cid="http://schemas.microsoft.com/office/word/2016/wordml/cid" xmlns:w16sdtdh="http://schemas.microsoft.com/office/word/2020/wordml/sdtdatahash" xmlns:w16se="http://schemas.microsoft.com/office/word/2015/wordml/symex" xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing" xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas" xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup" xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk" xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape" mc:Ignorable="w14 wp14">
  <xsl:output method="xml" version="1.0" indent="yes" encoding="UTF-8"/>

  <xsl:param name="repository.dir" select="string('C:/Werkbestanden/Geonovum/Beheer/archief')"/>
  <xsl:param name="base.dir" select="string('C:/Werkbestanden/Geonovum/Beheer/tpod_samenvoegen')"/>
  <xsl:param name="delimiter" select="string('/')"/>

  <!-- gebruikte directories -->
  <xsl:param name="temp.dir" select="fn:string-join(('file:',fn:tokenize($base.dir,$delimiter),'temp'),$delimiter)"/>
  <xsl:param name="fragmenten.dir" select="fn:string-join(('file:',fn:tokenize($base.dir,$delimiter),'temp','fragmenten'),$delimiter)"/>
  <xsl:param name="template.dir" select="fn:string-join(('file:',fn:tokenize($base.dir,$delimiter),'temp','template','word'),$delimiter)"/>
  <xsl:param name="word.dir" select="fn:string-join(('file:',fn:tokenize($base.dir,$delimiter),'temp','word','word'),$delimiter)"/>
  <xsl:param name="archief.dir" select="fn:string-join(('file:',fn:tokenize($repository.dir,$delimiter)),$delimiter)"/>

  <!-- manifest.xml -->
  <xsl:param name="manifest" select="fn:collection(concat($temp.dir,'?select=manifest.xml;recurse=yes'))/manifest"/>

  <!-- gebruikte afbeeldingen -->
  <xsl:param name="media">
    <xsl:for-each select="fn:collection(concat($fragmenten.dir,'?select=document.xml;recurse=yes'))//element()[@r:embed]">
      <xsl:element name="item">
        <xsl:attribute name="index" select="position()"/>
        <xsl:attribute name="name" select="name()"/>
        <xsl:attribute name="anchorId" select="ancestor::wp:inline/@wp14:anchorId"/>
      </xsl:element>
    </xsl:for-each>
  </xsl:param>

  <!-- voetnoten -->
  <xsl:param name="default">
    <xsl:for-each select="fn:collection(concat($template.dir,'?select=footnotes.xml;recurse=yes'))//w:footnote[@w:type]">
      <xsl:sort select="@w:id"/>
      <xsl:copy-of select="."/>
    </xsl:for-each>
  </xsl:param>
  <xsl:param name="footnotes">
    <xsl:variable name="list">
      <xsl:for-each select="fn:collection(concat($fragmenten.dir,'?select=document.xml;recurse=yes'))//w:footnoteReference/@w:id">
        <xsl:variable name="w:id" select="."/>
        <xsl:variable name="file.name" select="fn:tokenize(base-uri(),$delimiter)[last()]"/>
        <xsl:variable name="w:footnote" select="fn:document(replace(base-uri(),$file.name,'footnotes.xml'),.)//w:footnote[@w:id=$w:id]"/>
        <xsl:variable name="check">
          <xsl:apply-templates select="$w:footnote/node()" mode="check"/>
        </xsl:variable>
        <xsl:element name="item">
          <xsl:attribute name="check" select="digest:md5Hex(fn:string-join($check))"/>
          <xsl:copy-of select="$w:footnote"/>
        </xsl:element>
      </xsl:for-each>
    </xsl:variable>
    <xsl:for-each-group select="$list/item" group-by="@check">
      <xsl:element name="item">
        <xsl:attribute name="index" select="position() + $default/w:footnote[last()]/@w:id"/>
        <xsl:attribute name="check" select="current-grouping-key()"/>
        <xsl:copy-of select="current-group()[1]/w:footnote"/>
      </xsl:element>
    </xsl:for-each-group>
  </xsl:param>

  <!-- nummering -->
  <xsl:param name="numbering">
    <xsl:variable name="list">
      <xsl:for-each select="fn:collection(concat($fragmenten.dir,'?select=*.xml;recurse=yes'))//w:numPr[number(w:numId/@w:val) gt 0]">
        <xsl:variable name="w:numPr" select="."/>
        <xsl:variable name="file.name" select="fn:tokenize(base-uri(),$delimiter)[last()]"/>
        <xsl:variable name="w:num" select="fn:document(replace(base-uri(),$file.name,'numbering.xml'),.)//w:num[@w:numId=$w:numPr/w:numId/@w:val]"/>
        <xsl:variable name="check">
          <xsl:apply-templates select="$w:num/node()" mode="check"/>
        </xsl:variable>
        <xsl:element name="item">
          <xsl:attribute name="check" select="digest:md5Hex(fn:string-join($check))"/>
          <xsl:copy-of select="$w:num"/>
        </xsl:element>
      </xsl:for-each>
    </xsl:variable>
    <xsl:for-each-group select="$list/item" group-by="@check">
      <xsl:element name="item">
        <xsl:attribute name="index" select="position()"/>
        <xsl:attribute name="check" select="current-grouping-key()"/>
        <xsl:copy-of select="current-group()[1]/w:num"/>
      </xsl:element>
    </xsl:for-each-group>
  </xsl:param>

  <!-- bookmarks -->
  <xsl:param name="bookmarks">
    <xsl:for-each-group select="fn:collection(concat($fragmenten.dir,'?select=document.xml;recurse=yes'))//w:bookmarkStart" group-by="@w:id">
      <xsl:element name="item">
        <xsl:attribute name="index" select="position()"/>
        <xsl:attribute name="id" select="current-grouping-key()"/>
        <xsl:attribute name="name" select="current-group()[1]/@w:name"/>
      </xsl:element>
    </xsl:for-each-group>
  </xsl:param>

  <!-- bouw het document op -->

  <xsl:template match="document">
    <xsl:element name="log">
      <xsl:element name="start">
        <xsl:value-of select="fn:current-dateTime()"/>
      </xsl:element>
      <xsl:element name="naam">
        <xsl:value-of select="$manifest/naam"/>
      </xsl:element>
      <xsl:element name="omgevingswetbesluit">
        <xsl:attribute name="id" select="$manifest/colofon/metadata/data[@name='ID03']/@value"/>
        <xsl:value-of select="$manifest/colofon/metadata/data[@name='ID01']/@value"/>
      </xsl:element>
      <xsl:element name="versie">
        <xsl:value-of select="$manifest/colofon/metadata/data[@name='ID04']/@value"/>
      </xsl:element>
      <!-- document -->
      <xsl:for-each select="fn:collection(concat($fragmenten.dir,'?select=document.xml;recurse=yes'))">
        <xsl:variable name="fragment" select="."/>
        <xsl:variable name="index" select="position()"/>
        <xsl:element name="document">
          <xsl:attribute name="index" select="$index"/>
          <xsl:attribute name="checksum" select="$manifest/document[$index]/checksum"/>
          <xsl:attribute name="titel" select="$manifest/document[$index]/titel"/>
          <xsl:apply-templates select="$fragment//w:instrText[fn:tokenize(.,'\s+')[2]='REF']" mode="log"/>
        </xsl:element>
      </xsl:for-each>
      <xsl:result-document href="{concat($word.dir,'/document.xml')}" method="xml" indent="no" version="1.0" encoding="UTF-8" standalone="yes">
        <xsl:element name="w:document">
          <xsl:copy-of select="namespace::*|@*"/>
          <xsl:element name="w:body">
            <xsl:apply-templates select="fn:collection(concat($template.dir,'?select=document.xml;recurse=yes'))//w:body/node()"/>
            <xsl:apply-templates select="fn:collection(concat($fragmenten.dir,'?select=document.xml;recurse=yes'))//w:body/node()"/>
          </xsl:element>
        </xsl:element>
      </xsl:result-document>
      <!-- styles -->
      <xsl:result-document href="{concat($word.dir,'/styles.xml')}" method="xml" indent="no" version="1.0" encoding="UTF-8" standalone="yes">
        <xsl:apply-templates select="fn:collection(concat($template.dir,'?select=styles.xml;recurse=yes'))"/>
      </xsl:result-document>
      <!-- footnotes -->
      <xsl:result-document href="{concat($word.dir,'/footnotes.xml')}" method="xml" indent="no" version="1.0" encoding="UTF-8" standalone="yes">
        <xsl:variable name="template" select="fn:collection(concat($template.dir,'?select=footnotes.xml;recurse=yes'))//w:footnotes"/>
        <xsl:element name="w:footnotes">
          <xsl:copy-of select="$template/self::w:footnotes/(namespace::*|@*)"/>
          <xsl:copy-of select="$default/w:footnote"/>
          <xsl:for-each select="$footnotes/item">
            <xsl:element name="w:footnote">
              <xsl:attribute name="w:id" select="@index"/>
              <xsl:copy-of select="w:footnote/node()"/>
            </xsl:element>
          </xsl:for-each>
        </xsl:element>
      </xsl:result-document>
      <!-- numbering -->
      <xsl:result-document href="{concat($word.dir,'/numbering.xml')}" method="xml" indent="no" version="1.0" encoding="UTF-8" standalone="yes">
        <xsl:variable name="template" select="fn:collection(concat($template.dir,'?select=numbering.xml;recurse=yes'))//w:numbering"/>
        <xsl:element name="w:numbering">
          <xsl:copy-of select="$template/self::w:numbering/(namespace::*|@*|w:abstractNum)"/>
          <xsl:for-each select="$numbering/item">
            <xsl:element name="w:num">
              <xsl:attribute name="w:numId" select="@index"/>
              <xsl:copy-of select="w:num/node()"/>
            </xsl:element>
          </xsl:for-each>
        </xsl:element>
      </xsl:result-document>
    </xsl:element>
  </xsl:template>

  <xsl:template match="asvg:svgBlip/@r:embed">
    <xsl:variable name="anchorId" select="ancestor::w:drawing/wp:inline/@wp14:anchorId"/>
    <xsl:variable name="eId" select="fn:string-join(('eId',$media/item[@name='asvg:svgBlip'][@anchorId=$anchorId]/@index))"/>
    <xsl:attribute name="{name()}" select="$eId"/>
  </xsl:template>

  <xsl:template match="a:blip/@r:embed">
    <xsl:variable name="anchorId" select="ancestor::w:drawing/wp:inline/@wp14:anchorId"/>
    <xsl:variable name="eId" select="fn:string-join(('eId',$media/item[@name='a:blip'][@anchorId=$anchorId]/@index))"/>
    <xsl:attribute name="{name()}" select="$eId"/>
  </xsl:template>

  <xsl:template match="w:footnoteReference">
    <xsl:variable name="file.name" select="fn:tokenize(base-uri(),$delimiter)[last()]"/>
    <xsl:variable name="w:id" select="@w:id"/>
    <xsl:variable name="w:footnote" select="fn:document(replace(base-uri(),$file.name,'footnotes.xml'),.)//w:footnote[@w:id=$w:id]"/>
    <xsl:variable name="check">
      <xsl:apply-templates select="$w:footnote/node()" mode="check"/>
    </xsl:variable>
    <xsl:element name="{name()}">
      <xsl:attribute name="w:id" select="$footnotes/item[@check=digest:md5Hex(fn:string-join($check))]/@index"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="w:numId[number(@w:val) gt 0]">
    <xsl:variable name="file.name" select="fn:tokenize(base-uri(),$delimiter)[last()]"/>
    <xsl:variable name="w:numId" select="@w:val"/>
    <xsl:variable name="w:num" select="fn:document(replace(base-uri(),$file.name,'numbering.xml'),.)//w:num[@w:numId=$w:numId]"/>
    <xsl:variable name="check">
      <xsl:apply-templates select="$w:num/node()" mode="check"/>
    </xsl:variable>
    <xsl:element name="{name()}">
      <xsl:attribute name="w:val" select="$numbering/item[@check=digest:md5Hex(fn:string-join($check))]/@index"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="w:bookmarkStart">
    <xsl:variable name="w:id" select="@w:id"/>
    <xsl:element name="{name()}">
      <xsl:attribute name="w:id" select="$bookmarks/item[@id=$w:id]/@index"/>
      <xsl:attribute name="w:name" select="$bookmarks/item[@id=$w:id]/@name"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="w:bookmarkEnd">
    <xsl:variable name="w:id" select="@w:id"/>
    <xsl:element name="{name()}">
      <xsl:attribute name="w:id" select="$bookmarks/item[@id=$w:id]/@index"/>
    </xsl:element>
  </xsl:template>

  <!-- genereren van diagnostische gegevens -->

  <xsl:template match="w:instrText" mode="log">
    <xsl:variable name="check" select="fn:tokenize(.,'_')[3]"/>
    <!-- checksum moet voorkomen in manifest.xml -->
    <xsl:choose>
      <xsl:when test="$manifest/document[checksum=$check]">
        <xsl:element name="verwijzing">
          <xsl:attribute name="checksum" select="$check"/>
        </xsl:element>
      </xsl:when>
      <xsl:when test="not($manifest/document[checksum=$check])">
        <xsl:variable name="document" select="fn:collection(concat($archief.dir,'?select=manifest.xml;recurse=yes'))/manifest/document[checksum=$check]"/>
        <xsl:choose>
          <xsl:when test="$document">
            <xsl:element name="verwijzing">
              <xsl:attribute name="status" select="string('error')"/>
              <xsl:attribute name="checksum" select="$check"/>
              <xsl:attribute name="titel" select="$document/titel"/>
              <xsl:attribute name="omgevingswetbesluit" select="$document/omgevingswetbesluit"/>
              <xsl:attribute name="versie" select="$document/versie"/>
              <xsl:attribute name="zoektekst" select="fn:string-join(ancestor::w:p//w:t)"/>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:element name="verwijzing">
              <xsl:attribute name="status" select="string('error')"/>
              <xsl:attribute name="checksum" select="$check"/>
              <xsl:attribute name="titel" select="string('onbekend')"/>
              <xsl:attribute name="zoektekst" select="fn:string-join(ancestor::w:p//w:t)"/>
            </xsl:element>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
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

  <!-- voor het berekenen van de checksum -->

  <xsl:template match="element()" mode="check">
    <xsl:value-of select="concat('[',./name())"/>
    <xsl:for-each select="attribute::*">
      <xsl:value-of select="concat(' ',./name(),'=''',.,'''')"/>
    </xsl:for-each>
    <xsl:apply-templates mode="check"/>
    <xsl:value-of select="string(']')"/>
  </xsl:template>

  <xsl:template match="text()" mode="check">
    <xsl:value-of select="string(': ''')"/>
    <xsl:value-of select="."/>
    <xsl:value-of select="string('''')"/>
  </xsl:template>

</xsl:stylesheet>