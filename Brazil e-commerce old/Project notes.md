**Project Brief:** Customer Insights \& Market Optimization



Dataset: Brazilian E-Commerce Public Dataset (Olist) https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce?resource=download

Context: A mid-sized e-commerce marketplace wants to improve customer satisfaction, optimize product distribution, and increase sales efficiency.



Questions I should be asking:

* What questions should I be asking?
* What do execs and stake holders care about?



**Business Objective**



Leverage transactional, review, and geolocation data to:

* Improve customer experience
* Identify high-performing markets
* Drive revenue growth through data-driven decision-making





**Analytical Objectives:**

1\. Customer Sentiment Analysis (Voice of Customer)

Use customer reviews to identify the key drivers of satisfaction and dissatisfaction across products and categories.



📏 Measurable Goals

Classify ≥90% of reviews into positive, neutral, or negative sentiment

Identify the top 5 factors driving negative reviews (e.g., delivery delays, product quality)

Quantify impact:

e.g., “Late deliveries account for 35% of 1–2 star reviews”





2\. Geospatial Sales Analysis (Market Opportunity Mapping)

Use geolocation data to identify where products sell best and uncover high-potential underserved regions.



📏 Measurable Goals

Map sales distribution across regions (state/city level)

Identify top 10 regions contributing ≥X% of revenue

Detect regions with:

High traffic but low conversion

High delivery times impacting sales





3\. Delivery Performance \& Revenue Impact Optimization (NEW)

Quantify how delivery time affects customer satisfaction and repeat purchasing, and identify opportunities to improve revenue through logistics optimization.



📏 Measurable Goals

Measure correlation between:

Delivery delay and review score

Identify:

% increase in negative reviews when delivery exceeds estimated date

Estimate revenue impact:

e.g., “A 1-day delay increases likelihood of negative review by 15%, reducing repeat purchase rate by X%”





🧱 Deliverables

📊 dashboards / Visualizations

* Sentiment dashboard (key complaint drivers)
* Geographic sales heatmap
* Delivery performance vs satisfaction analysis

📄 Final Report

* Key insights
* Business recommendations
* Estimated impact (revenue / retention)





**5 Key Business Questions:**

1\. What are the primary drivers of negative customer sentiment?

2\. How does delivery performance impact customer satisfaction and future behavior? Yes

3\. Which geographic regions generate the most revenue—and which are underperforming?

4\. Where are high-potential regions being limited by poor customer experience (e.g., delivery delays or low satisfaction)?

5\. Which product categories perform best in which regions, and how can marketing be targeted accordingly?





### Analysis:

The top contributing states in terms of revenue and order volume are:



revenue:

"SP"

"RJ"

"MG"

"RS"

"PR"

"SC"

the sales in these states combined makes up 78% of total revenue and 81% of total order volume.

SP dominates the sales and revenue categories.



"state"	"revenue"	"pct\_revenue"

"SP"	5202955.05	38.3

"RJ"	1824092.67	13.4

"MG"	1585308.03	11.7

"RS"	750304.02	5.5

"PR"	683083.76	5.0

"SC"	520553.34	3.8



"state"	"num\_orders" "pct\_orders"

"SP"	41746	42.0

"RJ"	12852	12.9

"MG"	11635	11.7

"RS"	5466	5.5

"PR"	5045	5.1

"SC"	3637	3.7







PostgreSQL: (Design table schema)

CREATE TABLE orders (

&#x20;   order\_id TEXT PRIMARY KEY,

&#x20;   customer\_id TEXT,

&#x20;   order\_status TEXT,

&#x20;   order\_purchase\_timestamp TIMESTAMP,

&#x20;   order\_approved\_at TIMESTAMP,

&#x20;   order\_delivered\_carrier\_date TIMESTAMP,

&#x20;   order\_delivered\_customer\_date TIMESTAMP,

&#x20;   order\_estimated\_delivery\_date TIMESTAMP

);



CREATE TABLE customers (

&#x20;   customer\_id TEXT PRIMARY KEY,

&#x20;   customer\_unique\_id TEXT,

&#x20;   customer\_zip\_code\_prefix INT,

&#x20;   customer\_city TEXT,

&#x20;   customer\_state TEXT

);



CREATE TABLE reviews (

&#x20;   review\_id TEXT PRIMARY KEY,

&#x20;   order\_id TEXT,

&#x20;   review\_score INT,

&#x20;   review\_comment\_title TEXT,

&#x20;   review\_comment\_message TEXT,

&#x20;   review\_creation\_date TIMESTAMP,

&#x20;   review\_answer\_timestamp TIMESTAMP

);





(in cmd)
psql -U postgres -d "Brazilian-E-Commerce"

\--> password f1sh3r

\--Note using COPY is the fastest way to import data.



\\copy orders FROM 'C:/Users/samww/Documents/Codecademy\_projects/portfolio\_projects/ChatGPT Project Brazilian E-Commerce Analysis/data archive/olist\_orders\_dataset.csv' DELIMITER ',' CSV HEADER;



