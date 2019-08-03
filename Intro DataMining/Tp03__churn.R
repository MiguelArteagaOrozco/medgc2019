library(ggplot2)

db <- read.table("Churn.csv",sep = ';', header = TRUE)
db$Churn <- ifelse(db$Churn == 'False.', FALSE, TRUE)
summary(db)  #no se obserman missings

# area code and  state
db$codigoAreaState <- duplicated(db$State, db$Area_Code)
duplicados <- db[db$codigoAreaState == TRUE,]

#---->  los dos se repiten para distino estado/codigo  -> comportamiento anomalo


#chrum
sum.churn <- summary(db$Churn)
prop.churn <- sum(db$Churn == TRUE) / length(db$Churn)
barplot(table(db$Churn))

#-----------------
#International Plan
#-----------------
counts <- table(db$Churn, db$Intl_Plan, dnn=c("Churn", "International Plan"))
counts
barplot(counts, legend = rownames(counts), col = c("blue", "red"), ylim = c(0, 3300),
        ylab = "Count", xlab = "International Plan", main = "Comparison Bar Chart: Churn
Proportions by International Plan")
box(which = "plot", lty = "solid", col="black")

sumtable <- addmargins(counts, FUN = sum)
sumtable
#proporciones
row.margin <- round(prop.table(counts, margin = 1), 4)*100
row.margin
col.margin <- round(prop.table(counts, margin = 2), 4)*100
col.margin  # se fueron el 42% de los que tenian plan internacional

barplot(counts, col = c("blue", "red"), ylim = c(0, 3300), ylab = "Count", xlab =
          "International Plan", main = "Churn Count by International Plan", beside = TRUE)
legend("topright", c(rownames(counts)), col = c("blue", "red"), pch = 15, title =
         "Churn")
box(which = "plot", lty = "solid", col="black")

#traspuesta
barplot(t(counts), col = c("blue", "green"), ylim = c(0, 3300), ylab = "Counts", xlab =
          "Churn", main = "International Plan Count by Churn", beside = TRUE)
legend("topright", c(rownames(counts)), col = c("blue", "green"), pch = 15, title =
         "Int’l Plan")
box(which = "plot", lty = "solid", col="black")

#-----------------
#Customer Service Calls
#-----------------
hist(db$CustServ_Calls, xlim = c(0,10), col = "lightblue", ylab = "Count", xlab =
       "Customer Service Calls", main = "Histogram of Customer Service Calls")

ggplot() +
  geom_bar(data = db, aes(x = factor(db$CustServ_Calls), fill =
                               factor(db$Churn)), position = "stack") +
  scale_x_discrete("Customer Service Calls") +
  scale_y_continuous("Percent") +
  guides(fill=guide_legend(title="Churn")) +
  scale_fill_manual(values=c("blue", "red"))

ggplot() +
  geom_bar(data=db, aes(x = factor(db$CustServ_Calls), fill =
                             factor(db$Churn)), position = "fill") +
  scale_x_discrete("Customer Service Calls") +
  scale_y_continuous("Percent") +
  guides(fill=guide_legend(title="Churn"))+
  scale_fill_manual(values=c("blue", "red"))  # a partir de la 4 llamada la proporcion de churn es mayor
#-----------------
#Internacional Calls
#-----------------
# Partir los datos
churn.false <- subset(db, db$Churn == FALSE)
churn.true <- subset(db, db$Churn == TRUE)
# Correr el test t
t.test(churn.false$Intl_Calls, churn.true$Intl_Calls)#p-value = 0.00407
                                                     #   mean of x mean of y 
                                                     #    4.515083  4.149888   --->  Los churners tienden a colocar menos cantidad promedio de llamdas internacionles

#-----------------
# Evening Minutes y Day Minutes
#-----------------
plot(db$Eve_Mins,
     db$Day_Mins,
     xlim = c(0, 400),
     ylim = c(0, 400),
     xlab = "Evening Minutes",
     ylab = "Day Minutes",
     main = "Scatterplot of Day and Evening Minutes by Churn",
     col = ifelse(db$Churn == TRUE, "red", "blue"))
legend("topright",
       c("True", "False"),
       col = c("red", "blue"),
       pch = 1,
       title = "Churn")
#----
plot(db$Day_Mins,
     db$CustServ_Calls,
     xlim = c(0, 400),
     xlab = "Day Minutes",
     ylab = "Customer Service Calls",
     main = "Scatterplot of Day Minutes and Customer Service Calls by Churn",
     col = ifelse(db$Churn==TRUE, "red", "blue"),
     pch = ifelse(db$Churn==TRUE, 16, 20))
legend("topright",
       c("True", "False"),
       col = c("red", "blue"),
       pch = c(16, 20),
       title = "Churn")

pairs(~db$Day_Mins+ db$Day_Calls+ db$Day_Charge)

#regrecion lineal
fit <- lm(as.numeric( db$Day_Charge) ~ as.numeric(db$Day_Mins) )
summary(fit)

# Correlación con valores p
days <- cbind(db$Day.Mins, db$Day_Calls, db$Day_Charge)
MinsCallsTest <- cor.test(as.numeric(db$Day_Mins), db$Day_Calls)
MinsChargeTest <- cor.test(as.numeric(db$Day_Mins), as.numeric(db$Day_Charge))
CallsChargeTest <- cor.test(as.numeric(db$Day_Calls), as.numeric(db$Day_Charge))
round(cor(days), 4)
MinsCallsTest$p.value
MinsChargeTest$p.value
CallsChargeTest$p.value

# Reunir las variables de interes
corrdata <-
  cbind(db$Account_Length,
        db$VMail_Message,
        db$Day_Mins,
        db$Day_Calls,
        db$CustServ_Calls)
# Declarar la matriz
corrpvalues <- matrix(rep(0, 25), ncol = 5)
# Llenar la matriz con las correlaciones
for (i in 1:4) {
  for (j in (i+1):5) {
    corrpvalues[i,j] <-
      corrpvalues[j,i] <-
      round(cor.test(corrdata[,i], corrdata[,j])$p.value, 4) } }
round(cor(corrdata), 4)
corrpvalues

#------------------------------
# Creacion de Arbol de decision
#------------------------------
library(rpart)
library(rpart.plot)

#seleccion de variables
#int_plan, Vmail_plan, Vmail_Message, Day_Mins, 
#Day_Calls,Eve_Mins,Eve_Calls,Night_Mins,Night_Calls, 
#Intl_Mins,Intl_Calls,CustServ_Calls,Churn
churn <- db[,c(5,6,7,8,9,11,12,14,15,17,18,20,21)]
churn$Day_Mins <- as.numeric(churn$Day_Mins)
churn$Eve_Mins <- as.numeric(churn$Eve_Mins)
churn$Night_Mins <- as.numeric(churn$Night_Mins)
churn$Intl_Mins <- as.numeric(churn$Intl_Mins)

#train and test sets
ind <- sample(2, nrow(churn), replace = TRUE, prob = c(0.7, 0.3))
trainData <- churn[ind==1,]
testData  <- churn[ind==2,]

#arbol
arbol <- rpart(Churn ~ ., method = 'class', data = trainData)
rpart.plot(arbol,extra = 4)

#poda
printcp(arbol)
plotcp(arbol)

# el error del arbol no deja de decrecer, por lo que no se ve necesidad de poda

#efectividad
testPred <- predict(arbol,newdata = testData, type = 'class')
table(testPred, testData$Churn)

sum(testPred == testData$Churn) / length(testData$Churn) * 100

#----------------------------------------------------------------

#arbol 2
cor.test(as.numeric(churn$Vmail_Plan), churn$Vmail_Message)

#se elimina la variable  Vmail_Message  por estar correlacionada con Vmail_Plan
churn2 <- churn[,c(1,2,4,5,6,7,8,9,10,11,12,13)]

#train and test sets
ind2 <- sample(2, nrow(churn2), replace = TRUE, prob = c(0.7, 0.3))
trainData2 <- churn2[ind2==1,]
testData2  <- churn2[ind2==2,]
#arbol
arbol2 <- rpart(Churn ~ ., method = 'class', data = trainData2)
rpart.plot(arbol2,extra = 4)
printcp(arbol2)
plotcp(arbol2)
# el error del arbol no deja de decrecer, por lo que no se ve necesidad de poda

#efectividad
testPred2 <- predict(arbol2,newdata = testData2, type = 'class')
table(testPred2, testData2$Churn)

sum(testPred2 == testData2$Churn) / length(testData2$Churn) * 100

#----------------------------------------------------------------

#arbol 3
# se agrega la variable AccountLenght
churn3 <- churn2
churn3$Account_Length <- db$Account_Length
summary(churn3$Account_Length)
churn3$Account_Length <- ifelse(churn3$Account_Length <= 101, 'nuevo', 'antiguo')
churn3$Account_Length <- as.factor(churn3$Account_Length)

#train and test sets
ind3 <- sample(2, nrow(churn3), replace = TRUE, prob = c(0.7, 0.3))
trainData3 <- churn3[ind3==1,]
testData3  <- churn3[ind3==2,]
#arbol
arbol3 <- rpart(Churn ~ ., method = 'class', data = trainData3)
rpart.plot(arbol3,extra = 4)
printcp(arbol3)
plotcp(arbol3)

#efectividad
testPred3 <- predict(arbol3,newdata = testData3, type = 'class')
table(testPred3, testData3$Churn)
sum(testPred3 == testData3$Churn) / length(testData3$Churn) * 100

#poda
arbol3Pruned <- prune(arbol3, cp = 0.023729)
rpart.plot(arbol3Pruned,extra = 4)
printcp(arbol3Pruned)
plotcp(arbol3Pruned)

#efectividad pruned
testPred3Pruned <- predict(arbol3Pruned,newdata = testData3, type = 'class')
table(testPred3Pruned, testData3$Churn)
sum(testPred3Pruned == testData3$Churn) / length(testData3$Churn) * 100





























