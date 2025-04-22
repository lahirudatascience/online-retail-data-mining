
# Load required libraries
library(readxl)
library(dplyr)
library(ggplot2)
library(corrplot)
library(stringr)
library(arules)
library(writexl)
library(tidyr)

# Step 1: Load cleaned data
retail_clean <- read_excel("~/Documents/online-retail-data-mining/online_retail_clean_data.xlsx")