#!/bin/bash
#SBATCH -n 1
#SBATCH -t 08:00:00
#
#SBATCH --job-name=vcs.3
#SBATCH --output=/mnt/lustre/scratch/home/uvi/be/mef/output/vcs.3.o
#SBATCH --error=/mnt/lustre/scratch/home/uvi/be/mef/error/vcs.3.e
#SBATCH --workdir=/mnt/lustre/scratch/home/uvi/be/mef/data/
#
#SBATCH --mail-type=end
#SBATCH --mail-user=escalona10@gmail.com
#SBATCH --partition shared
#SBATCH --qos=shared

pipelinesName="vcs.00001"
replicateID=$(printf "%02g" ${SLURM_ARRAY_TASK_ID})
echo $(hostname),$pipelinesName, $replicateID, ${SLURM_ARRAY_TASK_ID}
module purge
module load gcc/5.3.0 indelible/1.03
echo "cd $LUSTRE/data/$pipelinesName/$replicateID"
cd $LUSTRE/data/$pipelinesName/$replicateID
indelible
module unload gcc/5.3.0 indelible/1.03
