# FIA-forest-dynamics

*Quantifying changes in the dynamics of U.S. forests using national forest inventory data*

*Objective*:  To estimate biomass stock and biomass growth productivity trends using non-linear modeling techniques.  We define the productivty trend as the net temporal change in biomass stock or biomass growth due to positive (e.g., CO2 fertilization) and negative  (e.g., warming, drought) environmental drivers.

*Data*:  Data from the United States Forest Service's Forest Inventory and Analysis program from ~2000-2022 were used (see https://www.fia.fs.usda.gov/).
We recommend the rFIA package for downloading FIA data tables (see `rfia::getFIA`, https://rfia.netlify.app/).

This respository accompanies Hogan et al. "Climate change determines the sign of productivity trends in US forests"  (*in review* at *PNAS*)

This repository includes: 

* code used to derive a single processed FIA dataset from the FIA datatables. That dataset, including metadata, are archived in this main directory:
    - A single processed FIA plot biomass growth dataset (G) is used for all analyses.  This dataset is structured at the second of two FIA plot measurments (i.e., at the re-measurment).  For analyses which use plot biomass as the response variable, the very first plot measument is not included in the mode fits (i.e., biomass models are fit only to the t2 obsrevations to make the sample of data consistent with that used in growth analyses).  For growth analyses, the growth interval is defined between successive plot meausurements (i.e., the growth measurements is at t2).  

                    - codefile: create_Growth.R
                    - dataset: Growth.Rdata
                    - metadata: Growth_metadata.txt

* analyses which fit non-linear weighted least-squares regressions to: 
    - biomass vs. stand age, 
    - growth vs. biomass, and 
    - growth vs. stand age.

Each analysis is included in a separate sub-directory.  
