

/*****************************************************/
/**Program 3: New Analyses: Baseline Covariates Only**/
/*****************************************************/
/*Note: adherence carried forward 2 missed visits****/
/*%difference and 95%CI based on 500 bootstraps******/
/*Crude and Standardized estimates*******************/
/****************************************************/


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
