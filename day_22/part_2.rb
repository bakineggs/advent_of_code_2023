require 'set'

x_max, y_max, z_max = 0, 0, 0

blocks = File.readlines(ARGV[0]).map do |line|
  raise "Failed to parse line #{line}" unless match = line.match(/^(\d+),(\d+),(\d+)~(\d+),(\d+),(\d+)$/)
  x1, y1, z1, x2, y2, z2 = match[1..6].map &:to_i
  raise 'Expected each block to be 1x1xN' if [x1 == x2, y1 == y2, z1 == z2].count {|b| b} < 2
  x_max = [x1, x2].max if x1 > x_max || x2 > x_max
  y_max = [y1, y2].max if y1 > y_max || y2 > y_max
  z_max = [z1, z2].max if z1 > z_max || z2 > z_max
  [[x1, x2].sort, [y1, y2].sort, [z1, z2].sort, false]
end

stack = (0..x_max).map { (0..y_max).map { (0..z_max).map {nil}}}

blocks.each do |block|
  (x1, x2), (y1, y2), (z1, z2) = block
  (x1..x2).each do |x|
    (y1..y2).each do |y|
      (z1..z2).each do |z|
        raise 'Had 2 blocks starting at the same place' if stack[x][y][z]
        stack[x][y][z] = block
      end
    end
  end
  block[3] = true if z1 == 0
end

supports = Hash[blocks.map {|block| [block.object_id, Set.new]}]
supported_by = Hash[blocks.map {|block| [block.object_id, Set.new]}]

(0..z_max).each do |z|
  (0..x_max).each do |x|
    (0..y_max).each do |y|
      next if stack[x][y][z].nil? || stack[x][y][z][3]
      stack[x][y][z][3] = true
      (x1, x2), (y1, y2), (z1_start, z2_start) = stack[x][y][z]
      z1 = z1_start
      z1 -= 1 while z1 > 0 && (x1..x2).all? {|xc| (y1..y2).all? {|yc| stack[xc][yc][z1 - 1].nil?}}

      unless z1 == z1_start
        z2 = z1 + z2_start - z1_start
        stack[x][y][z][2] = [z1, z2]
        (z1..[z2, z2_start - 1].min).each do |zc|
          (x1..x2).each {|xc| (y1..y2).each {|yc| stack[xc][yc][zc] = stack[x][y][z]}}
        end
        ([z1_start, z2 + 1].max..z2_start).each do |zc|
          (x1..x2).each {|xc| (y1..y2).each {|yc| stack[xc][yc][zc] = nil}}
        end
      end

      next if z1 == 0
      zc = z1 - 1
      (x1..x2).each do |xc|
        (y1..y2).each do |yc|
          next if stack[xc][yc][zc].nil?
          supports[stack[xc][yc][zc].object_id].add stack[x][y][z1].object_id
          supported_by[stack[x][y][z1].object_id].add stack[xc][yc][zc].object_id
        end
      end
    end
  end
end

puts blocks.sum {|block|
  fall, check = [block.object_id].to_set, supports[block.object_id]
  until check.empty?
    check = check.flat_map do |other|
      next [] unless (supported_by[other] - fall).empty?
      fall.add other
      supports[other].to_a
    end.to_set
  end
  fall.length - 1
}
