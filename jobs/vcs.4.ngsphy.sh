#!/bin/bash
#SBATCH -n 1
#SBATCH -t 12:00:00
#
#SBATCH --job-name=ngsphy
#SBATCH --output=/mnt/lustre/scratch/home/uvi/be/mef/output/vcs.4.o
#SBATCH --error=/mnt/lustre/scratch/home/uvi/be/mef/error/vcs.4.e
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
echo $(hostname),$pipelinesName,${SLURM_ARRAY_TASK_ID},$replicateID, $simphyFOLDER
################################################################################
# generate ngsphy settings file
echo "generate ngsphy settings file"
if [ ! -d $LUSTRE/data/ngsphy.settings ];then
    mkdir $LUSTRE/data/ngsphy.settings
fi
################################################################################
# PATHS
ngsphyCOMMAND="$HOME/src/ngsphy/scripts/ngsphy"
ngsphySettingsGenerator="$HOME/vc-benchmark-cesga/src/vcs.write.ngsphy"
folderNGSPROFILE="$HOME/vc-benchmark-cesga/files"

################################################################################
$ngsphySettingsGenerator $pipelinesName $replicateID $LUSTRE/data/$simphyFOLDER
################################################################################
module purge
module load anaconda2/4.0.0 gcc/5.3.0 art/2016-06-05
################################################################################
wrapper="$HOME/vc-benchmark-cesga/src/INDELible_wrapper_v2.pl"
controlFile="$HOME/vc-benchmark-cesga/files/indelible.control.v2.txt"
#Usage: ./INDELIble_wrapper.pl directory input_config seed numberofcores
echo "perl $wrapper $pipelinesName.$pipeID $controlFile 523911721 1 &> \"$LUSTRE/output/$pipelinesName.$pipeID.1.2.indelible.wrapper.txt\""
perl $wrapper $LUSTRE/data/$pipelinesName.$pipeID $controlFile 523911721 1 &> "$LUSTRE/output/$pipelinesName.$pipeID.1.2.indelible.wrapper.txt"
################################################################################
module unload anaconda2/4.0.0 gcc/5.3.0 art/2016-06-05
