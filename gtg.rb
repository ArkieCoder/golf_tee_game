#!/usr/bin/env ruby

require 'pp'
require_relative 'golf_tee_board'

def main
  open_location = ARGV[0]
  gtb = GolfTeeBoard.new open_location
  pp gtb
  gtb.traverse_moves
end

main
