require 'test/unit'
require 'grid'

class GridTester < Test::Unit::TestCase
  def test_grid_valid
    grid = Grid::load("grids/easy_grid.txt")
    assert_equal(9, grid.get(0, 0))
    assert_equal(8, grid.get(0, 1))
    assert_equal(nil, grid.get(1, 0))
  end
  
  def test_unused_values_for_row
    grid = Grid::load("grids/easy_grid.txt")
    assert_equal(grid.unused_values_for_row(0), [1, 2, 4, 5, 7])
    assert_equal(grid.unused_values_for_row(2), [1, 6, 7, 8])
  end
  
  def test_unused_values_for_col
    grid = Grid::load("grids/easy_grid.txt")
    assert_equal(grid.unused_values_for_col(2), [5, 6, 7])
    assert_equal(grid.unused_values_for_col(0), [2, 4, 6, 7])
  end
  
  def test_zone_for
    grid = Grid::load("grids/easy_grid.txt")
    assert_equal(grid.zone_for(0, 0), [0, 0])
    assert_equal(grid.zone_for(1, 0), [0, 0])
    assert_equal(grid.zone_for(2, 0), [0, 0])
    assert_equal(grid.zone_for(8, 0), [2, 0])
  end
  
  def test_unused_values_for_zone
    grid = Grid::load("grids/easy_grid.txt")
    assert_equal(grid.unused_values_for_zone(0, 0), [1, 4, 5, 6, 7])
    assert_equal(grid.unused_values_for_zone(0, 8), [1, 6, 7, 8])
    assert_equal(grid.unused_values_for_zone(8, 8), [1, 4, 5, 6, 7])
  end
  
  def test_unused_values_for_cell
    grid = Grid::load("grids/easy_grid.txt")
    assert_equal(grid.unused_values_for_cell(0, 2), [5, 7])
    assert_equal(grid.unused_values_for_cell(1, 0), [4, 6])
    assert_equal(grid.unused_values_for_cell(1, 1), [1])
    assert_equal(grid.unused_values_for_cell(1, 2), [6])
    assert_equal(grid.unused_values_for_cell(2, 0), [6, 7])

    # Fill in cells with only one valid option
    grid.set(1, 1, 1)
    grid.set(1, 2, 6)
    
    assert_equal(grid.unused_values_for_cell(1, 0), [4])
    grid.set(1, 0, 4)
    
    assert_equal(grid.unused_values_for_cell(2, 0), [7])
    grid.set(2, 0, 7)
    
    assert_equal(grid.unused_values_for_cell(0, 2), [5])
    grid.set(0, 2, 5)
  end
  
  def test_solve_easy_grid
    puts "running easy grid"
    grid = Grid::load("grids/easy_grid.txt")
    grid.solve

    assert_equal true, grid.solved?
    
    puts "solved grid:"
    puts grid.to_s
  end
  
  def test_grid_solvable
    grid = Grid::load("grids/medium_grid.txt")
    assert_equal true, grid.solvable?
    assert_equal [2, 8, 9], grid.unused_values_for_cell(1,3)
    
    grid.set(7,3,8)
    grid.set(8,3,9)
    grid.set(0,4,2)
    
    assert_equal [], grid.unused_values_for_cell(1,3)
    assert_equal false, grid.solvable?
  end
  
  def test_solve_medium_grid
    puts "running medium grid"
    grid = Grid::load("grids/medium_grid.txt")

    # cheating: solve part the of puzzle
    # grid.set(0,1,6)
    # grid.set(0,4,2)
    # grid.set(0,5,7)
    # grid.set(0,7,9)
    # grid.set(0,8,8)

    grid.solve
    puts "solved grid:"
    puts grid.to_s
   end
   
   def test_solve_hard_grid
     puts "running hard grid"
     grid = Grid::load("grids/hard_grid.txt")
     grid.solve
     puts "solved grid:"
     puts grid.to_s
   end
end
