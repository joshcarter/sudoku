# Exception class used internally by the solver.
class Solved < Exception
  attr_reader :cells
  
  def initialize(cells)
    @cells = cells
  end
end

# Exception thrown by Grid#solve() and Grid#[]= if grid is unsolvable.
class Unsolvable < Exception
end

# Sudoku grid. Easiest way to populate one is from a file; see load() and 
# load_line(). Grid will automatically solve cells which can only logically
# have one value. Call solve() to search unknown cells for the solution.
#
# Some details on implementation: Each solved cell contains a single value,
# each unsolved cell contains an array of possible values. (Coming into 
# initialize() those unsolved cells contain nil.) Taking a cue from Peter
# Norvig [1], setting any cell causes all peer cells to update their list of
# possible values. If any of these cells reduce to a single value, that'll
# cause its peers to recalculate, and so on. Simple grids can be entirely
# solved in this manner.
#
# Another important note is that the grid contains a map of every cell's
# index to a flat array of all its peers (same row, same column, same zone).
# This map is computed in initialize() so that the constraint operation
# (above) can operate very quickly. The peer map is large, so it is not
# copied in dup(), nor does it need to be, because it's the same for all
# grids of the same dimensions.
#
# Early versions of this class were much more dynamic, and would compute
# peers and possible values on the fly. Doing it that was was elegant (in
# a way) but also extremely slow -- it took an hour to solve the grid in
# grids/super_hard_grid.txt. Most of the time was spent iterating over the
# grid, which is what lead me to create the peer map. This version solves
# the same grid in about 1.2 seconds, roughly a 3000x improvement.
#
# [1]: http://norvig.com/sudoku.html
#
class Grid
  # Create grid from array of cell values. Unknown cells should be nil.
  def initialize(cell_array)
    @dimension = Math::sqrt(cell_array.length).to_i # 9 for 9x9 grid
    @stride = Math::sqrt(@dimension).to_i           # 3 for 9x9 grid
    @possible_values = (1..@dimension).to_a         # 0...9 for 9x9 grid

    # Make hash of cells. Using a hash here instead of array because
    # it allows for some handy transforms down in solve().
    @cells = Hash.new
    
    cell_array.each_with_index do |value, index|
      @cells[index] = value
    end
    
    # Figure out peers for each cell. This flat list of peers lets us
    # traverse them quickly when we need to re-evaluate their list
    # of possible values. Otherwise we need to do a lot more iteration
    # over the grid, especially when figuring out zone peers.
    @peers = Hash.new
    
    @dimension.times do |row|
      @dimension.times do |col|
        index = index_for(row, col)
        @peers[index] = Array.new

        # All cells in same row
        @dimension.times do |peer_row|
          @peers[index] << index_for(peer_row, col)
        end
        
        # All cells in same column
        @dimension.times do |peer_col|
          @peers[index] << index_for(row, peer_col)
        end
        
        # All cells in same zone
        @dimension.times do |peer_row|
          @dimension.times do |peer_col|
            if (peer_row / @stride == row / @stride) and (peer_col / @stride == col / @stride)
              @peers[index] << index_for(peer_row, peer_col)
            end
          end
        end
        
        # Remove duplicates and remove ourself
        @peers[index] = @peers[index].uniq - [index]
        @peers[index].freeze
      end
    end
    
    @peers.freeze

    # Calculate options for each unknown cell. For trivial grids this
    # will solve it immediately.
    @cells.each_key do |index|
      update_possible_values(index)
    end
  end
  
  # Custom dup that copies its cells. Peer list is intentionally not 
  # copied, as that can be shared among grids of same dimensions.
  def dup
    copy = super
    @cells = @cells.dup # Need to copy the cells, but nothing else
    copy
  end
  
  # Translates (row, col) coordinate into cell index.
  def index_for(row, col)
    (row * @dimension) + col
  end
  
  # Updates possible values for a cell. Does nothing if cell is 
  # already solved.
  def update_possible_values(index)
    value = @cells[index]

    return if value.class == Fixnum # Cell already solved
    
    # Find values used by peers
    used_values = Array.new
    
    @peers[index].each do |peer|
      peer_value = @cells[peer]
      used_values << peer_value if (peer_value.class == Fixnum)
    end
    
    # Possible values are everything that's left
    values = @possible_values - used_values

    case values.length
    when 0
      raise Unsolvable.new("no possible values for cell #{index}")
    when 1
      # Cell is solved. Note: assignment of cell will force peers to
      # update their possible values, i.e. this method is re-entrant.
      self[index] = values.first
    else
      @cells[index] = values
    end
  end

  # Load grid file from "pretty" format, like those in "grids" directory.
  def self.load(filename)
    lines = File::readlines(filename)

    cells = lines.map do |line|
      line.split.map do |cell| 
        cell == '_' ? nil : cell.to_i
      end
    end
    
    Grid.new(cells.flatten)
  end
  
  # Load grid in one-line format, 0 in place of unknowns. Handy for loading
  # grids from http://people.csse.uwa.edu.au/gordon/sudokumin.php
  def self.load_line(filename)
    line = File::readlines(filename)[0]
    cells = line.split('')
    cells.map { |cell| cell == 0 ? nil : cell.to_i }
    Grid.new(cells)
  end
  
  # Save grid in "pretty" format.
  def save(filename)
    File::open(filename, "w") do |file|
      file.print self
    end
  end

  # Prints cells in pretty format. Setting show_possible_values will print
  # something less pretty, but it can be useful for debugging.
  def to_s(show_possible_values = false)
    str = String.new
    
    @cells.keys.sort.each do |index|
      if show_possible_values
        str << (@cells[index].nil? ? '_' : @cells[index].to_s)
      else
        str << (@cells[index].class == Fixnum ? @cells[index].to_s : '_')
      end
      str << (index % @dimension == @dimension - 1 ? "\n" : ' ')
    end

    str
  end
  
  # Get cell value at index.
  def [](index)
    @cells[index]
  end
  
  # Set cell value at index, forcing peers with unknown value to update
  # their list of possible values. Will throw Unsolvable if setting the
  # cell makes the grid unsolvable.
  def []=(index, value)
    @cells[index] = value
    @peers[index].each { |peer| update_possible_values(peer) }
  end

  # True if all cells are solved.
  def solved?
    @cells.each_value do |value|
      return false if value.class != Fixnum
    end
    
    return true
  end
  
  # Main solve method. Will do depth-first search as required to figure
  # out anything that the constraint solver can't figure out. Raises 
  # Unsolvable if puzzle is truly unsolvable.
  def solve
    begin
      solve_with_guesses
    rescue Solved => e
      @cells = e.cells # Copy over cells from solved grid
    end
  end

  # Internal method to do depth-first search. Raises Solved with solution
  # cells when complete (aborting all further searching) or Unsolvable if
  # search can't find any solution.
  def solve_with_guesses
    return if solved?
  
    # Find all cells with unknown values.  We're guaranteed to have at least
    # one Array value in there because otherwise solved? would have returned
    # true.
    unknown_cells = @cells.select do |index, value|
      value.class == Array
    end
    
    # Pick cell with least number of unknowns, i.e. the guess of least risk.
    index, values = unknown_cells.min { |a, b| a[1].length <=> b[1].length }
    
    values.each do |value|
      begin
        # Subsequent work needs to operate on a copy of the grid, as this
        # guess may have been wrong.
        new_grid = self.dup
        new_grid[index] = value
        new_grid.solve_with_guesses
  
        # Solved. Bail out to top-level solve()
        raise Solved.new(new_grid.instance_variable_get(:@cells))
      rescue Unsolvable
      end
    end
  
    raise Unsolvable unless solved?
  end
end
