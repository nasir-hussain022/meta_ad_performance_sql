# Meta Ad Performance Analysis – SQL Project 

<img width="1006" height="580" alt="instagram_dashboard" src="https://github.com/user-attachments/assets/c39bcee9-01e4-4161-9f6e-57f4bdbceeed" />

<img width="1009" height="579" alt="insta_tooltip" src="https://github.com/user-attachments/assets/9baa258e-e23a-4c3d-b2ff-07e67fb1d2f1" />

<img width="1006" height="576" alt="facebook_dashboard" src="https://github.com/user-attachments/assets/1b332c70-83e2-45ef-a1b5-b031e0ac22ef" />

## Project Overview

**Project Title**: Meta Ad Performance 

**Database**: `ad_performance`

The goal of this analysis is to evaluate advertising performance across Facebook and Instagram. The 
business requires insights into campaign reach, engagement, conversions, and budget utilization to 
optimize ROI and understand audience patterns. 

# Objectives
 
**Primary Goal**: To evaluate advertising performance across Facebook and Instagram to optimize ROI and understand audience patterns.

**Evaluate Ad Efficiency**: Identify which campaigns generate the highest interaction volume relative to their total cost.

**Compare Platform Effectiveness**: Directly identify whether Facebook or Instagram is more effective for driving sales through conversion rate comparison.

**Optimize Ad Scheduling**: Understand user activity patterns throughout the day to find "Peak Engagement Hours" for various ad types.

**Analyze Funnel Efficiency**: Determine which target gender segments have the highest purchase-to-click ratios.

**Visualize Budget Distribution**: Rank age groups by budget utilization to see how spending is distributed across target demographics.

**Measure Viral Impact**: Calculate the relationship between "viral" engagement (shares) and hard conversions (purchases).

**Identify Underperformers**: Detect campaigns with fewer than 1,000 impressions to flag low-performing ads. 

**Detect Seasonal Trends**: Track the monthly growth trend of purchases to find peak activity periods throughout the year.

**Demographic Cost-Effectiveness**: Determine which age groups provide the cheapest conversions for better future budget allocation.

# Project Structure

### 1. Database Setup

<img width="1007" height="689" alt="ad_erd" src="https://github.com/user-attachments/assets/2f204435-9fc2-48d9-a178-77d670ab884a" />


**Database Creation**: Created a database named `ad_performance`.
**Table Creation**: Created tables for ad_events, ads, campaigns, and users. Each table includes relevant columns and relationships.


  ```sql

-- Create ad_events table

create table ad_events (
event_id int,
ad_id	int,
user_id	varchar(20),
`timestamp` text,
day_of_week text,
time_of_day text,	
event_type text
);

/* Bulk insert- it inserts multiple rows into a single command,
 making it faster and more efficient than inserting rows on by one. Data is large that's why I preferred this method */

load data local infile "C:/Users/AVITA/Downloads/ad_events.csv"
into table ad_events
fields terminated by ','
lines terminated by '\n'
ignore 1 rows;


-- Create ads table

create table ads (
ad_id int primary key,
campaign_id	int,
ad_platform	varchar(20),
ad_type	varchar(20),
target_gender varchar(20),
target_age_group varchar(20),	
target_interests varchar(20)
);


load data local infile "C:/Users/AVITA/Downloads/ads.csv" 
into table ads
fields terminated by ','
lines terminated by '\r\n'
ignore 1 rows;

-- Import the remaining tables(campaigns, and users) from 'Table data Import Wizard'


-- Add Primary Key to the ads table (ad_id);

alter table ads
add primary key(ad_id);
                             -- relation btw ads (P) and ad_events (F)
                           
-- Add Foreign Key to the ad_events table  (ad_id)

alter table ad_events
add constraint  fk_ad
foreign key (ad_id)
REFERENCES ads(ad_id);

                             -- relation btw ads (F) campaign (P)
                              
-- Add Foreign Key to the ads table  (campaign_id)

alter table ads
add constraint  fk_camp
foreign key (campaign_id)
REFERENCES campaigns(campaign_id);

Alter table ad_events
modify column user_id varchar(20);

delete from ad_events 
where user_id NOT IN (select user_id from users);
      
                                -- relation btw users (P) ad_events (F)
-- Add Foreign Key to the ad_events table (user_id)

alter table ad_events
add constraint  fk_users
foreign key (user_id)
REFERENCES users(user_id) 
;

-- Updating table

Update campaigns
set start_date = STR_TO_DATE (start_date ,'%d-%m-%Y');

-- type casting

Alter table campaigns
modify column start_date DATE;

Update campaigns
set end_date = STR_TO_DATE (end_date ,'%d-%m-%Y');

-- type casting

Alter table campaigns
modify column end_date DATE;

Update ad_events
set `timestamp` = STR_TO_DATE (`timestamp` ,'%d-%m-%Y %H:%i');

-- type casting

Alter table ad_events
modify column `timestamp` datetime;
  
  ```



  # 2. Technical KPIs & Logic

