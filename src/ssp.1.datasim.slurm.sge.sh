################################################################################
# (c) 2015-2017 Merly Escalona <merlyescalona@uvigo.es>
# Phylogenomics Lab. University of Vigo.
#
# Description:
# ============
# Pipelines for data simulation for variant calling assesment
# Running @ft2.cesga.es
################################################################################
#!/bin/bash -l
################################################################################
# Previous to running the wrapper I had to set up the perl env.
<<MODULE_INSTALL_PERL
module load gcc/6.3.0  perl/5.24.0  gsl/2.3 loaded
% cpan
cpan> o conf mbuildpl_arg '--install_base /home/uvi/be/mef/perl'
cpan> o conf commit
cpan> q
cpan install Math::GSL
MODULE_INSTALL_PERL
################################################################################
# Folder paths
################################################################################
source $HOME/vc-benchmark-cesga/src/vcs.variables.sh
simphyReplicateID=3
################################################################################
# 0. Folder structure
################################################################################
# git clone https://merlyescalona@github.com/merlyescalona/vc-benchmark-cesga.git $HOME/vc-benchmark-cesga
# mkdir $folderDATA  $folderOUTPUT  $folderERROR  $folderINFO
################################################################################
# STEP 1. SimPhyvc
################################################################################
step1JOBID=$(sbatch -a $simphyReplicateID $folderJOBS/vcs.1.simphy.sh | awk '{ print $4}')
################################################################################
# STEP 2. INDELible wrapper
################################################################################
# After the running of SimPhy, it is necessary to run the INDELIble_wrapper
# to obtain the control files for INDELible. Since, is not possible to
# run it for all the configurations, it is necessary to modify the name of the
# output files in order to keep track of every thing
################################################################################
step2JOBID=$(sbatch -a $simphyReplicateID --dependency=afterok:$step1JOBID $folderJOBS/vcs.2.wrapper.sh | awk '{ print $4}')

################################################################################
# 3. INDELIBLE CALLS
################################################################################
# Need to figure out the folder from where I'll call indelilble
# Need to filter the species tree replicates that do not have ninds % 2==0
numJobs=$(wc -l $HOME/vc-benchmark-cesga/files/${pipelinesName}.$(printf "%05g" $simphyReplicateID).indelible.folders.txt | awk '{ print $1}')
step3JOBID=$(sbatch -a 1-$numJobs $folderJOBS/vcs.3.indelible.array.sh $simphyReplicateID | awk '{ print $4}')
#-------------------------------------------------------------------------------
# To check num fasta files and trees in indelible folders
indelibleFolders="$HOME/vc-benchmark-cesga/files/${pipelinesName}.$(printf "%05g" $simphyReplicateID).indelible.folders.txt"
for item in $(cat $indelibleFolders);do
    cd $LUSTRE/data/${pipelinesName}.$(printf "%05g" $simphyReplicateID)/$(printf "%02g" $item)
    echo -e "$(printf "%02g" $item): gt $(ls g_trees* | wc -l)\tFASTA $(ls *.fasta | grep TRUE | wc -l)\tTRUEFASTA $(ls *TRUE.fasta | wc -l)"
done
################################################################################
# 4. ngsphy
################################################################################
step4JOBID=$(sbatch -a $simphyReplicateID --dependency=afterok:$step3JOBID $folderJOBS/vcs.4.ngsphy.sh)
# Possible - Generate Folder structure for art
################################################################################
# 4.1 DATA TRANSFERENCE
################################################################################
replicateID=$(printf "%05g" $simphyReplicateID)
pipelinesName="ssp"
replicateFOLDER="$LUSTRE/data/$pipelinesName.$replicateID"
rsync -rP $replicateFOLDER/  merly@triploid.uvigo.es:/home/merly/data/$pipelinesName.$replicateID
rsync -rP $LUSTRE/data/ngsphy.data/NGSphy_$pipelinesName.$replicateID/  merly@triploid.uvigo.es:/home/merly/data/NGSphy_$pipelinesName.$replicateID
################################################################################
# 4.2 DATA COMPRESSION LUSTRE
################################################################################
simphyReplicateID=1
replicateID=$(printf "%05g" $simphyReplicateID)
pipelinesName="ssp"
replicateFOLDER="$LUSTRE/data/$pipelinesName.$replicateID"
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

