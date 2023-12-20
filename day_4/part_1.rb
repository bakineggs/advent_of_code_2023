puts File.readlines(ARGV[0]).sum {|line|
  raise "Can't parse line #{line}" unless match = line.match(/^Card +\d+: +((\d+ +)+)\|(( +\d+)+)$/)
  winning = match[1].split(' ') & match[3].split(' ')
  winning.empty? ? 0 : 2 ** (winning.length - 1)
}
