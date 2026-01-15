.export fnv1a
.export fnv1a_hash

.data

fnv1a_initval:	.byte	$25, $23, $22, $84, $e4, $9c, $f2, $cb

.bss

fnv1a_hash:	.res	8
fnv1a_tmp:	.res	8

.code

fnv1a:
		sta	fnv1a_rd+1
		stx	fnv1a_rd+2
		ldx	#7
fnv1a_initloop:	lda	fnv1a_initval,x
		sta	fnv1a_hash,x
		dex
		bpl	fnv1a_initloop
fnv1a_rd:	lda	$ffff
		bne	fnv1a_mainloop
		rts
fnv1a_mainloop:	eor	fnv1a_hash
		sta	fnv1a_hash
		ldx	#7
fnv1a_tmploop:	lda	fnv1a_hash,x
		sta	fnv1a_tmp,x
		dex
		bpl	fnv1a_tmploop
		clc
		lda	fnv1a_tmp
		adc	fnv1a_hash+5
		sta	fnv1a_hash+5
		lda	fnv1a_tmp+1
		adc	fnv1a_hash+6
		sta	fnv1a_hash+6
		lda	fnv1a_tmp+2
		adc	fnv1a_hash+7
		sta	fnv1a_hash+7
		jsr	fnv1a_shift
		jsr	fnv1a_add
		jsr	fnv1a_shift
		jsr	fnv1a_shift
		jsr	fnv1a_shift
		jsr	fnv1a_add
		jsr	fnv1a_shift
		jsr	fnv1a_add
		jsr	fnv1a_shift
		jsr	fnv1a_shift
		jsr	fnv1a_add
		jsr	fnv1a_shift
		jsr	fnv1a_add
		inc	fnv1a_rd+1
		bne	fnv1a_next
		inc	fnv1a_rd+2
fnv1a_next:	jmp	fnv1a_rd
fnv1a_shift:	asl	fnv1a_tmp
		rol	fnv1a_tmp+1
		rol	fnv1a_tmp+2
		rol	fnv1a_tmp+3
		rol	fnv1a_tmp+4
		rol	fnv1a_tmp+5
		rol	fnv1a_tmp+6
		rol	fnv1a_tmp+7
		rts
fnv1a_add:	clc
		ldx	#$f8
fnv1a_addloop:	lda	fnv1a_tmp-$f8,x
		adc	fnv1a_hash-$f8,x
		sta	fnv1a_hash-$f8,x
		inx
		bne	fnv1a_addloop
		rts

