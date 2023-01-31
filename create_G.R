### CREATE G - FIA Stand biomass Growth dataset -- 
### G is the plot biomass growth dataset 
###  7.7.2022 
### JAH
### FIA CO2 growth enhancement project

library(rFIA); library(dplyr)

### GOAL: In this script, I create a biomass growth (G) dataset from the raw FIA inventory data (stored separately by state)
## Two methods are used to calculate plot-level biomass G from the tree tables for each plot. 
## The Mass Balance Method (MassBal) uses difference in plot level biomass between successive censuses plus the biomass of harvested and dead trees (see supplemental methods)
## The Summed Tree Incremental Growth (TreeInc) method uses the collective biomass increment of individual trees within an FIA plot between successive censuses plus the biomass of ingrowth trees (see supplemental methods)
## The script also calculates several additional details of plot level metrics between census intervals which help check the biomass G calculations

### START CODE ###

## file name housekeeping
data_path <- 'C:/Users/hogan.jaaron/Dropbox/FIA_R/data_FIA_nov2022/'

save_object_path <- 'C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/'

## state_vec: vector of state abbreviations to loop over
state_vec <- c("al", "az", "ar", "ca", "co", "ct", "de", "fl","ga", "id", "il", "in", 
               "ia", "ks", "ky", "la", "me", "md", "ma", "mi", "mn", "ms", "mo", "mt",
               "ne", "nv", "nh", "nj", "nm", "ny", "nc", "nd", "oh", "ok", "or", "pa", 
               "ri", "sc", "sd", "tn", "tx", "ut", "vt", "va", "wa", "wv", "wi")  ## exclude WY - Wyoming:  code does not work for wyo (for some reason)

