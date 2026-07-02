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







\## Poorly Categorized Reviews:

\### DELIVERY DELAY ###

3\. Score: 1★

&#x20;     PT: O produto não chegou à unidade dos correios. Invés de tomar a responsabilidade para si e estonar o valor, a loja disse que só faria o estorno após receber de volta o objeto. Sou cliente não entregador

&#x20;     EN: The product did not arrive at the post office. Instead of taking responsibility and refunding the value, the store said it would only issue a refund after receiving the item back. I am a non-delivery customer

&#x20;

4\. Score: 1★

&#x20;     PT: Somente recebi o produto (Relógio Casio G-shock Ga-100cm-8adr), outro que esta no mesmo pedido não foi enviado.

&#x20;     EN: I only received the product (Casio G-shock Ga-100cm-8adr Watch), another one in the same order was not sent.



\### NON-DELIVERY ###

&#x20;1. Score: 1★

&#x20;     PT: Não recebi o produto até hoje !!!

&#x20;     EN: I haven't received the product until today!!!



\### PRODUCT QUALITY ###

1\. Score: 1★

&#x20;     PT: Acredito não ter recebido por conta da greve . Mas não indico a lannister por motivo de venda de televisão com defeito

&#x20;     EN: I believe I didn't receive it due to the strike. But I do not recommend Lannister due to the sale of defective televisions. (Here I think this does reference a product quality issue with this seller who is known for defective TV's but I don't think this comes directly from this customers experience, that being said this still hurts reputation so I do not know if I should count this as a product complaint or not.)

2\. Score: 1★

&#x20;     PT: Pessimo vendedor, foi entregue parte do Pedido, e os que vieram são errados, comprei 60XL color veio 60XL Preto

&#x20;     EN: Terrible seller, part of the Order was delivered, and the ones that came were wrong, I bought 60XL color came 60XL Black

7\. Score: 1★

&#x20;     PT: Produto muito diferente da imagem apresentada no site da lannister, o diâmetro não chega nem

próximo do apresentado no site, não serve na cama Queen Size, péssimo acabamento não tem nada de Elegance

&#x20;     EN: Product very different from the image presented on the Lannister website, the diameter is not even enough

close to what is shown on the website, does not fit a Queen Size bed, poor finish, has nothing Elegance



\### WRONG PRODUCT ###

1\. Score: 2★

&#x20;     PT: Comprei três produtos e recebi apenas um .

&#x20;     EN: I bought three products and only received one.

5\. Score: 1★

&#x20;     PT: COMPREI 2 PRODUTOS E SÓ ME ENTREGARAM ATE AGORA NÃO TIVE RESPOSTA SOBRE O OUTRO PRODUTO!

&#x20;     EN: I BOUGHT 2 PRODUCTS AND THEY ONLY DELIVERED IT TO ME SO FAR I HAVE NO RESPONSE ABOUT THE OTHER PRODUCT!

6\. Score: 2★

&#x20;     PT: comprei dois produtos e só recebi um sem nota fiscal

&#x20;     EN: I bought two products and only received one without an invoice

7\. Score: 2★

&#x20;     PT: Comprei dois produtos e recebi apenas um.

&#x20;     EN: I bought two products and only received one.

9\. Score: 1★

&#x20;     PT: comprei 2 quite e so recebi 1 estou aguardando o outro

&#x20;     EN: I bought 2 sets and only received 1, I'm waiting for the other one



\### POOR COMMUNICATION ###

4\. Score: 1★

&#x20;     PT: Infelizmente o fone não reconhece em nenhum tipo de celular , já entrei em contato com a stark , inclusive hoje.

Pediram que eu aguardasse vcs entrarem em contato em dois dias

&#x20;     EN: Unfortunately, the phone does not recognize it on any type of cell phone, I have already contacted Stark, including today.

They asked me to wait for you to get in touch in two days (Not sure if this demonstraights poor communication)



\### POOR PACKAGING ###

1\. Score: 1★

&#x20;     PT: Boa tarde,qdo comprei era cartucho hp 933XL original e veio cartucho desconhecido com tinta.

No anuncio nao deveriam colocar a embalagem do produto,pois pela foto é que eu queria mas vei o generico.

&#x20;     EN: Good afternoon, when I bought it, it was an original HP 933XL cartridge and it came with an unknown cartridge with ink.

In the ad, they shouldn't include the packaging of the product, because from the photo I wanted it but I saw the generic one. (I feel like they are talking about the product not the packaging)

3\. Score: 1★

