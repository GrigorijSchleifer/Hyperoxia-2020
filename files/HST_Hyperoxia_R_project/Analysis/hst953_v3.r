library(dplyr)
library(ggplot2)
library(readr)
#install.packages("descr")
require(descr)
#install.packages("car")
library(car)
write.csv(df, file = "df.csv")
write.csv(df_matching, file = "df_matching.csv")

Trauma_Hyperoxemia_v3 <- read_csv("Trauma_Hyperoxemia_v3.csv")
admissions <- read_csv("admissions.csv")

mydata2 <- Trauma_Hyperoxemia_v3

mtcars <- mtcars

™# exclude people age less than 18 years old and transfered after 6 hours
mydata2 <- mydata2 %>%
  filter(mydata2$transfer_within_6hr == 1 , age >= 18)



# discribe time weighted spo2 24hr
summary(mydata2$time_weighted_24hr_spo2)
summary(mydata2$time_weighted_24hr_pao2)
length(which(mydata2$time_weighted_24hr_spo2 < 94))
length(which(mydata2$time_weighted_24hr_pao2 > 70))

# assign exposure based on pao2
cohort_pao2 <- mydata2 %>%
  filter(mydata2$time_weighted_24hr_pao2 >= 70, los >= 1) %>%
  mutate(oxy_level = 
           ifelse(time_weighted_24hr_pao2 >= 100, 1,0))

# assign exposure based on spo2 (patients wihtout pao2 measured)
cohort_spo2 <- mydata2 %>%
  filter(is.na(mydata2$time_weighted_24hr_pao2) == TRUE , los >= 1, 
        time_weighted_24hr_spo2 >= 94) %>%
  mutate(oxy_level = 
           ifelse(time_weighted_24hr_spo2 >= 98, 1,0))
  
# merge two groups 
df<- rbind(cohort_pao2,cohort_spo2)

# check censoring
df <- df %>%
  mutate(censor = 
           ifelse(los < 2 & aki_48hr == 0, 1,0))

df <- merge( df,admissions, by = "hadm_id")

df$has_chronic_lung_conditions[is.na(df$has_chronic_lung_conditions)] <- 0
df$has_chronic_heart_problems[is.na(df$has_chronic_heart_problems)] <- 0
df$has_diabetes[is.na(df$has_diabetes)] <- 0
df$has_hypertension[is.na(df$has_hypertension)] <- 0
df$transfusion_first_24hr[is.na(df$transfusion_first_24hr)] <- 0
df$marital_status[is.na(df$marital_status)] <- "UNKNOWN (DEFAULT)"
df$religion[is.na(df$religion)] <- "NOT SPECIFIED"
#df$marital_status[df$marital_status == "marital_statusUNKNOWN (DEFAULT)"] <- "UNKNOWN (DEFAULT)"
df$ethnicity[df$ethnicity == "ASIAN - ASIAN INDIAN" | 
             df$ethnicity == "ASIAN - CHINESE" | 
             df$ethnicity == "ASIAN - VIETNAMESE"] <- "ASIAN"

df$ethnicity[df$ethnicity == "BLACK/AFRICAN" | 
             df$ethnicity == "BLACK/AFRICAN AMERICAN" | 
             df$ethnicity == "BLACK/CAPE VERDEAN" |
             df$ethnicity == "BLACK/HAITIAN"] <- "BLACK"

df$ethnicity[df$ethnicity == "HISPANIC OR LATINO" | 
               df$ethnicity == "HISPANIC/LATINO - DOMINICAN" | 
               df$ethnicity == "HISPANIC/LATINO - GUATEMALAN" |
               df$ethnicity == "HISPANIC/LATINO - PUERTO RICAN" |
               df$ethnicity == "HISPANIC/LATINO - SALVADORAN" |
               df$ethnicity == "SOUTH AMERICAN"] <- "HISPANIC"

df$ethnicity[df$ethnicity == "WHITE - BRAZILIAN" | 
               df$ethnicity == "WHITE - RUSSIAN"] <- "WHITE"

df$ethnicity[df$ethnicity == "MULTI RACE ETHNICITY" | 
               df$ethnicity == "PATIENT DECLINED TO ANSWER" | 
               df$ethnicity == "UNABLE TO OBTAIN" |
               df$ethnicity == "UNKNOWN/NOT SPECIFIED"] <- "OTHER"

df$religion[df$religion == "7TH DAY ADVENTIST" | 
               df$religion == "BAPTIST" | 
               df$religion == "CHRISTIAN SCIENTIST" |
               df$religion == "PROTESTANT QUAKER" |
               df$religion == "JEHOVAH'S WITNESS" |
               df$religion == "CATHOLIC" |
               df$religion == "GREEK ORTHODOX" |
               df$religion == "ROMANIAN EAST. ORTH" |
               df$religion == "EPISCOPALIAN" ] <- "CHRISTIAN"

