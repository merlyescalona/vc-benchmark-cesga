#!/bin/bash
#$ -wd /home/merly/data
#$ -o /home/merly/output/ssp.7.1.o
#$ -e /home/merly/error/ssp.7.1.e
#$ -N dataTransfer

echo -e "[$(date)]\nDefinition"
LUSTRE="/mnt/lustre/scratch/home/uvi/be/mef"
simphyReplicateID=${SGE_TASK_ID}
pipelinesName="ssp"
replicatesNumDigits=5
replicateID="$(printf "%0${replicatesNumDigits}g" $simphyReplicateID)"
ngsphyReplicatePathTRIPLOID="$HOME/data/NGSphy_${pipelinesName}.${replicateID}"
ngsphyReplicatePathCESGA="$LUSTRE/data/ngsphy.data/NGSphy_${pipelinesName}.${replicateID}/"

replicateFOLDERCESGA="$LUSTRE/data/$pipelinesName.$replicateID/"
replicateFOLDERTRIPLOID="$HOME/data/$pipelinesName.$replicateID"


rsync -rP uvibemef@ft2.cesga.es:$ngsphyReplicatePathCESGA $ngsphyReplicatePathTRIPLOID
rsync -rP uvibemef@ft2.cesga.es:$replicateFOLDERCESGA $replicateFOLDERTRIPLOID
