/*******************************************************************************
title: 	2.1_UI_parametric
author:	Fabian Reutzel
content: 
	0. Define bootstrap function for UI (i.e., IOp) estimates
	1. Standard IOp estimation (Ferreira & Gignoux 2011)
	2. CV IOp estimation (Burnori et al. 2019, EqualChances.org)
	3. Lasso IOp estimation (Hufe et al. 2022)
*******************************************************************************/

clear all 
set more off
do "C:\Users\fabia\OneDrive - Université Paris 1 Panthéon-Sorbonne\IOP and attitudes project\Fabian\do_files\micro_analysis\code_EJPE\0_globals.do"

*define number of bootstrap iterations
gl B 200

*define circumstances
gl circumstances i.urban_birth i.fedu_4adj i.medu_4adj i.pcommunist i.minority

*define variables IOp estimates
gl iop_vars sample_size gin* abs_iop_p abs_iop_l abs_iop_u rel_iop_p rel_iop_l rel_iop_u mld* abs_iop_mld_p abs_iop_mld_l abs_iop_mld_u 

********************************************************************************
**#0. Define bootstrap function for UI (i.e., IOp) estimates
********************************************************************************
capture program drop boot_iop
program boot_iop, rclass
syntax varlist (fv)
tempvar yhat iopabs ioprel ineq iopabs_mld ioprel_mld ineq_mld

*predict counterfacutal distribution mu
reg ln_y `varlist' [fweight=fw], robust
predict `yhat'
replace `yhat'=exp(`yhat') 

*estimate inequality measures
quietly ineqdeco `yhat' [fweight=fw] if `yhat'!=.
gen `iopabs'=r(gini)
gen `iopabs_mld'=r(ge0)
quietly ineqdeco y [fweight=fw] if `yhat'!=.
gen `ineq'=r(gini)
gen `ineq_mld'=r(ge0)
gen `ioprel'=`iopabs'/`ineq'
gen `ioprel_mld'=`iopabs_mld'/`ineq_mld'
return local Ineq=`ineq'
return local IOpAbs= `iopabs'
return local IOpRel= `ioprel'
return local Ineq_mld=`ineq_mld'
return local IOpAbs_mld= `iopabs_mld'
return local IOpRel_mld= `ioprel_mld'
end

********************************************************************************
**#1. Standard IOp estimation (Ferreira & Gignoux 2011)
********************************************************************************
use "$working\LiTS_IOp_data", clear

*define global for all countries in sample 
levelsof iso_code_2, local(countries)
gl countries "`countries'"

*estimate IOp
foreach country in $countries {
	*load data
	use "$working\LiTS_IOp_data", clear
	keep if iso_code_2=="`country'"

	*sample size
	reg ln_y $circumstances [fweight=fw], robust
	gen sample_size=e(N)

	*run bootstrap function 
	bootstrap real(r(Ineq)) real(r(Ineq_mld)) real(r(IOpAbs)) real(r(IOpAbs_mld)) real(r(IOpRel)) real(r(IOpRel_mld)), reps($B): boot_iop $circumstances
	
	*save boot results 
	estat bootstrap, normal
	mat p = e(b)
	mat ci = e(ci_normal)
	gen gini_p = p[1,1]
	gen mld_p = p[1,2]
	gen abs_iop_p = p[1,3]
	gen abs_iop_mld_p = p[1,4]
	gen rel_iop_p = p[1,5]
	gen rel_iop_mld_p = p[1,6]
	gen gini_l = ci[1,1]
	gen mld_l = ci[1,2]
	gen abs_iop_l = ci[1,3]
	gen abs_iop_mld_l = ci[1,4]
	gen rel_iop_l = ci[1,5]
	gen rel_iop_mld_l = ci[1,6]
	gen gini_u = ci[2,1]
	gen mld_u = ci[2,2]
	gen abs_iop_u = ci[2,3]
	gen abs_iop_mld_u = ci[2,4]	
	gen rel_iop_u = ci[2,5]
	gen rel_iop_mld_u = ci[2,6]
	
	*extract & save relevant measures
	keep $iop_vars
	collapse (mean) $iop_vars
	gen iso_code_2 = "`country'"
	order iso_code_2 $iop_vars
	save "$working/iop_standard_`country'", replace
}

