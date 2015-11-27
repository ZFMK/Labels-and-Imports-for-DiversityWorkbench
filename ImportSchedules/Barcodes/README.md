# German Barcode of Life (GBOL)

## Import of Barcodes

### Prerequisites
- Collection specimen entries are already present in DiversityCollection
- Import schedule attaches data via merge/update
- Analysis and Methods are laid out


### Scheme for Analysis:

| id  | Name      |
|-----|-----------|
| 146 | Barcoding |
| 155 | Barcode   |

![Preview](https://github.com/ZFMK/Labels-and-Imports-for-DiversityWorkbench/blob/screenshots/preview/barcodes_in_dc_methods_analysis_definition.png)

### Scheme for Methods:

| id | Method         | Analysis                    | Remarks                   |
|----|----------------|-----------------------------|---------------------------|
| 12 | Barcode        |                             |                           |
|    |                | project                     |                           |
|    |                | failure                     |                           |
|    |                | failure detail              |                           |
|    |                | region                      | genregion (CO1, LSU, ...) |
| 14 | Sequencing_Fwd |                             |                           |
|    |                | direction                   | forward                   |
|    |                | pcr_primer_forward_name     |                           |
|    |                | pcr_primer_forward_sequence |                           |
|    |                | pcr_primer_reverse_name     |                           |
|    |                | pcr_primer_reverse_sequence |                           |
|    |                | sequencing_primer_name      |                           |
|    |                | sequencing_primer_sequence  |                           |
|    |                | sequencing_timestamp        |                           |
|    |                | sequencing_lab              |                           |
|    |                | trace_file_name             |                           |
|    |                | trace_file_url              |                           |
| 15 | Sequencing_Rev |                             |                           |
|    |                | direction                   | reverse                   |
|    |                | pcr_primer_forward_name     |                           |
|    |                | pcr_primer_forward_sequence |                           |
|    |                | pcr_primer_reverse_name     |                           |
|    |                | pcr_primer_reverse_sequence |                           |
|    |                | sequencing_primer_name      |                           |
|    |                | sequencing_primer_sequence  |                           |
|    |                | sequencing_timestamp        |                           |
|    |                | sequencing_lab              |                           |
|    |                | trace_file_name             |                           |
|    |                | trace_file_url              |                           |

![Preview](https://github.com/ZFMK/Labels-and-Imports-for-DiversityWorkbench/blob/screenshots/preview/barcodes_in_dc_methods_methods_definition.png)

## Preview of data in DiversityCollection

![Preview](https://github.com/ZFMK/Labels-and-Imports-for-DiversityWorkbench/blob/screenshots/preview/barcodes_in_dc_methods_preview.png)


