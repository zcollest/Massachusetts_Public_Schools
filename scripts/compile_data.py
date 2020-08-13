import pandas as pd
import numpy as np
from functools import reduce
import os

os.chdir('/Users/zacharycollester/Documents/ma_public_schools/data/')
#-----------------------------------------#
#COMPILING MA PUBLIC SCHOOL DISTRCICT DATA#
#-----------------------------------------#

# important notes before running compilation function:
#   1. should edit column names manually in excel first
#   2. should delete $ signs or other special characters in excel first (except commas)
#   3. put pathlist data in desired order to show up in dataframe
#   4. if data isn't available for all columns, columns receive 99999 input

# function for compiling district data
def compile_data(path):
    dflist = list()
    # generating list of files from data directory path
    pathlist = list()
    for filename in os.listdir(path):
        if filename.endswith(".csv"):
            pathlist.append(filename)
    pathlist.sort()
    # looping through data files, appending each df in a list
    for i in range(len(pathlist)):
        df = pd.read_csv(pathlist[i], sep=None, thousands = ',')
        df.columns = df.iloc[0]
        df = df.drop(df.index[0])
        df = df.drop(['District Code'], axis=1)
        dflist.append(df)
    # concatenating dfs into one large df
    data = reduce(lambda left,right: pd.merge(left,right,how='outer',on='District Name'), dflist)
    # removing nan columns and adding "99999" to missing cells
    data = data.loc[:, data.columns.notnull()]
    data = data.fillna(99999)
    return data

# calling function
data_directory = '/Users/zacharycollester/Documents/ma_public_schools/data/'
data = compile_data(path=data_directory)

# converting dtypes
data = data.astype(str)
float_columns = []
int_columns = []
for columns in data:
    if columns != "District Name":
        for value in data[columns]:
            if '.' in value:
                data[columns] = data[columns].astype(float)
                float_columns.append(columns)
                break
        if columns not in float_columns:
            int_columns.append(columns)
            data[columns] = data[columns].astype(int)

