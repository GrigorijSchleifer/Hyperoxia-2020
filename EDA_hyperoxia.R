# rm(list = ls())
# setwd("/Users/grigorijschleifer/Desktop/MIMIC_III/PT_Hyperoxia_2020")
# library(ProjectTemplate); load.project()
# par(mar=c(1,1,1,1)) to deal with the Error in plot.new() : figure margins too large


############################# EDA ###################################


hyper %>% filter(!is.na(mean_pao2_24hr), los >= 1) %>% summarize(n())


# What type of variation occurs within my variables?
# What type of covariation occurs between my variables?

glimpse(hyper)

##### age ##### 
# age distirbution
ggplot(hyper) +
    geom_bar(mapping = aes(x = age), binwidth = 10)
# table age distribution with a defined interval, similar to binwidth

hyper %>% 
    count(cut_width(age, 10)) 

hyper %>% 
    count(gender, hospital_mortality)
    

###### Difference in admission type (emergent vs elective) based on gender
# creates the observer difference 
diff_orig <- hyper %>%   
    # Group by gender
    group_by(hospital_mortality) %>%
    # Summarize proportion of emergency patients
    summarize(prop = mean(admission_type == 'EMERGENCY')) %>%
    # Summarize difference in proportion of admission
    summarize(obs_diff_prop = diff(prop))

 
hyper %>%
    select(admission_type, hospital_mortality) %>% 
    filter(admission_type %in% c("EMERGENCY",'ELECTIVE')) %>% 
    mutate(hospital_mortality_fct = as.factor(hospital_mortality)) %>% 
    specify(response = hospital_mortality_fct, explanatory = admission_type, success = "1") %>%  # test whether the admission_type is independent of gender
    hypothesize(null = "independence") %>%
    generate(reps = 1000, type = "permute") %>%
    calculate(stat = "diff in props",  order = c("EMERGENCY","ELECTIVE")) %>%
    visualise()

mean(hyper$icu_mortality[hyper$admission_type == "EMERGENCY"])
# 0.09042884

hyper %>%
    filter(admission_type %in% c("EMERGENCY",'ELECTIVE')) %>% 
    specify(admission_type ~ gender, success = "EMERGENCY") %>% # test whether the admission_type is independent of gender
    hypothesize(null = "independence") %>%
    generate(reps = 1000, type = "permute") %>%
    calculate(stat = "diff in props", order = c("M", "F")) %>% 
    ggplot(aes(x = stat)) +
    geom_dotplot(binwidth = 0.0003) +
    geom_density() +
    geom_vline(aes(xintercept = as.integer(diff_orig)),
               col = "red")



infer_dt %>% 
    summarise(sum(stat > as.integer(diff_orig)))
# counts the number of permuted observations that are greater that the original difference
# how many permuted observations had smaller proportion compared to the original observation

hyper %>% 
    count(hospital_mortality, aki_48hr)

##### Differece in icu mortality proprotion between male and female #####
diff_orig_mort <- hyper %>%   
    # Group by gender
    group_by(gender) %>%
    # Summarize proportion of dead patients based on their gender
    summarize(prop = mean(icu_mortality)) %>%
    # Summarize difference in mortality based on gender
    summarize(obs_diff_prop = diff(prop))


infer_dt_mort <- hyper %>%
    select(icu_mortality, gender) %>% 
    mutate(icu_mortality = factor(icu_mortality)) %>% 
    specify(icu_mortality ~ gender, success = "1") %>%
    hypothesize(null = "independence") %>%
    generate(reps = 1000, type = "permute") %>%
    calculate(stat = "diff in props", order = c("M", "F"))

ggplot(infer_dt_mort, aes(x = stat)) +
    geom_dotplot(binwidth = 0.0003) +
    geom_density() +
    geom_vline(aes(xintercept = as.numeric(diff_orig_mort)),
               col = "red")

##### Differece in hospital mortality proprotion between male and female #####
diff_orig_mort <- hyper %>%   
    # Group by gender
    group_by(gender) %>%
    # Summarize proportion of dead patients based on their gender
    summarize(prop = mean(hospital_mortality)) %>%
    # Summarize difference in mortality based on gender
    summarize(obs_diff_prop = diff(prop))


infer_dt_hosp_mort <- hyper %>%
    select(hospital_mortality, gender) %>% 
    mutate(hospital_mortality = factor(hospital_mortality)) %>% 
    specify(hospital_mortality ~ gender, success = "0") %>%
    hypothesize(null = "independence") %>%
    generate(reps = 100, type = "permute") %>%
    calculate(stat = "diff in props", order = c("M", "F"))

ggplot(infer_dt_hosp_mort, aes(x = stat)) +
    geom_dotplot(binwidth = 0.0003) +
    geom_density() +
    geom_vline(aes(xintercept = as.numeric(diff_orig_mort)),
               col = "red")
