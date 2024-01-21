mods = Hash[File.readlines(ARGV[0]).map do |line|
  raise "Failed to parse line #{line}" unless match = line.match(/^([%&]?)(\w+) -> (\w+(, \w+)*)$/)
  raise 'Only the broadcaster module can have the broadcast type' if match[1] == '' && match[2] != 'broadcaster'
  [match[2], [match[1], match[3].split(', ')]]
end]

raise 'Expected a module named broadcaster' unless mods.has_key? 'broadcaster'
raise 'Expected broadcaster module to be plain type' unless mods['broadcaster'][0] == ''

mods.each do |mod, (type, _)|
  next unless type == '&'
  mods[mod][2] = Hash[mods.keys.select {|m| mods[m][1].include? mod}.map {|m| [m, :low]}]
end

count = {low: 0, high: 0}

1000.times do
  pulses = [['broadcaster', :low]]
  until pulses.empty?
    mod, pulse_type, sender = pulses.shift
    count[pulse_type] += 1

    next unless mods.has_key? mod
    mod_type, dests = mods[mod]
    case mod_type
    when ''
      dests.each {|dest| pulses.push [dest, pulse_type, mod]}
    when '%'
      next if pulse_type == :high
      dest_type = mods[mod][2] ? :low : :high
      mods[mod][2] = !mods[mod][2]
      dests.each {|dest| pulses.push [dest, dest_type, mod]}
    when '&'
      raise unless mods[mod][2].has_key? sender
      mods[mod][2][sender] = pulse_type
      dest_type = mods[mod][2].all? {|_, v| v == :high} ? :low : :high
      dests.each {|dest| pulses.push [dest, dest_type, mod]}
    else
      raise NotImplementedError
    end
  end
end

puts count[:low] * count[:high]
