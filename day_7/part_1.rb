CARD_RANK = Hash[['A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2'].each_with_index.to_a]

puts File.readlines(ARGV[0]).map {|line|
  raise "Failed to parse line #{line}" unless match = line.match(/^([#{CARD_RANK.keys.join}]{5}) (\d+)$/)
  cards = match[1].chars.map {|c| CARD_RANK[c]}
  groups = cards.group_by {|c| c}.map {|_, group| 5 - group.length}.sort
  [[groups.length, *groups, *cards], match[2].to_i]
}.sort.reverse_each.each_with_index.sum {|(_, strength), rank|
  (rank + 1) * strength
}
