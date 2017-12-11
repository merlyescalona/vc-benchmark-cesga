touch $HOME/data/status.org.txt
echo -e "PIPELINE_REPLICATE\t01\t02\t03\t04\t05\t06\t07\t08\t09\t10" # > $HOME/data/status.org.txt
for item in $(seq 1 25); do
    simphyReplicateID=$item
    pipelinesName="ssp"
    replicatesNumDigits=5
    replicateID="$(printf "%0${replicatesNumDigits}g" $simphyReplicateID)"
    ngsphyReplicatePath="$HOME/data/NGSphy_${pipelinesName}.${replicateID}"
    replicates=(01 02 03 04 05 06 07 08 09 10)
    numInds=()
    val=0
    for rep in ${replicates[*]}; do
        # echo $ngsphyReplicatePath/PE150DFLT/$rep
        if [[ -d $ngsphyReplicatePath/PE150DFLT/$rep ]]; then
            val=$(ls -l $ngsphyReplicatePath/PE150DFLT/$rep| grep R1 | wc -l)
        else
            val=0
        fi
        numInds+="\t$val"
    done
    echo -e "${pipelinesName}.${replicateID}${numInds[*]}"  #>> $HOME/data/status.org.txt
    echo -e "${pipelinesName}.${replicateID}${numInds[*]}"  >> $HOME/data/status.org.txt
done


<<RCOMMANDS
inds=read.table("numinds.rep.txt", header=T)
status=read.table("status.org.txt",header=T)
repALL=inds[,1]
inds=inds[,2:11]
status=status[,2:11]
rownames(inds)=repALL
rownames(status)=repALL
inds-status
apply(inds-status, 1,sum)
ssp.00001 ssp.00002 ssp.00003 ssp.00004 ssp.00005 ssp.00006 ssp.00007 ssp.00008
        0       -54         0         0        24        81        25        17
ssp.00009 ssp.00010 ssp.00011 ssp.00012 ssp.00013 ssp.00014 ssp.00015 ssp.00016
       22       192       137        51        88        43         0        42
ssp.00017 ssp.00018 ssp.00019 ssp.00020 ssp.00021 ssp.00022 ssp.00023 ssp.00024
       74        38        59       183        50        43       145         0
ssp.00025
       54

RCOMMANDS

################################################################################
# Generate file with number of ST replicates per SIMPHY replicate
################################################################################
echo -e "SIMPHY_REPLICATE\tSTs_REPLICATES\tREPLICATES_ID(NUM_LOCI)" > $HOME/src/vc-benchmark-cesga/info/num.replicates.txt
for item in $(seq 1 25); do
    simphyReplicateID=$item
    pipelinesName="ssp"
    replicatesNumDigits=5
    replicateID="$(printf "%0${replicatesNumDigits}g" $simphyReplicateID)"
    numReplicates=$(cat "$HOME/src/vc-benchmark-cesga/files/${pipelinesName}.${replicateID}.indelible.folders.txt" | wc -l)
    replicates=($(ls $HOME/data/NGSphy_${pipelinesName}.${replicateID}/reads))
    locPerReplicate=()
    for item in ${replicates[*]}; do
        locPerReplicate+=" $(ls $HOME/data/${pipelinesName}.${replicateID}/$item/*TRUE.fasta | wc -l)"
    done
    totalNum=${#replicates[*]}
    locPerReplicate=($locPerReplicate)
    let totalNum=totalNum-1
    values=()
    for index in $(seq 0 $totalNum);do
        values+=("${replicates[index]}(${locPerReplicate[index]})")
    done
    echo -e "${pipelinesName}.${replicateID}\t$numReplicates\t${values[*]}" >> $HOME/src/vc-benchmark-cesga/info/num.replicates.txt
done

################################################################################
# Generate file with INFORMATION about sequence size of the loci
################################################################################

for item in $(seq 2 25); do
    simphyReplicateID=$item
    pipelinesName="ssp"
    replicatesNumDigits=5
    replicateID="$(printf "%0${replicatesNumDigits}g" $simphyReplicateID)"
    ngsphyReplicatePath="$HOME/data/NGSphy_${pipelinesName}.${replicateID}"

    sizes=()
    val=0
    replicates=(01 02 03 04 05 06 07 08 09 10)
    for rep in ${replicates[*]}; do
        if [[ -d $ngsphyReplicatePath/PE150DFLT/$rep ]]; then
            val=$(cat $HOME/data/${pipelinesName}.${replicateID}/${rep}/control.txt | grep PARTITION  | awk '{print $5}' | tr "]" " " | sort | uniq)
        else
            val=0
        fi
        sizes+="\t$val"
    done
    echo -e "${pipelinesName}.${replicateID}\t $sizes"
done
