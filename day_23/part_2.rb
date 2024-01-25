require 'set'

lines = File.readlines ARGV[0], chomp: true

raise 'Expected all lines to be the same length' unless lines.all? {|line| line.length == lines.first.length}
raise 'Expected each line to only contain the characters . # ^ v < >' unless lines.all? {|line| line.match /^#[.#^v<>]+\#$/}
raise 'Expected entrance in the top left corner' unless lines.first.match /^#\.#+$/
raise 'Expected exit in the bottom right corner' unless lines.last.match /^#+\.\#$/

max_row, max_col = lines.length - 1, lines.first.length - 1

longest, to_explore, explored = nil, [[0, 1, Set.new]], Set.new
until to_explore.empty?
  row, col, visited = to_explore.pop
  next if explored.include? [row, col, visited]
  explored.add [row, col, visited]
  visited += [[row, col]]

  if row == max_row
    longest = visited.length if longest.nil? || longest < visited.length
    next
  end

  [[row - 1, col], [row + 1, col], [row, col - 1], [row, col + 1]].each do |r, c|
    next if r == 0 || c == 0 || c == max_col || lines[r][c] == '#'
    next if visited.include? [r, c]
    to_explore.push [r, c, visited]
  end
end

puts longest - 1
