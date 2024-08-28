	.cpu cortex-m33
	.eabi_attribute 27, 1
	.eabi_attribute 28, 1
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 1
	.eabi_attribute 18, 4
	.text
	.comm	bouncer_state,4,4
	.global	signals
	.section	.data.signals,"aw"
	.align	2
	.type	signals, %object
	.size	signals, 14
signals:
	.ascii	"\001\001\000\002\003\000\000\001\003\003\001\002\002"
	.ascii	"\000"
	.global	sig_idx
	.section	.bss.sig_idx,"aw",%nobits
	.align	2
	.type	sig_idx, %object
	.size	sig_idx, 4
sig_idx:
	.space	4
	.global	DEBOUNCED_STATE
	.section	.rodata.DEBOUNCED_STATE,"a"
	.type	DEBOUNCED_STATE, %object
	.size	DEBOUNCED_STATE, 1
DEBOUNCED_STATE:
	.byte	1
	.global	UNSTABLE_STATE
	.section	.rodata.UNSTABLE_STATE,"a"
	.type	UNSTABLE_STATE, %object
	.size	UNSTABLE_STATE, 1
UNSTABLE_STATE:
	.byte	2
	.global	CHANGED_STATE
	.section	.rodata.CHANGED_STATE,"a"
	.type	CHANGED_STATE, %object
	.size	CHANGED_STATE, 1
