* create xwalk file from ZIP code to MSA
*Source: 2010 ZCTA to Metropolitan and Micropolitan Statistical Areas Relationship File from [Census Bureau](https://www.census.gov/geo/maps-data/data/zcta_rel_download.html)
*Source: zip_to_zcta_2017.xlsx

local dta /ifs/home/kimk13/locallabor/data
cd `dta'

insheet using zip_msa_xwalk.csv, comma names clear

compress
save zip_msa_xwalk, replace

/* import delim zcta_cbsa_rel_10.txt, delim(",") clear

*zpoppct : % population in the ZIP code in the MSA
keep zcta5 cbsa zpoppct
duplicates drop

preserve
keep zcta5
duplicates drop
tempfile uniq_zcta
save `uniq_zcta'
restore

tempfile zip_msa
save `zip_msa'
*------------------
* create ZIP code to ZCTA xwalk & ZCTA to fips code xwalk
import excel using zip_to_zcta_2017.xlsx, clear first
rename STATE state
rename ZCTA zcta5
rename ZIP_CODE zip_cd
destring zcta , replace

duplicates tag zcta5, gen(dd)
tab dd
drop dd
* not unique at the zcta5 level but unique at the zip code level

keep zip_cd zcta5
duplicates drop
tempfile zip_zcta
save `zip_zcta'

*merge with zcta  */
