
/************************************************************/
/**Program 4: New Analyses: Post-randomization Covariates **/
/**********************************************************/
/*Note: adherence carried forward 2 missed visits*********/
/**Regimes: Cumulative average >=80% vs *****************/
/**cumulative average <80%******************************/
/*%difference and 95%CI based on 500 bootstraps********/
/*IPW for adherence level at time t*******************/
/****************************************************/

/*libname cdp "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS data";
*/
%include 'C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS code\rcspline.sas';

%macro partC(outdest = , inset = ,  titlemain = , nboot= , lib= , covs_0 = , covs_FV = , covs_lag = , adhvar = adhx15bin );
title &titlemain;
%let rawdata = &lib..&inset;
%put &rawdata;


/*Inverse probability weighting for censoring due to change in adherence*/
proc sort data=&rawdata out=onesample;
by id visit;
run;

%put "sort complete";

data onesample;
set onesample;
where &adhvar ne .;
run;

data onesample ;
  set onesample end = _end_  ;
  by ID;
 retain _id ;
  if _n_ = 1 then _id = 0;
  if first.id then do;
  	_id = _id + 1 ;	
  end;
  if _end_ then do ;
     call symput("nids",trim(left(_id)));
  end;

/*Spline of time*/
%rcspline(visit,0,8,17);
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

%put "initial data created";

data onesample; 
set onesample; 
	adhr_t_flag = 1;
	adh_measure_flag =1;
	cov0_flag = 1;

	if nmiss(of adhbin0, adhr_t1, %sysfunc(tranwrd(%sysfunc(compbl(&covs_0)),%str( ), %str(,))),
			%sysfunc(tranwrd(%sysfunc(compbl(&covs_lag)),%str( ), %str(,)))) then adh_measure_flag = 0;
	if nmiss(of adhbin0, adhr_t1, %sysfunc(tranwrd(%sysfunc(compbl(&covs_0)),%str( ), %str(,))),
			%sysfunc(tranwrd(%sysfunc(compbl(&covs_FV)),%str( ), %str(,)))) then adhr_t_flag = 0;
	if nmiss(of adhx15bin, %sysfunc(tranwrd(%sysfunc(compbl(&covs_0)),%str( ), %str(,)))) then cov0_flag = 0;

run;	


	
%put "outcome set to missing when covs missing";		

%do bsample = 0 %to &nboot;

	%if %eval(&bsample) = 0 %then %do;


