lines = File.readlines ARGV[0], chomp: true

raise 'Expected all lines to be the same length' unless lines.all? {|line| line.length == lines.first.length}
raise 'Unrecognized character' unless lines.all? {|line| line.match /^[.F7JL\-\|S]+$/}

start_line = lines.find_all {|line| line.include? 'S'}
raise 'Expected exactly one starting point' unless start_line.length == 1 && start_line.first.match(/^[^S]*S[^S]*$/)

start_line = start_line.first
to_visit = [[lines.index(start_line), start_line.index('S'), 0]]

distances = lines.map {lines.first.length.times.map {nil}}

loop do
  row, col, distance = to_visit.shift
  distances[row][col] = distance

  if distance == 0
    neighbors = []
    neighbors.push [row - 1, col] if row > 0 && 'F7|'.include?(lines[row - 1][col])
    neighbors.push [row + 1, col] if row < lines.length - 1 && 'LJ|'.include?(lines[row + 1][col])
    neighbors.push [row, col - 1] if col > 0 && 'FL-'.include?(lines[row][col - 1])
    neighbors.push [row, col + 1] if col < lines.first.length - 1 && '7J-'.include?(lines[row][col + 1])
    raise "Expected exactly 2 paths from starting point, but had #{neighbors.length}" unless neighbors.length == 2
    neighbors.each {|row, col| to_visit.push [row, col, 1]}
    next
  end

  neighbors = if lines[row][col] == 'F'
    raise "Invalid character F at line #{row + 1} column #{col + 1}" if row == lines.length - 1 || col == lines.first.length - 1
    [[row + 1, col], [row, col + 1]]
  elsif lines[row][col] == '7'
    raise "Invalid character 7 at line #{row + 1} column #{col + 1}" if row == lines.length - 1 || col == 0
    [[row + 1, col], [row, col - 1]]
  elsif lines[row][col] == 'J'
    raise "Invalid character J at line #{row + 1} column #{col + 1}" if row == 0 || col == 0
    [[row - 1, col], [row, col - 1]]
  elsif lines[row][col] == 'L'
    raise "Invalid character L at line #{row + 1} column #{col + 1}" if row == 0 || col == lines.first.length - 1
    [[row - 1, col], [row, col + 1]]
  elsif lines[row][col] == '-'
    raise "Invalid character - at line #{row + 1} column #{col + 1}" if col == 0 || col == lines.first.length - 1
    [[row, col - 1], [row, col + 1]]
  elsif lines[row][col] == '|'
    raise "Invalid character | at line #{row + 1} column #{col + 1}" if row == 0 || row == lines.length - 1
    [[row - 1, col], [row + 1, col]]
  else
    raise "Unexpected character #{lines[row][col]} at line #{row + 1} column #{col + 1}"
  end

  visited, unvisited = neighbors.partition {|r, c| distances[r][c]}

  if visited.length == 2
    distances = visited.map {|r, c| distances[r][c]}
    raise 'Distances of neighbors to finish point should be within 1 of each other' unless distances.max - distances.min <= 1
    puts distances.min + 1
    exit 0
  end

  raise "Expected 1 unvisited neighbor of line #{row + 1} column #{col + 1}" unless unvisited.length == 1

  to_visit.push [*unvisited.first, distance + 1]
end
