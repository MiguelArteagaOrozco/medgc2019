#limpio la memoria
rm( list=ls() )
gc()

#install.packages ("dummies")

library(dplyr) #cuartiles
library(readxl) # leer archivos excel
library(Hmisc)
library(grid)
library(gridExtra)
library(classInt)
library(questionr)
library(dummies)

winDialog("okcancel","Seleccionar el archivo de Cars")
cars <- read_excel(file.choose())
summary(cars)

#punto 3
cars <- mutate(cars, Origin_T = as.factor(Origin))
cars$DriveTrain_T <- ifelse(cars$DriveTrain == "All", "All", "Other") 
cars <- mutate(cars, DriveTrain_T = as.factor(DriveTrain_T))

summary(cars)
#punto 4
cars <- cbind(cars, dummy(cars$Origin_T, sep = "_"))

#punto 5
#igual ancho
clases <- classIntervals(cars$Weight, 3, style="equal")
names(clases)
clases

cars <- mutate(cars, cut(cars$Weight, breaks = clases$brks, labels=as.character(c("bajo", "medio", "alto"))))
colnames(cars)[21] <- "Weight_igualAncho"

#igual frequencia
clases2 <- classIntervals(cars$Weight, 3, style="quantile")
names(clases2)
clases2

cars <- mutate(cars, cut(cars$Weight, breaks = clases2$brks, labels=as.character(c("bajo", "medio", "alto"))))
colnames(cars)[22] <- "Weight_igualFreq"

#punto 6
histogram(cars$Invoice)
histogram(sqrt(cars$Invoice))
histogram(log10(cars$Invoice))

cars$InvoiceLog10 <- log10(cars$Invoice)
histogram(cars$InvoiceLog10)

#punto 7
cars$Length_Norm = ((cars$Length - min(cars$Length))/(max(cars$Length)-min(cars$Length))*(100-1)) +1
cars$Weight_Norm = ((cars$Weight - min(cars$Weight))/(max(cars$Weight)-min(cars$Weight))*(100-1)) +1
