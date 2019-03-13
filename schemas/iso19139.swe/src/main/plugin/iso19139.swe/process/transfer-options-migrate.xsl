<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:xlink='http://www.w3.org/1999/xlink'
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xls="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="gmd xlink gco xsi gmx srv">

  <!-- ================================================================= -->

  <!-- Process to migrate gmd:transferOptions to gmd:distributorTransferOptions.

       If entries for gmd:onLine already exists are skipped.
  -->

  <xsl:template match="gmd:MD_Distribution">
    <xsl:copy>
      <xsl:copy-of select="@*" />

      <xsl:apply-templates select="gmd:distributionFormat" />

      <xsl:variable name="transferOptions" select="gmd:transferOptions[gmd:MD_DigitalTransferOptions]" />

      <xsl:choose>
        <!-- Create distributor section if doesn't exist and there're gmd:transferOptions to move -->
        <xsl:when test="count(gmd:distributor) = 0 and count($transferOptions) > 0">
          <gmd:distributor>
            <gmd:MD_Distributor>
              <gmd:distributorContact />

              <xsl:for-each select="$transferOptions/gmd:MD_DigitalTransferOptions">                                           
                <gmd:distributorTransferOptions>
                  <gmd:MD_DigitalTransferOptions>                       
                      <xsl:copy-of select="*" />                          
                  </gmd:MD_DigitalTransferOptions>
                </gmd:distributorTransferOptions>
              </xsl:for-each>
            </gmd:MD_Distributor>
          </gmd:distributor>

        </xsl:when>

        <xsl:otherwise>
          <xsl:for-each select="gmd:distributor">
            <xsl:copy>
              <xsl:copy-of select="@*" />

              <gmd:MD_Distributor>
                <xsl:apply-templates select="gmd:MD_Distributor/gmd:distributorContact" />
                <xsl:apply-templates select="gmd:MD_Distributor/gmd:distributionOrderProcess" />
                <xsl:apply-templates select="gmd:MD_Distributor/gmd:distributorFormat" />
                <xsl:apply-templates select="gmd:MD_Distributor/gmd:distributorTransferOptions" />

                <xsl:variable name="distributorTransferOptions" select="gmd:MD_Distributor/gmd:distributorTransferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine" />
              
                
                <!-- Move gmd:transferOptions to the first distributor -->
                <xsl:choose>
                  <xsl:when test="position() = 1">
                    <xsl:for-each select="$transferOptions/gmd:MD_DigitalTransferOptions">     
                      
                      <!-- List with entries that doesn't exists in gmd:distributorTransferOptions -->
                      <xsl:variable name="resourcesToAdd">
                        <xsl:for-each select="gmd:onLine">
                          <xsl:variable name="url" select="gmd:CI_OnlineResource/gmd:linkage/gmd:URL" />
                           
                          <xsl:if test="count($distributorTransferOptions[gmd:CI_OnlineResource/gmd:linkage/gmd:URL = $url]) = 0">
                           <xsl:copy-of select="." />
                          </xsl:if> 
                        </xsl:for-each>                        
                      </xsl:variable>
                       
                      <xsl:choose>
                        <!-- If  resources to add, transfer them, along with gmd:transferOptions  other elements -->
                        <xsl:when test="count($resourcesToAdd/*) > 0">
                          <gmd:distributorTransferOptions>
                            <gmd:MD_DigitalTransferOptions>    

                              <xsl:copy-of select="gmd:unitsOfDistribution" />
                              <xsl:copy-of select="gmd:transferSize" />
                                                            
                              <xsl:for-each select="$resourcesToAdd/*">
                                <xsl:copy-of select="." />               
                              </xsl:for-each>
                              
                              <xsl:copy-of select="gmd:offLine" />
                            </gmd:MD_DigitalTransferOptions>
                          </gmd:distributorTransferOptions>
                          
                        </xsl:when>
                        
                        <!-- If no resources to add but gmd:transferOptions has other elements, transfer them -->
                        <xsl:when test="count($resourcesToAdd/*) = 0 and ((count(gmd:unitsOfDistribution) > 0) or (count(gmd:transferSize) > 0)  or (count(gmd:offLine) > 0) )">
                          <gmd:distributorTransferOptions>
                            <gmd:MD_DigitalTransferOptions>    
                              
                              <xsl:copy-of select="gmd:unitsOfDistribution" />
                              <xsl:copy-of select="gmd:transferSize" />
                                        
                              <xsl:copy-of select="gmd:offLine" />
                            </gmd:MD_DigitalTransferOptions>
                          </gmd:distributorTransferOptions>
                        </xsl:when>
                      </xsl:choose>
                      
                    </xsl:for-each>
                  </xsl:when>
                  <xsl:otherwise>
                  </xsl:otherwise>
                </xsl:choose>
              </gmd:MD_Distributor>

            </xsl:copy>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
      
    </xsl:copy>
  </xsl:template>


  <!-- ================================================================= -->
  <!-- copy everything else as is -->

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