################################################################################
# 5. Reference Loci Selection
# @ triploid
################################################################################
step3.1JOBID=$(qsub -t $simphyReplicateID  $HOME/vc-benchmark-cesga/jobs/vcs.3.1.references.sh | awk '{ print $4}')
################################################################################
# 4. 0
#-------------------------------------------------------------------------------
# Compress gene tree files of the replicates into a single gtrees file.
# The file will be a tab separated file with the id and the gtree
################################################################################
simphyReplicateID=1
replicateID=$(printf "%05g" $simphyReplicateID)
pipelinesName="ssp"
replicateFOLDER="$LUSTRE/data/$pipelinesName.$replicateID"
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

################################################################################
# 4.1 ART
################################################################################
# Need to split the command file. This is because the slurm sysmtem does not
# allow me to launch jobs over 1K.
################################################################################
<<SPLIT_COMMANDS
# If staying at LUSTRE, LUSTRE does not allow to launch more than 1000 jobs.
# So,if I had to split the files and wait for all the jobs to finish to launch
# the following 1000 jobs.
# In any case, I'm moving things to triploid,
# Way better and faster to run on triploid sequentially
SPLIT_COMMANDS
<<RSYNC
# This takes like an hour
rsync -rP $LUSTRE/data/ngsphy.data/NGSphy_ssp.00002/  merly@triploid.uvigo.es:/home/merly/data/NGSphy_ssp.00002
# Had to change the names of the paths for the files that were used, since I'm no longer at cesga
cat ssp.00002.sh | sed 's/\/mnt\/lustre\/scratch\/home\/uvi\/be\/mef\/data\/ngsphy.data/\/home\/merly\/data/g' | sed 's/\/home\/uvi\/be\/mef\/vc-benchmark-cesga\/files/\/home\/merly\/csNGSProfile/g'  > ssp.00002.triploid.sh

RSYNC
################################################################################
#  Run 1 - PE 150 bp with custom profile
################################################################################
simphyReplicateID=1
pipelinesName="ssp"
replicatesNumDigits=5
replicateID="$pipelinesName.$(printf "%0${replicatesNumDigits}g" $simphyReplicateID)"
split -l 10000 -d -a 2 ${replicateID}.triploid.sh ${replicateID}.art.commands.
for file in $(ls ${replicateID}.art.commands*); do    mv $file "$file.sh"; done

