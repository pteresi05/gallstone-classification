library(leaps)     # For stepwise and all-subsets
library(lmSubsets) # For another all-subsets with some more features
library(MASS)      # Many useful statistics functions
library(corrplot)  # For a correlation plot
library(car)       # For vif
library(psych)
library(pracma)
library(GGally)
library(ggplot2)
library(glmnet)
library(broom)
library(ca)
library(pROC)
library(patchwork)
library(DataExplorer)


gallstone = read.csv("gallstonenew.csv")
gallstone$person_id = NULL
names(gallstone) = c("Gallstone", "Age", "Gender", "Comorbidity", "CAD", "Hypothyroidism",
                     "Hyperlipidemia", "DM", "Height", "Weight", "BMI", "TBW", "ECW", "ICW", "ECF.TBW",
                     "TBFR", "LeanMass", "BPC", "VFR", "BoneMass", "MuscleMass", "Obesity",
                     "TFC", "VFA", "VMAkg", "HFA", "Glucose", "TotChol", "LDL", "HDL",
                     "Triglyceride", "AST", "ALT", "ALP", "Creatinine", "GFR", "CRP", "Hemoglobin",
                     "VitD")
set.seed(34)
n<-nrow(gallstone)
trainIdx <- sample(1:n, size = 0.8*n)

# split data 80/20 training and testing respectively
gallstoneTrain<-gallstone[trainIdx,]
gallstoneTest<-gallstone[-trainIdx,]

head(gallstone)

df = as.data.frame(gallstone)

# Exploratory Data Analysis
pairs.panels(gallstone[c(1:10)])
pairs.panels(gallstone[c(11:20)])
pairs.panels(gallstone[c(21:30)])
pairs.panels(gallstone[c(31:39)])

hist(x=gallstone$TotChol, main="Total Cholesterol", xlab="Cholesterol", col="gray",border="black")
boxplot(TotChol ~ Gallstone, data=gallstone, ylab="Total Cholesterol", xlab="Gallstone Status")

ggplot(gallstone, aes(x = factor(Gallstone), y = ALP)) + geom_boxplot()
ggplot(gallstone, aes(x = factor(Gallstone))) + geom_bar()

corrplot(cor(gallstone), order="AOE")

boxplot(LDL.TotChol.Ratio ~ Gallstone, data = gallstone, xlab="Gallstone Status",
        ylab = "Total Cholesterol to LDL Cholesterol")
boxplot(Gender ~ Gallstone, data=gallstone)

ggplot(gallstone, aes(x = factor(Gallstone))) + geom_bar()

boxplot(BMI ~ Gallstone, data = gallstone, xlab = "Gallstone Status", 
        ylab = "BMI")
boxplot(Weight ~ Gallstone, data = gallstone, xlab = "Gallstone Status", 
        ylab = "Weight")
boxplot(LDL ~ Gallstone,data=gallstone,xlab="Gallstone Status",ylab="Low Density Lipoprotein")

boxplot(Age ~ Gallstone, data = gallstone, xlab = "Gallstone Status", 
        ylab = "Age")
boxplot(TotChol ~ Gallstone, data = gallstone, xlab = "Gallstone Status", 
        ylab = "Total Cholesterol")
ggplot(gallstone, aes(x = factor(Gallstone), y = TotChol)) +
  geom_boxplot() +
  labs(x = "Gallstone Status", y = "Total Cholesterol",
       title = "Cholesterol Distribution by Binary Class")



# ----------------------------------------------------- Linear Discriminant Analysis ---------------------------------

fitLDA<-lda(Gallstone~., data=gallstoneTrain)
fitLDA

pLDA<-predict(fitLDA, gallstoneTest)

table(Predicted=pLDA$class, Actual=gallstoneTest$Gallstone)
mean(pLDA$class == gallstoneTest$Gallstone) # accuracy

plot(roc(gallstoneTest$Gallstone, pLDA$posterior[, 2]), 
      main = "LDA ROC Curve", col="purple")
print(auc(roc(gallstoneTest$Gallstone, pLDA$posterior[,2])))


# ----------------------------------------------------- Logistic and Regularized Regression ---------------------------------

# Logistic Regression
xTrain=as.matrix(train_data[, -1])
yTrain=as.matrix(train_data[, 1])
xTest=as.matrix(test_data[, -1])
yTest=as.matrix(test_data[, 1])


gallstoneLog = glm(Gallstone ~ ., data = train_data, family = "binomial")


# Predicted probabilities
predTrain = predict(gallstoneLog, newdata = train_data, type = "response")
predTest  = predict(gallstoneLog, newdata = test_data,  type = "response")

