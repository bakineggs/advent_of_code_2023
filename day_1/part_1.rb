puts File.readlines(ARGV[0]).sum {|line| (line.chars.find{|c| c =~ /\d/} + line.chars.reverse.find{|c| c =~ /\d/}).to_i}
