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
    @cells = Marshal.load(Marshal.dump(cells))
    @dimension = (@cells[0].length)
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
    
    Grid.new(cells)
  end
  
  def save(filename)
    File::open(filename, "w") do |file|
      file.print self
    end
  end

  def to_s
    str = String.new
    
    each_cell_with_index do |cell, row, col|
      str << (cell ? cell.to_s : '_')
      str << (col == @dimension - 1 ? "\n" : " ")
    end

    str
  end
  
  def get(row, col)
    @cells[row][col]
  end
  
  def set(row, col, value)
    @cells[row][col] = value
  end
  
  def each_cell
    @cells.each do |row|
      row.each do |cell|
        yield cell
      end
    end
  end
  
  def each_cell_with_index
    @cells.each_with_index do |row, row_num|
      row.each_with_index do |cell, col_num|
        yield cell, row_num, col_num
      end
    end
  end

  def solved?
    each_cell do |cell|
      return false if cell.nil?
    end
    
    return true
  end
  
  def solvable?
    each_cell_with_index do |cell, row, col|
      return false if (cell.nil? and unused_values_for_cell(row, col) == [])
    end
    
    return true
  end

  def unused_values_for_row(row)
    values = []

    each_cell_with_index do |cell, current_row, current_col|
      values << cell unless cell.nil? or current_row != row
    end

    @possible_values - values
  end

  def unused_values_for_col(col)
    values = []

    each_cell_with_index do |cell, current_row, current_col|
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

    each_cell_with_index do |cell, current_row, current_col|
      values << cell unless cell.nil? or
                            zone_for(current_row, current_col) != requested_zone
    end

    @possible_values - values
  end
  
  def unused_values_for_cell(row, col)
    (unused_values_for_row(row) &
     unused_values_for_col(col) &
     unused_values_for_zone(row, col)).uniq.sort
  end
  
  def solve_determinate_cells
    loop do
      changes = 0
      
      each_cell_with_index do |cell, row, col|
        if cell.nil?
          possible_values = unused_values_for_cell(row, col)

          if (possible_values.length == 1)
            # puts "solve_determinate_cells: (#{row}, #{col}) = #{possible_values.first}"
            set(row, col, possible_values.first)
            changes += 1
          end
        end
      end

      break if changes == 0
    end
  end
  
  def solve_with_guesses
    solve_determinate_cells

    raise Unsolvable unless solvable?

    each_cell_with_index do |cell, row, col|
      if cell.nil?
        possible_values = unused_values_for_cell(row, col)

        # puts "possible values for (#{row}, #{col}): #{possible_values.join(', ')}"

        possible_values.each do |value|
          begin
            puts "trying (#{row}, #{col}) = #{value}"

            new_grid = Grid::new(@cells)
            new_grid.set(row, col, value)
            new_grid.solve_with_guesses

            # Bail out to top-level solve
            raise Solved.new(new_grid.instance_variable_get(:@cells))
          rescue Unsolvable
            puts "unsolvable"
          end
        end
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
