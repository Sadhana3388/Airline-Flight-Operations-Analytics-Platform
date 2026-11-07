# ✈️ Airline Flight Operations Analytics – Databricks Medallion Architecture

## 📌 Project Overview

The **Airline Flight Operations Analytics Platform** is an end-to-end Data Engineering project developed using **Databricks, Lakeflow Spark Declarative Pipelines, Databricks SQL, Unity Catalog, and AI/BI Dashboards**.

The main objective of this project is to transform raw airline flight data into clean, reliable, and business-ready datasets using the Medallion Architecture (Bronze, Silver, and Gold layers).

The project focuses on improving data quality, analyzing airline and route performance, monitoring flight delays, tracking passenger activity, and understanding ticket revenue through interactive dashboards.

## 🎯 Business Objectives

- Build an automated and repeatable data pipeline in Databricks.
- Ingest raw airline flight data from a CSV file.
- Implement Bronze, Silver, and Gold data layers.
- Identify and handle duplicate and invalid flight records.
- Perform data cleaning and transformation using SQL.
- Calculate missing delay minutes and ticket revenue.
- Generate business-level summary tables.
- Validate data quality through reconciliation checks.
- Develop interactive dashboards for airline operations analysis.

## 🛠️ Technologies Used

- **Databricks** – Data engineering and analytics platform.
- **Lakeflow Spark Declarative Pipelines** – Data pipeline development and orchestration.
- **SQL** – Data ingestion, cleaning, transformation, and analysis.
- **Unity Catalog** – Data organization and governance.
- **Medallion Architecture** – Bronze, Silver, and Gold data processing.
- **Databricks AI/BI Dashboards** – Data visualization and business reporting.

## 🏗️ Project Architecture – Medallion Architecture

The project follows a three-layer Medallion Architecture to process raw airline flight data.

### 🥉 Bronze Layer – Raw Data Ingestion

- Ingested the airline flight CSV dataset into Databricks using a Unity Catalog Volume.
- Created a Bronze streaming table using Lakeflow Spark Declarative Pipelines.
- Preserved the original source data without applying cleaning transformations.
- Added source file name and data load timestamp for tracking.
- Loaded 1,365 raw flight records into the Bronze layer.

### 🥈 Silver Layer – Data Cleaning and Transformation

Performed data cleaning and validation to improve data quality and prepare reliable flight records.

Key operations:

- Removed duplicate flight records using `flight_id`.
- Standardized airline names, origin cities, destination cities, and delay reasons.
- Handled missing airline and delay reason values using `COALESCE()`.
- Calculated missing delay minutes using `TIMESTAMPDIFF()`.
- Recalculated missing ticket revenue using passenger count and average fare.
- Created delay categories using `CASE WHEN`.
- Identified invalid records, including passengers exceeding seat capacity and negative fares.
- Stored rejected records separately with rejection reasons.
- Retained early departures as valid on-time flights.

### 🥇 Gold Layer – Business-Ready Data

Created five aggregated summary tables to support airline business analysis.

| **Gold Table** | **Purpose** |
|---|---|
| `gold_monthly_flights` | Monthly flight trends, passengers, load factor and revenue |
| `gold_airline_summary` | Airline performance, on-time percentage and average delay |
| `gold_route_summary` | Route-wise flights, passengers, revenue and load factor |
| `gold_delay_summary` | Flight delay categories and delay reason analysis |
| `gold_data_quality` | Data quality metrics and reconciliation |

## 📊 Dashboard Development

Developed a three-page interactive Databricks AI/BI Dashboard using Gold-layer tables to visualize airline operational performance.

The dashboard includes three analytical sections:

**1. Airline Flight Operations – Overview**

- Total Flights
- Total Passengers
- Ticket Revenue
- Delayed Flights
- Monthly Ticket Revenue Trends
- On-Time Percentage by Airline

**2. Airlines, Routes & Delays**

- Top 10 Routes by Ticket Revenue
- Flights by Delay Category
- Delayed Flights by Reason
- Airline Performance Comparison
- Airline-wise Revenue and Load Factor

**3. Data Quality Analysis**

- Total Bronze Records
- Clean Flights
- Rejected Records
- Duplicate Records
- Data Reconciliation Status
- Data Quality Issues by Category

## 📈 Key Business Metrics

- **Total Flights:** Number of valid flight records after data cleaning.
- **Total Passengers:** Total passengers carried across all clean flights.
- **Ticket Revenue:** Total revenue generated from flight bookings.
- **Load Factor:** Percentage of available seat capacity occupied by passengers.
- **On-Time Percentage:** Percentage of flights departing within 15 minutes of scheduled departure.
- **Average Delay:** Average delay duration across flights.
- **Delayed Flights:** Number of flights with delays greater than 15 minutes.

## 🔍 Data Quality and Validation

Implemented data quality checks to ensure accurate and reliable reporting.

- Duplicate flight identification using `flight_id`.
- Missing value handling.
- Standardization of inconsistent text values.
- Invalid passenger capacity validation.
- Negative fare validation.
- Separate rejected records with rejection reasons.
- Data reconciliation between Bronze, clean, rejected, and duplicate records.

**Data Reconciliation Check:**

Bronze Records = Clean Records + Rejected Records + Duplicate Records

1,365 = 1,321 + 19 + 25

The reconciliation check was successfully validated, confirming that all source records were accounted for.

## 📊 Key Project Results

| **Metric** | **Result** |
|---|---:|
| Total Raw Records | 1,365 |
| Clean Flights | 1,321 |
| Rejected Records | 19 |
| Duplicate Records | 25 |
| Total Passengers | 172,030 |
| Ticket Revenue | ₹118.17 Cr |
| Delayed Flights | 419 

## 💡 Key Learning Outcomes

Through this project, I gained practical experience in:

- Building end-to-end data pipelines using Databricks.
- Understanding and implementing Medallion Architecture.
- Working with Unity Catalog and Volumes.
- Developing Lakeflow Spark Declarative Pipelines using SQL.
- Performing data cleaning and transformation.
- Creating business-ready Gold summary tables.
- Implementing data quality and reconciliation checks.
- Developing interactive Databricks AI/BI dashboards.
- Understanding airline operational metrics and business requirements.

## 📁 Project Deliverables

- Databricks Lakeflow Spark Declarative Pipeline.
- Bronze, Silver, and Gold tables.
- SQL transformation queries.
- Data quality and reconciliation results.
- Pipeline workflow and architecture screenshots.
- Three-page Databricks AI/BI Dashboard.
- Project documentation.

## 👨‍💻 Conclusion

This project demonstrates how raw airline flight data can be transformed into trusted, business-ready information using modern Data Engineering concepts.

By implementing the Medallion Architecture in Databricks, the project establishes a structured and repeatable data processing workflow, improves data quality, and provides meaningful insights into airline performance, passenger activity, ticket revenue, flight delays, and route operations.

This project helped me strengthen my practical knowledge of **Databricks, SQL, Lakeflow Spark Declarative Pipelines, Medallion Architecture, and Data Engineering workflows**.