## looping over the 48 continental US states
for (j in 1:length(state_vec)) {
 
  ## read in the data
  state <- readFIA(paste(data_path, state_vec[j], sep = ""))
 
  ## convert units -- lbs dry biomass to Mg (metric tons)
  state$TREE$DRYBIO_AG_Mg <- state$TREE$DRYBIO_AG * 0.00045359237
  ## convert units - conversion of per acre to per hectare
  state$TREE$TPHa_UNADJ <-  state$TREE$TPA_UNADJ * 2.4710538147   ##TPA base level TPA
  
  ##  create pltID - unique plot identifier string
  state$TREE$pltID <-  stringr::str_c(state$TREE$UNITCD, state$TREE$STATECD, state$TREE$COUNTYCD, state$TREE$PLOT, sep = '_')
  state$PLOT$pltID <-  stringr::str_c(state$PLOT$UNITCD, state$PLOT$STATECD, state$PLOT$COUNTYCD, state$PLOT$PLOT, sep = '_')
  
  ## for each state -- get the FIA plot and tree tables as R dataframes
  tree_df <- state$TREE
  plot_df <- state$PLOT
  
## STEP 2 - TREE BIOMASS G
  
  ## make placeholder datafame - each row with a unique record for each plot - t1 to t2
  ## filters out plots with before 1995(implementation of FIA 2.0), year = 9999 (non-inventories), and plots missing REMPER (i.e., no tree records for t1)
  calc_df <-  plot_df %>% filter(INVYR >1995 & INVYR !=9999 & !is.na(REMPER)) %>% select(pltID, CN, PREV_PLT_CN, MEASYEAR, MEASMON, INVYR, REMPER, LAT, LON, ECOSUBCD) %>% arrange(pltID, INVYR)
  
  ## remove rows where PREV_PLT_CN is NA - these are the very first censuses for each plot
  calc_df <-  calc_df[!is.na(calc_df$PREV_PLT_CN),]
  
  ## add state column
  calc_df$STATE <- state$SURVEY$STATEAB[1]
  
  ### create placeholer columns for variables
  calc_df$B_plt_t1_MgHa <-                 -9999
  calc_df$B_plt_t1_g5_MgHa <-              -9999
  
  calc_df$B_plt_t2_MgHa <-                 -9999
  calc_df$B_plt_t2_g5_MgHa <-              -9999
  
  calc_df$B_dead_MgHa <-                   -9999
  calc_df$B_cut_MgHa <-                    -9999
  calc_df$B_ingrow_MgHa <-                 -9999
  calc_df$B_surv_MgHa <-                   -9999
  
  calc_df$G_MassBal_MgHaYr <-              -9999
  calc_df$G_MassBal_g5_MgHaYr <-           -9999
  
  calc_df$G_obs_TreeInc_MgHaYr <-          -9999
  calc_df$B_L_prop <-                      -9999
  calc_df$G_pot_TreeInc_MgHaYr <-          -9999
  
  calc_df$G_obs_TreeInc_NoIngrow_MgHaYr <- -9999
  
  calc_df$nTree_Rec <-                     -9999
  calc_df$nTrees_t1 <-                     -9999
  calc_df$nTrees_t2 <-                     -9999
  calc_df$nTrees_both <-                   -9999
  
  calc_df$nIngrowTrees <-                  -9999
  calc_df$sumTPHa_Ingrow <-                -9999
  calc_df$Ingrowth <-                      -9999
  calc_df$nDeadTrees <-                    -9999
  calc_df$sumTPHa_Dead <-                  -9999
  calc_df$Mortality <-                     -9999
  calc_df$nCutTrees <-                     -9999
  calc_df$sumTPHa_Cut <-                   -9999
  calc_df$Harvest <-                       -9999
  calc_df$sumTPHa_Surv <-                  -9999
  
  calc_df$PREVDIA_NA <-                    -9999
  calc_df$TPHa_Match <-                    -9999
  calc_df$TPHa_Match_percent <-            -9999
  
  calc_df$MEASTIME_t2   <-                 -9999
  calc_df$MEASTIME_t1  <-                  -9999
  calc_df$MEASTIME_REMPER <-               -9999
  calc_df$diff_T <-                        -9999
  
  ### FOR LOOP on calc_df
  
  ### start for loop, which loops over each pltID in the placeholder calc_df - dataframe of plot censuses
  for(i in 1:nrow(calc_df)) {   
    
    ### GET THE DATA
    ## create t2 data frame - contains all tree records from the second census
    t2_df <- tree_df[tree_df$STATUSCD %in% c(1) & tree_df$PLT_CN %in% calc_df$CN[i], c("CN", "DIA", "PREVDIA", "TPHa_UNADJ", "PREV_TRE_CN","DRYBIO_AG_Mg", "RECONCILECD")]
    
    ## t2_df_b  - the mutates t2_df - rewriting data where the logical statements are fulfilled: i.e., for ingrowth trees
    t2_df_b <- t2_df %>% mutate(PREVDIA = ifelse((DIA<5 & is.na(t2_df$PREVDIA)) | (t2_df$DIA>=5 & is.na(t2_df$PREVDIA) & t2_df$RECONCILECD==2), 
                                                 0, PREVDIA),
                                PREV_TRE_CN = ifelse((DIA<5 & is.na(t2_df$PREVDIA)) | (t2_df$DIA>=5 & is.na(t2_df$PREVDIA) & t2_df$RECONCILECD==2), 
                                                     7777777, PREV_TRE_CN), 
                                RECONCILECD = ifelse((DIA<5 & is.na(t2_df$PREVDIA)) | (t2_df$DIA>=5 & is.na(t2_df$PREVDIA) & t2_df$RECONCILECD==2), 
                                                     99, RECONCILECD))
    
    ## create t2_dead and t2_cut data frames - contains all tree records recorded dead or cut from the second census
    t2_dead_df <- tree_df[tree_df$STATUSCD %in% c(2) & tree_df$PLT_CN %in% calc_df$CN[i], c("CN", "DIA", "PREVDIA", "TPHa_UNADJ", "PREV_TRE_CN","DRYBIO_AG_Mg")]
    t2_cut_df <- tree_df[tree_df$STATUSCD %in% c(3) & tree_df$PLT_CN %in% calc_df$CN[i], c("CN", "DIA",  "PREVDIA", "TPHa_UNADJ", "PREV_TRE_CN","DRYBIO_AG_Mg")]
    
    ## create t2_new dataframe, which just includes the data for ingrowth trees
    ## ingrowth trees are defined as the two following cases:
    ## CASE 1: DBH t2 is 1-5 inches, and DBH_t1 (PREVDIA) is missing
    ## CASE 2: DBH_t2 >=5 and DBH_t1  (PREVDIA) missing and the tree is recoreded as RECONCILECD=2
    t2_new_df <- tree_df[(tree_df$PLT_CN %in% calc_df$CN[i] & tree_df$DIA<5 & is.na(tree_df$PREVDIA)) | (tree_df$PLT_CN %in% calc_df$CN[i] & tree_df$DIA>=5 & is.na(tree_df$PREVDIA) & tree_df$RECONCILECD==2), c("CN", "DIA", "PREVDIA", "TPHa_UNADJ", "PREV_TRE_CN","DRYBIO_AG_Mg")]
    
    ## create t1 data frame - contains all live tree records at first census (trees that are dead or cut at t1 do not affect growth calculations)
    t1_df <- tree_df[tree_df$STATUSCD %in% c(1) & tree_df$PLT_CN %in% calc_df$PREV_PLT_CN[i],  c("CN", "DIA", "PREVDIA", "TPHa_UNADJ", "PREV_TRE_CN","DRYBIO_AG_Mg")]
  
    ## Merge the two
    tb_df <- dplyr::left_join(t2_df, t1_df, by = c("PREV_TRE_CN" = "CN"), suffix = c("_t2","_t1"))
    ## same for dead, cut & new
    tb_dead_df <- dplyr::left_join(t2_dead_df, t1_df, by = c("PREV_TRE_CN" = "CN"), suffix = c("_t2","_t1"))
    tb_cut_df <- dplyr::left_join(t2_cut_df, t1_df, by = c("PREV_TRE_CN" = "CN"), suffix = c("_t2","_t1"))
    
    ## replace TPHa_UNADJ_t1 and DBH t1 (PREVDIA) data for new saplings
    ## this mutates the tb_df dataframe- assigning 0 to PREVDIA, 0 to DRYBIO_AG_Mg_t1, assigning the sapling TPHa values, 7777777 to PREV_TRE_CN and 99 to RECONCILECD for ingrowth trees.
    ## ingrowth trees are defined as the following two cases of trees: 
    ## CASE 1: DBH t2 is 1-5 inches, and DBH_t1 (PREVDIA) is missing: assign sapling TPHa (185.24311 ) at t1 and DBH_t1/DRYBIO_AG_Mg_t1 = 0
    ## CASE 2: DBH_t2 >=5 and DBH_t1  (PREVDIA) missing and the tree is recoreded as RECONCILECD=2:  assign sapling TPHa (185.24311 ) and DBH_t1/DRYBIO_AG_Mg_t1 = 0
    tb_df <- tb_df %>% mutate(PREVDIA_t2 = ifelse((DIA_t2<5 & is.na(tb_df$PREVDIA_t2)) | (tb_df$DIA_t2>=5 & is.na(tb_df$PREVDIA_t2) & tb_df$RECONCILECD==2), 
                                               0, PREVDIA_t2),
                              DRYBIO_AG_Mg_t1 = ifelse((DIA_t2<5 & is.na(tb_df$PREVDIA_t2)) | (tb_df$DIA_t2>=5 & is.na(tb_df$PREVDIA_t2) & tb_df$RECONCILECD==2), 
                                                       0, DRYBIO_AG_Mg_t1),
                              TPHa_UNADJ_t1 = ifelse((DIA_t2<5 & is.na(tb_df$PREVDIA_t2)) | (tb_df$DIA_t2>=5 & is.na(tb_df$PREVDIA_t2) & tb_df$RECONCILECD==2), 
                                                     185.24311, TPHa_UNADJ_t1), 
                              RECONCILECD = ifelse((DIA_t2<5 & is.na(tb_df$PREVDIA_t2)) | (tb_df$DIA_t2>=5 & is.na(tb_df$PREVDIA_t2) & tb_df$RECONCILECD==2),
                                                   99, RECONCILECD), 
                              PREV_TRE_CN = ifelse((DIA_t2<5 & is.na(tb_df$PREVDIA_t2)) | (tb_df$DIA_t2>=5 & is.na(tb_df$PREVDIA_t2) & tb_df$RECONCILECD==2), 
                                                   7777777, PREV_TRE_CN))
        ## this dplyr code takes all trees that meet case 1 and 2, and gives them diameter of 0 and TPHa_t1 the sapling TPHa.  They are labelled RECONCILECD = 99, PREV_TRE_CN = 7777, for subsetting complete cases later on
    
    #### ADDITIONAL CALCULATIONS
    
    ## do the math for plot biomass at T1
    calc_df$B_plt_t1_MgHa[i] <- sum((t1_df$DRYBIO_AG_Mg * t1_df$TPHa_UNADJ), na.rm = T)
    calc_df$B_plt_t1_g5_MgHa[i] <- sum((t1_df[t1_df$DIA>5,]$DRYBIO_AG_Mg * t1_df[t1_df$DIA>5,]$TPHa_UNADJ), na.rm = T)
    
    ## do the math for plot biomass at T2
    calc_df$B_plt_t2_MgHa[i] <- sum((t2_df$DRYBIO_AG_Mg * t2_df$TPHa_UNADJ), na.rm = T)
    calc_df$B_plt_t2_g5_MgHa[i] <- sum((t2_df[t2_df$DIA>5,]$DRYBIO_AG_Mg * t2_df[t2_df$DIA>5,]$TPHa_UNADJ), na.rm = T)
    
    ## do the math for the biomass of dead trees T1 to T2
    calc_df$B_dead_MgHa[i] <- sum((tb_dead_df$DRYBIO_AG_Mg_t1 * tb_dead_df$TPHa_UNADJ_t1), na.rm = T)
    
    ## do the math for the biomass of cut trees T1 to T2
    calc_df$B_cut_MgHa[i] <- sum((tb_cut_df$DRYBIO_AG_Mg_t1 * tb_cut_df$TPHa_UNADJ_t1), na.rm = T)
    
    ## do the math for biomass of new (aka ingrowth trees) at T2
    calc_df$B_ingrow_MgHa[i] <- sum((t2_new_df$DRYBIO_AG_Mg * t2_new_df$TPHa_UNADJ), na.rm = T)
    
    ## do the math for biomass of surviving trees 
    calc_df$B_surv_MgHa[i] <- sum((t2_df_b[complete.cases(t2_df_b),]$DRYBIO_AG_Mg * t2_df_b[complete.cases(t2_df_b),]$TPHa_UNADJ), na.rm = T)
    
    ## do the math for plot G -- Mass Balance Method -- sum of (Bt2 - Bt1  * TPHa) over REMPER
    calc_df$G_MassBal_MgHaYr[i] <- ((calc_df$B_plt_t2_MgHa[i] - calc_df$B_plt_t1_MgHa[i]) + calc_df$B_dead_MgHa[i] + calc_df$B_cut_MgHa[i])/ calc_df$REMPER[i]
    
    calc_df$G_MassBal_g5_MgHaYr[i] <- ((calc_df$B_plt_t2_g5_MgHa[i] - calc_df$B_plt_t1_g5_MgHa[i]) + calc_df$B_dead_MgHa[i] + calc_df$B_cut_MgHa[i])/ calc_df$REMPER[i]
    
    ## do the math for plot G (observed) -- Summed Tree Incremental Growth Method -- sum of (Bt2 - Bt1  * TPHa) over REMPER
    calc_df$G_obs_TreeInc_MgHaYr[i] <- sum((tb_df$DRYBIO_AG_Mg_t2 - tb_df$DRYBIO_AG_Mg_t1) * tb_df$TPHa_UNADJ_t1, na.rm =T) / calc_df$REMPER[i]
    
    calc_df$G_obs_TreeInc_NoIngrow_MgHaYr[i] <- sum((tb_df[tb_df$DIA_t1>5,]$DRYBIO_AG_Mg_t2 - tb_df[tb_df$DIA_t1>5,]$DRYBIO_AG_Mg_t1) * tb_df[tb_df$DIA_t1>5,]$TPHa_UNADJ_t1, na.rm =T) / calc_df$REMPER[i]
    
    
    ## do the math for L - proportion of biomass loss due to tree harvest or mortality
    calc_df$B_L_prop[i] <- (calc_df$B_dead_MgHa[i] + calc_df$B_cut_MgHa[i]) / calc_df$B_plt_t1_MgHa[i]
    
    ## do the math for G_pot -- Biomass-loss corrected Summed Tree Incremental Growth Method -- potential growth of the stand adjusted for biomass losses
    calc_df$G_pot_TreeInc_MgHaYr[i] <- calc_df$G_obs_TreeInc_MgHaYr[i] / (1 - calc_df$B_L_prop[i])
    
    ## year decimal calculation for both t1, t2 and MEASTIME_REMPER (our calucation of FIA REMPER using MEASTIME t1 and t2)
    ## This assumes the mid-month measuring date of the month, year combination at FIA census time
    calc_df$MEASTIME_t2[i] <- calc_df$MEASYEAR[i] + ((calc_df$MEASMON[i] - 0.5) / 12)
    
    calc_df$MEASTIME_t1[i] <- ifelse(nrow(plot_df[plot_df$CN == calc_df$PREV_PLT_CN[i],])>0, 
                                     plot_df[plot_df$CN == calc_df$PREV_PLT_CN[i],]$MEASYEAR+((plot_df[plot_df$CN==calc_df$PREV_PLT_CN[i],]$MEASMON-0.5)/12), 
                                     NA)
    
    calc_df$MEASTIME_REMPER[i] <- ifelse(!is.na(calc_df$MEASTIME_t1[i]) &!is.na(calc_df$MEASTIME_t2[i]), 
                                         (calc_df$MEASTIME_t2[i] - calc_df$MEASTIME_t1[i]), 
                                         NA)
    
    ## compare difference in MEASTIME_REMPER and REMPER
    calc_df$diff_T <- calc_df$MEASTIME_REMPER[i] - calc_df$REMPER[i]
    
    #### FOR PLOT SCENARIOS   
    
    calc_df$nTree_Rec[i] <- length(tb_df$CN)
    calc_df$nTrees_t1[i] <- length(t1_df$CN)
    calc_df$nTrees_t2[i] <- length(t2_df$CN)
    calc_df$nTrees_both[i] <-  length(tb_df[!(is.na(tb_df$TPHa_UNADJ_t1) | tb_df$TPHa_UNADJ_t1 < 0.001) & !(is.na(tb_df$TPHa_UNADJ_t2) | tb_df$TPHa_UNADJ_t2 < 0.001),]$CN)
    
    ## InGrowth - number of ingrowth tree and T/F classifier
    calc_df$nIngrowTrees[i] <- length(t2_new_df$CN)
    calc_df$sumTPHa_Ingrow[i] <- sum(t2_new_df$TPHa_UNADJ, na.rm = T)
    calc_df$Ingrowth[i] <- length(t2_new_df$CN) > 0
    
    ## Mortality - number of cut trees and T/F classifier
    calc_df$nDeadTrees[i] <- length(t2_dead_df$CN)
    calc_df$sumTPHa_Dead[i] <- sum(tb_dead_df$TPHa_UNADJ_t1, na.rm = T)
    calc_df$Mortality[i] <- length(t2_dead_df$CN) > 0
    
    ## Harvest - number of cut trees and T/F classifier
    calc_df$nCutTrees[i] <- length(tb_cut_df$CN)
    calc_df$sumTPHa_Cut[i] <- sum(tb_cut_df$TPHa_UNADJ_t1, na.rm = T)
    calc_df$Harvest[i] <- length(tb_cut_df$CN) > 0
    
    calc_df$sumTPHa_Surv[i] <- sum(tb_df$TPHa_UNADJ_t2)
    
    ### count the NAs in PREVDIA column
    calc_df$PREVDIA_NA[i] <- sum(is.na(calc_df$PREVDIA))
    
    #### TPA changes for surviving non-ingrowth trees
    ## count the number of matching TPA values -- fuzzy match to within 2 decimal places
    calc_df$TPHa_Match[i] <- sum(abs(tb_df[complete.cases(tb_df[!colnames(tb_df) %in% c("RECONCILECD")]),]$TPHa_UNADJ_t2 - tb_df[complete.cases(tb_df[!colnames(tb_df) %in% c("RECONCILECD")]),]$TPHa_UNADJ_t1) < 0.01)
    
    ## percentage of matching TPA values (count / total) -- FOR NON INGROWTH TREES
    calc_df$TPHa_Match_percent[i] <- calc_df$TPHa_Match[i]/calc_df$nTrees_both[i]
  
  } ## end plot loop

  
  ## some cleaning up 
  #calc_df <- calc_df[complete.cases(calc_df),]
  
  calc_df$Ingrowth <- as.logical(calc_df$Ingrowth)
  calc_df$Harvest <- as.logical(calc_df$Harvest)
 
  ### add state prefix to Robject -- re-assign calc_df
  assign(paste(state_vec[j], "_calc", sep =""), calc_df)
  
  ## save Rdata object
  saver <-  get(paste(state_vec[j], "_calc", sep =""))
  save(saver, file = paste(save_object_path, state_vec[j], "_calc.Rdata", sep =""))

} ## end  state loop

