/*******************************************************************************
title: 	3.2_regressions_analysis
author:	Fabian Reutzel
content: 
	1. Main Regression Analysis
	1.0 define controls
	1.1 Main Results - Gini - Tables 1 & A4-A6 
	1.2 Main Results - MLD - Tables 2 & A7
	1.3 Marginal Effects - Figure 4
	2. Sensitivity Analysis
	2.1 Comparison UI Estimation Methodologies - Tables A8 & A9
	2.2 Coefficient Robustness - leave one out - Figures A4 & A5 
	2.3 Interaction Interaction sociotropic and egocentric Dimension - Table A11
	2.4 Cohort Effects - Table A12
	2.5 Poverty Interaction - Tables A13 & A14
	2.6 Growth Interaction - Table A15-A17
	2.7 Country-level Controls - GDPpc, Contemporary, no Controls - Tables A18-20
	2.8 Country-level Controls - LASSO - Table A21
	2.9 Bootstrapped SEs - Table A22
	2.10 Multilevel Model - A23 & A24
*******************************************************************************/
clear all 
set more off
do "C:\Users\fabia\OneDrive - Université Paris 1 Panthéon-Sorbonne\IOP and attitudes project\Fabian\do_files\micro_analysis\code_EJPE\0_globals.do"

********************************************************************************
********************************************************************************
**#1. Main Regression Analysis
********************************************************************************
********************************************************************************
	
********************************************************************************
**#1.0 define controls
********************************************************************************
*individual-level controls
gl i_controls gender i.edu_3c b_life_satisfaction age age_2 minority

*country-level controls
gl c_controls gdppc gdppc_growth_5y_annu unempl_5y govexp_5y new_eu governance

*all controls
gl c_i_controls_cons_xtile $i_controls cons_xtile mob_exp $c_controls

********************************************************************************
**#1.1 Main Results - Gini - Tables 1 & A4-A6 
********************************************************************************
use "$working/LiTS_analysis_data", clear
est clear
drop if iso_code_2=="RU" | iso_code_2=="MK" 

