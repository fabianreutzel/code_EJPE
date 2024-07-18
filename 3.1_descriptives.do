/*******************************************************************************
title: 	3.2_summary_statistics
author:	Fabian Reutzel
content: 
	1.1 Descriptive Analysis - Country-level
	1.2 Descriptive Analysis - Individual-level
	2. Summary Sample Size & Circumstances - Table A1 & A2
	3.1 I/UI Estimate Summary - Graphs A
	3.1 I/UI Estimate Summary - Table A3
*******************************************************************************/
clear all 
set more off
do "C:\Users\fabia\OneDrive - Université Paris 1 Panthéon-Sorbonne\IOP and attitudes project\Fabian\do_files\micro_analysis\code_EJPE\0_globals.do"

********************************************************************************
**#1.1 Descriptive Analysis - Country-level
********************************************************************************
use "$working/LiTS_analysis_data.dta", clear

collapse I_gini_f IR_gini_f pov_rate pov_rate_int pov pov_int UI_gini_f supdem vd_democracy vd_index, by(cname iso_code_2)

*scatter plot I vs UI - Figure 1a
reg UI_gini_f I_gini_f if vd_democracy==1
loc b_demo: display %03.2f round(e(b)[1,1],.01) 
loc p_demo: display %04.3f round(r(table)[4,1],.001) 
reg UI_gini_f I_gini_f if vd_democracy==0
loc b_ndemo: display %03.2f round(e(b)[1,1],.01) 
loc p_ndemo: display %04.3f round(r(table)[4,1],.001)  
twoway scatter UI_gini_f I_gini_f if vd_democracy==1, mcolor("green") mlabcolor("black") mlabel(iso_code_2) || /*
*/ scatter UI_gini_f I_gini_f if vd_democracy==0, mcolor("red") mlabcolor("black") mlabel(iso_code_2) || /*
*/ lfit UI_gini_f I_gini_f if vd_democracy==1, lcolor("green") || /*
*/ lfit UI_gini_f I_gini_f if vd_democracy==0, lcolor("red") /*
*/ ytitle("Unfair Inequality") xtitle("Total Inequality") xlabel(0.2(0.05)0.45)  ylabel(0.05(0.05)0.2)  /*
*/ bgcolor(white) graphregion(color(white)) legend(off) /*
*/ text(.195 .225 "{&beta}{subscript:demo}= `b_demo' ({it:p}-value=`p_demo')", place(e)) /*
*/ text(.205 .225 "{&beta}{subscript:non-demo}= `b_ndemo' ({it:p}-value=`p_ndemo')", place(e)) 
graph export "$figures\scatter_I_UI.png", as(png) replace	

*scatter plot IR vs UI - Figure 1b
reg UI_gini_f IR_gini_f if vd_democracy==1
loc b_demo: display %03.2f round(e(b)[1,1],.01) 
loc p_demo: display %04.3f round(r(table)[4,1],.001) 
reg UI_gini_f IR_gini_f if vd_democracy==0
loc b_ndemo: display %03.2f round(e(b)[1,1],.01) 
loc p_ndemo: display %04.3f round(r(table)[4,1],.001) 
twoway scatter UI_gini_f IR_gini_f if vd_democracy==1, mcolor("green") mlabcolor("black") mlabel(iso_code_2) || /*
*/ scatter UI_gini_f IR_gini_f if vd_democracy==0, mcolor("red") mlabcolor("black") mlabel(iso_code_2) || /*
*/ lfit UI_gini_f IR_gini_f if vd_democracy==1, lcolor("green") || /*
*/ lfit UI_gini_f IR_gini_f if vd_democracy==0, lcolor("red") /*
*/ ytitle("Unfair Inequality") xtitle("Inequality Residual") ylabel(0.05(0.05)0.2) xlabel(0.1(0.05)0.35) /*
*/ bgcolor(white) graphregion(color(white)) legend(off) /*
*/ text(.195 .125 "{&beta}{subscript:demo}= `b_demo' ({it:p}-value=`p_demo')", place(e)) /*
*/ text(.205 .125 "{&beta}{subscript:non-demo}= `b_ndemo' ({it:p}-value=`p_ndemo')", place(e)) //
graph export "$figures\scatter_IR_UI.png", as(png) replace	

