module purge
module load java/jdk/1.8.0_31  bio/picard/2.0.1
profiles=("PE150OWN" "SE150DFLT" "PE150DFLT" "SE250DFLT"  "PE250DFLT" )
summaryFile="$HOME/data/mappings/duplicates.summary.txt"
for simphyReplicateID in $(seq 1); do
    pipelinesName="ssp"
    replicatesNumDigits=5
    replicateID="$(printf "%0${replicatesNumDigits}g" $simphyReplicateID)"
    ngsphyReplicatePath="$HOME/data/NGSphy_${pipelinesName}.${replicateID}"
    replicates=($(ls $ngsphyReplicatePath/reads))
    for profile in ${profiles[*]}; do
        if [[ $profile == *"PE150OWN"* ]]; then
            replicates=("02" "04" "10")
        fi
        for replicateST in ${replicates[*]}; do
            for reference in "outgroup" "rndingroup"; do
                echo "Getting into replicate: ${replicateST} with profile ${profile} from NGSphy_replicate: $ngsphyReplicatePath"
                for bamFile in $(find $HOME/data/mappings/${pipelinesName}.${replicateID}/$profile/$replicateST/sorted/$reference/ -name "*.bam" -type f | tail -n+2); do
                    echo $bamFile
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
                    mkdir -p "$dir/metrics/$reference/"
                    metricOutput="$dir/metrics/$reference/$base.metrics.txt"
                    dedupOutput="$dir/dedup/$reference/$base.dedup.bam"
                    echo "picard MarkDuplicates I=$bamFile O=$dedupOutput M=$metricOutput"
                    picard MarkDuplicates INPUT=$bamFile OUTPUT=$dedupOutput METRICS_FILE=$metricOutput

                    header=$(head -7 $metricOutput | tail -n+7)
                    summaryInfo=$(head -8 $metricOutput | tail -n+8)

                    if [[ ! -f $summaryFile ]]; then
                        echo -e "SIMPHY_REPLICATE\tREPLICATE_ST\tINDIVIDUAL_ID\tPROFILE\t$header" > $summaryFile
                    fi
                    echo -e "${fileSplit[1]}\t${fileSplit[2]}\t${replicate_file_ST}\t${profile}\t${summaryInfo}">> $summaryFile

                    histogramOutput="$dir/histogram/$reference/$base.histogram.txt"

                    tail -n+11 $metricOutput > $histogramOutput
                done
            done
        done
    done
done
