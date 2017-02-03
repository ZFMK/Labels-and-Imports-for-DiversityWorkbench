USE [DiversityCollection_SGND]
GO

DECLARE @institutes_name nvarchar(50) = '<Insert name of institute name>';
DECLARE @ProjectID int = (Select ProjectID From [DiversityProjects_ZFMK].[dbo].[Project] Where Project = '<peoject name within DiversityProjects>');

DECLARE @analysis_barcode_id1 int = 146;
DECLARE @analysis_barcode_id2 int = 161;
DECLARE @method_id1 int = 12;
DECLARE @method_id2 int = 16;

Declare @projects table (projectID int Primary key);
Declare @tax_groups table (tax_name nvarchar(50) Primary key);

Insert Into @projects Values (@ProjectID);
Insert Into @tax_groups Values ('animal'), ('insect'), ('fungus'), ('plant');

IF NOT EXISTS (SELECT AnalysisID FROM Analysis WHERE AnalysisID in (@analysis_barcode_id1, @analysis_barcode_id2)) BEGIN
	SET IDENTITY_INSERT Analysis ON;
	INSERT INTO [Analysis]
			   ([AnalysisID]
			   ,[AnalysisParentID]
			   ,[DisplayText]
			   ,[Description]
			   ,[MeasurementUnit]
			   ,[Notes]
			   ,[OnlyHierarchy]
			   ,[RowGUID])
		 VALUES
	(@analysis_barcode_id1
		, NULL
		, 'Barcoding'
		, NULL
		, NULL
		, NULL
		, 1
		, '33873E5E-15C3-E211-9AFD-00163E343213'),
	(@analysis_barcode_id2
		, @analysis_barcode_id1
		, 'A_'+@institutes_name+cast(@analysis_barcode_id2 AS nvarchar)
		, 'Barcodes for '+@institutes_name+' using Methods'
		, NULL
		, 'The sequence must be written into Analysis Results!'
		, 0
		,'90AF28FD-F102-E611-8D1A-00155D4BD503');
	SET IDENTITY_INSERT Analysis OFF;

	INSERT INTO [AnalysisTaxonomicGroup]
			   ([AnalysisID]
			   ,[TaxonomicGroup])
	select @analysis_barcode_id1, tax_name from @tax_groups;
	INSERT INTO [AnalysisTaxonomicGroup]
			   ([AnalysisID]
			   ,[TaxonomicGroup])
	select @analysis_barcode_id2, tax_name from @tax_groups;

	INSERT INTO [ProjectAnalysis]
			   ([AnalysisID]
			   ,[ProjectID])
	select @analysis_barcode_id1, projectID from @projects;
END

