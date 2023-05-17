
/***************************************************/
/**Long format dataset for analysis of**************/
/**Censoring-Weighted Cumulative Adherence**********/
/***************************************************/

/*Convert data into observations for each follow-up visit*/
/*For censoring due to change in missing adherence only*/
/*As with baseline-only analysis, individuals with missing*/
/*covariates over time not censored - covariates carried */
/*forward from last recorded value for censoring weights*/
%macro longdata(datain = , dataout = );

data &dataout;
set &datain;

array adhbin_a(*) 		adhbin0 - adhbin15;
array adh(*)   			adh1-adh16;
array indic(*)			indic0 - indic15;

array NIHA_FV_a(*) 		NIHA_FV0 - NIHA_FV15; 
array HiSysBP_FV_a(*) 		HiSysBP_FV0-HiSysBP_FV15;
array HiDiasBP_FV_a(*)	 	HiDiasBP_FV0-HiDiasBP_FV15 ;
array HiWhiteCell_FV_a(*) 	HiWhiteCell_FV0-HiWhiteCell_FV15;
array HiNeut_FV_a(*)		HiNeut_FV0-HiNeut_FV15; 
array HiHemat_FV_a(*)		HiHemat_FV0-HiHemat_FV15;
array HiBili_FV_a(*)		HiBili_FV0-HiBili_FV15; 
array HiSerChol_FV_a(*)		HiSerChol_FV0-HiSerChol_FV15;
array HiSerTrigly_FV_a(*) 	HiSerTrigly_FV0-HiSerTrigly_FV15;
array HiSerUric_FV_a(*)		HiSerUric_FV0-HiSerUric_FV15;
array HiSerAlk_FV_a(*)		HiSerAlk_FV0-HiSerAlk_FV15; 
array HiPlasUrea_FV_a(*)	HiPlasUrea_FV0-HiPlasUrea_FV15;
array HiFastGluc_FV_a(*)	HiFastGluc_FV0-HiFastGluc_FV15;
array HiOneGluc_FV_a(*) 	HiOneGluc_FV0-HiOneGluc_FV15;
array HiHeart_FV_a(*) 		HiHeart_FV0-HiHeart_FV15;
array CHF_FV_a(*)		CHF_FV0-CHF_FV15;
array ACI_FV_a(*)		ACI_FV0-ACI_FV15;
array AP_FV_a(*)		AP_FV0-AP_FV15;
array IC_FV_a(*)		IC_FV0-IC_FV15;
array ICIA_FV_a(*)		ICIA_FV0-ICIA_FV15;
array DIG_FV_a(*)		DIG_FV0-DIG_FV15;
array DIUR_FV_a(*)		DIUR_FV0-DIUR_FV15;
array AntiArr_FV_a(*)	 	AntiArr_FV0-AntiArr_FV15;
array AntiHyp_FV_a(*)	 	AntiHyp_FV0-AntiHyp_FV15;
array OralHyp_FV_a(*)	 	OralHyp_FV0-OralHyp_FV15;
array CardioM_FV_a(*)	 	CardioM_FV0 - CardioM_FV15;
array AnyQQS_FV_a(*)		AnyQQS_FV0-AnyQQS_FV15; 
array AnySTDep_FV_a(*)		AnySTDep_FV0-AnySTDep_FV15;
array AnyTwave_FV_a(*)		AnyTwave_FV0-AnyTwave_FV15;
array STElev_FV_a(*)		STElev_FV0-STElev_FV15;
array FVEB_FV_a(*)		FVEB_FV0-FVEB_FV15;
array VCD_FV_a(*)		VCD_FV0-VCD_FV15;
array CIG_FV_a(*)		CIG_FV0 - CIG_FV15;
array INACT_FV_a(*)		INACT_FV0-INACT_FV15;

/*NEW COVARIATES*/
array EMPLOY_FV_a(*)	EMPLOY_FV0 - EMPLOY_FV15;
array FULLTIME_FV_a(*) 	FULLTIME_FV0 - FULLTIME_FV15;
array HYPERTENS_FV_a(*) HYPERTENS_FV0 - HYPERTENS_FV15;
array HTMED_FV_a(*)		HTMED_FV0 - HTMED_FV15;
array HYPERLIPID_FV_a(*) HYPERLIPID_FV0 - HYPERLIPID_FV15;
array DIAB_FV_a(*)		DIAB_FV0 - DIAB_FV15;
array AFIB_FV_a(*)		AFIB_FV0 - AFIB_FV15;


