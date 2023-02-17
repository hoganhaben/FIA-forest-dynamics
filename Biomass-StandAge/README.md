This folder contains analyses for biomass vs. stand age.

For the biomass vs. stand age analyses, we consider two functional forms for the age function: 1) the Michaelis-Menten form and 2) the Log-Normal form.  The model selection procedure is performed in three steps.  First, the simple Michaelis-Menten form is used and the phi and alpha parameters are added to model to determine if they improve model fit.  The best-fitting model from this step is used downstream where shape (s) and intercept (terms) are added, and the best-fitting model is re-selected.  Finally, a third model selection is perfomed taking the best fitting model form the previous two steps and comparing it to the models using the Log-Normal form of the age function.  This procedure is performed separately by ecoprovince.  

Two analyses were carried out for biomass vs. stand age.  Both analyses use the same analytical pipeline (i.e., code) implemented to different datasets. 

1. The main analysis is: [FIA_nls3_plotB_StdAge_ReconciledG_FINAL.html](https://htmlpreview.github.io/?https://github.com/hoganhaben/FIA-forest-dynamics/blob/main/Biomass-StandAge/FIA_nls3_plotB_StdAge_ReconciledG_FINAL.html) (the .Rmd is the R markdown code file that makes the html output file)

2. The addidional analyses are in: [FIA_nls3_plotB_StdAge_ReconciledG_Other_Datasets.html](https://htmlpreview.github.io/?https://github.com/hoganhaben/FIA-forest-dynamics/blob/main/Biomass-StandAge/FIA_nls3_plotB_StdAge_ReconciledG_Other_Datasets.html)
In the additional analyses (i.e., for "Other_Datasets), the same analytical approach is complete, but for two additional data subsets: 
   - a "temporally-balanced" dataset, which includes only a single plot measurement per decade.  In cases where plots had more than 2 records, we used the first and last measurements. 
   - a "temporally-balanced, no harvest" dataset, which takes the dataset used in 1 (above) and furhter excludes any plot locations which have experience timber harvest (at any point over the study period (2000-2022).
These analyses are contained in the same file one after another.