<img width="638" height="666" alt="KPIs" src="https://github.com/user-attachments/assets/4ccccc6d-c492-44ae-b815-8daa21ffd5b8" />

## Level: Basic (Data Discovery)

1.**Retrieve unique ad types:  Identify all formats like Image or Video.**

```sql
SELECT DISTINCT
    ad_type
FROM
    ads; 
         
```
<img width="96" height="141" alt="Q1" src="https://github.com/user-attachments/assets/d488dad3-1b9f-47a6-b88c-b66848939529" />

2.**Count total Impressions: total reach across all campaigns.**

```sql
  SELECT 
    COUNT(*)
FROM
    ad_events
WHERE
    event_type = 'impression'; 
```
<img width="141" height="72" alt="Q2" src="https://github.com/user-attachments/assets/ef7432f7-95b2-41ee-a0a0-337162d3822b" />

## Level: Intermediate (Aggregation & Joins) 

3.**Count total Impressions: total reach by ad platform.**

```sql
SELECT 
    ad_platform,
    CONCAT(ROUND((SUM(CASE
                        WHEN event_type = 'impression' THEN 1
                        ELSE 0
                    END)) / 1000,
                    1),
            'k') AS impression
FROM
    ad_events e
        INNER JOIN
    ads a ON a.ad_id = e.ad_id
GROUP BY 1;


```

<img width="175" height="62" alt="image" src="https://github.com/user-attachments/assets/e5891d3c-a8b7-40a0-8e8b-726fb39b5260" />

4.**Instagram / Facebook impression by month**

```sql
SELECT 
    ad_platform,
    MONTHNAME(`timestamp`) AS `month`,
    CONCAT(ROUND((SUM(CASE
                        WHEN event_type = 'impression' THEN 1
                        ELSE 0
                    END)) / 1000,
                    1),
            'k') AS impression
FROM
    ad_events e
        INNER JOIN
    ads a ON a.ad_id = e.ad_id
GROUP BY 1 , 2;
```

<img width="218" height="123" alt="image" src="https://github.com/user-attachments/assets/0911a4d9-c574-486d-abca-7c645515e25b" />

5.**count of clicks by ad platform**

```sql
SELECT 
    ad_platform,
    CONCAT(ROUND((SUM(CASE
                        WHEN event_type = 'click' THEN 1
                        ELSE 0
                    END)) / 1000,
                    1),
            'k') AS clicks
FROM
    ad_events e
        INNER JOIN
    ads a ON a.ad_id = e.ad_id
GROUP BY 1;
```

<img width="139" height="60" alt="image" src="https://github.com/user-attachments/assets/5cac3008-e791-4659-a216-ba6eb4df467c" />


6.**count of clicks by month & ad platform**

```sql
SELECT 
    ad_platform,
    MONTHNAME(`timestamp`) AS `month`,
    CONCAT(ROUND((SUM(CASE
                        WHEN event_type = 'click' THEN 1
                        ELSE 0
                    END)) / 1000,
                    1),
            'k') AS clicks
FROM
    ad_events e
        INNER JOIN
    ads a ON a.ad_id = e.ad_id
GROUP BY 1 , 2;
```

<img width="175" height="149" alt="image" src="https://github.com/user-attachments/assets/b2c88882-b7b8-45ec-b779-ffd16d888c0e" />


7.**count of shares by ad platform**

```sql
SELECT 
    ad_platform,
    MONTHNAME(`timestamp`) AS `month`,
    ROUND((SUM(CASE
                WHEN event_type = 'share' THEN 1
                ELSE 0
            END)),
            1) AS shares
FROM
    ad_events e
        INNER JOIN
    ads a ON a.ad_id = e.ad_id
GROUP BY 1 , 2;
```

<img width="194" height="143" alt="image" src="https://github.com/user-attachments/assets/b71987b5-04c0-4451-aa4f-396ee4a0568a" />


 8.**Total comment by ad platform**

```sql
SELECT 
    ad_platform,
    (SUM(CASE
        WHEN event_type = 'comment' THEN 1
        ELSE 0
    END)) AS comments
FROM
    ad_events e
        INNER JOIN
    ads a ON a.ad_id = e.ad_id
GROUP BY 1;
```

