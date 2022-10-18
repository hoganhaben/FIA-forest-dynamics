# FIA-forest-dynamics

*Quantifying changes in the dynamics of U.S. forests using national forest inventory data*

*Objective*:  To estimate biomass stock and biomass growth enhancement effects using non-linear modeling techniques. 

*Data*:  Data from the United States Forest Service's Forest Inventory and Analysis program from 2000-2022 were used (see https://www.fia.fs.usda.gov/).
We recommend the rFIA package for downloading FIA data tables (see `rfia::getFIA`, https://rfia.netlify.app/).

This repository includes: 

* analyses which fit non-linear weighted least-squares regressions to: 
    - biomass-stand age relationships, 
    - growth-biomass relationships, and 
    - growth-stand age relationships.

Each analysis is included in a separate sub-folder.


* code used to process Palmer Drought Severity Index (PDSI) data, which is included in our non-linear models.
 
 
* code used to derive processed FIA datasets, from the FIA datatables.  Processed datasets, including metadata, are archived in this main directory:
    1.  a processed FIA plot biomass dataset (P)
        - codefile: create_P.R
        - dataset: P_dataset.Rdata
        - metadata: P_metadata.txt
    
    2.  a processed FIA plot biomass growth dataset (G)
        - codefile: create_G.R
        - dataset: G_dataset.Rdata
        - metadata: G_metadata.txt
