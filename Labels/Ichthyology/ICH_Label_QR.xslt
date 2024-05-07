<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt" extension-element-prefixes="msxsl">
	<xsl:output method="xml" encoding="utf-8"/>
	<!--Printing options-->
	<xsl:variable name="PrintBarcode">1</xsl:variable>

	<!--Page format-->
	<xsl:variable name="No_Cells" select="2"/>
	<xsl:variable name="PageBreak_After_Cells" select="5"/>
	<xsl:variable name="Cell_Width" select="100 div $No_Cells -2" />
	<xsl:variable name="Cell_Height" select="200 * (2 div $No_Cells)" />
	<xsl:variable name="Font_Size" select="10 * (2 div $No_Cells)"/>
	<xsl:variable name="QR_Img_Size" select="120"/>

	<xsl:variable name="BackgroundImage">https://biocase.zfmk.de/logo/Logo_ZFMK_Small.svg</xsl:variable>
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
					.font_barcode{font-family:'Bar-Code 39', 'Code 39';bottom:0;position:absolute;right:2px;}
					div.cell{
						border:1px solid #aaa;
						height:<xsl:value-of select="$Cell_Height"/>px;
						margin:0;
						overflow:hidden;
						padding:3px 7px;
						width:<xsl:value-of select="$Cell_Width"/>%;
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
						<xsl:with-param name="Pos">
							<xsl:value-of select="position()"/>
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
		<xsl:param name="Pos"/>

		<div class="row">
			<div class="cell">
				<p style="margin-top:13px">
					<span class="left">
						<xsl:value-of select="./CollectionSpecimen/LabelTitle"/>
					</span>
					<span class="right">
						<xsl:choose>
							<xsl:when test="./CollectionSpecimen/ExternalIdentifiers/ExternalIdentifier[Type='FamilyNumber (Pisces)']">
								<xsl:value-of select="./CollectionSpecimen/ExternalIdentifiers/ExternalIdentifier[Type='FamilyNumber (Pisces)']/Identifier"/>
							</xsl:when>
							<xsl:when test="./Units/MainUnit/ExternalIdentifiers/ExternalIdentifier[Type='FamilyNumber (Pisces)']">
								<xsl:value-of select="./Units/MainUnit/ExternalIdentifiers/ExternalIdentifier[Type='FamilyNumber (Pisces)']/Identifier"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="./Units/MainUnit/FamilyCache"/>
							</xsl:otherwise>
						</xsl:choose>
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

		<xsl:if test="$Pos mod $PageBreak_After_Cells = 0">
			<p class="breakafter">.</p>
		</xsl:if>
	</xsl:template>

	<!-- Printout single labels -->
	<xsl:template match="LabelList/Label" mode="no_lot">
		<div class="cell">
			<p style="margin-top:13px">
				<span class="left">
					<xsl:value-of select="./CollectionSpecimen/AccessionNumber"/>
				</span>
				<span class="right">
					<xsl:choose>
						<xsl:when test="./Units/MainUnit/UnitIdentifier">
							<xsl:value-of select="./Units/MainUnit/UnitIdentifier"/>
						</xsl:when>
						<xsl:when test="./CollectionSpecimen/ExternalIdentifiers/ExternalIdentifier[Type='FamilyNumber (Pisces)']">
							<xsl:value-of select="./CollectionSpecimen/ExternalIdentifiers/ExternalIdentifier[Type='FamilyNumber (Pisces)']/Identifier"/>
						</xsl:when>
						<xsl:when test="./Units/MainUnit/ExternalIdentifiers/ExternalIdentifier[Type='FamilyNumber (Pisces)']">
							<xsl:value-of select="./Units/MainUnit/ExternalIdentifiers/ExternalIdentifier[Type='FamilyNumber (Pisces)']/Identifier"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="./Units/MainUnit/FamilyCache"/>
						</xsl:otherwise>
					</xsl:choose>
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
		
		<xsl:if test="position() mod $PageBreak_After_Cells = 0">
			<p class="breakafter">.</p>
		</xsl:if>
	</xsl:template>

	<!-- Content -->
	<xsl:template name="content">
		<xsl:choose>
			<xsl:when test="./CollectionEvent/CountryCache != ''">
				<xsl:call-template name="Event"/>
			</xsl:when>
			<xsl:when test="./Units/MainUnit/Circumstances != ''">
				<strong><xsl:value-of select="concat(Units/MainUnit/Circumstances, ': ')"/></strong>
				<xsl:apply-templates select="Relations/Relation[RelationType='Child of']"/>
			</xsl:when>
		</xsl:choose>
	
		<p>
			<span class="left">
				<xsl:apply-templates select="Collectors"/>
				<xsl:text> </xsl:text>
			</span>
			<span class="right">
				<xsl:text> </xsl:text>
				<xsl:call-template name="CollectionDate"/>
			</span>
		</p>

		<p>
			<xsl:if test="./Units/MainUnit/Identifications/Identification/ResponsibleName != ''">
				<span class="left">
					det.
					<xsl:if test="./Units/MainUnit/Identifications/Identification/Agent/FirstNameAbbreviation != ''">
						<xsl:value-of select="./Units/MainUnit/Identifications/Identification/Agent/FirstName"/>
						<xsl:text> </xsl:text>
					</xsl:if>
					<xsl:value-of select="./Units/MainUnit/Identifications/Identification/Agent/SecondName"/>
				</span><br />
			</xsl:if>

			<xsl:if test="./CollectionSpecimen/PreparationMethod!= ''">
				<span class="left">
					<xsl:value-of select="concat('treat: ' , ./CollectionSpecimen/PreparationMethod)"/>
				</span><br />
			</xsl:if>


			<xsl:if test="./CollectionSpecimen/DepositorsName != ''">
				<span class="left">
					<xsl:text>ex coll. </xsl:text>
					<xsl:value-of select="./CollectionSpecimen/DepositorsName"/>
					<xsl:if test="./CollectionSpecimen/DepositorsAccessionNumber != ''">
						<xsl:text>: </xsl:text>
						<xsl:value-of select="./CollectionSpecimen/DepositorsAccessionNumber"/>
					</xsl:if>
				</span><br />
			</xsl:if>
			
			<xsl:if test="$PrintBarcode = 1">
				<span class="right font_barcode">
					<xsl:text> </xsl:text>
					<xsl:if test="./QRcode/ImagePath != ''">
						<xsl:element name="img">
								<xsl:attribute name="src">
									<xsl:value-of select="./QRcode/ImagePath"/>
								</xsl:attribute>
								<xsl:attribute name="align">right</xsl:attribute>
								<xsl:attribute name="height">40</xsl:attribute>
								<xsl:attribute name="width">40</xsl:attribute>
						</xsl:element>
						<br />
					</xsl:if>
				</span>
			</xsl:if>

		</p>
	</xsl:template>

	<xsl:template match="Relations/Relation[RelationType='Child of']">
		<xsl:value-of select="./RelatedSpecimenDisplayText"/>
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
		<xsl:value-of select="./CollectorsName"/>
		<xsl:if test="position()!= last()">; </xsl:if>
	</xsl:template>
	<xsl:template match="CollectorsNumber">
		<xsl:text> </xsl:text>
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template name="Event">
		<p>
			<span class="left">
				<strong><xsl:value-of select="./CollectionEvent/CountryCache"/></strong>
				<xsl:for-each select="./CollectionEventLocalisations/Localisation">
					<xsl:if test="./ParsingMethod = 'Gazetteer'">
						<xsl:if test="./Location1!= '' and LocalisationSystemName='3. Named area (DiversityGazetteer)'">
							<xsl:text>: </xsl:text>
							<xsl:value-of select="./Location1"/>
						</xsl:if>
					</xsl:if>
				</xsl:for-each>
			<xsl:text> </xsl:text>
			</span>
			<span class="right">
				<xsl:for-each select="./CollectionEventLocalisations/Localisation">
					<xsl:choose>
						<xsl:when test="./ParsingMethod = 'Gazetteer'">
							<xsl:if test="./Location1!= '' and LocalisationSystemName='4. Named area (DiversityGazetteer)'">
									<xsl:if test="./CollectionEvent/CountryCache != ''">
										<xsl:text>: </xsl:text>
									</xsl:if>
									<xsl:value-of select="./Location1"/>
							</xsl:if>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>
				<xsl:text> </xsl:text>
			</span>
		</p>
		<p>
			<xsl:if test="./CollectionEvent/LocalityDescription != ''">
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
		<xsl:for-each select="./CollectionEventLocalisations/Localisation">
			<xsl:if test="./ParsingMethod = 'Coordinates'">
				<xsl:if test="./Location2 != '' and ./Location1 != ''">
					<p>
						<xsl:choose>
							<xsl:when test="./LocalisationSystemName = 'Coordinates WGS84' and ./CoordinatesDegMinSec">
								<xsl:value-of select="concat('lat. ',format-number(./Location2,'#.####'),', long. ',format-number(./Location1,'#.####'))"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat(./Location2, ', ', ./Location1)"/>
							</xsl:otherwise>
						</xsl:choose>
					</p>
				</xsl:if>
			</xsl:if>
		</xsl:for-each>
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

	<xsl:template match="text"></xsl:template>
</xsl:stylesheet>
