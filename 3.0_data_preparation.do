/*******************************************************************************
title: 	3.0_data_preparation
author:	Fabian Reutzel
content: 
	1. merge IOp estimates & LiTS
	2. adjust country-level variables
	3. identify countries for attitude estimation sample
	4. label variables for output
*******************************************************************************/
clear all 
set more off
do "C:\Users\fabia\OneDrive - Université Paris 1 Panthéon-Sorbonne\IOP and attitudes project\Fabian\do_files\micro_analysis\code_EJPE\0_globals.do"

********************************************************************************
**#1. merge IOp estimates & LiTS
********************************************************************************
*convert forest UI estimates to .dta (generated via R)
import delimited "$working\iop_forest_complete.csv", varnames(1) clear
drop v1
ren * *_f
ren countries_f iso_code_2
save "$working\iop_forest_complete.dta",replace
import delimited "$working\iop_forest_complete_all.csv", varnames(1) clear
drop v1
ren * *_fa
ren countries_fa iso_code_2
save "$working\iop_forest_complete_all.dta",replace
import delimited "$working\iop_forest_incomplete.csv", varnames(1) clear
drop v1
ren * *_fi
ren countries_fi iso_code_2
save "$working\iop_forest_incomplete.dta",replace

*merge UI estimates 
use "$working\iop_standard.dta", clear
merge m:1 iso_code_2 using "$working\iop_cv.dta", keep(match) nogen
merge m:1 iso_code_2 using "$working\iop_lasso.dta", keep(match) nogen
merge m:1 iso_code_2 using "$working\iop_forest_complete.dta", keep(match) nogen
merge m:1 iso_code_2 using "$working\iop_forest_complete_all.dta", keep(match) nogen
merge m:1 iso_code_2 using "$working\iop_forest_incomplete.dta", keep(match) nogen
save "$working\iop_estimates.dta", replace

*add UI estimates to LiTS
use "$working\LiTS_clean.dta", clear 
merge m:1 iso_code_2 using "$working\iop_estimates.dta", keep(match) nogen

********************************************************************************
**#2. adjust country-level variables
********************************************************************************

*adjust variable names
ren gini_disp gini_p_swiid
ren gini_disp_l gini_l_swiid
ren gini_disp_u gini_u_swiid
ren abs_iop_mld* UI_mld*
ren abs_iop* UI_gini*

*generate inequality residual IR 
foreach m in s c l f fa fi{
gen IR_gini_`m' = gini_p_`m' - UI_gini_p_`m'
gen IR_mld_`m' = mld_p_`m' - UI_mld_p_`m'
}

*save country-level dataset for summary graphs I/UI
preserve
collapse gini* mld* UI* , by(country iso_code_2)
drop *mkt* *se*
save "$working\country_data", replace
restore

*abreviate I/UI point estimates names
ren UI_gini_p* UI_gini*
ren UI_mld_p* UI_mld*
ren gini_p* gini*
ren mld_p* mld*

*LiTS-based poverty estimates & interaction term
egen pov_cutoff = median(wini_hhpc_mcons), by(cname)
replace pov_cutoff = pov_cutoff*0.6
gen pov_indicator = (wini_hhpc_mcons<pov_cutoff) if wini_hhpc_mcons!=.
egen pov_rate = mean(pov_indicator) if pov_indicator!=., by(cname)
gen pov_rate_int = 1- pov_rate
gen pov_int = 1- poverty 
gen pov = poverty

*generate dummy for new EU member states
gen new_eu = (country=="Romania"|country=="Bulgaria"|country=="Slovenia"|country=="Slovak Rep."|country=="Poland"|country=="Lithuania"|country=="Latvia"|country=="Hungary"|country=="Estonia"|country=="Czech Rep."|country=="Cyprus"|country=="Croatia")

*adjust VD regime variable: combine autocracies (add Uzbekistan)
ren vd_regime vd_regime_og
gen vd_regime = vd_regime_og
replace vd_regime = 1 if vd_regime==0 //only Uzbekistan 
gen vd_democracy = (vd_regime_og>1)
lab def vd_regime_og 0 "closed autocracy" 1 "electoral autocracy" 2 "electoral democracy" 3 "liberal democracy"
lab def vd_regime 1 "Autocracy" 2 "electoral Democracy" 3 "liberal Democracy"
lab def democracy 0 "Autocracy" 1 "Democracy" 
lab val vd_regime_og vd_regime_og
lab val vd_regime vd_regime
lab val vd_democracy democracy

