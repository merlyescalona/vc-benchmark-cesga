#!/bin/bash
#SBATCH -n 1
#SBATCH -c 10
#SBATCH -t 12:00:00
#
#SBATCH --job-name=indelible
#SBATCH --output=/mnt/lustre/scratch/home/uvi/be/mef/output/vcs.3.%a.o
#SBATCH --error=/mnt/lustre/scratch/home/uvi/be/mef/error/vcs.3.%a.e
#SBATCH --workdir=/mnt/lustre/scratch/home/uvi/be/mef/data/
#
#SBATCH --mail-type=end
#SBATCH --mail-user=escalona10@gmail.com
#SBATCH --partition=shared
#SBATCH --qos=shared

################################################################################
# Parallel indelible calls (cd to folder + indelible)
################################################################################
echo -e "$(date)\nDefinition of the function"
parallel_indelible_calls() {
    echo "(func) SimPhy folder"
    echo "(func) cd $1"
    cd $1
    echo "(func) $(pwd); indelible"
    indelible
}
export -f parallel_indelible_calls
################################################################################
pipelinesName="vcs"
simphyFOLDER=${pipelinesName}.$(printf "%05g" ${SLURM_ARRAY_TASK_ID})
nReplicates=$(find $LUSTRE/data/${simphyFOLDER} -type d | wc -l)
let nReplicates=nReplicates-1
echo $(hostname),$pipelinesName,${SLURM_ARRAY_TASK_ID}, $nReplicates, $simphyFOLDER
################################################################################
module purge
module load gcc/5.3.0 indelible/1.03 parallel
################################################################################
# Parallel logs
echo "Cheking parallel log folder"
if [ ! -d $LUSTRE/data/${simphyFOLDER}/logs ];then
    mkdir $LUSTRE/data/${simphyFOLDER}/logs;
fi
#############################################################r###################
# Getting args for parallel - > folder id of the folder
echo "Getting args for parallel"
if [ ! -f $LUSTRE/data/${simphyFOLDER}/logs/args_list.txt ]; then
    for item in $(seq 1 $nReplicates); do
        locusID=$(printf "%02g" $item)
        echo -e "$LUSTRE/data/${simphyFOLDER}/${locusID}\t${locusID}" >> $LUSTRE/data/${simphyFOLDER}/logs/args_list.txt
        touch $LUSTRE/data/${simphyFOLDER}/logs/parallel.${locusID}.log
    done
fi
################################################################################
# SLURM MEMORY MANAGEMENT
################################################################################
corespertask=${SLURM_CPUS_PER_TASK=10}
SRUN="srun -N1 -n1 --mem=$(( $MEMPERCORE*$corespertask )) -c $corespertask --cpu_bind=none"
################################################################################
parallelCOMMAND="parallel --delay .2 -j $nReplicates --joblog $LUSTRE/data/${simphyFOLDER}/logs/runtask.log --resume-failed "
echo "$parallelCOMMAND --colsep "\t" "parallel_indelible_calls {1} > $LUSTRE/data/${simphyFOLDER}/logs/parallel.{2}.log" < $LUSTRE/data/${simphyFOLDER}/logs/args_list.txt"
$parallelCOMMAND --colsep "\t" "$SRUN parallel_indelible_calls {1} > $LUSTRE/data/${simphyFOLDER}/logs/parallel.{2}.log" < $LUSTRE/data/${simphyFOLDER}/logs/args_list.txt

################################################################################
module unload gcc/5.3.0 indelible/1.03 parallel
