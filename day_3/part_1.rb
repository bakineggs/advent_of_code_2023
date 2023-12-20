require 'set'
SYMBOLS = %w(@ # $ % & * - = + /).to_set

VALID = /^(#{SYMBOLS.map {|sym| "\\#{sym}|"}.join}\.|\d)*$/

lines = File.readlines ARGV[0]
line_number = 0

puts lines.sum {|line|
  raise "Can't parse line #{line}" unless line =~ VALID
  offset = 0
  line.scan(/\d+/).sum do |number|
    index = line.index number, offset
    offset = index + number.length
    is_part = SYMBOLS.include?(line[index - 1]) || SYMBOLS.include?(line[index + number.length])
    [line_number - 1, line_number + 1].each do |check_line_number|
      next if is_part || check_line_number == -1 || check_line_number == lines.length
      is_part = ((index - 1)..(index + number.length)).any? {|check_index| check_index != -1 && SYMBOLS.include?(lines[check_line_number][check_index])}
    end
    is_part ? number.to_i : 0
  end.tap do
    line_number += 1
  end
}