\\copy customers FROM 'C:/Users/samww/Documents/Codecademy\_projects/portfolio\_projects/ChatGPT Project Brazilian E-Commerce Analysis/data archive/olist\_customers\_dataset.csv' DELIMITER ',' CSV HEADER;



\\copy reviews FROM 'C:/Users/samww/Documents/Codecademy\_projects/portfolio\_projects/ChatGPT Project Brazilian E-Commerce Analysis/data archive/olist\_order\_reviews\_dataset.csv' DELIMITER ',' CSV HEADER;

\-- This came up with an error, ERROR:  character with byte sequence 0x8f in encoding "WIN1252" has no equivalent in encoding "UTF8".



\-- new approach (remove invalid characters) in python:

import pandas as pd

import re



input\_path = r"C:\\Users\\samww\\Documents\\Codecademy\_projects\\portfolio\_projects\\ChatGPT Project Brazilian E-Commerce Analysis\\data archive\\olist\_order\_reviews\_dataset.csv"

output\_path = r"C:\\Users\\samww\\Documents\\Codecademy\_projects\\portfolio\_projects\\ChatGPT Project Brazilian E-Commerce Analysis\\data archive\\olist\_order\_reviews\_dataset\_clean\_final.csv"



\# Read raw data

df = pd.read\_csv(input\_path, encoding='latin1', engine='python')



\# Optional: remove any remaining non-printable characters

def clean\_text(x):

&#x20;   return re.sub(r'\[^\\x20-\\x7E]+', ' ', x) if isinstance(x, str) else x



for col in df.select\_dtypes(include=\['object']).columns:

&#x20;   df\[col] = df\[col].apply(clean\_text)



\# Save clean file

df.to\_csv(output\_path, index=False, encoding='utf-8')



now go back to psql:

\\copy reviews FROM 'C:/Users/samww/Documents/Codecademy\_projects/portfolio\_projects/ChatGPT Project Brazilian E-Commerce Analysis/data archive/olist\_order\_reviews\_dataset\_clean\_final.csv' DELIMITER ',' CSV HEADER;

\-- worked



\-- Index inspection

SELECT indexname, indexdef

FROM pg\_indexes

WHERE tablename = 'customers';





\-- Now in pgAdmin

\-- make a bunch of indexes to increase performance.

CREATE INDEX idx\_orders\_customer\_id ON orders(customer\_id);

CREATE INDEX idx\_orders\_purchase\_time ON orders(order\_purchase\_timestamp);



CREATE INDEX idx\_reviews\_order\_id ON order\_reviews(order\_id);

CREATE INDEX idx\_reviews\_score ON order\_reviews(review\_score);



CREATE INDEX idx\_order\_items\_order\_id ON order\_items(order\_id);

CREATE INDEX idx\_order\_items\_product\_id ON order\_items(product\_id);



CREATE INDEX idx\_customers\_zip ON customers(customer\_zip\_code\_prefix);

CREATE INDEX idx\_customers\_state ON customers(customer\_state);



CREATE INDEX idx\_products\_category ON products(product\_category\_name);



\-- add primary keys:

ALTER TABLE customers ADD CONSTRAINT pk\_costomer\_id PRIMARY KEY (customer\_id);

ALTER TABLE orders ADD CONSTRAINT pk\_order\_id PRIMARY KEY(order\_id);

ALTER TABLE products ADD CONSTRAINT pk\_product\_id PRIMARY KEY(product\_id);



\--**DATA VALIDATION:** (completeness checks, referential integrity validation, and logical consistency testing)

**1. Missing Data \& Null Analysis (Completeness Check)**

SELECT

&#x20;   COUNT(\*) AS total\_rows,

&#x20;   COUNT(order\_delivered\_customer\_date) AS delivered\_count,

&#x20;   COUNT(\*) - COUNT(order\_delivered\_customer\_date) AS missing\_deliveries

FROM orders;

\-- 99441 96476 2965





SELECT

&#x20;   COUNT(\*) AS total\_rows,

&#x20;

&#x20;   COUNT(\*) - COUNT(order\_purchase\_timestamp) AS missing\_purchase\_time,

&#x20;   COUNT(\*) - COUNT(order\_delivered\_customer\_date) AS missing\_delivery\_time,

&#x20;   COUNT(\*) - COUNT(order\_estimated\_delivery\_date) AS missing\_estimated\_delivery

&#x20;

FROM orders;





\--How much is missing from order\_delivered\_customer\_date?

SELECT

&#x20;   COUNT(\*) AS total\_orders,

&#x20;   COUNT(\*) - COUNT(order\_delivered\_customer\_date) AS missing\_delivery,

&#x20;   ROUND(100.0 \* (COUNT(\*) - COUNT(order\_delivered\_customer\_date)) / COUNT(\*), 2) AS missing\_pct

FROM orders;

\-- 3%.





\-- Here we try to determine the type of missingness from the order\_delivered\_customer\_date column.



\--Check missingness by order\_status.

SELECT

&#x20;   order\_status,

&#x20;   COUNT(\*) AS total\_orders,

