# discribe time weighted spo2 24hr
summary(mydata2$time_weighted_24hr_spo2)
summary(mydata2$time_weighted_24hr_pao2)
length(which(mydata2$time_weighted_24hr_spo2 < 94))
length(which(mydata2$time_weighted_24hr_pao2 > 70))

#
summary(mydata2$transfusion_first_24hr)
#
summary(mydata2$time_weighted_24hr_pao2)