proc printto print = &outdest;
run;
	

	
	  	/*IPW for adherence at time t - point estimate*/

		/*model for adherence measured at time t*/
		/*Numerator: Pr(Adh_measured=1|A_0, Baseline covariates)*/

		proc logistic data = onesample (where = (adhbin0 ne . and adhr_t1 ne . and  visit >0 and adh_measure_flag = 1)) descending;
			model adh_measure = visit visit1 adhbin0 adhr_t1 
				&covs_0 ;
			output out = adhmeas_num0 (keep=id visit mesr_0a0) p = mesr_0a0;
		run;

	
		/*Denominator: Pr(Adh_measured=1|Baseline covariates, Time-varying covariates)*/

		proc logistic data = onesample (where =(adhbin0 ne . and adhr_t1 ne . and  visit >0 and adh_measure_flag = 1)) descending ;
			model adh_measure = visit visit1  adhbin0 adhr_t1 
				&covs_0 &covs_lag ;
			output out = adhmeas_dnom0 (keep=id visit mesr_wa0) p = mesr_wa0;
		run;

		/*model for adherence at time t, given adherence measured*/

		/*Numerator: Pr(A_t=1|A_0, Baseline covariates)*/

		proc logistic data=onesample (where =(adhbin0 ne . and adhr_t1 ne . and visit >0 and adhr_t_flag = 1)) descending;
			model adhr_t = visit visit1 adhbin0 adhr_t1 
				&covs_0 ;
			output out = censadh_num0 (keep=id visit punc_0a0) p = punc_0a0;
		run;

		/*Denominator: Pr(A_t=1|A_0, Baseline covariates, Time-varying covariates)*/

		proc logistic data=onesample (where =(adhbin0 ne . and adhr_t1 ne . and visit >0 and adhr_t_flag = 1 )) descending;
			model adhr_t =  visit visit1  adhbin0 adhr_t1 
				&covs_0 &covs_FV ;
			output out = censadh_dnom0 (keep = id  visit punc_wa0)  p = punc_wa0;
		run;


		proc sort data=adhmeas_num0;
			by ID visit;
		proc sort data=adhmeas_dnom0;
			by ID visit;
		proc sort data=censadh_num0;
			by ID  visit;
		proc sort data=censadh_dnom0;
			by ID  visit;
		proc sort data=onesample;
			by ID  visit;
		data main_w6;
		        merge onesample censadh_num0 censadh_dnom0 adhmeas_num0 adhmeas_dnom0 ;
		        by ID  visit;

		/* variables ending with _0 refer to the numerator of the weights
		   Variables ending with _w refer to the denominator of the weights */

		        if first.id then do; 
				k1_0=1;
				k1_w=1; 
				m1_0=1;
				m1_w=1;
			end;
			retain k1_0 k1_w m1_0 m1_w;
		
			if adhr_t ne . then do;
		
				if mesr_0a0 = . then mesr_0a0 =1;	
				if mesr_wa0 = . then mesr_wa0 =1;
				m1_0=m1_0*mesr_0a0;
				m1_w=m1_w*mesr_wa0;

				if adhr_t = 0 then do;
					if punc_0a0 = . then punc_0a0 =0;
					if punc_wa0 = . then punc_wa0 =0;

				        k1_0=k1_0*(1-punc_0a0);
				       	k1_w=k1_w*(1-punc_wa0);
				end;
				else if adhr_t = 1 then do;
					if punc_0a0 = . then punc_0a0 =1;
					if punc_wa0 = . then punc_wa0 =1;
				        k1_0=k1_0*(punc_0a0);
			        	k1_w=k1_w*(punc_wa0);
				end;

			end;
			else if adhr_t = . then do;
				if mesr_0a0 = . then mesr_0a0 =0;	
				if mesr_wa0 = . then mesr_wa0 =0;
				m1_0=m1_0*(1-mesr_0a0);
				m1_w=m1_w*(1-mesr_wa0);

				k1_0 = k1_0*1;
				k1_w = k1_w*1;
			end;
				
		        stabw_a=(k1_0)/(k1_w);
		        nstabw_a=1/(k1_w);

		        stabw_m=(m1_0)/(m1_w);
		        nstabw_m=1/(m1_w);

		        stabw =stabw_a*stabw_m;
		        nstabw =nstabw_a*nstabw_m;

		run;
		proc printto print = &outdest;
		run;
		proc means data=main_w6  n mean std min max p95 p99 nmiss;
			var nstabw stabw nstabw_a stabw_a nstabw_m stabw_m;
			title 'weights, all';
		run;
		proc printto print = &outdest;
		run;
		proc freq data=main_w6 nlevels;
			where stabw ne .; 
			tables ID /noprint;
			title 'weights, all';
		run;

		data endfup;
		 	set main_w6  end = _end_  ;
			by ID;
			retain _id ;
			 if _n_ = 1 then _id = 0;
			 if last.id then do;
			  	_id = _id + 1 ;	
				output;
			  end;
		run;

		proc printto print = &outdest;
		run;
		proc means data=endfup  n mean std min max p95 p99 p1 nmiss;
			var  nstabw stabw nstabw_a stabw_a nstabw_m stabw_m;
			title 'weights, end of follow-up';
		run;
		
		proc freq data=endfup nlevels;
			where stabw ne .; 
			tables ID /noprint;
			title 'weights, end of follow-up';
		run;
		
		/*for truncation*/
		proc means data=endfup  n mean std min max p95 p99 nmiss noprint;
			var stabw;
			title 'stabilized weights, end of follow-up';
			output out=pctl (keep = p99) p99 = p99 ;
		run;
		proc means data=endfup  p99 noprint;
			var nstabw;
			title 'stabilized weights, end of follow-up';
			output out=pctl_n (keep = p99) p99 = p99 ;
		run;			

		data temp;
			set pctl;
			call symput ('cutoff', p99);
		run;
		data temp_n;
			set pctl_n;
			call symput ('cutoff_n', p99);
		run;

		data trunc; 
		set endfup;
			stabw1 = stabw;
			if stabw >  %sysevalf(&cutoff)  then do;
				stabw1 = %sysevalf(&cutoff);
			end;
			nstabw1 = nstabw;
			if nstabw >  %sysevalf(&cutoff_n)  then do;
				nstabw1 = %sysevalf(&cutoff_n);
			end;
		run;
		proc means data=trunc  n mean std min max p95 p99 nmiss;
			var stabw stabw1 nstabw nstabw1;
			title 'stabilized weights, end of follow-up';
		run;



		/*Weighted regression model*/
		/*Pr(Y=1|Adherence at last visit, Baseline covariates)*/
		proc logistic data = trunc  descending ;
		ods output ParameterEstimates = PE;
		        model dth5 =  adhx15bin &covs_0 ;
		        weight stabw1;
			title 'Main Weighted model';
		run;
		
		proc sql noprint;
			select ESTIMATE FORMAT =16.12 INTO: IBC_ESTIMATE separated by ' ' from pe;
		quit;
		proc sql noprint;
			select variable INTO: model separated by ' ' from PE;
		quit;

		proc means sum noprint data = pe;	
			var df;
			output out = nobs (drop = _type_ _freq_ where=(_stat_ ="N"));
		run;
		proc sql noprint;
			select df into:nvar separated by ' ' from nobs;		
		quit;

		data rq1 (keep = p0 p1 numberhits );
			set trunc;
			where cov0_flag =1;
			array var{&nvar} &model;
			array coef{&nvar} (&ibc_estimate);

			intercept = 1;
			numberhits = 1;
	
			xbeta0 = 0;
			xbeta1 = 0;
			do i = 1 to dim(var);
				adhx15bin =0;
				xbeta0 = xbeta0 + coef[i] *var[i];
		
				adhx15bin = 1;
				xbeta1 = xbeta1 + coef[i]*var[i];
			end;

			p0 = 1/(1+exp(-xbeta0));
			p1 = 1/(1+exp(-xbeta1));
	
			output;
		run;

		proc means data = rq1 mean noprint;
			var p0 p1;
			freq numberhits;
			output out = mean_1 (drop =_type_ _freq_) mean(p0 p1) = ;
		run;
		
		data mean_1;
			set mean_1;
			label p0 = "Cumulative Adherence < 80%"
			      p1 = "Cumulative Adherence >= 80%";
			bsample = &bsample;
		run;

		data means_all;
			set mean_1;
		run;
		

		proc datasets library = work nolist;
			delete censadh_num0  censadh_dnom0 temp pctl rq1 pe mean_1;
		run;
		%symdel cutoff;


