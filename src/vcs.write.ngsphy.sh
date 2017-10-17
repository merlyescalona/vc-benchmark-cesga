#!/bin/bash
pipelinesName=$1
idREPLICATE=$2
folderSIMPHY=$3
folderNGSPROFILE=$4
fileOUTPUT=$5
folderOUTPUT=$6
echo -e "
[general]
path=${folderOUTPUT}
output_folder_name=NGSphy_${pipelinesName}.${idREPLICATE}
ploidy=2
[data]
inputmode=4
simphy_folder_path=$folderSIMPHY
simphy_data_prefix=data
simphy_filter=true
[coverage]
experiment=U:1, 300
individual=LN:1.2,1
locus=LN:1.2,1
[ngs-reads-art]
ss=HS25
l=150
m=215
s=50
q=true
p=true
na=false
[execution]
environment=bash
runART=off
running_times=off
threads=2
" > $fileOUTPUT
