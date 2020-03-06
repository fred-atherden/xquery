<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ali="http://www.niso.org/schemas/ali/1.0/"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    exclude-result-prefixes="xs" 
    version="2.0">

    <xsl:output 
        method="xml"
        encoding="UTF-8"
        omit-xml-declaration="no"
        indent="no"/>
    
    <xsl:template match="/">
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE article PUBLIC "-//NLM//DTD JATS (Z39.96) Journal Archiving and Interchange DTD v1.1 20151215//EN"  "JATS-archivearticle1.dtd"&gt;</xsl:text>
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*|@*|text()|comment()|processing-instruction()">
        <xsl:copy>
            <xsl:apply-templates select="*|@*|text()|comment()|processing-instruction()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="abstract">
        <xsl:copy-of select="."/>
        <xsl:for-each
            select="./parent::article-meta/custom-meta-group/custom-meta[meta-name = 'Author impact statement']/meta-value">
            <xsl:element name="abstract">
                <xsl:attribute name="abstract-type">
                    <xsl:value-of select="'toc'"/>
                </xsl:attribute>
                <xsl:element name="p">
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="article-categories">
        <xsl:element name="article-categories">
            <xsl:element name="subj-group">
                <xsl:attribute name="subj-group-type">
                    <xsl:value-of select="'heading'"/>
                </xsl:attribute>
                <xsl:copy-of select="./subj-group[@subj-group-type='display-channel']/subject"/>
            </xsl:element>
            <xsl:choose>
                <xsl:when test="./subj-group[not(contains(@subj-group-type,'display-channel'))]">
                    <xsl:element name="subj-group">
                        <xsl:attribute name="subj-group-type">
                            <xsl:value-of select="'subject'"/>
                        </xsl:attribute>
                        <xsl:copy-of select="./subj-group[not(contains(@subj-group-type,'display-channel'))]/subject"/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <xsl:template match="code">
        <xsl:element name="preformat">
            <xsl:copy-of select="./text()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="contrib-group[not(@*)]">
        <xsl:element name="contrib-group">
            <xsl:attribute name="content-type">
                <xsl:value-of select="'author'"/>
            </xsl:attribute>
        <xsl:apply-templates/>
        </xsl:element>
        <xsl:element name="author-notes">
            <xsl:for-each select="./ancestor::article/back//fn-group[@content-type='competing-interest']/fn">
                <xsl:copy-of select="."></xsl:copy-of>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>

    <xsl:template match="custom-meta-group">
        <xsl:choose>
            <xsl:when test="count(./custom-meta) = 1"/>
            <xsl:otherwise>
                <xsl:element name="custom-meta-group">
                    <xsl:for-each select="./custom-meta[meta-name != 'Author impact statement']">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="element-citation[@publication-type = 'preprint']">
        <xsl:element name="element-citation">
            <xsl:attribute name="publication-type">
                <xsl:value-of select="'pre-print'"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="fig/graphic">
        <xsl:element name="graphic">
            <xsl:copy-of select="@*[name()!='xlink:href']"/>
            <xsl:attribute name="xlink:href">
                <xsl:variable name="new-string" select="string-join(tokenize(@xlink:href,'\.')[.!='tif' and .!='tiff'],'.')"/>
                <xsl:value-of select="concat($new-string,'.jpg')"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="fn-group[@content-type='competing-interest']"/>
    
    <xsl:template match="contrib[@contrib-type='author']/xref[@ref-type='fn']">
        <xsl:variable name="rid" select="./@rid"/>
        <xsl:variable name="target-type" select="./ancestor::article//fn[@id=$rid]/@fn-type"/>
        <xsl:choose>
            <xsl:when test="$target-type='COI-statement'">
                <xsl:element name="xref">
                    <xsl:attribute name="ref-type">
                        <xsl:value-of select="'author-notes'"/>
                    </xsl:attribute>
                    <xsl:attribute name="rid">
                        <xsl:value-of select="$rid"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="history"/>
    
    <xsl:template match="kwd-group[@kwd-group-type='author-keywords']">
        <xsl:element name="kwd-group">
            <xsl:attribute name="kwd-group-type">
                <xsl:value-of select="'author-generated'"/>
            </xsl:attribute>
            <xsl:apply-templates select="./kwd"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="kwd-group[@kwd-group-type='research-organism']/title"/>
    
    <xsl:template match="named-content[@content-type='city']">
        <xsl:element name="city">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
