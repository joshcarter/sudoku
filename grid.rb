class Grid
  def initialize(cells, stride)
    @cells = cells
    @stride = stride
    @dimension = (stride * stride)
  end

  def self.load(filename)
    lines = File::readlines(filename)
    stride = Math::sqrt(lines[0].split.length).to_i

    cells = lines.map do |line|
      line.split.map do |cell| 
        cell == '_' ? nil : cell.to_i
      end
    end

    # Should do some assertions in here that each 
    # line has correct number of elements
    
    Grid.new(cells, stride)
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
      return false if cell == nil
    end
    
    return true
  end

  def invalid_for_row(row)
    row_contents = @cells[row].clone
    row_contents.compact
  end

  def valid_for_row(row)
    all_options = Array.new(@dimension) { |i| i + 1 }
    all_options - invalid_for_row(row)
  end
  
  def invalid_for_col(col)
    col_contents = Array.new
    
    for row in 0...@dimension
      col_contents << @cells[row][col]
    end
    
    col_contents.compact
  end
  
  def valid_for_col(col)
    all_options = Array.new(@dimension) { |i| i + 1 }
    all_options - invalid_for_col(col)
  end
  
  def range_containing_cell(cell)
    base = 0
    
    @stride.times do
      for i in base...(base + @stride)
        if (i == cell)
          return Array.new(@stride) { |i| base + i }
        end
      end
      
      base += @stride
    end
  end
  
  def valid_for_square(row, col)
    all_options = Array.new(@dimension) { |i| i + 1 }
    square_contains = Array.new
    
    range_containing_cell(row).each do |row|
      range_containing_cell(col).each do |col|
        if (@cells[row][col])
          square_contains << @cells[row][col]
        end
      end
    end
    
    all_options - square_contains
  end
  
  def valid_for_cell(row, col)
    # Note: using & for array union here, not bitwise AND
    valid_for_row(row) & valid_for_col(col) & valid_for_square(row, col)
  end
  
  def solve
    iteration = 1
    
    loop do
      changes = 0
      
      each_cell_with_index do |cell, row, col|
        if cell == nil
          possible_values = valid_for_cell(row, col)

          if (possible_values.length == 1)
            set(row, col, possible_values[0])
            changes += 1
          end
        end
      end

      if solved?
        puts "solved in #{iteration} iterations"
        return self
      elsif changes == 0
        throw "cannot solve grid"
      else
        iteration += 1
      end
    end
  end
end
