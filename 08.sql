select actor.* from actor
inner join film_actor using(actor_id)
inner join film using(film_id)
where film.title = 'Academy Dinosaur';