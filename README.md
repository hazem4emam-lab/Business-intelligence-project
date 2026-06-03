# Business-intelligence-project
# 🏪 Retail Data Warehouse & Business Intelligence Project

![SQL Server](https://img.shields.io/badge/SQL%20Server-Data%20Warehouse-red)
![Power BI](https://img.shields.io/badge/Power%20BI-Business%20Intelligence-yellow)
![ETL](https://img.shields.io/badge/ETL-Bronze%20→%20Silver%20→%20Gold-blue)
![Status](https://img.shields.io/badge/Status-Completed-success)

---

# 📖 Overview

This project delivers a complete end-to-end **Retail Data Warehouse & Business Intelligence Solution** built using **Microsoft SQL Server** and **Power BI**.

The solution integrates CRM and ERP data sources, transforms raw operational data through the Medallion Architecture, and provides decision-makers with interactive dashboards and advanced cross-schema analytics.

The project supports multiple business stakeholders including Sales Directors, Store Managers, E-Commerce Managers, Customer Analysts, and Marketing Teams.

---

# 🎯 Project Objectives

✅ Design a scalable retail data warehouse

✅ Implement ETL pipelines using Medallion Architecture

✅ Clean and standardize operational data

✅ Build a dimensional analytical model

✅ Enable cross-schema business analysis

✅ Create interactive Power BI dashboards

✅ Deliver actionable business insights

---

# 🏗️ Solution Architecture

```text
📂 CRM & ERP Data Sources (19 CSV Files)
                    │
                    ▼
🥉 Bronze Layer
Raw Data Ingestion
                    │
                    ▼
🥈 Silver Layer
Data Cleansing & Standardization
                    │
                    ▼
🥇 Gold Layer
Dimensional Analytics Model
                    │
                    ▼
📊 Power BI Dashboard
Business Intelligence & Reporting
```

---

# 📊 Project Statistics

| Metric | Value |
|----------|----------|
| Source Files | 19 |
| Bronze Tables | 19 |
| Silver Tables | 19 |
| Fact Tables | 2 |
| Dimension Tables | 9 |
| Dashboard Pages | 5 |
| Business Personas | 5 |
| Business Questions | 25 |
| Cross-Schema Questions | 6 |
| Dashboard Visuals | 35+ |

---

# 🥉 Bronze Layer

## Purpose

The Bronze Layer serves as the landing zone for raw source data.

All data is loaded exactly as received without modifications to preserve data lineage and support auditing.

### Features

- 📂 Raw data storage
- 🔄 Full load processing
- 📋 Audit logging
- ⚡ BULK INSERT loading
- 🔒 Source preservation
- 📊 19 source tables

### Data Sources

### CRM System

- Customers
- Employees
- Online Orders
- Online Order Items
- Payments
- Deliveries
- Delivery Providers

### ERP System

- Products
- Brands
- Departments
- Stores
- Warehouses
- Suppliers
- Product Suppliers
- Promotions
- Registers
- POS Transactions
- Transaction Items
- Inventory

---

# 🥈 Silver Layer

## Purpose

The Silver Layer transforms raw data into validated and business-ready datasets.

### Data Quality Processes

| Process | Description |
|----------|-------------|
| TRY_CAST() | Data type conversion |
| TRIM() | Remove extra spaces |
| LOWER() | Email standardization |
| CASE WHEN | Value normalization |
| ISNULL() | Missing value handling |

### Business Enhancements

📌 Customer Full Name

📌 Total Line Amount

📌 Delivery Days

📌 Promotion Duration

📌 Revenue Calculations

### Validation Rules

- ✅ Null checks
- ✅ Primary key validation
- ✅ Data quality validation
- ✅ Business rule validation
- ✅ Load monitoring

---

# 🥇 Gold Layer

## Dimensional Analytics Model

The Gold Layer is designed to support business intelligence and advanced cross-schema reporting.

The model combines multiple sales channels into a unified analytical environment.

---

## ⭐ Fact Tables

### fact_store_sales

Contains all in-store sales transactions.

#### Measures

- Quantity
- Unit Price
- Sales Amount

#### Grain

One row per POS transaction line item.

---

### fact_online_sales

Contains all online sales transactions.

#### Measures

- Quantity
- Unit Price
- Sales Amount

#### Grain

One row per online order line item.

---

## 📚 Dimension Tables

### Shared Dimensions

Used across multiple sales channels.

- dim_customer
- dim_date
- dim_product
- dim_promotion

### Store Sales Dimensions

- dim_store
- dim_employee

### Online Sales Dimensions

- dim_warehouse
- dim_order_status
- dim_payment_method

---

# 🔄 Cross-Schema Analytics Model

The dimensional model enables reporting across multiple sales channels.

```text
                    dim_date
                        │
                        │
        dim_customer ───┼─── dim_product
                        │
                        │
                 fact_online_sales
                        │
        ┌───────────────┼───────────────┐
        │               │               │
 dim_warehouse   dim_order_status   dim_payment_method


                    dim_date
                        │
                        │
        dim_customer ───┼─── dim_product
                        │
                        │
                 fact_store_sales
                        │
        ┌───────────────┴───────────────┐
        │                               │
   dim_store                    dim_employee
```

This architecture enables unified reporting across online and in-store channels.

---

# 📊 Power BI Dashboard

The dashboard contains **5 interactive analytical pages** built for different business stakeholders.

---

# 🏠 Sales Performance Overview

### 👔 Audience

Sales Director

### Key KPIs

- 💰 Total Combined Revenue
- 🏪 Total Store Revenue
- 🌐 Total Online Revenue
- 📈 Revenue Trends
- 🎯 Revenue Goal Tracking
- 🗺️ Revenue by Region

### Business Questions

✔️ How does store revenue compare to online revenue?

✔️ Are we meeting revenue goals?

✔️ Which regions generate the most revenue?

### Dashboard Preview

![Sales Overview](<img width="1074" height="604" alt="WhatsApp Image 2026-06-04 at 2 02 13 AM" src="https://github.com/user-attachments/assets/389e5df3-f85e-473e-9104-b3340519b27e" />)

---

# 🏪 Store Sales Performance

### 👨‍💼 Audience

Store Operations Manager

### Key KPIs

- Revenue Growth
- Revenue YTD
- Average Transaction Value
- Top Employees
- Department Performance
- Regional Performance

### Business Questions

✔️ Which departments drive the most revenue?

✔️ Who are the top-performing employees?

✔️ How does revenue vary by region?

### Dashboard Preview

![Store Sales](<img width="1074" height="596" alt="Store Sales" src="https://github.com/user-attachments/assets/6c187884-4381-4fff-b7f6-319413eea409" />)

---

# 🌐 Online Orders & Fulfillment

### 📦 Audience

E-Commerce & Fulfillment Manager

### Key KPIs

- Online Revenue
- Delivery Rate
- Cancellation Rate
- Total Orders
- Warehouse Performance
- Payment Method Analysis

### Business Questions

✔️ Which warehouses generate the highest revenue?

✔️ What payment methods do customers prefer?

✔️ How effective is order fulfillment?

### Dashboard Preview

![Online Orders](<img width="1058" height="590" alt="Online Orders" src="https://github.com/user-attachments/assets/b8c202ce-7826-4617-9d51-b8b0406cf56d" />)

---

# 👥 Customer & Loyalty Analysis

### 📈 Audience

Customer Insights Analyst

### Key KPIs

- Total Customers
- Revenue Per Customer
- Customer Lifetime Value
- Loyalty Analysis
- Geographic Distribution

### Business Questions

✔️ Who are the highest-value customers?

✔️ How does loyalty impact revenue?

✔️ Which cities generate the most customer revenue?

### Dashboard Preview

![Customer Analysis](<img width="1071" height="604" alt="Customer Analysis" src="https://github.com/user-attachments/assets/721fd1cc-51e5-493f-aee5-2c17ce488723" />)

---

# 📣 Promotions Analysis

### 📢 Audience

Marketing Analyst

### Key KPIs

- Promotion Revenue
- Promotion Lift %
- Promotion Effectiveness
- Revenue by Promotion Type
- Discount Impact Analysis

### Business Questions

✔️ Which promotion types generate the highest revenue?

✔️ How do discounts impact sales?

✔️ Does promotion duration affect performance?

### Dashboard Preview

![Promotions](<img width="1074" height="600" alt="Promotions" src="https://github.com/user-attachments/assets/c224dee9-fabe-426c-8626-f32fc1a33a0f" />)

---

# 🔍 Advanced Cross-Schema Analytics

One of the main strengths of this project is the ability to answer business questions using multiple sales channels simultaneously.

### Cross-Schema Business Questions

### 💰 Revenue Analysis

- Store Revenue vs Online Revenue
- Combined Revenue Trends
- Revenue vs Goals

### 👥 Customer Analytics

- Top Customers Across Channels
- Revenue by Customer Geography

### 📣 Marketing Analytics

- Promotion Performance Across Channels

---

# 📈 Business Impact

```text
💰 Total Combined Revenue
██████████████████████ 168K

🏪 Store Revenue
████████████████       124K

🌐 Online Revenue
██████                 44K

👥 Customers
██████████████████████ 4000

📦 Orders
██████████████████     3000+
```

---

# 🛠️ Technologies Used

## Data Engineering

- Microsoft SQL Server
- SQL Server Management Studio
- T-SQL
- Stored Procedures
- ETL Pipelines

## Data Warehousing

- Medallion Architecture
- Dimensional Modeling
- Star Schema Design
- Cross-Schema Analytics

## Business Intelligence

- Power BI Desktop
- DAX
- Power Query
- Data Visualization

---

# 🚀 Skills Demonstrated

- Data Warehousing
- ETL Development
- SQL Programming
- Data Modeling
- Business Intelligence
- Dashboard Design
- KPI Development
- DAX Development
- Data Visualization
- Analytical Thinking
- Problem Solving

---

# 👥 Team Members

- Youssef Hassan
- Ali Mohamed
- Omar Samer
- Bahaa Ahmed
- Hazem Adel

### 🎓 Instructor

Dr. Shaimaa Masry

---

# ⭐ Project Outcome

Successfully developed a complete Business Intelligence solution featuring:

✅ Bronze Layer

✅ Silver Layer

✅ Gold Layer

✅ Cross-Schema Analytics

✅ Power BI Dashboard

✅ KPI Monitoring

✅ Interactive Reporting

✅ End-to-End ETL Pipeline

---

### 🌟 If you found this project interesting, consider giving the repository a star!
