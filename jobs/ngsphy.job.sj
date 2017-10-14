#!/bin/bash
#SBATCH -n 1
#SBATCH -t 10:00:00
#
#SBATCH --job-name=ngsphy
#SBATCH --output=/mnt/lustre/scratch/home/uvi/be/mef/output/ssp.4.o
#SBATCH --error=/mnt/lustre/scratch/home/uvi/be/mef/error/ssp.4.e
#SBATCH --workdir=/mnt/lustre/scratch/home/uvi/be/mef/data/
#
#SBATCH --mail-type=begin,end
#SBATCH --mail-user=escalona10@gmail.com
#SBATCH --partition thinnodes
################################################################################
module load anaconda2/4.0.0 gcc/5.3.0 art/2016-06-05
echo "ngsphy -s /mnt/lustre/scratch/home/uvi/be/mef/data/ngsphy.settings/ssp.00002.txt"
ngsphy -s /mnt/lustre/scratch/home/uvi/be/mef/data/ngsphy.settings/ssp.00002.txt
################################################################################
module unload anaconda2/4.0.0 gcc/5.3.0 art/2016-06-05
