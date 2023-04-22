/*
https://r.isba.co/sql-assignment-02-spring23
Assignment 02: Business Analytics SQL - Board Meeting Presentation
Due: Monday, April 3, 11:59 PM
Overall Grade %: 8
Total Points: 100
1 point for SQL formatting and the correct filename

Database Connection Details:
hostname: lmu-dev-01.isba.co
username: lmu_dba
password: go_lions
database: tahoe_fuzzy_factory
port: 3306

Situation:
Tahoe Fuzzy Factory has been live for about 8 months. Your CEO is due to present company performance metrics to the board next week.
You'll be the one tasked with preparing relevant metrics to show the company's promising growth.

Objective:
Extract and analyze website traffic and performance data from the Tahoe Fuzzy Factory database to quantify the company's growth and
to tell the story of how you have been able to generate that growth.

As an analyst, the first part of your job is extracting and analyzing the requested data. The next part of your job is effectively 
communicating the story to your stakeholders.

Restrict to data before November 27, 2012, when the CEO made the email request.

Provide 2+ sentences of insight for each task. Keep in mind the tests ran and the changes made by the business leading up to this point.
Refer to the previous business analytics SQL exercises to explain the story behind the results.
*/


/*
4.0 - Board Meeting Presentation Project
From: Kara (CEO)
Subject: Board Meeting Next Week
Date: November 27, 2012
I need help preparing a presentation for the board meeting next week.
The board would like to have a better understanding of our growth story over our first 8 months.

Objectives:
- Tell the story of the company's growth using trended performance data
- Use the database to explain some of the details around the growth story and quantify the revenue impact of some of the wins
- Analyze current performance and use that data to assess upcoming opportunities
*/


/*
4.1 - SQL (5 points)
Gsearch seems to be the biggest driver of our business. Could you pull monthly trends for the # of gsearch sessions and orders
so that we can showcase the growth there? Include the conversion rate.

Expected results:
session_year|session_month|sessions|orders|conversion_rate|
------------+-------------+--------+------+---------------+
        2012|            3|    1843|    59|           3.20|
        2012|            4|    3569|    93|           2.61|
        2012|            5|    3405|    96|           2.82|
        2012|            6|    3590|   121|           3.37|
        2012|            7|    3797|   145|           3.82|
        2012|            8|    4887|   184|           3.77|
        2012|            9|    4487|   186|           4.15|
        2012|           10|    5519|   237|           4.29|
        2012|           11|    8586|   360|           4.19|
*/

WITH number_of_sessions_and_orders AS (
    SELECT 
        LEFT(ws.created_at, 4) AS session_year,
        MONTH(ws.created_at) AS session_month,
        COUNT(ws.website_session_id) AS sessions,
        COUNT(o.order_id) AS orders
    FROM website_sessions ws 
    LEFT JOIN orders o 
    	ON ws.website_session_id = o.website_session_id 
        AND o.created_at < '2012-11-27'
    WHERE ws.created_at < '2012-11-27' 
    	AND ws.utm_source = 'gsearch'
    GROUP BY LEFT(ws.created_at, 7)
    )
SELECT 
    session_year,
    session_month,
    sessions,
    orders,
    CONVERT(FORMAT(((orders / sessions) * 100), 2), DECIMAL(3, 2)) AS conversion_rate
FROM number_of_sessions_and_orders;

/*
4.1 - Insight (3 points)
There is an upward trend in the conversion rate over the months. This increase can be 
attributed to both the increase in the number of website sessions and the high number of orders placed during
those sesions. We can see that the highest conversation rate was in October 2012 with 4.29% and the lowest
in March 2012 with only 3.2%.
*/


