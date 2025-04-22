# Install packages if needed
install.packages(c("readxl", "arules", "arulesViz", "dplyr", "ggplot2"))
install.packages("writexl")

# Step 1: Initial Data Loading and Structure Examination
# Load required libraries
library(readxl)
library(stringr)
library(arules)
library(arulesViz)
library(dplyr)
library(ggplot2)
library(writexl)


data_path <- "~/Documents/online-retail-data-mining/online_retail.xlsx"
retail_data <- readxl::read_excel(data_path)

# Basic structure examination
glimpse(retail_data)

# View first and last few rows
head(retail_data)
tail(retail_data)

# Summary statistics
summary(retail_data)

# Check for missing values
colSums(is.na(retail_data))

# Count negative quantity transactions
negative_qty <- retail_data %>% 
  filter(Quantity < 0) %>% 
  count()

cat("Number of transactions with negative quantities:", negative_qty$n, "\n")

# View some examples of negative Unit Price transactions
head(retail_data[retail_data$UnitPrice < 0, ])

# Count negative Unit Price transactions
negative_up <- retail_data %>% 
  filter(UnitPrice < 0) %>% 
  count()

cat("Number of transactions with negative Unit Price:", negative_up$n, "\n")

# View some examples of negative Unit Price transactions
head(retail_data[retail_data$UnitPrice < 0, ])

# Step 2: Enhanced Missing Value and Data Quality Management
clean_retail_data <- function(retail_data) {
  retail_data %>%
    # 1. Handle missing CustomerID (keep but mark as Unknown)
    mutate(CustomerID = ifelse(is.na(CustomerID), "Unknown", as.character(CustomerID))) %>%
    
    # 2. Remove missing Descriptions
    filter(!is.na(Description) & Description != "Unknown") %>%
    
    # 3. Handle Quantity and UnitPrice issues
    filter(
      # Remove zero quantities
      Quantity != 0,
      # Remove zero unit prices (unless they're special markers)
      UnitPrice != 0,
      # Remove returns (negative quantities)
      Quantity > 0,
      # Remove complex adjustments (both negative)
      !(Quantity < 0 & UnitPrice < 0)
    ) %>%
    
    # 4. Convert negative unit prices to positive for discounts
    mutate(
      UnitPrice = abs(UnitPrice),
      # Create transaction type flags
      TransactionType = case_when(
        Quantity > 0 & UnitPrice > 0 ~ "Normal Sale",
        Quantity > 0 & UnitPrice == 0 ~ "Free Item",  # Should be filtered out already
        TRUE ~ "Other"
      )
    ) %>%
    
    # 5. Remove cancelled invoices (starting with 'C')
    filter(!grepl("^C", InvoiceNo)) %>%
    
    # 6. Additional cleaning for basket analysis
    mutate(
      # Clean description text
      Description = str_trim(toupper(Description)),
      # Create absolute quantity (already positive due to filtering)
      Quantity = Quantity
    ) %>%
    
    # 7. Remove postage and other non-product items
    filter(!StockCode %in% c("POST", "D", "C2", "M", "BANK CHARGES", "AMAZONFEE"))
}

# Apply the cleaning function
retail_clean <- clean_retail_data(retail_data)

# Verify the cleaning results
cat("Data cleaning summary:\n")
cat("Original rows:", nrow(retail_data), "\n")
cat("Cleaned rows:", nrow(retail_clean), "\n")
cat("Percentage kept:", round(nrow(retail_clean)/nrow(retail_data)*100, 1), "%\n\n")

# Check for remaining issues
cat("Post-cleaning validation:\n")
cat("Negative Quantities:", sum(retail_clean$Quantity < 0), "\n")
cat("Negative UnitPrices:", sum(retail_clean$UnitPrice < 0), "\n")
cat("Missing Descriptions:", sum(is.na(retail_clean$Description)), "\n")
cat("Unknown Customers:", sum(retail_clean$CustomerID == "Unknown"), "\n")

# Summary statistics
summary(retail_clean)
head(retail_clean)

# Specify the output file path
output_path <- "~/Documents/online-retail-data-mining/online_retail_clean_data.xlsx" 

# Save the cleaned data to Excel
write_xlsx(retail_clean, path = output_path)

# Verify the file was created
if(file.exists(output_path)) {
  cat("Successfully saved cleaned data to:", output_path, "\n")
} else {
  cat("Failed to save the file. Please check your path.\n")
}



