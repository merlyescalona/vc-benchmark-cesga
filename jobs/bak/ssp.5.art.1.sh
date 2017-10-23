#!/bin/bash
#SBATCH -n 1
#SBATCH -t 1:00:00
#
#SBATCH --job-name=art
#SBATCH --output=/mnt/lustre/scratch/home/uvi/be/mef/output/ssp.5.1.o
#SBATCH --error=/mnt/lustre/scratch/home/uvi/be/mef/error/ssp.5.1.e
#SBATCH --workdir=/mnt/lustre/scratch/home/uvi/be/mef/data/
#
#SBATCH --partition shared
#SBATCH --qos=shared

echo -e "[$(date)]\nDefinition"
module load gcc/5.3.0 art/2016-06-05
correctID=$SLURM_ARRAY_TASK_ID
let correctID=correctID-1
filename="$1.$(printf "%04g" $correctID).sh"
bash $filename
module unload gcc/5.3.0 art/2016-06-05
