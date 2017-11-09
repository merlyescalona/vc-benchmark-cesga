touch$HOME/data/status.org.txt
echo -e "PIPELINE_REPLICATE\t01\t02\t03\t04\t05\t06\t07\t08\t09\t10" > $HOME/data/status.org.txt
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
    echo -e "${pipelinesName}.${replicateID}${numInds[*]}" >> $HOME/data/status.org.txt
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
       0       -30         0         0        43        90        40        27
ssp.00009 ssp.00010 ssp.00011 ssp.00012 ssp.00013 ssp.00014 ssp.00015 ssp.00016
      42         0       159        64       105        51         5        55
ssp.00017 ssp.00018 ssp.00019 ssp.00020 ssp.00021 ssp.00022 ssp.00023 ssp.00024
      85        55        82       197        92        90       166         0
ssp.00025
      81
RCOMMANDS
