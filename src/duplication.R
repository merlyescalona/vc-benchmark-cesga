library(ggplot2)
##  cat duplicates.summary.txt | sed 's/?/NA/g' >duplicates.txt
##  cat duplicates.txt | grep -v sorted  > duplicates.2.txt
duplicates=read.table("/home/merly/git/ngsphy/test/ngsphy-case1/files/duplicates.2.txt",
    header=T, fill=T,colClasses= c ("character", rep("numeric",2), "character", rep("numeric",9)))


duplicates=duplicates[duplicates$INDIVIDUAL_ID!="sorted",]
duplicates=duplicates[duplicates$PERCENT_DUPLICATION!="?",]

duplicates=duplicates[!is.na(duplicates$PERCENT_DUPLICATION), ]
ggplot(duplicates, aes(x=INDIVIDUAL_ID, y=PERCENT_DUPLICATION, colour=COVERAGE)) +
    geom_point()
