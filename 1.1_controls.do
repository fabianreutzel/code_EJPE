/******************************************************************************\
1.1 control variables dataset generation
author: Fabian Reutzel	
structure: 	
	1. Macro data (source:  World Economic Outlook database October 2021 IMF) 
	2. Governance Indicators (source: World Governance Indicators World Bank)
	3. Democracy Index (source: Varieties of Democracy)
	4. Gini Index (source: SWIID)
	5. GDP growth, PPP, Unemployment (source: World Development Indicators (WDI) World Bank)
	6. Poverty rates (source: Poverty and Inequality Platform (PIP) World Bank)
	7. generate long-run averages 3/5y 
\******************************************************************************/

clear all
set more off

*load file paths
do "C:\Users\fabia\OneDrive - Université Paris 1 Panthéon-Sorbonne\IOP and attitudes project\Fabian\do_files\micro_analysis\code_EJPE\0_globals.do"

********************************************************************************
**#1. Macro data (source:  World Economic Outlook database October 2021 IMF) 
*https://www.imf.org/external/pubs/ft/weo/2019/02/weodata/download.aspx
*re: need to use WEO instead of WDI because of braoder coverage
********************************************************************************
*import excel "World Economic Outlook (WEO) Oct2019.xlsx", sheet("WEOOct2019all") firstrow case(lower) clear
import excel "$controls\World Economic Outlook (WEO) Oct2021.xlsx", sheet("WEOOct2021all") firstrow case(lower) clear

*remove non-needed variables & years 
keep(iso weosubjectcode subjectdescriptor units scale year2005-year2016)
rename weosubjectcode code
rename iso iso_code
keep if (code=="PCPI" | code=="NGDPRPPPPC" | code=="GGX_NGDP" | code=="LUR") 

*remove non-needed countries 
merge m:1  iso_code using "$controls\countrymatch.dta", keep(match) nogen //adjusted 
replace iso_code = "XKX" if iso_code=="UVK" 

*recode missings
forvalues y = 2005(1)2016 {
	replace year`y'="" if year`y'=="--"
	replace year`y'="" if year`y'=="n/a"
	}
destring year*, replace ignore(",")

*reshape
drop scale units subjectdescriptor 
reshape wide year2005-year2016 , i(iso_code) j(code) string
*rename and label variables
forvalues y = 2005(1)2016 {
rename year`y'GGX_NGDP govexp`y'
lab var govexp`y' "General government total expenditure `y', in % of GDP"
rename year`y'NGDPRPPPPC gdppc`y'
lab var gdppc`y' "GDP per capita `y', constant prices internat. $(PPP 2011)"
rename year`y'PCPI infl`y'
lab var infl`y' "Inflation, average consumer prices `y', Index"
rename year`y'LUR unempl_weo`y'
lab var infl`y' "Inflation, average consumer prices `y', Index"
}
reshape long govexp unempl_weo gdppc infl, i(iso_code country) j(year) 
lab var govexp "General government total expenditure, in % of GDP"
lab var gdppc "log GDP per capita, constant prices internat. $(PPP 2011)"
lab var infl "Inflation, average consumer prices, Index"
lab var unempl_weo "Unemployment rate,  in % of total labor force"
save "$working\controls.dta", replace

********************************************************************************
**#2. Governance Indicators (source: World Governance Indicators World Bank)
*https://info.worldbank.org/governance/wgi/
********************************************************************************
use "$controls\World Governance Indicators (WGI).dta", clear
keep(gee rqe rle cce vae pve countryname year code)
rename code iso_code
*ADJUST iso code for merge
replace iso_code = "ROU" if iso_code=="ROM"
replace iso_code = "XKX" if iso_code=="KSV" 

*governance=(average of government effectiveness, regulatory quality, the rule of law and control of corruption; see Transition Report 2013, page 39)
gen governance=(gee+rqe+rle+cce) / 4
lab var governance "average governance score across non-demo dimensions"
keep iso_code year governance
merge 1:1 iso_code year using "$working\controls.dta", keep(match using) nogen 
save "$working\controls.dta", replace

********************************************************************************
**#3. Democracy Index (source: Varieties of Democracy)
*https://www.v-dem.net/en/data/data-version-10/
********************************************************************************
use "$controls\V-Dem\V-Dem-CY-Core-v10.dta", clear
rename country_text_id iso_code
rename v2x_libdem vd_index
rename v2x_polyarchy vd_polyarchy
rename v2x_regime vd_regime
keep year iso_code vd_index vd_polyarchy vd_regime
merge m:1 iso_code year using "$working\controls", keep(match) nogen
save "$working\controls.dta", replace

********************************************************************************
**#4. Gini Index (source: SWIID)
*https://fsolt.org/swiid/
********************************************************************************
*import delimited "SWIID\swiid8_3.csv", varnames(1) clear
import delimited "$controls\SWIID\swiid9_6\swiid9_6_summary.csv", varnames(1) clear

