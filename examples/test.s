mov 1, 0x02
mov 03, pc
mov a, 0b10100101
mov b, zero
nop
in a
out a
not 5, 6
or 7, 8, 9
and 7, 8, 9
xor 7, 8, 9
add 7, 8, 9
sub 7, 8, 9
shl 7, 8, 9
shr 7, 8, 9


jmp 0xb0
jnz 0xb1, a

@0x40
out 0xa0
out 0xa1
out 0xa2
out 0xa3
hlt
mov pc, ones
out 0xa4

@0xa0
&72;&101;&108;&108;&111
@0xb0;&0x40;&0x42