*combine country estimates
use "$working/iop_standard_AL", clear
drop if iso_code_2!=""
foreach country in $countries {
append using "$working/iop_standard_`country'"
}
ren * *_s
ren iso_code_2_s iso_code_2
save "$working\iop_standard", replace

********************************************************************************
**#2. CV IOp estimation (Burnori et al. 2019, EqualChances.org)
********************************************************************************
*define additional binary education variables as circumstances
gl origin1 urban_birth
gl origin2 minority 
gl p_occ1 pcommunist	

gl p_edu1 pedu_ter
gl p_edu2 fedu_ter
gl p_edu3 medu_ter

gl p_edu4 pedu_4adj
gl p_edu5 fedu_4adj
gl p_edu6 medu_4adj

gl p_edu7 pedu_uppsec
gl p_edu8 fedu_uppsec
gl p_edu9 medu_uppsec

gl p_edu10 pedu_sec
gl p_edu11 fedu_sec
gl p_edu12 medu_sec 


*define global for all countries in sample 
use "$working\LiTS_IOp_data", clear
levelsof iso_code_2, local(countries)
gl countries "`countries'"

*estimate IOp
foreach country in $countries {
	*load data
	use "$working\LiTS_IOp_data", clear
	keep if iso_code_2=="`country'"

	local all_circ "i.$origin1 i.$origin2 i.$p_occ1 i.$p_edu1 i.$p_edu2 i.$p_edu3 i.$p_edu4 i.$p_edu5 i.$p_edu6 i.$p_edu7 i.$p_edu8 i.$p_edu9 i.$p_edu10 i.$p_edu11 i.$p_edu12" 
	
	*generate all possible models
	local best_rmse 1000^100
	local best_var "error"
	tuples `all_circ' , ///
		 min(3) max(3) cond(!(1&2) !(4&7) !(5&8) !(5&11) !(5&14) !(6&9) !(6&12) !(6&15) !(7&10) !(7&13) !(8&11) !(8&14) !(9&12) !(9&15) !(10&13) !(11&14) !(12&15)) display
		  
	*10-fold cross-validation of alternative models for circumstance selection
	*i.e., selecting the best (most predictive) set of circumstances
	forval i = 1/`ntuples' {
		crossfold regress ln_y `tuple`i''[weight=fw], robust k(10) 
		matrix rmse`i'= r(est)
		gen avg_rmse`i'= (rmse`i'[1,1]+rmse`i'[2,1] + rmse`i'[3,1]+rmse`i'[4,1] + rmse`i'[5,1]+ rmse`i'[6,1]+rmse`i'[7,1]+rmse`i'[8,1]+rmse`i'[9,1]+rmse`i'[10,1])/10
		if avg_rmse`i' < `best_rmse' & avg_rmse`i'!=. {
			local best_rmse avg_rmse`i'
			local best_var `tuple`i''
			gl best_var `best_var'
		}
	}


	**generate all possible models considering interaction terms of selected circumstances
	*generate associated locals
	local var_1: word 1 of `best_var'
	local var_2: word 2 of `best_var'
	local var_3: word 3 of `best_var'
	gl newvar_1 = substr("`var_1'", 3,.)
	gl newvar_2 = substr("`var_2'", 3,.)
	gl newvar_3 = substr("`var_3'", 3,.)
	gl vars "$newvar_1 $newvar_2 $newvar_3"

	egen n_var_1=nvals($newvar_1)
	egen n_var_2=nvals($newvar_2)
	egen n_var_3=nvals($newvar_3)

	local circ1 "`var_1' `var_2' `var_3'"
	local circ2 "`var_1' `var_2'#`var_3'"
	local circ3 "`var_2' `var_1'#`var_3'"
	local circ4 "`var_3' `var_1'#`var_2'"
	local circ5 "`var_1' `var_2' `var_1'#`var_3'"
	local circ6 "`var_1' `var_2' `var_2'#`var_3'"
	local circ7 "`var_1' `var_3' `var_1'#`var_2'"
	local circ8 "`var_1' `var_3' `var_2'#`var_3'"
	local circ9 "`var_3' `var_2' `var_1'#`var_2'"
	local circ10 "`var_3' `var_2' `var_1'#`var_3'"
	local circ11 "`var_1' `var_2' `var_3'"
	local circ12 "`var_1' `var_2' `var_3' `var_1'#`var_2'"
	local circ13 "`var_1' `var_2' `var_3' `var_2'#`var_3'"
	local circ14 "`var_1' `var_2' `var_3' `var_1'#`var_3'"
	local circ15 "`var_1'#`var_2'#`var_3' "

	if (n_var_1* n_var_2* n_var_3)<2000 {
		local ncirc "15"
	}
	if (n_var_1* n_var_2* n_var_3) >2000 {
		local ncirc "14"
	}
	display "`ncirc'"

	*generate all possible models 
	local best_rmse 10000^10
	local best_model "error"
	set emptycells drop

	*10-fold cross-validation of alternative models for circumstance interaction
	*i.e., selecting the best (most predictive) interaction of the selected circumstances
	forval i = 1(1)`ncirc'{
			crossfold regress ln_y `circ`i'' [weight=fw], robust k(10) 
			matrix rmse`i'= r(est)
			gen new_avg_rmse`i'= (rmse`i'[1,1]+rmse`i'[2,1] + rmse`i'[3,1]+rmse`i'[4,1] + rmse`i'[5,1]+ rmse`i'[6,1]+rmse`i'[7,1]+rmse`i'[8,1]+rmse`i'[9,1]+rmse`i'[10,1])/10
			if new_avg_rmse`i' < `best_rmse' & new_avg_rmse`i' !=. {
				local best_rmse new_avg_rmse`i'
				local best_model `circ`i''
				gl best_model `best_model'
			}
	}

	*single run (=> get best model for full sample)
	reg ln_y `best_model' [fweight=fw], robust
	*outreg2 using "$working/bestmodel_cv_`country'.tex", label tex(fra) sideway replace 
	gen sample_size=e(N)

	*bootstrap relevant measures
	*re: only the estimates of the best_model are bootstraped not procedure itself
	bootstrap real(r(Ineq)) real(r(Ineq_mld)) real(r(IOpAbs)) real(r(IOpAbs_mld)) real(r(IOpRel)) real(r(IOpRel_mld)), reps($B): boot_iop `best_model'
	estat bootstrap, normal
	mat p = e(b)
	mat ci = e(ci_normal)
	gen gini_p = p[1,1]
	gen mld_p = p[1,2]
	gen abs_iop_p = p[1,3]
	gen abs_iop_mld_p = p[1,4]
	gen rel_iop_p = p[1,5]
	gen rel_iop_mld_p = p[1,6]
	gen gini_l = ci[1,1]
	gen mld_l = ci[1,2]
	gen abs_iop_l = ci[1,3]
	gen abs_iop_mld_l = ci[1,4]
	gen rel_iop_l = ci[1,5]
	gen rel_iop_mld_l = ci[1,6]
	gen gini_u = ci[2,1]
	gen mld_u = ci[2,2]
	gen abs_iop_u = ci[2,3]
	gen abs_iop_mld_u = ci[2,4]	
	gen rel_iop_u = ci[2,5]
	gen rel_iop_mld_u = ci[2,6]
	
	*extract & save relevant measures
	keep $iop_vars
	collapse (mean) $iop_vars
	gen iso_code_2 = "`country'"
	order iso_code_2 $iop_vars
	save "$working/iop_cv_`country'", replace
}

