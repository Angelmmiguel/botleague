#!/usr/bin/env ruby
require 'json'
require 'pry'
require 'pry-nav'

require_relative './game.rb'
require_relative './square.rb'
require_relative './frame.rb'
require_relative './player.rb'

if ARGV.size != 1
  puts 'Usage: parser <hlt file>'
  exit
end

json = JSON.parse(File.read(ARGV.first))
game = Game.new(json)

game.print_last_frame

puts game
