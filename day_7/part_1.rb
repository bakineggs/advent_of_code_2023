CARD_RANK = Hash[['A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2'].each_with_index.to_a]

puts File.readlines(ARGV[0]).map {|line|
  raise "Failed to parse line #{line}" unless match = line.match(/^([#{CARD_RANK.keys.join}]{5}) (\d+)$/)
  groups = match[1].chars.group_by {|c| c}.map {|rank, group| [5 - group.length, CARD_RANK[rank]]}.sort
  [[groups.length, *groups], match[2].to_i]
}.sort.reverse_each.each_with_index.sum {|(_, strength), rank|
  (rank + 1) * strength
}