df$religion[df$religion == "BUDDHIST" | 
              df$religion == "MUSLIM" | 
              df$religion == "UNITARIAN-UNIVERSALIST" |
              df$religion == "JEWISH" |
              df$religion == "HEBREW" ] <- "OTHER"

df$religion[df$religion == "NOT SPECIFIED" | 
              df$religion == "UNOBTAINABLE" ] <- "UNKNOWN"

df$marital_status[df$marital_status == "NOT SPECIFIED" | 
              df$religion == "UNOBTAINABLE" ] <- "UNKNOWN"

df$age_cat[df$age < 30 ] <- "18-29 yr"
df$age_cat[df$age < 40 & df$age >= 30] <- "30-39 yr"
df$age_cat[df$age < 50 & df$age >= 40] <- "40-49 yr"
df$age_cat[df$age < 60 & df$age >= 50] <- "50-59 yr"
df$age_cat[df$age < 70 & df$age >= 60] <- "60-69 yr"
df$age_cat[df$age < 80 & df$age >= 70] <- "70-79 yr"
df$age_cat[df$age < 90 & df$age >= 80] <- "80-89 yr"
df$age_cat[df$age >= 90] <- ">=90 yr"

df_nolof <- df %>%
  filter(df$censor == 0)

table(df$oxy_level, df$censor) 
#substantial selection bias 


#####################################################
# Estimating IP weights to adjust for selection bias due to censoring
#####################################################

crosstab(df$censor, df$oxy_level, plot = F, format = "SAS")

# estimation of denominator of ip weights for not being censored
denom.cens <- glm(censor ~ oxy_level + as.factor(gender) + as.factor(age_cat) + as.factor(insurance) 
                    + as.factor(marital_status) + as.factor(ethnicity) + as.factor(religion)
                    + surg + sofa + as.factor(admission_type) + transfusion_first_24hr
                    + has_chronic_lung_conditions + has_chronic_heart_problems + has_diabetes + has_hypertension, 
                  family = binomial(), data = df)
summary(denom.cens)

denom.p.cens <- predict(denom.cens, type = "response")

# estimation of numerator of ip weights for not being censored
numer.cens <- glm(censor ~ oxy_level, family = binomial(), data = df)
summary(numer.cens)
numer.p.cens <- predict(numer.cens, type = "response")

# Estimation of stabilized weight for not being censored
df$sw.c <- ifelse(df$censor == 0, ((1-numer.p.cens)/(1-denom.p.cens)),
                      1)

summary(df$sw.c)
sd(df$sw.c)

# estimation of denominator of ip weights for treatment
denom.fit <- glm(oxy_level ~ as.factor(gender) + as.factor(age_cat) + as.factor(insurance) 
                 + as.factor(marital_status) + as.factor(ethnicity) + as.factor(religion)
                 + surg + sofa + as.factor(admission_type) + transfusion_first_24hr
                 + has_chronic_lung_conditions + has_chronic_heart_problems + has_diabetes + has_hypertension, 
                 family = binomial(), data = df)
summary(denom.fit)

denom.p <- predict(denom.fit, type = "response")

# estimation of numerator of ip weights for treatment
numer.fit <- glm(oxy_level ~ 1, family = binomial(), data = df)
summary(numer.fit)
numer.p <- predict(numer.fit, type = "response")

# Estimation of stabilized weight for treatment
df$sw.a <- ifelse(df$oxy_level == 0, ((1-numer.p)/(1-denom.p)),
                      (numer.p/denom.p))

summary(df$sw.a)

# Estimation of Stabilized Censoring weight (sw)
df$sw <- df$sw.a * df$sw.c
summary(df$sw)
sd(df$sw)

df_nolof <- df %>%
  filter(df$censor == 0)

#install.packages("geepack")
require(geepack)
#install.packages("multcomp")
library(multcomp)
#install.packages("BSagri")
library(BSagri)
#install.packages("sandwich")
require(sandwich)

# obtaining final estimates
glm.obj <- glm(aki_48hr ~ oxy_level + cluster(hadm_id), data = df, family = binomial(),
               weights = sw.a)
summary(glm.obj)

glm.obj2 <- glm(aki_48hr ~ oxy_level + cluster(hadm_id), data = df, family = quasibinomial(),
               weights = sw.a)
summary(glm.obj2)

comp<-glht(glm.obj2)
CIadj<-CIGLM(comp,method="Adj")
CIadj
vcov(glm.obj2)

