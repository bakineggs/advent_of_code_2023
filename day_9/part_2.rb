puts File.readlines(ARGV[0]).sum {|line|
  raise "Expected list of integers: #{line}" unless line.match /^-?\d+( +-?\d+)+$/
  diffs = [line.split(' ').map(&:to_i)]
  until diffs.last.all? {|d| d == diffs.last.first}
    diffs.push diffs.last.first(diffs.last.length - 1).each_with_index.map {|d, idx| diffs.last[idx + 1] - d}
  end
  diffs.each_with_index.reverse_each do |diff, idx|
    if idx == diffs.length - 1
      diff.unshift diff.first
    else
      diff.unshift diff.first - diffs[idx + 1].first
    end
  end
  diffs.first.first
}
