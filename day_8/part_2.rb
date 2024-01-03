lines = File.readlines ARGV[0], chomp: true

raise 'Expected first line to only contain the characters L and R' unless lines.first.match /^[LR]+$/

instructions = lines.shift.chars.map {|c| c == 'L' ? 0 : 1}

raise 'Expected second line in between instructions and edges to be blank' unless lines.shift.empty?

edges = Hash[lines.map do |line|
  raise "Failed to parse line #{line}" unless match = line.match(/^([A-Z0-9]{3}) = \(([A-Z0-9]{3}), ([A-Z0-9]{3})\)$/)
  [match[1], [match[2], match[3]]]
end]

count = 0
current = edges.keys.select {|node| node[-1] == 'A'}

until current.all? {|node| node[-1] == 'Z'}
  instructions.each do |instruction|
    current.map! do |node|
      raise "No edge starting from #{node}" unless edges.has_key? node
      edges[node][instruction]
    end
    count += 1
    break if current.all? {|node| node[-1] == 'Z'}
  end
end

puts count
