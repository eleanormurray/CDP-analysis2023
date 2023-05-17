libname cdp 'C:\Users\ejmurray\Dropbox\ProjectManagement\Trials\CDP\CDP_paper_final';

data cdp.expertDAG;
set cdp.allcdp_new;
where itr = 6;  /*ITR = 6 is placebo arm. */

keep 
/*treatment group and administrative variables*/
ID ITR INV1--INV24 INV28 INVCV1-INVCV3 LVA LV5 LV6 LVSS ENTRYDATE ENDDATE DEATHDATE

/*exposures*/
ICAP1--ICAP26 ICAPQ1 ICAPQ2 IADH1--IADH26
ADHX15  ADH1--ADH52 CAPS1--CAPS26 JADH1-JADH2

/*outcomes*/
DTH5 ISTAT ITS ITD INVDTH ITDX

/*covariates from NEJM paper*/
IAGE IRC NMI LMI ZLABB1 ZLABB4 
ZLABB5 ZLABB6 ZLABB7 ZLABB8 ZLABB9 
ZLABB10 WTBP61 WTBP32 RBW WBC23 
WBC1 WBC12 IRK NIHA1 
KLIN1 KLIN2 KLIN3 KLIN5 KLIN7

IMDCT58 IMDCT114 IMDCT86 IMDCT142 IMDCT30 
IXRAY1 IXRAY12 ICG1 IJOB34 IECG2 
IECG14 IECG26 IECG38 IECG50 IECG62
IECG74 IECG86 IECG98 IECG110 IECG122 
IECG134 IECG206 IECG194 IECG278

ZLAB88 ZLAB89 ZLAB90 

/*Longitudinal variables for time-varying adherence analyses*/
NIHA1-NIHA6 ICG1-ICG6 WTBP32-WTBP47 WTBP61-WTBP76
IJOB34-IJOB39 IXRAY1-IXRAY22 WBC1-WBC33 IMDCT30-IMDCT45 
IMDCT58-IMDCT73 IMDCT86-IMDCT101 IMDCT114-IMDCT129 
IMDCT142-IMDCT157 ICCL1-ICCL15 ZLAB4-ZLAB18 ZLAB91--ZLAB116 
ZLAB120-ZLAB134 ZLAB149-ZLAB163 ZLAB178-ZLAB192 

ZLAB207-ZLAB221 ZLAB236-ZLAB250 ZLAB265-ZLAB279
IECG1-IECG283

/*NEW COVARIATES FROM EXPERT CONSENSUS*/
IOC /*occupational category -- 9 levels ordinal*/
IJOB1-IJOB6 IJOB12-IJOB17 IJOB23-IJOB28 /*Employment & physical activity / nature of work*/
ISUM21-ISUM25 ISUM31-ISUM35 IMDCT113-IMDCT114 IMDCT141-IMDCT142/*Hypertension & hypertension treatment*/
IDB1-IDB5 IDB21/*Diabetes*/
ICCL365-ICCL379 IRHY1-IRHY3; /*Atrial fibrilation & baseline heart rhythm*/


/***Demographic & Baseline-Only Variables****/
age_bin = .;
if iage ge 55 then age_bin = 1;
else if .< iage <55 then age_bin = 0;

age_cat = .;
if .< iage <45 then age_cat =0;
else if 45 le iage < 50 then age_cat = 1;
else if 50 le iage < 55 then age_cat = 2;
else if 55 le iage < 60 then age_cat = 3;
else if 60 le iage  then age_cat = 4;

nonwhite = .;
if irc = 1 then nonwhite = 0;
else if irc in (2,3) then nonwhite = 1;

mi_bin = .;
if NMI ge 2 then mi_bin = 1;
else if .< NMI <2 then mi_bin = 0;

rbw_bin = .;
if RBW ge 1.15 then rbw_bin = 1;
else if . < RBW < 1.15 then rbw_bin = 0;



keep  age_cat age_bin nonwhite mi_bin rbw_bin occupation;


/***Time-varying Covariates*****************/

/*For annual variables, code assigns most recent annual visit to subsequent 2 non-annual follow-up visits*/
/*For any missing data, carry forward up to 2 consecutive missed visits - censor on third consecutive missed visit*/
/*Where necessary, set invalid response levels to missing*/

/*New York Heart Association Risk group: 1 v 2 at baseline; 1 v (2,3,4) over follow-up*/
array NIHA_FV(17) NIHA_FV1 - NIHA_FV17;
array NIHA(6) NIHA1 - NIHA6;
array NIHA_bin(6) NIHA_bin1 - NIHA_bin6;
do i = 1 to 6;
	if NIHA(i) = 1 then NIHA_bin(i) = 0;
	else if NIHA(i) = 9 then do; 
		NIHA(i) = . ;
		NIHA_bin(i) = .;
		end;
	else if NIHA(i) >1 then NIHA_bin(i) = 1;
	end;
NIHA_FV0 = NIHA_bin1;
NIHA_FV1 = NIHA_bin1;
NIHA_FV2 = NIHA_bin1;
do i = 2 to 6;
	if NIHA_bin(i) ne . then do;
		NIHA_FV((i-1)*3) = NIHA_bin(i);
		NIHA_FV((i-1)*3+1) = NIHA_bin(i);
		NIHA_FV((i-1)*3+2) = NIHA_bin(i);
		end;
	else do;
		NIHA_FV((i-1)*3) = .;
		NIHA_FV((i-1)*3+1) = .;
		NIHA_FV((i-1)*3+2) = .;
		end;
	end;

keep NIHA_FV0-NIHA_FV15 NIHA_bin1;



/*Clinical history variables: 0=no, 1=suspect or definite; baseline and follow-up*/
array KLIN1_FV(15) KLIN1_FV1-KLIN1_FV15;
array KLIN2_FV(15) KLIN2_FV1-KLIN2_FV15;
array KLIN3_FV(15) KLIN3_FV1-KLIN3_FV15;
array KLIN5_FV(15) KLIN5_FV1-KLIN5_FV15;
array KLIN7_FV(15) KLIN7_FV1-KLIN7_FV15;
array ICCL(75) 	ICCL1-ICCL15
		ICCL27-ICCL41
		ICCL53-ICCL67
		ICCL157-ICCL171
		ICCL235-ICCL249;
KLIN1_FV0 = KLIN1;
KLIN2_FV0 = KLIN2;
KLIN3_FV0 = KLIN3;
KLIN5_FV0 = KLIN5;
KLIN7_FV0 = KLIN7;
do i=1 to 15;
	if ICCL(i) ne . 			then KLIN1_FV(i) = ICCL(i);
	else if i = 1 				then KLIN1_FV(i) = KLIN1_FV0;
	else if i = 2 and ICCL(i-1) ne . 	then KLIN1_FV(i) = KLIN1_FV1;
	else if i >2 then do;
		if ICCL(i-1) ne . 		then KLIN1_FV(i) = KLIN1_FV(i-1);
		else if ICCL(i-2) ne . 		then KLIN1_FV(i) = KLIN1_FV(i-2);
		else if ICCL(i-2) = . 		then KLIN1_FV(i) = .;
	end;
end;
do i=16 to 30;
	if ICCL(i) ne . 			then KLIN2_FV(i-15) = ICCL(i);
	else if i =16 				then KLIN2_FV(i-15) = KLIN2_FV0;
	else if i =17 and ICCL(i-1) ne . 	then KLIN2_FV(i-15) = KLIN2_FV1;
	else if i >17 then do;
		if ICCL(i-1) ne . 		then KLIN2_FV(i-15) = KLIN2_FV(i-16);
		else if ICCL(i-2) ne .		then KLIN2_FV(i-15) = KLIN2_FV(i-17);
		else if ICCL(i-2) = . 		then KLIN2_FV(i-15) = .;
	end;
end;
do i=31 to 45;
	if ICCL(i) ne . 			then KLIN3_FV(i-30) = ICCL(i);
	else if i =31 				then KLIN3_FV(i-30) = KLIN3_FV0;
	else if i =32 and ICCL(i-1) ne . 	then KLIN3_FV(i-30) = KLIN3_FV1;
	else if i >32 then do;
		if ICCL(i-1) ne . 		then KLIN3_FV(i-30) = KLIN3_FV(i-31);
		else if ICCL(i-2) ne . 		then KLIN3_FV(i-30) = KLIN3_FV(i-32);
		else if ICCL(i-2) = . 		then KLIN3_FV(i-30) = .;
	end;
end;
do i=46 to 60;
	if ICCL(i) ne . 			then KLIN5_FV(i-45) = ICCL(i);
	else if i =46 				then KLIN5_FV(i-45) = KLIN5_FV0;
	else if i =47 and ICCL(i-1) ne . 	then KLIN5_FV(i-45) = KLIN5_FV1;
	else if i >47 then do;
		if ICCL(i-1) ne . 		then KLIN5_FV(i-45) = KLIN5_FV(i-46);
		else if ICCL(i-2) ne .		then KLIN5_FV(i-45) = KLIN5_FV(i-47);
		else if ICCL(i-2) = . 		then KLIN5_FV(i-45) = .;
	end;
end;
do i=61 to 75;
	if ICCL(i) ne . 			then KLIN7_FV(i-60) = ICCL(i);
	else if i =61 				then KLIN7_FV(i-60) = KLIN7_FV0;
	else if i =62 and ICCL(i-1) ne . 	then KLIN7_FV(i-60) = KLIN7_FV1;
	else if i >62 then do;
		if ICCL(i-1) ne . 		then KLIN7_FV(i-60) = KLIN7_FV(i-61);
		else if ICCL(i-2) ne . 		then KLIN7_FV(i-60) = KLIN7_FV(i-62);
		else if ICCL(i-2) = . 		then KLIN7_FV(i-60) = .;
	end;
end;

