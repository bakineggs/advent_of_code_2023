require 'set'

plan = File.readlines(ARGV[0]).map do |line|
  raise "Failed to parse line #{line}" unless match = line.match(/^[LRUD] \d* \(#([\da-f]{5})([0-3])\)$/)
  ['RDLU'[match[2].to_i], match[1].to_i(16)]
end

row, col, min_row, max_row, min_col, max_col = 0, 0, 0, 0, 0, 0
plan.each do |dir, steps|
  case dir
  when 'R'
    col += steps
    max_col = col if col > max_col
  when 'L'
    col -= steps
    min_col = col if col < min_col
  when 'D'
    row += steps
    max_row = row if row > max_row
  when 'U'
    row -= steps
    min_row = row if row < min_row
  end
end
raise 'Expected to end up back at the starting point' unless row == 0 &&  col == 0

depth = [[[[0, 0, max_col - min_col]], 0, max_row - min_row]]
row, col = -1 * min_row, -1 * min_col

plan.each do |dir, steps|
  row_idx = (depth.bsearch_index {|_, start_row, _| row < start_row} || depth.length) - 1
  col_idx = (depth[row_idx][0].bsearch_index {|_, start_col, _| col < start_col} || depth[row_idx][0].length) - 1
  case dir

  when 'R'
    if depth[row_idx][1] < row
      depth.insert row_idx, [depth[row_idx][0].map(&:dup), depth[row_idx][1], row - 1]
      depth[row_idx += 1][1] = row
    end
    if depth[row_idx][2] > row
      depth.insert row_idx + 1, [depth[row_idx][0].map(&:dup), row + 1, depth[row_idx][2]]
      depth[row_idx][2] = row
    end

    if depth[row_idx][0][col_idx][0] == 0 && depth[row_idx][0][col_idx][1] < col
      depth[row_idx][0].insert col_idx, [0, depth[row_idx][0][col_idx][1], col - 1]
      depth[row_idx][0][col_idx += 1][1] = col
    end
    if col_idx == depth[row_idx][0].length - 1 && depth[row_idx][0][col_idx][2] > col + steps
      depth[row_idx][0].push [depth[row_idx][0][col_idx][0], col + steps + 1, depth[row_idx][0][col_idx][2]]
    end
    until col_idx == depth[row_idx][0].length - 1 || depth[row_idx][0][col_idx + 1][2] > col + steps
      depth[row_idx][0][col_idx][2] = depth[row_idx][0].delete_at(col_idx + 1)[2]
    end
    unless col_idx == depth[row_idx][0].length - 1
      depth[row_idx][0][col_idx][2] = col + steps
      depth[row_idx][0][col_idx + 1][1] = col + steps + 1
    end

    depth[row_idx][0][col_idx][0] = 1
    depth[row_idx][0][col_idx][2] = depth[row_idx][0].delete_at(col_idx + 1)[2] if col_idx + 1 < depth[row_idx][0].length && depth[row_idx][0][col_idx + 1][0] == 1
    depth[row_idx][0][col_idx - 1][2] = depth[row_idx][0].delete_at(col_idx)[2] if col_idx > 0 && depth[row_idx][0][col_idx - 1][0] == 1
    col += steps

  when 'L'
    if depth[row_idx][1] < row
      depth.insert row_idx, [depth[row_idx][0].map(&:dup), depth[row_idx][1], row - 1]
      depth[row_idx += 1][1] = row
    end
    if depth[row_idx][2] > row
      depth.insert row_idx + 1, [depth[row_idx][0].map(&:dup), row + 1, depth[row_idx][2]]
      depth[row_idx][2] = row
    end

    if depth[row_idx][0][col_idx][0] == 0 && depth[row_idx][0][col_idx][2] > col
      depth[row_idx][0].insert col_idx + 1, [0, col + 1, depth[row_idx][0][col_idx][2]]
      depth[row_idx][0][col_idx][2] = col
    end
    if col_idx == 0 && depth[row_idx][0][col_idx][1] < col - steps
      depth[row_idx][0].unshift [depth[row_idx][0][col_idx][0], depth[row_idx][0][col_idx][1], col - steps - 1]
    end
    until col_idx == 0 || depth[row_idx][0][col_idx - 1][1] < col - steps
      depth[row_idx][0][col_idx][1] = depth[row_idx][0].delete_at(col_idx -= 1)[1]
    end
    unless col_idx == 0
      depth[row_idx][0][col_idx][1] = col - steps
      depth[row_idx][0][col_idx - 1][2] = col - steps - 1
    end

    depth[row_idx][0][col_idx][0] = 1
    depth[row_idx][0][col_idx][2] = depth[row_idx][0].delete_at(col_idx + 1)[2] if col_idx + 1 < depth[row_idx][0].length && depth[row_idx][0][col_idx + 1][0] == 1
    depth[row_idx][0][col_idx - 1][2] = depth[row_idx][0].delete_at(col_idx)[2] if col_idx > 0 && depth[row_idx][0][col_idx - 1][0] == 1
    col -= steps

  when 'D'
    raise NotImplementedError unless depth[row_idx][0][col_idx][0] == 1 && depth[row_idx][1] == row && depth[row_idx][2] == row
    until depth[row_idx][2] == row + steps
      row_idx += 1
      if depth[row_idx][2] > row + steps
        depth.insert row_idx + 1, [depth[row_idx][0].map(&:dup), row + steps + 1, depth[row_idx][2]]
        depth[row_idx][2] = row + steps
      end
      col_idx = (depth[row_idx][0].bsearch_index {|_, start_col, _| col < start_col} || depth[row_idx][0].length) - 1
      if depth[row_idx][0][col_idx][1] < col
        depth[row_idx][0].insert col_idx, [depth[row_idx][0][col_idx][0], depth[row_idx][0][col_idx][1], col - 1]
        depth[row_idx][0][col_idx += 1][1] = col
      end
      if depth[row_idx][0][col_idx][2] > col
        depth[row_idx][0].insert col_idx + 1, [depth[row_idx][0][col_idx][0], col + 1, depth[row_idx][0][col_idx][2]]
        depth[row_idx][0][col_idx][2] = col
      end
      depth[row_idx][0][col_idx][0] = 1
      depth[row_idx][0][col_idx][2] = depth[row_idx][0].delete_at(col_idx + 1)[2] if col_idx + 1 < depth[row_idx][0].length && depth[row_idx][0][col_idx + 1][0] == 1
      depth[row_idx][0][col_idx - 1][2] = depth[row_idx][0].delete_at(col_idx)[2] if col_idx > 0 && depth[row_idx][0][col_idx - 1][0] == 1
    end
    row += steps

  when 'U'
    raise NotImplementedError unless depth[row_idx][0][col_idx][0] == 1 && depth[row_idx][1] == row && depth[row_idx][2] == row
    until depth[row_idx][1] == row - steps
      row_idx -= 1
      if depth[row_idx][1] < row - steps
        depth.insert row_idx, [depth[row_idx][0].map(&:dup), depth[row_idx][1], row - steps - 1]
        depth[row_idx += 1][1] = row - steps
      end
      col_idx = (depth[row_idx][0].bsearch_index {|_, start_col, _| col < start_col} || depth[row_idx][0].length) - 1
      if depth[row_idx][0][col_idx][1] < col
        depth[row_idx][0].insert col_idx, [depth[row_idx][0][col_idx][0], depth[row_idx][0][col_idx][1], col - 1]
        depth[row_idx][0][col_idx += 1][1] = col
      end
      if depth[row_idx][0][col_idx][2] > col
        depth[row_idx][0].insert col_idx + 1, [depth[row_idx][0][col_idx][0], col + 1, depth[row_idx][0][col_idx][2]]
        depth[row_idx][0][col_idx][2] = col
      end
      depth[row_idx][0][col_idx][0] = 1
      depth[row_idx][0][col_idx][2] = depth[row_idx][0].delete_at(col_idx + 1)[2] if col_idx + 1 < depth[row_idx][0].length && depth[row_idx][0][col_idx + 1][0] == 1
      depth[row_idx][0][col_idx - 1][2] = depth[row_idx][0].delete_at(col_idx)[2] if col_idx > 0 && depth[row_idx][0][col_idx - 1][0] == 1
    end
    row -= steps
  end
end

row_idx = depth.find_index {|cols, _, _| cols.length >= 4 && [0, 2].all? {|idx| cols[idx][0] == 0} && [1, 3].all? {|idx| cols[idx][0] == 1 && cols[idx][1] == cols[idx][2]}} or raise NotImplementedError
col = depth[row_idx][0][2][1]
to_explore = [[row_idx, col]].to_set

until to_explore.empty?
  row_idx, col = to_explore.take(1).first
  to_explore.delete [row_idx, col]
  col_idx = (depth[row_idx][0].bsearch_index {|_, start_col, _| col < start_col} || depth[row_idx][0].length) - 1
  next unless depth[row_idx][0][col_idx][0] == 0
  depth[row_idx][0][col_idx][0] = 1
  [[row_idx + 1, col], [row_idx - 1, col]].each {|r, c| to_explore.add [r, c]}
  _, min_col, max_col = depth[row_idx][0][col_idx]
  [row_idx - 1, row_idx + 1].each do |row_idx|
    start_col_idx = (depth[row_idx][0].bsearch_index {|_, start_col, _| min_col < start_col} || depth[row_idx][0].length) - 1
    end_col_idx = (depth[row_idx][0].bsearch_index {|_, start_col, _| max_col < start_col} || depth[row_idx][0].length) - 1
    (start_col_idx...end_col_idx).each do |col_idx|
      to_explore.add [row_idx, depth[row_idx][0][col_idx][2]]
      to_explore.add [row_idx, depth[row_idx][0][col_idx + 1][1]]
    end
  end
end

puts depth.sum {|cols, start_row, end_row|
  cols.sum do |depth, start_col, end_col|
    depth * (end_col - start_col + 1)
  end * (end_row - start_row + 1)
}
