require 'chunky_png'
# Load and extract the information of the game
class Game
  attr_accessor :name, :players, :frames, :width, :height

  COLORS = %w(F50E4E AE78C9 164293)

  def initialize(json)
    @players = [Player.new(0, 'Empty', 'e4e4e4')]
    @width = json['width']
    @height = json['height']

    json['player_names'].each_with_index do |name, i|
      @players << Player.new(i + 1, name, COLORS[i])
    end

    @frames = json['frames'].map { |f| Frame.new(f) }
    @name = "game-#{Time.now.to_i}"
  end

  def print_frame(num)
    frame = @frames[num]
    px_square = 10;

    png = ChunkyPNG::Image.new(width * px_square, height * px_square, ChunkyPNG::Color::TRANSPARENT)

    frame.squares.each do |row|
      row.each do |square|
        alpha = square.strength.to_s(16).upcase.rjust(2, '0')
        if square.owner == 0
          color = ChunkyPNG::Color("#e4e4e4")
        else
          color = ChunkyPNG::Color("##{alpha}#{players[square.owner].color}")
        end

        px_square.times do |w|
          px_square.times do |h|
            # Here the order is in this direction
            png[(square.y * px_square) + h, (square.x * px_square) + w] = color
          end
        end
      end
    end

    png.save("results/images/#{name}.png", :interlace => true)
  end

  def print_last_frame
    print_frame(frames.size - 1)
  end

  def to_s
    "#{frames.size} #{width} #{height}"
  end
end