*scatter plot demo index vs. supdem - Figure 2a
reg supdem vd_index if vd_democracy==1
loc b_demo: display %03.2f round(e(b)[1,1],.01) 
loc p_demo: display %04.3f round(r(table)[4,1],.001) 
reg supdem vd_index if vd_democracy==0
loc b_ndemo: display %03.2f round(e(b)[1,1],.01) 
loc p_ndemo: display %04.3f round(r(table)[4,1],.001) 
twoway scatter supdem vd_index if vd_democracy==1, mcolor("green") mlabcolor("black") mlabel(iso_code_2) || /*
*/ scatter supdem vd_index if vd_democracy==0, mcolor("red") mlabcolor("black") mlabel(iso_code_2) || /*
*/ lfit supdem vd_index if vd_democracy==1, lcolor("green") || /*
*/ lfit supdem vd_index if vd_democracy==0, lcolor("red") /*
*/ bgcolor(white) graphregion(color(white)) legend(off) /*
*/ ytitle("Support for Democracry") xtitle("Liberal Democracy Index (V-Dem)") ylabel(0.2(0.1)0.8) xlabel(0(10)90) /*
*/ text(.78 9 "{&beta}{subscript:demo}= `b_demo' ({it:p}-value=`p_demo')", place(e)) /*
*/ text(.82 9 "{&beta}{subscript:non-demo}= `b_ndemo' ({it:p}-value=`p_ndemo')", place(e)) //
graph export "$figures\scatter_vd_index_supdem.png", as(png) replace	

*scatter plot I vs. supdem - Figure 2b
reg supdem I_gini_f if vd_democracy==1
loc b_demo: display %03.2f round(e(b)[1,1],.01) 
loc p_demo: display %04.3f round(r(table)[4,1],.001)  
reg supdem I_gini_f if vd_democracy==0
loc b_ndemo: display %03.2f round(e(b)[1,1],.01) 
loc p_ndemo: display %04.3f round(r(table)[4,1],.001) 
twoway scatter supdem I_gini_f if vd_democracy==1, mcolor("green") mlabcolor("black") mlabel(iso_code_2) || /*
*/ scatter supdem I_gini_f if vd_democracy==0, mcolor("red") mlabcolor("black") mlabel(iso_code_2) || /*
*/ lfit supdem I_gini_f if vd_democracy==1, lcolor("green") || /*
*/ lfit supdem I_gini_f if vd_democracy==0, lcolor("red") /*
*/ bgcolor(white) graphregion(color(white)) legend(off) /*
*/ ytitle("Support for Democracry") xtitle("Total Inequality") ylabel(0.2(0.1)0.8) xlabel(0.2(0.05)0.45) /*
*/ text(.78 .2 "{&beta}{subscript:demo}= `b_demo' ({it:p}-value=`p_demo')", place(e)) /*
*/ text(.82 .2 "{&beta}{subscript:non-demo}= `b_ndemo' ({it:p}-value=`p_ndemo')", place(e)) //
graph export "$figures\scatter_I_supdem.png", as(png) replace	

