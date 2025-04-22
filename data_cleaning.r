# nstall necessary packages (run only once if not installed)
install.packages(c("readxl", "arules", "arulesViz", "dplyr", "ggplot2", "writexl"))

# Load libraries
library(readxl)
library(stringr)
library(arules)
library(arulesViz)
library(dplyr)
library(ggplot2)
library(writexl)

# tep 1: Load the Excel file
data_path <- "~/Documents/online-retail-data-mining/online_retail.xlsx"
retail_data <- read_excel(data_path)

# ook at the structure and first rows
glimpse(retail_data)
head(retail_data)

# tep 2: Remove unwanted or bad rows
retail_clean <- retail_data %>%
  # Remove rows without CustomerID
  filter(!is.na(CustomerID)) %>%
  
  # emove missing or empty Description
  filter(!is.na(Description) & Description != "") %>%
  
  # Remove rows with Quantity or UnitPrice <= 0
  filter(Quantity > 0, UnitPrice > 0) %>%
  
  # Remove cancelled invoices (starting with 'C')
  filter(!grepl("^C", InvoiceNo)) %>%
  
  # Remove delivery and adjustment codes
  filter(!StockCode %in% c("POST", "D", "C2", "M", "BANK CHARGES", "AMAZONFEE")) %>%
  
  # lean Description (uppercase and trim spaces)
  mutate(Description = str_trim(toupper(Description)))

# how cleaning summary
cat("Original rows:", nrow(retail_data), "\n")
cat("Cleaned rows:", nrow(retail_clean), "\n")
cat("Remaining missing CustomerIDs:", sum(is.na(retail_clean$CustomerID)), "\n")

# tep 3: Save the cleaned data
output_path <- "~/Documents/online-retail-data-mining/online_retail_clean_data.xlsx"
write_xlsx(retail_clean, path = output_path)

# heck if saved
if (file.exists(output_path)) {
  cat("Cleaned data saved to:", output_path, "\n")
} else {
  cat("Failed to save the file. Check your file path.\n")
}
