#!/bin/bash
#SBATCH -n 1
#SBATCH -t 00:30:00
#
#SBATCH --job-name=simphy
#SBATCH --output=/mnt/lustre/scratch/home/uvi/be/mef/output/ssp.1.%a.o
#SBATCH --error=/mnt/lustre/scratch/home/uvi/be/mef/error/ssp.1.%a.e
#SBATCH --workdir=/mnt/lustre/scratch/home/uvi/be/mef/data/
#
#SBATCH --mail-type=begin,end
#SBATCH --mail-user=escalona10@gmail.com
#SBATCH --partition shared
#SBATCH --qos=shared

pipeID=$(printf "%05g" ${SLURM_ARRAY_TASK_ID})
pipelinesName="ssp"
echo $pipeID, $pipelinesName, $(hostname)
echo $(date)
RS="10" #number of species trees
RL="U:100,3000" # Number of locus tree /= to number of gene tress (1 locus tree per gene tree)
SB="L:-13.58,1.85" # Speciation rate - depends on SU and SI (species tree height and number of inds. per taxa/tips)
SG="F:1" # tree wide generation time
SI="U:2,10" #numIndTaxa
SL="U:5,10" #Num. taxa
SO="F:1" # outgroupBranch length - This can be modified (LN:0,1)
SP="F:10000" # Effective population size
ST="U:5000000,20000000" # species tree heights
SU="U:0.00000001,0.0000000001" # Mutation rate (10e-8 - 10e-10)
GP="L:1.4,1"  # Gene-by-lineage-specific rate heterogeneity modifier (HYPER PARAM)
HH="L:1.2,1" # Gene-by-family heterogeneity
HG="F:GP" # Gene-by-lineage-specific rate heterogeneity modifier

module purge
module load gcc/5.3.0 simphy/1.0.2 sqlite/3.11.0  R/3.3.3
simphy  -rs $RS -rl $RL -su $SU -sb $SB -sl $SL -si $SI -sp $SP -st $ST -so $SO \
        -sg $SG -gp $GP -hh $HH -hg $HG  -v 1 \
        -o ${pipelinesName}.$(printf "%05g" ${SLURM_ARRAY_TASK_ID}) \
        -cs "$RANDOM$RANDOM" -od 1 -op 1 -oc 1 -on 1
echo "Filtering replicates"
simphyLOCATION="/mnt/lustre/scratch/home/uvi/be/mef/data/${pipelinesName}.$(printf "%05g" ${SLURM_ARRAY_TASK_ID})"
Rscript $HOME/vc-benchmark-cesga/src/filtering.even.R \
    "$simphyLOCATION/${pipelinesName}.$(printf "%05g" ${SLURM_ARRAY_TASK_ID}).db" \
    "$HOME/vc-benchmark-cesga/files/${pipelinesName}.$(printf "%05g" ${SLURM_ARRAY_TASK_ID}).evens" \
    "$HOME/vc-benchmark-cesga/files/${pipelinesName}.$(printf "%05g" ${SLURM_ARRAY_TASK_ID}).odds"

for line in $(cat $HOME/vc-benchmark-cesga/files/${pipelinesName}.$(printf "%05g" ${SLURM_ARRAY_TASK_ID}).evens); do
  st=$(printf "%02g" ${line})
  echo "$LUSTRE/data/${pipelinesName}.$(printf "%05g" ${SLURM_ARRAY_TASK_ID})/${st}" >> $HOME/vc-benchmark-cesga/files/${pipelinesName}.$(printf "%05g" ${SLURM_ARRAY_TASK_ID}).indelible.folders.txt
done

module unload gcc/5.3.0 simphy/1.0.2 sqlite/3.11.0 R/3.3.3
