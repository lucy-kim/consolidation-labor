*create 2 measures of hospital market consolidation for each HRR-year using the AHA data for 2005-2015: 1) HHI using # beds, 2) indicator for a system merger that occurred

local dta /ifs/home/kimk13/locallabor/data
cd `dta'

insheet using AHA_2005-2015.csv, clear comma
*had to change a variable name "long" to "longi"

des id year sysid sysname mcrnum hrrcode genbd mhsmemb
sort id year

list id year sysid sysname mcrnum hrrcode genbd mhsmemb in 1/100

*fill in missing values
foreach v of varlist mcrnum hrrcode {
    gsort id -`v'
    bys id: replace `v' = `v'[_n-1] if `v' >=.
}

preserve
keep if mcrnum==.
keep id mname
duplicates drop
count
*1098
restore

gen zip_code = substr(mloczip, 1,5)
destring zip_code, replace

tempfile tmp
save `tmp'

*------------------------------
* create hospital-year level data with system ID, HRR code, Medicare provider number
use `tmp', clear
rename mcrnum provid
drop fy
rename year fy

replace hrrcode = 352 if provid== 390067
replace hsacode = 39050 if provid== 390067

drop if provid==.
drop if hrrcode==. | hsacode==.

bys provid: gen n = _N
foreach v of varlist hrrcode hsacode {
    bys provid `v': gen n`v' = _N
    gen fr`v' = n`v'/n
    bys provid: egen maxfr`v' = max(fr`v')
    gen `v'2 = `v' if fr`v'==maxfr`v' & fr`v'!=0.5
}
rename hrrcode2 hrrnum
rename hsacode2 hsanum

list provid fy hsa* frhsa* if provid==193064

*if fraction = 0.5, choose the first HRR
foreach v in "hrr" "hsa" {
    *fill in missing values after finding the dominant HRR/HSA
    gsort provid -`v'num
    bys provid: replace `v'num = `v'num[_n-1] if `v'num >=.

    *if equal %, use the first-year value
    sort provid fy
    bys provid: replace `v'num = `v'code if _n==1 & fr`v'code==0.5
    bys provid: replace `v'num = `v'num[_n-1] if `v'num >=.
    assert `v'num!=.
}

keep provid fy sysid hrrnum hsanum zip_code
collapse (max) sysid, by(provid fy hrrnum hsanum zip_code)
duplicates tag provid fy, gen(dup)
*just randomly drop one ZIP code
gsort provid fy -sysid
bys provid fy: drop if _n==2 & dup > 0
drop dup
duplicates tag provid fy, gen(dup)
assert dup==0
drop dup

*create indicator if a hospital has a sysid from missing to nonmissing in a year
sort provid fy
bys provid: gen joinsys = sysid!=. & sysid[_n-1]==. if fy!=2005

*create indicator if the sys ID has another hospital in the same HRR / HSA in each year
foreach v0 in "hrr" "hsa" {
    loc v `v0'num
    sort `v' sysid fy provid
    bys `v' sysid fy: gen nhosp_`v0' = _N
    gen joinsys_`v0' = joinsys* (nhosp_`v0' > 1)
    sum joinsys_`v0'
}

* create indicator if the hospital joined a sys ID that has no other hospital in the same market in a year
foreach v0 in "hrr" "hsa" {
    gen joinsys_n`v0' = joinsys * (nhosp_`v0'==1)
}

des

tempfile joinsys
save `joinsys'

*create market-year level data on whether a merger into a system with existing hospitals in the same market
foreach v0 in "hrr" "hsa" {
    use `joinsys', clear
    collapse (max) joinsys_`v0' joinsys_n`v0' (mean) nhosp_`v0', by(`v0'num fy zip)

    rename joinsys_`v0' joinsys_samemkt
    rename joinsys_n`v0' joinsys_othmkt
    rename nhosp_`v0' nhosp

    gen geoid = `v0'num
    gen mktlvl = "`v0'"
    drop `v0'num
    des
    tempfile joinsys_`v0'
    save `joinsys_`v0''
}

use `joinsys_hrr', clear
append using `joinsys_hsa'
lab var joinsys_samemkt "Have a hospital join the system with other hospitals in the same market"
lab var joinsys_othmkt "Have a hospital join the system with hospitals outside of the local market"
lab var nhosp "Mean # hospitals in the same system in the market-year"

tempfile joinsys_mkt
save `joinsys_mkt'

*---------------------------------

*merge with # beds data from POS
use /ifs/home/kimk13/VI/data/pos/pos_panel_hosp, clear
drop if fy==2016
duplicates tag provid fy, gen(dup)
assert dup==0
drop dup

*get HRR code
rename provid provider
merge m:1 provider using /ifs/home/kimk13/VI/data/dartmouth/hosp_hrr_xwalk.dta, keep(1 3)
rename provider provid

preserve
use `joinsys', clear
keep provid hrrnum hsanum
duplicates drop
tempfile aha_provid_hrr
save `aha_provid_hrr'
restore

preserve
keep if _m==1
drop hrrnum hsanum _m
merge m:1 provid using `aha_provid_hrr', keep(1 3) nogen
tempfile m1
save `m1'
restore

drop if _m==1
drop _m

append using `m1'
drop if hrrnum==. | hsanum==.
drop hrrstate

*for each HRR (HSA) - year pair, get HHI using the share of beds
rename crtfd_bed_cnt beds
foreach v0 in "hrr" "hsa" {
    loc v `v0'num
    preserve
    bys `v' fy: egen tbeds = sum(beds)
    gen shbeds_`v0'_sq2 = (beds/tbeds)^2
    collapse (sum) hosphhi = shbeds_`v0'_sq2, by(`v' fy)
    gen geoid = `v'
    gen mktlvl = "`v0'"
    drop `v'
    des
    tempfile hosphhi_`v0'
    save `hosphhi_`v0''
    restore
}

use `hosphhi_hrr', clear
append using `hosphhi_hsa'
tempfile hosphhi
save `hosphhi'

*---------------------
* merge HHI data & system merger data
use `hosphhi', clear
merge 1:1 geoid mktlvl fy using `joinsys_mkt'
*407 have _m=1; 11925 have _m=2; 27229 have _m=3

*for now, just keep matched market-year level obs
keep if _m==3
drop _m

compress
save hosp_mkt_consol, replace