do i = 1 to 15;

	ind = indic(i);

	visit = i-1; /*visit number: 0 = baseline, 1 = FV1, etc*/
	
	if i < 4 then do;
		if invdth = 0 then do;
			cens = -1;
			p_cens0 = 1;

			adhr_t = adhbin_a(i);

			death = 0;

			if i ge 2 then adhr_t1 = adhbin_a(i-1);
			if i ge 3 then adhr_t2 = adhbin_a(i-2);
		end;

		else if i > invdth then do;
			cens = .; 
			p_cens0 = .;
			adhr_t = .;
			death = .;
		end;
		else if i le invdth then do;
			cens = -1;
			p_cens0 = 1; 
	
			adhr_t = adhbin_a(i);

			if invdth = i then death = 1;	
			else if  invdth > i then death = 0;
			
			if death in (0,1) then do;
				if i ge 2 then adhr_t1 = adhbin_a(i-1);
				if i ge 3 then adhr_t2 = adhbin_a(i-2);
			end;
		end;
	end;

	else if i ge 4 then do;
		if indic(i) = 0 	then do; 
			cens = -1; 
			p_cens0 = 1; 

			if invdth = i then death = 1;	
			else if invdth = 0 or invdth > i then death = 0;
		end;
		else if indic(i) = 1 	then do; 
			if adh(i) = .       then cens = 1; 
			else if adh(i) ne . then cens = 0;
			p_cens0 = .; 
		end;
		else if indic(i) = . 	then do; 
			cens = .; 
			p_cens0 = .; 
			death = .;
		end;
		
		/*current and baseline adherence*/
		if death in (0,1) then do;		
			adhr_t  = adhbin_a(i);

			adhr_t1 = adhbin_a(i-1);
			adhr_t2 = adhbin_a(i-2);
			adhr_t3 = adhbin_a(i-3);					
		end;
		else if death = . then do;
			adhr_t = .; 
			
			adhr_t1 = .;
			adhr_t2 = .;
			adhr_t3 = .;
		end;
	end;

	/*if death = 1 and i > 1 then adhr_t = adhbin_a(i-1);*/
	
	if death in (0,1) then do;	
		if adhr_t = . then adh_measure = 0;
		else if adhr_t ne . then adh_measure = 1;
	end;
	else if death = . then adh_measure = .;

	/*Save covariates for visit i*/
	NIHA_bin0 = NIHA_FV0;
	NIHAFV = NIHA_FV_a(i);
	if i > 1 then NIHAFV_t1 = NIHA_FV_a(i-1);	else NIHAFV_t1 = NIHA_bin0;
	if i > 2 then do;
		if NIHAFV_t1 = . then NIHAFV_t1 = NIHA_FV_a(i-2);
	end;
	if i > 3 then do;
		if NIHAFV_t1 = . then NIHAFV_t1 = NIHA_FV_a(i-3);
	end;

	CHF0 = CHF_FV0;	
	ACI0 = ACI_FV0;
	AP0 = AP_FV0;
	IC0 = IC_FV0;
	ICIA0 = ICIA_FV0;
	
	CHFFV = CHF_FV_a(i);
	ACIFV = ACI_FV_a(i);
	APFV = AP_FV_a(i);
	ICFV = IC_FV_a(i);
	ICIAFV = ICIA_FV_a(i);

	if i > 1 then CHFFV_t1 = CHF_FV_a(i-1); 	else CHFFV_t1 = CHF0;
	if i > 1 then ACIFV_t1 = ACI_FV_a(i-1);		else ACIFV_t1 = ACI0;
	if i > 1 then APFV_t1 = AP_FV_a(i-1);		else APFV_t1 = AP0;
	if i > 1 then ICFV_t1 = IC_FV_a(i-1);		else ICFV_t1 = IC0;
	if i > 1 then ICIAFV_t1 = ICIA_FV_a(i-1);	else ICIAFV_t1 = ICIA0;

	if i > 2 then do;	
		if CHFFV_t1 = . then CHFFV_t1 = CHF_FV_a(i-2);
		if ACIFV_t1 = . then ACIFV_t1 = ACI_FV_a(i-2);
		if APFV_t1  = . then APFV_t1 = AP_FV_a(i-2);
		if ICFV_t1  = . then ICFV_t1 = IC_FV_a(i-2);
		if ICIAFV_t1 = . then ICIAFV_t1 = ICIA_FV_a(i-2);
	end;

	DIG0 = DIG_FV0;
	DIUR0 = DIUR_FV0;
	AntiArr0 = AntiARR_FV0;
	AntiHyp0 = AntiHyp_FV0;
	OralHyp0 = OralHyp_FV0;

	DIGFV = DIG_FV_a(i);
	DIURFV = DIUR_FV_a(i);
	AntiArrFV = AntiARR_FV_a(i);
	AntiHypFV = AntiHyp_FV_a(i);
	OralHypFV = OralHyp_FV_a(i);

	if i > 1 then DIGFV_t1 = DIG_FV_a(i-1);			else DigFV_t1 = DIG0;
	if i > 1 then DIURFV_t1 = DIUR_FV_a(i-1);		else DiurFV_t1 = DIUR0;
	if i > 1 then AntiArrFV_t1 = AntiARR_FV_a(i-1);		else AntiArrFV_t1 = AntiArr0;
	if i > 1 then AntiHypFV_t1 = AntiHyp_FV_a(i-1);		else AntiHypFV_t1 = AntiHyp0;
	if i > 1 then OralHypFV_t1 = OralHyp_FV_a(i-1);		else OralHypFV_t1 = OralHyp0;	
		
	if i > 2 then do;
		if DIGFV_t1 = . then DIGFV_t1 = DIG_FV_a(i-2);
		if DIURFV_t1 = . then DIURFV_t1 = DIUR_FV_a(i-2);
		if AntiArrFV_t1  = . then AntiArrFV_t1 = AntiARR_FV_a(i-2);
		if AntiHypFV_t1  = . then AntiHypFV_t1 = AntiHyp_FV_a(i-2);
		if OralHypFV_t1 = . then OralHypFV_t1 = OralHyp_FV_a(i-2);
	end;
	

	CardioM0 = CardioM_FV0;
	CardioMFV = CardioM_FV_a(i);
	if i > 1 then CardioMFV_t1 = CardioM_FV_a(i-1);		else CardioMFV_t1 = CardioM0;
	if i > 2 then do;
		if CardioMFV_t1 = . then CardioMFV_t1 = CardioM_FV_a(i-2);
	end;	

	AnyQQS0 = AnyQQS_FV0;
	AnySTDep0 = AnySTDep_FV0;
	AnyTWave0 = AnyTWave_FV0;
	STElev0 = STElev_FV0;
	FVEB0 = FVEB_FV0;
	VCD0 = VCD_FV0;
	HiHeart0 = HiHeart_FV0;

	AnyQQSFV = AnyQQS_FV_a(i);
	AnySTDepFV = AnySTDep_FV_a(i);
	AnyTWaveFV = AnyTWave_FV_a(i);
	STElevFV = STElev_FV_a(i);
	FVEBFV = FVEB_FV_a(i);
	VCDFV = VCD_FV_a(i);
	HiHeartFV = HiHeart_FV_a(i);

	if i > 1 then AnyQQSFV_t1 = AnyQQS_FV_a(i-1);		else AnyQQSFV_t1 = AnyQQS0;
	if i > 1 then AnySTDepFV_t1 = AnySTDep_FV_a(i-1);	else AnyStDepFV_t1 = AnyStDep0;
	if i > 1 then AnyTWaveFV_t1 = AnyTWave_FV_a(i-1);	else AnyTWaveFV_t1 = AnyTWave0;
	if i > 1 then STElevFV_t1 = STElev_FV_a(i-1);		else StElevFV_t1 = StElev0;
	if i > 1 then FVEBFV_t1 = FVEB_FV_a(i-1);		else FVEBFV_t1 = FVEB0;
	if i > 1 then VCDFV_t1 = VCD_FV_a(i-1);			else VCDFV_t1 = VCD0;
	if i > 1 then HiHeartFV_t1 = HiHeart_FV_a(i-1);		else HiHeartFV_t1 = HiHeart0;

	if i > 2 then do;
		if AnyQQSFV_t1 = . then AnyQQSFV_t1 = AnyQQS_FV_a(i-2);
		if AnySTDepFV_t1 = . then AnySTDepFV_t1 = AnySTDep_FV_a(i-2);
		if AnyTWaveFV_t1 = . then AnyTWaveFV_t1 = AnyTWave_FV_a(i-2);
		if STElevFV_t1 	= . then STElevFV_t1 = STElev_FV_a(i-2);
		if FVEBFV_t1 	= . then  FVEBFV_t1 = FVEB_FV_a(i-2);
		if VCDFV_t1	= . then  VCDFV_t1 = VCD_FV_a(i-2);
		if HiHeartFV_t1 = . then  HiHeartFV_t1 = HiHeart_FV_a(i-2);
	end;

	HiBili0 = HiBili_FV0;
	HiSerChol0 = HiSerChol_FV0;
	HiSerTrigly0 = HiSerTrigly_FV0;
	HiSerUric0 = HiSerUric_FV0;	
	HiSerAlk0 = HiSerAlk_FV0;
	HiPlasUrea0 = HiPlasUrea_FV0;
	HiFastGluc0 = HiFastGluc_FV0;
	HiOneGluc0 = HiOneGluc_FV0;

	HiBiliFV = HiBili_FV_a(i);
	HiSerCholFV = HiSerChol_FV_a(i);
	HiSerTriglyFV = HiSerTrigly_FV_a(i);
	HiSerUricFV = HiSerUric_FV_a(i);
	HiSerAlkFV = HiSerAlk_FV_a(i);
	HiPlasUreaFV = HiPlasUrea_FV_a(i);
	HiFastGlucFV = HiFastGluc_FV_a(i);
	HiOneGlucFV = HiOneGluc_FV_a(i);

	if i > 1 then HiBiliFV_t1 = HiBili_FV_a(i-1);		else HiBiliFV_t1 = HiBili0;
	if i > 1 then HiSerCholFV_t1 = HiSerChol_FV_a(i-1);	else HiSerCholFV_t1 = HiSerChol0;
	if i > 1 then HiSerTriglyFV_t1 = HiSerTrigly_FV_a(i-1);	else HiSerTriglyFV_t1 = HiSerTrigly0;
	if i > 1 then HiSerUricFV_t1 = HiSerUric_FV_a(i-1);	else HiSerUricFV_t1 = HiSerUric0;
	if i > 1 then HiSerAlkFV_t1 = HiSerAlk_FV_a(i-1);	else HiSerAlkFV_t1 = HiSerAlk0;
	if i > 1 then HiPlasUreaFV_t1 = HiPlasUrea_FV_a(i-1);	else HiPlasUreaFV_t1 = HiPlasUrea0;
	if i > 1 then HiFastGlucFV_t1 = HiFastGluc_FV_a(i-1);	else HiFastGlucFV_t1 = HiFastGluc0;
	if i > 1 then HiOneGlucFV_t1 = HiOneGluc_FV_a(i-1);	else HiOneGlucFV_t1 = HiOneGluc0;

	if i > 2 then do;
		if HiBiliFV_t1 = . then HiBiliFV_t1 = HiBili_FV_a(i-2);
		if HiSerCholFV_t1 = . then HiSerCholFV_t1 = HiSerChol_FV_a(i-2);
		if HiSerTriglyFV_t1 = . then HiSerTriglyFV_t1 = HiSerTrigly_FV_a(i-2);
		if HiSerUricFV_t1 = . then HiSerUricFV_t1 = HiSerUric_FV_a(i-2);
		if HiSerAlkFV_t1 = . then  HiSerAlkFV_t1 = HiSerAlk_FV_a(i-2);
		if HiPlasUreaFV_t1 = . then  HiPlasUreaFV_t1 = HiPlasUrea_FV_a(i-2);
		if HiFastGlucFV_t1 = . then  HiFastGlucFV_t1 = HiFastGluc_FV_a(i-2);
		if HiOneGlucFV_t1 = . then  HiOneGlucFV_t1 = HiOneGluc_FV_a(i-2);
	end;

	HiSysBP0 = HiSysBP_FV0;
	HiDiasBP0 = HiDiasBP_FV0;

	HiSysBPFV = HiSysBP_FV_a(i);
	HiDiasBPFV = HiDiasBP_FV_a(i);

	if i > 1 then HiSysBPFV_t1 = HiSysBP_FV_a(i-1);		else HiSysBPFV_t1 = HiSysBP0;
	if i > 1 then HiDiasBPFV_t1 = HiDiasBP_FV_a(i-1);	else HiDiasBPFV_t1 = HiDiasBP0;

	if i > 2 then do;
		if HiSysBPFV_t1  = . then HiSysBPFV_t1 = HiSysBP_FV_a(i-2);
		if HiDiasBPFV_t1 = . then  HiDiasBPFV_t1 = HiDiasBP_FV_a(i-2);
	end;

	CIG0 = CIG_FV0;
	INACT0 = INACT_FV0;	

	CIGFV = CIG_FV_a(i);
	INACTFV = INACT_FV_a(i);

	if i > 1 then CIGFV_t1 = CIG_FV_a(i-1); 	else CIGFV_t1 = CIG0;
	if i > 1 then INACTFV_t1 = INACT_FV_a(i-1); 	else InactFV_t1 = Inact0;

	if i > 2 then do;
		if CIGFV_t1 = . then CIGFV_t1 = CIG_FV_a(i-2);
		if INACTFV_t1 = . then INACTFV_t1 = INACT_FV_a(i-2);
	end;

	HiWhiteCell0 = HiWhiteCell_FV0;
	HiNeut0 	= HiNeut_FV0;
	HiHemat0 	= HiHemat_FV0;

	HiWhiteCellFV = HiWhiteCell_FV_a(i);
	HiNeutFV 	= HiNeut_FV_a(i);
	HiHematFV	= HiHemat_FV_a(i);

	if i > 1 then HiWhiteCellFV_t1 = HiWhiteCell_FV_a(i-1); else HiWhiteCellFV_t1 = HiWhiteCell0;
	if i > 1 then HiNeutFV_t1 = HiNeut_FV_a(i-1);  	else HiNeutFV_t1 = HiNeut0;
	if i > 1 then HiHematFV_t1 = HiHemat_FV_a(i-1); 		else HiHematFV_t1 = HiHemat0;

	if i > 2 then do;
		if HiWhiteCellFV_t1 = . then HiWhiteCellFV_t1 = HiWhiteCell_FV_a(i-2);
		if HiNeutFV_t1 = . then HiNeutFV_t1 = HiNeut_FV_a(i-2);
		if HiHematFV_t1 = . then HiHematFV_t1 = HiHemat_FV_a(i-2);
	end;	

