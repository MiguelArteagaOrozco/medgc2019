FILENAME toll_1 '/home/u39724369/TP01/Molinete1Txt.txt';
FILENAME toll_2 '/home/u39724369/TP01/Molinete2Txt.txt';
FILENAME parking '/home/u39724369/TP01/CocheraTxt.txt';

options datestyle=DMY;

PROC IMPORT DATAFILE=toll_1 replace
	DBMS=DLM
	OUT=TP01.toll1;
	GETNAMES=YES;
	delimiter='09'x;
RUN;

proc import datafile=toll_2 replace
	DBMS=DLM
	OUT=TP01.toll2;
	GETNAMES=YES;
	delimiter='09'x;
RUN;

PROC IMPORT DATAFILE=parking replace
	DBMS=DLM
	OUT=TP01.parking;
	GETNAMES=YES;
	delimiter='09'x;
RUN;

PROC CONTENTS DATA=TP01.toll1; RUN;
PROC CONTENTS DATA=TP01.toll2; RUN;
PROC CONTENTS DATA=TP01.parking; RUN;


data TP01.toll1;
set TP01.toll1; 
maxtime = '15:00:00'T;
hour = TIMEPART(fecha);
format date ddmmyy10. time time8.;
if (persona ne 0) and (persona ne .) and (hour < maxtime); 
run;

data TP01.toll2;
set TP01.toll2; 
maxtime = '15:00:00'T;
hour = TIMEPART(fecha);
format date ddmmyy10. time time8.;
if (persona ne 0) and (persona ne .) and (hour < maxtime);
run;

data TP01.parking;
set TP01.parking; 
maxtime = '15:00:00'T;
hour = TIMEPART(fecha);
format date ddmmyy10. time time8.;
if (persona ne 0) and (persona ne .) and (hour < maxtime); 
run;

data TP01.combined;
set TP01.parking TP01.toll1 TP01.toll2;
if Estado = "Identify Success";
run;

*Proc sql;
*select count(distinct Estado)as Estado_count from TP01.combined;
*Quit;

* Sort by date;
proc sort data=TP01.combined out=TP01.combined_and_sorted;
by fecha;
run;

data TP01.with_date_separated;
set TP01.combined_and_sorted;
Fecha2=datepart(fecha);
format Fecha2 date9.;
run;

data TP01.combine_data_and_people;
set TP01.with_date_separated;
mixed_column = catx(',',persona,Fecha2);
run;

* Sort by person and keep only the first occurrence;
PROC SORT DATA=TP01.combine_data_and_people
 DUPOUT=TP01.no_duplicate_entries
 NODUPkey;
 BY mixed_column;
RUN;

* Sort by date;
proc sort data=TP01.no_duplicate_entries out=TP01.single_access;
by fecha;
run;

* Entrance data per day;
proc freq data = TP01.single_access ;
tables Fecha2 / nopercent nocum out=TP01.Serie1(rename=(count=Cantidad) drop=percent);
run;

data TP01.Serie2;
set TP01.Serie1;
Year_value=year(Fecha2);
Month_value=month(Fecha2);
Day_value=weekday(Fecha2);
Week_value=week(Fecha2);
* Remove Sundays and Saturdays;
if Day_value ne 7 and Day_value ne 1;
run;


data TP01.entrances_2017;
set TP01.Serie2;
drop Year_value Fecha2 Month_value; 
if Year_value=2017;
run;

proc transpose data=TP01.entrances_2017 prefix=Day_
     out=TP01.entrances_2017(drop=name drop=label);
   by Week_value ;
   id Day_value;
run;

data TP01.entrances_2018;
set TP01.Serie2;
drop Year_value Fecha2 Month_value; 
if Year_value=2018;
run;

proc transpose data=TP01.entrances_2018 prefix=Day_
     out=TP01.entrances_2018(drop=name drop=label);
   by Week_value ;
   id Day_value;
run;
