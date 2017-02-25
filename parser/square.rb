class Square
  attr_accessor :x, :y, :owner, :strength

  def initialize(x, y, data)
    @x = x
    @y = y
    @owner = data.first
    @strength = data.last
  end
end