*scatter plot UI vs. supdem - Figure 2c
reg supdem UI_gini_f if vd_democracy==1
loc b_demo: display %03.2f round(e(b)[1,1],.01) 
loc p_demo: display %04.3f round(r(table)[4,1],.001) 
reg supdem UI_gini_f if vd_democracy==0
loc b_ndemo: display %03.2f round(e(b)[1,1],.01) 
loc p_ndemo: display %04.3f round(r(table)[4,1],.001)  
twoway scatter supdem UI_gini_f if vd_democracy==1, mcolor("green") mlabcolor("black") mlabel(iso_code_2) || /*
*/ scatter supdem UI_gini_f if vd_democracy==0, mcolor("red") mlabcolor("black") mlabel(iso_code_2) || /*
*/ lfit supdem UI_gini_f if vd_democracy==1, lcolor("green") || /*
*/ lfit supdem UI_gini_f if vd_democracy==0, lcolor("red") /*
*/ ytitle("Support for Democracry") xtitle("Unfair Inequality") ylabel(0.2(0.1)0.8) xlabel(0(0.05)0.25) /*
*/ bgcolor(white) graphregion(color(white)) legend(off) /*
*/ text(.78 .0 "{&beta}{subscript:demo}= `b_demo' ({it:p}-value=`p_demo')", place(e)) /*
*/ text(.82 .0 "{&beta}{subscript:non-demo}= `b_ndemo' ({it:p}-value=`p_ndemo')", place(e)) //
graph export "$figures\scatter_UI_supdem.png", as(png) replace	

*scatter plot IR vs. supdem - Figure 2d
reg supdem IR_gini_f if vd_democracy==1
loc b_demo: display %03.2f round(e(b)[1,1],.01) 
loc p_demo: display %04.3f round(r(table)[4,1],.001) 
reg supdem IR_gini_f if vd_democracy==0
loc b_ndemo: display %03.2f round(e(b)[1,1],.01) 
loc p_ndemo: display %04.3f round(r(table)[4,1],.001) 
twoway scatter supdem IR_gini_f if vd_democracy==1, mcolor("green") mlabcolor("black") mlabel(iso_code_2) || /*
*/ scatter supdem IR_gini_f if vd_democracy==0, mcolor("red") mlabcolor("black") mlabel(iso_code_2) || /*
*/ lfit supdem IR_gini_f if vd_democracy==1, lcolor("green") || /*
*/ lfit supdem IR_gini_f if vd_democracy==0, lcolor("red") /*
*/ ytitle("Support for Democracy") xtitle("Inequality Residual") ylabel(0.2(0.1)0.8) xlabel(0.1(0.05)0.35) /*
*/ bgcolor(white) graphregion(color(white)) legend(off) /*
*/ text(.78 .1 "{&beta}{subscript:demo}= `b_demo' ({it:p}-value=`p_demo')", place(e)) /*
*/ text(.82 .1 "{&beta}{subscript:non-demo}= `b_ndemo' ({it:p}-value=`p_ndemo')", place(e)) 
graph export "$figures\scatter_IR_supdem.png", as(png) replace	

*descriptives I,UI & IR for estimation sample (first paragraph section 5) 
drop if iso_code_2=="RU" | iso_code_2=="MK" 
pwcorr UI_gini_f I_gini_f, sig
loc rhoUII: display %04.3f round(r(rho),0.001)
di `rhoUII'
pwcorr UI_gini_f IR_gini_f, sig
loc rhoUIIR: display %04.3f round(r(rho),0.001)
	  
*descriptives poverty (footnote 26)
sum pov	 
loc povmax: display %03.2f round(r(max),0.0001)*100
loc povmean: display %03.2f round(r(mean),0.0001)*100
loc povsd: display %03.2f round(r(sd),0.0001)*100
gen UI_gini_f_pov_int = UI_gini_f * pov_int
pwcorr UI_gini_f UI_gini_f_pov_int, sig
loc rhoUIpovint: display %04.3f round(r(rho),0.001)
*re: no poverty estimates for AZ & UZ available

*save descriptives to be displayed in text
capture: file close macros_descriptives
file open macros_descriptives using "$tables/macros_descriptives.tex", write replace
    file write macros_descriptives "\newcommand{\rhoUII}{`rhoUII'}" _n	
    file write macros_descriptives "\newcommand{\rhoUIIR}{`rhoUIIR'}" _n	
    file write macros_descriptives "\newcommand{\rhoUIpovint}{`rhoUIpovint'}" _n	
	file write macros_descriptives "\newcommand{\povmax}{`povmax'}" _n	
    file write macros_descriptives "\newcommand{\povmean}{`povmean'}" _n	
    file write macros_descriptives "\newcommand{\povsd}{`povsd'}" _n	
