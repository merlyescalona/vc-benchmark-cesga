#!/bin/bash
#SBATCH -n 1
#SBATCH -t 10:00:00
#
#SBATCH --job-name=prep2art
#SBATCH --output=/mnt/lustre/scratch/home/uvi/be/mef/output/ssp.6.%a.o
#SBATCH --error=/mnt/lustre/scratch/home/uvi/be/mef/error/ssp.6.%a.e
#SBATCH --workdir=/mnt/lustre/scratch/home/uvi/be/mef/data/
#
#SBATCH --mail-type=begin,end
#SBATCH --mail-user=escalona10@gmail.com
#SBATCH --partition=shared,gpu-shared-k2
#SBATCH --qos=shared

simphyReplicateID=$SLURM_ARRAY_TASK_ID
pipelinesName="ssp"
replicatesNumDigits=5
replicateID="$(printf "%0${replicatesNumDigits}g" $simphyReplicateID)"
# ngsphyReplicatePath="$LUSTRE/data/ngsphy.data/NGSphy_${pipelinesName}.${replicateID}"
ngsphyReplicatePath="$LUSTRE/data/ngsphy.data/NGSphy_${pipelinesName}.${replicateID}"
# This is to remove the profiles leaving PE150
triploidARTSE150=$ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.HS25.SE.150.sh
triploidARTPE150=$ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.HS25.PE.150.sh
triploidARTSE250=$ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.MSv3.SE.250.sh
triploidARTPE250=$ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.MSv3.PE.250.sh
# This is to remove the profiles and the paired end
cat $ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.sh | sed 's/--out \/mnt\/lustre\/scratch\/home\/uvi\/be\/mef\/data\/ngsphy.data\/NGSphy_'"${pipelinesName}"'.'"${replicateID}"'\/reads/--out \/mnt\/lustre\/scratch\/home\/uvi\/be\/mef\/data\/ngsphy.data\/NGSphy_'"${pipelinesName}"'.'"${replicateID}"'\/reads_run_PE_150_DFLT/g' > $triploidARTPE150
cat $ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.sh | sed 's/--out \/mnt\/lustre\/scratch\/home\/uvi\/be\/mef\/data\/ngsphy.data\/NGSphy_'"${pipelinesName}"'.'"${replicateID}"'\/reads/--out \/mnt\/lustre\/scratch\/home\/uvi\/be\/mef\/data\/ngsphy.data\/NGSphy_'"${pipelinesName}"'.'"${replicateID}"'\/reads_run_SE_150_DFLT/g' | sed 's/ -p / /g' >  $triploidARTSE150
cat $ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.sh | sed 's/--out \/mnt\/lustre\/scratch\/home\/uvi\/be\/mef\/data\/ngsphy.data\/NGSphy_'"${pipelinesName}"'.'"${replicateID}"'\/reads/--out \/mnt\/lustre\/scratch\/home\/uvi\/be\/mef\/data\/ngsphy.data\/NGSphy_'"${pipelinesName}"'.'"${replicateID}"'\/reads_run_PE_250_DFLT/g' | sed 's/ -ss HS25/ -ss MSv3/g' | sed 's/-l 150/-l 250/g' | sed 's/-m 215 -s 50/-m 375 -s 100/g' > $triploidARTPE250
cat $ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.sh | sed 's/--out \/mnt\/lustre\/scratch\/home\/uvi\/be\/mef\/data\/ngsphy.data\/NGSphy_'"${pipelinesName}"'.'"${replicateID}"'\/reads/--out \/mnt\/lustre\/scratch\/home\/uvi\/be\/mef\/data\/ngsphy.data\/NGSphy_'"${pipelinesName}"'.'"${replicateID}"'\/reads_run_SE_250_DFLT/g' | sed 's/ -ss HS25/ -ss MSv3/g' | sed 's/-l 150/-l 250/g' | sed 's/-m 215 -s 50/-m 375 -s 100/g' | sed 's/ -p / /g' >  $triploidARTSE250

split -l 10000 -d -a 2 $triploidARTSE150 $ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.HS25.SE.150.art.commands.
split -l 10000 -d -a 2 $triploidARTPE150 $ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.HS25.PE.150.art.commands.
split -l 10000 -d -a 2 $triploidARTSE250 $ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.MSv3.SE.250.art.commands.
split -l 10000 -d -a 2 $triploidARTPE250 $ngsphyReplicatePath/scripts/${pipelinesName}.${replicateID}.MSv3.PE.250.art.commands.
for file in $(ls $ngsphyReplicatePath/scripts/*.art.commands*); do    mv $file "$file.sh"; done

################################################################################
# Generate folder structure for all the possible read scenarios
################################################################################
replicates=($(ls $ngsphyReplicatePath/reads))
for item in ${replicates[*]}; do
    numLoc=$(ls $ngsphyReplicatePath/reads/$item| wc -l);
    for loc in $(seq 1 $numLoc); do
        echo "$item/$loc"
        mkdir -p $ngsphyReplicatePath/reads_run_PE_150_DFLT/$item/$(printf "%04g" $loc);
        mkdir -p $ngsphyReplicatePath/reads_run_SE_150_DFLT/$item/$(printf "%04g" $loc);
        mkdir -p $ngsphyReplicatePath/reads_run_SE_250_DFLT/$item/$(printf "%04g" $loc);
        mkdir -p $ngsphyReplicatePath/reads_run_PE_250_DFLT/$item/$(printf "%04g" $loc);
    done
done
