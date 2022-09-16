require "yaml"


def col(b=0, color)
  if color != 0
    "\033[#{b};3#{color}m"   
  else
    "\033[0m" 
  end
end

def clear
  "\e[H\e[2J"
end

def title(header, border="-", a=3, b=7)
  puts "#{col(b)}" + ("#{border}" * header.size).center(86) + "#{col(0)}"
  puts "#{col(a)}" + header.center(86) + "#{col(0)}"
  puts "#{col(b)}" + ("#{border}" * header.size).center(86) + "#{col(0)}"
  puts "\n" * 3
end

def stop(b=0)
  puts "\n#{col(3)}<enter>#{col(0)}"
  w = gets.chomp
  w
end

def one_char
  normal_state = `stty -g`
  system "stty raw"
  one = STDIN.getc
  system "stty #{normal_state}"
  one.chomp
end
  
def path
  path =  Dir.pwd + "/" + $0
  tmp  = path.split("/")
  file = tmp.pop
  tmp.join("/") + "/"
end





def read_char
  begin
    # save previous state of stty
    old_state = `stty -g`
    # disable echoing and enable raw (not having to press enter)
    system "stty raw -echo"
    c = STDIN.getc.chr
    # gather next two characters of special keys
    if(c=="\e")
      extra_thread = Thread.new{
        c = c + STDIN.getc.chr
        c = c + STDIN.getc.chr
      }
      # wait just long enough for special keys to get swallowed
      extra_thread.join(0.001)
      # kill thread so not-so-long special keys don't wait on getc
      extra_thread.kill
    end
  rescue => ex
    puts "#{ex.class}: #{ex.message}"
    puts ex.backtrace
  ensure
    # restore previous state of stty
    system "stty #{old_state}"
  end
  return c
end