## this commented code loas the 

### funciton to load R data to specified name
# loadRData <- function(fileName){
#   #loads an RData file, and returns it
#   load(fileName)
#   get(ls()[ls() != "fileName"])
# }
# 
# al_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/al_calc.Rdata")
# ar_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/ar_calc.Rdata")
# az_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/az_calc.Rdata")
# ca_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/ca_calc.Rdata")
# co_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/co_calc.Rdata")
# ct_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/ct_calc.Rdata")
# de_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/de_calc.Rdata")
# fl_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/fl_calc.Rdata")
# ga_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/ga_calc.Rdata")
# ia_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/ia_calc.Rdata")
# id_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/id_calc.Rdata")
# il_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/il_calc.Rdata")
# in_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/in_calc.Rdata")
# ks_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/ks_calc.Rdata")
# ky_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/ky_calc.Rdata")
# la_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/la_calc.Rdata")
# ma_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/ma_calc.Rdata")
# md_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/md_calc.Rdata")
# me_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/me_calc.Rdata")
# mi_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/mi_calc.Rdata")
# mn_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/mn_calc.Rdata")
# mo_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/mo_calc.Rdata")
# ms_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/ms_calc.Rdata")
# mt_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/mt_calc.Rdata")
# nc_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/nc_calc.Rdata")
# nd_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/nd_calc.Rdata")
# ne_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/ne_calc.Rdata")
# nh_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/nh_calc.Rdata")
# nj_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/nj_calc.Rdata")
# nm_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/nm_calc.Rdata")
# nv_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/nv_calc.Rdata")
# ny_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/ny_calc.Rdata")
# oh_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/oh_calc.Rdata")
# pa_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/pa_calc.Rdata")
# ri_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/ri_calc.Rdata")
# sc_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/sc_calc.Rdata")
# sd_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/sd_calc.Rdata")
# tn_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/tn_calc.Rdata")
# tx_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/tx_calc.Rdata")
# ut_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/ut_calc.Rdata")
# va_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/va_calc.Rdata")
# vt_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/vt_calc.Rdata")
# wa_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/wa_calc.Rdata")
# wi_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/wi_calc.Rdata")
# wv_calc <- loadRData("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022/wv_calc.Rdata")

