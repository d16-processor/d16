nop
start:
mov r0,start
ld r1,[r0+start]
st [end],r3
jmp.ne start
end:

