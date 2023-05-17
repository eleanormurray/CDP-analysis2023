

/*****************************************************/
/**Program 3: New Analyses: Baseline Covariates Only**/
/*****************************************************/
/*Note: adherence carried forward 2 missed visits****/
/*%difference and 95%CI based on 500 bootstraps******/
/*Crude and Standardized estimates*******************/
/****************************************************/

/*libname cdp "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS data";
*/

%macro partB_unadjusted(outdest = , inset = , titlemain = , nboot=, lib=);
proc printto print = &outdest;
run;
%let rawdata = &lib..&inset;

/******a. Unadjusted*********************/
title &titlemain;

/*Tabulate Unadjusted Probabilities*/

proc freq data = &rawdata;

	tables adhx15bin*dth5 / nopercent nocol cl binomial riskdiff;
run;


%mend partB_unadjusted;


%macro partB_adjusted(outdest = , inset = , titlemain = , nboot=, lib=, adhvar = , covs = );


/******b. Adjusted*********************/

%let rawdata = &lib..&inset;

title &titlemain;

proc format ;
   value adher -1= "Observed"
                0= "Adherence >=80%"
 		1= "Adherence <80%"
				; 
run;
data onesample;
set &rawdata;
  where &adhvar ne .;
run;

data onesample ;			
  set onesample end = _end_  ;  
label adher= "Adherence"; 
  where &adhvar ne .;

 retain _id ;
  if _n_ = 1 then _id = 0;
  _id = _id + 1 ;
  if _end_ then do ;
     call symput("nids",trim(left(_id)));
  end;
  adher = -1 ;    
  	output ; 
  adher = 0 ;     
  	&adhvar = 0 ;
  	dth5 = . ;
  	output ;  
  adher = 1 ;    
  	&adhvar = 1 ;
  	dth5 = . ;
  	output ;    
run;
data ids ;
   do bsample = 1 to &nboot;
       do _id = 1 to &nids ;
           output ;
       end;
   end;
run;
proc surveyselect data= ids 
         method = urs
         n= &nids
         seed = 1232  
         out = _idsamples (keep = bsample _id  numberhits  ) 
         outall  noprint  ;       
      strata bsample ;
      run;    

%do bsample = 0 %to &nboot;

	%if %eval(&bsample) = 0 %then %do;

proc printto print = &outdest;
run;

		/*logistic model for death given adherence*/
		proc logistic data = onesample descending;
			model dth5 = &adhvar 
			&covs ;
			output out = predicted_mean0 (keep=adher probY) p = probY ;
		run;
		data predicted_mean;
			set predicted_mean0 ;
			bsample = 0 ;
			numberhits = 1 ;
		run;
		
		proc datasets library = work nolist;
			delete predicted_mean0;
		run;

proc printto ;
run;
	%end;

	%else %do;
		data bootsample;
			merge onesample _idsamples (where = (bsample = &bsample));
			by _id;
		run;	

		ods listing select none ;
		proc logistic data=bootsample descending;
			model dth5 = &adhvar 
			&covs;
			output out = predicted_mean1 (keep=bsample numberhits adher probY) p = probY ;
			freq numberhits ;
			by bsample ;
		run;
		ods listing ;

		data predicted_mean ;
			set predicted_mean predicted_mean1;
			by bsample ;
		run;
	
		proc datasets library = work nolist;
			delete predicted_mean1 bootsample;
		run;
	%end;
%end;

proc printto print = &outdest;
run;

proc sort data = predicted_mean ;
	by bsample adher;
run;

/*Risk Difference and Confidence Intervals*/
proc means data=predicted_mean mean noprint;
	var probY ;
	by bsample adher;
	freq numberhits;
	output out = results (keep = bsample adher mean) mean=mean;
run;

proc transpose data=results out = for_diff prefix = Risk_;
	var mean;
	id adher;
	by bsample;
run;
data for_diff;
	set for_diff;
	mean = Risk_1 - Risk_0;
	adher = 2;
	keep bsample adher mean;
run;
proc means data = for_diff (where = (bsample >0)) noprint;
	var mean;
	by adher;
	output out = diffstd (keep = adher std) std = std;
run;
data sample0;
	set for_diff (where = (bsample = 0));
	keep mean;
run;
data final_2014Bbin;
	merge sample0 diffstd;
	lb = mean - 1.96 * std ;
	ub = mean + 1.96 * std ;
	label lb="95% Lower bound"
    	      ub="95% Upper bound"
             std="Standard Error"
      ;
	n = &nids;
run;

/*Print Results*/
proc printto print = &outdest;
run;
proc print data= final_2014Bbin label noobs ;
title2 "95% Confidence Intervals using &nboot samples" ;
title3 "Logistic Regression, Placebo Arm";
title4 "<80% Adherence vs >=80% Adherence";
	var mean std lb ub n;
run;
proc datasets library=work nolist;
	delete Ids Onesample 
 	exp_plc plc plc0 plc1 
	predicted_mean results 
	diffstd for_diff sample0 _idsamples
	; 
quit;

proc printto;
run;

%let timenow2=%sysfunc(time(), time.);
%let datenow2=%sysfunc(date(), date9.);
%put Part B is Complete;
%put End time is &datenow2 / &timenow2 ;
%put ; 	

%mend partB_adjusted;