### END CODE ###

## combine results into one big dataframe
FIA_G_calc <- rbind(al_calc, az_calc, ar_calc, ca_calc, co_calc, ct_calc, de_calc, fl_calc, ga_calc, id_calc, il_calc, in_calc, ia_calc, ks_calc, ky_calc, la_calc, me_calc, md_calc, ma_calc, mi_calc, mn_calc, ms_calc, mo_calc, mt_calc, ne_calc, nv_calc, nh_calc, nj_calc, nm_calc, ny_calc, nc_calc, nd_calc, oh_calc, ok_calc, or_calc, pa_calc, ri_calc, sc_calc, sd_calc, tn_calc, tx_calc, ut_calc, vt_calc, va_calc, wa_calc, wv_calc, wi_calc) 

## small change to the dataset -- rename column 2 (was "CN") to "PLT_CN" -
colnames(FIA_G_calc)[2] <- "PLT_CN"

## deal with zeros in B_dead and B_cut
FIA_G_calc[is.nan(G$B_L_prop),]

# 
# ## save result
# #save(FIA_G_calc, file = "FIA_G_calc.Rdata")
# 
# 


############# ADDITIONAL CODE 

### ### ### ### ### ### ### ### ### ### ### ### ###
# ## FILTER THE DATASTET -- Plot Selection Criteria
### ### ### ### ### ### ### ### ### ### ### ### ###
# 
# ################################################################################## apply filters to the FIA_G_calc data frame
#
# ### create p_Cond_surv --- the combined  plot condition and survey table dataframe for subsetting
#
# for FIA plot conditions
load("C:/Users/hogan.jaaron/Dropbox/FIA_R/Plot_Conditions_rFIA/FIA_conditions_allPlots.Rdata")  # this is a stacked COND table for all 48 states
FIA_conditions$STATE <- as.factor(FIA_conditions$STATE)
FIA_conditions$PROP_BASIS <- as.factor(FIA_conditions$PROP_BASIS)
FIA_conditions$MIXEDCONFCD <- as.factor(FIA_conditions$MIXEDCONFCD)
FIA_conditions$DWM_FUELBED_TYPCD  <-  as.factor(FIA_conditions$DWM_FUELBED_TYPCD)

