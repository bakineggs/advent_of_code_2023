hail = File.readlines(ARGV[0]).map do |line|
  raise "Failed to parse line #{line}" unless match = line.match(/^(\d+), +(\d+), +(\d+) +@ +(-?\d+), +(-?\d+), +(-?\d+)$/)
  match[1..6].map &:to_i
end

i = 0
loop do
  i += 1
  (0...i).flat_map {|i2| [[i, i2], [i2, i]]}.each do |t1, t2|
    x1, y1, z1 = hail[0][0..2].zip(hail[0][3..5]).map {|p, d| p + d * t1}
    x2, y2, z2 = hail[1][0..2].zip(hail[1][3..5]).map {|p, d| p + d * t2}
    dx12, dy12, dz12 = x2 - x1, y2 - y1, z2 - z1
    dt = t2 - t1
    next unless dx12 % dt == 0 && dy12 % dt == 0 && dz12 % dt == 0
    next unless hail[2..].all? do |x2, y2, z2, dx2, dy2, dz2|
      (dy12 * dz2 - dz12 * dy2) * (x1 - x2) + (dz12 * dx2 - dx12 * dz2) * (y1 - y2) + (dx12 * dy2 - dy12 * dx2) * (z1 - z2) == 0
    end
    if t1 < t2
      x2, y2, z2 = hail[1][0..2].zip(hail[1][3..5]).map {|p, d| p + d * t2}
    else
      t1, t2 = t2, t1
      x2, y2, z2 = x1, y1, z1
      x1, y1, z1 = hail[1][0..2].zip(hail[1][3..5]).map {|p, d| p + d * t1}
    end
    dt = t2 - t1
    raise unless (x2 - x1) % dt == 0
    raise unless (y2 - y1) % dt == 0
    raise unless (z2 - z1) % dt == 0
    dx = (x2 - x1) / dt
    x = x1 - dx * t1
    next unless hail[2..].all? do |x2, y2, z2, dx2, dy2, dz2|
      (x - x2) / (dx2 - dx) > 0
    end
    puts x + y1 - (y2 - y1) / dt * t1 + z1 - (z2 - z1) / dt * t1
    exit 0
  end
end