plot(roc(yTrain, predTrain), main="ROC Curve", col="red")
print(auc(roc(yTrain, predTrain)))
plot(roc(yTest, predTest), main="Testing ROC Curve", col = "blue")
print(auc(roc(yTest, predTest)))




gallstoneReg = cv.glmnet(xTrain, yTrain, family = "binomial", alpha = 1)

predTrain = predict(gallstoneReg, newx=xTrain, type="response", s="lambda.1se", se.fit=FALSE)
predTest = predict(gallstoneReg, newx=xTest, type="response", s="lambda.1se", se.fit=FALSE)

plot(roc(yTrain, predTrain), main="ROC Curve", col="red")
print(auc(roc(yTrain, predTrain)))
plot(roc(yTest, predTest), main="Testing ROC Curve", col = "blue")
print(auc(roc(yTest, predTest)))


# -----------------------------------------------------PCA and Factor Analysis -----------------------------------------------


gallstoneNew = gallstone[-c(gallstone$Gallstone)]
head(gallstoneNew)
names(gallstoneNew)

p = prcomp(gallstoneNew, scale = T)
summary(p)
# 6 components captures 63%, 8 components captures 73.5%


plot(p, main = "Scree Plot", xlab="Number of Components")
abline(1, 0, col="red") # .
fa.parallel(gallstoneNew) # seven comps.

pfaGal = principal(gallstoneNew, nfactors = 7, rotate = "varimax")
sc = as.data.frame(pfaGal$scores)
print(pfaGal$loadings, cutoff = .4, sort = T)

# 
gallstoneR = gallstoneNew[-c(4, 5, 6, 21, 33, 36)]


head(gallstoneR)

pR = prcomp(gallstoneR, scale=T)
summary(pR)

plot(pR, main = "Scree Plot of Reduced PCA", xlab="Number of Components")
abline(1, 0, col = 'red')
fa.parallel(gallstoneR)

pfaGalR = principal(gallstoneR, nfactors=7, rotate="varimax")
sc2 = as.data.frame(pfaGalR$scores)
print(pfaGalR$loadings, cutoff=.4, sort = T)

# Create new data frame of PFA scores
newData = as.data.frame(pfaGalR$scores)
# Rename factors
names(newData) = c("Body Size/Lean Mass", "Adiposity", "Diabetes", "GKF",
                   "Increased LDL", "LEL", "Comorbidity/Fluid-Vitamin Status")
# Add individual factors (uncorrelated predictors)

newData$Gallstone = as.factor(gallstone$Gallstone)
newData$Obesity = gallstoneNew$Obesity
newData$Hypothyroidism = gallstoneNew$Hypothyroidism
newData$Hyperlipidemia = gallstoneNew$Hyperlipidemia
newData$ALP = gallstoneNew$ALP
newData$CRP = gallstoneNew$CRP
newData$CAD = gallstoneNew$CAD

names(newData)
head(newData)


library(glmnet)



n<-nrow(newData)
trainIdx <- sample(1:n, size = 0.65*n)

train_data<-newData[trainIdx,]
nrow(train_data)
test_data<-newData[-trainIdx,]
nrow(test_data)

names(train_data)


x_train = train_data[, -which(names(train_data) == "Gallstone")]
y_train=train_data[, which(names(train_data) == "Gallstone")]
x_test=test_data[,-which(names(test_data) == "Gallstone")]
y_test=test_data[,which(names(test_data) == "Gallstone")]

logReg<-glm(Gallstone~., data = train_data, family="binomial")

predTrain = predict(logReg, newdata = train_data, type = "response")
predTest  = predict(logReg, newdata = test_data,  type = "response")
plot(roc(y_train, predTrain), main="ROC Curve (Train)", col="red")
print(auc(roc(y_train,predTrain)))
plot(roc(y_test, predTest), main="ROC Curve (Test)", col="blue")
print(auc(roc(y_test,predTest)))



auc_train = auc(roc(train_data$Gallstone, predTrain))
auc_test  = auc(roc(test_data$Gallstone,  predTest))

print(auc_train)
print(auc_test)


faReg = cv.glmnet(as.matrix(x_train), as.matrix(y_train), family = "binomial", alpha = 1)

predTrain = predict(faReg, newx=as.matrix(x_train), type="response", s="lambda.1se", se.fit=FALSE)
predTest = predict(faReg, newx=as.matrix(x_test), type="response", s="lambda.1se", se.fit=FALSE)
roc_train = roc(y_train, predTrain)
roc_test=roc(y_test, predTest)
auc_train = auc(roc_train)
auc_test = auc(roc_test)
# AUC for Train Data
print(auc_train)
# AUC for Test Data
print(auc_test)
