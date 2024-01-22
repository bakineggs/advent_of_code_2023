require 'set'

lines = File.readlines ARGV[0], chomp: true

raise 'Expected all lines to have the same length' unless lines.all? {|line| line.length == lines.first.length}
raise 'Expected all lines to only contain . # and S' unless lines.all? {|line| line.match /^[.#S]+$/}
raise 'Expected exactly one S in the input' unless lines.sum {|line| line.count 'S'} == 1

STEPS = ARGV[1].to_i

rows, cols = lines.length, lines.first.length
raise NotImplementedError unless rows % 2 == 1 && cols % 2 == 1

start_row = lines.find_index {|line| line.include? 'S'}
start_col = lines[start_row].index 'S'

steps_from_start = {}

to_explore = [[start_row, start_col, 0]]
explored = Set.new
until to_explore.empty?
  row, col, steps = to_explore.shift
  next if explored.include? [row, col]
  explored.add [row, col]
  steps_from_start[[row, col]] = steps
  [[row - 1, col], [row + 1, col], [row, col - 1], [row, col + 1]].each do |row, col|
    next if row < -3 * rows || row >= rows * 4 || col < -3 * cols || col >= cols * 4
    next if lines[row % rows][col % cols] == '#'
    to_explore.push [row, col, steps + 1]
  end
end

(0...rows).each do |row|
  (0...cols).each do |col|
    [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]].each do |r, c|
      next if lines[row][col] == '#'
      next unless steps_from_start.has_key? [row, col]
      raise NotImplementedError unless steps_from_start[[row + r * 3 * rows, col + c * 3 * cols]] - steps_from_start[[row + r * 2 * rows, col + c * 2 * cols]] == steps_from_start[[row + r * 2 * rows, col + c * 2 * cols]] - steps_from_start[[row + r * rows, col + c * cols]]
    end
  end
end

puts (0...rows).sum {|row|
  (0...cols).sum do |col|
    next 0 if lines[row][col] == '#'
    next 0 unless steps_from_start.has_key? [row, col]
    count = 0
    count += 1 if steps_from_start[[row, col]] <= STEPS && steps_from_start[[row, col]] % 2 == STEPS % 2

    [[-1, -1], [-1, 1], [1, -1], [1, 1]].each do |r, c|
      steps1 = steps_from_start[[row + r * rows, col + c * cols]]
      steps2 = steps_from_start[[row + r * 2 * rows, col + c * 2 * cols]]

      hops = (STEPS - steps1) / (steps2 - steps1) + 1
      if (steps2 - steps1) % 2 == 0
        count += hops if steps1 % 2 == STEPS % 2
      else
        count += hops / 2 + (hops % 2 == 1 && steps1 % 2 == STEPS % 2 ? 1 : 0)
      end

      [[r, 0], [0, c]].each do |r2, c2|
        steps3 = steps_from_start[[row + (r + r2) * rows, col + (c + c2) * cols]]
        raise NotImplementedError if (steps3 - steps1) % 2 == 0

        hops_first = (STEPS - steps1) / (steps3 - steps1)
        count_first = hops_first / 2 + (hops_first % 2 == 1 && (steps1 + steps3 - steps1) % 2 == STEPS % 2 ? 1 : 0)
        hops_last = (STEPS - steps1 - (steps2 - steps1) * (hops - 1)) / (steps3 - steps1)
        count_last = hops_last / 2 + (hops_last % 2 == 1 && (steps1 + (steps2 - steps1) * (hops - 1) + steps3 - steps1) % 2 == STEPS % 2 ? 1 : 0)
        add_to_count = hops * (count_first + count_last) / 2.0
        raise unless add_to_count.to_i == add_to_count
        count += add_to_count.to_i
      end
    end
    [[-1, 0], [1, 0], [0, -1], [0, 1]].each do |r, c|
      steps1 = steps_from_start[[row + r * rows, col + c * cols]]
      steps2 = steps_from_start[[row + r * 2 * rows, col + c * 2 * cols]]
      hops = (STEPS - steps1) / (steps2 - steps1) + 1
      count += hops / 2 + (hops % 2 == 1 && steps1 % 2 == STEPS % 2 ? 1 : 0)
    end
    count
  end
}
