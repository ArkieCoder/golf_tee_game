#!/bin/bash -x

for open_space in a b c d e f g h i j k l m n o
do
  ./scripts/report.rb logs/gtg-$open_space.log 1 > logs/gtg-$open_space-1.log
  ./scripts/report.rb logs/gtg-$open_space.log 2 > logs/gtg-$open_space-2.log
  ./scripts/report.rb logs/gtg-$open_space.log 3 > logs/gtg-$open_space-3.log
done