&#x20;   COUNT(\*) - COUNT(order\_delivered\_customer\_date) AS missing\_delivery,

&#x20;   ROUND(100.0 \* (COUNT(\*) - COUNT(order\_delivered\_customer\_date)) / COUNT(\*), 2) AS missing\_pct

FROM orders

GROUP BY order\_status

ORDER BY missing\_pct DESC;



\--Clearly we have some structurally missing data, or MNAR only 8 out of 96K orders with 'delivered' order status are missing a timestamp, all other categories have about 100% missingness.



\-- investiatge 8 anomalies:

SELECT \*

FROM orders

WHERE order\_status = 'delivered'

AND order\_delivered\_customer\_date IS NULL;



\-- check time based missingness:

SELECT

&#x20;   DATE\_TRUNC('month', order\_purchase\_timestamp::timestamp) AS month,

&#x20;   COUNT(\*) AS total\_orders,

&#x20;   COUNT(\*) - COUNT(order\_delivered\_customer\_date) AS missing\_delivery

FROM orders

GROUP BY month

ORDER BY month;





\-- missingness over time:

SELECT

&#x09;DATE\_TRUNC('month', order\_purchase\_timestamp::timestamp) AS month,

&#x20;   COUNT(\*) AS total\_orders,

&#x20;   COUNT(\*) - COUNT(order\_delivered\_customer\_date) AS missing\_delivery,

&#x09;ROUND(100.0 \* (COUNT(\*) - COUNT(order\_delivered\_customer\_date)) / COUNT(\*), 2) AS missing\_pct

FROM orders

GROUP BY month

ORDER BY month;



\--See reviews with missingness

SELECT

&#x20;   o.order\_id,

&#x20;   o.order\_status,

&#x20;   o.order\_purchase\_timestamp,

&#x20;   o.order\_delivered\_customer\_date,

&#x20;   r.review\_score,

&#x20;   r.review\_comment\_message

FROM orders o

JOIN order\_reviews r

&#x20;   ON o.order\_id = r.order\_id

WHERE o.order\_delivered\_customer\_date IS NULL

&#x09;AND r.review\_comment\_message IS NOT NULL

\--ORDER BY o.order\_purchase\_timestamp DESC

LIMIT 10;

\--It seems that products are in-fact not arriving although some invoiced products do arrive.



SELECT

&#x20;   COUNT(o.order\_id) AS orders,

&#x20;   o.order\_status,

&#x20;   AVG(r.review\_score) AS avg\_review

FROM orders o

JOIN order\_reviews r

&#x20;   ON o.order\_id = r.order\_id

WHERE o.order\_delivered\_customer\_date IS NULL

GROUP BY o.order\_status;



\--Check reviews from 8 delivered but no delivery time.

SELECT

&#x20;   o.order\_id,

&#x20;   o.order\_status,

&#x20;   o.order\_purchase\_timestamp,

&#x20;   o.order\_delivered\_customer\_date,

&#x20;   r.review\_score,

&#x20;   r.review\_comment\_message

FROM orders o

JOIN order\_reviews r

&#x20;   ON o.order\_id = r.order\_id

WHERE o.order\_delivered\_customer\_date IS NULL

&#x09;AND order\_status = 'delivered';

\--We can see here that deliveries were actually made for the 8 orders with 'delivered' status but missing 'order\_delivered\_customer\_date', infact they were generally made abnormally quickly.



\--

WITH count\_greater\_than\_two AS (

&#x09;SELECT

&#x09;    o.order\_status,

&#x09;    COUNT(r.review\_score) AS more\_than\_3\_count

&#x09;FROM orders o

&#x09;JOIN order\_reviews r

&#x09;    ON o.order\_id = r.order\_id

&#x09;WHERE o.order\_delivered\_customer\_date IS NULL

&#x09;	AND review\_score > 3

&#x09;GROUP BY o.order\_status

),

totals AS (

&#x09;SELECT

&#x09;    o.order\_status,

&#x09;    COUNT(r.review\_score) AS total\_count

&#x09;FROM orders o

&#x09;JOIN order\_reviews r

&#x09;    ON o.order\_id = r.order\_id

&#x09;WHERE o.order\_delivered\_customer\_date IS NULL

&#x09;GROUP BY o.order\_status

)

SELECT

&#x09;g.order\_status,

&#x09;g.more\_than\_3\_count,

&#x09;t.total\_count,

&#x09;ROUND(100.0 \* (g.more\_than\_3\_count)/t.total\_count, 2) AS pct\_greater\_than\_3

FROM count\_greater\_than\_two g

JOIN totals t

&#x09;ON g.order\_status = t.order\_status;

\--Since 20% of 'shipped' status orders have a review score of 4 or 5 we can probably assume that these packages were actually delivered.



SELECT

&#x09;o.order\_id,

&#x09;o.order\_status,

&#x09;o.order\_purchase\_timestamp,

&#x09;r.review\_score,

&#x09;r.review\_comment\_message AS review\_message

FROM orders o

JOIN order\_reviews r

&#x09;ON o.order\_id = r.order\_id

WHERE o.order\_delivered\_customer\_date IS NULL

