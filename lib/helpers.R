helper.function <- function(hyper)
{
  result <- hyper %>% 
    dplyr::filter(!is.na(mean_pao2_24hr), los >= 1) %>%
    summarize(n())
  
  return(result)
}
