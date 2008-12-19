require 'test/unit'
require 'grid'

class GridTester < Test::Unit::TestCase
  def test_grid_valid
    grid = Grid::load("grids/easy_grid.txt")  
    assert_equal 9, grid['A0']
    assert_equal 8, grid['A1']
    assert_equal 3, grid['I7']
    assert_equal 2, grid['I8']
    assert_equal nil, grid['A2']
    
    peers = grid.instance_variable_get(:@peers)
    assert_equal(
      ["A1", "A2", "A3", "A4", "A5", "A6", "A7", "A8", "B0", "B1", "B2",
       "C0", "C1", "C2", "D0", "E0", "F0", "G0", "H0", "I0"],
      peers['A0'].sort)
    assert_equal(
      ["A8", "B8", "C8", "D8", "E8", "F8", "G6", "G7", "G8", "H6", "H7",
       "H8", "I0", "I1", "I2", "I3", "I4", "I5", "I6", "I7"],
      peers['I8'].sort)
  end
  
  def test_unused_values_for_cell
    grid = Grid::load("grids/easy_grid.txt")
    assert_equal [5, 7], grid['A2']
    assert_equal [4, 6], grid['B0']
    # assert_equal(grid.unused_values_for_cell(1, 0), [4, 6])
    # assert_equal(grid.unused_values_for_cell(1, 1), [1])
    # assert_equal(grid.unused_values_for_cell(1, 2), [6])
    # assert_equal(grid.unused_values_for_cell(2, 0), [6, 7])
    #   
    # # Fill in cells with only one valid option
    # grid[1, 1] = 1
    # grid[1, 2] = 6
    # 
    # assert_equal(grid.unused_values_for_cell(1, 0), [4])
    # grid[1, 0] = 4
    # 
    # assert_equal(grid.unused_values_for_cell(2, 0), [7])
    # grid[2, 0] = 7
    # 
    # assert_equal(grid.unused_values_for_cell(0, 2), [5])
    # grid[0, 2] = 5
  end
  # 
  # def test_solve_easy_grid
  #   puts "running easy grid"
  #   grid = Grid::load("grids/easy_grid.txt")
  #   grid.solve
  # 
  #   assert_equal true, grid.solved?
  #   
  #   puts "solved grid:"
  #   puts grid.to_s
  # end
  # 
  # def test_grid_solvable
  #   grid = Grid::load("grids/medium_grid.txt")
  #   assert_equal true, grid.solvable?
  #   assert_equal [2, 8, 9], grid.unused_values_for_cell(1,3)
  #   
  #   grid[7, 3] = 8
  #   grid[8, 3] = 9
  #   grid[0, 4] = 2
  #   
  #   assert_equal [], grid.unused_values_for_cell(1,3)
  #   assert_equal false, grid.solvable?
  # end
  # 
  # def test_solve_medium_grid
  #   puts "running medium grid"
  #   grid = Grid::load("grids/medium_grid.txt")
  # 
  #   # cheating: solve part the of puzzle
  #   # grid.set(0,1,6)
  #   # grid.set(0,4,2)
  #   # grid.set(0,5,7)
  #   # grid.set(0,7,9)
  #   # grid.set(0,8,8)
  # 
  #   grid.solve
  #   puts "solved grid:"
  #   puts grid.to_s
  #  end
  #  
  #  def test_solve_hard_grid
  #    puts "running hard grid"
  #    grid = Grid::load("grids/hard_grid.txt")
  #    grid.solve
  #    puts "solved grid:"
  #    puts grid.to_s
  #  end

  # def test_solve_super_hard_grid
  #   puts "running super hard grid"
  #   grid = Grid::load("grids/super_hard_grid.txt")
  #   grid.solve
  #   puts "solved grid:"
  #   puts grid.to_s
  # end
end
