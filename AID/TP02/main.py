#%%
import pandas as pd
import numpy as np
from pathlib import Path
import datetime
from dateutil.relativedelta import relativedelta
from datetime import date
import matplotlib.pyplot as plt
# import seaborn
import seaborn as sns

#%%
documentos = pd.read_excel(Path().joinpath('data','Documentos_vinculados_a_expedientes_Mayo2019.xlsx'))

#%%
tipos = pd.read_excel(Path().joinpath('data','Tipos_tramites.xlsx'))

#%%
db = documentos.merge(tipos,'inner',left_on='Cód. trámite', right_on='N°detrata')
print(len(db))

#%%
#elimino documentos que no entregan certifcado
db = db.loc[(db['Acron1'].notnull() | db['Acron2'].notnull() | db['Acron3'].notnull() | db['Acron4'].notnull())]
db = db.loc[db['Acrónimo'].notnull()]
print(len(db))

#%%
correctos = db.loc[( (db['Acrónimo'] == db['Acron1']) | (db['Acrónimo'] == db['Acron2']) | (db['Acrónimo'] == db['Acron3']) | (db['Acrónimo'] == db['Acron4']))]
correctos.columns = correctos.columns.str.strip()
db.columns = db.columns.str.strip()

filter1 = db['Acrónimo'] != db['Acron1']
filter2 = db['Acrónimo'] != db['Acron2']
filter3 = db['Acrónimo'] != db['Acron3']
filter4 = db['Acrónimo'] != db['Acron4']
filter5 = db['Expediente'].isin(correctos['Expediente'])

incorrectos = db[filter1 & filter2 & filter3 & filter4 & ~filter5]

print(len(correctos))
print(len(incorrectos))

#%%
correctos.columns = correctos.columns.str.strip()
correctos = correctos.sort_values('Expediente')
correctos = correctos.drop_duplicates(subset='Expediente', keep='first')

incorrectos.columns = incorrectos.columns.str.strip()
incorrectos = incorrectos.sort_values('Expediente')
incorrectos = incorrectos.drop_duplicates(subset='Expediente', keep='first')

#%%
#Punto 1
expedientesCount = len(correctos) + len(incorrectos)
tipoDeTramiteCount = len(pd.concat([correctos, incorrectos]).drop_duplicates(subset='Cód. trámite', keep='first'))

tipoDetramiteCorrectos = len(correctos.drop_duplicates(subset='Cód. trámite', keep='first'))
tipoDetramiteIncorrectos = len(incorrectos.drop_duplicates(subset='Cód. trámite', keep='first'))

print("volumen.usaronAcronimo.cantidad: ", len(correctos))
print("volumen.usaronAcronimo.porcentaje: ", len(correctos)/expedientesCount*100, " %")
print("volumen.NoUsaronAcronimo.cantidad: " ,len(incorrectos))
print("volumen.NoUsaronAcronimo.porcentaje: " , len(incorrectos) / expedientesCount*100, " %")
print("----------")
print("TipoDeTramite.UsaronAcronimo.cantidad: ", tipoDetramiteCorrectos)
print("TipoDeTramite.UsaronAcronimo.porcentaje: ", tipoDetramiteCorrectos/tipoDeTramiteCount*100, " %")
print("TipoDeTramite.NoUsaronAcronimo.cantidad: " , tipoDetramiteIncorrectos)
print("TipoDeTramite.NoUsaronAcronimo.porcentaje: " , tipoDetramiteIncorrectos /tipoDeTramiteCount*100, " %")

#%%
#Punto 2
correctos["UsaronAcronimoCountTipoTramite"] = 1
serieCorrectos = correctos.groupby("Cód. trámite").sum()
serieCorrectos["UsaronAcronimoPorcentajeTipoTramite"] = serieCorrectos["UsaronAcronimoCountTipoTramite"]/expedientesCount*100

incorrectos["NoUsaronAcronimoCountTipoTramite"] = 1
serieIncorrectos = incorrectos.groupby("Cód. trámite").sum()
serieIncorrectos["NoUsaronAcronimoPorcentajeTipoTramite"] = serieIncorrectos["NoUsaronAcronimoCountTipoTramite"]/expedientesCount*100

tabla2 = pd.merge(serieIncorrectos, serieCorrectos, "outer", "Cód. trámite")

#%%
#Punto 3
correctos["DiferenciaDias"] = correctos["Fecha de asociación del documento"] - correctos["Fecha de caratulación del expediente"]
correctos["DiferenciaDias"] = correctos["DiferenciaDias"] / np.timedelta64(1,'D')
correctos["weekyear"] = correctos["Fecha de asociación del documento"].dt.week
correctos = correctos.sort_values(by=["weekyear"])

def convertirSemana(weekyear):
    if(weekyear == 18):
        return "1 al 4 de Mayo"
    elif weekyear == 19 :
        return  "5 al 11 de Mayo"
    elif weekyear == 20 :
        return  "12 al 18 de Mayo"
    elif weekyear == 21 :
        return  "19 al 25 de Mayo"
    else:
        return "26 al 31 de Mayo"

correctos["semana"] = correctos['weekyear'].map(lambda x: convertirSemana(x))

#%%
Fito = correctos[correctos["Nombre del trámite"].str.contains("Fito")]
importacion = Fito[Fito["Nombre del trámite"].str.contains("mporta")]
exportacion = Fito[Fito["Nombre del trámite"].str.contains("xporta")]

#%%
def convertirTipo24H(nombre):
    if "24" in nombre:
        return "24 Horas"
    else:
        return "Normal"
#%%
importacion["tipo24"] = importacion["Nombre del trámite"].map(lambda x: convertirTipo24H(x))
#%%
exportacion["tipo24"] = exportacion["Nombre del trámite"].map(lambda x: convertirTipo24H(x))

#%%
importacion.groupby("tipo24").boxplot(by='semana',
                       column=['DiferenciaDias'],
                       grid=False)
plt.show()

#%%
exportacion.groupby("tipo24").boxplot(by='semana',
                       column=['DiferenciaDias'],
                       grid=False)
plt.show()