status_cohort <- status_cohort_original %>%
    # select(marital_status, religion, ethnicity, insurance) %>%
    mutate(
        marital_status = case_when(
            marital_status == "SINGLE" ~ "SINGLE",
            marital_status == "MARRIED" ~ "MARRIED",
            marital_status == "SEPARATED" ~ "SEPARATED",
            marital_status == "DIVORCED" ~ "DIVORCED",
            marital_status == "WIDOWED" ~ "WIDOWED",
            marital_status == "UNKNOWN (DEFAULT)" ~ "UNKNOWN (DEFAULT)",
            marital_status == "" ~ "UNKNOWN (DEFAULT)"
        )
    ) %>%
    mutate( # assign religion categories
        religion = case_when(
            religion == "UNOBTAINABLE" ~ "UNKNOWN (DEFAULT)",
            religion == "NOT SPECIFIED" ~ "NOT SPECIFIED",
            religion == "" ~ "UNKNOWN (DEFAULT)",
            ###
            religion == "7TH DAY ADVENTIST" ~ "CHRISTIAN",
            religion == "BAPTIST" ~ "CHRISTIAN",
            religion == "CHRISTIAN SCIENTIST" ~ "CHRISTIAN",
            religion == "PROTESTANT QUAKER" ~ "CHRISTIAN",
            religion == "JEHOVAH'S WITNESS" ~ "CHRISTIAN",
            religion == "CATHOLIC" ~ "CHRISTIAN",
            religion == "GREEK ORTHODOX" ~ "CHRISTIAN",
            religion == "ROMANIAN EAST. ORTH" ~ "CHRISTIAN",
            religion == "EPISCOPALIAN" ~ "CHRISTIAN",
            ###
            religion == "OTHER" ~ "OTHER",
            religion == "BUDDHIST" ~ "OTHER",
            religion == "MUSLIM" ~ "OTHER",
            religion == "UNITARIAN-UNIVERSALIST" ~ "OTHER",
            religion == "JEWISH" ~ "OTHER",
            religion == "HEBREW" ~ "OTHER"
        )
    ) %>%
    mutate(
        ethnicity = case_when(
            ethnicity == "ASIAN" ~ "ASIAN",
            ethnicity == "ASIAN - ASIAN INDIAN" ~ "ASIAN",
            ethnicity == "ASIAN - CHINESE" ~ "ASIAN",
            ###
            ethnicity == "BLACK/AFRICAN" ~ "BLACK",
            ethnicity == "BLACK/AFRICAN AMERICAN" ~ "BLACK",
            ethnicity == "BLACK/CAPE VERDEAN" ~ "BLACK",
            ethnicity == "BLACK/HAITIAN" ~ "BLACK",
            ###
            ethnicity == "HISPANIC OR LATINO" ~ "HISPANIC",
            ethnicity == "HISPANIC/LATINO - DOMINICAN" ~ "HISPANIC",
            ethnicity == "HISPANIC/LATINO - GUATEMALAN" ~ "HISPANIC",
            ethnicity == "HISPANIC/LATINO - PUERTO RICAN" ~ "HISPANIC",
            ###
            ethnicity == "WHITE" ~ "WHITE",
            ethnicity == "WHITE - BRAZILIAN" ~ "WHITE",
            ethnicity == "WHITE - RUSSIAN"  ~ "WHITE",
            ###
            ethnicity == "OTHER" ~ "OTHER",
            ethnicity == "MULTI RACE ETHNICITY" ~ "OTHER",
            ethnicity == "PATIENT DECLINED TO ANSWER" ~ "OTHER",
            ethnicity == "UNABLE TO OBTAIN" ~ "OTHER",
            ethnicity == "UNKNOWN/NOT SPECIFIED" ~ "OTHER"
        )
    ) %>% 
    mutate(
        insurance = case_when(
            insurance == "Government" ~ "Private/goverment/self",
            insurance == "Self Pay" ~ "Private/goverment/self",
            insurance == "Private" ~ "Private/goverment/self",
            insurance == "Medicaid" ~ "Medicaid/Medicare",
            insurance == "Medicare" ~ "Medicaid/Medicare"
        )
    )
