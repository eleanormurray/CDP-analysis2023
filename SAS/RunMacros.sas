

libname cdp "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS data";


/*****RUN MACROS***/
%let nboot = 500;

%let covs_orig = age_bin nonwhite mi_bin niha_bin1 rbw_bin 
			chf aci ap ic icia dig diur irk antiarr antihyp oralhyp  
			cardiom stelev hifastgluc cig inact anyqqs anystdep 
			anytwave fveb vcd hiheart hisysbp hidiasbp hibili hiserchol  
			hisertrigly hiseruric hiseralk hiplasurea hionegluc hiwhitecell 
			hineut hihemat ; 

%let covs_new =  age_bin mi_bin irk  occupation0
			occupation1 occupation2 occupation3 occupation4 occupation5
			occupation6 occupation7 occupation8 occupation9
			niha_bin1 rbw_bin nonwhite
			cig employ fulltime
			hypertens 
			hyperlipid_1 hyperlipid_2 hyperlipid_0 chf diab 
			afib inact 
			oralhyp adhpre0bin
			dig ap aci cardioM
			icia ic diur 
			antihyp  antiArr HiFastGluc;

			
%let covs_subset =  age_bin nonwhite mi_bin niha_bin1 rbw_bin irk 
			hifastgluc chf aci ap ic icia dig diur antiarr antihyp oralhyp  
			cardiom  cig inact;

/***************************************/
/*Unadjusted: old adherence definition*/
/*Part A unadj == old adherence definition (missed adherence = 0). This replicates original CDP */
%partA_unadjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartA.Unadj.old_data.rtf", 
		inset = ExpertDAG_wide_orig, titlemain = "Unadjusted, Old data, Missed Adherence = 0", 
		nboot = &nboot, lib = cdp);

/*Subset of original covs: using dataset with missing obs deleted on basis of ^trimmed^ covariate list*/
%partA_unadjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartA.Unadj.subset_covs.rtf", 
		inset = ExpertDAG_wide_subset, titlemain = "Unadjusted, New data, Missed Adherence = 0", 
		nboot = &nboot, lib = cdp);

/*DAG-based analysis Using dataset with missing obs deleted on basis of NEW covariate list*/
%partA_unadjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartA.Unadj.new_data.rtf", 
		inset = ExpertDAG_wide, titlemain = "Unadjusted, New data, Missed Adherence = 0", 
		nboot = &nboot, lib = cdp);
/***************************************/
/*Unadjusted: new adherence definition*/

/*Unadjusted; old dataset; new adherence definition*/
%partB_unadjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartB.Unadj.old_cov_data.rtf", 
		inset = ExpertDAG_wide_orig, titlemain = "Unadjusted, Missed Adherence Carried Forward", 
		nboot = &nboot, lib = cdp);

/*Unadjusted; new dataset; new adherence definition*/
%partB_unadjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartB.Unadj.new_cov_data.rtf", 
		inset = ExpertDAG_wide, titlemain = "Unadjusted, Missed Adherence Carried Forward", 
		nboot = &nboot, lib = cdp);

/*Unadjusted; subset covs; new adherence definition*/
%partB_unadjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartB.Unadj.subset_cov_data.rtf", 
		inset = ExpertDAG_wide_subset, titlemain = "Unadjusted, Missed Adherence Carried Forward", 
		nboot = &nboot, lib = cdp);

/***************************************/
/*Part A adj == linear regression*/
/*Old adherence definition & old dataset / old covariates*/
%partA_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartA.Adj.linear.old_covs.old_adhbin.test.rtf", 
	inset =  ExpertDAG_wide_orig, 
	titlemain = 'Adjusted, 1980 Replication, Missed Adherence = 0',  nboot = &nboot, lib=cdp, adhvar = old_adhx15bin, covs = &covs_orig);

/*original 1980 adherence definition & new covariates /dataset*/
%partA_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartA.Adj.linear.new_covs.old_adhbin.test.rtf", 
	inset =  ExpertDAG_wide, 
	titlemain = 'Adjusted, New covariates, Missed Adherence = 0',  nboot = &nboot, lib=cdp, adhvar = old_adhx15bin, covs = &covs_new);


