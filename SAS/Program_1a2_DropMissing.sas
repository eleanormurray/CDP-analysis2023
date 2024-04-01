
/****************************************************/
/* Program 1a.2: Debertin et al 2024 			    */
/* This program takes as input a list of covariates */
/* and drops observations with missingness		    */
/* this ensures all analyses use the same input data*/
/***************************************************/


%let covs_new = adhbin0 age_bin mi_bin irk  occupation 
			NIHA_FV0 rbw_bin nonwhite
			cig_FV0 employ_FV0 fulltime_FV0 
			hypertens_FV0 htmed_FV0
			hyperlipid_FV0 chf_FV0 diab_FV0 
			afib_FV0 inact_FV0 
			oralhyp_FV0 adhpre0bin
			dig_FV0 ap_FV0 aci_FV0 cardioM_FV0
			icia_FV0 ic_FV0 diur_FV0 
			antihyp_FV0  antiArr_FV0 HiFastGluc_FV0 ;

%let covs_orig = adhbin0 age_bin   nonwhite   IRK   MI_bin  RBW_bin  
			NIHA_FV0  HiSysBP_FV0   HiDiasBP_FV0   HiWhiteCell_FV0   HiNeut_FV0    HiHemat_FV0 	 
			HiBili_FV0   HiSerChol_FV0   HiSerTrigly_FV0    HiSerUric_FV0   HiSerAlk_FV0    HiPlasUrea_FV0   
			HiFastGluc_FV0    HiOneGluc_FV0   HiHeart_FV0   CHF_FV0    ACI_FV0    AP_FV0  
			IC_FV0  ICIA_FV0   DIG_FV0    DIUR_FV0    AntiArr_FV0    AntiHyp_FV0    OralHyp_FV0   
			CardioM_FV0   AnyQQS_FV0   AnySTDep_FV0   AnyTWave_FV0 
			STElev_FV0    FVEB_FV0   VCD_FV0   CIG_FV0   INACT_FV0 ;

%let covs_subset = adhbin0 age_bin   nonwhite   IRK   MI_bin  RBW_bin  
			NIHA_FV0  
			HiFastGluc_FV0   CHF_FV0    ACI_FV0    AP_FV0  
			IC_FV0  ICIA_FV0   DIG_FV0    DIUR_FV0    AntiArr_FV0    AntiHyp_FV0    OralHyp_FV0   
			CardioM_FV0    CIG_FV0   INACT_FV0 ;

/*all covariates in any analysis*/
%let covs_new2 = adhbin0 age_bin mi_bin irk  occupation 
			NIHA_FV0 rbw_bin nonwhite
			cig_FV0 employ_FV0 fulltime_FV0 
			hypertens_FV0 htmed_FV0
			hyperlipid_FV0 chf_FV0 diab_FV0 
			afib_FV0 inact_FV0 
			oralhyp_FV0 adhpre0bin
			dig_FV0 ap_FV0 aci_FV0 cardioM_FV0
			icia_FV0 ic_FV0 diur_FV0 
			antihyp_FV0  antiArr_FV0 HiFastGluc_FV0 
			HiSysBP_FV0   HiDiasBP_FV0   HiWhiteCell_FV0   HiNeut_FV0    HiHemat_FV0 	 
			HiBili_FV0   HiSerChol_FV0   HiSerTrigly_FV0    HiSerUric_FV0   HiSerAlk_FV0    HiPlasUrea_FV0   
			  HiOneGluc_FV0   HiHeart_FV0   
		   AnyQQS_FV0   AnySTDep_FV0   AnyTWave_FV0 
			STElev_FV0    FVEB_FV0   VCD_FV0   CIG_FV0   ;

%macro drop_missing(covs, data_in = , data_out = );
proc freq data = &data_in nlevels;
tables ID /noprint;
title 'Before exclusion of missing baseline vars';
run;

data missing; 
	set &data_in;
	if nmiss(of %sysfunc(tranwrd(%sysfunc(compbl(&covs)),%str( ), %str(,))) ) then output;
run;

data &data_out;
	set &data_in;
	if nmiss(of %sysfunc(tranwrd(%sysfunc(compbl(&covs)),%str( ), %str(,))) ) then delete;
run;

proc freq data = &data_out nlevels;
tables ID /noprint;
title 'After exclusion of missing baseline vars';
run;

proc freq data = missing nlevels;
tables ID /noprint;
title 'Deleted observations';
run;
%mend drop_missing;


%drop_missing(&covs_new, data_in = cdp.ExpertDAG, data_out = cdp.ExpertDAG_wide);


%drop_missing(&covs_orig, data_in = cdp.ExpertDAG, data_out = cdp.ExpertDAG_wide_orig);

%drop_missing(&covs_subset, data_in = cdp.ExpertDAG, data_out = cdp.ExpertDAG_wide_subset);

%drop_missing(&covs_new2, data_in = cdp.ExpertDAG, data_out = cdp.ExpertDAG_wide2);

