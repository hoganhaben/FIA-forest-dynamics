This folder contains analyses related to forest biomass - stand age relationships.

Four analyses were carried out, which use the same analytical pipeline (i.e., code) implemented to different datasets
See the files (.html and .Rmd files) for each analysis.

We fitted models using two functional forms: 1) Michaelis-Menten equation and 2) Log-Normal equation.  The Log-Normal models generally fit the data better, so we went with them.  They are in the main folder here, and the Michaelis-Menten fits are in a separate sub-folder.

1. The entire FIA plot biomass dataset (P dataset).
    - FIA_nls3_plotB_StdAge_LogNormal.Rmd/html

2. The same plot records included in the plot biomass growth vs. plot biomass analyses (G dataset).
    -  FIA_nls3_plotB_StdAge_ReconciledG_LogNormal.Rmd/html

3. The same plot records included in the plot biomass growth vs. plot biomass analyses, but "temporally-balanced" to include only one plot measurement per decade (in cases where plots had more than 2 records, we used the first and last measurements).
    -  FIA_nls3_plotB_StdAge_TemporallyBalanced_LogNormal.Rmd/html

3.  The same plot records included in the plot biomass growth vs. plot biomass analyses, but "temporally-balanced" to include only one plot measurement per decade, and excluding any plots which experienced timber harvest. 
    -  FIA_nls3_plotB_StdAge_TemporallyBalanced_NoHarvest_LogNormal.Rmd/html
