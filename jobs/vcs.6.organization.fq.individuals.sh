#!/bin/bash
#$ -v pipelinesName=ssp
#$ -wd /home/merly/data
#$ -o /home/merly/org.ind.fq.o
#$ -e /home/merly/org.ind.fq.e
#$ -N org.ind.fq

# $1 - NGSMODE
# $2 - MODE
replicateNum=${SGE_TASK_ID}
pipelinesName="ssp"
replicatesNumDigits=5
replicateID="$(printf "%0${replicatesNumDigits}g" $replicateNum)"
ngsphyReplicatePath="$HOME/data/NGSphy_${pipelinesName}.${replicateID}"
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
