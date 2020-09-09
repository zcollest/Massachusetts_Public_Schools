library(tidyverse)
library(ggpubr)
library(rstatix)
library(car)
library(moments)
library(readr)
library(Hmisc)
library(corrplot)
library(arsenal)

#### IMPORTING DATA AND SPLITTING STATE TOTALS ####
# importing data 
data <- read_csv("/Users/zacharycollester/Documents/ma_public_schools/data/csv_R/data.csv")

# getting state total data
statetotals <- data.frame(data[407,])
# removing state total and Hampden school from dataframe
data <- data[-c(407,408),]


#### MISSING DATA / ENROLLMENT DATA ####   
# missing data
nalist <- vector()
for (i in 1:ncol(data)){
  total <- sum(data[,i] == 99999)
  nalist[i] <- total
}
nalist <- data.frame(nalist)
missingdata <- ggplot(nalist, aes(x=nalist)) + geom_histogram(color="black", fill="lightblue") + 
  geom_vline(aes(xintercept=mean(nalist)),color="darkblue", linetype="dashed", size=1) +
  labs(y="Frequency",x="Number of Missing Data Points") +
  ggtitle("Histogram of Missing Data")
missingdata

# total enrollment per district
enrollment <- vector()
for (i in 1:nrow(data)){
  enrollment[i] <- as.integer(data[i,"Total"])
}
enrollment <- data.frame(enrollment)
enrollmentdata <- ggplot(enrollment, aes(x=enrollment)) + geom_histogram(color="black", fill="lightblue") + 
  geom_vline(aes(xintercept=median(enrollment)),color="darkblue", linetype="dashed", size=1) +
  labs(y="Frequency",x="Number of Students") +
  ggtitle("Histogram of Total Enrollment by District")
enrollmentdata



## COLLEGE ATTENDANCE DATA FOR ALL DISTRICTS ##
# all
college <- data.frame(data$`Attending Coll./Univ. (%)`,'All')
# white
collegewhite <- data.frame(data$`White Attending Coll./Univ. (%)`,'White')
# black
collegeblack <- data.frame(data$`Black Attending Coll./Univ. (%)`,'Black')
# hisp
collegehisp <- data.frame(data$`Hisp Attending Coll./Univ. (%)`,'Hispanic/Latino')
# low income
collegeecon <- data.frame(data$`Low Income Attending Coll./Univ. (%)`,'Low Income')
# changing column names
dflist = list(college=college, collegewhite=collegewhite, collegeblack=collegeblack, collegehisp=collegehisp, collegeecon=collegeecon)
colnames <- c("Percent", "Group")
list2env(lapply(dflist, setNames, colnames), .GlobalEnv)
# rbinding all groups, removing null data
collegeattend <- rbind(college,collegewhite,collegeblack,collegehisp,collegeecon)
collegeattend <- filter(collegeattend, Percent != 99999)
# boxplot
collegeboxplot <- ggplot(collegeattend, aes(x=Group, y=Percent, fill=Group)) + 
  geom_boxplot(alpha=0.3) + theme(legend.position="none") +
  scale_fill_brewer(palette="BuPu") +
  ggtitle("Boxplot of College Attendance \nby Racial/Socioeconomic Group") +
  geom_hline(aes(yintercept=statetotals$Attending.Coll..Univ......1),color="darkblue", linetype="dashed", size=1)
collegeboxplot


#### COMPARISON OF MEANS OF COLLEGE ATTENDANCE BY GROUP FOR ALL DISTRICTS ####
# Shapiro Test of Normality for College Attendance (not normal)      
collegeattend %>%
  group_by(Group) %>%
  shapiro_test(Percent)

# Levene Test for Homogeneity of Variances (variance is homogenous)
leveneTest(Percent ~ Group, data = collegeattend)

