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
simphyReplicateID=4
pipelinesName="ssp"
replicatesNumDigits=5
replicateID="$(printf "%0${replicatesNumDigits}g" $simphyReplicateID)"
ngsphyReplicatePath="$HOME/data/NGSphy_${pipelinesName}.${replicateID}"
simphyReplicatePath="$HOME/data/${pipelinesName}.${replicateID}"
referencesReplicatePath="$HOME/data/references/references.${pipelinesName}.${replicateID}*"
################################################################################
# 1. REFERENCE INDEXING WITH BWA
################################################################################
for refereceFolder in $referencesReplicatePath; do
    for fastaFile in $(find $refereceFolder  -name "*.fasta"); do
        qsub $HOME/src/vc-benchmark-cesga/jobs/2.analysis/ssp.analysis.1.sh $fastaFile
    done
done
################################################################################
# 2. GENERATION OF BWA COMMAND LINESs
################################################################################
qsub -t $simphyReplicateID  $HOME/src/vc-benchmark-cesga/jobs/2.analysis/ssp.analysis.2.sh PE150DFLT HiSeq2500
qsub -t $simphyReplicateID  $HOME/src/vc-benchmark-cesga/jobs/2.analysis/ssp.analysis.2.sh SE150DFLT HiSeq2500
qsub -t $simphyReplicateID  $HOME/src/vc-benchmark-cesga/jobs/2.analysis/ssp.analysis.2.sh PE250DFLT MiSeqV3
qsub -t $simphyReplicateID  $HOME/src/vc-benchmark-cesga/jobs/2.analysis/ssp.analysis.2.sh SE250DFLT MiSeqV3
################################################################################
# 3. MAPPINGS
################################################################################
profiles=("SE150DFLT" "PE150DFLT"  "SE250DFLT" "PE250DFLT" ) # ("PE150OWN") #
for profileFOLDER in ${profiles[*]};do
    numJobs=$(find "$HOME/data/mappings/${pipelinesName}.${replicateID}/scripts/" -name "${pipelinesName}.${replicateID}.${profileFOLDER}.bwa.commands.*" -type f | wc -l );
    echo $numJobs
    qsub -t 1-$numJobs  $HOME/src/vc-benchmark-cesga/jobs/2.analysis/ssp.analysis.3.sh "$HOME/data/mappings/${pipelinesName}.${replicateID}/scripts/${pipelinesName}.${replicateID}.${profileFOLDER}.bwa.commands"
done
################################################################################
# 4. Generating BAMMING SORTING commands
################################################################################
qsub -t $simphyReplicateID $HOME/src/vc-benchmark-cesga/jobs/2.analysis/ssp.analysis.4.sh PE150DFLT
qsub -t $simphyReplicateID $HOME/src/vc-benchmark-cesga/jobs/2.analysis/ssp.analysis.4.sh SE150DFLT
qsub -t $simphyReplicateID $HOME/src/vc-benchmark-cesga/jobs/2.analysis/ssp.analysis.4.sh PE250DFLT
qsub -t $simphyReplicateID $HOME/src/vc-benchmark-cesga/jobs/2.analysis/ssp.analysis.4.sh SE250DFLT


bwa mem -t 4 -R "@RG\tID:outgroup-300\tSM:S.02-I.61\tPL:Illumina\tLB:outgroup-300\tPU:HiSeq2500" /home/merly/data/references/references.ssp.00001.outgroup.300/outgroup300_02.fasta /home/merly/data/NGSphy_ssp.00001/PE150DFLT/02/ssp_61_R1.fq.gz /home/merly/data/NGSphy_ssp.00001/PE150DFLT/02/ssp_61_R2.fq.gz > /home/merly/data/mappings/ssp.00001/PE150DFLT/02/ssp.00001.02.61.outgroup.300.sam
################################################################################
# 5. BAMMING SORTING # 12 threads
################################################################################
profiles=("PE250DFLT" "SE250DFLT") # ("PE150DFLT" "PE150OWN" "SE150DFLT") #
bammingFile=$HOME/src/vc-benchmark-cesga/files/${pipelinesName}.${replicateID}.p2.sh
for profileFOLDER in ${profiles[*]};do
    find "$HOME/data/mappings/${pipelinesName}.${replicateID}/scripts/" -name "${pipelinesName}.${replicateID}.${profileFOLDER}.samtools.commands.*" -type f  | sort  >> $bammingFile
done
numJobs=$(cat $bammingFile | wc -l )
qsub -pe threaded 12 -t 1-$numJobs  $HOME/src/vc-benchmark-cesga/jobs/2.analysis/ssp.analysis.5.sh $bammingFile



################################################################################
# 6. INFORMATION ON THE MAPPING
################################################################################

To ask the view command to report solely “proper pairs” we use the -f
option and ask for alignments where the second bit is true (proper pair is true).

samtools view -f 0x2 sample.sorted.bam
How many properly paired alignments are there?

samtools view -f 0x2 sample.sorted.bam | wc -l
Now, let’s ask for alignments that are NOT properly paired. To do this,
we use the -F option (note the capitalization to denote “opposite”).

samtools view -F 0x2 sample.sorted.bam
How many improperly paired alignments are there?

samtools view -F 0x2 sample.sorted.bam | wc -l