<img width="157" height="61" alt="image" src="https://github.com/user-attachments/assets/ddd8e43f-d468-449d-a645-a1624a1dd2a6" />

9.**Total purchase by ad platform**

```sql
SELECT 
    ad_platform,
    (SUM(CASE
        WHEN event_type = 'purchase' THEN 1
        ELSE 0
    END)) AS Purchase
FROM
    ad_events e
        INNER JOIN
    ads a ON a.ad_id = e.ad_id
GROUP BY 1;
```

<img width="175" height="68" alt="image" src="https://github.com/user-attachments/assets/d4923f71-69ec-4a9c-8fa6-ef38d4f67ca0" />



10.**List Facebook-only Ads: Filter ads strictly for the Facebook platform.**       
```sql
  SELECT 
    ad_type, ad_platform
FROM
    ads
WHERE
    ad_platform = 'facebook'; 
```
<img width="167" height="171" alt="Q3" src="https://github.com/user-attachments/assets/42a3b08e-e1c5-45fb-9adb-21b3ba48067e" />


11.**Budget per Platform: Total budget allocated to Facebook vs. Instagram.**
```sql
SELECT 
    ad_platform,
    CONCAT(ROUND((SUM(c.total_budget)) / 1000000, 2),
            'M') AS total_budget
FROM
    campaigns c
        INNER JOIN
    ads a ON a.campaign_id = c.campaign_id
GROUP BY ad_platform;
```
<img width="196" height="92" alt="budget" src="https://github.com/user-attachments/assets/52474223-f83b-4e5d-9995-e8be09eeccc5" />


12.**Engagement by Age Group: Total interactions per demographic.**
```sql
SELECT 
    age_group,
    CONCAT(ROUND(COUNT(event_type) / 1000, 2), 'K') AS engagement
FROM
    ad_events e
        INNER JOIN
    users u ON u.user_id = e.user_id
WHERE
    e.event_type IN ('like' , 'comment', 'share', 'click', 'purchase')
GROUP BY 1; 
```

<img width="197" height="118" alt="image" src="https://github.com/user-attachments/assets/6ce14b51-1f00-4f2c-b4ae-59974d026bbb" />


```sql
SELECT 
    CONCAT(ROUND(AVG(total_budget) / 1000, 2), 'K') AS average_budget
FROM
    campaigns; 
```



## Level: Advanced (Calculated Metrics & Trends) 

14.**Click-Through Rate (CTR) by Ad Type and ad platform: Identify which format drives most intent.**

```sql
SELECT 
    ad_platform,
    ad_type,
    CONCAT(ROUND(IFNULL((SUM(CASE
                                WHEN e.event_type = 'click' THEN 1
                                ELSE 0
                            END)),
                            0) / NULLIF((SUM(CASE
                                WHEN event_type = 'impression' THEN 1
                                ELSE 0
                            END)),
                            0) * 100,
                    2),
            '%') AS CTR
FROM
    ad_events e
        INNER JOIN
    ads a ON a.ad_id = e.ad_id
GROUP BY 1 , 2;
```

<img width="146" height="39" alt="Screenshot 2026-02-13 214535" src="https://github.com/user-attachments/assets/9314c8c9-1c8c-4e94-99e7-9f02e0fdfdb1" />


15.**Hourly Activity Pattern: Find peak activity hours (0-23).**

```sql
SELECT 
    HOUR(`timestamp`) AS hour, COUNT(*) AS peak_activity
FROM
    ad_events
GROUP BY 1
ORDER BY peak_activity DESC
LIMIT 5; 
```

<img width="163" height="137" alt="Q8" src="https://github.com/user-attachments/assets/0e4175d6-d242-48be-9101-d95e33fb1eee" />

16.**Hourly Activity Pattern: Find 2nd peak activity hours (0-23).**
```sql

SELECT 
    HOUR(`timestamp`) AS hour, COUNT(*) AS peak_activity
FROM
    ad_events
GROUP BY 1
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

<img width="159" height="78" alt="Q9" src="https://github.com/user-attachments/assets/a360cfa3-45f8-4095-bd02-b7b57194c153" />

17.**Weekly Performance Trend: Stacked view of performance per week.**

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

<img width="238" height="150" alt="Q10" src="https://github.com/user-attachments/assets/eaea7ed4-0921-4636-a0f6-3af2b3df4a03" />

18.**High-ROI Gender Segments: Purchase rates for Target Genders.**
```sql
SELECT 
    u.user_gender,
    CONCAT(ROUND((COUNT(CASE
                        WHEN e.event_type = 'purchase' THEN 1
                    END)) / (COUNT(DISTINCT e.user_id)) * 100,
                    2),
            '%') AS purchase_rate
