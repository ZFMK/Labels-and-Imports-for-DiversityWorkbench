<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt" extension-element-prefixes="msxsl">
	<xsl:output method="xml" encoding="utf-8"/>
	
	<xsl:include href="Template/ICH_Template.xslt"/>
	
	<!--Printing options-->
	<xsl:variable name="PrintBarcode">1</xsl:variable>

	<!--Page format-->
	<xsl:variable name="No_Cells" select="1"/>
	<xsl:variable name="PageBreak_After_Cells" select="2"/>
	<xsl:variable name="Cell_Width" select="100 div $No_Cells -4" />
	<xsl:variable name="Cell_Height" select="200 * (2 div $No_Cells)" />
	<xsl:variable name="Font_Size" select="10 * (2 div $No_Cells)"/>
	<xsl:variable name="QR_Img_Size" select="120"/>

	<!--Templates-->
	<xsl:template match="/LabelPrint">
		<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
		<html>
			<head>
				<xsl:comment>Transformed using XSLT ver. <xsl:value-of select="system-property('xsl:version')"/> provided by <xsl:value-of select="system-property('xsl:vendor')"/></xsl:comment>
				<style type="text/css">
					html,body{height:100%;width:100%}
					body{padding:0;
						margin:0;
						font-family: Frutiger, "Frutiger Linotype", Univers, Calibri, "Gill Sans", "Gill Sans MT", "Myriad Pro", Myriad, "DejaVu Sans Condensed", "Liberation Sans", "Nimbus Sans L", Tahoma, Geneva, "Helvetica Neue", Helvetica, Arial, sans-serif;
						font-size:<xsl:value-of select="$Font_Size"/>pt}
					.font_bold{font-weight:bold;}
					.font_bold_italic{font-weight:bold;font-style:italic;}
					.font_title{font-weight:bold;}
					.font_barcode{font-family:'Bar-Code 39', 'Code 39';bottom:2px;right:2px;position:absolute}
					div.cell{
						border:1px solid #aaa;
						height:<xsl:value-of select="$Cell_Height"/>px;
						margin:0;
						overflow:hidden;
						padding:3px 7px;
						width:<xsl:value-of select="$Cell_Width"/>%;
						float:left;
						position:relative;
					}
					img{left:0;margin:0}
					p{clear:left;margin:0.1em 0;padding:0;width:100%}
					.taxon_name{border-bottom:1px solid #000;border-top:1px solid #000;font-weight:bold;padding:0.3em 0;text-align:center}
					.left{float:left}
					.center{text-align:center}
					.right{float:right;clear:right}
					.text-right{text-align:right}
					.border_bottom{border-bottom:1px solid #000}
					.breakafter{page-break-after:always; color: white}
				</style>			
			</head>
			<body>
				<xsl:apply-templates select="LabelList/Label[substring(./CollectionSpecimen/LabelTitle, 1, 3)!= 'Lot']" mode="no_lot" />
			</body>
		</html>
	</xsl:template>

	<!-- Printout single labels -->
	<xsl:template match="LabelList/Label" mode="no_lot">
		<div class="cell">
			<p style="margin-top:13px">
				<span class="left">
					<xsl:value-of select="./CollectionSpecimen/AccessionNumber"/>
				</span>
				<span class="right">
					<xsl:text> </xsl:text>
					<xsl:choose>
						<xsl:when test="./CollectionSpecimen/StorageLocation">
							<xsl:value-of select="./CollectionSpecimen/StorageLocation"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:for-each select="./SpecimenParts/SpecimenPart">
								<xsl:if test="position()=1">
									<xsl:value-of select="StorageLocation"/>
								</xsl:if>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</span>
			</p>

			<xsl:for-each select="./Units/MainUnit/Identifications/Identification">
				<xsl:if test="position()=1">
					<xsl:call-template name="Identification"/>
				</xsl:if>
			</xsl:for-each>
			
			<xsl:call-template name="content"/>
		</div>
		
		<xsl:if test="position() mod $PageBreak_After_Cells = 0">
			<p class="breakafter">.</p>
		</xsl:if>
	</xsl:template>
		
	<xsl:template match="text"></xsl:template>
</xsl:stylesheet>
