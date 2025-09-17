use high_performance_mysql;
# 测试char存储
create table char_test(char_col char(10));
insert into char_test(char_col) values ('string1'),(' string2'),('string3 ');
select concat('\'', char_col, '\'') from char_test;
# 测试varchar
create table varchar_test(varchar_col char(10));
insert into varchar_test(varchar_col) values ('string1'),(' string2'),('string3 ');
select concat('\'', varchar_col, '\'') from varchar_test;
# 测试enum
create table enum_test(e enum('fish', 'apple', 'dog') not null);
insert into enum_test(e) values ('fish'),('dog'),('apple');
## enum数字和字符特性, 不适合实际环境,因为值desc经常变
select e + 0 from enum_test;
select e from enum_test;
select e from enum_test order by field(e, 'apple', 'dog', 'fish');
# BIT可以是Hex码形式,也可以是数字形式
create table bittest(b bit(8));
insert into bittest values (b'00111001');
select b, b + 0 from bittest;
# SET

