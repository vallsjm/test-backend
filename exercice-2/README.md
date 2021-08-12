# Ejercicio 2

##### Explicación:

Tenemos tres tablas, usuario, producto y seguidores. Donde cada usuario puede seguir a N usuarios.

##### Problema 1:

Realiza una consulta en SQL que muestre los últimos 50 productos de las usuarias que
sigue Beatriz. Dichos productos han de estar creados la última semana como mucho.

```sql
SELECT p.* 
FROM product p 
    INNER JOIN follow w ON w.user_followed_id = p.user_id
    INNER JOIN user u ON u.id = w.user_follower_id
WHERE
    u.username = 'beatriz' 
AND
    p.date >= DATE_SUB(CURDATE(), INTERVAL 1 WEEK) 
LIMIT 50 
```

##### Problema 2:

¿Qué índices son necesarios para que la consulta se realice de forma eficiente por parte del
motor de bases de datos?

Dando por echo que las primary keys sean los campo id de cada tabla como autoincrement y que un username de usuario es único

```sql
-- user
ALTER TABLE user
  ADD UNIQUE INDEX idx_username (username);

-- product
ALTER TABLE product
  ADD INDEX idx_date (date);

ALTER TABLE product ADD CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES user(id);

-- follow
ALTER TABLE follow ADD CONSTRAINT fk_user_follower_id FOREIGN KEY (user_follower_id) REFERENCES user(id);
ALTER TABLE follow ADD CONSTRAINT fk_user_followed_id FOREIGN KEY (user_followed_id) REFERENCES user(id);
```

##### Problema 3:

La usuaria beatriz le gusta seguir a todas las usuarias que se le ponen por delante.
Actualmente sigue a más de diez mil usuarias y muchas de estas suben muchas prendas. Pese
a los índices, la consulta sigue siendo demasiado lenta. ¿Cómo modificarías la consulta para
que fuese más rápida? Pueden ser sugerencias que sacrifiquen la exhaustividad y exactitud de
los resultados a costa de la eficiencia.

```sql
SELECT p.*
FROM product p
WHERE
    p.date >= DATE_SUB(CURDATE(), INTERVAL 1 WEEK)
AND
    p.user_id
IN (
    SELECT w.user_followed_id
    FROM follow w INNER JOIN user u ON u.id = w.user_follower_id
    WHERE u.username = 'beatriz'
)
LIMIT 50
```

Explain consulta por optimizar:

| id | select\_type | table | partitions | type | possible\_keys | key | key\_len | ref | rows | filtered | Extra |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | SIMPLE | u | NULL | const | PRIMARY,idx\_username | idx\_username | 452 | const | 1 | 100 | Using index |
| 1 | SIMPLE | w | NULL | ref | fk\_user\_follower\_id,fk\_user\_followed\_id | fk\_user\_follower\_id | 4 | const | 2 | 100 | NULL |
| 1 | SIMPLE | p | NULL | ref | idx\_date,fk\_user\_id | fk\_user\_id | 4 | test\_backend.w.user\_followed\_id | 2 | 40 | Using where |

Explain consulta optimizada:

| id | select\_type | table | partitions | type | possible\_keys | key | key\_len | ref | rows | filtered | Extra |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | SIMPLE | u | NULL | const | PRIMARY,idx\_username | idx\_username | 452 | const | 1 | 100 | Using index |
| 1 | SIMPLE | p | NULL | range | idx\_date,fk\_user\_id | idx\_date | 3 | NULL | 2 | 100 | Using index condition |
| 1 | SIMPLE | w | NULL | ref | fk\_user\_follower\_id,fk\_user\_followed\_id | fk\_user\_followed\_id | 4 | test\_backend.p.user\_id | 1 | 66.67 | Using where; FirstMatch\(p\) |


##### Problema 4:

Siguiendo con la pregunta anterior, ¿sugerirías alguna otra alternativa aunque implicara
crear tablas nuevas o incluso otros servicios?

Si la consistencia permanente de los datos no es critica, se puede optar por crear vistas materializadas
trabajando con un engine en memoria enfocadas a la optimización consulta.

Algo similar a esto:
```sql
CREATE TABLE view_products_lastweek ENGINE=MEMORY
SELECT p.*
FROM product p
WHERE
    p.date >= DATE_SUB(CURDATE(), INTERVAL 1 WEEK)
``` 

Seria importante actualizar las vistas creadas de forma regular para asegurar la consistencia. 
Esto lo podemos conseguir creando un pequeño procedimiento que actualice parte o la totalidad de la vista en función 
de eventos en la capa de dominio, ej: si una usuaria ha añadido productos / sigue a una nueva usuaria / deja de seguirla, etc.. 

Lo ideal es que dichas vistas retornen los datos exclusivamente necesarios para lo que estan diseñadas, como si fueran DTO's.

Hay que tener en cuenta que al usar el engine Memory los datos no son persistidos. Si la maquina cae, o se reinicia el mysql tocaria repoblar la vista.

En el caso en cuestion, seria algo del estilo:

```sql
SELECT * 
FROM view_products_from_my_follows 
WHERE user_follower_id = 3

y que retorne
user_followed_id, product_id, product_name, date
``` 
