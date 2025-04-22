# 🛍️ Market Basket Analysis on Online Retail Dataset (R Project)

## 📁 Project Overview

This repository contains an end-to-end analysis pipeline for **Market Basket Analysis** using the **Online Retail Dataset**. The dataset includes transactional data from a UK-based non-store online retailer between **01/12/2010** and **09/12/2011**. The company primarily sells unique all-occasion gifts, with many of its customers being wholesalers.

The project is implemented in **R**, focusing on:
- Data cleaning and preprocessing
- Handling missing values
- Regional market basket creation
- Applying the **Apriori algorithm**
- Extracting actionable insights

---

## 📊 Dataset Description

**Files included:**
- `online_retail.xlsx`: Raw dataset
- `online_retail_clean_data.xlsx`: Cleaned version after preprocessing
- `data_cleaning.r`: R script used for data inspection and cleaning

**Attributes:**

| Column         | Description                                                                 |
|----------------|-----------------------------------------------------------------------------|
| `InvoiceNo`    | Unique 6-digit invoice number. If it starts with 'C', it indicates a cancellation. |
| `StockCode`    | Product code, uniquely identifies each item.                               |
| `Description`  | Product name.                                                              |
| `Quantity`     | Quantity of the item purchased per transaction.                           |
| `InvoiceDate`  | Date and time when each invoice was generated.                            |
| `UnitPrice`    | Unit price in GBP.                                                        |
| `CustomerID`   | Unique customer ID.                                                       |
| `Country`      | Country name of the customer.                                             |

---

## ⚙️ Tasks Performed

1. **Missing Value Analysis & Data Cleaning**
   - Handled missing `CustomerID` values.
   - Removed transactions with negative quantities or prices.
   - Cleaned textual inconsistencies in `Description`.

2. **Basket Creation**
   - Filtered top 3 countries by transaction volume.
   - Created individual baskets for each region.

3. **Market Basket Analysis**
   - Applied the **Apriori algorithm** on each country's basket using R packages such as `arules` and `arulesViz`.
   - Generated frequent itemsets and association rules.

---