file close macros_descriptives

********************************************************************************
**#1.2 Descriptive Analysis - Individual-level
********************************************************************************
use "$working/LiTS_analysis_data.dta", clear
drop if iso_code_2=="RU" | iso_code_2=="MK" 

*delete obs with missing variables 
gl i_controls gender edu_3c b_life_satisfaction age age_2 commu_exp minority
gl i_controls_cons_xtile $i_controls cons_xtile mob_exp
foreach x in $i_controls_cons_xtile {
drop if `x'==.
}

*scatter plot cons_xtile vs. mob_exp - Figure 3a
preserve
collapse mob_exp, by(cons_xtile vd_democracy)
reg mob_exp cons_xtile if vd_democracy==1
loc b_demo: display %03.2f round(e(b)[1,1],.01) 
loc p_demo: display %04.3f round(r(table)[4,1],.001) 
reg mob_exp cons_xtile if vd_democracy==0
loc b_ndemo: display %03.2f round(e(b)[1,1],.01) 
loc p_ndemo: display %04.3f round(r(table)[4,1],.001)  
twoway scatter mob_exp cons_xtile if vd_democracy==1, mcolor("green") || /*
*/ scatter mob_exp cons_xtile if vd_democracy==0, mcolor("red") || /*
*/ lfit mob_exp cons_xtile if vd_democracy==1, lcolor("green") || /*
*/ lfit mob_exp cons_xtile if vd_democracy==0, lcolor("red") /*
*/ ytitle("Average Mobility Experience") xtitle("Consumption Decile") ylabel(-.1(0.1)0.4) xlabel(1(1)10) /*
*/ bgcolor(white) graphregion(color(white)) legend(off) /*
*/ text(.385 2 "{&beta}{subscript:demo}= `b_demo' ({it:p}-value=`p_demo')", place(e)) /*
*/ text(.415 2 "{&beta}{subscript:non-demo}= `b_ndemo' ({it:p}-value=`p_ndemo')", place(e))
graph export "$figures\scatter_cons_xtile_mob_exp.png", as(png) replace	
restore

*scatter plot cons_xtile vs. supdem - Figure 3b
preserve
collapse supdem, by(cons_xtile vd_democracy)
reg supdem cons_xtile if vd_democracy==1
loc b_demo: display %03.2f round(e(b)[1,1],.01) 
loc p_demo: display %04.3f round(r(table)[4,1],.001) 
reg supdem cons_xtile if vd_democracy==0
loc b_ndemo: display %03.2f round(e(b)[1,1],.01) 
loc p_ndemo: display %04.3f round(r(table)[4,1],.001)  
twoway scatter supdem cons_xtile if vd_democracy==1, mcolor("green") || /*
*/ scatter supdem cons_xtile if vd_democracy==0, mcolor("red") || /*
*/ lfit supdem cons_xtile if vd_democracy==1, lcolor("green") || /*
*/ lfit supdem cons_xtile if vd_democracy==0, lcolor("red") /*
*/ ytitle("Average Support for Democracry") xtitle("Consumption Decile") ylabel(.4(0.05)0.6) xlabel(1(1)10) /*
*/ bgcolor(white) graphregion(color(white)) legend(off) /*
*/ text(.595 2 "{&beta}{subscript:demo}= `b_demo' ({it:p}-value=`p_demo')", place(e)) /*
*/ text(.6055 2 "{&beta}{subscript:non-demo}= `b_ndemo' ({it:p}-value=`p_ndemo')", place(e))
graph export "$figures\scatter_cons_xtile_supdem.png", as(png) replace	
restore