/*NEW adherence definition & old dataset / old covariates*/
%partA_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartA.Adj.linear.old_covs.new_adhbin.test.rtf", 
	inset =  ExpertDAG_wide_orig, 
	titlemain = 'Adjusted, 2016 replication, Missed Adherence = .',  nboot = &nboot, lib=cdp, adhvar = adhx15bin, covs = &covs_orig);

/*NEW adherence definition & new covariates /dataset*/
%partA_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartA.Adj.linear.new_covs.new_adhbin.test.rtf", 
	inset =  ExpertDAG_wide, 
	titlemain = 'Adjusted, New covariates, Missed Adherence = .',  nboot = &nboot, lib=cdp, adhvar = adhx15bin, covs = &covs_new);

/*original 1980 adherence definition & subset of covariates*/
%partA_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartA.Adj.linear.subset_covs.old_adhbin.test.rtf", 
		inset = ExpertDAG_wide_subset, titlemain = 'Adjusted, Subset covariates, Missed Adherence = 0',  nboot = &nboot, lib=cdp, 
	adhvar = old_adhx15bin, covs = &covs_subset);

/*NEW adherence definition & subset of covariates*/
%partA_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartA.Adj.linear.subset_covs.new_adhbin.test.rtf", 
		inset = ExpertDAG_wide_subset, titlemain = 'Adjusted, Subset covariates, Missed Adherence = 0',  nboot = &nboot, lib=cdp, 
	adhvar = adhx15bin, covs = &covs_subset);


/*NEW adherence definition & old dataset + new covariates*/
%partA_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartA.Adj.linear.new_covs.new_adhbin.olddata.rtf", 
	inset =  ExpertDAG_wide_orig, 
	titlemain = 'Adjusted, 2016 replication, Missed Adherence = .',  nboot = &nboot, lib=cdp, adhvar = adhx15bin, covs = &covs_new);


/***************************************/
/*Part B adj == logistic regression*/

/*old adherence definition*/
/*updated adherence definition: old covariates /old data*/
%partB_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartB.Adj.logistic.orig_covs1.rtf", 
	inset =  ExpertDAG_wide_orig, 
	titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=cdp, adhvar = old_adhx15bin, covs = &covs_orig);

/*updated adherence definition: new covariates and AFTER deleting obs with missing values of the new vars*/
%partB_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartB.Adj.logistic.new_covs1.rtf", 
	inset =  ExpertDAG_wide, 
	titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=cdp, adhvar = old_adhx15bin, covs = &covs_new);

/*updated adherence definition: subset covariates */
%partB_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartB.Adj.logistic.subset_covs1.rtf", 
	inset =  ExpertDAG_wide_subset, 
	titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=cdp, adhvar = old_adhx15bin, covs = &covs_subset);

/*new adherence definition*/
/*updated adherence definition: old covariates /old data*/
%partB_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartB.Adj.logistic.orig_covs2.rtf", 
	inset =  ExpertDAG_wide_orig, 
	titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=cdp, adhvar = adhx15bin, covs = &covs_orig);

/*updated adherence definition: new covariates and AFTER deleting obs with missing values of the new vars*/
%partB_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartB.Adj.logistic.new_covs2.rtf", 
	inset =  ExpertDAG_wide, 
	titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=cdp, adhvar = adhx15bin, covs = &covs_new);

/*updated adherence definition: subset covariates */
%partB_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartB.Adj.logistic.subset_covs2.rtf", 
	inset =  ExpertDAG_wide_subset, 
	titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=cdp, adhvar = adhx15bin, covs = &covs_subset);


/*updated adherence definition: new covariates and AFTER deleting obs with missing values of the new vars*/
%partB_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartB.Adj.logistic.new_covs3.rtf", 
	inset =  ExpertDAG_wide_orig, 
	titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=cdp, adhvar = adhx15bin, covs = &covs_new);

/***************************************/
/*Part C adj == IP weighted*/

%let covs_orig =  adhpre0bin age_bin nonwhite irk mi_bin rbw_bin niha_bin0 
		hisysbp0 hidiasbp0 hiwhitecell0 hineut0 hihemat0 hibili0 hiserchol0 
		hisertrigly0 hiseruric0 hiseralk0 hiplasurea0 hifastgluc0 hionegluc0 
		hiheart0 chf0 aci0 ap0 ic0 icia0 dig0 diur0 antiarr0 antihyp0 oralhyp0 
		cardiom0 anyqqs0 anystdep0 anytwave0 stelev0 fveb0 vcd0 cig0 inact0 ;

