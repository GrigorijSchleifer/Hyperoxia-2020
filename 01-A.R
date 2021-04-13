# why is day 7 set as a cutoff?
# a separate column (censor_7d) for censoring is created where patients with less than 7 days of stay and without AKI are assigned a 0

##############################################################
###################       GIT      ###########################
##############################################################
#  use_git_config(user.name = "Grigorij Schleifer", user.email = "chaosambulance@googlemail.com")
cohort_pao2 <- hyper %>%
    ##### how is this calculated #####
    filter(!is.na(time_weighted_24hr_pao2), los >= 1, age >= 16) %>%
    ####################################################################
    #### where is the admission time? What about the 6 hours?????? #####
    ####################################################################
    # assign two hyperoxia levels
    mutate(two_oxy_level = ifelse(time_weighted_24hr_pao2 >= 100, 1, 0)) %>% 
    # create 5 different levels of oxygenation
    mutate(
        many_oxy_level = case_when(
            time_weighted_24hr_pao2 <= 75 ~ "<= 75",
            time_weighted_24hr_pao2 > 75 &
                time_weighted_24hr_pao2 <= 100 ~ "> 75 & <= 100",
            time_weighted_24hr_pao2 > 100 &
                time_weighted_24hr_pao2 <= 150 ~ "> 100 & <= 150",
            time_weighted_24hr_pao2 > 150 &
                time_weighted_24hr_pao2 <= 200 ~ "> 150 & <= 200",
            time_weighted_24hr_pao2 > 200 ~ "> 200"
        )
    ) %>% # factorise hyperoxia levels
    mutate(many_oxy_level = factor(
        many_oxy_level,
        levels = c("<= 75",
                   "> 75 & <= 100",
                   "> 100 & <= 150",
                   "> 150 & <= 200",
                   "> 200")
    )) %>% 
    mutate(los_hos = as.numeric(difftime(dischtime, intime, units = "days"))) %>%
    rowwise() %>%
    mutate(
        cre_max_7d = max(
            mean_creatinine_day1,
            mean_creatinine_day2,
            mean_creatinine_day3,
            mean_creatinine_day4,
            mean_creatinine_day5,
            mean_creatinine_day6,
            mean_creatinine_day7,
            na.rm = T
        )
    ) %>%
    # removing "" from hyper$crrt_starttime and code use of RRT 
    mutate(crrt_starttime = fct_recode(crrt_starttime, NULL = "")) %>%
    mutate(crrt_start_day = as.numeric(difftime(crrt_starttime, intime, units = "days"))) %>% 
    # create aki definition as yes or no (no staging)
    mutate(
        aki_7day_new = ifelse(
            cre_max_7d >= admcreat + 0.3 |
                cre_max_7d >= admcreat * 1.5 |
                # add RRT
                crrt_start_day < 7 &
                !is.na(crrt_start_day),
            1,
            0
        )
    ####################################
    ########## AKI STAGING???? #########
    ####################################
    ) %>% # CENSORING
    mutate(censor = ifelse(los_hos < 2 & aki_7day_new == 0, 1, 0)) %>%
    mutate(censor_7d = case_when(los_hos < 7 &
                                     aki_7day_new == 0 ~ 1,
                                 TRUE ~ 0)) %>% 
    mutate(aki_48hr_c = ifelse(censor == 0, 0, 1)) %>% 
    mutate(aki_7day_c = ifelse(censor_7d == 0, 0, 1)) %>% 
    mutate( # categorizing age into ordered factor
        age_cat = case_when(
            age < 30 ~ "18-29 yr",
            age >= 30 & age < 40 ~ "30-39 yr",
            age >= 40 & age < 50 ~ "40-49 yr",
            age >= 50 & age < 60 ~ "50-59 yr",
            age >= 60 & age < 70 ~ "60-69 yr",
            age >= 70 & age < 80 ~ "70-79 yr",
            age >= 80 & age < 90 ~ "80-89 yr",
            age >= 90 ~ ">=90 yr",
            age >= 300 ~ "90"
        )
    ) %>%
    mutate(age_cat = factor(
        age_cat,
        levels =
            c(
                "18-29 yr",
                "30-39 yr",
                "40-49 yr",
                "50-59 yr",
                "60-69 yr",
                "70-79 yr",
                "80-89 yr",
                "90 yr",
                ">=90 yr"
            )
    )) %>%  # MERGING admission to hyper
    select(., !c("X")) %>% 
    inner_join(admissions.real, by = "hadm_id") # removing "X" column
    
