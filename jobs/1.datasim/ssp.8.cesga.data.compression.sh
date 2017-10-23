#!/bin/bash
#SBATCH -n 1
#SBATCH -t 10:00:00
#
#SBATCH --job-name=data.zip%a
#SBATCH --output=/mnt/lustre/scratch/home/uvi/be/mef/output/ssp.5.%a.o
#SBATCH --error=/mnt/lustre/scratch/home/uvi/be/mef/error/ssp.5.%a.e
#SBATCH --workdir=/mnt/lustre/scratch/home/uvi/be/mef/data/
#
#SBATCH --mail-type=begin,end
#SBATCH --mail-user=escalona10@gmail.com
#SBATCH --partition=shared,gpu-shared-k2
#SBATCH --qos=shared
################################################################################
simphyReplicateID=$SLURM_ARRAY_TASK_ID
replicateID=$(printf "%05g" $simphyReplicateID)
pipelinesName="ssp"
replicateFOLDER="$LUSTRE/data/$pipelinesName.$replicateID"
# replicateFOLDER="/home/merly/data/ssp.00001"
for replicate in $(find $replicateFOLDER -maxdepth 1 -mindepth 1 -type d | sort); do
    echo "$replicate"
    for tree in $(find $replicate -name "g_trees*.trees" | sort); do
        cat $tree >> $replicate/g_trees.all
    done
    echo "Gzipped trees file"
    gzip $replicate/g_trees.all
    echo "Removing all g_trees*.trees"
    find $replicate -name "g_trees*.trees" | xargs rm
done
for replicate in $(find $replicateFOLDER -maxdepth 1 -mindepth 1 -type d | sort); do
    echo "$replicate"
    mkdir $replicate/FASTA $replicate/TRUE_FASTA
    cd $replicate
    mv *_TRUE.fasta TRUE_FASTA
    mv *.fasta FASTA
    tar -czf TRUE_FASTA.tar.gz TRUE_FASTA
    tar -czf FASTA.tar.gz FASTA
    rm -rf $replicate/TRUE_FASTA
    rm -rf $replicate/FASTA
done
