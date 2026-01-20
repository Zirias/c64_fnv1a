.export fnv1a
.exportzp fnv1a_hash

.data

fnv1a_initval:	.byte	$25, $23, $22, $84, $e4, $9c, $f2, $cb
fnv1a_steps:	.byte	$01, $02, $01, $03, $01
fnv1a_nsteps=	* - fnv1a_steps

.zeropage

fnv1a_hash:	.res	8
fnv1a_tmp:	.res	8

.code

fnv1a_done:	rts

fnv1a:
		sta	fnv1a_mainloop+1
		stx	fnv1a_mainloop+2
		ldx	#7
fnv1a_initloop:	lda	fnv1a_initval,x
		sta	fnv1a_hash,x
		dex
		bpl	fnv1a_initloop
fnv1a_mainloop:	lda	$ffff
		beq	fnv1a_done
		eor	fnv1a_hash
		sta	fnv1a_hash
		sta	fnv1a_tmp
		lda	fnv1a_hash+1
		sta	fnv1a_tmp+1
		lda	fnv1a_hash+2
		sta	fnv1a_tmp+2
		lda	fnv1a_hash+3
		sta	fnv1a_tmp+3
		lda	fnv1a_hash+4
		sta	fnv1a_tmp+4
		lda	fnv1a_hash+5
		sta	fnv1a_tmp+5
		clc
		adc	fnv1a_tmp
		sta	fnv1a_hash+5
		lda	fnv1a_hash+6
		sta	fnv1a_tmp+6
		adc	fnv1a_tmp+1
		sta	fnv1a_hash+6
		lda	fnv1a_hash+7
		sta	fnv1a_tmp+7
		adc	fnv1a_tmp+2
		sta	fnv1a_hash+7

		ldx	#fnv1a_nsteps-1
fnv1a_mult:	ldy	fnv1a_steps,x

fnv1a_shift:	asl	fnv1a_tmp
		rol	fnv1a_tmp+1
		rol	fnv1a_tmp+2
		rol	fnv1a_tmp+3
		rol	fnv1a_tmp+4
		rol	fnv1a_tmp+5
		rol	fnv1a_tmp+6
		rol	fnv1a_tmp+7
		dey
		bne	fnv1a_shift

		clc
		lda	fnv1a_tmp
		adc	fnv1a_hash
		sta	fnv1a_hash
		lda	fnv1a_tmp+1
		adc	fnv1a_hash+1
		sta	fnv1a_hash+1
		lda	fnv1a_tmp+2
		adc	fnv1a_hash+2
		sta	fnv1a_hash+2
		lda	fnv1a_tmp+3
		adc	fnv1a_hash+3
		sta	fnv1a_hash+3
		lda	fnv1a_tmp+4
		adc	fnv1a_hash+4
		sta	fnv1a_hash+4
		lda	fnv1a_tmp+5
		adc	fnv1a_hash+5
		sta	fnv1a_hash+5
		lda	fnv1a_tmp+6
		adc	fnv1a_hash+6
		sta	fnv1a_hash+6
		lda	fnv1a_tmp+7
		adc	fnv1a_hash+7
		sta	fnv1a_hash+7
		dex
		bpl	fnv1a_mult

		inc	fnv1a_mainloop+1
		bne	fnv1a_next
		inc	fnv1a_mainloop+2
fnv1a_next:	jmp	fnv1a_mainloop

