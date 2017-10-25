#!/bin/bash
#$ -wd /home/merly/data
#$ -o /home/merly/output/ssp.analysis.2.o
#$ -e /home/merly/error/ssp.analysis.2.e
#$ -N doMapScript
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
referencesReplicatePath="$HOME/data/references/references.${pipelinesName}.${replicateID}"
################################################################################
distanceReference=("outgroup" "rndingroup")
sizes=("300" "500")
replicates=($(ls $ngsphyReplicatePath/${profileFOLDER}))
sizeID=""
for distRefID in ${distanceReference[*]}; do
    if [[ $profileFOLDER == *"150"* ]]; then
        sizeID="300"
    fi
    if [[ $profileFOLDER == *"250"* ]]; then
        sizeID="500"
    fi
    for replicateST in ${replicates[*]}; do
        nInds=($(ls $ngsphyReplicatePath/$profileFOLDER/$replicateST/*_R1.fq.gz | wc -l))
        let nInds=nInds-1
        referenceFile="${referencesReplicatePath}.${distRefID}.${sizeID}/${distRefID}${sizeID}_${replicateST}.fasta" # outgroup size 300
        for indID in $(seq 0 $nInds); do
            echo "${profileFOLDER}/${replicateST}/${pipelinesName}_${indID}"
            infile="${ngsphyReplicatePath}/${profileFOLDER}/${replicateST}/${pipelinesName}_${indID}_"
            mkdir -p "$HOME/data/mappings/${pipelinesName}.${replicateID}/$profileFOLDER/$replicateST/"
            outfile="$HOME/data/mappings/${pipelinesName}.${replicateID}/$profileFOLDER/$replicateST/${pipelinesName}.${replicateID}.$replicateST.${indID}.${distRefID}.${sizeID}.sam"
            RGID="${distRefID}-${sizeID}"
            SMID="S.${replicateST}-I.${indID}"
            echo "bwa mem -t 4 -R \"@RG\tID:${RGID}\tSM:${SMID}\tPL:Illumina\tLB:${RGID}\tPU:${machine}\" ${referenceFile} ${infile}R1.fq.gz ${infile}R2.fq.gz > $outfile" >> "$HOME/data/mappings/${pipelinesName}.${replicateID}/scripts/${pipelinesName}.${replicateID}.${profileFOLDER}.sh"
        done
    done
done

split -l 5 -d -a 5 "$HOME/data/mappings/${pipelinesName}.${replicateID}/scripts/${pipelinesName}.${replicateID}.${profileFOLDER}.sh" "$HOME/data/mappings/${pipelinesName}.${replicateID}/scripts/${pipelinesName}.${replicateID}.${profileFOLDER}.bwa.commands."

for file in $(find "$HOME/data/mappings/${pipelinesName}.${replicateID}/scripts/" -name "${pipelinesName}.${replicateID}.${profileFOLDER}.bwa.commands.*" -type f); do
    mv $file "$file.sh";
done
