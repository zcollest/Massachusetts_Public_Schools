# Regression for ALL 
normal <- data %>% filter(DistSize == "Normal")
normalvars <- data.frame(normal$`Average Class Size`, normal$`Average Salary`, normal$`Total Expenditures per Pupil`,
                                normal$reading_writing_all, normal$math_all, normal$`% All Completed Advanced`, normal$`% Exemplary`,
                                normal$`% Proficient`, normal$`% Needs Improvement`, normal$`Attending Coll./Univ. (%)`, normal$`Actual NSS as % of Required`, normal$G12)
normalvars <- normalvars %>% filter_all(all_vars(.!= 99999))
columns <- c('class_size', 'avg_salary', 'per_pupil', 'sat_rr', 'sat_math', 'advanced_course', 'exemplary', 'proficient', 'needs_improv', 'college', 'actualNSS','G12')
names(normalvars) <- columns

# Loops to optimize regression models
fitall <- lm(college ~ sat_math + avg_salary + per_pupil + advanced_course + needs_improv + actualNSS + exemplary, data=normalvars)
summary(fitall) # show results
plot(fitall)


collegeattendvars = collegeattendvars[-c(14,148),]

influence(fitall)
confint(fitall)
vcov(fitall)
Anova(fitall)

# Regression for low income 

fitlow <- lm(college ~ per_pupil + sat_math + actualNSS + avg_salary, data=lowinccollegeattendvars)
summary(fitlow) # show results
plot(fitlow)





collegeattendvars = collegeattendvars[-c(137),]

influence(fitall)
confint(fitall)
vcov(fitall)
Anova(fitall)



# Regression for hispanic

fithisp <- lm(college ~ sat_math, data=hispcollegeattendvars)
summary(fithisp) # show results
plot(fithisp)


collegeattendvars = collegeattendvars[-c(137),]

influence(fithisp)
confint(fithisp)
vcov(fithisp)
Anova(fithisp)


# Regression for large

fitbig <- lm(college ~sat_math, data=bigsumvars)
summary(fitbig) # show results
plot(fitbig)


bigsumvars = bigsumvars[-c(17),]

influence(fithisp)
confint(fithisp)
vcov(fithisp)
Anova(fithisp)