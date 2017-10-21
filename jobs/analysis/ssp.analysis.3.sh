#!/bin/bash
#$ -wd /home/merly/data
#$ -o /home/merly/output/ssp.analysis.3.o
#$ -e /home/merly/error/ssp.analysis.3.e
#$ -pe threaded 4
#$ -N bwa
module purge
module load gcc/5.2.0 bio/bwa/0.7.10
################################################################################
correctID=$SGE_TASK_ID
let correctID=correctID-1
filename="$1.$(printf "%02g" $correctID).sh"
nlines=$(wc -l $filename | awk '{print $1}')
for item in $(seq 1 $nlines);do
    echo "$item"
    command=$(awk -v x=$item "NR==x" $filename)
    $command
done
module unload  gcc/5.2.0 bio/bwa/0.7.10
