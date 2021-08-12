<?php

declare(strict_types=1);


final class TreeCategoryGenerator
{
    private function sortCategoriesByParent(array $categories) :array
    {
        usort(
            $categories,
            function ($a, $b) {
                if ($a['parent'] == $b['parent']) {
                    return 0;
                }
                return ($a['parent'] > $b['parent']) ? 1 : -1;
            }
        );

        return $categories;
    }

    private function childrens(array $categories, ?int $parentId = null) :array
    {
        $branch = [];

        foreach ($categories as $category) {
            if ($category['parent'] === $parentId) {
                $children = $this->childrens($categories, $category['id']);
                $category['children'] = $children;
                $branch[] = $category;
            }
            if (isset($parentId) && ($parentId < $category['parent'])) {
                return $branch;
            }
        }

        return $branch;
    }

    public function handle(array $categories) :array
    {
        $categories = $this->sortCategoriesByParent($categories);
        return $this->childrens($categories);
    }
}