<?xml version="1.0" encoding="UTF-8"?>
<!--
  assays.xsl - human-readable view of an <assays> document (resources/
  methods2aop_schema_proposal.xsd). XSLT 1.0 so that both browsers and lxml can run it.
  Two views: assays grouped by Key Event (each row shows its technique), and techniques
  (each with the assays and Key Events that use it). GUIDs are resolved to the readable
  ids through the document's <lookup> section; ontology terms (and the object / process /
  action of an assay's optional <kec-triple>) link to a search on the EBI Ontology Lookup
  Service.
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:m="http://www.aopkb.org/aop-xml">

  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <xsl:key name="by-ke" match="m:assay" use="@ke-id"/>
  <xsl:key name="by-tech" match="m:assay" use="@technique-id"/>
  <xsl:key name="by-tech-ke" match="m:assay" use="concat(@technique-id, '|', @ke-id)"/>
  <xsl:key name="technique" match="m:technique" use="@id"/>
  <xsl:key name="ke-ref" match="m:key-event-reference" use="@id"/>
  <xsl:key name="tech-ref" match="m:technique-reference" use="@id"/>
  <xsl:key name="assay-ref" match="m:assay-reference" use="@id"/>

  <xsl:template match="/m:assays">
    <html lang="en">
      <head>
        <meta charset="UTF-8"/>
        <title>Curated assays</title>
        <style>
          body { font-family: sans-serif; margin: 1.5em; color: #222; }
          h1 { font-size: 1.4em; }
          h2 { font-size: 1.1em; margin-top: 1.6em; border-bottom: 1px solid #ccc; }
          table { border-collapse: collapse; width: 100%; font-size: 0.85em; }
          th, td { border: 1px solid #ddd; padding: 4px 6px; vertical-align: top;
                   text-align: left; }
          th { background: #f3f3f3; }
          .meta { color: #666; font-size: 0.85em; }
          .tag { display: inline-block; background: #eef; border-radius: 3px;
                 padding: 0 4px; margin: 1px; }
          .ev { color: #555; font-style: italic; }
        </style>
      </head>
      <body>
        <h1>Curated assays</h1>
        <p class="meta">
          <xsl:value-of select="count(m:assay)"/> assays,
          <xsl:value-of select="count(m:assay[generate-id() = generate-id(key('by-ke', @ke-id)[1])])"/>
          Key Events,
          <xsl:value-of select="count(m:techniques/m:technique)"/> techniques.
          <a href="#by-ke">Assays by Key Event</a> | <a href="#by-technique">Techniques</a>
        </p>

        <h1 id="by-ke">Assays by Key Event</h1>
        <xsl:for-each select="m:assay[generate-id() = generate-id(key('by-ke', @ke-id)[1])]">
          <xsl:variable name="ke-label">
            <xsl:call-template name="ke-label"><xsl:with-param name="id" select="@ke-id"/></xsl:call-template>
          </xsl:variable>
          <h2 id="{$ke-label}">
            <xsl:value-of select="$ke-label"/>
            <span class="meta"> - <xsl:value-of select="count(key('by-ke', @ke-id))"/> assays</span>
          </h2>
          <table>
            <tr>
              <th>Assay</th><th>Technique</th><th>Type</th><th>System</th><th>Endpoint</th>
              <th>Ontology terms</th><th>KEC triple</th><th>Guideline</th><th>Throughput</th>
              <th>Support</th><th>Evidence</th>
            </tr>
            <xsl:apply-templates select="key('by-ke', @ke-id)"/>
          </table>
        </xsl:for-each>

        <h1 id="by-technique">Techniques</h1>
        <xsl:for-each select="m:techniques/m:technique">
          <xsl:variable name="tid" select="@id"/>
          <h2>
            <xsl:value-of select="m:name"/>
            <span class="meta">
              [<xsl:call-template name="tech-label"><xsl:with-param name="id" select="$tid"/></xsl:call-template>]
              - <xsl:value-of select="count(key('by-tech', $tid))"/> assays in
              <xsl:value-of select="count(/m:assays/m:assay[generate-id() = generate-id(key('by-tech-ke', concat($tid, '|', @ke-id))[1]) and @technique-id = $tid])"/>
              Key Events
            </span>
          </h2>
          <xsl:if test="m:synonym">
            <p class="meta">Also written as:
              <xsl:for-each select="m:synonym">
                <span class="tag"><xsl:value-of select="."/></span>
              </xsl:for-each>
            </p>
          </xsl:if>
          <p>
            <xsl:for-each select="/m:assays/m:assay[@technique-id = $tid][generate-id() = generate-id(key('by-tech-ke', concat($tid, '|', @ke-id))[1])]">
              <a class="tag">
                <xsl:attribute name="href">
                  <xsl:text>#</xsl:text>
                  <xsl:call-template name="ke-label"><xsl:with-param name="id" select="@ke-id"/></xsl:call-template>
                </xsl:attribute>
                <xsl:call-template name="ke-label"><xsl:with-param name="id" select="@ke-id"/></xsl:call-template>
              </a>
            </xsl:for-each>
          </p>
          <table>
            <tr><th>Key Event</th><th>Assay name</th><th>Endpoint</th><th>Support</th></tr>
            <xsl:for-each select="key('by-tech', $tid)">
              <tr>
                <td><xsl:call-template name="ke-label"><xsl:with-param name="id" select="@ke-id"/></xsl:call-template></td>
                <td><xsl:value-of select="m:method/m:assay-name"/></td>
                <td><xsl:value-of select="m:method/m:measured-endpoint"/></td>
                <td><xsl:value-of select="@support"/></td>
              </tr>
            </xsl:for-each>
          </table>
        </xsl:for-each>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="m:assay">
    <xsl:variable name="mm" select="m:method"/>
    <tr id="{@id}">
      <td>
        <b><xsl:value-of select="$mm/m:assay-name"/></b>
        <xsl:variable name="aid" select="key('assay-ref', @id)/@assay-id"/>
        <xsl:if test="$aid"><br/><span class="meta"><xsl:value-of select="$aid"/></span></xsl:if>
        <xsl:if test="$mm/m:description">
          <br/><span class="meta"><xsl:value-of select="$mm/m:description"/></span>
        </xsl:if>
      </td>
      <td>
        <xsl:value-of select="key('technique', @technique-id)/m:name"/>
      </td>
      <td><xsl:value-of select="$mm/m:method-type"/></td>
      <td>
        <xsl:for-each select="$mm/m:cell-types/m:cell-type | $mm/m:organ-tissues/m:organ-tissue | $mm/m:species/m:taxon">
          <span class="tag"><xsl:value-of select="."/></span>
        </xsl:for-each>
      </td>
      <td>
        <xsl:value-of select="$mm/m:measured-endpoint"/>
        <xsl:if test="$mm/m:endpoint-direction and $mm/m:endpoint-direction != 'not_specified'">
          (<xsl:value-of select="$mm/m:endpoint-direction"/>)
        </xsl:if>
      </td>
      <td>
        <xsl:for-each select="$mm/m:ontology-terms/m:ontology-term">
          <div><xsl:call-template name="term"/></div>
        </xsl:for-each>
      </td>
      <td>
        <xsl:for-each select="m:kec-triple/m:object | m:kec-triple/m:process | m:kec-triple/m:action">
          <div>
            <span class="meta"><xsl:value-of select="local-name()"/>: </span>
            <xsl:call-template name="term"/>
          </div>
        </xsl:for-each>
      </td>
      <td><xsl:value-of select="$mm/m:guideline"/></td>
      <td><xsl:value-of select="$mm/m:throughput"/></td>
      <td><xsl:value-of select="@support"/></td>
      <td class="ev">
        <xsl:for-each select="$mm/m:evidence/m:source-text">
          <div><xsl:value-of select="."/></div>
        </xsl:for-each>
      </td>
    </tr>
  </xsl:template>

  <!-- an ontology-term-type element (ontology-term, or a kec-triple object / process /
       action): label linked to an OLS search when it has an IRI, then the ontology prefix -->
  <xsl:template name="term">
    <xsl:choose>
      <xsl:when test="m:iri">
        <a target="_blank">
          <xsl:attribute name="href">
            <xsl:text>https://www.ebi.ac.uk/ols4/search?q=</xsl:text>
            <xsl:call-template name="local-id"><xsl:with-param name="iri" select="m:iri"/></xsl:call-template>
          </xsl:attribute>
          <xsl:value-of select="m:label"/>
        </a>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="m:label"/></xsl:otherwise>
    </xsl:choose>
    <xsl:if test="m:ontology"> <span class="meta">[<xsl:value-of select="m:ontology"/>]</span></xsl:if>
  </xsl:template>

  <!-- Key Event GUID -> "KE123" through the lookup (the GUID itself if not listed) -->
  <xsl:template name="ke-label">
    <xsl:param name="id"/>
    <xsl:variable name="ref" select="key('ke-ref', $id)"/>
    <xsl:choose>
      <xsl:when test="$ref">KE<xsl:value-of select="$ref/@aop-wiki-id"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="$id"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- technique GUID -> "TECH123" through the lookup -->
  <xsl:template name="tech-label">
    <xsl:param name="id"/>
    <xsl:variable name="ref" select="key('tech-ref', $id)"/>
    <xsl:choose>
      <xsl:when test="$ref"><xsl:value-of select="$ref/@technique-id"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="$id"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- the accession after the last '/' or '#' of an IRI (GO_0006954, BAO_0000179) -->
  <xsl:template name="local-id">
    <xsl:param name="iri"/>
    <xsl:choose>
      <xsl:when test="contains($iri, '#')">
        <xsl:call-template name="local-id">
          <xsl:with-param name="iri" select="substring-after($iri, '#')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($iri, '/')">
        <xsl:call-template name="local-id">
          <xsl:with-param name="iri" select="substring-after($iri, '/')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$iri"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
