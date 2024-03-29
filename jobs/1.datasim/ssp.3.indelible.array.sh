#!/bin/bash
#SBATCH -n 1
#SBATCH -t 20:00:00
#
#SBATCH --job-name=indelible
#SBATCH --output=/mnt/lustre/scratch/home/uvi/be/mef/output/ssp.3.%a.o
#SBATCH --error=/mnt/lustre/scratch/home/uvi/be/mef/error/ssp.3.%a.e
#SBATCH --workdir=/mnt/lustre/scratch/home/uvi/be/mef/data/
#
#SBATCH --partition=shared
#SBATCH --qos=shared
#SBATCH --mail-type=end
#SBATCH --mail-user=escalona10@gmail.com
echo -e "[$(date)]\nDefinition"
pipelinesName="ssp"
simphyFOLDER=$(awk "NR==${SLURM_ARRAY_TASK_ID}" $HOME/vc-benchmark-cesga/files/${pipelinesName}.$(printf "%05g" $1).indelible.folders.txt)
echo -e "[$(date)] \t module purge \t module load gcc/5.3.0 indelible/1.03"
module purge
module load gcc/5.3.0 indelible/1.03
echo -e "[$(date)] \t cd $simphyFOLDER"
cd $simphyFOLDER
echo -e "[$(date)] \t indelible"
indelible
echo -e "[$(date)] \t module unload gcc/5.3.0 indelible/1.03"
module unload gcc/5.3.0 indelible/1.03
