args <- commandArgs(trailingOnly = TRUE)
# args: 1 : db name
# args: 2 : output name evens
# args: 2 : output name odds

library("DBI") # Requisite for RSQlite
library("RSQLite")
# connect to the sqlite file
dbfile<-args[1]
con = dbConnect(drv=SQLite(),  dbname=dbfile)
# Done once, to keep the trees with even Ind_per_sp
sts = dbGetQuery( con,'select SID from Species_Trees WHERE Ind_per_sp % 2 = 0')
write(sts[,1],ncolumns = 1,file=args[2])

sts = dbGetQuery( con,'select SID from Species_Trees WHERE Ind_per_sp % 2 = 1')
write(sts[,1],ncolumns = 1,file=args[3])