CHF = .;
if KLIN1 = 2 		then CHF = 0;
if KLIN1 in (1,3)	then CHF = 1;
ACI =.;
if KLIN3 = 2 		then ACI = 0;
if KLIN3 in (1, 3) 	then ACI = 1;
AP =.;
if KLIN2 = 2 		then AP = 0;
if KLIN2 in (1,3) 	then AP = 1;
IC =.;
if KLIN7 = 2 		then IC = 0;
if KLIN7 in (1,3)	then IC = 1;
ICIA=.;
if KLIN5 = 2 		then ICIA = 0;
if KLIN5  in (1,3)	then ICIA = 1;
keep CHF ACI AP IC ICIA;

array CHF_FV(15) CHF_FV1 - CHF_FV15;
CHF_FV0 = CHF;
do i = 1 to 15;
	if KLIN1_FV(i) = 2 then CHF_FV(i) = 0;
	if KLIN1_FV(i) in (1,3) then CHF_FV(i) = 1;
	end;
array ACI_FV(15) ACI_FV1 - ACI_FV15;
ACI_FV0 = ACI;
do i = 1 to 15;
	if KLIN3_FV(i) = 2 then ACI_FV(i) = 0;
	if KLIN3_FV(i) in (1,3) then ACI_FV(i) = 1;
	end;
array AP_FV(15) AP_FV1 - AP_FV15;
AP_FV0 = AP;
do i = 1 to 15;
	if KLIN2_FV(i) = 2 then AP_FV(i) = 0;
	if KLIN2_FV(i) in (1,3) then AP_FV(i) = 1;
	end;
array IC_FV(15) IC_FV1 - IC_FV15;
IC_FV0 = IC;
do i = 1 to 15;
	if KLIN7_FV(i) = 2 then IC_FV(i) = 0;
	if KLIN7_FV(i) in (1,3) then IC_FV(i) = 1;
	end;
array ICIA_FV(15) ICIA_FV1 - ICIA_FV15;
ICIA_FV0 = ICIA;
do i = 1 to 15;
	if KLIN5_FV(i) = 2 then ICIA_FV(i) = 0;
	if KLIN5_FV(i) in (1,3) then ICIA_FV(i) = 1;
	end;
keep CHF_FV0-CHF_FV15 ACI_FV0-ACI_FV15 AP_FV0-AP_FV15 IC_FV0-IC_FV15 ICIA_FV0-ICIA_FV15;




/*Medication use variables: 0 = no, 1 = yes; baseline and follow-up*/
array IMDCT(80) IMDCT30-IMDCT45 			
				IMDCT58-IMDCT73				
				IMDCT86-IMDCT101			
				IMDCT114-IMDCT129			
				IMDCT142-IMDCT157;	
array IMDCT30_FV(17) IMDCT30_FV1-IMDCT30_FV17;
array IMDCT58_FV(17) IMDCT58_FV1-IMDCT58_FV17;
array IMDCT86_FV(17) IMDCT86_FV1-IMDCT86_FV17;
array IMDCT114_FV(17) IMDCT114_FV1-IMDCT114_FV17;
array IMDCT142_FV(17) IMDCT142_FV1-IMDCT142_FV17;
do i = 1 to 80;
	if IMDCT(i) =0 then IMDCT(i)=.;
	end;
IMDCT30_FV0 = IMDCT30;
IMDCT58_FV0 = IMDCT58;
IMDCT86_FV0 = IMDCT86;
IMDCT114_FV0 = IMDCT114;
IMDCT142_FV0 = IMDCT142;
do i=2 to 16;
	if  IMDCT(i) ne . 			then IMDCT30_FV(i-1) = IMDCT(i);
	else if i = 2 				then IMDCT30_FV(i-1) = IMDCT30_FV0;
	else if i = 3 and IMDCT(i-1) ne . 	then IMDCT30_FV(i-1) = IMDCT30_FV1;
	else if i > 3 then do;	
		if IMDCT(i-1) ne . 		then IMDCT30_FV(i-1) = IMDCT30_FV(i-2);
		else if IMDCT(i-2) ne . 	then IMDCT30_FV(i-1) = IMDCT30_FV(i-3);
		else if IMDCT(i-2) = . 		then IMDCT30_FV(i-1) = .;
	end;
end;
do i=18 to 32;
	if  IMDCT(i) ne . 			then IMDCT58_FV(i-17) = IMDCT(i);
	else if i = 18 				then IMDCT58_FV(i-17) = IMDCT58_FV0;
	else if i = 19 and IMDCT(i-1) ne . 	then IMDCT58_FV(i-17) = IMDCT58_FV1;
	else if i > 19 then do;	
		if IMDCT(i-1) ne . 		then IMDCT58_FV(i-17) = IMDCT58_FV(i-18);
		else if IMDCT(i-2) ne . 	then IMDCT58_FV(i-17) = IMDCT58_FV(i-19);
		else if IMDCT(i-2) = . 		then IMDCT58_FV(i-17) = .;
	end;
end;
do i=34 to 48;
	if  IMDCT(i) ne . 			then IMDCT86_FV(i-33) = IMDCT(i);
	else if i = 34 				then IMDCT86_FV(i-33) = IMDCT86_FV0;
	else if i = 35 and IMDCT(i-1) ne . 	then IMDCT86_FV(i-33) = IMDCT86_FV1;
	else if i > 35 then do;	
		if IMDCT(i-1) ne . 		then IMDCT86_FV(i-33) = IMDCT86_FV(i-34);
		else if IMDCT(i-2) ne . 	then IMDCT86_FV(i-33) = IMDCT86_FV(i-35);
		else if IMDCT(i-2) = . 		then IMDCT86_FV(i-33) = .;
	end;
end;
do i=50 to 64;
	if  IMDCT(i) ne . 			then IMDCT114_FV(i-49) = IMDCT(i);
	else if i = 50 				then IMDCT114_FV(i-49) = IMDCT114_FV0;
	else if i = 51 and IMDCT(i-1) ne . 	then IMDCT114_FV(i-49) = IMDCT114_FV1;
	else if i > 51 then do;	
		if IMDCT(i-1) ne . 		then IMDCT114_FV(i-49) = IMDCT114_FV(i-50);
		else if IMDCT(i-2) ne . 	then IMDCT114_FV(i-49) = IMDCT114_FV(i-51);
		else if IMDCT(i-2) = . 		then IMDCT114_FV(i-49) = .;
	end;
end;
do i=66 to 80;
	if  IMDCT(i) ne . 			then IMDCT142_FV(i-65) = IMDCT(i);
	else if i = 66 				then IMDCT142_FV(i-65) = IMDCT142_FV0;
	else if i = 67 and IMDCT(i-1) ne . 	then IMDCT142_FV(i-65) = IMDCT142_FV1;
	else if i > 67 then do;	
		if IMDCT(i-1) ne . 		then IMDCT142_FV(i-65) = IMDCT142_FV(i-66);
		else if IMDCT(i-2) ne . 	then IMDCT142_FV(i-65) = IMDCT142_FV(i-67);
		else if IMDCT(i-2) = . 		then IMDCT142_FV(i-65) = .;
	end;
end;


DIG =.;
if IMDCT58 = 2	then DIG = 0;
if IMDCT58 = 1	then DIG = 1;
DIUR = .;
if IMDCT114 = 2 then DIUR = 0;
if IMDCT114 = 1 then DIUR = 1;
AntiArr =.;
if IMDCT86 = 2 	then AntiArr = 0;
if IMDCT86 = 1 	then AntiArr = 1;
AntiHyp =.;
if IMDCT142 = 2 then AntiHyp = 0;
if IMDCT142 = 1 then AntiHyp = 1;
OralHyp =.;
if IMDCT30 = 2 	then OralHyp = 0;
if IMDCT30 = 1 	then OralHyp = 1;
Keep DIG DIUR AntiArr AntiHyp OralHyp;

array DIG_FV(15) DIG_FV1 - DIG_FV15;
DIG_FV0 = DIG;
do i = 1 to 15;
	if IMDCT58_FV(i) = 2 then DIG_FV(i) = 0;
	if IMDCT58_FV(i) = 1 then DIG_FV(i) = 1;
	end;
array DIUR_FV(15) DIUR_FV1 - DIUR_FV15;
DIUR_FV0 = DIUR;
do i = 1 to 15;
	if IMDCT114_FV(i) = 2 then DIUR_FV(i) = 0;
	if IMDCT114_FV(i) = 1 then DIUR_FV(i) = 1;
	end;
array AntiArr_FV(15) AntiArr_FV1 - AntiArr_FV15;
AntiArr_FV0 = AntiArr;
do i = 1 to 15;
	if IMDCT86_FV(i) = 2 then AntiArr_FV(i) = 0;
	if IMDCT86_FV(i) = 1 then AntiArr_FV(i) = 1;
	end;
array AntiHyp_FV(15) AntiHyp_FV1 - AntiHyp_FV15;
AntiHyp_FV0 = AntiHyp;
do i = 1 to 15;
	if IMDCT142_FV(i) = 2 then AntiHyp_FV(i) = 0;
	if IMDCT142_FV(i) = 1 then AntiHyp_FV(i) = 1;
	end;
array OralHyp_FV(15) OralHyp_FV1 - OralHyp_FV15;
OralHyp_FV0 = OralHyp;
do i = 1 to 15;
	if IMDCT30_FV(i) = 2 then OralHyp_FV(i) = 0;
	if IMDCT30_FV(i) = 1 then OralHyp_FV(i) = 1;
	end;
keep DIG_FV0-DIG_FV15 DIUR_FV0-DIUR_FV15 AntiArr_FV0-AntiArr_FV15
AntiHyp_FV0-AntiHyp_FV15 OralHyp_FV0-OralHyp_FV15;


/*Cardiomegaly on x-ray: 0 = no, 1 = probable or definite; baseline and follow-up*/
array IXRAY1_FV(17) IXRAY1_FV1-IXRAY1_FV17;
array IXRAY2_FV(17) IXRAY2_FV1-IXRAY2_FV17;
array IXRAY(22) IXRAY1 - IXRAY22;
do i = 1 to 11;
	if IXRAY(i) = 3 then IXRAY(i)=.;
	end;
