#!/usr/bin/env ruby

require 'rgl/adjacency'
require 'rgl/path'
require 'rgl/dijkstra'
require 'rgl/dot'
require 'pp'

class GolfTeeBoard
  attr_accessor :board, :vals, :binary_s, :state_no, :state, :start_state

  @board = nil
  @valid_move_graphs = []
  @vals = {}
  @binary_s = nil
  @state_no = nil
  @last_move = ""
  @start_state = nil

  def init_valid_move_graphs
    ## probably a better way ---
    valid_move_graph_1 = RGL::AdjacencyGraph.new
    valid_move_graph_1.add_edge 'a','d'
    valid_move_graph_1.add_edge 'a','f'
    valid_move_graph_1.add_edge 'f','d'
  
    valid_move_graph_2 = RGL::AdjacencyGraph.new
    valid_move_graph_2.add_edge 'd','k'
    valid_move_graph_2.add_edge 'd','m'
    valid_move_graph_2.add_edge 'm','k'
  
    valid_move_graph_3 = RGL::AdjacencyGraph.new
    valid_move_graph_3.add_edge 'f','m'
    valid_move_graph_3.add_edge 'f','o'
    valid_move_graph_3.add_edge 'o','m'
  
    valid_move_graph_4 = RGL::AdjacencyGraph.new
    valid_move_graph_4.add_edge 'b','g'
    valid_move_graph_4.add_edge 'b','i'
    valid_move_graph_4.add_edge 'i','g'
  
    valid_move_graph_5 = RGL::AdjacencyGraph.new
    valid_move_graph_5.add_edge 'c','h'
    valid_move_graph_5.add_edge 'c','j'
    valid_move_graph_5.add_edge 'j','h'
  
    valid_move_graph_6 = RGL::AdjacencyGraph.new
    valid_move_graph_6.add_edge 'e','l'
    valid_move_graph_6.add_edge 'e','n'
    valid_move_graph_6.add_edge 'n','l'

    valid_move_graph_7 = RGL::AdjacencyGraph.new
    valid_move_graph_7.add_edge 'd','f'
    valid_move_graph_7.add_edge 'f','m'
    valid_move_graph_7.add_edge 'm','d'
    [
      valid_move_graph_1,
      valid_move_graph_2,
      valid_move_graph_3,
      valid_move_graph_4,
      valid_move_graph_5,
      valid_move_graph_6,
      valid_move_graph_7,
    ]
  end

  def init_board
    graph = RGL::AdjacencyGraph.new 
    graph.add_edge 'a','b'
    graph.add_edge 'a','c'
  
    graph.add_edge 'b','c'
    graph.add_edge 'b','d'
    graph.add_edge 'b','e'
  
    graph.add_edge 'c','e'
    graph.add_edge 'c','f'
  
    graph.add_edge 'd','e'
    graph.add_edge 'd','g'
    graph.add_edge 'd','h'
  
    graph.add_edge 'e','f'
    graph.add_edge 'e','h'
    graph.add_edge 'e','i'
  
    graph.add_edge 'f','i'
    graph.add_edge 'f','j'
  
    graph.add_edge 'g','h'
    graph.add_edge 'g','k'
    graph.add_edge 'g','l'
  
    graph.add_edge 'h','i'
    graph.add_edge 'h','l'
    graph.add_edge 'h','m'
  
    graph.add_edge 'i','j'
    graph.add_edge 'i','m'
    graph.add_edge 'i','n'
  
    graph.add_edge 'j','n'
    graph.add_edge 'j','o'
  
    graph.add_edge 'k','l'
  
    graph.add_edge 'l','m'
  
    graph.add_edge 'm','n'
  
    graph.add_edge 'n','o'
  
    graph
  end

  def move?(from,to)
    has_path = @board.path?(from,to)
    #puts "has_path = #{has_path}"
    shortest_path = @board.dijkstra_shortest_path(Hash.new(1), from, to)
    valid_path = @valid_move_graphs.map {|vmg| vmg.path?(from,to)}.any?
    #puts "valid_path = #{valid_path}"
    from_occupied = @vals[from] == 1
    #puts "from_occupied = #{from_occupied}"
    to_empty = @vals[to] == 0
    #puts "to_empty = #{to_empty}"
    #puts "shortest_path = "
    #pp shortest_path
    intermediate_node = shortest_path[1]
    #puts "intermediate_node = #{intermediate_node}"
    intermediate_occupied = @vals[intermediate_node] == 1
    #puts "intermediate_occupied = #{intermediate_occupied}"
    has_path && valid_path && from_occupied && to_empty && intermediate_occupied
  end

  def moves
    all_nodes = ('a'..'o').to_a
    occupied_nodes = @vals.select { |k,v| v==1 }.map{|k,v| k}
    unoccupied_nodes = all_nodes.reject{ |n| occupied_nodes.include?(n) }
    occupied_nodes.map{ |on| 
      valid_tos = unoccupied_nodes.select{ |un|
        move?(on, un)
      }
      [on, valid_tos]
    }.reject { |n|
      n.last.empty?
    }
  end

  def update_state(from=nil, to=nil)
    @binary_s = @vals.values.join
    @state_no = @binary_s.to_i(2)
    @last_move = "#{from}->#{to}" if (!from.nil? && !to.nil?)
    @state = {
      binary_s: @binary_s,
      last_move: @last_move,
      state_no: @state_no
    } 
  end
  
  def move(from,to)
    new_vals = @vals.dup
    result = false
    if self.move?(from,to) 
      shortest_path = @board.dijkstra_shortest_path(Hash.new(1), from, to)
      intermediate_node = shortest_path[1]
      new_vals[from] = 0
      new_vals[to] = 1
      new_vals[intermediate_node] = 0
      #puts "Successful move from node [#{from}] to node [#{to}]."
      @vals = new_vals
      update_state(from, to)
      result = true
    else
      #puts "Invalid move from node [#{from}] to node [#{to}] discarded."
    end
    return result
  end

  def traverse_moves(board=self, move_graph=nil, prev_node=nil)
    move_graph = move_graph || RGL::DirectedAdjacencyGraph.new
    graph_options = {
      'edge' => {
        'label' => Proc.new {|u,v| v[:last_move] },
        'to' => Proc.new {|u,v| v[:binary_s] },
        'from' => Proc.new {|u,v| u[:binary_s] }
       },
      'vertex' => {
        'label' => Proc.new {|v| v[:binary_s] },
        'name' => Proc.new {|v| v[:binary_s] }
      }
    }

    if board.moves.size == 0
      #dotfile = "gtg"
      #move_graph.write_to_graphic_file('png', dotfile, graph_options)
      start = board.start_state 
      current = board.state
      pp move_graph.dijkstra_shortest_path(Hash.new(1), start, current)
    else
      board.moves.each { |m|
        from = m.first
        tos = m.last
        tos.each { |to| 
          dup_board = board.dup
          orig_state = dup_board.state
          dup_board.move from, to
          new_state = dup_board.state
          move_graph.add_edge orig_state, new_state
          further_results = traverse_moves(dup_board, move_graph, new_state)
          move_graph = further_results
        }
      }
    end
    move_graph
  end

  def initialize(blank)
    @valid_move_graphs = init_valid_move_graphs
    @board = init_board
    @vals = ('a'..'o').map {|node|
      {node => node == blank ? 0 : 1 }
    }.inject(&:merge)
    update_state
    @start_state = self.state
  end
end
