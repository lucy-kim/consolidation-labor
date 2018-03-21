*create BLS OES panel data, ideally at the MSA-industry-occupation level, for 2005-2016

local dta /ifs/home/kimk13/locallabor/data
cd `dta'/labordata

*for years split into multiple files append first
/* forval y=2005/2013 {
  forval i = 1/3 {
    loc file MSA_M`y'_dl_`i'.csv
    insheet using `file', clear comma names
    tempfile d`y'_`i'
    save `d`y'_`i''
  }
  clear
  forval i = 1/3 {
    append using `d`y'_`i''
  }
  outsheet using MSA_M`y'_dl.csv, comma names replace
} */

*do conv_xls_csv.sh

 list area* group occ* in 1/30

forval y=2005/2016 {
  di "Year `y'-------------------------------"
  loc file MSA_M`y'_dl.csv
  insheet using `file', clear comma names

  *explore whether i can create the MSA-industry-occupation level data
  *area_type = 1 for US, = 2 for state, =3 for Guam, PR, VI, =4 for MSA, =5 for Metropolitan Division / New England City and Town Areas (NECTAs) divisions, =6 for nonmetropolitan area
  *Met/NECT divisions are smaller units than MSAs or NECTs (https://www.bls.gov/sae/saemd.htm, https://www.census.gov/geo/reference/webatlas/metdivs.html)
  *capture tab area_type

  *keep MSAs & nonmetropolitan areas
  *keep if area_type==4 | area_type==6

  *industry-specific #s not available; only naics_title="cross-industry"
  *drop naics*

  *group = total for occtitle="All Occupations"
  *group = major for major categories of occtitle, e.g. Management Occupations, Personal Care and Service Occupations, Healthcare Practitioners and Technic
  capture rename occ_group group
  tab group

  gen yr = `y'

  tempfile tmp`y'
  save `tmp`y''
}

*------------------------
*merge with % employment in the industry in the given occupation
*first create the data
loc file o-net-All_Industries.csv
insheet using `file', clear comma names

*detailed occupations, e.g. accountants in "Accountants and Auditors" have missing industries
drop if industries==""

*sometimes multiple industries listed for an occupation
*first count the number of industries listed for each occupation entry
egen nind = noccur(industries) , string("%")
tab nind
split industries, p("%)")

sum nind
forval x=1/`r(max)' {
  capture drop pct`x'
  gen pct`x' = substr(industries`x', -2,2)

  capture drop ind`x'
  gen ind`x' = regexr(industries`x', "(^[, ])", "")
  replace ind`x' = regexr(ind`x', "([ (][0-9]+)$", "")
  drop industries`x'
}
drop industries projected*

*reshape long ind pct, i(code occupation nind) j(n)
destring pct*, replace
*drop if pct==.

rename code occcode
rename occupation occtitle

*one occupation missing code: occupation="Fishing and Hunting Workers"
drop if occcode==""

replace occcode = subinstr(occcode, ".00","",.)
rename occcode occ_code

tempfile occ
save `occ'

*------------------------
*create NAICS string name to code xwalk

*get 2-digit NAICS title to code xwalk (b/c occupation data have only 2-digit NAICS title)
loc file 2017_NAICS_Structure.csv
insheet using `file', clear comma names
drop if _n < 3
gen l = length(v2)
keep if l==2 | v2=="31-33" | v2=="44-45" | v3=="48-49" | regexm(v2, "-")
keep v2 v3
rename v2 naics
rename v3 naics_title
replace naics_title = regexr(naics_title, "[T]$", "")
replace naics_title = trim(naics_title)

*for 6-digit NAICS code, use the following
/* loc file all_data_M_2015.csv
insheet using `file', clear comma names
drop v30

drop if naics_title=="Cross-industry"
keep naics*
duplicates drop
gen l = length(naics)
drop if l==2 | naics_title=="Cross-industry, private ownership only"
drop l
duplicates drop

duplicates tag naics_ti, gen(dup)
tab dup
*a few industries have 2 different industry codes; just choose one that ends with 000
gen digit = substr(naics,-3,3)
drop if dup > 0 & digit!="000"
drop digit dup
duplicates tag naics_ti, gen(dup)
assert dup==0
drop dup */

tempfile indxwalk
save `indxwalk'

*------------------------

*merge occupation-industry xwalk with MSA-occupation level data
clear
forval y=2005/2016 {
  append using `tmp`y''
}
merge m:1 occ_code using `occ', keep(1 3)

*unmatched obs mostly have group = "major" or "total"
tab group _m
* if group = major or total, all not matched

*if not those 2 groups, only 5 occupations are unmatched
preserve
keep if _m==1
drop if group=="major" | group=="total"
tab occ_t
*chief executives, door-to-door sale workers, fishers, substitute teachers, all other teachers and instructors
restore

drop _m

tempfile tmp2
save `tmp2'

use `tmp2', clear
tab ind1

*merge with industry xwalk by industry string names
forval x = 1/5 {
  loc v ind`x'
  replace `v' = trim(`v')
  replace `v'="Administrative and Support and Waste Management and Remediation Services" if `v'=="Administrative and Support Services"
  replace `v' = "Agriculture, Forestry, Fishing and Hunting" if `v'=="Agriculture, Forestry, Fishing, and Hunting"
  replace `v' = "Public Administration" if `v'=="Government"
  replace `v' = "Other Services (except Public Administration)" if `v'=="Other Services (Except Public Administration)"

  rename `v' naics_title
  merge m:1 naics_title using `indxwalk', keep(1 3) nogen keepusing(naics)
  rename naics_title `v'
  rename naics naics`x'
  assert naics`x'!="" if `v'!=""
}

compress
save oes_panel, replace

*pct_total =	Percent of industry employment in the given occupation (only on the national industry files). Percents may not total to 100 due to occupational data not published separately.
*pct_rpt = Percent of establishments reporting the given occupation in the given industry (only on the national industry files)
*jobs_1000 =	The number of jobs (employment) in the given occupation per 1,000 jobs in the given area (only on the statewide, metropolitan, and nonmetropolitan area files)
