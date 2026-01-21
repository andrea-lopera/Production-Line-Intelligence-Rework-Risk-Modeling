# Production Line Intelligence & Rework Risk Modeling

A simulated **multi-stage production line** analytics project for tracking throughput, cycle time, rework, and downtime using **Python**, **PostgreSQL**, **Tableau**, and **machine learning**.  
(Modeled after an architectural glass line, but designed to be transferable to other discrete manufacturing environments.) In addition to analytics and modeling, this project includes end-to-end Lean-aligned improvement recommendations covering flow optimization, standard work, predictive quality, and operational control systems.

---

## Project Purpose

This project simulates a **multi-step manufacturing process** (cutting → tempering → framing/assembly) and builds an end-to-end analytics stack around it:

- **Python** to generate realistic production and quality data (JSON + CSV)
- **PostgreSQL** to model the process with relational tables, joins, and window functions
- **Tableau** to create operations dashboards
- **Scikit-learn** to predict **which units will need rework** and **why**

**Tools:** `Python` · `pandas` · `NumPy` · `scikit-learn` · `PostgreSQL` · `Tableau`  
**Skills:** Data simulation · SQL modeling · Feature engineering · Dashboarding · Classification (LogReg, Random Forest)

---

## Phase 1: Define the Process & Simulate Data (Python)

We defined a 3-shift, multi-machine production process and simulated operational data over a full quarter. The flow mirrors a typical discrete manufacturing line (for example, architectural glass panels or other custom fabricated components).

### Process Setup

- **Units produced**: 54,720
- **Time horizon:** Jan 1 – Jun 1, 2025 (about 5 months of production)  
- **Shifts:** 3 per day (Shift 1, Shift 2, Shift 3)  
- **Machines:** 20 machines (M01–M20)  
- **Units per machine per shift:** 6  
- **Product types:** Standard, Custom  
- **Product categories:** Doors, Walls, Flooring, Stairs, Partitions (representing different product families / SKUs)

### Generated Datasets

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

**Quality_Audit (CSV)**  
One record per unit, focusing on QC:

- `unit_id`
- `qc_result` (Pass / Fail)
- `rework_flag` (0/1)
- `downtime_minutes`
- `rework_reason` (detailed defect / cause)

### Files

- `notebooks/01_data_production.ipynb` – Python code to generate `Production_Logs.json` + `Quality_Audit.csv`  
- `data/Production_Logs_Single.json` – Row-oriented NDJSON (one record per line) 
- `data/Production_Logs.json` – JSON (An array of objects [])  
- `data/Quality_Audit.csv` – QC outcomes and rework info  

---

## Phase 2: SQL Data Modeling & Feature Engineering (PostgreSQL)

We loaded the simulated data into PostgreSQL to emulate a basic **operations data mart** and do feature engineering in SQL.

### Steps

- Created a **staging table** for raw JSON and used `\copy` to load `Production_Logs.json` as text.
- Parsed the JSON into a clean **`production_logs`** table with columns:

  - `prod_timestamp`
  - `unit_id`
  - `shift`
  - `machine_id`
  - `product_type`
  - `product_category`
  - `cutting_time`
  - `tempering_time`
  - `framing_time`

- Loaded **`Quality_Audit.csv`** into a **`quality_audit`** table:

  - `unit_id`
  - `qc_result`
  - `rework_flag`
  - `downtime_minutes`
  - `rework_reason`

- Defined a **foreign key** relationship on `unit_id`.
- Built a **view** joining production and quality:

```sql
CREATE VIEW production_with_qc AS
SELECT 
    p.prod_timestamp,
    p.unit_id,
    p.shift,
    p.machine_id,
    p.product_type,
    p.product_category,
    p.cutting_time,
    p.tempering_time,
    p.framing_time,
    q.qc_result,
    q.rework_flag,
    q.downtime_minutes,
    q.rework_reason
FROM production_logs AS p
JOIN quality_audit AS q
  ON q.unit_id = p.unit_id;
```

