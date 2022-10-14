### CREATE P - FIA plot biomass dataset -- 
### 7.7.2022 
### P is the plot biomass dataset
### JAH
### FIA CO2 growth enhancement project

library(rFIA); library(dplyr)

## GOAL: In this script, I sum the biomass of all living trees for each plot census in the raw FIA inventory data (stored separately by state)

##################################################################################################
###############################              START CODE              #############################
##################################################################################################

## file name housekeeping
data_path <- 'C:/Users/hogan.jaaron/Dropbox/FIA_R/data_FIA/'

save_object_path <- 'C:/Users/hogan.jaaron/Dropbox/FIA_R/Biomass_calculation/P_calc/'

## state_vec: vector of state abbreviations to loop over
state_vec <- c("al", "az", "ar", "ca", "co", "ct", "de", "fl","ga", "id", "il", "in", 
               "ia", "ks", "ky", "la", "me", "md", "ma", "mi", "mn", "ms", "mo", "mt", 
               "ne", "nv", "nh", "nj", "nm", "ny", "nc", "nd", "oh", "ok", "or", "pa", 
               "ri", "sc", "sd", "tn", "tx", "ut", "vt", "va", "wa", "wv", "wi", "wy")

## looping over the 48 continental US states
for (j in 1:length(state_vec)) {
  
  ## read in the data
  state <- readFIA(paste(data_path, state_vec[j], sep = ""))
  
  ## convert units -- lbs dry biomass to Mg (metric tons)
  state$TREE$DRYBIO_AG_Mg <- state$TREE$DRYBIO_AG * 0.00045359237
  ## convert units - conversion of per acre to per hectare
  state$TREE$TPHa_UNADJ <-  state$TREE$TPA_UNADJ * 2.4710538147   ##TPA base level TPA
  
  ##  create pltID - unique plot identifier string
  state$TREE$pltID <-  stringr::str_c(state$TREE$UNITCD, state$TREE$STATECD, 
                                      state$TREE$COUNTYCD, state$TREE$PLOT, sep = '_')
  
  state$PLOT$pltID <-  stringr::str_c(state$PLOT$UNITCD, state$PLOT$STATECD, 
                                      state$PLOT$COUNTYCD, state$PLOT$PLOT, sep = '_')

  ## for each state -- get the FIA tables of interest as R dataframes
  tree_df <- state$TREE
  plot_df <- state$PLOT
  cond_df <- state$COND
  survey_df <- state$SURVEY
  
  ### create comp df
  comp_df <- plot_df %>% 
             filter(INVYR >1995 & INVYR !=9999) %>%  ####################& !is.na(REMPER) all of wyo REMPER is NA
             select(pltID, CN, SRV_CN, MEASYEAR, MEASMON, INVYR, REMPER, LAT, LON, ECOSUBCD) %>% 
             arrange(pltID, INVYR)
  
  # add state column
  comp_df$STATE <- state$SURVEY$STATEAB[1]
  
  ### create placeholer columns for variables
  comp_df$BIO_MgHa <-         -9999
  comp_df$CARB_MgHa <-        -9999
  
  #################### FOR LOOP on comp_df
  
  ##### start for loop, which loops over each pltID in the placeholder calc_df - dataframe of plot censuses
  for(i in 1:nrow(comp_df)) {
    
    #### GET THE DATA
    ## create t_data frame - contains all tree records from the plot record in question
    t_df <- tree_df[tree_df$STATUSCD %in% c(1) & tree_df$PLT_CN %in% comp_df$CN[i], c("CN", "DIA", "PREVDIA", "TPHa_UNADJ", "PREV_TRE_CN","DRYBIO_AG_Mg", "RECONCILECD")]
    
    ## do the math for plot biomass
    comp_df$BIO_MgHa[i] <- ifelse(length(t_df$CN>0),  
                                  sum((t_df$DRYBIO_AG_Mg * t_df$TPHa_UNADJ), na.rm = T),
                                  0)
    
    comp_df$CARB_MgHa[i] <- ifelse(length(t_df$CN>0),  
                                   comp_df$BIO_MgHa[i] * 0.5, 
                                   0)
    
    
    comp_df$MEASTIME[i] <- ifelse(length(t_df$CN>0),
                                  comp_df$MEASYEAR[i] + ((comp_df$MEASMON[i] - 0.5) / 12),  # own calcualtion of measurment year
                                  NA)
    
  }   ### end for loop for plots 
    
  ### subset the condition table to the variable of interest
  cond_df <- cond_df[,c("PLT_CN", "PLOT", "INVYR", "STDAGE", "STDORGCD", "COND_STATUS_CD", 
                        "CONDPROP_UNADJ", "STDSZCD", "SITECLCD", "PHYSCLCD", "GSSTKCD")]
  
  ### subset the survey table to the variables of interst                   
  survey_df <- survey_df[,c("CN", "INVYR", "P3_OZONE_IND", "ANN_INVENTORY")]
  
  ##################################### COMBINING THINGS
  #### combine comp_df and condition table
  P_comp <- dplyr::left_join(comp_df, cond_df, by = c("INVYR", "CN" = "PLT_CN"))
  
  ## add in the survey_df 
  P_comp <- dplyr::left_join(P_comp, survey_df, by = c("INVYR", "SRV_CN" = "CN"))
  
  ### add state prefix to Robject -- re-assign calc_df
  assign(paste(state_vec[j], "_P_comp", sep =""), P_comp)
  
  ## save Rdata object
  saver <-  get(paste(state_vec[j], "_P_comp", sep =""))
  save(saver, file = paste(save_object_path, state_vec[j], "_P_comp.Rdata", sep =""))

}
 