/*NEW COVARIATES*/

	EMPLOY0 = EMPLOY_FV0;
	FULLTIME0 = FULLTIME_FV0;	
	HYPERTENS0 = HYPERTENS_FV0;	
	HTMED0 = HTMED_FV0;	
	HYPERLIPID0 = HYPERLIPID_FV0;	
	DIAB0 = DIAB_FV0;	
	AFIB0 = AFIB_FV0;	
	
	EMPLOYFV = EMPLOY_FV_a(i);
	FULLTIMEFV = FULLTIME_FV_a(i);	
	HYPERTENSFV = HYPERTENS_FV_a(i);	
	HTMEDFV = HTMED_FV_a(i);	
	HYPERLIPIDFV = HYPERLIPID_FV_a(i);	
	DIABFV = DIAB_FV_a(i);	
	AFIBFV = AFIB_FV_a(i);	


	if i > 1 then EMPLOYFV_t1 = EMPLOY_FV_a(i-1); 	else EMPLOYFV_t1 = EMPLOY0;
	if i > 1 then FULLTIMEFV_t1 = FULLTIME_FV_a(i-1); 	else FULLTIMEFV_t1 = FULLTIME0;
	if i > 1 then HYPERTENSFV_t1 = HYPERTENS_FV_a(i-1); 	else HYPERTENSFV_t1 = HYPERTENS0;
	if i > 1 then HTMEDFV_t1 = HTMED_FV_a(i-1); 	else HTMEDFV_t1 = HTMED0;
	if i > 1 then HYPERLIPIDFV_t1 = HYPERLIPID_FV_a(i-1); 	else HYPERLIPIDFV_t1 = HYPERLIPID0;
	if i > 1 then DIABFV_t1 = DIAB_FV_a(i-1); 	else DIABFV_t1 = DIAB0;
	if i > 1 then AFIBFV_t1 = AFIB_FV_a(i-1); 	else AFIBFV_t1 = AFIB0;

	if i > 2 then do;
		if EMPLOYFV_t1 = . then EMPLOYFV_t1 = EMPLOY_FV_a(i-2);
		if FULLTIMEFV_t1 = . then FULLTIMEFV_t1 = FULLTIME_FV_a(i-2);
		if HYPERTENSFV_t1 = . then HYPERTENSFV_t1 = HYPERTENS_FV_a(i-2);
		if HTMEDFV_t1 = . then HTMEDFV_t1 = HTMED_FV_a(i-2);
		if HYPERLIPIDFV_t1 = . then HYPERLIPIDFV_t1 = HYPERLIPID_FV_a(i-2);
		if DIABFV_t1 = . then DIABFV_t1 = DIAB_FV_a(i-2);	
		if AFIBFV_t1 = . then AFIBFV_t1 = AFIB_FV_a(i-2);
	end;



	keep ID istat visit dth5 invdth 
	Adhx15Bin itr entrydate death

 	adhbin0  adhr_t adhr_t1 adhr_t2 adhr_t3 cens p_cens0  adh_measure
	
	adh1-adh16 adhbin0-adhbin15 indic0 - indic15 ind

	adhpre0bin age_bin nonwhite IRK MI_bin RBW_bin age_cat

			NIHA_bin0 HiSysBP0 HiDiasBP0 HiWhiteCell0 HiNeut0 HiHemat0 	
			HiBili0 HiSerChol0 HiSerTrigly0 HiSerUric0 HiSerAlk0 HiPlasUrea0 
			HiFastGluc0 HiOneGluc0 HiHeart0 CHF0 ACI0 AP0
			IC0 ICIA0 DIG0 DIUR0 AntiArr0 AntiHyp0 OralHyp0 
			CardioM0 AnyQQS0 AnySTDep0 AnyTWave0
			STElev0 FVEB0 VCD0 CIG0 INACT0
		
			NIHAFV HiSysBPFV HiDiasBPFV HiWhiteCellFV HiNeutFV HiHematFV	
			HiBiliFV HiSerCholFV HiSerTriglyFV HiSerUricFV HiSerAlkFV
			HiPlasUreaFV HiFastGlucFV HiOneGlucFV HiHeartFV 
			CHFFV ACIFV APFV ICFV ICIAFV DIGFV DIURFV AntiArrFV 
			AntiHypFV OralHypFV CardioMFV AnyQQSFV AnySTDepFV
			AnyTWaveFV STElevFV FVEBFV VCDFV
			CIGFV INACTFV 

			NIHAFV_t1 HiSysBPFV_t1 HiDiasBPFV_t1 HiWhiteCellFV_t1 HiNeutFV_t1 HiHematFV_t1 	
			HiBiliFV_t1 HiSerCholFV_t1 HiSerTriglyFV_t1 HiSerUricFV_t1 HiSerAlkFV_t1 
			HiPlasUreaFV_t1 HiFastGlucFV_t1 HiOneGlucFV_t1 HiHeartFV_t1 
			CHFFV_t1 ACIFV_t1 APFV_t1 ICFV_t1 ICIAFV_t1 DIGFV_t1 DIURFV_t1 AntiArrFV_t1 
			AntiHypFV_t1 OralHypFV_t1 CardioMFV_t1 AnyQQSFV_t1 AnySTDepFV_t1 
			AnyTWaveFV_t1 STElevFV_t1 FVEBFV_t1 VCDFV_t1
			CIGFV_t1 INACTFV_t1 

