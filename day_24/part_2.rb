hail = File.readlines(ARGV[0]).map do |line|
  raise "Failed to parse line #{line}" unless match = line.match(/^(\d+), +(\d+), +(\d+) +@ +(-?\d+), +(-?\d+), +(-?\d+)$/)
  match[1..6].map &:to_i
end

x0, y0, z0, dx0, dy0, dz0 = hail.pop
x1, y1, z1, dx1, dy1, dz1 = hail.pop
x2, y2, z2, dx2, dy2, dz2 = hail.pop
dx1x2, dy1y2, dz1z2 = x1 - x2, y1 - y2, z1 - z2
t0 = 0
loop do
  t0 += 1
  x0 += dx0 and y0 += dy0 and z0 += dz0
  xn = (y0 - y1) * dz1 - (z0 - z1) * dy1
  yn = (z0 - z1) * dx1 - (x0 - x1) * dz1
  zn = (x0 - x1) * dy1 - (y0 - y1) * dx1

  dp = xn * dx2 + yn * dy2 + zn * dz2
  next if dp == 0
  t2 = dx1x2 * xn + dy1y2 * yn + dz1z2 * zn
  next unless t2 % dp == 0
  t2 /= dp
  xp, yp, zp = x2 + dx2 * t2, y2 + dy2 * t2, z2 + dz2 * t2
  dxp, dyp, dzp = xp - x0, yp - y0, zp - z0

  next unless hail.all? do |x, y, z, dx, dy, dz|
    (dy * dzp - dz * dyp) * (x - x0) + (dz * dxp - dx * dzp) * (y - y0) + (dx * dyp - dy * dxp) * (z - z0) == 0
  end

  dx, dy, dz = (x0 - xp) / (t0 - t2), (y0 - yp) / (t0 - t2), (z0 - zp) / (t0 - t2)
  x, y, z = xp - t2 * dx, yp - t2 * dy, zp - t2 * dz

  next unless hail.all? do |xh, _, _, dxh|
    xd, dxd = xh - x, dx - dxh
    xd % dxd == 0 && xd / dxd > 0
  end

  puts x + y + z
  exit 0
end
