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
terminal = current.map {[]}
cycles = current.map {nil}
visits = instructions.map {{}}

until current.all? {|node| node[-1] == 'Z'} || cycles.all?
  instructions.each_with_index do |instruction, instruction_idx|
    count += 1
    current.map! do |node|
      raise "No edge starting from #{node}" unless edges.has_key? node
      edges[node][instruction]
    end
    current.each_with_index do |node, current_idx|
      terminal[current_idx].push count if node[-1] == 'Z'
      next if cycles[current_idx]
      if visits[instruction_idx][node]
        cycles[current_idx] = [visits[instruction_idx][node], count]
      else
        visits[instruction_idx][node] = count
      end
    end
    break if current.all? {|node| node[-1] == 'Z'} || cycles.all?
  end
end

if current.all? {|node| node[-1] == 'Z'}
  puts count
  exit 0
end

raise NotImplementedError unless terminal.all? {|counts| counts.length == 1}
terminal.map! &:first

raise NotImplementedError unless cycles.each_with_index.all? {|(start, finish), idx| terminal[idx] == finish - start}

require 'prime'
require 'set'

puts terminal.inject(Set.new) {|factors, count|
  factors_counts = Prime.prime_division count
  raise NotImplementedError unless factors_counts.all? {|_, count| count == 1}
  factors + factors_counts.map(&:first)
}.inject(1) {|product, factor|
  product * factor
}
