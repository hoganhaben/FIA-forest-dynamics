This folder contains analyses related to forest biomass - stand age relationships.

Four analyses were carried out, which use the same analytical pipeline (i.e., code) implemented to different datasets
See the files (.html and .Rmd files) for each analysis.

1. The entire FIA plot biomass dataset (P dataset).
    - FIA_nls3_plotB_StdAge.Rmd/html

2. The same plot records included in the plot biomass growth vs. plot biomass analyses (G dataset).
    -  FIA_nls3_plotB_StdAge_ReconciledG.Rmd/html

3. The same plot records included in the plot biomass growth vs. plot biomass analyses, but "temporally-balanced" to include only one plot measurement per decade (in cases where plots had more than 2 records, we used the first and last measurements).
    -  FIA_nls3_plotB_StdAge_TemporallyBalanced.Rmd/html

3.  The same plot records included in the plot biomass growth vs. plot biomass analyses, but "temporally-balanced" to include only one plot measurement per decade, and excluding any plots which experienced timber harvest. 
    -  FIA_nls3_plotB_StdAge_TemporallyBalanced_NoHarvest.Rmd/html
