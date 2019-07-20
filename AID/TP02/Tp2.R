library(readxl) # leer archivos excel
library(dplyr) #cuartiles
library(ggplot2) 
library(ggExtra) #mejorar grafico
library(nortest) #normalidad
library(expss) 
library(TMB)
library(sjPlot)
library(data.table)

winDialog("okcancel","Seleccionar el archivo de Documentos")
documentos <- read_excel(file.choose())
dim(documentos)

winDialog("okcancel","Seleccionar el archivo de Tipos de tramite")
tiposTramite <- read_excel(file.choose())
dim(tiposTramite)

#merge
names(documentos)[2] <-"TipoTramite"
names(tiposTramite)[1] <- "TipoTramite"
db <- merge(documentos, tiposTramite, by = "TipoTramite")
names(db)[5] <- "Acronimo"
dim(db)

#elimino documentos que no entregan certifcado
db <- db[(!is.na(db$Acron1) | !is.na(db$Acron2) | !is.na(db$Acron3) | !is.na(db$Acron4)),]
dim(db)
db <- db[(!is.na(db$Acronimo) | db$Acronimo != ''),]
dim(db)

#con acronimico correcto
correctos <- filter(db, (Acronimo==Acron1) | (Acronimo==Acron2) | (Acronimo==Acron3) | (Acronimo==Acron4))
dim(correctos)

#sin Acronimo correcto
incorrectos <- subset(db, (!(Acronimo %in% c(Acron1,Acron2,Acron3,Acron4)) & !(Expediente %in% correctos$Expediente)))
dim(incorrectos)

#elimino expedientes duplicados por ser parte del mismo tramite
correctos$primero <- !duplicated(correctos$Expediente)
correctos <- correctos[correctos$primero,]

incorrectos$primero <- !duplicated(incorrectos$Expediente)
incorrectos <- incorrectos[incorrectos$primero,]

correctos$UsaronAcronimo <- TRUE
incorrectos$UsaronAcronimo <- FALSE

db2 <- rbind(correctos, incorrectos) 

# obtengo el total de expedientes y tipos de tramite
expedientes <- as.data.frame(db2$Expediente)
names(expedientes)[1] <- "Expediente"
expedientes$primero <- !duplicated(expedientes$Expediente)
expedientes <- expedientes[expedientes$primero,]

tipoDeTramitesUsados <- as.data.frame(db2$TipoTramite)
names(tipoDeTramitesUsados)[1] <- "TipoTramite"
tipoDeTramitesUsados$primero <- !duplicated(tipoDeTramitesUsados$TipoTramite)
tipoDeTramitesUsados <- tipoDeTramitesUsados[tipoDeTramitesUsados$primero,]



#tabla 1
volumen.usaronAcronimo.cantidad <- nrow(correctos)
volumen.usaronAcronimo.porcentaje <- volumen.usaronAcronimo.cantidad / nrow(expedientes) * 100
volumen.NoUsaronAcronimo.cantidad <- nrow(incorrectos)
volumen.NoUsaronAcronimo.porcentaje <- volumen.NoUsaronAcronimo.cantidad / nrow(expedientes) * 100
paste("volumen.usaronAcronimo.cantidad: " , volumen.usaronAcronimo.cantidad)
paste("volumen.usaronAcronimo.porcentaje: " , volumen.usaronAcronimo.porcentaje)
paste("volumen.NoUsaronAcronimo.cantidad: " , volumen.NoUsaronAcronimo.cantidad)
paste("volumen.NoUsaronAcronimo.porcentaje: " , volumen.NoUsaronAcronimo.porcentaje)


