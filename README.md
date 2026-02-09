# Meta Ad Performance Analysis – SQL Project 

## 1. Project Overview

**Project Title**: Meta Ad Performance 

**Database**: `ad_performance`

The goal of this analysis is to evaluate advertising performance across Facebook and Instagram. The 
business requires insights into campaign reach, engagement, conversions, and budget utilization to 
optimize ROI and understand audience patterns. 

## 2. Technical KPIs & Logic
![KPIs](KPIs.png)

## Project Structure

### 1. Database Setup
![ERD]("ad_erd.png")

- **Database Creation**: Created a database named `ad_performance`.
- **Table Creation**: Created tables for ad_events, ads, campaigns, and users. Each table includes relevant columns and relationships.

## Level: Basic (Data Discovery)

1.**Retrieve unique ad types:  Identify all formats like Image or Video.**

```sql
SELECT DISTINCT 
ad_type 
FROM 
ads; 
         
```

2.**Count total Impressions: total reach across all campaigns.**

```sql
SELECT  
COUNT(*) 
FROM 
ad_events 
WHERE 
event_type = 'impression'; 
```

3.**List Facebook-only Ads: Filter ads strictly for the Facebook platform.**       
```sql
SELECT  
ad_type, ad_platform 
FROM 
ads 
WHERE 
ad_platform = 'facebook'; 
```
## Level: Intermediate (Aggregation & Joins) 

4.**Budget per Platform: Total budget allocated to Facebook vs. Instagram.**
```sql
SELECT  
FROM 
campaigns c 
INNER JOIN -- 4. Budget per Platform: Total budget allocated to Facebook vs. Instagram. 
ad_platform, ROUND(SUM(total_budget), 2) AS total_budget 
ads a ON a.campaign_id = c.campaign_id 
GROUP BY 1;
```


5.**Engagement by Age Group: Total interactions per demographic.**
```sql
SELECT  
age_group, COUNT(event_type) AS engagement 
FROM 
ad_events e 
INNER JOIN 
users u ON u.user_id = e.user_id 
WHERE 
e.event_type IN ('like' , 'comment', 'share', 'click', 'purchase') 
GROUP BY 1; 
```

6.**Average Campaign Budget: Calculate the mean allocation.**

```sql
SELECT  
FROM -- 6. Average Campaign Budget: Calculate the mean allocation. 
ROUND(AVG(total_budget), 2) AS average_budget 
campaigns; 
```


## Level: Advanced (Calculated Metrics & Trends) 

7.**Click-Through Rate (CTR) by Ad Type: Identify which format drives most intent.**

```sql
SELECT  
ad_type, 
CONCAT(ROUND((COUNT(CASE 
WHEN e.event_type = 'click' THEN 1 
ELSE 0 
END) / COUNT(CASE 
WHEN e.event_type = 'impression' THEN 1 
ELSE 0 
END)) * 100, 
2), 
'%') AS CTR 
FROM 
ads a 
INNER JOIN 
ad_events e ON a.ad_id = e.ad_id 
GROUP BY a.ad_type; 
```

8.**Hourly Activity Pattern: Find peak activity hours (0-23).**

```sql
SELECT  
HOUR(`timestamp`) AS hour, COUNT(*) AS peak_activity 
FROM 
ad_events 
GROUP BY 1 
ORDER BY peak_activity DESC 
LIMIT 5; 
```

9.**Hourly Activity Pattern: Find 2nd peak activity hours (0-23).**
```sql

SELECT  
FROM 
ad_events 
GROUP BY 1 
HOUR(`timestamp`) AS hour, COUNT(*) AS peak_activity 
HAVING COUNT(*) < (SELECT  
MAX(peak_activity) 
FROM 
(SELECT  
COUNT(*) AS peak_activity 
FROM 
ad_events 
GROUP BY HOUR(`timestamp`)) AS abc)
ORDER BY peak_activity DESC 
LIMIT 1; 


```

10.**Weekly Performance Trend: Stacked view of performance per week.**

```sql
SELECT  
WEEK(`timestamp`) AS weeks, 
event_type, 
COUNT(*) AS performance 
FROM 
ad_events 
GROUP BY 1 , 2 
ORDER BY performance DESC; 

```

11.**High-ROI Gender Segments: Purchase rates for Target Genders.**
```sql
SELECT  
u.user_gender, 
CONCAT(ROUND((COUNT(CASE 
WHEN e.event_type = 'purchase' THEN 1 
END)) / (COUNT(DISTINCT e.user_id)) * 100, 
2), 
'%') AS purchase_rate
FROM 
Email- nasirhussainnk172@gmail.com  LinkedIn- Nasir-hussain022 GitHub- Nasir_hussain022 
ad_events e 
INNER JOIN 
users u ON u.user_id = e.user_id 
GROUP BY 1; 
A. Business Logic & Performance KPIs 


```
## A. Business Logic & Performance KPIs 

12.**Calculate the "Ad Efficiency Score" (Total Engagements / Total Budget).**
```sql
SELECT  
c.name, 
(COUNT(CASE 
WHEN e.event_type IN ('like' , 'comment', 'share', 'click', 'purchase') THEN 1 
ELSE 0 
END) / c.total_budget) AS ad_efficiency_score 
FROM 
ad_events e 
INNER JOIN 
ads a ON e.ad_id = a.ad_id 
INNER JOIN 
campaigns c ON c.campaign_id = a.campaign_id 
GROUP BY c.name , c.total_budget 
ORDER BY ad_efficiency_score DESC 
LIMIT 5;

```

13.**Compare Facebook vs. Instagram Conversion Rates.** 
•  Purpose: Directly identify the most effective platform for driving sales.

