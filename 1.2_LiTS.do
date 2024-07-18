/*******************************************************************************
title: 	1.2_LiTS
author:	Fabian Reutzel
content: 
	1. load data & restrict sample to former communist countries
	2. individual-level variables
	3. monthly HH total consumption per capita
	4. adjust parental education
	5. adjust circumstances with only mariginal variation 
	6. add controls and save dataset	
*******************************************************************************/
clear all 
set more off

*load file paths
do "C:\Users\fabia\OneDrive - Université Paris 1 Panthéon-Sorbonne\IOP and attitudes project\Fabian\do_files\micro_analysis\code_EJPE\0_globals.do"

********************************************************************************
**#1. load data & restrict sample to former communist countries
*https://www.ebrd.com/what-we-do/economic-research-and-data/data/lits.html
********************************************************************************
use "$data\LiTS III", clear 

*generate numeric country variable
encode country, gen(cname)

*drop non-communist countries 
drop if (country=="Germany"|country=="Italy"|country=="Cyprus"|country=="Greece"|country=="Turkey")

*drop BiH following Gugushvili (2020)
drop if country=="Bosnia and Herz." 

ren weight_population weight_pop

********************************************************************************
**#2. individual-level variables
********************************************************************************
gen gender = (gender_pr==2) if gender_pr!=.
lab define gender 0 "Male" 1 "Female"
lab val gender gender

*age
ren age_pr age 
gen age_2 = age * age					
gen age_cat = 1 if age<25 
replace age_cat = 2 if (age>24 & age<35)
replace age_cat = 3 if (age>34 & age<45)
replace age_cat = 4 if (age>44 & age<55)
replace age_cat = 5 if (age>54 & age<65)
replace age_cat = 6 if (age>64)
lab define age_cat 1 "18-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55-64" 6 "65+"
lab val age_cat age_cat
gen year_birth = 2015 - age
gen cohort_10y 	  = 0 if year_birth>1985
replace cohort_10y = 1 if year_birth<=1985 & year_birth>1975
replace cohort_10y = 2 if year_birth<=1975 & year_birth>1965
replace cohort_10y = 3 if year_birth<=1965 & year_birth>1955
replace cohort_10y = 4 if year_birth<=1955 & year_birth>1945
replace cohort_10y = 5 if year_birth<=1945 
label def cohort_10y 0 "born $>$1985" 1 "born 1985-1976" 2 "born 1975-1966" 3 "born 1965-1956" 4 "born 1955-1946" 5 "born $<$1946"
lab val cohort_10y cohort_10y
*experience labor market under communism 16 or younger at fall of wall 1990
gen commu_exp = 0
replace commu_exp= 1 if age>42 
gen working_age = (age_c>1 & age_c<6)

