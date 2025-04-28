# Load required libraries
library(dplyr)
library(ggplot2)
library(readxl)
library(writexl)
library(ggcorrplot)

# Load the cleaned retail dataset
data_path <- "~/Documents/online-retail-data-mining/dataset/online_retail_clean_data.xlsx"
retail_clean <- read_excel(data_path)

# Check the structure of the cleaned data
str(retail_clean)
# Check the first few rows of the cleaned data
head(retail_clean)

# statistical exploration 
# Summary statistics for Quantity and UnitPrice
summary_stats <- retail_clean %>%
  summarise(
    mean_quantity = mean(Quantity),
    median_quantity = median(Quantity),
    sd_quantity = sd(Quantity),
    mean_unitprice = mean(UnitPrice),
    median_unitprice = median(UnitPrice),
    sd_unitprice = sd(UnitPrice)
  )
print(summary_stats)

#  Top 10 countries with the most transactions
top_countries <- retail_clean %>%
  count(Country, sort = TRUE) %>%
  top_n(10)
print(top_countries)

# Plot: Number of transactions per country (Top 10)
ggplot(top_countries, aes(x = reorder(Country, n), y = n)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Top 10 Countries by Number of Transactions",
       x = "Country", y = "Transaction Count") +
  theme_minimal()

#  Top 10 products with the most transactions 
top_products <- retail_clean %>%
  count(Description, sort = TRUE) %>%
  top_n(10)
print(top_products)

# Plot: Number of transactions per product (Top 10)
ggplot(top_products, aes(x = reorder(Description, n), y = n)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Top 10 Products by Number of Transactions",
       x = "Product Description", y = "Transaction Count") +
  theme_minimal()

#  Top 10 customers with the most transactions
top_customers <- retail_clean %>%
  count(CustomerID, sort = TRUE) %>%
  top_n(10)

print(top_customers)

# Plot: Number of transactions per customer (Top 10)
ggplot(top_customers, aes(x = reorder(as.factor(CustomerID), n), y = n)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Top 10 Customers by Number of Transactions",
       x = "Customer ID", y = "Transaction Count") +
  theme_minimal()

#  Top 10 invoices with the most transactions
top_invoices <- retail_clean %>%
  count(InvoiceNo, sort = TRUE) %>%
  top_n(10)

print(top_invoices)

# Plot: Number of transactions per invoice (Top 10)
ggplot(top_invoices, aes(x = reorder(InvoiceNo, n), y = n)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Top 10 Invoices by Number of Transactions",
       x = "Invoice Number", y = "Transaction Count") +
  theme_minimal()


# Step Calculate total items per customer
customer_items <- retail_clean %>%
  group_by(CustomerID) %>%
  summarise(TotalItems = sum(Quantity)) %>%
  arrange(desc(TotalItems))

# Calculate total revenue
revenue_country <- retail_clean %>%
  mutate(Revenue = Quantity * UnitPrice) %>%
  group_by(Country) %>%
  summarise(TotalRevenue = sum(Revenue)) %>%
  arrange(desc(TotalRevenue)) %>%
  top_n(10)

# Plot: Revenue per country
ggplot(revenue_country, aes(x = reorder(Country, TotalRevenue), y = TotalRevenue)) +
  geom_bar(stat = "identity", fill = "darkgreen") +
  coord_flip() +
  labs(title = "Top 10 Countries by Revenue",
       x = "Country", y = "Total Revenue") +
  theme_minimal()

# --- Invoice Value Distribution ---
# Plot: Distribution of invoice values
retail_clean %>%
  mutate(InvoiceValue = Quantity * UnitPrice) %>%
  ggplot(aes(x = InvoiceValue)) +
  geom_histogram(binwidth = 10, fill = "purple", color = "white") +
  xlim(0, 500) +
  labs(title = "Distribution of Invoice Values",
       x = "Invoice Value", y = "Frequency") +
  theme_minimal()

# Step Visualize outliers using boxplot
ggplot(customer_items, aes(y = TotalItems)) +
  geom_boxplot(fill = "tomato", outlier.color = "blue") +
  labs(title = "Boxplot of Total Items per Customer",
       y = "Total Items") +
  theme_minimal()

# remove over total Items 100000 outliers
customer_items <- customer_items %>%
  filter(TotalItems <= 100000)

# Step Visualize outliers using boxplot
ggplot(customer_items, aes(y = TotalItems)) +
  geom_boxplot(fill = "tomato", outlier.color = "blue") +
  labs(title = "Boxplot of Total Items per Customer (Outliers Removed)",
       y = "Total Items") +
  theme_minimal()

# Step: Filter the main dataset to keep only valid CustomerIDs
retail_no_outliers <- retail_clean %>%
  filter(CustomerID %in% customer_items$CustomerID)

# --- Correlation Heatmap ---
# Select numeric columns only
numeric_cols <- retail_no_outliers %>%
  select(where(is.numeric))

# Add TotalPrice column: Quantity * UnitPrice
retail_no_outliers <- retail_no_outliers %>%
  mutate(TotalPrice = Quantity * UnitPrice)

# Create aggregated features per Customer
customer_features <- retail_no_outliers %>%
  group_by(CustomerID) %>%
  summarise(
    TotalQuantity = sum(Quantity),
    TotalRevenue = sum(TotalPrice),
    AverageUnitPrice = mean(UnitPrice),
    AverageQuantity = mean(Quantity),
    NumberOfInvoices = n_distinct(InvoiceNo),
    AverageInvoiceValue = TotalRevenue / NumberOfInvoices
  )

# View the new customer-level feature data
head(customer_features)

# Compute correlation matrix
correlation_matrix_new <- cor(customer_features %>% select(where(is.numeric)), use = "complete.obs")

# Plot the enhanced correlation heatmap
ggcorrplot(correlation_matrix_new,
           method = "square",
           type = "lower",
           lab = TRUE,
           lab_size = 3,
           colors = c("red", "white", "blue"),
           title = "Enhanced Correlation Heatmap of Customer Features",
           ggtheme = theme_minimal())


# Step: Save the new dataset without extreme outliers
output_path <- "~/Documents/online-retail-data-mining/dataset/online_retail_no_outliers.xlsx"
write_xlsx(retail_no_outliers, path = output_path)

# Confirm file saved
if (file.exists(output_path)) {
  cat("✅ Data without outliers saved to:", output_path, "\n")
} else {
  cat("❌ File not saved. Check your path.\n")
}








