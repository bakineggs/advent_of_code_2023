lines = File.readlines ARGV[0], chomp: true

workflows = {}
until (line = lines.shift).empty?
  raise "Failed to parse line #{line}" unless match = line.match(/^(\w+){(([xmas][<>]\d+:\w+,)+\w+)}$/)
  workflows[match[1]] = match[2].split(',').map do |rule|
    if rule.include? ':'
      _, var, comp, value, result = *rule.match(/^([xmas])([<>])(\d+):(\w+)$/)
      [var, comp, value.to_i, result]
    else
      rule
    end
  end
end

raise 'Expected a starting workflow named "in"' unless workflows.has_key? 'in'

def deep_clone array
  return array unless array.is_a? Array
  array.map {|el| deep_clone el}
end

def accept space, *range
  min, max = range.shift, range.shift
  min_idx = space.bsearch_index {|_, m, _| min <= m}
  max_idx = (space.bsearch_index {|m, _, _| max < m} || space.length) - 1

  if space[min_idx][0] < min
    space.insert min_idx, [space[min_idx][0], min - 1, deep_clone(space[min_idx][2])]
    space[min_idx += 1][0] = min
    max_idx += 1
  end

  if space[max_idx][1] > max
    space.insert max_idx + 1, [max + 1, space[max_idx][1], deep_clone(space[max_idx][2])]
    space[max_idx][1] = max
  end

  (min_idx..max_idx).each do |idx|
    if range.empty?
      raise unless space[idx][2] == 'A' || space[idx][2] == 'R'
      space[idx][2] = 'A'
    else
      accept space[idx][2], *range
    end
  end
end

def explore workflow, rule, range, var, min, max
  range = range.dup
  range[var] = [min, max]
  [workflow, rule, range]
end

space = [[1, 4000, [[1, 4000, [[1, 4000, [[1, 4000, 'R']]]]]]]]
to_explore = [['in', 0, {'x' => [1, 4000], 'm' => [1, 4000], 'a' => [1, 4000], 's' => [1, 4000]}]]

until to_explore.empty?
  workflow, rule, range = to_explore.shift

  accept space, *range['x'], *range['m'], *range['a'], *range['s'] if workflow == 'A'
  next if workflow == 'A' || workflow == 'R'

  raise "Uknown workflow #{workflow}" unless workflows.has_key? workflow
  raise "Workflow #{workflow} does not have a rule #{rule}" unless rule < workflows[workflow].length

  if workflows[workflow][rule].is_a? String
    to_explore.push [workflows[workflow][rule], 0, range]
    next
  end

  var, comp, value, result = workflows[workflow][rule]
  if comp == '<'
    to_explore.push explore result, 0, range, var, range[var][0], [range[var][1], value - 1].min if range[var][0] < value
    to_explore.push explore workflow, rule + 1, range, var, [range[var][0], value].max, range[var][1] if range[var][1] >= value
  elsif comp == '>'
    to_explore.push explore result, 0, range, var, [range[var][0], value + 1].max, range[var][1] if range[var][1] > value
    to_explore.push explore workflow, rule + 1, range, var, range[var][0], [range[var][1], value].min if range[var][0] <= value
  else
    raise NotImplementedError
  end
end

def accepted space
  return 1 if space == 'A'
  return 0 if space == 'R'
  space.sum do |min, max, subspace|
    (max - min + 1) * accepted(subspace)
  end
end

puts accepted space