&#x20;     PT: O produto recebido em embalagem lacrada, após abrir observei que o perfume estava com tampa do spray com uma colar envelhecida e com arranhões e a parte metálica solta. Desconfio da originalidade.

&#x20;     EN: The product was received in a sealed package, after opening it I noticed that the perfume had a spray cap with an aged collar with scratches and the metal part was loose. I suspect originality.

6\. Score: 1★

&#x20;     PT: Comprei duas capa de sofa nf correta na embalagem só veio uma

&#x20;     EN: I bought two sofa covers not correct in the packaging only one came

&#x20;



## Prompt for new conversation after completing jupyter notebooks

## Project Context — Olist Seller Health Analysis

### Role and scenario

I am a data analyst on Olist's Seller Success team.
I was asked by the Head of Operations to identify
sellers who are negatively impacting platform
reputation and characterise what poor performance
looks like, so the team can prioritise proactive
outreach before issues escalate.

Olist is a Brazilian SaaS marketplace integrator
that connects small and medium-sized sellers to
major Brazilian online marketplaces under a shared
Olist Store brand. All sellers share collective
reputation — one underperforming seller affects
the whole platform.

### Stack

Python (pandas, matplotlib, seaborn, scipy),
PostgreSQL (pgAdmin), Jupyter Notebooks, Tableau,
deep-translator for review translation.

### Project structure

Brazil\_E-Commerce/

├── 01\_setup/

│   ├── 01\_create\_schema.sql

│   ├── 02\_load\_data.ipynb

│   ├── 03\_data\_validation.sql

│   └── 04\_foreign\_key\_constraints.sql

│

├── 02\_analysis/

│   ├── 05\_EDA.ipynb

│   ├── 06\_seller\_feature\_engineering.ipynb

│   └── 07\_review\_text\_analysis.ipynb

│

├── dashboard/

│   └── seller\_health\_dashboard.twbx

│

├── data/

│   ├── raw/

│   │   └── 9 original Kaggle CSVs

│   └── processed/

│       ├── at\_risk\_complaints\_long.csv

│       ├── at\_risk\_profiles\_final.csv

│       ├── seller\_excluded.csv

│       └── seller\_health\_scores.csv

│

├── .gitignore

├── AI\_diligence\_statement.txt

├── GLOSSARY.md

├── README.md

└── notes.md





### Dataset

Olist Brazilian E-Commerce public dataset from
Kaggle. 9 CSV files covering orders, customers,
sellers, products, payments, reviews, and
geolocation. Period: September 2016–October 2018. (Max order\_purchase\_timestamp = 2018-10-17 17:30:18)
99,441 orders. Analytical universe: 97,917 orders (Min order\_purchase\_timestamp = 2016-09-04 21:15:19)
with complete chain (items + delivery + review).

### What has been completed

**Notebook 05 — EDA**
Four analytical questions answered:

Q1 — Review score distribution: heavily right-skewed.
57.8% five-star, 11.5% one-star. Platform weighted
average: 4.09. One-star rate tracked separately as
it captures extreme dissatisfaction that averages
obscure.

Q2 — Seller order volume: 2,970 sellers with
delivered orders. Median 7 orders, mean 32.9,
heavily right-skewed. 58.4% of sellers have fewer
than 10 orders. Minimum scoring threshold set at
10 delivered orders. Revenue follows marketplace
power law — 17.9% of sellers generate 80% of GMV,
less concentrated than typical marketplace
benchmarks per Marketplace Pulse research.

Q3 — Delivery delay: 91.89% of orders delivered
early. Median order arrives 11.95 days ahead of
estimated date. Olist deliberately sets generous
estimated windows (avg 23.74 days) against actual
delivery of 12.56 days — an 11.18 day buffer
strategy. Only 8.11% of orders are late. Extreme
outliers: 360 orders (0.37%) more than 30 days late.

Q4 — Factors associated with low review scores:

* Spearman correlation (delay vs review score):
ρ = -0.1757, p < 0.0001 (weak but significant)
* Spearman correlation (actual delivery days vs
review score): ρ = -0.2344, p < 0.0001
* Mann-Whitney U test (late vs early/on-time):
U = 530,208,489, p < 0.0001
* Effect size (rank-biserial): -0.5534 (large)
Interpretation: 77.7% probability early order
has higher review score than late order
* Key finding: threshold effect not sliding scale.
Scores stable (4.24–4.33) across all early
delivery buckets, collapse to 3.18 for 0–7 days
late, further to \~1.6–1.75 for 7+ days late.
* Late order RATE is more discriminating than
average delay days given 92% early delivery.
* Actual delivery time is a stronger signal than
relative delay for customer satisfaction.

