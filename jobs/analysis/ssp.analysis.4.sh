#!/bin/bash
#$ -wd /home/merly/data
#$ -o /home/merly/output/ssp.analysis.4.o
#$ -e /home/merly/error/ssp.analysis.4.e
#$ -N doBAMsScript
module purge
################################################################################
simphyReplicateID=$SGE_TASK_ID
profileFOLDER=$1 #"PE150OWN"
machine=$2 #"HiSeq2500"
################################################################################
pipelinesName="ssp"
replicatesNumDigits=5
replicateID="$(printf "%0${replicatesNumDigits}g" $simphyReplicateID)"
ngsphyReplicatePath="$HOME/data/NGSphy_${pipelinesName}.${replicateID}"
################################################################################
distanceReference=("outgroup" "rndingroup")
sizes=("300" "500")
replicates=($(ls $ngsphyReplicatePath/${profileFOLDER}))
script="$HOME/data/mappings/${pipelinesName}.${replicateID}/scripts"
for distRefID in ${distanceReference[*]}; do
    for sizeID in ${sizes[*]}; do
        for replicateST in ${replicates[*]}; do
            nInds=($(ls $ngsphyReplicatePath/$profileFOLDER/$replicateST/*_R1.fq.gz | wc -l))
            let nInds=nInds-1
            for indID in $(seq 0 $nInds); do
                echo "${profileFOLDER}/${replicateST}/${pipelinesName}_${indID}"
                outfile="$HOME/data/mappings/${pipelinesName}.${replicateID}/$profileFOLDER/$replicateST/${pipelinesName}.${replicateID}.$replicateST.${indID}.${distRefID}.${sizeID}.sam"
                echo "samtools view -bSh $outfile | samtools sort - -o $(basename $outfile .sam).sorted.bam -@ 4" >> "${script}/${pipelinesName}.${replicateID}.${profileFOLDER}.samtools.sh"
                echo "samtools index $(basename $outfile .sam).sorted.bam" >> "${script}/${pipelinesName}.${replicateID}.${profileFOLDER}.samtools.sh"
                echo "rm $outfile" >> "${script}/${pipelinesName}.${replicateID}.${profileFOLDER}.samtools.sh"
            done
        done
    done
done

split -l 10 -d -a 3 "$HOME/data/mappings/${pipelinesName}.${replicateID}/scripts/${pipelinesName}.${replicateID}.${profileFOLDER}.sh" "$HOME/data/mappings/${pipelinesName}.${replicateID}/scripts/${pipelinesName}.${replicateID}.${profileFOLDER}.samtools.commands."

for file in $(find "$HOME/data/mappings/${pipelinesName}.${replicateID}/scripts/" -name "${pipelinesName}.${replicateID}.${profileFOLDER}.samtools.commands.*" -type f); do
    mv $file "$file.sh";
done
