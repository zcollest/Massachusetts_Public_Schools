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
os.chdir('/Users/zacharycollester/Documents/ma_public_schools/data/')

#-----------------------------------------#
#COMPILING MA PUBLIC SCHOOL DISTRCICT DATA#
#-----------------------------------------#

# important notes before running compilation function:
#   1. should edit column names manually in excel first
#   2. should delete $ signs or other special characters in excel first (except commas)
#   3. put pathlist data in desired order
#   4. if data isn't available for all columns, those columns are left blank

# function for compiling district data
def compile_data(pathlist):
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

# creating a list of paths for function
data_directory = '/Users/zacharycollester/Documents/ma_public_schools/data/'
file_list = []

for filename in os.listdir(data_directory):
    if filename.endswith(".csv"):
        file_list.append(filename)
file_list.sort()


# calling function
data = compile_data(file_list)


#----------------------------------------#
#CLEANING MA PUBLIC SCHOOL DISTRCICT DATA#
#----------------------------------------#
# taking care of blank values
#   assigning a large number to random values, and will ignore this nunber in analysis

blank_number = 999999
data = data.fillna(blank_number)
column_list = []

for columns in data:
   column_list.append(columns)

data = data.drop(data.iloc[:,[69,76]])

# changing dtypes


