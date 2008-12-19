class Solved < Exception
  attr_reader :cells
  
  def initialize(cells)
    @cells = cells
  end
end

class Unsolvable < Exception
end

class Grid
  def initialize(cell_array)
    @dimension = Math::sqrt(cell_array.length).to_i
    @stride = Math::sqrt(@dimension).to_i
    @possible_values = (1..@dimension).to_a
    @all_rows = (0...@dimension).to_a # 0..8 for a 9x9 grid
    @all_cols = (0...@dimension).to_a # 0..8 for a 9x9 grid

    # Make hash of cells
    @cells = Hash.new
    
    cell_array.each_with_index do |value, index|
      @cells[index] = value
    end
    
    # Figure out peers for each cell
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
      end
    end

    # Calculate options for each unknown cell
    @cells.each_key do |index|
      update_possible_values(index)
    end
  end
  
  def dup
    copy = super
    @cells = @cells.dup # Need to copy the cells, but nothing else
    copy
  end
  
  def index_for(row, col)
    (row * @dimension) + col
  end
  
  def update_possible_values(index)
    value = @cells[index]

    return if value.class == Fixnum # Cell already solved

    used_values = Array.new
    
    @peers[index].each do |peer|
      peer_value = @cells[peer]
      used_values << peer_value if (peer_value.class == Fixnum)
    end
    
    values = @possible_values - used_values

    case values.length
    when 0
      raise Unsolvable.new("no possible values for cell #{index}")
    when 1
      self[index] = values.first # Note: this will re-enter update_possible_values!
    else
      @cells[index] = values
    end
  end

  def self.load(filename)
    lines = File::readlines(filename)

    cells = lines.map do |line|
      line.split.map do |cell| 
        cell == '_' ? nil : cell.to_i
      end
    end
    
    Grid.new(cells.flatten)
  end
  
  # Used for loading grids with everything one line, 0 in place of nulls
  def self.load_line(filename)
    line = File::readlines(filename)[0]
    cells = line.split('')
    cells.map { |cell| cell == 0 ? nil : cell.to_i }    
    Grid.new(cells)
  end
  
  def save(filename)
    File::open(filename, "w") do |file|
      file.print self
    end
  end

  def to_s
    str = String.new
    
    @dimension.times do |row|
      str << @all_cols.map { |col| @cells[index_for(row, col)].to_s }.join(' ')
      str << "\n"
    end

    str
  end
  
  def [](index)
    @cells[index]
  end
  
  def []=(index, value)
    @cells[index] = value
    
    # Update all peers to exclude this value from their possible values
    @peers[index].each { |peer| update_possible_values(peer) }
  end
  
  def solved?
    @cells.each_value do |value|
      return false if value.class != Fixnum
    end
    
    return true
  end
  
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
  
  def solve
    begin
      solve_with_guesses
    rescue Solved => e
      @cells = e.cells # Copy over cells from solved grid
    end
  end
end
