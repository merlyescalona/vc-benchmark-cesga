#!/bin/bash
#$ -v pipelinesName=ssp
#$ -wd /home/merly/data
#$ -o /home/merly/output/art.3.o
#$ -e /home/merly/error/art.3.e
#$ -N art

echo -e "[$(date)]\nDefinition"
module load gcc/5.2.0 bio/art/050616
correctID=$SGE_TASK_ID
let correctID=correctID-1
filename="$1.$(printf "%04g" $correctID).sh"
bash $filename
module unload gcc/5.2.0 bio/art/050616