# for FIA plots (plot table)
load("C:/Users/hogan.jaaron/Dropbox/FIA_R/Plot_Conditions_rFIA/FIA_plots_allPlots.Rdata") # this is a stacked PLOT table for all 48 states
FIA_plots$STATE <- as.factor(FIA_plots$STATE)
FIA_plots$ECOSUBCD <- as.factor(FIA_plots$ECOSUBCD)

##### COMBINE PLOT and CODITION TABLES
P_cond <- dplyr::left_join(FIA_conditions, FIA_plots, by = c("STATE", "PLOT", "INVYR", "PLT_CN" = "CN"))  #PLT_CN = CN  merges condition table to the plot table using PLT_CN (see FIA data user guide 8.0)

#### load survey tables
load("C:/Users/hogan.jaaron/Dropbox/FIA_R/Plot_Conditions_rFIA/FIA_survey.Rdata") # this is a staked SURVEY table for all 48 states
##### COMBINE P_cond and survey tables
P_cond_surv <- dplyr::left_join(P_cond, FIA_survey[,c("CN", "P3_OZONE_IND", "ANN_INVENTORY")], by = c("SRV_CN" = "CN"))

###### COMBINE G_calc
G <- dplyr::left_join(FIA_G_calc, P_cond_surv[,c("STATE", "CN", "PLT_CN", "INVYR", "STDAGE", "STDORGCD", "CONDPROP_UNADJ", "SITECLCD", "STDSZCD", "COND_STATUS_CD", "P3_OZONE_IND", "ANN_INVENTORY")], by = c("STATE", "PLT_CN", "INVYR")) %>% distinct()  # 370598 observations

