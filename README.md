# 🛒 E-Commerce Delivery Intelligence & Customer Experience

An end-to-end data analytics project exploring e-commerce delivery performance, seller operations, regional trends, and customer satisfaction using **SQL and Power BI**.

The project uses the Brazilian E-Commerce Public Dataset by Olist to uncover operational patterns, identify delivery challenges, and understand how delivery experiences relate to customer satisfaction.

---

## 🎯 Project Objective

The objective of this project is to analyze the e-commerce order-to-delivery journey and identify opportunities to improve delivery performance and customer experience.

The analysis focuses on five major business areas:

- 🔍 Data Quality Investigation
- 🚚 Overall Delivery Performance
- 🌎 Category, State & Monthly Delivery Analysis
- 🏭 Seller Delivery Investigation
- ⭐ Customer Review Analysis

The findings are presented through SQL analysis and four interactive Power BI dashboard pages.

## 🛠️ Tools & Technologies

| Tool            | Purpose                                                                        |
| --------------- | ------------------------------------------------------------------------------ |
| 🗄️ SQL (MySQL) | Data exploration, validation, joins, aggregations, CTEs, and business analysis |
| 📊 Power BI     | Interactive dashboards, KPIs, and data visualization                           |
| 🔄 Power Query  | Data preparation and transformation                                            |
| 📐 DAX          | Calculated columns, measures, and dynamic dashboard titles                     |

## 📦 Dataset Understanding

**Dataset:** Brazilian E-Commerce Public Dataset by Olist

The dataset contains information about e-commerce orders, customers, sellers, products, payments, delivery dates, and customer reviews.

Multiple related datasets were used to investigate delivery performance and customer experience across different business dimensions.

## 🔎 SQL Analysis & Key Findings

### 1️⃣ Initial Data Quality Investigation

Investigated inconsistencies in order status and delivery timestamps before proceeding with the main analysis.

**Key findings:**

- 8 delivered orders had missing customer-delivery timestamps.
- All 8 orders had associated order-item records.
- 7 of these orders had review records.
- 625 orders were marked as cancelled.
- 6 cancelled orders (0.96%) had customer-delivery timestamps.

These records were investigated without modifying the original data. The underlying causes of the inconsistencies were not established.

### 2️⃣ Overall Delivery Performance

Evaluated delivery performance using orders marked as delivered with an available actual customer-delivery timestamp.

**Key findings:**

| Metric                    | Result |
| ------------------------- | -----: |
| Eligible Delivered Orders | 96,470 |
| Late Orders               |  6,534 |
| Late Delivery Rate        |  6.77% |

An order was classified as late when its actual customer-delivery date was later than its estimated delivery date.

### 3️⃣ Category, State & Monthly Delivery Analysis

Analyzed how delivery performance varied across time, product categories, and customer states.

**Key findings:**

- 📅 March 2018 recorded a late delivery rate of **18.96%**.
- 📅 June 2018 recorded a much lower rate of **1.16%**.
- 📍 São Paulo (SP) had 1,820 late orders out of 40,494 eligible orders, a rate of **4.49%**.
- 📍 Alagoas (AL) recorded a late delivery rate of **21.41%**.
- 📍 Maranhão (MA) recorded a late delivery rate of **17.43%**.
- 📦 Certain product categories showed higher late delivery rates than others.

The investigation also explored monthly delivery performance in Rio de Janeiro and category-level performance in São Paulo.

### 4️⃣ Seller Delivery Investigation

Conducted a focused investigation of a seller's delivery performance during August 2018.

**Seller performance compared with the São Paulo benchmark:**

| Metric                    |                   Result |
| ------------------------- | -----------------------: |
| Eligible Orders           |                       26 |
| Late Orders               |                        6 |
| Seller Late Delivery Rate |                   23.08% |
| São Paulo Benchmark       |                    9.01% |
| Difference                | +14.07 percentage points |

Additional investigations examined shipping deadline compliance and the time taken between order approval, carrier handoff, and customer delivery.

The analysis identified areas for further investigation but does not establish that the seller was solely responsible for the delays.

### 5️⃣ Customer Review Analysis

Examined the relationship between delivery classification and customer review scores.

