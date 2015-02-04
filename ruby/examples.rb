require 'pry'
require 'pry-nav'



# an array gives the sum
def sum(array)
  array.inject(0, &:+)
end
#p sum([])
#p sum([1,2,3,4])


# a list of numbers: sum numbers that are even
def sum_even(array)
  array.collect { |e| e if e % 2 == 0 }.compact!.inject(0, &:+)
end
#p sum_even([1,2,3,4])
#p sum_even([1,3])



# a list of numbers: sum odd numbers > 4
def sum_odd_greater_than_4(array)
  array.keep_if { |e| e % 2 == 1 && e > 4 }.inject(0, &:+)
end
#p sum_odd_greater_than_4([1,2,3,4])
#p sum_odd_greater_than_4([1,3,5,6,7])



def flexible_sum(array)
  if !block_given?
    sum(array)
  else
    array.keep_if { |e| yield(e) }.inject(0, &:+)
  end
end
#p flexible_sum([1,3,5,6,7]) { |e| e % 2 == 1 && e > 4 }
#p flexible_sum([1,3,5,6,7], Proc.new { e % 2 == 1 && e > 4 })




def flexible_sum2(array, block)
  array.keep_if { |e| block.call(e) }.inject(0, &:+)
end
#p flexible_sum2([1,3,5,6,7], Proc.new { |e| e % 2 == 1 && e > 4 })



def coin_change(value)
  coin_types = [25, 10, 5, 1]
  num_coins  = []
  remainder  = value

  coin_types.each do |coin_type|
    num_coins << remainder / coin_type
    remainder = remainder % coin_type
  end

  num_coins.collect.with_index { |num, index| num.times.collect { |i| coin_types[index] } }.flatten
end
#p coin_change(66)


# Block Example 1
# def hello
#   yield if block_given?
# end
# 
# blah = -> {puts "lambda"}
# 
# hello(blah)


# Block Example 2
# def hello(&val)
#   puts val
# end
# 
# hello { 3 }