%let covs_origFV = 	NIHAFV HiSysBPFV HiDiasBPFV HiWhiteCellFV HiNeutFV HiHematFV	
			HiBiliFV HiSerCholFV HiSerTriglyFV HiSerUricFV HiSerAlkFV
			HiPlasUreaFV HiFastGlucFV HiOneGlucFV HiHeartFV 
			CHFFV ACIFV APFV ICFV ICIAFV DIGFV DIURFV AntiArrFV 
			AntiHypFV OralHypFV CardioMFV AnyQQSFV AnySTDepFV
			AnyTWaveFV STElevFV FVEBFV VCDFV
			CIGFV INACTFV ;

%let covs_origFV2 = 	NIHAFV HiSysBPFV HiDiasBPFV HiWhiteCellFV HiNeutFV HiHematFV	
			HiBiliFV HiSerCholFV HiSerTriglyFV hisertriglyfv_t1 hiseruricfv_t1 
		hiseralkfv_t1 hiplasureafv_t1 hifastglucfv_t1 hioneglucfv_t1 HiHeartFV 
			CHFFV ACIFV APFV ICFV ICIAFV DIGFV DIURFV AntiArrFV 
			AntiHypFV OralHypFV CardioMFV AnyQQSFV AnySTDepFV
			AnyTWaveFV STElevFV FVEBFV VCDFV
			CIGFV INACTFV ;

%let covs_origlag = nihafv_t1 hisysbpfv_t1 hidiasbpfv_t1 hiwhitecellfv_t1 hineutfv_t1 
		hihematfv_t1 hibilifv_t1 hisercholfv_t1 hisertriglyfv_t1 hiseruricfv_t1 
		hiseralkfv_t1 hiplasureafv_t1 hifastglucfv_t1 hioneglucfv_t1 hiheartfv_t1 chffv_t1
		acifv_t1 apfv_t1 icfv_t1 iciafv_t1 digfv_t1 diurfv_t1 antiarrfv_t1 antihypfv_t1
		oralhypfv_t1 cardiomfv_t1 anyqqsfv_t1 anystdepfv_t1 anytwavefv_t1 stelevfv_t1
		fvebfv_t1 vcdfv_t1 cigfv_t1 inactfv_t1 ;

%let covs_new = adhpre0bin age_bin mi_bin irk occupation0 
			occupation1 occupation2 occupation3 occupation4 occupation5
			occupation6 occupation7 occupation8 occupation9
			NIHA_bin0 rbw_bin nonwhite
			cig0 employ0 fulltime0 
			hypertens0 
			hyperlipid0_1 hyperlipid0_2  hyperlipid0_0 chf0 diab0 
			afib0 inact0 
			oralhyp0 dig0 ap0 aci0 cardioM0
			icia0 ic0 diur0 
			antihyp0  antiArr0 HiFastGluc0 ;

%let covsFV = employFV fulltimeFV
			hypertensFV
			hyperlipidFV_1	hyperlipidFV_2 	hyperlipidFV_0  chfFV diabFV 
			afibFV inactFV oralhypFV	
			digFV apFV aciFV cardioMFV
			iciaFV icFV diurFV 
			antihypFV antiArrFV HiFastGlucFV 
;

%let covs_lag = employFV_t1 fulltimeFV_t1
			hypertensFV_t1 
			hyperlipidfv_t1_1 hyperlipidFV_t1_2  hyperlipidFV_t1_0 chfFV_t1 diabFV_t1 
			afibFV_t1 inactFV_t1 oralhypFV_t1	
			digFV_t1 apFV_t1 aciFV_t1 cardioMFV_t1
			iciaFV_t1 icFV_t1 diurFV_t1 
			antihypFV_t1 antiArrFV_t1 HiFastGlucFV_t1 
;

			
%let covs_subset = adhpre0bin age_bin   nonwhite   IRK   MI_bin  RBW_bin  
			NIHA_bin0 HiFastGluc0   CHF0   ACI0   AP0  
			IC0  ICIA0   DIG0    DIUR0    
			AntiArr0    AntiHyp0    OralHyp0   
			CardioM0    CIG0   INACT0 ;
			
			