/*****RUN MACROS***

%let nboot = 5;

%let covs_orig = adhbin0 age_bin   nonwhite   IRK   MI_bin  RBW_bin  
			NIHA_FV0  HiSysBP_FV0   HiDiasBP_FV0   HiWhiteCell_FV0   HiNeut_FV0    HiHemat_FV0 	 
			HiBili_FV0   HiSerChol_FV0   HiSerTrigly_FV0    HiSerUric_FV0   HiSerAlk_FV0    HiPlasUrea_FV0   
			HiFastGluc_FV0    HiOneGluc_FV0   HiHeart_FV0   CHF_FV0    ACI_FV0    AP_FV0  
			IC_FV0  ICIA_FV0   DIG_FV0    DIUR_FV0    AntiArr_FV0    AntiHyp_FV0    OralHyp_FV0   
			CardioM_FV0   AnyQQS_FV0   AnySTDep_FV0   AnyTWave_FV0 
			STElev_FV0    FVEB_FV0   VCD_FV0   CIG_FV0   INACT_FV0 ;


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

			
			
%let covs_subset = adhbin0 age_bin   nonwhite   IRK   MI_bin  RBW_bin  
			NIHA_FV0  
			HiFastGluc_FV0   CHF_FV0    ACI_FV0    AP_FV0  
			IC_FV0  ICIA_FV0   DIG_FV0    DIUR_FV0    AntiArr_FV0    AntiHyp_FV0    OralHyp_FV0   
			CardioM_FV0    CIG_FV0   INACT_FV0 ;

/*Unadjusted; old dataset; new adherence definition*
%partB_unadjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartB.Unadj.old_cov_data.rtf", 
		inset = ExpertDAG_wide_orig, titlemain = "Unadjusted, Missed Adherence Carried Forward", 
		nboot = &nboot, lib = cdp);

/*Unadjusted; new dataset; new adherence definition*
%partB_unadjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartB.Unadj.new_cov_data.rtf", 
		inset = ExpertDAG_wide, titlemain = "Unadjusted, Missed Adherence Carried Forward", 
		nboot = &nboot, lib = cdp);

/*Unadjusted; subset covs; new adherence definition*
%partB_unadjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartB.Unadj.subset_cov_data.rtf", 
		inset = ExpertDAG_wide_subset, titlemain = "Unadjusted, Missed Adherence Carried Forward", 
		nboot = &nboot, lib = cdp);

/*updated adherence definition: old covariates /old data*
%partB_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartB.Adj.logistic.new_covs.rtf", 
	inset =  ExpertDAG_wide_orig, 
	titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=cdp, adhvar = adhx15bin, covs = &covs_orig);

/*updated adherence definition: new covariates and AFTER deleting obs with missing values of the new vars*/
%partB_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartB.Adj.logistic.new_covs.rtf", 
	inset =  ExpertDAG_wide, 
	titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=cdp, adhvar = adhx15bin, covs = &covs_new);

/*updated adherence definition: subset covariates *
%partB_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartB.Adj.logistic.subset_covs.rtf", 
	inset =  ExpertDAG_wide_subset, 
	titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=cdp, adhvar = adhx15bin, covs = &covs_subset);


/*Accuracy checks:
/*Unadjusted run on new dataset before deleting obs with missing values of new covariates
%partA_unadjusted(outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartA.Unadj.orig_cov_data.rtf", inset = ExpertDAG, titlemain = "Unadjusted, New data, Missed Adherence = 0", 
		nboot = &nboot, lib = cdp);

/*Original covariates run on new dataset before deleting obs with missing values of new covariates 

	%partA_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartA.Adj.linear.orig_covs.orig_cov_data.rtf",
	inset =  ExpertDAG, 
	titlemain = 'Adjusted, 1980 Replication, Missed Adherence = 0',  nboot = &nboot, lib=cdp, adhvar = old_adhx15bin, covs = &covs_orig);


/*New covariates run on new dataset before deleting obs with missing values of new covariates 
	%partA_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartA.Adj.linear.new_covs.orig_cov_data.rtf",
	inset =  ExpertDAG, 
	titlemain = 'Adjusted, 1980 Replication, Missed Adherence = 0',  nboot = &nboot, lib=cdp, adhvar = old_adhx15bin, covs = &covs);

/*Original covariates run on new dataset AFTER deleting obs with missing values of new covariates 
		%partA_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartA.Adj.linear.orig_covs.new_cov_data.rtf", 
	inset =  ExpertDAG_wide, 
	titlemain = 'Adjusted, 1980 Replication, Missed Adherence = 0',  nboot = &nboot, lib=cdp, adhvar = old_adhx15bin, covs = &covs_orig);


/*updated adherence definition: original covariates and AFTER deleting obs with missing values of the new vars*
%partA_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartA.Adj_updatedAdh.linear.orig_covs.new_cov_data.rtf", 
	inset = ExpertDAG_wide, 
	titlemain = 'Adjusted, 1980 Replication, Missed Adherence = 0',  nboot = &nboot, lib=cdp, adhvar = adhx15bin, covs = &covs_orig);


/******
%partB_unadjusted( outdest = "PartB.Unadj.final.rtf", inset = binary, 
	titlemain = 'Unadjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=cdp);
%partB_adjusted( outdest = "PartB.Adj.logistic.final.rtf", inset = binary, 
	titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=cdp,adhvar = adhx15bin);
/*Run logistic regression with original 1980 adherence definition
%partB_adjusted( outdest = "PartB.Adj_oldadhvar.logistic.final.rtf", inset = binary, 
	titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=cdp,adhvar = old_adhx15bin);
