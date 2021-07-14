cohort_pao2 %>% 
    group_by(two_oxy_level) %>%
    summarise(mean_sf = median(sofa, na.rm = TRUE))
