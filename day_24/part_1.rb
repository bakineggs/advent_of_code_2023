X_MIN = Y_MIN = ARGV[1].to_i
X_MAX = Y_MAX = ARGV[2].to_i

hail = []

puts File.readlines(ARGV[0]).sum {|line|
  raise "Failed to parse line #{line}" unless match = line.match(/^(\d+), +(\d+), +\d+ +@ +(-?\d+), +(-?\d+), +-?\d+$/)
  x1, y1, dx1, dy1 = match[1..4].map &:to_i
  raise NotImplementedError if dx1 == 0
  hail.push [x1, y1, dx1, m1 = dy1.to_f / dx1, c1 = y1 - m1 * x1]
  hail[0...].count do |x2, y2, dx2, m2, c2|
    next false if m1 == m2
    x = (c1 - c2) / (m2 - m1)
    next false if x < X_MIN || x > X_MAX
    next false unless x > x1 == dx1 > 0
    next false unless x > x2 == dx2 > 0
    y = (c1 * m2 - c2 * m1) / (m2 - m1)
    next false if y < Y_MIN || y > Y_MAX
    true
  end
}
