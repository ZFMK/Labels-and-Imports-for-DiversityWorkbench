# German Barcode of Life (GBOL)

## Import of Barcodes

### Prerequisites
- Collection specimen entries are already present in DiversityCollection
- Import schedule attaches data via merge/update
- Analysis and Methods are laid out


### Scheme for Analysis:

| id  | Name               |
|-----|--------------------|
|  94 | Barcode            |
| 161 | Barcode_Analyse161 |

![Preview](https://github.com/ZFMK/Labels-and-Imports-for-DiversityWorkbench/blob/master/ImportSchedules/GBOL/Barcodes/screenshot_analysis161.png)


### Scheme for Methods:

| id | Method         | Parameter                    |    | Remarks                           |
|----|----------------|------------------------------|----|-----------------------------------|
| 12 | Barcode        |                              |    |                                   |
|    |                | project                      | 27 |                                   |
|    |                | failure                      | 28 | failure occured during sequencing |
|    |                | failure detail               | 29 | Desription of failure             |
|    |                | region                       | 62 | genregion (CO1, LSU, ...)         |
|    |                | sequence_length              | 86 | length of consensus sequence      |
|    |                | trace_count                  | 87 | number of traces                  |
|    |                | barcode_compliant            | 88 |                                   |
|    |                | sequence                     | 90 | the consensus sequence            |
|    |                |                              |    |                                   |
|    |                |                              |    |                                   |
| 16 | Sequencing     |                              |    |                                   |
|    |                | direction                    | 73 | forward or reverse                |
|    |                | pcr_primer_forward_name      | 63 |                                   |
|    |                | pcr_primer_forward_sequence  | 64 |                                   |
|    |                | pcr_primer_reverse_name      | 65 |                                   |
|    |                | pcr_primer_reverse_sequence  | 66 |                                   |
|    |                | sequencing_primer_name       | 91 |                                   |
|    |                | sequencing_primer_sequence   | 92 |                                   |
|    |                | sequencing_timestamp         | 71 |                                   |
|    |                | sequencing_labor             | 72 |                                   |
|    |                | trace_filename               | 74 |                                   |
|    |                | trace_file_url               | 75 |                                   |
|    |                | trace_file_org_length        | 76 |                                   |
|    |                | trace_file_org_md5           | 77 |                                   |
|    |                | trace_file_encoded           | 78 |                                   |
|    |                | trace_file_encoding          | 79 |                                   |
|    |                | trace_file_enc_length        | 80 |                                   |
|    |                | trace_file_format            | 81 |                                   |
|    |                | trace_id                     | 83 |                                   |
|    |                | sequence_id                  | 84 |                                   |
|    |                | well                         | 85 |                                   |


### Detailed Description of Import schedule

![Preview](https://github.com/ZFMK/Labels-and-Imports-for-DiversityWorkbench/blob/master/ImportSchedules/GBOL/Barcodes/Description_Import_Barcodeanalyse_BOLD_to_DC.pdf)

![Preview](https://github.com/ZFMK/Labels-and-Imports-for-DiversityWorkbench/blob/master/ImportSchedules/GBOL/Barcodes/screenshot_method_barcode.png)
![Preview](https://github.com/ZFMK/Labels-and-Imports-for-DiversityWorkbench/blob/master/ImportSchedules/GBOL/Barcodes/screenshot_method_sequencing.png)

## Preview of data in DiversityCollection

![Preview](https://github.com/ZFMK/Labels-and-Imports-for-DiversityWorkbench/blob/master/ImportSchedules/GBOL/Barcodes/screenshot_preview_data.png)