/*
4.2 - SQL (10 points)
It would be great to see a similar monthly trend for gsearch but this time splitting out nonbrand and brand campaigns separately.
I wonder if brand is picking up at all. If so, this is a good story to tell.

Expected results:
session_year|session_month|nonbrand_sessions|nonbrand_orders|brand_sessions|brand_orders|
------------+-------------+-----------------+---------------+--------------+------------+
        2012|            3|             1835|             59|             8|           0|
        2012|            4|             3505|             87|            64|           6|
        2012|            5|             3292|             90|           113|           6|
        2012|            6|             3449|            115|           141|           6|
        2012|            7|             3647|            135|           150|          10|
        2012|            8|             4683|            174|           204|          10|
        2012|            9|             4222|            170|           265|          16|
        2012|           10|             5186|            222|           333|          15|
        2012|           11|             8208|            343|           378|          17|
*/

WITH campaigns_sessions_and_orders AS (
    SELECT 
        LEFT(website_sessions.created_at, 4) AS session_year,
        MONTH(website_sessions.created_at) AS session_month,
        COUNT(
            CASE WHEN utm_campaign = 'nonbrand' THEN website_sessions.website_session_id END
        ) AS nonbrand_sessions,
        COUNT(
            CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id END
        ) AS brand_sessions,
        COUNT(
            CASE WHEN utm_campaign = 'nonbrand' THEN order_id END
        ) AS nonbrand_orders,
        COUNT(
            CASE WHEN utm_campaign = 'brand' THEN order_id END
        ) AS brand_orders
    FROM website_sessions 
    LEFT JOIN orders 
        ON website_sessions.website_session_id = orders.website_session_id 
    WHERE 
        website_sessions.created_at < '2012-11-27' 
        AND website_sessions.utm_source = 'gsearch'
    GROUP BY 
    	session_year, 
    	session_month
)
SELECT 
    session_year,
    session_month,
    nonbrand_sessions,
    nonbrand_orders,
    brand_sessions,
    brand_orders
FROM campaigns_sessions_and_orders;


/*
4.2 - Insight (3 points)
It can clearly be seen that there is an increase in sessions volumes for both campaigns. However, the brand 
ratio is higher than the nonbrand ratio, making it clear that brands are more popular.
*/


/*
4.3 - SQL (10 points)
While we're on gsearch, could you dive into nonbrand and pull monthly sessions and orders split by device type?
I want to show the board we really know our traffic sources.

Expected results:
session_year|session_month|desktop_sessions|desktop_orders|mobile_sessions|mobile_orders|
------------+-------------+----------------+--------------+---------------+-------------+
        2012|            3|            1119|            49|            716|           10|
        2012|            4|            2135|            76|           1370|           11|
        2012|            5|            2271|            82|           1021|            8|
        2012|            6|            2678|           107|            771|            8|
        2012|            7|            2768|           121|            879|           14|
        2012|            8|            3519|           165|           1164|            9|
        2012|            9|            3169|           154|           1053|           16|
        2012|           10|            3929|           203|           1257|           19|
        2012|           11|            6233|           311|           1975|           32|
*/
WITH device_sessions AS(
	SELECT
		LEFT(ws.created_at, 4) AS session_year,
	    MONTH(ws.created_at) AS session_month,
	    COUNT(
	    	CASE WHEN device_type = 'desktop' THEN ws.website_session_id END
	    )AS desktop_sessions,
	    COUNT(
	    	CASE WHEN device_type = 'mobile' THEN ws.website_session_id END
	    )AS mobile_sessions,
	    COUNT(
	    	CASE WHEN device_type = 'desktop' THEN order_id END
	    )AS desktop_orders,
	    COUNT(
	    	CASE WHEN device_type = 'mobile' THEN order_id END
	    )AS mobile_orders
	FROM website_sessions ws
	LEFT JOIN orders o 
		ON ws.website_session_id = o.website_session_id 
	WHERE 
        ws.created_at < '2012-11-27' 
        AND ws.utm_source = 'gsearch'
        AND ws.utm_campaign = 'nonbrand'
    GROUP BY LEFT(ws.created_at, 7)
)
SELECT 
	session_year,
	session_month,
	desktop_sessions,
	desktop_orders,
	mobile_sessions,
	mobile_orders
