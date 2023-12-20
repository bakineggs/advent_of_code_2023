puts File.readlines(ARGV[0]).sum {|line|
  raise 'Failed to parse line' unless match = line.match(/^Game \d+: (\d+ \w+(, \d+ \w+)*(; \d+ \w+(, \d+ \w+)*)*)$/)
  minimums = {}

  match[1].split('; ').each do |set|
    set.split(', ').each do |group|
      quantity, color = group.split ' '
      quantity = quantity.to_i
      minimums[color] = quantity if !minimums.has_key?(color) || quantity > minimums[color]
    end
  end

  minimums.values.inject(1) {|product, quantity| product * quantity}
}
