.export fnv1a
.exportzp fnv1a_hash

.data
		; Initial hash value: 0xcbf29ce484222325
fnv1a_initval:	.byte	$25, $23, $22, $84, $e4, $9c, $f2, $cb
FNV1A_SIZE=	* - fnv1a_initval

.zeropage

fnv1a_hash:	.res	FNV1A_SIZE	; Buffer for the 64bit hash value
fnv1a_tmp:	.res	FNV1A_SIZE	; Temporary buffer used for shift/add

.code

fnv1a_done:	rts	; routine exit, branches here when done hashing

; fnv1a: Calculate 64bit FNV-1A hash for a given NUL-terminated input.
;
;	A/X (in)		pointer to NUL-terminated input
;	fnv1a_hash (ZP,out)	64bit hash in little endian
;
;	clobbers:		A, X, SR (all flags)
;
fnv1a:
		sta	fnv1a_mainloop+1	; initialize pointer to
		stx	fnv1a_mainloop+2	; input
		ldx	#FNV1A_SIZE-1
fnv1a_initloop:	lda	fnv1a_initval,x		; initialize hash value
		sta	fnv1a_hash,x
		dex
		bpl	fnv1a_initloop

fnv1a_mainloop:	lda	$ffff			; read next input byte
		beq	fnv1a_done		; stop on NUL
		eor	fnv1a_hash		; xor with current hash
		sta	fnv1a_hash		; write lowest byte to
		sta	fnv1a_tmp		; both buffers

		; FNV-1a now requires a multiplication by the prime number
		; 0x00000100000001b3. We first multiply by 0x0000010000000001
		; which is a nice special case. The most significant 1 bit in
		; that factor is an "outlier" which would require an excessive
		; amount of bit-shifting, but happens to be placed at a
		; multiple of 8, so it can be done instead without *any*
		; shifting by adding the lowest 3 bytes to the topmost 3 bytes.

		.repeat	5, B
		lda	fnv1a_hash+1+B		; copy the next 5 bytes
		sta	fnv1a_tmp+1+B		; to temp buffer
		.endrep
		clc				; special case multiplication
		adc	fnv1a_tmp		; by 0x0000010000000001 ->
		sta	fnv1a_hash+5		; add value shifted by 5 bytes
		.repeat 2, B
		lda	fnv1a_hash+6+B		; copy and add remaining
		sta	fnv1a_tmp+6+B		; two bytes
		adc	fnv1a_tmp+1+B
		sta	fnv1a_hash+6+B
		.endrep

		; Now we just need to multiply by another 8bit value for
		; the bits #1 to #8 not considered yet.

		lda	#$d9			; factor (0x1b3 >> 1)

fnv1a_mult:	asl	fnv1a_tmp		; shift temp buffer left
		.repeat FNV1A_SIZE-1, B
		rol	fnv1a_tmp+1+B
		.endrep
		lsr	a			; check factor afterwards,
		bcc	fnv1a_mult		; accounting for the 1bit shift
		tax				; save factor while adding

		clc				; add shifted temp buffer
		.repeat FNV1A_SIZE, B
		lda	fnv1a_tmp+B
		adc	fnv1a_hash+B
		sta	fnv1a_hash+B
		.endrep
		txa				; restore factor
		bne	fnv1a_mult		; repeat until factor is 0

		inc	fnv1a_mainloop+1	; update input pointer to
		bne	fnv1a_next		; next input byte
		inc	fnv1a_mainloop+2
fnv1a_next:	jmp	fnv1a_mainloop		; and repeat

