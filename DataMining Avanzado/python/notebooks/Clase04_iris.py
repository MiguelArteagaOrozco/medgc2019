# -*- coding: utf-8 -*-
"""
IRIS

https://stackabuse.com/implementing-svm-and-kernel-svm-with-pythons-scikit-learn/
"""
#%%
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

#%%
url = "https://archive.ics.uci.edu/ml/machine-learning-databases/iris/iris.data"

# Assign colum names to the dataset
colnames = ['sepal-length', 'sepal-width', 'petal-length', 'petal-width', 'Class']

# Read dataset to pandas dataframe
irisdata = pd.read_csv(url, names=colnames)

#%% Preprocessing
X = irisdata.drop('Class', axis=1)
y = irisdata['Class']

#%% conversion a numerico
filas = y[y=='Iris-setosa'].index
y1 = y.copy()
y1[y.index] = 0
y1[filas] = 1

#%% Training test split
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y1, test_size = 0.20)

#%% polinomial kernel de grado 8
from sklearn.svm import SVC
svclassifier = SVC(kernel='poly', degree=8)
svclassifier.fit(X_train, y_train)

#%% making prediction
y_pred = svclassifier.predict(X_test)

#%% evaluating alg.
from sklearn.metrics import classification_report, confusion_matrix
print(confusion_matrix(y_test, y_pred))
print(classification_report(y_test, y_pred))