*rescale libdem 
replace vd_index = vd_index*100

*log-transform GDPpc
replace gdppc = log(gdppc)

********************************************************************************
**#3. identify countries for attitude estimation sample
********************************************************************************
*indentify outliers based on gini matching SWIID
gen sample_gini = 1
*mark countries with LiTS-based gini above the 99.99% CI of SWIID
replace sample_gini = 0 if gini_l_s>(gini_swiid+(gini_u_swiid-gini_swiid)*3.291/1.96) 
tab cname if sample_gini==0
gen dist_cut_off = gini_l_s -(gini_swiid+(gini_u_swiid-gini_swiid)*3.291/1.96) 
tab dist_cut_off if country=="Slovakia"
*=> difference to cut-off is .006 so reasonably close for inclusion (Results are robust to exclusion)
replace sample_gini = 1 if country=="Slovakia"

*justify exclusion Tajikistan based on large discrapancy to SWIID
gen diff_gini = gini_f - gini_swiid
tab country diff_gini 
sum gini_f 		if iso_code_2=="TJ" 
loc ginifTJ: 		display %04.3f round(r(mean),.001) 
sum gini_swiid 	if iso_code_2=="TJ" 
loc giniswiidTJ: 	display %04.3f round(r(mean),.001) 
*drop if iso_code_2=="TJ" // -.101

*save descriptives to be displayed in text
capture: file close I_descriptives
file open I_descriptives using "$tables/I_descriptives.tex", write replace
    file write I_descriptives "\newcommand{\ginifTJ}{`ginifTJ'}" _n	
    file write I_descriptives "\newcommand{\giniswiidTJ}{`giniswiidTJ'}" _n	
file close I_descriptives

*drop outliers based on gini not matching SWIID
drop if sample_gini==0
drop sample_gini

********************************************************************************
**#4. label variables for output
********************************************************************************
ren gini_* I_gini_*
ren mld_* I_mld_*
lab var I_gini_swiid "Total Inequality (SWIID)"
lab var I_gini_f "Total Inequality"
lab var I_gini_fa "I Full Pop."
lab var UI_gini_f "Unfair Inequality"
lab var UI_gini_fa "UI Full Pop."
lab var UI_gini_s "UI Standard"
lab var UI_gini_c "UI CV"
lab var UI_gini_l "UI Lasso"
lab var IR_gini_f "Inequality Residual"
lab var IR_gini_fa "IR Full Pop."
lab var IR_gini_s "IR Standard"
lab var IR_gini_c "IR CV"
lab var IR_gini_l "IR Lasso"
lab var I_mld_f "Total Inequality (MLD)"
lab var UI_mld_f "Unfair Inequality (MLD)"
lab var IR_mld_f "Inequality Residual(MLD)"
lab var vd_democracy "Democracy"
lab var vd_regime "Regime Type (VDem)"
lab var vd_index "Democracy Index"
lab var governance "Governance"
lab var commu_exp "Communist Experience"
lab var mob_exp "Mobility Experience"
lab var b_life_satisfaction "Life Satisfaction"
lab var urban "Urban Residence"
lab var gender "Female"
lab var edu_3c "Education"
lab var age "Age"
lab var age_2 "Age$^2$"
lab var pcommunist "Communist Partymembership Parents"
lab var pedu_4adj "Parental Education"
lab var minority "Minority"
lab var cons_xtile "Consumption Decile"
lab var gdppc "log GDP per capita"
lab var gdppc_growth_5y_annu "GDP per capita Growth" 
lab var unempl_5y "Unemployment"
lab var govexp_5y "Gov. Expenditure"
lab var pov_rate "Poverty"
lab var pov_rate_int "(1-Poverty)"
lab var pov_rate "Poverty"
lab var pov_int "(1-Poverty)"
lab var pov "Poverty"
lab var new_eu "New EU Member"

keep supdem I_* UI_* IR_* vd_democracy vd_regime vd_index ///
	gov* gdppc* unempl_5y pov* new_eu cname iso_code_2 country ///
	cons_xtile mob_exp commu_exp b_life_satisfaction urban gender edu_3c age* pcommunist pedu_4adj minority cohort_10y

save "$working\LiTS_analysis_data.dta", replace