################################################################################
#  Runs with DEFAULT PROFILES
################################################################################
simphyReplicateID=2
pipelinesName="ssp"
replicatesNumDigits=5
replicateID="$(printf "%0${replicatesNumDigits}g" $simphyReplicateID)"
# ngsphyReplicatePath="$LUSTRE/data/ngsphy.data/NGSphy_${pipelinesName}.${replicateID}"
ngsphyReplicatePath="$HOME/data/NGSphy_${pipelinesName}.${replicateID}"
# This is to remove the profiles leaving PE150
triploidARTSE150=$ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.triploid.HS25.SE.150.sh
triploidARTPE150=$ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.triploid.HS25.PE.150.sh
triploidARTSE250=$ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.triploid.MSv3.SE.250.sh
triploidARTPE250=$ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.triploid.MSv3.PE.250.sh
# This is to remove the profiles and the paired end
cat $ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.sh | sed 's/\/mnt\/lustre\/scratch\/home\/uvi\/be\/mef\/data\/ngsphy.data/\/home\/merly\/data/g' | sed 's/--out \/home\/merly\/data\/NGSphy_'"${pipelinesName}"'.'"${replicateID}"'\/reads/--out \/home\/merly\/data\/NGSphy_'"${pipelinesName}"'.'"${replicateID}"'\/reads_run_PE_150_DFLT/g' > $triploidARTPE150
cat $ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.sh | sed 's/\/mnt\/lustre\/scratch\/home\/uvi\/be\/mef\/data\/ngsphy.data/\/home\/merly\/data/g' | sed 's/--out \/home\/merly\/data\/NGSphy_'"${pipelinesName}"'.'"${replicateID}"'\/reads/--out \/home\/merly\/data\/NGSphy_'"${pipelinesName}"'.'"${replicateID}"'\/reads_run_SE_150_DFLT/g' | sed 's/ -p / /g' >  $triploidARTSE150
cat $ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.sh | sed 's/\/mnt\/lustre\/scratch\/home\/uvi\/be\/mef\/data\/ngsphy.data/\/home\/merly\/data/g' | sed 's/--out \/home\/merly\/data\/NGSphy_'"${pipelinesName}"'.'"${replicateID}"'\/reads/--out \/home\/merly\/data\/NGSphy_'"${pipelinesName}"'.'"${replicateID}"'\/reads_run_PE_250_DFLT/g' | sed 's/ -ss HS25/ -ss MSv3/g' | sed 's/-l 150/-l 250/g' | sed 's/-m 215 -s 50/-m 375 -s 100/g' > $triploidARTPE250
cat $ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.sh | sed 's/\/mnt\/lustre\/scratch\/home\/uvi\/be\/mef\/data\/ngsphy.data/\/home\/merly\/data/g' | sed 's/--out \/home\/merly\/data\/NGSphy_'"${pipelinesName}"'.'"${replicateID}"'\/reads/--out \/home\/merly\/data\/NGSphy_'"${pipelinesName}"'.'"${replicateID}"'\/reads_run_SE_250_DFLT/g' | sed 's/ -ss HS25/ -ss MSv3/g' | sed 's/-l 150/-l 250/g' | sed 's/-m 215 -s 50/-m 375 -s 100/g' | sed 's/ -p / /g' >  $triploidARTSE250

