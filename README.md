# User Financial Behavior Analysis
- **Tools:** SQL, Tableau
- **Visualizations:** KPI Cards, Line Chart, Segmented Histogram, Geo Map
- **Dataset:** Public synthetic data (users, cards, transactions)

---

## I. Business Problem Understanding
### Problem Statement
- Business Perspective: Data-driven decisions in marketing strategy, risk management, and product development depend on an understanding of user behavior. Financial organizations can reduce risk and increase profitability by using spending trends, debt levels, and card usage.
- User Perspective: By identifying user demands and hazards, this study enables more relevant and individualized services.
- 
### Goals
- Examine users' financial transactions across a number of years.
- Determine client categories according to activity levels, debt, and spending.
- Provide information that bolsters credit and marketing plans.

### Business Impact
- Determine which users are high-risk, productive, and active.
- Identify anomalies with high debt-to-income ratios and significant annual spending.
- Direct focused efforts at risk reduction and product design.

---

## II. Data Understanding & Preparation
### Dataset Summary
- users.csv: 2,000 records – demographic and financial information
- cards.csv: ~6,000 records – credit/debit card ownership
- transactions.csv: ~13 million records – transaction history from 2010 to 2019

*Note:* Transaction data spans from 2010-01-01 00:01:00 to 2019-10-31 23:59:00. The 2019 data is incomplete.

### Key Steps
**Data Cleaning:**
- Removed $ and , from currency columns
- Converted fields to numeric or date types

**Aggregation:**
- Yearly transaction summary per user
- Card aggregation per user (total cards, dark web exposure, credit limit)

**Feature Engineering:**
- active_user: User has made at least 1 transaction
- productive_user: User is under 60 years old
- having_debt: User has non-zero total debt

**Final Table:** transaction_analysis containing one row per user per year

---

## III. Insights & Analysis
### SQL-Based Key Insights
- 781 users never made a purchase.
- Between 2010 and 2014, the number of active users rose from 1,137 to over 1,200 per year.
- 97 users (high-value outliers) spent more than $100,000 in a single year.
- The top five debt-to-income ratios are higher than 3.9.
- The average credit scores for Male and Female are 710.32 and 709.17, respectively.
- Those with credit ratings below 600 spent the most on average per year.
- Through card tracking, none of the users were exposed to the dark web.

### Dashboard Insights (Tableau)

**Dashboard**
The clean data saved from the previous SQL results is visualized using Tableau. Here is the link to this Tableau project:

https://public.tableau.com/app/profile/giovanny.theotista/viz/FinancialActivity_17544578630310/Dashboard1?publish=yes

Here's a glimpse of this Tableau project:

<img width="1160" height="824" alt="image" src="https://github.com/user-attachments/assets/7b802646-f765-404a-b150-8bb2395cac76" />


**KPIs:**
- Total Amount: $571.8M
- Total Transactions: 13.3M
- Productive Users: 15,940
- Average Transaction Value: $528.8
**Yearly Trend:** Growth until 2016, then gradual decline (2019 drop due to incomplete data)

**User Segmentation:**
- 64.06% active, productive, with debt
- 30.65% active, productive, no debt
- 1.6% active but not productive
- 3.69% inactive

**Geographic Distribution:** Most users located in Eastern US (NY, DC, Great Lakes); significant presence in California

**Income Distribution:** Most earn under $50K; right-skewed distribution

---

## IV. Conclusion and Recommendations
### Conclusion
- Structured and scalable insight discovery from millions of records was made possible by SQL + Tableau.
- The most predictive factors for user categories are financial factors (debt, credit score, and loan amount).
- Segmentation provides useful information on user risk profiles.

### Recommendations
**Risk Management:**
- Keep an eye on users with large debt and spending.
- Determine and re-engage high-risk or inactive segments.

**Product Strategy:**
- Reward stable, high-credit users
- Offer financial counseling for borderline or new users

**Marketing & Targeting:**
- Make reaching out to people who are active, productive, and debt-free a top priority. 
- Use regional segmentation to create tailored marketing.

**Data Ops:**
- Extend the dataset beyond 2019 for continued insight
- Automate SQL and dashboard refresh pipelines

