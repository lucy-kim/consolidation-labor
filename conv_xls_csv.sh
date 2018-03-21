#!/bin/bash

# convert XLS to CSV files;

# cd /ifs/home/kimk13/locallabor/data
cd /Users/kimk13/Dropbox/Research/locallabormkt/data/bls-oes

for file in `find . -name '*20*.xls'` ; do
    echo "$file"
    dir=`dirname $file`
    base=`basename ${file} .xls`
    csvfile="${dir}/${base}.csv"
    if [ -f $csvfile ] ; then
        echo "Skipping $csvfile"
    else
	echo "Creating $csvfile"
    	xls2csv -x "$file" -c "$csvfile"
    fi
done

# # unify name styles
# mv BOS_may2006_dl.csv BOS_May2006_dl.csv
# mv MSA_may2005_dl_1.csv MSA_May2005_dl_1.csv
# mv MSA_may2005_dl_2.csv MSA_May2005_dl_2.csv
# mv MSA_may2005_dl_3.csv MSA_May2005_dl_3.csv
# mv MSA_may2006_dl_1.csv MSA_May2006_dl_1.csv
# mv MSA_may2006_dl_2.csv MSA_May2006_dl_2.csv
# mv MSA_may2006_dl_3.csv MSA_May2006_dl_3.csv
# mv BOS__M2008_dl.csv BOS_M2008_dl.csv
# mv MSA__M2008_dl_1.csv MSA_M2008_dl_1.csv
#
# cd /Users/kimk13/Dropbox/Research/locallabormkt/data/bls-oes/csv
#
# for i in `seq 1 3` ; do
#     mv "MSA_M201${i}_dl_1_AK_IN.csv" "MSA_M201${i}_dl_1.csv"
#     mv "MSA_M201${i}_dl_2_KS_NY.csv" "MSA_M201${i}_dl_2.csv"
#     mv "MSA_M201${i}_dl_3_OH_WY.csv" "MSA_M201${i}_dl_3.csv"
# done
#
# for i in `seq 5 7` ; do
#     for j in `seq 1 3`; do
#         mv "MSA_May200${i}_dl_${j}.csv" "MSA_M200${i}_dl_${j}.csv"
#     done
# done
#
# for i in `seq 6 7` ; do
#     mv "BOS_May200${i}_dl.csv" "BOS_M200${i}_dl.csv"
# done
