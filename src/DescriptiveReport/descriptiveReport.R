################################################################################
# Sean Murphy (http://stackoverflow.com/questions/9341635/check-for-installed-packages-before-running-install-packages)
checkPackages<-function(packages){
  if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
    install.packages(setdiff(packages, rownames(installed.packages())), dependencies = T,repos='http://cran.us.r-project.org')
  }
}
# -----------------------------------------------------------------------------
loadPackageList<-function(packages,verbose=F){
  if(verbose) print("Checking installed packages...")
  # checkPackages(packages)
  # Pratik Patil (http://stackoverflow.com/questions/9341635/check-for-installed-packages-before-running-install-packages)
  # Packages dependencies
  if(verbose) print("Loading packages...")
  for(pkg in packages ){
    if(verbose) print(paste("Loading:",pkg))
    suppressMessages(library(pkg,character.only=TRUE,quietly=TRUE))
  }
}
################################################################################
packages=c("phangorn","ape","Biostrings","devtools","phyloch","shiny","plyr","geiger","apTreeshape","DBI","RSQLite","ggplot2","gplots","RColorBrewer","knitr","VennDiagram","gridExtra","futile.logger","DT","fields","stringr","png")
loadPackageList(packages)
#install_github("fmichonneau/phyloch")
################################################################################
# NEed to generate a file with information ST   GT      FASTA PATH FILE
library(data.table)
filename="test.files.txt"
indexfiles=fread(filename)
colnames(indexfiles)<-c("repid","locid","seqsize","file")
newdata=data.frame(repid=indexfiles$repid,
    locid=indexfiles$locid,
    seqsize=rep(0, nrow(indexfiles)),
    infsites=rep(0, nrow(indexfiles)),
    varsites=rep(0, nrow(indexfiles)),
    freqA=rep(0, nrow(indexfiles)),
    freqC=rep(0, nrow(indexfiles)),
    freqG=rep(0, nrow(indexfiles)),
    freqT=rep(0, nrow(indexfiles)),
    mpwd=rep(0, nrow(indexfiles))
)

for(index in 1:nrow(indexfiles)){
    entry=indexfiles[index,]
    print(entry$file)
    newdata[index,]$seqsize=entry$seqsize
    newdata[index,]$repid=entry$repid
    newdata[index,]$locid=entry$locid

    dna=read.dna(entry$file, format="fasta",as.character=T)
    for (indexRow in 1:nrow(dna)){
      elem=paste0(dna[indexRow,],collapse = "")
      baseComposition=rbind(baseComposition,oligonucleotideFrequency(DNAString(elem), width = 1))
    }
    bc=apply(baseComposition,2,mean)/entry$seqsize
    bc=data.frame(t(bc))
    newdata[index,]$freqA=bc$A
    newdata[index,]$freqC=bc$C
    newdata[index,]$freqG=bc$G
    newdata[index,]$freqT=bc$T
    dna=read.dna(entry$file, format="fasta")
    pairwiseDistMatrix=dist.p(as.phyDat(dna))
    m=as.matrix(pairwiseDistMatrix)
    newdata[index,]$mpwd=mean(as.numeric(m[upper.tri(m)]))
    newdata[index,]$varsites=length(seg.sites(dna))
    newdata[index,]$infsites=pis(dna)
}



################################################################################
# connect to the sqlite file
dbfile<-paste0(simphyPath,"/",pipelinesName,".db")
con = dbConnect(drv=SQLite(),  dbname=dbfile)
# Queries
replicates = dbGetQuery( con,'select SID from `Species_Trees` where Ind_per_sp %2 == 0' )$SID
numLociPerReplicate=dbGetQuery( con,'select N_loci from `Species_Trees`')
dbDisconnect(con)
colors=brewer.pal(5,"Paired")
stReplicates=1

pipelinesName="testwsimphy"
simphyPath=paste0("/home/merly/git/test-ngsphy/test4/", pipelinesName)
repID=1
locID=1
prefix="data"
filename=paste0(simphyPath,"/",repID,"/", prefix,"_", sprintf("%01g",locID),"_TRUE.fasta")
dna=read.dna(filename, format="fasta",as.character=T)
pairwiseDistMatrix=dist.p(as.phyDat(dna))
attributesPWDM=attributes(pairwiseDistMatrix)
m=as.matrix(pairwiseDistMatrix)
m[upper.tri(m)]=0
lmat = rbind(c(3,2),c(1,4))
lwid = c(5,2)
lhei = c(1,6)
heatmap.2(m, symm =T, dendrogram="none", Rowv=FALSE,
          Colv=FALSE,lmat=lmat,lwid=lwid,lhei=lhei,
          denscol="black",
          trace ="none", key.title="Locus1",
          key.xlab = "Pairwise Distance", key.ylab = "Frequency")
segsites=seg.sites(dna)
a=attributes(dna)

baseComposition=c()
dna=read.dna(filename, format="fasta",as.character=T)
for (indexRow in 1:nrow(dna)){
  elem=paste0(dna[indexRow,],collapse = "")
  baseComposition=rbind(baseComposition,oligonucleotideFrequency(DNAString(elem), width = 1))
}
lenSize=143
apply(baseComposition,2,mean)/lenSize

dna=read.dna(filename, format="fasta")
pis(dna)
seg.sites(dna)