*scatter plot mob_exp vs. supdem - Figure 3c
preserve
collapse supdem, by(mob_exp vd_democracy)
reg supdem mob_exp if vd_democracy==1
loc b_demo: display %03.2f round(e(b)[1,1],.01) 
loc p_demo: display %04.3f round(r(table)[4,1],.001) 
reg supdem mob_exp if vd_democracy==0
loc b_ndemo: display %03.2f round(e(b)[1,1],.01) 
loc p_ndemo: display %04.3f round(r(table)[4,1],.001)  
twoway scatter supdem mob_exp if vd_democracy==1, mcolor("green") || /*
*/ scatter supdem mob_exp if vd_democracy==0, mcolor("red") || /*
*/ lfit supdem mob_exp if vd_democracy==1, lcolor("green") || /*
*/ lfit supdem mob_exp if vd_democracy==0, lcolor("red") /*
*/ ytitle("Average Support for Democracry") xtitle("Mobility Experience") ylabel(.4(0.05)0.6) xlabel(-2(1)2) /*
*/ bgcolor(white) graphregion(color(white)) legend(off) /*
*/ text(.595 -1.5 "{&beta}{subscript:demo}= `b_demo' ({it:p}-value=`p_demo')", place(e)) /*
*/ text(.6055 -1.5 "{&beta}{subscript:non-demo}= `b_ndemo' ({it:p}-value=`p_ndemo')", place(e))
graph export "$figures\scatter_mob_exp_supdem.png", as(png) replace	
restore

********************************************************************************
**#2. Summary Sample Size & Circumstances - Table A1 & A2
********************************************************************************
use "$working/LiTS_clean.dta", replace

*adjust cname labels
rename cname cname_og
encode iso_code_2, gen(cname)

gen N_sample=.
gen N_y=.
gen N_y_age=.
gen N_circ=.
gen N_circ_age=.
gen m_urban_birth=.
gen m_minority=.
gen m_pcommunist=.
gen m_fedu_uppsec=.
gen m_medu_uppsec=.
gen p_urban_birth=.
gen p_minority=.
gen p_pcommunist=.
gen p_fedu_uppsec=.
gen p_medu_uppsec=.

gl shares p_urban_birth p_minority p_pcommunist p_fedu_uppsec p_medu_uppsec
gl missings m_urban_birth m_minority m_pcommunist m_fedu_uppsec m_medu_uppsec
gl obs N_sample N_y N_circ N_circ_age
gl all_var $obs $missings $shares