- Used SQL window functions to engineer features such as:
  - **Cumulative downtime per machine over time**
  - **Cycle time** (sum of cutting + tempering + framing)

The resulting view is exported as a clean table for Tableau and modeling.

### Files

- `ETL/production_data.sql` – Table creation, JSON staging, CSV load, view definition  
- `data/production_with_qc.csv` – Exported dataset used for Tableau and ML  


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

## Phase 3: Exploratory Data Analysis (Python)

Using the joined dataset, we explored relationships between process times, rework, and downtime.

### Key Analyses

- Production volume by **shift**, **machine**, and **product category**
- Distribution of **cycle time** and process times (cutting, tempering, framing)
- **Rework rate** by product category, shift, and machine
- Pareto-style distribution of **rework reasons**
- Correlation matrix between:
  - process times  
  - `rework_flag`  
  - `downtime_minutes`  
  - `cycle_time`

### Highlights

- **Custom & complex product families** (like Flooring and Stairs) have longer cycle times and higher rework rates.  
- **Tempering time** behaves like a stable core process: mostly uncorrelated with rework, as long as it stays within spec.  
- **Cycle time** and **rework_flag** are positively correlated: longer jobs are more likely to require rework.  
- **Downtime_minutes** is strongly tied to rework, as expected.

### Files

- `notebooks/02_eda.ipynb` – EDA on `production_with_qc`  
- Plots saved under `plots/`

---

## Phase 4: Dashboards in Tableau

We built two Tableau dashboards on top of the SQL-curated dataset to simulate plant-level monitoring in a manufacturing environment.

### Dashboards

**Production Overview**

- KPIs: Total Units, Rework Rate, Avg Cycle Time  
- Units by Product Category & Shift  
- Cycle Time by Category  
- Throughput trend over time  
- Filters: Product Category, Shift, Machine, Month  

**Quality & Rework Insights**

- Rework rate by Product Category, Shift, and Machine  
- Rework Units vs. Rework Rate  
- Pareto of Rework Reasons  
- Downtime by Machine / Category  

### Previews

![Production Overview](dashboards/screenshots/production_thumbnail.png)  
![Quality Insights](dashboards/screenshots/quality_thumbnail.png)

