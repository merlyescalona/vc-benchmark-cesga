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
echo "$replicate, $profile"
filename=$(awk "NR==$SGE_TASK_ID" $1)
base=$(basename $filename .bam)
dir=$(dirname $filename )
if [[ ! -d  $dir/metrics/ ]]; then
    mkdir -p $dir/metrics/
fi
if [[ ! -d  $dir/dedup/ ]]; then
    mkdir -p $dir/dedup/
fi
if [[ ! -d  $dir/summary/ ]]; then
    mkdir -p $dir/summary/
fi
if [[ ! -d  $dir/histogram/ ]]; then
    mkdir -p $dir/histogram/
fi
metricOutput="$dir/metrics/$base.metrics.txt"
dedupOutput="$dir/dedup/$base.dedup.bam"
echo "picard MarkDuplicates I=$filename O=$dedupOutput M=$metricOutput"
picard MarkDuplicates I=$filename O=$dedupOutput M=$metricOutput


summaryOutput="$dir/summary/$base.summary.txt"
histogramOutput="$dir/histogram/$base.histogram.txt"

head -8 $metricOutput | tail -n+7 > $summaryOutput
tail -n+11 $metricOutput > $histogramOutput
################################################################################
module unload java/jdk/1.8.0_31  bio/picard/2.0.1
