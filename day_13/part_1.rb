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
    if idx < lines.length / 2
      (0..idx).zip(((idx + 1)..(2 * idx + 1)).to_a.reverse)
    else
      ((2 * idx - lines.length + 2)..idx).zip(((idx + 1)..(lines.length - 1)).to_a.reverse)
    end.all? do |idx1, idx2|
      lines[idx1] == lines[idx2]
    end
  end

  vertical_split = lines.first.chars.each_index.first(lines.first.length - 1).find do |idx|
    if idx < lines.first.length / 2
      (0..idx).zip(((idx + 1)..(2 * idx + 1)).to_a.reverse)
    else
      ((2 * idx - lines.first.length + 2)..idx).zip(((idx + 1)..(lines.first.length - 1)).to_a.reverse)
    end.all? do |idx1, idx2|
      lines.all? do |line|
        line[idx1] == line[idx2]
      end
    end
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
