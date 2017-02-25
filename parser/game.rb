require 'chunky_png'
require 'pry'
require 'pry-nav'

# Load and extract the information of the game
class Game
  attr_accessor :name, :players, :frames, :width, :height

  COLORS = [
    {
      name: 'red',
      hex: 'F50E4E'
    },
    {
      name: 'purple',
      hex: 'AE78C9'
    },
    {
      name: 'blue',
      hex: '164293'
    }
  ]

  def initialize(json)
    @players = []
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
        # alpha = square.strength.to_s(16).upcase.rjust(2, '0')
        if square.owner == 0
          color = ChunkyPNG::Color("#e4e4e4")
        else
          color = ChunkyPNG::Color("##{players[square.owner - 1].color[:hex]}")
        end

        px_square.times do |w|
          px_square.times do |h|
            # Here the order is in this direction
            png[(square.y * px_square) + h, (square.x * px_square) + w] = color
          end
        end
      end
    end

    png.save("results/#{name}.png", :interlace => true)
  end

  def print_last_frame
    print_frame(frames.size - 1)
  end

  def result_table
    rows = []
    rows << ['Winner', 'Player', 'Color', 'Territory (Max)', 'Territory (End)',
             'Strength (Max)', 'Strength (End)']
    rows << ['---', '---', '---', '---', '---', '---', '---']

    strengthWinner = 0

    frames.last.strength.each do |player_id, value|
      next if player_id == 0 || strengthWinner > value
      strengthWinner = value
    end

    @players.each do |player|
      strength_end = frames.last.strength[player.id] || 0
      territory_end = frames.last.territory[player.id] || 0
      strength_max = frames.map { |f| f.strength[player.id] }.compact.max
      territory_max = frames.map { |f| f.territory[player.id] }.compact.max
      winner = frames.last.strength[player.id] == strengthWinner ? "🏆" : ''

      rows << [winner.encode('utf-8'), player.name, player.color[:name],
               territory_max, territory_end, strength_max, strength_end]
    end

    rows.map { |r| r.join(' | ')}.join("\n")
  end

  def to_s
    "#{frames.size} #{width} #{height}"
  end
end
