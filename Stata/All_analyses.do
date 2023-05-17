
*******************************************
*****Main dataset: DAG-based covariates****
*****2016 updated adherence variable*******
*******************************************

**A. Unadjusted analysis**
*Import Data 
use "<path>\expertdag_wide.dta", clear
*Unadusted Risk Differences and regression analysis new calculation 
*Generate 2x2 table 
tab adhx15bin dth5
*risk difference calculation 
csi 133 369 320 1659
reg adhx15bin dth5

**B. Linear regression with standardization**
use "<path>\expertdag_wide.dta", clear
*Run adjusted linear regression with  adherence measure (only runs with index=0)
reg dth5 i.adhx15bin age_bin nonwhite adhpre0bin cig rbw_bin inact mi_bin ///
	ap chf aci icia ic irk niha_bin1 cardiom diur antihyp dig oralhyp antiarr ///
	hifastgluc i.hyperlipid diab afib employ fulltime hypertens htmed i.occupation
margins, dydx(adhx15bin) 
margins i.adhx15bin	

**C. Logistic regression with standardization**
use "<path>\expertdag_wide.dta", clear
*Run adjusted linear regression with  adherence measure (only runs with index=0)
logit dth5 i.adhx15bin age_bin nonwhite adhpre0bin cig rbw_bin inact mi_bin ///
	ap chf aci icia ic irk niha_bin1 cardiom diur antihyp dig oralhyp antiarr ///
	hifastgluc i.hyperlipid diab afib employ fulltime hypertens htmed i.occupation
margins, dydx(adhx15bin) 
margins i.adhx15bin	


**D. Logistic regression with inverse probability weighting for time-varying adhernece and visit attendence and standardization**

use "<path>\expertdag_ag_new.dta", clear

/*To ensure numerator & denominator models for the two sets of weights are fit to the same individuals we need to create some missingness flags*/
gen adhr_t_flag = 1
replace adhr_t_flag = 0 if adhbin0 ==. | adhr_t1 ==. |	adhpre0bin==. |  age_bin==. |  nonwhite==. |  irk==. |  mi_bin==. |  rbw_bin==. |  niha_bin0 ==. | ///
		employ0 ==. | fulltime0 ==. | cig0 ==. | inact0==. | hypertens0 ==. | htmed0 ==. | hyperlipid0 ==. | hifastgluc0 ==. |  ///
		chf0==. |  aci0==. |  ap0==. |  ic0 ==. | icia0 ==. | dig0==. |  diur0==. |  antiarr0==. |  antihyp0==. |  oralhyp0 ==. | ///
		diab0==. | afib0 ==.| cardiom0==. | ///
		employfv ==. | fulltimefv ==. | inactfv ==. | nihafv ==. |  hypertensfv ==. | htmedfv==. | hyperlipidfv == . |  hifastglucfv ==. | ///
		chffv ==. |  apfv  ==. |  acifv  ==. |  icfv  ==. |  iciafv  ==. |  digfv ==. |  diurfv ==. |   antiarrfv ==. |   antihypfv ==. |  oralhypfv ==. | ///
		diabfv ==. | afibfv==. | cardiomfv ==.   
tab adhr_t_flag

gen adhr_measure_flag = 1
replace  adhr_measure_flag  = 0 if   adhbin0 ==. | adhr_t1 ==. |	adhpre0bin==. |  age_bin==. |  nonwhite==. |  irk==. |  mi_bin==. |  rbw_bin==. |  niha_bin0 ==. | ///
		employ0 ==. | fulltime0 ==. | cig0 ==. | inact0==. | hypertens0 ==. | htmed0 ==. | hyperlipid0 ==. | hifastgluc0 ==. |  ///
		chf0==. |  aci0==. |  ap0==. |  ic0 ==. | icia0 ==. | dig0==. |  diur0==. |  antiarr0==. |  antihyp0==. |  oralhyp0 ==. | ///
		diab0==. | afib0 ==.| cardiom0==. | ///
		employfv_t1 ==. | fulltimefv_t1 ==. | inactfv_t1 ==. | nihafv_t1 ==. |  hypertensfv_t1 ==. | htmedfv_t1==. | hyperlipidfv_t1 == . | hifastglucfv_t1 ==. | ///
		chffv_t1 ==. |  apfv_t1  ==. |  acifv_t1  ==. |  icfv_t1  ==. |  iciafv_t1  ==. |  digfv_t1 ==. |  diurfv_t1 ==. |   antiarrfv_t1 ==. |   antihypfv_t1 ==. |  oralhypfv_t1 ==. | ///
		diabfv_t1 ==. | afibfv_t1==. | cardiomfv_t1 ==.  
 tab adhr_measure_flag 
 
