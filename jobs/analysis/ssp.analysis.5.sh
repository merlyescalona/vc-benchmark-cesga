#!/bin/bash
#$ -wd /home/merly/data
#$ -o /home/merly/output/ssp.analysis.5.o
#$ -e /home/merly/error/ssp.analysis.6.e
#$ -pe threaded 4
#$ -N bamming
module purge
module load gcc/5.2.0 xz bio/samtools
################################################################################
correctID=$SGE_TASK_ID
let correctID=correctID-1
filename="$1.$(printf "%03g" $correctID).sh"
bash $filename
module unload  gcc/5.2.0 xz bio/samtools