levelsof cname, local(countries)
foreach c of local countries {
	*sample size
	qui sum cname if cname==`c'
	replace N_sample=r(N) if cname==`c'
	qui sum cname if cname==`c' & winiw_hhpc_mcons_lcu!=. 
	replace N_y=r(N) if cname==`c'
	qui sum cname if cname==`c' & winiw_hhpc_mcons_lcu!=. & working_age==1
	replace N_y_age=r(N) if cname==`c'
	qui sum cname if cname==`c' & winiw_hhpc_mcons_lcu!=. & urban_birth!=. & minority!=. & pcommunist!=. & fedu_4adj!=. & medu_4adj!=.
	replace N_circ=r(N) if cname==`c'
	qui sum cname if cname==`c' & winiw_hhpc_mcons_lcu!=. & urban_birth!=. & minority!=. & pcommunist!=. & fedu_4adj!=. & medu_4adj!=. & working_age==1
	replace N_circ_age=r(N) if cname==`c'
	*share of missings (in sample including outcome)
	foreach x in urban_birth minority pcommunist fedu_uppsec medu_uppsec {
		qui sum `x' if cname==`c' & working_age==1 & winiw_hhpc_mcons_lcu!=., detail
		replace m_`x'= (1-(r(N) / N_y_age))*100 if cname==`c' 
	}
	*share binary response
	foreach x in urban_birth minority pcommunist fedu_uppsec medu_uppsec {
		qui sum `x' if cname==`c' & working_age==1 & winiw_hhpc_mcons_lcu!=.
		replace p_`x'=r(mean) if cname==`c'
	}
}
collapse $all_var , by(country iso_code_2)
foreach x in $shares $missings {
tostring `x', replace force format(%12.2f)
}

*align order with graphs I & UI
sort iso_code_2

preserve
keep country iso_code_2 $shares
export delimited using "$tables/tab_summary_circumstances.csv", replace
restore
keep country iso_code_2 $obs $missings
export delimited using "$tables/tab_sample_missing.csv", replace

********************************************************************************
**#3.1 I/UI Estimate Summary - Graphs A
********************************************************************************
use "$working/country_data", clear 

*generate labels for graph
encode iso_code_2, gen(country_id)

*reshape to get required format
reshape long ///
UI_gini_p UI_gini_l UI_gini_u ///
UI_mld_p UI_mld_l UI_mld_u /// 
gini_p gini_l gini_u ///
mld_p mld_l mld_u , i(country_id) j(measure) string
rename *_p p_*
rename *_l l_*
rename *_u u_*
reshape long p_ l_ u_ , i(country_id measure) j(measure2) string

*comparison total inequality (gini)
preserve
keep if measure2=="gini"
gen m1 = 0 if measure=="_swiid"
replace m1 = 1 if measure=="_s"
replace m1 = 2 if measure=="_fi"
replace m1 = 3 if measure=="_fa"
gen graph_id = country_id + 0.2*m1
lab val graph_id country_id

twoway ///
rspike l_ u_ graph_id if measure=="_swiid", lcolor("black") || ///
rspike l_ u_ graph_id if measure=="_s", lcolor("green") || ///
rspike l_ u_ graph_id if measure=="_fi", lcolor("red") || ///
rspike l_ u_ graph_id if measure=="_fa", lcolor("blue") || ///
scatter p_ graph_id if measure=="_swiid", mcolor("black") || ///
scatter p_ graph_id if measure=="_s", mcolor("green") || ///
scatter p_ graph_id if measure=="_fi", mcolor("red") || ///
scatter p_ graph_id if measure=="_fa", mcolor("blue") ///
bgcolor(white) graphregion(color(white)) ///
legend(r(1) order(5 6 7 8)label(5 "SWIID") label(6 "Complete C") label(7 "Incomplete C") label(8 "Full Pop.")) ///
xtitle("") ytitle("Total Inequality (Gini)") xlabel(1(1) 28, val angle(45) labsize(small)) 
graph export "$figures/comparison_I_gini.png", as(png) replace	
restore

*comparison UI gini
preserve
keep if measure2=="UI_gini"
gen m1 = 0 if measure=="_s"
replace m1 = 1 if measure=="_c"
replace m1 = 2 if measure=="_l"
replace m1 = 3 if measure=="_f"
gen graph_id = country_id + 0.2*m1
lab val graph_id country_id

twoway ///
rspike l_ u_ graph_id if measure=="_s", lcolor("red") || ///
rspike l_ u_ graph_id if measure=="_c", lcolor("yellow") || ///
rspike l_ u_ graph_id if measure=="_l", lcolor("blue") || ///
rspike l_ u_ graph_id if measure=="_f", lcolor("green") || ///
scatter p_ graph_id if measure=="_s", mcolor("red") || ///
scatter p_ graph_id if measure=="_c", mcolor("yellow") || ///
scatter p_ graph_id if measure=="_l", mcolor("blue") || ///
scatter p_ graph_id if measure=="_f", mcolor("green") ///
xlabel(1(1) 28, val angle(45) labsize(small)) bgcolor(white) graphregion(color(white)) ///  
legend(r(1) order(5 6 7 8) label(5 "Standard") label(6 "CV")  label(7 "Lasso") label(8 "Forest")) ///
xtitle("") ytitle("Unfair Inequality (Gini)")
graph export "$figures/comparison_UI_gini.png", as(png) replace	
restore

*comparison UI mld
preserve
keep if measure2=="UI_mld"
gen m1 = 0 if measure=="_s"
replace m1 = 1 if measure=="_c"
replace m1 = 2 if measure=="_l"
replace m1 = 3 if measure=="_f"
gen graph_id = country_id + 0.2*m1
lab val graph_id country_id

twoway ///
rspike l_ u_ graph_id if measure=="_s", lcolor("red") || ///
rspike l_ u_ graph_id if measure=="_c", lcolor("yellow") || ///
rspike l_ u_ graph_id if measure=="_l", lcolor("blue") || ///
rspike l_ u_ graph_id if measure=="_f", lcolor("green") || ///
scatter p_ graph_id if measure=="_s", mcolor("red") || ///
scatter p_ graph_id if measure=="_c", mcolor("yellow") || ///
scatter p_ graph_id if measure=="_l", mcolor("blue") || ///
scatter p_ graph_id if measure=="_f", mcolor("green") ///
xlabel(1(1)28, val angle(45) labsize(small)) bgcolor(white) graphregion(color(white)) ///
legend(r(1) order(5 6 7 8) label(5 "Standard") label(6 "CV")  label(7 "Lasso") label(8 "Forest")) ///
xtitle("") ytitle("Unfair Inequality (MLD)") 
graph export "$figures/comparison_UI_mld.png", as(png) replace	
restore
	
********************************************************************************
**#3.1 I/UI Estimate Summary - Table A3
********************************************************************************
*UI
use "$working/country_data", clear 
keep country iso_code_2 UI_gini_p* UI_gini_l* UI_gini_u*
collapse UI_gini*, by(country iso_code_2)
tostring UI_gini*, replace force format(%12.3f)
foreach x in `r(varlist)' {
replace `x' = substr(`x', 1, 5) 
}
expand 2, gen(dup)
foreach x in s c l f fi fa {
gen ci_`x'= "["+UI_gini_l_`x'+";"+UI_gini_u_`x'+"]"
replace UI_gini_p_`x' = ci_`x' if dup==1
}