mkspline vis = visit, cubic knots(0, 8, 17)

/* Numerator: Pr(adhr(t)=1|adhr_b, Baseline covariates)*/
/* This model is created in data EXCLUDING the baseline visit*/
/* Create predicted probability at each time point */
/* (Pr(adhr(t) = 1 | adhr_b, baseline))*/

logit adhr_t vis1 vis2 adhbin0 adhr_t1 adhpre0bin ///
		age_bin nonwhite irk mi_bin rbw_bin niha_bin0 ///
		employ0 fulltime0 cig0 inact0 ///
		hypertens0 htmed0 i.hyperlipid0 hifastgluc0 ///
		chf0 ap0 aci0 ic0 icia0 ///
		dig0 diur0 antiarr0 antihyp0 oralhyp0 ///
		diab0 afib0 cardiom0 ///
		if visit > 0 & adhr_t_flag ==1, cluster(id)
predict pnum_0 if adhr_t_flag ==1, pr

logit adh_measure vis1 vis2 adhbin0 adhr_t1 adhpre0bin ///
		age_bin nonwhite irk mi_bin rbw_bin niha_bin0 ///
		employ0 fulltime0 cig0 inact0 ///
		hypertens0 htmed0 i.hyperlipid0 hifastgluc0 ///
		chf0 ap0 aci0 ic0 icia0 ///
		dig0 diur0 antiarr0 antihyp0 oralhyp0 ///
		diab0 afib0 cardiom0 ///
		if visit > 0 & adhr_measure_flag ==1, cluster(id) 
predict pmsrnum_0  if adhr_measure_flag ==1, pr

/* Denominator: Pr(adhr(t)=1|adhr_b, Baseline covariates, Time-varying covariates)*/
/* Create predicted probability at each time point */
/* (Pr(adhr(t) = 1 | adhr_b, baseline, time-varying covariates))*/

logit adhr_t vis1 vis2 adhbin0 adhr_t1 adhpre0bin ///
		age_bin nonwhite irk mi_bin rbw_bin niha_bin0 ///
		employ0 fulltime0 cig0 inact0 ///
		hypertens0 htmed0 i.hyperlipid0 hifastgluc0 ///
		chf0 ap0 aci0 ic0 icia0 ///
		dig0 diur0 antiarr0 antihyp0 oralhyp0 ///
		diab0 afib0 cardiom0 ///		
		employfv fulltimefv inactfv nihafv ///
		hypertensfv htmedfv i.hyperlipidfv hifastglucfv ///
		chffv apfv acifv icfv iciafv ///
		digfv diurfv antiarrfv antihypfv oralhypfv ///
		diabfv afibfv cardiomfv ///
		if visit > 0 & adhr_t_flag ==1, cluster(id)
predict pdenom_0 if adhr_t_flag ==1, pr

logit adh_measure vis1 vis2 adhbin0 adhr_t1 adhpre0bin ///
		age_bin nonwhite irk mi_bin rbw_bin niha_bin0 ///
		employ0 fulltime0 cig0 inact0 ///
		hypertens0 htmed0 i.hyperlipid0 hifastgluc0 ///
		chf0 ap0 aci0 ic0 icia0 ///
		dig0 diur0 antiarr0 antihyp0 oralhyp0 ///
		diab0 afib0 cardiom0 ///		
		employfv_t1 fulltimefv_t1 inactfv_t1 nihafv_t1 ///
		hypertensfv_t1 htmedfv_t1 i.hyperlipidfv_t1 hifastglucfv_t1 ///
		chffv_t1 apfv_t1 acifv_t1 icfv_t1 iciafv_t1 ///
		digfv_t1 diurfv_t1 antiarrfv_t1 antihypfv_t1 oralhypfv_t1 ///
		diabfv_t1 afibfv_t1 cardiomfv_t1 ///
		if visit > 0 & adhr_measure_flag ==1, cluster(id)
predict pmsrden_0  if adhr_measure_flag ==1, pr


/*sort by ID and visit*/
sort id visit

/*Calculate the weights*/ 
gen numcont = 1 if visit == 0
gen dencont = 1 if visit == 0
replace pnum_0 = adhr_t if pnum_0 == . 
replace pdenom_0 = adhr_t if pdenom_0 == . 
replace numcont = adhr_t*pnum_0 + (1-adhr_t)*(1-pnum_0) if adhr_t != . 
replace dencont = adhr_t*pdenom_0 + (1-adhr_t)*(1-pdenom_0) if adhr_t != . 
replace numcont = 1 if adhr_t == . 
replace dencont = 1 if adhr_t == . 

