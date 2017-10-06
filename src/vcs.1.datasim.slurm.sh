################################################################################
# (c) 2015-2017 Merly Escalona <merlyescalona@uvigo.es>
# Phylogenomics Lab. University of Vigo.
#
# Description:
# ============
# Pipelines for data simulation for variant calling assesment
# Running @ft2.cesga.es
################################################################################
#!/bin/bash -l
################################################################################
# Folder paths
################################################################################
source $HOME/vc-benchmark-cesga/src/vcs.variables.sh
################################################################################
# 0. Folder structure
################################################################################
git clone https://merlyescalona@github.com/merlyescalona/vc-benchmark-cesga.git $HOME/vc-benchmark-cesga
mkdir $folderDATA  $folderOUTPUT  $folderERROR  $folderINFO
echo -e "PipelinesName\tStep\tRepetition\tJOBID\tStatus\tDescription" > $fileJOBS
################################################################################
# STEP 1. SimPhyvc
################################################################################
jobID=$(sbatch 2-10 $folderJOBS/vcs.1.simphy.sh | awk '{ print $4}')
echo "Job submitted: $jobID"
step=1; rep=1; status="[sent]"; description="Ran 8 folders"
echo -e "$pipelinesName\t${step}\t${rep}\t$jobID\t${status}\t${description}" >> $fileJOBS
################################################################################
# STEP 2. INDELible wrapper
################################################################################
# After the running of SimPhy, it is necessary to run the INDELIble_wrapper
# to obtain the control files for INDELible. Since, is not possible to
# run it for all the configurations, it is necessary to modify the name of the
# output files in order to keep track of every thing
################################################################################
# Previous to running the wrapper I had to set up the perl env.
<<MODULE_INSTALL_PERL
module load gcc/6.3.0  perl/5.24.0  gsl/2.3 loaded
% cpan
cpan> o conf mbuildpl_arg '--install_base /home/uvi/be/mef/perl'
cpan> o conf commit
cpan> q
cpan install Math::GSL
MODULE_INSTALL_PERL
################################################################################
jobID=$(sbatch -a 1-11 $folderJOBS/vcs.2.wrapper.sh | awk '{ print $4}')
step=2; rep=1; status="[sent]"; description="Wrapper 10 folders"
echo -e "$pipelinesName\t${step}\t${rep}\t$jobID\t${status}\t${description}" >> $fileJOBS
################################################################################
# 3. INDELIBLE CALLS
################################################################################
source $HOME/vc-benchmark-cesga/src/vcs.variables.sh
find $LUSTRE/data/ -mindepth 2 -maxdepth 2 -type d | grep ssp | sort > $HOME/vc-benchmark-cesga/files/ssp.3.indelible.folders.txt

jobID=$(sbatch -a 11-50 $folderJOBS/vcs.3.indelible.array.sh | awk '{ print $4}')
step=3; rep=1; status="[sent]"; description="INDELIBLE single calls"
echo -e "$pipelinesName\t${step}\t${rep}\t$jobID\t${status}\t${description}" >> $fileJOBS
################################################################################
# 4. ngsphy
################################################################################
jobID=$(sbatch $folderJOBS/vcs.4.ngsphy.sh | awk '{ print $4}')
step=2; rep=1; status="[error]"; description="NGSPhy calls (10)"
echo -e "$pipelinesName\t${step}\t${rep}\t$jobID\t${status}\t${description}" >> $fileJOBS
################################################################################
for item in $(find $LUSTRE/data/ngsphy.data -maxdepth 1 -mindepth 1 -type d); do
    echo $item
    foldername=($(basename $item | tr "_" " "))
    echo ${foldername[1]}
    folder="$item/scripts/${foldername[1]}.sh"
    echo $folder
    while read -r line
    do
        myline=($(echo "$line"))
        echo ${myline[20]}
        numelems="${#myline[@]}"
        myitem="${myline[$numelems-1]}"
        newFolder=("$(dirname $myitem)")
        echo $newFolder
        mkdir -p $newFolder
    done < "$folder"
