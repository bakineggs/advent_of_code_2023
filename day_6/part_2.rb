lines = File.readlines ARGV[0]
raise 'Expected 2 lines in the input file' unless lines.length == 2

raise 'Expected time on the first line' unless match = lines.shift.match(/^Time:(( +\d+)+)$/)
time = match[1].split(' ').join.to_i

raise 'Expected distance on the second line' unless match = lines.shift.match(/^Distance:(( +\d+)+)$/)
distance = match[1].split(' ').join.to_i

wait_time = (1..(time / 2)).bsearch do |wait|
  wait * (time - wait) > distance
end
puts time - 2 * wait_time + 1
