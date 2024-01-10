lines = File.readlines ARGV[0], chomp: true

raise 'Expected all lines to have the same length' unless lines.all? {|line| line.length == lines.first.length}

puts lines.first.chars.each_index.sum {|col|
  cube_rocks = [-1] + lines.each_index.select {|row| lines[row][col] == '#'}
  cube_rocks.each_index.sum do |idx|
    if idx == cube_rocks.length - 1
      (cube_rocks[idx] + 1)...lines.length
    else
      (cube_rocks[idx] + 1)...cube_rocks[idx + 1]
    end.select {|row| lines[row][col] == 'O'}.each_index.sum do |offset|
      lines.length - cube_rocks[idx] - 1 - offset
    end
  end
}
