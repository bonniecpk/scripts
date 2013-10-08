data <- read.csv("~/Downloads/hw1_data.csv")
good <- complete.cases(data)
ozone <- data[good,][1]
temp <- data[good,][4]
result <- good[ozone > 31 & temp > 90,]

solar <- data[data[1] > 31 & data[2] > 90,][2]


temp <- data[data[5] == 6,][4]
mean(temp[!is.na(temp)])

ozone <- data[data[5] == 5,][1]
max(ozone[!is.na(ozone)])

