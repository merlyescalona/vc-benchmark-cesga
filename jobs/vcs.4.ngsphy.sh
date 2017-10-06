#!/bin/bash
#SBATCH -n 1
#SBATCH -t 10:00:00
#
#SBATCH --job-name=ngsphy
#SBATCH --output=/mnt/lustre/scratch/home/uvi/be/mef/output/vcs.4.%a.o
#SBATCH --error=/mnt/lustre/scratch/home/uvi/be/mef/error/vcs.4.%a.e
#SBATCH --workdir=/mnt/lustre/scratch/home/uvi/be/mef/data/
#
#SBATCH --mail-type=begin,end
#SBATCH --mail-user=escalona10@gmail.com
#SBATCH --partition shared
#SBATCH --qos=shared
################################################################################
# Variables
replicateID=$(printf "%05g" ${SLURM_ARRAY_TASK_ID})
pipelinesName="vcs"
simphyFOLDER=${pipelinesName}.$(printf "%05g" ${SLURM_ARRAY_TASK_ID})
echo -e "[$(date)] $(hostname):\t${SLURM_ARRAY_TASK_ID},\t$pipelinesName,\t$replicateID,\t$simphyFOLDER"
################################################################################
# generate ngsphy settings file
echo "generate ngsphy settings file"
if [ ! -d $LUSTRE/data/ngsphy.settings ];then
    mkdir $LUSTRE/data/ngsphy.settings
fi
if [ ! -d $LUSTRE/data/ngsphy.data ];then
    mkdir $LUSTRE/data/ngsphy.data
fi
################################################################################
# PATHS
ngsphySettingsGenerator="$HOME/vc-benchmark-cesga/src/vcs.write.ngsphy.sh"
folderNGSPROFILE="$HOME/vc-benchmark-cesga/files"
################################################################################
# bash vcs.write.ngsphy pipelinesName idREPLICATE folderSIMPHY folderNGSPROFILE fileOUTPUT folderOUTPUT
echo "bash $ngsphySettingsGenerator $pipelinesName $replicateID $LUSTRE/data/$simphyFOLDER $folderNGSPROFILE $LUSTRE/data/ngsphy.settings/${simphyFOLDER}.txt $LUSTRE/data/ngsphy.data"
bash $ngsphySettingsGenerator $pipelinesName $replicateID $LUSTRE/data/$simphyFOLDER $folderNGSPROFILE $LUSTRE/data/ngsphy.settings/${simphyFOLDER}.txt $LUSTRE/data/ngsphy.data
################################################################################
module purge
module load anaconda2/4.0.0 gcc/5.3.0 art/2016-06-05
################################################################################
#Usage: ./INDELIble_wrapper.pl directory input_config seed numberofcores
echo "ngsphy -s $LUSTRE/data/ngsphy.settings/${simphyFOLDER}.txt"
ngsphy -s $LUSTRE/data/ngsphy.settings/${simphyFOLDER}.txt
################################################################################
module unload anaconda2/4.0.0 gcc/5.3.0 art/2016-06-05
