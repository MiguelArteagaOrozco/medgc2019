proc import datafile="D:\tp1\CocheraTxt.txt"
			out=Tp01.Cochera
			dbms=dlm
			replace;
datarow=2;
delimiter='09'x;
run;
proc import datafile="D:\tp1\Molinete1Txt.txt"
			out=Tp01.Molinete1
			dbms=dlm
			replace;
datarow=2;
delimiter='09'x;
run;
proc import datafile="D:\tp1\Molinete2Txt.txt"
			out=Tp01.Molinete2
			dbms=dlm
			replace;
datarow=2;
delimiter='09'x;
run;
/*1. Una los datasets enviados. */
data Tp01.Ingresos;
set Tp01.Cochera Tp01.Molinete1 Tp01.Molinete2;
run;
/**************************************************************************************************************/
/*2. Elimine los registros que considere necesario de acuerdo a las consideraciones 
del problema planteadas anteriormente. 
Cree las variables que considere necesarias para poder luego eliminar registros.*/

/*me quedo solo con los ingresos que tengan una variable persona valida*/
data Tp01.IngPersonaOK;
set Tp01.Ingresos;
if(persona <> 0 or persona <> .);
run;

/*separo Fecha y Hora*/
data Tp01.Ing_SplitFechaHora;
set Tp01.IngPersonaOK;
fecha2 = datepart(fecha);
hora = timepart(fecha);
format fecha2 ddmmyy10.;
format hora hhmm.;  
run;

/*marco los primeros ingreos, para eso primero ordeno*/
proc sort data = Tp01.Ing_SplitFechaHora;
  by fecha2 persona;
run;
data Tp01.Ing_Marcaprimero;
	set Tp01.Ing_SplitFechaHora;
	by fecha2 Persona;
	if first.Persona then primerIngreso = 1;
	else primerIngreso = 0;
run;
/*me quedo solo con los primeros ingresos antes de las 15hrs, como dataSet Base*/
data Tp01.IngresosFinal;
	set Tp01.Ing_Marcaprimero;
	if primerIngreso = 1;
	if hora lt '15:00't;
run;

/**************************************************************************************************************/
/*
Cree un nuevo dataset con nombre “Serie1” ordenado por fecha de la forma:  
Fecha2           Cantidad 
03-jul-2017      xxxx 
04-jul-2017      xxxx 
*/

data Tp01.Serie1;
	set Tp01.IngresosFinal; 
	keep fecha2;
	format fecha2 DATE11.;
run;
proc freq data= Tp01.Serie1 ;
 tables Fecha2/ out=Tp01.Serie1 (keep = fecha2 count) nopercent nocum;
 run;
data Tp01.Serie1;
	set Tp01.Serie1;
	Cantidad = count;
	keep Fecha2 Cantidad;
run;

/**************************************************************************************************************/
/*
4. Agregue al dataset “Serie1” las siguientes variable y cambie el nombre a “Serie2”: 
	 Dia_semana (es decir si la fecha cae Lunes) 
	 Año 
	 Mes 
	 Semana 
*/

data Tp01.Serie2;
	set Tp01.Serie1;
	Dia_semana = weekday(fecha2);
	Anio = year(Fecha2);
	Mes = month(Fecha2);
	Semana = week(Fecha2, 'v');
run;
/**************************************************************************************************************/
/*
5. Elimine los registros cuya fecha sea sábado o Domingo 
	(ya que los sábados y domingos solo ingresan personas de mantenimiento).
*/
data Tp01.Serie2;
	set Tp01.Serie2;
	if (Dia_semana > 1) and (Dia_semana < 7);
run;
/**************************************************************************************************************/
/*
6. Cree dos tablas 2017 y 2018 por semana y dia de la semana
*/
 /*2017*/
data Tp01.anio2017;
set Tp01.Serie2;
if Anio = 2017;
run;

proc transpose data=Tp01.anio2017
out=Tp01.anio2017 (drop=_name_);
id Dia_Semana;
by semana;
var Cantidad;
run;

Options validvarname = Any;

data Tp01.anio2017;
set Tp01.anio2017;
rename _2 = '01-Lunes'n;
rename _3 = '02-Martes'n;
rename _4 = '03-Miercoles'n;
rename _5 = '04-Jueves'n;
rename _6 = '05-Viernes'n;
run;
Options validvarname = V7;
/*2018*/
data Tp01.anio2018;
set Tp01.Serie2;
if Anio = 2018;
run;

proc transpose data=Tp01.anio2018
out=Tp01.anio2018 (drop=_name_);
id Dia_Semana;
by semana;
var Cantidad;
run;

Options validvarname = Any;

data Tp01.anio2018;
set Tp01.anio2018;
rename _2 = '01-Lunes'n;
rename _3 = '02-Martes'n;
rename _4 = '03-Miercoles'n;
rename _5 = '04-Jueves'n;
rename _6 = '05-Viernes'n;
run;