**Notebook 06 — Seller Feature Engineering
and Health Scoring**

Feature table built for 2,970 sellers using a
CTE-based SQL query that pre-aggregates to order
level to avoid multi-item order duplication.
Key features: total\_orders, total\_gmv,
avg\_review\_score, review\_response\_rate,
pct\_one\_star, avg\_actual\_delivery\_days,
avg\_delay\_days, late\_order\_rate, pct\_extreme\_late,
orders\_last\_6\_months, first/last order dates.

Scoring methodology:

* Scoreable population: 1,238 sellers
(10+ orders, non-null review score)
* Excluded: 1,732 sellers (insufficient history)
* Normalisation: percentile ranking within
scoreable population. Chosen over z-score and
min-max for interpretability and robustness
to skew.
* pct\_extreme\_late removed from score due to
zero inflation (83.4% of sellers have zero
extreme late orders — percentile ranking
non-discriminatory). Converted to binary flag.

Health score formula (0–100, higher = healthier):
health\_score =
(review\_score\_pct  × 0.40) +
(late\_rate\_pct     × 0.28) +
(one\_star\_pct      × 0.22) +
(delivery\_days\_pct × 0.10)

All inverted metrics (late\_rate, one\_star,
delivery\_days) use: 100 - percentile\_rank
so higher always means healthier.

Tier thresholds (based on score distribution):

* At Risk:  score < 23.0  → 186 sellers (15.0%)
* Monitor:  23.0–43.0     → 309 sellers (25.0%)
* Healthy:  > 43.0        → 743 sellers (60.0%)

Sensitivity analysis: 91.3% of sellers receive
identical tier across three weight configurations.
At Risk tier 87.6% stable. No sellers jump
between At Risk and Healthy — no contradictory
classifications.

Additional flags per seller:

* extreme\_late\_flag: at least one order >30 days late
* boundary\_case\_flag: tier changes across weight
configurations (108 sellers, 8.7%)

**Notebook 07 — Review Text Analysis**

Scope: 2,328 negative reviews (1–2 star) with
written comments from 186 At Risk sellers.

Methodology: keyword-based complaint categorisation
in Portuguese with prefix stemming. Six categories.
Iterative refinement through precision evaluation
(manual translation of 10 reviews per category
using deep-translator/Google Translate, evaluated
against 70% precision threshold).

Final precision scores:

* Non-Delivery:      90% — High confidence
* Poor Communication: 90% — High confidence
* Delivery Delay:    80% — High confidence
* Wrong Product:     80% — High confidence
* Product Quality:   70% — Moderate confidence
* Poor Packaging:    70% — Moderate confidence

Uncategorised: 40.0% of reviews (predominantly
short emotional expressions, positive text with
negative scores, idiomatic language).

Key refinement: partial delivery keywords
(só recebi, recebi apenas, so recebi) transferred
from Wrong Product to Non-Delivery after precision
evaluation revealed systematic miscategorisation.

Complaint distribution (categorised reviews,
n=1,397 from 180 sellers):

* Non-Delivery:       696 (49.8%)
* Delivery Delay:     441 (31.6%)
* Wrong Product:      218 (15.6%)
* Product Quality:    196 (14.0%)
* Poor Communication: 135 (9.7%)
* Poor Packaging:      65 (4.7%)
* Return/refund flag: 180 (7.7% — consequence
indicator, not primary category)

Delivery-related combined (deduplicated):
977 reviews (69.9%)
Product-related combined (deduplicated):
393 reviews (28.1%)

Seller complaint profiles built with:

* dominant\_category: primary failure mode
* Binary flags per category
* compound\_failure: avg 1.5+ categories per review
* delivery\_comms\_compound: delivery AND
communication failure co-present
* low\_review\_coverage: fewer than 3 categorised
reviews (directional only)
* intervention\_priority: 4-tier prioritisation

### Key findings

1. 186 sellers (15.0% of scoreable population)
are At Risk.
2. Delivery failure is the primary failure mode
for \~75% of At Risk sellers. Dominant category
distribution:

   * Non-Delivery: 83 sellers (44.6%)
   * Mixed Delivery Delay/Non-Delivery: 33 (17.7%)
   * Delivery Delay: 23 (12.4%)
   * Mixed categories (delivery-involved): \~16
3. Delivery Delay sellers are the worst performers
by health score (mean 10.30) despite being fewer
in number than Non-Delivery sellers (mean 13.59).
4. Wrong Product sellers have the highest 1-star
rate (27.93%) but the lowest late order rate
(8.52%) — product failure, not logistics failure.
5. 61 sellers (32.8% of At Risk) have delivery +
communication compound failure — the most
damaging pattern identified. Mean health score
12.2 vs 14.1 for non-compound sellers.
6. 45 sellers (24.2%) carry extreme late flag
(at least one order >30 days late).
7. 68 sellers (36.6%) have low review coverage
(<3 categorised reviews) — profiles directional.

