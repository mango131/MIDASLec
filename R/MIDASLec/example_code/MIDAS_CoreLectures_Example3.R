# Chapter 3. GARCH-MIDAS
setwd('/Users/striaukas/Documents/GitHub/core_lectures_r_code/garch_midas')
# --- preliminaries --- #
rm(list=ls())
require("MIDASLec")
# --- GARCH-MIDAS regressions --- #

# --- load data --- #
load("example3.rda")

# --- prepare NASDAQ data --- #
#trim data so start at same date..
start.indxy <- which(nasdaq[,1]==as.Date("2019-06-28"))
nasdaq.trunc <- nasdaq[1:start.indxy,]
y <- nasdaq.trunc[,2]/100


# --- First example with RV as a regressor and fixed window --- #

rollingWindow <- FALSE
thetaM <- FALSE
period <- 22
nlag <- 24
est.fixed.rv <- midas.garch(y,period,nlag,params0.fixedrv,regressor=NULL,rollingWindow=rollingWindow,thetaM=thetaM)

# --- plot variance and long-term component --- #
nobs <- length(y)
idx <-  seq(period*nlag+1,nobs,by=1)
date <- nasdaq.trunc[,1]
plot(date[idx],sqrt(252*est.fixed.rv$Variance[idx]), type = 'l', col='green',
    xlab='',ylab='')
lines(date[idx],sqrt(252*est.fixed.rv$LongRun[idx]), type = 'l',col='blue')
leg.txt <- c('Total Volatility','Secular Volatility')
legend(1000,1.2,leg.txt,lty=c(1,1),lwd=c(2.5,2.5),col=c('green','blue'))


# --- plot weight function --- #
param1 <- est.fixed.rv$estParams[5]
weights <- beta.weights(nlag,1,param1)
plot(weights, type = 'l', col='blue',
     xlab='',ylab='', main = 'Weight function. Fixed window - RV')




# --- Second example with RV as a regressor rolling window --- #
rollingWindow <- TRUE
thetaM <- FALSE
period <- 22
nlag <- 24
est.roll.rv <- midas.garch(y,period,nlag,params0.rollrv,regressor=NULL,rollingWindow=rollingWindow,thetaM=thetaM)

# --- plot variance and long-term component --- #
nobs <- length(y)
idx <-  seq(period*nlag+1,nobs,by=1)
date <- nasdaq.trunc[,1]
plot(date[idx],sqrt(252*est.roll.rv$Variance[idx]), type = 'l', col='green',
     xlab='',ylab='')
lines(date[idx],sqrt(252*est.roll.rv$LongRun[idx]), type = 'l',col='blue')
leg.txt <- c('Total Volatility','Secular Volatility')
legend(1000,1,leg.txt,lty=c(1,1),lwd=c(2.5,2.5),col=c('green','blue'))

# --- plot weight function --- #
param1 <- est.roll.rv$estParams[5]
weights <- beta.weights(nlag,1,param1)
plot(weights, type = 'l', col='blue',
     xlab='',ylab='', main = 'Weight function. Rolling window - RV')

# --- Third example with Industrial production as a regressor and fixed window --- #

# --- prepare indpro data --- #
yDate <- nasdaq.trunc[,1]
yDateDetails <- date.vec(yDate)
yDateMonth <- yDateDetails[[1]][,2]

# --- trim data so start at same date --- #
start.indx <- which(as.Date(indpro[,1])==as.Date("1971-02-01"))
indpro.trunc <- indpro[start.indx:dim(indpro)[1],]

# --- get indpro series --- #
xMonth <- indpro.trunc[,2]/100
nobs <- length(y)

# --- now we repeat the monthly values to match the daily data --- #
xDay <- matrix(NA,nrow=nobs,ncol=1)
count <- 1
for (t in 1:nobs){
if ((t > 1) && (yDateMonth[t] != yDateMonth[t-1]))  { 
  count <- count + 1
  if (count > length(xMonth)){
    break
  }
}
xDay[t] <- xMonth[count]
}

