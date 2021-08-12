# Ejercicio 3

Siguiendo con las tablas anteriores, queremos enviar una notificación cada 8 horas a cada
usuaria que ha conseguido nuevas seguidoras durante esas últimas 8 horas.
Para evitar cargar la base de datos, usaremos redis para controlar usuarias que tienen nuevas
seguidoras las últimas 24 horas y les generaremos una notificación del tipo “Beatriz, Carla y 3
usuarias más te están siguiendo ahora”.

##### Problema 1:

¿Qué estructuras de redis usarías? ¿Cómo serían los accesos a dichas estructuras? Puedes
hacer un esquema o lo que consideres más efectivo para explicarlo.

Dando por echo que el username es Unique, podemos usarlo a modo de key. 
Una propuesta simple seria implementar una versión expirable mediante TTL de la tabla follow. 
Donde cada vez que aparece una nueva seguidora, añadiriamos un nuevo registro con una vida 24h.    

```redis
> MULTI
> HMSET redishop:follows:maria-beatriz user_follower_id 1 user_followed_id 3 followed_at 1628761145
> SADD  redishop:follows:all-follows maria-beatriz
> ZADD  redishop:userFollowedIdIndex 3 maria-beatriz
> EXPIRE redishop:follows:maria-beatriz 86400
> EXEC
```

Cada 8h al ejecutarse la tarea de notificación, podriamos filtrar todas las seguidoras de Beatriz 
haciendo por ejemplo un ZRANGE sobre el indice redishop:userFollowedIdIndex esto nos daria el listado de 
keys de usuarias que han seguido a Beatriz en las últimas 24h. Notificando únicamente de las usuarias que tienen el followed_at dentro de las 8h.

```redis
> ZRANGE redishop:userFollowedIdIndex 3 3
"maria-beatriz"
...
> HMGET redishop:follows:maria-beatriz user_follower_id
"1"
```
  
Otra posible opción, sería hacer uso de LPUSH para tener el listado de seguidoras de una usuaria, añadiendo un elemento nuevo a la lista.

```redis
> LPUSH redishop:follows:beatriz "{"user_follower_id":1,"followed_at":1628761145}"
> LPUSH redishop:follows:beatriz "{"user_follower_id":2,"followed_at":1348765457}"
```

Esto requeriría un proceso que fuera asegurandose de la integridad de los datos eliminando de cada lista las seguidoras con antigüedad superior a 24h.  

##### Problema 2:

Lo primero sería implementar una capa de eventos de dominio que permitiera notificar al sistema cada vez que una usuaria 
sigue o deja de seguir a otra, o si una usuaria se da de baja.

```php

class UserFollowOtherUser implements StoredEvent {
    ...
}


$this->recordThat(
    UserFollowOtherUser::create(
        $userFollower,
        $userFollowed      
    )
);
```
Mediante listeners de estos eventos, podriamos modelar el comportamiento para persistir tanto en base de datos tabla (follow), 
como para actualizar redis.

Serian necesarias las implementaciones de las clases de repositorios de Mysql y Redis dentro de la infraestructura.

```php

interface FollowRepository
{
    public function save(Follow $follow);

    public function findFollowsByUserFollowed(User $userFollowed, int $timeSince) :FollowCollection;
    
    public function findUserWithFollowers() :UserCollection;

    public function findAllFollows() :FollowCollection;
}

final class RedisFollowRepository implements FollowRepository
{
    ...
}

final class NotifyFollowersHandler
{
    private $followRepository;
    private $notifier;
    private $timeSince; // 8h
    
    public function __construct(
        FollowRepository $followRepository,
        Notifier $notifier,
        int $timeSince
    ) {
        $this->followRepository = $followRepository;
        $this->notifier = $notifier;
        $this->timeSince = $timeSince;
    }
    
    public function handle()
    {
        $users = $this->followRepository->findUserWithFollowers();
        foreach ($users as $user) {
            $userFollows = $this->followRepository->findFollowsByUserFollowed(
                    $user, 
                    $this->timeSince
            );
            $notice = Notice::create($user, $userFollows);
            $this->notifier->notify($notice);
        }       
    }

}
```
    