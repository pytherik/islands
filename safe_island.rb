#!/usr/bin/env ruby
# coding: utf-8
require_relative "helpers"

class Guess
  def initialize(spieler, startx, starty)
    @@spieler_start = [spieler, startx, starty]   
    if defined?(@@alle_spieler)
      @@alle_spieler << @@spieler_start
    else
      @@alle_spieler = []
      @@alle_spieler << @@spieler_start
    end
  end
end



class Play < Guess
  
  def initialize(posx, posy)
    @spielfeld = []
    @showtime  = []
    @kill      = [". "]
    @schweif = [[posx, posy]]
    @ranking = []
    @posx = posx
    @posy = posy
    40.times do  
      @spielfeld << (". ," * 40).split(",")
    end
    @spielfeld
    40.times do |i|
      40.times do |j|
        @showtime << [i, j]
      end
      @total = @showtime.size
    end
    @@alle_spieler.each do |start|
      @spielfeld[start[1]][start[2]] = "#{col(3)}#{start[0][0..1].capitalize}#{col(0)}"
      @kill << "#{col(3)}#{start[0][0..1].capitalize}#{col(0)}"
    end
    show(@posx, @posy)
  end
  
  def show(posx,posy,aus=false)
    if !aus
      @@alle_spieler.each do |tot|
        endstand = @total - @showtime.size
        if [tot[1], tot[2]] == [posx, posy]
          tot[1] = "#{endstand}"
          @ranking << tot
        end
      end
      begin
        sleep(0.05)
        puts clear
        @spielfeld[posx][posy] = "#{col(1)}̣Ø #{col(0)}"
        @spielfeld.each do |line|
          puts line.join
        end
        @@alle_spieler.each do |points|
          spieler = points[0].capitalize.ljust(12, " ") 
          if points[1].class == String
            puts "#{col(3)}#{spieler.capitalize}#{col(1)} gefressen - #{points[1].rjust(4, " ")}#{col(0)} Punkte!".center(90)
          else
            puts "#{col(3)}#{spieler}   #{col(0)}hat #{col(2)}#{(@total - @showtime.size).to_s.rjust(4, " ")}#{col(0)} Punkte ...".center(92)
          end
        end
      rescue Interrupt
        puts "\n\n#{col(1)}schlange gestoppt\n\n#{col(0)}".upcase
        exit
      end

      @schweif.each do |sw|
        @spielfeld[sw[0]][sw[1]] = "#{col(1)}° #{col(0)}"
      end
      if @schweif.size > 15 && @showtime.size > 15
        @schweif << [posx, posy]
        @spielfeld[@schweif[0][0]][@schweif[0][1]] = "  "
        @schweif.delete_at(0)
      else
        @schweif << [posx,posy]
      end
      
      move(@posx, @posy)
    else
      @spielfeld[posx][posy] = "#{col(1)}o #{col(0)}"
      @spielfeld.each do |line|
        puts line.join
      end
      puts clear
      @spielfeld[posx][posy] = "  "
      @spielfeld.each do |line|
        puts line.join
      end
      sleep(0.04)
    end      
  end


  
  def move(posx, posy)
    dir = ["0", "1", "2", "3", "4", "5", "6", "7"]
    if (posx - 1 < 0 || posy + 1 > 39) || !@kill.include?(@spielfeld[posx-1][posy+1]) 
      dir.delete("0")
    end
    if posy + 1 > 39 || !@kill.include?(@spielfeld[posx][posy+1])   
      dir.delete("1")
    end
    if (posx + 1 > 39 || posy + 1 > 39) || !@kill.include?(@spielfeld[posx+1][posy+1]) 
      dir.delete("2")
    end
    if posx + 1 > 39 || !@kill.include?(@spielfeld[posx+1][posy]) 
      dir.delete("3")
    end
    if (posx + 1 > 39 || posy - 1 < 0) || !@kill.include?(@spielfeld[posx+1][posy-1]) 
      dir.delete("4")
    end
    if posy - 1 < 0 || !@kill.include?(@spielfeld[posx][posy-1])  
      dir.delete("5")
    end
    if (posx - 1 < 0 || posy - 1 < 0) || !@kill.include?(@spielfeld[posx-1][posy-1]) 
      dir.delete("6")
    end
    if posx - 1 < 0 || !@kill.include?(@spielfeld[posx-1][posy]) 
      dir.delete("7")
    end
    if dir.empty? && @showtime.empty?
      @schweif.each do |weg|
        show(weg[0], weg[1], true)
      end



      puts clear
      title("S i e g e r t r e p p c h e n".upcase)
      i = 0
      @ranking.each do |spieler|
        rang = [2, 3, 3, 7, "GOLD", "SILBER", "BRONZE", "Rest #{i}"]
        j = i
        if i > 3
          j = 3
        end
        puts "#{col(rang[j])}" + "#{rang[4+j].ljust(10," ")}: #{spieler[0].capitalize.ljust(10, " ")} -- #{spieler[1].rjust(4," ")} Punkte!".center(86) + "#{col(0)}"
        i += 1
      end
      puts "\n" * 3
      title("G A M E   O V E R", "x", 1, 1)
      @@alle_spieler = []
      nochmal
    elsif dir.empty?
      start = @showtime[rand(@showtime.size)]
      @posx = start[0]
      @posy = start[1]
      @showtime.delete(start)
      show(@posx, @posy)
    else
      direction = dir[rand(dir.size)]
      case direction
          
      when "0"
        
        @posx -= 1
        @posy += 1
      when "1"
        @posy += 1
      when "2"
        @posx += 1
        @posy += 1
      when "3"
        @posx += 1
      when "4"
        @posx += 1
        @posy -= 1
      when "5"
        @posy -= 1
      when "6"
        @posx -= 1
        @posy -= 1
      when "7"
        
        @posx -= 1
      end
      @showtime.delete([@posx, @posy])
      show(@posx, @posy)
      
    end
    
  end
