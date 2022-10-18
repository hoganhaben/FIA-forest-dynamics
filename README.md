# FIA-forest-dynamics

Quantifying changes in the dynamics of U.S. forests using national forest inventory data

Objective:  To estimate biomass stock and biomass growth enhancement effects usingn non-linear modeling techniques. 

Data:  Data from the United States Forest Service's Forest Inventory and Analysis program were used. https://www.fia.fs.usda.gov/
We recommend the rFIA package for downloading FIA data tables (see rfia::getFIA).  https://rfia.netlify.app/ 

In this repository we include: 
* code used to derive processed FIA datasets, from the FIA data tables.  We include those processed data products including metadata.
* code used to processed Palmer Drought Severity Index (PDSI) data to include in our models.
* code for fitting non-linear weighted least-squares regressions to: 
    - biomass-stand age relationships, 
    - growth-biomass relationships, and 
    - growth-stand age relationships.

* code for deriving processed FIA datasets from FIA datatables
    1.  our FIA plot biomass dataset (P)
        - codefile: create_P.R
        - dataset: FIA_P_dataset.Rdata
    
    2. our FIA plot biomass growth dataset (G)
        - codefile: create_G.R
        - dataset: FIA_G_dataset.Rdata
