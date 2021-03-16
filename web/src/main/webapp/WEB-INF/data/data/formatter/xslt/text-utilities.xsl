<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/02/xpath-functions"
                version="2.0"
                exclude-result-prefixes="fn">
  <!--
      Translates CR-LF sequences into HTML newlines <p/>
      and process current line and next line to add hyperlinks.

      Add new line before hyperlinks because normalize-space
      remove new line information.

  -->
  <xsl:template name="addLineBreaksAndHyperlinks">
    <xsl:param name="txt"/>

    <xsl:choose>
      <xsl:when test="$txt instance of node() and $txt/div">
        <xsl:for-each select="$txt/div">
          <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:call-template name="addLineBreaksAndHyperlinksInternal">
              <xsl:with-param name="txt" select="."/>
            </xsl:call-template>
          </xsl:copy>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="addLineBreaksAndHyperlinksInternal">
          <xsl:with-param name="txt" select="."/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="addLineBreaksAndHyperlinksInternal">
    <xsl:param name="txt" select="string(.)" />

    <xsl:variable name="txtWithBr">
      <xsl:analyze-string select="$txt"
                          regex="[\r\n]{{2}}">
        <!-- Code the breakline with the char ◿, to be matched later (regular expression with ^ seem doesn't match multiple chars)
             so can't use string that is unlikely to happen like BRBRBR for this and replaced later by <br/>.

             The use of the char ◿ is arbitrary, selected as a very unlikely char to happen in the metadata.
        -->
        <xsl:matching-substring>
          ◿<xsl:value-of select="."/>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <xsl:value-of select="."/>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
    </xsl:variable>

    <!-- See previous comment about the usage of the char ◿ -->
    <xsl:analyze-string select="$txtWithBr"
                        regex="[^\n\r◿]+">
      <!-- Surround text without breaklines inside a p element -->
      <xsl:matching-substring>
        <xsl:if test="string(normalize-space(.))">
          <p>
            <xsl:call-template name="hyperlink">
              <xsl:with-param name="string" select="." />
            </xsl:call-template>
          </p>
        </xsl:if>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:if test="string(normalize-space(.))">
          <xsl:call-template name="hyperlink">
            <xsl:with-param name="string" select="." />
          </xsl:call-template>
        </xsl:if>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>


  <xsl:template name="hyperlink">
    <xsl:param name="string" select="." />
    <xsl:analyze-string select="$string"
                        regex="(http|https|ftp)://[^\s]+">
      <xsl:matching-substring>
        <a href="{.}">
          <xsl:value-of select="." />
        </a>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:call-template name="hyperlink-mailaddress">
          <xsl:with-param name="string" select="." />
        </xsl:call-template>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>

  <xsl:template name="hyperlink-mailaddress">
    <xsl:param name="string" select="." />
    <xsl:analyze-string select="$string"
                        regex="([\w\.]+)@([a-zA-Z_]+?\.[a-zA-Z]{{2,3}})">
      <xsl:matching-substring>
        <a href="mailto:{.}">
          <xsl:value-of select="." />
        </a>
      </xsl:matching-substring>
      <xsl:non-matching-substring>

        <!-- See previous comment about the usage of the char ◿ -->
        <xsl:analyze-string select="$string"
                            regex="◿">
          <xsl:matching-substring>
            <br/>
            <xsl:value-of select="replace(., '◿', '')"/>
          </xsl:matching-substring>
          <xsl:non-matching-substring>
            <span><xsl:value-of select="."/></span>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>

</xsl:stylesheet>
