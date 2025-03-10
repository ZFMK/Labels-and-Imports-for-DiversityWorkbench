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

	<!-- Generate key of all Label Titles for printing out lot labels -->
	<xsl:key name="Lots" match="CollectionSpecimen" use="LabelTitle"/>

	<!-- Tree fragment of all Lot Labels containing first and last Catalogue No. -->
	<xsl:variable name="LotContent">
		<xsl:for-each select="//CollectionSpecimen[generate-id(.)=generate-id(key('Lots', LabelTitle)[1])]">
			<xsl:sort select="LabelTitle"/>
			<Lot>
			<xsl:for-each select="key('Lots', LabelTitle)">
				<xsl:if test="position() = 1">
					<LotTitle><xsl:value-of select="LabelTitle"/></LotTitle>
					<LotCount><xsl:value-of select="count(key('Lots', LabelTitle))"/></LotCount>
					<CollectionSpecimenID><xsl:value-of select="./CollectionSpecimenID"/></CollectionSpecimenID>
					<FirstCatNo><xsl:value-of select="./AccessionNumber"/></FirstCatNo>
					<Label><xsl:value-of select="./LabelTitle"/></Label>
				</xsl:if>
				<xsl:if test="position() = last()">
					<LastCatNo><xsl:value-of select="./AccessionNumber"/></LastCatNo>
				</xsl:if>
			</xsl:for-each>
			</Lot>
		</xsl:for-each>
	</xsl:variable>

	<xsl:decimal-format name="eu" decimal-separator=',' grouping-separator='.' />

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

				<xsl:variable name="current" select="." />

				<xsl:for-each select="msxsl:node-set($LotContent)/Lot">
				
					<xsl:if test="substring(./Label, 1, 3) = 'Lot'">			

						<xsl:variable name="CollectionSpecimenID" select="./CollectionSpecimenID" />
						<xsl:apply-templates select="$current/LabelList/Label[CollectionSpecimen/CollectionSpecimenID=$CollectionSpecimenID]" mode="has_lot">
							<xsl:with-param name="CatNo">
								<xsl:value-of select="./FirstCatNo"/>-<xsl:value-of select="./LastCatNo"/>
							</xsl:with-param>
							<xsl:with-param name="ItemCount">
								<xsl:value-of select="./LotCount"/>
							</xsl:with-param>
							<xsl:with-param name="Pos">
								<xsl:value-of select="position()"/>
							</xsl:with-param>
						</xsl:apply-templates>
						
					</xsl:if>

				</xsl:for-each>
			</body>
		</html>
	</xsl:template>

	<!-- Printout lot labels -->
	<xsl:template match="LabelList/Label" mode="has_lot">
		<xsl:param name="CatNo"/>
		<xsl:param name="ItemCount"/>
		<xsl:param name="Pos"/>
		<div class="row">
			<div class="cell">
				<p style="margin-top:13px">
					<span class="left">
						<xsl:value-of select="./CollectionSpecimen/LabelTitle"/> 
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

				<p class="taxon_name">
					<xsl:for-each select="./Units/MainUnit/Identifications/Identification">
						<xsl:if test="position()=1">
							<xsl:if test="not(./Taxon/TaxonPart)">
								<xsl:value-of select="./TaxonomicName"/>
							</xsl:if>
							<xsl:if test="./Taxon/TaxonPart">
								<xsl:for-each select="./Taxon/TaxonPart">
									<xsl:call-template name="TaxonPart">
										<xsl:with-param name="ParamIdentificationQualifierText">
											<xsl:value-of select="ancestor::Identification[1]/IdentificationQualifier"/>
										</xsl:with-param>
										<xsl:with-param name="ParamQualifierText">
											<xsl:value-of select="ancestor::Taxon[1]/Qualifier"/>
										</xsl:with-param>
										<xsl:with-param name="ParamQualifierRank">
											<xsl:value-of select="ancestor::Taxon[1]/QualifierRank"/>
										</xsl:with-param>
									</xsl:call-template>
								</xsl:for-each>
							</xsl:if>
						</xsl:if>
					</xsl:for-each>
				</p>
				<p>
					<xsl:value-of select="$CatNo"/>: <xsl:value-of select="$ItemCount"/> specimens
				</p>
				<xsl:call-template name="content"/>
			</div>
		</div>

		<xsl:if test="$Pos mod $PageBreak_After_Cells = 0">
			<p class="breakafter">.</p>
		</xsl:if>
	</xsl:template>

	<!-- Printout single labels -->
	<xsl:template match="LabelList/Label" mode="no_lot" />

	<xsl:template match="text"></xsl:template>
</xsl:stylesheet>