IXRAY1_FV0 = IXRAY1;
IXRAY1_FV1 = IXRAY1;
IXRAY1_FV2 = IXRAY1;
do i = 2 to 6;
	if IXRAY(i) ne . then do;
		IXRAY1_FV((i-1)*3) = IXRAY(i);
		IXRAY1_FV((i-1)*3+1) = IXRAY(i);
		IXRAY1_FV((i-1)*3+2) = IXRAY(i);
		end;
	else do;
		IXRAY1_FV((i-1)*3) = .;
		IXRAY1_FV((i-1)*3+1) = .;
		IXRAY1_FV((i-1)*3+2) = .;
		end;
end;
IXRAY2_FV0 = IXRAY12;
IXRAY2_FV1 = IXRAY12;
IXRAY2_FV2 = IXRAY12;
do i = 13 to 17;
	if IXRAY(i) ne . then do;
		IXRAY2_FV((i-12)*3) = IXRAY(i);
		IXRAY2_FV((i-12)*3+1) = IXRAY(i);
		IXRAY2_FV((i-12)*3+2) = IXRAY(i);
		end;
	else do;
		IXRAY2_FV((i-12)*3) = .;
		IXRAY2_FV((i-12)*3+1) = .;
		IXRAY2_FV((i-12)*3+2) = .;
		end;
end;

CardioM =.;
if IXRAY1 = 1 or IXRAY12 = 1	then CardioM = 0;
if IXRAY12 in (2,3)			 	then CardioM = 1;
keep CardioM;

array CardioM_FV(15) CardioM_FV1 - CardioM_FV15;
CardioM_FV0 = CardioM;
do i = 1 to 15;
	if IXRAY1_FV(i) = 1 or IXRAY2_FV(i) = 1 then CardioM_FV(i) = 0;
	if IXRAY2_FV(i) in (2,3) 				then CardioM_FV(i) = 1;
	end;
keep CardioM_FV0 - CardioM_FV15;



/*ECG findings: categorical; baseline and follow-up, scheduled ECGs only*/
array IECG(283) IECG1-IECG283;
array IECG2_FV(17) IECG2_FV1 - IECG2_FV17;
array IECG14_FV(17) IECG14_FV1 - IECG14_FV17;
array IECG26_FV(17) IECG26_FV1 - IECG26_FV17;
array IECG38_FV(17) IECG38_FV1 - IECG38_FV17;
array IECG50_FV(17) IECG50_FV1 - IECG50_FV17;
array IECG62_FV(17) IECG62_FV1 - IECG62_FV17;
array IECG74_FV(17) IECG74_FV1 - IECG74_FV17;
array IECG86_FV(17) IECG86_FV1 - IECG86_FV17;
array IECG98_FV(17) IECG98_FV1 - IECG98_FV17;
array IECG110_FV(17) IECG110_FV1 - IECG110_FV17;
array IECG122_FV(17) IECG122_FV1 - IECG122_FV17;
array IECG134_FV(17) IECG134_FV1 - IECG134_FV17;
array IECG206_FV(17) IECG206_FV1 - IECG206_FV17;
array IECG194_FV(17) IECG194_FV1 - IECG194_FV17;
array IECG278_FV(17) IECG278_FV1 - IECG278_FV17;
do i=1 to 36; 
	if IECG(i) in (1, 10, 20, 37, 99) then IECG(i) = .;
	end;
do i=37 to 72;
	if IECG(i) in (5, 8, 9) then IECG(i) = .;
	end;
do i=73 to 108;
	if IECG(i) in (6, 7, 9) then IECG(i) = .;
	end;
do i=109 to 144;
	if IECG(i) in (3, 9) then IECG(i) = .;
	end;
do i=206 to 211;
	if IECG(i) in (6, 9) then IECG(i) = .;
	end;
do i=194 to 199;
	if IECG(i) = 9 then IECG(i) = .;
	end;
do i=278 to 283;
	if IECG(i) in (490, 999) then IECG(i) = .;
	end;
IECG2_FV0 = IECG2;
IECG14_FV0 = IECG14;
IECG26_FV0 = IECG26;
IECG38_FV0 = IECG38;
IECG50_FV0 = IECG50;
IECG62_FV0 = IECG62;
IECG74_FV0 = IECG74;
IECG86_FV0 = IECG86;
IECG98_FV0 = IECG98;
IECG110_FV0 = IECG110;
IECG122_FV0 = IECG122;
IECG134_FV0 = IECG134;
IECG206_FV0 = IECG206;
IECG194_FV0 = IECG194;
IECG278_FV0 = IECG278;
IECG2_FV1 = IECG2;
IECG14_FV1 = IECG14;
IECG26_FV1 = IECG26;
IECG38_FV1 = IECG38;
IECG50_FV1 = IECG50;
IECG62_FV1 = IECG62;
IECG74_FV1 = IECG74;
IECG86_FV1 = IECG86;
IECG98_FV1 = IECG98;
IECG110_FV1 = IECG110;
IECG122_FV1 = IECG122;
IECG134_FV1 = IECG134;
IECG206_FV1 = IECG206;
IECG194_FV1 = IECG194;
IECG278_FV1 = IECG278;
IECG2_FV2 = IECG2;
IECG14_FV2 = IECG14;
IECG26_FV2 = IECG26;
IECG38_FV2 = IECG38;
IECG50_FV2 = IECG50;
IECG62_FV2 = IECG62;
IECG74_FV2 = IECG74;
IECG86_FV2 = IECG86;
IECG98_FV2 = IECG98;
IECG110_FV2 = IECG110;
IECG122_FV2 = IECG122;
IECG134_FV2 = IECG134;
IECG206_FV2 = IECG206;
IECG194_FV2 = IECG194;
IECG278_FV2 = IECG278;

do i = 3 to 7;
	if IECG(i) ne . then do;
		IECG2_FV((i-2)*3) = IECG(i);
		IECG2_FV((i-2)*3+1) = IECG(i);
		IECG2_FV((i-2)*3+2) = IECG(i);
		end;
	else do;
		IECG2_FV((i-2)*3) = .;
		IECG2_FV((i-2)*3+1) = .;
		IECG2_FV((i-2)*3+2) = .;
		end;
end;

do i = 15 to 19;
	if IECG(i) ne . then do;
		IECG14_FV((i-14)*3) = IECG(i);
		IECG14_FV((i-14)*3+1) = IECG(i);
		IECG14_FV((i-14)*3+2) = IECG(i);
		end;
	else do;
		IECG14_FV((i-14)*3) = .;
		IECG14_FV((i-14)*3+1) = .;
		IECG14_FV((i-14)*3+2) = .;
		end;
end;

do i = 27 to 31;
	if IECG(i) ne . then do;
		IECG26_FV((i-26)*3) = IECG(i);
		IECG26_FV((i-26)*3+1) = IECG(i);
		IECG26_FV((i-26)*3+2) = IECG(i);
		end;
	else do;
		IECG26_FV((i-26)*3) = .;
		IECG26_FV((i-26)*3+1) = .;
		IECG26_FV((i-26)*3+2) = .;
		end;
end;

do i = 39 to 43;
	if IECG(i) ne . then do;
		IECG38_FV((i-38)*3) = IECG(i);
		IECG38_FV((i-38)*3+1) = IECG(i);
		IECG38_FV((i-38)*3+2) = IECG(i);
		end;
	else do;
		IECG38_FV((i-38)*3) = .;
		IECG38_FV((i-38)*3+1) = .;
		IECG38_FV((i-38)*3+2) = .;
		end;
end;

do i = 51 to 55;
	if IECG(i) ne . then do;
		IECG50_FV((i-50)*3) = IECG(i);
		IECG50_FV((i-50)*3+1) = IECG(i);
		IECG50_FV((i-50)*3+2) = IECG(i);
		end;
	else do;
		IECG50_FV((i-50)*3) = .;
		IECG50_FV((i-50)*3+1) = .;
		IECG50_FV((i-50)*3+2) = .;
		end;
end;

do i = 63 to 67;
	if IECG(i) ne . then do;
		IECG62_FV((i-62)*3) = IECG(i);
		IECG62_FV((i-62)*3+1) = IECG(i);
		IECG62_FV((i-62)*3+2) = IECG(i);
		end;
	else do;
		IECG62_FV((i-62)*3) = .;
		IECG62_FV((i-62)*3+1) = .;
		IECG62_FV((i-62)*3+2) = .;
		end;
end;

do i = 75 to 79;
	if IECG(i) ne . then do;
		IECG74_FV((i-74)*3) = IECG(i);
		IECG74_FV((i-74)*3+1) = IECG(i);
		IECG74_FV((i-74)*3+2) = IECG(i);
		end;
	else do;
		IECG74_FV((i-74)*3) = .;
		IECG74_FV((i-74)*3+1) = .;
		IECG74_FV((i-74)*3+2) = .;
		end;
end;

do i = 87 to 91;
	if IECG(i) ne . then do;
		IECG86_FV((i-86)*3) = IECG(i);
		IECG86_FV((i-86)*3+1) = IECG(i);
		IECG86_FV((i-86)*3+2) = IECG(i);
		end;
	else do;
		IECG86_FV((i-86)*3) = .;
		IECG86_FV((i-86)*3+1) = .;
		IECG86_FV((i-86)*3+2) = .;
		end;
end;

do i = 99 to 103;
	if IECG(i) ne . then do;
		IECG98_FV((i-98)*3) = IECG(i);
		IECG98_FV((i-98)*3+1) = IECG(i);
		IECG98_FV((i-98)*3+2) = IECG(i);
		end;
	else do;
		IECG98_FV((i-98)*3) = .;
		IECG98_FV((i-98)*3+1) = .;
		IECG98_FV((i-98)*3+2) = .;
		end;
end;