CHANGED_STATE:
	.byte	4
	.section	.text.setStateFlag,"ax",%progbits
	.align	1
	.global	setStateFlag
	.arch armv8-m.main
	.arch_extension dsp
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	setStateFlag, %function
setStateFlag:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	mov	r3, r0
	strb	r3, [r7, #7]
	ldrb	r2, [r7, #7]	@ zero_extendqisi2
	ldr	r3, .L2
	ldr	r3, [r3]
	orrs	r3, r3, r2
	ldr	r2, .L2
	str	r3, [r2]
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L3:
	.align	2
.L2:
	.word	bouncer_state
	.size	setStateFlag, .-setStateFlag
	.section	.text.unsetStateFlag,"ax",%progbits
	.align	1
	.global	unsetStateFlag
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	unsetStateFlag, %function
unsetStateFlag:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	mov	r3, r0
	strb	r3, [r7, #7]
	ldrb	r3, [r7, #7]	@ zero_extendqisi2
	mvns	r3, r3
	mov	r2, r3
	ldr	r3, .L5
	ldr	r3, [r3]
	ands	r3, r3, r2
	ldr	r2, .L5
	str	r3, [r2]
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L6:
	.align	2
.L5:
	.word	bouncer_state
	.size	unsetStateFlag, .-unsetStateFlag
	.section	.text.toggleStateFlag,"ax",%progbits
	.align	1
	.global	toggleStateFlag
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	toggleStateFlag, %function
toggleStateFlag:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	mov	r3, r0
	strb	r3, [r7, #7]
	ldrb	r2, [r7, #7]	@ zero_extendqisi2
	ldr	r3, .L8
	ldr	r3, [r3]
	eors	r3, r3, r2
	ldr	r2, .L8
	str	r3, [r2]
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L9:
	.align	2
.L8:
	.word	bouncer_state
	.size	toggleStateFlag, .-toggleStateFlag
	.section	.text.getStateFlag,"ax",%progbits
	.align	1
	.global	getStateFlag
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	getStateFlag, %function
getStateFlag:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	mov	r3, r0
	strb	r3, [r7, #7]
	ldrb	r2, [r7, #7]	@ zero_extendqisi2
	ldr	r3, .L12
	ldr	r3, [r3]
	ands	r3, r3, r2
	cmp	r3, #0
	ite	ne
	movne	r3, #1
	moveq	r3, #0
	uxtb	r3, r3
	mov	r0, r3
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L13:
	.align	2
.L12:
	.word	bouncer_state
	.size	getStateFlag, .-getStateFlag
	.section	.text.changeState,"ax",%progbits
	.align	1
	.global	changeState
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	changeState, %function
changeState:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	add	r7, sp, #0
	movs	r3, #1
	mov	r0, r3
	ldr	r10, =toggleStateFlag
	bl	SECURE_log_call
	movs	r3, #4
	mov	r0, r3
	ldr	r10, =setStateFlag
	bl	SECURE_log_call
	pop	{r7, lr}
	b	SECURE_log_ret
	.size	changeState, .-changeState
	.section	.text.digitalRead,"ax",%progbits
	.align	1
	.global	digitalRead
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	digitalRead, %function
digitalRead:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	ldr	r3, .L17
	ldr	r3, [r3]
	ldr	r2, .L17+4
	ldrb	r3, [r2, r3]	@ zero_extendqisi2
	str	r3, [r7, #4]
	ldr	r3, .L17
	ldr	r3, [r3]
	adds	r3, r3, #1
	ldr	r2, .L17
	str	r3, [r2]
	ldr	r3, [r7, #4]
	mov	r0, r3
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L18:
	.align	2
.L17:
	.word	sig_idx
	.word	signals
	.size	digitalRead, .-digitalRead
	.section	.text.changed,"ax",%progbits
	.align	1
	.global	changed
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	changed, %function
changed:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	add	r7, sp, #0
	movs	r3, #4
	mov	r0, r3
	ldr	r10, =getStateFlag
	bl	SECURE_log_call
	mov	r3, r0
	mov	r0, r3
	pop	{r7, lr}
	b	SECURE_log_ret
	.size	changed, .-changed
	.section	.text.readCurrentState,"ax",%progbits
	.align	1
	.global	readCurrentState
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	readCurrentState, %function
readCurrentState:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	add	r7, sp, #0
	ldr	r10, =digitalRead
	bl	SECURE_log_call
	mov	r3, r0
	mov	r0, r3
	pop	{r7, lr}
	b	SECURE_log_ret
	.size	readCurrentState, .-readCurrentState
	.section	.text.bouncer_begin,"ax",%progbits
	.align	1
	.global	bouncer_begin
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	bouncer_begin, %function
bouncer_begin:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	add	r7, sp, #0
	ldr	r3, .L26
	movs	r2, #0
	str	r2, [r3]
	ldr	r10, =readCurrentState
	bl	SECURE_log_call
	mov	r3, r0
	cmp	r3, #0
	beq	.L25
	bl	SECURE_log_cond_br
	movs	r2, #1
	movs	r3, #2
	orrs	r3, r3, r2
	uxtb	r3, r3
	mov	r0, r3
	ldr	r10, =setStateFlag
	bl	SECURE_log_call
.L25:
	bl	SECURE_log_cond_br
	pop	{r7, lr}
	b	SECURE_log_ret
.L27:
	.align	2
.L26:
	.word	bouncer_state
	.size	bouncer_begin, .-bouncer_begin
	.section	.text.bouncer_update,"ax",%progbits
	.align	1
	.global	bouncer_update
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	bouncer_update, %function
bouncer_update:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r4, r7, lr}
	sub	sp, sp, #12
	add	r7, sp, #0
	movs	r3, #4
	mov	r0, r3
	ldr	r10, =unsetStateFlag
	bl	SECURE_log_call
	ldr	r10, =readCurrentState
	bl	SECURE_log_call
	str	r0, [r7, #4]
	movs	r3, #2
	mov	r2, r3
	ldr	r3, [r7, #4]
	ands	r3, r3, r2
	cmp	r3, #0
	ite	ne
	movne	r3, #1
	moveq	r3, #0
	uxtb	r3, r3
	mov	r4, r3
	movs	r3, #2
	mov	r0, r3
	ldr	r10, =getStateFlag
	bl	SECURE_log_call
	mov	r3, r0
	cmp	r4, r3
	beq	.L29
	bl	SECURE_log_cond_br
	movs	r3, #2
	mov	r0, r3
	ldr	r10, =toggleStateFlag
	bl	SECURE_log_call
	b	.L30
.L29:
	bl	SECURE_log_cond_br
	movs	r3, #1
	mov	r2, r3
	ldr	r3, [r7, #4]
	ands	r3, r3, r2
	cmp	r3, #0
	ite	ne
	movne	r3, #1
	moveq	r3, #0
	uxtb	r3, r3
	mov	r4, r3
	movs	r3, #1
	mov	r0, r3
	ldr	r10, =getStateFlag
	bl	SECURE_log_call
	mov	r3, r0
	cmp	r4, r3
	beq	.L30
	bl	SECURE_log_cond_br
	ldr	r10, =changeState
	bl	SECURE_log_call
.L30:
	bl	SECURE_log_cond_br
	ldr	r10, =changed
	bl	SECURE_log_call
	mov	r3, r0
	mov	r0, r3
	adds	r7, r7, #12
	mov	sp, r7
	@ sp needed
	pop	{r4, r7, lr}
	b	SECURE_log_ret
	.size	bouncer_update, .-bouncer_update
	.section	.text.bouncer_read,"ax",%progbits
	.align	1
	.global	bouncer_read
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	bouncer_read, %function
bouncer_read:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	add	r7, sp, #0
	movs	r3, #1
	mov	r0, r3
	ldr	r10, =getStateFlag
	bl	SECURE_log_call
	mov	r3, r0
	mov	r0, r3
	pop	{r7, lr}
	b	SECURE_log_ret
	.size	bouncer_read, .-bouncer_read
	.global	datastring
	.section	.bss.datastring,"aw",%nobits
	.align	2
	.type	datastring, %object
	.size	datastring, 10
datastring:
	.space	10
	.section	.text.application,"ax",%progbits
	.align	1
	.global	application
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	application, %function
application:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	movs	r3, #0
	str	r3, [r7, #4]
	ldr	r10, =bouncer_begin
	bl	SECURE_log_call
	b	.L35
.L36:
	bl	SECURE_log_cond_br
	ldr	r10, =bouncer_update
	bl	SECURE_log_call
	mov	r3, r0
	cmp	r3, #0
	beq	.L35
	bl	SECURE_log_cond_br
	ldr	r10, =bouncer_read
	bl	SECURE_log_call
	mov	r3, r0
	cmp	r3, #0
	bne	.L35
	bl	SECURE_log_cond_br
	ldr	r2, .L37
	ldr	r3, [r7, #4]
	add	r3, r3, r2
	movs	r2, #49
	strb	r2, [r3]
	ldr	r3, [r7, #4]
	adds	r3, r3, #1
	ldr	r2, .L37
	movs	r1, #44
	strb	r1, [r2, r3]
	ldr	r3, [r7, #4]
	adds	r3, r3, #2
	str	r3, [r7, #4]
.L35:
	bl	SECURE_log_cond_br
	ldr	r3, .L37+4
	ldr	r3, [r3]
	cmp	r3, #13
	ble	.L36
	bl	SECURE_log_cond_br
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L38:
	.align	2
.L37:
	.word	datastring
	.word	sig_idx
	.size	application, .-application
	.ident	"GCC: (15:9-2019-q4-0ubuntu1) 9.2.1 20191025 (release) [ARM/arm-9-branch revision 277599]"
