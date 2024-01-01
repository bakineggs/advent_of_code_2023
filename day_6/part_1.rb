lines = File.readlines ARGV[0]
raise 'Expected 2 lines in the input file' unless lines.length == 2

raise 'Expected times on the first line' unless match = lines.shift.match(/^Time:(( +\d+)+)$/)
times = match[1].split(' ').map &:to_i

raise 'Expected distances on the second line' unless match = lines.shift.match(/^Distance:(( +\d+)+)$/)
distances = match[1].split(' ').map &:to_i

raise 'Expected same number of times and distances' unless times.length == distances.length

puts times.zip(distances).inject(1) {|product, (time, distance)|
  wait_time = (1..(time / 2)).bsearch do |wait|
    wait * (time - wait) > distance
  end
  product * (time - 2 * wait_time + 1)
}
