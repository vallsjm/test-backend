# Ejercicio 1

##### Explicación:

El problema que se pretende solucionar es la creación de un árbol de categorias a partir de un array asociativo.
Se opta por implementar un UseCase denominado TreeCategoryGenerator que permita solucionarlo mediante una función recursiva con poda. 
La poda se hace por un tema de rendimiento. 

Comando:
```
docker/console exercice-1/index.php
```

Resultado:
```json
[
    {
        "id": 1,
        "name": "Shoes",
        "parent": null,
        "children": [
            {
                "id": 4,
                "name": "Sandals",
                "parent": 1,
                "children": [
                    {
                        "id": 5,
                        "name": "Water sandals",
                        "parent": 4,
                        "children": []
                    }
                ]
            }
        ]
    },
    {
        "id": 2,
        "name": "Clothes",
        "parent": null,
        "children": [
            {
                "id": 3,
                "name": "Dresses",
                "parent": 2,
                "children": [
                    {
                        "id": 6,
                        "name": "Party dresses",
                        "parent": 3,
                        "children": []
                    }
                ]
            },
            {
                "id": 7,
                "name": "Trousers",
                "parent": 2,
                "children": []
            }
        ]
    }
]
```
