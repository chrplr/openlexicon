# Time-stamp: <2019-03-30 12:11:42 christophe@pallier.org>

rm(list=ls())
a<-read.table("results.utf8.csv",as.is=T,encoding="utf-8",sep='\t',
              col.names=c('sujet','num','mot','rt','acc','typemot','ordre','ordresuite'))

pdf("pseudowords.pdf",onefile=T)
a$sujet = paste("subj",a$sujet,sep="")

# suppress the words
b = subset(a, typemot=="nonmot")
(n = nrow(b))

# number of subjects
length(unique(b$sujet))


# suppress trials with rt<300 (note: rt max=2003)
b = subset(b, rt >300)
nrow(b)
n-nrow(b)
(n-nrow(b))/n

# plot accuracy ~ rt per subject 
rtsuj = tapply(b$rt, b$sujet, mean)
accsuj = tapply(b$acc, b$sujet, mean)
sdsuj = tapply(b$rt, b$sujet, sd)

plot(rtsuj, accsuj, main="RT & accuracy (one point per subject)") 
rtcutoff <- 1100
acccutoff <- .75
abline(h=acccutoff)
abline(v=rtcutoff)

# select subjects according to cutoffs
goodsubjects = (rtsuj<rtcutoff) & (accsuj>acccutoff)
b = subset(b, goodsubjects[b$sujet]==TRUE)
length(unique(b$sujet))

nrow(b)

# number of trials per item (including errors)
ntrials = tapply(b$rt, b$mot, length)

# suppress trials with wrong responses
n = nrow(b)
b = subset(b, b$acc==1)
1-(nrow(b)/n) # proportion of rejected datapoints

nhits = tapply(b$rt, b$mot, length)

# suppress RT which are at more than  3stddev of the mean for each subject
rtsuj = tapply(b$rt, b$sujet, mean)
sdsuj = tapply(b$rt, b$sujet, sd)
keep = abs(b$rt - rtsuj[b$sujet]) < 3*sdsuj[b$sujet]
1-mean(keep) # proportion of excluded datapoints by 3SD rule


b$keep = keep
write.csv(b,"intermediate.pseudowords.csv",row.names=F)

b = subset(b, keep)

summary(tapply(b$rt, b$mot, mean))
summary(tapply(b$rt, b$sujet, mean))
summary(tapply(b$rt, b$mot, sd))
summary(tapply(b$rt, b$sujet, sd))

par(mfcol=c(2,2))
hist(tapply(b$rt, b$mot, mean),main="mean rt by items")
hist(tapply(b$rt, b$sujet, mean),main="mean rt by Ss")
hist(tapply(b$rt, b$mot, sd),main="stdev within items")
hist(tapply(b$rt, b$sujet, sd),main="stdev within Ss")


#b = subset(b, !(b$mot %in% setdiff(unique(b$mot),unique(b$mot[b$keep]))))
# suppress words with a single response
x <- tapply(b$rt, b$mot, length)
(singleton <- names(x[x==1]))
b <- b[! (b$mot %in% singleton),]

# compute again the rtz
rtsuj = tapply(b$rt, b$sujet, mean)
sdsuj = tapply(b$rt, b$sujet, sd)
b$rtz = (b$rt - rtsuj[b$sujet])/sdsuj[b$sujet]

nused <- tapply(b$rt, b$mot, length)
rt3sd <- tapply(b$rt, b$mot, mean)
sdrt <-  tapply(b$rt, b$mot, sd)
rtz <- tapply(b$rtz, b$mot, mean)
pairs(cbind(rt3sd,rtz))

words <- unique(b$mot)

dd <- data.frame(item = words,
                 ntrials = ntrials[words],
                 err = 1-(nhits[words]/ntrials[words]),
                 rt = rt3sd[words],
                 sd = sdrt[words],
                 rtz = rtz[words],
                 nused = nused[words])


summary(dd)
hist(dd$err)
hist(dd$rt)
hist(dd$rtz)
hist(dd$sd)


write.csv(dd,'FLP.pseudowords.csv',row.names=F)

graphics.off()

proc.time()
