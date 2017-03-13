# D16 CPU
This is a simple(ish) 16 bit CPU formed in a collaboration between C-Elegans and flaviut.
The CPU is a load-store architecture, with variable length instructions (multiples of 16 bits) and 7 GP registers.
The CPU is written in Verilog and is synthesizable for Altera FPGAs (Currently tested on a DE0-Nano).


## D16 Assembler
The included assembler is written in C, and uses bison and flex for parsing. It's not of the best quality, but it works.
 
Dependencies:
```
flex bison glib-2.0
```

It can be built by:

```
cd assembler
mkdir build
cd build
cmake ..
make 
./d16-main/d16 <file> <output>
```

### Usage

`d16 input.d16 -o output.o`

`-h`: display assembler help

`-b`: assemble to flat binary instead of a.out object file

`-o`: set output file (defaults to `a.out`)

By default the assembler outputs files in a.out object file format which can then be linked with the d16 linker (d16-ld)

# CPU 
A general layout of the CPU is provided here, this is subject to change during the project


![alt text](https://raw.githubusercontent.com/C-Elegans/d16/master/D16%20Cpu%20Diagram.png "D16 CPU Diagram")


The CPU's execution cycle takes 5 cycles for most instructions, 6 cycles for memory instructions, and 7 for jump instructions.


![alt text](https://raw.githubusercontent.com/C-Elegans/d16/master/CPU%20Execution.png "D16 Execution Diagram")


## Module testbenches
Most modules have a testbench associated to verify the functionaity of the module. However, most testbenches do not include asserts and cannot be used as automated verification that the module is functioning correctly. To run testbenches, it is necessary to install [vbuild](https://github.com/C_Elegans/vbuild), my verilog build helper and [icarus](http://iverilog.icarus.com) the verilog simulator.


```
git clone https://github.com/C_Elegans/vbuild
cd vbuild
sudo python setup.py install --install-scripts /usr/local/bin #or wherever else you want the tool installed
```

Once vbuild is installed, to run a testbench, simply run `vbuild test testbench_tb.v` and open `dump.vcd` to see the output.


## Formal Verification
Several modules also contain SystemVerilog Asserts for use in formal verification. To run formal verificaiton on a module, first install [yosys](https://github.com/cliffordwolf/yosys) and a SMT solver such as [z3](https://github.com/Z3Prover/z3) or [yices](http://yices.csl.sri.com). Formal verification can then be run by entering `vbuild smt2 module.v solver` or `vbuild formal module.v`. To formally verify all applicable modules, run `./run_formal.sh`.
