MAP_TYPES = ['seed-to-soil', 'soil-to-fertilizer', 'fertilizer-to-water', 'water-to-light', 'light-to-temperature', 'temperature-to-humidity', 'humidity-to-location']

lines = File.readlines ARGV[0], chomp: true

raise 'Failed to parse seed IDs' unless match = lines.shift.match(/^seeds: (\d+( \d+)*)$/)
seeds = match[1].split(' ').map &:to_i
raise 'Expected pairs of seed IDs and lengths' unless seeds.length % 2 == 0

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
to_visit = seeds.each_slice(2).map {|id, length| [0, id, id + length - 1]}
until to_visit.empty?
  map_idx, from_start, from_end = to_visit.pop
  raise "Can't visit #{map_idx}, #{from_start}, #{from_end}" if from_start > from_end

  if map_idx == maps.length
    location = from_start if location.nil? || from_start < location
    next
  end

  idx_start = maps[map_idx].bsearch_index {|from, to, _| to ? from > from_start : from >= from_start}

  if idx_start.nil?
    raise if maps[map_idx].bsearch_index {|from, to, _| to ? from > from_end : from >= from_end}
    to_visit.push [map_idx + 1, from_start, from_end]
    next
  end

  idx_end = maps[map_idx].bsearch_index {|from, to, _| to ? from > from_end : from >= from_end} || maps[map_idx].length

  if idx_start == idx_end
    if idx_start % 2 == 0
      to_visit.push [map_idx + 1, from_start, from_end]
    else
      offset = maps[map_idx][idx_start - 1][1] - maps[map_idx][idx_start - 1][0]
      to_visit.push [map_idx + 1, from_start + offset, from_end + offset]
    end
    next
  end

  if idx_start % 2 == 0
    to_visit.push [map_idx + 1, from_start, maps[map_idx][idx_start][0] - 1]
  else
    offset = maps[map_idx][idx_start - 1][1] - maps[map_idx][idx_start - 1][0]
    to_visit.push [map_idx + 1, from_start + offset, maps[map_idx][idx_start] + offset]
  end

  ((idx_start + 1)...(idx_end - 1)).each do |idx|
    if idx % 2 == 0
      offset = maps[map_idx][idx][1] - maps[map_idx][idx][0]
      to_visit.push [map_idx + 1, maps[map_idx][idx][0] + offset, maps[map_idx][idx + 1] + offset]
    elsif maps[map_idx][idx + 1][0] > maps[map_idx][idx] + 1
      to_visit.push [map_idx + 1, maps[map_idx][idx] + 1, maps[map_idx][idx + 1][0] - 1]
    end
  end

  if idx_end % 2 == 0
    to_visit.push [map_idx + 1, maps[map_idx][idx_end - 1] - 1, from_end]
  else
    offset = maps[map_idx][idx_end - 1][1] - maps[map_idx][idx_end - 1][0]
    to_visit.push [map_idx + 1, maps[map_idx][idx_end - 1][0] + offset, from_end + offset]
  end
end

puts location
