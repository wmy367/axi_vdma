
$old = '______________________________________________
_______  ___   ___          ___   __   _    _
_______ |     |   | |\  /| |___  |  \  |   /_\
_______ |___  |___| | \/ | |___  |__/  |  /   \
_______________________________________________'

$new_str= '______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________'


$cpath = File.dirname(File.expand_path(__FILE__))

def search_file(path)
    fp = Dir.entries(path) - %w{. ..}
    fp.each do |item|
        cf = File.join(path,item)

        if item =~  /(?:\.v|\.sv)/i
            str = File.open(cf,'r'){|f| f.read}
            next unless str.include? $old
            str.sub!($old,$new_str)
            File.open(cf,'w') {|f| f.puts str}
        elsif File.directory? cf
            search_file cf
        end
    end
end

search_file($cpath)
