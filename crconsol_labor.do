*link the hospital market consolidation with labor market outcomes data

local dta /ifs/home/kimk13/locallabor/data
cd `dta'

use `dta'/labordata/oes_panel, clear
