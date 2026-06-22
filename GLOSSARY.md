\# Glossary and Data Dictionary



\## Scoring Metrics



\*\*health\_score\*\*

Composite seller health score ranging from 0 to 100 

where higher indicates healthier performance. 

Calculated as a weighted sum of four percentile-ranked 

components within the scoreable seller population 

(minimum 10 delivered orders).



Formula:

health\_score = 

&#x20; (review\_score\_pct  × 0.40) +

&#x20; (late\_rate\_pct     × 0.28) +

&#x20; (one\_star\_pct      × 0.22) +

&#x20; (delivery\_days\_pct × 0.10)



\*\*review\_score\_pct\*\*

Percentile rank of avg\_review\_score within the 

scoreable population. Higher = better.

Range: 0–100.



\*\*late\_rate\_pct\*\*

Inverted percentile rank of late\_order\_rate. 

Higher = better (lower late rate).

Formula: 100 - percentile\_rank(late\_order\_rate)

Range: 0–100.



\*\*one\_star\_pct\*\*

Inverted percentile rank of pct\_one\_star. 

Higher = better (lower 1-star rate).

Formula: 100 - percentile\_rank(pct\_one\_star)

Range: 0–100.



\*\*delivery\_days\_pct\*\*

Inverted percentile rank of avg\_actual\_delivery\_days. 

Higher = better (shorter delivery time).

Formula: 100 - percentile\_rank(avg\_actual\_delivery\_days)

Range: 0–100.



\---



\## Raw Performance Metrics



\*\*avg\_review\_score\*\*

Mean review score across all delivered orders with 

a review. Scale 1–5. Platform average: 4.09.

Nulls: 5 sellers had zero reviews — excluded from 

scoring.



\*\*late\_order\_rate\*\*

Percentage of delivered orders where 

order\_delivered\_customer\_date > 

order\_estimated\_delivery\_date.

Formula: (late orders / total delivered orders) × 100

Range: 0–100%.



\*\*pct\_one\_star\*\*

Percentage of reviews scoring 1 star out of all 

reviews received.

Formula: (1-star reviews / total reviews) × 100

Range: 0–100%.



\*\*avg\_actual\_delivery\_days\*\*

Mean number of days from order\_purchase\_timestamp 

to order\_delivered\_customer\_date across all 

delivered orders.

Note: partially influenced by geographic distance 

between seller and customer — not solely within 

seller control.



\*\*avg\_delay\_days\*\*

Mean number of days between actual delivery and 

estimated delivery date. Negative = early, 

positive = late. Platform mean: -11.18 days 

(orders typically arrive early due to Olist's 

deliberate buffer strategy of \~11 days).



\*\*review\_response\_rate\*\*

Percentage of delivered orders that received a 

written or scored review from the customer.

Formula: (orders with review / total orders) × 100

Platform mean: 99.3% — almost all orders receive 

a review score.



\*\*total\_gmv\*\*

Total Gross Merchandise Value — sum of all item 

prices across all delivered orders for a seller. 

Does not include freight value.



\*\*orders\_last\_6\_months\*\*

Count of delivered orders in the final 6 months 

of the dataset period (approximately March–August 

2018). Used as a recency signal — sellers with 

zero recent orders may be inactive.



\---



\## Risk Flags



\*\*extreme\_late\_flag\*\*

Binary (0/1). Fires when a seller has at least 

one delivered order more than 30 days later than 

the estimated delivery date.

Threshold rationale: >30 days late represents a 

qualitatively different failure (likely lost or 

severely misrouted shipment) from moderate lateness.

Note: excluded from composite health score due to 

zero inflation (83.4% of scoreable sellers have 

zero extreme late orders, making percentile ranking 

non-discriminatory). Retained as an independent 

warning indicator.



\*\*boundary\_case\_flag\*\*

Binary (0/1). Fires when a seller's tier 

classification changes across the three weight 

configurations tested in the sensitivity analysis 

(baseline 40/28/22/10, review-heavy 50/23/18/9, 

delivery-heavy 40/20/15/25).

Interpretation: seller sits near a tier boundary. 

Raw metrics should be reviewed directly rather 

than relying solely on tier label. Affects 108 

sellers (8.7% of scoreable population).



\*\*compound\_failure\*\* (General)

Binary (0/1). Fires when a seller's average number 

of complaint categories per negative review with 

text is 1.5 or higher.

Formula: 

avg\_complaints\_per\_review = 

&#x20; sum(category\_count) / total\_negative\_reviews

compound\_failure = 1 if avg >= 1.5, else 0

Interpretation: multi-complaint reviews are the 

norm for this seller — customers describe multiple 

distinct failure types simultaneously.

Only 4 sellers (2.2% of At Risk) meet this 

threshold.



\*\*delivery\_comms\_compound\*\*

Binary (0/1). Fires when a seller has at least 

one delivery-related review (delivery\_delay OR 

non\_delivery flag) AND at least one 

communication-related review (communication flag) 

across their review history.

Note: does not require both failures in the same 

review — measures co-occurrence across all reviews.

Interpretation: seller has demonstrated both 

fulfilment failure and communication failure. 

Identified in Section 6 as the most damaging 

compound pattern — customers have no resolution 

path when both failure modes are present.

