options nocenter ;
*Download & unzip the BLS OES metropolitan area data;

%macro download(firstyr, lastyr);
%do y = &firstyr. %to &lastyr.;

* Get files;
x "cd /ifs/home/kimk13/locallabor/data";
x "wget -nv -N https://www.bls.gov/oes/special.requests/oesm0&y.ma.zip";
x "unzip oesm0&y.ma.zip";
x "ssconvert *.xls *.csv";
x "rm -f *zip";
x "rm a"

%end;
%mend download;

%download(5,9);

%macro download2(firstyr, lastyr);
%do y = &firstyr. %to &lastyr.;

* Get files;
x "cd /ifs/home/kimk13/locallabor/data";
x "wget -nv -N https://www.bls.gov/oes/special.requests/oesm1&y.ma.zip";
x "unzip oesm1&y.ma.zip";
x "rm -f *zip";

%end;
%mend download;

%download2(0,6);