&#x09;AND review\_score > 3

&#x09;AND review\_comment\_message IS NOT NULL;

\--this next query explores the written messages to null delivery time orders with a high (4-5) review score. responses vary from great and arrived earlier than expected, to issues with the post office or waiting for refund etc.





\--check if missingness is correlated with the **product**.

SELECT

&#x20;   oi.product\_id,

&#x20;   COUNT(DISTINCT o.order\_id) AS missing\_delivery\_orders

FROM orders o

JOIN order\_items oi

&#x20;   ON o.order\_id = oi.order\_id

WHERE o.order\_delivered\_customer\_date IS NULL

GROUP BY oi.product\_id

ORDER BY missing\_delivery\_orders DESC;





\-- --check if missingness is correlated with the **seller**.

SELECT

&#x20;   oi.seller\_id,

&#x20;   COUNT(DISTINCT o.order\_id) AS total\_orders,

&#x20;   COUNT(DISTINCT o.order\_id) FILTER (

&#x20;       WHERE o.order\_delivered\_customer\_date IS NULL

&#x20;   ) AS missing\_delivery\_orders,

&#x20;   ROUND(

&#x20;       100.0 \* COUNT(DISTINCT o.order\_id) FILTER (

&#x20;           WHERE o.order\_delivered\_customer\_date IS NULL

&#x20;       )

&#x20;       / COUNT(DISTINCT o.order\_id),

&#x20;       2

&#x20;   ) AS missing\_pct

FROM orders o

JOIN order\_items oi

&#x20;   ON o.order\_id = oi.order\_id

GROUP BY oi.seller\_id

ORDER BY missing\_pct DESC;

\-- While some sellers do appear to have lower rates of missingness than others there is not a strong enough trend to determine that the sellers influence the missingness strongly.





\--Check if missingness is correlated with **buyer** state:

SELECT

&#x20;   c.customer\_state AS buyer\_state,

&#x20;

&#x20;   COUNT(DISTINCT o.order\_id) AS total\_orders,

&#x20;

&#x20;   COUNT(DISTINCT o.order\_id) FILTER (

&#x20;       WHERE o.order\_delivered\_customer\_date IS NULL

&#x20;   ) AS missing\_delivery\_orders,

&#x20;

&#x20;   ROUND(

&#x20;       100.0 \* COUNT(DISTINCT o.order\_id) FILTER (

&#x20;           WHERE o.order\_delivered\_customer\_date IS NULL

&#x20;       )

&#x20;       / COUNT(DISTINCT o.order\_id),

&#x20;       2

&#x20;   ) AS missing\_pct



FROM orders o

JOIN customers c

&#x20;   ON o.customer\_id = c.customer\_id



GROUP BY c.customer\_state

ORDER BY missing\_pct DESC;





\--Check if missingness is correlated with **seller** state:

SELECT

&#x20;   s.seller\_state,

&#x20;

&#x20;   COUNT(DISTINCT o.order\_id) AS total\_orders,

&#x20;

&#x20;   COUNT(DISTINCT o.order\_id) FILTER (

&#x20;       WHERE o.order\_delivered\_customer\_date IS NULL

&#x20;   ) AS missing\_delivery\_orders,

&#x20;

&#x20;   ROUND(

&#x20;       100.0 \* COUNT(DISTINCT o.order\_id) FILTER (

&#x20;           WHERE o.order\_delivered\_customer\_date IS NULL

&#x20;       )

&#x20;       / COUNT(DISTINCT o.order\_id),

&#x20;       2

&#x20;   ) AS missing\_pct



FROM orders o

JOIN order\_items oi

&#x20;   ON o.order\_id = oi.order\_id

JOIN sellers s

&#x20;   ON oi.seller\_id = s.seller\_id

GROUP BY s.seller\_state

ORDER BY missing\_pct DESC;





**2. Referential Integrity Checks (Join Consistency)**

SELECT COUNT(\*) AS broken\_links

FROM orders o

LEFT JOIN customers c ON o.customer\_id = c.customer\_id

WHERE c.customer\_id IS NULL;

\-- 0 (good)



SELECT COUNT(\*) AS orphan\_reviews

FROM order\_reviews r

LEFT JOIN orders o ON r.order\_id = o.order\_id

WHERE o.order\_id IS NULL;

\-- 0



**3. Outliers \& Logical Consistency Checks**

SELECT

&#x20;   MIN(order\_delivered\_customer\_date::timestamp - order\_purchase\_timestamp::timestamp) AS min\_delivery\_time,

&#x20;   MAX(order\_delivered\_customer\_date::timestamp - order\_purchase\_timestamp::timestamp) AS max\_delivery\_time

FROM orders;

\-- "12:48:07"	"209 days 15:05:12"



SELECT \*

FROM orders

WHERE order\_delivered\_customer\_date::timestamp < order\_purchase\_timestamp::timestamp;

\-- empty rows



SELECT review\_score, COUNT(\*)

FROM order\_reviews

GROUP BY review\_score

ORDER BY review\_score;



SELECT

&#x20;   MIN(price),

