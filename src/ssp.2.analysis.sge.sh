################################################################################
# (c) 2015-2017 Merly Escalona <merlyescalona@uvigo.es>
# Phylogenomics Lab. University of Vigo.
# Description:
# ============
# Pipelines for data analysis
# Running @triploid.uvigo.es
################################################################################
#!/bin/bash -l
################################################################################
# Folder paths
################################################################################
source $HOME/src/vc-benchmark-cesga/src/vcs.variables.sh
################################################################################
simphyReplicateID=1
pipelinesName="ssp"
replicatesNumDigits=5
replicateID="$(printf "%0${replicatesNumDigits}g" $simphyReplicateID)"
ngsphyReplicatePath="$HOME/data/NGSphy_${pipelinesName}.${replicateID}"
simphyReplicatePath="$HOME/data/${pipelinesName}.${replicateID}"
referencesReplicatePath="$HOME/data/references/references.${pipelinesName}.${replicateID}*"
################################################################################
# 1. REFERENCE INDEXING WITH BWA
################################################################################
for fastaFile in $(find $referencesReplicatePath  -name *.fasta); do
    qsub $HOME/src/vc-benchmark-cesga/jobs/analysis/ssp.analysis.1.sh $fastaFile
done
################################################################################
# 2. GENERATION OF BWA COMMAND LINESs
################################################################################
qsub -t $simphyReplicateID $HOME/src/vc-benchmark-cesga/jobs/analysis/ssp.analysis.2.sh PE150OWN HiSeq2500
qsub -t $simphyReplicateID $HOME/src/vc-benchmark-cesga/jobs/analysis/ssp.analysis.2.sh PE150DFLT HiSeq2500
qsub -t $simphyReplicateID $HOME/src/vc-benchmark-cesga/jobs/analysis/ssp.analysis.2.sh SE150DFLT HiSeq2500
qsub -t $simphyReplicateID $HOME/src/vc-benchmark-cesga/jobs/analysis/ssp.analysis.2.sh PE250DFLT MiSeqV3
qsub -t $simphyReplicateID $HOME/src/vc-benchmark-cesga/jobs/analysis/ssp.analysis.2.sh SE250DFLT MiSeqV3
################################################################################
# 3. MAPPINGS
################################################################################
profiles=("PE150OWN")#"PE150DFLT" "SE150DFLT" "PE250DFLT" "SE250DFLT")
for profileFOLDER in ${profiles[*]};do
    numJobs=$(find "$HOME/data/mappings/${pipelinesName}.${replicateID}/scripts/${pipelinesName}.${replicateID}.${profileFOLDER}.bwa.commands.*" -type f | wc -l );
    echo $numJobs
    # qsub -t 1-$numJobs  $HOME/src/vc-benchmark-cesga/jobs/analysis/ssp.analysis.3.sh "$HOME/data/mappings/${pipelinesName}.${replicateID}/scripts/${pipelinesName}.${replicateID}.${profileFOLDER}.bwa.commands.*"
done
