### CREATE P - dataset -- 5.20.2022 - for hopefully the last time. 
### P is the plotbiomass dataset
### JAH
### FIA eCO2 project

rm(list = ls()) #Start clean

setwd("C:/Users/hogan.jaaron/Dropbox/FIA_R/Starter_FIA_data_processing") ##set wd

### Reading in the FIA data
### load data for biomass stocks  --- calculated using rFIA biomass function -  see FIA_starte.RMd
load("C:/Users/hogan.jaaron/Dropbox/FIA_R/Biomass calculation_rFIA/FIA_Biomass_allPlots.Rdata")

### load data from plot condition tables
load("C:/Users/hogan.jaaron/Dropbox/FIA_R/Plot Conditions_rFIA/FIA_conditions_allPlots.Rdata")
FIA_conditions$STATE <- as.factor(FIA_conditions$STATE)
FIA_conditions$PROP_BASIS <- as.factor(FIA_conditions$PROP_BASIS)
FIA_conditions$MIXEDCONFCD <- as.factor(FIA_conditions$MIXEDCONFCD)
FIA_conditions$DWM_FUELBED_TYPCD  <-  as.factor(FIA_conditions$DWM_FUELBED_TYPCD)

### load data from plot tables
load("C:/Users/hogan.jaaron/Dropbox/FIA_R/Plot Conditions_rFIA/FIA_plots_allPlots.Rdata")
FIA_plots$STATE <- as.factor(FIA_plots$STATE)
FIA_plots$ECOSUBCD <- as.factor(FIA_plots$ECOSUBCD)

##### COMBINE PLOT and CODITION TABLES - P_cond
P_cond <- dplyr::left_join(FIA_conditions, FIA_plots, by = c("STATE", "PLOT", "INVYR", "PLT_CN" = "CN"))  #PLT_CN = CN  merges condition table to the plot table using PLT_CN (see FIA data user guide 8.0)

### load data from the survey tables
load("C:/Users/hogan.jaaron/Dropbox/FIA_R/Plot Conditions_rFIA/FIA_survey.Rdata")

##### COMBINE P_cond and survey tables
P_cond_surv <- dplyr::left_join(P_cond, FIA_survey[,c("CN", "P3_OZONE_IND", "ANN_INVENTORY")], by = c("SRV_CN" = "CN"))
#### vvvvvvvvvvvvvvvv ####----------------------------------------------------------------------------------------------------------
#### APPLYING FILTERS ####

## remove cases of NA's STDAGE columns
P_cond_surv <- P_cond_surv[!is.na(P_cond_surv$STDAGE) & !P_cond_surv$STDAGE == 9999,]
## Filter out plantations
P_cond_surv <- P_cond_surv[P_cond_surv$STDORGCD == 0, ]
## Filter plots with a single condition using a 95% threshold for CONDPROP_UNADJ
P_cond_surv <- P_cond_surv[P_cond_surv$CONDPROP_UNADJ >= 0.95, ]
### Filter out SITECLCD 7 (non productive stands - those with less than 20 ft3/ac/yr)
P_cond_surv <- P_cond_surv[!P_cond_surv$SITECLCD == 7,]
### Filter out non-stocked plots (with STDSZCD == 5)
P_cond_surv <- P_cond_surv[!P_cond_surv$STDSZCD == 5,]

### new filters - MAY 2022
### Filter out the the non-accessible pltos -- COND_STATUS_CD == 1 is accessible 
P_cond_surv <- P_cond_surv[P_cond_surv$COND_STATUS_CD == 1,]
### Filter by survey table --- annual inventories YES
P_cond_surv <- P_cond_surv[P_cond_surv$ANN_INVENTORY == "Y",]
### Filter by survey table --- B3_OZONE NO
P_cond_surv <- P_cond_surv[P_cond_surv$P3_OZONE_IND == "N",]

#### APPLYING FILTERS ####
#### ^^^^^^^^^^^^^^^^ ####----------------------------------------------------------------------------------------------------------

### joining Dataframes
P <-  dplyr::left_join(FIA_biomass, P_cond_surv, by = c("STATE", "PLT_CN", "PLOT"))

#### vvvvvvvvvvvvvvvv ####----------------------------------------------------------------------------------------------------------
#### CODING  ECOPROVS ####

############## CODE FOR ECOPROVINCES
##### RE_FACTOR ECOLOGICAL SUBCD to ECOSYSTEM PROVINCES
P$ECOPROVCD <-  NA

P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][1:27]] <- "211"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][28:85]] <- "212"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][86:127]] <- "221"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][128:173]] <- "222"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][174:223]] <- "223"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][224:282]] <- "231"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][283:337]] <- "232"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][338:351]] <- "234"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][352:363]] <- "242"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][364:401]] <- "251"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][402:425]] <- "255"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][426:435]] <- "261"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][436:437]] <- "262"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][438:443]] <- "263"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][444:477]] <- "313"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][478:503]] <- "315"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][504:517]] <- "321"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][518:538]] <- "322"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][539:596]] <- "331"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][597:618]] <- "332"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][619:674]] <- "341"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][675:724]] <- "342"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][725:729]] <- "411"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][730:750]] <- "M211"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][751:769]] <- "M221"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][770:771]] <- "M223"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][772:775]] <- "M231"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][776:801]] <- "M242"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][802:870]] <- "M261"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][871:889]] <- "M262"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][890:904]] <- "M313"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][905:998]] <- "M331"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][999:1079]] <- "M332"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][1080:1102]] <- "M333"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][1103:1104]] <- "M334"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][1105:1138]] <- "M341"
P$ECOPROVCD[P$ECOSUBCD %in% unique(P$ECOSUBCD)[order(unique(P$ECOSUBCD))][1139:1233]] <- "NA"

P$ECOPROVCD <- as.factor(P$ECOPROVCD)

#### CODING  ECOPROVS ####
#### ^^^^^^^^^^^^^^^^ ####----------------------------------------------------------------------------------------------------------

## IMPORTANT !! --- UNIT CONVERSION ---  ## P dataset
P$BIO_MgHa <- (P$BIO_ACRE/1.102311310924)*2.47105381467165

## STATE, pltID, and YEAR as factors
P$STATE <- as.factor(P$STATE)
P$pltID <- as.factor(P$pltID)
P$YEAR <- as.factor(P$YEAR)

### subset out ZEROES
P <- P[P$BIO_ACRE > 0,]

## drop levels in pltID
P$pltID <-  droplevels(P$pltID)

### save dataset
save(P, file = "C:/Users/hogan.jaaron/Dropbox/FIA_R/Starter_FIA_data_processing/P_dataset.Rdata")
