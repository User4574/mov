0x00 - 0xEF  Memory Segment
0xF0 - 0xFF  Operations Segment

Address   Read    Write
0xF0      A       Set A
0xF1      B       Set B
0xF2      ¬A      NOP
0xF3      A | B   NOP
0xF4      A & B   NOP
0xF5      A ^ B   NOP
0xF6      A + B   NOP
0xF7      A - B   NOP
0xF8      A << B  NOP
0xF9      A >> B  NOP
0xFA      0       NOP
0xFB      Input   Output
0xFC      PC      Set PC if @a != 0
0xFD      PC      Set PC
0xFE      0       NOP
0xFF      0xFF    NOP

The machine will halt if the PC enters the Operations Segment.
All words are unsigned single 8-bit bytes.
