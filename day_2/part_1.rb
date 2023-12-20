VALID = {
  'red' => 12,
  'green' => 13,
  'blue' => 14,
}

puts File.readlines(ARGV[0]).sum {|line|
  raise 'Failed to parse line' unless match = line.match(/^Game (\d+): (\d+ \w+(, \d+ \w+)*(; \d+ \w+(, \d+ \w+)*)*)$/)
  next 0 if match[2].split('; ').any? do |set|
    set.split(', ').any? do |group|
      quantity, color = group.split ' '
      !VALID.has_key?(color) || quantity.to_i > VALID[color]
    end
  end
  match[1].to_i
}
