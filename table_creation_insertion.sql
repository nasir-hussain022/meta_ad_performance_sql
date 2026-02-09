
-- Create ad_events table

create table ad_events (
event_id int,
ad_id	int,
user_id	varchar(20),
`timestamp`	text,
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



