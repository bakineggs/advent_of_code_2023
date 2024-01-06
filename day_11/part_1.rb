lines = File.readlines ARGV[0], chomp: true

raise 'Expected all lines to be the same length' unless lines.all? {|line| line.length == lines.first.length}
raise 'Unrecognized character' unless lines.all? {|line| line.match /^[.#]+$/}

double_rows = lines.each_with_index.select {|line, idx| line.match /^\.+$/}.map &:last
double_cols = lines.first.chars.each_index.select {|idx| lines.all? {|line| line[idx] == '.'}}

galaxies = lines.each_with_index.flat_map do |line, row|
  line.chars.each_with_index.select do |char, col|
    char == '#'
  end.map do |_, col|
    [row, col]
  end
end

puts galaxies.each_with_index.sum {|(row1, col1), idx|
  galaxies[0...idx].sum do |row2, col2|
    min_row, max_row, min_col, max_col = [row1, row2].min, [row1, row2].max, [col1, col2].min, [col1, col2].max
    max_row - min_row + max_col - min_col + double_rows.select {|row| row > min_row && row < max_row}.length + double_cols.select {|col| col > min_col && col < max_col}.length
  end
}