proc printto ;
run;

	%end;

	%else %do;
		title "Bootstrap number &bsample";
	
		proc sort data = onesample ;
			by _id;
		run;

		data bootsample;
			merge onesample _idsamples (where = (bsample = &bsample));
			by _id;
		run;

		proc sort data = bootsample  sortsize=5G ;
			by id visit ;
		run;
	
	

	  	/*IPW for adherence at time t - bootstrap sample*/

		/*model for adherence measured at time t*/
		/*Numerator: Pr(Adh_measured=1|A_0, Baseline covariates)*/

		proc logistic data = bootsample (where =(adhbin0 ne . and adhr_t1 ne . and  visit >0 and adh_measure_flag = 1)) descending;

			model adh_measure = visit visit1 adhbin0 adhr_t1 
				&covs_0 ;
			freq numberhits ;
			output out = adhmeasbootnum0 (keep=id visit mesr_0a0) p = mesr_0a0;
		run;

	
		/*Denominator: Pr(Adh_measured=1|Baseline covariates, Time-varying covariates)*/

		proc logistic data = bootsample (where =(adhbin0 ne . and adhr_t1 ne . and  visit >0 and adh_measure_flag = 1)) descending ;

			model adh_measure = visit visit1  adhbin0 adhr_t1 
				&covs_0 &covs_lag ;
			freq numberhits ;
			output out = adhmeasbootden0 (keep=id visit mesr_wa0) p = mesr_wa0;
		run;

		/*model for adherence at time t, given adherence measured*/
	
		/*Numerator: Pr(A_t=1|A_0, Baseline covariates)*/

		proc logistic data=bootsample (where =(adhbin0 ne . and adhr_t1 ne . and  visit >0 and adhr_t_flag = 1 )) descending;

			model adhr_t = visit visit1 adhbin0 adhr_t1 
				&covs_0 ;
			freq numberhits ;
			output out = cnsadhbootnum0 (keep=id visit punc_0a0) p = punc_0a0;
		run;

		/*Denominator: Pr(A_t=1|A_0, Baseline covariates, Time-varying covariates)*/

		proc logistic data=bootsample (where =(adhbin0 ne . and adhr_t1 ne . and  visit >0 and adhr_t_flag = 1)) descending;

			model adhr_t =  visit visit1  adhbin0 adhr_t1 
				&covs_0 &covs_FV;
			freq numberhits ;
			output out = cnsadhbootden0 (keep = id  visit punc_wa0)  p = punc_wa0;
		run;


		proc sort data=adhmeasbootnum0;
		by ID visit;
		proc sort data=adhmeasbootden0;
		by ID visit;
		proc sort data=cnsadhbootnum0;
		by ID visit;
		proc sort data=cnsadhbootden0;
		by ID visit;

		proc sort data = bootsample  sortsize=5G ;
			by id visit ;
		run;

		data weighted;
		        merge bootsample cnsadhbootnum0 cnsadhbootden0 adhmeasbootnum0 adhmeasbootden0;
		        by ID visit;

		/* variables ending with _0 refer to the numerator of the weights
		   Variables ending with _w refer to the denominator of the weights */

		    if first.id then do; 
				k1_0=1;
				k1_w=1; 
				m1_0=1;
				m1_w=1;
			end;
			retain k1_0 k1_w m1_0 m1_w;

			if adhr_t ne . then do;
		
				if mesr_0a0 = . then mesr_0a0 =1;	
				if mesr_wa0 = . then mesr_wa0 =1;
				m1_0=m1_0*mesr_0a0;
				m1_w=m1_w*mesr_wa0;

				if adhr_t = 0 then do;
					if punc_0a0 = . then punc_0a0 =0;
					if punc_wa0 = . then punc_wa0 =0;

				        k1_0=k1_0*(1-punc_0a0);
				       	k1_w=k1_w*(1-punc_wa0);
				end;
				else if adhr_t = 1 then do;
					if punc_0a0 = . then punc_0a0 =1;
					if punc_wa0 = . then punc_wa0 =1;
				        k1_0=k1_0*(punc_0a0);
			        	k1_w=k1_w*(punc_wa0);
				end;

			end;
			else if adhr_t = . then do;
				if mesr_0a0 = . then mesr_0a0 =0;	
				if mesr_wa0 = . then mesr_wa0 =0;
				m1_0=m1_0*(1-mesr_0a0);
				m1_w=m1_w*(1-mesr_wa0);

				k1_0 = k1_0*1;
				k1_w = k1_w*1;
			end;
				
		        stabw_a=(k1_0)/(k1_w);
		        nstabw_a=1/(k1_w);

		        stabw_m=(m1_0)/(m1_w);
		        nstabw_m=1/(m1_w);

		        stabw =stabw_a*stabw_m;
		        nstabw =nstabw_a*nstabw_m;

		run;

		data endfup_boot;
		 	set weighted  end = _end_  ;
			by ID;
			retain _id ;
			 if _n_ = 1 then _id = 0;
			 if last.id then do;
			  	_id = _id + 1 ;	
				output;
			  end;
		run;

		proc means data=endfup_boot  p99 noprint;
			var stabw;
			title 'stabilized weights, end of follow-up';
			output out=pctl_boot (keep = p99) p99 = p99 ;
		run;
		proc means data=endfup_boot  p99 noprint;
			var nstabw;
			title 'unstabilized weights, end of follow-up';
			output out=pctl_boot_n (keep = p99) p99 = p99 ;
		run;

		data temp_boot;
			set pctl_boot;
			call symput ('cutoff', p99);
		run;

		data temp_boot_n;
			set pctl_boot_n;
			call symput ('cutoff_n', p99);
		run;

		data trunc_boot; 
			set endfup_boot;
			stabw1 = stabw;
			if stabw >  %sysevalf(&cutoff)  then do;
				stabw1 = %sysevalf(&cutoff);
			end;
			nstabw1 = nstabw;
			if nstabw >  %sysevalf(&cutoff_n)  then do;
				nstabw1 = %sysevalf(&cutoff_n);
			end;
		run;

		/*Weighted regression model*/
		/*Pr(Y=1|Cumulative Adherence to last visit, Baseline covariates)*/
		proc logistic data = trunc_boot  descending;
		ods output ParameterEstimates = pe_boot;
		        model dth5 =  adhx15bin  
		       	&covs_0 ;	
		        weight stabw1;
			freq numberhits;
		run;

		proc sql noprint;
			select ESTIMATE FORMAT =16.12 INTO: IBC_ESTIMATE separated by ' ' from pe_boot;
		quit;
		proc sql noprint;
			select variable INTO: model separated by ' ' from pe_boot;
		quit;

		proc means sum noprint data = pe_boot;	
			var df;
			output out = nobs_boot (drop = _type_ _freq_ where=(_stat_ ="N"));
		run;
		proc sql noprint;
			select df into:nvar separated by ' ' from nobs_boot;		
		quit;

		data rq1_boot (keep = p0 p1 numberhits);
			set trunc_boot;
			where cov0_flag =1;
			array var{&nvar} &model;
			array coef{&nvar} (&ibc_estimate);

			intercept = 1;
	
			xbeta0 = 0;
			xbeta1 = 0;
			do i = 1 to dim(var);
				adhx15bin =0;
				xbeta0 = xbeta0 + coef[i] *var[i];
		
				adhx15bin = 1;
				xbeta1 = xbeta1 + coef[i]*var[i];
			end;

			p0 = 1/(1+exp(-xbeta0));
			p1 = 1/(1+exp(-xbeta1));
	
			output;
		run;

		proc means data = rq1_boot mean noprint;
			var p0 p1;
			freq numberhits;
			output out = mean_boot (drop =_type_ _freq_) mean(p0 p1) = ;
		run;
		
		data mean_boot;
			set mean_boot;
			label p0 = "Cumulative Adherence < 80%"
			      p1 = "Cumulative Adherence >= 80%";
			bsample = &bsample;
		run;

		data means_all;
			set means_all mean_boot;
			by bsample;
		run;
		
		proc datasets library = work nolist;
			delete mean_boot bootsample weighted cnsadhbootnum0 cnsadhbootden0  endfup_boot trunc_boot temp_boot pctl_boot pe_boot rq1_boot;
		run;
		%symdel cutoff;
	%end;