replace country="BiH" if country=="Bosnia and Herzegovina"
replace country="Czech" if country=="Czech Republic"
replace country="FRYOM" if country=="North Macedonia"
keep country year gini_disp gini_disp_se gini_mkt gini_mkt_se
gen gini_mkt_l = (gini_mkt - 1.96*gini_mkt_se)/100
gen gini_mkt_u = (gini_mkt + 1.96*gini_mkt_se)/100
gen gini_disp_l = (gini_disp - 1.96*gini_disp_se)/100
gen gini_disp_u = (gini_disp + 1.96*gini_disp_se)/100
replace gini_disp = gini_disp /100
replace gini_mkt = gini_mkt /100

merge 1:1 country year using "$working\controls.dta", keep(match using) nogen 
save "$working\controls.dta", replace

********************************************************************************
**#5. GDP growth, PPP, Unemployment (source: World Development Indicators (WDI) World Bank )
*re: low poverty coverage => use of PIP
********************************************************************************
import delimited "$controls\World Development Indicators (WDI)\WDIData.csv", varnames(1) clear
keep if (indicatorname=="PPP conversion factor, GDP (LCU per international $)" | ///
	indicatorname=="PPP conversion factor, private consumption (LCU per international $)" | ///
	indicatorname=="GDP per capita growth (annual %)" | ///
	indicatorname=="Population, total" | ///
	indicatorname=="Unemployment, total (% of total labor force) (modeled ILO estimate)")
drop indicatorname
rename countrycode iso_code
replace indicatorcode ="ppp_gdp" if indicatorcode=="PA.NUS.PPP"
replace indicatorcode ="ppp_cons" if indicatorcode=="PA.NUS.PRVT.PP"
replace indicatorcode ="gdppc_growth" if indicatorcode=="NY.GDP.PCAP.KD.ZG"
replace indicatorcode ="pop" if indicatorcode=="SP.POP.TOTL"
replace indicatorcode ="unempl" if indicatorcode=="SL.UEM.TOTL.ZS"

reshape long v , i(iso_code indicatorcode) j(y)
rename v value
rename y year 
replace year = year + 1960
reshape wide value , i(iso_code year) j(indicatorcode) string
foreach x in ppp_gdp ppp_cons gdppc_growth pop unempl {
rename value`x' `x'
}

*adjusted PPP based on private consumption
gen ppp = ppp_cons
replace ppp = ppp_gdp if ppp_cons==.
lab var ppp "Purchasing Power Parity based on priv cons, (LCU/internat$)"
drop ppp_gdp ppp_cons

merge 1:1 iso_code year using "$working\controls.dta", keep(match using) nogen

*fill missing Unemployment for Kosovo from WEO
replace unempl = unempl_weo if unempl==.
drop unempl_weo

save "$working\controls.dta", replace

********************************************************************************
**#6. Poverty rates (source: Poverty and Inequality Platform (PIP) World Bank)
*re: use intrapolated data (_intrapol)
********************************************************************************
import delimited "$controls\pip.csv", varnames(1) clear

*prefer national consumption-based estimates if available 
duplicates tag reporting_year country_name, gen(dup)
drop if dup!=0 & (welfare_type!="consumption"|reporting_level!="national")
ren country_code iso_code
ren reporting_year year 
ren headcount poverty
lab var poverty "Poverty Headcount"

keep poverty iso_code year 
merge 1:1 iso_code year using "$working\controls.dta", keep(match using) nogen
replace poverty = .0021093 if iso_code=="MNG" & year==2015 //use value of 2014
*re: AZ & UZ only in 2003/2005 

save "$working\controls.dta", replace

********************************************************************************
**#7. generate long-run averages 3/5y 
********************************************************************************
use "$working\controls.dta", clear

*absolute changes
foreach x in govexp unempl infl poverty gdppc_growth {
bysort iso_code (year): gen `x'_y = sum(`x')
bysort iso_code (year): gen `x'_3y = (`x'_y[_n] - `x'_y[_n-2])/2 if (`x'[_n]!=.&`x'[_n-1]!=.&`x'[_n-2]!=.)
bysort iso_code (year): gen `x'_5y = (`x'_y[_n] - `x'_y[_n-4])/4 if (`x'[_n]!=.&`x'[_n-1]!=.&`x'[_n-2]!=.&`x'[_n-3]!=.&`x'[_n-4]!=.)
drop `x'_y
}

*annualized changes
bysort iso_code (year): gen gdppc_growth_3y_annu = (gdppc[_n] - gdppc[_n-3])/(3*gdppc[_n-3]) if (gdppc[_n]!=.&gdppc[_n-3]!=.)
bysort iso_code (year): gen gdppc_growth_5y_annu = (gdppc[_n] - gdppc[_n-5])/(5*gdppc[_n-5]) if (gdppc[_n]!=.&gdppc[_n-5]!=.)

*keep year of interest & adjust variable names accordingly
keep if year==2015|year==2010
order iso_code iso_code_2 countryname country cname
reshape wide poverty-gdppc_growth_5y_annu, i(iso_code iso_code_2 countryname country cname) j(year)
ren gdppc_growth_5y_annu2010 gdppc_growth_5y_annu20102015
ren gdppc2010 gdppc20102015
drop *2010
ren *2015 *

*adjust missing Unemployment for Kosovo
replace unempl_5y = (30.9+30+35.3+32.9)/4 if country=="Kosovo" // 4year average 

*adjust for currency reform Belarus 2016 (PPP in new currency)
replace ppp = ppp * 10000 if iso_code=="BLR"

save "$working\controls.dta", replace