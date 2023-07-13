#!/bin/bash

for open_space in a b c d e f g h i j k l m n o
do
  ./gtg.rb $open_space > logs/gtg-$open_space.log
done
