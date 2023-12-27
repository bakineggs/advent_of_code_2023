MAP_TYPES = ['seed-to-soil', 'soil-to-fertilizer', 'fertilizer-to-water', 'water-to-light', 'light-to-temperature', 'temperature-to-humidity', 'humidity-to-location']

lines = File.readlines ARGV[0], chomp: true

raise 'Failed to parse seed IDs' unless match = lines.shift.match(/^seeds: (\d+( \d+)*)$/)
seeds = match[1].split(' ').map &:to_i

maps = []
MAP_TYPES.each_with_index do |map_type, map_type_idx|
  raise "Expected blank line after #{map_type_idx == 0 ? 'seed IDs' : "#{map_type} map"}" unless lines.shift.empty?
  raise "Expected #{map_type} map after #{map_type_idx == 0 ? 'seed IDs' : "#{MAP_TYPES[map_type_idx - 1]} map"}" unless lines.shift == "#{map_type} map:"

  maps.push []
  until map_type == MAP_TYPES.last ? lines.empty? : lines.first.empty?
    raise "Failed to parse #{map_type} entry" unless match = lines.shift.match(/^(\d+) (\d+) (\d+)$/)
    to_start, from_start, length = match[1..3].map &:to_i
    if idx = maps.last.bsearch_index {|from, _, _| from > from_start}
      raise "Invalid #{map_type} entry [#{from_start}, #{to_start}, #{length}] due to previous entry [#{maps.last[idx - 1][0]}, #{maps.last[idx - 1][1]}, #{maps.last[idx]}]" unless idx % 2 == 0
      maps.last.insert idx, [from_start, to_start], from_start + length - 1
    else
      maps.last.push [from_start, to_start], from_start + length - 1
    end
  end
end

location = nil
seeds.each do |id|
  maps.each do |map|
    idx = map.bsearch_index {|from, to, _| to ? from > id : from >= id}
    next if idx.nil? || idx % 2 == 0
    from_start, to_start = map[idx - 1]
    id += to_start - from_start
  end
  location = id if location.nil? || id < location
end

puts location