**Key findings:**

| Metric               | On-Time Orders | Late Orders |
| -------------------- | -------------: | ----------: |
| Orders               |         89,442 |       6,379 |
| Average Review Score |         4.29/5 |      2.27/5 |

**Additional insights:**

- ⭐ The average review score difference was **2.02 points**.
- 53.67% of late orders had an average review score of 1.0.
- Only 6.58% of on-time orders had an average review score of 1.0.
- 62.21% of on-time orders had an average review score of 5.0.
- Only 16.53% of late orders had an average review score of 5.0.

The findings indicate a strong association between delivery delays and lower customer review scores, although they do not establish causation.

---

## 📊 Power BI Dashboard

The Power BI report consists of four interactive pages, each designed to provide a different perspective on e-commerce business performance.

### 🏠 1. Executive Overview

A high-level summary of order volume, delivery performance, and customer satisfaction through key performance indicators and trend analysis.

<p align="center">
  <img src="Pictures/Executive%20View.png" width="850">
</p>
### 🚚 2. Delivery Performance

Analyzes delivery performance across time, product categories, and customer states to identify patterns and regional delivery challenges.

<p align="center">
  <img src="Pictures/Delivery%20Performance.png" width="850">
</p>
### 🏭 3. Seller Performance

Evaluates seller-level delivery performance, highlighting sellers with higher late delivery rates and differences in delivery timelines.

<p align="center">
  <img src="Pictures/Seller%20Performance.png" width="850">
</p>

### ⭐ 4. Customer Experience

Explores customer review scores and compares satisfaction across on-time and late delivery classifications.

<p align="center">
  <img src="Pictures/Customer%20Experience.png" width="850" alt="Customer Experience Dashboard">
</p>



### 📥 Access the Power BI Report

The complete interactive Power BI report is available in the repository:

📁 `Power BI/ecommerce_delivery_project.pbix`

Download the `.pbix` file and open it using **Microsoft Power BI Desktop** to explore all four interactive dashboard pages, apply filters, and investigate the underlying insights.
---

## 💡 Key Business Takeaways

- 🚚 Overall late delivery rate was **6.77%** across 96,470 eligible delivered orders.
- 📅 Delivery performance varied considerably across months, with March 2018 recording a particularly high late delivery rate.
- 🌎 Regional analysis highlighted substantial differences in delivery performance across customer states.
- 🏭 The investigated seller recorded a late delivery rate considerably higher than the São Paulo benchmark in the selected comparison period.
- ⭐ On-time orders had a considerably higher average review score than late orders.
- 📉 More than half of late orders in the customer review comparison had an average review score of 1.0.

These findings can help businesses prioritize regional investigations, monitor seller performance, and identify opportunities to improve the delivery experience.

## 📚 Important Analytical Considerations

- Original data was retained for reference.
- Delivery performance calculations follow defined eligibility criteria.
- Orders with missing delivery timestamps were investigated separately.
- Seller-level investigations used different analytical populations for different comparisons. Their counts should not be combined.
- The SQL customer-review comparison uses a narrower eligible population than the Power BI Total Reviewed Orders KPI. These figures therefore have different inclusion criteria.
- The analysis identifies associations and patterns, not necessarily direct causation.

## 📁 Repository Structure

```text
E-Commerce Delivery Intelligence/
│
├── 📂 Docs/
│   └── 5 SQL analysis documentation files
│
├── 📂 Raw_Data/
│   └── Original Olist dataset CSV files
│
├── 📂 SQL/
│   └── 5 SQL analysis files
│
├── 📂 Pictures/
│   ├── executive view.png
│   ├── seller performance.png
│   ├── delivery performance.png
│   └── customer experience.png
│
├── 📂 Power Bi/
│   └── ecommerce_delivery_project.pbix
│
└── 📄 README.md
```

## 🏁 Conclusion

This project demonstrates how SQL and Power BI can be used together to investigate real-world e-commerce business problems.

By combining data validation, business-focused SQL analysis, and interactive dashboards, the project transforms raw transactional data into meaningful insights about delivery operations, seller performance, regional trends, and customer experience.

The analysis highlights how data-driven investigation can support better operational monitoring and business decision-making.
