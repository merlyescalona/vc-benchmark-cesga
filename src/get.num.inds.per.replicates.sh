touch $HOME/data/numinds.rep.txt
echo -e "PIPELINE_REPLICATE\t01\t02\t03\t04\t05\t06\t07\t08\t09\t10" > $HOME/data/numinds.rep.txt
for item in $(seq 1 25); do
    simphyReplicateID=$item #$item
    pipelinesName="ssp"
    replicatesNumDigits=5
    replicateID="$(printf "%0${replicatesNumDigits}g" $simphyReplicateID)"
    ngsphyReplicatePath="$HOME/data/NGSphy_${pipelinesName}.${replicateID}"
    replicates=(01 02 03 04 05 06 07 08 09 10)
    numInds=()
    val=0
    for rep in ${replicates[*]}; do
        if [[ -f $ngsphyReplicatePath/ind_labels/${pipelinesName}.${replicateID}.${rep}.individuals.csv ]]; then
            val=$(cat $ngsphyReplicatePath/ind_labels/${pipelinesName}.${replicateID}.${rep}.individuals.csv | tail -n+2 | wc -l)
        else
            val=0
        fi
        numInds+="\t$val"
    done
    echo -e "${pipelinesName}.${replicateID}${numInds[*]}"
done


<<RCHECKSTATUS
R
inds=read.table("numinds.rep.txt", header=T)
status=read.table("status.org.txt",header=T)
rownamesAll=inds[,1]
inds=inds[,2:11]
status=status[,2:11]
rownames(inds)=rownamesAll
rownames(status)=rownamesAll
comp=inds==status
comp
compNum=inds-status

X01 X02 X03 X04 X05 X06 X07 X08 X09 X10
ssp.00005   0   0  31  22  27   0   0   0   0  23
ssp.00006   9   0   0  28   0  53  28   0  31  34
ssp.00007   0  18  33   0   0  48   0   0   0   0
ssp.00008  16  20  29   0   0   0   0   0   0  17
ssp.00009   0   6   0   0   0  18   0  49   3   0
ssp.00011   0  37   0  28  19   0  55  36  17   0
ssp.00012  12  34  57  31  15   5  26   0   0   0
ssp.00013   0  53   0   0   0   0  35  11   0  47
ssp.00014  16  12  29  32   0  34  33   0  28   4
ssp.00015   0   0   0  18   0   0   0   0  38  38
ssp.00016  28   0  34   0   0  49  36  37   0   0
ssp.00017   0  26   8   0  26  36  43   0  34  34
ssp.00018  13   0  46   0   0  21  31   0   0  31
ssp.00019  16  19  55  21   0   0  21   0   0  33
ssp.00020  67   0  23   0  73  56   0  19   0   0
ssp.00021  45  23  73   0  41   0  37  25  55  33
ssp.00022   0   0  28  11  25   0  21  67  31   0
ssp.00023  55   0   0   0  31  34  34  45   0  16
ssp.00024   0   0   0   0   0   0   0   0   0  18 < 1
ssp.00025  67   0  25   0  73   0   0   0  37  31


RCHECKSTATUS
