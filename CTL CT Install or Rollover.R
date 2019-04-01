#load appropriate librarys
library(tidyverse)
library(readxl)
library(writexl)

# load the initial file
data <- read_xls(file.choose(new = FALSE))

#Splitting out the New CFA based on the spaces into individual components
data$new_CFA_broken <- str_split(data$NEW_CFA, "\\W", n = 5)
data$new_CFA_loc1 <- lapply(data$new_CFA_broken, function(x) {
  x[c(4)]
})
data$new_CFA_loc2 <- lapply(data$new_CFA_broken, function(x) {
  x[c(5)]
})

#Splitting out the Old CFA based on the spaces into individual components
data$old_CFA_broken <- str_split(data$OLD_CFA, "\\W", n = 5)
data$old_CFA_loc1 <- lapply(data$old_CFA_broken, function(x) {
  x[c(4)]
})
data$old_CFA_loc2 <- lapply(data$old_CFA_broken, function(x) {
  x[c(5)]
})

#trimming all of the CFA locations to make them 8 character
data$new_CFA_loc1_trim <- str_sub(data$new_CFA_loc1, 1, 8)
data$new_CFA_loc2_trim <- str_sub(data$new_CFA_loc2, 1, 8)
data$old_CFA_loc1_trim <- str_sub(data$old_CFA_loc1, 1, 8)
data$old_CFA_loc2_trim <- str_sub(data$old_CFA_loc2, 1, 8)

#Create a flag indicating whether new CFA locations match old CFA locations
data$CFA_loc1_match <- (data$new_CFA_loc1_trim == data$old_CFA_loc1_trim) | (data$new_CFA_loc1_trim == data$old_CFA_loc2_trim)
data$CFA_loc2_match <- (data$new_CFA_loc2_trim == data$old_CFA_loc2_trim) | (data$new_CFA_loc2_trim == data$old_CFA_loc1_trim)
data$CFA_loc_match <- data$CFA_loc1_match & data$CFA_loc2_match

#Modify strings to remove spaces, special characters
data$new_address_short <- str_replace_all(data$NEW_ADDRESS, "[:space:]", "")
data$new_address_short <- str_replace_all(data$new_address_short, "[:punct:]", "")
data$old_address_short <- str_replace_all(data$OLD_ADDRESS, "[:space:]", "")
data$old_address_short <- str_replace_all(data$old_address_short, "[:punct:]", "")

#Compare first 10 characters of shortened strings to see if the same.  If first
#10 characters are the same, assume it's the same address
data$address_match <- str_sub(data$new_address_short, 1, 10) == str_sub(data$old_address_short, 1, 10)

#Look at indicators and determine if charge on circuit should be CT install 
data$charge_type <- ifelse(data$CFA_loc_match & data$address_match, "Rollover", "CT Install")

#Export data to Excel for analysis and dispute
write_xlsx(data, path = "data.xlsx", col_names = TRUE, format_headers = TRUE)