/*NEW COVARIATES*/
	OCCUPATION 
	EMPLOY0 FULLTIME0 HYPERTENS0 HTMED0 HYPERLIPID0 DIAB0 AFIB0 	
	EMPLOYFV FULLTIMEFV HYPERTENSFV HTMEDFV HYPERLIPIDFV DIABFV AFIBFV 
	EMPLOYFV_t1 FULLTIMEFV_t1 HYPERTENSFV_t1 HTMEDFV_t1 HYPERLIPIDFV_t1 DIABFV_t1 AFIBFV_t1 
;

output;
end;
run;

%mend;

%macro delete_postDeath(data = );
PROC FREQ DATA =  &data;
TABLES DEATH / LIST MISSING;
RUN;
proc freq data =  &data nlevels;
tables ID /noprint;
title 'Before exclusion of post-death time-points';
run;

data &data;
	set &data;
	if death ne . then output;
run;


PROC FREQ DATA =  &data;
TABLES DEATH / LIST MISSING;
RUN;

proc freq data =  &data nlevels;
tables ID /noprint;
title 'After exclusion of post-death time-points';
title2 'Number of IDs should match pre-exclusion value';
run;
%mend;

%longdata(datain=cdp.ExpertDAG_wide_orig, dataout = cdp.ExpertDAG_ag_orig);
%delete_postDeath(data =cdp.ExpertDAG_ag_orig );

%longdata(datain=cdp.ExpertDAG_wide, dataout = cdp.ExpertDAG_ag_new);
%delete_postDeath(data =cdp.ExpertDAG_ag_new);

%longdata(datain=cdp.ExpertDAG_wide_subset, dataout = cdp.ExpertDAG_ag_subset);
%delete_postDeath(data =cdp.ExpertDAG_ag_subset);


%longdata(datain=cdp.ExpertDAG_wide2, dataout = cdp.ExpertDAG_ag_new2);
%delete_postDeath(data =cdp.ExpertDAG_ag_new2);
