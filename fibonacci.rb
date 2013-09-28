# Fibonacci sequence:
# 1, 1, 2, 3, 5, 8, 13....
def fibonacci(term)
  return 1 if term == 1
  return 1 if term == 2
  return fibonacci(term - 2) + fibonacci(term - 1)
end

#puts fibonacci(7)



# Fibonacci sequence:
# 1, 1, 2, 3, 5, 8, 13....
input = STDIN.read.to_i
#input = ARGF.read.first

@@cache = {1 => 1, 2 => 1}

def fibonacci2(term)
  return @@cache[1] if term == 1
  return @@cache[2] if term == 2
  @@cache[term - 2] = fibonacci2(term - 2) if !@@cache.has_key?(term - 2)
  @@cache[term - 1] = fibonacci2(term - 1) if !@@cache.has_key?(term - 1)
  return @@cache[term - 2] + @@cache[term - 1]
end

puts fibonacci2(input)
