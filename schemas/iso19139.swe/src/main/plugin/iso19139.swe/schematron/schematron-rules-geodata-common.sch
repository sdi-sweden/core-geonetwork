<?xml version="1.0" encoding="UTF-8"?>
<sch:schema  xmlns:sch="http://purl.oclc.org/dsdl/schematron">
  
  <sch:pattern fpi="[Geodata.se:101] - En titel måste anges">
    <sch:rule context="//gmd:identificationInfo[1]/*">
      <sch:let name="resourceTitle" value="normalize-space(gmd:citation/*/gmd:title/*/text())"/>
      <sch:let name="resourceTitleLength" value="string-length(gmd:citation/*/gmd:title/*/text())"/>
      <!--<sch:report test="$resourceTitle">Titel funnen:
        <sch:value-of select="$resourceTitle"/>
        <sch:value-of select="$resourceTitleLength"/>
        </sch:report>-->
      <sch:assert test="$resourceTitle and ($resourceTitleLength &lt; 300)">[Geodata.se:101] - Titel måste anges och innehålla mindre än 300 tecken</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern fpi="[Geodata.se:102] - Sammanfattning  måste anges">
    <sch:rule context="//gmd:identificationInfo[1]/*">
      <sch:let name="resourceAbstract" value="normalize-space(gmd:abstract/*/text())"/>
      <sch:let name="resourceAbstractLength" value="string-length(gmd:abstract/*/text())"/>
      <sch:assert test="$resourceAbstract and ($resourceAbstractLength &lt; 4000)">[Geodata.se:102] - Sammanfattning krävs och skall vara på max 4000 tecken</sch:assert>
      <!--<sch:report test="$resourceAbstract">(2.2.2) Resource abstract found: <sch:value-of	select="$resourceAbstract"/>
  			</sch:report> -->
    </sch:rule>
  </sch:pattern>
</sch:schema>