FROM
    ad_events e
        INNER JOIN
    users u ON u.user_id = e.user_id
GROUP BY 1; 

```

<img width="200" height="97" alt="Q11" src="https://github.com/user-attachments/assets/5a8a8a1f-a75a-4904-8d1d-c248dbd3fc6e" />

## A. Business Logic & Performance KPIs 

19.**Calculate the "Ad Efficiency Score" (Total Engagements / Total Budget).**
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

<img width="286" height="101" alt="Q13" src="https://github.com/user-attachments/assets/846957bc-ff11-4c2f-9658-ae9f61294a13" />

20.**Compare Facebook vs. Instagram Conversion Rates.** 
•  Purpose: Directly identify the most effective platform for driving sales.

```sql

SELECT 
    ad_platform,
    CONCAT(ROUND((SUM(CASE
                        WHEN e.event_type = 'purchase' THEN 1
                        ELSE 0
                    END)) / SUM(CASE
                        WHEN event_type = 'click' THEN 1
                        ELSE 0
                    END) * 100,
                    2),
            '%') AS conversion_rate
FROM
    ad_events e
        INNER JOIN
    ads a ON a.ad_id = e.ad_id
GROUP BY ad_platform;

```

<img width="202" height="61" alt="Screenshot 2026-02-12 220136" src="https://github.com/user-attachments/assets/9d1b025b-f8bd-44e9-bb47-9743dd9dbcb4" />


21.**Identify the "Peak Engagement Hour" for each Ad Type.**  
• Purpose: Understand user activity patterns throughout the day to optimize ad scheduling.

```sql
SELECT 
    ad_type,
    HOUR(`timestamp`) AS `hour`,
    CONCAT(ROUND((COUNT(CASE 10
                        WHEN event_type IN ('like' , 'comment', 'share', 'click', 'purchase') THEN 1
                        ELSE 0
                    END)) / 1000,
                    2),
            'K') peak_engagement
FROM
    ad_events e
        INNER JOIN
    ads a ON a.ad_id = e.ad_id
GROUP BY 1 , 2
ORDER BY peak_engagement DESC
LIMIT 5; 
```

<img width="234" height="110" alt="image" src="https://github.com/user-attachments/assets/5d744032-99a2-4f6a-b0ec-8b93222d5826" />



## B. Audience & Demographic Insights 

22.**Find which Target Gender has the highest Purchase-to-Click ratio.**  
•  Purpose: Analyze funnel efficiency across different gender segments.


```sql