gen numcont_m = 1 if visit == 0 
gen dencont_m = 1 if visit == 0 
replace numcont_m = pmsrnum_0 if adhr_t !=. & pmsrnum_0 !=.
replace dencont_m = pmsrden_0 if adhr_t !=. & pmsrnum_0 !=.
replace numcont_m = (1 - pmsrnum_0) if adhr_t ==. & pmsrnum_0 !=.
replace dencont_m = (1 - pmsrden_0) if adhr_t ==. & pmsrnum_0 !=.
replace numcont_m = 1 if pmsrnum_0 ==.
replace dencont_m = 1 if pmsrnum_0 ==.

gen _t = visit + 1
gen k1_0 = 1 if _t == 1
gen k1_w = 1 if _t == 1
replace k1_0 = numcont*k1_0[_n-1] if _t > 1
replace k1_w = dencont*k1_w[_n-1] if _t > 1


gen m1_0 = 1 if _t == 1
gen m1_w = 1 if _t == 1
replace m1_0 = numcont_m*m1_0[_n-1] if _t > 1
replace m1_w = dencont_m*m1_w[_n-1] if _t > 1

gen unstabw_k = 1.0/k1_w
gen stabw_k = k1_0/k1_w
gen unstabw_m = 1.0/m1_w
gen stabw_m = m1_0/m1_w

gen unstabw = unstabw_k*unstabw_m
gen stabw = stabw_k*stabw_m

*Select last visit time points 
by id, sort: egen maxVisit = max(visit) if visit < .
*list id visit maxVisit if maxVisit <14
tab maxVisit
*list id visit maxVisit dth5 if maxVisit == 1
drop if visit != maxVisit
/*calculate 99th percentile & truncate stabilized weights*/
gen stabw_trunc = stabw
quietly summarize stabw, detail
replace stabw_trunc = r(p99) if stabw_trunc > r(p99)

summarize stabw_trunc
summarize unstabw 
summarize stabw 
summarize unstabw_k
summarize stabw_k
summarize unstabw_m

*Preparing data for standardization                       
*Duplicating data and indicating new set (index=1)
expand 2, generate(index)
*Duplicate original set again for a third set where index=2 
expand 2 if index == 0, generate(index2)
*drop index2 and recode that set as index = -1 
replace index = -1  if index2 ==1
drop index2
*Check index variable to make sure they're all equal data sets 
tab index 

*Sets 1 and -1 are for standardization, so set 5yr mortality outcome to missing and 
*adherence exposure to 0 or 1 for each set 
replace dth5 = . if index != -1
replace adhx15bin = 0 if index == 0
replace adhx15bin = 1 if index == 1

*Check structure, original has mean between 0 and 1, -1 mean of 0, 1 mean of 1 
by index, sort: summarize adhx15bin
by adhx15bin, sort: summarize stabw_trunc
by index, sort: tab adhx15bin, missing

*Run adjusted regression with  adherence measure (only runs with index=-1)
logit  dth5 adhx15bin adhpre0bin age_bin nonwhite irk mi_bin rbw_bin niha_bin0 ///
		employ0 fulltime0 cig0 inact0 hypertens0 htmed0 i.hyperlipid0 hifastgluc0 ///
		chf0 ap0 aci0 ic0 icia0 dig0 diur0 antiarr0 antihyp0 oralhyp0 diab0 afib0 cardiom0 ///
		if visit == maxVisit [pweight = stabw_trunc] 
				
*Get logistic prediction for all data sets 
predict predY, pr 

