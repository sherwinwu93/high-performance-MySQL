# Indexing Basics
select first_name
from actor
where actor_id = 5;
explain
select *
from People
where first_name = 'Smith';
# where last_name = 'Smith' and first_name = 'J%' ;
#   and dob = '1976-01-01';
## Indexing Strategies for High Performance
### Prefix Indexes and Index Selectivity
create table city_demo
(
    city varchar(50) not null
);
insert into city_demo(city)
select city
from city;
-- Repeat the next statement five times:
insert into city_demo(city)
select city
from city_demo;
-- Now randomize the distribution (inefficiently but conveniently):
update city_demo
set city = (select city from city order by rand() limit 1);
### most frequently occurring cities, 平均大概频次是45
select count(*) as c, city
from city_demo
group by city
order by c desc
limit 10;
### 三字母前缀的频次大概是150, 距离45差的比较远,所以要增大索引长度
select count(*) as c, left(city, 3) as pref
from city_demo
group by pref
order by c desc
limit 10;
### 7比较接近
select count(*) as c, left(city, 7) as pref
from city_demo
group by pref
order by c desc
limit 10;
### 另一种方式
### 0.0312
select count(distinct city) / count(*)
from city_demo;
### 0.0236
select count(distinct left(city, 3)) / count(*)
from city_demo;
### 0.0293
select count(distinct left(city, 4)) / count(*)
from city_demo;
select count(distinct left(city, 5)) / count(*)
from city_demo;
select count(distinct left(city, 6)) / count(*)
from city_demo;
### 0.0310 精确到2位有效数字
select count(distinct left(city, 7)) / count(*)
from city_demo;
### 还有非常不平的情况,要格外当心
select count(*) as c, left(city, 4) as pref
from city_demo
group by pref
order by c desc
limit 5;
### 加索引了
alter table city_demo
    add key (city(7));
explain
select film_id,
       actor_id
from film_actor
where actor_id = 1
   or film_id = 1;
## Choosing a Good Column Order
select *
from payment
where staff_id = 2
  and customer_id = 584;
select sum(staff_id = 2), sum(customer_id = 584)
from payment;
select sum(staff_id = 2)
from payment
where customer_id = 584;
## 针对全体,比只针对特殊情况要好
select count(distinct staff_id) / count(*)    as staff_id_selectivity,
       count(distinct customer_id) / count(*) as customer_id_selectivity,
       count(*)
from payment;
alter table payment
    add key (customer_id, staff_id);
### query running very slowly
# select count(distinct threadId) as count_value from message
# where (groupId = 10137) and (userId = 1288826) and (anonymous = 0)
# order by priority desc, modifiedDate desc;
-- 结果
# id: 1
# select_type: SIMPLE
# table: Message
# type: ref
# key: ix_groupId_userId
# key_len: 18
# ref: const,const
# rows: 1251162
# Extra: Using where
-- 分析
# SELECT COUNT(*), SUM(groupId = 10137),
#     -> SUM(userId = 1288826), SUM(anonymous = 0)
#     -> FROM Message\G
# *************************** 1. row ***************************
# count(*): 4142217
# sum(groupId = 10137): 4092654
# sum(userId = 1288826): 1288496
# sum(anonymous = 0): 4141934
-- 原来因为这个userId是admin, 这些数据都是迁移过来的.
-- 解决: 程序对这个用户进行特殊处理.

#### InnoDB's data layout
create table layout_test
(
    col1 int not null,
    col2 int not null,
    primary key (col1),
    key (col2)
);

####
CREATE TABLE userinfo
(
    id              int unsigned      NOT NULL AUTO_INCREMENT,
    name            varchar(64)       NOT NULL DEFAULT '',
    email           varchar(64)       NOT NULL DEFAULT '',
    password        varchar(64)       NOT NULL DEFAULT '',
    dob             date                       DEFAULT NULL,
    address         varchar(255)      NOT NULL DEFAULT '',
    city            varchar(64)       NOT NULL DEFAULT '',
    state_id        tinyint unsigned  NOT NULL DEFAULT '0',
    zip             varchar(8)        NOT NULL DEFAULT '',
    country_id      smallint unsigned NOT NULL DEFAULT '0',
    gender          enum ('M', 'F')   NOT NULL DEFAULT 'M',
    account_type    varchar(32)       NOT NULL DEFAULT '',
    verified        tinyint           NOT NULL DEFAULT '0',
    allow_mail      tinyint unsigned  NOT NULL DEFAULT '0',
    parrent_account int unsigned      NOT NULL DEFAULT '0',
    closest_airport varchar(3)        NOT NULL DEFAULT '',
    PRIMARY KEY (id),
    UNIQUE KEY email (email),
    KEY country_id (country_id),
    KEY state_id (state_id),
    KEY state_id_2 (state_id, city, address)
) ENGINE = InnoDB;

### 只查索引不查行
explain
select store_id, film_id
from inventory;
### 只查索引不查行,有主键
explain select actor_id, last_name
from actor
# where last_name = 'HOPPER'
order by last_name, first_name;

explain select state_id, city, address
from userinfo
order by state_id, city;

### 排序用索引情况
# constraint rental_date
#         unique (rental_date, inventory_id, customer_id),
# 走索引,因为最左边列是常量,顺序也相同
explain select * from rental
where rental_date = '2005-05-25'
order by inventory_id, customer_id;
### 也走索引,最左边是常量
explain select * from rental
        where rental_date = '2005-05-25'
        order by inventory_id desc;
### 走索引,最左原则, 期望走索引,但是没走
explain select * from rental
        where rental_date > '2005-05-25'
        order by rental_date, inventory_id;
### 不走索引,联合字段排序顺序不对
explain select * from rental
        where rental_date = '2005-05-25'
        order by inventory_id desc, customer_id asc;
explain select * from rental
        where rental_date = '2005-05-25'
        order by inventory_id, staff_id;
### 没这个字段不走索引
explain select * from rental
where rental_date = '2005-05-25'
order by customer_id;
## range不走索引
explain select * from rental
where rental_date > '2005-05-25'
order by inventory_id, customer_id;
### range不走索引
explain select * from rental
where rental_date = '2005-05-25'
and inventory_id in (1, 2)
order by customer_id;
## 理论排序要走索引,实际没有走索引.因为film_actor.actor_id作为第二张表
explain select actor_id, title from film_actor
inner join film using(film_id) order by actor_id;