<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:variable name="Space"> </xsl:variable>
	<xsl:decimal-format name="eu" decimal-separator=',' grouping-separator='.' />
	<xsl:variable name="BackgroundImage">https://biocase.zfmk.de/logo/Logo_ZFMK_Small.svg</xsl:variable>

	<!-- Content -->
	<xsl:template name="content">
		<xsl:call-template name="Event"/>
		<xsl:choose>
			<xsl:when test="./Units/MainUnit/Circumstances != ''">
				<p>
					<strong><xsl:value-of select="concat(./Units/MainUnit/Circumstances, ': ')"/></strong>
					<xsl:apply-templates select="Relations/Relation[RelationType='Child of']"/>
				</p>
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
			<xsl:for-each select="./Units/MainUnit/Identifications/Identification">
				<xsl:if test="position()=1">
					<xsl:if test="./ResponsibleName != ''">
						<span class="left">
							det.
							<xsl:value-of select="./Agent/SecondName"/>
							<xsl:if test="./Agent/FirstName != ''">
								<xsl:value-of select="concat(', ', ./Agent/FirstName)"/>
							</xsl:if>
						</span><br />
					</xsl:if>
				</xsl:if>
			</xsl:for-each>

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
			
		</p>

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

	</xsl:template>

	<xsl:template match="Relations/Relation[RelationType='Child of']">
		<xsl:value-of select="./RelatedSpecimenDisplayText"/>
	</xsl:template>
	
	<xsl:template name="Identification">
		<p class="taxon_name">
			<xsl:if test="not(./Taxon/TaxonPart)">
				<xsl:value-of select="./TaxonomicName"/>
			</xsl:if>
			<xsl:if test="./Taxon/TaxonPart">
				<xsl:for-each select="./Taxon/TaxonPart">
					<xsl:call-template name="TaxonPart"> <!-- Test case: ICH-135090 -->
						<xsl:with-param name="ParamIdentificationQualifierText">
							<xsl:value-of select="ancestor::Identification[1]/IdentificationQualifier"/>
						</xsl:with-param>
						<xsl:with-param name="ParamQualifierText">
							<xsl:value-of select="ancestor::Identification[1]/QualifierText"/>
						</xsl:with-param>
						<xsl:with-param name="ParamQualifierRank">
							<xsl:value-of select="ancestor::Identification[1]/QualifierRank"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:if>
		</p>
	</xsl:template>
	
	<xsl:template name="TaxonPart">
		<xsl:param name="ParamIdentificationQualifierText"/>
		<xsl:param name="ParamQualifierText"/>
		<xsl:param name="ParamQualifierRank"/>

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
			<xsl:choose>
				<xsl:when test="$ParamQualifierText != ''">
					<xsl:value-of select="concat($ParamQualifierText, ' ')"/>
				</xsl:when>
				<xsl:when test="$ParamIdentificationQualifierText != ''">
					<xsl:value-of select="concat($ParamIdentificationQualifierText, ' ')"/>
				</xsl:when>
				<xsl:otherwise>
					sp. <!--xsl:value-of select="concat('sp. ', ' ')"/-->
				</xsl:otherwise>
			</xsl:choose>
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
		<xsl:if test="$ParamQualifierRank = 'sp.' and not(./QualifierSpecies)">
			<xsl:value-of select="concat($ParamQualifierText, ' ')"/>
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
			<xsl:if test="./CollectionEvent/CollectionEndYear != '' or ./CollectionEvent/CollectionEndMonth != '' or ./CollectionEvent/CollectionEndDay != ''">
				<xsl:text>-</xsl:text>
			</xsl:if>
		</xsl:if>
		<xsl:if test="./CollectionEvent/CollectionDate != '' and not(./CollectionEvent/CollectionYear) and not(./CollectionEvent/CollectionMonth) and not(./CollectionEvent/CollectionDay)">
			<xsl:value-of select="./CollectionEvent/CollectionDate"/>
		</xsl:if>
		<xsl:if test="./CollectionEvent/CollectionEndYear != '' or ./CollectionEvent/CollectionEndMonth != '' or ./CollectionEvent/CollectionEndDay != ''">
			<xsl:value-of select="./CollectionEvent/CollectionEndDay"/>
			<xsl:if test="./CollectionEvent/CollectionEndDay != ''">.</xsl:if>
			<xsl:call-template name="CollectionEndMonth"/>
			<xsl:if test="./CollectionEvent/CollectionEndMonth != ''">.</xsl:if>
			<xsl:value-of select="./CollectionEvent/CollectionEndYear"/>
		</xsl:if>
	</xsl:template>

	<xsl:template name="Event">
		<p>
			<span class="left">
				<xsl:if test="./CollectionEvent/CountryCache != '' and ./CollectionEvent/CountryCache != 'N/A'">
					<strong><xsl:value-of select="./CollectionEvent/CountryCache"/></strong>
				</xsl:if>
				<xsl:for-each select="./CollectionEventLocalisations/Localisation">
					<xsl:if test="./ParsingMethod = 'Gazetteer'">
						<xsl:if test="./Location1!= '' and LocalisationSystemName='3. Named area (DiversityGazetteer)'">
							<xsl:text> </xsl:text>
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
									<xsl:text> </xsl:text>
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

	<xsl:template match="Collectors">
		leg. <xsl:apply-templates select="Collector"/>
	</xsl:template>

	<xsl:template match="Collector">
		<xsl:value-of select="./Agent/SecondName"/>
		<xsl:if test="./Agent/FirstName != ''">
			<xsl:value-of select="concat(', ', ./Agent/FirstName)"/>
		</xsl:if>
		<xsl:if test="position()!= last()">; </xsl:if>
	</xsl:template>
	
	<xsl:template match="CollectorsNumber">
		<xsl:text> </xsl:text>
		<xsl:value-of select="."/>
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
	<xsl:template name="CollectionEndMonth">
		<xsl:if test="./CollectionEvent/CollectionEndMonth != ''">
			<xsl:if test="./CollectionEvent/CollectionEndMonth = 1">I</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionEndMonth = 2">II</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionEndMonth = 3">III</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionEndMonth = 4">IV</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionEndMonth = 5">V</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionEndMonth = 6">VI</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionEndMonth = 7">VII</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionEndMonth = 8">IIX</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionEndMonth = 9">IX</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionEndMonth = 10">X</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionEndMonth = 11">XI</xsl:if>
			<xsl:if test="./CollectionEvent/CollectionEndMonth = 12">XII</xsl:if>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>