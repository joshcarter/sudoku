Simple Sudoku Solver in Ruby
    by Josh Carter
    http://github.com/joshcarter/sudoku/tree/master

== DESCRIPTION:

Simple Sudoku solver built in Ruby. Run the test.rb for a demonstration,
or something like this in irb:

  grid = Grid::load("grids/medium_grid.txt")
  grid.solve
  puts grid

Some details on implementation: Each solved cell contains a single value,
each unsolved cell contains an array of possible values. (Coming into 
initialize() those unsolved cells contain nil.) Taking a cue from Peter
Norvig [1], setting any cell causes all peer cells to update their list of
possible values. If any of these cells reduce to a single value, that'll
cause its peers to recalculate, and so on. Simple grids can be entirely
solved in this manner.

Another important note is that the grid contains a map of every cell's
index to a flat array of all its peers (same row, same column, same zone).
This map is computed in initialize() so that the constraint operation
(above) can operate very quickly. The peer map is large, so it is not
copied in dup(), nor does it need to be, because it's the same for all
grids of the same dimensions.

Early versions of this class were much more dynamic, and would compute
peers and possible values on the fly. Doing it that was was elegant (in
a way) but also extremely slow -- it took an hour to solve the grid in
grids/super_hard_grid.txt. Most of the time was spent iterating over the
grid, which is what lead me to create the peer map. This version solves
the same grid in about 1.2 seconds, roughly a 3000x improvement.

[1]: http://norvig.com/sudoku.html

== LICENSE:

MIT License
Copyright (c) 2008

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sub-license, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
