<?xml version="1.0" encoding="utf-16"?>
<xsl:stylesheet version="1.0"  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" encoding="utf-16"/>

	<xsl:variable name="NoEntriesPage" select="17"/>    <!-- bestimmt die Anzahl der Einträge nach der der Umbruch erfolgen soll -->

	<xsl:variable name="header_left">
		<thead>
			<tr>
				<th class="small">ZFMK</th>
				<th class="big">Species</th>
				<th class="tiny">Sex</th>
				<th class="tiny">Age</th>
				<th class="small">Country</th>
				<th class="big">Locality</th>
				<th class="tiny">Lat <br /> (NS)</th>
				<th class="tiny">Long (EW)</th>
				<th class="tiny">Alt (mNN)</th>
			</tr>
		</thead>
	</xsl:variable>
	
	<xsl:variable name="header_right">
		<thead>
			<tr>
				<th class="medium"> Locality Remarks</th>
				<th class="small">Collection Date</th>
				<th class="medium">Leg.</th>
				<th class="small">Inventory Date</th>
				<th class="medium">Ded.</th>
				<th class="big">General Remarks</th>
			</tr>
		</thead>
	</xsl:variable>
	
	<xsl:template match="/LabelPrint">
		<html>
			<head>
				<style type="text/css" media="screen, print" >
					html,body{height:100%;width:100%;}
					body{padding:0; margin:0; font-family: Arial;}
					p{clear:left; margin:0.1em 0; padding:0; width:100%}
					
					
					table{border-collapse: collapse; table-layout: fixed; font-size:8pt;}
					tr{padding:1; margin:1em 0; height:5em;}	
					th{border: 2px solid black; background-color:#ccc; font-size: 9pt; }
					td{border: 1px solid black; padding: 3px; overflow:hidden; text-overflow: ellipsis;}
					
					thead {display:table-header-group;}
					tbody {display:table-row-group;}

					.tiny{width:37pt;}	<!-- schmale Zelle für Zahlen -->
					.small{width:50pt;}	<!-- breite Zelle für Namen -->
					.medium{width:90pt;} 
					.big{width:100pt;}		

					.breakafter{page-break-after:always; color: white}
				</style>
			</head>
			<body>
				<xsl:for-each select="/LabelPrint/LabelList/Label">
					<xsl:variable name="i" select="position() -1"/>  <!-- notwendig, da mod sonst für den ersten Block -->
																	 <!-- nicht funktioniert (position() fängt bei 1 an!) -->
					<xsl:if test="$i mod $NoEntriesPage = 0">   <!-- nehme nur jeden NoEntriesPage-ten Eintrag -->
						<xsl:call-template name="table_left">   <!-- und rufe die linke Tabelle auf, diese durchläuft alle Einträge der Seite und ruft dann die rechte Tabelle auf und durchläuft nochmal dieselben Einträge-->
							<xsl:with-param name="num">         <!-- in num wird vor dem Durchlauf die erste Position gespeichert (0, 17, 34, ... -->
								<xsl:value-of select="$i"/>     <!-- num erhält den Wert von i -->
							</xsl:with-param>                   
						</xsl:call-template>
					</xsl:if>
				</xsl:for-each>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="table_left">
		<xsl:param name="num"/>
		<table>
			<xsl:copy-of select="$header_left" />
			<tbody>
				<xsl:for-each select="/LabelPrint/LabelList/Label[position() &gt;= $num and position() &lt; ($num + $NoEntriesPage)]">  <!-- solange beide Bedingungen wahr sind, werden die Tabellezeilen aufgebaut (Position >= num AND Position < (num + 17)-->
					<!-- durchlaufe den Block der Einträge für die linke Seite  -->
					<tr>
							<td><xsl:value-of select="./CollectionSpecimen/AccessionNumber"/></td>
							<td>
								<xsl:for-each select="./Units/MainUnit/Identifications/Identification">
									<xsl:if test="position()=1">
										<xsl:for-each select="./Taxon/TaxonPart">
											<xsl:call-template name="TaxonPart"/>
										</xsl:for-each>
									</xsl:if>
								</xsl:for-each> 
							</td>
							
							<td><xsl:value-of select="./Units/MainUnit/Gender"/></td>
							
							<td><xsl:value-of select="./Units/MainUnit/LifeStage"/></td>
							
							<td><xsl:value-of select="./CollectionEvent/CountryCache"/></td>
							
							<td><xsl:value-of select="./CollectionEvent/LocalityDescription"/></td>
							
							<td>
								<xsl:for-each select="./CollectionEventLocalisations/Localisation">
									<xsl:choose>
										<xsl:when test="./ParsingMethod = 'Coordinates'">
											<xsl:if test="./Location2!= ''"> 
												<xsl:value-of select="./Location2"/>
											</xsl:if>
										</xsl:when>					
									</xsl:choose>
								</xsl:for-each>
							</td>
							
							<td>
								<xsl:for-each select="./CollectionEventLocalisations/Localisation">
									<xsl:choose>
										<xsl:when test="./ParsingMethod = 'Coordinates'">
											<xsl:if test="./Location1!= ''">
												<xsl:value-of select="./Location1"/>
											</xsl:if>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</td>
							
							<td>
								<xsl:for-each select="./CollectionEventLocalisations/Localisation">
									<xsl:choose>
										<xsl:when test="./ParsingMethod = 'Altitude'">
											<xsl:if test="./Location1!= ''">
												<xsl:value-of select="./Location1"/>
											</xsl:if>
											<xsl:if test="./Location2!= ''">  - 
												<xsl:value-of select="./Location2"/>
											</xsl:if>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>

		<p class="breakafter">.</p>

		<xsl:call-template name="table_right">   <!-- rufe die rechte Tabelle auf -->
			<xsl:with-param name="num">
				<xsl:value-of select="$num"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="table_right">
		<xsl:param name="num"/>
		<table>
			<xsl:copy-of select="$header_right" />
			<tbody>
				<xsl:for-each select="/LabelPrint/LabelList/Label[position() &gt;= $num and position() &lt; ($num + $NoEntriesPage)]">
					<!-- durchlaufe den Block der Einträge für die rechte Seite  -->
					<tr>
							<td><xsl:value-of select="./CollectionEvent/Notes"/></td>
							
							<td><xsl:call-template name="CollectionDate"/></td>
							
							<td><xsl:apply-templates select="Collectors"/></td>
							
							
							
							<td>IIX.2020</td><!-- noch: Datum der Inventarisierung  noch nicht importiert-->
							
							<td>
								<xsl:if test="./CollectionSpecimen/DepositorsName != ''">
									<span>
										<xsl:value-of select="./CollectionSpecimen/DepositorsName"/>		
									</span>
								</xsl:if>
							</td>
							
							<td>	<!-- GeneralRemarks-->
								<xsl:if test="./CollectionSpecimen/OriginalNotes != ''">
									<xsl:value-of select="./CollectionSpecimen/OriginalNotes"/>; 
								</xsl:if>
								<xsl:if test="./Units/MainUnit/Identifications/Identification/TypeStatus != ''">
									 <xsl:value-of select="./Units/MainUnit/Identifications/Identification/TypeStatus"/>; 
								</xsl:if>
								<xsl:if test="./CollectionSpecimen/Notes != ''">
									 <xsl:value-of select="./CollectionSpecimen/Notes"/>; 
								</xsl:if>
								<xsl:if test="./CollectionSpecimen/DepositorsAccessionNumber != ''">
									 <xsl:value-of select="./CollectionSpecimen/DepositorsAccessionNumber"/> <!-- alte Sammlungsnummer oder Feldnummer -->
								</xsl:if>
																					
							</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>

		<p class="breakafter">.</p>

	</xsl:template>

	<!--  Aufgerufene Templates -->
	<!--  Linke Tabelle -->
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
	
	<!--  rechte Tabelle -->
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

</xsl:stylesheet>

	