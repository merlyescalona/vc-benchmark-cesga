#!/bin/bash
#$ -v pipelinesName=ssp
#$ -wd /home/merly/data
#$ -o /home/merly/output/art.6.o
#$ -e /home/merly/error/art.6.e
#$ -N art

echo -e "[$(date)]\nDefinition"
module load gcc/5.2.0 bio/art/050616
filename=$(awk "NR==$SGE_TASK_ID" $1)
bash $filename
module unload gcc/5.2.0 bio/art/050616
