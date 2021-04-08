status_cohort <- cohort_pao2 %>% 
    select(marital_status, religion, ethnicity, insurance)

cohort_pao2$marital_status[is.na(cohort_pao2$marital_status) |
                               cohort_pao2$marital_status == ""] <- "UNKNOWN (DEFAULT)"

#### RELIGION #####
cohort_pao2$religion[is.na(cohort_pao2$religion) |
                         cohort_pao2$religion == ""] <- "NOT SPECIFIED"

cohort_pao2$religion[cohort_pao2$religion == "7TH DAY ADVENTIST" |
                         cohort_pao2$religion == "BAPTIST" |
                         cohort_pao2$religion == "CHRISTIAN SCIENTIST" |
                         cohort_pao2$religion == "PROTESTANT QUAKER" |
                         cohort_pao2$religion == "JEHOVAH'S WITNESS" |
                         cohort_pao2$religion == "CATHOLIC" |
                         cohort_pao2$religion == "GREEK ORTHODOX" |
                         cohort_pao2$religion == "ROMANIAN EAST. ORTH" |
                         cohort_pao2$religion == "EPISCOPALIAN"] <- "CHRISTIAN"

cohort_pao2$religion[cohort_pao2$religion == "NOT SPECIFIED" |
                         cohort_pao2$religion == "UNOBTAINABLE"] <- "UNKNOWN"

cohort_pao2$religion[cohort_pao2$religion == "BUDDHIST" |
                         cohort_pao2$religion == "MUSLIM" |
                         cohort_pao2$religion == "UNITARIAN-UNIVERSALIST" |
                         cohort_pao2$religion == "JEWISH" |
                         cohort_pao2$religion == "HEBREW"] <- "OTHER"

#### ETHNICITY #####
cohort_pao2$ethnicity[cohort_pao2$ethnicity == "ASIAN - ASIAN INDIAN" |
                          cohort_pao2$ethnicity == "ASIAN - CHINESE" |
                          cohort_pao2$ethnicity == "ASIAN - VIETNAMESE"] <- "ASIAN"

cohort_pao2$ethnicity[cohort_pao2$ethnicity == "BLACK/AFRICAN" |
                          cohort_pao2$ethnicity == "BLACK/AFRICAN AMERICAN" |
                          cohort_pao2$ethnicity == "BLACK/CAPE VERDEAN" |
                          cohort_pao2$ethnicity == "BLACK/HAITIAN"] <- "BLACK"

cohort_pao2$ethnicity[cohort_pao2$ethnicity == "HISPANIC OR LATINO" |
                          cohort_pao2$ethnicity == "HISPANIC/LATINO - DOMINICAN" |
                          cohort_pao2$ethnicity == "HISPANIC/LATINO - GUATEMALAN" |
                          cohort_pao2$ethnicity == "HISPANIC/LATINO - PUERTO RICAN" |
                          cohort_pao2$ethnicity == "HISPANIC/LATINO - SALVADORAN" |
                          cohort_pao2$ethnicity == "SOUTH AMERICAN"] <- "HISPANIC"

cohort_pao2$ethnicity[cohort_pao2$ethnicity == "WHITE - BRAZILIAN" |
                          cohort_pao2$ethnicity == "WHITE - RUSSIAN"] <- "WHITE"

cohort_pao2$ethnicity[cohort_pao2$ethnicity == "MULTI RACE ETHNICITY" |
                          cohort_pao2$ethnicity == "PATIENT DECLINED TO ANSWER" |
                          cohort_pao2$ethnicity == "UNABLE TO OBTAIN" |
                          cohort_pao2$ethnicity == "UNKNOWN/NOT SPECIFIED"] <- "OTHER"
# Combine ethnicity
cohort_pao2$ethnicity[cohort_pao2$ethnicity == "ASIAN" |
                          cohort_pao2$ethnicity == "BLACK" |
                          cohort_pao2$ethnicity == "HISPANIC"] <- "OTHER"


#### INSURANCE #####
# Combine insurance
cohort_pao2$insurance[cohort_pao2$insurance == "Government" |
                          cohort_pao2$insurance == "Self Pay" |
                          cohort_pao2$insurance == "Private"] <- "Private/goverment/self"

cohort_pao2$insurance[cohort_pao2$insurance == "Medicaid" |
                          cohort_pao2$insurance == "Medicare"] <- "Medicaid/Medicare"

