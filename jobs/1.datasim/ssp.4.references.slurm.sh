#!/bin/bash
#SBATCH -n 1
#SBATCH -t 10:00:00
#
#SBATCH --job-name=refselector
#SBATCH --output=/mnt/lustre/scratch/home/uvi/be/mef/output/ssp.4.%a.o
#SBATCH --error=/mnt/lustre/scratch/home/uvi/be/mef/error/ssp.4.%a.e
#SBATCH --workdir=/mnt/lustre/scratch/home/uvi/be/mef/data/
#
#SBATCH --mail-type=begin,end
#SBATCH --mail-user=escalona10@gmail.com
#SBATCH --partition=shared
#SBATCH --qos=shared
################################################################################
# Variables

simphyReplicateID=${SLURM_ARRAY_TASK_ID}
replicateID=$(printf "%05g" $simphyReplicateID)
pipelinesName="ssp"
module purge
module load anaconda2/4.0.0

if [ ! -d $LUSTRE/data/references ];then
    mkdir -p $LUSTRE/data/references
fi

refselector -p 2 -s $LUSTRE/data/${pipelinesName}.${replicateID} -ip data -op outgroup300 -o $LUSTRE/data/references/references.${pipelinesName}.${replicateID}.outgroup.300  -m 0 --nsize 300
refselector -p 2 -s $LUSTRE/data/${pipelinesName}.${replicateID} -ip data -op rndingroup300 -o $LUSTRE/data/references/references.${pipelinesName}.${replicateID}.rndingroup.300  -m 2 --nsize 300
refselector -p 2 -s $LUSTRE/data/${pipelinesName}.${replicateID} -ip data -op outgroup500 -o $LUSTRE/data/references/references.${pipelinesName}.${replicateID}.outgroup.500  -m 0 --nsize 500
refselector -p 2 -s $LUSTRE/data/${pipelinesName}.${replicateID} -ip data -op rndingroup500 -o $LUSTRE/data/references/references.${pipelinesName}.${replicateID}.rndingroup.500  -m 2 --nsize 500

module unload anaconda2/4.0.0
