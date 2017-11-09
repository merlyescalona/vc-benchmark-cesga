simphyReplicateID=$SGE_TASK_ID
profileFOLDER=$1 #"PE150OWN"
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
    if [[ $profileFOLDER == *"150"* ]]; then
        sizeID="300"
    fi
    if [[ $profileFOLDER == *"250"* ]]; then
        sizeID="500"
    fi
    for replicateST in ${replicates[*]}; do
      nInds=($(ls $ngsphyReplicatePath/$profileFOLDER/$replicateST/*_R1.fq.gz | wc -l))
      let nInds=nInds-1
      for indID in $(seq 0 $nInds); do
        echo "$distRefID - $sizeID | ${profileFOLDER}/${replicateST}/${pipelinesName}_${indID}"
        outfile="$HOME/data/mappings/${pipelinesName}.${replicateID}/$profileFOLDER/$replicateST/${pipelinesName}.${replicateID}.$replicateST.${indID}.${distRefID}.${sizeID}.sam"
        outputFILE="$(basename $outfile .sam).sorted.bam"
        outputDIR="$(dirname $outfile)"
        echo "samtools view -bSh $outfile | samtools sort - -o $outputDIR/$outputFILE -@ 12" >> "${script}/${pipelinesName}.${replicateID}.${profileFOLDER}.samtools.sh"
        echo "samtools index $outputDIR/$outputFILE" >> "${script}/${pipelinesName}.${replicateID}.${profileFOLDER}.samtools.sh"
        echo "rm $outfile" >> "${script}/${pipelinesName}.${replicateID}.${profileFOLDER}.samtools.sh"
      done
    done
done
