#!/bin/bash
#$ -l mem_free=10G
#$ -N sasjob01 #$ -j y

# module load stata/13
module load sas/9.4

cd /ifs/home/kimk13/locallabor
# stata-se -q -b do croes_panel.do

sas -nodms -noterminal crzip_msa_xwalk.sas
