<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:my="functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:digest="java:org.apache.commons.codec.digest.DigestUtils" xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas" xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:rel="http://schemas.openxmlformats.org/package/2006/relationships" xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:w10="urn:schemas-microsoft-com:office:word" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml" xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup" xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk" xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture" xmlns:a14="http://schemas.microsoft.com/office/drawing/2010/main" xmlns:asvg="http://schemas.microsoft.com/office/drawing/2016/SVG/main" mc:Ignorable="w14 wp14">
  <xsl:output method="xml" version="1.0" indent="yes" encoding="UTF-8" standalone="yes"/>

  <xsl:param name="base.dir" select="string('C:\Werkbestanden\Geonovum\Beheer\tpod_splitsen')"/>
  <xsl:param name="input.name"/>

  <!-- gebruikte directories -->
  <xsl:param name="word.dir" select="fn:string-join((fn:tokenize($base.dir,'\\'),'temp','template','word'),'/')"/>
  <xsl:param name="checksum.dir" select="fn:string-join((fn:tokenize($base.dir,'\\'),'temp','checksum'),'/')"/>

  <!-- gebruikte documenten -->
  <xsl:param name="comments" select="fn:string-join(('file:',$word.dir,'comments.xml'),'/')"/>
  <xsl:param name="endnotes" select="fn:string-join(('file:',$word.dir,'endnotes.xml'),'/')"/>
  <xsl:param name="footnotes" select="fn:string-join(('file:',$word.dir,'footnotes.xml'),'/')"/>
  <xsl:param name="numbering" select="fn:string-join(('file:',$word.dir,'numbering.xml'),'/')"/>
  <xsl:param name="settings" select="fn:string-join(('file:',$word.dir,'settings.xml'),'/')"/>
  <xsl:param name="styles" select="fn:string-join(('file:',$word.dir,'styles.xml'),'/')"/>

  <xsl:param name="document.rels" select="fn:string-join(('file:',$word.dir,'_rels/document.xml.rels'),'/')"/>
  <xsl:param name="header2.rels" select="fn:string-join(('file:',$word.dir,'_rels/header2.xml.rels'),'/')"/>
  <xsl:param name="header3.rels" select="fn:string-join(('file:',$word.dir,'_rels/header3.xml.rels'),'/')"/>

  <!-- gebruikte collecties -->
  <xsl:param name="checksum.list" select="collection(concat('file:/',$checksum.dir,'?select=*.xml'))//file"/>

  <!-- verwijzingen -->
  <xsl:param name="reference.name" select="//w:instrText[tokenize(.,'\s+')[2]='REF']/text()/tokenize(.,'\s+')[3]"/>
  <xsl:param name="reference.list">
    <xsl:for-each-group select="w:document/w:body/*" group-starting-with="w:p[w:pPr/w:pStyle/@w:val eq $TOC[1]][1]">
      <xsl:choose>
        <xsl:when test="position() eq 1">
          <!-- voorwerk -->
        </xsl:when>
        <xsl:otherwise>
          <!-- tekstfragmenten -->
          <xsl:for-each-group select="current-group()" group-starting-with="w:p[fn:index-of($TOC,(w:pPr/w:pStyle/@w:val,'Geen')[1]) gt 0]">
            <xsl:variable name="checksum">
              <xsl:variable name="check">
                <xsl:apply-templates select="current-group()" mode="check"/>
              </xsl:variable>
              <xsl:value-of select="digest:md5Hex(fn:string-join($check))"/>
            </xsl:variable>
            <xsl:element name="document">
              <xsl:attribute name="index" select="position()"/>
              <xsl:element name="checksum">
                <xsl:value-of select="$checksum"/>
              </xsl:element>
              <xsl:for-each select="current-group()//w:bookmarkStart[@w:name=$reference.name]">
                <xsl:element name="bookmark">
                  <xsl:attribute name="id" select="@w:id"/>
                  <xsl:attribute name="name" select="@w:name"/>
                  <xsl:value-of select="fn:string-join(('_Ref',$checksum,position()),'_')"/>
                </xsl:element>
              </xsl:for-each>
            </xsl:element>
          </xsl:for-each-group>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
  </xsl:param>

  <!-- globale parameters -->
  <xsl:param name="omgevingswetbesluit" select="document($settings,.)//w:settings/w:docVars/w:docVar[@w:name='ID01']/@w:val"/>
  <xsl:param name="omgevingswetbesluit.id" select="document($settings,.)//w:settings/w:docVars/w:docVar[@w:name='ID03']/@w:val"/>
  <xsl:param name="versie" select="document($settings,.)//w:settings/w:docVars/w:docVar[@w:name='ID04']/@w:val"/>

  <xsl:template name="colofon">
    <xsl:param name="group"/>
    <xsl:variable name="href" select="string('000_Colofon')"/>
    <xsl:element name="colofon">
      <xsl:attribute name="index" select="0"/>
      <xsl:element name="naam">
        <xsl:value-of select="concat($href,'.docx')"/>
      </xsl:element>
      <xsl:element name="omgevingswetbesluit">
        <xsl:attribute name="id" select="$omgevingswetbesluit.id"/>
        <xsl:value-of select="$omgevingswetbesluit"/>
      </xsl:element>
      <xsl:element name="afbeelding">
        <xsl:attribute name="index" select="position()"/>
        <xsl:element name="naam">
          <xsl:value-of select="$checksum.list[not(id)]/rename"/>
        </xsl:element>
        <xsl:element name="omgevingswetbesluit">
          <xsl:attribute name="id" select="$omgevingswetbesluit.id"/>
          <xsl:value-of select="$omgevingswetbesluit"/>
        </xsl:element>
        <xsl:element name="type">
          <xsl:value-of select="$checksum.list[not(id)]/type"/>
        </xsl:element>
        <xsl:element name="checksum">
          <xsl:value-of select="$checksum.list[not(id)]/checksum"/>
        </xsl:element>
      </xsl:element>
      <xsl:element name="metadata">
        <xsl:for-each select="document($settings,.)//w:settings/w:docVars/w:docVar[starts-with(@w:name,'ID')]">
          <xsl:element name="data">
            <xsl:attribute name="name">
              <xsl:value-of select="./@w:name"/>
            </xsl:attribute>
            <xsl:attribute name="value">
              <xsl:value-of select="./@w:val"/>
            </xsl:attribute>
          </xsl:element>
        </xsl:for-each>
      </xsl:element>
      <xsl:element name="versiehistorie">
        <xsl:for-each-group select="$group[self::w:tbl][1]/w:tr[descendant::w:t]" group-by="fn:string-join(w:tc[1]//w:t)">
          <xsl:choose>
            <xsl:when test="position() gt 1">
              <xsl:element name="versie">
                <xsl:attribute name="nummer" select="current-grouping-key()"/>
                <xsl:for-each select="current-group()">
                  <xsl:element name="wijziging">
                    <xsl:attribute name="datum" select="fn:format-date(xs:date(fn:string-join(w:tc[2]//w:t)),'[Y0001]-[M01]-[D01]')"/>
                    <xsl:for-each select="w:tc[3]/w:p">
                      <xsl:element name="alinea">
                        <xsl:attribute name="opmaak" select="(fn:document($styles,.)/w:styles/w:style[@w:type='paragraph'][@w:styleId=current()/w:pPr/w:pStyle/@w:val]/w:name/@w:val,'Standaard')[1]"/>
                        <xsl:value-of select="fn:string-join(w:r/w:t)"/>
                      </xsl:element>
                    </xsl:for-each>
                  </xsl:element>
                </xsl:for-each>
              </xsl:element>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each-group>
      </xsl:element>
    </xsl:element>
    <!-- maak document.xml -->
    <xsl:result-document encoding="UTF-8" href="{concat($href,'/document.xml')}" indent="no" method="xml" version="1.0">
      <xsl:element name="w:document">
        <xsl:copy-of select="ancestor::w:document/namespace::*"/>
        <xsl:copy-of select="ancestor::w:document/@*"/>
        <xsl:element name="w:body">
          <xsl:apply-templates select="$group/self::w:p|$group/self::w:tbl"/>
        </xsl:element>
      </xsl:element>
    </xsl:result-document>
    <!-- maak document.xml.rels -->
    <xsl:result-document encoding="UTF-8" href="000_Colofon/document.xml.rels" indent="no" method="xml" version="1.0">
      <xsl:element name="Relationships" namespace="http://schemas.openxmlformats.org/package/2006/relationships">
        <xsl:for-each select="document($document.rels,.)//Relationship[(tokenize(@Type,'/')[last()] ne 'image')]" xpath-default-namespace="http://schemas.openxmlformats.org/package/2006/relationships">
          <xsl:copy-of select="."/>
        </xsl:for-each>
      </xsl:element>
    </xsl:result-document>
    <!-- maak headere2.xml.rels -->
    <xsl:result-document encoding="UTF-8" href="000_Colofon/header2.xml.rels" indent="no" method="xml" version="1.0">
      <xsl:element name="Relationships" namespace="http://schemas.openxmlformats.org/package/2006/relationships">
        <xsl:element name="Relationship" namespace="http://schemas.openxmlformats.org/package/2006/relationships">
          <xsl:attribute name="Id" select="string('rId1')"/>
          <xsl:attribute name="Type" select="string('http://schemas.openxmlformats.org/officeDocument/2006/relationships/image')"/>
          <xsl:attribute name="Target" select="concat('media/',$checksum.list[not(id)]/rename)"/>
        </xsl:element>
      </xsl:element>
    </xsl:result-document>
    <!-- maak headere3.xml.rels -->
    <xsl:result-document encoding="UTF-8" href="000_Colofon/header3.xml.rels" indent="no" method="xml" version="1.0">
      <xsl:element name="Relationships" namespace="http://schemas.openxmlformats.org/package/2006/relationships">
        <xsl:element name="Relationship" namespace="http://schemas.openxmlformats.org/package/2006/relationships">
          <xsl:attribute name="Id" select="string('rId1')"/>
          <xsl:attribute name="Type" select="string('http://schemas.openxmlformats.org/officeDocument/2006/relationships/image')"/>
          <xsl:attribute name="Target" select="concat('media/',$checksum.list[not(id)]/rename)"/>
        </xsl:element>
      </xsl:element>
    </xsl:result-document>
  </xsl:template>

  <!-- splits bestand op op basis van inhoudsopgave -->
  <xsl:param name="TOC" select="('Kop1','Kop2','Kop3','Kop4','Kop5','Kop2bijlage','Kop3bijlage')"/>

  <xsl:template name="tekstfragmenten">
    <xsl:param name="group"/>
    <xsl:for-each-group select="$group" group-starting-with="w:p[fn:index-of($TOC,(w:pPr/w:pStyle/@w:val,'Geen')[1]) gt 0]">
      <xsl:variable name="index" select="position()"/>
      <xsl:variable name="href">
        <xsl:variable name="check">
          <xsl:apply-templates select="current-group()[self::w:p][1]" mode="check"/>
        </xsl:variable>
        <xsl:value-of select="fn:string-join((fn:format-number($index,'000'),my:uri($check)),'_')"/>
      </xsl:variable>
      <xsl:variable name="titel" select="fn:string-join(current-group()[self::w:p][1]//w:t)"/>
      <xsl:variable name="niveau" select="fn:index-of($TOC,(current-group()[self::w:p][1]/w:pPr/w:pStyle/@w:val,'Geen')[1])"/>
      <xsl:variable name="checksum">
        <xsl:value-of select="$reference.list/document[@index=$index]/checksum"/>
      </xsl:variable>
      <!-- maak de elementen voor het manifest-bestand -->
      <xsl:element name="document">
        <xsl:attribute name="index" select="$index"/>
        <xsl:element name="naam">
          <xsl:value-of select="concat($href,'.docx')"/>
        </xsl:element>
        <xsl:element name="omgevingswetbesluit">
          <xsl:attribute name="id" select="$omgevingswetbesluit.id"/>
          <xsl:value-of select="$omgevingswetbesluit"/>
        </xsl:element>
        <xsl:element name="versie">
          <xsl:value-of select="$versie"/>
        </xsl:element>
        <xsl:element name="titel">
          <xsl:value-of select="$titel"/>
        </xsl:element>
        <xsl:element name="niveau">
          <xsl:value-of select="$niveau"/>
        </xsl:element>
        <xsl:element name="checksum">
          <xsl:value-of select="$checksum"/>
        </xsl:element>
        <xsl:for-each select="current-group()//w:drawing//element()[@r:embed]">
          <xsl:variable name="rId" select="@r:embed" as="xs:string"/>
          <xsl:element name="afbeelding">
            <xsl:attribute name="index" select="position()"/>
            <xsl:element name="naam">
              <xsl:value-of select="$checksum.list[id=$rId]/rename"/>
            </xsl:element>
            <xsl:element name="omgevingswetbesluit">
              <xsl:attribute name="id" select="$omgevingswetbesluit.id"/>
              <xsl:value-of select="$omgevingswetbesluit"/>
            </xsl:element>
            <xsl:element name="type">
              <xsl:value-of select="$checksum.list[id=$rId]/type"/>
            </xsl:element>
            <xsl:element name="checksum">
              <xsl:value-of select="$checksum.list[id=$rId]/checksum"/>
            </xsl:element>
          </xsl:element>
        </xsl:for-each>
      </xsl:element>
      <!-- maak document.xml -->
      <xsl:result-document encoding="UTF-8" href="{concat($href,'/document.xml')}" indent="no" method="xml" version="1.0">
        <xsl:element name="w:document">
          <xsl:copy-of select="ancestor::w:document/namespace::*"/>
          <xsl:copy-of select="ancestor::w:document/@*"/>
          <xsl:element name="w:body">
            <xsl:apply-templates select="current-group()"/>
          </xsl:element>
        </xsl:element>
      </xsl:result-document>
      <!-- maak document.xml.rels -->
      <xsl:result-document encoding="UTF-8" href="{concat($href,'/document.xml.rels')}" indent="no" method="xml" version="1.0">
        <xsl:element name="Relationships" namespace="http://schemas.openxmlformats.org/package/2006/relationships">
          <xsl:for-each select="document($document.rels,.)//Relationship[(tokenize(@Type,'/')[last()] ne 'image')]" xpath-default-namespace="http://schemas.openxmlformats.org/package/2006/relationships">
            <xsl:copy-of select="."/>
          </xsl:for-each>
          <xsl:for-each select="current-group()//w:drawing//element()[@r:embed]">
            <xsl:element name="Relationship" namespace="http://schemas.openxmlformats.org/package/2006/relationships">
              <xsl:variable name="rId" select="@r:embed" as="xs:string"/>
              <xsl:attribute name="Id" select="$checksum.list[id=$rId]/id"/>
              <xsl:attribute name="Type" select="string('http://schemas.openxmlformats.org/officeDocument/2006/relationships/image')"/>
              <xsl:attribute name="Target" select="concat('media/',$checksum.list[id=$rId]/rename)"/>
            </xsl:element>
          </xsl:for-each>
        </xsl:element>
      </xsl:result-document>
      <!-- maak headere2.xml.rels -->
      <xsl:result-document encoding="UTF-8" href="{concat($href,'/header2.xml.rels')}" indent="no" method="xml" version="1.0">
        <xsl:element name="Relationships" namespace="http://schemas.openxmlformats.org/package/2006/relationships">
          <xsl:element name="Relationship" namespace="http://schemas.openxmlformats.org/package/2006/relationships">
            <xsl:attribute name="Id" select="string('rId1')"/>
            <xsl:attribute name="Type" select="string('http://schemas.openxmlformats.org/officeDocument/2006/relationships/image')"/>
            <xsl:attribute name="Target" select="concat('media/',$checksum.list[not(id)]/rename)"/>
          </xsl:element>
        </xsl:element>
      </xsl:result-document>
      <!-- maak headere3.xml.rels -->
      <xsl:result-document encoding="UTF-8" href="{concat($href,'/header3.xml.rels')}" indent="no" method="xml" version="1.0">
        <xsl:element name="Relationships" namespace="http://schemas.openxmlformats.org/package/2006/relationships">
          <xsl:element name="Relationship" namespace="http://schemas.openxmlformats.org/package/2006/relationships">
            <xsl:attribute name="Id" select="string('rId1')"/>
            <xsl:attribute name="Type" select="string('http://schemas.openxmlformats.org/officeDocument/2006/relationships/image')"/>
            <xsl:attribute name="Target" select="concat('media/',$checksum.list[not(id)]/rename)"/>
          </xsl:element>
        </xsl:element>
      </xsl:result-document>
    </xsl:for-each-group>
  </xsl:template>

  <!-- verwerk de documenten -->

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

  <!-- verwerk de root -->

  <xsl:template match="/">
    <xsl:element name="manifest">
      <xsl:element name="naam">
        <xsl:value-of select="$input.name"/>
      </xsl:element>
      <xsl:element name="datum">
        <xsl:value-of select="fn:current-dateTime()"/>
      </xsl:element>
      <xsl:for-each-group select="w:document/w:body/*" group-starting-with="w:p[w:pPr/w:pStyle/@w:val eq $TOC[1]][1]">
        <xsl:choose>
          <xsl:when test="position() eq 1">
            <!-- colofon -->
            <xsl:call-template name="colofon">
              <xsl:with-param name="group" select="current-group()"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <!-- tekstfragmenten -->
            <xsl:call-template name="tekstfragmenten">
              <xsl:with-param name="group" select="current-group()"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:element>
  </xsl:template>

  <xsl:template match="w:bookmarkStart">
    <xsl:variable name="bookmark" select="$reference.list/document/bookmark[@id=current()/@w:id]"/>
    <xsl:choose>
      <xsl:when test="$bookmark">
        <xsl:element name="{name()}">
          <xsl:apply-templates select="namespace::*|@*"/>
          <xsl:attribute name="w:name" select="$bookmark"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <!-- doe niets -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="w:bookmarkEnd">
    <xsl:variable name="bookmark" select="$reference.list/document/bookmark[@id=current()/@w:id]"/>
    <xsl:choose>
      <xsl:when test="$bookmark">
        <xsl:element name="{name()}">
          <xsl:apply-templates select="namespace::*|@*"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <!-- doe niets -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="w:instrText">
    <xsl:variable name="bookmark.name" select="tokenize(text(),'\s+')[3]"/>
    <xsl:variable name="bookmark" select="$reference.list/document/bookmark[@name=$bookmark.name]"/>
    <xsl:choose>
      <xsl:when test="$bookmark">
        <xsl:element name="{name()}">
          <xsl:apply-templates select="namespace::*|@*"/>
          <xsl:value-of select="replace(text(),$bookmark.name,$bookmark/text())"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="{name()}">
          <xsl:apply-templates select="namespace::*|@*|node()"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- verwerk elementen voor berekening van de checksum -->

  <xsl:template match="element()" mode="check">
    <xsl:apply-templates mode="check"/>
  </xsl:template>

  <xsl:template match="text()" mode="check">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="w:tc" mode="check">
    <xsl:apply-templates mode="check"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="w:p" mode="check">
    <xsl:for-each-group select="*" group-starting-with="w:r[w:fldChar]">
      <xsl:choose>
        <xsl:when test="current-group()[w:fldChar/@w:fldCharType='begin']">
          <xsl:value-of select="concat('[',fn:string-join((tokenize(fn:string-join(current-group()//w:instrText),'\s+|&quot;|\* MERGEFORMAT')[. ne '']),' '),']')"/>
        </xsl:when>
        <xsl:when test="current-group()[w:fldChar/@w:fldCharType='separate']">
          <!-- doe niets -->
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="current-group()" mode="check"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
    <xsl:if test="following-sibling::w:p">
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="w:r" mode="check">
    <xsl:apply-templates mode="check"/>
  </xsl:template>

  <xsl:template match="w:t" mode="check">
    <xsl:apply-templates mode="check"/>
  </xsl:template>

  <xsl:template match="w:tab" mode="check">
    <xsl:text>&#9;</xsl:text>
  </xsl:template>

  <xsl:template match="w:instrText" mode="check">
    <!-- doe niets -->
  </xsl:template>

  <xsl:template match="w:fldSimple" mode="check">
    <xsl:value-of select="concat('[',normalize-space(@w:instr),']')"/>
  </xsl:template>

  <xsl:template match="w:EndnoteReference" mode="check">
    <xsl:variable name="id" select="@w:id"/>
    <xsl:text>[</xsl:text>
    <xsl:apply-templates select="fn:document($endnotes,.)/w:Endnotes/w:Endnote[@w:id=$id]" mode="check"/>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template match="w:EndnoteRef" mode="check">
    <xsl:text>ENDNOTEREF</xsl:text>
  </xsl:template>

  <xsl:template match="w:footnoteReference" mode="check">
    <xsl:variable name="id" select="@w:id"/>
    <xsl:text>[</xsl:text>
    <xsl:apply-templates select="fn:document($footnotes,.)/w:footnotes/w:footnote[@w:id=$id]" mode="check"/>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template match="w:footnoteRef" mode="check">
    <xsl:text>FOOTNOTEREF</xsl:text>
  </xsl:template>

  <xsl:template match="w:drawing" mode="check">
    <xsl:text>[IMAGEREF]</xsl:text>
  </xsl:template>

  <!-- functies -->

  <xsl:function name="my:uri">
    <xsl:param name="string"/>
    <xsl:variable name="check_string">
      <!-- controleer op velden, noten, enzovoorts -->
      <xsl:for-each select="tokenize($string,'\[|\]')">
        <xsl:choose>
          <xsl:when test="contains(.,'NOTEREF')">
            <!-- doe niets -->
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="fn:string-to-codepoints(.)">
              <xsl:choose>
                <xsl:when test="(. ge 48) and (. le 57)">
                  <!-- cijfers -->
                  <node><xsl:value-of select="."/></node>
                </xsl:when>
                <xsl:when test="((. ge 65) and (. le 90)) or ((. ge 97) and (. le 122))">
                  <!-- letters -->
                  <node><xsl:value-of select="."/></node>
                </xsl:when>
                <xsl:when test="(. eq 45)">
                  <!-- dash -->
                  <node><xsl:value-of select="."/></node>
                </xsl:when>
                <xsl:when test="(. ge 224) and (. le 229)">
                  <!-- leestekens a -->
                  <node><xsl:value-of select="97"/></node>
                </xsl:when>
                <xsl:when test="(. eq 231)">
                  <!-- leestekens c -->
                  <node><xsl:value-of select="99"/></node>
                </xsl:when>
                <xsl:when test="(. ge 232) and (. le 235)">
                  <!-- leestekens e -->
                  <node><xsl:value-of select="101"/></node>
                </xsl:when>
                <xsl:when test="(. ge 236) and (. le 239)">
                  <!-- leestekens i -->
                  <node><xsl:value-of select="105"/></node>
                </xsl:when>
                <xsl:when test="(. eq 241)">
                  <!-- leestekens n -->
                  <node><xsl:value-of select="110"/></node>
                </xsl:when>
                <xsl:when test="(. ge 242) and (. le 246)">
                  <!-- leestekens o -->
                  <node><xsl:value-of select="111"/></node>
                </xsl:when>
                <xsl:when test="(. ge 249) and (. le 252)">
                  <!-- leestekens u -->
                  <node><xsl:value-of select="117"/></node>
                </xsl:when>
                <xsl:when test="(. eq 253) and (. eq 255)">
                  <!-- leestekens y -->
                  <node><xsl:value-of select="121"/></node>
                </xsl:when>
                <xsl:when test="(. eq 32)">
                  <!-- spatie -->
                  <node><xsl:value-of select="95"/></node>
                </xsl:when>
              </xsl:choose>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="fn:codepoints-to-string($check_string/node)"/>
  </xsl:function>

</xsl:stylesheet>