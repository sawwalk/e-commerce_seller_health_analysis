Dataset: Brazilian E-Commerce Public Dataset (Olist) https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce?resource=download



##### Scenario

"As a data analyst on Olist's Seller Success team, I was asked by the Head of Operations to identify sellers who are negatively impacting platform reputation — and to characterise what poor performance looks like — so the team can prioritise proactive outreach before issues escalate."



topic: seller disengagement



##### Scenario trigger

Olist is preparing to pitch new marketplace partners and needs to demonstrate seller quality controls exist.



##### Defining successful intervention

"Success would be measured by an improvement in average review score among flagged sellers within 90 days of outreach, and a reduction in the proportion of sellers in the at-risk tier quarter-on-quarter."





##### Teams who would legitimately care about this analysis

* Seller Success / Seller Relations team — arguably the most direct consumer of your output. They're the ones who actually pick up the phone or send the email to underperforming sellers. Your risk tiering tells them who to contact and your root cause breakdown (delivery vs product vs communication) tells them what conversation to have.
* Customer Experience team — they care about review scores and complaint patterns from the customer side. Your keyword analysis of negative reviews is directly relevant to them — it tells them what customers are actually upset about at a granular level.
* Logistics / Operations team — separate from the Head of Operations as a stakeholder, the operational team who manages carrier relationships would want to see delivery delay data broken down by seller and region. If delays are clustering around specific routes or carrier handoff points, that's their problem to fix, not the seller's.
* Product team — if certain product categories consistently generate bad reviews regardless of seller, that's a category management problem. Your analysis might surface this as a secondary finding.
* Finance / Commercial team — sellers who are high volume but low satisfaction represent a specific kind of risk. Losing them would hurt GMV, but keeping them hurts reputation. That trade-off is a commercial decision that finance would want input on.







##### Proposed project structure across 8-9 days



Day 1 — Setup \& Domain Familiarisation

Load all 9 CSVs into PostgreSQL. Model the schema with proper primary and foreign keys. Write basic validation queries — row counts, null checks, duplicate checks. This is unglamorous but it's what real analysts do first, and showing it in your GitHub repo signals professionalism.



Day 2 — Exploratory Data Analysis (Python)

Get a feel for the data before committing to your analytical direction. Distribution of orders per seller, review score distributions, order volume over time, delivery delay distribution. You're not producing outputs yet — you're learning what the data can and can't support.



Day 3 — Seller-Level Feature Engineering (Python + PostgreSQL)

This is the core analytical work. Build your seller-level base table. The key features to engineer:



Total orders, total GMV

Average review score and review score standard deviation

Rate of 1-star reviews

Average delivery delay (actual vs estimated)

Order volume trend (early period vs late period — a rough proxy for growth or decline)

Keyword flags on review comments (your existing skill)

Primary product category per seller



Day 4 — Seller Risk Segmentation

Use your engineered features to segment sellers into tiers — something like high performing, needs monitoring, and at-risk. You don't need ML for this. A rule-based scoring approach using thresholds (e.g. average review score below 3.5, more than 20% one-star reviews, delivery delay above X days) is completely defensible and actually more explainable to a business audience than a clustering algorithm. Explainability is a feature, not a limitation.



Day 5 — Review Text Analysis

Focus your keyword analysis on the reviews linked to at-risk sellers specifically. What are customers actually complaining about — late delivery, wrong product, damaged goods, no response? This layer adds texture to your risk segments and makes your recommendations concrete rather than abstract.



Day 6 — Tableau Dashboard Build

Build three views:



Platform health overview (order volume growth, overall review score trend, GMV over time)

Seller risk matrix (scatter plot of volume vs review score, coloured by risk tier)

At-risk seller deep dive (delivery delay, review keywords, category breakdown for the bottom segment)



Day 7 — Validation \& Sense-Checking

Go back and stress-test your findings. Are your at-risk sellers actually small sample sizes that just had bad luck? Does your segmentation hold up when you filter to sellers with a minimum order threshold? This is the step most portfolio projects skip, and it's exactly what a real analyst would do before presenting findings.



Day 8 — Write-up, README, and GitHub Polish

This matters more than most people think. Your GitHub README is what a hiring manager reads before they look at a single line of code. It should clearly state the business problem, your approach, your key findings, and your recommendations — in plain English. Include screenshots of your Tableau dashboard. A well-presented mediocre analysis beats a brilliant poorly-presented one almost every time.



Day 9 — Buffer

Something will take longer than planned. This is your contingency.

##### 



* Use pgAdmin for uploading data creating schemas, adding primary keys and data cleaning/validation, then move to jupyter notebook to conduct analysis.







##### Data cleaning notes

Dataset cutoff October 2018



###### Null order delivery dates 3% of total

"3% of orders have null delivery dates corresponding to cancelled/unavailable status. These will be excluded from delivery performance analysis but retained for order volume and status distribution analysis."



A status breakdown of orders with null order\_delivered\_customer\_date reveals the following distribution:

Status		Count	% of Null Delivery Orders

"shipped"	1107	37.34

"canceled"	619	20.88

"unavailable"	609	20.54

"invoiced"	314	10.59

"processing"	301	10.15

"delivered"	8	0.27

"created"	5	0.17

"approved"	2	0.07



Further investigation — such as checking whether shipped/invoiced/processing order timestamps cluster near the October 2018 cutoff, and whether these orders have associated reviews — would help clarify the true nature of these nulls. This is flagged for future analysis.



Handling approach by context:

* Delivery time performance: all orders with null order\_delivered\_customer\_date will be excluded - 3.0% of data.
* Order volume and status distribution analysis: include all orders
* Seller health scoring: track rate of non-delivered orders per seller as a potential risk indicator rather than silently excluding them further analysis will be done to determine weather the nature of the nulls and how they reflect on the seller (does the seller have many orders with unavailable status hinting at stock issues, or where the nulls due to orders not being able to be fulfilled before the data cutoff) data quality issues also need to be considered when using nulls which is a concern to bring up with the operations and data management team.





"41.3% of reviews (40,977) contain written comments. Text analysis will be scoped to this subset."



Column		Table		Null Count	% Null

review\_score	order\_reviews	0		0.00%

seller\_id	order\_items	0		0.00%

price		order\_items	0		0.00%



###### Join health notes:

* Every order\_id in order\_items has a matching order\_id in orders
* Every order\_id in orders has a customer\_id that matches a customer\_id in customers  ( I don't think this is as important )





**Join Health Assessment**

Check					Count	% of Total (99441)

Reviews without valid order		0	0.00%

Reviews without seller attribution	759	0.76%

Orders without items			775	0.78%

Orders without reviews			768	0.77%

Orders with full chain (items + review)	97,917	98.47%



Join health between key tables for seller scoring is strong. With 759 reviews that can not be attributed to any seller making up 0.76% of total orders which will naturally be filtered out without causing significant bias. Overall join health between the 3 key tables is strong with 98.47% of the data being fully usable for seller performance analysis.



Source on using customer health metrics in SaaS companies: https://www.gainsight.com/guides/the-customer-success-index/

&#x20;

