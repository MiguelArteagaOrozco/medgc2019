# -*- coding: utf-8 -*-
"""
BankNote

https://stackabuse.com/implementing-svm-and-kernel-svm-with-pythons-scikit-learn/
"""
#%%
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

#%%
path = "data/BankNote_Authentication.csv"
bankdata = pd.read_csv(path, sep=",")
#%%
bankdata.columns
bankdata.head()
#%%
X = bankdata.drop('class', axis=1)
y = bankdata['class']

#%%
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.20)
#%%
from sklearn.svm import SVC
svclassifier = SVC(kernel='linear')
svclassifier.fit(X_train, y_train)
#%%
y_pred = svclassifier.predict(X_test)
#%%
from sklearn.metrics import classification_report, confusion_matrix
print(confusion_matrix(y_test,y_pred))
print(classification_report(y_test,y_pred))