> 🔗 **View Tableau Dashboard:**  
> [Production KPIs & Downtime Trends](https://public.tableau.com/app/profile/andrea.lopera/viz/ProductionKPIsDowntimeTrends/ProductionOverview)

### Files

- `dashboards/Production Overview.twbx` – Tableau workbook  
- `dashboards/screenshots/` – Dashboard previews  

---

## Phase 5: Modeling – Rework Risk & Rework Reason

We trained classification models to answer two core questions that apply across many manufacturing environments:

1. **Rework risk:** *Will this unit require rework?*  
2. **Rework reason:** *If it fails, what type of issue is most likely?*

---

### 5.1 Rework Risk – Logistic Regression vs Random Forest

**Features used**

- `cycle_time`  
- `shift`  
- `machine_id`  
- `product_type`  
- `product_category`  
- `production_month` (from timestamp)  

Categorical variables were one-hot encoded.

#### Logistic Regression (class-weighted)

- **Goal:** Interpretable baseline, adjusted for class imbalance.  

**Metrics (rework class):**

- Accuracy ≈ **0.57**  
- Precision ≈ **0.38**  
- Recall ≈ **0.83**  
- F1 ≈ **0.52**  

**Interpretation:**

- **Standard vs Custom** and **product family** (e.g., Flooring, Stairs) have clear effects on rework risk.  
- **Night shift (Shift 3)** shows higher rework probability.  
- Some machines consistently appear as lower-risk even after controlling for other factors.

#### Random Forest (tuned)

- **Goal:** Maximize recall on rework units and capture non-linear relationships.  

**Metrics (rework class):**

- Accuracy ≈ **0.54**  
- Precision ≈ **0.37**  
- Recall ≈ **0.91**  
- F1 ≈ **0.53**  

**Feature importance (top drivers):**

- **`cycle_time`** is the dominant driver: longer, more complex jobs fail more often.  
- **`product_type_Standard`** (negative) and complex categories (Flooring, Stairs) are important secondary signals.  
- Shift and machine ID refine risk at the margin.

#### Model Comparison


| Model                                | Accuracy | Precision | Recall |   F1   |
|--------------------------------------|---------:|----------:|-------:|-------:|
| Logistic Regression (class_weighted) |   0.567  |    0.381  | 0.828  | 0.522  |
| Random Forest (tuned)                |   0.539  |    0.374  | 0.914  | 0.531  |


**Why Random Forest for Rework Risk?**

- In a production context, **recall on rework is the priority**: missing defective units (false negatives) is more costly than over-flagging good ones.  
- Random Forest catches **~91%** of rework units vs **~83%** for Logistic Regression, with a slightly stronger F1.  
- **Logistic Regression** is kept as a transparent benchmark;  
  **Random Forest** is used as the main rework-risk model because it maximizes recall while maintaining similar overall performance.

---

### 5.2 Rework Reason – Grouped Buckets (Random Forest)

For units that failed QC (`rework_flag = 1`), we predict a **high-level rework bucket**:

- **Dimensional / Assembly Issues**  
- **Equipment / Human Factors**  
- **Surface / Material Defects**  

(Each bucket groups several detailed reasons like edge chips, misalignment, contamination, material defects, etc.)

**Metrics (test set)**

| Bucket                         | Precision | Recall |  F1  | Support |
|--------------------------------|----------:|-------:|-----:|--------:|
| Dimensional / Assembly Issues  |     0.95  |  0.93  | 0.94 |   2377  |
| Equipment / Human Factors      |     0.89  |  0.98  | 0.93 |    541  |
| Surface / Material Defects     |     0.33  |  0.30  | 0.32 |    204  |
| **Overall Accuracy**           |           |        | **0.90** |  3122   |


**Observations**

- The model reliably distinguishes between **Dimensional / Assembly** vs **Equipment / Human Factors** causes.  
- **Surface / Material Defects** is rarer and harder to separate, but still meaningfully better than random.  
- **Machine ID** (especially certain machines) and **process times** are the strongest drivers of which bucket a failed unit falls into.  
- This structure is generic enough to apply to many factories (e.g., “setup/assembly issues”, “equipment/operator factors”, “material/surface defects”).

**Interpretation**

The model shows that **machine identity + process behavior** can be used to not only predict *whether* a unit will fail, but also **what kind of corrective action is likely needed** (setup/assembly vs equipment/operator vs material).

---

## Phase 6: Lean-Aligned End-to-End Improvement Recommendations

### 6.1 Flow Optimization & Bottleneck Management 

**Problem:** Longer cycle times and higher rework rates on complex product families (Flooring, Stairs), with variability across machines and shifts.

**Lean Improvements:**

- Introduced product-family-based flow lanes to separate high-complexity work from standard jobs.
- Implemented dynamic line balancing using cycle-time distributions by product category and machine.
- Proposed capacity buffering at known bottlenecks (tempering and framing stages) using WIP caps and priority sequencing rules.

**Business Impact (Modeled):**

- Reduced average cycle time variability.
- Improved through predictability for complex SKUs.

### 6.2 First-Pass Yield Improvement via Predictive Quality Triggers

**Problem:** Rework rate ~9%, with long jobs and specific machines driving most failures.

**Lean Improvements:**

- Embedded predictive quality checkpoints before high-risk process steps using model ouputs.
- Designed risk-based inspection routing: high-risk units receive enhanced inspection or operator review before advancing.
- Linked machine-specific corrective actions (calibration, maintenance, setup validation) to model-identified high-risk machines.

**Business Impact (Modeled):**

- Reduced false-negative defects.
- Improved first-pass yield through earlier defect interception.

### 6.3 Standard Work & Error-Proofing (Poka-Yoke)

**Problem:** High incidence of dimensional and assembly-related rework.

**Lean Improvements:**

- Developed standard work instructions for cutting, framing, and assembly steps tied to product complexity tiers.
- Introduced visual controls and poka-yoke concepts for frame alignment, fixture placement, and setup verification.
- Created setup verification checklists for machines with consistently higher rework probability.

**Business Impact (Modeled):**

- Reduced variation in assembly quality.
- Improved operator consistency across shifts.

### 6.4 Machine-Level Continuous Improvement System

**Problem:** Certain machines consistently correlated with higher rework and downtime.

**Lean Improvements:**

- Established machine performance scorecards tracking:
  - Rework rate
  - Downtime minutes
  - Cicle time drift
- Designed a targeted maintenance and retraining loop based on machine risk profiles.
- Introduced root-cause Kaizen triggers when thresholds are breached.

**Business Impact (Modeled):**

- Reduced machine-driven variability.
- Enabled proactive maintenance rather than reactive repair.

### 6.5 Shift-Level Performance Stabilization 

**Problem:** Shift 3 consistently showed higher rework risk.

**Lean Improvements:**

- Standardized handoff protocols between shifts.
- Introduced shift-level visual dashboards for:
  - First-pass yield
  - Rework rate
  - Cycle time adherence
- Designed shift-specific coaching and staffing alignment for complex jobs.

**Business Impact (Modeled):**

- Reduced shift-to-shift quality variability.
- Improved workforce consistency and accountability.

### 6.6 Control System & Operational Governance

**Problem:** No closed-loop system to sustain improvements.

**Lean Improvements:**

- Built a process control framework using:
  - Control charts for cycle time and rework.
  - Daily management dashboards
  - Escalation thresholds and response playbooks
- Defined process ownership and accountability structure by stage (cutting, tempering, framing).

**Business Impact (Modeled):**

- Sustained performance improvements.
- Enabled data-driven daily management.

---

## Phase 7: Improvement Prioritization & Decision Framework

Improvement opportunities identified in Phase 6 were prioritized based on expected operational impact, implementation complexity, and scalability across product families in a discrete manufacturing environment.

**High Impact / Low Complexity**
- Flow separation by product family (standard vs complex products) to reduce cycle time variability and congestion.
- Risk-based quality checkpoints for long cycle-time and high-risk units identified by the rework-risk model.
- Machine-specific setup verification for consistently high-risk machines.

**High Impact / Medium Complexity**
- Standard work and error-proofing (poka-yoke) concepts for framing and assembly operations.
- Shift-level handoff standardization to reduce performance variability across shifts.

**Strategic / Longer-Term**
- Integration of predictive rework-risk outputs into inspection workflows or MES decision logic.
- Closed-loop feedback between quality outcomes, maintenance planning, and operator training programs.

This prioritization framework supports phased implementation, allowing operations teams to capture early gains while building toward more advanced, system-level improvements.

---

## Phase 8: Modeled Impact & Scope

Based on the simulated production environment and model outputs, the proposed Lean-aligned improvements are expected to reduce rework risk and stabilize throughput by intercepting high-risk units earlier and reducing process variability across machines, shifts, and product families.

**Modeled directional impact includes:**
- Reduction in overall rework rate through predictive quality triggers and standardized work.
- Improved first-pass yield driven by earlier detection of dimensional and assembly risks.
- Reduced cycle time variability for complex product families through flow separation and line balancing.
- Improved operational predictability through machine-level performance monitoring and control mechanisms.

This project focuses on analytics-driven insight generation and improvement design. While the data and models are simulated, the process logic, operational patterns, and Lean improvement recommendations are grounded in real-world manufacturing experience. Physical process changes, pilot execution, and financial validation were intentionally out of scope.


