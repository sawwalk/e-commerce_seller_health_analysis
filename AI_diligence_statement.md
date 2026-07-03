# AI Diligence Statement

**Olist Seller Health Analysis · Samuel Walker**

---

In creating this project, I collaborated with Claude (Anthropic) to assist with exploratory data analysis framing, SQL query drafting and debugging, statistical methodology review, Tableau calculated-field logic, and documentation (README, GLOSSARY) drafting and editing.

I affirm that all AI-generated and co-created content underwent thorough review and evaluation — including verifying statistical claims against primary sources, checking generated SQL against real query outputs on the Olist dataset, and testing methodology conclusions before accepting them into the final analysis. The final output reflects my own understanding of seller reputation risk on Olist's marketplace, my judgment about which analytical claims were adequately supported by the data, and my intended meaning throughout the health scoring system, complaint classification, and Seller Success dashboard built for this project.

While AI assistance was instrumental throughout — from initial exploratory analysis through final README and dashboard documentation — I maintain full responsibility for the content, its accuracy, and its presentation. This disclosure is made in the spirit of transparency and to acknowledge the role of AI in the creation of this project.

---

## Examples of Discernment

Ten instances, drawn from across the project, where I evaluated an AI-generated suggestion, output, or claim and used my own judgment to correct, refine, verify, or extend it before it entered the final analysis.

### 1. Challenging the "delivery delay causes bad reviews" framing
*Notebook 05, Q4*

An early framing treated Q4 as validating that delivery delay *causes* low review scores. I identified this as an oversimplification — there are many possible drivers of a bad review beyond delivery — and reframed the question from a single-hypothesis test into a broader investigation of factors associated with low review scores. This more analytically honest framing also directly motivated the text-analysis work in Notebook 07.

### 2. Verifying the null-delivery-dates assumption instead of accepting it
*Notebook 05*

Rather than accept an initial assumption that null delivery dates were primarily cancelled orders, I insisted on checking before documenting it. The status breakdown showed only 20.9% of null delivery dates were actually cancelled — 37.3% were shipped orders likely representing active fulfilment at the dataset cutoff. This changed how nulls are documented and handled throughout the seller health score.

### 3. Removing an unsupported statistical threshold claim
*Notebook 05, Q1*

A draft finding asserted that "a seller with an average score below 4.0 is a meaningful underperformer relative to platform norms." I identified this as unsupported — no standard deviation or seller-level score distribution had been calculated yet — and removed the claim, replacing it with a placeholder deferring to Notebook 06 rather than letting an unfounded assertion stand in the findings.

### 4. Correcting the revenue concentration risk narrative
*Notebook 05, Q2*

An initial framing suggested that 17.9% of sellers generating 80% of GMV represented a business concentration risk. I questioned whether the numbers actually supported that, and running the top-10-seller query directly showed the top 10 sellers hold only 13.15% of total GMV — broadly consistent with a normal marketplace Pareto distribution, not a risk signal. The finding was revised to reference the Marketplace Pulse industry benchmark instead of the unsupported risk claim.

### 5. Resolving a contradiction in Mann-Whitney U test assumptions
*Notebook 05, Q4*

One cited source stated the Mann-Whitney U test requires a continuous dependent variable; I identified a direct contradiction with another source that explicitly permitted ordinal variables. Rather than defer to either uncritically, I worked through both, documented the methodological nuance with citations to two academic sources, and confirmed a 1–5 star rating is an appropriate dependent variable for the test despite being ordinal.

### 6. Catching review_response_rate exceeding 100%
*Notebook 06*

The first version of the seller feature table returned review response rates above 100% for some sellers — a mathematical impossibility I caught during review rather than accepting the output. This led to diagnosing a multi-item order duplication problem in the join chain, and restructuring the query with a CTE that pre-aggregates to the order level before computing seller-level rates.

### 7. Independently testing actual delivery time as a second predictor
*Notebook 05, Q4*

After reviewing the delay-bucket analysis, I hypothesised — independently of any AI suggestion — that absolute delivery time might have a stronger relationship with review score than relative delay, and ran the Spearman test myself to check. It did (ρ = -0.2344 vs. -0.1757), adding a genuinely richer finding that distinguishes broken promises from absolute wait experience as separate drivers of dissatisfaction.

### 8. Catching a category-merge recommendation that would have missed the real overlap
*Notebook 07*

A merge of two complaint categories was proposed after one showed weak classification precision. I identified that the actual issue was a larger overlap with a *third*, different category — meaning the proposed merge would not have resolved the precision problem it was meant to fix. The categories were kept separate and the keyword dictionary was refined instead.

### 9. Adding weight sensitivity analysis as independent validation
*Notebook 06*

Rather than accept the health score's weighting scheme as final once it produced reasonable-looking tiers, I introduced a weight sensitivity analysis — testing how risk-tier assignment changed under alternative weight configurations — as an independent check on the scoring methodology's robustness before trusting it for seller-level intervention decisions.

### 10. Catching a logic gap in the automated intervention text
*Seller Health Dashboard*

The dashboard's automated recommendation text assigned every seller with a delivery-and-communication compound flag the same logistics-focused script, regardless of their actual dominant complaint category. I caught this on a specific seller whose dominant category was Wrong Product — a product-side issue — who was still receiving delivery-focused recommendations. This reflected a real logic gap (a presence-based flag with no magnitude threshold) rather than a wording issue, and led to rewriting the recommendation logic to branch on each seller's actual dominant complaint category.
