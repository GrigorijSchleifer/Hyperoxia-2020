## Create an overall table for categorical variables
catVars <-
    c(
        "age_cat",
        "gender",
        "insurance",
        "surg",
        "ethnicity",
        "has_chronic_lung_conditions",
        "has_chronic_heart_problems",
        "has_diabetes",
        "has_hypertension",
        "marital_status",
        "aki_stage"
    )
catTableOverall <-
    CreateCatTable(vars = catVars,
                   strata = "two_oxy_level",
                   data = cohort_pao2)
## Simply typing the object name will invoke the print.CatTable method,
## which will show the sample size, frequencies and percentages.
## For 2-level variables, only the higher level is shown for simplicity
## unless the variables are specified in the cramVars argument.
catTableOverall

try <- print(catTableOverall, exact = "ascites", quote = FALSE)
write.csv(try, file = "catTableOverall.csv")


CreateContTable(
    vars = c(
        "age",
        "sofa",
        "transfusion_first_24hr",
        "fluid_intake_first24hr",
        "oasis",
        "saps",
        "los",
        "los_hos"
    ),
    strata = "two_oxy_level",
    data = cohort_pao2
)

