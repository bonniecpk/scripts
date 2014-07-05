#!/usr/bin/env ruby

# n = 0 returns [[], [0]]
# n = 1 returns [[], [0], [1], [0,1]]
# n = 2 returns [[], [0], [1], [2], [0,1], [0,2], [1,2], [0,1,2]]
# etc
def power_set(n)
  return [[], [0]] if n == 0
  n_minus_1_set = power_set(n-1) if n > 0
  (n_minus_1_set + n_minus_1_set.map { |set| set.clone << n }).sort_by { |set| set.size }
end

answer = power_set(ARGV[0].to_i)
puts "Power set size = #{answer.size}"
puts answer.inspect
