# Every frame of the game
class Frame
  attr_accessor :squares

  def initialize(frame)
    @squares = []

    frame.each_with_index do |row, i|
      @squares[i] = []

      row.each_with_index do |col, j|
        @squares[i] << Square.new(i, j, col)
      end
    end
  end
end
