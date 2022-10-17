This folder contains analyses on biomass growth - stand age realationships 

Like growth - plot biomass, three analyses were done. They all use the same analytical pipeline (i.e., code) applied to different version of the G dataset. 

1. The entire plot biomass growth vs. plot biomass dataset.
    - FIA_nls3_BiomassG_StdAge.Rmd/html

2. A "temporally-balanced" plot biomass growth vs. stand age dataset, where only one growth measurement per plot per decade (2000-2010, and 2011-2020) was considered (in cases where plots had more than 2 records, we used the first and last measurements).
    - FIA_nls3_BiomassG_StdAge_TemporallyBalanced.Rmd/html

3. A "temporally-balanced" plot biomass growth vs. plot biomass dataset, excluding plots which experienced timber harvest.
    - FIA_nls3_BiomassG_StdAge_TemporallyBalanced_NoHarvest.Rmd/html
