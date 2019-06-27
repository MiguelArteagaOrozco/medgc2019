cochera <- read.table("CocheraTxt.txt",sep="\t", header=TRUE)
molinete1 <- read.table("Molinete1Txt.txt",sep="\t", header=TRUE)
molinete2 <- read.table("Molinete2Txt.txt",sep="\t", header=TRUE)

#*************************************************************************************************************/
#1. Una los datasets enviados.

ingresos = rbind(molinete1, molinete2, cochera)

#*************************************************************************************************************/
#  2. Elimine los registros que considere necesario de acuerdo a las consideraciones 
#  del problema planteadas anteriormente. 
#  Cree las variables que considere necesarias para poder luego eliminar registros.*/

# me quedo solo con los ingresos que tengan una variable persona valida
ingresos <- subset(ingresos,ingresos$Persona != 0 )
ingresos <- subset(ingresos,!is.na(ingresos$Persona) )
# separo fecha y hora
if (!require(plyr)){
  install.packages('plyr')
  library(plyr)
}

if (!require(datetime)){
  install.packages('datetime')
  library(datetime)
}

ingresos$Fecha2 <- as.Date(ingresos$Fecha, "%d/%m/%Y")
ingresos$Fecha3 <- as.datetime(as.character(ingresos$Fecha), "%d/%m/%Y %H:%M")
ingresos$Hora <- format(ingresos$Fecha3 ,format = "%H:%M:%S") 

ingresos <- ingresos[order(ingresos$Fecha3, ingresos$Persona),] 

ingresos$primerIngreso <- !duplicated(ingresos$Persona, ingresos$Fecha2)

primerosIngresos <- ingresos[ingresos$primerIngreso,]

primerosIngresos$despues15hrs  <- as.time(primerosIngresos$Hora) > as.time("15:00")

primerosIngresosAntes15Hrs <- primerosIngresos[!primerosIngresos$despues15hrs,]

#/**************************************************************************************************************/
#  /*
#  Cree un nuevo dataset con nombre “Serie1” ordenado por fecha de la forma:  
#  Fecha2           Cantidad 
#  03-jul-2017      xxxx 
#  04-jul-2017      xxxx 

Serie1 <- count(primerosIngresosAntes15Hrs, c('Fecha2'))
Serie1$Cantidad <- Serie1$freq
Serie1$freq <- NULL

#/**************************************************************************************************************/
#  /*
#  4. Agregue al dataset “Serie1” las siguientes variable y cambie el nombre a “Serie2”: 
#      Dia_semana (es decir si la fecha cae Lunes) 
#      Año 
#      Mes 
#      Semana 
#*/
if (!require(ISOweek)){
  install.packages('ISOweek')
  library(ISOweek)
}
Serie2 <- Serie1
Serie2$Dia_semana <- ISOweekday(Serie1$Fecha2)
Serie2$Anio <- as.numeric(format(Serie1$Fecha2, "%Y"))
Serie2$Mes <- as.numeric(format(Serie1$Fecha2, "%m"))
Serie2$Semana <- as.numeric(format(Serie1$Fecha2, "%W"))

#/**************************************************************************************************************/
#/*
#  5. Elimine los registros cuya fecha sea sábado o Domingo 
# (ya que los sábados y domingos solo ingresan personas de mantenimiento).
#*/

Serie2 <- Serie2[Serie2$Dia_semana > 1 & Serie2$Dia_semana < 7,]

#/**************************************************************************************************************/
#  /*
#  6. Cree dos tablas 2017 y 2018 por semana y dia de la semana
#*/
if (!require(reshape2)){
  install.packages('reshape2')
  library(reshape2)
}
## 2017
anio2017 <- Serie2[Serie2$Anio == 2017,]
anio2017 <- dcast(anio2017, Semana ~ Dia_semana, value.var = "Cantidad")
names(anio2017)[2] <- "01-Lunes"
names(anio2017)[3] <- "02-Martes"
names(anio2017)[4] <- "03-Miercoles"
names(anio2017)[5] <- "04-Jueves"
names(anio2017)[6] <- "05-Viernes"

## 2018
anio2018 <- Serie2[Serie2$Anio == 2018,]
anio2018 <- dcast(anio2018, Semana ~ Dia_semana, value.var = "Cantidad")
names(anio2018)[2] <- "01-Lunes"
names(anio2018)[3] <- "02-Martes"
names(anio2018)[4] <- "03-Miercoles"
names(anio2018)[5] <- "04-Jueves"



  
  
  
  
  
  
  
  
  