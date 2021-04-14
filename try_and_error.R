

#### RELIGION (CHRISTIAN, NOT SPECIFIED, OTHER) #####

#########################################################
#### RELIGION (NONCPECIFIED, OTHER, ASIAN)          #####
#########################################################
status_cohort[] <- lapply(status_cohort, as.character)

status_cohort$religion 

     

notspecified_religion <- c("UNOBTAINABLE",
                           "")

christian_religion <- c("7TH DAY ADVENTIST",
                        "BAPTIST",
                        "CHRISTIAN SCIENTIST",
                        "PROTESTANT QUAKER",
                        "JEHOVAH'S WITNESS",
                        "CATHOLIC",
                        "GREEK ORTHODOX",
                        "ROMANIAN EAST. ORTH",
                        "EPISCOPALIAN"
)
other_religion <- c("BUDDHIST",
                    "MUSLIM",
                    "UNITARIAN-UNIVERSALIST",
                    "JEWISH",
                    "HEBREW")

asian_religion <- c("ASIAN - ASIAN INDIAN",
                    "ASIAN - CHINESE")


all_religion <- list(notspecified_religion, christian_religion, other_religion, asian_religion)

cohort_pao2$
for (i in all_religion) {
    print(i)
}

##########################################################
#### ETHNICITY (ASIAN, BLACK, HISPANIC, OTHER, WHITE)#####
##########################################################


black_ethnicity <- c("BLACK/AFRICAN",
                     "BLACK/AFRICAN AMERICAN",
                     "BLACK/CAPE VERDEAN",
                     "BLACK/HAITIAN")


hispanic_ethnicity <- c("HISPANIC OR LATINO",
                        "HISPANIC/LATINO - DOMINICAN",
                        "HISPANIC/LATINO - GUATEMALAN",
                        "HISPANIC/LATINO - PUERTO RICAN")

white_ethnicity <- c("WHITE - BRAZILIAN",
                     "WHITE - RUSSIAN")

other_ethnicity <- c("MULTI RACE ETHNICITY",
                     "PATIENT DECLINED TO ANSWER",
                     "UNABLE TO OBTAIN",
                     "UNKNOWN/NOT SPECIFIED")

# # Combine ethnicities to just OTHER
# status_cohort$ethnicity[status_cohort$ethnicity == "ASIAN" |
#                           status_cohort$ethnicity == "BLACK" |
#                           status_cohort$ethnicity == "HISPANIC"] <- "OTHER"