# create a dataframe for status updates
status_cohort <- cohort_pao2 %>% 
    select(marital_status, religion, ethnicity, insurance)

# change all factors inside the columns to characters
status_cohort[] <- lapply(status_cohort, as.character)
# save a copy of a "characterised" data.frame just in case I screw things up
status_cohort_original <- status_cohort


######################################################################################
##########         Recreating and cleaning religion, ethnicity columns       #########
######################################################################################


status_cohort$marital_status[status_cohort$marital_status == ""] <- "UNKNOWN (DEFAULT)"

#### RELIGION (CHRISTIAN, NOT SPECIFIED, OTHER) #####
status_cohort$religion[status_cohort$religion == "UNOBTAINABLE" |
                           status_cohort$religion == ""] <- "NOT SPECIFIED"

status_cohort$religion[status_cohort$religion == "7TH DAY ADVENTIST" |
                           status_cohort$religion == "BAPTIST" |
                           status_cohort$religion == "CHRISTIAN SCIENTIST" |
                           status_cohort$religion == "PROTESTANT QUAKER" |
                           status_cohort$religion == "JEHOVAH'S WITNESS" |
                           status_cohort$religion == "CATHOLIC" |
                           status_cohort$religion == "GREEK ORTHODOX" |
                           status_cohort$religion == "ROMANIAN EAST. ORTH" |
                           status_cohort$religion == "EPISCOPALIAN"] <- "CHRISTIAN"

status_cohort$religion[status_cohort$religion == "BUDDHIST" |
                           status_cohort$religion == "MUSLIM" |
                           status_cohort$religion == "UNITARIAN-UNIVERSALIST" |
                           status_cohort$religion == "JEWISH" |
                           status_cohort$religion == "HEBREW"] <- "OTHER"


#### ETHNICITY (ASIAN, BLACK, HISPANIC, OTHER, WHITE)#####
status_cohort$ethnicity[status_cohort$ethnicity == "ASIAN - ASIAN INDIAN" |
                            status_cohort$ethnicity == "ASIAN - CHINESE"] <- "ASIAN"

status_cohort$ethnicity[status_cohort$ethnicity == "BLACK/AFRICAN" |
                            status_cohort$ethnicity == "BLACK/AFRICAN AMERICAN" |
                            status_cohort$ethnicity == "BLACK/CAPE VERDEAN" |
                            status_cohort$ethnicity == "BLACK/HAITIAN"] <- "BLACK"

status_cohort$ethnicity[status_cohort$ethnicity == "HISPANIC OR LATINO" |
                            status_cohort$ethnicity == "HISPANIC/LATINO - DOMINICAN" |
                            status_cohort$ethnicity == "HISPANIC/LATINO - GUATEMALAN" |
                            status_cohort$ethnicity == "HISPANIC/LATINO - PUERTO RICAN"] <- "HISPANIC"

status_cohort$ethnicity[status_cohort$ethnicity == "WHITE - BRAZILIAN" |
                            status_cohort$ethnicity == "WHITE - RUSSIAN"] <- "WHITE"

status_cohort$ethnicity[status_cohort$ethnicity == "MULTI RACE ETHNICITY" |
                            status_cohort$ethnicity == "PATIENT DECLINED TO ANSWER" |
                            status_cohort$ethnicity == "UNABLE TO OBTAIN" |
                            status_cohort$ethnicity == "UNKNOWN/NOT SPECIFIED"] <- "OTHER"

# # Combine ethnicity
# status_cohort$ethnicity[status_cohort$ethnicity == "ASIAN" |
#                           status_cohort$ethnicity == "BLACK" |
#                           status_cohort$ethnicity == "HISPANIC"] <- "OTHER"


#### INSURANCE #####
# Combine insurance
status_cohort$insurance[status_cohort$insurance == "Government" |
                            status_cohort$insurance == "Self Pay" |
                            status_cohort$insurance == "Private"] <- "Private/goverment/self"

status_cohort$insurance[status_cohort$insurance == "Medicaid" |
                            status_cohort$insurance == "Medicare"] <- "Medicaid/Medicare"

##########################################
########## change_status_columns #########
##########################################

change_status_columns <- function(df, df_status) {
    status_list <- c("marital_status", "religion", "ethnicity", "insurance")
    for (i in status_list) {
        df[, i] <- df_status[, i]
    }
    return(df)
}

cohort_pao2_status <- change_status_columns(cohort_pao2, status_cohort)

