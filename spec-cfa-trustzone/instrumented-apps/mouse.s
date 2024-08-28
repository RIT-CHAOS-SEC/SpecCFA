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
	.comm	_buttons,1,1
	.section	.text.limit_xy,"ax",%progbits
	.align	1
	.global	limit_xy
	.arch armv8-m.main
	.arch_extension dsp
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	limit_xy, %function
limit_xy:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	str	r0, [r7, #4]
	ldr	r3, [r7, #4]
	cmn	r3, #127
	bge	.L2
	bl	SECURE_log_cond_br
	mvn	r3, #126
	b	.L3
.L2:
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #4]
	cmp	r3, #127
	ble	.L4
	bl	SECURE_log_cond_br
	movs	r3, #127
	b	.L3
.L4:
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #4]
	sxtb	r3, r3
.L3:
	mov	r0, r3
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
	.size	limit_xy, .-limit_xy
	.section	.text.mouseBegin,"ax",%progbits
	.align	1
	.global	mouseBegin
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	mouseBegin, %function
mouseBegin:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	add	r7, sp, #0
	pop	{r7, lr}
	b	SECURE_log_ret
	.size	mouseBegin, .-mouseBegin
	.section	.text.mouseEnd,"ax",%progbits
	.align	1
	.global	mouseEnd
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	mouseEnd, %function
mouseEnd:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	add	r7, sp, #0
	pop	{r7, lr}
	b	SECURE_log_ret
	.size	mouseEnd, .-mouseEnd
	.section	.text.mouseMove,"ax",%progbits
	.align	1
	.global	mouseMove
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	mouseMove, %function
mouseMove:
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #24
	add	r7, sp, #0
	str	r0, [r7, #12]
	str	r1, [r7, #8]
	mov	r3, r2
	strb	r3, [r7, #7]
	ldr	r3, .L8
	ldrb	r3, [r3]	@ zero_extendqisi2
	strb	r3, [r7, #20]
	ldr	r0, [r7, #12]
	ldr	r10, =limit_xy
	bl	SECURE_log_call
	mov	r3, r0
	uxtb	r3, r3
	strb	r3, [r7, #21]
	ldr	r0, [r7, #8]
	ldr	r10, =limit_xy
	bl	SECURE_log_call
	mov	r3, r0
	uxtb	r3, r3
	strb	r3, [r7, #22]
	ldrb	r3, [r7, #7]	@ zero_extendqisi2
	strb	r3, [r7, #23]
	adds	r7, r7, #24
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L9:
	.align	2
.L8:
	.word	_buttons
	.size	mouseMove, .-mouseMove
	.section	.text.mouseClick,"ax",%progbits
	.align	1
	.global	mouseClick
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	mouseClick, %function
mouseClick:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	mov	r3, r0
	strb	r3, [r7, #7]
	ldr	r2, .L11
	ldrb	r3, [r7, #7]
	strb	r3, [r2]
	movs	r2, #0
	movs	r1, #0
	movs	r0, #0
	ldr	r10, =mouseMove
	bl	SECURE_log_call
	ldr	r3, .L11
	movs	r2, #0
	strb	r2, [r3]
	movs	r2, #0
	movs	r1, #0
	movs	r0, #0
	ldr	r10, =mouseMove
	bl	SECURE_log_call
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L12:
	.align	2
.L11:
	.word	_buttons
	.size	mouseClick, .-mouseClick
	.section	.text.mouseButtons,"ax",%progbits
	.align	1
	.global	mouseButtons
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	mouseButtons, %function
mouseButtons:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	mov	r3, r0
	strb	r3, [r7, #7]
	ldr	r3, .L16
	ldrb	r3, [r3]	@ zero_extendqisi2
	ldrb	r2, [r7, #7]	@ zero_extendqisi2
	cmp	r2, r3
	beq	.L15
	bl	SECURE_log_cond_br
	ldr	r2, .L16
	ldrb	r3, [r7, #7]
	strb	r3, [r2]
	movs	r2, #0
	movs	r1, #0
	movs	r0, #0
	ldr	r10, =mouseMove
	bl	SECURE_log_call
.L15:
	bl	SECURE_log_cond_br
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L17:
	.align	2
.L16:
	.word	_buttons
	.size	mouseButtons, .-mouseButtons
	.section	.text.mousePress,"ax",%progbits
	.align	1
	.global	mousePress
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	mousePress, %function
mousePress:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	mov	r3, r0
	strb	r3, [r7, #7]
	ldr	r3, .L19
	ldrb	r2, [r3]	@ zero_extendqisi2
	ldrb	r3, [r7, #7]
	orrs	r3, r3, r2
	uxtb	r3, r3
	mov	r0, r3
	ldr	r10, =mouseButtons
	bl	SECURE_log_call
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L20:
	.align	2
.L19:
	.word	_buttons
	.size	mousePress, .-mousePress
	.section	.text.mouseRelease,"ax",%progbits
	.align	1
	.global	mouseRelease
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	mouseRelease, %function
mouseRelease:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	mov	r3, r0
	strb	r3, [r7, #7]
	ldrsb	r3, [r7, #7]
	mvns	r3, r3
	sxtb	r2, r3
	ldr	r3, .L22
	ldrb	r3, [r3]	@ zero_extendqisi2
	sxtb	r3, r3
	ands	r3, r3, r2
	sxtb	r3, r3
	uxtb	r3, r3
	mov	r0, r3
	ldr	r10, =mouseButtons
	bl	SECURE_log_call
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L23:
	.align	2
.L22:
	.word	_buttons
	.size	mouseRelease, .-mouseRelease
	.section	.text.mouseIsPressed,"ax",%progbits
	.align	1
	.global	mouseIsPressed
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	mouseIsPressed, %function
mouseIsPressed:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	mov	r3, r0
	strb	r3, [r7, #7]
	ldr	r3, .L27
	ldrb	r2, [r3]	@ zero_extendqisi2
	ldrb	r3, [r7, #7]
	ands	r3, r3, r2
	uxtb	r3, r3
	cmp	r3, #0
	beq	.L25
	bl	SECURE_log_cond_br
	movs	r3, #1
	b	.L26
.L25:
	bl	SECURE_log_cond_br
	movs	r3, #0
.L26:
	mov	r0, r3
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L28:
	.align	2
.L27:
	.word	_buttons
	.size	mouseIsPressed, .-mouseIsPressed
	.global	mouseActive
	.section	.bss.mouseActive,"aw",%nobits
	.type	mouseActive, %object
	.size	mouseActive, 1
mouseActive:
	.space	1
	.global	lastSwitchState
	.section	.data.lastSwitchState,"aw"
	.type	lastSwitchState, %object
	.size	lastSwitchState, 1
lastSwitchState:
	.byte	1
	.global	lastMouseRightState
	.section	.data.lastMouseRightState,"aw"
	.type	lastMouseRightState, %object
	.size	lastMouseRightState, 1
lastMouseRightState:
	.byte	1
	.global	lastMouseLeftState
	.section	.data.lastMouseLeftState,"aw"
	.type	lastMouseLeftState, %object
	.size	lastMouseLeftState, 1
lastMouseLeftState:
	.byte	1
	.global	mockReads
	.section	.data.mockReads,"aw"
	.align	2
	.type	mockReads, %object
	.size	mockReads, 800
mockReads:
	.word	95
	.word	-39
	.word	-39
	.word	-10
	.word	-100
	.word	119
	.word	43
	.word	15
	.word	67
	.word	129
	.word	98
	.word	-30
	.word	26
	.word	90
	.word	-154
	.word	-109
	.word	-182
	.word	-103
	.word	-114
	.word	-111
	.word	14
	.word	-119
	.word	-148
	.word	-46
	.word	-67
	.word	-162
	.word	-1
	.word	-198
	.word	116
	.word	-82
	.word	4
	.word	-158
	.word	60
	.word	73
	.word	77
	.word	-74
	.word	180
	.word	-128
	.word	-134
	.word	-3
	.word	195
	.word	-31
	.word	123
	.word	-33
	.word	0
	.word	150
	.word	42
	.word	125
	.word	27
	.word	-164
	.word	-38
	.word	-99
	.word	-162
	.word	112
	.word	70
	.word	-21
	.word	134
	.word	-123
	.word	72
	.word	184
	.word	81
	.word	-169
	.word	-147
	.word	146
	.word	-3
	.word	-143
	.word	173
	.word	13
	.word	90
	.word	189
	.word	-99
	.word	-40
	.word	-69
	.word	-65
	.word	80
	.word	-34
	.word	-82
	.word	-196
	.word	-68
	.word	-75
	.word	200
	.word	-144
	.word	163
	.word	96
	.word	14
	.word	38
	.word	-140
	.word	31
	.word	94
	.word	54
	.word	87
	.word	173
	.word	-75
	.word	-199
	.word	-74
	.word	-8
	.word	95
	.word	-185
	.word	-34
	.word	62
	.word	-1
	.word	-120
	.word	-124
	.word	-164
	.word	-2
	.word	51
	.word	116
	.word	-86
	.word	-135
	.word	114
	.word	179
	.word	21
	.word	173
	.word	-39
	.word	-40
	.word	-28
	.word	-1
	.word	-73
	.word	-1
	.word	192
	.word	-76
	.word	-141
	.word	-91
	.word	-160
	.word	139
	.word	43
	.word	-132
	.word	38
	.word	-68
	.word	-168
	.word	87
	.word	9
	.word	66
	.word	50
	.word	-84
	.word	-146
	.word	-56
	.word	-104
	.word	-114
	.word	-45
	.word	-7
	.word	43
	.word	161
	.word	58
	.word	-65
	.word	-7
	.word	-66
	.word	-54
	.word	129
	.word	55
	.word	101
	.word	28
	.word	-103
	.word	46
	.word	121
	.word	188
	.word	-83
	.word	147
	.word	174
	.word	-195
	.word	-54
	.word	-169
	.word	76
	.word	31
	.word	194
	.word	-104
	.word	-112
	.word	53
	.word	159
	.word	35
	.word	-172
	.word	184
	.word	-175
	.word	-56
	.word	-148
	.word	192
	.word	132
	.word	-87
	.word	124
	.word	-160
	.word	-22
	.word	-163
	.word	-172
	.word	-139
	.word	36
	.word	-125
	.word	-71
	.word	-99
	.word	-139
	.word	-81
	.word	167
	.word	40
	.word	50
	.word	45
	.word	-94
	.word	-20
	.word	-111
	.word	21
	.word	11
	.word	-55
	.global	indx
	.section	.bss.indx,"aw",%nobits
	.align	2
	.type	indx, %object
	.size	indx, 4
indx:
	.space	4
	.section	.text.analogRead,"ax",%progbits
	.align	1
	.global	analogRead
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	analogRead, %function
analogRead:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #16
	add	r7, sp, #0
	mov	r3, r0
	strb	r3, [r7, #7]
	ldrb	r3, [r7, #7]	@ zero_extendqisi2
	cmp	r3, #120
	bne	.L30
	bl	SECURE_log_cond_br
	ldr	r3, .L33
	ldr	r3, [r3]
	ldr	r2, .L33+4
	ldr	r3, [r2, r3, lsl #2]
	str	r3, [r7, #12]
	b	.L31
.L30:
	bl	SECURE_log_cond_br
	ldrb	r3, [r7, #7]	@ zero_extendqisi2
	cmp	r3, #121
	bne	.L31
	bl	SECURE_log_cond_br
	ldr	r3, .L33
	ldr	r3, [r3]
	ldr	r2, .L33+4
	ldr	r3, [r2, r3, lsl #2]
	str	r3, [r7, #12]
.L31:
	bl	SECURE_log_cond_br
	ldr	r3, .L33
	ldr	r3, [r3]
	adds	r3, r3, #1
	ldr	r2, .L33
	str	r3, [r2]
	ldr	r3, [r7, #12]
	mov	r0, r3
	adds	r7, r7, #16
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L34:
	.align	2
.L33:
	.word	indx
	.word	mockReads
	.size	analogRead, .-analogRead
	.section	.text.map,"ax",%progbits
	.align	1
	.global	map
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	map, %function
map:
	@ args = 4, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #16
	add	r7, sp, #0
	str	r0, [r7, #12]
	str	r1, [r7, #8]
	str	r2, [r7, #4]
	str	r3, [r7]
	ldr	r2, [r7, #12]
	ldr	r3, [r7, #8]
	subs	r3, r2, r3
	ldr	r1, [r7, #24]
	ldr	r2, [r7]
	subs	r2, r1, r2
	mul	r2, r2, r3
	ldr	r1, [r7, #4]
	ldr	r3, [r7, #8]
	subs	r3, r1, r3
	sdiv	r2, r2, r3
	ldr	r3, [r7]
	add	r3, r3, r2
	mov	r0, r3
	adds	r7, r7, #16
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
	.size	map, .-map
	.section	.text.handleMouse,"ax",%progbits
	.align	1
	.global	handleMouse
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	handleMouse, %function
handleMouse:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #24
	add	r7, sp, #8
	movs	r0, #120
	ldr	r10, =analogRead
	bl	SECURE_log_call
	str	r0, [r7, #12]
	movs	r0, #121
	ldr	r10, =analogRead
	bl	SECURE_log_call
	str	r0, [r7, #8]
	movs	r3, #10
	str	r3, [sp]
	mvn	r3, #9
	mov	r2, #1024
	movs	r1, #0
	ldr	r0, [r7, #12]
	ldr	r10, =map
	bl	SECURE_log_call
	str	r0, [r7, #4]
	mvn	r3, #9
	str	r3, [sp]
	movs	r3, #10
	mov	r2, #1024
	movs	r1, #0
	ldr	r0, [r7, #8]
	ldr	r10, =map
	bl	SECURE_log_call
	str	r0, [r7]
	ldr	r3, [r7, #4]
	cmp	r3, #1
	bgt	.L38
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #4]
	cmp	r3, #-1
	blt	.L38
	bl	SECURE_log_cond_br
	ldr	r3, [r7]
	cmp	r3, #-1
	blt	.L38
	bl	SECURE_log_cond_br
	ldr	r3, [r7]
	cmp	r3, #1
	ble	.L40
	bl	SECURE_log_cond_br
.L38:
	bl	SECURE_log_cond_br
	movs	r2, #0
	ldr	r1, [r7]
	ldr	r0, [r7, #4]
	ldr	r10, =mouseMove
	bl	SECURE_log_call
.L40:
	bl	SECURE_log_cond_br
	adds	r7, r7, #16
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
	.size	handleMouse, .-handleMouse
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
	str	r0, [r7, #4]
	ldr	r3, .L43
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #0
	ite	eq
	moveq	r3, #1
	movne	r3, #0
	uxtb	r3, r3
	mov	r0, r3
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L44:
	.align	2
.L43:
	.word	lastSwitchState
	.size	digitalRead, .-digitalRead
	.section	.text.readMouseButton,"ax",%progbits
	.align	1
	.global	readMouseButton
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	readMouseButton, %function
readMouseButton:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #16
	add	r7, sp, #0
	str	r0, [r7, #4]
	mov	r3, r1
	strb	r3, [r7, #3]
	mov	r3, r2
	strb	r3, [r7, #2]
	movs	r3, #0
	strb	r3, [r7, #15]
	ldr	r0, [r7, #4]
	ldr	r10, =digitalRead
	bl	SECURE_log_call
	mov	r3, r0
	strb	r3, [r7, #14]
	ldrb	r2, [r7, #14]	@ zero_extendqisi2
	ldrb	r3, [r7, #3]	@ zero_extendqisi2
	cmp	r2, r3
	beq	.L46
	bl	SECURE_log_cond_br
	ldrb	r3, [r7, #2]	@ zero_extendqisi2
	cmp	r3, #1
	bne	.L47
	bl	SECURE_log_cond_br
	ldrb	r3, [r7, #14]	@ zero_extendqisi2
	cmp	r3, #0
	beq	.L48
	bl	SECURE_log_cond_br
.L47:
	bl	SECURE_log_cond_br
	ldrb	r3, [r7, #2]	@ zero_extendqisi2
	cmp	r3, #2
	bne	.L49
	bl	SECURE_log_cond_br
	ldrb	r3, [r7, #14]	@ zero_extendqisi2
	cmp	r3, #1
	beq	.L48
	bl	SECURE_log_cond_br
.L49:
	bl	SECURE_log_cond_br
	ldrb	r3, [r7, #2]	@ zero_extendqisi2
	cmp	r3, #3
	bne	.L46
	bl	SECURE_log_cond_br
.L48:
	bl	SECURE_log_cond_br
	movs	r3, #1
	strb	r3, [r7, #15]
.L46:
	bl	SECURE_log_cond_br
	ldrb	r3, [r7, #14]
	strb	r3, [r7, #3]
	ldrb	r3, [r7, #15]	@ zero_extendqisi2
	mov	r0, r3
	adds	r7, r7, #16
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
	.size	readMouseButton, .-readMouseButton
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
	b	.L52
.L60:
	bl	SECURE_log_cond_br
	ldr	r3, .L61
	ldrb	r3, [r3]	@ zero_extendqisi2
	movs	r2, #1
	mov	r1, r3
	movs	r0, #2
	ldr	r10, =readMouseButton
	bl	SECURE_log_call
	mov	r3, r0
	cmp	r3, #0
	beq	.L53
	bl	SECURE_log_cond_br
	ldr	r3, .L61+4
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #0
	beq	.L54
	bl	SECURE_log_cond_br
	ldr	r10, =mouseEnd
	bl	SECURE_log_call
	ldr	r3, .L61+4
	movs	r2, #0
	strb	r2, [r3]
	b	.L53
.L54:
	bl	SECURE_log_cond_br
	ldr	r10, =mouseBegin
	bl	SECURE_log_call
	ldr	r3, .L61+4
	movs	r2, #1
	strb	r2, [r3]
.L53:
	bl	SECURE_log_cond_br
	ldr	r3, .L61+4
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #0
	beq	.L55
	bl	SECURE_log_cond_br
	ldr	r10, =handleMouse
	bl	SECURE_log_call
	ldr	r3, .L61+8
	ldrb	r3, [r3]	@ zero_extendqisi2
	movs	r2, #3
	mov	r1, r3
	movs	r0, #5
	ldr	r10, =readMouseButton
	bl	SECURE_log_call
	mov	r3, r0
	cmp	r3, #0
	beq	.L55
	bl	SECURE_log_cond_br
	ldr	r3, .L61+8
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #0
	bne	.L56
	bl	SECURE_log_cond_br
	movs	r0, #5
	ldr	r10, =mouseIsPressed
	bl	SECURE_log_call
	mov	r3, r0
	cmp	r3, #0
	bne	.L56
	bl	SECURE_log_cond_br
	movs	r0, #1
	ldr	r10, =mousePress
	bl	SECURE_log_call
	b	.L55
.L56:
	bl	SECURE_log_cond_br
	ldr	r3, .L61+8
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #1
	bne	.L55
	bl	SECURE_log_cond_br
	movs	r0, #5
	ldr	r10, =mouseIsPressed
	bl	SECURE_log_call
	mov	r3, r0
	cmp	r3, #0
	beq	.L55
	bl	SECURE_log_cond_br
	movs	r0, #1
	ldr	r10, =mouseRelease
	bl	SECURE_log_call
.L55:
	bl	SECURE_log_cond_br
	ldr	r3, .L61+12
	ldrb	r3, [r3]	@ zero_extendqisi2
	movs	r2, #2
	mov	r1, r3
	movs	r0, #3
	ldr	r10, =readMouseButton
	bl	SECURE_log_call
	mov	r3, r0
	cmp	r3, #0
	beq	.L57
	bl	SECURE_log_cond_br
	movs	r0, #2
	ldr	r10, =mousePress
	bl	SECURE_log_call
	movs	r0, #2
	ldr	r10, =mouseRelease
	bl	SECURE_log_call
.L57:
	bl	SECURE_log_cond_br
	movs	r3, #0
	str	r3, [r7]
	b	.L58
.L59:
	bl	SECURE_log_cond_br
	ldr	r3, [r7]
	adds	r3, r3, #1
	str	r3, [r7]
.L58:
	ldr	r3, [r7]
	cmp	r3, #4
	ble	.L59
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #4]
	adds	r3, r3, #1
	str	r3, [r7, #4]
.L52:
	ldr	r3, [r7, #4]
	cmp	r3, #99
	ble	.L60
	bl	SECURE_log_cond_br
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L62:
	.align	2
.L61:
	.word	lastSwitchState
	.word	mouseActive
	.word	lastMouseLeftState
	.word	lastMouseRightState
	.size	application, .-application
	.ident	"GCC: (15:9-2019-q4-0ubuntu1) 9.2.1 20191025 (release) [ARM/arm-9-branch revision 277599]"
