require 'test/unit'
require 'grid'

class GridTester < Test::Unit::TestCase
  def test_grid_valid
    grid = Grid::load("grids/easy_grid.txt")  
    assert_equal 9, grid[0]
    assert_equal 8, grid[1]
    assert_equal 3, grid[79]
    assert_equal 2, grid[80]
    
    peers = grid.instance_variable_get(:@peers)
    assert_equal(
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 18, 19, 20, 27, 36, 45, 54, 63, 72],
      peers[0].sort)
    assert_equal(
      [8, 17, 26, 35, 44, 53, 60, 61, 62, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79],
      peers[80].sort)
  end
  
  def test_solve_easy_grid
    puts "running easy grid"
    grid = Grid::load("grids/easy_grid.txt")

    # Note: don't even need to solve it, simple constraint propogation
    # applied during loading will solve it for us
    assert_equal true, grid.solved?
    
    puts "solved grid:"
    puts grid.to_s
  end

  def test_grid_unsolvable
    grid = Grid::load("grids/medium_grid.txt")
    assert_equal false, grid.solved?
    assert_equal [2, 8, 9], grid[grid.index_for(1, 3)]

    assert_raise Unsolvable do
      grid[grid.index_for(7, 3)] = 8
      grid[grid.index_for(8, 3)] = 9
      grid[grid.index_for(0, 4)] = 2
    end
  end

  def test_solve_medium_grid
    puts "running medium grid"
    grid = Grid::load("grids/medium_grid.txt")
  
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

  def test_solve_super_hard_grid
    puts "running super hard grid"
    grid = Grid::load("grids/super_hard_grid.txt")
    grid.solve
    puts "solved grid:"
    puts grid.to_s
  end
end
