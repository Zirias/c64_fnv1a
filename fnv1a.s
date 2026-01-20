.export fnv1a
.exportzp fnv1a_hash

.data
		; Initial hash value: 0xcbf29ce484222325
fnv1a_initval:	.byte	$25, $23, $22, $84, $e4, $9c, $f2, $cb
FNV1A_SIZE=	* - fnv1a_initval

		; 64bit FNV-1a prime is 0x00000100000001b3
		; Table of the number of necessary left shifts to multiply by
		; just 0x1b3, in backwards order for simple x-indexed reading:
fnv1a_steps:	.byte	$01, $02, $01, $03, $01
FNV1A_NSTEPS=	* - fnv1a_steps
		; The table excludes the single bit position needed to multiply
		; by 0x0000010000000000, because it's an outlier (which would
		; require *excessive* bit shifting) AND happens to have a
		; position that's a multiple of 8, so it can be special-cased
		; without executing any actual bit shifts for our optimized
		; implementation.

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
;	clobbers:		A, X, Y, SR (all flags)
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
		.repeat	5, B
		lda	fnv1a_hash+1+B		; copy the next 5 bytes
		sta	fnv1a_tmp+1+B		; to temp buffer
		.endrep
		clc				; special case multiplication
		adc	fnv1a_tmp		; by 0x0000010000000000 ->
		sta	fnv1a_hash+5		; add value shifted by 5 bytes
		.repeat 2, B
		lda	fnv1a_hash+6+B		; copy and add remaining
		sta	fnv1a_tmp+6+B		; two bytes
		adc	fnv1a_tmp+1+B
		sta	fnv1a_hash+6+B
		.endrep

		ldx	#FNV1A_NSTEPS-1
fnv1a_mult:	ldy	fnv1a_steps,x		; multiply by 0x1b3 using table

fnv1a_shift:	asl	fnv1a_tmp		; shift temp buffer left
		.repeat FNV1A_SIZE-1, B
		rol	fnv1a_tmp+1+B
		.endrep
		dey
		bne	fnv1a_shift		; repeat as needed

		clc				; add temp buffer to hash value
		.repeat FNV1A_SIZE, B
		lda	fnv1a_tmp+B
		adc	fnv1a_hash+B
		sta	fnv1a_hash+B
		.endrep
		dex
		bpl	fnv1a_mult		; repeat until end of table

		inc	fnv1a_mainloop+1	; update input pointer to
		bne	fnv1a_next		; next input byte
		inc	fnv1a_mainloop+2
fnv1a_next:	jmp	fnv1a_mainloop		; and repeat

