#-------------#
#GENERAL NOTES#
#-------------#

# data is separated by district, rather than by individual school
# data from 2017-2018 school year used since not all data is updated past that

#-----------------#
#ENVIRONMENT SETUP#
#-----------------#

# importing libraries
import pandas as pd
import numpy as np
from functools import reduce
import os

# changing working directory
os.chdir('/Users/zacharycollester/Documents/ma_public_schools/')

#------------------------------------------------------#
#COMPILING AND CLEANING MA PUBLIC SCHOOL DISTRCICT DATA#
#------------------------------------------------------#

# important notes before running compilation function:
#   1. should edit column names manually in excel first
#   2. should delete $ signs or other special characters in excel first (except commas)
#   3. put pathlist data in desired order
#   4. if data isn't available for all columns, those columns are left blank

# function for compiling district data
def compile_data(paths):
    dflist = list()
    # looping through data files, appending each df in a list
    for i in range(len(pathlist)):
        df = pd.read_csv(pathlist[i], sep=None, thousands = ',')
        df.columns = df.iloc[0]
        df = df.drop(df.index[0])
        df = df.drop(['District Code'], axis=1)
        dflist.append(df)
    # concatenating dfs into one large df and returning it
    data = reduce(lambda left,right: pd.merge(left,right,how='outer',on='District Name'), dflist)
    return data

# list of paths for function
pathlist = ["data/enrollmentbygrade.csv", "data/enrollmentbyracegender.csv",
"data/enrollselectedpopulations.csv", 'data/ClassSizebyGenPopulation.csv',
'data/ClassSizebyRaceEthnicity.csv', 'data/staffracegender.csv']

# calling function
data = compile_data(pathlist)

# general cleaning (if necessary - deleting unnecessary columns, etc.)

# changing dtypes

