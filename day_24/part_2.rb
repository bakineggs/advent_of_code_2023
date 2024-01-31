hail = File.readlines(ARGV[0]).map do |line|
  raise "Failed to parse line #{line}" unless match = line.match(/^(\d+), +(\d+), +(\d+) +@ +(-?\d+), +(-?\d+), +(-?\d+)$/)
  match[1..6].map &:to_i
end

best, idx0, idx1, idx2, t2_start = nil, nil, nil, nil, nil

hail.each_with_index.reverse_each do |(x0, y0, z0, dx0, dy0, dz0), i0|
  hail.each_with_index.reverse_each do |(x1, y1, z1, dx1, dy1, dz1), i1|
    break if i0 == i1
    hail.each_with_index do |(x2, y2, z2, dx2, dy2, dz2), i2|
      next if i2 == i0 || i2 == i1
      x0, y0, z0, dx0, dy0, dz0 = hail[i0]
      x1, y1, z1, dx1, dy1, dz1 = hail[i1]
      x2, y2, z2, dx2, dy2, dz2 = hail[i2]

      xn0 = (y1 - y0) * dz0 - (z1 - z0) * dy0
      yn0 = (z1 - z0) * dx0 - (x1 - x0) * dz0
      zn0 = (x1 - x0) * dy0 - (y1 - y0) * dx0

      next if xn0 * dx1 + yn0 * dy1 + zn0 * dz1 == 0

      dp0 = xn0 * dx2 + yn0 * dy2 + zn0 * dz2
      next if dp0 == 0

      xn1 = (y0 - y1) * dz1 - (z0 - z1) * dy1
      yn1 = (z0 - z1) * dx1 - (x0 - x1) * dz1
      zn1 = (x0 - x1) * dy1 - (y0 - y1) * dx1

      dp1 = xn1 * dx2 + yn1 * dy2 + zn1 * dz2
      next if dp1 == 0

      t2_0 = (((x0 - x2) * xn0 + (y0 - y2) * yn0 + (z0 - z2) * zn0) / dp0.to_f).abs
      t2_1 = (((x1 - x2) * xn1 + (y1 - y2) * yn1 + (z1 - z2) * zn1) / dp1.to_f).abs

      t2_diff = (t2_1 - t2_0).abs
      next unless t2_diff < best unless best.nil?

      best, idx0, idx1, idx2, t2_start = t2_diff, i0, i1, i2, (t2_0 / 2 + t2_1 / 2).round
    end
  end
end

x0, y0, z0, dx0, dy0, dz0 = hail[idx0]
x1, y1, z1, dx1, dy1, dz1 = hail[idx1]
x2, y2, z2, dx2, dy2, dz2 = hail[idx2]
[idx0, idx1, idx2].sort.reverse_each {|idx| hail.delete_at idx}

t2_d = -1
loop do
  t2_d += 1
  [-1, 1].map {|pos| t2_start + t2_d * pos}.each do |t2|
    next if t2 < 0
    x2_t, y2_t, z2_t = x2 + dx2 * t2, y2 + dy2 * t2, z2 + dz2 * t2

    xn = (y2_t - y0) * dz0 - (z2_t - z0) * dy0
    yn = (z2_t - z0) * dx0 - (x2_t - x0) * dz0
    zn = (x2_t - x0) * dy0 - (y2_t - y0) * dx0

    dp = xn * dx1 + yn * dy1 + zn * dz1
    next if dp == 0
    t1 = (x2_t - x1) * xn + (y2_t - y1) * yn + (z2_t - z1) * zn
    next unless t1 % dp == 0
    t1 /= dp
    raise NotImplementedError if t1 == t2

    x1_t, y1_t, z1_t = x1 + dx1 * t1, y1 + dy1 * t1, z1 + dz1 * t1

    if t1 < t2
      t = t2 - t1
      next unless (x2_t - x1_t) % t == 0 && (y2_t - y1_t) % t == 0 && (z2_t - z1_t) % t == 0
      dx, dy, dz = (x2_t - x1_t) / t, (y2_t - y1_t) / t, (z2_t - z1_t) / t
      x, y, z = x1_t - dx * t1, y1_t - dy * t1, z1_t - dz * t1
    else
      t = t1 - t2
      next unless (x1_t - x2_t) % t == 0 && (y1_t - y2_t) % t == 0 && (z1_t - z2_t) % t == 0
      dx, dy, dz = (x1_t - x2_t) / t, (y1_t - y2_t) / t, (z1_t - z2_t) / t
      x, y, z = x2_t - dx * t2, y2_t - dy * t2, z2_t - dz * t2
    end

    next unless (hail + [[x0, y0, z0, dx0, dy0, dz0]]).all? do |xh, yh, zh, dxh, dyh, dzh|
      (dy * dzh - dz * dyh) * (x - xh) + (dz * dxh - dx * dzh) * (y - yh) + (dx * dyh - dy * dxh) * (z - zh) == 0
    end

    puts x + y + z
    exit 0
  end
end