%end;

proc printto print = &outdest;
run;

title "Summary";

proc sort data=means_all;
by bsample;
run;

/*Risk Difference and Confidence Intervals*/
data rds ;
	set means_all;
	risk_diff = p1-p0;
	keep bsample risk_diff p1 p0;
run;

proc means data = rds (where = (bsample > 0)) noprint ;
	var risk_diff;
	output out=diffstd (keep = std) std = std ;
run;

data sample0;
	set rds (where=(bsample = 0));
	keep risk_diff p0 p1;
run;

data final_2014C;
	merge sample0 diffstd; 
	lb = risk_diff - 1.96 * std ;
	ub = risk_diff + 1.96 * std ;
	n = &nids;
	label lb="95% Lower bound"
    	  ub="95% Upper bound"
          std="Standard Error"
		  p0 = "EY_a0"
		  p1 = "EY_a1"
      ;
run;

proc printto print = &outdest;
run;
proc print data= final_2014C label noobs ;
title &titlemain;
title2 'Adjusted Risk Difference, Logistic regression';
title3 "95% Confidence Intervals using &nboot samples" ;
title4 "<80% Adherence vs >=80% Adherence";
	var risk_diff std lb ub n p0 p1;
run;

/*
proc datasets library=work nolist;
	delete Diffstd Ids Main_w6 Onesample 
	results sample0 weighted _idsamples means_all rds
	; 
quit;*/


