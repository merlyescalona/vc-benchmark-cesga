#!/bin/bash
#$ -v pipelinesName=ssp
#$ -wd /home/merly/data
#$ -o /home/merly/refselector.o
#$ -e /home/merly/refselector.e
#$ -N refselector
simphyReplicateID=${SGE_TASK_ID}
replicateID=$(printf "%05g" $simphyReplicateID)
pipelinesName="ssp"
module load python/2.7.8

if [ ! -d $HOME/data/references ];then
    mkdir -p $HOME/data/references
fi

refselector -p 2 -s $HOME/data/${pipelinesName}.${replicateID} -ip data -op outgroup300 -o $HOME/data/references/references.${pipelinesName}.${replicateID}.outgroup.300  -m 0 --nsize 300
refselector -p 2 -s $HOME/data/${pipelinesName}.${replicateID} -ip data -op rndingroup300 -o $HOME/data/references/references.${pipelinesName}.${replicateID}.rndingroup.300  -m 2 --nsize 300
refselector -p 2 -s $HOME/data/${pipelinesName}.${replicateID} -ip data -op outgroup500 -o $HOME/data/references/references.${pipelinesName}.${replicateID}.outgroup.500  -m 0 --nsize 500
refselector -p 2 -s $HOME/data/${pipelinesName}.${replicateID} -ip data -op rndingroup500 -o $HOME/data/references/references.${pipelinesName}.${replicateID}.rndingroup.500  -m 2 --nsize 500

module unload python/2.7.8