foreach d in vd_democracy vd_index {

*adjust democracy variable	
if "`d'"=="vd_index" 		gl d "c.`d'"
if "`d'"=="vd_democracy" 	gl d "i.`d'" 
	 
*run regressions
eststo I: 		probit supdem I_gini_f $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 
eststo Ii: 		probit supdem I_gini_f $d#c.I_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 
eststo UI: 		probit supdem UI_gini_f $d $c_i_controls_cons_xtile , vce(cluster cname) noomit
eststo UIi: 	probit supdem UI_gini_f $d#c.UI_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname) noomit
eststo I_UI: 	probit supdem UI_gini_f I_gini_f $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 
eststo I_UIi: 	probit supdem UI_gini_f I_gini_f $d#c.UI_gini_f $d#c.I_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 
eststo IR_UI: 	probit supdem UI_gini_f IR_gini_f $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 
eststo IR_UIi: 	probit supdem UI_gini_f IR_gini_f $d#c.UI_gini_f $d#c.IR_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname) noomit  

*Table 1
if ("`d'"=="vd_democracy") {
	noi esttab I Ii UI UIi I_UI I_UIi IR_UI IR_UIi using "$tables/tab_`d'.tex", replace ///
	eqlabels(none) nodepvars nonotes nomtitles noomitted nogaps booktabs label b(3) se(3) star(* .1 ** .05 *** .01) ///
	collabels(none) ///
	keep(I_gini_f 1.`d'#c.I_gini_f UI_gini_f 1.`d'#c.UI_gini_f IR_gini_f 1.`d'#c.IR_gini_f cons_xtile 1.`d'#c.cons_xtile mob_exp 1.`d'#c.mob_exp 1.`d') ///
	order(I_gini_f 1.`d'#c.I_gini_f UI_gini_f 1.`d'#c.UI_gini_f IR_gini_f 1.`d'#c.IR_gini_f cons_xtile 1.`d'#c.cons_xtile mob_exp 1.`d'#c.mob_exp 1.`d') ///
	stats(N N_clust r2_p , fmt(0 0 3) ///
	labels("Number of individuals" "Number of countries" "pseudo \$R^2$"))
}
*Table A6
if ("`d'"=="vd_index") {
	noi esttab I Ii UI UIi I_UI I_UIi IR_UI IR_UIi using "$tables/tab_`d'.tex", replace ///
	eqlabels(none) nodepvars nonotes nomtitles noomitted nogaps booktabs label b(3) se(3) star(* .1 ** .05 *** .01) ///
	collabels(none) ///
	keep(I_gini_f $d#c.I_gini_f UI_gini_f $d#c.UI_gini_f IR_gini_f $d#c.IR_gini_f cons_xtile $d#c.cons_xtile mob_exp $d#c.mob_exp `d') ///
	order(I_gini_f $d#c.I_gini_f UI_gini_f $d#c.UI_gini_f IR_gini_f $d#c.IR_gini_f cons_xtile $d#c.cons_xtile mob_exp $d#c.mob_exp `d') ///
	stats(N N_clust r2_p , fmt(0 0 3) ///
	labels("Number of individuals" "Number of countries" "pseudo \$R^2$"))
}
*Table A4 (extended output)
if ("`d'"=="vd_democracy") {
	noi esttab I Ii UI UIi I_UI I_UIi IR_UI IR_UIi using "$tables/tab_`d'_all_coef.tex", replace ///
	eqlabels(none) nodepvars nonotes nomtitles noomitted nogaps booktabs nobaselevels label b(3) se(3) star(* .1 ** .05 *** .01) ///
	collabels(none) ///
	order(I_gini_f 1.`d'#c.I_gini_f UI_gini_f 1.`d'#c.UI_gini_f IR_gini_f 1.`d'#c.IR_gini_f cons_xtile 1.`d'#c.cons_xtile mob_exp 1.`d'#c.mob_exp 1.`d') ///
	stats(N N_clust r2_p , fmt(0 0 3) ///
	labels("Number of individuals" "Number of countries" "pseudo \$R^2$"))
}
}

*save coefficients to be displayed in text
local d vd_democracy
gl d "i.`d'"
probit supdem I_gini_f $d#c.I_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 
loc betaI: display %04.3f round(_b[I_gini_f] + _b[1.vd_democracy#c.I_gini_f],0.0001)
probit supdem UI_gini_f I_gini_f $d#c.UI_gini_f $d#c.I_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname) noomit
loc betaIi: display %04.3f round(_b[I_gini_f] + _b[1.vd_democracy#c.I_gini_f],0.0001)
capture: file close macros_regression_analysis
file open macros_regression_analysis using "$tables/macros_regression_analysis.tex", write replace
    file write macros_regression_analysis "\newcommand{\betaI}{`betaI'}" _n	
    file write macros_regression_analysis "\newcommand{\betaIi}{`betaIi'}" _n	
file close macros_regression_analysis

*include Russia & North Macedonia 
use "$working/LiTS_analysis_data", clear
est clear 

*adjust democracy variable	
local d vd_democracy
gl d "i.`d'"
	
*run regressions
eststo I: 		probit supdem I_gini_f $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 
eststo Ii: 		probit supdem I_gini_f $d#c.I_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 
eststo UI: 		probit supdem UI_gini_f $d $c_i_controls_cons_xtile , vce(cluster cname) noomit
eststo UIi: 	probit supdem UI_gini_f $d#c.UI_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname) noomit
eststo IR_UI: 	probit supdem UI_gini_f IR_gini_f $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 
eststo IR_UIi: 	probit supdem UI_gini_f IR_gini_f $d#c.UI_gini_f $d#c.IR_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 
eststo I_UI:	probit supdem UI_gini_f I_gini_f $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 
eststo I_UIi: 	probit supdem UI_gini_f I_gini_f $d#c.UI_gini_f $d#c.I_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 

*Table A5
noi esttab I Ii UI UIi I_UI I_UIi IR_UI IR_UIi using "$tables/tab_`d'_inclRUMK.tex", replace ///
eqlabels(none) nodepvars nonotes nomtitles noomitted nogaps booktabs label b(3) se(3) star(* .1 ** .05 *** .01) ///
collabels(none) ///
keep(I_gini_f 1.`d'#c.I_gini_f UI_gini_f 1.`d'#c.UI_gini_f IR_gini_f 1.`d'#c.IR_gini_f cons_xtile 1.`d'#c.cons_xtile mob_exp 1.`d'#c.mob_exp 1.`d') ///
order(I_gini_f 1.`d'#c.I_gini_f UI_gini_f 1.`d'#c.UI_gini_f IR_gini_f 1.`d'#c.IR_gini_f cons_xtile 1.`d'#c.cons_xtile mob_exp 1.`d'#c.mob_exp 1.`d') ///
stats(N N_clust r2_p , fmt(0 0 3) ///
labels("Number of individuals" "Number of countries" "pseudo \$R^2$"))

********************************************************************************
**#1.2 Main Results - MLD - Tables 2 & A7
********************************************************************************
use "$working/LiTS_analysis_data", clear
est clear
drop if iso_code_2=="RU" | iso_code_2=="MK" 

foreach d in vd_democracy vd_index {

*adjust democracy variable	
if "`d'"=="vd_index" 		gl d "c.`d'"
if "`d'"=="vd_democracy" 	gl d "i.`d'" 
	
*run regressions
eststo I: 				probit supdem I_mld_f $d $c_i_controls_cons_xtile, vce(cluster cname) noomit
eststo Ii: 				probit supdem I_mld_f $d#c.I_mld_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile, vce(cluster cname) noomit 
eststo UI_mld_f: 		probit supdem UI_mld_f $d $c_i_controls_cons_xtile, vce(cluster cname) noomit
eststo UI_mld_fi: 		probit supdem UI_mld_f $d#c.UI_mld_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile, vce(cluster cname) noomit
eststo IUI_mld_f: 		probit supdem UI_mld_f I_mld_f $d $c_i_controls_cons_xtile, vce(cluster cname) noomit 
eststo IUI_mld_fi: 		probit supdem UI_mld_f I_mld_f $d#c.UI_mld_f $d#c.I_mld_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile, vce(cluster cname) noomit 
eststo IR_UI_mld_f: 	probit supdem UI_mld_f IR_mld_f $d $c_i_controls_cons_xtile, vce(cluster cname) noomit 
eststo IR_UI_mld_fi: 	probit supdem UI_mld_f IR_mld_f $d#c.UI_mld_f $d#c.IR_mld_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile, vce(cluster cname) noomit 

*Table 2
if ("`d'"=="vd_democracy") {
	noi esttab I Ii UI_mld_f UI_mld_fi IUI_mld_f IUI_mld_fi IR_UI_mld_f IR_UI_mld_fi using "$tables/tab_`d'_mld.tex", replace ///
	eqlabels(none) nodepvars nonotes nomtitles noomitted nogaps booktabs label b(3) se(3) star(* .1 ** .05 *** .01) ///
	collabels(none) ///
	keep(I_mld_f 1.`d'#c.I_mld_f UI_mld_f 1.`d'#c.UI_mld_f IR_mld_f 1.`d'#c.IR_mld_f cons_xtile 1.`d'#c.cons_xtile mob_exp 1.`d'#c.mob_exp 1.`d') ///
	order(I_mld_f 1.`d'#c.I_mld_f UI_mld_f 1.`d'#c.UI_mld_f IR_mld_f 1.`d'#c.IR_mld_f cons_xtile 1.`d'#c.cons_xtile mob_exp 1.`d'#c.mob_exp 1.`d') ///
	stats(N N_clust r2_p , fmt(0 0 3) ///
	labels("Number of individuals" "Number of countries" "pseudo \$R^2$"))
}
*Table A7
if ("`d'"=="vd_index") {
	noi esttab I Ii UI_mld_f UI_mld_fi IUI_mld_f IUI_mld_fi IR_UI_mld_f IR_UI_mld_fi using "$tables/tab_`d'_mld.tex", replace ///
	eqlabels(none) nodepvars nonotes nomtitles noomitted nogaps booktabs label b(3) se(3) star(* .1 ** .05 *** .01) ///
	collabels(none) ///
	keep(I_mld_f $d#c.I_mld_f UI_mld_f $d#c.UI_mld_f IR_mld_f $d#c.IR_mld_f cons_xtile $d#c.cons_xtile mob_exp $d#c.mob_exp `d') ///
	order(I_mld_f $d#c.I_mld_f UI_mld_f $d#c.UI_mld_f IR_mld_f $d#c.IR_mld_f cons_xtile $d#c.cons_xtile mob_exp $d#c.mob_exp `d') ///
	stats(N N_clust r2_p , fmt(0 0 3) ///
	labels("Number of individuals" "Number of countries" "pseudo \$R^2$"))
}
}

********************************************************************************
**#1.3 Marginal Effects - Figure 4
********************************************************************************
use "$working/LiTS_analysis_data", clear

drop if iso_code_2=="RU" | iso_code_2=="MK" 

*adjust democracy variable	
gl d "c.vd_index" 

*I	
probit supdem I_gini_f $d#c.I_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile, vce(cluster cname) 
margins, dydx(I_gini_f) at((means) _all vd_index=(0(5)90)) post
marginsplot, legend(off) yline(0) recast(line) recastci(rconnected) title("") bgcolor(white) allx xlabel(##10) graphregion(color(white)) xtitle("V-Dem Index") ytitle("Predicted Effects on Pr(Support Democracy)") ylabel(-10(2)16) xlabel(0(10)90) 
graph export "$figures\marginsplot_I_vd_index.png", replace

*UI
probit supdem UI_gini_f $d#c.UI_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile, vce(cluster cname)
margins, dydx(UI_gini_f) at((means) _all vd_index=(0(5)90)) post
marginsplot, legend(off) yline(0) recast(line) recastci(rconnected) title("") bgcolor(white) xlabel(##10) graphregion(color(white)) xtitle("V-Dem Index") ytitle("Predicted Effects on Pr(Support Democracy)") ylabel(-10(2)16) xlabel(0(10)90) 
graph export "$figures\marginsplot_UI_vd_index.png", replace

*I + UI
probit supdem UI_gini_f I_gini_f $d#c.UI_gini_f $d#c.I_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile, vce(cluster cname) 
margins, dydx(I_gini_f) at((means) _all vd_index=(0(5)90)) post
marginsplot, legend(off) yline(0) recast(line) recastci(rconnected) title("") bgcolor(white) allx xlabel(##10) graphregion(color(white)) xtitle("V-Dem Index") ytitle("Predicted Effects on Pr(Support Democracy)") ylabel(-10(2)16) xlabel(0(10)90) 
graph export "$figures\marginsplot_I_UI_vd_index_I.png", replace

probit supdem UI_gini_f I_gini_f $d#c.UI_gini_f $d#c.I_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile, vce(cluster cname) 
margins, dydx(UI_gini_f) at((means) _all vd_index=(0(5)90)) post
marginsplot, legend(off) yline(0) recast(line) recastci(rconnected) title("") bgcolor(white) allx xlabel(##10) graphregion(color(white)) xtitle("V-Dem Index") ytitle("Predicted Effects on Pr(Support Democracy)") ylabel(-10(2)16) xlabel(0(10)90) 
graph export "$figures\marginsplot_I_UI_vd_index_UI.png", replace

*IR + UI
probit supdem UI_gini_f IR_gini_f $d#c.UI_gini_f $d#c.IR_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile, vce(cluster cname) 
margins, dydx(IR_gini_f) at((means) _all vd_index=(0(5)90)) post
marginsplot, legend(off) yline(0) recast(line) recastci(rconnected) title("") bgcolor(white) allx xlabel(##10) graphregion(color(white)) xtitle("V-Dem Index") ytitle("Predicted Effects on Pr(Support Democracy)") ylabel(-10(2)16) xlabel(0(10)90) 
graph export "$figures\marginsplot_IR_UI_vd_index_IR.png", replace

probit supdem UI_gini_f IR_gini_f $d#c.UI_gini_f $d#c.IR_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile, vce(cluster cname) 
margins, dydx(UI_gini_f) at((means) _all vd_index=(0(5)90)) post
marginsplot, legend(off) yline(0) recast(line) recastci(rconnected) title("") bgcolor(white) allx xlabel(##10) graphregion(color(white)) xtitle("V-Dem Index") ytitle("Predicted Effects on Pr(Support Democracy)") ylabel(-10(2)16) xlabel(0(10)90) 
graph export "$figures\marginsplot_IR_UI_vd_index_UI.png", replace

********************************************************************************
********************************************************************************
**#2. Sensitivity Analysis
********************************************************************************
********************************************************************************

********************************************************************************
**#2.1 Robustness UI Estimation - Tables A8-A10
********************************************************************************
*comparison UI estimation methodlogies
use "$working/LiTS_analysis_data", clear
drop if iso_code_2=="RU" | iso_code_2=="MK" 
est clear

lab var UI_gini_f "UI Forest"
lab var IR_gini_f "IR Forest"
lab var vd_index "V-Dem Index"

foreach d in vd_democracy vd_index {
	*adjust democracy variable	
	if "`d'"=="vd_index" 		gl d "c.`d'"
	if "`d'"=="vd_democracy" 	gl d "i.`d'" 
		
	*run regressions
	eststo Ii:	probit supdem I_gini_f $d#c.I_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile, vce(cluster cname) 
	foreach iop in s c l f {
		eststo UI_`iop'i: 		probit supdem UI_gini_`iop' $d#c.UI_gini_`iop' $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile, vce(cluster cname)
		eststo I_UI_`iop'i: 	probit supdem UI_gini_`iop' I_gini_f $d#c.UI_gini_`iop' $d#c.I_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile, vce(cluster cname) 
		eststo IR_UI_`iop'i: 	probit supdem UI_gini_`iop' IR_gini_`iop' $d#c.UI_gini_`iop' $d#c.IR_gini_`iop' $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile, vce(cluster cname) 
	}

	*Table A8
	if ("`d'"=="vd_democracy") {
		noi esttab UI_fi UI_si UI_ci UI_li I_UI_fi I_UI_si I_UI_ci I_UI_li IR_UI_fi IR_UI_si IR_UI_ci IR_UI_li ///
		using "$tables/tab_`d'_UI_comp.tex", replace ///
		eqlabels(none) nodepvars nonotes nomtitles noomitted nogaps booktabs label b(3) se(3) star(* .1 ** .05 *** .01) ///
		collabels(none) ///
		keep(I_gini_f 1.`d'#c.I_gini_f UI_gini_f 1.`d'#c.UI_gini_f UI_gini_s 1.`d'#c.UI_gini_s UI_gini_c 1.`d'#c.UI_gini_c UI_gini_l 1.`d'#c.UI_gini_l UI_gini_f 1.`d'#c.UI_gini_f 1.`d') ///
		order(I_gini_f 1.`d'#c.I_gini_f UI_gini_f 1.`d'#c.UI_gini_f UI_gini_s 1.`d'#c.UI_gini_s UI_gini_c 1.`d'#c.UI_gini_c UI_gini_l 1.`d'#c.UI_gini_l UI_gini_f 1.`d'#c.UI_gini_f 1.`d') ///
		stats(N N_clust r2_p , fmt(0 0 3) ///
		labels("Number of individuals" "Number of countries" "pseudo \$R^2$"))
	}
	*Table A9
	if ("`d'"=="vd_index") {
		noi esttab UI_fi UI_si UI_ci UI_li I_UI_fi I_UI_si I_UI_ci I_UI_li IR_UI_fi IR_UI_si IR_UI_ci IR_UI_li ///
		using "$tables/tab_`d'_UI_comp.tex", replace ///
		eqlabels(none) nodepvars nonotes nomtitles noomitted nogaps booktabs label b(3) se(3) star(* .1 ** .05 *** .01) ///
		collabels(none) ///
		keep(I_gini_f $d#c.I_gini_f UI_gini_f $d#c.UI_gini_f UI_gini_s $d#c.UI_gini_s UI_gini_c $d#c.UI_gini_c UI_gini_l $d#c.UI_gini_l UI_gini_f $d#c.UI_gini_f `d') ///
		order(I_gini_f $d#c.I_gini_f UI_gini_f $d#c.UI_gini_f UI_gini_s $d#c.UI_gini_s UI_gini_c $d#c.UI_gini_c UI_gini_l $d#c.UI_gini_l UI_gini_f $d#c.UI_gini_f `d') ///
		stats(N N_clust r2_p , fmt(0 0 3) ///
		labels("Number of individuals" "Number of countries" "pseudo \$R^2$"))
	}
}

*UI full population
use "$working/LiTS_analysis_data", clear
drop if iso_code_2=="RU" | iso_code_2=="MK" 
est clear

*adjust democracy variable	
local d vd_democracy
gl d "i.`d'"

*run regressions
eststo I: 		probit supdem I_gini_fa $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 
eststo Ii: 		probit supdem I_gini_fa $d#c.I_gini_fa $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 
eststo UI: 		probit supdem UI_gini_fa $d $c_i_controls_cons_xtile , vce(cluster cname) noomit
eststo UIi: 	probit supdem UI_gini_fa $d#c.UI_gini_fa $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname) noomit
eststo IR_UI: 	probit supdem UI_gini_fa IR_gini_fa $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 
eststo IR_UIi: 	probit supdem UI_gini_fa IR_gini_fa $d#c.UI_gini_fa $d#c.IR_gini_fa $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 
eststo I_UI: 	probit supdem UI_gini_fa I_gini_fa $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 
eststo I_UIi: 	probit supdem UI_gini_fa I_gini_fa $d#c.UI_gini_fa $d#c.I_gini_fa $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 

*Table A10
noi esttab I Ii UI UIi I_UI I_UIi IR_UI IR_UIi using "$tables/tab_`d'_full_pop.tex", replace ///
eqlabels(none) nodepvars nonotes nomtitles noomitted nogaps booktabs label b(3) se(3) star(* .1 ** .05 *** .01) ///
collabels(none) ///
keep(I_gini_fa 1.`d'#c.I_gini_fa UI_gini_fa 1.`d'#c.UI_gini_fa IR_gini_fa 1.`d'#c.IR_gini_fa cons_xtile 1.`d'#c.cons_xtile mob_exp 1.`d'#c.mob_exp 1.`d') ///
order(I_gini_fa 1.`d'#c.I_gini_fa UI_gini_fa 1.`d'#c.UI_gini_fa IR_gini_fa 1.`d'#c.IR_gini_fa cons_xtile 1.`d'#c.cons_xtile mob_exp 1.`d'#c.mob_exp 1.`d') ///
stats(N N_clust r2_p , fmt(0 0 3) ///
labels("Number of individuals" "Number of countries" "pseudo \$R^2$"))

********************************************************************************
**#2.2 Coefficient Robustness - leave one out - Figures A4 & A5 
********************************************************************************
use "$working/LiTS_analysis_data", clear
drop if iso_code_2=="RU" | iso_code_2=="MK" 

*adjust democracy variable	
local d vd_democracy
gl d "i.`d'"

***Gini	- Figure A4
*fill matrix with leave-one-out estimates
levelsof iso_code_2, local(countries)	
di `countries'
local n_row : word count `countries'
matrix mat_coef = J(`n_row', 25, .)
local i = 1
foreach c in `countries' {
	matrix mat_coef [`i', 1] = `i'
	probit supdem I_gini_f $d#c.I_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile if iso_code_2!="`c'", vce(cluster cname) 	
	matrix mat_coef [`i', 2] = e(b)[1,1]
	matrix mat_coef [`i', 3] = sqrt(e(V)[1,1])
	matrix mat_coef [`i', 4] = e(b)[1,3]
	matrix mat_coef [`i', 5] = sqrt(e(V)[3,3])
	probit supdem UI_gini_f $d#c.UI_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile if iso_code_2!="`c'", vce(cluster cname)
	matrix mat_coef [`i', 6] = e(b)[1,1] 
	matrix mat_coef [`i', 7] = sqrt(e(V)[1,1])
	matrix mat_coef [`i', 8] = e(b)[1,3] 
	matrix mat_coef [`i', 9] = sqrt(e(V)[3,3])
	probit supdem I_gini_f $d#c.I_gini_f UI_gini_f $d#c.UI_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile if iso_code_2!="`c'", vce(cluster cname) 
	matrix mat_coef [`i', 10] = e(b)[1,1] 
	matrix mat_coef [`i', 11] = sqrt(e(V)[1,1])
	matrix mat_coef [`i', 12] = e(b)[1,3] 
	matrix mat_coef [`i', 13] = sqrt(e(V)[3,3])
	matrix mat_coef [`i', 14] = e(b)[1,4]
	matrix mat_coef [`i', 15] = sqrt(e(V)[4,4])
	matrix mat_coef [`i', 16] = e(b)[1,6]
	matrix mat_coef [`i', 17] = sqrt(e(V)[6,6])
	probit supdem IR_gini_f $d#c.IR_gini_f UI_gini_f $d#c.UI_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile if iso_code_2!="`c'", vce(cluster cname) 
	matrix mat_coef [`i', 18] = e(b)[1,1] 
	matrix mat_coef [`i', 19] = sqrt(e(V)[1,1])
	matrix mat_coef [`i', 20] = e(b)[1,3] 
	matrix mat_coef [`i', 21] = sqrt(e(V)[3,3])
	matrix mat_coef [`i', 22] = e(b)[1,4]
	matrix mat_coef [`i', 23] = sqrt(e(V)[4,4])
	matrix mat_coef [`i', 24] = e(b)[1,6]
	matrix mat_coef [`i', 25] = sqrt(e(V)[6,6])
 local ++i
}
mat2txt, matrix(mat_coef) saving("$working/mat_coef.txt") replace 

*get full sample estimates 
use "$working/LiTS_analysis_data", clear
drop if iso_code_2=="RU" | iso_code_2=="MK" 
probit supdem I_gini_f $d#c.I_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname) 
local I_gini_f_p = e(b)[1,1]
local I_gini_f_u = `I_gini_f_p' + sqrt(e(V)[1,1])
local I_gini_f_l = `I_gini_f_p' - sqrt(e(V)[1,1])
local d_I_gini_f_p = e(b)[1,3]
local d_I_gini_f_u = `d_I_gini_f_p' + sqrt(e(V)[3,3])
local d_I_gini_f_l = `d_I_gini_f_p' - sqrt(e(V)[3,3])
probit supdem UI_gini_f $d#c.UI_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname)
local UI_gini_f_p = e(b)[1,1]
local UI_gini_f_u = `UI_gini_f_p' + sqrt(e(V)[1,1])
local UI_gini_f_l = `UI_gini_f_p' - sqrt(e(V)[1,1])
local d_UI_gini_f_p = e(b)[1,3]
local d_UI_gini_f_u = `d_UI_gini_f_p' + sqrt(e(V)[3,3])
local d_UI_gini_f_l = `d_UI_gini_f_p' - sqrt(e(V)[3,3])
probit supdem I_gini_f $d#c.I_gini_f UI_gini_f $d#c.UI_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname) 
local i_I_gini_f_p = e(b)[1,1]
local i_I_gini_f_u = `i_I_gini_f_p' + sqrt(e(V)[1,1])
local i_I_gini_f_l = `i_I_gini_f_p' - sqrt(e(V)[1,1])
local d_i_I_gini_f_p = e(b)[1,3]
local d_i_I_gini_f_u = `d_i_I_gini_f_p' + sqrt(e(V)[3,3])
local d_i_I_gini_f_l = `d_i_I_gini_f_p' - sqrt(e(V)[3,3])
local i_UI_gini_f_p = e(b)[1,4]
local i_UI_gini_f_u = `i_UI_gini_f_p' + sqrt(e(V)[4,4])
local i_UI_gini_f_l = `i_UI_gini_f_p' - sqrt(e(V)[4,4])
local d_i_UI_gini_f_p = e(b)[1,6]
local d_i_UI_gini_f_u = `d_i_UI_gini_f_p' + sqrt(e(V)[6,6])
local d_i_UI_gini_f_l = `d_i_UI_gini_f_p' - sqrt(e(V)[6,6])
probit supdem IR_gini_f $d#c.IR_gini_f UI_gini_f $d#c.UI_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname) 
local i_IR_gini_f_p = e(b)[1,1]
local i_IR_gini_f_u = `i_IR_gini_f_p' + sqrt(e(V)[1,1])
local i_IR_gini_f_l = `i_IR_gini_f_p' - sqrt(e(V)[1,1])
local d_i_IR_gini_f_p = e(b)[1,3]
local d_i_IR_gini_f_u = `d_i_IR_gini_f_p' + sqrt(e(V)[3,3])
local d_i_IR_gini_f_l = `d_i_IR_gini_f_p' - sqrt(e(V)[3,3])
local i_IR_UI_gini_f_p = e(b)[1,4]
local i_IR_UI_gini_f_u = `i_IR_UI_gini_f_p' + sqrt(e(V)[4,4])
local i_IR_UI_gini_f_l = `i_IR_UI_gini_f_p' - sqrt(e(V)[4,4])
local d_i_IR_UI_gini_f_p = e(b)[1,6]
local d_i_IR_UI_gini_f_u = `d_i_IR_UI_gini_f_p' + sqrt(e(V)[6,6])
local d_i_IR_UI_gini_f_l = `d_i_IR_UI_gini_f_p' - sqrt(e(V)[6,6])

**generate plots by inequality measure
import delimited "$working/mat_coef.txt", clear

*generate country lables
ren c1 iso_code_2
lab def iso_code_2 /*
*/ 1 "AL" 2 "AM" 3 "AZ" 4 "BG" 5 "BY" 6 "CZ" 7 "EE" 8 "GE" 9 "HR" 10 "HU" 11 "KZ" 12 "LT" 13 "LV" /*
*/ 14 "ME" 15 "MN" 16 "PL" 17 "RO" 18 "RS" 19 "SI" 20 "SK" 21 "UA" 22 "UZ" 23 "XK"
lab val iso_code_2 iso_code_2
ren (c2 c3 c4 c5) (I_gini_f_p I_gini_f_se d_I_gini_f_p d_I_gini_f_se)
ren (c6 c7 c8 c9) (UI_gini_f_p UI_gini_f_se d_UI_gini_f_p d_UI_gini_f_se)
ren (c10 c11 c12 c13) (i_I_gini_f_p i_I_gini_f_se d_i_I_gini_f_p d_i_I_gini_f_se)
ren (c14 c15 c16 c17) (i_UI_gini_f_p i_UI_gini_f_se d_i_UI_gini_f_p d_i_UI_gini_f_se)
ren (c18 c19 c20 c21) (i_IR_gini_f_p i_IR_gini_f_se d_i_IR_gini_f_p d_i_IR_gini_f_se)
ren (c22 c23 c24 c25) (i_IR_UI_gini_f_p i_IR_UI_gini_f_se d_i_IR_UI_gini_f_p d_i_IR_UI_gini_f_se)

foreach coef in I_gini_f d_I_gini_f UI_gini_f d_UI_gini_f i_I_gini_f d_i_I_gini_f i_UI_gini_f d_i_UI_gini_f i_IR_gini_f d_i_IR_gini_f i_IR_UI_gini_f d_i_IR_UI_gini_f {
	gen `coef'_l = `coef'_p - `coef'_se
	gen `coef'_u = `coef'_p + `coef'_se
}

foreach var in I_gini_f UI_gini_f i_I_gini_f i_UI_gini_f i_IR_gini_f i_IR_UI_gini_f {
twoway scatter `var'_p iso_code_2, mcolor("red") /*
*/ yline(``var'_p', lcolor("red")) yline(``var'_u', lcolor("red") lpattern("dash")) yline(``var'_l', lcolor("red") lpattern("dash")) || /* 
*/ scatter d_`var'_p iso_code_2, mcolor("green") /*
*/ yline(`d_`var'_p', lcolor("green")) yline(`d_`var'_u', lcolor("green") lpattern("dash")) yline(`d_`var'_l', lcolor("green") lpattern("dash")) || /* 
*/ rspike `var'_l `var'_u iso_code_2, lcolor("red") || /*
*/ rspike d_`var'_l d_`var'_u iso_code_2, lcolor("green") /*
*/ xlabel(1(1) 23, val angle(45) labsize(small)) ylabel(-60(20)60) bgcolor(white) graphregion(color(white)) xtitle("") legend(off)
graph export "$figures\coef_`var'.png", as(png) replace	
} 

***MLD - Figure A5
use "$working/LiTS_analysis_data", clear
drop if iso_code_2=="RU" | iso_code_2=="MK" 

*adjust democracy variable	
local d vd_democracy
gl d "i.`d'"
*fill matrix with leave-one-out estimates
levelsof iso_code_2, local(countries)	
di `countries'
local n_row : word count `countries'
matrix mat_coef = J(`n_row', 25, .)
local i = 1
foreach c in `countries' {
	matrix mat_coef [`i', 1] = `i'
	probit supdem I_mld_f $d#c.I_mld_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile if iso_code_2!="`c'", vce(cluster cname) 	
	matrix mat_coef [`i', 2] = e(b)[1,1]
	matrix mat_coef [`i', 3] = sqrt(e(V)[1,1])
	matrix mat_coef [`i', 4] = e(b)[1,3]
	matrix mat_coef [`i', 5] = sqrt(e(V)[3,3])
	probit supdem UI_mld_f $d#c.UI_mld_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile if iso_code_2!="`c'", vce(cluster cname)
	matrix mat_coef [`i', 6] = e(b)[1,1] 
	matrix mat_coef [`i', 7] = sqrt(e(V)[1,1])
	matrix mat_coef [`i', 8] = e(b)[1,3] 
	matrix mat_coef [`i', 9] = sqrt(e(V)[3,3])
	probit supdem I_mld_f $d#c.I_mld_f UI_mld_f $d#c.UI_mld_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile if iso_code_2!="`c'", vce(cluster cname) 
	matrix mat_coef [`i', 10] = e(b)[1,1] 
	matrix mat_coef [`i', 11] = sqrt(e(V)[1,1])
	matrix mat_coef [`i', 12] = e(b)[1,3] 
	matrix mat_coef [`i', 13] = sqrt(e(V)[3,3])
	matrix mat_coef [`i', 14] = e(b)[1,4]
	matrix mat_coef [`i', 15] = sqrt(e(V)[4,4])
	matrix mat_coef [`i', 16] = e(b)[1,6]
	matrix mat_coef [`i', 17] = sqrt(e(V)[6,6])
	probit supdem IR_mld_f $d#c.IR_mld_f UI_mld_f $d#c.UI_mld_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile if iso_code_2!="`c'", vce(cluster cname) 
	matrix mat_coef [`i', 18] = e(b)[1,1] 
	matrix mat_coef [`i', 19] = sqrt(e(V)[1,1])
	matrix mat_coef [`i', 20] = e(b)[1,3] 
	matrix mat_coef [`i', 21] = sqrt(e(V)[3,3])
	matrix mat_coef [`i', 22] = e(b)[1,4]
	matrix mat_coef [`i', 23] = sqrt(e(V)[4,4])
	matrix mat_coef [`i', 24] = e(b)[1,6]
	matrix mat_coef [`i', 25] = sqrt(e(V)[6,6])
 local ++i
}
mat2txt, matrix(mat_coef) saving("$working/mat_coef.txt") replace 

*get full sample estimates 
use "$working/LiTS_analysis_data", clear
drop if iso_code_2=="RU" | iso_code_2=="MK" 
probit supdem I_mld_f $d#c.I_mld_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname) 
local I_mld_f_p = e(b)[1,1]
local I_mld_f_u = `I_mld_f_p' + sqrt(e(V)[1,1])
local I_mld_f_l = `I_mld_f_p' - sqrt(e(V)[1,1])
local d_I_mld_f_p = e(b)[1,3]
local d_I_mld_f_u = `d_I_mld_f_p' + sqrt(e(V)[3,3])
local d_I_mld_f_l = `d_I_mld_f_p' - sqrt(e(V)[3,3])
probit supdem UI_mld_f $d#c.UI_mld_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname)
local UI_mld_f_p = e(b)[1,1]
local UI_mld_f_u = `UI_mld_f_p' + sqrt(e(V)[1,1])
local UI_mld_f_l = `UI_mld_f_p' - sqrt(e(V)[1,1])
local d_UI_mld_f_p = e(b)[1,3]
local d_UI_mld_f_u = `d_UI_mld_f_p' + sqrt(e(V)[3,3])
local d_UI_mld_f_l = `d_UI_mld_f_p' - sqrt(e(V)[3,3])
probit supdem I_mld_f $d#c.I_mld_f UI_mld_f $d#c.UI_mld_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname) 
local i_I_mld_f_p = e(b)[1,1]
local i_I_mld_f_u = `i_I_mld_f_p' + sqrt(e(V)[1,1])
local i_I_mld_f_l = `i_I_mld_f_p' - sqrt(e(V)[1,1])
local d_i_I_mld_f_p = e(b)[1,3]
local d_i_I_mld_f_u = `d_i_I_mld_f_p' + sqrt(e(V)[3,3])
local d_i_I_mld_f_l = `d_i_I_mld_f_p' - sqrt(e(V)[3,3])
local i_UI_mld_f_p = e(b)[1,4]
local i_UI_mld_f_u = `i_UI_mld_f_p' + sqrt(e(V)[4,4])
local i_UI_mld_f_l = `i_UI_mld_f_p' - sqrt(e(V)[4,4])
local d_i_UI_mld_f_p = e(b)[1,6]
local d_i_UI_mld_f_u = `d_i_UI_mld_f_p' + sqrt(e(V)[6,6])
local d_i_UI_mld_f_l = `d_i_UI_mld_f_p' - sqrt(e(V)[6,6])
probit supdem IR_mld_f $d#c.IR_mld_f UI_mld_f $d#c.UI_mld_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname) 
local i_IR_mld_f_p = e(b)[1,1]
local i_IR_mld_f_u = `i_IR_mld_f_p' + sqrt(e(V)[1,1])
local i_IR_mld_f_l = `i_IR_mld_f_p' - sqrt(e(V)[1,1])
local d_i_IR_mld_f_p = e(b)[1,3]
local d_i_IR_mld_f_u = `d_i_IR_mld_f_p' + sqrt(e(V)[3,3])
local d_i_IR_mld_f_l = `d_i_IR_mld_f_p' - sqrt(e(V)[3,3])
local i_IR_UI_mld_f_p = e(b)[1,4]
local i_IR_UI_mld_f_u = `i_IR_UI_mld_f_p' + sqrt(e(V)[4,4])
local i_IR_UI_mld_f_l = `i_IR_UI_mld_f_p' - sqrt(e(V)[4,4])
local d_i_IR_UI_mld_f_p = e(b)[1,6]
local d_i_IR_UI_mld_f_u = `d_i_IR_UI_mld_f_p' + sqrt(e(V)[6,6])
local d_i_IR_UI_mld_f_l = `d_i_IR_UI_mld_f_p' - sqrt(e(V)[6,6])

**generate plots by inequality measure
import delimited "$working/mat_coef.txt", clear

*generate country lables
ren c1 iso_code_2
lab def iso_code_2 /*
*/ 1 "AL" 2 "AM" 3 "AZ" 4 "BG" 5 "BY" 6 "CZ" 7 "EE" 8 "GE" 9 "HR" 10 "HU" 11 "KZ" 12 "LT" 13 "LV" /*
*/ 14 "ME" 15 "MN" 16 "PL" 17 "RO" 18 "RS" 19 "SI" 20 "SK" 21 "UA" 22 "UZ" 23 "XK"
lab val iso_code_2 iso_code_2
ren (c2 c3 c4 c5) (I_mld_f_p I_mld_f_se d_I_mld_f_p d_I_mld_f_se)
ren (c6 c7 c8 c9) (UI_mld_f_p UI_mld_f_se d_UI_mld_f_p d_UI_mld_f_se)
ren (c10 c11 c12 c13) (i_I_mld_f_p i_I_mld_f_se d_i_I_mld_f_p d_i_I_mld_f_se)
ren (c14 c15 c16 c17) (i_UI_mld_f_p i_UI_mld_f_se d_i_UI_mld_f_p d_i_UI_mld_f_se)
ren (c18 c19 c20 c21) (i_IR_mld_f_p i_IR_mld_f_se d_i_IR_mld_f_p d_i_IR_mld_f_se)
ren (c22 c23 c24 c25) (i_IR_UI_mld_f_p i_IR_UI_mld_f_se d_i_IR_UI_mld_f_p d_i_IR_UI_mld_f_se)

foreach coef in I_mld_f d_I_mld_f UI_mld_f d_UI_mld_f i_I_mld_f d_i_I_mld_f i_UI_mld_f d_i_UI_mld_f i_IR_mld_f d_i_IR_mld_f i_IR_UI_mld_f d_i_IR_UI_mld_f {
	gen `coef'_l = `coef'_p - `coef'_se
	gen `coef'_u = `coef'_p + `coef'_se
}

*adjust graph scaling
foreach var in UI_mld_f i_UI_mld_f i_IR_UI_mld_f {
	twoway scatter `var'_p iso_code_2, mcolor("red") /*
	*/ yline(``var'_p', lcolor("red")) yline(``var'_u', lcolor("red") lpattern("dash")) yline(``var'_l', lcolor("red") lpattern("dash")) || /* 
	*/ scatter d_`var'_p iso_code_2, mcolor("green") /*
	*/ yline(`d_`var'_p', lcolor("green")) yline(`d_`var'_u', lcolor("green") lpattern("dash")) yline(`d_`var'_l', lcolor("green") lpattern("dash")) || /* 
	*/ rspike `var'_l `var'_u iso_code_2, lcolor("red") || /*
	*/ rspike d_`var'_l d_`var'_u iso_code_2, lcolor("green") /*
	*/ xlabel(1(1) 23, val angle(45) labsize(small)) ylabel(-80(20)80) bgcolor(white) graphregion(color(white)) xtitle("") legend(off)
	graph export "$figures\coef_`var'.png", as(png) replace	
} 
foreach var in I_mld_f i_I_mld_f i_IR_mld_f {
	twoway scatter `var'_p iso_code_2, mcolor("red") /*
	*/ yline(``var'_p', lcolor("red")) yline(``var'_u', lcolor("red") lpattern("dash")) yline(``var'_l', lcolor("red") lpattern("dash")) || /* 
	*/ scatter d_`var'_p iso_code_2, mcolor("green") /*
	*/ yline(`d_`var'_p', lcolor("green")) yline(`d_`var'_u', lcolor("green") lpattern("dash")) yline(`d_`var'_l', lcolor("green") lpattern("dash")) || /* 
	*/ rspike `var'_l `var'_u iso_code_2, lcolor("red") || /*
	*/ rspike d_`var'_l d_`var'_u iso_code_2, lcolor("green") /*
	*/ xlabel(1(1) 23, val angle(45) labsize(small)) ylabel(-60(20)60) bgcolor(white) graphregion(color(white)) xtitle("") legend(off)
	graph export "$figures\coef_`var'.png", as(png) replace	
} 

********************************************************************************
**#2.3 Interaction Interaction sociotropic and egocentric Dimension - Table A11
********************************************************************************
use "$working/LiTS_analysis_data", clear
drop if iso_code_2=="RU" | iso_code_2=="MK" 
est clear

*adjust democracy variable	
local d vd_democracy
gl d "i.`d'"

*run regressions
eststo Ii: 		probit supdem I_gini_f $d#c.I_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile, vce(cluster cname) 
eststo UIi: 	probit supdem UI_gini_f $d#c.UI_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile, vce(cluster cname)
eststo I_UIi: 	probit supdem UI_gini_f I_gini_f $d#c.UI_gini_f $d#c.I_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile, vce(cluster cname) 
eststo IR_UIi: 	probit supdem UI_gini_f IR_gini_f $d#c.UI_gini_f $d#c.IR_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile, vce(cluster cname) 
eststo Iii: 	probit supdem I_gini_f $d#c.I_gini_f c.I_gini_f#c.cons_xtile c.I_gini_f#c.mob_exp $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile, vce(cluster cname) 
eststo UIii: 	probit supdem UI_gini_f $d#c.UI_gini_f c.UI_gini_f#c.cons_xtile c.UI_gini_f#c.mob_exp $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile, vce(cluster cname)
eststo I_UIii: 	probit supdem UI_gini_f I_gini_f $d#c.UI_gini_f $d#c.I_gini_f c.UI_gini_f#c.cons_xtile c.I_gini_f#c.cons_xtile c.UI_gini_f#c.mob_exp c.I_gini_f#c.mob_exp $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile, vce(cluster cname) 
eststo IR_UIii: probit supdem UI_gini_f IR_gini_f $d#c.UI_gini_f $d#c.IR_gini_f c.UI_gini_f#c.cons_xtile c.IR_gini_f#c.cons_xtile c.UI_gini_f#c.mob_exp c.IR_gini_f#c.mob_exp $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile, vce(cluster cname) 

*adjust output
noi esttab Ii Iii UIi UIii I_UIi I_UIii IR_UIi IR_UIii using "$tables/tab_`d'_cons_xtile_int.tex", replace ///
eqlabels(none) nodepvars nonotes nomtitles noomitted nogaps booktabs label b(3) se(3) star(* .1 ** .05 *** .01) ///
collabels(none) ///
keep(I_gini_f 1.`d'#c.I_gini_f UI_gini_f 1.`d'#c.UI_gini_f I_gini_f 1.`d'#c.I_gini_f UI_gini_f 1.`d'#c.UI_gini_f IR_gini_f 1.`d'#c.IR_gini_f cons_xtile 1.`d'#c.cons_xtile c.I_gini_f#c.cons_xtile c.UI_gini_f#c.cons_xtile c.I_gini_f#c.cons_xtile c.UI_gini_f#c.cons_xtile c.IR_gini_f#c.cons_xtile mob_exp 1.`d'#c.mob_exp c.I_gini_f#c.mob_exp c.UI_gini_f#c.mob_exp c.I_gini_f#c.mob_exp c.UI_gini_f#c.mob_exp c.IR_gini_f#c.mob_exp 1.`d') ///
order(I_gini_f 1.`d'#c.I_gini_f UI_gini_f 1.`d'#c.UI_gini_f I_gini_f 1.`d'#c.I_gini_f UI_gini_f 1.`d'#c.UI_gini_f IR_gini_f 1.`d'#c.IR_gini_f cons_xtile 1.`d'#c.cons_xtile c.I_gini_f#c.cons_xtile c.UI_gini_f#c.cons_xtile c.I_gini_f#c.cons_xtile c.UI_gini_f#c.cons_xtile c.IR_gini_f#c.cons_xtile mob_exp 1.`d'#c.mob_exp c.I_gini_f#c.mob_exp c.UI_gini_f#c.mob_exp c.I_gini_f#c.mob_exp c.UI_gini_f#c.mob_exp c.IR_gini_f#c.mob_exp 1.`d') ///
stats(N N_clust r2_p , fmt(0 0 3) ///
labels("Number of individuals" "Number of countries" "pseudo \$R^2$"))

********************************************************************************
**#2.4 Cohort Effects - Table A12
********************************************************************************
est clear
local v "cohort_10y"
gl v "i.`v'" 
gl i_controls_maindj "gender i.edu_3c $v b_life_satisfaction commu_exp minority" 
gl c_i_controls_cons_xtiledj $i_controls_maindj cons_xtile mob_exp $c_controls

*adjust democracy variable	
local d vd_democracy
gl d "i.`d'"

*run regressions
eststo I: 		probit supdem I_gini_f $d $c_i_controls_cons_xtiledj , vce(cluster cname) 
eststo Iv: 		probit supdem I_gini_f $d $v#$d $v $c_i_controls_cons_xtiledj , vce(cluster cname) 
eststo Ii: 		probit supdem I_gini_f c.I_gini_f#$d $d $d#c.cons_xtile $d#c.mob_exp $v $c_i_controls_cons_xtiledj , vce(cluster cname) 
eststo Iiv: 	probit supdem I_gini_f c.I_gini_f#$d $d $d#c.cons_xtile $d#c.mob_exp $v $v#$d $c_i_controls_cons_xtiledj , vce(cluster cname) 
eststo UI: 		probit supdem UI_gini_f $d $c_i_controls_cons_xtiledj , vce(cluster cname)
eststo UIv: 	probit supdem UI_gini_f $d $v#$d $v $c_i_controls_cons_xtiledj , vce(cluster cname) 
eststo UIi: 	probit supdem UI_gini_f c.UI_gini_f#$d $d $v $d#c.cons_xtile $d#c.mob_exp $c_i_controls_cons_xtiledj , vce(cluster cname)
eststo UIiv: 	probit supdem UI_gini_f c.UI_gini_f#$d $d $v $d#c.cons_xtile $d#c.mob_exp $v#$d $c_i_controls_cons_xtiledj , vce(cluster cname)
eststo I_UI: 	probit supdem UI_gini_f I_gini_f $d $c_i_controls_cons_xtiledj , vce(cluster cname) 
eststo I_UIv: 	probit supdem UI_gini_f I_gini_f $d $v#$d $v $c_i_controls_cons_xtiledj , vce(cluster cname) 
eststo I_UIi: 	probit supdem UI_gini_f I_gini_f c.UI_gini_f#$d c.I_gini_f#$d $d $d#c.cons_xtile $d#c.mob_exp $v $c_i_controls_cons_xtiledj , vce(cluster cname) 
eststo I_UIiv: 	probit supdem UI_gini_f I_gini_f c.UI_gini_f#$d c.I_gini_f#$d $d $d#c.cons_xtile $d#c.mob_exp $v#$d $c_i_controls_cons_xtiledj , vce(cluster cname) 

*adjust output
noi esttab Ii Iiv UIi UIiv I_UIi I_UIiv using "$tables/tab_`d'_cohort.tex", replace ///
eqlabels(none) nodepvars nonotes nomtitles noomitted nogaps booktabs label b(3) se(3) star(* .1 ** .05 *** .01) ///
collabels(none) ///
keep(I_gini_f 1.`d'#c.I_gini_f UI_gini_f 1.`d'#c.UI_gini_f I_gini_f 1.`d'#c.I_gini_f cons_xtile 1.`d'#c.cons_xtile mob_exp 1.`d'#c.mob_exp 1.`v' 2.`v' 3.`v' 4.`v' 5.`v' 1.`v'#1.`d' 2.`v'#1.`d' 3.`v'#1.`d' 4.`v'#1.`d' 5.`v'#1.`d' 1.`d') ///
order(I_gini_f 1.`d'#c.I_gini_f UI_gini_f 1.`d'#c.UI_gini_f I_gini_f 1.`d'#c.I_gini_f cons_xtile 1.`d'#c.cons_xtile mob_exp 1.`d'#c.mob_exp 1.`v' 2.`v' 3.`v' 4.`v' 5.`v' 1.`v'#1.`d' 2.`v'#1.`d' 3.`v'#1.`d' 4.`v'#1.`d' 5.`v'#1.`d' 1.`d') ///
stats(N N_clust r2_p , fmt(0 0 3) ///
labels("Number of individuals" "Number of countries" "pseudo \$R^2$"))

********************************************************************************
**#2.5 Poverty Interaction - Tables A13 & A14
********************************************************************************
use "$working/LiTS_analysis_data", clear
drop if iso_code_2=="RU" | iso_code_2=="MK" 
est clear

foreach p in pov pov_rate {
*adjust controls 
gl c_i_controls_cons_xtile_poverty "$i_controls cons_xtile mob_exp $c_controls `p'"
gl i_treat $d#c.cons_xtile $d#c.mob_exp $d

*adjust democracy variable	
local d vd_democracy
gl d "i.`d'"

*run regressions
eststo I: 		probit supdem I_gini_f $d $c_i_controls_cons_xtile_poverty, vce(cluster cname) 
eststo Ii: 		probit supdem I_gini_f $d c.I_gini_f#c.`p'_int $c_i_controls_cons_xtile_poverty, vce(cluster cname) 
eststo Iii: 	probit supdem $d##c.I_gini_f $d#c.I_gini_f#c.`p'_int c.I_gini_f#c.`p'_int $d#c.`p' $i_treat $c_i_controls_cons_xtile_poverty, vce(cluster cname) 
eststo UI: 		probit supdem UI_gini_f $d $c_i_controls_cons_xtile_poverty, vce(cluster cname) 
eststo UIi: 	probit supdem UI_gini_f $d c.UI_gini_f#c.`p'_int $c_i_controls_cons_xtile_poverty, vce(cluster cname) 
eststo UIii: 	probit supdem $d##c.UI_gini_f $d#c.UI_gini_f#c.`p'_int c.UI_gini_f#c.`p'_int $d#c.`p' $i_treat $c_i_controls_cons_xtile_poverty, vce(cluster cname) 
eststo I_UI: 	probit supdem I_gini_f UI_gini_f $d $c_i_controls_cons_xtile_poverty, vce(cluster cname) 
eststo I_UIi: 	probit supdem I_gini_f UI_gini_f $d c.I_gini_f#c.`p'_int c.UI_gini_f#c.`p'_int $c_i_controls_cons_xtile_poverty, vce(cluster cname) 
eststo I_UIii: 	probit supdem $d##c.I_gini_f $d##c.UI_gini_f $d#c.I_gini_f#c.`p'_int c.I_gini_f#c.`p'_int $d#c.UI_gini_f#c.`p'_int c.UI_gini_f#c.`p'_int $d#c.`p' $i_treat $c_i_controls_cons_xtile_poverty, vce(cluster cname)  iterate(1000) 

*adjust output
noi esttab I Ii Iii UI UIi UIii I_UI I_UIi I_UIii using "$tables/tab_`d'_`p'.tex", replace ///
eqlabels(none) nodepvars nonotes nomtitles noomitted nogaps booktabs label b(3) se(3) star(* .1 ** .05 *** .01) ///
collabels(none) ///
keep(I_gini_f c.I_gini_f#c.`p'_int 1.`d'#c.I_gini_f 1.`d'#c.I_gini_f#c.`p'_int UI_gini_f c.UI_gini_f#c.`p'_int 1.`d'#c.UI_gini_f 1.`d'#c.UI_gini_f#c.`p'_int `p' 1.`d'#c.`p' cons_xtile 1.`d'#c.cons_xtile mob_exp 1.`d'#c.mob_exp 1.`d') ///
order(I_gini_f c.I_gini_f#c.`p'_int 1.`d'#c.I_gini_f 1.`d'#c.I_gini_f#c.`p'_int UI_gini_f c.UI_gini_f#c.`p'_int 1.`d'#c.UI_gini_f 1.`d'#c.UI_gini_f#c.`p'_int `p' 1.`d'#c.`p' cons_xtile 1.`d'#c.cons_xtile mob_exp 1.`d'#c.mob_exp 1.`d') ///
stats(N N_clust r2_p , fmt(0 0 3) ///
labels("Number of individuals" "Number of countries" "pseudo \$R^2$"))
}

********************************************************************************
**#2.6 Growth Interaction - Table A15-A17
********************************************************************************
use "$working/LiTS_analysis_data", clear
drop if iso_code_2=="RU" | iso_code_2=="MK" 

est clear
gen growth = .
gen growth_int = .
lab var growth "Growth"
lab var growth_int "(1-Growth)"

gl i_treat $d#c.cons_xtile $d#c.mob_exp $d

foreach g in gdppc_growth_5y_annu gdppc_growth_3y_annu gdppc_growth_5y_annu2010 {
	gl c_i_controls_cons_xtile_growth $c_i_controls_cons_xtile growth
	replace growth = `g'
	replace growth_int = 1 - `g'

	*adjust democracy variable	
	local d vd_democracy
	gl d "i.`d'"

	*run regressions
	eststo I: 		probit supdem I_gini_f $d $c_i_controls_cons_xtile_growth, vce(cluster cname) 
	eststo Ii: 		probit supdem I_gini_f $d c.I_gini_f#c.growth_int $c_i_controls_cons_xtile_growth, vce(cluster cname) 
	eststo Iii: 	probit supdem $d##c.I_gini_f $d#c.I_gini_f#c.growth_int c.I_gini_f#c.growth_int $d#c.growth $i_treat $c_i_controls_cons_xtile_growth, vce(cluster cname) 
	eststo UI: 		probit supdem UI_gini_f $d $c_i_controls_cons_xtile_growth, vce(cluster cname) 
	eststo UIi: 	probit supdem UI_gini_f $d c.UI_gini_f#c.growth_int $c_i_controls_cons_xtile_growth, vce(cluster cname) 
	eststo UIii: 	probit supdem $d##c.UI_gini_f $d#c.UI_gini_f#c.growth_int c.UI_gini_f#c.growth_int $d#c.growth $i_treat $c_i_controls_cons_xtile_growth, vce(cluster cname) 
	eststo I_UI: 	probit supdem I_gini_f UI_gini_f $d $c_i_controls_cons_xtile_growth, vce(cluster cname) 
	eststo I_UIi: 	probit supdem I_gini_f UI_gini_f $d c.I_gini_f#c.growth_int c.UI_gini_f#c.growth_int $c_i_controls_cons_xtile_growth, vce(cluster cname) 
	eststo I_UIii: 	probit supdem $d##c.I_gini_f $d##c.UI_gini_f $d#c.I_gini_f#c.growth_int c.I_gini_f#c.growth_int $d#c.UI_gini_f#c.growth_int c.UI_gini_f#c.growth_int $d#c.growth $i_treat $c_i_controls_cons_xtile_growth, vce(cluster cname) 

	*adjust output 
	noi esttab I Ii Iii UI UIi UIii I_UI I_UIi I_UIii using "$tables/tab_`d'_`g'.tex", replace ///
	eqlabels(none) nodepvars nonotes nomtitles noomitted nogaps booktabs label b(3) se(3) star(* .1 ** .05 *** .01) ///
	collabels(none) ///
	keep(I_gini_f c.I_gini_f#c.growth_int 1.`d'#c.I_gini_f 1.`d'#c.I_gini_f#c.growth_int UI_gini_f c.UI_gini_f#c.growth_int 1.`d'#c.UI_gini_f 1.`d'#c.UI_gini_f#c.growth_int growth 1.`d'#c.growth cons_xtile 1.`d'#c.cons_xtile mob_exp 1.`d'#c.mob_exp 1.`d') ///
	order(I_gini_f c.I_gini_f#c.growth_int 1.`d'#c.I_gini_f 1.`d'#c.I_gini_f#c.growth_int UI_gini_f c.UI_gini_f#c.growth_int 1.`d'#c.UI_gini_f 1.`d'#c.UI_gini_f#c.growth_int growth 1.`d'#c.growth cons_xtile 1.`d'#c.cons_xtile mob_exp 1.`d'#c.mob_exp 1.`d') ///
	stats(N N_clust r2_p , fmt(0 0 3) ///
	labels("Number of individuals" "Number of countries" "pseudo \$R^2$"))
}

********************************************************************************
**#2.7 Country-level Controls - GDPpc, Contemporary, no Controls - Tables A18-20
********************************************************************************
use "$working/LiTS_analysis_data", clear
est clear
drop if iso_code_2=="RU" | iso_code_2=="MK" 
gen gdppc_lag = log(gdppc2010)
gen gdppc2015 = exp(gdppc)
lab var gdppc "log GDP per capita 2015"
lab var gdppc_lag "log GDP per capita 2010"
lab var gdppc2015 "GDP per capita 2015"
lab var gdppc2010 "GDP per capita 2010"

*adjust controls 
gl c_controlsdj gdppc_growth_5y_annu unempl_5y govexp_5y new_eu governance
gl i_controls gender i.edu_3c b_life_satisfaction age age_2 commu_exp minority
gl c_i_controls_cons_xtiledj $i_controls cons_xtile mob_exp $c_controlsdj

*adjust democracy variable	
local d vd_democracy
gl d "i.`d'"

*GDPpc - Table A18
foreach g in gdppc gdppc_lag gdppc2015 gdppc2010 {
	eststo I_UI_`g': probit supdem UI_gini_f I_gini_f $d#c.UI_gini_f $d#c.I_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtiledj `g' , vce(cluster cname) noomit 
	eststo IR_UI_`g': probit supdem UI_gini_f IR_gini_f $d#c.UI_gini_f $d#c.IR_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtiledj `g' , vce(cluster cname) noomit 
}
noi esttab I_UI_gdppc I_UI_gdppc_lag I_UI_gdppc2015 I_UI_gdppc2010 IR_UI_gdppc IR_UI_gdppc_lag IR_UI_gdppc2015 IR_UI_gdppc2010 ///
using "$tables/tab_`d'_gdppc.tex", replace ///
eqlabels(none) nodepvars nonotes nomtitles noomitted nogaps booktabs label b(3) se(3) star(* .1 ** .05 *** .01) ///
collabels(none) ///
keep(I_gini_f 1.`d'#c.I_gini_f UI_gini_f 1.`d'#c.UI_gini_f IR_gini_f 1.`d'#c.IR_gini_f cons_xtile 1.`d'#c.cons_xtile mob_exp 1.`d'#c.mob_exp 1.`d' gdppc gdppc_lag gdppc2015 gdppc2010) ///
order(I_gini_f 1.`d'#c.I_gini_f UI_gini_f 1.`d'#c.UI_gini_f IR_gini_f 1.`d'#c.IR_gini_f cons_xtile 1.`d'#c.cons_xtile mob_exp 1.`d'#c.mob_exp 1.`d' gdppc gdppc_lag gdppc2015 gdppc2010) ///
stats(N N_clust r2_p , fmt(0 0 3) ///
labels("Number of individuals" "Number of countries" "pseudo \$R^2$"))

*Contemporary Controls - Table A19
est clear 
gl c_controls gdppc gdppc_growth unempl govexp new_eu governance //_contemp 
gl i_controls gender i.edu_3c b_life_satisfaction age age_2 commu_exp minority
gl c_i_controls_cons_xtile $i_controls cons_xtile mob_exp $c_controls
eststo I: 		probit supdem I_gini_f $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 
eststo Ii: 		probit supdem I_gini_f $d#c.I_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 
eststo UI: 		probit supdem UI_gini_f $d $c_i_controls_cons_xtile , vce(cluster cname) noomit
eststo UIi: 	probit supdem UI_gini_f $d#c.UI_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname) noomit
eststo IR_UI: 	probit supdem UI_gini_f IR_gini_f $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 
eststo IR_UIi: 	probit supdem UI_gini_f IR_gini_f $d#c.UI_gini_f $d#c.IR_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 
eststo I_UI: 	probit supdem UI_gini_f I_gini_f $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 
eststo I_UIi: 	probit supdem UI_gini_f I_gini_f $d#c.UI_gini_f $d#c.I_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 
noi esttab I Ii UI UIi I_UI I_UIi IR_UI IR_UIi using "$tables/tab_`d'_contemp.tex", replace ///
eqlabels(none) nodepvars nonotes nomtitles noomitted nogaps booktabs label b(3) se(3) star(* .1 ** .05 *** .01) ///
collabels(none) ///
keep(I_gini_f 1.`d'#c.I_gini_f UI_gini_f 1.`d'#c.UI_gini_f IR_gini_f 1.`d'#c.IR_gini_f cons_xtile 1.`d'#c.cons_xtile mob_exp 1.`d'#c.mob_exp 1.`d') ///
order(I_gini_f 1.`d'#c.I_gini_f UI_gini_f 1.`d'#c.UI_gini_f IR_gini_f 1.`d'#c.IR_gini_f cons_xtile 1.`d'#c.cons_xtile mob_exp 1.`d'#c.mob_exp 1.`d') ///
stats(N N_clust r2_p , fmt(0 0 3) ///
labels("Number of individuals" "Number of countries" "pseudo \$R^2$"))

*Baseline No Controls - Table A20
est clear 
gl c_i_controls_cons_xtile $i_controls cons_xtile mob_exp
eststo I: 		probit supdem I_gini_f $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 
eststo Ii: 		probit supdem I_gini_f $d#c.I_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 
eststo UI: 		probit supdem UI_gini_f $d $c_i_controls_cons_xtile , vce(cluster cname) noomit
eststo UIi: 	probit supdem UI_gini_f $d#c.UI_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname) noomit
eststo IR_UI: 	probit supdem UI_gini_f IR_gini_f $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 
eststo IR_UIi: 	probit supdem UI_gini_f IR_gini_f $d#c.UI_gini_f $d#c.IR_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 
eststo I_UI: 	probit supdem UI_gini_f I_gini_f $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 
eststo I_UIi: 	probit supdem UI_gini_f I_gini_f $d#c.UI_gini_f $d#c.I_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile , vce(cluster cname) noomit 
noi esttab I Ii UI UIi I_UI I_UIi IR_UI IR_UIi using "$tables/tab_`d'_base.tex", replace ///
eqlabels(none) nodepvars nonotes nomtitles noomitted nogaps booktabs label b(3) se(3) star(* .1 ** .05 *** .01) ///
collabels(none) ///
keep(I_gini_f 1.`d'#c.I_gini_f UI_gini_f 1.`d'#c.UI_gini_f IR_gini_f 1.`d'#c.IR_gini_f cons_xtile 1.`d'#c.cons_xtile mob_exp 1.`d'#c.mob_exp 1.`d') ///
order(I_gini_f 1.`d'#c.I_gini_f UI_gini_f 1.`d'#c.UI_gini_f IR_gini_f 1.`d'#c.IR_gini_f cons_xtile 1.`d'#c.cons_xtile mob_exp 1.`d'#c.mob_exp 1.`d') ///
stats(N N_clust r2_p , fmt(0 0 3) ///
labels("Number of individuals" "Number of countries" "pseudo \$R^2$"))

********************************************************************************
**#2.8 Country-level Controls - LASSO - Table A21
********************************************************************************
use "$working/LiTS_analysis_data", clear
est clear
drop if iso_code_2=="RU" | iso_code_2=="MK" 

*adjust controls 
gl c_controls gdppc gdppc_growth_5y_annu unempl_5y govexp_5y new_eu governance 
gl i_controls gender i.edu_3c b_life_satisfaction age age_2 commu_exp minority
gl c_i_controls_cons_xtile $i_controls cons_xtile mob_exp $c_controls

*adjust democracy variable	
local d vd_democracy
gl d "i.`d'"

*run regressions (1.lasso for selection 2.simple probit using selected cofficents to store regression results)
eststo l_I: 	lasso probit supdem I_gini_f $d $c_i_controls_cons_xtile, postsel rseed(123)
eststo I: 		probit supdem `e(othervars_sel)', vce(cluster cname) 
eststo l_Ii: 	lasso probit supdem I_gini_f $d#c.I_gini_f $c_i_controls_cons_xtile, postsel rseed(123) 
eststo Ii: 		probit supdem `e(allvars_sel)', vce(cluster cname) 
eststo l_UI: 	lasso probit supdem UI_gini_f $d $c_i_controls_cons_xtile, postsel rseed(123)
eststo UI: 		probit supdem `e(allvars_sel)', vce(cluster cname) 
eststo l_UIi: 	lasso probit supdem UI_gini_f $d#c.UI_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile, postsel rseed(123)
eststo UIi: 	probit supdem `e(allvars_sel)', vce(cluster cname) 
eststo l_I_UI: 	lasso probit supdem UI_gini_f I_gini_f $d $c_i_controls_cons_xtile, postsel rseed(123) 
eststo I_UI: 	probit supdem `e(allvars_sel)', vce(cluster cname) 
eststo l_I_UIi: lasso probit supdem UI_gini_f I_gini_f $d#c.UI_gini_f $d#c.I_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile, postsel rseed(123) 
eststo I_UIi: 	probit supdem `e(allvars_sel)', vce(cluster cname) 
eststo l_IR_UI: lasso probit supdem UI_gini_f IR_gini_f $d $c_i_controls_cons_xtile, postsel rseed(123) 
eststo IR_UI: 	probit supdem `e(allvars_sel)', vce(cluster cname)
eststo l_IR_UIi:lasso probit supdem UI_gini_f IR_gini_f $d#c.UI_gini_f $d#c.I_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile, postsel rseed(123) 
eststo IR_UIi: 	probit supdem `e(allvars_sel)', vce(cluster cname) 	

*adjust output 
noi esttab I Ii UI UIi I_UI I_UIi IR_UI IR_UIi using "$tables/tab_`d'_lasso.tex", replace ///
eqlabels(none) nodepvars nonotes nomtitles noomitted nogaps booktabs label b(3) se(3) star(* .1 ** .05 *** .01) ///
collabels(none) ///
order(I_gini_f 1.`d'#c.I_gini_f UI_gini_f 1.`d'#c.UI_gini_f IR_gini_f 1.`d'#c.IR_gini_f cons_xtile 1.`d'#c.cons_xtile mob_exp 1.`d'#c.mob_exp 1.`d') ///
stats(N N_clust r2_p , fmt(0 0 3) ///
labels("Number of individuals" "Number of countries" "pseudo \$R^2$"))

********************************************************************************
**#2.9 Bootstrapped SEs - Table A22
********************************************************************************
use "$working/LiTS_analysis_data", clear
drop if iso_code_2=="RU" | iso_code_2=="MK" 
est clear

*adjust democracy variable	
local d vd_democracy
gl d "i.`d'"
	
*run regressions
eststo I: 		probit supdem I_gini_f $d $c_i_controls_cons_xtile, vce(bootstrap, cluster (cname) rep(200)) 
boottest I_gini_f , small
estadd scalar wald = r(p) 
eststo Ii: 	probit supdem I_gini_f $d#c.I_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile, vce(bootstrap, cluster (cname) rep(200)) 
boottest I_gini_f , small
estadd scalar wald = r(p) 
eststo UI: 		probit supdem UI_gini_f $d $c_i_controls_cons_xtile, vce(bootstrap, cluster (cname) rep(200)) 
boottest UI_gini_f , small
estadd scalar wald = r(p) 
eststo UIi: 	probit supdem UI_gini_f $d#c.UI_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile, vce(bootstrap, cluster (cname) rep(200)) 
boottest UI_gini_f , small
estadd scalar wald = r(p) 
eststo I_UI: 	probit supdem UI_gini_f I_gini_f $d $c_i_controls_cons_xtile, vce(bootstrap, cluster (cname) rep(200)) 
boottest UI_gini_f I_gini_f, small
estadd scalar wald = r(p) 
eststo I_UIi: 	probit supdem UI_gini_f I_gini_f $d#c.UI_gini_f $d#c.I_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile, vce(bootstrap, cluster (cname) rep(200)) 
boottest UI_gini_f I_gini_f, small
estadd scalar wald = r(p) 
eststo IR_UI: 	probit supdem UI_gini_f IR_gini_f $d $c_i_controls_cons_xtile, vce(bootstrap, cluster (cname) rep(200)) 
boottest UI_gini_f IR_gini_f, small
estadd scalar wald = r(p) 
eststo IR_UIi: 	probit supdem UI_gini_f IR_gini_f $d#c.UI_gini_f $d#c.IR_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile, vce(bootstrap, cluster (cname) rep(200)) 
boottest UI_gini_f IR_gini_f, small
estadd scalar wald = r(p) 

*adjust output 
noi esttab I Ii UI UIi I_UI I_UIi using "$tables/tab_`d'_boot.tex", replace ///
eqlabels(none) nodepvars nonotes nomtitles noomitted nogaps booktabs label b(3) se(3) star(* .1 ** .05 *** .01) ///
collabels(none) ///
keep(I_gini_f 1.`d'#c.I_gini_f UI_gini_f 1.`d'#c.UI_gini_f cons_xtile 1.`d'#c.cons_xtile mob_exp 1.`d'#c.mob_exp 1.`d') ///
order(I_gini_f 1.`d'#c.I_gini_f UI_gini_f 1.`d'#c.UI_gini_f cons_xtile 1.`d'#c.cons_xtile mob_exp 1.`d'#c.mob_exp 1.`d') ///
stats(N N_clust r2_p wald, fmt(0 0 3 3 ) ///
labels("Number of individuals" "Number of countries" "pseudo \$R^2$" "\$p$-value Wald test \$\beta_{Ineq}$"))

********************************************************************************
**#2.10 Multilevel Model - A23 & A24
********************************************************************************
use "$working/LiTS_analysis_data", clear
drop if iso_code_2=="RU" | iso_code_2=="MK" 
est clear

foreach d in vd_democracy vd_index {

	*adjust democracy variable	
	if "`d'"=="vd_index" 		gl d "c.`d'"
	if "`d'"=="vd_democracy" 	gl d "i.`d'" 

	*run regressions
	xtmixed supdem I_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile || cname: I_gini_f $d $c_controls, reml 
	mltrsq
	eststo I
	xtmixed supdem I_gini_f $d#c.I_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile || cname: I_gini_f $d#c.I_gini_f $d $c_controls , reml 
	mltrsq
	eststo Ii
	xtmixed supdem UI_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile || cname: UI_gini_f $d $c_controls , reml 
	mltrsq
	eststo UI 
	xtmixed supdem UI_gini_f $d#c.UI_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile || cname: UI_gini_f $d#c.UI_gini_f $d $c_controls , reml 
	mltrsq
	eststo UIi
	xtmixed supdem UI_gini_f I_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile || cname: I_gini_f UI_gini_f $d $c_controls , reml 
	mltrsq 
	eststo I_UI
	xtmixed supdem I_gini_f UI_gini_f $d#c.I_gini_f $d#c.UI_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile || cname: I_gini_f UI_gini_f $d#c.UI_gini_f $d#c.I_gini_f $d $c_controls , reml 
	mltrsq
	eststo I_UIi
	xtmixed supdem UI_gini_f IR_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile || cname: IR_gini_f UI_gini_f $d $c_controls , reml 
	mltrsq 
	eststo IR_UI
	xtmixed supdem IR_gini_f UI_gini_f $d#c.IR_gini_f $d#c.UI_gini_f $d#c.cons_xtile $d#c.mob_exp $d $c_i_controls_cons_xtile || cname: IR_gini_f UI_gini_f $d#c.UI_gini_f $d#c.IR_gini_f $d $c_controls , reml 
	mltrsq
	eststo IR_UIi

	*adjust output
	if ("`d'"=="vd_democracy") {
		noi esttab I Ii UI UIi I_UI I_UIi IR_UI IR_UIi using "$tables/tab_`d'_multi.tex", replace ///
		eqlabels(none) nodepvars nonotes nomtitles noomitted nogaps booktabs label b(3) se(3) star(* .1 ** .05 *** .01) ///
		collabels(none) ///
		keep(I_gini_f 1.`d'#c.I_gini_f UI_gini_f 1.`d'#c.UI_gini_f cons_xtile 1.`d'#c.cons_xtile mob_exp 1.`d'#c.mob_exp 1.`d') ///
		order(I_gini_f 1.`d'#c.I_gini_f UI_gini_f 1.`d'#c.UI_gini_f cons_xtile 1.`d'#c.cons_xtile mob_exp 1.`d'#c.mob_exp 1.`d') ///
		stats(N N_clust sb_rsq_l1 sb_rsq_l2 , fmt(0 0 3 3) ///
		labels("Number of individuals" "Number of countries" "Level 1 \$R^2$" "Level 2 \$R^2$"))
	}
	if ("`d'"=="vd_index") {
		noi esttab I Ii UI UIi I_UI I_UIi IR_UI IR_UIi using "$tables/tab_`d'_multi.tex", replace ///
		eqlabels(none) nodepvars nonotes nomtitles noomitted nogaps booktabs label b(3) se(3) star(* .1 ** .05 *** .01) ///
		collabels(none) ///
		keep(I_gini_f $d#c.I_gini_f UI_gini_f $d#c.UI_gini_f IR_gini_f $d#c.IR_gini_f cons_xtile $d#c.cons_xtile mob_exp $d#c.mob_exp `d') ///
		order(I_gini_f $d#c.I_gini_f UI_gini_f $d#c.UI_gini_f IR_gini_f $d#c.IR_gini_f cons_xtile $d#c.cons_xtile mob_exp $d#c.mob_exp `d') ///
		stats(N N_clust sb_rsq_l1 sb_rsq_l2 , fmt(0 0 3 3) ///
		labels("Number of individuals" "Number of countries" "Level 1 \$R^2$" "Level 2 \$R^2$"))
	}
}