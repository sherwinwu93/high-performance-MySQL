select actor.*
from actor
         inner join film_actor using (actor_id)
         inner join film using (film_id)
where film.title = 'Academy Dinosaur';

## 有索引只需examine 10行,type:ref
## type: ref, key: idx_fk_film_id, rows: 10(examine10行)
explain
select *
from film_actor
where film_id = 1;

## 把索引去掉,再试 需要examine 5462行,type: ALL; Extra: Using where;
# ALTER TABLE film_actor DROP FOREIGN KEY fk_film_actor_film;
# ALTER TABLE sakila.film_actor DROP KEY idx_fk_film_id;
EXPLAIN
SELECT *
FROM sakila.film_actor
WHERE film_id = 1;

select actor_id, count(*)
from film_actor
group by actor_id;
explain
select actor_id, count(*)
from film_actor
group by actor_id;

# 分批删除
# delete
# from message
# where created < Date_sub(now(), interval 3 month);
#
# rows_affected = 0
# do {
#     rows_affected = do_query(
#         "Delete from messages where created < Date_sub(now(), interval 3 month)
#         limit 10000"
#         )
#     } while rows_affected > 0

# 分解join
# select * from tag
# join tag_post on tag_post.tag_id = tag.id
# join post on tag_post.post_id = post.id
# where tag.tag = 'mysql';
# ## 分解后
# select * from tag where tag = 'mysql';
# select * from tag_post where  tag_id=1234;
# select * from post where post.id in (123,456,567,9098,8904);
