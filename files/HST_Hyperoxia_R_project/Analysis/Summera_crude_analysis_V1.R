# read_csv2 reads semicolon separated values
# read_csv reads comma separated values
mydata <- read_csv("Trauma_Hyperoxemia_v1-1.csv")
problems(mydata)
dim(mydata)
names(mydata)
skim(mydata)

# # create a recoded recoded_mean_pao2_24hr for AKI vs NO AKI
# # set NA as a character NA
# mydata <- mydata %>% 
#     mutate(recoded_aki_48h = dplyr::recode(aki_48hr, `1` = "AKI",
#                                            `0` = "NO AKI",
#                                           .default = NA_character_))
# 
# 
# 
# mydata %>% 
#     select(aki_48hr, mean_pao2_24hr) %>%
#     mutate(high_o2 = case_when(mean_pao2_24hr < 100 ~ "Normoxiemia",
#                                mean_pao2_24hr > 100 ~ "Hyperoxemia",
#                                mean_pao2_24hr == NA ~ "Unknown")) %>% 
#     group_by(high_o2) %>% 
#     table(as.factor(aki_48hr))
    

# dichotomize mean_PaO2 during 24 hr into high and low
# limit the cohort to patients who have mean_pao2_24hr measured and have at least 2 days of stay
pao2_48hr <- mydata %>%
    dplyr::filter(!is.na(mean_pao2_24hr), los >= 2) %>%
    mutate(pao2_level = ifelse(mean_pao2_24hr >= mean(mean_pao2_24hr, na.rm=TRUE), 1, 0))
# count number of patients with available mean PaO2 and los > 2 days
count(pao2_48hr)



pao2_48hr <- pao2_48hr %>%
    mutate(creat_change_24hr = mean_creatinine_24hr - admcreat,
           creat_change_2day = mean_creatinine_day2 - admcreat,
           creat_increase_24hr = ifelse(creat_change_24hr > 0, 1, 0),
           creat_increase_2day = ifelse(creat_change_2day > 0, 1, 0))

mydata %>% 
    select(aki_48hr, aki_stage_48hr) %>% 
    count(aki_48hr, aki_stage_48hr)

 mydata %>% 
    select(aki_48hr, aki_stage_48hr) %>%
    mutate(real_aki = ifelse(aki_stage_48hr == 0, 0, 1)) %>% 
    count(real_aki, aki_stage_48hr)

mydata %>% 
    ggplot(aes(as.factor(aki_stage_48hr), mean_spo2_24hr, 
                colour = as.factor(aki_stage_48hr))) +
    geom_boxplot() +
    labs(x = "AKI stage", y = "Mean PaO2") +
    theme(legend.position="none") +
    ylim(c(90, 100))
     









       