do i = 111 to 115;
	if IECG(i) ne . then do;
		IECG110_FV((i-110)*3) = IECG(i);
		IECG110_FV((i-110)*3+1) = IECG(i);
		IECG110_FV((i-110)*3+2) = IECG(i);
		end;
	else do;
		IECG110_FV((i-110)*3) = .;
		IECG110_FV((i-110)*3+1) = .;
		IECG110_FV((i-110)*3+2) = .;
		end;
end;

do i = 123 to 127;
	if IECG(i) ne . then do;
		IECG122_FV((i-122)*3) = IECG(i);
		IECG122_FV((i-122)*3+1) = IECG(i);
		IECG122_FV((i-122)*3+2) = IECG(i);
		end;
	else do;
		IECG122_FV((i-122)*3) = .;
		IECG122_FV((i-122)*3+1) = .;
		IECG122_FV((i-122)*3+2) = .;
		end;
end;

do i = 135 to 139;
	if IECG(i) ne . then do;
		IECG134_FV((i-134)*3) = IECG(i);
		IECG134_FV((i-134)*3+1) = IECG(i);
		IECG134_FV((i-134)*3+2) = IECG(i);
		end;
	else do;
		IECG134_FV((i-134)*3) = .;
		IECG134_FV((i-134)*3+1) = .;
		IECG134_FV((i-134)*3+2) = .;
		end;
end;

do i = 207 to 211;
	if IECG(i) ne . then do;
		IECG206_FV((i-206)*3) = IECG(i);
		IECG206_FV((i-206)*3+1) = IECG(i);
		IECG206_FV((i-206)*3+2) = IECG(i);
		end;
	else do;
		IECG206_FV((i-206)*3) = .;
		IECG206_FV((i-206)*3+1) = .;
		IECG206_FV((i-206)*3+2) = .;
		end;
end;

do i = 195 to 199;
	if IECG(i) ne . then do;
		IECG194_FV((i-194)*3) = IECG(i);
		IECG194_FV((i-194)*3+1) = IECG(i);
		IECG194_FV((i-194)*3+2) = IECG(i);
		end;
	else do;
		IECG194_FV((i-194)*3) = .;
		IECG194_FV((i-194)*3+1) = .;
		IECG194_FV((i-194)*3+2) = .;
		end;
end;

do i = 279 to 283;
	if IECG(i) ne . then do;
		IECG278_FV((i-278)*3) = IECG(i);
		IECG278_FV((i-278)*3+1) = IECG(i);
		IECG278_FV((i-278)*3+2) = IECG(i);
		end;
	else do;
		IECG278_FV((i-278)*3) = .;
		IECG278_FV((i-278)*3+1) = .;
		IECG278_FV((i-278)*3+2) = .;
		end;
end;

QQS = .;
if IECG2 = 0 and IECG14 = 0 and IECG26 = 0						then QQS = 0;
if IECG2 in (28,31,32,33,34,35,36) or IECG14 in (28,31,32,33,34,35,36) 
				or IECG26 in (28,31,32,33,34,35,36)			then QQS = 1;
if IECG2 in (21,22,23,24,25,26,27) or IECG14 in (21,22,23,24,25,26,27) 
				or IECG26 in (21,22,23,24,25,26,27)			then QQS = 2;
if IECG2 in (11,12,13,14,15,16,17,18) or IECG14 in (11,12,13,14,15,16,17,18) 
				or IECG26 in (11,12,13,14,15,16,17,18)			then QQS = 3;
array QQS_FV(15) QQS_FV1 - QQS_FV15;
QQS_FV0 = QQS;
do i = 1 to 15;
	if IECG2_FV(i) = 0 and IECG14_FV(i) = 0 and IECG26_FV(i) = 0				then QQS_FV(i) = 0;
	if IECG2_FV(i) in (28,31,32,33,34,35,36) or IECG14_FV(i) in (28,31,32,33,34,35,36) 
				or IECG26_FV(i) in (28,31,32,33,34,35,36)			then QQS_FV(i) = 1;
	if IECG2_FV(i) in (21,22,23,24,25,26,27) or IECG14_FV(i) in (21,22,23,24,25,26,27) 
				or IECG26_FV(i) in (21,22,23,24,25,26,27)			then QQS_FV(i) = 2;
	if IECG2_FV(i) in (11,12,13,14,15,16,17,18) or IECG14_FV(i) in (11,12,13,14,15,16,17,18) 
				or IECG26_FV(i) in (11,12,13,14,15,16,17,18)			then QQS_FV(i) = 3;
 	end;

AnyQQS =.;
if QQS ge 1 then AnyQQS = 1;
if QQS = 0 	then AnyQQS = 0;
array AnyQQS_FV(15) AnyQQS_FV1 - AnyQQS_FV15;
AnyQQS_FV0 = AnyQQS;
do i=1 to 15;
	if QQS_FV(i) ge 1 	then AnyQQS_FV(i) = 1;
	if QQS_FV(i) = 0 	then AnyQQS_FV(i) = 0;
	end;

STDep = .;
if IECG38 = 0 and IECG50 = 0 and IECG62 = 0 		then STDep = 0;
else if IECG38 = 4 or IECG50 = 4 or IECG62 = 4 		then STDep = 1;
else if IECG38 = 3 or IECG50 = 3 or IECG62 = 3		then STDep = 2;
else if IECG38 = 2 or IECG50 = 2 or IECG62 = 2		then STDep = 3;
else if IECG38 = 1 or IECG50 = 1 or IECG62 = 1		then STDep = 4;
array STDep_FV(15) STDep_FV1 - STDep_FV15;
STDep_FV0 = STDep;
do i = 1 to 15;
	if IECG38_FV(i) = 0 and IECG50_FV(i) = 0 and IECG62_FV(i) = 0 		then STDep_FV(i) = 0;
	else if IECG38_FV(i) = 4 or IECG50_FV(i) = 4 or IECG62_FV(i) = 4 	then STDep_FV(i) = 1;
	else if IECG38_FV(i) = 3 or IECG50_FV(i) = 3 or IECG62_FV(i) = 3	then STDep_FV(i) = 2;
	else if IECG38_FV(i) = 2 or IECG50_FV(i) = 2 or IECG62_FV(i) = 2	then STDep_FV(i) = 3;
	else if IECG38_FV(i) = 1 or IECG50_FV(i) = 1 or IECG62_FV(i) = 1	then STDep_FV(i) = 4;
 	end;

AnySTDep=.;
if STDep = 0 	then AnySTDep = 0;
if STDep >0 	then AnySTDep = 1;
array AnySTDep_FV(15) AnySTDep_FV1 - AnyStDep_FV15;
AnySTDep_FV0 = AnySTDep;
do i=1 to 15;
	if STDep_FV(i) = 0 	then AnySTDep_FV(i) = 0;
	if STDep_FV(i) >0 	then AnySTDep_FV(i) = 1;
	end;

TWave =.;
if IECG74 = 0 and IECG86 = 0 and IECG98 = 0 		then TWave = 0;
else if IECG74 = 4 or IECG86 = 4 or IECG98 = 4 		then TWave = 1;
else if IECG74 = 3 or IECG86 = 3 or IECG98 = 3		then TWave = 2;
else if IECG74 = 2 or IECG86 = 2 or IECG98 = 2		then TWave = 3;
else if IECG74 = 1 or IECG86 = 1 or IECG98 = 1		then TWave = 4;
array TWave_FV(15) 	TWave_FV1 - TWave_FV15;
TWave_FV0 = TWave;
do i = 1 to 15;
	if IECG74_FV(i) = 0 and IECG86_FV(i) = 0 and IECG98_FV(i) = 0 		then TWave_FV(i) = 0;
	else if IECG74_FV(i) = 4 or IECG86_FV(i) = 4 or IECG98_FV(i) = 4 	then TWave_FV(i) = 1;
	else if IECG74_FV(i) = 3 or IECG86_FV(i) = 3 or IECG98_FV(i) = 3	then TWave_FV(i) = 2;
	else if IECG74_FV(i) = 2 or IECG86_FV(i) = 2 or IECG98_FV(i) = 2	then TWave_FV(i) = 3;
	else if IECG74_FV(i) = 1 or IECG86_FV(i) = 1 or IECG98_FV(i) = 1	then TWave_FV(i) = 4;
 	end;

AnyTwave=.;
if Twave = 0 	then AnyTwave = 0;
if Twave >0 	then AnyTwave = 1;
array AnyTwave_FV(15) AnyTwave_FV1 - AnyTwave_FV15;
AnyTwave_FV0 = AnyTwave;
do i=1 to 15;
	if Twave_FV(i) = 0 	then AnyTwave_FV(i) = 0;
	if Twave_FV(i) >0 	then AnyTwave_FV(i) = 1;
	end;

STElev = .;
if IECG110 = 0 and IECG122 = 0 and IECG134 = 0 	then STElev = 0;
if IECG110 = 2 or IECG122 = 2 or IECG134 = 2	then STElev = 1;
array STElev_FV(15)  STElev_FV1 - STElev_FV15;
STElev_FV0 = STElev;
do i = 1 to 15;
	if IECG110_FV(i) = 0 and IECG122_FV(i) = 0 and IECG134_FV(i) = 0 	then STElev_FV(i) = 0;
	if IECG110_FV(i) = 2 or IECG122_FV(i) = 2 or IECG134_FV(i) = 2		then STElev_FV(i) = 1;
	end;

FVEB = .;
if IECG206 in (0, 1, 3, 4) then FVEB = 0;
if IECG206 = 2 then FVEB = 1;
array FVEB_FV(15) FVEB_FV1 - FVEB_FV15;
FVEB_FV0 = FVEB;
do i = 1 to 15;
	if IECG206_FV(i) in (0, 1, 3, 4) then FVEB_FV(i) = 0;
	if IECG206_FV(i) = 2 			 then FVEB_FV(i) = 1;
 	end;

