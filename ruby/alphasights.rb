log = [
  {time: 201201, x: 2},
  {time: 201201, y: 7},
  {time: 201201, z: 2},
  {time: 201202, a: 3},
  {time: 201202, b: 4},
  {time: 201202, c: 0}
]

compact_log = {}
log.each do |entry|
  compact_log[entry[:time]] = {} unless compact_log[entry[:time]]
  entry.each do |key, val|
    compact_log[entry[:time]][key] = val
  end
end

puts compact_log.values.inspect