*HH head identifier for primary respondent (i.e., primary respondent==HH head)
gen hhhead = 0
forvalues x = 1(1)10 {
	replace hhhead = 1 if (b2a==`x' & q104_`x'==1)
}

*HH size (considering ONLY individuals who have lived in HH for past six months)
forvalues x = 1(1)10 {
	recode q102_`x' 2=0
}
egen hhsize=rowtotal(q102_1 q102_2 q102_3 q102_4 q102_5 q102_6 q102_7 q102_8 q102_9 q102_10) 

*marital status 
gen married= (q107_1==2|q107_1==5) if q107_1!=.

*education
gen edu = q109_1
replace edu = 6 if (q109_1==6|q109_1==7|q109_1==8) 
replace edu = edu - 1
lab define edu /*
	*/0 "No Education" /*
	*/1 "Primary" /*
	*/2 "Lower Secondary" /*
	*/3 "Upper Secondary" /*
	*/4 "Post-Secondary" /*
	*/5 "Tertiary"
lab val edu edu
gen edu_3c = edu
replace edu_3c = 0 if (edu==0|edu==1) 
replace edu_3c = 1 if (edu==2|edu==3|edu==4)
replace edu_3c = 2 if (edu==5) 
lab def edu_3c /*
	*/0 "No/Primary Education" /*
	*/1 "Secondary Education" /*
	*/2 "Tertiary Education"
lab val edu_3c edu_3c

*urban/rural status
ren urban urban_pr
gen urban=.
replace urban=1 if urban_pr==1
replace urban=0 if urban_pr==2 
lab drop urban
lab define urban 0 "Rural" 1 "Urban"
lab val urban urban

*place of birth: urban/rural 
gen urban_birth = urban if q908==-90|(age-q908<10) //length of time in this town/city
replace urban_birth = 1 if q910c==1|(q911c==1 & q910c==.)
replace urban_birth = 0 if q910c==2|(q910c==2 & q910c==.)
lab val urban_birth urban

*Communist party membership of parents
gen pcommunist=.
replace pcommunist=1 if (q920b==1|q920c==1)
replace pcommunist=0 if (q920b==0 & q920c==0)
lab define pcommunist 0 "Parents not member" 1 "Either mother or father member"
lab val pcommunist pcommunist

*minority status
gen minority = .
replace minority=0 if q923==1
replace minority=1 if (q923!=1 & q923!=-99) //treat refusal as missing

**parental education
*recode missings
replace q110_1 = . if (q110_1==-97)
replace q111_1 = . if (q111_1==-97)
gen fedu = q110_1
replace fedu = 6 if (q110_1==6|q110_1==7|q110_1==8) 
replace fedu = fedu - 1
gen medu = q111_1
replace medu = 6 if (q111_1==6|q111_1==7|q111_1==8) 
replace medu = medu - 1
gen pedu = fedu
replace pedu = medu if (medu>fedu & medu!=.|fedu==.) 
lab val pedu edu

**perception & attitude
ren q401e life_satisfaction
gen b_life_satisfaction=.
replace b_life_satisfaction=1 if life_satisfaction==4|life_satisfaction==5
replace b_life_satisfaction=0 if life_satisfaction==1|life_satisfaction==2|life_satisfaction==3

*support for democracy 
ren q412 demo_support
gen supdem = (demo_support==1 & demo_support!=.) if demo_support>0 
*re: "Don't know -97" responses are excluded as it cannot be distinguish from item non-response

*mobility experience 
gen mob_exp = q401c
replace mob_exp =. if mob_exp==-98|mob_exp==-97 //not applicable & don't know
replace mob_exp = mob_exp - 3 //center variable

********************************************************************************
**#3. monthly HH total consumption per capita
********************************************************************************
*change DON'T KNOW/REFUSAL into missings
replace q221a=. if q221a==-99|q221a==-97
replace q221b=. if q221b==-99|q221b==-97
replace q221c=. if q221c==-99|q221c==-97
replace q222a=. if q222a==-99|q222a==-97
replace q222b=. if q222b==-99|q222b==-97
replace q222c=. if q222c==-99|q222c==-97
replace q222d=. if q222d==-99|q222d==-97

*generate consumption items
gen mexp_food=q221a 		//monthly expenditure in food
gen mexp_util=q221b 		//monthly expenditure in utilities
gen mexp_trans=q221c 		//monthly expenditure in transports
gen mexp_educ=q222a/12 		//monthly expenditure in education
gen mexp_health=q222b/12	//monthly expenditure in health
gen mexp_cloth=q222c/12		//monthly expenditure in clothing 
gen mexp_durg=q222d/12		//monthly expenditure in durable goods

gl mexp mexp_food mexp_util mexp_trans mexp_educ mexp_health mexp_cloth mexp_durg

*drop Outlier PSUs of Albania 
foreach x in $mexp {
	replace `x'=. if (PSU_number==3|PSU_number==4|PSU_number==5) & cname==1
}

*HH total monthly consumption expenditure 
gen hh_mcons_lcu = (mexp_food + mexp_util + mexp_trans + mexp_educ + mexp_health + mexp_cloth + mexp_durg)
replace hh_mcons_lcu = . if hh_mcons_lcu==0
lab var hh_mcons_lcu "HH total monthly consumption, in LCU"

*HH total monthly consumption expenditure - winsorized by item
foreach i in $mexp{
	winsor2 `i', suffix(_wini) cuts(0.5 99.5) by(cname) 
}
gen hh_mcons_lcu_wini = (mexp_food_wini + mexp_util_wini + mexp_trans_wini + mexp_educ_wini + mexp_health_wini + mexp_cloth_wini + mexp_durg_wini)

*hh per capita consumption expenditure 
gen hhpc_mcons_lcu = hh_mcons_lcu / hhsize
gen wini_hhpc_mcons_lcu = hh_mcons_lcu / hhsize

*winsorize
winsor2 wini_hhpc_mcons_lcu, suffix(_w) cuts(0.5 99.5) by(cname)
ren wini_hhpc_mcons_lcu_w winiw_hhpc_mcons_lcu
lab var hhpc_mcons_lcu "HHpc monthly consumption, in LCU"
lab var wini_hhpc_mcons_lcu "HHpc monthly consumption win by item, in LCU"
lab var winiw_hhpc_mcons_lcu "HHpc monthly consumption win by item & overall, in LCU"

*generate consumption decentiles
gen cons_xtile=.
levelsof cname, local (countries)
foreach c of local countries {
xtile cons_xtile_`c' = wini_hhpc_mcons if cname==`c' , n(10)
replace cons_xtile=cons_xtile_`c' if cons_xtile_`c'!=.
drop *_xtile_*
}

********************************************************************************
**#4. adjust parental education
********************************************************************************
*generate 4 category country-adjusted parental education variables 
foreach x in fedu medu pedu { //using country-based aggregation
	gen `x'_4adj =.
	*Albania 
	replace `x'_4adj = 0 if (`x'==0|`x'==1) & country=="Albania"
	replace `x'_4adj = 1 if (`x'==2) & country=="Albania"
	replace `x'_4adj = 2 if (`x'==3) & country=="Albania"
	replace `x'_4adj = 3 if (`x'==4|`x'==5) & country=="Albania"

	*Armenia
	replace `x'_4adj = 0 if (`x'==0|`x'==1|`x'==2) & country=="Armenia"
	replace `x'_4adj = 1 if (`x'==3) & country=="Armenia"
	replace `x'_4adj = 2 if (`x'==4) & country=="Armenia"
	replace `x'_4adj = 3 if (`x'==5) & country=="Armenia"

	*Azerbaijan
	replace `x'_4adj = 0 if (`x'==0|`x'==1|`x'==2) & country=="Azerbaijan"
	replace `x'_4adj = 2 if (`x'==3|`x'==4) & country=="Azerbaijan"
	replace `x'_4adj = 3 if (`x'==5) & country=="Azerbaijan"

	*Belarus
	replace `x'_4adj = 0 if (`x'==0|`x'==1|`x'==2) & country=="Belarus"
	replace `x'_4adj = 1 if (`x'==3) & country=="Belarus"
	replace `x'_4adj = 2 if (`x'==3) & country=="Belarus"
	replace `x'_4adj = 3 if (`x'==5) & country=="Belarus"

	*Bulgaria
	replace `x'_4adj = 0 if (`x'==0) & country=="Bulgaria"
	replace `x'_4adj = 1 if (`x'==1) & country=="Bulgaria"
	replace `x'_4adj = 2 if (`x'==2|`x'==3) & country=="Bulgaria"
	replace `x'_4adj = 3 if (`x'==4|`x'==5) & country=="Bulgaria"

	*Croatia
	replace `x'_4adj = 0 if (`x'==0) & country=="Croatia"
	replace `x'_4adj = 1 if (`x'==1|`x'==2) & country=="Croatia"
	replace `x'_4adj = 2 if (`x'==3) & country=="Croatia"
	replace `x'_4adj = 3 if (`x'==4|`x'==5) & country=="Croatia"

	*Czech 
	replace `x'_4adj = 0 if (`x'==0|`x'==1) & country=="Czech Rep."
	replace `x'_4adj = 2 if (`x'==3) & country=="Czech Rep."
	replace `x'_4adj = 3 if (`x'==4|`x'==5) & country=="Czech Rep."

	*Estonia
	replace `x'_4adj = 0 if (`x'==0|`x'==1) & country=="Estonia"
	replace `x'_4adj = 1 if (`x'==2|`x'==3) & country=="Estonia"
	replace `x'_4adj = 2 if (`x'==4) & country=="Estonia"
	replace `x'_4adj = 3 if (`x'==5) & country=="Estonia"

	*FRYOM
	replace `x'_4adj = 0 if (`x'==0) & country=="FYR Macedonia"
	replace `x'_4adj = 1 if (`x'==1) & country=="FYR Macedonia"
	replace `x'_4adj = 2 if (`x'==2|`x'==3) & country=="FYR Macedonia"
	replace `x'_4adj = 3 if (`x'==4|`x'==5) & country=="FYR Macedonia"

	*Georgia
	replace `x'_4adj = 0 if (`x'==0|`x'==1|`x'==2) & country=="Georgia"
	replace `x'_4adj = 1 if (`x'==3) & country=="Georgia"
	replace `x'_4adj = 2 if (`x'==4) & country=="Georgia"
	replace `x'_4adj = 3 if (`x'==5) & country=="Georgia"

	*Hungary
	replace `x'_4adj = 0 if (`x'==0) & country=="Hungary"
	replace `x'_4adj = 1 if (`x'==1|`x'==2) & country=="Hungary"
	replace `x'_4adj = 2 if (`x'==3) & country=="Hungary"
	replace `x'_4adj = 3 if (`x'==4|`x'==5) & country=="Hungary"

	*Kazakhstan
	replace `x'_4adj = 0 if (`x'==0|`x'==1) & country=="Kazakhstan"
	replace `x'_4adj = 1 if (`x'==2|`x'==3) & country=="Kazakhstan"
	replace `x'_4adj = 2 if (`x'==4) & country=="Kazakhstan"
	replace `x'_4adj = 3 if (`x'==5) & country=="Kazakhstan"

	*Kosovo
	replace `x'_4adj = 0 if (`x'==0) & country=="Kosovo"
	replace `x'_4adj = 1 if (`x'==1) & country=="Kosovo"
	replace `x'_4adj = 2 if (`x'==2|`x'==3) & country=="Kosovo"
	replace `x'_4adj = 3 if (`x'==4|`x'==5) & country=="Kosovo"

	*Kyrgyz Rep.
	replace `x'_4adj = 0 if (`x'==0|`x'==1) & country=="Kyrgyz Rep."
	replace `x'_4adj = 1 if (`x'==2) & country=="Kyrgyz Rep."
	replace `x'_4adj = 2 if (`x'==3|`x'==4) & country=="Kyrgyz Rep."
	replace `x'_4adj = 3 if (`x'==5) & country=="Kyrgyz Rep."

	*Latvia
	replace `x'_4adj = 0 if (`x'==0) & country=="Latvia"
	replace `x'_4adj = 1 if (`x'==1|`x'==2) & country=="Latvia"
	replace `x'_4adj = 2 if (`x'==3|`x'==4) & country=="Latvia"
	replace `x'_4adj = 3 if (`x'==5) & country=="Latvia"

	*Lithuania
	replace `x'_4adj = 0 if (`x'==0) & country=="Lithuania"
	replace `x'_4adj = 1 if (`x'==1|`x'==2) & country=="Lithuania"
	replace `x'_4adj = 2 if (`x'==3|`x'==4) & country=="Lithuania"
	replace `x'_4adj = 3 if (`x'==5) & country=="Lithuania"

	*Moldova
	replace `x'_4adj = 0 if (`x'==0|`x'==1) & country=="Moldova"
	replace `x'_4adj = 1 if (`x'==2) & country=="Moldova"
	replace `x'_4adj = 2 if (`x'==3 ) & country=="Moldova"
	replace `x'_4adj = 3 if (`x'==4|`x'==5) & country=="Moldova"

	*Mongolia
	replace `x'_4adj = 0 if (`x'==0|`x'==1) & country=="Mongolia"
	replace `x'_4adj = 1 if (`x'==2) & country=="Mongolia"
	replace `x'_4adj = 2 if (`x'==3 ) & country=="Mongolia"
	replace `x'_4adj = 3 if (`x'==4|`x'==5) & country=="Mongolia"

	*Montenegro
	replace `x'_4adj = 0 if (`x'==0) & country=="Montenegro"
	replace `x'_4adj = 1 if (`x'==1|`x'==2) & country=="Montenegro" 
	replace `x'_4adj = 2 if (`x'==3|`x'==4) & country=="Montenegro"
	replace `x'_4adj = 3 if (`x'==5) & country=="Montenegro"

	*Poland
	replace `x'_4adj = 0 if (`x'==0|`x'==1) & country=="Poland"
	replace `x'_4adj = 1 if (`x'==2|`x'==3) & country=="Poland"
	replace `x'_4adj = 2 if (`x'==4|`x'==5) & country=="Poland"

	*Romania
	replace `x'_4adj = 0 if (`x'==0|`x'==1) & country=="Romania"
	replace `x'_4adj = 1 if (`x'==2) & country=="Romania"
	replace `x'_4adj = 2 if (`x'==3|`x'==4) & country=="Romania"
	replace `x'_4adj = 3 if (`x'==5) & country=="Romania"

	*Russia
	replace `x'_4adj = 0 if (`x'==0|`x'==1|`x'==2) & country=="Russia"
	replace `x'_4adj = 1 if (`x'==3) & country=="Russia"
	replace `x'_4adj = 2 if (`x'==4) & country=="Russia"
	replace `x'_4adj = 3 if (`x'==5) & country=="Russia"

	*Serbia
	replace `x'_4adj = 0 if (`x'==0) & country=="Serbia"
	replace `x'_4adj = 1 if (`x'==1) & country=="Serbia"
	replace `x'_4adj = 2 if (`x'==2|`x'==3) & country=="Serbia"
	replace `x'_4adj = 3 if (`x'==4|`x'==5) & country=="Serbia"

	*Slovakia
	replace `x'_4adj = 0 if (`x'==0|`x'==1) & country=="Slovak Rep."
	replace `x'_4adj = 1 if (`x'==2) & country=="Slovak Rep."
	replace `x'_4adj = 2 if (`x'==3|`x'==4) & country=="Slovak Rep."
	replace `x'_4adj = 3 if (`x'==5) & country=="Slovak Rep."

	*Slovenia
	replace `x'_4adj = 0 if (`x'==0|`x'==1) & country=="Slovenia"
	replace `x'_4adj = 1 if (`x'==2) & country=="Slovenia"
	replace `x'_4adj = 2 if (`x'==3) & country=="Slovenia"
	replace `x'_4adj = 3 if (`x'==4|`x'==5) & country=="Slovenia"

	*Tajikistan
	replace `x'_4adj = 0 if (`x'==0|`x'==1) & country=="Tajikistan"
	replace `x'_4adj = 1 if (`x'==2) & country=="Tajikistan"
	replace `x'_4adj = 2 if (`x'==3) & country=="Tajikistan"
	replace `x'_4adj = 3 if (`x'==4|`x'==5) & country=="Tajikistan"

	*Ukraine
	replace `x'_4adj = 0 if (`x'==0|`x'==1) & country=="Ukraine"
	replace `x'_4adj = 1 if (`x'==2|`x'==3) & country=="Ukraine"
	replace `x'_4adj = 2 if (`x'==4) & country=="Ukraine"
	replace `x'_4adj = 3 if (`x'==5) & country=="Ukraine"

	*Uzbekistan
	replace `x'_4adj = 0 if (`x'==0|`x'==1|`x'==2) & country=="Uzbekistan"
	replace `x'_4adj = 1 if (`x'==3) & country=="Uzbekistan"
	replace `x'_4adj = 2 if (`x'==4) & country=="Uzbekistan"
	replace `x'_4adj = 3 if (`x'==5) & country=="Uzbekistan"
}

