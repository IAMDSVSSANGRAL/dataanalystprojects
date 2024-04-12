USE ig_clone;

-- 1 Loyal User Reward: The marketing team wants to reward the most loyal users, 
-- i.e., those who have been using the platform for the longest time.
-- My Task: Identify the five oldest users on Instagram from the provided database.

Select * from users
order by created_at
limit 5;

-- 2 Inactive User Engagement: The team wants to encourage inactive users to start posting by sending them promotional emails.
-- My Task: Identify users who have never posted a single photo on Instagram.

select * from users u
left join photos p on u.id = p.user_id
where p.id is null;

-- 3 Contest Winner Declaration: The team has organized a contest where the user with the most likes on a single photo wins.
-- My Task: Determine the winner of the contest and provide their details to the team.

select count(*) from likes;
select * from likes;
select count(*) from users;
select * from users;
select * from photos;
select count(*) from photos;

select l.photo_id,u.username, count(l.user_id) like_count
from likes l 
inner join photos p on l.photo_id = p.id
inner join users u on p.user_id = u.id 
group by l.photo_id , u.username 
order by like_count desc
limit 1;


-- 4 Hashtag Research: A partner brand wants to know the most popular hashtags to use in their posts to reach the most people.
-- My Task: Identify and suggest the top five most commonly used hashtags on the platform.
select * from photo_tags;
select * from tags;


select count(photo_id) noofphotos, tag_id , tag_name
from photo_tags p
join tags t
on p.tag_id = t.id
group by tag_id
order by noofphotos desc
limit 5;

-- 5 Ad Campaign Launch: The team wants to know the best day of the week to launch ads.
-- My Task: Determine the day of the week when most users register on Instagram. Provide insights on when to schedule an ad campaign.

select * from users;
select date_format((created_at),'%w')  day ,count(username) num_of_user
from users
group by day
order by num_of_user desc;

## B) Investor Metrics: 
-- 6 User Engagement: Investors want to know if users are still active and posting on Instagram or if they are making fewer posts.
-- Calculate the average number of posts per user on Instagram. 
-- Also, provide the total number of photos on Instagram divided by the total number of users''
select * from photos;
select * from users;

with base as 
(select count(p.id) as num_of_photos , u.id as user_id
from users u
left join  photos p
on u.id = p.user_id
group by u.id)

select sum(num_of_photos) as total_photos,
count(user_id) as total_users,
sum(num_of_photos)/count(user_id) as avg_photo_per_user
from base;

-- 7 Bots & Fake Accounts: Investors want to know if the platform is crowded with fake and dummy accounts.
-- My Task: Identify users (potential bots) who have liked every single photo on the site, as this is not typically possible for a normal user.

Select * from likes;
select * from users;
with cte as 
(select user_id,count(photo_id) photo_liked
from likes
group by user_id)

select user_id,username, photo_liked 
from cte
inner join users 
on user_id = id
where photo_liked = (select count(*) from photos);

-- EXTRA WORKS (number of photos posted by each users)

select * from photos;

select user_id, count(id) photos_posted
from photos
group by user_id
order by photos_posted desc;

-- user id 23 is the most engaged user on instagram  he posted 12 photos  his user name is EVELINE 
select * from users
where id = 23;
-- only 74 users are active on instagram out of 100 users. 
-- Resulting 26 users out of which 13 are fake bot accounts and 13 are inactive users .