P <- tibble::tibble(rbind(al_P_comp, az_P_comp, ar_P_comp, ca_P_comp, co_P_comp, ct_P_comp, de_P_comp, fl_P_comp, 
                          ga_P_comp, id_P_comp, il_P_comp, in_P_comp, ia_P_comp, ks_P_comp, ky_P_comp, la_P_comp,
                          me_P_comp, md_P_comp, ma_P_comp, mi_P_comp, mn_P_comp, ms_P_comp, mo_P_comp, mt_P_comp,
                          ne_P_comp, nv_P_comp, nh_P_comp, nj_P_comp, nm_P_comp, ny_P_comp, nc_P_comp, nd_P_comp, 
                          oh_P_comp, ok_P_comp, or_P_comp, pa_P_comp, ri_P_comp, sc_P_comp, sd_P_comp, tn_P_comp,
                          tx_P_comp, ut_P_comp, vt_P_comp, va_P_comp, wa_P_comp, wv_P_comp, wi_P_comp, wy_P_comp))

### remove these pesky rows where all is NA
P <- janitor::remove_empty(P, which = "rows")

save(P, file = "C:/Users/hogan.jaaron/Dropbox/FIA_R/Biomass_calculation/P_calc/FIA_P_comp.Rdata")


####################################################################################################################################
#### vvvvvvvvvvvvvvvv ####----------------------------------------------------------------------------------------------------------
#### APPLYING FILTERS ####

## remove cases of NA's STDAGE columns
P <- P[!is.na(P$STDAGE) & !P$STDAGE == 9999,]
## Filter out plantations
P <- P[P$STDORGCD == 0, ]
## Filter plots with a single condition using a 95% threshold for CONDPROP_UNADJ
P <- P[P$CONDPROP_UNADJ >= 0.95, ]
### Filter out SITECLCD 7 (non productive stands - those with less than 20 ft3/ac/yr)
P <- P[!P$SITECLCD == 7,]
### Filter out non-stocked plots (with STDSZCD == 5)
P <- P[!P$STDSZCD == 5,]

### new filters - MAY 2022
### Filter out the the non-accessible pltos -- COND_STATUS_CD == 1 is accessible 
P <- P[P$COND_STATUS_CD == 1,]
### Filter by survey table --- annual inventories YES
P <- P[P$ANN_INVENTORY == "Y",]
### Filter by survey table --- B3_OZONE NO
P <- P[P$P3_OZONE_IND == "N",]

#### APPLYING FILTERS ####
#### ^^^^^^^^^^^^^^^^ ####----------------------------------------------------------------------------------------------------------
####################################################################################################################################
####################################################################################################################################
#### vvvvvvvvvvvvvvvv ####----------------------------------------------------------------------------------------------------------
#### CODING  ECOPROVS ####

############## CODE FOR ECOPROVINCES
P$ECOPROVCD <- stringr::str_replace_all(gsub('.{2}$', '', P$ECOSUBCD), stringr::fixed(" "), "")

## deal with 2 pesky ECOPROVCDS
P[!is.na(P$ECOPROVCD) & P$ECOPROVCD == "M332A",]$ECOPROVCD <- "M332"
P[!is.na(P$ECOPROVCD) & P$ECOPROVCD == "M332E",]$ECOPROVCD <- "M332"

P$ECOPROVCD <- as.factor(P$ECOPROVCD)

#### CODING  ECOPROVS ####
#### ^^^^^^^^^^^^^^^^ ####----------------------------------------------------------------------------------------------------------
####################################################################################################################################

## STATE, pltID, and YEAR as factors
P$STATE <- as.factor(P$STATE)
P$pltID <- as.factor(P$pltID)

### subset out ZEROES
P <- P[P$BIO_MgHa > 0,]

## drop levels in pltID
P$pltID <-  droplevels(P$pltID)

### remove these pesky rows where all is NA
P <- janitor::remove_empty(P, which = "rows")

### save dataset
save(P, file = "C:/Users/hogan.jaaron/Dropbox/FIA_R/Starter_FIA_data_processing/P_dataset.Rdata")
      