*Summarize linear predictions by standardized set* 
by index, sort: summarize predY
**give predicted mortality based on adherence as defined in original study 
quietly summarize predY if(index == -1)
matrix input observe = (-1,`r(mean)')
quietly summarize predY if(index == 0)
matrix observe = (observe \0,`r(mean)')
quietly summarize predY if(index == 1)
matrix observe = (observe \1,`r(mean)')
matrix observe = (observe \., observe[3,2]-observe[2,2]) 
*Add some row/column descriptions and print results to screen*
matrix rownames observe = observed E(Y(a=0)) E(Y(a=1)) difference
matrix colnames observe = index value
matrix list observe





******************************************************************************************************************
******************************************************************************************************************
********************************************All analyses**********************************************************
******************************************************************************************************************
******************************************************************************************************************

*******************************
*****A. Unadjusted Analyses****
*******************************

**1. 1980 dataset, 1980 adherence measure**
*Import Data 
use "<path>\expertdag_wide_orig.dta", clear
*Unadjusted Risk Differences and regressional analysis old calculation 
tab old_adhx15bin dth5
csi 245 279 579 1527
reg old_adhx15bin dth5

**2. 1980 dataset, 2016 adherence measure**
*Import Data 
use "<path>\expertdag_wide_orig.dta", clear
*Unadusted Risk Differences and regression analysis new calculation 
*Generate 2x2 table 
tab adhx15bin dth5
*risk difference calculation 
csi 131 360 315 1607 
reg adhx15bin dth5

**3. 2022 dataset -- full covariate list, 1980 adherence measure**
*Import Data 
use "<path>\expertdag_wide.dta", clear
*Unadjusted Risk Differences and regressional analysis old calculation 
tab old_adhx15bin dth5
csi 247 288 590 1577
reg old_adhx15bin dth5

**4. 2022 dataset -- full covariate list, 2016 adherence measure**
*Import Data 
use "<path>\expertdag_wide.dta", clear
*Unadusted Risk Differences and regression analysis new calculation 
*Generate 2x2 table 
tab adhx15bin dth5
*risk difference calculation 
csi 133 369 320 1659
reg adhx15bin dth5


**5. 2022 dataset -- subset covariate list, 1980 adherence measure**
*Import Data 
use "<path>\expertdag_wide_subset.dta", clear
*Unadjusted Risk Differences and regressional analysis old calculation 
tab old_adhx15bin dth5
csi 247 289 592 1578
reg old_adhx15bin dth5

**6. 2022 dataset -- subset covariate list, 2016 adherence measure**
*Import Data 
use "<path>\expertdag_wide_subset.dta", clear
*Unadusted Risk Differences and regression analysis new calculation 
*Generate 2x2 table 
tab adhx15bin dth5
*risk difference calculation 
csi 133 370 321 1661
reg adhx15bin dth5


********************************
*****B. Linear Regression*******
********************************

**1. 1980 dataset, 1980 adherence measure, 1980 covariates**
use "<path>\expertdag_wide_orig.dta", clear
reg dth5 i.old_adhx15bin age_bin nonwhite mi_bin niha_bin1 rbw_bin ///
			chf aci ap ic icia dig diur irk antiarr antihyp oralhyp  ///
			cardiom stelev hifastgluc cig inact anyqqs anystdep ///
			anytwave fveb vcd hiheart hisysbp hidiasbp hibili hiserchol  ///
			hisertrigly hiseruric hiseralk hiplasurea hionegluc hiwhitecell  ///
			hineut hihemat 
margins, dydx(old_adhx15bin) 
margins i.old_adhx15bin

**2. 1980 dataset, 2016 adherence measure, 1980 covariates**
use "<path>\expertdag_wide_orig.dta", clear
reg dth5 i.adhx15bin age_bin nonwhite mi_bin niha_bin1 rbw_bin ///
			chf aci ap ic icia dig diur irk antiarr antihyp oralhyp  ///
			cardiom stelev hifastgluc cig inact anyqqs anystdep ///
			anytwave fveb vcd hiheart hisysbp hidiasbp hibili hiserchol  ///
			hisertrigly hiseruric hiseralk hiplasurea hionegluc hiwhitecell  ///
			hineut hihemat 
margins, dydx(adhx15bin) 
margins i.adhx15bin

**3. 2022 dataset -- full covariate list, 2016 adherence measure, 2022 full list covariates**
use "<path>\expertdag_wide.dta", clear
reg dth5 i.adhx15bin age_bin nonwhite adhpre0bin cig rbw_bin inact mi_bin ///
	ap chf aci icia ic irk niha_bin1 cardiom diur antihyp dig oralhyp antiarr ///
	hifastgluc i.hyperlipid diab afib employ fulltime hypertens htmed i.occupation
margins, dydx(adhx15bin) 
margins i.adhx15bin	
	
**4. 2022 dataset -- full covariate list, 1980 adherence measure, 2022 full list covariates**
use "<path>\expertdag_wide.dta", clear
reg dth5 i.old_adhx15bin  age_bin nonwhite adhpre0bin cig rbw_bin inact mi_bin ///
	ap chf aci icia ic irk niha_bin1 cardiom diur antihyp dig oralhyp antiarr ///
	hifastgluc i.hyperlipid diab afib employ fulltime hypertens htmed i.occupation
margins, dydx(old_adhx15bin) 
margins i.old_adhx15bin	


**5. 2022 dataset -- subset covariate list, 2016 adherence measure, 2022 subset  list covariates**
use "<path>\expertdag_wide.dta", clear
reg dth5 i.adhx15bin age_bin nonwhite adhpre0bin cig rbw_bin inact mi_bin ///
	ap chf aci icia ic irk niha_bin1 cardiom diur antihyp dig oralhyp antiarr ///
	hifastgluc
margins, dydx(adhx15bin) 
margins i.adhx15bin	
	
**6. 2022 dataset -- subset covariate list, 1980 adherence measure, 2022 subset  list covariates**
use "<path>\expertdag_wide.dta", clear
reg dth5 i.old_adhx15bin age_bin nonwhite adhpre0bin cig rbw_bin inact mi_bin ///
	ap chf aci icia ic irk niha_bin1 cardiom diur antihyp dig oralhyp antiarr ///
	hifastgluc
margins, dydx(old_adhx15bin) 
margins i.old_adhx15bin	


*****************************
*****Logistic Regression*****
*****************************
**1. 1980 dataset, 1980 adherence measure, 1980 covariates**
use "<path>\expertdag_wide_orig.dta", clear
logit dth5 i.old_adhx15bin age_bin nonwhite mi_bin niha_bin1 rbw_bin ///
			chf aci ap ic icia dig diur irk antiarr antihyp oralhyp  ///
			cardiom stelev hifastgluc cig inact anyqqs anystdep ///
			anytwave fveb vcd hiheart hisysbp hidiasbp hibili hiserchol  ///
			hisertrigly hiseruric hiseralk hiplasurea hionegluc hiwhitecell  ///
			hineut hihemat 
margins, dydx(old_adhx15bin) 
margins i.old_adhx15bin

**2. 1980 dataset, 2016 adherence measure, 1980 covariates**
use "<path>\expertdag_wide_orig.dta", clear
logit dth5 i.adhx15bin age_bin nonwhite mi_bin niha_bin1 rbw_bin ///
			chf aci ap ic icia dig diur irk antiarr antihyp oralhyp  ///
			cardiom stelev hifastgluc cig inact anyqqs anystdep ///
			anytwave fveb vcd hiheart hisysbp hidiasbp hibili hiserchol  ///
			hisertrigly hiseruric hiseralk hiplasurea hionegluc hiwhitecell  ///
			hineut hihemat 
margins, dydx(adhx15bin) 
margins i.adhx15bin

**3. 2022 dataset -- full covariate list, 2016 adherence measure, 2022 full list covariates**
use "<path>\expertdag_wide.dta", clear
logit dth5 i.adhx15bin age_bin nonwhite adhpre0bin cig rbw_bin inact mi_bin ///
	ap chf aci icia ic irk niha_bin1 cardiom diur antihyp dig oralhyp antiarr ///
	hifastgluc i.hyperlipid diab afib employ fulltime hypertens htmed i.occupation
margins, dydx(adhx15bin) 
margins i.adhx15bin	
	
**4. 2022 dataset -- full covariate list, 1980 adherence measure, 2022 full list covariates**
use "<path>\expertdag_wide.dta", clear
logit dth5 i.old_adhx15bin  age_bin nonwhite adhpre0bin cig rbw_bin inact mi_bin ///
	ap chf aci icia ic irk niha_bin1 cardiom diur antihyp dig oralhyp antiarr ///
	hifastgluc i.hyperlipid diab afib employ fulltime hypertens htmed i.occupation
margins, dydx(old_adhx15bin) 
margins i.old_adhx15bin	


**5. 2022 dataset -- subset covariate list, 2016 adherence measure, 2022 subset  list covariates**
use "<path>\expertdag_wide.dta", clear
logit dth5 i.adhx15bin age_bin nonwhite adhpre0bin cig rbw_bin inact mi_bin ///
	ap chf aci icia ic irk niha_bin1 cardiom diur antihyp dig oralhyp antiarr ///
	hifastgluc
margins, dydx(adhx15bin) 
margins i.adhx15bin	
	
**6. 2022 dataset -- subset covariate list, 1980 adherence measure, 2022 subset  list covariates**
use "<path>\expertdag_wide.dta", clear
logit dth5 i.old_adhx15bin age_bin nonwhite adhpre0bin cig rbw_bin inact mi_bin ///
	ap chf aci icia ic irk niha_bin1 cardiom diur antihyp dig oralhyp antiarr ///
	hifastgluc
margins, dydx(old_adhx15bin) 
margins i.old_adhx15bin	

