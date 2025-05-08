# Load required libraries
library(readxl)
library(arules)
library(arulesViz)
library(dplyr)
library(ggplot2)
library(stringr)

# Load the cleaned Online Retail dataset
data_path <- "~/Documents/online-retail-data-mining/dataset/online_retail_no_outliers.xlsx"
retail_data <- read_excel(data_path)

# Remove transactions with missing descriptions or invoice numbers
retail_data <- retail_data %>%
  filter(!is.na(Description) & !is.na(InvoiceNo))

# Find Top 3 Countries by Transaction Volume
top_countries <- retail_data %>%
  count(Country, name = "TransactionCount") %>%
  arrange(desc(TransactionCount)) %>%
  slice_head(n = 3) %>%
  pull(Country)

cat("Top 3 Countries selected for Basket Analysis:", paste(top_countries, collapse = ", "), "\n")

# Filter data for only the top countries
retail_top_countries <- retail_data %>%
  filter(Country %in% top_countries)

# Define Basket Analysis Function
perform_basket_analysis <- function(country_data, country_name, min_support = 0.01, min_confidence = 0.5) {
  cat("\nPerforming Basket Analysis for:", country_name, "\n")
  
  # Prepare transactions
  transactions <- as(split(country_data$Description, country_data$InvoiceNo), "transactions")
  
  # Apply Apriori algorithm
  rules <- apriori(transactions,
                   parameter = list(supp = min_support, 
                                    conf = min_confidence,
                                    minlen = 2))
  
  # Sort rules by lift
  sorted_rules <- sort(rules, by = "lift", decreasing = TRUE)
  
  # Return results
  list(
    country = country_name,
    total_transactions = n_distinct(country_data$InvoiceNo),
    unique_items = n_distinct(country_data$Description),
    association_rules = sorted_rules
  )
}

# Output directory for saving results
output_dir <- "~/Documents/online-retail-data-mining/basket_analysis_results/"
dir.create(output_dir, showWarnings = FALSE)

basket_analysis_results <- list()

# Loop through top countries
for (country in top_countries) {
  country_data <- retail_top_countries %>% filter(Country == country)
  analysis_result <- perform_basket_analysis(country_data, country)
  basket_analysis_results[[country]] <- analysis_result
  
  # Save rules as CSV
  rules_df <- as(analysis_result$association_rules, "data.frame")
  country_clean_name <- str_replace_all(country, "\\s+", "_")
  write.csv(rules_df, 
            file = paste0(output_dir, "association_rules_", country_clean_name, ".csv"), 
            row.names = FALSE)
  
  # Optional: Save a rule plot for each country
  if (length(analysis_result$association_rules) > 0) {
    png(filename = paste0(output_dir, "rules_plot_", country_clean_name, ".png"), width = 1200, height = 800)
    plot(head(analysis_result$association_rules, 20), method = "graph", engine = "htmlwidget")
    dev.off()
  }
}

# Print summary function
print_basket_analysis_summary <- function(analysis_result) {
  cat("\n=== Basket Analysis Summary for:", analysis_result$country, "===\n")
  cat("Total Transactions:", analysis_result$total_transactions, "\n")
  cat("Unique Items:", analysis_result$unique_items, "\n")
  cat("Number of Rules Found:", length(analysis_result$association_rules), "\n")
  
  if (length(analysis_result$association_rules) > 0) {
    cat("\nTop 5 Rules (by Lift):\n")
    print(inspect(head(analysis_result$association_rules, 5)))
  } else {
    cat("\nNo rules found. Consider adjusting support/confidence thresholds.\n")
  }
}

# Print results for each top country
lapply(basket_analysis_results, print_basket_analysis_summary)

cat("\n✅ All Basket Analysis outputs saved in:", output_dir, "\n")