TipoDeTramite.UsaronAcronimo.cantidad <- length(unique(as.array(correctos$TipoTramite)))
TipoDeTramite.UsaronAcronimo.porcentaje <- TipoDeTramite.UsaronAcronimo.cantidad / nrow(tipoDeTramitesUsados) * 100
TipoDeTramite.NoUsaronAcronimo.cantidad <- length(unique(as.array(incorrectos$TipoTramite)))
TipoDeTramite.NoUsaronAcronimo.porcentaje <- TipoDeTramite.NoUsaronAcronimo.cantidad / nrow(tipoDeTramitesUsados) * 100
paste("TipoDeTramite.UsaronAcronimo.cantidad: ",TipoDeTramite.UsaronAcronimo.cantidad)
paste("TipoDeTramite.UsaronAcronimo.porcentaje: ", TipoDeTramite.UsaronAcronimo.porcentaje)
paste("TipoDeTramite.NoUsaronAcronimo.cantidad: ",TipoDeTramite.NoUsaronAcronimo.cantidad)
paste("TipoDeTramite.NoUsaronAcronimo.porcentaje: ",TipoDeTramite.NoUsaronAcronimo.porcentaje)

#----------------------------------------------------------------------------------------
#tabla 2
correctos$UsaronAcronimoCountTipoTramite <- 1
SerieCorrectos <- aggregate(UsaronAcronimoCountTipoTramite~TipoTramite,correctos,sum)
SerieCorrectos$UsaronAcronimoPorcentajeTipoTramite <- SerieCorrectos$UsaronAcronimoCountTipoTramite / (volumen.usaronAcronimo.cantidad + volumen.NoUsaronAcronimo.cantidad) * 100

incorrectos$NoUsaronAcronimoCountTipoTramite <- 1
SerieIncorrectos <- aggregate(NoUsaronAcronimoCountTipoTramite~TipoTramite,incorrectos,sum)
SerieIncorrectos$NoUsaronAcronimoPorcentajeTipoTramite <- SerieIncorrectos$NoUsaronAcronimoCountTipoTramite / (volumen.usaronAcronimo.cantidad + volumen.NoUsaronAcronimo.cantidad) * 100

Tabla2 <- merge(SerieCorrectos, SerieIncorrectos, by = "TipoTramite", all = TRUE)
#write_labelled_xlsx(Tabla2, "Tp2Tabla2.xlsx")

#----------------------------------------------------------------------------------------
# punto  3
correctos$DiferenciaDias <- as.Date(correctos$`Fecha de asociación del documento`, "%Y-%m-%d") - as.Date(correctos$`Fecha de caratulación del expediente`, "%Y-%m-%d")
correctos$weekyear <- as.numeric(format(correctos$`Fecha de asociación del documento`, "%W"))
summary(correctos$weekyear)
correctosOrdenados <- arrange(correctos,weekyear)
correctosOrdenados <- mutate(correctosOrdenados, semana = ifelse((weekyear == 17 ), "1 al 4 de Mayo" , ifelse((weekyear == 18), "5 al 11 de Mayo", ifelse((weekyear == 19), "12 al 18 de Mayo", ifelse((weekyear==20), "19 al 25 de Mayo", "26 al 31 de Mayo")))))

Fito <- correctosOrdenados[correctosOrdenados$`Nombre del trámite` %like% "Fito",]
Importacion <- Fito[Fito$`Nombre del trámite` %like% "mporta",]
Exportacion <- Fito[Fito$`Nombre del trámite` %like% "xporta",]

Importacion$Tipo24 <- ifelse(Importacion$`Nombre del trámite` %like% "24", "24 Horas", "Normal")
Exportacion$Tipo24 <- ifelse(Exportacion$`Nombre del trámite` %like% "24", "24 Horas", "Normal")

# boxplot fitosanitarios de importacion
summary(as.numeric(Importacion$DiferenciaDias))
ggplot(Importacion,aes(x=as.factor(semana), y=as.numeric(DiferenciaDias)))+geom_boxplot(aes(fill=Tipo24))

# boxplot fitosanitarios de exportacion
summary(as.numeric(Exportacion$DiferenciaDias))
ggplot(Exportacion,aes(x=as.factor(semana), y=as.numeric(DiferenciaDias)))+geom_boxplot(aes(fill=Tipo24))
