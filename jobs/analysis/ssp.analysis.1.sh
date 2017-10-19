#!/bin/bash
#$ -v pipelinesName=ssp
#$ -wd /home/merly/data
#$ -o /home/merly/output/ssp.analysis.1.o
#$ -e /home/merly/error/ssp.analysis.1.e
#$ -N ref.index
module purge
module load gcc/5.2.0  bio/bwa/0.7.10

bwa index -a is $1

module unload gcc/5.2.0  bio/bwa/0.7.10