beta <- coef(glm.obj2)
SE <-sqrt(diag(vcovHC(glm.obj2, type="HC0"))) # robust standard errors
lcl <- beta-1.96*SE 
ucl <- beta+1.96*SE
p.value <- 2*(1-pnorm(abs(beta/SE)))
round(cbind(beta, SE, lcl, ucl, p.value),1)[2,]


#####################################################
# Standard logistic regression
#####################################################

uni_logistic <- glm(formula = aki_48hr ~ oxy_level, 
                      data = df,
                      family = binomial)

summary(uni_logistic)
confint.lm(uni_logistic)

multi_logistic <- glm(formula = aki_48hr ~ oxy_level + as.factor(gender) + as.factor(age_cat) + as.factor(insurance) 
            + as.factor(marital_status) + as.factor(ethnicity) + as.factor(religion)
            + surg + sofa + as.factor(admission_type) + transfusion_first_24hr 
            + has_chronic_lung_conditions + has_chronic_heart_problems + has_diabetes + has_hypertension, 
            data = df,
            family = binomial)

logistic_cens <- glm(formula = aki_48hr ~ oxy_level + as.factor(gender) + as.factor(age_cat) + as.factor(insurance) 
                      + as.factor(marital_status) + as.factor(ethnicity) + as.factor(religion)
                      + surg + sofa + as.factor(admission_type) + transfusion_first_24hr 
                      + has_chronic_lung_conditions + has_chronic_heart_problems + has_diabetes + has_hypertension + cluster(hadm_id), 
                      data = df_nolof,
                      family = binomial(),
                      weights = sw.c)
summary(logistic_cens)
confint(logistic_cens)

multi_logistic_df <- multi_logistic$coefficients
write.csv(multi_logistic_df, "multi_logistic.csv")


#####################################################
# Propensity Score
#####################################################

# model to estimate propensity score
model3 <- glm(oxy_level ~ as.factor(gender) + as.factor(age_cat) + as.factor(insurance) 
              + as.factor(marital_status) + as.factor(ethnicity) + as.factor(religion)
              + surg + sofa + as.factor(admission_type) + transfusion_first_24hr
              + has_chronic_lung_conditions + has_chronic_heart_problems + has_diabetes + has_hypertension, 
              family = binomial(), data = df)

#install.packages("DescTools")
library(DescTools)
Cstat(model3)
# summary(model3) to see the results...

# predict PS values and assign to variable in dataset
df$p.oxy <- predict(model3, df, 'response')

df$ps <- denom.p

# view summary statistics for PS by oxy_level (base R method)
with(df, by(ps, oxy_level, summary))

df$oxylabel = ifelse(df$oxy_level == 1,
                   yes = 'Liberal',
                   no = 'Conservative')

# plot PS distribution by oxy_level status (much more helpful)
ggplot(df, aes(x = ps, fill = oxylabel)) + geom_density(alpha = 0.2) +
  xlab('Probability of Having Liberal Oxygen Level') +
  ggtitle('Propensity Score Distribution') +
  scale_fill_discrete('') +
  theme(legend.position = 'bottom', legend.direction = 'vertical')

# attempt to reproduce plot from the book
df %>%
  mutate(ps.grp = round(ps/0.05) * 0.05) %>%
  group_by(oxy_level, oxylabel, ps.grp) %>%
  summarize(n = n()) %>%
  ungroup() %>%
  mutate(n2 = ifelse(oxy_level == 0, yes = n, no =  -1*n)) %>%
  ggplot(aes(x = ps.grp, y = n2, fill = oxylabel)) +
  geom_bar(stat = 'identity', position = 'identity') +
  geom_text(aes(label = n, x = ps.grp, y = n2 + ifelse(oxylabel == 0, 8, -8))) +
  xlab('Probability of Having Liberal Oxygen Level') +
  ylab('N') +
  ggtitle('Propensity Score Distribution by Treatment Group') +
  scale_fill_discrete('') +
  scale_x_continuous(breaks = seq(0, 1, 0.05)) +
  theme(legend.position = 'bottom', legend.direction = 'vertical',
        axis.ticks.y = element_blank(),
        axis.text.y = element_blank())

#######################################################################################
#### Stratification on the propensity score                                      
#######################################################################################

library(gtools)

# function to create deciles easily
decile <- function(x) {
  return(factor(quantcut(x, seq(0, 1, 0.1), labels = FALSE)))
}

# regression on PS deciles, not allowing for effect modification
model4 <- glm(aki_48hr ~ oxy_level + decile(p.oxy), data = df, family = binomial())
summary(model4)
confint.lm(model4)

model5 <- glm(aki_48hr ~ oxy_level + decile(p.oxy) + cluster(hadm_id), data = df_nolof, family = binomial(), weight=sw.c)
summary(model5)
confint.lm(model5)

