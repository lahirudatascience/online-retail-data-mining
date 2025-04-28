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
  
  # emove missing or empty Descriptions
  filter(!is.na(Description) & Description != "") %>%
  
  # Remove rows with Quantity and UnitPrice <= o
  filter(Quantity > 0, UnitPrice > 0) %>%
  
  # Remove cancelled invoices (starting with 'C')
  filter(!grepl("^C", InvoiceNo)) %>%
  
  # Remove delivery and adjustment codes
  filter(!StockCode %in% c("POST", "D", "C2", "DOT", "M", "m", 
                           "BANK CHARGES", "S", "AMAZONFEE", 
                           "gift_0001_40", "gift_0001_50", "gift_0001_30", "gift_0001_20", "gift_0001_10",
                           "gift_0001_20")) %>%
  
  # lean Description (uppercase and trim spaces)
  mutate(Description = str_trim(toupper(Description)))

# how cleaning summary
cat("Original rows:", nrow(retail_data), "\n")
cat("Cleaned rows:", nrow(retail_clean), "\n")
cat("Remaining missing CustomerIDs:", sum(is.na(retail_clean$CustomerID)), "\n")
cat("Remaining missing Descriptions:", sum(is.na(retail_clean$Description)), "\n")
cat("Remaining negative Quantities:", sum(retail_clean$Quantity <= 0), "\n")
cat("Remaining negative UnitPrices:", sum(retail_clean$UnitPrice <= 0), "\n")
cat("Remaining cancelled invoices:", sum(grepl("^C", retail_clean$InvoiceNo)), "\n")

# tep 3: Save the cleaned data
output_path <- "~/Documents/online-retail-data-mining/online_retail_clean_data.xlsx"
write_xlsx(retail_clean, path = output_path)

# heck if saved
if (file.exists(output_path)) {
  cat("Cleaned data saved to:", output_path, "\n")
} else {
  cat("Failed to save the file. Check your file path.\n")
}

