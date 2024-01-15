lines = File.readlines ARGV[0], chomp: true
raise 'Expected all lines to have the same length' unless lines.all? {|line| line.length == lines.first.length}
raise 'Expected each line to only have numbers' unless lines.all? {|line| line.match /^\d+$/}

heat_loss = lines.map {|line| line.chars.map &:to_i}
max_row = heat_loss.length - 1
max_col = heat_loss.first.length - 1

def explore to_explore, row, col, dir, steps, cost, min_cost
  idx = to_explore.bsearch_index {|_, _, _, _, _, m| m > min_cost} || to_explore.length
  to_explore.insert idx, [row, col, dir, steps, cost, min_cost]
end

best = (max_row + max_col) * 9
to_explore = [[0, 1, :right, 0, 0, 0], [1, 0, :down, 0, 0, 0]]
explored  = heat_loss.map { heat_loss.first.map { [nil, {}, {}, {}]  }}
until to_explore.empty? || best < to_explore.first[5]
  row, col, dir, steps, cost, _ = to_explore.shift
  steps += 1
  cost += heat_loss[row][col]
  min_cost = cost + max_row - row + max_col - col

  next if explored[row][col][steps][dir] && explored[row][col][steps][dir] <= cost
  explored[row][col][steps][dir] = cost

  if row == max_row && col == max_col
    best = cost if cost < best
    if idx = to_explore.bsearch_index {|_, _, _, _, _, m| m > best}
      to_explore = to_explore[0...idx]
    end
    next
  end

  case dir
  when :right
    explore to_explore, row, col + 1, :right, steps, cost, min_cost unless col == max_col || steps == 3
    explore to_explore, row - 1, col, :up, 0, cost, min_cost unless row == 0
    explore to_explore, row + 1, col, :down, 0, cost, min_cost unless row == max_row
  when :left
    explore to_explore, row, col - 1, :left, steps, cost, min_cost unless col == 0 || steps == 3
    explore to_explore, row - 1, col, :up, 0, cost, min_cost unless row == 0
    explore to_explore, row + 1, col, :down, 0, cost, min_cost unless row == max_row
  when :down
    explore to_explore, row + 1, col, :down, steps, cost, min_cost unless row == max_row || steps == 3
    explore to_explore, row, col - 1, :left, 0, cost, min_cost unless col == 0
    explore to_explore, row, col + 1, :right, 0, cost, min_cost unless col == max_col
  when :up
    explore to_explore, row - 1, col, :up, steps, cost, min_cost unless row == 0 || steps == 3
    explore to_explore, row, col - 1, :left, 0, cost, min_cost unless col == 0
    explore to_explore, row, col + 1, :right, 0, cost, min_cost unless col == max_col
  end
end

puts best