&#x20;   MAX(price),

&#x20;   AVG(price)

FROM order\_items;





**4. Duplicate detection**

SELECT order\_id, COUNT(\*)

FROM orders

GROUP BY order\_id

HAVING COUNT(\*) > 1;

\-empty rows (There are no duplicate order\_ids).





**.1 Sentiment analysis \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_**

\-- Create a view to begin.

CREATE VIEW review\_sentiment AS

SELECT

&#x20;   r.review\_id,

&#x20;   r.order\_id,

&#x20;   r.review\_score,

&#x20;   CASE

&#x20;       WHEN r.review\_score >= 4 THEN 'positive'

&#x20;       WHEN r.review\_score = 3 THEN 'neutral'

&#x20;       ELSE 'negative'

&#x20;   END AS sentiment\_label,

&#x20;   r.review\_comment\_message,

&#x09;r.review\_comment\_title,

&#x09;oi.product\_id,

&#x09;oi.seller\_id,

&#x09;oi.price,

&#x09;o.customer\_id,

&#x09;o.order\_purchase\_timestamp,

&#x09;o.order\_delivered\_customer\_date

FROM order\_reviews r

JOIN order\_items oi

&#x09;ON r.order\_id = oi.order\_id

JOIN orders o

&#x09;ON o.order\_id = oi.order\_id

JOIN customers c

&#x09;ON c.customer\_id = o.customer\_id;





SELECT \* FROM review\_sentiment;

SELECT COUNT(DISTINCT order\_id) FROM review\_sentiment;

SELECT \* FROM orders;



SELECT 100.0\*(99441.0 - 97917.0)/99441.0;

\-- 1.53% missing order\_ids from review\_sentiment. Assume that it is MAR and excluding the rows should be fine.



\--next figure out how much data we are missing because of inner joins.



**Audit tables for join health analysis**

CREATE TABLE join\_audit (

&#x20;   relationship\_name TEXT,

&#x20;   table\_a TEXT,

&#x20;   table\_b TEXT,

&#x20;   join\_key TEXT,

&#x20;

&#x20;   rows\_in\_a BIGINT,

&#x20;   rows\_in\_b BIGINT,

&#x20;

&#x20;   matched\_rows BIGINT,

&#x20;   a\_not\_in\_b BIGINT,

&#x20;   b\_not\_in\_a BIGINT,

&#x20;

&#x20;   pct\_a\_not\_in\_b NUMERIC(5,2),

&#x20;   pct\_b\_not\_in\_a NUMERIC(5,2),

&#x20;

&#x20;   audit\_timestamp TIMESTAMP DEFAULT CURRENT\_TIMESTAMP

);





\-- Upload join health info logic

WITH a AS (

&#x20;   SELECT DISTINCT key FROM table\_a

),

b AS (

&#x20;   SELECT DISTINCT key FROM table\_b

)

SELECT

&#x20;   COUNT(\*) FILTER (WHERE a.key IS NOT NULL AND b.key IS NOT NULL) AS matched,

&#x20;   COUNT(\*) FILTER (WHERE a.key IS NOT NULL AND b.key IS NULL) AS a\_missing,

&#x20;   COUNT(\*) FILTER (WHERE a.key IS NULL AND b.key IS NOT NULL) AS b\_missing

FROM a

FULL OUTER JOIN b

ON a.key = b.key;



\-- Example auditing orders and order\_reviews

INSERT INTO join\_audit

WITH a AS (

&#x20;   SELECT DISTINCT order\_id FROM orders

),

b AS (

&#x20;   SELECT DISTINCT order\_id FROM order\_reviews

),

counts AS (

&#x20;   SELECT

&#x20;       COUNT(\*) FILTER (WHERE a.order\_id IS NOT NULL AND b.order\_id IS NOT NULL) AS matched\_rows,

&#x20;       COUNT(\*) FILTER (WHERE a.order\_id IS NOT NULL AND b.order\_id IS NULL) AS a\_not\_in\_b,

&#x20;       COUNT(\*) FILTER (WHERE a.order\_id IS NULL AND b.order\_id IS NOT NULL) AS b\_not\_in\_a,

&#x20;       (SELECT COUNT(\*) FROM a) AS rows\_in\_a,

&#x20;       (SELECT COUNT(\*) FROM b) AS rows\_in\_b

&#x20;   FROM a

&#x20;   FULL OUTER JOIN b

&#x20;   ON a.order\_id = b.order\_id

)

SELECT

&#x20;   'orders ↔ order\_reviews',

&#x20;   'orders',

&#x20;   'order\_reviews',

&#x20;   'order\_id',

&#x20;   rows\_in\_a,

&#x20;   rows\_in\_b,

&#x20;   matched\_rows,

&#x20;   a\_not\_in\_b,

&#x20;   b\_not\_in\_a,

&#x20;   ROUND(100.0 \* a\_not\_in\_b / rows\_in\_a, 2),

&#x20;   ROUND(100.0 \* b\_not\_in\_a / rows\_in\_b, 2),

&#x20;   CURRENT\_TIMESTAMP