# Kruskall Wallace Test
kruskal.test(Percent ~ Group, data = collegeattend)
# Multiple Comparisons with Wilcox Test
pairwise.wilcox.test(collegeattend$Percent, collegeattend$Group,
                     p.adjust.method = "BH")

#### COMPARISON OF MEANS OF ALL COLLEGE ATTENDANCE BETWEEN ALL AND LARGE DISTRICTS ####
alldistrictsize <- rbind(allcoll,allbigcoll)  ## variables from other R script
# Shapiro Test of Normality for College Attendance (not normal)      
alldistrictsize %>%
  group_by(group) %>%
  shapiro_test(percent)

# Levene Test for Homogeneity of Variances (variance is homogenous)
leveneTest(percent ~ group, data = alldistrictsize)

# Kruskall Wallace Test
kruskal.test(percent ~ group, data = alldistrictsize)


#### EXAMINING ENROLLMENT AND COLLEGE ATTENDANCE ####
# Scatter plot of enrollment vs college attendance
enrollattend <- data.frame(data$`District Name`,data$Total,data$`Attending Coll./Univ. (%)`, data$`White Attending Coll./Univ. (%)`,
                           data$`Black Attending Coll./Univ. (%)`, data$`Hisp Attending Coll./Univ. (%)`, 
                           data$`Low Income Attending Coll./Univ. (%)`)
colnames <- c('distname','enroll','all','white','black','hisp','lowincome')
names(enrollattend) <- colnames
enrollattend <- enrollattend %>% filter(all != 99999)
ggplot(enrollattend, aes(x=enroll, y=all)) + geom_point() + geom_hline(aes(yintercept=median(all)),color="darkblue", linetype="dashed", size=1)
enrollattend <- enrollattend %>% filter(hisp != 99999)
ggplot(enrollattend, aes(x=enroll, y=hisp)) + geom_point() + geom_hline(aes(yintercept=median(hisp)),color="darkblue", linetype="dashed", size=1)
enrollattend <- enrollattend %>% filter(lowincome != 99999)
ggplot(enrollattend, aes(x=enroll, y=lowincome)) + geom_point() + geom_hline(aes(yintercept=median(lowincome)),color="darkblue", linetype="dashed", size=1)
enrollattend <- enrollattend %>% filter(black != 99999)
ggplot(enrollattend, aes(x=enroll, y=black)) + geom_point() + geom_hline(aes(yintercept=median(black)),color="darkblue", linetype="dashed", size=1)
enrollattend <- enrollattend %>% filter(white != 99999)
ggplot(enrollattend, aes(x=enroll, y=white)) + geom_point() + geom_hline(aes(yintercept=median(white)),color="darkblue", linetype="dashed", size=1)




# DATAFRAME AND CORRELATION MATRIX OF POTENTIAL PREDICTORS (ALL)
collegeattendvars <- data.frame(data$`Average Class Size`, data$`Average Salary`, data$`Total Expenditures per Pupil`,
                                data$reading_writing_all, data$math_all, data$`% All Completed Advanced`, data$`% Exemplary`,
                                data$`% Proficient`, data$`% Needs Improvement`, data$`Attending Coll./Univ. (%)`, data$`Actual NSS as % of Required`)
collegeattendvars <- collegeattendvars %>% filter_all(all_vars(.!= 99999))
columns <- c('class_size', 'avg_salary', 'per_pupil', 'sat_rr', 'sat_math', 'advanced_course', 'exemplary', 'proficient', 'needs_improv', 'college', 'actualNSS')
names(collegeattendvars) <- columns
newdata <- collegeattendvars[,-1]

# Correlation Matrix of Predictor Variables (with pearson R2 values)
res <- rcorr(as.matrix(collegeattendvars), type = "pearson")
col <- colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))
corrplot(res$r, method = "color", col = col(200),
         type = "upper", order = "hclust", number.cex = .7,
         addCoef.col = "black", # Add coefficient of correlation
         tl.col = "black", tl.srt = 45, # Text label color and rotation
         # Combine with significance
         p.mat = res$P, sig.level = 0.01, insig = "blank", 
         # hide correlation coefficient on the principal diagonal
         diag = FALSE)