SELECT 
    u.user_gender,
    CONCAT(ROUND((SUM(CASE
                        WHEN event_type = 'purchase' THEN 1
                        ELSE 0
                    END) / NULLIF(SUM(CASE
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

<img width="202" height="79" alt="image" src="https://github.com/user-attachments/assets/2271e480-e7f0-4847-8f46-9e67fbf0eddb" />



23.**Rank Age Groups by total Budget Utilization.**  
•  Purpose: Visualize how the budget is distributed across target demographics.

```sql
SELECT 
    age_group,
    CONCAT(ROUND(SUM(total_budget) / 1000000, 0),
            'M') AS total_spend
FROM
    users u
        INNER JOIN
    ad_events e ON e.user_id = u.user_id
        INNER JOIN
    ads a ON a.ad_id = e.ad_id
        INNER JOIN
    campaigns c ON c.campaign_id = a.campaign_id
GROUP BY age_group
ORDER BY total_spend DESC; 

```

<img width="162" height="73" alt="image" src="https://github.com/user-attachments/assets/52e69a73-0602-4fe9-bfb5-1b6a4ec2011d" />


24.**Calculate the "Viral Impact" (Shares per Purchase).**  
•  Purpose: Measure the relationship between "viral" engagement and hard conversions.

```sql
SELECT 
   (COUNT(CASE
        WHEN event_type = 'shares' THEN 1
        ELSE 0
    END)) /(COUNT(CASE
        WHEN event_type = 'purchase' THEN 1
        ELSE 0
    END)) AS shares_per_purchase
FROM
    ad_events;  

```

<img width="164" height="66" alt="Q18" src="https://github.com/user-attachments/assets/3c66e459-fb95-4226-9264-7067c4108090" />


## C. Data Integrity & Seasonal Reporting 

25.**Identify campaigns with less than 1000 impressions (Underperformers).**  

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
END) < 1000
LIMIT 5; 
```

<img width="260" height="119" alt="Q20" src="https://github.com/user-attachments/assets/fbe909b6-c685-4c74-b793-c59720a032cb" />

26.**Monthly Growth Trend of Purchases.**  
•  Purpose: Detect seasonal trends and peak activity months. 

```sql
SELECT 
    MONTHNAME(`timestamp`) AS `month`,
    CONCAT(ROUND(COUNT(CASE
                        WHEN event_type = 'purchase' THEN 1
                        ELSE 0
                    END) / 1000,
                    1),
            'K') AS purchases
FROM
    ad_events
GROUP BY 1
ORDER BY purchases DESC;

```

<img width="165" height="95" alt="image" src="https://github.com/user-attachments/assets/be3188aa-bb9d-4994-acbd-53c1c8d4ba21" />


27.**Performance Matrix: Budget vs. Total Engagements per Ad Type.**  
•  Purpose: Compare the cost of different ad formats against the engagement volume they generate.

```sql
SELECT 
    a.ad_type,
    CONCAT(ROUND(SUM(c.total_budget) / 1000000, 2),
            'M') AS budget,
    CONCAT(ROUND(COUNT(CASE
                        WHEN event_type IN ('like' , 'comment', 'share', 'click', 'purchase') THEN 1
                        ELSE 0
                    END) / 1000,
                    2),
            'K') AS engagement
FROM
    ad_events e
        INNER JOIN
    ads a ON a.ad_id = e.ad_id
        INNER JOIN
    campaigns c ON c.campaign_id = a.campaign_id
GROUP BY 1
ORDER BY budget DESC; 

```

<img width="224" height="89" alt="image" src="https://github.com/user-attachments/assets/de168c4e-e1f4-4d81-a7dd-b3cc0941890f" />


28.**Find the most "Cost-Effective" Age Group (Budget per Purchase).**  
•  Purpose: Determine which demographic provides the cheapest conversions for better budget 
allocation. 

```sql
SELECT 
    age_group,
    CONCAT(ROUND(SUM(total_budget) / 1000000, 2),
            'M') AS budget,
    CONCAT(ROUND(COUNT(CASE
                        WHEN event_type = 'purchase' THEN 1
                        ELSE 0
                    END) / 1000,
                    2),
            'K') AS Purchases
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

<img width="219" height="58" alt="image" src="https://github.com/user-attachments/assets/b5273fc9-94f4-4abc-943b-f2eb8940ef93" />


### Strategies to Boost Ad Performance

**1. Fix the "First Impression" (Creatives)**

**The 1% Rule:** if less than 1% of people click (**CTR**), your ad is boring.

*Action:* Change the first 3 seconds of your video or use a bolder image.

**Ad Fatigue Management:** If the same person sees your ad more than 3 times (**Frequency**), they get tired of it and costs go up.

* *Action:* Swap in a new ad or show it to a new group of people.

**2. Spend Money Smarter (Budget)**

* **Bet on the Winner:** Use SQL to see where you get the most sales (Instagram vs. Facebook).

* *Action:* Stop spending money on the "losers" and move that cash to the "winners."

* **The "Kill" Switch:** Don't let an ad bleed money.

* *Action:* If an ad spends double your goal without a single sale, **turn it off immediately.**

**3. Smooth Out the Customer Journey (The Funnel)**

* **Don't Lie:** If your ad promises a "50% Discount" but your website says "10%," people will leave.

* *Action:* Make sure your ad and your website say the exact same thing.

* **Speed it Up:** If people click the ad but leave before the page loads, your site is too slow.

* *Action:* Make your website faster so you don't lose the customers you just paid for.

**4. Win Back Lost Customers (Retargeting)**

* **The "Second Chance":** People often "Add to Cart" but get distracted and don't buy.

* *Action:* Show a special ad with a **discount code** specifically to those people to finish the sale.


## Conclusion

This performance tracking report empowers the marketing team to optimize budget allocation and ROI by providing clear visibility into campaign reach, engagement, and conversions across Facebook and Instagram. By leveraging dynamic visualizations and key performance metrics, the business can accurately identify high-performing platforms and understand audience engagement patterns to drive more effective advertising strategies.

- **Instagram**: [Follow me on instagram for daily tips](https://www.instagram.com/bca_wale022/)
- **LinkedIn**: [Connect with me on linkedIn](https://www.linkedin.com/in/nasir-hussain022)
- **Contact**: [Send me an email](mailto:nasirhussainnk172@gmail.com)
