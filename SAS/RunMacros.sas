
/***************************************************/
/* Program RunMacros: Debertin et al 2024          */
/* This program gives the variable names & 	       */
/* macro calls for the analyses using  Maximal DAG */
/***************************************************/

libname cdp "<path>";

%include '<path>\Program3.sas';
%include '<path>\Program4.sas';
%include '<path>\rcspline.sas';

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


/*Example calls for new variable list*/
/*Unadjusted*/
%partB_unadjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartB.Unadj.new_cov_data3.rtf", 
		inset = ExpertDAG_wide2, titlemain = "Unadjusted, Missed Adherence Carried Forward", 
		nboot = &nboot, lib = cdp);

/*Baseline adjusted*/
%partB_adjusted( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartB.Adj.logistic.new_covs3.rtf", 
	inset =  ExpertDAG_wide2, 
	titlemain = 'Adjusted, Missed Adherence Carried Forward',  nboot = &nboot, lib=cdp, adhvar = adhx15bin, covs = &covs_new);

/*Baseline & time-varying adjusted*/
%partC( outdest = "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGopedia\CDP_DAG_Julia\SAS output\PartC.new_covs3.rtf", 
	inset = ExpertDAG_ag_new2, 
	titlemain = 'Adherence at time t: IPW Adjusted, Missed Adherence Carried Forward', nboot = &nboot, lib=cdp, 
		covs_0 = &covs_new, covs_FV = &covsFV , covs_lag = &covs_lag);

