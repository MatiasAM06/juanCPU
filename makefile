riscv.txt:	riscv
	vvp riscv>>riscv.tmp
	mv riscv.tmp riscv.txt

riscv: ./src/* riscv.v ./build/program.hex riscvTb.v
	iverilog -g2012 -o ./riscv ./riscvTb.v ./riscv.v ./src/* 

./build/program.hex: ./build/program.elf
	~/Public/riscv/bin/riscv32-unknown-elf-objcopy -O verilog --verilog-data-width=4 ./build/program.elf ./build/program.hex

./build/program.elf:
	~/Public/riscv/bin/riscv32-unknown-elf-gcc -O0 -o ./build/program.elf -Wa,-march=rv32i -mabi=ilp32 -nostdlib -nostartfiles -static -Wl,-Ttext=0x00000000 ./build/pm_ev_grupo.c
	~/Public/riscv/bin/riscv32-unknown-elf-objdump -D ./build/program.elf > objDump.txt