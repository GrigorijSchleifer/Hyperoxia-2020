# status_cohort <- status_cohort_original %>%
#     # select(marital_status, religion, ethnicity, insurance) %>%
#     mutate(
#         marital_status = case_when(
#             marital_status == "SINGLE" ~ "SINGLE",
#             marital_status == "MARRIED" ~ "MARRIED",
#             marital_status == "SEPARATED" ~ "SEPARATED",
#             marital_status == "DIVORCED" ~ "DIVORCED",
#             marital_status == "WIDOWED" ~ "WIDOWED",
#             marital_status == "UNKNOWN (DEFAULT)" ~ "UNKNOWN (DEFAULT)",
#             marital_status == "" ~ "UNKNOWN (DEFAULT)"
#         )
#     ) %>%
#     mutate( # assign religion categories
#         religion = case_when(
#             religion == "UNOBTAINABLE" ~ "UNKNOWN (DEFAULT)",
#             religion == "NOT SPECIFIED" ~ "NOT SPECIFIED",
#             religion == "" ~ "UNKNOWN (DEFAULT)",
#             ###
#             religion == "7TH DAY ADVENTIST" ~ "CHRISTIAN",
#             religion == "BAPTIST" ~ "CHRISTIAN",
#             religion == "CHRISTIAN SCIENTIST" ~ "CHRISTIAN",
#             religion == "PROTESTANT QUAKER" ~ "CHRISTIAN",
#             religion == "JEHOVAH'S WITNESS" ~ "CHRISTIAN",
#             religion == "CATHOLIC" ~ "CHRISTIAN",
#             religion == "GREEK ORTHODOX" ~ "CHRISTIAN",
#             religion == "ROMANIAN EAST. ORTH" ~ "CHRISTIAN",
#             religion == "EPISCOPALIAN" ~ "CHRISTIAN",
#             ###
#             religion == "OTHER" ~ "OTHER",
#             religion == "BUDDHIST" ~ "OTHER",
#             religion == "MUSLIM" ~ "OTHER",
#             religion == "UNITARIAN-UNIVERSALIST" ~ "OTHER",
#             religion == "JEWISH" ~ "OTHER",
#             religion == "HEBREW" ~ "OTHER"
#         )
#     ) %>%
#     mutate(
#         ethnicity = case_when(
#             ethnicity == "ASIAN" ~ "ASIAN",
#             ethnicity == "ASIAN - ASIAN INDIAN" ~ "ASIAN",
#             ethnicity == "ASIAN - CHINESE" ~ "ASIAN",
#             ###
#             ethnicity == "BLACK/AFRICAN" ~ "BLACK",
#             ethnicity == "BLACK/AFRICAN AMERICAN" ~ "BLACK",
#             ethnicity == "BLACK/CAPE VERDEAN" ~ "BLACK",
#             ethnicity == "BLACK/HAITIAN" ~ "BLACK",
#             ###
#             ethnicity == "HISPANIC OR LATINO" ~ "HISPANIC",
#             ethnicity == "HISPANIC/LATINO - DOMINICAN" ~ "HISPANIC",
#             ethnicity == "HISPANIC/LATINO - GUATEMALAN" ~ "HISPANIC",
#             ethnicity == "HISPANIC/LATINO - PUERTO RICAN" ~ "HISPANIC",
#             ###
#             ethnicity == "WHITE" ~ "WHITE",
#             ethnicity == "WHITE - BRAZILIAN" ~ "WHITE",
#             ethnicity == "WHITE - RUSSIAN"  ~ "WHITE",
#             ###
#             ethnicity == "OTHER" ~ "OTHER",
#             ethnicity == "MULTI RACE ETHNICITY" ~ "OTHER",
#             ethnicity == "PATIENT DECLINED TO ANSWER" ~ "OTHER",
#             ethnicity == "UNABLE TO OBTAIN" ~ "OTHER",
#             ethnicity == "UNKNOWN/NOT SPECIFIED" ~ "OTHER"
#         )
#     ) %>% 
#     mutate(
#         insurance = case_when(
#             insurance == "Government" ~ "Private/goverment/self",
#             insurance == "Self Pay" ~ "Private/goverment/self",
#             insurance == "Private" ~ "Private/goverment/self",
#             insurance == "Medicaid" ~ "Medicaid/Medicare",
#             insurance == "Medicare" ~ "Medicaid/Medicare"
#         )
#     )
# 
# 
# ######################################################################################
# ##########         Recreating and cleaning religion, ethnicity columns       #########
# ######################################################################################
# 
# 
# status_cohort$marital_status[status_cohort$marital_status == ""] <- "UNKNOWN (DEFAULT)"
# 
# #### RELIGION (CHRISTIAN, NOT SPECIFIED, OTHER) #####
# status_cohort$religion[status_cohort$religion == "UNOBTAINABLE" |
#                            status_cohort$religion == ""] <- "NOT SPECIFIED"
# 
# status_cohort$religion[status_cohort$religion == "7TH DAY ADVENTIST" |
#                            status_cohort$religion == "BAPTIST" |
#                            status_cohort$religion == "CHRISTIAN SCIENTIST" |
#                            status_cohort$religion == "PROTESTANT QUAKER" |
#                            status_cohort$religion == "JEHOVAH'S WITNESS" |
#                            status_cohort$religion == "CATHOLIC" |
#                            status_cohort$religion == "GREEK ORTHODOX" |
#                            status_cohort$religion == "ROMANIAN EAST. ORTH" |
#                            status_cohort$religion == "EPISCOPALIAN"] <- "CHRISTIAN"
# 
# status_cohort$religion[status_cohort$religion == "BUDDHIST" |
#                            status_cohort$religion == "MUSLIM" |
#                            status_cohort$religion == "UNITARIAN-UNIVERSALIST" |
#                            status_cohort$religion == "JEWISH" |
#                            status_cohort$religion == "HEBREW"] <- "OTHER"
# 
# 
# 
# 
# 
# #### ETHNICITY (ASIAN, BLACK, HISPANIC, OTHER, WHITE)#####
# status_cohort$ethnicity[status_cohort$ethnicity == "ASIAN - ASIAN INDIAN" |
#                             status_cohort$ethnicity == "ASIAN - CHINESE"] <- "ASIAN"
# 
# status_cohort$ethnicity[status_cohort$ethnicity == "BLACK/AFRICAN" |
#                             status_cohort$ethnicity == "BLACK/AFRICAN AMERICAN" |
#                             status_cohort$ethnicity == "BLACK/CAPE VERDEAN" |
#                             status_cohort$ethnicity == "BLACK/HAITIAN"] <- "BLACK"
# 
# status_cohort$ethnicity[status_cohort$ethnicity == "HISPANIC OR LATINO" |
#                             status_cohort$ethnicity == "HISPANIC/LATINO - DOMINICAN" |
#                             status_cohort$ethnicity == "HISPANIC/LATINO - GUATEMALAN" |
#                             status_cohort$ethnicity == "HISPANIC/LATINO - PUERTO RICAN"] <- "HISPANIC"
# 
# status_cohort$ethnicity[status_cohort$ethnicity == "WHITE - BRAZILIAN" |
#                             status_cohort$ethnicity == "WHITE - RUSSIAN"] <- "WHITE"
# 
# status_cohort$ethnicity[status_cohort$ethnicity == "MULTI RACE ETHNICITY" |
#                             status_cohort$ethnicity == "PATIENT DECLINED TO ANSWER" |
#                             status_cohort$ethnicity == "UNABLE TO OBTAIN" |
#                             status_cohort$ethnicity == "UNKNOWN/NOT SPECIFIED"] <- "OTHER"
# 
# # # Combine ethnicity
# # status_cohort$ethnicity[status_cohort$ethnicity == "ASIAN" |
# #                           status_cohort$ethnicity == "BLACK" |
# #                           status_cohort$ethnicity == "HISPANIC"] <- "OTHER"

# #### INSURANCE #####
# # Combine insurance
# status_cohort$insurance[status_cohort$insurance == "Government" |
# #                             status_cohort$insurance == "Self Pay" |
# #                             status_cohort$insurance == "Private"] <- "Private/goverment/self"
# # 
# # status_cohort$insurance[status_cohort$insurance == "Medicaid" |
#                             status_cohort$insurance == "Medicare"] <- "Medicaid/Medicare"






# # change all factors inside the columns to characters
# status_cohort[] <- lapply(status_cohort, as.character)
# # save a copy of a "characterised" data.frame just in case I screw things up
# status_cohort_original <- status_cohort
# 
# ##########################################
# ########## change_status_columns #########
# ##########################################
# 
# change_status_columns <- function(df, df_status) {
#     status_list <-
#         c("marital_status", "religion", "ethnicity", "insurance")
#     for (i in status_list) {
#         df[, i] <- df_status[, i]
#     }
#     return(df)
# }
# 
# cohort_pao2_status <- change_status_columns(cohort_pao2, status_cohort)