FROM counts;





\-- View results

SELECT \*

FROM join\_audit

ORDER BY pct\_a\_not\_in\_b DESC;



\-- Modify if needed

DELETE FROM join\_audit WHERE audit\_timestamp = '2026-03-29 13:22:04.861066';



**Create a review sentiment table which keeps track of key words**

CREATE TABLE review\_sentiment\_table AS

SELECT

&#x20;   r.review\_id,

&#x20;   r.order\_id,

&#x20;   r.review\_score,

&#x20;   CASE

&#x20;       WHEN r.review\_score >= 4 THEN 'positive'

&#x20;       WHEN r.review\_score = 3 THEN 'neutral'

&#x20;       ELSE 'negative'

&#x20;   END AS sentiment\_label,

&#x20;   r.review\_comment\_message,

&#x09;

&#x09;CASE WHEN review\_comment\_message ILIKE '%atraso%'

&#x20;          OR review\_comment\_message ILIKE '%demora%'

&#x20;        THEN 1 ELSE 0 END AS delivery\_issue,

&#x20;

&#x20;   CASE WHEN review\_comment\_message ILIKE '%defeito%'

&#x20;          OR review\_comment\_message ILIKE '%ruim%'

&#x20;        THEN 1 ELSE 0 END AS quality\_issue,

&#x20;

&#x20;   CASE WHEN review\_comment\_message ILIKE '%errado%'

&#x20;        THEN 1 ELSE 0 END AS wrong\_item,

&#x20;

&#x20;   CASE WHEN review\_comment\_message ILIKE '%faltando%'

&#x20;        THEN 1 ELSE 0 END AS missing\_item,

&#x09;

&#x09;r.review\_comment\_title,

&#x09;oi.product\_id,

&#x09;oi.seller\_id,

&#x09;oi.price,

&#x09;o.customer\_id,

&#x09;o.order\_purchase\_timestamp,

&#x09;o.order\_delivered\_customer\_date

FROM order\_reviews r

JOIN order\_items oi

&#x09;ON r.order\_id = oi.order\_id

JOIN orders o

&#x09;ON o.order\_id = oi.order\_id

JOIN customers c

&#x09;ON c.customer\_id = o.customer\_id;





**Summarize findings:**

SELECT

&#x20;   sentiment\_label,

&#x09;SUM(delivery\_issue) AS delivery\_issues,

&#x20;   SUM(quality\_issue) AS quality\_issues,

&#x20;   SUM(wrong\_item) AS wrong\_item\_issues,

&#x20;   SUM(missing\_item) AS missing\_item\_issues,

&#x20;   COUNT(\*) AS total\_category\_reviews,

&#x09;ROUND(100.0 \* SUM(delivery\_issue) / COUNT(\*), 2) AS pct\_delivery\_issues,

&#x09;ROUND(100.0 \* SUM(quality\_issue) / COUNT(\*), 2) AS pct\_quality\_issue,

&#x09;ROUND(100.0 \* SUM(wrong\_item) / COUNT(\*), 2) AS pct\_wrong\_item,

&#x09;ROUND(100.0 \* SUM(missing\_item) / COUNT(\*), 2) AS pct\_missing\_item

FROM review\_sentiment\_table

GROUP BY sentiment\_label;



\-- Or



SELECT

&#x20;   sentiment\_label,

&#x09;SUM(delivery\_issue) AS delivery\_issues,

&#x20;   SUM(quality\_issue) AS quality\_issues,

&#x20;   SUM(wrong\_item) AS wrong\_item\_issues,

&#x20;   SUM(missing\_item) AS missing\_item\_issues,

&#x20;   COUNT(\*) AS total\_category\_reviews,

&#x09;ROUND(100.0 \* SUM(delivery\_issue) / COUNT(\*) FILTER (WHERE review\_comment\_message IS NOT NULL), 2) AS pct\_delivery\_issues,

&#x09;ROUND(100.0 \* SUM(quality\_issue) / COUNT(\*) FILTER (WHERE review\_comment\_message IS NOT NULL), 2) AS pct\_quality\_issue,

&#x09;ROUND(100.0 \* SUM(wrong\_item) / COUNT(\*) FILTER (WHERE review\_comment\_message IS NOT NULL), 2) AS pct\_wrong\_item,

&#x09;ROUND(100.0 \* SUM(missing\_item) / COUNT(\*) FILTER (WHERE review\_comment\_message IS NOT NULL), 2) AS pct\_missing\_item,

&#x09;COUNT(\*) FILTER (WHERE review\_comment\_message IS NOT NULL) AS non\_null\_reviews

FROM review\_sentiment\_table

GROUP BY sentiment\_label;



**Investigate drivers of review\_score:**

\-- **Price:**

SELECT

&#x20;   CORR(review\_score, price) AS corr\_review\_price

FROM review\_sentiment\_table

WHERE price IS NOT NULL;





SELECT

&#x20;   CASE

&#x20;       WHEN price < 50 THEN 'low'

&#x20;       WHEN price < 150 THEN 'mid'

&#x20;       ELSE 'high'