%let covs_subsetFV = NIHAFV HiFastGlucFV   CHFFV    ACIFV   APFV 
			ICFV  ICIAFV   DIGFV    DIURFV    AntiArrFV    AntiHypFV    OralHypFV   
			CardioMFV    CIGFV   INACTFV ;
			
			
%let covs_subset_lag = 	NIHAFV_t1 HiFastGlucFV_t1   CHFFV_t1    ACIFV_t1    APFV_t1 
			ICFV_t1   ICIAFV_t1    DIGFV_t1     DIURFV_t1     AntiArrFV_t1     AntiHypFV_t1    OralHypFV_t1    
			CardioMFV_t1     CIGFV_t1    INACTFV_t1  ;

/*original covs; original data*/
%partC( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartC.orig_covs_test2.rtf", 
	inset = ExpertDAG_ag_orig, 
	titlemain = 'Adherence at time t: IPW Adjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=cdp, 
		covs_0 = &covs_orig, covs_FV = &covs_origFV2 , covs_lag = &covs_origlag);

/*Subset covs*/
%partC( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartC.subset_covs1.rtf", 
		inset = ExpertDAG_ag_subset, 
	titlemain = 'Adherence at time t: IPW Adjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=cdp, 
		covs_0 = &covs_subset, covs_FV = &covs_subsetFV , covs_lag = &covs_subset_lag);

%let nboot = 500;
/*New covs; new data*/
%partC( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartC.new_covs_8.8.2022.rtf", 
	inset = ExpertDAG_ag_new, 
	titlemain = 'Adherence at time t: IPW Adjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=cdp, 
		covs_0 = &covs_new, covs_FV = &covsFV , covs_lag = &covs_lag);

	
%let nboot = 500;
/*New covs; old data*/
%partC( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartC.new_covs2_8.15.2022.rtf", 
	inset = ExpertDAG_ag_orig, 
	titlemain = 'Adherence at time t: IPW Adjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=cdp, 
		covs_0 = &covs_new, covs_FV = &covsFV , covs_lag = &covs_lag);

	




/*New covs list, data subset to original dataset + no missingness on new covs*/
%partA_unadjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartA.Unadj.new_data3.rtf", 
		inset = ExpertDAG_wide2, titlemain = "Unadjusted, New data, Missed Adherence = 0", 
		nboot = &nboot, lib = cdp);
%partA_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartA.Adj.linear.new_covs.new_adhbin.test3.rtf", 
	inset =  ExpertDAG_wide2, 
	titlemain = 'Adjusted, New covariates, Missed Adherence = .',  nboot = &nboot, lib=cdp, adhvar = adhx15bin, covs = &covs_new);
%partA_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartA.Adj.linear.new_covs.new_adhbin.test3.rtf", 
	inset =  ExpertDAG_wide2, 
	titlemain = 'Adjusted, New covariates, Missed Adherence = .',  nboot = &nboot, lib=cdp, adhvar = old_adhx15bin, covs = &covs_new);
%partB_unadjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartB.Unadj.new_cov_data3.rtf", 
		inset = ExpertDAG_wide2, titlemain = "Unadjusted, Missed Adherence Carried Forward", 
		nboot = &nboot, lib = cdp);
%partB_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartB.Adj.logistic.new_covs3.rtf", 
	inset =  ExpertDAG_wide2, 
	titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=cdp, adhvar = old_adhx15bin, covs = &covs_new);
%partB_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartB.Adj.logistic.new_covs3.rtf", 
	inset =  ExpertDAG_wide2, 
	titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=cdp, adhvar = adhx15bin, covs = &covs_new);

%partC( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartC.new_covs3.rtf", 
	inset = ExpertDAG_ag_new2, 
	titlemain = 'Adherence at time t: IPW Adjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=cdp, 
		covs_0 = &covs_new, covs_FV = &covsFV , covs_lag = &covs_lag);

		proc contents data = cdp.expertDAG_wide2;
		run;


		%let covs_orig_plus = age_bin nonwhite mi_bin niha_bin1 rbw_bin 
			chf aci ap ic icia dig diur irk antiarr antihyp oralhyp  
			cardiom stelev hifastgluc cig inact anyqqs anystdep 
			anytwave fveb vcd hiheart hisysbp hidiasbp hibili hiserchol  
			hisertrigly hiseruric hiseralk hiplasurea hionegluc hiwhitecell 
			hineut hihemat  diab afib
			occupation1 occupation2 occupation3 occupation4 occupation5
			occupation6 occupation7 occupation8 occupation9
			employ fulltime
			hypertens htmed
			hyperlipid_1 hyperlipid_2 ;
