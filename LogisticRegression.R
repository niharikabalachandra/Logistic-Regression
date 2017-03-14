
library(car) ## needed to recode variables
set.seed(1)

## read and print the data
delays_flight <- read.csv("~/FlightDelays.csv")
delays_flight[1:3,]

## define hours of departure
delays_flight$sched=factor(floor(delays_flight$schedtime/100))
table(delays_flight$sched)
table(delays_flight$carrier)
table(delays_flight$dest)
table(delays_flight$origin)
table(delays_flight$weather)
table(delays_flight$dayweek)
table(delays_flight$daymonth)
table(delays_flight$delay)
delays_flight$delay=recode(delays_flight$delay,"'delayed'=1;else=0")
delays_flight$delay=as.numeric(levels(delays_flight$delay)[delays_flight$delay])
table(delays_flight$delay)

## Delay: 1=Monday; 2=Tuesday; 3=Wednesday; 4=Thursday;
## 5=Friday; 6=Saturday; 7=Sunday
## 7=Sunday and 1=Monday coded as 1

delays_flight$dayweek=recode(delays_flight$dayweek,"c(1,7)=1;else=0")
table(delays_flight$dayweek)

## omit unused variables
delays_flight=delays_flight[,c(-1,-3,-5,-6,-7,-11,-12)]
delays_flight[1:3,]
n=length(delays_flight$delay)
n
n1=floor(n*(0.6))
n1
n2=n-n1
n2

train=sample(1:n,n1)

## estimation of the logistic regression model
## explanatory variables: carrier, destination, origin, weather, day of week
## (weekday/weekend), scheduled hour of departure
## create design matrix; indicators for categorical variables (factors)
Xdelays_flight <- model.matrix(delay~.,data=delays_flight)[,-1]
Xdelays_flight[1:3,]
xtrain <- Xdelays_flight[train,]
xnew <- Xdelays_flight[-train,]
ytrain <- delays_flight$delay[train]
ynew <- delays_flight$delay[-train]
m1=glm(delay~.,family=binomial,data=data.frame(delay=ytrain,xtrain))
summary(m1)

## prediction: predicted default probabilities for cases in test set
ptest <- predict(m1,newdata=data.frame(xnew),type="response")
data.frame(ynew,ptest)[1:10,]

## first column in list represents the case number of the test element
plot(ynew~ptest)
26

## coding as 1 if probability 0.5 or larger
gg1=floor(ptest+0.5) ## floor function; see help command
ttt=table(ynew,gg1)
ttt
error=(ttt[1,2]+ttt[2,1])/n2
error

## coding as 1 if probability 0.3 or larger
gg2=floor(ptest+0.7)
ttt=table(ynew,gg2)
ttt
error=(ttt[1,2]+ttt[2,1])/n2
error
bb=cbind(ptest,ynew)
bb
bb1=bb[order(ptest,decreasing=TRUE),]
bb1

## order cases in test set according to their success prob
## actual outcome shown next to it
## overall success (delay) prob in the evaluation data set
xbar=mean(ynew)
xbar

## calculating the lift
## cumulative 1's sorted by predicted values
## cumulative 1's using the average success prob from evaluation set
axis=dim(n2)
ax=dim(n2)
ay=dim(n2)
axis[1]=1
ax[1]=xbar
ay[1]=bb1[1,2]
for (i in 2:n2) {
  axis[i]=i
  ax[i]=xbar*i
  ay[i]=ay[i-1]+bb1[i,2]
}
aaa=cbind(bb1[,1],bb1[,2],ay,ax)
aaa[1:100,]
plot(axis,ay,xlab="number of cases",ylab="number of successes",main="Lift:
     Cum successes sorted by pred val/success prob")
points(axis,ax,type="l")