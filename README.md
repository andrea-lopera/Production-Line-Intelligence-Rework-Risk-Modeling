# Production Line Intelligence & Rework Risk Modeling

A simulated multi-stage production line analytics project for tracking throughput, cycle time, rework, and downtime using **Python**, **PostgreSQL**, **Tableau**, and **Machine Learning**.

---

## Project Purpose

This project simulates a **multi-step manufacturing process** (cutting → tempering → framing/assembly) and builds an end-to-end analytics stack around it:
- **Python** to generate realistic production and quality data (JSON + CSV)
- **PostgreSQL** to model the process with relational tables, joins, and window functions
- **Tableau** to create operations dashboards
- **Scikit-learn** to predict which units will need rework and why

**Tools:** `Python` · `pandas` · `NumPy` · `scikit-learn` · `PostgreSQL` · `Tableau`  
**Skills:** Data simulation · SQL modeling · Feature engineering · Dashboarding · Classification (LogReg, Random Forest)

---

## Phase 1: Define the Process + Simulate Data

We defined a 3-shift, multi-machine production process and simulated operational data over a full quarter. The flow mirrors a typical discrete manufacturing line (for example, architectural glass panels or other custom fabricated components).

### Process Setup:
- **Time horizon**: Jan 1 - Jun 1, 2025 (about 5 months of production)  
- **Shifts:** 3 per day (Shift 1, Shift 2, Shift 3)
- **Machines:** 20 machines (M01–M20)
- **Total Units:** 54,720
- **Product types:** Standard, Custom  
- **Product categories**: Doors, Walls, Flooring, Stairs, Partitions (representing different product families / SKUs)

**Production_Logs (JSON, row-oriented)**  
Row-oriented JSON, one record per unit produced:

- `timestamp`
- `unit_id`
- `shift`
- `machine_id`
- `product_type`
- `product_category`
- `cutting_time`
- `tempering_time`
- `framing_time`

  
- **Metrics**:
  - Processing times (cutting, tempering, framing)
  - Downtime minutes
  - Quality check result + rework flag
  - Rework reason (for failures only)

### Files:
- `notebooks/01_data_simulation.ipynb` – Python code to simulate production data  
- `data/production_data.csv` – Final output (ready for analysis)

---

## Phase 2: Exploratory Data Analysis

We explored the simulated production dataset to uncover trends in processing time, rework, and downtime.

### Key Analyses:
- Units produced per shift
- Average cycle time by product category
- Rework rates by shift
- Downtime patterns by product type
- Distribution of rework reasons

### Key Insights:
- All three shifts produced equal volume
- Stairs and Walls had the longest average cycle times
- Rework rate averaged ~9%, highest in Shift 1
- Downtime was highest for Stairs and Flooring
- Most common rework reason: Misaligned Frame

### Files:
- `notebooks/02_eda.ipynb`  
- Charts: `plots/`

---

## Phase 3: Dashboard with Tableau

In this phase, we transformed the CSV data into an interactive Tableau dashboard to simulate real-time monitoring for manufacturing operations.

### Visuals:
- Bar Chart: Units produced per shift  
- Pie Chart: Rework reason distribution  
- KPI Cards: Total Units, Rework Rate, Avg Cycle Time  
- Line Chart: Units over time  
- Filters: Product category, Shift, Rework flag  

### Dashboard with Tableau:
Here's a preview of the final interactive dashboard built in Tableau Public:

[![Production Insights Preview](dashboards/screenshots/production_thumbnail.png)]
[![Quality Insights Preview](dashboards/screenshots/quality_thumbnail.png)]

> [🔗 View Tableau Dashboard ([click here](https://public.tableau.com/app/profile/andrea.lopera/viz/ProductionKPIsDowntimeTrends/ProductionOverview))]

### Files:
- Tableau Workbook: `dashboards/Production Overview.twbx`  
- Preview: `dashboards/screenshots/`

---

## Project Goal

By the end, this dashboard will help:
- Monitor process efficiency and product quality  
- Identify shifts or product types with high rework or downtime  
- Demonstrate analytics and reporting skills using realistic operations data

---

## Project Summary

> This simulated analytics project replicates how a Data Analyst would monitor and improve a real glass manufacturing line. From simulating shift-level production data to uncovering root causes of rework, the project concludes with a Tableau dashboard ready for stakeholder reporting.


> This project is part of a career portfolio in **manufacturing analytics** and **process intelligence**.