*generate binary variables for CV estimation (incl. initial granularity) 
lab def edu_ter 0 "no tertiary" 1 "tertiary"
lab def edu_uppsec 0 "no upper/postsec/tert" 1 "upper/postsec/tert"
lab def edu_sec 0 "no/primary" 1 ">primary"
foreach x in fedu medu pedu {
	gen `x'_ter = 0 if (`x'!=. & `x'<5)
	replace `x'_ter = 1 if (`x'==5) 
	lab val `x'_ter edu_ter

	gen `x'_uppsec = 0 if (`x'!=. & `x'<3)
	replace `x'_uppsec = 1 if (`x'==3|`x'==4|`x'==5) 
	lab val `x'_uppsec edu_uppsec

	gen `x'_sec = 0 if (`x'!=. & `x'<2)
	replace `x'_sec = 1 if (`x'==2|`x'==3|`x'==4|`x'==5) 
	lab val `x'_sec edu_sec 
}

*adjust country names in line with current naming conventions 
replace country="Czech Republic" if country=="Czech Rep."
replace country="North Macedonia" if country=="FYR Macedonia"
replace country="Kyrgyzstan" if country=="Kyrgyz Rep."
replace country="North Macedonia" if country=="Kyrgyz Rep."
replace country="Slovakia" if country=="Slovak Rep."

********************************************************************************
**#5. adjust circumstances with only mariginal variation 
********************************************************************************
*replace minority for countries in which share of estimation sample too small
levelsof cname, local (countries)
foreach c of local countries {
qui sum minority if cname==`c' & winiw_hhpc_mcons_lcu!=.
if r(mean)<0.05{
di `c'
replace minority = 0 if cname==`c'
}
	qui tab minority if minority==1 & cname==`c' & winiw_hhpc_mcons_lcu!=.
	if r(N)<50 {
		replace minority = 0 if cname==`c'
	}
}
*replace communist party membership for countries in which share of estimation sample too small
levelsof cname , local (countries)
foreach c of local countries {
	qui tab pcommunist if pcommunist==1 & cname==`c' & winiw_hhpc_mcons_lcu!=.
	if r(N)<50 {
		replace pcommunist = 0 if cname==`c'
	}
}