FROM device_sessions;

/*
4.3 - Insight (3 points)
It is apparent that orders are placed more with a desktop than a mobile. It is also evident that both desktop & mobile
sessions are increasing the past several months. However, mobile sessions went down aroun 300 in June then 
continued to increase again in July.
*/

/*
4.4 - SQL (10 points)
I'm worried that one of our more pessimistic board members may be concerned about the large % of traffic from gsearch.
Can you pull monthly trends for gsearch, alongside monthly trends for each of our other channels?

Hint: CASE can have an AND operator to check against multiple conditions

Expected results:
session_year|session_month|gsearch_paid_sessions|bsearch_paid_sessions|organic_search_sessions|direct_type_in_sessions|
------------+-------------+---------------------+---------------------+-----------------------+-----------------------+
        2012|            3|                 1843|                    2|                      8|                      9|
        2012|            4|                 3569|                   11|                     76|                     71|
        2012|            5|                 3405|                   25|                    148|                    150|
        2012|            6|                 3590|                   25|                    194|                    169|
        2012|            7|                 3797|                   44|                    206|                    188|
        2012|            8|                 4887|                  696|                    265|                    250|
        2012|            9|                 4487|                 1438|                    332|                    284|
        2012|           10|                 5519|                 1770|                    427|                    442|
        2012|           11|                 8586|                 2752|                    525|                    475|
*/

-- find the various utm sources and referers to see the traffic we're getting
SELECT 
	DISTINCT
		utm_source,
		utm_campaign,
		http_referer
FROM website_sessions ws 
WHERE created_at < '2012-11-27';
/*
utm_source|utm_campaign|http_referer           |
----------+------------+-----------------------+
gsearch   |nonbrand    |https://www.gsearch.com| gsearch_paid_session
NULL      |NULL        |NULL                   | direct_type_in_session
gsearch   |brand       |https://www.gsearch.com| gsearch_paid_session
NULL      |NULL        |https://www.gsearch.com| organic_search_session
bsearch   |brand       |https://www.bsearch.com| bsearch_paid_session
NULL      |NULL        |https://www.bsearch.com| organic_search_session
bsearch   |nonbrand    |https://www.bsearch.com| bsearch_paid_session
 */
SELECT 
	LEFT(created_at, 4) AS session_year,
	MONTH(created_at) AS session_month,
	COUNT(CASE WHEN utm_source = 'gsearch' AND http_referer LIKE '%gsearch%' THEN website_sessions.website_session_id END) AS gsearch_paid_session,
	COUNT(CASE WHEN utm_source = 'bsearch' AND http_referer LIKE '%bsearch%' THEN website_sessions.website_session_id END) AS bsearch_paid_session,
	COUNT(
		CASE WHEN utm_source IS NULL
		AND utm_campaign IS NULL 
		AND http_referer IS NOT NULL THEN website_sessions.website_session_id END) AS organic_search_session,
	COUNT(
		CASE WHEN utm_source IS NULL
		AND utm_campaign IS NULL 
		AND http_referer IS NULL THEN website_sessions.website_session_id END) AS direct_type_in_session
FROM website_sessions 
WHERE created_at < '2012-11-27'
GROUP BY 
	session_year,
	session_month;

/*
4.4 - Insight (3 points)
We can see that gsearch started off with a high number of sessions compared to bsearch, organic, and direct. 
With this information, we can conclude that gsearch holds the largest portion of the paid sessions. 
*/


/*
4.5 - SQL (10 points)
I'd like to tell the story of our website performance over the course of the first 8 months. 
Could you pull session to order conversion rates by month?

Expected results:
session_year|session_month|sessions|orders|conversion_rate|
------------+-------------+--------+------+---------------+
        2012|            3|    1862|    59|           3.17|
        2012|            4|    3727|   100|           2.68|
        2012|            5|    3728|   107|           2.87|
        2012|            6|    3978|   140|           3.52|
        2012|            7|    4235|   169|           3.99|
        2012|            8|    6098|   228|           3.74|
        2012|            9|    6541|   285|           4.36|
        2012|           10|    8158|   368|           4.51|
        2012|           11|   12338|   547|           4.43|
*/

