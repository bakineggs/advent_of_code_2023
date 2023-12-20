NUMBERS = {
  'one' => 1,
  'two' => 2,
  'three' => 3,
  'four' => 4,
  'five' => 5,
  'six' => 6,
  'seven' => 7,
  'eight' => 8,
  'nine' => 9,
}
NUMBERS.default_proc = lambda {|_, number| number}

MATCH_NUMBERS = /#{NUMBERS.keys.map{|number| "#{number}|"}.join}\d/
MATCH_NUMBERS_REVERSE = /#{NUMBERS.keys.map{|number| "#{number.reverse}|"}.join}\d/

puts File.readlines(ARGV[0]).sum {|line|
  first_digit = NUMBERS[line.match(MATCH_NUMBERS)[0]]
  last_digit = NUMBERS[line.reverse.match(MATCH_NUMBERS_REVERSE)[0].reverse]
  "#{first_digit}#{last_digit}".to_i
}
