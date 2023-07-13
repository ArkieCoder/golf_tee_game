#!/bin/bash

echo "open_space,total,one_peg_games,two_peg_games,three_peg_games"
for open_space in a b c d e f g h i j k l m n o
do
  total=`grep -c "^[[]" logs/gtg-$open_space.log`
  one_peg=`grep -c "[[]" logs/gtg-$open_space-1.log`
  two_peg=`grep -c "[[]" logs/gtg-$open_space-2.log`
  three_peg=`grep -c "[[]" logs/gtg-$open_space-3.log`
  echo "$open_space,$total,$one_peg,$two_peg,$three_peg"
done
