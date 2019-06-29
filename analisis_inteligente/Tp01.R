library(plyr)
library(lubridate)

setwd("C:/Users/Pablo Oliva/Google Drive/MaestriaDataScience/AnalisisInteligenteDeDatos/Clase02")

is_valid_time <- function(time_value) {
  max_time <- hms("15:00:00")
  input_format <- "%d/%m/%Y %H:%M"
  result <- hms(format(as.POSIXct(time_value, format=input_format), format="%H:%M:%S")) < max_time
  return(result)
}

extract_date <- function(time_value) {
  input_format <- "%d/%m/%Y %H:%M"
  result <- dmy(format(as.POSIXct(time_value, format=input_format), format="%d/%m/%Y"))
  return(result)
}

is_valid_state <- function(state_value) {
  state_value_minuscule = tolower(state_value);
  result <- grepl("identify success", state_value_minuscule, fixed=TRUE);
  #result <- result || grepl("verify success", state_value_minuscule, fixed=TRUE);
  return(result)
}

is_work_day <- function(day) {
  day_minuscule = tolower(day);
  result <- grepl("bado", day_minuscule, fixed=TRUE);
  result <- result || grepl("domingo", day_minuscule, fixed=TRUE);
  return(!result)
}

data_path_parking <- "./CocheraTxt.txt"
data_path_toll_1 <- "./Molinete1Txt.txt"
data_path_toll_2 <- "./Molinete2Txt.txt"

parking_dataset <- read.csv(file=data_path_parking, header=TRUE, sep="\t")
toll_1_dataset <- read.csv(file=data_path_toll_1, header=TRUE, sep="\t")
toll_2_dataset <- read.csv(file=data_path_toll_2, header=TRUE, sep="\t")

# Remove if Persona is 0
parking_dataset <- parking_dataset[parking_dataset$Persona > 0,]
toll_1_dataset <- toll_1_dataset[toll_1_dataset$Persona > 0,]
toll_2_dataset <- toll_2_dataset[toll_2_dataset$Persona > 0,]

# Remove missing values
parking_dataset <- parking_dataset[complete.cases(parking_dataset), ]
toll_1_dataset <- toll_1_dataset[complete.cases(toll_1_dataset), ]
toll_2_dataset <- toll_2_dataset[complete.cases(toll_2_dataset), ]

# Remove entrances after 15:00
parking_dataset <- parking_dataset[is_valid_time(parking_dataset$Fecha), ]
toll_1_dataset <- toll_1_dataset[is_valid_time(toll_1_dataset$Fecha), ]
toll_2_dataset <- toll_2_dataset[is_valid_time(toll_2_dataset$Fecha), ]

# Create a combined dataset
combined_dataset <- rbind.data.frame(parking_dataset, toll_1_dataset)
combined_dataset <- rbind.data.frame(combined_dataset, toll_2_dataset)

# Remove states which are not valid
combined_dataset <- combined_dataset[unlist(lapply(combined_dataset$Estado, is_valid_state)), ]

combined_dataset <- combined_dataset[order(toll_1_dataset$Fecha),]

# Add a custom date without hour and remove all duplicate combinations of Persona and custom date.
combined_dataset$fecha_sin_hora <- extract_date(combined_dataset$Fecha)
combined_dataset <- combined_dataset[!duplicated(combined_dataset[,c('Persona', 'fecha_sin_hora')]),]

Serie1 <- count(combined_dataset$fecha_sin_hora)
colnames(Serie1) <- c("fecha_sin_hora", "freq")
Serie1 <- na.omit(Serie1)
Serie2 <- na.omit(Serie1)
Serie2$Dia_semana <- weekdays(as.Date(Serie2$fecha_sin_hora))
Serie2$Agno <- format(as.Date(Serie2$fecha_sin_hora, format="%d/%m/%Y"),"%Y")
Serie2$Mes <- format(as.Date(Serie2$fecha_sin_hora, format="%d/%m/%Y"),"%m")
Serie2$Semana <- format(as.Date(Serie2$fecha_sin_hora, format="%d/%m/%Y"),"%W")

# Remove weekends
Serie2 <- Serie2[unlist(lapply(Serie2$Dia_semana, is_work_day)), ]

# Create table for 2017
temp_table_2017 <- Serie2
temp_table_2017 <- temp_table_2017[temp_table_2017$Agno == "2017", ]
available_days <- unique(Serie2$Dia_semana)
Table_2017 <- data.frame(matrix(ncol = 6, nrow = 52))
colnames(Table_2017) <- c("Semana", available_days)
Table_2017$Semana <- c(1:52)
for (day_of_week in available_days) {
  for (week_value in temp_table_2017$Semana) {
    temporary_rows <- temp_table_2017[temp_table_2017$Semana == week_value, ]
    temporary_rows <- temporary_rows[temporary_rows$Dia_semana == day_of_week, ]
    Table_2017[Table_2017$Semana == as.integer(week_value), ][day_of_week] <- temporary_rows$freq
  }
}
Table_2017[is.na(Table_2017)] <- 0

# Create table for 2018
temp_table_2018 <- Serie2
temp_table_2018 <- temp_table_2018[temp_table_2018$Agno == "2018", ]
temp_table_2018$Semana <- trimws(temp_table_2018$Semana)
temp_table_2018$Dia_semana <- trimws(temp_table_2018$Dia_semana)
available_days <- unique(Serie2$Dia_semana)
Table_2018 <- data.frame(matrix(ncol = 6, nrow = 52))
colnames(Table_2018) <- c("Semana", available_days)
Table_2018$Semana <- c(1:52)
for (day_of_week in available_days) {
  for (week_value in temp_table_2018$Semana) {
    temporary_rows <- temp_table_2018[temp_table_2018$Semana == week_value, ]
    temporary_rows <- temporary_rows[temporary_rows$Dia_semana == day_of_week, ]
    Table_2018[Table_2018$Semana == as.integer(week_value), ][day_of_week] <- temporary_rows$freq
  }
}
Table_2018[is.na(Table_2018)] <- 0

write.table(Serie1, "C:/Users/Pablo Oliva/Google Drive/MaestriaDataScience/AnalisisInteligenteDeDatos/Clase02/Serie1.csv", sep="\t", col.names=TRUE, row.names=FALSE)
write.table(Serie2, "C:/Users/Pablo Oliva/Google Drive/MaestriaDataScience/AnalisisInteligenteDeDatos/Clase02/Serie2.csv", sep="\t", col.names=TRUE, row.names=FALSE)
write.table(Table_2017, "C:/Users/Pablo Oliva/Google Drive/MaestriaDataScience/AnalisisInteligenteDeDatos/Clase02/Table_2017.csv", sep="\t", col.names=TRUE, row.names=FALSE)
write.table(Table_2018, "C:/Users/Pablo Oliva/Google Drive/MaestriaDataScience/AnalisisInteligenteDeDatos/Clase02/Table_2018.csv", sep="\t", col.names=TRUE, row.names=FALSE)

