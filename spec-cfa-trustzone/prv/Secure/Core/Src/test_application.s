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
	.global	some_func
	.section	.data.some_func,"aw",%progbits
	.align	2
	.type	some_func, %object
	.size	some_func, 4
some_func:
	.word	func
	.section	.text.func2,"ax",%progbits
	.align	1
	.global	func2
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	func2, %function
func2:
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	str	r5, [r7, #4]
	str	r1, [r7]
	ldr	r2, [r7]
	ldr	r3, [r7, #4]
	cmp	r2, r3
	ble	.L2
	bl	SECURE_log_cond_br
	ldr	r2, [r7]
	ldr	r3, [r7, #4]
	subs	r3, r2, r3
	b	.L3
.L2:
	bl	SECURE_log_cond_br
	ldr	r2, [r7, #4]
	ldr	r3, [r7]
	subs	r3, r2, r3
.L3:
	mov	r5, r3
	adds	r7, r7, #8
	mov	sp, r7
	pop	{r7, lr}
	b	SECURE_log_ret
	.size	func2, .-func2
	.section	.text.func,"ax",%progbits
	.align	1
	.global	func
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	func, %function
func:
	push	{r7, lr}
	sub	sp, sp, #16
	add	r7, sp, #0
	str	r5, [r7, #4]
	ldr	r3, [r7, #4]
	and	r3, r3, #3
	cmp	r3, #0
	bne	.L5
	bl	SECURE_log_cond_br
	ldr	r1, [r7, #4]
	ldr	r5, [r7, #4]
	ldr	r0, =func2
	bl	SECURE_log_call
	mov	r2, r5
	ldr	r3, [r7, #4]
	add	r3, r3, r2
	ldr	r2, [r7, #4]
	add	r3, r3, r2
	str	r3, [r7, #4]
	b	.L6
.L5:
	bl	SECURE_log_cond_br
	ldr	r1, [r7, #4]
	ldr	r5, [r7, #4]
	ldr	r0, =func2
	bl	SECURE_log_call
	mov	r2, r5
	ldr	r3, [r7, #4]
	subs	r3, r3, r2
	str	r3, [r7, #4]
.L6:
	movs	r3, #0
	str	r3, [r7, #12]
	b	.L7
.L8:
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #4]
	lsls	r3, r3, #1
	eor	r3, r3, #340
	str	r3, [r7, #4]
	ldr	r3, [r7, #12]
	adds	r3, r3, #1
	str	r3, [r7, #12]
.L7:
	ldr	r3, [r7, #12]
	cmp	r3, #15
	ble	.L8
	bl	SECURE_log_cond_br
	nop
	adds	r7, r7, #16
	mov	sp, r7
	pop	{r7, lr}
	b	SECURE_log_ret
	.size	func, .-func
	.section	.text.test_application,"ax",%progbits
	.align	1
	.global	test_application
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	test_application, %function
test_application:
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	movw	r3, #1234
	str	r3, [r7, #4]
	ldr	r5, [r7, #4]
	ldr	r0, =func
	bl	SECURE_log_call
	ldr	r3, .L10
	ldr	r3, [r3]
	mov	r0, r3
	bl	SECURE_log_call
	nop
	adds	r7, r7, #8
	mov	sp, r7
	pop	{r7, lr}
	b	SECURE_log_ret
.L11:
	.align	2
.L10:
	.word	some_func
	.size	test_application, .-test_application
	.ident	"GCC: (15:6.3.1+svn253039-1build1) 6.3.1 20170620"
