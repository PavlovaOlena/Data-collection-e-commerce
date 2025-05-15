# SQL Advanced Module – Final Project

## 📘 Overview

This repository focused on analyzing user and email activity using a **BigQuery** e-commerce dataset. The project includes a single **SQL query** to generate a detailed dataset and a visualization built in **Looker Studio**.

---

## 🎯 Objective

The goal is to collect data for:

- Tracking account creation trends
- Analyzing email engagement (sent, opened, clicked)
- Evaluating behavior across dimensions:
  - Send interval
  - Account verification
  - Unsubscription status

The dataset supports comparisons between countries, identifies key markets, and allows user segmentation based on various parameters.

---

## 🛠️ SQL Query Requirements

The query includes:

### Grouping fields:
- `date` – account creation or email send date  
- `country`  
- `send_interval` – account-defined email sending interval  
- `is_verified` – whether the account is verified  
- `is_unsubscribed` – whether the user unsubscribed  

### Main metrics:
- `account_cnt` – number of accounts created  
- `sent_msg` – number of emails sent  
- `open_msg` – number of emails opened  
- `visit_msg` – number of link clicks from emails  

### Additional metrics:
- `total_country_account_cnt` – total accounts per country  
- `total_country_sent_cnt` – total sent emails per country  
- `rank_total_country_account_cnt` – country rank by accounts  
- `rank_total_country_sent_cnt` – country rank by sent emails  

> 🧠 Metrics for accounts and emails are calculated separately to avoid conflicting logics and are combined using `UNION`.

### Technical constraints:
- Use at least **one CTE**
- Use **window functions** to calculate ranks
- Final output must include only rows where `rank_total_country_account_cnt` or `rank_total_country_sent_cnt` ≤ 10

---

## 🧾 Output Columns

```text
date  
country  
send_interval  
is_verified  
is_unsubscribed  
account_cnt  
sent_msg  
open_msg  
visit_msg  
total_country_account_cnt  
total_country_sent_cnt  
rank_total_country_account_cnt  
rank_total_country_sent_cnt
