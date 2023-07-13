#!/usr/bin/env ruby

require 'pp'

def usage
  puts "Usage: #{$0} <log_file> <remaining_golf_tees>"
  puts "  Display games log file resulting in given number of remaining golf tees"
  puts "ABORTING!"
  exit
end

def main
  log_name = ARGV[0]
  remaining_golf_tees = ARGV[1].to_i

  if ARGV.size != 2
    usage
  end

  log = File.open(log_name)
  arrays = log.read.split(/\[/)
  arrays.shift
  arrays.shift
  arrays.each{ |game|
    move_array = "[#{game.gsub(/\n/,'')}"
    eval_game = eval move_array 
    final_state = eval_game[-1][:binary_s]
    if final_state.gsub("0","").size == remaining_golf_tees
      pp eval_game
      puts
    end
  }

end

main
