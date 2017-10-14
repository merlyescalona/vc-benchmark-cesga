#!/bin/bash
replicateNum=$1
pipelinesName="ssp"
replicateID="$(printf "%0${replicatesNumDigits}g" $replicateID)"
replicatesNumDigits=5
ngsphyReplicatePath="$LUSTRE/data/ngsphy.data/NGSphy_${pipelinesName}.${replicateID}"
# reads/1/03/testwsimphy_1_03_data_7_R2.fq
numReplicates=10
for replicateST in $(seq 1 $numReplicates); do
    numIndividuals=$( cat $ngsphyReplicatePath/ind_labels/${pipelinesName}.${replicateST}.individuals.csv | tail -n+2 | wc -l)
    let numIndividuals=numIndividuals-1
    mkdir -p $ngsphyReplicatePath/reads_per_individual/$replicateST
    for individualID in $(seq 0 $numIndividuals); do
        fqFilesR1=($(find $ngsphyReplicatePath/reads/$replicateST -name "*_${individualID}_R1.fq"))
        fqFilesR2=($(find $ngsphyReplicatePath/reads/$replicateST -name "*_${individualID}_R2.fq"))
        for item in ${fqFilesR1[@]}; do
            cat $item >>  $ngsphyReplicatePath/reads_per_individual/$replicateST/${pipelinesName}_${replicateST}_${individualID}_R1.fq
            gzip $item
        done
        for item in ${fqFilesR2[@]}; do
            cat $item >>  $ngsphyReplicatePath/reads_per_individual/$replicateST/${pipelinesName}_${replicateST}_${individualID}_R2.fq
            gzip $item
        done
        gzip $ngsphyReplicatePath/reads_per_individual/$replicateST/${pipelinesName}_${replicateST}_${individualID}_R1.fq
        gzip $ngsphyReplicatePath/reads_per_individual/$replicateST/${pipelinesName}_${replicateST}_${individualID}_R2.fq
    done
done
