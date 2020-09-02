import pandas as pd
import numpy as np
from functools import reduce
import os
import scipy.stats as stats
from sklearn import linear_model
import matplotlib.pyplot as plt
import seaborn as sns
import hvplot.pandas
from pingouin import pairwise_tukey

os.chdir('/Users/zacharycollester/Documents/ma_public_schools/data/df_data')
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
    data = data.loc[:,~data.columns.duplicated()]
    return data

# calling function
data_directory = '/Users/zacharycollester/Documents/ma_public_schools/data/df_data/'
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


data.to_csv(r'/Users/zacharycollester/documents/ma_public_schools/data/csv_R/data.csv', index = False)
# drop Hampden district and save district totals
statetotals = pd.DataFrame(data.iloc[406])
statetotals = statetotals.transpose()
data = data[0:406]

#-------------------------#
#EXPLORATORY DATA ANALYSIS#
#-------------------------#

#shape
data.shape

## MISSING DATA ##

# counting and visualizing missing data
nalist = list()
for name in data:
    total = (data[name] == 99999).sum()
    nalist.append(total)
plt.bar(range(len(data.columns)), nalist)
plt.ylabel('Frequency')
plt.xlabel('Column Index')
plt.title("Frequency of Missing Data per Column")
plt.show()



## ENROLLMENT DATA ##

# counting and visualizing enrollment data with histogram
enrollment = pd.Series(data['Total'], name="total no. students")
ax = sns.distplot(enrollment).set_title('distribution of total enrollment by district')
np.median(enrollment)
np.std(enrollment)
#   boston outlier
np.max(enrollment)
enrollment.skew()



## COLLEGE ATTENDANCE RATES FOR ALL, WHITE, BLACK, HISPANIC ##

# all
collegeattendall = pd.Series(data['Attending Coll./Univ. (%)'], name="all college attendance %")
collegeattendall = pd.Series([i for i in collegeattendall if i != 99999])
np.mean(collegeattendall)
np.std(collegeattendall)
collegeattendall.skew()
collegeattendall = pd.DataFrame(collegeattendall)
collegeattendall['Percent'] = collegeattendall.iloc[:,0]
collegeattendall['Ethnicity'] = 'All'
stat, p = stats.shapiro(collegeattendall)

#black
collegeattendblack = pd.Series(data['Black Attending Coll./Univ. (%)'], name="black college attendance %")
collegeattendblack = pd.Series([i for i in collegeattendblack if i != 99999])
np.mean(collegeattendblack)
np.std(collegeattendblack)
collegeattendblack.skew()
collegeattendblack = pd.DataFrame(collegeattendblack)
collegeattendblack['Percent'] = collegeattendblack.iloc[:,0]
collegeattendblack['Ethnicity'] = 'Black'

#hispanic
collegeattendhisp = pd.Series(data['Hisp Attending Coll./Univ. (%)'], name="hisp college attendance %")
collegeattendhisp = pd.Series([i for i in collegeattendhisp if i != 99999])
np.mean(collegeattendhisp)
np.std(collegeattendhisp)
collegeattendhisp.skew()
collegeattendhisp = pd.DataFrame(collegeattendhisp)
collegeattendhisp['Percent'] = collegeattendhisp.iloc[:,0]
collegeattendhisp['Ethnicity'] = 'Hispanic/Latino'

#white
collegeattendwhite = pd.Series(data['White Attending Coll./Univ. (%)'], name="white college attendance %")
collegeattendwhite = pd.Series([i for i in collegeattendwhite if i != 99999])
np.mean(collegeattendwhite)
np.std(collegeattendwhite)
collegeattendwhite.skew()
collegeattendwhite = pd.DataFrame(collegeattendwhite)
collegeattendwhite['Percent'] = collegeattendwhite.iloc[:,0]
collegeattendwhite['Ethnicity'] = 'White'

# economocially disadvantaged
collegeattendlowecon = pd.Series(data['Low Income Attending Coll./Univ. (%)'], name="low income college attendance %")
collegeattendlowecon = pd.Series([i for i in collegeattendlowecon if i != 99999])
np.mean(collegeattendlowecon)
np.std(collegeattendlowecon)
collegeattendlowecon.skew()
collegeattendlowecon = pd.DataFrame(collegeattendlowecon)
collegeattendlowecon['Percent'] = collegeattendlowecon.iloc[:,0]
collegeattendlowecon['Ethnicity'] = 'Low Income'

