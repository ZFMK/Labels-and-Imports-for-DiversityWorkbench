<?xml version="1.0" encoding="utf-16"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt" extension-element-prefixes="msxsl">
<msxsl:script implements-prefix="msxsl" language="javascript">
<![CDATA[
function replace_str(str_text,str_replace,str_by){
     return str_text.replace(str_replace,str_by);
}
]]>
</msxsl:script>
	<xsl:output method="xml" encoding="utf-8"/>
	<!--Printing options-->
	<xsl:variable name="ReportHeader">Header of report</xsl:variable>
	<xsl:variable name="PrintReportHeader">0</xsl:variable>
	<xsl:variable name="PrintReportTitle">1</xsl:variable>
	<xsl:variable name="PrintBarcode">1</xsl:variable>
	
	<xsl:variable name="CollNumberPrefix">ZFMK </xsl:variable>

	<!--Page format-->
	<xsl:variable name="No_Cells" select="2"/>
	<xsl:variable name="PageBreak_After_Cells" select="5"/>
	<xsl:variable name="Cell_Width" select="100 div $No_Cells -2" />
	<xsl:variable name="Cell_Height" select="200 * (2 div $No_Cells)" />
	<xsl:variable name="Font_Size" select="10 * (2 div $No_Cells)"/>

	<!-- Logo -->
	<xsl:variable name="BackgroundImage_Fallback">http://biocase.zfmk.de/images/logo/zfmk_logo_small.png</xsl:variable>
	<xsl:variable name="BackgroundImage">http://biocase.zfmk.de/images/logo/zfmk_logo_small.svg</xsl:variable>
	<xsl:variable name="Space"> </xsl:variable>

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
				</xsl:if>
				<xsl:if test="position() = last()">
					<LastCatNo><xsl:value-of select="./AccessionNumber"/></LastCatNo>
				</xsl:if>
			</xsl:for-each>
			</Lot>
		</xsl:for-each>
	</xsl:variable>

	<!--Templates-->
	<xsl:template match="/LabelPrint">
		<html>
			<head>
				<xsl:comment>Transformed using <xsl:value-of select="system-property('xsl:version')"/> provided by <xsl:value-of select="system-property('xsl:vendor')"/></xsl:comment>
				<style type="text/css">
					@import url(http://biocase.zfmk.de/images/logo/font_barcode.css);
					html,body{height:100%;width:100%}
					body{padding:0;margin:0;font-family: Frutiger, "Frutiger Linotype", Univers, Calibri, "Gill Sans", "Gill Sans MT", "Myriad Pro", Myriad, "DejaVu Sans Condensed", "Liberation Sans", "Nimbus Sans L", Tahoma, Geneva, "Helvetica Neue", Helvetica, Arial, sans-serif;font-size:<xsl:value-of select="$Font_Size"/>pt}
					p{clear:left;margin:0.1em 0;padding:0;width:100%}
					.taxon_name{border-bottom:1px solid #000;border-top:1px solid #000;font-weight:bold;padding:0.3em 0;text-align:center}
					.alert{background-color:#FFDE00;color:#FF004E}
					.font_bold{font-weight:bold;}
					.font_bold_italic{font-weight:bold;font-style:italic;}
					.font_title{font-weight:bold;}
					.font_barcode{font-family:'Bar-Code 39', 'Code 39';bottom:-7px;position:absolute;right:2px;}
					.font_small{font-size:80%}
					.left{float:left}
					.center{text-align:center}
					.right{float:right;clear:right;}
					.row{clear:left;height:<xsl:value-of select="$Cell_Height"/>px;margin:0;width:100%;}
					div.cell{
						background:url(<xsl:value-of select="$BackgroundImage"/>) no-repeat top center;
						background-color:#fff;
						border:1px solid #aaa;
						display:block;
						float:left;
						height:<xsl:value-of select="$Cell_Height"/>px;
						margin:0;
						overflow:hidden;
						padding:3px 7px;
						position:relative;
						width:<xsl:value-of select="$Cell_Width"/>%;
					}
					.border_bottom{border-bottom:1px solid #000}
					.breakafter{page-break-after:always; color: white}
				</style>
			</head>
			<body>
				<xsl:apply-templates select="LabelList/Label[substring(./CollectionSpecimen/LabelTitle, 1, 3)!= 'Lot']" mode="no_lot"/>

				<p class="breakafter">.</p>

				<xsl:variable name="current" select="." />
				<xsl:for-each select="msxsl:node-set($LotContent)/Lot">
					<xsl:variable name="CollectionSpecimenID" select="./CollectionSpecimenID" />
					<xsl:apply-templates select="$current/LabelList/Label[CollectionSpecimen/CollectionSpecimenID=$CollectionSpecimenID]" mode="has_lot">
						<xsl:with-param name="CatNo">
							<xsl:value-of select="./FirstCatNo"/>-<xsl:value-of select="./LastCatNo"/>
						</xsl:with-param>
						<xsl:with-param name="ItemCount">
							<xsl:value-of select="./LotCount"/>
						</xsl:with-param>
					</xsl:apply-templates>
				</xsl:for-each>
			</body>
		</html>
	</xsl:template>

	<!-- Printout lot labels -->
	<xsl:template match="LabelList/Label" mode="has_lot">
		<xsl:param name="CatNo"/>
		<xsl:param name="ItemCount"/>
		<div class="row">
			<div class="cell">
				<p style="margin-top:13px">
					<span class="left">
						<xsl:value-of select="./CollectionSpecimen/LabelTitle"/>
					</span>
					<span class="right">
						<xsl:value-of select="./Units/MainUnit/FamilyCache"/>
					</span>
				</p>

				<p class="taxon_name">
					<xsl:for-each select="./Units/MainUnit/Identifications/Identification">
						<xsl:if test="position()=1">
							<xsl:for-each select="./Taxon/TaxonPart">
								<xsl:call-template name="TaxonPart"/>
							</xsl:for-each>
						</xsl:if>
					</xsl:for-each>
				</p>
				<p>
						<xsl:value-of select="$CatNo"/>: <xsl:value-of select="$ItemCount"/> specimens
				</p>
				<xsl:call-template name="content"/>
			</div>
		</div>

		<xsl:if test="position() mod $PageBreak_After_Cells = 0">
			<p class="breakafter">.</p>
		</xsl:if>
	</xsl:template>

	<!-- Printout single labels -->
	<xsl:template match="LabelList/Label" mode="no_lot">
		<div class="row">
			<div class="cell">
				<p style="margin-top:13px">
					<span class="left">
						<xsl:value-of select="./CollectionSpecimen/AccessionNumber"/>
					</span>
					<span class="right">
						<xsl:value-of select="./Units/MainUnit/FamilyCache"/>
					</span>
				</p>

				<p class="taxon_name">
					<xsl:for-each select="./Units/MainUnit/Identifications/Identification">
						<xsl:if test="position()=1">
							<xsl:for-each select="./Taxon/TaxonPart">
								<xsl:call-template name="TaxonPart"/>
							</xsl:for-each>
						</xsl:if>
					</xsl:for-each>
				</p>
				<xsl:call-template name="content"/>
			</div>
		</div>
		<xsl:if test="position() mod $PageBreak_After_Cells = 0">
			<p class="breakafter">.</p>
		</xsl:if>
	</xsl:template>

	<!-- Content -->
	<xsl:template name="content">
		<xsl:param name="Title"/>
		<xsl:param name="CatNo"/>
		<xsl:param name="ItemCount"/>

		<xsl:call-template name="Event"/>

		<p>
			<xsl:variable name="coord_content">
				<xsl:call-template name="GeoCoordinates" />
			</xsl:variable>
			<xsl:if test="string-length($coord_content) &gt; 0">
				<span class="left">
					<xsl:value-of select="$coord_content"/>
				</span>
			</xsl:if>
			<xsl:call-template name="CollectionDate"/>
		</p>

		<xsl:if test="./Units/MainUnit/Gender!= '' or ./Units/MainUnit/Gender!= '?' or ./CollectionEvent/HabitatDescription != '' or ./Units/MainUnit/LifeStage!= ''">
			<p>
				<xsl:if test="./CollectionEvent/HabitatDescription != ''">
					<span class="left">
						<xsl:value-of select="./CollectionEvent/HabitatDescription"/>.
					</span>
				</xsl:if>
				<xsl:if test="(./Units/MainUnit/Gender!= '' and ./Units/MainUnit/Gender!= '?') or ./Units/MainUnit/LifeStage!= ''">
					<span class="right">
						<xsl:if test="./Units/MainUnit/Gender!= '' and ./Units/MainUnit/Gender!= '?'">
							<xsl:value-of select="./Units/MainUnit/Gender"/>
						</xsl:if>
						<xsl:if test="./Units/MainUnit/LifeStage!= ''">
							<xsl:if test="./Units/MainUnit/Gender!= '' and ./Units/MainUnit/Gender!= '?'">
								<xsl:text>, </xsl:text>
							</xsl:if>
							<xsl:value-of select="./Units/MainUnit/LifeStage"/>
						</xsl:if>
					</span>
				</xsl:if>
			</p>
		</xsl:if>

		<p>
			<xsl:apply-templates select="Collectors"/>
		</p>

		<xsl:for-each select="./SpecimenParts/SpecimenPart">
			<xsl:if test="position()=1">
				<xsl:if test="./PreparationMethod!= ''">
					<p class="left">
						<xsl:value-of select="concat('fix. ' , ./PreparationMethod)"/>
					</p>
				</xsl:if>
			</xsl:if>
		</xsl:for-each>

		<xsl:call-template name="Analysis"/>

		<xsl:call-template name="Relations"/>

		<xsl:if test="$PrintBarcode = 1">
			<p class="font_barcode">
				<table width="100%">
					<tr>
						<td>
							<span class="right">
								<xsl:if test="./QRcode/ImagePath != ''">
									<xsl:element name="img">
										<xsl:attribute name="src">
											<xsl:value-of select="./QRcode/ImagePath"/>
										</xsl:attribute>
										<xsl:attribute name="align">left</xsl:attribute>
										<xsl:attribute name="height">40</xsl:attribute>
										<xsl:attribute name="width">40</xsl:attribute>
									</xsl:element>
								</xsl:if>
							</span>
						</td>
						<td width="80%" valign="bottom">
							<span class="right">
								*<xsl:value-of select="./CollectionSpecimen/AccessionNumber"/>*
							</span>
						</td>
					</tr>
				</table>
			</p>
		</xsl:if>
	</xsl:template>

	<xsl:template name="TaxonPart">
		<xsl:if test="self::node()[HybridSeparator]">
			<xsl:value-of select="concat(' ' , ./HybridSeparator, ' ')"/>
		</xsl:if>
		<xsl:if test="./QualifierLeading != ''">
			<xsl:value-of select="concat(./QualifierLeading, ' ')"/>
		</xsl:if>
		<i>
			<xsl:value-of select="concat(./Genus,' ')"/>
		</i>
		<xsl:if test="./QualifierGenus != ''">
			<xsl:value-of select="concat(./QualifierGenus, ' ')"/>
		</xsl:if>
		<xsl:if test="./Rank = 'gen.'">
			sp. <!--xsl:value-of select="concat('sp. ', ' ')"/-->
		</xsl:if>
		<xsl:if test="./InfragenericEpithet != ''">
			<xsl:if test="./Rank = 'subgen.'">
				<xsl:value-of select="concat(./Rank, ' ')"/>
			</xsl:if>
			<i>
				<xsl:value-of select="concat(./InfragenericEpithet, ' ')"/>
			</i>
		</xsl:if>
		<xsl:if test="./AuthorsInfrageneric != ''">
			<xsl:value-of select="concat(./AuthorsInfrageneric, ' ')"/>
		</xsl:if>
		<xsl:if test="./QualifierSpecies != ''">
			<xsl:value-of select="concat(./QualifierSpecies, ' ')"/>
		</xsl:if>
		<i>
			<xsl:value-of select="concat(./SpeciesEpithet, ' ')"/>
		</i>
		<xsl:if test="./AuthorsSpecies != ''">
			<xsl:value-of select="concat(./AuthorsSpecies, ' ')"/>
		</xsl:if>
		<xsl:if test="./Rank != 'sp.' and ./Rank != 'subgen.' and ./InfraspecificEpithet != ''">
			<xsl:value-of select="concat(./Rank, ' ')"/>
		</xsl:if>
		<xsl:if test="./InfraspecificEpithet != ''">
			<xsl:if test="./QualifierInfraspecific != ''">
				<xsl:value-of select="concat(./QualifierInfraspecific, ' ')"/>
			</xsl:if>
			<i>
				<xsl:value-of select="concat(./InfraspecificEpithet, ' ')"/>
			</i>
			<xsl:if test="./AuthorsInfraspecific != ''">
				<xsl:value-of select="concat(./AuthorsInfraspecific, ' ')"/>
			</xsl:if>
		</xsl:if>
		<xsl:if test="./Undefined != ''">
			<xsl:value-of select="concat(./Undefined, ' ')"/>
		</xsl:if>
		<xsl:if test="./QualifierTerminatory != ''">
			<xsl:value-of select="concat(./QualifierTerminatory, ' ')"/>
		</xsl:if>
	</xsl:template>

	<xsl:template name="CollectionDate">
		<xsl:if test="./CollectionEvent/CollectionYear != '' or ./CollectionEvent/CollectionMonth != '' or ./CollectionEvent/CollectionDay != '' or ./CollectionEvent/CollectionDate != ''">
			<span class="right">
				<xsl:if test="./CollectionEvent/CollectionYear != '' or ./CollectionEvent/CollectionMonth != '' or ./CollectionEvent/CollectionDay != ''">
					<xsl:value-of select="./CollectionEvent/CollectionDay"/>
					<xsl:if test="./CollectionEvent/CollectionDay != ''">.</xsl:if>
					<xsl:call-template name="CollectionMonth"/>
					<xsl:if test="./CollectionEvent/CollectionMonth != ''">.</xsl:if>
					<xsl:value-of select="./CollectionEvent/CollectionYear"/>
				</xsl:if>
				<xsl:if test="./CollectionEvent/CollectionDate != '' and not(./CollectionEvent/CollectionYear) and not(./CollectionEvent/CollectionMonth) and not(./CollectionEvent/CollectionDay)">
					<xsl:value-of select="./CollectionEvent/CollectionDate"/>
				</xsl:if>
			</span>
		</xsl:if>
	</xsl:template>

	<xsl:template match="Collectors">
		<xsl:apply-templates select="Collector"/>
	</xsl:template>

	<xsl:template match="Collector">
		<xsl:if test="./Agent/FirstNameAbbreviation != ''">
			<xsl:value-of select="./Agent/FirstName"/>
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:value-of select="./Agent/SecondName"/>
		<xsl:text> </xsl:text>
		<xsl:apply-templates select="CollectorsNumber"/>
		<xsl:if test="position()!= last()">, </xsl:if>
	</xsl:template>

	<xsl:template match="CollectorsNumber">
		(<xsl:value-of select="."/>)
	</xsl:template>

	<xsl:template name="GeoCoordinates">
		<xsl:for-each select="./CollectionEventLocalisations/Localisation">
			<xsl:if test="./ParsingMethod = 'Coordinates'">
				<xsl:if test="./Location1 != ''">
					Long.
					<xsl:value-of select="format-number(./Location1, '#.0000')"/>
				</xsl:if>
				<xsl:text>/</xsl:text>
				<xsl:if test="./Location2 != ''">
					Lat.
					<xsl:value-of select="format-number(./Location2, '#.0000')"/>
				</xsl:if>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="Event">
		<p>
			<xsl:if test="./CollectionEvent/CountryCache != ''">
				<xsl:value-of select="./CollectionEvent/CountryCache"/>
			</xsl:if>
			<xsl:if test="./CollectionEvent/LocalityDescription != ''">
				<xsl:if test="./CollectionEvent/CountryCache != ''">
					<xsl:text>, </xsl:text>
				</xsl:if>
				<xsl:value-of select="./CollectionEvent/LocalityDescription"/>
			</xsl:if>
			<xsl:for-each select="./CollectionEventLocalisations/Localisation">
				<xsl:choose>
					<xsl:when test="./ParsingMethod = 'SamplingPlot'">
						<xsl:if test="./Location1!= ''">
							<xsl:value-of select="concat(', ',./Location1)"/>
						</xsl:if>
					</xsl:when>
					<xsl:when test="./ParsingMethod = 'Altitude'">
						<xsl:if test="./Location1!= ''">
							<xsl:value-of select="concat(', ',./Location1,./MeasurementUnit)"/>
						</xsl:if>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
			<xsl:if test="./CollectionEvent/CollectionMethod != ''">
				<xsl:value-of select="concat(', ',./CollectionEvent/CollectionMethod)"/>
			</xsl:if>
		</p>
	</xsl:template>

	<xsl:template name="Analysis">
		<xsl:if test="./Units/MainUnit/UnitAnalysis/Analysis/AnalysisName!= ''">
			<p class="font_small">
				<xsl:for-each select="./Units/MainUnit/UnitAnalysis/Analysis">
					<xsl:choose>
						<xsl:when test="number(AnalysisResult)!=number(AnalysisResult)">
							<xsl:call-template name="AnalysisResult">
								<xsl:with-param name="name">
									<xsl:value-of select="AnalysisName"/>
								</xsl:with-param>
								<xsl:with-param name="value">
									<xsl:value-of select="AnalysisResult"/>
								</xsl:with-param>
								<xsl:with-param name="unit">
									<xsl:value-of select="MeasurementUnit"/>
								</xsl:with-param>
								<xsl:with-param name="unit_modifier">
									<xsl:value-of select="0"/>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:when test="number(AnalysisResult) &gt;= 1000">
							<xsl:call-template name="AnalysisResult">
								<xsl:with-param name="name">
									<xsl:value-of select="AnalysisName"/>
								</xsl:with-param>
								<xsl:with-param name="value">
									<xsl:value-of select="format-number(number(AnalysisResult) div 1000, '0.##')"/>
								</xsl:with-param>
								<xsl:with-param name="unit">
									<xsl:value-of select="MeasurementUnit"/>
								</xsl:with-param>
								<xsl:with-param name="unit_modifier">
									<xsl:value-of select="1"/>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="AnalysisResult">
								<xsl:with-param name="name">
									<xsl:value-of select="AnalysisName"/>
								</xsl:with-param>
								<xsl:with-param name="value">
									<xsl:value-of select="number(AnalysisResult)"/>
								</xsl:with-param>
								<xsl:with-param name="unit">
									<xsl:value-of select="MeasurementUnit"/>
								</xsl:with-param>
								<xsl:with-param name="unit_modifier">
									<xsl:value-of select="0"/>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="position()!= last()">, </xsl:if>
				</xsl:for-each>
			</p>
		</xsl:if>
	</xsl:template>

	<xsl:template name="AnalysisResult">
		<xsl:param name="name"/>
		<xsl:param name="value"/>
		<xsl:param name="unit"/>
		<xsl:param name="unit_modifier"/>
		<xsl:choose>
			<xsl:when test="$unit = 'mm'">
				<xsl:value-of select="$name"/>=<xsl:value-of select="$value"/>
				<xsl:choose>
					<xsl:when test="$unit_modifier=1"> m</xsl:when>
					<xsl:otherwise> mm</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$unit = 'g'">
				<xsl:value-of select="$name"/>=<xsl:value-of select="$value"/>
				<xsl:choose>
					<xsl:when test="$unit_modifier=1"> kg</xsl:when>
					<xsl:otherwise> g</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$unit = 'cm'">
				<xsl:value-of select="name"/>=<xsl:value-of select="$value"/>
				<span class="alert"> cm</span>
			</xsl:when>
			<xsl:when test="$unit = 'kg'">
				<xsl:value-of select="$name"/>=<xsl:value-of select="$value"/>
				<span class="alert"> kg</span>
			</xsl:when>
			<xsl:otherwise></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="Relations">
		<xsl:if test="./Relations/Relation/RelatedSpecimenDisplayText!= ''">
			<p>
				<xsl:for-each select="./Relations/Relation">
					<xsl:value-of select="RelatedSpecimenDisplayText"/>
					<xsl:if test="RelationType!= ''">
						(<xsl:value-of select="RelationType"/>)
					</xsl:if>
					<xsl:if test="position()!= last()">, </xsl:if>
				</xsl:for-each>
			</p>
		</xsl:if>
	</xsl:template>

	<xsl:template name="CollectionMonth">
		<xsl:if test="./CollectionEvent/CollectionMonth != ''">
			<xsl:if test="./CollectionEvent/CollectionMonth = 1">Jan</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 2">Feb</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 3">Mar</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 4">Apr</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 5">May</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 6">Jun</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 7">Jul</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 8">Aug</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 9">Sep</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 10">Oct</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 11">Nov</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 12">Dec</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="text"></xsl:template>
</xsl:stylesheet>
