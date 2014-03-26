<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="res.xsl"/>
	<xsl:include href="validation.xsl"/>

	<!-- much the same as error.xsl but no back button offered - for use with
	     metadata.validate service only because it brings up its own window
			 with the validation report in it -->

	<!--
	page content
	-->
	<xsl:template name="content">
		<font class="error"><xsl:value-of select="/root/gui/error/message"/></font>
		<p/>
		<!-- Remvoed by Lantmäteriet: Error details -->
	</xsl:template>

	<!--
	title
	-->
	<xsl:template mode="title" match="/">
		<xsl:value-of select="/root/gui/error/heading"/>
	</xsl:template>

</xsl:stylesheet>