# boxplot of all
collegeattend = pd.concat([collegeattendall,collegeattendhisp,collegeattendwhite,collegeattendblack,collegeattendlowecon])
ax = sns.boxplot(data=collegeattend,x='Ethnicity',y='Percent').set_title('Boxplot of College Attendance by Ethnicity')

# one way ANOVA for hispanic vs. other races for college attendance
stats.f_oneway(collegeattendwhite,collegeattendhisp,collegeattendblack)
# creating model
model = ols('Percent ~ C(Ethnicity)', data=collegeattend).fit()
anova_table = sm.stats.anova_lm(model, typ=2)
anova_table
# multiple comparisons
m_comp = pairwise_tukey(data=collegeattend, dv='Percent', between='Ethnicity')
print(m_comp)
# checking ANOVA assumptions
w, pvalue = stats.shapiro(model.resid)
print(w, pvalue)


# one way anova non-parametric
stat, p = stats.kruskal(collegeattendall, collegeattendblack, collegeattendhisp)


## LOOKING AT PREDICTOR VARIABLES ##


## Potential Predictor Variables

# maybe add AP results
predictorvars = data.loc[:, ['enroll_low_econ',"Average Class Size","Total Expenditures per Pupil", "Average Salary", '% All Completed Advanced', 'reading_writing_all', 'math_all', '% Exemplary','% Proficient', '% Needs Improvement', 'Teacher % Retained','Low Income Attending Coll./Univ. (%)']]
predictorvarshisp = data.loc[:, ['%_staff_hispanic','enroll_hispanic','Percent Class Hispanic',"Average Class Size","Total Expenditures per Pupil", "Average Salary", '% All Completed Advanced', 'reading_writing_all', 'math_all', '% Exemplary','% Proficient', '% Needs Improvement', 'Teacher % Retained','Hisp Attending Coll./Univ. (%)']]
hey2 =  predictorvars[(predictorvars.iloc[:, 1:] != 99999).all(axis=1)]
heycorr = hey2.corr()
heycorr






# visualizing funding per student with histogram

fundingperstudent = pd.Series(data['Total Expenditures per Pupil'], name="total expenditures per pupil")
fundingperstudent = pd.Series([i for i in fundingperstudent if i != 99999])
ax = sns.distplot(fundingperstudent).set_title('distribution of per pupil expenditure by district')
np.mean(fundingperstudent)
np.std(fundingperstudent)
np.min(fundingperstudent)
np.max(fundingperstudent)
fundingperstudent.skew()

# average salaries

avgsal = pd.Series(data['Average Salary'], name="Average Salary")
avgsal = pd.Series([i for i in avgsal if i != 99999])
ax = sns.distplot(avgsal).set_title('average salary by district')
np.mean(avgsal)
np.std(avgsal)
np.min(avgsal)
np.max(avgsal)
avgsal.skew()

# sat score distributions (all)

# sat score distributions (non-white)

# sat score distributions (female)




#-------------------------#
#EXPLORATORY DATA ANALYSIS#
#-------------------------#

## FIND CORRELATIONS BETWEEN ALL PAIRS OF INTERESTING COLUMNS, BUT MUST SUBSET DATA FIRST ##


# advancednonwhite(money)
nonwhiteadvanced = data.loc[:, ["%_completedadvanced_nonwhite","Total Expenditures per Pupil","Average Salary"]]
indexNames = nonwhiteadvanced[nonwhiteadvanced["%_completedadvanced_nonwhite"] == 99999].index
nonwhiteadvanced.drop(indexNames , inplace=True)
nonwhiteadvanced.hvplot(x="%_completedadvanced_nonwhite", y=["Total Expenditures per Pupil","Average Salary"], kind='scatter',ylabel='USD',legend='right',xlabel='% non-white students completing advanced courses')

nonwhiteadvancedcorr = nonwhiteadvanced.corr()
nonwhiteadvancedcorr


# analyzing skew of predictor and target variables
for name in data:
    if name != 'District Name':
        print(data[name].skew())




#----------------------------------#
#REGRESSION ANALYSIS FOR SAT SCORES#
#----------------------------------#

# go through list of things to check for to make a good model (assumptions screenshot)
