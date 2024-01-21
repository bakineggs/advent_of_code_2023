mods = Hash[File.readlines(ARGV[0]).map do |line|
  raise "Failed to parse line #{line}" unless match = line.match(/^([%&]?)(\w+) -> (\w+(, \w+)*)$/)
  raise 'Only the broadcaster module can have the broadcast type' if match[1] == '' && match[2] != 'broadcaster'
  [match[2], [match[1], match[3].split(', ')]]
end]

raise 'Expected a module named broadcaster' unless mods.has_key? 'broadcaster'
raise 'Expected broadcaster module to be plain type' unless mods['broadcaster'][0] == ''

raise NotImplementedError if mods.has_key? 'rx'
raise NotImplementedError unless mods.count {|_, (_, dests)| dests.include? 'rx'} == 1
raise NotImplementedError unless mods.count {|_, (_, dests)| dests == ['rx']} == 1

final_nand = mods.keys.find {|mod| mods[mod][1] == ['rx']}
final_nand_inputs = Hash[mods.keys.select {|mod| mods[mod][1].include? final_nand}.map {|mod| [mod, true]}]

raise NotImplementedError unless mods['broadcaster'][1].length == final_nand_inputs.length

subgraphs = Hash[mods['broadcaster'][1].map {|mod| [mod, []]}]
subgraph_for = Hash[subgraphs.keys.map {|mod| [mod, mod]}]
subgraph_success = Hash[subgraphs.keys.map {|mod| [mod, []]}]

to_explore = mods['broadcaster'][1].dup
until to_explore.empty?
  mod = to_explore.pop
  subgraph = subgraph_for[mod]
  mods[mod][1].each do |dest|
    next if dest == final_nand
    raise NotImplementedError if subgraph_for.has_key?(dest) && subgraph_for[dest] != subgraph
    next if subgraph_for.has_key? dest
    subgraphs[subgraph].push dest
    subgraph_for[dest] = subgraph
    to_explore.push dest
  end
end

mods.each do |mod, (type, _)|
  case type
  when '%'
    mods[mod][2] = false
  when '&'
    mods[mod][2] = Hash[mods.keys.select {|m| mods[m][1].include? mod}.map {|m| [m, :low]}]
  else
    raise unless mod == 'broadcaster'
  end
end

count, cycles, histories = 0, {}, Hash[subgraphs.keys.map {|mod| [mod, []]}]
until subgraphs.keys.all? {|mod| cycles.has_key? mod}
  count += 1
  pulses = [['broadcaster', :low]]
  until pulses.empty?
    mod, pulse_type, sender = pulses.shift
    subgraph_success[subgraph_for[mod]].push count if pulse_type == :low && final_nand_inputs[mod]

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
  histories.each do |subgraph, history|
    next if cycles.has_key? subgraph
    status = subgraphs[subgraph].map do |mod|
      case mods[mod][0]
      when '%'
        mods[mod][2]
      when '&'
        mods[mod][2].keys.sort.map {|dest| mods[mod][2][dest]}
      else
        raise
      end
    end
    if history.include? status
      cycles[subgraph] = [history.find_index(status), count - 1]
    else
      history.push status
    end
  end
end

raise NotImplementedError unless subgraph_success.values.all? {|successes| successes.length == 1}
raise NotImplementedError unless cycles.values.all? {|start, _| start == 0}
raise NotImplementedError unless cycles.all? {|mod, (_, count)| count == subgraph_success[mod].first}
puts cycles.values.map(&:last).inject(1) {|product, count| product * count}
