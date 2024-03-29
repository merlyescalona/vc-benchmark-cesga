#!/bin/bash
#SBATCH -n 1
#SBATCH -t 1:00:00
#
#SBATCH --job-name=art
#SBATCH --output=/mnt/lustre/scratch/home/uvi/be/mef/output/vcs.5.1.%a.o
#SBATCH --error=/mnt/lustre/scratch/home/uvi/be/mef/error/vcs.5.1.%a.e
#SBATCH --workdir=/mnt/lustre/scratch/home/uvi/be/mef/data/
#
#SBATCH --mail-type=end
#SBATCH --mail-user=escalona10@gmail.com
#SBATCH --partition shared
#SBATCH --qos=shared

echo -e "[$(date)]\nDefinition"
module load gcc/5.3.0 art
for item in $(seq 1 $nlines);do
    echo "$item"
    command=$(awk -v x=$item "NR==x" $1)
    $command
done
module load gcc/5.3.0 art
