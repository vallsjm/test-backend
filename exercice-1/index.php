#!/usr/bin/env php
<?php

require __DIR__.'/TreeCategoryGenerator.php';

$categories = [
    ['id' => 1, 'name' => 'Shoes',          'parent' => null],
    ['id' => 2, 'name' => 'Clothes',        'parent' => null],
    ['id' => 3, 'name' => 'Dresses',        'parent' => 2],
    ['id' => 4, 'name' => 'Sandals',        'parent' => 1],
    ['id' => 5, 'name' => 'Water sandals',  'parent' => 4],
    ['id' => 6, 'name' => 'Party dresses',  'parent' => 3],
    ['id' => 7, 'name' => 'Trousers',       'parent' => 2]
];

$treeCategoryGenerator = new TreeCategoryGenerator();
$treeCategories = $treeCategoryGenerator->handle($categories);

echo json_encode($treeCategories, JSON_PRETTY_PRINT) . PHP_EOL;