lines = File.readlines ARGV[0], chomp: true

workflows = {}
until (line = lines.shift).empty?
  raise "Failed to parse line #{line}" unless match = line.match(/^(\w+){(([xmas][<>]\d+:\w+,)+\w+)}$/)
  workflows[match[1]] = match[2].split(',').map do |rule|
    if rule.include? ':'
      condition, result = rule.split ':'
      lambda {|x,m,a,s| result if eval condition}
    else
      lambda {|x,m,a,s| rule}
    end
  end
end

raise 'Expected a starting workflow named "in"' unless workflows.has_key? 'in'

puts lines.sum {|line|
  raise "Failed to parse line #{line}" unless match = line.match(/^{x=(\d+),m=(\d+),a=(\d+),s=(\d+)}$/)
  x,m,a,s = match[1..4].map &:to_i
  result, workflow = nil, workflows['in']

  until result == 'A' || result == 'R'
    workflow.each do |rule|
      next unless result = rule[x,m,a,s]
      break if result == 'A' || result == 'R'
      raise "Could not find a workflow named \"#{result}\"" unless workflows.has_key? result
      workflow = workflows[result]
      break
    end
  end

  if result == 'A'
    x+m+a+s
  elsif result == 'R'
    0
  else
    raise 'Expected result to be A or R'
  end
}
