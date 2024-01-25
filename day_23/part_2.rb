require 'set'

lines = File.readlines ARGV[0], chomp: true

raise 'Expected all lines to be the same length' unless lines.all? {|line| line.length == lines.first.length}
raise 'Expected each line to only contain the characters . # ^ v < >' unless lines.all? {|line| line.match /^#[.#^v<>]+\#$/}
raise 'Expected entrance in the top left corner' unless lines.first.match /^#\.#+$/
raise 'Expected exit in the bottom right corner' unless lines.last.match /^#+\.\#$/

max_row, max_col = lines.length - 1, lines.first.length - 1

adjacency, to_explore, explored = {}, [[0, 1]], Set.new
until to_explore.empty?
  row, col = to_explore.pop
  next if row == max_row
  next if explored.include? [row, col]
  explored.add [row, col]

  [[row - 1, col], [row + 1, col], [row, col - 1], [row, col + 1]].each do |r, c|
    next if r == 0 || c == 0 || c == max_col || lines[r][c] == '#'
    next if explored.include? [r, c]
    (adjacency[[row, col]] ||= []).push [[r, c], 1]
    (adjacency[[r, c]] ||= []).push [[row, col], 1]
    to_explore.push [r, c]
  end
end

while n = adjacency.keys.find {|n| adjacency[n].length == 2}
  (n1, w1), (n2, w2) = adjacency[n]
  raise unless adjacency[n1].include? [n, w1]
  raise unless adjacency[n2].include? [n, w2]
  adjacency[n1].delete [n, w1]
  adjacency[n2].delete [n, w2]
  adjacency.delete n
  adjacency[n1].push [n2, w1 + w2]
  adjacency[n2].push [n1, w1 + w2]
end

longest, to_explore = nil, [[[0, 1], Set.new, 0]]
until to_explore.empty?
  n1, visited, length = to_explore.pop
  visited += [n1]

  if n1[0] == max_row
    longest = length if longest.nil? || longest < length
    next
  end

  adjacency[n1].each do |n2, weight|
    next if visited.include? n2
    to_explore.push [n2, visited, length + weight]
  end
end

puts longest
