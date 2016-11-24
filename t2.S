.text
.global start
start:
	# check all registers are 0
	mr 3, 0
	bl printn
	mr 3, 1
	bl printn
	mr 3, 2
	bl printn
	mr 3, 4
	bl printn
	mr 3, 5
	bl printn
	mr 3, 6
	bl printn
	mr 3, 7
	bl printn
	mr 3, 8
	bl printn
	mr 3, 9
	bl printn
	mr 3, 10
	bl printn
	mr 3, 11
	bl printn
	mr 3, 12
	bl printn
	mr 3, 13
	bl printn
	mr 3, 14
	bl printn
	mr 3, 15
	bl printn
	mr 3, 16
	bl printn
	mr 3, 17
	bl printn
	mr 3, 18
	bl printn
	mr 3, 19
	bl printn
	mr 3, 20
	bl printn
	mr 3, 21
	bl printn
	mr 3, 22
	bl printn
	mr 3, 23
	bl printn
	mr 3, 24
	bl printn
	mr 3, 25
	bl printn
	mr 3, 26
	bl printn
	mr 3, 27
	bl printn
	mr 3, 28
	bl printn
	mr 3, 29
	bl printn
	mr 3, 30
	bl printn
	mr 3, 31
	bl printn

	# test noops
	.int 0x0
	.int 0x001231341

	# test invalid ldu
	.int 0x7D494051
	bl printn
	.int 0x7D494429
	bl printn


	# ignore normal ld, check sign extension
	li 1, maxValue-start
	ld 3, -8(1)	
	bl printn

	# check ldu loading
	ldu 3, -8(1)
	bl printn

	mr 3, 1
	bl printn

	li 1, 1
	li 2, 1

	add. 3, 2, 1
	bl printn

	# check weird branching on cr/ctr (ctr should be 0 before instruction, and -1 after
	# this will not branch, but will set lr)
	bdnzt 1, branch
	b uhoh

branchBack:
	# now test xer's SO bit
	li 1, maxValue
	ld 2, 0(1)
	li 4, 1

	add. 3, 2, 4
	bl printn

	# shouldn't set summary bit, so no branching
	bso uhoh

	addo. 3, 2, 4
	bl printn

	bns uhoh

	li 3, 'B'
	bl printc

	# branch to uhoh to exit
	b store_test

branch:
	li 3, 'A'
	bl printc
	b branchBack

store_test:
	li 4, 20
	li 5, -20
	std 4, storage(0)
	nop
	ld 3, storage(0)
	add. 4, 3, 5
	bne uhoh

	li 3, 'S'
	bl printc
	b store_test2

#ADD MORE STORES TESTS
store_test2:
	li 0, 2
	li 4, 0
	li 3, 0x1 
	std 4, poop(0)

	.align 3
poop:
	sc 
	nop
	li 3, 0x0
	sc

move_to_lr_check1:
	li 4, lr_check1
	mtlr 4
	blr
	li 3, 'F'
	bl printc
	b uhoh

lr_check1:
	li 3, 'L'
	bl printc
####################Test mtlr followed by mflr to make sure they use the updated, stored value instead of the temp, current thing
#the same can be done for each of the mfsprs (use move to followed by move from)

move_to_from_ctr_check1:
	mfctr 3
	bl printn
	li 4, 0x1234
	mtctr 4
	mfctr 3
	bl printn

move_to_from_xer_check1:
	mfxer 3
	bl printn
	li 4, 0x1234
	mtxer 4
	mfxer 3
	bl printn

#Each of the check2 tests move from the 
lr_check2:
	li 5, 0x0
	mtlr 5
	li 4, 0x5678
	mtlr 4
	mflr 6
	add. 7, 6, 5 
	beq uhoh
	li 3, 'L'
	bl printc

xer_check2:
	li 5, 0x0
	mtxer 5
	li 4, 0x5678
	mtxer 4
	mfxer 6
	add. 7, 6, 5 
	beq uhoh
	li 3, 'X'
	bl printc

ctr_check2:
	li 5, 0x0
	mtctr 5
	li 4, 0x5678
	mtctr 4
	mfctr 6
	add. 7, 6, 5 
	beq uhoh
	li 3, 'T'
	bl printc

#TODO implement other tests
#Set all the relevant CR bits to 1, and then branch based on all of them (Should all branch)
move_to_cr_check_step0:
	li 4, 0xFFFFFFFFFFFFFFFF
	mtcrf 0xFF, 4 #at this point cr should be all 1's
	beq move_to_cr_check_step1
	b uhoh

move_to_cr_check_step1:
	blt move_to_cr_check_step2
	b uhoh

move_to_cr_check_step2:
	bgt move_to_cr_check_step3
	b uhoh

move_to_cr_check_step3:
	bso move_to_cr_check_final
	b uhoh

move_to_cr_check_final:
	li 3, 'C'
	bl printc
	b uhoh

uhoh:
	li 0, 1
	sc


printc:
	li 0, 0
	sc
	blr

printn:
	li 0, 2
	sc
	blr

.align 3
storage: .quad 0
storage2: .quad 0
 

.align 3
ten: .quad 10
maxValue: .quad 0x7FFFFFFFFFFFFFFF
minValue: .quad 0xFFFFFFFFFFFFFFFF

