#!/bin/bash
#SBATCH -n 1
#SBATCH -t 00:30:00
#
#SBATCH --job-name=vcs.1.1
#SBATCH --output=/mnt/lustre/scratch/home/uvi/be/mef/output/vcs.2.o
#SBATCH --error=/mnt/lustre/scratch/home/uvi/be/mef/error/vcs.2.e
#SBATCH --workdir=/mnt/lustre/scratch/home/uvi/be/mef/data/
#
#SBATCH --mail-type=begin,end
#SBATCH --mail-user=escalona10@gmail.com
#SBATCH --partition shared
#SBATCH --qos=shared

pipeID=$(printf "%05g" ${SLURM_ARRAY_TASK_ID})
pipelinesName="vcs"
echo $pipeID, $pipelinesName
module purge
module load gcc/6.3.0  perl/5.24.0  gsl/2.3
wrapper="$HOME/vc-benchmark-cesga/src/INDELIble_wrapper.v2.pl"
controlFile="$HOME/vc-benchmark-cesga/files/indelible.control.v2.txt"
#Usage: ./INDELIble_wrapper.pl directory input_config seed numberofcores
echo "perl $wrapper $pipelinesName.$pipeID $controlFile 523911721 1 &> \"$LUSTRE/output/$pipelinesName.$pipeID.1.2.indelible.wrapper.txt\""
perl $wrapper $pipelinesName.$pipeID $controlFile 523911721 1 &> "$LUSTRE/output/$pipelinesName.$pipeID.1.2.indelible.wrapper.txt"
module unload gcc/6.3.0  perl/5.24.0  gsl/2.3
