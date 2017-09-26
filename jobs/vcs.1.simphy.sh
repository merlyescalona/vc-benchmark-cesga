#!/bin/bash
#SBATCH -n 1
#SBATCH -t 00:30:00
#
#SBATCH --job-name=vcs.1.1
#SBATCH --output=/mnt/EMC/Store_uni/home/uvi/be/mef/vc-benchmark-sims/output/vcs.1.1.o
#SBATCH --error=/mnt/EMC/Store_uni/home/uvi/be/mef/vc-benchmark-sims/error/vcs.1.1.e
#SBATCH --workdir=/mnt/EMC/Store_uni/home/uvi/be/mef/vc-benchmark-sims/
#
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --mail-user=escalona10@gmail.com

pipelinesName="vcs.01"
RS="1000" #number of species trees
RL="F:5000" # Number of locus tree /= to number of gene tress (1 locus tree per gene tree)
SB="L:-13.58,1.85" # Speciation rate - depends on SU and SI (species tree height and number of inds. per taxa/tips)
SG="F:1" # tree wide generation time
SI="U:2,20" #numIndTaxa
SL="U:10,20" #Num. taxa
SO="F:1" # outgroupBranch length - This can be modified (LN:0,1)
SP="F:10000" # Effective population size
ST="U:5000000,20000000" # species tree heights
SU="U:0.00000001,0.0000000001" # Mutation rate (10e-8 - 10e-10)
GP="L:1.4,1"  # Gene-by-lineage-specific rate heterogeneity modifier (HYPER PARAM)
HH="L:1.2,1" # Gene-by-family heterogeneity
HG="F:GP" # Gene-by-lineage-specific rate heterogeneity modifier

module load gcc/5.3.0 simphy/1.0.2
simphy -rs $RS -rl $RL -su $SU -sb $SB -sl $SL -si $SI -sp $SP -st $ST -so $SO -sg $SG -gp $GP -hh $HH -hg $HG  -v 1 -o $pipelinesName -cs $RANDOM -od 1 -op 1 -oc 1 -on 1
module unload gcc/5.3.0 simphy/1.0.2
