These import schemas allow the import of DNA samples of parasite fungi (Pucciniales) to existing voucher. 
The host plant and the parasite fungi is already imported in DiversityCollection. The parasite fungi is saved as second Organism on top of the host plant. 

The import table includes the following information:

    Identifiers (e.g. BelegID, )
    Identification of host plant and parasite fungi (Including identifier)
    Parameters regarding the amplifying and sequencing: barcodesequence, primers of pcr and sequencing, trace links, sequencing center

These import schemas were created based on the original organization of the data. For a further successful use of this schema, please keep in mind that interface settings e.g. CollectionID, ProjectID, AnalysisID should be adapted to your installation, as well as other settings like prefixes, postfixes, splitters or filters.

The data was partly imported as two records. In case of a second forward or reverse trace file, you need to import these files with the second schema (02_Add_second_fwd_or_rev_trace.xml).

Furthermore you need to adapt the import scheme in case of a second or third parasite fungi on top of one host plant. Then you have to switch the Attachment from AccessionNumber to IdentificationUnitID.

The settings for the import of the DNA are described below: 
