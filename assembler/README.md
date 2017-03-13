#D16 Assembler

This is the recommended assembler for use with the D16 processor

## Installation

The assembler depends on Glib, flex, and bison. Please install them before continuing

```
mkdir build && cd build
cmake ..
make -j
make install 
```

## Usage

`d16 input.d16 -o output.o`

`-h`: display assembler help

`-b`: assemble to flat binary instead of a.out object file

`-o`: set output file (defaults to `a.out`)

By default the assembler outputs files in a.out object file format which can then be linked with the d16 linker (d16-ld)

## Syntax

* Syntax is similar to ARM assembly, using intel style operand ordering. 
* Registers, constants, or register + constant (in that order) can appear inside brackets
* Size suffixes or condition codes are placed after the opcode following a dot (Ex. `jmp.ne 0`)
* Labels can contain letters or underscore for the first character, then letters, numbers and underscores afterwards


Example syntax:
```assembly
start:
	mov r0, 2          
	add r0, r1 
	mov r3, start       ; can use labels as constant
	ld.b r1, [r0+data]  ; displacement (reg+imm)
	st [r0], r3         ; register indirect 
	ld r0, [data]       ; immediate
	jmp.eq start        ; conditional jump to label
data:
	.db 5
	.db 7
	.db 8
```

## Labels

* Labels can be either local, visible to the whole file, or globally exported.
* There are 10 different local labels that can be used (0-9). Accessing a local label requires you to add a `b` or `f` to the label number depending on whether the jump should go backwards or forwards.
* Labels will only be made global if preceeded by the `.global` directive (Local labels cannot be global)

Examples:
```assembly
;Local labels
	jmp 1f ; jumps to the next location of '1:'
1:
	jmp 1b ; jumps to the previous location of '1:'

;Normal (File local labels)
labelName:
	jmp labelName 
	
;Global labels
.global
anotherLabelName:
	jmp anotherLabelName
```