IF NOT EXISTS (SELECT MethodID FROM Method WHERE MethodID in (@method_id1, @method_id2)) BEGIN
	SET IDENTITY_INSERT Method ON;
	INSERT INTO [Method]
			   ([MethodID], [MethodParentID]
			   ,[OnlyHierarchy]
			   ,[DisplayText]
			   ,[Description]
			   ,[Notes]
			   ,[RowGUID])
		 VALUES
	(@method_id1, NULL, 0, 'Barcode', 'Container for barcodes. The consensus sequence must be written into Analysis Results!','The consensus sequence can be duplicated into the parameter `sequence` for security', 'A2396487-8942-E511-B59E-00155D4BD503'),
	(@method_id2, @method_id1, 0, 'Sequencing', 'Data from PCR amplification and from the sequencing procedure', NULL, '943FA5A4-F302-E611-8D1A-00155D4BD503');
	SET IDENTITY_INSERT Method OFF;

	INSERT INTO [MethodForAnalysis]
			   ([AnalysisID]
			   ,[MethodID]
			   ,[RowGUID])
		 VALUES
	(@analysis_barcode_id2, @method_id1, '90F4136C-6F08-E611-8D1A-00155D4BD503'),
	(@analysis_barcode_id2, @method_id2, '387442B4-F402-E611-8D1A-00155D4BD503');


	SET IDENTITY_INSERT [Parameter] ON;
	INSERT INTO [Parameter]
			   ([MethodID]
			   ,[ParameterID]
			   ,DisplayText
			   ,[Description]
			   ,[RowGUID])
		 VALUES
	(@method_id1, 27, 'project',NULL, '9AEDC591-8A42-E511-B59E-00155D4BD503'),
	(@method_id1, 28, 'failure','failure occured during sequencing', '9BEDC591-8A42-E511-B59E-00155D4BD503'),
	(@method_id1, 29, 'failure_detail','Description of the failure, e.g. taxa in the contamination, only 1 trace, stop codon is in sequence or flagged record', '0159A39B-8A42-E511-B59E-00155D4BD503'),
	(@method_id1, 62, 'region','Genlokus (CO1, LSU, ...)', '552D8EBC-8A5B-E511-B59E-00155D4BD503'),
	(@method_id2, 63, 'pcr_primer_forward_name',NULL, '068664EE-F302-E611-8D1A-00155D4BD503'),
	(@method_id2, 64, 'pcr_primer_forward_sequence',NULL, '95AE8FF6-F302-E611-8D1A-00155D4BD503'),
	(@method_id2, 65, 'pcr_primer_reverse_name',NULL, 'EA92AF00-F402-E611-8D1A-00155D4BD503'),
	(@method_id2, 66, 'pcr_primer_reverse_sequence',NULL, '90A7E608-F402-E611-8D1A-00155D4BD503'),
	(@method_id2, 67, 'sequencing_primer_forward_name',NULL, 'FEFB5114-F402-E611-8D1A-00155D4BD503'),
	(@method_id2, 68, 'sequencing_primer_forward_sequence',NULL, '2D42931E-F402-E611-8D1A-00155D4BD503'),
	(@method_id2, 69, 'sequencing_primer_reverse_name',NULL, 'F7706925-F402-E611-8D1A-00155D4BD503'),
	(@method_id2, 70, 'sequencing_primer_reverse_sequence',NULL, 'F314742C-F402-E611-8D1A-00155D4BD503'),
	(@method_id2, 71, 'sequencing_timestamp',NULL, '0249953A-F402-E611-8D1A-00155D4BD503'),
	(@method_id2, 72, 'sequencing_labor',NULL, '938A9D41-F402-E611-8D1A-00155D4BD503'),
	(@method_id2, 73, 'direction',NULL, '450BC847-F402-E611-8D1A-00155D4BD503'),
	(@method_id2, 74, 'trace_filename',NULL, '460BC847-F402-E611-8D1A-00155D4BD503'),
	(@method_id2, 75, 'trace_file_url',NULL, '35AE4153-F402-E611-8D1A-00155D4BD503'),
	(@method_id2, 76, 'trace_file_org_length',NULL, '0569D65D-F402-E611-8D1A-00155D4BD503'),
	(@method_id2, 77, 'trace_file_org_md5',NULL, 'DDAE2166-F402-E611-8D1A-00155D4BD503'),
	(@method_id2, 78, 'trace_file_encoded',NULL, '8C60B06C-F402-E611-8D1A-00155D4BD503'),
	(@method_id2, 79, 'trace_file_encoding',NULL, '93197173-F402-E611-8D1A-00155D4BD503'),
	(@method_id2, 80, 'trace_file_enc_length',NULL, '031C577B-F402-E611-8D1A-00155D4BD503'),
	(@method_id2, 81, 'trace_file_format',NULL, '14FEF285-F402-E611-8D1A-00155D4BD503'),
	(@method_id2, 83, 'trace_id',NULL, 'FD20FFAD-F502-E611-8D1A-00155D4BD503'),
	(@method_id2, 84, 'sequence_id',NULL, 'B9F910FD-F602-E611-8D1A-00155D4BD503'),
	(@method_id2, 85, 'well',NULL, 'FF95E708-F702-E611-8D1A-00155D4BD503'),
	(@method_id1, 86, 'sequence_length','length of consensus sequence', '68D287A1-2118-E611-8D1A-00155D4BD503'),
	(@method_id1, 87, 'trace_count','number of traces', '5EAB7FB2-2118-E611-8D1A-00155D4BD503'),
	(@method_id1, 88, 'barcode_compliant',NULL, '3E3450BF-2118-E611-8D1A-00155D4BD503'),
	(@method_id1, 89, 'sequence','the consensus sequence', '789BB990-6D1E-E611-8691-00155D4BD503');
	SET IDENTITY_INSERT [Parameter] OFF;

	INSERT INTO [ParameterValue_Enum]
			   ([MethodID]
			   ,[ParameterID]
			   ,[Value]
			   ,[DisplayText])
		 VALUES
	(@method_id2, 73, 'forward', 'forward'),
	(@method_id2, 73, 'reverse', 'reverse'),
	(@method_id2, 79, 'base64', 'base64'),
	(@method_id2, 79, 'hex', 'hex'),
	(@method_id2, 79, 'not_encoded', 'not_encoded'),
	(@method_id2, 81, 'ABI', 'ABI'),
	(@method_id2, 81, 'SCF', 'SCF');
END
GO
