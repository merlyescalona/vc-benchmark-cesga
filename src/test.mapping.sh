################################################################################
simphyReplicateID=1
profileFOLDER="PE150OWN"
machine="HiSeq2500"
################################################################################
pipelinesName="ssp"
replicatesNumDigits=5
replicateID="$(printf "%0${replicatesNumDigits}g" $simphyReplicateID)"
ngsphyReplicatePath="$HOME/data/NGSphy_${pipelinesName}.${replicateID}"
referencesReplicatePath="$HOME/data/references/references.${pipelinesName}.${replicateID}"
################################################################################
distanceReference=("outgroup" "rndingroup")
sizes=("300" "500")
replicates=($(ls $ngsphyReplicatePath/reads))
for distRefID in ${distanceReference[*]}; do
    for sizeID in ${sizes[*]}; do
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
done
