

/****************************************************/
/**Program 2: Replicate Analysis of 1980 NEJM paper**/
/****************************************************/
/*Note: adherence = 0 for missed visits*************/
/*%difference and 95%CI based on 500 bootstraps*****/
/***************************************************/

libname cdp "<path>\SAS data";

/*A. Unadjusted 1980 analysis*/
%macro partA_unadjusted(outdest = , inset=, titlemain =, nboot = , lib =);

proc printto print = &outdest;
run;

%let rawdata = &lib..&inset;

/******A.1. Unadjusted*********************/
/*Original coding for missing adherence (missed visits: adherence = 0)*/

title &titlemain;

/*Tabulate Unadjusted Probabilities*/

proc freq data = &rawdata;
	tables old_adhx15bin*dth5 / nopercent nocol cl binomial riskdiff;
run;


%mend partA_unadjusted;


/*B. Adjusted via linear regression, baseline covariates only*/
%macro partA_adjusted(nboot = , outdest = , inset=, titlemain =, lib=, adhvar =  , covs =);

proc printto print = &outdest;
run;

%let rawdata = &lib..&inset;


/******b. Adjusted: linear regression*****/
title &titlemain;
data onesample;
set &rawdata;
  where &adhvar ne .;
run;

data onesample ;			
  set onesample end = _end_  ;
   retain _id ;
  if _n_ = 1 then _id = 0;
  _id = _id + 1 ;
  if _end_ then do ;
     call symput("nids",trim(left(_id)));
  end;
  label adher= "Adherence"; 
  adher = -1 ;    /* 1st copy: equal to original one */
  	output ; 
  adher = 0 ;     /* 2nd copy: adherence set to 0, outcome to missing */
  	&adhvar = 0 ;
  	dth5 = . ;
  	output ;  
  adher = 1 ;     /* 3rd copy: adherence set to 1, outcome to missing*/
  	&adhvar = 1 ;
  	dth5 = . ;
  	output ;
run;


data ids ;
	do bsample = 1 to &nboot  ;
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

%do bsample =  0 %to &nboot ;   

	%if %eval(&bsample) = 0 %then %do;
		proc reg data = onesample plots=none outest = est0;
			model dth5 = &adhvar 
			&covs ;
  			output out = predicted_mean0 (keep = id &adhvar adher meanY) p = meanY ;
		run;
		quit;

		data params;
			set est0 ;
			bsample = 0 ;
			keep &adhvar bsample;
		run;

		data predicted_mean;
			set predicted_mean0 ;
			bsample = 0 ;
			numberhits = 1 ;
		run;


		proc datasets library = work nolist;
			delete est0 predicted_mean0;
		run;
	%end;

	%else %do;

		data bootsample;
			merge onesample _idsamples (where= (bsample = &bsample ));  
			by _id;
		run;
		
		ods listing select none ;
		proc reg data=bootsample plots = none outest = est1;
		      model dth5 = &adhvar 
				&covs  ;
		     freq numberhits;
		     output out = predicted_mean1 (keep = bsample id &adhvar adher meanY numberhits) p = meanY; 
		run;		
		quit;
		ods listing ;
	
		data est1;
			set est1;
			bsample = %eval(&bsample);
			keep &adhvar bsample;
		run;
	
		data params ;
			set params est1;
			by bsample ;
		run;


		data predicted_mean;
			set predicted_mean predicted_mean1;
			by bsample ;
		run;
	
		proc datasets library = work nolist;
			delete est1 predicted_mean1 bootsample;
		run;
	%end;

%end;


proc sort data = params;
	by bsample &adhvar;
run;

proc sort data = predicted_mean ;
	by bsample adher;
run;


/*Risk Difference and Confidence Intervals*/
data temp;
	set params (where=(bsample = 0));
	call symput("rd",&adhvar);
run;
proc univariate data=params (where = (bsample > 0)) noprint;
	var &adhvar;
	output out = stderrs
	std = rd_std;
run;
data temp;
	set stderrs;
	call symput("std",rd_std);
run;
data final_1980Bbin;
	mean = &rd;
	std = &std;
	lb = mean - 1.96 * std ;
	ub = mean + 1.96 * std ;
	label lb="95% Lower bound"
    	      ub="95% Upper bound"
             std="Standard Error"
      ;
	n = &nids;
run;


/*Standardized risks and confidence intervals*/
proc means data = predicted_mean mean noprint ; 
  var meanY;  
  by bsample adher;
  freq numberhits ; 
  output out = results0 (keep = bsample adher mean ) mean = mean ;
run;

proc transpose data=results0 out=results1b prefix=Risk_;
	by bsample;
	id adher;
	var mean;
run;

data results3;
	set results1b;
	rd = Risk_1 - Risk_0;
run;


data temp3;
	set results3 (where=(bsample = 0));
	call symput("Ard",rd);
	call symput("ARisk0", Risk_0);
	call symput("ARisk1", Risk_1);
run;
proc univariate data=results3 (where = (bsample > 0)) noprint;
	var Risk_0 Risk_1;
	output out = stderrs3
	std = Risk0_std Risk1_std;
run;

data temp3;
	set stderrs3;
	call symput("ARisk0std",risk0_std);
	call symput("ARisk1std",risk1_std);

run;
data final_predB;
	RDmean = &Ard;
	HiAd = &ARisk0;
	HiAdstd = &ARisk0std;
	HiAdlb = HiAd - 1.96 * HiAdstd ;
	HiAdub = HiAd + 1.96 * HiAdstd ;
	LoAd = &ARisk1;
	LoAdstd = &ARisk1std;
	LoAdlb = LoAd - 1.96 * LoAdstd ;
	LoAdub = LoAd + 1.96 * LoAdstd ;
        label HiADlb="95% Lower bound >80% Adh"
    	      HiADub="95% Upper bound >80% Adh"
	      LoADlb="95% Lower bound <80% Adh"
    	      LoADub="95% Upper bound <80% Adh"
	;
run;


/*Print Results*/
proc printto print = &outdest;
run;
proc print data = final_1980Bbin label noobs ;
title2 "Bootstrap results using &nboot samples" ;
title3 "Linear Regression, Placebo Arm";
title4 "<80% Adherence vs >=80% Adherence";
	var mean std lb ub n;
run;

proc print data = final_predB label noobs ;
title2 "Bootstrap results using &nboot samples" ;
title3 "Linear Regression, Placebo Arm";
title4 "<80% Adherence vs >=80% Adherence";
	var RDmean HiAd HiAdlb HiAdub LoAd LoAdlb LoAdub;
run;

proc datasets library=work nolist;
	delete Ids Onesample 
 	params predicted_mean
	results0 results1b results3
	stderrs temp test _idsamples
	temp2 temp3 stderrs3
	; 
quit;



proc printto;
run;
%let timenow2=%sysfunc(time(), time.);
%let datenow2=%sysfunc(date(), date9.);
%put Part A is Complete;
%put End time is &datenow2 / &timenow2 ;
%put ;


%mend partA_adjusted;
