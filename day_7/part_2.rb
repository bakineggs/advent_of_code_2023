CARD_RANK = Hash[['A', 'K', 'Q', 'T', '9', '8', '7', '6', '5', '4', '3', '2', 'J'].each_with_index.to_a]

puts File.readlines(ARGV[0]).map {|line|
  raise "Failed to parse line #{line}" unless match = line.match(/^([#{CARD_RANK.keys.join}]{5}) (\d+)$/)
  cards = match[1].chars.map {|c| CARD_RANK[c]}
  groups = cards.group_by {|c| c}.map {|rank, group| [5 - group.length, rank]}.sort
  if groups.length > 1 && wild = groups.find {|_, rank| rank == CARD_RANK['J']}
    groups.delete wild
    groups.first[0] -= 5 - wild[0]
  end
  [[groups.length, *groups.map(&:first), *cards], match[2].to_i]
}.sort.reverse_each.each_with_index.sum {|(_, strength), rank|
  (rank + 1) * strength
}
