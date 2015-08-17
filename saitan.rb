#!/usr/bin/env ruby

field = File.read('data.txt').each_line.map{|line| line.chomp.each_char.to_a }
start = nil
goal = nil
field.each.with_index do |line, y|
  if x = line.index('S')
    start = [x, y].freeze
  end
  if x = line.index('G')
    goal = [x, y].freeze
  end
end
class Field
  attr_reader :data
  def initialize(data)
    @data = data
    @width = data.first.size
    @height = data.size
  end
  def at(x, y)
    if x < 0 || x >= @width || y < 0 || y >= @height
      raise "range error #{x} #{y}"
    end
    return @data[y][x]
  end
  def put(x, y)
    if at(x, y) != ' '
      raise 'not empty'
    end
    @data[y][x] = '$'
  end
  def fill(x, y, step)
    if x < 0 || x >= @width || y < 0 || y >= @height
      return false # skip
    end
    if at(x, y) == 'G'
      throw :complete, [self, step] # finish
    end
    if at(x, y) == ' '
      @data[y][x] = step
      return true
    end
    false
  end
  def print
    @data.each do |line|
      puts line.join
    end
  end
end
def collect(field, x, y, step)
  dests = []
  dests << [x + 1, y] if field.fill(x + 1, y, step)
  dests << [x - 1, y] if field.fill(x - 1, y, step)
  dests << [x, y + 1] if field.fill(x, y + 1, step)
  dests << [x, y - 1] if field.fill(x, y - 1, step)
  return dests
end
def solve(field, x, y)
  step = 1
  targets = collect(field, x, y, step)
  loop do
    next_targets = []
    while target = targets.pop
      x, y = *target
      next_targets += collect(field, x, y, step)
    end
    targets = next_targets
    step += 1
  end
end
def fill_backword(answer, output, goal, step)
  x, y = *goal
  loop do
    step -= 1
    if answer.at(x + 1, y) == step
      x = x + 1
      output.put(x, y)
      next
    end
    if answer.at(x - 1, y) == step
      x = x - 1
      output.put(x, y)
      next
    end
    if answer.at(x, y + 1) == step
      y = y + 1
      output.put(x, y)
      next
    end
    if answer.at(x, y - 1) == step
      y = y - 1
      output.put(x, y)
      next
    end
    return
  end
end
backup = field.map{|line| line.dup}
ret = catch :complete do
  solve(Field.new(field), *start)
end
ans, step = *ret
printing = Field.new(backup)
fill_backword(ans, printing, goal, step)
printing.print