end

def spieler(player=1, name=false, hallo="Hallo ")
  while true
    puts clear
    title("Die 'Sichere Insel'")
    if !name
      print "\n\n\n#{col(3)}Spieler #{player}#{col(0)}, gib deinen Namen ein ››#{col(3)} "
      name = gets.chomp
      puts "#{col(0)}"
      if name == ""
        puts "\nAbbruch ‹enter›"
        if gets.chomp == ""
          if player == 1
            exit
          else
            Play.new(rand(40), rand(40))
          end
        else
          spieler(player)
        end
      end
    end
    puts "\n#{col(3)}#{hallo}#{name.capitalize}#{col(0)}! Wo befindet sich deine 'Sichere Insel' ?"
    print"\n\n\n#{col(3)}X - Achse #{col(0)}‹1› - ‹40› ››#{col(3)} "
    x = gets.to_i
    puts "#{col(0)}"
    if x < 1 || x > 40
      spieler(player, name, "1 - 40 ")
    end
    print "#{col(3)}Y - Achse#{col(0)} ‹1› - ‹40› ››#{col(3)} "
    y = gets.to_i
    puts "#{col(0)}"
    if y < 1 || y > 40
      spieler(player, name, "Also nochmal, ")
    end
    Guess.new(name, 40-y, x-1)
    print "\nweitere Spieler (j/n) ›› "
    if !["j", "y", "ja", "yes", ""].include?(one_char)
      Play.new(rand(40), rand(40))
    else
      player += 1
      name = false
      hallo = "Tachchen "
    end
  end
end

def nochmal
  puts "\n" * 3
  puts "#{col(3)}" + "Nochmal ?".center(86) + "#{col(0)}"
  puts "‹j/n›".center(86)
  if one_char == "j"
    puts "#{col(0)}"
    spieler
  else
    puts "#{col(0)}"
    exit
  end
end
 
spieler
