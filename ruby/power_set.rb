# n = 0 returns [[], [0]]
# n = 1 returns [[], [0], [1], [0,1]]
# n = 2 returns [[], [0], [1], [2], [0,1], [0,2], [1,2], [0,1,2]]
# etc
def power_set(n)
  return [[], [0]] if n == 0
  n_minus_1_set = power_set(n-1) if n > 0
  n_minus_1_set + n_minus_1_set.map { |set| set.clone << n }
end

puts power_set(0).inspect
puts power_set(1).inspect
puts power_set(2).inspect