### Intervention priority distribution

Priority 1 — Immediate (Delivery+Comms): 61
Priority 2 — Logistics Intervention:    106
Priority 3 — Product Intervention:       11
Priority 4 — Review Directly:             8

### Exported files

* data/processed/seller\_health\_scores.csv
(1,238 scoreable sellers with full metrics,
health score, tier, and flags)
* data/processed/seller\_excluded.csv  
(1,732 excluded sellers)
* data/processed/at\_risk\_profiles\_final.csv
(186 At Risk sellers with complaint profiles,
dominant category, intervention priority,
ranked by health score within priority tier)

### Key methodological decisions already made

These should not be re-litigated without good
reason:

* Minimum order threshold: 10 delivered orders
* Normalisation: percentile ranking
* pct\_extreme\_late: binary flag, excluded from score
* Health score weights: 0.40/0.28/0.22/0.10
* Tier thresholds: 23.0 and 43.0
* Precision threshold: 70%
* Mixed category threshold: 90% ratio
* Low coverage threshold: 3 categorised reviews
* Complaint categories: 6 (final v3 dictionary)

### What I need help with next

1. Tableau dashboard planning — what to build,
how to structure it for the Head of Operations
and Seller Success team audiences
2. README writing — structure, content, and
how to present AI tool usage honestly
3. Project polish — any gaps before GitHub upload

### How to help me

* Think like a professional data analyst
* Help me develop my skills and guide me
* Cite references to back up claims and
data interpretations
* Keep the business scenario front of mind:
Head of Operations, Seller Success team,
platform reputation management







┌─────────────────────────────────────────────────────────────┐

│  PLATFORM HEALTH OVERVIEW                    \[Active in past 6 months]  │

├───────────┬───────────┬───────────┬─────────────────────────┤

│ Scoreable │ At Risk   │ Priority 1│ Active At Risk           │

│   1,238   │ 186 (15%) │    61     │ \[your count]            │

├───────────┴───────────┴───────────┴─────────────────────────┤

│                        │                                     │

│  Intervention Priority │   Dominant Failure Mode             │

│  (horiz. stacked bar)  │   (horiz. bar, sorted desc)         │

│                        │                                     │

│  P1 Immediate    61    │   Non-Delivery        83            │

│  P2 Logistics   106    │   Mixed Delivery      33            │

│  P3 Product      11    │   Delivery Delay      23            │

│  P4 Review        8    │   Wrong Product       \[n]           │

│                        │                                     │

├────────────────────────┴─────────────────────────────────────┤

│                                                              │

│   Brazil State Map — At Risk Seller Count by State          │

│   (filled/choropleth, colour intensity = count)             │

│                                                              │

│              \[callout text box — one insight sentence]       │

└──────────────────────────────────────────────────────────────┘



Seller ID | Health Score | Priority | Dominant Category | Total Orders | Avg Review Score | Late Order Rate | Extreme Late Flag | Compound Failure Flag

┌────────────┬────────────────────────────────────────────────┐

│  FILTERS   │  SELLER RISK EXPLORER                          │

│            │                                                │

│ Priority   │  Seller ID  │Score│Priority│Category│Orders   │

│ \[1]\[2]\[3]  │  abc123...  │ 8.2 │  P1    │Non-Del │  34    │

│ \[4]        │  def456...  │ 9.1 │  P1    │Delay   │  18    │

│            │  ...        │     │        │        │        │

│ Category   │                                                │

│ \[multisel] │  (sorted: priority asc, score asc within)     │

│            │                                                │

│ Flags      │  Late Rate │ 1-Star │ Extreme │ Compound      │

│ □ Extreme  │    %       │   %    │  Late   │ Failure       │

│ □ Compound │                                                │

│ □ Active   │                                                │

│            │  → Click row to open Seller Profile           │

└────────────┴────────────────────────────────────────────────┘







┌──────────────────────────────────────────────────────────────┐

│  ← Back to Explorer                                          │

│  Seller: \[ID]    Health Score: 8.2    Priority: IMMEDIATE   │

├─────────────────────────┬────────────────────────────────────┤

│  PERFORMANCE METRICS    │  COMPLAINT PROFILE                 │

│                         │                                    │

│  Metric    Seller  Plat │  Dominant: NON-DELIVERY            │

