# D16 CPU
This is a simple(ish) 16 bit cpu formed in a collaboration between C-Elegans, flaviaut, and pmathbraniac.
The cpu is a load-store architecture, with variable length instructions (multiples of 16 bits) and 7 GP registers
The cpu is written in VHDL and is simulatable with GHDL.


##D16 Assembler
The included assembler is written in C, and uses bison and flex for parsing. It's not of the best quality, but it works.
It can be built on OS X by:
```
cd assembler
xcodebuild
```
and on linux by:
```
cd assembler/d16-asm
./configure
make
```
