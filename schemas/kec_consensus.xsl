<?xml version="1.0" encoding="UTF-8"?>
<!--
  kec_consensus.xsl - human-readable view of a <kec-consensus> document (resources/
  kec_consensus_schema.xsd), mirroring the viz_consensus report: per Key Event the curated
  triples with the cluster(s) confirming them (support bar, models, best match), the curated
  triples no model found (amber), and the novel clusters by support (blue); above them the
  panel summary and the support histogram. XSLT 1.0 so that both browsers and lxml can run it.
  Terms and Key Events are resolved through the document's <terms> and <lookup>. Statuses are
  the ones derived by tasks/kec_xml.py, so the HTML and the XML agree. Each <details> summary
  holds inline content only (Chromium hides the body of a details whose summary is flex or
  wraps its content in a block).
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:c="http://www.aopkb.org/kec-consensus">

  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <xsl:key name="term" match="c:term" use="@id"/>
  <xsl:key name="ke-ref" match="c:key-event-reference" use="@id"/>
  <xsl:key name="cluster-by-ke" match="c:consensus-triple" use="@ke-id"/>

  <xsl:variable name="n-models" select="/c:kec-consensus/c:summary/@n-models"/>
  <xsl:variable name="min-support" select="/c:kec-consensus/c:summary/@min-support-ensemble"/>

  <xsl:template match="/c:kec-consensus">
    <xsl:variable name="s" select="c:summary"/>
    <html lang="en">
      <head>
        <meta charset="UTF-8"/>
        <title>Cross-model consensus triples</title>
        <style>
          body { font-family: sans-serif; margin: 1.5em; color: #222; font-size: 13px; }
          h1 { font-size: 1.4em; }
          .meta { color: #666; font-size: 0.85em; }
          table { border-collapse: collapse; width: 100%; font-size: 0.9em; }
          th, td { border: 1px solid #e4e4e4; padding: 3px 6px; vertical-align: top;
                   text-align: left; }
          th { background: #eceff1; font-size: 0.85em; }
          details.ke { margin-bottom: 6px; border: 1px solid #ddd; border-radius: 4px; }
          details.ke > summary { padding: 6px 10px; background: #f5f5f5; cursor: pointer; }
          details.cl { margin: 4px 0; padding-left: 6px; border-left: 4px solid #2e7d32; }
          details.cl.novel { border-left-color: #1565c0; }
          .gt-row { background: #f1f8e9; }
          .miss-row { background: #fff8e1; }
          .novel-row { background: #e3f2fd; }
          .slot-name { font-weight: 500; }
          .slot-id { font-size: 0.8em; color: #666; display: block; }
          .tier { font-size: 0.8em; font-weight: 700; padding: 1px 5px; border-radius: 3px;
                  background: #eee; color: #333; }
          .tier-iri { background: #e8f5e9; color: #1b5e20; }
          .tier-name { background: #efebe9; color: #4e342e; }
          .tier-embedding { background: #e3f2fd; color: #0d47a1; }
          .tier-judge { background: #f3e5f5; color: #6a1b9a; }
          .bar { display: inline-block; width: 70px; height: 9px; background: #eee;
                 border-radius: 3px; vertical-align: middle; }
          .bar span { display: block; height: 100%; background: #2e7d32; border-radius: 3px; }
          .ok { color: #2e7d32; } .bad { color: #b71c1c; } .novelc { color: #1565c0; }
          .bin { padding: 1px 5px; border-radius: 3px; font-size: 0.85em;
                 background: #e8f5e9; color: #2e7d32; }
          .bin.dropped { background: #f0f0f0; color: #888; }
          .chip { display: inline-block; background: #eceff1; padding: 1px 6px;
                  border-radius: 3px; margin: 1px; font-size: 0.85em; }
        </style>
      </head>
      <body>
        <h1>Cross-model consensus triples</h1>
        <p class="meta">
          <xsl:value-of select="$s/@n-models"/> models
          <xsl:if test="$s/@restricted = 'true'"> (recommended ensemble subset)</xsl:if>
          | <xsl:value-of select="$s/@n-clusters"/> clusters,
          <xsl:value-of select="$s/@n-accepted"/> accepted (support >= <xsl:value-of select="$min-support"/>)
          over <xsl:value-of select="$s/@n-kes"/> Key Events
          <xsl:if test="$s/@min-support"> | clustered at support >= <xsl:value-of select="$s/@min-support"/></xsl:if>
          <xsl:if test="$s/@tau"> | tau=<xsl:value-of select="$s/@tau"/></xsl:if>
          <xsl:if test="$s/@embedding"> | <xsl:value-of select="$s/@embedding"/></xsl:if>
        </p>
        <details>
          <summary class="meta">Model panel - <xsl:value-of select="count($s/c:model)"/> models</summary>
          <p>
            <xsl:for-each select="$s/c:model">
              <span class="chip"><xsl:value-of select="position()"/>. <xsl:value-of select="."/></span>
            </xsl:for-each>
          </p>
        </details>
        <p>Support distribution:
          <xsl:for-each select="$s/c:support-histogram/c:bin">
            <xsl:variable name="accepted" select="@support >= $min-support"/>
            <span>
              <xsl:attribute name="class">
                <xsl:text>bin</xsl:text>
                <xsl:if test="not($accepted)"><xsl:text> dropped</xsl:text></xsl:if>
              </xsl:attribute>
              <xsl:attribute name="title">
                <xsl:choose>
                  <xsl:when test="$accepted">exported</xsl:when>
                  <xsl:otherwise>below the acceptance threshold, not exported</xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
              <xsl:text>sup=</xsl:text><xsl:value-of select="@support"/>: <xsl:value-of select="@clusters"/>
            </span>
            <xsl:text> </xsl:text>
          </xsl:for-each>
        </p>

        <xsl:for-each select="c:key-event-result">
          <xsl:sort select="@n-curated" data-type="number" order="descending"/>
          <xsl:sort select="key('ke-ref', @ke-id)/@aop-wiki-id" data-type="number"/>
          <xsl:call-template name="ke-block"/>
        </xsl:for-each>
      </body>
    </html>
  </xsl:template>

  <!-- one Key Event: curated triples (confirmed / missed) then novel clusters -->
  <xsl:template name="ke-block">
    <xsl:variable name="ke" select="@ke-id"/>
    <xsl:variable name="ref" select="key('ke-ref', $ke)"/>
    <xsl:variable name="clusters" select="key('cluster-by-ke', $ke)"/>
    <details class="ke">
      <summary>
        <a target="_blank">
          <xsl:attribute name="href">
            <xsl:text>https://aopwiki.org/events/</xsl:text><xsl:value-of select="$ref/@aop-wiki-id"/>
          </xsl:attribute>
          <xsl:text>KE</xsl:text><xsl:value-of select="$ref/@aop-wiki-id"/>
        </a>
        <xsl:text> | </xsl:text>
        <xsl:value-of select="$ref/@title"/>
        <xsl:text> | </xsl:text>
        <span>
          <xsl:attribute name="class">
            <xsl:choose>
              <xsl:when test="@n-confirmed &gt; 0">ok</xsl:when>
              <xsl:when test="@n-curated &gt; 0">bad</xsl:when>
              <xsl:otherwise>meta</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:value-of select="@n-confirmed"/>/<xsl:value-of select="@n-curated"/> curated confirmed
        </span>
        <xsl:text> </xsl:text>
        <span class="novelc"><xsl:value-of select="@n-novel"/> novel</span>
        <xsl:text> </xsl:text>
        <span class="meta"><xsl:value-of select="count($clusters)"/> clusters</span>
      </summary>
      <table>
        <tr><th>#</th><th>Curated object</th><th>Curated process</th><th>Curated action</th><th>Consensus</th></tr>
        <xsl:for-each select="c:curated-triple">
          <xsl:variable name="idx" select="@index"/>
          <xsl:variable name="confirming"
              select="$clusters[contains(concat(' ', @curated-indices, ' '), concat(' ', $idx, ' '))]"/>
          <tr>
            <xsl:attribute name="class">
              <xsl:choose>
                <xsl:when test="@status = 'confirmed'">gt-row</xsl:when>
                <xsl:otherwise>miss-row</xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <td class="meta"><xsl:value-of select="$idx"/></td>
            <td><xsl:call-template name="slot"><xsl:with-param name="id" select="@object-id"/></xsl:call-template></td>
            <td><xsl:call-template name="slot"><xsl:with-param name="id" select="@process-id"/></xsl:call-template></td>
            <td><xsl:call-template name="slot"><xsl:with-param name="id" select="@action-id"/></xsl:call-template></td>
            <td>
              <xsl:choose>
                <xsl:when test="@status = 'confirmed'">
                  <span class="ok">confirmed (<xsl:value-of select="count($confirming)"/> cluster(s))</span>
                  <xsl:for-each select="$confirming">
                    <xsl:sort select="@support" data-type="number" order="descending"/>
                    <xsl:call-template name="cluster"/>
                  </xsl:for-each>
                </xsl:when>
                <xsl:otherwise><span class="bad">not found by any model</span></xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
        </xsl:for-each>
        <xsl:if test="$clusters[@status = 'novel']">
          <tr class="novel-row">
            <td colspan="5">
              <span class="novelc">novel (no curated match) - <xsl:value-of select="@n-novel"/> cluster(s)</span>
              <xsl:for-each select="$clusters[@status = 'novel']">
                <xsl:sort select="@support" data-type="number" order="descending"/>
                <xsl:call-template name="cluster"/>
              </xsl:for-each>
            </td>
          </tr>
        </xsl:if>
      </table>
    </details>
  </xsl:template>

  <!-- one cluster: support bar, models, best match; representative triple; member triples -->
  <xsl:template name="cluster">
    <details>
      <xsl:attribute name="class">
        <xsl:text>cl</xsl:text>
        <xsl:if test="@status = 'novel'"><xsl:text> novel</xsl:text></xsl:if>
      </xsl:attribute>
      <summary>
        <b class="ok"><xsl:value-of select="@support"/>/<xsl:value-of select="$n-models"/></b>
        <xsl:text> </xsl:text>
        <span class="bar"><span>
          <xsl:attribute name="style">width:<xsl:value-of select="round(100 * @support div $n-models)"/>%</xsl:attribute>
        </span></span>
        <xsl:text> </xsl:text>
        <span class="meta"><xsl:value-of select="translate(normalize-space(@models), ' ', ',')"/></span>
        <xsl:text> </xsl:text>
        <xsl:call-template name="tier"><xsl:with-param name="m" select="@method"/></xsl:call-template>
        <xsl:if test="@score">
          <xsl:text> </xsl:text>
          <span class="meta">score=<xsl:value-of select="format-number(@score, '0.000')"/></span>
        </xsl:if>
      </summary>
      <table>
        <tr><th>Object (representative)</th><th>Process (representative)</th><th>Action</th></tr>
        <tr>
          <td><xsl:call-template name="slot"><xsl:with-param name="id" select="@object-id"/></xsl:call-template></td>
          <td><xsl:call-template name="slot"><xsl:with-param name="id" select="@process-id"/></xsl:call-template></td>
          <td><xsl:call-template name="slot"><xsl:with-param name="id" select="@action-id"/></xsl:call-template></td>
        </tr>
      </table>
      <details>
        <summary class="meta"><xsl:value-of select="count(c:member)"/> member triple(s)</summary>
        <table>
          <tr><th>Model</th><th>Object</th><th>Process</th><th>Action</th><th>Curated match</th></tr>
          <xsl:for-each select="c:member">
            <tr>
              <td class="meta"><xsl:value-of select="@model"/></td>
              <td><xsl:call-template name="slot"><xsl:with-param name="id" select="@object-id"/></xsl:call-template></td>
              <td><xsl:call-template name="slot"><xsl:with-param name="id" select="@process-id"/></xsl:call-template></td>
              <td><xsl:call-template name="slot"><xsl:with-param name="id" select="@action-id"/></xsl:call-template></td>
              <td>
                <xsl:call-template name="tier"><xsl:with-param name="m" select="@method"/></xsl:call-template>
                <xsl:if test="@score">
                  <xsl:text> </xsl:text><xsl:value-of select="format-number(@score, '0.000')"/>
                </xsl:if>
                <xsl:if test="@curated-index"> -&gt; #<xsl:value-of select="@curated-index"/></xsl:if>
              </td>
            </tr>
          </xsl:for-each>
        </table>
      </details>
    </details>
  </xsl:template>

  <xsl:template name="tier">
    <xsl:param name="m"/>
    <xsl:if test="$m">
      <span>
        <xsl:attribute name="class">tier tier-<xsl:value-of select="$m"/></xsl:attribute>
        <xsl:value-of select="$m"/>
      </span>
    </xsl:if>
  </xsl:template>

  <!-- a slot: the term's name, and its identifier linked to a search on the EBI OLS -->
  <xsl:template name="slot">
    <xsl:param name="id"/>
    <xsl:variable name="t" select="key('term', $id)"/>
    <xsl:choose>
      <xsl:when test="$t">
        <span class="slot-name"><xsl:value-of select="$t/c:name"/></span>
        <xsl:if test="$t/@source-id">
          <span class="slot-id">
            <xsl:choose>
              <xsl:when test="$t/@iri">
                <a target="_blank">
                  <xsl:attribute name="href">
                    <xsl:text>https://www.ebi.ac.uk/ols4/search?q=</xsl:text><xsl:value-of select="$t/@source-id"/>
                  </xsl:attribute>
                  <xsl:value-of select="translate($t/@source-id, '_', ':')"/>
                </a>
              </xsl:when>
              <xsl:otherwise><xsl:value-of select="$t/@source"/>:<xsl:value-of select="$t/@source-id"/></xsl:otherwise>
            </xsl:choose>
          </span>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise><span class="meta">-</span></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
