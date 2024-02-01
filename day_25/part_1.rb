require 'set'

connected = {}

File.readlines(ARGV[0]).each do |line|
  raise "Failed to parse line #{line}" unless match = line.match(/^(\w+): (\w+( \w+)*)$/)
  connected[match[1]] ||= Set.new
  match[2].split(' ').each do |name|
    connected[match[1]].add name
    (connected[name] ||= Set.new).add match[1]
  end
end

cut = []

connected.each do |source, neighbors|
  neighbors.each do |destination|
    next unless source < destination

    paths = [[[source, destination].sort].to_set].to_set
    used = [[source, destination].sort].to_set
    explore_forward = [[source, 0, Set.new]]
    explore_backward = [[destination, 0, Set.new]]

    2.times do
      reachable, steps, reach_from = Set.new, nil, [[source, 0]]
      until reach_from.empty?
        reaching_from, step = reach_from.shift
        next if reachable.include? reaching_from
        reachable.add reaching_from
        steps = step and break if reaching_from == destination
        connected[reaching_from].each do |reaching_to|
          next if reachable.include? reaching_to
          next if used.include? [reaching_from, reaching_to].sort
          reach_from.push [reaching_to, step + 1]
        end
      end

      raise NotImplementedError if steps.nil?
      steps_forward, steps_backward = (steps / 2.0).ceil, (steps / 2.0).floor

      [[explore_forward, steps_forward], [explore_backward, steps_backward]].each do |explore, steps|
        until explore.empty? || explore.first[1] == steps
          current, step, path = explore.shift
          next if path.intersect? used
          connected[current].each do |adjacent|
            next if path.any? {|edge| edge.include? adjacent}
            edge = [current, adjacent].sort
            next if used.include? edge
            explore.push [adjacent, step + 1, path + [edge]]
          end
        end
      end

      break unless explore_forward.any? do |head, _, head_path|
        explore_backward.any? do |tail, _, tail_path|
          next false unless head == tail
          paths.add path = head_path + tail_path
          used.merge path
          next true if paths.length == 3
          explore_forward.reject! {|_, _, path| path.intersect? head_path}
          explore_backward.reject! {|_, _, path| path.intersect? tail_path}
          true
        end
      end
    end

    next unless paths.length == 3

    reachable = Set.new
    explore = [source]
    until explore.empty?
      current = explore.pop
      next if reachable.include? current
      reachable.add current
      break if current == destination
      connected[current].each do |adjacent|
        next if reachable.include? adjacent
        next if used.include? [current, adjacent].sort
        explore.push adjacent
      end
    end
    next if reachable.include? destination

    cut.push [source, destination, paths]
  end
end

raise NotImplementedError unless cut.length == 3

cut.each do |name0, name1|
  connected[name0].delete name1
  connected[name1].delete name0
end

reachable = Set.new
explore = [connected.keys.first]
until explore.empty?
  current = explore.pop
  next if reachable.include? current
  reachable.add current
  connected[current].each do |adjacent|
    explore.push adjacent unless reachable.include? adjacent
  end
end

puts reachable.length * (connected.length - reachable.length)