#rm(P_cond, FIA_G_calc, FIA_conditions, FIA_plots, FIA_survey, P_cond_surv)  #removes other data frames

### # vvvvvvvvvvvvvvvv ## # #  --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# # ## APPLYING FILTERS ## # #

## remove cases of NA's STDAGE columns
G <- G[!is.na(G$STDAGE) & !G$STDAGE == 9999,]
## Filter out plantations
G <- G[G$STDORGCD == 0, ]
## Filter plots with a single condition using a 95% threshold for CONDPROP_UNADJ
G <- G[G$CONDPROP_UNADJ >= 0.95, ]
### Filter out SITECLCD 7 (non productive stands - those with less than 20 ft3/ac/yr)
G <- G[!G$SITECLCD == 7,]
### Filter out non-stocked plots (with STDSZCD == 5)
G <- G[!G$STDSZCD == 5,]

### new filters - MAY 2022
### Filter out the the non-accessible plots -- COND_STATUS_CD == 1 is accessible
G <- G[G$COND_STATUS_CD == 1,]
### Filter by survey table --- annual inventories YES
G <- G[G$ANN_INVENTORY == "Y",]
### Filter by survey table --- B3_OZONE NO
G <- G[G$P3_OZONE_IND == "N",]

### NOTE: 111752 after filtering