********************************************************************************
**#6. add controls and save datasets
********************************************************************************´
*add controls
merge m:1 cname using "$working\controls.dta", keep(match) nogen 
save "$working\LiTS_clean.dta", replace

**save data for IOp estimation

*generate integer frequence weights
*re: Survey weights that add up to population totals => interpretation as fw
gen fw = round(weight_pop)

*adjust outcome variable
rename winiw_hhpc_mcons_lcu y
gen ln_y = ln(y)
drop if y==.

preserve
*restrict sample to working age individuals (equalchances.org)	
keep if working_age==1

*save data paramteric UI estimation (stata)
keep iso_code_2 fw y ln_y urban_birth minority pcommunist fedu_4adj medu_4adj ///
pedu_4adj pedu_ter fedu_ter medu_ter pedu_uppsec fedu_uppsec medu_uppsec pedu_sec fedu_sec medu_sec //additional vars for CV
save "$working\LiTS_IOp_data", replace

*save data forest UI estimation (R)
keep iso_code_2 fw y urban_birth minority pcommunist fedu_4adj medu_4adj 
ren iso_code_2 country
export delimited using "$working\LiTS_IOp_data.csv", nolab replace
restore 

*save data forest UI estimation (R) without working age restriction
keep iso_code_2 fw y urban_birth minority pcommunist fedu_4adj medu_4adj 
ren iso_code_2 country
export delimited using "$working\LiTS_IOp_data_all.csv", nolab replace