rollingWindow <- FALSE
thetaM <- TRUE
regressor <- xDay
period <- 22
nlag <- 24
est.indpro <- midas.garch(y,period,nlag,params0.indpro,regressor=regressor,rollingWindow=FALSE,thetaM=TRUE)

# --- plot variance and long-term component --- #
nobs <- length(y)
idx <-  seq(period*nlag+1,nobs,by=1)
date <- nasdaq.trunc[,1]
plot(date[idx],sqrt(252*est.indpro$Variance[idx]), type = 'l', col='green',
     xlab='',ylab='')
lines(date[idx],sqrt(252*est.indpro$LongRun[idx]), type = 'l',col='blue')
leg.txt <- c('Total Volatility','Secular Volatility')
legend(1000,0.8,leg.txt,lty=c(1,1),lwd=c(2.5,2.5),col=c('green','blue'))

# --- plot weight function --- #
param1 <- est.indpro$estParams[5]
weights <- beta.weights(nlag,1,param1)
plot(weights, type = 'l', col='blue',
     xlab='',ylab='', main = 'Weight function. Fixed window - Industrial Production')

# --- Forth example with Consumer Sentiment as an exogenous regressor and fixed window --- #

# --- prepare cons. sent. data --- #
yDate <- nasdaq.trunc[,1]
yDateDetails <- date.vec(yDate)
yDateMonth <- yDateDetails[[1]][,2]


yQuartMonth <- yDateMonth
yQuartMonth[sort(c(which(yDateMonth==1),which(yDateMonth==2),which(yDateMonth==3)))] <- 1
yQuartMonth[sort(c(which(yDateMonth==4),which(yDateMonth==5),which(yDateMonth==6)))] <- 4
yQuartMonth[sort(c(which(yDateMonth==7),which(yDateMonth==8),which(yDateMonth==9)))] <- 7
yQuartMonth[sort(c(which(yDateMonth==10),which(yDateMonth==11),which(yDateMonth==12)))] <- 10


xQuart <- umscent[,2]/100
nobs <- length(y)

# --- now we repeat the monthly values to match the daily data --- #
xDay <- matrix(NA,nrow=nobs,ncol=1)
count <- 1
for (t in 1:nobs){
  if ((t > 1) && (yQuartMonth[t] != yQuartMonth[t-1]))  { 
    count <- count + 1
    if (count > length(xQuart)){
      break
    }
  }
  xDay[t] <- xQuart[count]
}

rollingWindow <- FALSE
thetaM <- TRUE
regressor <- xDay
period <- 66
nlag <- 12

est.umscent <- midas.garch(y,period,nlag,params0.umscent,regressor=regressor,rollingWindow=rollingWindow,thetaM=thetaM)

# --- plot variance and long-term component --- #
nobs <- length(y)
idx <-  seq(period*nlag+1,nobs,by=1)
date <- nasdaq.trunc[,1]
plot(date[idx],sqrt(252*est.umscent$Variance[idx]), type = 'l', col='green',
     xlab='',ylab='')
lines(date[idx],sqrt(252*est.umscent$LongRun[idx]), type = 'l',col='blue')
leg.txt <- c('Total Volatility','Secular Volatility')
legend(1000,0.8,leg.txt,lty=c(1,1),lwd=c(2.5,2.5),col=c('green','blue'))


# --- plot weight function --- #
param1 <- est.umscent$estParams[5]
weights <- beta.weights(nlag,1,param1)
plot(weights, type = 'l', col='blue',
     xlab='',ylab='', main = 'Weight function. Fixed window - Consumer Sentiment')


# --- Last example with mfGARCH package --- #

# --- use prepared data in the package: df_mfgarch --- # 
est <- fit_mfgarch(data = df_mfgarch, y = "return", x = "dindpro", low.freq = "year_month", K = 12, weighting.two = "beta.restricted")




# --- plot variance and long-term component --- #