ps_matched <- glm(aki_48hr ~ oxy_level.y, data = df_matching, family = binomial())
summary(ps_matched)
confint.lm(ps_matched)

library(dplyr)      # easy, readable data manipulation
library(multcomp)   # estimation of linear contrasts from GLMs
library(ggplot2)    # graphics
library(gtools)     # easy decile creation
#install.packages("infoDecompuTE")
library(infoDecompuTE)

#######################################################################################
#### Standardization using the propensity score                                    ####
#######################################################################################

# regression on the propensity score (linear term)
model6 <- glm(aki_48hr ~ oxy_level + p.oxy, data = df_nolof, family = binomial())
summary(model6)

model7 <- glm(aki_48hr ~ oxy_level + p.oxy + cluster(hadm_id), data = df_nolof, weight = sw.c, family = binomial())
summary(model7)


# standarization on the propensity score
# (step 1) create two new datasets, one with all treated and one with all untreated
treated <- df_nolof
treated$oxy_level <- 1

untreated <- df_nolof
untreated$oxy_level <- 0

# (step 2) predict values for everyone in each new dataset based on above model
treated$pred.y <- predict(model7, treated)
untreated$pred.y <- predict(model7, untreated)

# (step 3) compare mean weight loss had all been treated vs. that had all been untreated
mean1 <- mean(treated$pred.y, na.rm = TRUE)
mean0 <- mean(untreated$pred.y, na.rm = TRUE)
mean1
mean0
mean1 / mean0

# (step 4) bootstrap a confidence interval
# number of bootstraps
nboot <- 100
# set up a matrix to store results
boots <- data.frame(i = 1:nboot,
                    mean1 = NA,
                    mean0 = NA,
                    difference = NA)
# loop to perform the bootstrapping
df_b <- subset(df, !is.na(p.oxy))
for(i in 1:nboot) {
  # sample with replacement
  sampl <- df_b[sample(1:nrow(df_b), nrow(df_b), replace = TRUE), ]
  
  # fit the model in the bootstrap sample
  bootmod <- glm(aki_48hr ~ oxy_level + p.oxy + cluster(hadm_id), data = df_nolof, weight = sw.c, family = binomial())
  
  # create new datasets
  sampl.treated <- sampl %>%
    mutate(oxy_level = 1)
  
  sampl.untreated <- sampl %>%
    mutate(oxy_level = 0)
  
  # predict values
  sampl.treated$pred.y <- predict(bootmod, sampl.treated)
  sampl.untreated$pred.y <- predict(bootmod, sampl.untreated)
  
  # output results 
  boots[i, 'odds1'] <- mean(sampl.treated$pred.y, na.rm = TRUE)
  boots[i, 'odds0'] <- mean(sampl.untreated$pred.y, na.rm = TRUE)
  boots[i, 'ratio'] <- boots[i, 'odds1'] / boots[i, 'odds0']
  
  # once loop is done, print the results
  if(i == nboot) {
    cat('95% CI for the causal odds ratio \n')
    cat(mean(boots$ratio) - 1.96*sd(boots$ratio), 
        ',',
        mean(boots$ratio) + 1.96*sd(boots$ratio))
  }
}

# a more flexible and elegant way to do this is to write a function 
# to perform the model fitting, prediction, bootstrapping, and reporting all at once
# view the code contained in the file mstandardize.R to learn more

# load the code for the mstandardize() function 
# (you may need to change the filepath)
source('chapter15_mstandardize.R') 

# performt the standardization
mstandardize(formula = aki_48hr ~ oxy_level + p.oxy, 
             family = 'binomial',
             trt = 'oxy_level', 
             nboot = 100, 
             data = df)

est <- read_csv("estimates.csv")
est$label <- factor(est$method)
mean  <- est$Mean
lower <- est$`Lower CI`
upper <- est$`Upper CI`
label <- est$method
forest <- data.frame(label, mean, lower, upper)
  
forest$label <- factor(forest$label, levels=rev(forest$label))

library(ggplot2)
ggplot(data=forest, aes(x=label, y=mean, ymin=lower, ymax=upper)) +
  geom_pointrange() + 
  geom_hline(yintercept=1, lty=2) +  # add a dotted line at x=1 after flip
  coord_flip() +  # flip coordinates (puts labels on y axis)
  xlab("Methods") + ylab("Odds Ratio (95% CI)") +
  theme_bw() 

fp <- ggplot(data=est, aes(x="method", y="Mean", ymin="Lower CI", ymax="Upper CI")) +
  geom_pointrange() + 
  geom_hline(yintercept=1, lty=2) +  # add a dotted line at x=1 after flip
  coord_flip() +  # flip coordinates (puts labels on y axis)
  xlab("X1") + ylab("Mean (95% CI)") +
  theme_bw()  # use a white background
print(fp)
