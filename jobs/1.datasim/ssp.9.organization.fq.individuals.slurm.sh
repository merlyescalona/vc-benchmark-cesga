#!/bin/bash
#SBATCH -n 1
#SBATCH -t 2-00:00:00
#
#SBATCH --job-name=orgFqInd
#SBATCH --output=/mnt/lustre/scratch/home/uvi/be/mef/output/ssp.9.%a.o
#SBATCH --error=/mnt/lustre/scratch/home/uvi/be/mef/error/ssp.9.%a.e
#SBATCH --workdir=/mnt/lustre/scratch/home/uvi/be/mef/data/
#
#SBATCH --mail-type=begin,end
#SBATCH --mail-user=escalona10@gmail.com
#SBATCH --partition=shared,gpu-shared-k2
#SBATCH --qos=shared

# $1 - NGSMODE
# $2 - MODE
replicateNum=${SLURM_ARRAY_TASK_ID}
pipelinesName="ssp"
replicatesNumDigits=5
replicateID="$(printf "%0${replicatesNumDigits}g" $replicateNum)"
ngsphyReplicatePath="$LUSTRE/data/ngsphy.data/NGSphy_${pipelinesName}.${replicateID}"
NGSMODE=$1
MODE=$2
replicateST=$3
readsFolderName=$4


# mv $ngsphyReplicatePath/reads $ngsphyReplicatePath/reads_run
# find $ngsphyReplicatePath/individuals/ -mindepth 2 -maxdepth 2 -type d |sed 's/individuals/reads/g' | xargs mkdir -p
# NGSMODE="PE150OWN"
# MODE="PAIRED"
numIndividuals=$( cat $ngsphyReplicatePath/ind_labels/${pipelinesName}.${replicateID}.$replicateST.individuals.csv | tail -n+2 | wc -l)
let numIndividuals=numIndividuals-1
mkdir -p $ngsphyReplicatePath/$NGSMODE/$replicateST
for individualID in $(seq 0 $numIndividuals); do
    echo $SGE_TASK_ID,$JOB_ID, $HOSTNAME, $replicateST, $individualID
    fqFilesR1=($(find $ngsphyReplicatePath/$readsFolderName/$replicateST -name "*_${individualID}_R1.fq"))
    cat ${fqFilesR1[*]} >  $ngsphyReplicatePath/$NGSMODE/$replicateST/${pipelinesName}_$replicateST_${individualID}_R1.fq
    gzip $ngsphyReplicatePath/$NGSMODE/$replicateST/${pipelinesName}_$replicateST_${individualID}_R1.fq

    if [[ MODE -eq "PAIRED" ]]; then
        fqFilesR2=($(find $ngsphyReplicatePath/$readsFolderName/$replicateST -name "*_${individualID}_R2.fq"))
        cat ${fqFilesR2[*]} >  $ngsphyReplicatePath/$NGSMODE/$replicateST/${pipelinesName}_$replicateST_${individualID}_R2.fq
        gzip $ngsphyReplicatePath/$NGSMODE/$replicateST/${pipelinesName}_$replicateST_${individualID}_R2.fq
    fi
done