VCD = .;
if IECG194 in (0,3,5) then VCD = 0;
if IECG194 in (1,2,4) then VCD = 1;
array VCD_FV(15) VCD_FV1 - VCD_FV15;
VCD_FV0 = VCD;
do i = 1 to 15;
	if IECG194_FV(i) in (0,3,5) then VCD_FV(i) = 0;
	if IECG194_FV(i) in (1,2,4) then VCD_FV(i) = 1;
 	end;

HiHeart = .;
if IECG278 ge 70 	then HiHeart = 1;
if IECG278 <70 		then HiHeart = 0;
array HiHeart_FV(15) HiHeart_FV1-HiHeart_FV15;
HiHeart_FV0 = HiHeart;
do i=1 to 15;
	if IECG278_FV(i) ge 70 	then HiHeart_FV(i) = 1;
	if IECG278_FV(i) <70 	then HiHeart_FV(i) = 0;
	end;
 
keep QQS QQS_FV0-QQS_FV15 AnyQQS AnyQQS_FV0-AnyQQS_FV15
	STDep STDep_FV0-STDep_FV15 AnySTDep AnySTDep_FV0-AnySTDep_FV15
	TWave TWave_FV0-TWave_FV15 AnyTWave AnyTWave_FV0-AnyTWave_FV15
	STElev STElev_FV0-STElev_FV15 
	FVEB FVEB_FV0-FVEB_FV15
	VCD VCD_FV0-VCD_FV15
	HiHeart HiHeart_FV0-HiHeart_FV15;



/* Blood pressure*/
array SysBP_FV(15) SysBP_FV1-SysBP_FV15;
array DiasBP_FV(15) DiasBP_FV1-DiasBP_FV15;
array WTBP(32) WTBP32 - WTBP47 WTBP61-WTBP76;
SysBP_FV0 = WTBP32;
do i=2 to 16;
	if  WTBP(i) ne . 			then SysBP_FV(i-1) = WTBP(i);
	else if i = 2 				then SysBP_FV(i-1) = SysBP_FV0;
	else if i = 3 and WTBP(i-1) ne . 	then SysBP_FV(i-1) = SysBP_FV1;
	else if i > 3 then do;	
		if WTBP(i-1) ne . 		then SysBP_FV(i-1) = SysBP_FV(i-2);
		else if WTBP(i-2) ne . 		then SysBP_FV(i-1) = SysBP_FV(i-3);
		else if WTBP(i-2) = . 		then SysBP_FV(i-1) = .;
	end;
end;
DiasBP_FV0 = WTBP61;
do i=18 to 32;
	if  WTBP(i) ne . 			then DiasBP_FV(i-17) = WTBP(i);
	else if i = 18 				then DiasBP_FV(i-17) = DiasBP_FV0;
	else if i = 19 and WTBP(i-1) ne . 	then DiasBP_FV(i-17) = DiasBP_FV1;
	else if i > 19 then do;	
		if WTBP(i-1) ne . 		then DiasBP_FV(i-17) = DiasBP_FV(i-18);
		else if WTBP(i-2) ne . 		then DiasBP_FV(i-17) = DiasBP_FV(i-19);
		else if WTBP(i-2) = . 		then DiasBP_FV(i-17) = .;
	end;
end;


array HiSysBP_a(15) HiSysBP_FV1 - HiSysBP_FV15;
array HiDiasBP_a(15) HiDiasBP_FV1 - HiDiasBP_FV15;
if . < SysBP_FV0 < 130 then do;
	HiSysBP = 0;
	HiSysBP_FV0 = 0;
	end;
	else if SysBP_FV0 ge 130 then do;
	HiSysBP =1;
	HiSysBP_FV0 = 1;
	end;
do i = 1 to 15;
	if . < SysBP_FV(i) < 130 then HiSysBP_a(i) = 0;
	else if SysBP_FV(i) ge 130 then HiSysBP_a(i) =1;
	end;

if . < DiasBP_FV0 < 85 then do; 
	HiDiasBP = 0;
	HiDiasBP_FV0 = 0;
	end;
	else if DiasBP_FV0 ge 85 then do;
	HiDiasBP =1;
	HiDiasBP_FV0 = 1;
	end;
do i = 1 to 15;
	if . < DiasBP_FV(i) < 85 then HiDiasBP_a(i) = 0;
	else if DiasBP_FV(i) ge 85 then HiDiasBP_a(i) =1;
	end;

keep HiSysBP 	HiSysBP_FV0 - HiSysBP_FV15
 HiDiasBP	HiDiasBP_FV0 - HiDiasBP_FV15;




/*blood work labs*/
array ZLABB1_FV(15) ZLABB1_FV1-ZLABB1_FV15;
array ZLABB4_FV(15) ZLABB4_FV1-ZLABB4_FV15;
array ZLABB5_FV(15) ZLABB5_FV1-ZLABB5_FV15;
array ZLABB6_FV(15) ZLABB6_FV1-ZLABB6_FV15;
array ZLABB7_FV(15) ZLABB7_FV1-ZLABB7_FV15;
array ZLABB8_FV(15) ZLABB8_FV1-ZLABB8_FV15;
array ZLABB9_FV(15) ZLABB9_FV1-ZLABB9_FV15;
array ZLABB10_FV(15) ZLABB10_FV1-ZLABB10_FV15;
array ZLAB(120) ZLAB4-ZLAB18 
				ZLAB91-ZLAB105 
				ZLAB120-ZLAB134
				ZLAB149-ZLAB163 
				ZLAB178-ZLAB192 
				ZLAB207-ZLAB221
				ZLAB236-ZLAB250 
				ZLAB265-ZLAB279;
ZLABB1_FV0 = ZLABB1;
ZLABB4_FV0 = ZLABB4;
ZLABB5_FV0 = ZLABB5;
ZLABB6_FV0 = ZLABB6;
ZLABB7_FV0 = ZLABB7;
ZLABB8_FV0 = ZLABB8;
ZLABB9_FV0 = ZLABB9;
ZLABB10_FV0 = ZLABB10;
do i=1 to 15;
	if   ZLAB(i) ne . 			then ZLABB1_FV(i) = ZLAB(i);
	else if i = 1 				then ZLABB1_FV(i) = ZLABB1_FV0;
	else if i = 2 and  ZLAB(i-1) ne . 	then ZLABB1_FV(i) = ZLABB1_FV1;
	else if i > 2 then do;	
		if  ZLAB(i-1) ne . 		then ZLABB1_FV(i) = ZLABB1_FV(i-1);
		else if ZLAB(i-2) ne . 		then ZLABB1_FV(i) = ZLABB1_FV(i-2);
		else if ZLAB(i-2) = . 		then ZLABB1_FV(i) = .;
	end;
end;
do i=16 to 30;
	if   ZLAB(i) ne . 			then ZLABB4_FV(i-15) = ZLAB(i);
	else if i = 16 				then ZLABB4_FV(i-15) = ZLABB4_FV0;
	else if i = 17 and  ZLAB(i-1) ne . 	then ZLABB4_FV(i-15) = ZLABB4_FV1;
	else if i > 17 then do;	
		if  ZLAB(i-1) ne . 		then ZLABB4_FV(i-15) = ZLABB4_FV(i-16);
		else if ZLAB(i-2) ne . 		then ZLABB4_FV(i-15) = ZLABB4_FV(i-17);
		else if ZLAB(i-2) = . 		then ZLABB4_FV(i-15) = .;
	end;
end;
do i=31 to 45;
	if   ZLAB(i) ne . 			then ZLABB5_FV(i-30) = ZLAB(i);
	else if i = 31 				then ZLABB5_FV(i-30) = ZLABB5_FV0;
	else if i = 32 and  ZLAB(i-1) ne . 	then ZLABB5_FV(i-30) = ZLABB5_FV1;
	else if i > 32 then do;	
		if  ZLAB(i-1) ne . 		then ZLABB5_FV(i-30) = ZLABB5_FV(i-31);
		else if ZLAB(i-2) ne . 		then ZLABB5_FV(i-30) = ZLABB5_FV(i-32);
		else if ZLAB(i-2) = . 		then ZLABB5_FV(i-30) = .;
	end;
end;
do i=46 to 60;
	if   ZLAB(i) ne . 			then ZLABB6_FV(i-45) = ZLAB(i);
	else if i = 46 				then ZLABB6_FV(i-45) = ZLABB6_FV0;
	else if i = 47 and  ZLAB(i-1) ne . 	then ZLABB6_FV(i-45) = ZLABB6_FV1;
	else if i > 47 then do;	
		if  ZLAB(i-1) ne . 		then ZLABB6_FV(i-45) = ZLABB6_FV(i-46);
		else if ZLAB(i-2) ne . 		then ZLABB6_FV(i-45) = ZLABB6_FV(i-47);
		else if ZLAB(i-2) = . 		then ZLABB6_FV(i-45) = .;
	end;
end;
do i=61 to 75;
	if   ZLAB(i) ne . 			then ZLABB7_FV(i-60) = ZLAB(i);
	else if i = 61 				then ZLABB7_FV(i-60) = ZLABB7_FV0;
	else if i = 62 and  ZLAB(i-1) ne . 	then ZLABB7_FV(i-60) = ZLABB7_FV1;
	else if i > 62 then do;	
		if  ZLAB(i-1) ne . 		then ZLABB7_FV(i-60) = ZLABB7_FV(i-61);
		else if ZLAB(i-2) ne . 		then ZLABB7_FV(i-60) = ZLABB7_FV(i-62);
		else if ZLAB(i-2) = . 		then ZLABB7_FV(i-60) = .;
	end;
end;
do i=76 to 90;
	if   ZLAB(i) ne . 			then ZLABB8_FV(i-75) = ZLAB(i);
	else if i = 76 				then ZLABB8_FV(i-75) = ZLABB8_FV0;
	else if i = 77 and  ZLAB(i-1) ne . 	then ZLABB8_FV(i-75) = ZLABB8_FV1;
	else if i > 77 then do;	
		if  ZLAB(i-1) ne . 		then ZLABB8_FV(i-75) = ZLABB8_FV(i-76);
		else if ZLAB(i-2) ne . 		then ZLABB8_FV(i-75) = ZLABB8_FV(i-77);
		else if ZLAB(i-2) = . 		then ZLABB8_FV(i-75) = .;
	end;
