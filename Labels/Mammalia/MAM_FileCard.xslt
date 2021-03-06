<?xml version="1.0" encoding="utf-16"?>
<xsl:stylesheet version="1.0"  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="utf-16"/>

	<!--Printing options-->
	<xsl:variable name="ReportHeader">Header of report</xsl:variable>
	<xsl:variable name="PrintReportHeader">0</xsl:variable>
	<xsl:variable name="PrintReportTitle">1</xsl:variable>
	<xsl:variable name="PrintBarcode">1</xsl:variable>

	<xsl:variable name="CollNumberPrefix">ZFMK </xsl:variable>

	<!--Page format-->
	<xsl:variable name="Cell_Width" select="560" />
	<xsl:variable name="Cell_Height" select="397" />
	<xsl:variable name="Font_Size" select="10"/>

	<!-- Logo -->
	<xsl:variable name="BackgroundImage_Fallback">http://biocase.zfmk.de/images/logo/zfmk_logo_small.png</xsl:variable>
	<xsl:variable name="BackgroundImage">http://biocase.zfmk.de/images/logo/zfmk_logo_small.svg</xsl:variable>
	<xsl:variable name="Space"> </xsl:variable>


	<!--Templates-->
	<xsl:template match="/LabelPrint">
		<html>
			<head>
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
					.font_label{font-weight:bold;}
					.font_barcode{font-family:'Bar-Code 39';bottom:-7px;position:absolute;right:2px;}
					.font_small{font-size:80%}
					.left{float:left}
					.center{text-align:center}
					.right{float:right;clear:right;}
					.cell.even{background-color:#fff;}
					.cell.odd{background-color:#fff;}
					div.cell{
						background:url(<xsl:value-of select="$BackgroundImage_Fallback"/>) no-repeat bottom left;
						background-image:url(<xsl:value-of select="$BackgroundImage"/>);
						border:1px solid #aaa;
						display:block;
						height:<xsl:value-of select="$Cell_Height"/>px;
						margin:0;padding:3px 7px;
						overflow:hidden;
						width:<xsl:value-of select="$Cell_Width"/>px;
					}
					.border_bottom{border-bottom:1px solid #000}
					.breakafter{page-break-after:always; color: white}
					.indent{margin-left:1em}
					.line1{height:24px;margin-top:13px}
					.line2{height:23px}
					.line3{height:102px}
					.line4{height:23px}
					.line5{height:23px}
					.line6{height:67px}
					.line7{height:23px}
					.line8{height:23px}
					.line9{height:35px}
				</style>
			</head>
			<body>
				<!--xsl:call-template name="Header"/-->
				<xsl:if test="$PrintReportHeader = 1">
					<hr/>
					<span style="font_title">
						<xsl:value-of select="$ReportHeader"/>
					</span>
				</xsl:if>
				<xsl:for-each select="/LabelPrint/LabelList/Label">
					<div class="cell odd">
						<xsl:call-template name="front_content"/>
					</div>
					<p class="breakafter">.</p>
					<div class="cell even">
						<xsl:call-template name="back_content"/>
					</div>
					<p class="breakafter">.</p>
				</xsl:for-each>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="Header">
		<p class="font_title">
			<xsl:value-of select="./ProjectTitle"/>
		</p>
		<p align="center">
			(<xsl:value-of select="./Title"/>)
		</p>
	</xsl:template>

	<xsl:template name="front_content">
		<p class="line1">
			<span class="left font_bold">
				<xsl:value-of select="$CollNumberPrefix"/>
				<xsl:value-of select="./CollectionSpecimen/AccessionNumber"/>
			</span>
			<span class="right font_bold">
				<xsl:value-of select="./Units/MainUnit/FamilyCache"/>
			</span>
		</p>

		<p class="taxon_name line2">
			<xsl:for-each select="./Units/MainUnit/Identifications/Identification">
				<xsl:if test="position()=1">
					<xsl:for-each select="./Taxon/TaxonPart">
						<xsl:call-template name="TaxonPart"/>
					</xsl:for-each>
				</xsl:if>
			</xsl:for-each>
		</p>

		<p class="line3">
			<span class="font_label">Fundort:</span>
			<br/>
			<span class="indent">
				<xsl:call-template name="Event"/>
			</span>
			<br/>
			<span class="indent">
				<xsl:variable name="coord_content">
					<xsl:call-template name="GeoCoordinates" />
				</xsl:variable>
				<xsl:if test="string-length($coord_content) &gt; 0">
					<xsl:value-of select="$coord_content"/>
				</xsl:if>
			</span>
		</p>

		<p class="line4">
			<span class="font_label">Sammelmethode: </span>
			<xsl:if test="./CollectionEvent/CollectingMethod != ''">
				<xsl:value-of select="./CollectionEvent/CollectingMethod"/>
			</xsl:if>
		</p>

		<p class="line5">
			<span class="left">
				<span class="font_label">Datum: </span>
				<xsl:call-template name="CollectionDate"/>
			</span>
			<span class="right">
				<span class="font_label">Sammler/Erwerb: </span>
				<xsl:apply-templates select="Collectors"/>
			</span>
		</p>

		<p class="line6">
			<span class="font_label">Biotop:</span>
			<br/>
			<span class="indent">
				<xsl:if test="./CollectionEvent/HabitatDescription != ''">
					<xsl:value-of select="./CollectionEvent/HabitatDescription"/>.
				</xsl:if>
			</span>
		</p>

		<p class="line7">
			<span class="font_label">Lagerort: </span>
			<xsl:if test="./CollectionSpecimen/StorageLocation != ''">
				<xsl:value-of select="./CollectionSpecimen/StorageLocation"/>
			</xsl:if>
		</p>

		<p class="font_bold border_bottom line8">
			<xsl:if test="./CollectionSpecimen/MaterialCategory!= ''">
				<xsl:value-of select="./CollectionSpecimen/MaterialCategory"/>
			</xsl:if>
				<xsl:if test="./CollectionSpecimen/MaterialCategory!= '' and ./CollectionSpecimen/StorageContainer!= ''">
					<xsl:text> - </xsl:text>
				</xsl:if>
			<xsl:if test="./CollectionSpecimen/StorageContainer!= ''">
				<xsl:value-of select="./CollectionSpecimen/StorageContainer"/>
			</xsl:if>
			<xsl:for-each select="./SpecimenParts/SpecimenPart">
				<xsl:if test="position()=1">
						<xsl:if test="./CollectionSpecimen/MaterialCategory!= '' or ./CollectionSpecimen/StorageContainer!= ''">
							<xsl:text> - </xsl:text>
						</xsl:if>
						<xsl:if test="./PreparationMethod!= ''">
							<xsl:value-of select="./PreparationMethod"/>
						</xsl:if>
				</xsl:if>
			</xsl:for-each>
		</p>

		<p class="border_bottom line9">
				<span class="left">
					<span class="font_label">Geschl.: </span>
					<xsl:if test="./Units/MainUnit/Gender!= '' and ./Units/MainUnit/Gender!= '?'">
						<xsl:value-of select="./Units/MainUnit/Gender"/>
					</xsl:if>
					<br/>
					<span class="font_label">Alter: </span>
					<xsl:if test="./Units/MainUnit/LifeStage!= ''">
						<xsl:value-of select="./Units/MainUnit/LifeStage"/>
					</xsl:if>
				</span>
				<span class="right">
					<span class="font_label">Feld-Nr.: </span>
					<xsl:if test="./CollectionEvent/CollectorsEventNumber!= ''">
						<xsl:value-of select="./CollectionEvent/CollectorsEventNumber"/>
					</xsl:if>
				</span>
			</p>

		<xsl:if test="$PrintBarcode = 1">
			<p>
				<span class="right font_barcode">
					*<xsl:value-of select="./CollectionSpecimen/AccessionNumber"/>*
				</span>
			</p>
		</xsl:if>
	</xsl:template>

	<xsl:template name="back_content">
		<xsl:call-template name="Analysis"/>

		<xsl:call-template name="Relations"/>
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
			sp.
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
	</xsl:template>

	<xsl:template name="Analysis">
			<p>
				<span class="font_label">Messungen:</span>
				<br/>
				<xsl:choose>
					<xsl:when test="./Units/MainUnit/UnitAnalysis/Analysis/AnalysisName!= ''">
						<span class="indent">
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
								<xsl:if test="position()!= last()">
									<br/>
								</xsl:if>
							</xsl:for-each>
						</span>
					</xsl:when>
					<xsl:otherwise>
						<br/>
						<br/>
					</xsl:otherwise>
				</xsl:choose>
			</p>
	</xsl:template>

	<xsl:template name="AnalysisResult">
		<xsl:param name="name"/>
		<xsl:param name="value"/>
		<xsl:param name="unit"/>
		<xsl:param name="unit_modifier"/>
		<span class="font_label"><xsl:value-of select="$name"/>: </span>
		<xsl:choose>
			<xsl:when test="$unit = 'mm'">
				<xsl:value-of select="$value"/>
				<xsl:choose>
					<xsl:when test="$unit_modifier=1"> m</xsl:when>
					<xsl:otherwise> mm</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$unit = 'g'">
				<xsl:value-of select="$value"/>
				<xsl:choose>
					<xsl:when test="$unit_modifier=1"> kg</xsl:when>
					<xsl:otherwise> g</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$unit = 'cm'">
				<xsl:value-of select="$value"/>
				<span class="alert"> cm</span>
			</xsl:when>
			<xsl:when test="$unit = 'kg'">
				<xsl:value-of select="$value"/>
				<span class="alert"> kg</span>
			</xsl:when>
			<xsl:otherwise></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="Relations">
		<p>
			<span class="font_label">Verwandte Objekte: </span>
			<br/>
			<xsl:if test="./Relations/Relation/RelatedSpecimenDisplayText!= ''">
				<span class="indent">
					<xsl:for-each select="./Relations/Relation">
						<xsl:value-of select="RelatedSpecimenDisplayText"/>
						<xsl:if test="RelationType!= ''">
							(<xsl:value-of select="RelationType"/>)
						</xsl:if>
						<xsl:if test="position()!= last()">, </xsl:if>
					</xsl:for-each>
				</span>
			</xsl:if>
		</p>
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