│  Avg Score  2.1   4.09  │                                    │

│  Late Rate  34%   8.1%  │  Non-Delivery      ████████ 12    │

│  1-Star     41%   11.5% │  Delivery Delay    ████     6     │

│  Del. Days  18.3  12.6  │  Wrong Product     ██       3     │

│                         │  Poor Comms        ██       3     │

│  Orders: 34

&#x20;  Orders categorized:              │                                    │

│  GMV: R$\[x]             │  ⚑ Extreme Late   ⚑ Compound     │

│  Active: YES            │  ⚑ Return/Refund                  │

│  Last order: \[date]     │                                    │

├─────────────────────────┴────────────────────────────────────┤

│  RECOMMENDED INTERVENTION                                    │

│  Priority 1 — Immediate: Delivery and communication failure. │

│  Escalate to logistics review. Outreach script should focus  │

│  on tracking communication and delivery timeline.            │

└──────────────────────────────────────────────────────────────┘



Add AOV

&#x20; 

### Reflections/Future Improvements:

* I should have created a active in past 6 month column in seller\_health\_scores.csv to make it easier in tableau. Generally speaking I lost sight of the temporal aspect of my analysis and identifying recently active sellers.
* I should add Sate and city information to the seller explorer and profiles as this could theoretically influence outreach efforts that are examining delivery systems in that sellers area. 
* It took a long time to make notes on everything to give a new reader all the context they need to understand the dashboard. Next time as I do my project I should keep track of all the definitions for metrics that I invent / create so that it is easier when I do my tableau project. 
After completing a notebook I think I should go through and make note of all of the important definitions, try and plan what I want to show in my visualizations as well. 
* When creating the README and tableau dashboard I was slowed down because of having to find definitions and justifications for methodological decisions when trying to build a narrative for the reader. One thing I think I can do in future is outline the sections that I know I am going to have in my README, methodology, glossary, deep dive insights etc. I should create  summaries of the relevant content for each section at the end of each notebook and also create separate documents for each so that at the end when I make my README I can put the full info into AI and ask it to filter for the most important parts. 



#### List of definitions I want to mention in tableau

