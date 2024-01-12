require 'set'

lines = File.readlines ARGV[0], chomp: true
raise 'Expected all lines to have the same length' unless lines.all? {|line| line.length == lines.first.length}
raise 'Expected each line to only have the characters . / \ | and -' unless lines.all? {|line| line.match /^[.\/\\|-]*$/}

max_row = lines.length - 1
max_col = lines.first.length - 1

puts((lines.each_index.flat_map do |row|
  [[row, 0, :right], [row, max_col, :left]]
end + lines.first.chars.each_index.flat_map do |col|
  [[0, col, :down], [max_row, col, :up]]
end).map do |starting_point|
  energized = lines.map { lines.first.chars.map {false}}

  to_explore = [starting_point]
  explored = Set.new
  until to_explore.empty?
    row, col, dir = to_explore.pop
    next if explored.include? [row, col, dir]
    explored.add [row, col, dir]
    energized[row][col] = true

    char = lines[row][col]
    case dir
    when :right
      to_explore.push [row, col + 1, :right] unless col == max_col if char == '.' || char == '-'
      to_explore.push [row - 1, col, :up] unless row == 0 if char == '/' || char == '|'
      to_explore.push [row + 1, col, :down] unless row == max_row if char == '\\' || char == '|'
    when :left
      to_explore.push [row, col - 1, :left] unless col == 0 if char == '.' || char == '-'
      to_explore.push [row - 1, col, :up] unless row == 0 if char == '\\' || char == '|'
      to_explore.push [row + 1, col, :down] unless row == max_row if char == '/' || char == '|'
    when :down
      to_explore.push [row + 1, col, :down] unless row == max_row if char == '.' || char == '|'
      to_explore.push [row, col - 1, :left] unless col == 0 if char == '/' || char == '-'
      to_explore.push [row, col + 1, :right] unless col == max_col if char == '\\' || char == '-'
    when :up
      to_explore.push [row - 1, col, :up] unless row == 0 if char == '.' || char == '|'
      to_explore.push [row, col - 1, :left] unless col == 0 if char == '\\' || char == '-'
      to_explore.push [row, col + 1, :right] unless col == max_col if char == '/' || char == '-'
    else
      raise
    end
  end

  energized.sum {|row| row.select {|b| b}.length}
end.max)