done
################################################################################
# 4.1 ART
################################################################################
jobID=$(sbatch -a 1-100 $folderJOBS/vcs.5.art.1.sh | awk '{ print $4}')
step=2; rep=1; status="[error]"; description="NGSPhy calls (10)"
echo -e "$pipelinesName\t${step}\t${rep}\t$jobID\t${status}\t${description}" >> $fileJOBS
################################################################################
# 5. Reference Loci Selection
################################################################################
echo -e "#! /bin/bash
#$ -m bea
#$ -M escalona10@gmail.com
#$ -o $outputFolder/$pipelinesName.5.o
#$ -e $outputFolder/$pipelinesName.5.e
#$ -N $pipelinesName.5

module load python/2.7.8
cd $WD/
python $lociReferenceSelection -ip $prefixLoci -op $prefixRef -sf $WD -o $WD/references/ -m 1
module unload python/2.7.8
" >  $scriptsFolder/$pipelinesName.5.sh

jobID=$(qsub -l num_proc=1,s_rt=0:10:00,s_vmem=2G,h_fsize=1G,arch=haswell $scriptsFolder/$pipelinesName.5.sh | awk '{ print $3}')
echo "$pipelinesName"".5    $jobID" >> $jobsSent
ls -Rl $WD > $filesFolder/$pipelinesName.5.files
echo "$pipelinesName"".5    $jobID" >> $usageFolder/$pipelinesName.5.usage
cat $outputFolder/$pipelinesName.5.o | grep "El consumo de memoria ha sido de" > $usageFolder/$pipelinesName.5.usage
cat $outputFolder/$pipelinesName.5.o | grep "El tiempo de ejecucion ha sido de (segundos)" >> $usageFolder/$pipelinesName.5.usage

################################################################################
# Step 5.1. Create file with information of the reference loci selected
################################################################################
for item in $(find $referencesFolder -name *.fasta); do
  head -1 $item >> $WD/${pipelinesName}.references.txt
done

################################################################################
# STEP 6. Diversity Statistics
################################################################################
# Creating an index file
/
sgeCounter=1
for line in $(cat $WD/$pipelinesName.evens); do
  st=$(printf "%0$numDigits""g" $line)
  for indexGT in $(seq 1 $nGTs); do
    gt=$(printf "%0$numDigitsGTs""g" $indexGT)
    echo -e "$sgeCounter\t$st\t$gt\t$WD/$st/${prefixLoci}_${gt}_TRUE.phy" >>  $scriptsFolder/$pipelinesName.diversity.re
    echo -e "$WD/$st/${prefix}_${gt}_TRUE.phy" >>  $scriptsFolder/$pipelinesName.diversity.files
    let sgeCounter=sgeCounter+1
  done
done
################################################################################
# Running diversity
counter=1
divFile="$scriptsFolder/$pipelinesName.diversity.files"
#divFile="mnt/phylolab/uvibemef/csSim0/report/scripts/csSim0.diversity.files"
totalFiles=$(wc -l $divFile |awk '{print $1}')
echo -e "#! /bin/bash
#$ -o $outputFolder/$pipelinesName.6.o
#$ -e $outputFolder/$pipelinesName.6.e
#$ -N $pipelinesName.6

cd $WD/1

" > $scriptsFolder/$pipelinesName.6.sh
for line in $(cat $divFile); do
  echo $counter/$totalFiles
  INPUTBASE=$(basename $line .phy)
  filename=$(basename $line)
  echo "diversity $filename &> $WD/report/stats/${INPUTBASE}.0.stats" >> $scriptsFolder/$pipelinesName.6.sh
  echo "diversity $filename -g &> $WD/report/stats/${INPUTBASE}.1.stats">> $scriptsFolder/$pipelinesName.6.sh
  echo "diversity $filename -g -m -p 2> $WD/report/stats/${INPUTBASE}.2.stats">> $scriptsFolder/$pipelinesName.6.sh
  echo "cat $WD/report/stats/${INPUTBASE}.2.stats | sed 's/\.0000/,/g' | sed 's/-/,-,/g' | sed 's/      ,//g'  | tail -n+15 >  $WD/report/stats/${INPUTBASE}.3.stats">> $scriptsFolder/$pipelinesName.6.sh
  let counter=counter+1
done

