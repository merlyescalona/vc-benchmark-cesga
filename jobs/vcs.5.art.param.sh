#!/bin/bash
#SBATCH -n 1
#SBATCH -t 2:00:00
#
#SBATCH --job-name=art
#SBATCH --output=/mnt/lustre/scratch/home/uvi/be/mef/output/vcs.5.1.o
#SBATCH --error=/mnt/lustre/scratch/home/uvi/be/mef/error/vcs.5.1.e
#SBATCH --workdir=/mnt/lustre/scratch/home/uvi/be/mef/data/
#
#SBATCH --partition shared
#SBATCH --qos=shared

echo -e "[$(date)]\nDefinition"
command=$(awk "NR==${SLURM_ARRAY_TASK_ID}" $1)

module load gcc/5.3.0 art/2016-06-05
echo $command
$command

module unload gcc/5.3.0 art/2016-06-05