# # ## APPLYING FILTERS ## # #
#### ^^^^^^^^^^^^^^^^ #### --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

## dealing with ECOPROVINCES:  this code takes the eco-subprovince codes and drops the necessary letters/ numbers to get the ecoprovinces
G$ECOPROVCD <- stringr::str_replace_all(gsub('.{2}$', '', G$ECOSUBCD), stringr::fixed(" "), "")

G[G$ECOPROVCD == "M322A"]$ECOPROVCD

G$ECOPROVCD <-  as.factor(G$ECOPROVCD)

# calculate & add MEASTIME_avg
G$MEASTIME_avg <- (G$MEASTIME_t1 + G$MEASTIME_t2) /2

############################# For STDAGE T1

### subset the condition table to include only the dominant condition for
FIA_single_conditions <- FIA_conditions %>% group_by(STATE, PLT_CN, INVYR) %>% filter(row_number() == which.max(CONDPROP_UNADJ))  %>% select(STATE, PLT_CN, INVYR, CONDPROP_UNADJ, STDAGE) %>% unique()

df_STDAGE_t1 <- as.data.frame(FIA_single_conditions[FIA_single_conditions$PLT_CN %in% G$PREV_PLT_CN ,c("STATE", "PLT_CN",  "INVYR", "STDAGE")])

colnames(df_STDAGE_t1)[2] <- "PREV_PLT_CN"
colnames(df_STDAGE_t1)[4] <- "STDAGE_t1"

## left_join  to add to the G dataframe
G <- left_join(G, df_STDAGE_t1[,c("STATE", "PREV_PLT_CN", "STDAGE_t1")], by = c("STATE", "PREV_PLT_CN"))

## for is.na STDAGE_t1 assign STDAGE_t2 value    ## done for 405 records
G[is.na(G$STDAGE_t1),]$STDAGE_t1 <- G[is.na(G$STDAGE_t1),]$STDAGE_t2

## difference in STDAGE
G$diff_STDAGE <- G$STDAGE_t2 - G$STDAGE_t1

### save the output -- the clean subsetted dataset
setwd("C:/Users/hogan.jaaron/Dropbox/FIA_R/BiomassGrowth/Biomass_Growth_calculations_NewData_november2022")
save(G, file = "G_clean&subsetted.Rdata")

