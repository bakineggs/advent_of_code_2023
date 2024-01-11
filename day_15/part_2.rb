lines = File.readlines ARGV[0], chomp: true
raise 'Expected an input file with a one line initialization sequence' unless lines.length == 1

boxes = 256.times.map {[]}
lines.first.split(',').each do |step|
  if match = step.match(/^(\w+)-$/)
    box = match[1].chars.inject(0) {|v, c| (v + c.ord) * 17 % 256}
    boxes[box].delete_if {|l, _| l == match[1]}
  elsif match = step.match(/^(\w+)=(\d)$/)
    box = match[1].chars.inject(0) {|v, c| (v + c.ord) * 17 % 256}
    if idx = boxes[box].find_index {|l, _| l == match[1]}
      boxes[box][idx][1] = match[2].to_i
    else
      boxes[box].push [match[1], match[2].to_i]
    end
  else
    raise "Unrecognized step: #{step}"
  end
end

puts boxes.each_with_index.sum {|box, box_idx|
  box.each_with_index.sum do |(_, focal_length), slot_idx|
    (box_idx + 1) * (slot_idx + 1) * focal_length
  end
}
