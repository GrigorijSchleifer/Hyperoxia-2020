status_cohort$marital_status[is.na(status_cohort$marital_status) |
                               status_cohort$marital_status == ""] <- "UNKNOWN (DEFAULT)"

#### RELIGION #####
status_cohort$religion[is.na(status_cohort$religion) |
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

status_cohort$religion[status_cohort$religion == "NOT SPECIFIED" |
                         status_cohort$religion == "UNOBTAINABLE"] <- "UNKNOWN"

status_cohort$religion[status_cohort$religion == "BUDDHIST" |
                         status_cohort$religion == "MUSLIM" |
                         status_cohort$religion == "UNITARIAN-UNIVERSALIST" |
                         status_cohort$religion == "JEWISH" |
                         status_cohort$religion == "HEBREW"] <- "OTHER"




#### ETHNICITY #####
status_cohort$ethnicity[status_cohort$ethnicity == "ASIAN - ASIAN INDIAN" |
                          status_cohort$ethnicity == "ASIAN - CHINESE" |
                          status_cohort$ethnicity == "ASIAN - VIETNAMESE"] <- "ASIAN"

status_cohort$ethnicity[status_cohort$ethnicity == "BLACK/AFRICAN" |
                          status_cohort$ethnicity == "BLACK/AFRICAN AMERICAN" |
                          status_cohort$ethnicity == "BLACK/CAPE VERDEAN" |
                          status_cohort$ethnicity == "BLACK/HAITIAN"] <- "BLACK"

status_cohort$ethnicity[status_cohort$ethnicity == "HISPANIC OR LATINO" |
                          status_cohort$ethnicity == "HISPANIC/LATINO - DOMINICAN" |
                          status_cohort$ethnicity == "HISPANIC/LATINO - GUATEMALAN" |
                          status_cohort$ethnicity == "HISPANIC/LATINO - PUERTO RICAN" |
                          status_cohort$ethnicity == "HISPANIC/LATINO - SALVADORAN" |
                          status_cohort$ethnicity == "SOUTH AMERICAN"] <- "HISPANIC"

status_cohort$ethnicity[status_cohort$ethnicity == "WHITE - BRAZILIAN" |
                          status_cohort$ethnicity == "WHITE - RUSSIAN"] <- "WHITE"

status_cohort$ethnicity[status_cohort$ethnicity == "MULTI RACE ETHNICITY" |
                          status_cohort$ethnicity == "PATIENT DECLINED TO ANSWER" |
                          status_cohort$ethnicity == "UNABLE TO OBTAIN" |
                          status_cohort$ethnicity == "UNKNOWN/NOT SPECIFIED"] <- "OTHER"

# Combine ethnicity
status_cohort$ethnicity[status_cohort$ethnicity == "ASIAN" |
                          status_cohort$ethnicity == "BLACK" |
                          status_cohort$ethnicity == "HISPANIC"] <- "OTHER"


#### INSURANCE #####
# Combine insurance
status_cohort$insurance[status_cohort$insurance == "Government" |
                          status_cohort$insurance == "Self Pay" |
                          status_cohort$insurance == "Private"] <- "Private/goverment/self"

status_cohort$insurance[status_cohort$insurance == "Medicaid" |
                          status_cohort$insurance == "Medicare"] <- "Medicaid/Medicare"

