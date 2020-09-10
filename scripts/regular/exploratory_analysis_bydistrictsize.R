

# Hispanic/Latinx College Attendance by District Size

col <- 'percent'
hispaniccoll <- data.frame(data$`Hisp Attending Coll./Univ. (%)`)
names(hispaniccoll) <- col
hispaniccoll$group <- 'All Districts'
hispaniccoll <- hispaniccoll %>% filter_all(all_vars(.!= 99999))

hispanicbigcoll <- data %>% filter(Total > 6000)
hispanicbigcoll <- data.frame(hispanicbigcoll$`Hisp Attending Coll./Univ. (%)`)
names(hispanicbigcoll) <- col
hispanicbigcoll$group <- 'Big Districts'
hispanicbigcoll <- hispanicbigcoll %>% filter_all(all_vars(.!= 99999))

hispanicsmallcoll <- data %>% filter(Total < 6000)
hispanicsmallcoll <- data.frame(hispanicsmallcoll$`Hisp Attending Coll./Univ. (%)`)
names(hispanicsmallcoll) <- col
hispanicsmallcoll$group <- 'Small Districts'
hispanicsmallcoll <- hispanicsmallcoll %>% filter_all(all_vars(.!= 99999))

total <- rbind(hispaniccoll,hispanicbigcoll, hispanicsmallcoll)

hispaniccollboxplot <- ggplot(total, aes(x=group, y=percent, fill=group)) + 
  geom_boxplot(alpha=0.3) + theme(legend.position="none") +
  scale_fill_brewer(palette="BuPu") +
  ggtitle("Boxplot of Hispanic College Attendance \nby District Size") +
  geom_hline(aes(yintercept=statetotals$Hisp.Attending.Coll..Univ......1),color="darkblue", linetype="dashed", size=1)
hispaniccollboxplot


# Low Income College Attendance by District Size

col <- 'percent'
lowincomecoll <- data.frame(data$`Low Income Attending Coll./Univ. (%)`)
names(lowincomecoll) <- col
lowincomecoll$group <- 'All Districts'
lowincomecoll <- lowincomecoll %>% filter_all(all_vars(.!= 99999))

lowincomebigcoll <- data %>% filter(Total > 6000)
lowincomebigcoll <- data.frame(lowincomebigcoll$`Low Income Attending Coll./Univ. (%)`)
names(lowincomebigcoll) <- col
lowincomebigcoll$group <- 'Big Districts'
lowincomebigcoll <- lowincomebigcoll %>% filter_all(all_vars(.!= 99999))

lowincomesmallcoll <- data %>% filter(Total < 6000)
lowincomesmallcoll <- data.frame(lowincomesmallcoll$`Low Income Attending Coll./Univ. (%)`)
names(lowincomesmallcoll) <- col
lowincomesmallcoll$group <- 'Small Districts'
lowincomesmallcoll <- lowincomesmallcoll %>% filter_all(all_vars(.!= 99999))

total <- rbind(lowincomecoll,lowincomebigcoll, lowincomesmallcoll)

lowincomecollboxplot <- ggplot(total, aes(x=group, y=percent, fill=group)) + 
  geom_boxplot(alpha=0.3) + theme(legend.position="none") +
  scale_fill_brewer(palette="BuPu") +
  ggtitle("Boxplot of Low Income College Attendance \nby District Size") +
  geom_hline(aes(yintercept=statetotals$Low.Income.Attending.Coll..Univ......1),color="darkblue", linetype="dashed", size=1)
lowincomecollboxplot
mean(lowincomebigcoll$percent)
# PREDICTOR VARIABLES BY DISTRICT SIZE # 

# all districts
sumvars <- data.frame(data$`District Name`, data$Total, data$`Average Class Size`, data$`Average Salary`, data$`Total Expenditures per Pupil`,
                      data$reading_writing_all, data$math_all, data$`% All Completed Advanced`, data$`% Exemplary`,
                      data$`% Proficient`, data$`% Needs Improvement`, data$`Attending Coll./Univ. (%)`)
sumvars <- sumvars %>% filter_all(all_vars(.!= 99999))
columns <- c('name', 'total', 'class_size', 'avg_salary', 'per_pupil$', 'sat_rr', 'sat_math', 'advanced_course', 'exemplary', 'proficient', 'needs_improv', 'college')
names(sumvars) <- columns
sumvars$group <- 'All'

# big districts
bigsumvars <- data %>% filter(Total > 6000)
bigsumvars <- data.frame(bigsumvars$`District Name`,bigsumvars$Total, bigsumvars$`Average Class Size`, bigsumvars$`Average Salary`, bigsumvars$`Total Expenditures per Pupil`,
                         bigsumvars$reading_writing_all, bigsumvars$math_all, bigsumvars$`% All Completed Advanced`, bigsumvars$`% Exemplary`,
                         bigsumvars$`% Proficient`, bigsumvars$`% Needs Improvement`, bigsumvars$`Attending Coll./Univ. (%)`, bigsumvars$`Actual NSS as % of Required`, bigsumvars$`Teacher % Retained`)
bigsumvars <- bigsumvars %>% filter_all(all_vars(.!= 99999))
columns <- c('name', 'total', 'class_size', 'avg_salary', 'per_pupil', 'sat_rr', 'sat_math', 'advanced_course', 'exemplary', 'proficient', 'needs_improv', 'college','actualNSS','retained')
names(bigsumvars) <- columns
bigsumvars$group <- 'Big Districts'

# small districts
smallsumvars <- data %>% filter(Total < 6000)
smallsumvars <- data.frame(smallsumvars$`District Name`,smallsumvars$Total, smallsumvars$`Average Class Size`, smallsumvars$`Average Salary`, smallsumvars$`Total Expenditures per Pupil`,
                           smallsumvars$reading_writing_all, smallsumvars$math_all, smallsumvars$`% All Completed Advanced`, smallsumvars$`% Exemplary`,
                           smallsumvars$`% Proficient`, smallsumvars$`% Needs Improvement`, smallsumvars$`Attending Coll./Univ. (%)`)
smallsumvars <- smallsumvars %>% filter_all(all_vars(.!= 99999))
columns <- c('name', 'total', 'class_size', 'avg_salary', 'per_pupil$', 'sat_rr', 'sat_math', 'advanced_course', 'exemplary', 'proficient', 'needs_improv', 'college')
names(smallsumvars) <- columns
smallsumvars$group <- 'Small Districts'

all_predictors <- rbind(sumvars,bigsumvars,smallsumvars)

table_one <- tableby(group ~ ., data = data[2:13], numeric.test = "kwt")
predictor_sum <- summary(table_one, title = "Variable Summary",text=TRUE, total=FALSE,test=TRUE, pfootnote=TRUE)
predictor_sum
