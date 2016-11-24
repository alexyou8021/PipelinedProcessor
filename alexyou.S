	.global start
start:
	li 3, 'a'
	ld 4,8(0)
.quad 0x7ffffffffffffffa
	li 5,5
	mr 0, 0
	sc
	addo. 4, 5, 4
	bc 12, 3, wrong
p1:
	li 3, 'b'
	mr 0, 0
	sc
	add. 4, 5, 4
	bc 12, 3, wrong
p2:
	li 3,'c'
	mr 0, 0
	sc
	ld 4, 8(0)
	add 4, 4, 5
	addo. 4, 5, 4
	bc 12, 3, p3
	ba wrong
p3:
	li 3,'d'
	mr 0, 0
	sc
.int 0b01000100000000000000000000000000
	ld 4, 8(0)
	addo 4, 5, 4
	bc 12, 3, p4
	ba wrong	
p4:
	li 3, 'e'
	mr 0, 0
	sc
p5:
	li 3, 'f'
	mr 0, 0
	.int 0xe863009
	.int 0xe860009
	sc
p6:	
	li 3, 'g'
	mr 0, 0
	sc
	std 3, num1(0)
num1:
	.quad 
p7:	
	ld 3, num1(0)
	nop
	addi 3, 3, 1
	sc
	ld 3, 200(0)
	std 3, 192(0)
p8:
	ba wrong
	ba wrong
	ba end
wrong:
	li 3, 'w'
	mr 0, 0
	sc
	li 0, 1
	sc
end:
	li 3, 'S'
	mr 0, 0
	sc
	mr 0, 0
	li 0, 1
	sc
extra:
	li 3, 'E'
	mr 0, 0
	li 0, 2
	sc

