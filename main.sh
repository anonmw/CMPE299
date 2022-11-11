rm main main_tb.vcd;
iverilog -o main main.v main_tb.v dcache.v icache.v regfile.v alu.v;
vvp main;
gtkwave main_tb.vcd &
