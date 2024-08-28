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
	.global	sensor
	.section	.data.sensor,"aw"
	.align	1
	.type	sensor, %object
	.size	sensor, 2
sensor:
	.short	165
	.comm	steps,4,4
	.section	.text.delay,"ax",%progbits
	.align	1
	.global	delay
	.arch armv8-m.main
	.arch_extension dsp
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	delay, %function
delay:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #16
	add	r7, sp, #0
	str	r0, [r7, #4]
	movs	r3, #0
	str	r3, [r7, #12]
	b	.L2
.L3:
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #12]
	adds	r3, r3, #1
	str	r3, [r7, #12]
.L2:
	ldr	r3, [r7, #12]
	ldr	r2, [r7, #4]
	cmp	r2, r3
	bhi	.L3
	bl	SECURE_log_cond_br
	adds	r7, r7, #16
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
	.size	delay, .-delay
	.global	maxinputpointer
	.section	.data.maxinputpointer,"aw"
	.type	maxinputpointer, %object
	.size	maxinputpointer, 1
maxinputpointer:
	.byte	2
	.global	input
	.section	.data.input,"aw"
	.align	2
	.type	input, %object
	.size	input, 2
input:
	.ascii	"+\012"
	.section	.text.getserialinput,"ax",%progbits
	.align	1
	.global	getserialinput
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	getserialinput, %function
getserialinput:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	mov	r3, r0
	strb	r3, [r7, #7]
	ldr	r3, .L7
	ldrb	r3, [r3]	@ zero_extendqisi2
	ldrb	r2, [r7, #7]	@ zero_extendqisi2
	cmp	r2, r3
	bcs	.L5
	bl	SECURE_log_cond_br
	ldrb	r3, [r7, #7]	@ zero_extendqisi2
	ldr	r2, .L7+4
	ldrb	r3, [r2, r3]	@ zero_extendqisi2
	b	.L6
.L5:
	bl	SECURE_log_cond_br
	movs	r3, #0
.L6:
	mov	r0, r3
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L8:
	.align	2
.L7:
	.word	maxinputpointer
	.word	input
	.size	getserialinput, .-getserialinput
	.global	mLBolus
	.section	.data.mLBolus,"aw"
	.align	1
	.type	mLBolus, %object
	.size	mLBolus, 2
mLBolus:
	.short	5
	.section	.text.run_syringe,"ax",%progbits
	.align	1
	.global	run_syringe
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	run_syringe, %function
run_syringe:
	@ args = 0, pretend = 0, frame = 40
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #40
	add	r7, sp, #0
	movs	r3, #255
	strb	r3, [r7, #15]
	movs	r3, #0
	strh	r3, [r7, #38]	@ movhi
	movs	r3, #8
	str	r3, [r7, #16]
	movs	r3, #0
	str	r3, [r7, #32]
	movs	r3, #0
	str	r3, [r7, #28]
	ldr	r3, .L22
	movs	r2, #0
	str	r2, [r3]
	b	.L10
.L20:
	bl	SECURE_log_cond_br
	ldrb	r3, [r7, #15]
	uxtb	r3, r3
	mov	r0, r3
	ldr	r10, =getserialinput
	bl	SECURE_log_call
	mov	r3, r0
	strb	r3, [r7, #27]
	ldrb	r3, [r7, #15]
	uxtb	r3, r3
	adds	r3, r3, #1
	uxtb	r3, r3
	strb	r3, [r7, #15]
	b	.L11
.L15:
	bl	SECURE_log_cond_br
	ldrb	r3, [r7, #27]	@ zero_extendqisi2
	cmp	r3, #10
	beq	.L21
	bl	SECURE_log_cond_br
	ldrb	r3, [r7, #27]	@ zero_extendqisi2
	cmp	r3, #0
	bne	.L14
	bl	SECURE_log_cond_br
	movs	r3, #10
	str	r3, [r7, #28]
	b	.L13
.L14:
	bl	SECURE_log_cond_br
	ldrh	r3, [r7, #38]
	adds	r2, r3, #1
	strh	r2, [r7, #38]	@ movhi
	add	r2, r7, #40
	add	r3, r3, r2
	ldrb	r2, [r7, #27]
	strb	r2, [r3, #-36]
	ldrb	r3, [r7, #15]
	uxtb	r3, r3
	mov	r0, r3
	ldr	r10, =getserialinput
	bl	SECURE_log_call
	mov	r3, r0
	strb	r3, [r7, #27]
	ldrb	r3, [r7, #15]
	uxtb	r3, r3
	adds	r3, r3, #1
	uxtb	r3, r3
	strb	r3, [r7, #15]
	ldr	r3, [r7, #32]
	adds	r3, r3, #1
	str	r3, [r7, #32]
.L11:
	ldr	r3, [r7, #32]
	cmp	r3, #9
	ble	.L15
	bl	SECURE_log_cond_br
	b	.L13
.L21:
	bl	SECURE_log_cond_br
.L13:
	ldrh	r3, [r7, #38]
	adds	r2, r3, #1
	strh	r2, [r7, #38]	@ movhi
	add	r2, r7, #40
	add	r3, r3, r2
	movs	r2, #0
	strb	r2, [r3, #-36]
	ldr	r3, .L22+4
	ldrh	r3, [r3]
	mov	r2, r3
	ldr	r3, [r7, #16]
	mul	r3, r3, r2
	ldr	r2, .L22
	str	r3, [r2]
	movs	r3, #0
	str	r3, [r7, #20]
	b	.L16
.L19:
	bl	SECURE_log_cond_br
	ldrb	r3, [r7, #4]	@ zero_extendqisi2
	cmp	r3, #43
	beq	.L17
	bl	SECURE_log_cond_br
	ldrb	r3, [r7, #4]	@ zero_extendqisi2
	cmp	r3, #45
	bne	.L18
	bl	SECURE_log_cond_br
.L17:
	bl	SECURE_log_cond_br
	ldr	r3, .L22+8
	movs	r2, #255
	strh	r2, [r3]	@ movhi
	movs	r0, #100
	ldr	r10, =delay
	bl	SECURE_log_call
.L18:
	bl	SECURE_log_cond_br
	ldr	r3, .L22+8
	movs	r2, #0
	strh	r2, [r3]	@ movhi
	movs	r0, #100
	ldr	r10, =delay
	bl	SECURE_log_call
	ldr	r3, [r7, #20]
	adds	r3, r3, #1
	str	r3, [r7, #20]
.L16:
	ldr	r3, .L22
	ldr	r3, [r3]
	ldr	r2, [r7, #20]
	cmp	r2, r3
	blt	.L19
	bl	SECURE_log_cond_br
	movs	r3, #0
	strh	r3, [r7, #38]	@ movhi
	ldr	r3, [r7, #28]
	adds	r3, r3, #1
	str	r3, [r7, #28]
.L10:
	ldr	r3, [r7, #28]
	cmp	r3, #0
	ble	.L20
	bl	SECURE_log_cond_br
	adds	r7, r7, #40
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L23:
	.align	2
.L22:
	.word	steps
	.word	mLBolus
	.word	sensor
	.size	run_syringe, .-run_syringe
	.section	.text.application,"ax",%progbits
	.align	1
	.global	application
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	application, %function
application:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	add	r7, sp, #0
	ldr	r10, =run_syringe
	bl	SECURE_log_call
	pop	{r7, lr}
	b	SECURE_log_ret
	.size	application, .-application
	.ident	"GCC: (15:9-2019-q4-0ubuntu1) 9.2.1 20191025 (release) [ARM/arm-9-branch revision 277599]"