proc printto;
run;
%let timenow2=%sysfunc(time(), time.);
%let datenow2=%sysfunc(date(), date9.);
%put Part C is complete;
%put End time is &datenow2 / &timenow2 ;
%put Program is complete;
%put ; 	

%mend partC;


/**RUN MACROS**

%let nboot = 5;


%let covs_orig = adhpre0bin age_bin   nonwhite   IRK   MI_bin  RBW_bin  
			NIHA_bin0  HiSysBP0   HiDiasBP0   HiWhiteCell0  
			HiNeut0    HiHemat0 	 
			HiBili0   HiSerChol0   HiSerTrigly0   
			HiSerUric0   HiSerAlk0    HiPlasUrea0   
			HiFastGluc0    HiOneGluc0   HiHeart0   
			CHF0    ACI0    AP0  
			IC0  ICIA0   DIG0    DIUR0    
			AntiArr0    AntiHyp0    OralHyp0   
			CardioM0   AnyQQS0   AnySTDep0   AnyTWave0 
			STElev0    FVEB0   VCD0   CIG0   INACT0 ;

%let covs_origFV = 	NIHAFV HiSysBPFV HiDiasBPFV HiWhiteCellFV HiNeutFV HiHematFV	
			HiBiliFV HiSerCholFV HiSerTriglyFV HiSerUricFV HiSerAlkFV
			HiPlasUreaFV HiFastGlucFV HiOneGlucFV HiHeartFV 
			CHFFV ACIFV APFV ICFV ICIAFV DIGFV DIURFV AntiArrFV 
			AntiHypFV OralHypFV CardioMFV AnyQQSFV AnySTDepFV
			AnyTWaveFV STElevFV FVEBFV VCDFV
			CIGFV INACTFV ;

%let covs_origlag = NIHAFV_t1 HiSysBPFV_t1  HiDiasBPFV_t1  HiWhiteCellFV_t1  HiNeutFV_t1  HiHematFV_t1 	
			HiBiliFV_t1  HiSerCholFV_t1  HiSerTriglyFV_t1  HiSerUricFV_t1  HiSerAlkFV_t1 
			HiPlasUreaFV_t1  HiFastGlucFV_t1  HiOneGlucFV_t1  HiHeartFV_t1  
			CHFFV_t1  ACIFV_t1  APFV_t1  ICFV_t1  ICIAFV_t1  DIGFV_t1  DIURFV_t1  AntiArrFV_t1  
			AntiHypFV_t1  OralHypFV_t1  CardioMFV_t1  AnyQQSFV_t1  AnySTDepFV_t1  
			AnyTWaveFV_t1  STElevFV_t1 FVEBFV_t1  VCDFV_t1  CIGFV_t1  INACTFV_t1 ;



%let covs_new = adhpre0bin age_bin mi_bin irk  occupation 
			NIHA_bin0 rbw_bin nonwhite
			cig0 employ0 fulltime0 
			hypertens0 htmed0
			hyperlipid0 chf0 diab0 
			afib0 inact0 
			oralhyp0 dig0 ap0 aci0 cardioM0
			icia0 ic0 diur0 
			antihyp0  antiArr0 HiFastGluc0 ;

%let covsFV = employFV fulltimeFV
			hypertensFV htmedFV
			hyperlipidFV chfFV diabFV 
			afibFV inactFV oralhypFV	
			digFV apFV aciFV cardioMFV
			iciaFV icFV diurFV 
			antihypFV antiArrFV HiFastGlucFV 
;

%let covs_lag = employFV_t1 fulltimeFV_t1
			hypertensFV_t1 htmedFV_t1
			hyperlipidFV_t1 chfFV_t1 diabFV_t1 
			afibFV_t1 inactFV_t1 oralhypFV_t1	
			digFV_t1 apFV_t1 aciFV_t1 cardioMFV_t1
			iciaFV_t1 icFV_t1 diurFV_t1 
			antihypFV_t1 antiArrFV_t1 HiFastGlucFV_t1 
;

			
%let covs_subset = adhpre0bin age_bin   nonwhite   IRK   MI_bin  RBW_bin  
			NIHA_bin0 
			HiFastGluc0      CHF0    ACI0    AP0  
			IC0  ICIA0   DIG0    DIUR0    
			AntiArr0    AntiHyp0    OralHyp0   
			CardioM0    CIG0   INACT0 ;

			
			
%let covs_subsetFV = NIHAFV HiFastGlucFV   CHFFV    ACIFV   APFV 
			ICFV  ICIAFV   DIGFV    DIURFV    AntiArrFV    AntiHypFV    OralHypFV   
			CardioMFV    CIGFV   INACTFV ;

			
			
%let covs_subset_lag = 	NIHAFV_t1 
			HiFastGlucFV_t1    CHFFV_t1     ACIFV_t1     APFV_t1 
			ICFV_t1   ICIAFV_t1    DIGFV_t1     DIURFV_t1     AntiArrFV_t1     AntiHypFV_t1    OralHypFV_t1    
			CardioMFV_t1     CIGFV_t1    INACTFV_t1  ;

/*original covs; original data*
%partC( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartC.orig_analysis.rtf", 
	inset = censwt_ag, 
	titlemain = 'Adherence at time t: IPW Adjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=cdp, 
		covs_0 = &covs_orig, covs_FV = &covs_FV_orig , covs_lag = &covs_lag_orig);

%partC( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartC.orig_covs.rtf", 
	inset = ExpertDAG_ag_orig, 
	titlemain = 'Adherence at time t: IPW Adjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=cdp, 
		covs_0 = &covs_orig, covs_FV = &covs_FV_orig , covs_lag = &covs_lag_orig);
/*Subset covs*
%partC( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartC.subset_covs.rtf", 
		inset = ExpertDAG_ag_subset, 
	titlemain = 'Adherence at time t: IPW Adjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=cdp, 
		covs_0 = &covs_subset, covs_FV = &covs_subsetFV , covs_lag = &covs_subset_lag);

/*New covs; new data*
%partC( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartC.new_covs.rtf", 
	inset = ExpertDAG_ag_new, 
	titlemain = 'Adherence at time t: IPW Adjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=cdp, 
		covs_0 = &covs_new, covs_FV = &covsFV , covs_lag = &covs_lag);


	

%let covsFV2 = employFV fulltimeFV
			htmedFV
			hyperlipidFV chfFV diabFV 
			afibFV inactFV oralhypFV	
			digFV apFV aciFV cardioMFV
			iciaFV icFV diurFV 
			antihypFV antiArrFV HiFastGlucFV 
;

%let covs_lag2 = employFV_t1 fulltimeFV_t1
			 htmedFV_t1
			hyperlipidFV_t1 chfFV_t1 diabFV_t1 
			afibFV_t1 inactFV_t1 oralhypFV_t1	
			digFV_t1 apFV_t1 aciFV_t1 cardioMFV_t1
			iciaFV_t1 icFV_t1 diurFV_t1 
			antihypFV_t1 antiArrFV_t1 HiFastGlucFV_t1 
;

/*New covs ( minus hypertensionFV); new data*
%partC( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartC.new_covs.noTVhyp.rtf", 
	inset = ExpertDAG_ag_new, 
	titlemain = 'Adherence at time t: IPW Adjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=cdp, 
		covs_0 = &covs_new, covs_FV = &covsFV2 , covs_lag = &covs_lag2);

	
/*
%partC( outdest = "PartC.cumA.final.rtf", inset = censwt_ag, 
	titlemain = 'Adherence at time t: IPW Adjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=cdp);
