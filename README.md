# consolidation-labor

This project investigates the impact of health care market consolidation on the labor market outcomes

## Data construction codes
1. `crzip_msa_xwalk.sas` & `crzcta_msa_xwalk.do`
  - create xwalk file between ZIP and MSA
  - Source: 2010 ZCTA to Metropolitan and Micropolitan Statistical Areas Relationship File from [Census Bureau](https://www.census.gov/geo/maps-data/data/zcta_rel_download.html)
  - Source: zip_to_zcta_2017.xlsx
1. `crhosp_mkt_consol.do`
  - create 2 measures of hospital market consolidation for each HRR-year using the AHA data for 2005-2015: 1) HHI using # beds, 2) indicator for a system merger that occurred
1. `download_oes.sas`
  - Download metropolitan/nonmetropolitan area (if available) level OES data for 2005-2016
1. `conv_xls_csv.sh`
  - convert XLS files to CSV files and make file names consistent
2. `croes_panel.do`
  - create BLS OES panel data, ideally at the MSA-industry-occupation level, for 2005-2016

## Analysis codes
1. `crconsol_labor.do`
  - link the hospital market consolidation with labor market outcomes data
