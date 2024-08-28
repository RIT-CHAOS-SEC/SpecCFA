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
	.section	.text.pulseIn,"ax",%progbits
	.align	1
	.global	pulseIn
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	pulseIn, %function
pulseIn:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	movs	r3, #0
	str	r3, [r7, #4]
	movs	r3, #0
	str	r3, [r7]
	b	.L5
.L6:
	bl	SECURE_log_cond_br
	ldr	r3, .L8
	ldr	r3, [r3, #16]
	lsrs	r3, r3, #8
	and	r3, r3, #1
	ldr	r2, [r7, #4]
	add	r3, r3, r2
	str	r3, [r7, #4]
	ldr	r3, [r7]
	adds	r3, r3, #1
	str	r3, [r7]
.L5:
	ldr	r3, [r7]
	cmp	r3, #1000
	blt	.L6
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #4]
	mov	r0, r3
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L9:
	.align	2
.L8:
	.word	1107427328
	.size	pulseIn, .-pulseIn
	.section	.text.getUltrasonicReading,"ax",%progbits
	.align	1
	.global	getUltrasonicReading
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	getUltrasonicReading, %function
getUltrasonicReading:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	ldr	r3, .L12
	mov	r2, #256
	str	r2, [r3, #24]
	movs	r0, #2
	ldr	r10, =delay
	bl	SECURE_log_call
	ldr	r3, .L12
	mov	r2, #256
	str	r2, [r3, #40]
	movs	r0, #5
	ldr	r10, =delay
	bl	SECURE_log_call
	ldr	r3, .L12
	mov	r2, #256
	str	r2, [r3, #24]
	ldr	r10, =pulseIn
	bl	SECURE_log_call
	str	r0, [r7, #4]
	ldr	r3, [r7, #4]
	mov	r0, r3
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L13:
	.align	2
.L12:
	.word	1107427328
	.size	getUltrasonicReading, .-getUltrasonicReading
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
	ldr	r10, =getUltrasonicReading
	bl	SECURE_log_call
	str	r0, [r7, #4]
	ldr	r0, [r7, #4]
	bl	SECURE_record_output_data
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
	.size	application, .-application
	.ident	"GCC: (15:9-2019-q4-0ubuntu1) 9.2.1 20191025 (release) [ARM/arm-9-branch revision 277599]"
