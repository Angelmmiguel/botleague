#!/usr/bin/env ruby

# Requires
require 'tty-prompt'
require 'tty-command'
require 'terminal-table'
require 'fileutils'
require 'yaml'

AVAILABLE_LANGUAGES = %w(Java Ruby PHP JS)

def current_players
  Dir.entries('./bots').select do |entry|
    File.directory?(File.join('./bots', entry)) && File.exists?(File.join('./bots', entry, 'config.yml'))
  end
end

def formatLang(lang)
  case lang
  when 'php'
    lang.upcase
  when 'js'
    'JavaScript'
  else
    lang.capitalize
  end
end

def extensionByLang(lang)
  case lang.downcase
  when 'ruby'
    'rb'
  else
    lang
  end
end

def defaultRunCommandByLang(name, lang)
  case lang.downcase
  when 'ruby'
    "ruby #{name}.rb"
  when 'java'
    "java #{name}"
  when 'js'
    "nodejs #{name}"
  when 'php'
    "php #{name}.php"
  end
end

def defaultBuildCommandsByLang(name, lang)
  case lang.downcase
  when 'java'
    ["javac #{name}.java"]
  else
    []
  end
end

def executeBattle(players, battleFolder, replaysFolder, cmd, progressCMD)
  rows = [['Player', 'Language', 'Require building'], :separator]

  players = players.map do |player|
    config = YAML.load_file("bots/#{player}/config.yml")
    build = config['build'] || []
    lang = formatLang(config['lang'])

    # Add to the table
    rows << [player, config['lang'], !build.empty?]

    {
      name: player,
      lang: lang,
      build: build,
      run: config['run']
    }
  end

  puts Terminal::Table.new rows: rows

  puts 'Preparing players'

  players.each do |player|
    if !player[:build].empty?
      puts 'Building player'
      tmp = "/tmp/#{player[:name]}"
      Dir.mkdir tmp
      FileUtils.cp_r Dir.glob("bots/#{player[:name]}/*.*"), tmp

      # Copy all elements from Getting started
      FileUtils.cp_r Dir.glob("/root/Halite-#{player[:lang]}-Starter-Package/*.*"), tmp

      player[:build].each { |command| cmd.run(command, chdir: tmp) }
      # This is specific for Java
      FileUtils.cp_r Dir.glob("#{tmp}/*.*"), battleFolder

      puts 'Finish building'
    else
      FileUtils.cp_r Dir.glob("/root/Halite-#{player[:lang]}-Starter-Package/*.*"), battleFolder
      FileUtils.cp_r Dir.glob("bots/#{player[:name]}/*.*"), battleFolder
    end
  end

  puts 'Preparing arena'
  FileUtils.cp("/root/halite", battleFolder)

  puts 'Executing the battle!'
  commands = players.map { |player| "\"#{player[:run]}\"" }
  res = progressCMD.run("./halite -d \"30 30\" #{commands.join(' ')}", chdir: battleFolder)

  # Get winner
  puts ''
  puts 'Results!'
  score = res.out.scan(/^Player #[\d]{1}, ([\w\d]+), came in rank #([\d]){1}.*$/)
  rows = [['Player', 'Ranking'], :separator]
  rows += score.sort_by { |item| item.last }

  puts Terminal::Table.new rows: rows

  FileUtils.cp_r Dir.glob("#{battleFolder}/*.hlt"), replaysFolder
  puts "Replays are available in /replays folder"
end

# Initializations
prompt = TTY::Prompt.new
cmd = TTY::Command.new
progressCMD = TTY::Command.new(printer: :progress)

# Base folders
battleFolder = '/battle'
baseFolder = '/arena'
replaysFolder = '/arena/replays'

Dir.mkdir(battleFolder) unless File.exists?(battleFolder)
Dir.mkdir(replaysFolder) unless File.exists?(replaysFolder)

# Show main message
puts 'Welcome to the Bot League!'

if ARGV.length == 0
  while true
    value = prompt.select("Choose your destiny?") do |menu|
      menu.choice 'Fight'
      menu.choice 'Create a bot'
      menu.choice 'Exit'
    end

    if value == 'Exit'
      break
    elsif value == 'Create a bot'
      name = prompt.ask("What's your user in Github?", convert: :string)
      lang = prompt.select('Select the programming language of your bot:', AVAILABLE_LANGUAGES)
      lang = lang.downcase

      puts 'Creating your bot...'
      userFolder =  "#{baseFolder}/bots/#{name}"
      Dir.mkdir userFolder
      FileUtils.cp Dir.glob("/root/Halite-#{formatLang(lang)}-Starter-Package/MyBot.#{extensionByLang(lang)}"), userFolder
      FileUtils.mv "#{userFolder}/MyBot.#{extensionByLang(lang)}", "#{userFolder}/#{name}.#{extensionByLang(lang)}"

      config = {
        'lang' => lang.downcase,
        'run' => defaultRunCommandByLang(name, lang),
        'build' => defaultBuildCommandsByLang(name, lang)
      }

      # Create the config file
      File.open("#{userFolder}/config.yml", 'w') { |f| f.write(config.to_yaml) }

      puts 'Done...'
    else
      players = prompt.multi_select('Select players', current_players, echo: false)
      executeBattle(players, battleFolder, replaysFolder, cmd, progressCMD)
    end

    puts "\n"
  end
else
  executeBattle(ARGV, battleFolder, replaysFolder, cmd, progressCMD)

  puts "Generating result!"
  cmd.run("parser/parser.rb #{Dir.glob('replays/*.hlt').first}", chdir: baseFolder)
  puts "Finish"
end

puts 'See you soon!'
