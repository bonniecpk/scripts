# Block
class Array
  def iterate!(&code)
    self.each_with_index do |n, i|
      self[i] = code.call(n)
    end
  end
end

array = [1, 2, 3, 4]

array.iterate! do |n|
  n ** 2   # same as n ^ 2
end

# Proc
# 1) Doesn't check the exact # of arguemnts
# 2) "return" will immediately terminate the function, or throw unexpected return (LocalJumpError)
class Array
  def iterate!(code)
    self.each_with_index do |n, i|
      self[i] = code.call(n)
    end
  end
end

array_1 = [1, 2, 3, 4]
array_2 = [2, 3, 4, 5]

square = Proc.new do |n|
  n ** 2
end

array_1.iterate!(square)
array_2.iterate!(square)

puts array_1.inspect
puts array_2.inspect

# Lambda
# 1) Checks the exact # of arguemnts
# 2) "return" will NOT immediately terminate the function
class Array
  def iterate!(code)
    self.each_with_index do |n, i|
      self[i] = code.call(n)
    end
  end
end

array = [1, 2, 3, 4]

array.iterate!(lambda { |n| n ** 2 })

puts array.inspect


# Proc vs Lambda inside the function
def proc_return
  Proc.new { return "Proc.new" }.call
  return "proc_return method finished"
end

def lambda_return
  lambda { return "lambda" }.call
  return "lambda_return method finished"
end

puts proc_return
puts lambda_return

# Example: Lambda and Proc return passing in as parameter
lam = lambda { return "lambda" }
pro = proc { return "proc" }

def test_return(block)
  block.call
end

p test_return(lam)
p test_return(pro)
