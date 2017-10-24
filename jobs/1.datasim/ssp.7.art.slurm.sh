#!/bin/bash
#SBATCH -n 1
#SBATCH -t 20:00:00
#
#SBATCH --job-name=art
#SBATCH --output=/mnt/lustre/scratch/home/uvi/be/mef/output/art.7.%a.o
#SBATCH --error=/mnt/lustre/scratch/home/uvi/be/mef/error/art.7.%a.e
#SBATCH --workdir=/mnt/lustre/scratch/home/uvi/be/mef/data/
#
#SBATCH --partition shared,gpu-shared-k2
#SBATCH --qos=shared

echo -e "[$(date)]\nDefinition"
module load gcc/5.3.0 art/2016-06-05
filename=$(awk "NR==$SLURM_ARRAY_TASK_ID" $1)
bash $filename
module unload gcc/5.3.0 art/2016-06-05
