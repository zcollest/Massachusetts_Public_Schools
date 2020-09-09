# Regression for ALL 

# Loops to optimize regression models
fitall <- lm(college ~ per_pupil + sat_math + actualNSS, data=collegeattendvars)
summary(fitall) # show results
plot(fitall)

collegeattendvars = collegeattendvars[-c(137),]

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