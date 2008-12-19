require 'rubygems'
require 'ruby-prof'

#
# Test hash with array keys
# Total Time: 3.231977
#
h = Hash.new

9.times do |j|
  9.times do |i|
    h[[i, j]] = 'foo'
  end
end

keys = h.keys.sort

result = RubyProf.profile do
  foo = nil

  1000.times do 
    keys.each do |key|
      foo = h[key]
    end
  end
end

printer = RubyProf::GraphPrinter.new(result)
printer.print(STDOUT, 0)

#
# Test hash with string keys
# Total Time: 0.604938
#
h = Hash.new

('A'..("" << (?A + 9))).to_a.each do |j|
  9.times do |i|
    h[j + i.to_s] = 'foo'
  end
end

keys = h.keys.sort

result = RubyProf.profile do
  foo = nil

  1000.times do 
    keys.each do |key|
      foo = h[key]
    end
  end
end

printer = RubyProf::GraphPrinter.new(result)
printer.print(STDOUT, 0)

#
# Test hash with int keys
# Total Time: 
#
h = Hash.new

9.times do |j|
  9.times do |i|
    h[j * 9 + i] = 'foo'
  end
end

keys = h.keys.sort

result = RubyProf.profile do
  foo = nil

  1000.times do 
    keys.each do |key|
      foo = h[key]
    end
  end
end

printer = RubyProf::GraphPrinter.new(result)
printer.print(STDOUT, 0)
