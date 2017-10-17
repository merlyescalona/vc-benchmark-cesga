#!/bin/bash
#$ -v pipelinesName=ssp
#$ -wd /home/merly/data
#$ -o /home/merly/art.3.o
#$ -e /home/merly/art.3.e
#$ -N art

echo -e "[$(date)]\nDefinition"
nlines=$(wc -l $1 | awk '{print $1}')
module load gcc/5.2.0 bio/art/050616
for item in $(seq 1 $nlines);do
    echo "$item"
    command=$(awk -v x=$item "NR==x" $1)
    $command
done

module unload gcc/5.2.0 bio/art/050616