Affects 61 At Risk sellers (32.8%).



\*\*low\_review\_coverage\*\*

Binary (0/1). Fires when a seller has fewer than 

3 categorised negative reviews with text.

Interpretation: complaint profile is based on 

very limited evidence and should be treated as 

directional rather than definitive. The Seller 

Success team should review all available reviews 

directly for these sellers.

Affects 68 At Risk sellers (36.6%).



\---



\## Complaint Categories



\*\*Delivery Delay\*\*

Reviews containing keywords describing late arrival 

or extended waiting relative to the estimated 

delivery date. Includes explicit delay language 

(atrasado, atraso) and waiting language 

(aguardando, estou esperando).

Precision: 80% (8/10 manual evaluation).



\*\*Non-Delivery\*\*

Reviews describing orders that never arrived, 

were marked delivered but not received, or 

arrived with fewer items than ordered (partial 

delivery).

Precision: 90% (9/10 manual evaluation).



\*\*Wrong Product\*\*

Reviews describing receipt of an incorrect item, 

wrong colour, wrong size, wrong model, or a 

product substantially different from the listing 

description or photos.

Precision: 80% (8/10 manual evaluation after 

keyword refinement — partial delivery keywords 

removed and transferred to Non-Delivery).



\*\*Product Quality\*\*

Reviews describing defective, broken, damaged, 

or poor quality products.

Precision: 70% (7/10 manual evaluation — sits 

at minimum threshold. False positives were 

predominantly description mismatch complaints 

overlapping with Wrong Product category).



\*\*Poor Communication\*\*

Reviews describing unresponsive sellers, ignored 

contacts, or failure to provide updates.

Precision: 90% (9/10 manual evaluation).



\*\*Poor Packaging\*\*

Reviews describing inadequate, damaged, or 

tampered packaging.

Precision: 70% (7/10 manual evaluation — small 

category, n=65 reviews).



\*\*flag\_return\_refund\*\* (not a primary category)

Binary flag indicating review mentions a return 

or refund request. Treated as a consequence 

indicator rather than a root cause — return 

requests typically result from another complaint 

type rather than being a standalone failure mode.



\---



\## Tier Classifications



\*\*🔴 At Risk\*\* (health score < 23.0)

186 sellers (15.0% of scoreable population). 

Priority intervention — Seller Success team 

outreach recommended.



\*\*🟡 Monitor\*\* (health score 23.0–43.0)

309 sellers (25.0% of scoreable population). 

Proactive monitoring — scheduled check-in 

recommended.



\*\*🟢 Healthy\*\* (health score > 43.0)

743 sellers (60.0% of scoreable population). 

No action required at this time.



\*\*Insufficient History\*\*

1,732 sellers with fewer than 10 delivered orders 

or zero review scores. Excluded from scoring. 

Retained in export for completeness.



\---



\## Intervention Priority Tiers (At Risk sellers only)



\*\*Priority 1 — Immediate Outreach\*\*

Sellers with delivery\_comms\_compound = 1. 

n=61 (32.8% of At Risk).

Rationale: compound failure with no communication 

path generates certain reputation damage.



\*\*Priority 2 — Logistics Intervention\*\*

Sellers with delivery-dominant complaint profile 

and no communication compound.

n=106 (57.0% of At Risk).

Rationale: fulfilment failure is the primary 

repair needed.



\*\*Priority 3 — Product Intervention\*\*

Sellers with product-dominant complaint profile.

n=11 (5.9% of At Risk).

Rationale: product-side failure requiring 

different intervention than logistics support.



\*\*Priority 4 — Review Directly\*\*

Sellers with mixed, uncategorised, or 

insufficient complaint profile data.

n=8 (4.3% of At Risk).

Rationale: insufficient evidence to assign 

a specific intervention type — raw metrics 

and reviews should be reviewed directly.



\---



\## Thresholds and Methodological Decisions



\*\*Minimum order threshold: 10 delivered orders\*\*

Established in EDA Q2. Sellers with fewer than 

10 delivered orders have insufficient history 

for reliable statistical scoring. Sensitivity 

to this threshold is flagged for future analysis.



\*\*Precision threshold: 70%\*\*

Minimum acceptable precision for complaint 

categories based on manual evaluation of 10 

randomly sampled translated reviews per category. 

Categories below 70% are excluded from primary 

findings.



\*\*Mixed dominant category threshold: 90% ratio\*\*

A seller receives a Mixed dominant category label 

when the second-highest complaint category has 

a review count within 90% of the highest. 

This prevents forcing a single label on sellers 

with genuinely ambiguous complaint profiles.



\*\*Low review coverage threshold: 3 reviews\*\*

Complaint profiles based on fewer than 3 

categorised reviews are flagged as low confidence. 

Consistent with general statistical guidance 

that group-level means based on fewer than 

10 observations are unreliable 

(Field, 2013, Discovering Statistics).



\*\*Percentile normalisation\*\*

All health score components are percentile-ranked 

within the scoreable population (n=1,238). 

Percentile ranking was chosen over z-score and 

min-max normalisation for three reasons: 

maximises dynamic range regardless of 

distribution skew, robust to outliers, and 

produces interpretable business-facing scores. 

See notebook 06 Section 4.1 for full rationale.

