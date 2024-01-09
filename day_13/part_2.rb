patterns = [[]]
File.readlines(ARGV[0], chomp: true).each do |line|
  if line.empty?
    patterns.push []
  else
    patterns.last.push line
  end
end

puts patterns.sum {|lines|
  raise 'Expected all lines in a pattern to have the same length' unless lines.all? {|line| line.length == lines.first.length}

  horizontal_split = lines.each_index.first(lines.length - 1).find do |idx|
    smudged = false
    if idx < lines.length / 2
      (0..idx).zip(((idx + 1)..(2 * idx + 1)).to_a.reverse)
    else
      ((2 * idx - lines.length + 2)..idx).zip(((idx + 1)..(lines.length - 1)).to_a.reverse)
    end.all? do |idx1, idx2|
      next true if lines[idx1] == lines[idx2]
      next false if smudged
      next false unless lines.first.chars.each_index.select {|char_idx| lines[idx1][char_idx] != lines[idx2][char_idx]}.length == 1
      smudged = true
    end && smudged
  end

  vertical_split = lines.first.chars.each_index.first(lines.first.length - 1).find do |idx|
    smudged = false
    if idx < lines.first.length / 2
      (0..idx).zip(((idx + 1)..(2 * idx + 1)).to_a.reverse)
    else
      ((2 * idx - lines.first.length + 2)..idx).zip(((idx + 1)..(lines.first.length - 1)).to_a.reverse)
    end.all? do |idx1, idx2|
      next true if lines.all? {|line| line[idx1] == line[idx2]}
      next false if smudged
      next false unless lines.each_index.select {|line_idx| lines[line_idx][idx1] != lines[line_idx][idx2]}.length == 1
      smudged = true
    end && smudged
  end

  if horizontal_split && vertical_split
    raise 'Expected to have either a horizontal split or a vertical split, but not both'
  elsif horizontal_split
    100 * (horizontal_split + 1)
  elsif vertical_split
    vertical_split + 1
  else
    raise 'Expected each pattern to have a horizontal split or a vertical split'
  end
}