%partA_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartA.Adj.linear.new_covs.new_adhbin.test4.rtf", 
	inset =  ExpertDAG_wide2, 
	titlemain = 'Adjusted, New covariates, Missed Adherence = .',  nboot = &nboot, lib=cdp, adhvar = adhx15bin, covs = &covs_orig_plus);
%partA_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartA.Adj.linear.new_covs.new_adhbin.test4.rtf", 
	inset =  ExpertDAG_wide2, 
	titlemain = 'Adjusted, New covariates, Missed Adherence = .',  nboot = &nboot, lib=cdp, adhvar = old_adhx15bin, covs = &covs_orig_plus);
%partB_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartB.Adj.logistic.new_covs4.rtf", 
	inset =  ExpertDAG_wide2, 
	titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=cdp, adhvar = old_adhx15bin, covs = &covs_orig_plus);
%partB_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartB.Adj.logistic.new_covs4.rtf", 
	inset =  ExpertDAG_wide2, 
	titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=cdp, adhvar = adhx15bin, covs = &covs_orig_plus);


	
%let covs_orig_plus2 =  adhpre0bin age_bin nonwhite irk mi_bin rbw_bin niha_bin0 
		hisysbp0 hidiasbp0 hiwhitecell0 hineut0 hihemat0 hibili0 hiserchol0 
		hisertrigly0 hiseruric0 hiseralk0 hiplasurea0 hifastgluc0 hionegluc0 
		hiheart0 chf0 aci0 ap0 ic0 icia0 dig0 diur0 antiarr0 antihyp0 oralhyp0 
		cardiom0 anyqqs0 anystdep0 anytwave0 stelev0 fveb0 vcd0 cig0 inact0
			occupation1 occupation2 occupation3 occupation4 occupation5
			occupation6 occupation7 occupation8 occupation9
			employ0 fulltime0 
			hypertens0 htmed0
			hyperlipid0_1 hyperlipid0_2 chf0 diab0 
			afib0 ;

%let covs_origFV_plus = 	NIHAFV HiSysBPFV HiDiasBPFV HiWhiteCellFV HiNeutFV HiHematFV	
			HiBiliFV HiSerCholFV HiSerTriglyFV HiSerUricFV HiSerAlkFV
			HiPlasUreaFV HiFastGlucFV HiOneGlucFV HiHeartFV 
			CHFFV ACIFV APFV ICFV ICIAFV DIGFV DIURFV AntiArrFV 
			AntiHypFV OralHypFV CardioMFV AnyQQSFV AnySTDepFV
			AnyTWaveFV STElevFV FVEBFV VCDFV
			CIGFV INACTFV
			employFV fulltimeFV
			hypertensFV htmedFV
			hyperlipidFV_1	hyperlipidFV_2  diabFV 
			afibFV;


%let covs_origlag_plus = nihafv_t1 hisysbpfv_t1 hidiasbpfv_t1 hiwhitecellfv_t1 hineutfv_t1 
		hihematfv_t1 hibilifv_t1 hisercholfv_t1 hisertriglyfv_t1 hiseruricfv_t1 
		hiseralkfv_t1 hiplasureafv_t1 hifastglucfv_t1 hioneglucfv_t1 hiheartfv_t1 chffv_t1
		acifv_t1 apfv_t1 icfv_t1 iciafv_t1 digfv_t1 diurfv_t1 antiarrfv_t1 antihypfv_t1
		oralhypfv_t1 cardiomfv_t1 anyqqsfv_t1 anystdepfv_t1 anytwavefv_t1 stelevfv_t1
		fvebfv_t1 vcdfv_t1 cigfv_t1 inactfv_t1  employFV_t1 fulltimeFV_t1
			hypertensFV_t1 htmedFV_t1
			hyperlipidFV_t1_1	hyperlipidFV_t1_2  diabFV_t1 
			afibFV_t1 
;

%partC( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartC.new_covs4.rtf", 
	inset = ExpertDAG_ag_new2, 
	titlemain = 'Adherence at time t: IPW Adjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=cdp, 
		covs_0 = &covs_orig_plus2, covs_FV = &covs_origFV_plus , covs_lag = &covs_origlag_plus);
