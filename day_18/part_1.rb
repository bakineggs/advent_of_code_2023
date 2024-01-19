require 'set'

plan = File.readlines(ARGV[0]).map do |line|
  raise "Failed to parse line #{line}" unless match = line.match(/^([LRUD]) (\d*) \(#[\da-f]{6}\)$/)
  [match[1], match[2].to_i]
end

depth, row, col, end_row, end_col = [[0]], 0, 0, 0, 0
plan.each do |dir, steps|
  case dir
  when 'R'
    depth.each {|d| d.push *([0] * (col + steps + 1 - depth.last.length))} if col + steps + 1 > depth.first.length
    move = lambda {|row, col| [row, col + 1]}
  when 'L'
    depth.each {|d| d.unshift *([0] * (steps - col))} and end_col += steps - col and col = steps if steps > col
    move = lambda {|row, col| [row, col - 1]}
  when 'D'
    depth.push *(row + steps + 1 - depth.length).times.map {[0] * depth.first.length} if row + steps + 1 > depth.length
    move = lambda {|row, col| [row + 1, col]}
  when 'U'
    depth.unshift *(steps - row).times.map {[0] * depth.first.length} and end_row += steps - row and row = steps if steps > row
    move = lambda {|row, col| [row - 1, col]}
  end
  steps.times do
    raise "Crossed a spot (#{row}, #{col}) that has already been dug" unless depth[row][col] == 0
    depth[row][col] = 1
    row, col = move[row, col]
  end
end
raise 'Expected to end up back at the starting point' unless row == end_row &&  col == end_col

row = depth.find_index {|row| row.count {|d| d == 1} == 2} or raise 'Expected a row with 2 dug columns'
col = depth[row].find_index {|d| d == 1} + 1
to_explore = [[row, col]].to_set

until to_explore.empty?
  row, col = to_explore.take(1).first
  to_explore.delete [row, col]
  next unless depth[row][col] == 0
  depth[row][col] = 1
  [[row + 1, col], [row - 1, col], [row, col + 1], [row, col - 1]].each do |row, col|
    to_explore.add [row, col] if depth[row][col] == 0
  end
end

puts depth.sum &:sum