&#x20;   END AS price\_segment,

&#x20;   AVG(review\_score) AS avg\_review,

&#x20;   COUNT(\*) AS total\_reviews,

&#x20;   ROUND( 100.0 \* COUNT(\*) FILTER (WHERE review\_score <= 2) / COUNT(\*), 2) AS pct\_negative

FROM review\_sentiment\_table

GROUP BY price\_segment

ORDER BY price\_segment;



**-- Delivery time:**

\--correlation coefficient

SELECT

&#x09;CORR(

&#x20;   review\_score,

&#x20;   EXTRACT(EPOCH FROM (order\_delivered\_customer\_date::timestamp - order\_purchase\_timestamp::timestamp))

&#x09;/ 86400

&#x09;) AS corr\_delivery\_review

FROM review\_sentiment\_table

WHERE order\_delivered\_customer\_date IS NOT NULL;





\--Bucket analysis

SELECT

&#x20;   CASE

&#x20;       WHEN delivery\_days <= 3 THEN 'fast'

&#x20;       WHEN delivery\_days <= 7 THEN 'normal'

&#x20;       ELSE 'slow'

&#x20;   END AS delivery\_speed,

&#x20;   AVG(review\_score) AS avg\_review,

&#x20;   COUNT(\*) AS n\_orders

FROM (

&#x20;   SELECT

&#x20;       review\_score,

&#x20;       EXTRACT(EPOCH FROM (order\_delivered\_customer\_date::timestamp

&#x20;- order\_purchase\_timestamp::timestamp

)) / 86400 AS delivery\_days

&#x20;   FROM review\_sentiment\_table

&#x20;   WHERE order\_delivered\_customer\_date IS NOT NULL

) t

GROUP BY delivery\_speed

ORDER BY delivery\_speed;





\-- deliveries within X days have Y% better reviews than when it takes longer than X days.

SELECT

&#x20;   CASE

&#x20;       WHEN delivery\_days <= 7 THEN 'on\_time'

&#x20;       ELSE 'delayed'

&#x20;   END AS delivery\_status,

&#x20;   COUNT(\*) FILTER (WHERE sentiment\_label = 'negative') \* 1.0 / COUNT(\*) AS pct\_negative

FROM (

&#x20;   SELECT

&#x20;       sentiment\_label,

&#x20;       EXTRACT(EPOCH FROM (order\_delivered\_customer\_date::timestamp

&#x20;- order\_purchase\_timestamp::timestamp

)) / 86400 AS delivery\_days

&#x20;   FROM review\_sentiment\_table

&#x20;   WHERE order\_delivered\_customer\_date IS NOT NULL

) t

GROUP BY delivery\_status;





**Seller performance**

SELECT

&#x20;   r.seller\_id,

&#x20;   s.seller\_city,

&#x20;   s.seller\_state,

&#x20;   AVG(r.review\_score) AS avg\_score,

&#x20;   COUNT(r.\*) AS total\_reviews,

&#x20;

&#x20;   COUNT(r.\*) FILTER (WHERE r.review\_score >= 4) AS count\_positive,

&#x20;   COUNT(r.\*) FILTER (WHERE r.review\_score = 3) AS count\_neutral,

&#x20;   COUNT(r.\*) FILTER (WHERE r.review\_score <= 2) AS count\_negative

FROM review\_sentiment\_table r

JOIN sellers s

&#x09;ON r.seller\_id = s.seller\_id

GROUP BY r.seller\_id, s.seller\_city, s.seller\_state

HAVING COUNT(\*) >= 20; -- avoid small sample noise





\-- Statistical outliers.

WITH seller\_stats AS (

&#x20;   SELECT

&#x20;       r.seller\_id,

&#x09;s.seller\_city,

&#x09;s.seller\_state,

&#x20;       AVG(r.review\_score) AS avg\_score,

&#x20;       COUNT(r.\*) AS total\_reviews

&#x20;   FROM review\_sentiment\_table r

&#x09;JOIN sellers s

&#x09;	ON r.seller\_id = s.seller\_id

&#x20;   GROUP BY r.seller\_id, s.seller\_city, s.seller\_state

&#x20;   HAVING COUNT(r.\*) >= 20

),

overall AS (

&#x20;   SELECT

&#x20;       AVG(avg\_score) AS mean\_score,

&#x20;       STDDEV(avg\_score) AS stddev\_score

&#x20;   FROM seller\_stats

)

SELECT

&#x09;s.\*,

&#x09;CASE

&#x09;	WHEN s.avg\_score > o.mean\_score + 2 \* o.stddev\_score THEN 'good'

&#x09;	WHEN s.avg\_score < o.mean\_score - 2 \* o.stddev\_score THEN 'bad'

&#x09;END AS outstanding\_how

FROM seller\_stats s, overall o

WHERE s.avg\_score > o.mean\_score + 2 \* o.stddev\_score

&#x20;  OR s.avg\_score < o.mean\_score - 2 \* o.stddev\_score;



\-- Using analysis on excel the sellers in RS are clearly exceptional they have the best review scores. Although there is less data from that area only 1620 reviews but it is still worth investigating further.



