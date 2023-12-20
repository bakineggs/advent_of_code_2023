values = {}

puts File.readlines(ARGV[0]).reverse.sum {|line|
  raise "Can't parse line #{line}" unless match = line.match(/^Card +(\d+): +((\d+ +)+)\|(( +\d+)+)$/)
  card = match[1].to_i
  winning = match[2].split(' ') & match[4].split(' ')
  values[card] = 1 + winning.each_index.sum {|offset| values[card + 1 + offset] or raise "Card #{card} won the next #{winning.length} cards, but there is no card #{card + 1 + offset}"}
}
