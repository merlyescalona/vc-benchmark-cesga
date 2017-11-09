# Parameterization of the LN of the speciation rate.
m=-13.58; s=1.85

q01=qlnorm(0.1, meanlog=m, sdlog=s) # proper limits for our distribution, we are keeping the 90% of the possible values
q09=qlnorm(0.9, meanlog=m, sdlog=s)  # proper limits for our distribution, we are keeping the 90% of the possible values

# this is the plot of the distribution
probs=seq(0,1,length.out=1000)
q=qlnorm(probs,meanlog=m,sdlog=s)
plot(probs,log10(q), main=paste0("LN:",m,",",s), xlab="Prob", ylab="log10(q)",axes=F) # | q0.1: ",q01, "    q0.9: ",q09 ))
axis(2); axis(1, at=seq(0,1,by=0.1), labels=seq(0,1,by=0.1), las=2)


meanLeaves=mean(c(4,20)) # these are the old values (remember, haploid individual for simphy)
E_Height_200Ky_Lima=log(meanLeaves)/200000 # same values as before, i was generating wrong years, but now I'm doing the correct ones
E_Height_20My_Lima=log(meanLeaves)/20000000  # same values as before, i was generating wrong years, but now I'm doing the correct ones
pEH20a=plnorm(E_Height_20My_Lima, mean=m, sdlog=s)
pEH200a=plnorm(E_Height_200Ky_Lima, mean=m, sdlog=s)
points(c(pEH20a,pEH200a),log10(c(E_Height_20My_Lima,E_Height_200Ky_Lima)), col="blue", pch=19)

meanLeaves=mean(c(4,12)) # these are our new number of leaves (remember, haploid individual for simphy)
E_Height_200Ky_Limb=log(meanLeaves)/200000
E_Height_20My_Limb=log(meanLeaves)/20000000
pEH20b=plnorm(E_Height_20My_Limb, mean=m, sdlog=s)
pEH200b=plnorm(E_Height_200Ky_Limb, mean=m, sdlog=s)
points(c(pEH20b,pEH200b),log10(c(E_Height_20My_Limb,E_Height_200Ky_Limb)), col="red", pch=19)



qs=c(q01,q09)
opta=c(E_Height_20My_Lima,E_Height_200Ky_Lima)
optb=c(E_Height_20My_Limb,E_Height_200Ky_Limb)
c(opta[1] >qs[1], opta[2] <qs[2])
c(optb[1] >qs[1],optb[2] <qs[2])