**--Compare total revenue from sellers in each state:**

SELECT

&#x09;s.seller\_state,

&#x09;SUM(o.price) AS total\_revenue,

&#x09;AVG(o.price) AS price\_per\_sale

FROM order\_items o

JOIN sellers s

&#x09;ON o.seller\_id = s.seller\_id

GROUP BY s.seller\_state;





\-- test correlation between average review score and number of reviews. (Maybe it is harder for areas with a high amount of traffic to produce superior service)

\--correlation coefficient

WITH reviews\_by\_state AS (

&#x09;SELECT

&#x09;	s.seller\_state,

&#x09;    COUNT(r.\*) AS review\_count,

&#x09;	AVG(r.review\_score) AS avg\_review\_score

&#x09;FROM review\_sentiment\_table r

&#x09;JOIN sellers s

&#x09;	ON r.seller\_id = s.seller\_id

&#x09;WHERE review\_score IS NOT NULL

&#x09;GROUP BY s.seller\_state

)

SELECT

&#x09;CORR(

&#x09;review\_count, avg\_review\_score

&#x09;) AS count\_avg\_review\_corr,

&#x09;COUNT(seller\_state)

FROM reviews\_by\_state

WHERE review\_count >= 1000; --Can sub this for 500, correlation goes to -0.5 across 9 states.



\-- It seems there is some inverse correlation between number of reviews and review scores per state.



\-- investigate if there are any states that have worse services ( delivery time ) compared to others

SELECT

&#x09;s.seller\_state,

&#x09;COUNT(r.\*) AS review\_count,

&#x09;AVG(EXTRACT(EPOCH FROM (r.order\_delivered\_customer\_date::timestamp - r.order\_purchase\_timestamp::timestamp

)) / 86400) AS avg\_delivery\_days,

&#x09;AVG(r.review\_score) AS avg\_review

FROM review\_sentiment\_table r

JOIN sellers s

&#x09;ON s.seller\_id = r.seller\_id

WHERE order\_delivered\_customer\_date IS NOT NULL

GROUP BY s.seller\_state

HAVING COUNT(r.\*) > 500

ORDER BY COUNT(r.\*);



\-- Correlation between delivery time and average\_review score per state.

WITH avg\_rev AS (

&#x09;SELECT

&#x09;	s.seller\_state,

&#x09;	COUNT(r.\*) AS review\_count,

&#x09;	AVG(EXTRACT(EPOCH FROM (r.order\_delivered\_customer\_date::timestamp - r.order\_purchase\_timestamp::timestamp

&#x09;)) / 86400) AS avg\_delivery\_days,

&#x09;	AVG(r.review\_score) AS avg\_review

&#x09;FROM review\_sentiment\_table r

&#x09;JOIN sellers s

&#x09;	ON s.seller\_id = r.seller\_id

&#x09;WHERE order\_delivered\_customer\_date IS NOT NULL

&#x09;GROUP BY s.seller\_state

&#x09;HAVING COUNT(r.\*) > 500

&#x09;ORDER BY COUNT(r.\*)

)

SELECT

&#x09;CORR(

&#x09;avg\_delivery\_days, avg\_review

&#x09;)

FROM avg\_rev;





\-- Check where the most buyers are, does it match where the most sellers are ?



\-- Checking how product categories perform in each state.

SELECT \* --We wrap in a subquery so that we can filter by the aggregation total\_state\_sales.

FROM (

&#x20;   SELECT

&#x20;       p.product\_category\_name AS category,

&#x20;       c.customer\_state AS state,

&#x09;	SUM(rs.price) AS revenue\_by\_state\_and\_category,

&#x09;	SUM(SUM(rs.price)) OVER (PARTITION BY c.customer\_state) AS total\_state\_revenue,

&#x09;	ROUND(

&#x20;           (100.0 \* SUM(rs.price)

&#x20;           / SUM(SUM(rs.price)) OVER (PARTITION BY c.customer\_state))::numeric,

&#x20;           2

&#x20;       ) AS pct\_of\_state\_revenue,

&#x20;       COUNT(\*) AS sales\_in\_state,

&#x20;       SUM(COUNT(\*)) OVER (PARTITION BY c.customer\_state) AS total\_state\_sales,

&#x20;       ROUND(

&#x20;           100.0 \* COUNT(\*)

&#x20;           / SUM(COUNT(\*)) OVER (PARTITION BY c.customer\_state),

&#x20;           2

&#x20;       ) AS pct\_of\_state\_sales

&#x20;   FROM products p

&#x20;   JOIN review\_sentiment\_table rs

&#x20;       ON p.product\_id = rs.product\_id

&#x20;   JOIN customers c

&#x20;       ON rs.customer\_id = c.customer\_id

&#x20;   GROUP BY

&#x20;       p.product\_category\_name,

&#x20;       c.customer\_state

) t

WHERE total\_state\_sales >= 1000

ORDER BY

&#x20;   category,

&#x20;   pct\_of\_state\_revenue DESC;



\-- time series data.

