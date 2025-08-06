# User Financial Behavior Analysis
- **Tools:** SQL, Tableau
- **Visualizations:** KPI Cards, Line Chart, Segmented Histogram, Geo Map
- **Dataset:** Public synthetic data (users, cards, transactions)

---

## I. Business Problem Understanding
### Problem Statement
- Business Perspective: Understanding user behavior is essential for making data-driven decisions in product development, risk management, and marketing strategy. Spending patterns, debt levels, and card usage can help financial institutions manage risk and maximize profitability.
- User Perspective: This analysis helps identify user needs and risks, allowing for more personalized and relevant services.

### Goals
- Analyze users’ financial transactions across multiple years.
- Identify customer segments based on spending, debt, and activity levels.
- Deliver insights that support marketing and credit strategies.

### Business Impact
- Identify active, productive, and high-risk users.
- Detect outliers with large annual spending and high debt-to-income ratios.
- Guide targeted product design and risk mitigation efforts.

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
- 781 users never transacted.
- Active users increased from 1,137 (2010) to over 1,200 yearly after 2014.
- 97 users spent over $100K in a single year (high-value outliers).
- Top 5 debt-to-income ratios exceed 3.9.
- Average credit scores: Male 710.32, Female 709.17.
- Users with credit scores <600 had the highest average annual spending.
- 0% of users were exposed to the dark web (through card tracking).

### Dashboard Insights (Tableau)
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
- SQL + Tableau enabled structured and scalable insight discovery from millions of records.
- Financial variables (debt, credit score, loan amount) are most predictive of user segments.
- Segmentation offers actionable insight into user risk profiles.

### Recommendations
**Risk Management:**
- Monitor high-spending, high-debt users
- Identify and re-engage inactive or high-risk segments

**Product Strategy:**
- Reward stable, high-credit users
- Offer financial counseling for borderline or new users

**Marketing & Targeting:**
- Prioritize outreach to active, productive, debt-free users
- Use regional segmentation for targeted campaigns

**Data Ops:**
- Extend the dataset beyond 2019 for continued insight
- Automate SQL and dashboard refresh pipelines

