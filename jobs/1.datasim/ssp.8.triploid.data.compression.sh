#!/bin/bash
#$ -v pipelinesName=ssp
#$ -wd /home/merly/data
#$ -o /home/merly/output/ssp.5.datazip.o
#$ -e /home/merly/error/ssp.5.datazip.e
#$ -N data.zip

simphyReplicateID=$SGE_TASK_ID
replicateID=$(printf "%05g" $simphyReplicateID)
pipelinesName="ssp"
replicateFOLDER="$HOME/data/$pipelinesName.$replicateID"
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