*combine country estimates
use "$working/iop_cv_AL", clear
drop if iso_code_2!=""
foreach country in $countries {
append using "$working/iop_cv_`country'"
}
ren * *_c
ren iso_code_2_c iso_code_2
save "$working\iop_cv", replace

********************************************************************************
**#3. Lasso IOp estimation (Hufe et al. 2022)
********************************************************************************
use "$working\LiTS_IOp_data", clear

*define global for all countries in sample 
levelsof iso_code_2, local(countries)
gl countries "`countries'"

*estimate IOp
foreach country in $countries {
	*load data
	use "$working\LiTS_IOp_data", clear
	local country AL
	keep if iso_code_2=="`country'"

	*single run (=> get best model for full sample)
	cvlasso ln_y $circumstances , nfolds(10) seed(123) postres lopt
	local best_model `e(selected)'
	reg ln_y `best_model'
	*outreg2 using "$working/bestmodel_lasso_`country'.tex", label tex(fra) sideway replace 	
	gen sample_size=e(N)
	
	*reg ln_y on ln_y if model does not converge
	if "`best_model'"=="" local best_model "ln_y "
	
	*run bootstrap function
	bootstrap real(r(Ineq)) real(r(Ineq_mld)) real(r(IOpAbs)) real(r(IOpAbs_mld)) real(r(IOpRel)) real(r(IOpRel_mld)), reps($B): boot_iop `best_model'
	estat bootstrap, normal
	mat p = e(b)
	mat ci = e(ci_normal)
	gen gini_p = p[1,1]
	gen mld_p = p[1,2]
	gen abs_iop_p = p[1,3]
	gen abs_iop_mld_p = p[1,4]
	gen rel_iop_p = p[1,5]
	gen rel_iop_mld_p = p[1,6]
	gen gini_l = ci[1,1]
	gen mld_l = ci[1,2]
	gen abs_iop_l = ci[1,3]
	gen abs_iop_mld_l = ci[1,4]
	gen rel_iop_l = ci[1,5]
	gen rel_iop_mld_l = ci[1,6]
	gen gini_u = ci[2,1]
	gen mld_u = ci[2,2]
	gen abs_iop_u = ci[2,3]
	gen abs_iop_mld_u = ci[2,4]	
	gen rel_iop_u = ci[2,5]
	gen rel_iop_mld_u = ci[2,6]
	
	*set IOp estimates to missing if model did not converge
	replace abs_iop_p = . if abs(1-abs_iop_p)<0.01
	replace abs_iop_mld_p = . if abs(1-abs_iop_mld_p)<0.01
	replace abs_iop_l = . if abs(1-abs_iop_l)<0.01
	replace abs_iop_mld_l = . if abs(1-abs_iop_mld_l)<0.01
	replace abs_iop_u = . if abs(1-abs_iop_u)<0.01
	replace abs_iop_mld_u = . if abs(1-abs_iop_mld_u)<0.01
	replace rel_iop_p = . if abs(1-rel_iop_p)<0.01
	replace rel_iop_mld_p = . if abs(1-rel_iop_mld_p)<0.01
	replace rel_iop_l = . if abs(1-rel_iop_l)<0.01
	replace rel_iop_mld_l = . if abs(1-rel_iop_mld_l)<0.01
	replace rel_iop_u = . if abs(1-rel_iop_u)<0.01
	replace rel_iop_mld_u = . if abs(1-rel_iop_mld_u)<0.01

	*extract & save relevant measures
	keep $iop_vars
	collapse (mean) $iop_vars
	gen iso_code_2 = "`country'"
	order iso_code_2 $iop_vars
	save "$working/iop_lasso_`country'", replace
}

*combine country estimates
use "$working/iop_lasso_AL", clear
drop if iso_code_2!=""
foreach country in $countries {
append using "$working/iop_lasso_`country'"
}
ren * *_l
ren iso_code_2_l iso_code_2
save "$working\iop_lasso", replace