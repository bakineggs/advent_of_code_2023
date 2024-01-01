lines = File.readlines ARGV[0], chomp: true

raise 'Expected first line to only contain the characters L and R' unless lines.first.match /^[LR]+$/

instructions = lines.shift.chars.map {|c| c == 'L' ? 0 : 1}

raise 'Expected second line in between instructions and edges to be blank' unless lines.shift.empty?

edges = Hash[lines.map do |line|
  raise "Failed to parse line #{line}" unless match = line.match(/^([A-Z]{3}) = \(([A-Z]{3}), ([A-Z]{3})\)$/)
  [match[1], [match[2], match[3]]]
end]

count = 0
current = 'AAA'

until current == 'ZZZ'
  instructions.each do |instruction|
    break if current == 'ZZZ'
    raise "No edge starting from #{current}" unless edges.has_key? current
    current = edges[current][instruction]
    count += 1
  end
end

puts count
