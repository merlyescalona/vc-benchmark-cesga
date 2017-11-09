#!/bin/bash
#$ -wd /home/merly/data
#$ -o /home/merly/output/ssp.analysis.6.o
#$ -e /home/merly/error/ssp.analysis.6.e
#$ -N markdup

module purge
module load java/jdk/1.8.0_31  bio/picard/2.0.1
################################################################################
replicate=$2
profile=$3
bamFile=$(awk "NR==$SGE_TASK_ID" $1)
reference=""
echo "$replicate, $profile, $bamFile"
base=$(basename $bamFile .bam)
dir="$HOME/data/mappings/${pipelinesName}.${replicateID}/$profile/$replicateST"
fileSplit=($(echo $base | tr "." " "))
individual=${fileSplit[4]}
replicate_file_ST=${fileSplit[3]}

if [[ $bamFile == *"outgroup"* ]]; then
  reference="outgroup"
fi

if [[ $bamFile == *"rndingroup"* ]]; then
  reference="rndingroup"
fi
mkdir -p "$dir/dedup/$reference/"
mkdir -p "$dir/histogram/$reference/"
metricOutput="$dir/metrics/$reference/$base.metrics.txt"
dedupOutput="$dir/dedup/$reference/$base.dedup.bam"
echo "picard MarkDuplicates I=$bamFile O=$dedupOutput M=$metricOutput"
picard MarkDuplicates INPUT=$bamFile OUTPUT=$dedupOutput METRICS_FILE=$metricOutput

header=$(head -7 $metricOutput | tail -n+7)
summaryInfo=$(head -8 $metricOutput | tail -n+8)

if [[ ! -f $summaryFile ]]; then
    echo -e "SIMPHY_REPLICATE\tREPLICATE_ST\tINDIVIDUAL_ID\tPROFILE\t$header" > $summaryFile
fi
echo -e "${fileSplit[1]}.${fileSplit[2]}\t${replicate_file_ST}\t${profile}\t${summaryInfo}">> $summaryOutput

histogramOutput="$dir/histogram/$reference/$base.histogram.txt"

tail -n+11 $metricOutput > $histogramOutput
################################################################################
module unload java/jdk/1.8.0_31  bio/picard/2.0.1