SELECT 
	LEFT(website_sessions.created_at, 4) AS session_year,
	MONTH(website_sessions.created_at) AS session_month,
	COUNT(website_sessions.website_session_id) AS sessions,
	COUNT(order_id) AS orders,
	CONVERT(FORMAT(((COUNT(order_id) / COUNT(website_sessions.website_session_id)) * 100), 2), DECIMAL(3, 2)) AS conversion_rate
FROM website_sessions
LEFT JOIN orders 
	ON website_sessions.website_session_id = orders.website_session_id 
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY LEFT(website_sessions.created_at, 7);
	

/*
4.5 - Insight (3 points)
It can be concluded that October 2012 had the highest conversion rate of 4.51% while April 2012 had the lowest 
of 2.68%. Not only is the conversion rate increase but also the sessions and orders. We can conclude that the performance
of the website has gotten bettter throughout the year. 
*/


/*
4.6 - SQL (15 points)
For the landing page test, it would be great to show a full conversion funnel from each of the two landing pages 
(/home, /lander-1) to orders. Use the time period when the test was running (Jun 19 - Jul 28).

Expected results:
landing_page_version_seen|lander_ctr|products_ctr|mrfuzzy_ctr|cart_ctr|shipping_ctr|billing_ctr|
-------------------------+----------+------------+-----------+--------+------------+-----------+
homepage                 |     46.82|       71.00|      42.84|   67.29|       85.76|      46.56|
custom_lander            |     46.79|       71.34|      44.99|   66.47|       85.22|      47.96|
*/

WITH conversion_funnel AS (
	SELECT website_sessions.website_session_id,
		CASE WHEN website_pageviews.pageview_url = '/home' THEN 1 ELSE 0 END AS home,
		CASE WHEN website_pageviews.pageview_url = '/lander-1' THEN 1 ELSE 0 END AS lander,
		CASE WHEN website_pageviews.pageview_url = '/products' THEN 1 ELSE 0 END AS products,
		CASE WHEN website_pageviews.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS ofuzzy,
		CASE WHEN website_pageviews.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart,
		CASE WHEN website_pageviews.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping,
		CASE WHEN website_pageviews.pageview_url = '/billing' THEN 1 ELSE 0 END AS billing,
		CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS ty
FROM website_sessions
LEFT JOIN website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-06-19' AND '2012-07-28'), session_level AS (
	SELECT
		website_session_id,
		MAX(home) AS home_session,
		MAX(lander) AS lander_session,
		MAX(products) AS products_session,
		MAX(ofuzzy) AS ofuzzy_session,
		MAX(cart) AS cart_session,
		MAX(shipping) AS shipping_session,
		MAX(billing) AS billing_session,
		MAX(ty) AS ty_session
	FROM conversion_funnel
	GROUP BY website_session_id
		)
SELECT
	CASE WHEN home_session = 1 THEN 'homepage' WHEN lander_session = 1 THEN 'custom_lander' END AS landing_page_version_seen,
	FORMAT(COUNT(CASE WHEN products_session = 1 THEN website_session_id END) / COUNT(website_session_id) * 100, 2) AS lander_ctr,
	FORMAT(COUNT(CASE WHEN ofuzzy_session = 1 THEN website_session_id END) / COUNT(CASE WHEN products_session = 1 THEN website_session_id END) * 100, 2) AS products_ctr,
	FORMAT(COUNT(CASE WHEN cart_session = 1 THEN website_session_id END) / COUNT(CASE WHEN ofuzzy_session = 1 THEN website_session_id END) * 100, 2) AS mrfuzzy_ctr,
	FORMAT(COUNT(CASE WHEN shipping_session = 1 THEN website_session_id END) / COUNT(CASE WHEN cart_session = 1 THEN website_session_id END) * 100, 2) AS cart_ctr,
	FORMAT(COUNT(CASE WHEN billing_session = 1 THEN website_session_id END) / COUNT(CASE WHEN shipping_session = 1 THEN website_session_id END) * 100, 2) AS shipping_ctr,
	FORMAT(COUNT(CASE WHEN ty_session = 1 THEN website_session_id END) / COUNT(CASE WHEN billing_session = 1 THEN website_session_id END) * 100, 2) AS billing_ctr