end;
do i=91 to 105;
	if   ZLAB(i) ne . 			then ZLABB9_FV(i-90) = ZLAB(i);
	else if i = 91 				then ZLABB9_FV(i-90) = ZLABB9_FV0;
	else if i = 92 and  ZLAB(i-1) ne . 	then ZLABB9_FV(i-90) = ZLABB9_FV1;
	else if i > 92 then do;	
		if  ZLAB(i-1) ne . 		then ZLABB9_FV(i-90) = ZLABB9_FV(i-91);
		else if ZLAB(i-2) ne . 		then ZLABB9_FV(i-90) = ZLABB9_FV(i-92);
		else if ZLAB(i-2) = . 		then ZLABB9_FV(i-90) = .;
	end;
end;
do i=106 to 120;
	if   ZLAB(i) ne . 			then ZLABB10_FV(i-105) = ZLAB(i);
	else if i = 106 			then ZLABB10_FV(i-105) = ZLABB10_FV0;
	else if i = 107 and  ZLAB(i-1) ne . 	then ZLABB10_FV(i-105) = ZLABB10_FV1;
	else if i > 107 then do;	
		if  ZLAB(i-1) ne . 		then ZLABB10_FV(i-105) = ZLABB10_FV(i-106);
		else if ZLAB(i-2) ne . 		then ZLABB10_FV(i-105) = ZLABB10_FV(i-107);
		else if ZLAB(i-2) = . 		then ZLABB10_FV(i-105) = .;
	end;
end;


HiBili =.;
if ZLABB1 ge 0.5 	then HiBili = 1;
if . < ZLABB1 <  0.5 	then HiBili = 0;
array HiBili_FV(15) HiBili_FV1-HiBili_FV15;
HiBili_FV0 = HiBili;
do i=1 to 15;
	if ZLABB1_FV(i) ge 0.5 		then HiBili_FV(i) = 1;
	if . < ZLABB1_FV(i) <  0.5 	then HiBili_FV(i) = 0;
	end;

HiSerChol = .;
if ZLABB4 ge 250 	then HiSerChol = 1;
if . < ZLABB4 <  250 	then HiSerChol = 0;
array HiSerChol_FV(15) HiSerChol_FV1-HiSerChol_FV15;
HiSerChol_FV0 = HiSerChol;
do i=1 to 15;
	if ZLABB4_FV(i) ge 250 		then HiSerChol_FV(i) = 1;
	if . < ZLABB4_FV(i) <  250 	then HiSerChol_FV(i) = 0;
	end;

HiSerTrigly = .;
if ZLABB5 ge 5.0 	then HiSerTrigly =1;
if . < ZLABB5 <  5.0 	then HiSerTrigly = 0;
array HiSerTrigly_FV(15) HiSerTrigly_FV1-HiSerTrigly_FV15;
HiSerTrigly_FV0 = HiSerTrigly;
do i=1 to 15;	
	if ZLABB5_FV(i) ge 5.0 		then HiSerTrigly_FV(i) = 1;
	if . < ZLABB5_FV(i) <  5.0 	then HiSerTrigly_FV(i) = 0;
	end;

HiSerUric = .;
if ZLABB6 ge 7.0 	then HiSerUric = 1;
if . < ZLABB6 <  7.0 	then HiSerUric = 0;
array HiSerUric_FV(15) HiSerUric_FV1-HiSerUric_FV15;
HiSerUric_FV0 = HiSerUric;
do i=1 to 15;
	if ZLABB6_FV(i) ge 7.0 		then HiSerUric_FV(i) = 1;
	if . < ZLABB6_FV(i) <  7.0 	then HiSerUric_FV(i) = 0;
	end;

HiSerAlk = .;
if ZLABB7 ge 7.5 	then HiSerAlk = 1;
if . < ZLABB7 <  7.5 	then HiSerAlk = 0;
array HiSerAlk_FV(15) HiSerAlk_FV1-HiSerAlk_FV15;
HiSerAlk_FV0 = HiSerAlk;
do i=1 to 15;
	if ZLABB7_FV(i) ge 7.5 		then HiSerAlk_FV(i) = 1;
	if . < ZLABB7_FV(i) <  7.5 	then HiSerAlk_FV(i) = 0;
	end;

HiPlasUrea = .;
if ZLABB8 ge 16 	then HiPlasUrea = 1;
if . < ZLABB8 <  16 	then HiPlasUrea = 0;
array HiPlasUrea_FV(15) HiPlasUrea_FV1-HiPlasUrea_FV15;
HiPlasUrea_FV0 = HiPlasUrea;
do i=1 to 15;
	if ZLABB8_FV(i) ge 16 		then HiPlasUrea_FV(i) = 1;
	if . < ZLABB8_FV(i) <  16 	then HiPlasUrea_FV(i) = 0;
	end;

HiFastGluc = .;
if ZLABB9 ge 100 	then HiFastGluc = 1;
if . < ZLABB9 <  100 	then HiFastGluc = 0;
array HiFastGluc_FV(15) HiFastGluc_FV1-HiFastGluc_FV15;
HiFastGluc_FV0 = HiFastGluc;
do i=1 to 15;
	if ZLABB9_FV(i) ge 100 		then HiFastGluc_FV(i) = 1;
	if . < ZLABB9_FV(i) <  100 	then HiFastGluc_FV(i) = 0;
	end;

HiOneGluc = .;
if ZLABB10 ge 180 	then HiOneGluc = 1;
if . < ZLABB10 <  180 	then HiOneGluc = 0;
array HiOneGluc_FV(15) HiOneGluc_FV1-HiOneGluc_FV15;
HiOneGluc_FV0 = HiOneGluc;
do i=1 to 15;
	if ZLABB10_FV(i) ge 180 	then HiOneGluc_FV(i) = 1;
	if . < ZLABB10_FV(i) <  180 	then HiOneGluc_FV(i) = 0;
	end;

keep 	HiBili 		HiBili_FV0-HiBili_Fv15
	HiSerChol 	HiSerChol_FV0-HiSerChol_FV15
	HiSerTrigly 	HiSerTrigly_FV0-HiSerTrigly_FV15
	HiSerUric 	HiSerUric_FV0-HiSerUric_FV15
	HiSerAlk 	HiSerAlk_FV0-HiSerAlk_FV15
	HiPlasUrea	HiPlasUrea_FV0-HiPlasUrea_FV15
	HiFastGluc 	HiFastGluc_FV0-HiFastGluc_FV15 
	HiOneGluc 	HiOneGluc_FV0-HiOneGluc_FV15
	;



array WBC1_FV(17) WBC1_FV1 - WBC1_FV17;
array WBC12_FV(17) WBC12_FV1 - WBC12_FV17;
array WBC23_FV(17) WBC23_FV1 - WBC23_FV17;
array WBC(33) WBC1-WBC33;
WBC1_FV0 = WBC1;
WBC1_FV1 = WBC1;
WBC1_FV2 = WBC1;
do i = 2 to 6;
	if WBC(i) ne . then do;
		WBC1_FV((i-1)*3) = WBC(i);
		WBC1_FV((i-1)*3+1) = WBC(i);
		WBC1_FV((i-1)*3+2) = WBC(i);
		end;
	else do;
		WBC1_FV((i-1)*3) = .;
		WBC1_FV((i-1)*3+1) = .;
		WBC1_FV((i-1)*3+2) = .;
		end;
end;
WBC12_FV0 = WBC12;
WBC12_FV1 = WBC12;
WBC12_FV2 = WBC12;
do i = 13 to 17;
	if WBC(i) ne . then do;
		WBC12_FV((i-12)*3) = WBC(i);
		WBC12_FV((i-12)*3+1) = WBC(i);
		WBC12_FV((i-12)*3+2) = WBC(i);
		end;
	else do;
		WBC12_FV((i-12)*3) = .;
		WBC12_FV((i-12)*3+1) = .;
		WBC12_FV((i-12)*3+2) = .;
		end;
end;
WBC23_FV0 = WBC23;
WBC23_FV1 = WBC23;
WBC23_FV2 = WBC23;
do i = 24 to 28;
	if WBC(i) ne . then do;
		WBC23_FV((i-23)*3) = WBC(i);
		WBC23_FV((i-23)*3+1) = WBC(i);
		WBC23_FV((i-23)*3+2) = WBC(i);
		end;
	else do;
		WBC23_FV((i-23)*3) = .;
		WBC23_FV((i-23)*3+1) = .;
		WBC23_FV((i-23)*3+2) = .;
		end;
end;


HiWhiteCell = .;
if WBC1 ge 7500 		then HiWhiteCell = 1;
if . <  WBC1 <  7500		then HiWhiteCell = 0;
array HiWhiteCell_FV(15) HiWhiteCell_FV1-HiWhiteCell_FV15;
HiWhiteCell_FV0 = HiWhiteCell;
do i=1 to 15;
	if WBC1_FV(i) ge 7500 		then HiWhiteCell_FV(i) = 1;
	if . < WBC1_FV(i) <  7500 	then HiWhiteCell_FV(i) = 0;
	end;

HiNeut = .;
if WBC12 ge 4500 		then HiNeut = 1;
if . <  WBC12 <  4500		then HiNeut = 0;
array HiNeut_FV(15) HiNeut_FV1-HiNeut_FV15;
HiNeut_FV0 = HiNeut;
do i=1 to 15;
	if WBC12_FV(i) ge 4500 		then HiNeut_FV(i) = 1;
	if . < WBC12_FV(i) <  4500 	then HiNeut_FV(i) = 0;
	end;

