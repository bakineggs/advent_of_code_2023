lines = File.readlines ARGV[0]
line_number = 0
sum = 0

lines.each do |line|
  offset = 0
  while index = line.index('*', offset)
    offset = index + 1
    parts = []
    parts.push [line_number, index - 1] if index > 0 && line[index - 1] =~ /\d/
    parts.push [line_number, index + 1] if index < line.length - 1 && line[index + 1] =~ /\d/

    [line_number - 1, line_number + 1].each do |check_line|
      next if check_line == -1 || check_line >= lines.length
      if lines[check_line][index] =~ /\d/
        parts.push [check_line, index]
      else
        parts.push [check_line, index - 1] if index > 0 && lines[check_line][index - 1] =~ /\d/
        parts.push [check_line, index + 1] if index < line.length - 1 && lines[check_line][index + 1] =~ /\d/
      end
      break if parts.length > 2
    end

    next unless parts.length == 2

    product = 1
    parts.each do |part_line_number, index|
      index -= 1 while index > 0 && lines[part_line_number][index - 1] =~ /\d/
      product *= lines[part_line_number][index..].to_i
    end
    sum += product
  end
  line_number += 1
end

puts sum
