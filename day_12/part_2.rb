class DedupQueue
  def initialize groups, lengths
    @order = [[groups, lengths]]
    @quantities = {[groups, lengths] => 1}
  end

  def empty?
    @order.empty?
  end

  def pop
    groups, lengths = @order.shift
    quantity = @quantities[[groups, lengths]]
    @quantities.delete [groups, lengths]
    [groups, lengths, quantity]
  end

  def push groups, lengths, quantity
    if @quantities.has_key? [groups, lengths]
      @quantities[[groups, lengths]] += quantity
    else
      @quantities[[groups, lengths]] = quantity
      @order.push [groups, lengths]
    end
  end
end

puts File.readlines(ARGV[0]).sum {|line|
  raise "Failed to parse line #{line}" unless match = line.match(/^([\.?#]+) (\d+(,\d+)*)$/)
  groups = ([match[1]] * 5).join('?').split(/\.+/).map &:chars
  lengths = match[2].split(',').map(&:to_i) * 5
  arrangements = 0

  to_visit = DedupQueue.new groups, lengths
  until to_visit.empty?
    groups, lengths, quantity = to_visit.pop

    changed = true
    while changed
      changed = false
      groups.shift and changed = true  while groups.first&.empty?
      groups.shift and lengths.shift and changed = true  while !groups.empty? && groups.first.include?('#') && groups.first.length == lengths.first
      groups.shift and changed = true  while !groups.empty? && !lengths.empty? && !groups.first.include?('#') && groups.first.length < lengths.first

      groups.first.shift and changed = true  while !groups.empty? && !lengths.empty? && groups.first.first == '?' && groups.first[lengths.first] == '#'
      groups.first.shift lengths.shift + 1 and changed = true  while !groups.empty? && !lengths.empty? && groups.first.first == '#' && groups.first.length > lengths.first && groups.first[lengths.first] == '?'

      groups.pop and changed = true while groups.last&.empty?
      groups.pop and lengths.pop and changed = true while !groups.empty? && groups.last.include?('#') && groups.last.length == lengths.last
      groups.pop and changed = true while !groups.empty? && !lengths.empty? && !groups.last.include?('#') && groups.last.length < lengths.last

      groups.last.pop and changed = true while !groups.empty? && !lengths.empty? && groups.last.last == '?' && groups.last[-1 * (lengths.last + 1)] == '#'
      groups.last.pop lengths.pop + 1 and changed = true while !groups.empty? && !lengths.empty? && groups.last.last == '#' && groups.last.length > lengths.last && groups.last[-1 * (lengths.last + 1)] == '?'
    end

    next if lengths.empty? && groups.any? {|group| group.include? '#'}
    arrangements += quantity and next if lengths.empty? || groups.map(&:length) == lengths

    next if groups.sum(&:length) <= lengths.sum

    next if groups.first.length < lengths.first && groups.first.include?('#')
    next if groups.last.length < lengths.last && groups.last.include?('#')

    next if groups.first.length > lengths.first && groups.first[lengths.first] == '#'
    next if groups.last.length > lengths.last && groups.last[-1 * (lengths.last + 1)] == '#'

    if groups.first.length <= lengths.first
      raise if groups.first.include? '#'
      to_visit.push groups[1..-1].map(&:dup), lengths.dup, quantity unless groups[1..-1].sum(&:length) < lengths.sum
    else
      raise if groups.first.first == '#'
      to_visit.push [groups.first[1..-1], *groups[1..-1].map(&:dup)], lengths.dup, quantity unless groups.sum(&:length) == lengths.sum
    end

    if groups.first.length == lengths.first
      to_visit.push groups[1..-1].map(&:dup), lengths[1..-1], quantity
    elsif groups.first.length > lengths.first
      to_visit.push [groups.first[(lengths.first + 1)..-1], *groups[1..-1].map(&:dup)], lengths[1..-1], quantity unless groups.first[lengths.first] == '#'
    end
  end

  arrangements
}