HiHemat = .;
if WBC23 ge 46 			then HiHemat = 1;
if . <  WBC23 <  46		then HiHemat = 0;
array HiHemat_FV(15) HiHemat_FV1-HiHemat_FV15;
HiHemat_FV0 = HiHemat;
do i=1 to 15;
	if WBC23_FV(i) ge 46 		then HiHemat_FV(i) = 1;
	if . < WBC23_FV(i) <  46 	then HiHemat_FV(i) = 0;
	end;

keep HiWhiteCell HiWhiteCell_FV0-HiWhiteCell_FV15
	HiNeut		HiNeut_FV0-HiNeut_FV15
	HiHemat 	HiHemat_FV0-HiHemat_FV15
	;




/*Other covariates*/
array ICG_FV(17) ICG_FV1 - ICG_FV17;
array ICG(6) ICG1 - ICG6;
ICG_FV0 = ICG1;
ICG_FV1 = ICG1;
ICG_FV2 = ICG1;
do i = 2 to 6;
	if ICG(i) ne . then do;
		ICG_FV((i-1)*3) = ICG(i);
		ICG_FV((i-1)*3+1) = ICG(i);
		ICG_FV((i-1)*3+2) = ICG(i);
		end;
	else do;
		ICG_FV((i-1)*3) = .;
		ICG_FV((i-1)*3+1) = .;
		ICG_FV((i-1)*3+2) = .;
		end;
end;

CIG = .;
if ICG1 = 1 			then CIG = 0;
if ICG1 in (2,3,4,5,6) 	then CIG = 1;
keep CIG;
array CIG_FV(15) CIG_FV1 - CIG_FV15;
CIG_FV0 = CIG;
do i = 1 to 15;
	if ICG_FV(i) = 1 		then CIG_FV(i) = 0;
	if ICG_FV(i) in (2,3,4,5,6)	then CIG_FV(i) = 1;
	end;
keep CIG_FV0 - CIG_FV15;



array IJOB_FV(17) IJOB_FV1 - IJOB_FV17;
array IJOB(6) IJOB34 - IJOB39;
IJOB_FV0 = IJOB34;
IJOB_FV1 = IJOB34;
IJOB_FV2 = IJOB34;
do i = 2 to 6;
	if IJOB(i) ne . then do;
		IJOB_FV((i-1)*3) = IJOB(i);
		IJOB_FV((i-1)*3+1) = IJOB(i);
		IJOB_FV((i-1)*3+2) = IJOB(i);
		end;
	else do;
		IJOB_FV((i-1)*3) = .;
		IJOB_FV((i-1)*3+1) = .;
		IJOB_FV((i-1)*3+2) = .;
		end;
end;


INACT =.;
if IJOB34 = 1 then INACT = 1;
if IJOB34 = 2 then INACT = 0;
if IJOB34 = 3 then INACT = 0;
keep INACT;
array INACT_FV(15) INACT_FV1 - INACT_FV15;
INACT_FV0 = INACT;
do i=1 to 15;
	if IJOB_FV(i) = 1 then INACT_FV(i) = 1;
	if IJOB_FV(i) = 2 then INACT_FV(i) = 0;
	if IJOB_FV(i) = 3 then INACT_FV(i) = 0;
	end;
keep INACT_FV0-INACT_FV15;




/****************************/
/*New covariates*/

/*DIABETES--NEW*/
/*Note, inclusion criteria required individuals not be on insulin*/
/*Diabetes was not recorded until Year 1 (FV4)*/
/*IDB21 == diabetes at entry to the study as recorded at Y1 visit*/
if IDB21 = 1 then diab = 1; 
else diab = 0;
diab_FV0 = diab;
diab_FV1 = diab;
diab_FV2 = diab;

array IDB(5) IDB1 - IDB5 ;
array diab_bin(5) diab_bin1 - diab_bin5;
do i = 1 to 5;
    if IDB(i) = 1 then diab_bin(i) = 1;
    else if IDB(i) = 2 then diab_bin(i) = 0;
    else diab_bin(i) = .;
end;

array diab_FV(17) diab_FV1-diab_FV17;

do i = 2 to 6;
    if diab_bin(i-1) ne . then do;
        diab_FV((i-1)*3) = diab_bin(i-1);
        diab_FV((i-1)*3+1) = diab_bin(i-1);
        diab_FV((i-1)*3+2) = diab_bin(i-1);
    end;
    else do;
        diab_FV((i-1)*3) = .;
        diab_FV((i-1)*3+1) =.;
        diab_FV((i-1)*3+2) = .;
    end;
end;

keep diab diab_FV0 - diab_FV15;

drop diab_FV16 diab_FV17;

/*EMPLOYMENT -- NEW */
array emp_FV(17) emp_FV1 - emp_FV17;
array IJOB_emp(6) IJOB1 - IJOB6;
emp_FV0 = IJOB1;
emp_FV1 = IJOB1;
emp_FV2 = IJOB1;
do i = 2 to 6;
	if IJOB_emp(i) ne . then do;
		emp_FV((i-1)*3) = IJOB_emp(i);
		emp_FV((i-1)*3+1) = IJOB_emp(i);
		emp_FV((i-1)*3+2) = IJOB_emp(i);
		end;
	else do;
		emp_FV((i-1)*3) = .;
		emp_FV((i-1)*3+1) = .;
		emp_FV((i-1)*3+2) = .;
		end;
end;

EMPLOY =.;
if IJOB1 = 1 then EMPLOY = 1;
else if IJOB1 = 2 then EMPLOY =0;
else EMPLOY= .;

array EMPLOY_FV(15) EMPLOY_FV1 - EMPLOY_FV15;
EMPLOY_FV0 = EMPLOY;
do i=1 to 15;
	if emp_FV(i) = 1 then EMPLOY_FV(i) = 1;
	else if emp_FV(i) = 2 then EMPLOY_FV(i) = 0;
    	else EMPLOY_FV(i) = .;
end;
keep EMPLOY EMPLOY_FV0 - EMPLOY_FV15;


array hours_FV(17) hours_FV1 - hours_FV17;
array IJOB_hours(6) IJOB12 - IJOB17;
hours_FV0 = IJOB12;
hours_FV1 = IJOB12;
hours_FV2 = IJOB12;
do i = 2 to 6;
	if IJOB_hours(i) ne . then do;
		hours_FV((i-1)*3) = IJOB_hours(i);
		hours_FV((i-1)*3+1) = IJOB_hours(i);
		hours_FV((i-1)*3+2) = IJOB_hours(i);
	end;
	else do;
		hours_FV((i-1)*3) = .;
		hours_FV((i-1)*3+1) = .;
    		hours_FV((i-1)*3+2) = .;
	end;
end;

FULLTIME =.;
if EMPLOY = 1 and hours_FV0 = 1 then FULLTIME = 1;
else if EMPLOY = 0 then FUllTIME =0;
else if EMPLOY = 1 and Hours_FV0 = 2 then FULLTIME = 0;
else FULLTIME= .;

array FULLTIME_FV(15) FULLTIME_FV1 - FULLTIME_FV15;
FULLTIME_FV0 = FULLTIME;
do i=1 to 15;
	if EMPLOY_FV(i) = 1 and hours_fv(i) = 1 then FULLTIME_FV(i) = 1;
	else if EMPLOY_FV(i) = 0 then FULLTIME_FV(i) = 0;
	else if EMPLOY_FV(i) = 1 and hours_FV(i) = 2 then FULLTIME_FV(i) = 0;
    	else FULLTIME_FV(i) = .;
end;
keep FULLTIME FULLTIME_FV0 - FULLTIME_FV15;

/*OCCUPATION -- NEW*/
occupation = .;
if 1 le ioc le 9 then occupation = ioc;
else occupation = .;

if occupation = . and employ = 0 then occupation = 0;


/*HYPERTENSION -- NEW */

/*Baseline hypertension if baseline systolic above 130 or diastolic BP above 85*/
if HiSysBP_FV0 = 1 or HiDiasBP_FV0 = 1 then hypertens = 1;
else if HiSysBP_FV0 = 0 and HiDiasBP_FV0 = 0 then hypertens = 0;
else hypertens = .;

array ISUM_ht(6) hypertens ISUM21-ISUM25;
array ht_FV(17) ht_fv1 - ht_fv17;

do i = 2 to 6;
	if ISUM_ht(i) ne . then do;
		ht_FV((i-1)*3) = ISUM_ht(i);
	    	ht_FV((i-1)*3+1) = ISUM_ht(i);
    		ht_FV((i-1)*3+2) = ISUM_ht(i);
	end;
	else do;
		ht_FV((i-1)*3) = .;
		ht_FV((i-1)*3+1) = .;
        	ht_FV((i-1)*3+2) = .;
	end;
end;

array HYPERTENS_FV(15) HYPERTENS_FV1 - HYPERTENS_FV15;

hypertens_FV0 = hypertens;
do i=1 to 15;
	if ht_FV(i) = 1 or ht_FV(i) = 3 then HYPERTENS_FV(i) = 1;
	else if ht_FV(i) = 2 then HYPERTENS_FV(i) = 0;
	else HYPERTENS_FV(i) = .;
end;
keep hypertens hypertens_FV0 - hypertens_FV15 ;

/*Any hypertension medication*/
array htMed_FV(15) htMed_fv1 - htMed_fv15;
htMed = ceil((Diur + Antihyp)/2); /* if either antihyp or diur prescribed then htMed = 1*/
htMed_FV0 = htMed;
do i = 1 to 15;
	htMed_FV(i) = ceil((Diur_FV(i) + Antihyp_FV(i))/2);
end;
keep htMed htMed_FV0-htMed_FV15;

/*ATRIAL FIBRILLATION --- NEW*/
array afib_FV(15) afib_FV1 - afib_FV15;
array ICCL_af(15) ICCL365 - ICCL379;
array KLIN_af_FV(15) KLIN_af_FV1 - KLIN_af_FV15;

