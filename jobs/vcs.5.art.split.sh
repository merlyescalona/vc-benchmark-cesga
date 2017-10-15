#!/bin/bash
#SBATCH -n 1
#SBATCH -t 12:00:00
#
#SBATCH --job-name=art
#SBATCH --output=/mnt/lustre/scratch/home/uvi/be/mef/output/ssp.5.00001.%a.o
#SBATCH --error=/mnt/lustre/scratch/home/uvi/be/mef/error/ssp.5.00001.%a.e
#SBATCH --workdir=/mnt/lustre/scratch/home/uvi/be/mef/data/
#
#SBATCH --partition shared
#SBATCH --qos=shared

echo -e "[$(date)]\nDefinition"
nlines=$(wc -l $1 | awk '{print $1}')
module load gcc/5.3.0 art/2016-06-05
for item in $(seq 1 $nlines);do
    echo "$item"
    command=$(awk -v x=$item "NR==x")
    $command
done

module unload gcc/5.3.0 art/2016-06-05
