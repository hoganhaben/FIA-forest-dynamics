This folder contains code for the procssing of Palmer Drought Severity Index (PDSI) rasters from the PRISM Climate group. 

The PRISM Climate Group archives, collates and develops spatial climate datasets (many of which are for the coterminous USA).  see: https://prism.oregonstate.edu/

PDSI is calculated using precipitation and temperature data, and is a metric of relative climate dryness.  The index is based on a physical water balance model and empirical temperature data.  It successfully captures landscape variation in drought and evapotranspiration (a key climatic control on drought development and severity), at annual and supra-annual scales.  It ranges from -10 (dry) to +10 (wet), but typically spans a -4 to +4 range.  For more information see Palmer 1965, Dai 2011.

Archived PRISM dataproducts (raster files) were obtained from the Western Regional Climate Center (wrcc.dri.edu) dataportal.  https://wrcc.dri.edu/wwdt/data/PRISM/pdsi/
I recommend you access the data directly.

In our analysese PDSI is incorpated as a change in PDSI (ΔPDSI).  We explored several ways of incorporating PDSI data into our analyses, experimenting with the monthly temporal window to consider and various time periods for baseline vs. observed values.  We settled on implementing a PDSI baseline based on the 1960-1989 time period (which is a 30-year climate normal).  We use a monthly window for each year from January to August (the growing season excluding the winter). 

  - For all analyses, PDSI for the growth interval was calulated as the average of the PDSI values from January to August for the years between the intial plot measurement and the plot re-measurement.  ΔPDSI is defined as PDSI growth interval - PDSI basineline.  ΔPDSI is positive when the climate trend is moving toward wetter and cooler conditions, and negative when the climate trend is shifting toward warmer and drier conditions

One processing script and one dataset is included here:
  - processing script: FIA_PDSI_wrangling.Rmd/html
  - dataset: G_pdsi_data.Rdata: ΔPDSI dataset for FIA plots for all growth analyses using the G dataset. 

References 

Dai, A., 2011. Characteristics and trends in various forms of the Palmer Drought Severity Index (PDSI) during 1900-2008. J. Geophys. Res., 116, D12115 https://doi.org/10.1029/2010JD015541

Palmer, W. C., 1965. Meteorological Drought. Res. Paper No.45, 58pp., Dept. of Commerce, Washington, D.C. https://www.droughtmanagement.info/literature/USWB_Meteorological_Drought_1965.pdf