if IRHY1 = 2 or IRHY2 = 2 or IRHY3 = 2 then afib_FV0 = 1;
else if IRHY1 = 1 or IRHY2 = 1 or IRHY3 = 1 then afib_FV0 = 0;
else afib_FV0 = .;
do i=1 to 15;
	if ICCL_af(i) ne . 			then KLIN_af_FV(i) = ICCL_af(i);
	else if i = 1 				then KLIN_af_FV(i) = afib_FV0;
	else if i = 2 and ICCL_af(i-1) ne . 	then KLIN_af_FV(i) = KLIN_af_FV1;
	else if i >2 then do;
		if ICCL_af(i-1) ne . 		then KLIN_af_FV(i) = KLIN_af_FV(i-1);
		else if ICCL_af(i-2) ne . 		then KLIN_af_FV(i) = KLIN_af_FV(i-2);
		else if ICCL_af(i-2) = . 		then KLIN_af_FV(i) = .;
	end;
end;
do i = 1 to 15;
	if KLIN_af_FV(i) = 2 then afib_FV(i) = 0;
	if KLIN_af_FV(i) in (1,3) then afib_FV(i) = 1;
	end;

AFIB = AFIB_FV0;
	
keep afib afib_FV0 afib_FV1-afib_FV15 KLIN_af_FV1-KLIN_af_FV15;

/*Hyperlipidemia*/
hyperlipidemia = .;
if ZLABB4 ge 240 	then hyperlipid = 2;
else if 200 le ZLABB4 < 240 then hyperlipid = 1;
else if . < ZLABB4 < 200 then hyperlipid = 0;

array hyperlipid_FV(15) hyperlipid_FV1-hyperlipid_FV15;
hyperlipid_FV0 = hyperlipid;
do i=1 to 15;
	if ZLABB4_FV(i) ge 240 		then hyperlipid_FV(i) = 2;
	else if 200 le ZLABB4_FV(i) <  240 	then hyperlipid_FV(i) = 1;
	else if . < ZLABB4_FV(i) < 200 then hyperlipid_FV(i) = 0;
	else hyperlipid_FV(i) = .;
end;
keep hyperlipid hyperlipid_fv0 - hyperlipid_Fv15;

/****************************/


/*******Adherence measures************/

/*Notes on visit number: */
/*icap1-26 prescription made at FV1-26*/
/*caps1-26 prescription made for baseline, FV1-25*/
/*iadh1-26; adh1-26 adherence observed at baseline, fv1 - 25*/
array inv_a(*)  inv1 - inv24;
array iadh(26)  iadh1-iadh26;
array caps(26)  caps1-caps26;
array capsFV(*) capsFV1 - capsFV26;
array adh(52)   adh1-adh52;
array adhFV(26) adhFV0 -adhFV25;

/*clear adherence variable to recalculate*/
do i = 2 to 52;
	adh(i) = .;
end;

/*Pre-baseline adherence: adherence to placebo assessed pre-randomization for all participants*/
if JADH1 ne . and JADH2 ne . then adhpre0 = (JADH1 + JADH2)/2;
else if JADH1 = . and JADH2 ne . then adhpre0 = JADH2;
else if JADH1 ne . and JADH2 = . then adhpre0 = JADH1;
else if JADH1 = . and JADH2 = .  then adhpre0 = .;

adhpre0bin = .;
if adhpre0 ge 80 then adhpre0bin  = 0;
if .< adhpre0 <80 then adhpre0bin  = 1;

/*Follow-up: calculate adherence at each time point*/

do i = 1 to 26;
	capsFV(i) = caps(i);
	if caps(i) = . then do;
		if i = 2 then capsFV(i) = 9;
		else if caps(i-1) ne . then capsFV(i) = caps(i-1);
		else if caps(i-1) = . then do;
			if i > 2 then capsFV(i) = caps(i-2);
		end;
	end;
end;

do i=2 to 26; 
	if invdth = 0 or i le invdth then do;
		if . < iadh(i) < 6 then adh(i)=(capsFV(i)/9)*(110-iadh(i)*20);
		else if iadh(i)= 6 then adh(i)=0; 			/*if no prescription, then adh = 0%*/
	end;
	else if i > invdth then adh(i) = .;
end;

/*carry forward adherence for a maximum of three consecutive missed visits (carry forward 3 times because occurs b/f visit when measured);*/
array indic(*) indic1-indic15;
indic0 = 0;

do i = 1 to 15;
	if adh(i) ne . 			then adhFV(i) = adh(i);
	else if i = 1 			then 	adhFV(i) = .;
	else if i = 2 			then 	adhFV(i) = adhFV(i-1);
	else if i = 3  	then do;
		if adh(i-1) ne . 	then adhFV(i) = adh(i-1);
		else if adh(i-2) ne .	then adhFV(i) = adh(i-2);
					else adhFV(i) = .;
	end;
	else if i = 4 	then do;
		if adh(i-1) ne . 	then adhFV(i) = adh(i-1);
		else if adh(i-2) ne .	then adhFV(i) = adh(i-2);
		else if adh(i-2) = . 	then adhFV(i) =.;        /*special case of censoring at visit 4 because Adh0 can be measured at IV4 or IV5*/
	end;
	else if i > 4 	then do;	
		if adh(i-1) ne . 	then adhFV(i) = adh(i-1);
		else if adh(i-2) ne .	then adhFV(i) = adh(i-2);
		else if adh(i-3) ne .	then adhFV(i) = adh(i-3);
		else if adh(i-3) = . 	then adhFV(i) = .;
	end;
	
	if i in (1,2,3) 			 			then indic(i) = 0;  
	else if adh(i) = . and adh(i-1) = . and adh(i-2) ne .		then indic(i) = 1; 
	else if adh(i) = . and adh(i-1) = . and adh(i-2) = . 		then indic(i) = .;
	else 								indic(i) = 0;


	if invdth ne 0 and i ge invdth then do;
		indic(i) = .;
		adhFV(i) = .;
	end;
end;

keep  adhFV0 -adhFV25 indic0-indic15 ;

/*censoring indicator - adherence*/
/*censvisit = visit # when adherence first is missing or end of 5-year follow-up*/
censvisit = .;
do i = 1 to 15; /*adh15 is adherence measured at visit 15 for the intervisit period 14-15 (last adherence before 5 years)*/
	if censvisit ne . then censvisit = censvisit;
	else if censvisit = . then do;
		if adhFV(i) = . then censvisit = i-1;
		else if i < 15 and adhFV(i) ne . then censvisit = .;
		else if i = 15 and adhFV(i) ne . then censvisit = 15;
		end;
	end;
keep censvisit;

/*For i = 27-52: ADH(i) = cumulative adherence from baseline to FV(x), x = 1-15*/
adh27=adhFV0;

do i=2 to 15;
	if adhFV(i) ne . then adh(26+i)=(adh(26+i-1)*(i-1)+adhFV(i))/i; 
	else adh(26+i) = .;
	end;

array adhbin_array(*) 		adhbin0-adhbin25 adhbin27-adhbin42;  /*binary time-varying adherence level*/
if     . < adhFV0 < 80 then adhbin0 = 1;
else if 	   adhFV0 >=80 then adhbin0 = 0;
else if 	   adhFV0 = .  then adhbin0 = .;

do i=2 to 15;
       	if   		  . < adh(i) < 80 then adhbin_array(i) = 1;
      	else if 	   adh(i) >=80 then adhbin_array(i) = 0;
      	else if 	   adh(i) = .  then adhbin_array(i) = .;
end;
adhbin27 = adhbin0;
do i=28 to 42;
       	if   		 . < adh(i) < 80 then adhbin_array(i) = 1;
      	else if 	   adh(i) >=80 then adhbin_array(i) = 0;
	else if 	   adh(i) = .  then adhbin_array(i) = .;
end;
keep adhbin0-adhbin15 adhbin27-adhbin42;

if dth5 = 1 and invdth = 0 then invdth = ceil(min(itd,itdx)*3/365);

/*New variable: ADHX15. Cumulative average adherence at last visit before death or 5 years, whichever is first*/
if dth5 = 1 and invdth = 1 				then adhx15 = adh27;
else if dth5 = 1 and invdth > 0 			then adhx15 = adh(26+(invdth-1));
else if dth5 = 1 and invdth = 0 and 0 < inv28 le 15 	then adhx15 = adh(26+(inv_a(inv28)));
else if dth5 ne 1 					then adhx15 = adh(26+15);

Adhx15Bin = .;
if Adhx15 ge 80 then Adhx15Bin = 0;
if .<Adhx15 <80 then Adhx15Bin = 1;
keep Adhx15Bin adhx15;


keep adhpre0bin adh1-adh52  ;


/****Code adherence to match original paper, where adherence = 0 on all missed visits*****/
array inv(*) inv1-inv27;
array old_adh(52) old_adh1-old_adh52;

old_adh1 = adh1;
if adh1 = . then old_adh1 = 0;  /*set adherence to 0 when missing*/

ihigh=2;
if invdth=0 and inv28>14 then ihigh=inv28;
if (istat=3 or istat=6) and lvss>ihigh then ihigh=lvss;
if invdth>2 then ihigh=invdth-1;

old_adh27=old_adh1;
do i=2 to ihigh;
	if iadh(i)=6 then old_adh(i)=0;			/*if no prescription, then adh =0%*/
	else if inv(i)=0 or inv(i)=2 or inv(i)=7 or inv(i)=8 then old_adh(i)=0;
	else if capsFV(i) = . or iadh(i) = . then old_adh(i) = 0;
	else old_adh(i)= adh(i);
	if old_adh(i) = . then old_adh(i) = 0;
end;
do i=2 to ihigh;
	old_adh(26+i)=(old_adh(26+i-1)*(i-1)+old_adh(i))/i;
end;
keep old_adh1-old_adh52;

old_adhx=old_adh(26+ihigh);
old_adhx15=old_adhx;
if ihigh>15 then old_adhx15=old_adh41;

old_Adhx15Bin = .;
if old_Adhx15 ge 80 then old_Adhx15Bin = 0;
if .<old_Adhx15 <80 then old_Adhx15Bin = 1;
keep old_Adhx15Bin old_adhx old_adhx15;

run;

