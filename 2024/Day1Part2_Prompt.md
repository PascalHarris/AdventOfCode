Problem: Given two columns of integers, calculate a similarity score by summing each left value multiplied by its occurrence count in the right list.

Algorithm:

1. Parse input into two separate lists (left column, right column)
2. Build frequency map of right list values
3. For each value in left list: score += value * count_in_right

Calculate the answer for the supplied input file.