# DATAFRAME AND CORRELATION MATRIX OF POTENTIAL PREDICTORS (HISPANIC)
hispcollegeattendvars <- data.frame(data$`Average Class Size`, data$`%_staff_hispanic`, data$enroll_hispanic, data$`Average Salary`, data$`Total Expenditures per Pupil`,
                                data$reading_writing_hispanic, data$math_hispanic, data$`%_complete_advanced_hispanic`, data$`% Exemplary`,
                                data$`% Proficient`, data$`% Needs Improvement`, data$`Hisp Attending Coll./Univ. (%)`, data$`Actual NSS as % of Required`)
hispcollegeattendvars <- hispcollegeattendvars %>% filter_all(all_vars(.!= 99999))
columns <- c('class_size','hisp_staff', 'enroll_hisp', 'avg_salary', 'per_pupil', 'sat_rr', 'sat_math', 'advanced_course', 'exemplary', 'proficient', 'needs_improv', 'college', 'actualNSS')
names(hispcollegeattendvars) <- columns

# Correlation Matrix of Predictor Variables (with pearson R2 values)
res <- rcorr(as.matrix(hispcollegeattendvars), type = "pearson")
col <- colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))
corrplot(res$r, method = "color", col = col(200),
         type = "upper", order = "hclust", number.cex = .7,
         addCoef.col = "black", # Add coefficient of correlation
         tl.col = "black", tl.srt = 45, # Text label color and rotation
         # Combine with significance
         p.mat = res$P, sig.level = 0.01, insig = "blank", 
         # hide correlation coefficient on the principal diagonal
         diag = FALSE)



# DATAFRAME AND CORRELATION MATRIX OF POTENTIAL PREDICTORS (LOW INCOME)
lowinccollegeattendvars <- data.frame(data$`Average Class Size`, data$enroll_low_econ, data$`Average Salary`, data$`Total Expenditures per Pupil`,
                                    data$reading_writing_lowincome, data$math_lowincome, data$`%_complete_advanced_lowincome`, data$`% Exemplary`,
                                    data$`% Proficient`, data$`% Needs Improvement`, data$`Low Income Attending Coll./Univ. (%)`, data$`Actual NSS as % of Required`)
lowinccollegeattendvars <- lowinccollegeattendvars %>% filter_all(all_vars(.!= 99999))
columns <- c('class_size', 'enroll_lowincome', 'avg_salary', 'per_pupil', 'sat_rr', 'sat_math', 'advanced_course', 'exemplary', 'proficient', 'needs_improv', 'college', 'actualNSS')
names(lowinccollegeattendvars) <- columns

# Correlation Matrix of Predictor Variables (with pearson R2 values)
res <- rcorr(as.matrix(lowinccollegeattendvars), type = "pearson")
col <- colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))
corrplot(res$r, method = "color", col = col(200),
         type = "lower", order = "hclust", number.cex = .7,
         addCoef.col = "black", # Add coefficient of correlation
         tl.col = "black", tl.srt = 45, # Text label color and rotation
         # Combine with significance
         p.mat = res$P, sig.level = 0.01, insig = "blank", 
         # hide correlation coefficient on the principal diagonal
         diag = FALSE)


# Multiple regression for all districts (all, hispanic, low income)
# Multiple regression for big districts (all)
# state total includes values not reported 

# while graduation rates are lower for all big disrict groups, I am lead to believe that 
# most of the differences in college attendnace rates for different racial/socioeconomic groups is 
# not strictly due to district size. There also just may not be enough data. In general, college
# attendance rates for all racial/socioeconomic groups decline in larger districts. 

# Therefore, I want to look at multivariate regressions for all districts and stratify those by the three
# significant groups.


