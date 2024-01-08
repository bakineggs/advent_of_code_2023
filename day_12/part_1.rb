puts File.readlines(ARGV[0]).sum {|line|
  raise "Failed to parse line #{line}" unless match = line.match(/^\.*([?#][\.?#]+[?#])\.* (\d+(,\d+)*)$/)
  groups = match[1].split /\.+/
  lengths = match[2].split(',').map &:to_i

  while groups.first.match(/^#+$/) || groups.first.match(/^?+$/) && groups.first.length < lengths.first
    raise "Unexpected group length mismatch on line #{line}" unless groups.shift == '#' * lengths.shift while groups.first.match(/^#+$/)
    groups.shift while groups.first.match(/^?+$/) && groups.first.length < lengths.first
  end
  while groups.last.match(/^#+$/) || groups.last.match(/^?+$/) && groups.last.length < lengths.last
    raise "Unexpected group length mismatch on line #{line}" unless groups.pop == '#' * lengths.pop while groups.last.match(/^#+$/)
    groups.pop while groups.last.match(/^?+$/) && groups.last.length < lengths.last
  end

  groups.each_with_index.flat_map do |group, group_idx|
    group.chars.each_with_index.select do |char, _|
      char == '?'
    end.map do |_, char_idx|
      [group_idx, char_idx]
    end
  end.combination(lengths.sum - groups.sum {|group| group.count '#'}).sum do |assumptions|
    assigned = groups.map &:dup
    assumptions.each do |group_idx, char_idx|
      assigned[group_idx][char_idx] = '#'
    end
    if assigned.flat_map do |group|
      group.sub(/^\?*/, '').sub(/\?*$/, '').split /\?+/
    end.map(&:length) == lengths
      1
    else
      0
    end
  end
}