FROM session_level
GROUP BY landing_page_version_seen;





/*
4.6 - Insight (3 points)
It can be concluded that buyers our often on the products page, but they don't continue on to the carts page. 
Although purchasing a product requires going through the process of shipping and billing to place an order, 
this results in a higher cart click-through rate (CTR) and shipping CTR. 
However, because customers must pay for the order to reach the thank you page, the CTR for the billing step is typically low.
*/


/*
4.7 - SQL (10 points)
I'd love for you to quantify the impact of our billing page A/B test. Please analyze the lift generated from the test
(Sep 10 - Nov 10) in terms of revenue per billing page session. Manually calculate the revenue per billing page session
difference between the old and new billing page versions. 

Expected results:
billing_version_seen|sessions|revenue_per_billing_page_seen|
--------------------+--------+-----------------------------+
/billing            |     657|                        22.90|
/billing-2          |     653|                        31.39|
*/
WITH billing_sessions AS(
	SELECT 
		pageview_url,
		website_session_id
	FROM website_pageviews
	WHERE created_at BETWEEN '2012-09-10' AND '2012-11-10'
		AND pageview_url IN ('/billing', '/billing-2')
)
SELECT 
	pageview_url AS billing_version_seen,
	COUNT(bs.website_session_id) AS sessions,
	CONVERT(FORMAT(
			(SUM(o.price_usd))/(COUNT(bs.website_session_id)), 2), 
			DECIMAL(4, 2)
	)AS revenue_per_billing_page_seen
FROM billing_sessions bs
LEFT JOIN orders o 
	ON bs.website_session_id = o.website_session_id 
GROUP BY pageview_url;

/*
4.7 - Insight (3 points)
It can be seen that the amount of revenue for each session in the new billing version is slightly greater, 
which could indicate that the new billing version might be better for the company. 
Specifically, based on the A/B test results, the new billing page (/billing-2) 
has a higher revenue per billing page session of $31.21 compared to the old billing page (/billing) with $22.88. 
This signifies that the new billing page is more effective in generating revenue, 
resulting in an $8.33 increase per billing page session.
 */


/*
4.8 - SQL (5 points)
Pull the number of billing page sessions (sessions that saw '/billing' or '/billing-2') for the past month and multiply that value
by the lift generated from the test (Sep 10 - Nov 10) to understand the monthly impact. 
You manually calculated the lift by taking the revenue per billing page session difference between /billing and /billing-2. 
You can hard code the revenue lift per billing session into the query.

Expected results:
past_month_billing_sessions|billing_test_value|
---------------------------+------------------+
                       1161|           9856.89|
*/
SELECT 
	COUNT(wp.website_session_id) AS past_month_bulling_sessions,
	COUNT(wp.website_session_id)*8.33 AS billing_test_value
FROM website_pageviews wp 
WHERE created_at BETWEEN '2012-10-27' AND '2012-11-27'
	AND pageview_url IN ('/billing', '/billing-2');

/*
4.8 - Insight (3 points)
We can see that in the past month, there was 1220 sessions. We get 10162 by multiplying
1220 * 8.33. From there, we can see the outcome of the new billing page. We can conclude
that if they did not implement the new billing page, they could have lost $10,162.6 in revenue.
 */



