lines = File.readlines ARGV[0], chomp: true

raise 'Expected all lines to be the same length' unless lines.all? {|line| line.length == lines.first.length}
raise 'Unrecognized character' unless lines.all? {|line| line.match /^[.F7JL\-\|S]+$/}

start_line = lines.find_all {|line| line.include? 'S'}
raise 'Expected exactly one starting point' unless start_line.length == 1 && start_line.first.match(/^[^S]*S[^S]*$/)

start_line = start_line.first
to_visit = [[lines.index(start_line), start_line.index('S'), true]]

in_loop = lines.map {lines.first.length.times.map {false}}

loop do
  row, col, starting_point = to_visit.shift
  in_loop[row][col] = true

  if starting_point
    neighbors = []
    neighbors.push [row - 1, col] if row > 0 && 'F7|'.include?(lines[row - 1][col])
    neighbors.push [row + 1, col] if row < lines.length - 1 && 'LJ|'.include?(lines[row + 1][col])
    neighbors.push [row, col - 1] if col > 0 && 'FL-'.include?(lines[row][col - 1])
    neighbors.push [row, col + 1] if col < lines.first.length - 1 && '7J-'.include?(lines[row][col + 1])
    raise "Expected exactly 2 paths from starting point, but had #{neighbors.length}" unless neighbors.length == 2
    neighbors.each {|row, col| to_visit.push [row, col]}
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

  visited, unvisited = neighbors.partition {|r, c| in_loop[r][c]}

  break if visited.length == 2

  raise "Expected 1 unvisited neighbor of line #{row + 1} column #{col + 1}" unless unvisited.length == 1

  to_visit.push unvisited.first
end

row = in_loop.bsearch_index &:any?
col = in_loop[row].bsearch_index {|d| d}
raise "Expected F at line #{row} column #{col}" unless lines[row][col] == 'F'
raise "Expected 7, J, or - at line #{row} column #{col + 1}" unless '7J-'.include? lines[row][col + 1]

require 'set'
visited = [[row, col]].to_set
to_visit = [[row, col + 1]]
dir = :R
count = 0

until to_visit.empty?
  row, col = to_visit.pop
  next if visited.include? [row, col]
  visited.add [row, col]

  if in_loop[row][col]
    if lines[row][col] == 'S'
      if dir == :U
        if col != 0 && in_loop[row][col - 1]
          lines[row][col] = '7'
        elsif row != 0 && in_loop[row - 1][col]
          lines[row][col] = '|'
        elsif col != lines.first.length - 1 && in_loop[row][col + 1]
          lines[row][col] = 'F'
        else
          raise
        end
      elsif dir == :D
        if col != 0 && in_loop[row][col - 1]
          lines[row][col] = 'J'
        elsif row != lines.length - 1 && in_loop[row + 1][col]
          lines[row][col] = '|'
        elsif col != lines.first.length - 1 && in_loop[row][col + 1]
          lines[row][col] = 'L'
        else
          raise
        end
      elsif dir == :L
        if row != 0 && in_loop[row - 1][col]
          lines[row][col] = 'L'
        elsif col != 0 && in_loop[row][col - 1]
          lines[row][col] = '-'
        elsif row != lines.length - 1 && in_loop[row + 1][col]
          lines[row][col] = 'F'
        else
          raise
        end
      elsif dir == :R
        if row != 0 && in_loop[row - 1][col]
          lines[row][col] = 'J'
        elsif col != lines.last.length - 1 && in_loop[row][col + 1]
          lines[row][col] = '-'
        elsif row != lines.length - 1 && in_loop[row + 1][col]
          lines[row][col] = '7'
        else
          raise
        end
      else
        raise
      end
    end

    if lines[row][col] == 'F'
      if dir == :U
        dir = :R
        to_visit.push [row, col + 1]
      elsif dir == :L
        dir = :D
        to_visit.push [row - 1, col] unless row == 0
        to_visit.push [row - 1, col - 1] unless row == 0 || col == 0
        to_visit.push [row, col - 1] unless col == 0
        to_visit.push [row + 1, col]
      else
        raise
      end
    elsif lines[row][col] == '7'
      if dir == :U
        dir = :L
        to_visit.push [row, col + 1] unless col == lines.first.length - 1
        to_visit.push [row - 1, col + 1] unless row == 0 || col == lines.first.length - 1
        to_visit.push [row - 1, col] unless row == 0
        to_visit.push [row, col - 1]
      elsif dir == :R
        dir = :D
        to_visit.push [row + 1, col]
      else
        raise
      end
    elsif lines[row][col] == 'J'
      if dir == :D
        dir = :L
        to_visit.push [row, col - 1]
      elsif dir == :R
        dir = :U
        to_visit.push [row + 1, col] unless row == lines.length - 1
        to_visit.push [row + 1, col + 1] unless row == lines.length - 1 || col == lines.first.length - 1
        to_visit.push [row, col + 1] unless col == lines.first.length - 1
        to_visit.push [row - 1, col]
      else
        raise
      end
    elsif lines[row][col] == 'L'
      if dir == :D
        dir = :R
        to_visit.push [row, col - 1] unless col == 0
        to_visit.push [row + 1, col - 1] unless row == lines.length - 1 || col == 0
        to_visit.push [row + 1, col] unless row == lines.length - 1
        to_visit.push [row, col + 1]
      elsif dir == :L
        dir = :U
        to_visit.push [row - 1, col]
      else
        raise
      end
    elsif lines[row][col] == '-'
      if dir == :L
        to_visit.push [row - 1, col] unless row == 0
        to_visit.push [row, col - 1]
      elsif dir == :R
        to_visit.push [row + 1, col] unless row == lines.length - 1
        to_visit.push [row, col + 1]
      else
        raise
      end
    elsif lines[row][col] == '|'
      if dir == :U
        to_visit.push [row, col + 1] unless col == lines.first.length - 1
        to_visit.push [row - 1, col]
      elsif dir == :D
        to_visit.push [row, col - 1] unless col == 0
        to_visit.push [row + 1, col]
      else
        raise
      end
    else
      raise "Unexpected character #{lines[row][col]} at line #{row} column #{col}"
    end
  else
    count += 1
    [[row - 1, col - 1], [row - 1, col], [row - 1, col + 1], [row, col - 1], [row, col + 1], [row + 1, col - 1], [row + 1, col], [row + 1, col + 1]].each do |row, col|
      to_visit.push [row, col] unless in_loop[row][col] || visited.include?([row, col])
    end
  end
end

puts count
