* create SAS data of the discharge level data;

LIBNAME out    '/ifs/home/kimk13/locallabor/data';

/* data out.zcta_cbsa (keep=ZCTA5 CBSA ZPOPPCT);
infile "/ifs/home/kimk13/locallabor/data/zcta_cbsa_rel_10.txt" dlm='2C0D'x dsd missover lrecl=10000 firstobs=2;
input ZCTA5 CBSA MEMI POPPT HUPT AREAPT AREALANDPT ZPOP ZHU ZAREA ZAREALAND MPOP MHU MAREA MAREALAND ZPOPPCT ZHUPCT ZAREAPCT ZAREALANDPCT MPOPPCT MHUPCT MAREAPCT MAREALANDPCT;
run;

proc contents data=out.zcta_cbsa;
  proc print data = out.zcta_cbsa (obs=10);
  run;

  PROC IMPORT OUT= out.zip_zcta DATAFILE= "/ifs/home/kimk13/locallabor/data/zip_to_zcta_2017.xlsx" DBMS=xlsx REPLACE;
    GETNAMES=YES;
  run;

data out.zip_zcta;
  set out.zip_zcta;
  ZCTA5= input(ZCTA,5.);
run;

  proc contents data=out.zip_zcta;
    proc print data = out.zip_zcta (obs=10);
    run;*/

    proc sql;
      create table out.zip_msa_xwalk as
      select a.ZIP_CODE, a.ZCTA5, b.*
      from out.zip_zcta as a,
      out.zcta_cbsa as b
      where a.ZCTA5=b.ZCTA5;
    quit;

    proc contents data=out.zip_msa_xwalk;
      proc print data = out.zip_msa_xwalk (obs=10);
      run;

    proc export data=out.zip_msa_xwalk outfile='/ifs/home/kimk13/locallabor/data/zip_msa_xwalk.csv' dbms = csv replace;
run;
