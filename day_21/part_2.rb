require 'set'

lines = File.readlines ARGV[0], chomp: true

raise 'Expected all lines to have the same length' unless lines.all? {|line| line.length == lines.first.length}
raise 'Expected all lines to only contain . # and S' unless lines.all? {|line| line.match /^[.#S]+$/}
raise 'Expected exactly one S in the input' unless lines.sum {|line| line.count 'S'} == 1

STEPS = ARGV[1].to_i

start_row = lines.find_index {|line| line.include? 'S'}
start_col = lines[start_row].index 'S'
to_explore = [[start_row, start_col, 0]]
explored = Set.new
end_points = 0

until to_explore.empty?
  row, col, steps = to_explore.shift
  next if explored.include? [row, col]
  explored.add [row, col]
  end_points += 1 if steps % 2 == STEPS % 2
  next if steps == STEPS
  [[row - 1, col], [row + 1, col], [row, col - 1], [row, col + 1]].each do |row, col|
    next if lines[row % lines.length][col % lines.first.length] == '#'
    to_explore.push [row, col, steps + 1]
  end
end

puts end_points
