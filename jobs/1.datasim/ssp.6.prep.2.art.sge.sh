#!/bin/bash
#$ -v pipelinesName=ssp
#$ -wd /home/merly/data
#$ -o /home/merly/output/art.6.o
#$ -e /home/merly/error/art.6.e
#$ -N prep2art

simphyReplicateID=$SGE_TASK_ID
pipelinesName="ssp"
replicatesNumDigits=5
replicateID="$(printf "%0${replicatesNumDigits}g" $simphyReplicateID)"
# ngsphyReplicatePath="$LUSTRE/data/ngsphy.data/NGSphy_${pipelinesName}.${replicateID}"
ngsphyReplicatePath="$HOME/data/NGSphy_${pipelinesName}.${replicateID}"
# This is to remove the profiles leaving PE150
triploidARTSE150=$ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.triploid.HS25.SE.150.sh
triploidARTPE150=$ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.triploid.HS25.PE.150.sh
triploidARTSE250=$ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.triploid.MSv3.SE.250.sh
triploidARTPE250=$ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.triploid.MSv3.PE.250.sh
# This is to remove the profiles and the paired end
cat $ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.sh | sed 's/\/mnt\/lustre\/scratch\/home\/uvi\/be\/mef\/data\/ngsphy.data/\/home\/merly\/data/g' | sed 's/--out \/home\/merly\/data\/NGSphy_'"${pipelinesName}"'.'"${replicateID}"'\/reads/--out \/home\/merly\/data\/NGSphy_'"${pipelinesName}"'.'"${replicateID}"'\/reads_run_PE_150_DFLT/g' > $triploidARTPE150
cat $ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.sh | sed 's/\/mnt\/lustre\/scratch\/home\/uvi\/be\/mef\/data\/ngsphy.data/\/home\/merly\/data/g' | sed 's/--out \/home\/merly\/data\/NGSphy_'"${pipelinesName}"'.'"${replicateID}"'\/reads/--out \/home\/merly\/data\/NGSphy_'"${pipelinesName}"'.'"${replicateID}"'\/reads_run_SE_150_DFLT/g' | sed 's/ -p / /g' >  $triploidARTSE150
cat $ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.sh | sed 's/\/mnt\/lustre\/scratch\/home\/uvi\/be\/mef\/data\/ngsphy.data/\/home\/merly\/data/g' | sed 's/--out \/home\/merly\/data\/NGSphy_'"${pipelinesName}"'.'"${replicateID}"'\/reads/--out \/home\/merly\/data\/NGSphy_'"${pipelinesName}"'.'"${replicateID}"'\/reads_run_PE_250_DFLT/g' | sed 's/ -ss HS25/ -ss MSv3/g' | sed 's/-l 150/-l 250/g' | sed 's/-m 215 -s 50/-m 375 -s 100/g' > $triploidARTPE250
cat $ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.sh | sed 's/\/mnt\/lustre\/scratch\/home\/uvi\/be\/mef\/data\/ngsphy.data/\/home\/merly\/data/g' | sed 's/--out \/home\/merly\/data\/NGSphy_'"${pipelinesName}"'.'"${replicateID}"'\/reads/--out \/home\/merly\/data\/NGSphy_'"${pipelinesName}"'.'"${replicateID}"'\/reads_run_SE_250_DFLT/g' | sed 's/ -ss HS25/ -ss MSv3/g' | sed 's/-l 150/-l 250/g' | sed 's/-m 215 -s 50/-m 375 -s 100/g' | sed 's/ -p / /g' >  $triploidARTSE250

split -l 5000 -d -a 5 $triploidARTSE150 $ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.HS25.SE.150.art.commands.
split -l 5000 -d -a 5 $triploidARTPE150 $ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.HS25.PE.150.art.commands.
split -l 5000 -d -a 5 $triploidARTSE250 $ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.MSv3.SE.250.art.commands.
split -l 5000 -d -a 5 $triploidARTPE250 $ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.MSv3.PE.250.art.commands.
for file in $(ls $ngsphyReplicatePath/scripts/*.art.commands*); do    mv $file "$file.sh"; done

################################################################################
# Generate folder structure for all the possible read scenarios
################################################################################
replicates=($(ls $ngsphyReplicatePath/reads))
for item in ${replicates[*]}; do
    numLoc=$(ls $ngsphyReplicatePath/reads/$item| wc -l);
    numDigits=${#numLoc}
    for loc in $(seq 1 $numLoc); do
        echo "$item/$loc"
        mkdir -p $ngsphyReplicatePath/reads_run_PE_150_DFLT/$item/$(printf "%0${numDigits}g" $loc);
        mkdir -p $ngsphyReplicatePath/reads_run_SE_150_DFLT/$item/$(printf "%0${numDigits}g" $loc);
        mkdir -p $ngsphyReplicatePath/reads_run_SE_250_DFLT/$item/$(printf "%0${numDigits}g" $loc);
        mkdir -p $ngsphyReplicatePath/reads_run_PE_250_DFLT/$item/$(printf "%0${numDigits}g" $loc);
    done
done
