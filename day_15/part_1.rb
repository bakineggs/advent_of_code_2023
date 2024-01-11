lines = File.readlines ARGV[0], chomp: true
raise 'Expected an input file with a one line initialization sequence' unless lines.length == 1

puts lines.first.split(',').sum {|step|
  step.chars.inject 0 do |value, char|
    (value + char.ord) * 17 % 256
  end
}
