#!/usr/bin/ruby -w
## subtitle_offset : shift subtitle index
## --------------------------------------
##
##   usage: subtitle_offset.rb [--kick-tags] your_srt.srt seconds_to_shift
## 
##   This will shift every subtitle by seconds_to_shift and produce a
##   your_srt.srt.shifted file.
##
##   If you add --kick-tags option, every TAG in the file will be removed.
##
## By Thomas "ook!" Lecavelier - http://thomas.lecavelier.name
##
## In memoriam Capucine, the most fabulous rabbit that I met (1996-09-01 - 2009-07-26)
## 2010-07-26: one year later, it's still so painful, Capucine…
# Under the WTFPL - http://sam.zoy.org/wtfpl/

TIMESTAMP_RX = /(\d{2}:\d{2}:\d{2})/

def usage
  # yeah, that's a complet robbery from sunny's code: http://github.com/sunny/mariokartwiit/
  puts open(__FILE__).read.grep(/^## ?/).join.gsub(/^## ?/, '')  
end

def check_args(args)
  $kick_tags = '--kick-tags' == args.delete('--kick-tags')
  args.size >= 2 && File.exist?($*[0])
end

def pad(int, pad = 2)
  int < 10 ? "0#{int.to_s}" : int.to_s
end

def kick_tag(line)
  line.gsub(/\{[^\}]+\}/, '')
end

def shift(time_index, shift_seconds = 40)
  return '!!:!!:!!' unless time_index

  elems = time_index.split(':')
  elems.each_with_index { |d, i| elems[i] = d.to_i }
  elems[-1] += shift_seconds
  if 59 < elems[-1]
    elems[-1] -= 60
    elems[-2] +=  1
  end
  if  0 > elems[-1]
    elems[-1] += 60
    elems[-2] -=  1
  end
  if 59 < elems[-2]
    elems[-2] -= 60
    elems[-3] +=  1
  end
  if  0 > elems[-2]
    elems[-2] += 60
    elems[-3] -=  1
  end
  if 23 < elems[-3]
    elems[-3] -= 24
  end
  if  0 > elems[-3]
    #elems[-3] += 24
    return time_index # don't try to mess with the index!
  end
  
  "#{pad(elems[0])}:#{pad(elems[1])}:#{pad(elems[2])}"
end

args = $*

unless check_args(args)
  usage
  exit 42
end
File.open($*[0], 'r') do |orig|
  out = File.open("#{$*[0]}.shifted", 'w')
  orig.each do |line|
    if line =~ TIMESTAMP_RX

      orig_from, orig_to = $1, $2
      out << line.gsub(TIMESTAMP_RX) { |m| "#{shift(m, $*[1].to_i)}" } 
    else
      out << ($kick_tags ? kick_tag(line) : line)
    end
  end
  out.close
end


