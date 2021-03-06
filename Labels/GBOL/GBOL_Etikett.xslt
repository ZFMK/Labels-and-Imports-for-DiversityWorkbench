<?xml version="1.0" encoding="utf-16"?>
<xsl:stylesheet version="1.0"  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="utf-16"/>

	<!--Printing options-->
	<xsl:variable name="ReportHeader">Header of report</xsl:variable>
	<xsl:variable name="PrintReportHeader">0</xsl:variable>
	<xsl:variable name="PrintReportTitle">1</xsl:variable>
	<xsl:variable name="PrintBarcode">1</xsl:variable>
	<xsl:variable name="PrintCountryCache">0</xsl:variable>

	<!--Page format-->
	<xsl:variable name="No_Cells" select="4"/>
	<xsl:variable name="PageBreak_After_Cells" select="84"/>
	<xsl:variable name="Cell_Width" select="100 div $No_Cells -2" />
	<xsl:variable name="Cell_Height" select="45" />
	<xsl:variable name="Barcode_Height" select="12" />
	<xsl:variable name="Font_Size" select="3.5"/>
	<xsl:variable name="Font_Size_Big" select="1.14"/>
	<xsl:variable name="Font_Size_Bigger" select="1.43"/>
	<xsl:variable name="Font_Size_Small" select="0.8"/>

	<!-- Logo -->
	<xsl:variable name="BackgroundImage_URL">http://biocase.zfmk.de/images/logo/zfmk_logo.jpg</xsl:variable>
	<xsl:variable name="Space"> </xsl:variable>


	<!--Templates-->
	<xsl:template match="/LabelPrint">
		<html>
			<head>
				<style type="text/css">
					@import url(http://biocase.zfmk.de/images/logo/font_barcode.css);
					html,body{height:100%;width:100%}
					body{padding:0;margin:0;font-family: Frutiger, "Frutiger Linotype", Univers, Calibri, "Gill Sans", "Gill Sans MT", "Myriad Pro", Myriad, "DejaVu Sans Condensed", "Liberation Sans", "Nimbus Sans L", Tahoma, Geneva, "Helvetica Neue", Helvetica, Arial, sans-serif;
						font-size:<xsl:value-of select="$Font_Size"/>pt}
					p{clear:left;margin:0.1em 0;padding:0 7px;}
					.font_bold{font-weight:bold;}
					.font_bold_italic{font-weight:bold;font-style:italic;}
					.font_title{font-weight:bold;}
					.font_barcode{font-family:'Bar-Code 39', 'Code 39';font-size:10pt;}
					.font_big{font-size:<xsl:value-of select="$Font_Size_Big"/>em}
					.font_bigger{font-size:<xsl:value-of select="$Font_Size_Bigger"/>em}
					.font_small{font-size:<xsl:value-of select="$Font_Size_Small"/>em}
					.row{height:<xsl:value-of select="$Cell_Height"/>px;margin:0;width:100%;}
					.row .even{background-color:#fff;}
					.row .odd{background-color:#fff;}
					div.cell{border:1px solid #c0c0c0;float:left;height:<xsl:value-of select="$Cell_Height"/>px;margin:0;padding:3px 0 0 0;width:<xsl:value-of select="$Cell_Width"/>%;overflow:hidden;position:relative;}
					.cell .left_content{float:left;height:<xsl:value-of select="$Cell_Height - $Barcode_Height"/>px;width:60%;overflow:hidden}
					.cell .right_content{float:left;height:<xsl:value-of select="$Cell_Height - $Barcode_Height"/>px;width:39%;overflow:hidden}
					.barcode_box{background-color:#fff;bottom:1px;clear:both;height:<xsl:value-of select="$Cell_Height"/>px;left:2px;overflow:hidden;float:left;width:98%}
					.breakafter{page-break-after:always; color: white}
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
					<xsl:call-template name="label">
						<xsl:with-param name="num">
							<xsl:value-of select="position()"/>
						</xsl:with-param>
					</xsl:call-template>
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

	<xsl:template name="label">
		<xsl:param name="num"/>
		<xsl:if test="$num mod $No_Cells = 1">
			<div class="row">
				<xsl:for-each select="/LabelPrint/LabelList/Label[position() &gt;= $num and position() &lt;= ($num + $No_Cells -1)]">
					<xsl:choose>
						<xsl:when test="position() mod 2 = 1">
							<div class="cell odd">
								<xsl:call-template name="content"/>
							</div>
						</xsl:when>
						<xsl:otherwise>
							<div class="cell even">
								<xsl:call-template name="content"/>
							</div>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</div>
		</xsl:if>
		<xsl:if test="$num mod $PageBreak_After_Cells = 0">
			<p class="breakafter">.</p>
		</xsl:if>
	</xsl:template>

	<xsl:template name="content">
		<div class="left_content">
			<p>
				<span class="font_small">Assoc.w/</span> <span class="font_bold font_big">
				<xsl:value-of select="./CollectionSpecimen/AccessionNumber"/>
				</span>
			</p>

			<xsl:call-template name="Event"/>

			<p>
				<xsl:call-template name="CollectionDate"/>
				<xsl:apply-templates select="Collectors"/>
			</p>

			<p>
				<xsl:if test="./Units/MainUnit/Gender!= '' and ./Units/MainUnit/Gender!= '?'">
					<xsl:text> </xsl:text>
					<xsl:value-of select="./Units/MainUnit/Gender"/>
				</xsl:if>
			</p>

			<xsl:call-template name="Relations"/>
		</div>

		<div class="right_content">
			<xsl:for-each select="./Units/MainUnit/Identifications/Identification">
				<xsl:if test="position()=1">
					<xsl:for-each select="./Taxon/TaxonPart">
						<p class="font_bold font_big">
							<xsl:call-template name="TaxonPart"/>
						</p>
					</xsl:for-each>
				</xsl:if>
			</xsl:for-each>
			<xsl:if test="./Units/MainUnit/Identifications/Identification/ResponsibleName != ''">
				<p class="font_big">
					det.
					<xsl:value-of select="./Units/MainUnit/Identifications/Identification/Agent/SecondName"/>
					<xsl:if test="./Units/MainUnit/Identifications/Identification/Agent/FirstNameAbbreviation != ''">
						<xsl:text>, </xsl:text>
						<xsl:value-of select="./Units/MainUnit/Identifications/Identification/Agent/FirstName"/>
					</xsl:if>
				</p>
			</xsl:if>
		</div>
		<xsl:if test="$PrintBarcode = 1">
			<div class="barcode_box">
				<p class="font_barcode">*<xsl:value-of select="./CollectionSpecimen/CollectionSpecimenID"/>*</p>
			</div>
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
		<!--xsl:if test="./AuthorsGenus != ''">
      <xsl:value-of select="concat(./AuthorsGenus, ' ')"/>
    </xsl:if-->
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
	</xsl:template>

	<xsl:template match="Collectors">
		leg. <xsl:apply-templates select="Collector"/>
	</xsl:template>

	<xsl:template match="Collector">
		<xsl:value-of select="./Agent/SecondName"/>
		<xsl:if test="./Agent/FirstNameAbbreviation != ''">
			<xsl:text>, </xsl:text>
			<xsl:value-of select="./Agent/FirstName"/>
		</xsl:if>
		<xsl:if test="position()!= last()">; </xsl:if>
	</xsl:template>

	<xsl:template name="Event">
		<p>
			<xsl:if test="./CollectionEvent/CountryCache != ''">
				<xsl:value-of select="./CollectionEvent/CountryCache"/>
			</xsl:if>
			<xsl:for-each select="./CollectionEventLocalisations/Localisation">
				<xsl:choose>
					<xsl:when test="./ParsingMethod = 'SamplingPlot'">
						<xsl:if test="./Location1!= ''">
							<xsl:value-of select="concat(', ',./Location1)"/>
						</xsl:if>
					</xsl:when>
					<xsl:when test="./ParsingMethod = 'Gazetteer'">
						<xsl:if test="./Location1!= ''">
							<xsl:value-of select="concat(', ',./Location1)"/>
						</xsl:if>
					</xsl:when>
					<xsl:when test="./ParsingMethod = 'Altitude'">
						<xsl:if test="./Location1!= ''">
							<xsl:value-of select="concat(', ',./Location1,./MeasurementUnit)"/>
						</xsl:if>
					</xsl:when>
					<xsl:when test="./ParsingMethod = 'Coordinates'">
						<xsl:if test="./Location2 != ''">
							<xsl:choose>
								<xsl:when test ="./Location2 &lt; 0">
									<xsl:value-of select="concat(', ',./Location2,'S')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat(', ',./Location2,'N')"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
						<xsl:if test="./Location1 != ''">
							<xsl:choose>
								<xsl:when test ="./Location1 &lt; 0">
									<xsl:value-of select="concat('/',./Location1,'W')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat('/',./Location1,'E')"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
			<xsl:if test="./CollectionEvent/LocalityDescription != ''">
				<xsl:value-of select="concat(', ',./CollectionEvent/LocalityDescription)"/>
			</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMethod != ''">
				<xsl:value-of select="concat(', ',./CollectionEvent/CollectionMethod)"/>
			</xsl:if>
		</p>
	</xsl:template>

	<xsl:template name="CollectionMonth">
		<xsl:if test="./CollectionEvent/CollectionMonth != ''">
			<xsl:if test="./CollectionEvent/CollectionMonth = 1">I</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 2">II</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 3">III</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 4">IV</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 5">V</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 6">VI</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 7">VII</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 8">IIX</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 9">IX</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 10">X</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 11">XI</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionMonth = 12">XII</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template name="Relations">
		<p>
			<xsl:if test="./Relations/Relation/RelatedSpecimenDisplayText!= ''">
				<xsl:for-each select="./Relations/Relation">
					<xsl:if test="RelationType='Hologenophore' or RelationType='Specimen part' or RelationType='Syngenophore'">
						<xsl:value-of select="RelatedSpecimenDisplayText"/>
					</xsl:if>
					<xsl:if test="position()!= last()">, </xsl:if>
				</xsl:for-each>
			</xsl:if>
		</p>
	</xsl:template>

	<xsl:template match="text"></xsl:template>
	<!-- D:\git\dwb_schemes\Label\GBOL_Etikett.xslt -->
</xsl:stylesheet>
