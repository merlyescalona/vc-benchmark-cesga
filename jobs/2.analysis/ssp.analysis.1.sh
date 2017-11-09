#!/bin/bash
#$ -v pipelinesName=ssp
#$ -wd /home/merly/data
#$ -o /home/merly/output/ssp.analysis.1.o
#$ -e /home/merly/error/ssp.analysis.1.e
#$ -N ref.index
module purge
module load gcc/5.2.0  bio/bwa/0.7.10 bio/samtools/   java/jdk/1.8.0_31  bio/picard/2.0.1

bwa index -a is $1
samtools faidx $1

referenceBasename=$(basename $1 .fasta)
referenceDirname=$(dirname $1)
picard CreateSequenceDictionary REFERENCE=$1 OUTPUT="${referenceDirname}/${referenceBasename}.dict"

module unload gcc/5.2.0  bio/bwa/0.7.10 bio/samtools/ java/jdk/1.8.0_31  bio/picard/2.0.1