* Active sellers are defined as having a order purchase timestamp within the last six months since the final purchase in the dataset i.e. 6 months before 2018-10-17. 
(Also how do you calculate the cutoff date 6 months before 2018-10-17? this was done in PostgreSQL using:
COUNT(CASE

&#x20;           WHEN ol.order\_purchase\_timestamp >=

&#x20;                (SELECT max\_date FROM last\_order\_date)

&#x20;                - INTERVAL '6 months'

&#x20;           THEN ol.order\_id

&#x20;       END)                                    AS orders\_last\_6\_months

* Low review coverage: Is defined as a seller with < 3 categorized reviews.
* Click any row to view it's seller profile.
* Final weight config for health scores:

The baseline weight configuration (review score 40%, 

late order rate 28%, 1-star rate 22%, actual delivery 

days 10%) is adopted as the primary scoring model. 

The 108 unstable sellers will be flagged in the 

Tableau dashboard as 'boundary cases' — their raw 

metric profiles should be reviewed directly by the 

Seller Success team rather than relying solely on 

tier classification.



Link to workbook on Tableau public:

https://public.tableau.com/app/profile/sam.walker3838/viz/OlistSellerRiskMonitor/Home





## Prompt for new conversation after completing Tableau Dashboards

## Project Context — Olist Seller Health Analysis

### Role and scenario

I am a data analyst on Olist's Seller Success team.
I was asked by the Head of Operations to identify
sellers who are negatively impacting platform
reputation and characterise what poor performance
looks like, so the team can prioritise proactive
outreach before issues escalate.

Olist is a Brazilian SaaS marketplace integrator
that connects small and medium-sized sellers to
major Brazilian online marketplaces under a shared
Olist Store brand. All sellers share collective
reputation — one underperforming seller affects
the whole platform.

### Stack

Python (pandas, matplotlib, seaborn, scipy),
PostgreSQL (pgAdmin), Jupyter Notebooks, Tableau,
deep-translator for review translation.

### Project structure

Brazil\_E-Commerce/

├── 01\_setup/

│   ├── 01\_create\_schema.sql

│   ├── 02\_load\_data.ipynb

│   ├── 03\_data\_validation.sql

│   └── 04\_foreign\_key\_constraints.sql

│

├── 02\_analysis/

│   ├── 05\_EDA.ipynb

│   ├── 06\_seller\_feature\_engineering.ipynb

│   └── 07\_review\_text\_analysis.ipynb

│

├── dashboard/

│   └── seller\_health\_dashboard.twbx

│

├── data/

│   ├── raw/

│   │   └── 9 original Kaggle CSVs

│   └── processed/

│       ├── at\_risk\_complaints\_long.csv

│       ├── at\_risk\_profiles\_final.csv

│       ├── seller\_excluded.csv

│       └── seller\_health\_scores.csv

│

├── .gitignore

├── AI\_diligence\_statement.txt

├── GLOSSARY.md

├── README.md

└── notes.md





### Dataset

Olist Brazilian E-Commerce public dataset from
Kaggle. 9 CSV files covering orders, customers,
sellers, products, payments, reviews, and
geolocation. Period: September 2016–October 2018. (Max order\_purchase\_timestamp = 2018-10-17 17:30:18)
99,441 orders. Analytical universe: 97,917 orders (Min order\_purchase\_timestamp = 2016-09-04 21:15:19)
with complete chain (items + delivery + review).

### What has been completed

**Notebook 05 — EDA**
Four analytical questions answered:

Q1 — Review score distribution: heavily right-skewed.
57.8% five-star, 11.5% one-star. Platform weighted
average: 4.09. One-star rate tracked separately as
it captures extreme dissatisfaction that averages
obscure.

Q2 — Seller order volume: 2,970 sellers with
delivered orders. Median 7 orders, mean 32.9,
heavily right-skewed. 58.4% of sellers have fewer
than 10 orders. Minimum scoring threshold set at
10 delivered orders. Revenue follows marketplace
power law — 17.9% of sellers generate 80% of GMV,
less concentrated than typical marketplace
benchmarks per Marketplace Pulse research.

Q3 — Delivery delay: 91.89% of orders delivered
early. Median order arrives 11.95 days ahead of
estimated date. Olist deliberately sets generous
estimated windows (avg 23.74 days) against actual
delivery of 12.56 days — an 11.18 day buffer
strategy. Only 8.11% of orders are late. Extreme
outliers: 360 orders (0.37%) more than 30 days late.

Q4 — Factors associated with low review scores:

* Spearman correlation (delay vs review score):
ρ = -0.1757, p < 0.0001 (weak but significant)
* Spearman correlation (actual delivery days vs
review score): ρ = -0.2344, p < 0.0001
* Mann-Whitney U test (late vs early/on-time):
U = 530,208,489, p < 0.0001
* Effect size (rank-biserial): -0.5534 (large)
Interpretation: 77.7% probability early order
has higher review score than late order
* Key finding: threshold effect not sliding scale.
Scores stable (4.24–4.33) across all early
delivery buckets, collapse to 3.18 for 0–7 days
late, further to \~1.6–1.75 for 7+ days late.
* Late order RATE is more discriminating than
average delay days given 92% early delivery.
* Actual delivery time is a stronger signal than
relative delay for customer satisfaction.

**Notebook 06 — Seller Feature Engineering
and Health Scoring**

Feature table built for 2,970 sellers using a
CTE-based SQL query that pre-aggregates to order
level to avoid multi-item order duplication.
Key features: total\_orders, total\_gmv,
avg\_review\_score, review\_response\_rate,
pct\_one\_star, avg\_actual\_delivery\_days,
avg\_delay\_days, late\_order\_rate, pct\_extreme\_late,
orders\_last\_6\_months, first/last order dates.

Scoring methodology:

* Scoreable population: 1,238 sellers
(10+ orders, non-null review score)
* Excluded: 1,732 sellers (insufficient history)
* Normalisation: percentile ranking within
scoreable population. Chosen over z-score and
min-max for interpretability and robustness
to skew.
* pct\_extreme\_late removed from score due to
zero inflation (83.4% of sellers have zero
extreme late orders — percentile ranking
non-discriminatory). Converted to binary flag.

Health score formula (0–100, higher = healthier):
health\_score =
(review\_score\_pct  × 0.40) +
(late\_rate\_pct     × 0.28) +
(one\_star\_pct      × 0.22) +
(delivery\_days\_pct × 0.10)

All inverted metrics (late\_rate, one\_star,
delivery\_days) use: 100 - percentile\_rank
so higher always means healthier.

Tier thresholds (based on score distribution):

* At Risk:  score < 23.0  → 186 sellers (15.0%)
* Monitor:  23.0–43.0     → 309 sellers (25.0%)
* Healthy:  > 43.0        → 743 sellers (60.0%)

Sensitivity analysis: 91.3% of sellers receive
identical tier across three weight configurations.
At Risk tier 87.6% stable. No sellers jump
between At Risk and Healthy — no contradictory
classifications.

Additional flags per seller:

* extreme\_late\_flag: at least one order >30 days late
* boundary\_case\_flag: tier changes across weight
configurations (108 sellers, 8.7%)

**Notebook 07 — Review Text Analysis**

Scope: 2,328 negative reviews (1–2 star) with
written comments from 186 At Risk sellers.

Methodology: keyword-based complaint categorisation
in Portuguese with prefix stemming. Six categories.
Iterative refinement through precision evaluation
(manual translation of 10 reviews per category
using deep-translator/Google Translate, evaluated
against 70% precision threshold).

Final precision scores:

* Non-Delivery:      90% — High confidence
* Poor Communication: 90% — High confidence
* Delivery Delay:    80% — High confidence
* Wrong Product:     80% — High confidence
* Product Quality:   70% — Moderate confidence
* Poor Packaging:    70% — Moderate confidence

Uncategorised: 40.0% of reviews (predominantly
short emotional expressions, positive text with
negative scores, idiomatic language).

Key refinement: partial delivery keywords
(só recebi, recebi apenas, so recebi) transferred
from Wrong Product to Non-Delivery after precision
evaluation revealed systematic miscategorisation.

Complaint distribution (categorised reviews,
n=1,397 from 180 sellers):

* Non-Delivery:       696 (49.8%)
* Delivery Delay:     441 (31.6%)
* Wrong Product:      218 (15.6%)
* Product Quality:    196 (14.0%)
* Poor Communication: 135 (9.7%)
* Poor Packaging:      65 (4.7%)
* Return/refund flag: 180 (7.7% — consequence
indicator, not primary category)

Delivery-related combined (deduplicated):
977 reviews (69.9%)
Product-related combined (deduplicated):
393 reviews (28.1%)

Seller complaint profiles built with:

* dominant\_category: primary failure mode
* Binary flags per category
* compound\_failure: avg 1.5+ categories per review
* delivery\_comms\_compound: delivery AND
communication failure co-present
* low\_review\_coverage: fewer than 3 categorised
reviews (directional only)
* intervention\_priority: 4-tier prioritization



**Tableau dashboard — three dashboards built and published:**

Dashboard 1 — Platform Health Overview (Head of Operations)



KPI strip: Scoreable (1,238), At Risk (186, 15%), Priority 1 (61)

Active sellers toggle filtering to orders between 2018-04-17 and 2018-10-17

Dominant category horizontal bar chart — top 8 categories, uncategorised excluded, delivery/product colour encoding

Intervention priority stacked bar with counts labelled

Brazil choropleth map — At Risk seller count by state, SP dominates (130/186)

Insight-driven titles throughout

Caption: "This visualization shows the top 8 of 16 dominant categories and excludes the 6 uncategorised sellers that did not have any categorized reviews"



Dashboard 2 — At Risk Seller Explorer (Seller Success Team)



Ranked table: Rank, Seller Id, Intervention Priority, Dominant Category, Health Score, Avg Review Score, Late Order Rate, Total Orders, Orders Last 6 Months, Low Review Coverage, Extreme Late Flag

Filters: Compound Failure, Active In Last 6 Months, Extreme Late Flag, Low Review Coverage, Intervention Priority, Dominant Category — grouped with section headers

Row colour encoding by Intervention Priority (consistent palette across all dashboards)

Filter action wired to Dashboard 3 on Seller Id

Title: "At Risk Seller Explorer" · subtitle: "186 at risk sellers · Sorted by intervention priority and health score"



Dashboard 3 — Seller Profile (Seller Success Team)



Header strip: Health Score, Rank, Seller Id, Priority (colour encoded), Dominant Category

Performance Metrics panel: Avg Review Score, Late Order Rate, Pct One Star Review, Average Delivery Days — each with seller value (conditionally red/green vs benchmark) and Platform Benchmark column. Benchmarks from full analytical universe (97,917 orders)

Order History panel: Active Period (First Order → Last Order), Total Orders, Total GMV R$, Orders In Last 6 Months

Review Profile panel: Total Negative Reviews, Total Categorised above complaint bar chart; bar chart coloured by category, sorted descending, zero counts filtered out

Flags panel: ⚑ Extreme Late Orders, ⚑ Delivery + Comms Failure in red; (!) Low Review Coverage in separate style; driven by calculated fields concatenated with CHAR(10)

Recommended Intervention panel: CASE-based text lookup by intervention priority, priority header in red, body text in black

Back to Seller Explorer navigation button top left

Filter action from Dashboard 2 targets all Dashboard 3 sheets on Seller Id across both data sources (at\_risk\_profiles\_final+ and at\_risk\_complaints\_long)



Home tab:



Title: Olist Seller Risk Monitor

Subtitle: Seller Success Team · Olist Operations

Data period and scored population context

How to use this workbook section (three dashboard descriptions)

Key Concepts section at bottom: Health Score, Risk Tiers, Intervention Priority definitions drawn from GLOSSARY.md

Footer: Analysis conducted by Samuel Walker · Olist Brazilian E-Commerce Dataset (Kaggle) · Built in Tableau Public

### Key findings

1. 186 sellers (15.0% of scoreable population)
are At Risk.
2. Delivery failure is the primary failure mode
for \~75% of At Risk sellers. Dominant category
distribution:

   * Non-Delivery: 83 sellers (44.6%)
   * Mixed Delivery Delay/Non-Delivery: 33 (17.7%)
   * Delivery Delay: 23 (12.4%)
   * Mixed categories (delivery-involved): \~16
3. Delivery Delay sellers are the worst performers
by health score (mean 10.30) despite being fewer
in number than Non-Delivery sellers (mean 13.59).
4. Wrong Product sellers have the highest 1-star
rate (27.93%) but the lowest late order rate
(8.52%) — product failure, not logistics failure.
5. 61 sellers (32.8% of At Risk) have delivery +
communication compound failure — the most
damaging pattern identified. Mean health score
12.2 vs 14.1 for non-compound sellers.
6. 45 sellers (24.2%) carry extreme late flag
(at least one order >30 days late).
7. 68 sellers (36.6%) have low review coverage
(<3 categorised reviews) — profiles directional.

### Intervention priority distribution

Priority 1 — Immediate (Delivery+Comms): 61
Priority 2 — Logistics Intervention:    106
Priority 3 — Product Intervention:       11
Priority 4 — Review Directly:             8

### Exported files

* data/processed/seller\_health\_scores.csv
(1,238 scoreable sellers with full metrics,
health score, tier, and flags)
* data/processed/seller\_excluded.csv  
(1,732 excluded sellers)
* data/processed/at\_risk\_profiles\_final.csv
(186 At Risk sellers with complaint profiles,
dominant category, intervention priority,
ranked by health score within priority tier)

### Key methodological decisions already made

These should not be re-litigated without good
reason:

* Minimum order threshold: 10 delivered orders
* Normalisation: percentile ranking
* pct\_extreme\_late: binary flag, excluded from score
* Health score weights: 0.40/0.28/0.22/0.10
* Tier thresholds: 23.0 and 43.0
* Precision threshold: 70%
* Mixed category threshold: 90% ratio
* Low coverage threshold: 3 categorised reviews
* Complaint categories: 6 (final v3 dictionary)

### What I need help with next

README writing — Please help me write my README using the following README Structure

#### README Structure:

Project Results Section:



1. Project Overview — 2–3 sentences, business scenario not tech
2. Data Structure Overview — intro to health score metrics, flags, complaint categories, domain knowledge for the reader
3. Executive Summary — aimed directly at the Head of Operations, key findings
4. Insights Deep Dive — additional layer of detail beneath the executive summary
5. Recommendations — tie everything together, outline next steps



Project Methodology Section:



6\. Methodology Overview — diagram or table showing notebook → output flow



7\. Repository Structure — annotated directory tree



8\. Data Source — Kaggle citation, dataset period, scope



9\. Technical Stack



10\. How to Reproduce — setup steps, dependencies



11\. Limitations and Caveats



12\. AI Tool Usage



#### Limitations to document in README:



* 40% uncategorised review rate — predominantly short emotional expressions and idiomatic Portuguese
* 1,732 sellers excluded for insufficient history
* Complaint categorisation precision validated on small samples (n=10 per category)
* avg\_actual\_delivery\_days partially influenced by geographic distance between seller and customer, not solely within seller control
* Platform benchmarks from full dataset differ from scoreable population benchmarks — full dataset chosen to represent customer experience

### How to help me

* Think like a professional data analyst
* Help me develop my skills and guide me
* Cite references to back up claims and
data interpretations
* Keep the business scenario front of mind:
Head of Operations, Seller Success team,
platform reputation management



/c/Users/samww/Documents/Codecademy\_projects/portfolio\_projects/Brazil\_E-Commerce



I accept your recommendation on "deduplicated". Please follow the actions you outlined regarding this. 







Question 1: 



There is no correct population average to site instead. You can mention that some reviews contained multiple different complaints and that sellers with over 1.5 complaints on average are flagged for having compounding customer complaints. You will have to remove the claim about customers mostly complaining about multiple issues. 







Question 2:



