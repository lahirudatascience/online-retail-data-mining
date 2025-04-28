# Load required libraries
library(readxl)
library(arules)
library(arulesViz)
library(dplyr)
library(ggplot2)

# Load the data
data_path <- "~/Documents/online-retail-data-mining/online_retail.xlsx"
retail_data <- readxl::read_excel(data_path)

# Find top 3 countries by transaction volume
top_countries <- retail_data %>%
  count(Country, name = "TransactionCount") %>%
  arrange(desc(TransactionCount)) %>%
  slice_head(n = 3) %>%
  pull(Country)

# Filter data for these countries
retail_top <- retail_data %>% 
  filter(Country %in% top_countries)

# Function to perform Market Basket Analysis for a country
perform_mba <- function(country_data, country_name, min_support = 0.01, min_confidence = 0.5) {
  # Create transaction data (group by InvoiceNo)
  transactions <- as(split(country_data$Description, country_data$InvoiceNo), "transactions")
  
  # Run Apriori algorithm
  rules <- apriori(transactions, 
                   parameter = list(support = min_support, 
                                   confidence = min_confidence, 
                                   minlen = 2))
  
  # Sort by lift (most interesting rules)
  rules_sorted <- sort(rules, by = "lift", decreasing = TRUE)
  
  # Return results
  list(
    country = country_name,
    transaction_count = n_distinct(country_data$InvoiceNo),
    item_count = n_distinct(country_data$Description),
    rules = rules_sorted
  )
}

# Initialize list to store results
mba_results <- list()

# Run MBA for each top country
for (country in top_countries) {
  country_data <- retail_top %>% filter(Country == country)
  results <- perform_mba(country_data, country)
  mba_results[[country]] <- results
}

# Function to print summary
print_mba_summary <- function(results) {
  cat("\n=== Market Basket Analysis for:", results$country, "===\n")
  cat("Total Transactions:", results$transaction_count, "\n")
  cat("Unique Items:", results$item_count, "\n")
  cat("Number of Rules Found:", length(results$rules), "\n")
  
  # Show top 5 rules
  cat("\nTop 5 Association Rules (by lift):\n")
  print(inspect(head(results$rules, 5)))
  
  # Visualize top 10 rules
  plot(head(results$rules, 10), 
       method = "graph", 
       main = paste("Association Rules -", results$country))
}

# Print results for each country
lapply(mba_results, print_mba_summary)

# Save rules to CSV files
for (country in names(mba_results)) {
  rules_df <- as(mba_results[[country]]$rules, "data.frame")
  write.csv(rules_df, 
            file = paste0("association_rules_", country, ".csv"), 
            row.names = FALSE)
}