####################################################
#######          RENAMING COLUMNS          #########
####################################################

names(cohort_pao2) <- cohort_pao2 %>%
    gsub(x = names(.),
         pattern = "\\.x",
         replacement = "")


##################################################
###########          AKI staging          ########
##################################################

# checks patients aki_stage and returns the result as number
check_aki <- function(df) {
    aki_stage <- 0
    df_mtx <- data.matrix(df[c("cre_max_7d", "admcreat")])
    
    cre_max_7d <- as.numeric(df_mtx["cre_max_7d",])
    admcreat <- as.numeric(df_mtx["admcreat",])
    
    if (cre_max_7d >= admcreat * 3) {
        aki_stage <- 3
    } else if (cre_max_7d >= admcreat * 2) {
        aki_stage <- 2
    } else if (cre_max_7d == 1 |
               cre_max_7d >= admcreat + 0.3 |
               cre_max_7d >= admcreat * 1.5) {
        aki_stage <- 1
    }
    return(aki_stage)
}

# uses the function check_aki for AKI staging
aki_stage <- function(df) {
    df$aki_stage <- apply(df, 1, check_aki)
    cohort_pao2_staged <- df
    return(cohort_pao2_staged)
}

cohort_pao2_staged <- aki_stage(cohort_pao2)

############################################################
##########          ROMOVE NA IN CHRONIC          ##########
############################################################
check_for_na_in_conditions <- function(df) {
    columns <- c(
        "has_chronic_lung_conditions",
        "has_chronic_heart_problems",
        "has_diabetes",
        "has_hypertension",
        "transfusion_first_24hr",
        "fluid_intake_first24hr",
        "transfusion_first_24hr"
    )
    
    for (i in columns) {
        df[[i]][is.na(df[[i]])] <- 0
    }
    return(df)
}

cohort_pao2 <- check_for_na_in_conditions(cohort_pao2)

######################################################################################
##########         ICU and HOSPITAL 30 days mortality indices and time      ##########
######################################################################################

attach(cohort_pao2)

# new column for ICU mortality and los < 20 and 0 for all NA
cohort_pao2$icu_mortality_20day[los <= 20] <- icu_mortality[los <= 20]
cohort_pao2$icu_mortality_20day[los > 20] <- 0


# new column for HOSPITAL mortality and los < 28 and 0 for all NA
cohort_pao2$hospmort28day[los <= 28] <- hospmort30day[los <= 28]
cohort_pao2$hospmort28day[los > 28] <- 0

cohort_pao2$hospmort60day[los <= 60] <- hospmort1yr[los <= 60]
# cohort_pao2$hospmort60day[los > 60] <- 0 # no NAs assigned above


# store los and assign 20 to all above 20 days of los
cohort_pao2$time_20[los <= 20] <- los[los <= 20]
cohort_pao2$time_20[los > 20] <- 20


# los_hos not los
# check for NA with the command "cohort_pao2$los_hos[is.na(cohort_pao2$time_)]"
cohort_pao2$time_28[los_hos <= 28] <- los_hos[los_hos <= 28]
cohort_pao2$time_28[los > 28] <- 28

cohort_pao2$time_30[los_hos <= 30] <- los_hos[los_hos <= 30]
cohort_pao2$time_30[los > 30] <- 30

cohort_pao2$time_60[los_hos <= 60] <- los_hos[los_hos <= 60]
cohort_pao2$time_60[los > 60] <- 60

detach(cohort_pao2)

####################################
##########     SAVING     ##########
####################################

write_csv(cohort_pao2, "~/Desktop/MIMIC_III/PT_Hyperoxia_2020/cohort_pao2.csv")






































# # without inclusion of RRT
# cohort_pao2 %>%
#     mutate(
#         aki_7day_new = ifelse(
#             cre_max_7d >= admcreat + 0.3 |
#                 cre_max_7d >= admcreat * 1.5,
#             1 ,
#             0
#         )
#     ) %>%
#     select(aki_7day_new) %>%
#     table(useNA = "always")
#
# # # with inclusion of RRT
# cohort_pao2 %>%
#     mutate(
#         aki_7day_new = ifelse(
#             cre_max_7d >= admcreat + 0.3 |
#                 cre_max_7d >= admcreat * 1.5 |
#                 crrt_start_day < 7 & !is.na(crrt_start_day),
#             1 ,
#             0
#         )
#     )  %>%
#     select(aki_7day_new) %>%
#     table(useNA = "always")
