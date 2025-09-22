# Indexing Basics
select first_name from actor where actor_id = 5;
explain select * from People
where first_name = 'Smith';
# where last_name = 'Smith' and first_name = 'J%' ;
#   and dob = '1976-01-01';
## Indexing Strategies for High Performance
### Prefix Indexes and Index Selectivity
create table city_demo(city varchar(50) not null);
insert into city_demo(city) select city from city;
-- Repeat the next statement five times:
insert into city_demo(city) select city from city_demo;
-- Now randomize the distribution (inefficiently but conveniently):
update city_demo set city = (select city from city order by rand() limit 1);
### most frequently occurring cities, 平均大概频次是45
select count(*) as c, city from city_demo
group by city order by c desc limit 10;
### 三字母前缀的频次大概是150, 距离45差的比较远,所以要增大索引长度
select count(*) as c, left(city, 3) as pref from city_demo
group by pref order by c desc limit 10;
### 7比较接近
select count(*) as c, left(city, 7) as pref from city_demo
group by pref order by c desc limit 10;
### 另一种方式
### 0.0312
select count(distinct city)/count(*) from city_demo;
### 0.0236
select count(distinct left(city, 3))/count(*) from city_demo;
### 0.0293
select count(distinct left(city, 4))/count(*) from city_demo;
select count(distinct left(city, 5))/count(*) from city_demo;
select count(distinct left(city, 6))/count(*) from city_demo;
### 0.0310 精确到2位有效数字
select count(distinct left(city, 7))/count(*) from city_demo;
### 还有非常不平的情况,要格外当心
select count(*) as c, left(city, 4) as pref from city_demo
group by pref order by c desc limit 5;
### 加索引了
alter table city_demo add key(city(7));