```sql
SELECT  
a.ad_platform, 
CONCAT(ROUND((COUNT(CASE 
WHEN e.event_type = 'purchase' THEN 1 
ELSE 0 
END)) / (COUNT(CASE 
WHEN e.event_type = 'click' THEN 1 
ELSE 0 
END)) * 100, 
0), 
'%') AS conversion_rate 
FROM 
ads a 
INNER JOIN 
GROUP BY a.ad_platform 
ad_events e ON e.ad_id = a.ad_id 
ORDER BY conversion_rate DESC 

```


14.**Identify the "Peak Engagement Hour" for each Ad Type.**  
• Purpose: Understand user activity patterns throughout the day to optimize ad scheduling.

```sql
SELECT ad_type, 
HOUR(`timestamp`) AS `hour`, 
(COUNT(CASE 
10 
WHEN event_type IN ('like' , 'comment', 'share', 'click', 'purchase') THEN 1 
ELSE 0 
END)) peak_engagement 
FROM 
ad_events e 
INNER JOIN 
ads a ON a.ad_id = e.ad_id 
GROUP BY 1 , 2 
ORDER BY peak_engagement DESC; 
```

## B. Audience & Demographic Insights 

15.**Find which Target Gender has the highest Purchase-to-Click ratio.**  
•  Purpose: Analyze funnel efficiency across different gender segments.


```sql

SELECT  
u.user_gender,  
CONCAT(ROUND((COUNT(CASE 
WHEN event_type = 'purchase' THEN 1 
ELSE 0 
END) / NULLIF(COUNT(CASE 
WHEN event_type = 'click' THEN 1 
ELSE 0 
END), 
0)) * 100,
1), 
'%') AS funnel_effiency 
FROM 
ad_events e 
INNER JOIN 
users u ON u.user_id = e.user_id 
GROUP BY 1 
ORDER BY 1;

```


16.**Rank Age Groups by total Budget Utilization.**  
•  Purpose: Visualize how the budget is distributed across target demographics.

```sql
SELECT age_group, SUM(total_budget) as total_spend 
FROM ads 
GROUP BY age_group 
ORDER BY total_spend DESC; 

```

17.**Calculate the "Viral Impact" (Shares per Purchase).**  
•  Purpose: Measure the relationship between "viral" engagement and hard conversions.

```sql
SELECT  
COUNT(CASE 
WHEN event_type = 'shares' THEN 1 
ELSE 0 
END) / COUNT(CASE 
WHEN event_type = 'purchase' THEN 1 
ELSE 0 
END) AS shares_per_purchase 
FROM 
ad_events;  

```

## C. Data Integrity & Seasonal Reporting 

18.**Identify campaigns with less than 1000 impressions (Underperformers).**  

```sql
SELECT  
c.name, 
COUNT(CASE 
WHEN event_type = 'impression' THEN 1 
ELSE 0 
END) AS impressions 
FROM 
campaigns c 
LEFT JOIN 
ads a ON a.campaign_id = c.campaign_id 
INNER JOIN 
ad_events e ON e.ad_id = a.ad_id 
GROUP BY 1 
HAVING COUNT(CASE 
WHEN event_type = 'impression' THEN 1 
ELSE 0 
END) < 1000; 

```


19.**Monthly Growth Trend of Purchases.**  
•  Purpose: Detect seasonal trends and peak activity months. 

```sql
SELECT  
MONTHNAME(`timestamp`) AS `month`, 
COUNT(CASE 
WHEN event_type = 'purchase' THEN 1 
ELSE 0 
END) AS purchases 
FROM ad_events 
GROUP BY 1 
ORDER BY purchases DESC;

```


20.**Performance Matrix: Budget vs. Total Engagements per Ad Type.**  
•  Purpose: Compare the cost of different ad formats against the engagement volume they generate.

```sql
SELECT  
a.ad_type, 
ROUND(SUM(c.total_budget), 2) AS budget, 
(COUNT(CASE 
WHEN event_type IN ('like' , 'comment', 'share', 'click', 'purchase') THEN 1 
ELSE 0 
END)) AS engagement 
FROM 
ad_events e 
INNER JOIN 
ads a ON a.ad_id = e.ad_id 
INNER JOIN 
campaigns c ON c.campaign_id = a.campaign_id 
GROUP BY 1 
ORDER BY budget DESC; 

```


21.**Find the most "Cost-Effective" Age Group (Budget per Purchase).**  
•  Purpose: Determine which demographic provides the cheapest conversions for better budget 
allocation. 

```sql
SELECT  
age_group, 
ROUND(SUM(total_budget), 2) AS budget, 
COUNT(CASE 
WHEN event_type = 'purchase' THEN 1 
ELSE 0 
END) AS Purchases 
FROM 
users u 
INNER JOIN 
ad_events e ON e.user_id = u.user_id 
INNER JOIN 
ads a ON a.ad_id = e.ad_id 
INNER JOIN 
campaigns c ON c.campaign_id = a.campaign_id 
GROUP BY 1 
ORDER BY budget , purchases ASC 
LIMIT 5; 

```


## Conclusion

This performance tracking report empowers the marketing team to optimize budget allocation and ROI by providing clear visibility into campaign reach, engagement, and conversions across Facebook and Instagram. By leveraging dynamic visualizations and key performance metrics, the business can accurately identify high-performing platforms and understand audience engagement patterns to drive more effective advertising strategies.

- **Instagram**: [Follow me on instagram for daily tips](https://www.instagram.com/bca_wale022/)
- **LinkedIn**: [Connect with me on linkedIn](https://www.linkedin.com/in/nasir-hussain022)
- **Contact**: [Send me an email](mailto:nasirhussainnk172@gmail.com)
