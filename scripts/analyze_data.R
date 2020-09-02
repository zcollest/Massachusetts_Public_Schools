library(tidyverse)
library(ggpubr)
library(rstatix)
library(car)
library(moments)
library(readr)
library(Hmisc)
library(corrplot)

# importing data 
data <- read_csv("/Users/zacharycollester/Documents/ma_public_schools/data/csv_R/data.csv")

# getting state total data
statetotals <- data.frame(data[407,])
# removing state total and Hampden school from dataframe
data <- data[-c(407,408),]

## ENROLLMENT DATA ## 
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

## COLLEGE ATTENDANCE ##
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
  ggtitle("Boxplot of College Attendance \nby Racial/Socioeconomic Group")
collegeboxplot

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


# Summary Statistics for College Attendance
collegeattend %>% 
  group_by(Group) %>% 
  summarise(count = n(),
            min = min(Percent),
            max = max(Percent),
            mean = mean(Percent),
            median = median(Percent),
            std = sd(Percent))

# State Total Summary Statistics 
statetotals %>% 
  summarise(all = Attending.Coll..Univ......1,
            white = White.Attending.Coll..Univ......1,
            black = Black.Attending.Coll..Univ......1,
            hispanic = Hisp.Attending.Coll..Univ......1,
            lowincome = Low.Income.Attending.Coll..Univ......1)

# Enrollment Outlier Summary Statistics
enrollment_outliers <- data %>% filter(Total > 8000)
# getting rid of lawrence
enrollment_outliers <- enrollment_outliers[-5,]
enrollment_outliers %>% 
  summarise(all = mean(`Attending Coll./Univ. (%)`),
            white = mean(`White Attending Coll./Univ. (%)`),
            black = mean(`Black Attending Coll./Univ. (%)`),
            hispanic = mean(`Hisp Attending Coll./Univ. (%)`),
            lowincome = mean(`Low Income Attending Coll./Univ. (%)`)) 

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


# Dataframe of potential predictors (all)
collegeattendvars <- data.frame(data$`Average Class Size`, data$`Average Salary`, data$`Total Expenditures per Pupil`,
                                data$reading_writing_all, data$math_all, data$`% All Completed Advanced`, data$`% Exemplary`,
                                data$`% Proficient`, data$`% Needs Improvement`, data$`Attending Coll./Univ. (%)`)
collegeattendvars <- collegeattendvars %>% filter_all(all_vars(.!= 99999))
columns <- c('class_size', 'avg_salary', 'per_pupil$', 'sat_rr', 'sat_math', 'advanced_course', 'exemplary', 'proficient', 'needs_improv', 'college')
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






# see how correlation matrix changes for larger districts and smaller districts
# multiple regression for big districts (all, hispanic, low income)
# multiple regression for smaller districts (all)
# maybe redo stats and hypothesis testing for small and big district subsets



