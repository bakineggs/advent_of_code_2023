lines = File.readlines ARGV[0], chomp: true

raise 'Expected all lines to have the same length' unless lines.all? {|line| line.length == lines.first.length}

cube_rocks_by_row = Hash[lines.each_with_index.map do |line, row|
  [row, line.chars.each_index.select {|col| line[col] == '#'}]
end]

cube_rocks_by_col = Hash[lines.first.chars.each_index.map do |col|
  [col, lines.each_index.select {|row| lines[row][col] == '#'}]
end]

round_rocks = lines.map {|line| line.chars.map {|char| char == 'O'}}
round_rocks_history = []

1000000000.times do |iterations|
  if cycle = round_rocks_history.find_index {|entry| round_rocks == entry}
    round_rocks = round_rocks_history[cycle + (1000000000 - cycle) % (iterations - cycle)]
    break
  end
  round_rocks_history.push round_rocks.map &:dup

  lines.first.chars.each_index do |col|
    cube_rows = cube_rocks_by_col[col]
    ([-1] + cube_rows).each_with_index do |cube_row, idx|
      round_rows = if idx == cube_rows.length
        (cube_row + 1)...lines.length
      else
        (cube_row + 1)...cube_rows[idx]
      end.select {|row| round_rocks[row][col]}
      round_rows.each {|row| raise if lines[row][col] == '#' ; round_rocks[row][col] = false}
      ((cube_row + 1)...(cube_row + 1 + round_rows.length)).each {|row| raise if lines[row][col] == '#' ; round_rocks[row][col] = true}
    end
  end

  lines.each_index do |row|
    cube_cols = cube_rocks_by_row[row]
    ([-1] + cube_cols).each_with_index do |cube_col, idx|
      round_cols = if idx == cube_cols.length
        (cube_col + 1)...lines.first.length
      else
        (cube_col + 1)...cube_cols[idx]
      end.select {|col| round_rocks[row][col]}
      round_cols.each {|col| raise if lines[row][col] == '#' ; round_rocks[row][col] = false}
      ((cube_col + 1)...(cube_col + 1 + round_cols.length)).each {|col| raise if lines[row][col] == '#' ; round_rocks[row][col] = true}
    end
  end

  lines.first.chars.each_index do |col|
    cube_rows = cube_rocks_by_col[col].reverse
    ([lines.length] + cube_rows).each_with_index do |cube_row, idx|
      round_rows = if idx == cube_rows.length
        0...cube_row
      else
        (cube_rows[idx] + 1)...cube_row
      end.select {|row| round_rocks[row][col]}
      round_rows.each {|row| raise if lines[row][col] == '#' ; round_rocks[row][col] = false}
      ((cube_row - round_rows.length)...cube_row).each {|row| raise if lines[row][col] == '#' ; round_rocks[row][col] = true}
    end
  end

  lines.each_index do |row|
    cube_cols = cube_rocks_by_row[row].reverse
    ([lines.first.length] + cube_cols).each_with_index do |cube_col, idx|
      round_cols = if idx == cube_cols.length
        0...cube_col
      else
        (cube_cols[idx] + 1)...cube_col
      end.select {|col| round_rocks[row][col]}
      round_cols.each {|col| raise if lines[row][col] == '#' ; round_rocks[row][col] = false}
      ((cube_col - round_cols.length)...cube_col).each {|col| raise if lines[row][col] == '#' ; round_rocks[row][col] = true}
    end
  end
end

puts round_rocks.each_with_index.sum {|bools, row|
  (lines.length - row) * bools.count {|b| b}
}