sort iso_code_2 dup
keep country iso_code_2 dup UI_gini_p_s UI_gini_p_c UI_gini_p_l UI_gini_p_f UI_gini_p_fi UI_gini_p_fa
order country iso_code_2 dup UI_gini_p_s UI_gini_p_c UI_gini_p_l UI_gini_p_f UI_gini_p_fi UI_gini_p_fa
bysort country (dup): replace country="" if _n!=1
sort iso_code_2 dup
lab var UI_gini_p_s "Standard"
lab var UI_gini_p_c "CV"
lab var UI_gini_p_l	"Lasso"
lab var UI_gini_p_f	"F Complete C" 
lab var UI_gini_p_fi "F Incomplete C" 
lab var UI_gini_p_fa "F Full Pop." 
save "$working/summary_UI_gini.dta", replace

*gini
use "$working/country_data", clear 
keep country iso_code_2 gini_p* gini_l* gini_u*
collapse gini*, by(country iso_code_2)
tostring gini*, replace force format(%12.3f)
foreach x in `r(varlist)' {
replace `x' = substr(`x', 1, 5) 
}
expand 2, gen(dup)
foreach x in swiid s fi fa {
gen ci_`x'= "["+gini_l_`x'+";"+gini_u_`x'+"]"
replace gini_p_`x' = ci_`x' if dup==1
}
sort iso_code_2 dup
keep country iso_code_2 dup gini_p_swiid gini_p_s gini_p_fi gini_p_fa
order country iso_code_2 dup gini_p_swiid gini_p_s gini_p_fi gini_p_fa
bysort country (dup): replace country="" if _n!=1
sort iso_code_2 dup
lab var gini_p_swiid "SWIID"
lab var gini_p_s "Full C"
lab var gini_p_fi "Incomplete C" 
lab var gini_p_fa "Full Population" 
save "$working/summary_gini.dta", replace

*combine I&UI
use "$working/summary_gini.dta", clear
merge 1:1 dup iso_code_2 using "$working/summary_UI_gini.dta", nogen
sort iso_code_2 dup
drop dup iso_code_2
lab var country "Country"
export delimited using "$tables/tab_I_UI.csv", replace