jobID=$(qsub -l num_proc=1,s_rt=0:30:00,s_vmem=2G,h_fsize=1G,arch=haswell $scriptsFolder/$pipelinesName.6.sh | awk '{ print $3}')
echo "$pipelinesName"".6    $jobID" >> $jobsSent
ls -Rl $WD > $filesFolder/$pipelinesName.6.files
echo "$pipelinesName"".6    $jobID" >> $usageFolder/$pipelinesName.6.usage
cat $outputFolder/$pipelinesName.6.o | grep "El consumo de memoria ha sido de" > $usageFolder/$pipelinesName.6.usage
cat $outputFolder/$pipelinesName.6.o | grep "El tiempo de ejecucion ha sido de (segundos)" >> $usageFolder/$pipelinesName.6.usage



################################################################################
# Parsing diversity
################################################################################
# Parsing both distance matrices file and output for summary
# Output file
tmp1="$WD/diversity.parsing.1.tmp"
tmp2="$WD/diversity.parsing.2.tmp"
for indexGT in $(seq 1 $nGTs); do
  gt=$(printf "%0$numDigitsGTs""g" $indexGT)
  elem=$(cat $WD/report/stats/${prefixLoci}_${gt}_TRUE.0.stats | grep "mean pairwise distance =" | awk -F"=" '{print $2}' )
  echo $elem
  echo $elem >>$tmp1
done
cat $outputFolder/$pipelinesName.6.o | grep ^data| paste -d "," - $tmp1 > $tmp2
diversitySummary="$WD/${pipelinesName}.diversity.summary"
echo "file,numTaxa,numSites,NumVarSites,NumInfSites,numMissSites,numGapSites,numAmbiguousSites,freqA,freqC,freqG,freqT,meanPairwiseDistancePerSite,meanPairwiseDistance" > $diversitySummary
cat $tmp2 >> $diversitySummary
rm $tmp1 $tmp2

# Distance matrices
outFolder="$WD/report/stats/csv"
inputFolder="$WD/report/stats"
mkdir $outFolder

echo -e "#! /bin/bash
#$ -m bea
#$ -M escalona10@gmail.com
#$ -o $outputFolder/$pipelinesName.6.1.o
#$ -e $outputFolder/$pipelinesName.6.1.e
#$ -N $pipelinesName.6.1

module load R/3.2.3
" > $scriptsFolder/$pipelinesName.6.1.sh
for item in $(seq 1 $nGTs); do
  gt=$(printf "%0$numDigitsGTs""g" $item)
  inputbase="${prefixLoci}_${gt}"
  echo $inputbase

  echo "Rscript --vanilla $HOME/src/me-phylolab-conussim/diversityMatrices/parseDiversityMatrices.R $inputFolder $inputbase $outFolder" >> $scriptsFolder/$pipelinesName.6.1.sh
done
echo "module unload R/3.2.3" >> $scriptsFolder/$pipelinesName.6.1.sh


jobID=$(qsub -l num_proc=1,s_rt=0:30:00,s_vmem=2G,h_fsize=1G,arch=haswell $scriptsFolder/$pipelinesName.6.1.sh | awk '{ print $3}')
echo "$pipelinesName"".6.1    $jobID" >> $jobsSent
ls -Rl $WD > $filesFolder/$pipelinesName.6.1.files
echo "$pipelinesName"".6.1    $jobID" >> $usageFolder/$pipelinesName.6.1.usage
cat $outputFolder/$pipelinesName.6.1.o | grep "El consumo de memoria ha sido de" > $usageFolder/$pipelinesName.6.1.usage
cat $outputFolder/$pipelinesName.6.1.o | grep "El tiempo de ejecucion ha sido de (segundos)" >> $usageFolder/$pipelinesName.6.1.usage