cd /home/merly/data/NGSphy_${pipelinesName}.${replicateID}/scripts/
split -l 10000 -d -a 2 $triploidART $ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.CUSTOM.PE.150.art.commands.
split -l 10000 -d -a 2 $triploidARTSE150 $ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.HS25.SE.150.art.commands.
split -l 10000 -d -a 2 $triploidARTPE150 $ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.HS25.PE.150.art.commands.
split -l 10000 -d -a 2 $triploidARTSE250 $ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.MSv3.SE.250.art.commands.
split -l 10000 -d -a 2 $triploidARTPE250 $ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.MSv3.PE.250.art.commands.
for file in $(ls $ngsphyReplicatePath/scripts/*.art.commands*); do    mv $file "$file.sh"; done

################################################################################
# Generate folder structure for all the possible read scenarios
################################################################################
replicates=($(ls $ngsphyReplicatePath/reads))
for item in ${replicates[*]}; do
    numLoc=$(ls $ngsphyReplicatePath/reads/$item| wc -l);
    for loc in $(seq 1 $numLoc); do
        echo "$item/$loc"
        mkdir -p $ngsphyReplicatePath/reads_run_PE_150_DFLT/$item/$(printf "%04g" $loc);
        mkdir -p $ngsphyReplicatePath/reads_run_SE_150_DFLT/$item/$(printf "%04g" $loc);
        mkdir -p $ngsphyReplicatePath/reads_run_SE_250_DFLT/$item/$(printf "%04g" $loc);
        mkdir -p $ngsphyReplicatePath/reads_run_PE_250_DFLT/$item/$(printf "%04g" $loc);
    done
done
################################################################################
# LAUNCHING JOBS FOR ART GENERATION
################################################################################
# for item in $(find $ngsphyReplicatePath/scripts/ -name "${pipelinesName}.${replicateID}.art.commands*" | sort); do
#     echo $item
#     qsub $HOME/vc-benchmark-cesga/jobs/vcs.5.art.split.sh $item;
# done
for item in $(find $ngsphyReplicatePath/scripts/ -name "${pipelinesName}.${replicateID}.HS25.PE.150.art.commands*" | sort); do
    echo $item
    qsub $HOME/src/vc-benchmark-cesga/jobs/vcs.5.art.split.sge.sh $item;
done
for item in $(find $ngsphyReplicatePath/scripts/ -name "${pipelinesName}.${replicateID}.HS25.SE.150.art.commands*" | sort); do
    echo $item
    qsub $HOME/src/vc-benchmark-cesga/jobs/vcs.5.art.split.sge.sh $item;
done
for item in $(find $ngsphyReplicatePath/scripts/ -name "${pipelinesName}.${replicateID}.MSv3.SE.250.art.commands*" | sort); do
    echo $item
    qsub $HOME/src/vc-benchmark-cesga/jobs/vcs.5.art.split.sge.sh $item;
done
for item in $(find $ngsphyReplicatePath/scripts/ -name "${pipelinesName}.${replicateID}.MSv3.PE.250.art.commands*" | sort); do
    echo $item
    qsub $HOME/src/vc-benchmark-cesga/jobs/vcs.5.art.split.sge.sh $item;
done
################################################################################
# ORGANIZATION OF READS PER INDIVIDUALS
################################################################################
# for replicateST in ${replicates[*]}; do
#     qsub -t $simphyReplicateID $HOME/vc-benchmark-cesga/jobs/vcs.6.organization.fq.individuals.sh PE150OWN PAIRED $replicateST reads_run
# done
simphyReplicateID=2
pipelinesName="ssp"
replicatesNumDigits=5
replicateID="$(printf "%0${replicatesNumDigits}g" $simphyReplicateID)"
# ngsphyReplicatePath="$LUSTRE/data/ngsphy.data/NGSphy_${pipelinesName}.${replicateID}"
ngsphyReplicatePath="$HOME/data/NGSphy_${pipelinesName}.${replicateID}"
replicates=($(ls $ngsphyReplicatePath/reads))
for replicateST in ${replicates[*]}; do
    qsub -t $simphyReplicateID $HOME/src/vc-benchmark-cesga/jobs/vcs.6.organization.fq.individuals.sh PE150DFLT PAIRED $replicateST reads_run_PE_150_DFLT
done
for replicateST in ${replicates[*]}; do
    qsub -t $simphyReplicateID $HOME/src/vc-benchmark-cesga/jobs/vcs.6.organization.fq.individuals.sh SE150DFLT SINGLE $replicateST reads_run_SE_150_DFLT
done
for replicateST in ${replicates[*]}; do
    qsub -t $simphyReplicateID $HOME/src/vc-benchmark-cesga/jobs/vcs.6.organization.fq.individuals.sh SE250DFLT SINGLE $replicateST reads_run_SE_250_DFLT
done
for replicateST in ${replicates[*]}; do
    qsub -t $simphyReplicateID $HOME/src/vc-benchmark-cesga/jobs/vcs.6.organization.fq.individuals.sh PE250DFLT PAIRED $replicateST reads_run_PE_250_DFLT
done

# To check status of the org.fq.ind jobs
for item in $(qstat | grep org  | awk '{print $1}'); do
    echo "$item, $(qstat -j $item | grep job_args)";
done






###############################################################################
# STEP 9. FASTQC
################################################################################

fqFiles="$fqReadsFolder/${pipelinesName}.allfiles.fastq"
find $fqReadsFolder -name *.fq | xargs cat > $fqFiles

st=1
echo -e "#! /bin/bash
#$ -o $outputFolder/$pipelinesName.8.$st.o
#$ -e $outputFolder/$pipelinesName.8.$st.e
#$ -N $pipelinesName.8.$st

INPUTBASE=$(basename $fqFiles .fastq)

cd $qcFolder/\$INPUTBASE
$fastqc $fqFiles -o $qcFolder/$INPUTBASE

">   $scriptsFolder/$pipelinesName.8.$st.sh
qsub -l num_proc=1,s_rt=0:05:00,s_vmem=2G,h_fsize=1G,arch=haswell $scriptsFolder/$pipelinesName.8.$st.sh
