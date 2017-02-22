$:.unshift(File.dirname(__FILE__))
require 'networking'

network = Networking.new("AngelmmiguelBot")
tag, map = network.configure

Neighbor = Struct.new(:loc, :map) do
  def site
    map.site(loc)
  end
end

def neighbors(loc, map, tag)
  neighbors = {}

  y = loc.y
  x = loc.x
  height = map.height
  width = map.width

  nl = Neighbor.new(Location.new(x, (y == 0 ? height - 1 : y - 1)), map)
  neighbors[:north] = nl

  sl = Neighbor.new(Location.new(x, (y == height - 1 ? 0 : y + 1)), map)
  neighbors[:south] = sl

  el = Neighbor.new(Location.new((x == width - 1 ? 0 : x + 1), y), map)
  neighbors[:east] = el

  wl = Neighbor.new(Location.new((x == 0 ? width - 1 : x - 1), y), map)
  neighbors[:west] = wl

  neighbors
end

while true
  moves = []
  map = network.frame

  (0...map.height).each do |y|
    (0...map.width).each do |x|
      loc = Location.new(x, y)
      site = map.site(loc)
      all_mine = true

      if site.owner == tag
        attack = Hash[neighbors(loc, map, tag).to_a.shuffle!]
        currentStrength = site.strength
        move = Move.new(loc, :still)

        if attack.all? { |k, v| v.site.owner == tag }
          selected = :north

          attack.each do |k ,v|
            next unless v.site.strength > attack[selected].site.strength
            selected = k
          end

          move = Move.new(loc, selected)
        else
          attack.each do |k, v|
            next unless v.site && currentStrength > v.site.strength && v.site.owner != tag
            move = Move.new(loc, k)
          end
        end

        moves << move
      end
    end
  end

  network.send_moves(moves)
end