################################################################################
# STEP 7. NGS Simulation
################################################################################
for line in $(tail -n+2  $WD/$pipelinesName.mating); do
  array=(${line//,/ })
  # Have 5 elems
  st=${array[0]}
  gt=${array[1]}
  ind=${array[2]}
  echo "$st $gt $ind"
  inputFile="${pipelinesName}_${st}_${gt}_${prefix}_${ind}.fasta"
  echo "$WD/individuals/$st/$gt/$inputFile" >>  $scriptsFolder/$pipelinesName.7.art.files
done

SEEDFILE="$scriptsFolder/$pipelinesName.7.art.files"
for line in $(cat $WD/$pipelinesName.evens); do
  st=$(printf "%0$numDigits""g" $line)
  echo -e "#! /bin/bash
#$ -o $outputFolder/$pipelinesName.7.$st.o
#$ -e $outputFolder/$pipelinesName.7.$st.e
#$ -N $pipelinesName.7.$st

SEED=\$(awk \"NR==\$SGE_TASK_ID\" $SEEDFILE )
INPUTBASE=\$(basename \$SEED .fasta)

cd $readsFolder/
art_illumina -sam  -1 $profilePath/csNGSProfile_hiseq2500_1.txt -2 $profilePath/csNGSProfile_hiseq2500_2.txt -f 100 -l 150 -p  -m 250 -s 50 -rs $RANDOM -ss HS25 -i \$SEED -o \${INPUTBASE}_R

">   $scriptsFolder/$pipelinesName.7.art.$st.sh
done

totalArtJobs=$(wc -l $SEEDFILE | awk '{print $1}')
for line in $(cat $WD/$pipelinesName.evens); do
  st=$(printf "%0$numDigits""g" $line)
  echo "$st"
  jobID=$(qsub -l num_proc=1,s_rt=0:05:00,s_vmem=2G,h_fsize=1G,arch=haswell -t 1-$totalArtJobs $scriptsFolder/$pipelinesName.7.art.$st.sh | awk '{ print $3}')
done


<<ITERATEJOBS
for i in $(seq 21001 1000 50000); do
  echo "Sending jobs from $i to $temp"
  qsub -l num_proc=1,s_rt=0:05:00,s_vmem=2G,h_fsize=1G,arch=haswell -t $i-$temp $scriptsFolder/$pipelinesName.7.art.1.sh
  let temp=temp+1000
  sleep 600
done
ITERATEJOBS
################################################################################
# STEP 8. Reorganize reads accroding to output file format and ST and GT.
################################################################################

# Just works for this case, will need to rearrange the folders.
# Need to think how would be the best way
# probably reads/ST/fq,aln,sam

for line in $(tail -n+2  $WD/$pipelinesName.mating); do
  array=(${line//,/ })
  # Have 5 elems
  st=${array[0]}
  gt=${array[1]}
  ind=${array[2]}
  echo "$st/$gt"
  mkdir -p $fqReadsFolder/$st/$gt/ $alnReadsFolder/$st/$gt/ $samReadsFolder/$st/$gt/
done

mv $readsFolder/*.fq $readsFolder/fq
mv $readsFolder/*.sam $readsFolder/sam
mv $readsFolder/*.aln $readsFolder/aln
for line in $(cat $WD/$pipelinesName.evens); do
  st=$(printf "%0$numDigits""g" $line)
  for item in $(seq 1 $nGTs); do
    gt=$(printf "%0$numDigitsGTs""g" $item)
    echo -e "\r$st/$gt"
    filePrefix="${pipelinesName}_${st}_${gt}_data_"
    mv "$fqReadsFolder/$filePrefix"* $fqReadsFolder/$st/$gt/
    mv "$samReadsFolder/$filePrefix"* $samReadsFolder/$st/$gt/
    mv "$alnReadsFolder/$filePrefix"* $alnReadsFolder/$st/$gt/
  done
done

################################################################################
# STEP 9. FASTQC
################################################################################

fqFiles="$fqReadsFolder/${pipelinesName}.allfiles.fastq"
find $fqReadsFolder -name *.fq | xargs cat > $fqFiles

st=1
echo -e "#! /bin/bash
#$ -o $outputFolder/$pipelinesName.8.$st.o
#$ -e $outputFolder/$pipelinesName.8.$st.e
#$ -N $pipelinesName.8.$st

INPUTBASE=$(basename $fqFiles .fastq)

cd $qcFolder/\$INPUTBASE
$fastqc $fqFiles -o $qcFolder/$INPUTBASE

">   $scriptsFolder/$pipelinesName.8.$st.sh
qsub -l num_proc=1,s_rt=0:05:00,s_vmem=2G,h_fsize=1G,arch=haswell $scriptsFolder/$pipelinesName.8.$st.sh
