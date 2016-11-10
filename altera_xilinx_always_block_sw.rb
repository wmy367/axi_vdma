file_root_path = File.dirname(File.expand_path(__FILE__))
# file_name = "/home/young/work/public_atom_modules/latency.v"
$mode = "xilinx"
def sw_always(to="xilinx",file_name)
    all_str = File.open(file_name).read
    altera_rep_0 = /always\s*@\s*\(\s*posedge\s+(?<clock_name>\w*(?i:clock|clk)\w*)\s*(?:,|or)\s*negedge\s+(?<rst_name>\w*(?:rst|reset)\w*)\s*\)/
    xilinx_rep   = /always\s*@\s*\(posedge\s+(?<clock_name>\w*(?i:clock|clk)\w*)\s*\/\*.+\*\/\s*\)/
    # altera_rep_0 = /always\s*@\s*\(\s*posedge\s+(?<clock_name>\s*(?i:clock|clk)\s*)\t*(?:,|or)\s*/
    if(to.downcase=="xilinx")
        all_str.gsub!(altera_rep_0) do |s|
            "always@(posedge #{$~["clock_name"]}/*,negedge #{$~["rst_name"]}*/)"
        end
    elsif to.downcase=="altera"
        all_str.gsub!(xilinx_rep) do |s|
            s.sub('/*','').sub('*/','')
        end
    end

    # if xilinx_rep.match("always@(posedge clk/*,negedge rst_n*/)")
    #     puts "rep OK"
    #     puts $~["clock_name"]
    # else
    #     puts "rep ERR"
    # end
    File.open(file_name,"w"){|f| f.print(all_str)}
end

def look_for_v(path)
    paths = Dir::entries(path) - %w{. ..}

    paths.each do |pf|
        full_name = File.join(path,pf)
        if(File.directory? full_name)
            look_for_v(full_name)
        elsif(File.file? full_name)
            if(/\.v$/i =~ pf || /\.sv$/i =~ pf)
                sw_always($mode,full_name)
            end
        end
    end
end

if ARGV.empty?
    puts "Pleace switch to xilinx or altera"
elsif ARGV[0] == "xilinx"
    $mode = "xilinx"
    look_for_v(file_root_path)
elsif ARGV[0] == "altera"
    $mode = "altera"
    look_for_v(file_root_path)
else
    puts "error ARVG"
end


# sw_always("xilinx",file_name)
# sw_always("altera",file_name)
