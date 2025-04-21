# Load required libraries
install.packages("arulesViz")
library(arules)        # For association rule mining
library(arulesViz)     # For visualizing association rules
library(dplyr)         # For data manipulation
library(ggplot2)       # For visualization
library(factoextra)    # For clustering visualization
library(cluster)       # For silhouette analysis

data_path <- "~/Documents/online-retail-data-mining/online_retail.xlsx"
retail_data <- readxl::read_excel(data_path)
# Alternatively, if you have your own data:
# retail_data <- read.csv("your_data_file.csv")

# View the structure of the data
str(retail_data)
head(retail_data)

# Check for missing values
colSums(is.na(retail_data))

