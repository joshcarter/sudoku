class Solved < Exception
  attr_reader :cells
  
  def initialize(cells)
    @cells = cells
  end
end

class Unsolvable < Exception
end

class Grid
  def initialize(cells)
    # Need to do a deep copy of the cells array
    @cells = cells.clone
    @dimension = Math::sqrt(@cells.length).to_i
    @stride = Math::sqrt(@dimension).to_i
    @possible_values = (1..@dimension).to_a
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
    
    each_cell do |cell, row, col|
      str << (cell ? cell.to_s : '_')
      str << (col == @dimension - 1 ? "\n" : " ")
    end

    str
  end
  
  def [](row, col)
    @cells[row * @dimension + col]
  end
  
  def []=(row, col, value)
    @cells[row * @dimension + col] = value
  end
  
  def each_cell
    @cells.each_with_index do |cell, cell_num|
      yield cell, (cell_num / @dimension), (cell_num % @dimension)
    end
  end

  def solved?
    each_cell do |cell, row, col|
      return false if cell.nil?
    end
    
    return true
  end
  
  def solvable?
    each_cell do |cell, row, col|
      return false if (cell.nil? and unused_values_for_cell(row, col) == [])
    end
    
    return true
  end

  def unused_values_for_row(row)
    values = []

    each_cell do |cell, current_row, current_col|
      values << cell unless cell.nil? or current_row != row
    end

    @possible_values - values
  end

  def unused_values_for_col(col)
    values = []

    each_cell do |cell, current_row, current_col|
      values << cell unless cell.nil? or current_col != col
    end

    @possible_values - values
  end

  def zone_for(row, col)
    [row / @stride, col / @stride]
  end

  def unused_values_for_zone(row, col)
    values = []
    requested_zone = zone_for(row, col)

    each_cell do |cell, current_row, current_col|
      values << cell unless cell.nil? or
                            zone_for(current_row, current_col) != requested_zone
    end

    @possible_values - values
  end
  
  def unused_values_for_cell(row, col)
    unused_values_for_row(row) &
    unused_values_for_col(col) &
    unused_values_for_zone(row, col)
  end
  
  def solve_determinate_cells
    loop do
      changes = 0
      
      each_cell do |cell, row, col|
        if cell.nil?
          possible_values = unused_values_for_cell(row, col)

          if (possible_values.length == 1)
            # puts "solve_determinate_cells: (#{row}, #{col}) = #{possible_values.first}"
            self[row, col] = possible_values.first
            changes += 1
          end
        end
      end

      break if changes == 0
    end
  end
  
  def solve_with_guesses
    solve_determinate_cells
    
    return if solved?

    raise Unsolvable unless solvable?

    # Create a list of cells that are empty, and the number of possible
    # values for each
    open_cells = Array.new
    each_cell do |cell, row, col|
      if cell.nil?
        open_cells << { :row => row, :col => col, :num_values => unused_values_for_cell(row, col).length }
      end
    end

    # Sort that list so that the cells with least possible values are first
    open_cells.sort_by { |tuple| tuple[:num_values] }

    # Start there and recurse
    row = open_cells.first[:row]
    col = open_cells.first[:col]
    possible_values = unused_values_for_cell(row, col)
    # puts "starting with cell (#{row}, #{col}) because it has #{possible_values.length} values"

    possible_values.each do |value|
      begin
        # puts "trying (#{row}, #{col}) = #{value}"

        new_grid = Grid::new(@cells)
        new_grid[row, col] = value
        # puts new_grid
        new_grid.solve_with_guesses

        # Bail out to top-level solve
        raise Solved.new(new_grid.instance_variable_get(:@cells))
      rescue Unsolvable
        # puts "unsolvable"
      end
    end

    raise Unsolvable unless solved?
  end
  
  def solve
    begin
      solve_with_guesses
    rescue Solved => e
      # Copy over cells from solved grid
      @cells = e.cells
    end
  end
end
