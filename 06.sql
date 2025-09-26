use high_performance_mysql;
# 测试char存储
create table char_test
(
    char_col char(10)
);
insert into char_test(char_col)
values ('string1'),
       (' string2'),
       ('string3 ');
select concat('\'', char_col, '\'')
from char_test;
# 测试varchar
create table varchar_test
(
    varchar_col char(10)
);
insert into varchar_test(varchar_col)
values ('string1'),
       (' string2'),
       ('string3 ');
select concat('\'', varchar_col, '\'')
from varchar_test;
# 测试enum
create table enum_test
(
    e enum ('fish', 'apple', 'dog') not null
);
insert into enum_test(e)
values ('fish'),
       ('dog'),
       ('apple');
## enum数字和字符特性, 不适合实际环境,因为值desc经常变
select e + 0
from enum_test;
select e
from enum_test;
select e
from enum_test
order by field(e, 'apple', 'dog', 'fish');
# BIT可以是Hex码形式,也可以是数字形式
create table bittest
(
    b bit(8)
);
insert into bittest
values (b'00111001');
select b, b + 0
from bittest;
# JSON
## JSON数据
DESC asteroids_json;
## 结构化数据
DESC asteroids_sql;
## 插入数据
# {"designation":"419880 (2011 AH37)","discovery_date":"2011-01-07T00:00:00.000","h_mag":"19.7","moid_au":"0.035","q_au_1":"0.84","q_au_2":"4.26","period_yr":"4.06","i_deg":"9.65","pha":"Y","orbit_class":"Apollo"}
## 查看情况
show table status
where Name like 'asteroids_%';
## 第一次没缓存,比第二次慢一点
select designation
from asteroids_sql;
## JSON查询字段
select json_data -> '$.designation'
FROM asteroids_json;
## JSON的生成字段
ALTER table asteroids_json add column designation varchar(30)
    generated always as (json_data->'$.designation'), add index(designation);
## IP的相互转换,如果不想每次都转化,可以直接用view
select inet_aton('192.168.1.1');
insert into ip_test(ip_col) values (inet_aton('192.168.1.1')), (inet_aton('192.168.1.2')), (inet_aton('192.168.1.3'));
select inet_ntoa(ip_col) from ip_test;
