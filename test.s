.import fnv1a
.import fnv1a_hash

.segment "BHDR"

		.word	$0801
		.word	hdrend
		.word	2026
		.byte	$9e, "2061", 0
hdrend:		.word	0

.bss

input:		.res	$200

.segment "MAINCODE"

main:		lda	#<input
		sta	inputstore+1
		lda	#>input
		sta	inputstore+2
inputloop:	jsr	$ffcf
		cmp	#$d
		bne	inputstore
		lda	#0
inputstore:	sta	$ffff
		beq	tryhash
		inc	inputstore+1
		bne	inputloop
		inc	inputstore+2
		bne	inputloop
tryhash:	lda	input
		bne	dohash
		rts
dohash:		lda	#<input
		ldx	#>input
		jsr	fnv1a
		lda	#$d
		jsr	$ffd2
		ldx	#7
hashoutloop:	lda	fnv1a_hash,x
		lsr
		lsr
		lsr
		lsr
		ora	#$30
		cmp	#$3a
		bcc	hashout1
		adc	#6
hashout1:	jsr	$ffd2
		lda	fnv1a_hash,x
		and	#$f
		ora	#$30
		cmp	#$3a
		bcc	hashout2
		adc	#6
hashout2:	jsr	$ffd2
		dex
		bpl	hashoutloop
		lda	#$d
		jsr	$ffd2
		jmp	main
	
