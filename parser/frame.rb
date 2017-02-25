# Every frame of the game
class Frame
  attr_accessor :squares, :strength, :territory

  def initialize(frame)
    @squares = []
    @strength = {}
    @territory = {}

    frame.each_with_index do |row, i|
      @squares[i] = []

      row.each_with_index do |col, j|
        square = Square.new(i, j, col)
        @squares[i] << square

        # Store other statistics
        @strength[square.owner] ||= 0
        @territory[square.owner] ||= 0
        @strength[square.owner] += square.strength
        @territory[square.owner] += 1
      end
    end
  end
end
