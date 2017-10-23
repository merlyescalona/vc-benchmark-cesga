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
# 0. Folder structure
################################################################################
# git clone https://merlyescalona@github.com/merlyescalona/vc-benchmark-cesga.git $HOME/vc-benchmark-cesga
# git clone https://merlyescalona@github.com/merlyescalona/refselector.git $HOME/src/refselector
# mkdir $folderDATA  $folderOUTPUT  $folderERROR  $folderINFO
################################################################################
# Folder paths
################################################################################
source $HOME/vc-benchmark-cesga/src/vcs.variables.sh
CLUSTER_ENV="SLURM"
simphyReplicateID=4
################################################################################
# 1. SIMPHY
################################################################################
step1JOBID=$(sbatch -a $simphyReplicateID $folderJOBS/1.datasim/ssp.1.simphy.sh | awk '{ print $4}')
################################################################################
# 2. INDELIBLE WRAPPER
################################################################################
# After the running of SimPhy, it is necessary to run the INDELIble_wrapper
# to obtain the control files for INDELible. Since, is not possible to
# run it for all the configurations, it is necessary to modify the name of the
# output files in order to keep track of every thing
################################################################################
step2JOBID=$(sbatch -a $simphyReplicateID --dependency=afterok:$step1JOBID $folderJOBS/1.datasim/ssp.2.wrapper.sh | awk '{ print $4}')
################################################################################
# 3. INDELIBLE
################################################################################
# Need to figure out the folder from where I'll call indelilble
# Need to filter the species tree replicates that do not have ninds % 2==0
numJobs=$(wc -l $HOME/vc-benchmark-cesga/files/${pipelinesName}.$(printf "%05g" $simphyReplicateID).indelible.folders.txt | awk '{ print $1}')
step3JOBID=$(sbatch -a 1-$numJobs $folderJOBS/1.datasim/ssp.3.indelible.array.sh $simphyReplicateID | awk '{ print $4}')
#-------------------------------------------------------------------------------
<<CHECK_NUM_FILES_INDELIBLE
# To check num fasta files and trees in indelible folders
indelibleFolders="$HOME/vc-benchmark-cesga/files/${pipelinesName}.$(printf "%05g" $simphyReplicateID).indelible.folders.txt"
for item in $(cat $indelibleFolders);do
    cd $LUSTRE/data/${pipelinesName}.$(printf "%05g" $simphyReplicateID)/$(printf "%02g" $item)
    echo -e "$(printf "%02g" $item): gt $(ls g_trees* | wc -l)\tFASTA $(ls *.fasta | grep TRUE | wc -l)\tTRUEFASTA $(ls *TRUE.fasta | wc -l)"
done
CHECK_NUM_FILES_INDELIBLE
########################################################################
# 4. Reference Loci Selection
########################################################################
step4JOBID=$(sbatch -t $simphyReplicateID  --dependency=afterok:$step3JOBID $folderJOBS/1.datasim/ssp.4.references.slurm.sh | awk '{ print $4}')
########################################################################
# 5. NGSPHY
########################################################################
step5JOBID=$(sbatch -a $simphyReplicateID --dependency=afterok:$step3JOBID $folderJOBS/1.datasim/ssp.5.ngsphy.sh | awk '{ print $4}')
step8JOBID=$(sbatch -a $simphyReplicateID --dependency=afterok:$step5JOBID $folderJOBS/1.datasim/ssp.8.cesga.data.compression.sh | awk '{ print $4}')
########################################################################
######## SLURM                  ########################################
########################################################################
########################################################################
########################################################################
########################################################################
########################################################################
# 6.1 SLURM PREP2ART - Generation of folder structure for all art commands per PROFILES
#-----------------------------------------------------------------------
if [[ $CLUSTER_ENV -eq "SLURM" ]]; then
    step6OBID=$(sbatch -a $simphyReplicateID --dependency=afterok:$step5JOBID $folderJOBS/1.datasim/ssp.6.prep.2.art.slurm.sh | awk '{ print $4}')
fi
########################################################################
# LAUNCHING JOBS FOR ART GENERATION
########################################################################
simphyReplicateID=3
pipelinesName="ssp"
replicatesNumDigits=5
replicateID="$(printf "%0${replicatesNumDigits}g" $simphyReplicateID)"
ngsphyReplicatePath="$LUSTRE/data/ngsphy.data/NGSphy_${pipelinesName}.${replicateID}"
replicates=($(ls $ngsphyReplicatePath/reads))
artFilesReplicate="$HOME/vc-benchmark-cesga/files/${pipelinesName}.${replicateID}.art.commands.files.txt"
for item in $(find $ngsphyReplicatePath/scripts/ -name "${pipelinesName}.${replicateID}.HS25.PE.150.art.commands*" | sort); do
    echo $item >> $artFilesReplicate
done
for item in $(find $ngsphyReplicatePath/scripts/ -name "${pipelinesName}.${replicateID}.HS25.SE.150.art.commands*" | sort); do
    echo $item >> $artFilesReplicate
done
for item in $(find $ngsphyReplicatePath/scripts/ -name "${pipelinesName}.${replicateID}.MSv3.SE.250.art.commands*" | sort); do
    echo $item >> $artFilesReplicate
done
for item in $(find $ngsphyReplicatePath/scripts/ -name "${pipelinesName}.${replicateID}.MSv3.PE.250.art.commands*" | sort); do
    echo $item >> $artFilesReplicate
done
nJobs=$(cat $artFilesReplicate |wc -l | awk '{print $1}')
sbatch -a 1-$nJobs $folderJOBS/1.datasim/ssp.7.art.slurm.sh $item;

########################################################################
##############         SGE                    ##########################
########################################################################
########################################################################
########################################################################
# 6.2 SGE PREP2ART - Generation of folder structure for all art commands per PROFILES
#-----------------------------------------------------------------------
simphyReplicateID=2
pipelinesName="ssp"
replicatesNumDigits=5
replicateID="$(printf "%0${replicatesNumDigits}g" $simphyReplicateID)"
ngsphyReplicatePath="$HOME/data/NGSphy_${pipelinesName}.${replicateID}"
replicates=($(ls $ngsphyReplicatePath/reads))
#-----------------------------------------------------------------------
if [[ $CLUSTER_ENV -eq "SGE" ]]; then
    replicateID=$(printf "%05g" $simphyReplicateID)
    pipelinesName="ssp"
    replicateFOLDER="$LUSTRE/data/$pipelinesName.$replicateID"
    rsync -rP $replicateFOLDER/  merly@triploid.uvigo.es:/home/merly/data/$pipelinesName.$replicateID
    rsync -rP $LUSTRE/data/ngsphy.data/NGSphy_$pipelinesName.$replicateID/  merly@triploid.uvigo.es:/home/merly/data/NGSphy_$pipelinesName.$replicateID
    scp -r $LUSTRE/data/references/references.${pipelinesName}.${replicateID}.*  merly@triploid.uvigo.es:/home/merly/references/
    step5OBID_SGE=$(qsub -t $simphyReplicateID $HOME/src/vc-benchmark-cesga/jobs/1.datasim/ssp.5.ngsphy.sh)
fi
########################################################################
# LAUNCHING JOBS FOR ART GENERATION
########################################################################
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
