mov r0,3
loop:
sub r0,#1
jmp.ne loop
mov r0,end
jmp r0
end: