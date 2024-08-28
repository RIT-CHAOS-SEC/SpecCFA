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
	.section	.rodata.GPS_INVALID_F_ANGLE,"a"
	.align	2
	.type	GPS_INVALID_F_ANGLE, %object
	.size	GPS_INVALID_F_ANGLE, 4
GPS_INVALID_F_ANGLE:
	.space	4
	.section	.rodata.GPS_INVALID_F_ALTITUDE,"a"
	.align	2
	.type	GPS_INVALID_F_ALTITUDE, %object
	.size	GPS_INVALID_F_ALTITUDE, 4
GPS_INVALID_F_ALTITUDE:
	.space	4
	.section	.rodata.GPS_INVALID_F_SPEED,"a"
	.align	2
	.type	GPS_INVALID_F_SPEED, %object
	.size	GPS_INVALID_F_SPEED, 4
GPS_INVALID_F_SPEED:
	.space	4
	.global	encodedCharCount
	.section	.bss.encodedCharCount,"aw",%nobits
	.align	2
	.type	encodedCharCount, %object
	.size	encodedCharCount, 4
encodedCharCount:
	.space	4
	.global	parity
	.section	.bss.parity,"aw",%nobits
	.type	parity, %object
	.size	parity, 1
parity:
	.space	1
	.global	isChecksumTerm
	.section	.bss.isChecksumTerm,"aw",%nobits
	.align	2
	.type	isChecksumTerm, %object
	.size	isChecksumTerm, 4
isChecksumTerm:
	.space	4
	.global	curSentenceType
	.section	.data.curSentenceType,"aw"
	.type	curSentenceType, %object
	.size	curSentenceType, 1
curSentenceType:
	.byte	2
	.global	curTermNumber
	.section	.bss.curTermNumber,"aw",%nobits
	.type	curTermNumber, %object
	.size	curTermNumber, 1
curTermNumber:
	.space	1
	.global	curTermOffset
	.section	.bss.curTermOffset,"aw",%nobits
	.type	curTermOffset, %object
	.size	curTermOffset, 1
curTermOffset:
	.space	1
	.global	term
	.section	.bss.term,"aw",%nobits
	.align	2
	.type	term, %object
	.size	term, 15
term:
	.space	15
	.global	sentenceHasFix
	.section	.bss.sentenceHasFix,"aw",%nobits
	.align	2
	.type	sentenceHasFix, %object
	.size	sentenceHasFix, 4
sentenceHasFix:
	.space	4
	.global	passedChecksumCount
	.section	.bss.passedChecksumCount,"aw",%nobits
	.align	2
	.type	passedChecksumCount, %object
	.size	passedChecksumCount, 4
passedChecksumCount:
	.space	4
	.global	sentencesWithFixCount
	.section	.bss.sentencesWithFixCount,"aw",%nobits
	.align	2
	.type	sentencesWithFixCount, %object
	.size	sentencesWithFixCount, 4
sentencesWithFixCount:
	.space	4
	.global	failedChecksumCount
	.section	.bss.failedChecksumCount,"aw",%nobits
	.align	2
	.type	failedChecksumCount, %object
	.size	failedChecksumCount, 4
failedChecksumCount:
	.space	4
	.section	.text.mystrcmp,"ax",%progbits
	.align	1
	.global	mystrcmp
	.arch armv8-m.main
	.arch_extension dsp
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	mystrcmp, %function
mystrcmp:
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #24
	add	r7, sp, #0
	str	r0, [r7, #4]
	str	r1, [r7]
	movs	r3, #0
	str	r3, [r7, #20]
	movs	r3, #1
	str	r3, [r7, #16]
	movs	r3, #0
	str	r3, [r7, #12]
	b	.L2
.L5:
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #16]
	cmp	r3, #1
	bne	.L3
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #12]
	ldr	r2, [r7, #4]
	add	r3, r3, r2
	ldrb	r2, [r3]	@ zero_extendqisi2
	ldr	r3, [r7, #12]
	ldr	r1, [r7]
	add	r3, r3, r1
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r2, r3
	bls	.L3
	bl	SECURE_log_cond_br
	movs	r3, #1
	str	r3, [r7, #20]
	movs	r3, #0
	str	r3, [r7, #16]
	b	.L4
.L3:
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #16]
	cmp	r3, #1
	bne	.L4
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #12]
	ldr	r2, [r7, #4]
	add	r3, r3, r2
	ldrb	r2, [r3]	@ zero_extendqisi2
	ldr	r3, [r7, #12]
	ldr	r1, [r7]
	add	r3, r3, r1
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r2, r3
	bcs	.L4
	bl	SECURE_log_cond_br
	movs	r3, #1
	str	r3, [r7, #20]
	movs	r3, #0
	str	r3, [r7, #16]
.L4:
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #12]
	adds	r3, r3, #1
	str	r3, [r7, #12]
.L2:
	ldr	r3, [r7, #12]
	cmp	r3, #14
	ble	.L5
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #20]
	mov	r0, r3
	adds	r7, r7, #24
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
	.size	mystrcmp, .-mystrcmp
	.section	.text.isdigit,"ax",%progbits
	.align	1
	.global	isdigit
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	isdigit, %function
isdigit:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	str	r0, [r7, #4]
	ldr	r3, [r7, #4]
	subs	r3, r3, #48
	cmp	r3, #9
	ite	ls
	movls	r3, #1
	movhi	r3, #0
	uxtb	r3, r3
	mov	r0, r3
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
	.size	isdigit, .-isdigit
	.section	.text.fromHex,"ax",%progbits
	.align	1
	.global	fromHex
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	fromHex, %function
fromHex:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	mov	r3, r0
	strb	r3, [r7, #7]
	ldrb	r3, [r7, #7]	@ zero_extendqisi2
	cmp	r3, #64
	bls	.L10
	bl	SECURE_log_cond_br
	ldrb	r3, [r7, #7]	@ zero_extendqisi2
	cmp	r3, #70
	bhi	.L10
	bl	SECURE_log_cond_br
	ldrb	r3, [r7, #7]	@ zero_extendqisi2
	subs	r3, r3, #55
	b	.L11
.L10:
	bl	SECURE_log_cond_br
	ldrb	r3, [r7, #7]	@ zero_extendqisi2
	cmp	r3, #96
	bls	.L12
	bl	SECURE_log_cond_br
	ldrb	r3, [r7, #7]	@ zero_extendqisi2
	cmp	r3, #102
	bhi	.L12
	bl	SECURE_log_cond_br
	ldrb	r3, [r7, #7]	@ zero_extendqisi2
	subs	r3, r3, #87
	b	.L11
.L12:
	bl	SECURE_log_cond_br
	ldrb	r3, [r7, #7]	@ zero_extendqisi2
	subs	r3, r3, #48
.L11:
	mov	r0, r3
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
	.size	fromHex, .-fromHex
	.global	validDate
	.section	.bss.validDate,"aw",%nobits
	.align	2
	.type	validDate, %object
	.size	validDate, 4
validDate:
	.space	4
	.global	upDate
	.section	.bss.upDate,"aw",%nobits
	.align	2
	.type	upDate, %object
	.size	upDate, 4
upDate:
	.space	4
	.global	dateValue
	.section	.bss.dateValue,"aw",%nobits
	.align	2
	.type	dateValue, %object
	.size	dateValue, 4
dateValue:
	.space	4
	.section	.text.date_commit,"ax",%progbits
	.align	1
	.global	date_commit
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	date_commit, %function
date_commit:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	add	r7, sp, #0
	ldr	r3, .L14
	movs	r2, #1
	str	r2, [r3]
	ldr	r3, .L14+4
	movs	r2, #1
	str	r2, [r3]
	pop	{r7, lr}
	b	SECURE_log_ret
.L15:
	.align	2
.L14:
	.word	validDate
	.word	upDate
	.size	date_commit, .-date_commit
	.global	timeVal
	.section	.bss.timeVal,"aw",%nobits
	.align	2
	.type	timeVal, %object
	.size	timeVal, 4
timeVal:
	.space	4
	.global	validTime
	.section	.bss.validTime,"aw",%nobits
	.align	2
	.type	validTime, %object
	.size	validTime, 4
validTime:
	.space	4
	.global	updateTime
	.section	.bss.updateTime,"aw",%nobits
	.align	2
	.type	updateTime, %object
	.size	updateTime, 4
updateTime:
	.space	4
	.section	.text.time_commit,"ax",%progbits
	.align	1
	.global	time_commit
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	time_commit, %function
time_commit:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	add	r7, sp, #0
	ldr	r3, .L17
	movs	r2, #1
	str	r2, [r3]
	ldr	r3, .L17+4
	movs	r2, #1
	str	r2, [r3]
	pop	{r7, lr}
	b	SECURE_log_ret
.L18:
	.align	2
.L17:
	.word	validTime
	.word	updateTime
	.size	time_commit, .-time_commit
	.global	lat
	.section	.bss.lat,"aw",%nobits
	.align	2
	.type	lat, %object
	.size	lat, 4
lat:
	.space	4
	.global	lng
	.section	.bss.lng,"aw",%nobits
	.align	2
	.type	lng, %object
	.size	lng, 4
lng:
	.space	4
	.global	rawNewLatDataNegative
	.section	.bss.rawNewLatDataNegative,"aw",%nobits
	.align	2
	.type	rawNewLatDataNegative, %object
	.size	rawNewLatDataNegative, 4
rawNewLatDataNegative:
	.space	4
	.global	rawNewLongDataNegative
	.section	.bss.rawNewLongDataNegative,"aw",%nobits
	.align	2
	.type	rawNewLongDataNegative, %object
	.size	rawNewLongDataNegative, 4
rawNewLongDataNegative:
	.space	4
	.global	validLoc
	.section	.bss.validLoc,"aw",%nobits
	.align	2
	.type	validLoc, %object
	.size	validLoc, 4
validLoc:
	.space	4
	.global	updateLoc
	.section	.bss.updateLoc,"aw",%nobits
	.align	2
	.type	updateLoc, %object
	.size	updateLoc, 4
updateLoc:
	.space	4
	.section	.text.location_commit,"ax",%progbits
	.align	1
	.global	location_commit
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	location_commit, %function
location_commit:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	add	r7, sp, #0
	ldr	r3, .L20
	movs	r2, #0
	str	r2, [r3]
	ldr	r3, .L20+4
	movs	r2, #0
	str	r2, [r3]
	pop	{r7, lr}
	b	SECURE_log_ret
.L21:
	.align	2
.L20:
	.word	validLoc
	.word	updateLoc
	.size	location_commit, .-location_commit
	.global	speedVal
	.section	.bss.speedVal,"aw",%nobits
	.align	2
	.type	speedVal, %object
	.size	speedVal, 4
speedVal:
	.space	4
	.global	validSpeed
	.section	.bss.validSpeed,"aw",%nobits
	.align	2
	.type	validSpeed, %object
	.size	validSpeed, 4
validSpeed:
	.space	4
	.global	updateSpeed
	.section	.bss.updateSpeed,"aw",%nobits
	.align	2
	.type	updateSpeed, %object
	.size	updateSpeed, 4
updateSpeed:
	.space	4
	.section	.text.speed_commit,"ax",%progbits
	.align	1
	.global	speed_commit
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	speed_commit, %function
speed_commit:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	add	r7, sp, #0
	ldr	r3, .L23
	movs	r2, #1
	str	r2, [r3]
	ldr	r3, .L23+4
	movs	r2, #1
	str	r2, [r3]
	pop	{r7, lr}
	b	SECURE_log_ret
.L24:
	.align	2
.L23:
	.word	validSpeed
	.word	updateSpeed
	.size	speed_commit, .-speed_commit
	.global	degrees
	.section	.bss.degrees,"aw",%nobits
	.align	2
	.type	degrees, %object
	.size	degrees, 4
degrees:
	.space	4
	.global	validDeg
	.section	.bss.validDeg,"aw",%nobits
	.align	2
	.type	validDeg, %object
	.size	validDeg, 4
validDeg:
	.space	4
	.global	updateDeg
	.section	.bss.updateDeg,"aw",%nobits
	.align	2
	.type	updateDeg, %object
	.size	updateDeg, 4
updateDeg:
	.space	4
	.section	.text.course_commit,"ax",%progbits
	.align	1
	.global	course_commit
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	course_commit, %function
course_commit:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	add	r7, sp, #0
	ldr	r3, .L26
	movs	r2, #1
	str	r2, [r3]
	ldr	r3, .L26+4
	movs	r2, #1
	str	r2, [r3]
	pop	{r7, lr}
	b	SECURE_log_ret
.L27:
	.align	2
.L26:
	.word	validDeg
	.word	updateDeg
	.size	course_commit, .-course_commit
	.global	height
	.section	.bss.height,"aw",%nobits
	.align	2
	.type	height, %object
	.size	height, 4
height:
	.space	4
	.global	validAlt
	.section	.bss.validAlt,"aw",%nobits
	.align	2
	.type	validAlt, %object
	.size	validAlt, 4
validAlt:
	.space	4
	.global	updateAlt
	.section	.bss.updateAlt,"aw",%nobits
	.align	2
	.type	updateAlt, %object
	.size	updateAlt, 4
updateAlt:
	.space	4
	.section	.text.altitude_commit,"ax",%progbits
	.align	1
	.global	altitude_commit
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	altitude_commit, %function
altitude_commit:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	add	r7, sp, #0
	ldr	r3, .L29
	movs	r2, #1
	str	r2, [r3]
	ldr	r3, .L29+4
	movs	r2, #1
	str	r2, [r3]
	pop	{r7, lr}
	b	SECURE_log_ret
.L30:
	.align	2
.L29:
	.word	validAlt
	.word	updateAlt
	.size	altitude_commit, .-altitude_commit
	.global	validSat
	.section	.bss.validSat,"aw",%nobits
	.align	2
	.type	validSat, %object
	.size	validSat, 4
validSat:
	.space	4
	.global	updateSat
	.section	.bss.updateSat,"aw",%nobits
	.align	2
	.type	updateSat, %object
	.size	updateSat, 4
updateSat:
	.space	4
	.global	satCount
	.section	.bss.satCount,"aw",%nobits
	.align	2
	.type	satCount, %object
	.size	satCount, 4
satCount:
	.space	4
	.section	.text.satellites_commit,"ax",%progbits
	.align	1
	.global	satellites_commit
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	satellites_commit, %function
satellites_commit:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	add	r7, sp, #0
	ldr	r3, .L32
	movs	r2, #1
	str	r2, [r3]
	ldr	r3, .L32+4
	movs	r2, #1
	str	r2, [r3]
	pop	{r7, lr}
	b	SECURE_log_ret
.L33:
	.align	2
.L32:
	.word	validSat
	.word	updateSat
	.size	satellites_commit, .-satellites_commit
	.global	hdopVal
	.section	.bss.hdopVal,"aw",%nobits
	.align	2
	.type	hdopVal, %object
	.size	hdopVal, 4
hdopVal:
	.space	4
	.global	validHDop
	.section	.bss.validHDop,"aw",%nobits
	.align	2
	.type	validHDop, %object
	.size	validHDop, 4
validHDop:
	.space	4
	.global	updateHDop
	.section	.bss.updateHDop,"aw",%nobits
	.align	2
	.type	updateHDop, %object
	.size	updateHDop, 4
updateHDop:
	.space	4
	.section	.text.hdop_commit,"ax",%progbits
	.align	1
	.global	hdop_commit
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	hdop_commit, %function
hdop_commit:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	add	r7, sp, #0
	ldr	r3, .L35
	movs	r2, #1
	str	r2, [r3]
	ldr	r3, .L35+4
	movs	r2, #1
	str	r2, [r3]
	pop	{r7, lr}
	b	SECURE_log_ret
.L36:
	.align	2
.L35:
	.word	validHDop
	.word	updateHDop
	.size	hdop_commit, .-hdop_commit
	.section	.text.parseDegrees,"ax",%progbits
	.align	1
	.global	parseDegrees
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	parseDegrees, %function
parseDegrees:
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #24
	add	r7, sp, #0
	str	r0, [r7, #4]
	ldr	r0, [r7, #4]
	ldr	r10, =atol
	bl	SECURE_log_call
	mov	r3, r0
	str	r3, [r7, #12]
	ldr	r2, [r7, #12]
	ldr	r3, .L44
	umull	r1, r3, r3, r2
	lsrs	r3, r3, #5
	movs	r1, #100
	mul	r3, r1, r3
	subs	r3, r2, r3
	strh	r3, [r7, #10]	@ movhi
	ldr	r3, .L44+4
	str	r3, [r7, #20]
	ldrh	r2, [r7, #10]
	ldr	r3, [r7, #20]
	mul	r3, r2, r3
	str	r3, [r7, #16]
	ldr	r3, [r7, #12]
	ldr	r2, .L44
	umull	r2, r3, r2, r3
	lsrs	r3, r3, #5
	strh	r3, [r7, #8]	@ movhi
	b	.L38
.L39:
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #4]
	adds	r3, r3, #1
	str	r3, [r7, #4]
.L38:
	ldr	r3, [r7, #4]
	ldrb	r3, [r3]	@ zero_extendqisi2
	subs	r3, r3, #48
	cmp	r3, #9
	bls	.L39
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #4]
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #46
	bne	.L40
	bl	SECURE_log_cond_br
	b	.L41
.L42:
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #20]
	ldr	r2, .L44+8
	umull	r2, r3, r2, r3
	lsrs	r3, r3, #3
	str	r3, [r7, #20]
	ldr	r3, [r7, #4]
	ldrb	r3, [r3]	@ zero_extendqisi2
	subs	r3, r3, #48
	mov	r2, r3
	ldr	r3, [r7, #20]
	mul	r3, r3, r2
	ldr	r2, [r7, #16]
	add	r3, r3, r2
	str	r3, [r7, #16]
.L41:
	ldr	r3, [r7, #4]
	adds	r3, r3, #1
	str	r3, [r7, #4]
	ldr	r3, [r7, #4]
	ldrb	r3, [r3]	@ zero_extendqisi2
	subs	r3, r3, #48
	cmp	r3, #9
	bls	.L42
	bl	SECURE_log_cond_br
.L40:
	bl	SECURE_log_cond_br
	ldrsh	r3, [r7, #8]
	vmov	s15, r3	@ int
	vcvt.f32.s32	s14, s15
	ldr	r2, [r7, #16]
	mov	r3, r2
	lsls	r3, r3, #2
	add	r3, r3, r2
	adds	r3, r3, #1
	ldr	r2, .L44+12
	umull	r2, r3, r2, r3
	lsrs	r3, r3, #1
	vmov	s15, r3	@ int
	vcvt.f32.u32	s13, s15
	vldr.32	s12, .L44+16
	vdiv.f32	s15, s13, s12
	vadd.f32	s15, s14, s15
	vcvt.s32.f32	s15, s15
	vmov	r3, s15	@ int
	strh	r3, [r7, #8]	@ movhi
	ldrsh	r3, [r7, #8]
	vmov	s15, r3	@ int
	vcvt.f32.s32	s15, s15
	vmov.f32	s0, s15
	adds	r7, r7, #24
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L45:
	.align	2
.L44:
	.word	1374389535
	.word	10000000
	.word	-858993459
	.word	-1431655765
	.word	1315859240
	.size	parseDegrees, .-parseDegrees
	.section	.text.parseDecimal,"ax",%progbits
	.align	1
	.global	parseDecimal
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	parseDecimal, %function
parseDecimal:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #16
	add	r7, sp, #0
	str	r0, [r7, #4]
	ldr	r3, [r7, #4]
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #45
	ite	eq
	moveq	r3, #1
	movne	r3, #0
	uxtb	r3, r3
	str	r3, [r7, #8]
	ldr	r3, [r7, #8]
	cmp	r3, #0
	beq	.L47
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #4]
	adds	r3, r3, #1
	str	r3, [r7, #4]
.L47:
	bl	SECURE_log_cond_br
	ldr	r0, [r7, #4]
	ldr	r10, =atol
	bl	SECURE_log_call
	mov	r3, r0
	movs	r2, #100
	mul	r3, r2, r3
	str	r3, [r7, #12]
	b	.L48
.L49:
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #4]
	adds	r3, r3, #1
	str	r3, [r7, #4]
.L48:
	ldr	r3, [r7, #4]
	ldrb	r3, [r3]	@ zero_extendqisi2
	subs	r3, r3, #48
	cmp	r3, #9
	bls	.L49
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #4]
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #46
	bne	.L50
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #4]
	adds	r3, r3, #1
	ldrb	r3, [r3]	@ zero_extendqisi2
	subs	r3, r3, #48
	cmp	r3, #9
	bhi	.L50
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #4]
	adds	r3, r3, #1
	ldrb	r3, [r3]	@ zero_extendqisi2
	sub	r2, r3, #48
	mov	r3, r2
	lsls	r3, r3, #2
	add	r3, r3, r2
	lsls	r3, r3, #1
	mov	r2, r3
	ldr	r3, [r7, #12]
	add	r3, r3, r2
	str	r3, [r7, #12]
	ldr	r3, [r7, #4]
	adds	r3, r3, #2
	ldrb	r3, [r3]	@ zero_extendqisi2
	subs	r3, r3, #48
	cmp	r3, #9
	bhi	.L50
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #4]
	adds	r3, r3, #2
	ldrb	r3, [r3]	@ zero_extendqisi2
	subs	r3, r3, #48
	ldr	r2, [r7, #12]
	add	r3, r3, r2
	str	r3, [r7, #12]
.L50:
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #8]
	cmp	r3, #0
	beq	.L51
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #12]
	rsbs	r3, r3, #0
	b	.L53
.L51:
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #12]
.L53:
	mov	r0, r3
	adds	r7, r7, #16
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
	.size	parseDecimal, .-parseDecimal
	.section	.text.time_setTime,"ax",%progbits
	.align	1
	.global	time_setTime
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	time_setTime, %function
time_setTime:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	str	r0, [r7, #4]
	ldr	r0, [r7, #4]
	ldr	r10, =parseDecimal
	bl	SECURE_log_call
	mov	r3, r0
	ldr	r2, .L55
	str	r3, [r2]
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L56:
	.align	2
.L55:
	.word	timeVal
	.size	time_setTime, .-time_setTime
	.section	.text.location_setLatitude,"ax",%progbits
	.align	1
	.global	location_setLatitude
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	location_setLatitude, %function
location_setLatitude:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	str	r0, [r7, #4]
	ldr	r0, [r7, #4]
	ldr	r10, =parseDegrees
	bl	SECURE_log_call
	vmov.f32	s15, s0
	ldr	r3, .L58
	vstr.32	s15, [r3]
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L59:
	.align	2
.L58:
	.word	lat
	.size	location_setLatitude, .-location_setLatitude
	.section	.text.location_setLongitude,"ax",%progbits
	.align	1
	.global	location_setLongitude
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	location_setLongitude, %function
location_setLongitude:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	str	r0, [r7, #4]
	ldr	r0, [r7, #4]
	ldr	r10, =parseDegrees
	bl	SECURE_log_call
	vmov.f32	s15, s0
	ldr	r3, .L61
	vstr.32	s15, [r3]
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L62:
	.align	2
.L61:
	.word	lng
	.size	location_setLongitude, .-location_setLongitude
	.section	.text.speed_set,"ax",%progbits
	.align	1
	.global	speed_set
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	speed_set, %function
speed_set:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	str	r0, [r7, #4]
	ldr	r0, [r7, #4]
	ldr	r10, =parseDecimal
	bl	SECURE_log_call
	vmov	s15, r0	@ int
	vcvt.f32.s32	s15, s15
	ldr	r3, .L64
	vstr.32	s15, [r3]
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L65:
	.align	2
.L64:
	.word	speedVal
	.size	speed_set, .-speed_set
	.section	.text.course_set,"ax",%progbits
	.align	1
	.global	course_set
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	course_set, %function
course_set:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	str	r0, [r7, #4]
	ldr	r0, [r7, #4]
	ldr	r10, =parseDecimal
	bl	SECURE_log_call
	vmov	s15, r0	@ int
	vcvt.f32.s32	s15, s15
	ldr	r3, .L67
	vstr.32	s15, [r3]
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L68:
	.align	2
.L67:
	.word	degrees
	.size	course_set, .-course_set
	.section	.text.satellites_set,"ax",%progbits
	.align	1
	.global	satellites_set
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	satellites_set, %function
satellites_set:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	str	r0, [r7, #4]
	ldr	r3, .L70
	ldr	r3, [r3]
	adds	r3, r3, #1
	ldr	r2, .L70
	str	r3, [r2]
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L71:
	.align	2
.L70:
	.word	satCount
	.size	satellites_set, .-satellites_set
	.section	.text.date_setDate,"ax",%progbits
	.align	1
	.global	date_setDate
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	date_setDate, %function
date_setDate:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	str	r0, [r7, #4]
	ldr	r0, [r7, #4]
	ldr	r10, =atol
	bl	SECURE_log_call
	mov	r3, r0
	mov	r2, r3
	ldr	r3, .L73
	str	r2, [r3]
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L74:
	.align	2
.L73:
	.word	dateValue
	.size	date_setDate, .-date_setDate
	.section	.text.hdop_set,"ax",%progbits
	.align	1
	.global	hdop_set
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	hdop_set, %function
hdop_set:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	str	r0, [r7, #4]
	ldr	r0, [r7, #4]
	ldr	r10, =parseDecimal
	bl	SECURE_log_call
	vmov	s15, r0	@ int
	vcvt.f32.s32	s15, s15
	ldr	r3, .L76
	vstr.32	s15, [r3]
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L77:
	.align	2
.L76:
	.word	hdopVal
	.size	hdop_set, .-hdop_set
	.section	.text.altitude_set,"ax",%progbits
	.align	1
	.global	altitude_set
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	altitude_set, %function
altitude_set:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	str	r0, [r7, #4]
	ldr	r0, [r7, #4]
	ldr	r10, =parseDecimal
	bl	SECURE_log_call
	vmov	s15, r0	@ int
	vcvt.f32.s32	s15, s15
	ldr	r3, .L79
	vstr.32	s15, [r3]
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L80:
	.align	2
.L79:
	.word	height
	.size	altitude_set, .-altitude_set
	.section	.rodata
	.align	2
.LC0:
	.ascii	"GPRMC\000"
	.align	2
.LC1:
	.ascii	"GNRMC\000"
	.align	2
.LC2:
	.ascii	"GPGGA\000"
	.align	2
.LC3:
	.ascii	"GNGGA\000"
	.section	.text.endOfTermHandler,"ax",%progbits
	.align	1
	.global	endOfTermHandler
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	endOfTermHandler, %function
endOfTermHandler:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r4, r7, lr}
	sub	sp, sp, #12
	add	r7, sp, #0
	ldr	r3, .L121
	ldr	r3, [r3]
	cmp	r3, #0
	beq	.L82
	bl	SECURE_log_cond_br
	ldr	r3, .L121+4
	ldrb	r3, [r3]	@ zero_extendqisi2
	mov	r0, r3
	ldr	r10, =fromHex
	bl	SECURE_log_call
	mov	r3, r0
	uxtb	r3, r3
	lsls	r3, r3, #4
	uxtb	r4, r3
	ldr	r3, .L121+4
	ldrb	r3, [r3, #1]	@ zero_extendqisi2
	mov	r0, r3
	ldr	r10, =fromHex
	bl	SECURE_log_call
	mov	r3, r0
	uxtb	r3, r3
	add	r3, r3, r4
	strb	r3, [r7, #7]
	ldr	r3, .L121+8
	ldrb	r3, [r3]	@ zero_extendqisi2
	ldrb	r2, [r7, #7]	@ zero_extendqisi2
	cmp	r2, r3
	bne	.L83
	bl	SECURE_log_cond_br
	ldr	r3, .L121+12
	ldr	r3, [r3]
	adds	r3, r3, #1
	ldr	r2, .L121+12
	str	r3, [r2]
	ldr	r3, .L121+16
	ldr	r3, [r3]
	cmp	r3, #0
	beq	.L84
	bl	SECURE_log_cond_br
	ldr	r3, .L121+20
	ldr	r3, [r3]
	adds	r3, r3, #1
	ldr	r2, .L121+20
	str	r3, [r2]
.L84:
	bl	SECURE_log_cond_br
	ldr	r3, .L121+24
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #0
	beq	.L85
	bl	SECURE_log_cond_br
	cmp	r3, #1
	bne	.L86
	bl	SECURE_log_cond_br
	ldr	r10, =date_commit
	bl	SECURE_log_call
	ldr	r10, =time_commit
	bl	SECURE_log_call
	ldr	r3, .L121+16
	ldr	r3, [r3]
	cmp	r3, #0
	beq	.L117
	bl	SECURE_log_cond_br
	ldr	r10, =location_commit
	bl	SECURE_log_call
	ldr	r10, =speed_commit
	bl	SECURE_log_call
	ldr	r10, =course_commit
	bl	SECURE_log_call
	b	.L117
.L85:
	bl	SECURE_log_cond_br
	ldr	r10, =time_commit
	bl	SECURE_log_call
	ldr	r3, .L121+16
	ldr	r3, [r3]
	cmp	r3, #0
	beq	.L88
	bl	SECURE_log_cond_br
	ldr	r10, =location_commit
	bl	SECURE_log_call
	ldr	r10, =altitude_commit
	bl	SECURE_log_call
.L88:
	bl	SECURE_log_cond_br
	ldr	r10, =satellites_commit
	bl	SECURE_log_call
	ldr	r10, =hdop_commit
	bl	SECURE_log_call
	b	.L86
.L117:
	bl	SECURE_log_cond_br
.L86:
	bl	SECURE_log_cond_br
	movs	r3, #1
	b	.L89
.L83:
	bl	SECURE_log_cond_br
	ldr	r3, .L121+28
	ldr	r3, [r3]
	adds	r3, r3, #1
	ldr	r2, .L121+28
	str	r3, [r2]
.L82:
	bl	SECURE_log_cond_br
	ldr	r3, .L121+32
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #0
	bne	.L90
	bl	SECURE_log_cond_br
	ldr	r1, .L121+36
	ldr	r0, .L121+4
	ldr	r10, =mystrcmp
	bl	SECURE_log_call
	mov	r3, r0
	cmp	r3, #0
	beq	.L91
	bl	SECURE_log_cond_br
	ldr	r1, .L121+40
	ldr	r0, .L121+4
	ldr	r10, =mystrcmp
	bl	SECURE_log_call
	mov	r3, r0
	cmp	r3, #0
	bne	.L92
	bl	SECURE_log_cond_br
.L91:
	bl	SECURE_log_cond_br
	ldr	r3, .L121+24
	movs	r2, #1
	strb	r2, [r3]
	b	.L90
.L92:
	bl	SECURE_log_cond_br
	ldr	r1, .L121+44
	ldr	r0, .L121+4
	ldr	r10, =mystrcmp
	bl	SECURE_log_call
	mov	r3, r0
	cmp	r3, #0
	beq	.L93
	bl	SECURE_log_cond_br
	ldr	r1, .L121+48
	ldr	r0, .L121+4
	ldr	r10, =mystrcmp
	bl	SECURE_log_call
	mov	r3, r0
	cmp	r3, #0
	bne	.L94
	bl	SECURE_log_cond_br
.L93:
	bl	SECURE_log_cond_br
	ldr	r3, .L121+24
	movs	r2, #0
	strb	r2, [r3]
	b	.L90
.L94:
	bl	SECURE_log_cond_br
	ldr	r3, .L121+24
	movs	r2, #2
	strb	r2, [r3]
.L90:
	bl	SECURE_log_cond_br
	ldr	r3, .L121+24
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #2
	beq	.L118
	bl	SECURE_log_cond_br
	ldr	r3, .L121+4
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #0
	beq	.L118
	bl	SECURE_log_cond_br
	ldr	r3, .L121+24
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #0
	beq	.L96
	bl	SECURE_log_cond_br
	cmp	r3, #1
	bne	.L95
	bl	SECURE_log_cond_br
	ldr	r3, .L121+32
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #9
	beq	.L97
	bl	SECURE_log_cond_br
	cmp	r3, #9
	bgt	.L119
	bl	SECURE_log_cond_br
	cmp	r3, #8
	beq	.L99
	bl	SECURE_log_cond_br
	cmp	r3, #8
	bgt	.L119
	bl	SECURE_log_cond_br
	cmp	r3, #7
	beq	.L100
	bl	SECURE_log_cond_br
	cmp	r3, #7
	bgt	.L119
	bl	SECURE_log_cond_br
	cmp	r3, #6
	beq	.L101
	bl	SECURE_log_cond_br
	cmp	r3, #6
	bgt	.L119
	bl	SECURE_log_cond_br
	cmp	r3, #5
	beq	.L102
	bl	SECURE_log_cond_br
	cmp	r3, #5
	bgt	.L119
	bl	SECURE_log_cond_br
	cmp	r3, #4
	beq	.L103
	bl	SECURE_log_cond_br
	cmp	r3, #4
	bgt	.L119
	bl	SECURE_log_cond_br
	cmp	r3, #3
	beq	.L104
	bl	SECURE_log_cond_br
	cmp	r3, #3
	bgt	.L119
	bl	SECURE_log_cond_br
	cmp	r3, #1
	beq	.L105
	bl	SECURE_log_cond_br
	cmp	r3, #2
	beq	.L106
	bl	SECURE_log_cond_br
	b	.L119
.L105:
	bl	SECURE_log_cond_br
	ldr	r0, .L121+4
	ldr	r10, =time_setTime
	bl	SECURE_log_call
	b	.L98
.L106:
	bl	SECURE_log_cond_br
	ldr	r3, .L121+4
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #65
	ite	eq
	moveq	r3, #1
	movne	r3, #0
	uxtb	r3, r3
	mov	r2, r3
	ldr	r3, .L121+16
	str	r2, [r3]
	b	.L98
.L104:
	bl	SECURE_log_cond_br
	ldr	r0, .L121+4
	ldr	r10, =location_setLatitude
	bl	SECURE_log_call
	b	.L98
.L103:
	bl	SECURE_log_cond_br
	ldr	r3, .L121+4
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #83
	ite	eq
	moveq	r3, #1
	movne	r3, #0
	uxtb	r3, r3
	mov	r2, r3
	ldr	r3, .L121+52
	str	r2, [r3]
	b	.L98
.L102:
	bl	SECURE_log_cond_br
	ldr	r0, .L121+4
	ldr	r10, =location_setLongitude
	bl	SECURE_log_call
	b	.L98
.L101:
	bl	SECURE_log_cond_br
	ldr	r3, .L121+4
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #87
	ite	eq
	moveq	r3, #1
	movne	r3, #0
	uxtb	r3, r3
	mov	r2, r3
	ldr	r3, .L121+56
	str	r2, [r3]
	b	.L98
.L100:
	bl	SECURE_log_cond_br
	ldr	r0, .L121+4
	ldr	r10, =speed_set
	bl	SECURE_log_call
	b	.L98
.L99:
	bl	SECURE_log_cond_br
	ldr	r0, .L121+4
	ldr	r10, =course_set
	bl	SECURE_log_call
	b	.L98
.L97:
	bl	SECURE_log_cond_br
	ldr	r0, .L121+4
	ldr	r10, =date_setDate
	bl	SECURE_log_call
.L98:
	b	.L119
.L96:
	bl	SECURE_log_cond_br
	ldr	r3, .L121+32
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #9
	beq	.L107
	bl	SECURE_log_cond_br
	cmp	r3, #9
	bgt	.L120
	bl	SECURE_log_cond_br
	cmp	r3, #8
	beq	.L109
	bl	SECURE_log_cond_br
	cmp	r3, #8
	bgt	.L120
	bl	SECURE_log_cond_br
	cmp	r3, #7
	beq	.L110
	bl	SECURE_log_cond_br
	cmp	r3, #7
	bgt	.L120
	bl	SECURE_log_cond_br
	cmp	r3, #6
	beq	.L111
	bl	SECURE_log_cond_br
	cmp	r3, #6
	bgt	.L120
	bl	SECURE_log_cond_br
	cmp	r3, #5
	beq	.L112
	bl	SECURE_log_cond_br
	cmp	r3, #5
	bgt	.L120
	bl	SECURE_log_cond_br
	cmp	r3, #4
	beq	.L113
	bl	SECURE_log_cond_br
	cmp	r3, #4
	bgt	.L120
	bl	SECURE_log_cond_br
	cmp	r3, #3
	beq	.L114
	bl	SECURE_log_cond_br
	cmp	r3, #3
	bgt	.L120
	bl	SECURE_log_cond_br
	cmp	r3, #1
	beq	.L115
	bl	SECURE_log_cond_br
	cmp	r3, #2
	beq	.L116
	bl	SECURE_log_cond_br
	b	.L120
.L115:
	bl	SECURE_log_cond_br
	ldr	r0, .L121+4
	ldr	r10, =time_setTime
	bl	SECURE_log_call
	b	.L108
.L116:
	bl	SECURE_log_cond_br
	ldr	r0, .L121+4
	ldr	r10, =location_setLatitude
	bl	SECURE_log_call
	b	.L108
.L114:
	bl	SECURE_log_cond_br
	ldr	r3, .L121+4
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #83
	ite	eq
	moveq	r3, #1
	movne	r3, #0
	uxtb	r3, r3
	mov	r2, r3
	ldr	r3, .L121+52
	str	r2, [r3]
	b	.L108
.L113:
	bl	SECURE_log_cond_br
	ldr	r0, .L121+4
	ldr	r10, =location_setLongitude
	bl	SECURE_log_call
	b	.L108
.L112:
	bl	SECURE_log_cond_br
	ldr	r3, .L121+4
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #87
	ite	eq
	moveq	r3, #1
	movne	r3, #0
	uxtb	r3, r3
	mov	r2, r3
	ldr	r3, .L121+56
	str	r2, [r3]
	b	.L108
.L111:
	bl	SECURE_log_cond_br
	ldr	r3, .L121+4
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #0
	ite	ne
	movne	r3, #1
	moveq	r3, #0
	uxtb	r3, r3
	mov	r2, r3
	ldr	r3, .L121+16
	str	r2, [r3]
	b	.L108
.L110:
	bl	SECURE_log_cond_br
	ldr	r0, .L121+4
	ldr	r10, =satellites_set
	bl	SECURE_log_call
	b	.L108
.L122:
	.align	2
.L121:
	.word	isChecksumTerm
	.word	term
	.word	parity
	.word	passedChecksumCount
	.word	sentenceHasFix
	.word	sentencesWithFixCount
	.word	curSentenceType
	.word	failedChecksumCount
	.word	curTermNumber
	.word	.LC0
	.word	.LC1
	.word	.LC2
	.word	.LC3
	.word	rawNewLatDataNegative
	.word	rawNewLongDataNegative
.L109:
	bl	SECURE_log_cond_br
	ldr	r0, .L123
	ldr	r10, =hdop_set
	bl	SECURE_log_call
	b	.L108
.L107:
	bl	SECURE_log_cond_br
	ldr	r0, .L123
	ldr	r10, =altitude_set
	bl	SECURE_log_call
.L108:
	b	.L120
.L118:
	bl	SECURE_log_cond_br
	b	.L95
.L119:
	bl	SECURE_log_cond_br
	b	.L95
.L120:
	bl	SECURE_log_cond_br
.L95:
	bl	SECURE_log_cond_br
	movs	r3, #0
.L89:
	mov	r0, r3
	adds	r7, r7, #12
	mov	sp, r7
	@ sp needed
	pop	{r4, r7, lr}
	b	SECURE_log_ret
.L124:
	.align	2
.L123:
	.word	term
	.size	endOfTermHandler, .-endOfTermHandler
	.section	.text.gps_encode,"ax",%progbits
	.align	1
	.global	gps_encode
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	gps_encode, %function
gps_encode:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #16
	add	r7, sp, #0
	mov	r3, r0
	strb	r3, [r7, #7]
	ldrb	r3, [r7, #7]	@ zero_extendqisi2
	mov	r0, r3
	bl	SECURE_record_output_data
	ldr	r3, .L136
	ldr	r3, [r3]
	adds	r3, r3, #1
	ldr	r2, .L136
	str	r3, [r2]
	ldrb	r3, [r7, #7]	@ zero_extendqisi2
	cmp	r3, #44
	beq	.L126
	bl	SECURE_log_cond_br
	cmp	r3, #44
	bgt	.L127
	bl	SECURE_log_cond_br
	cmp	r3, #42
	beq	.L128
	bl	SECURE_log_cond_br
	cmp	r3, #42
	bgt	.L127
	bl	SECURE_log_cond_br
	cmp	r3, #36
	beq	.L129
	bl	SECURE_log_cond_br
	cmp	r3, #36
	bgt	.L127
	bl	SECURE_log_cond_br
	cmp	r3, #10
	beq	.L130
	bl	SECURE_log_cond_br
	cmp	r3, #13
	beq	.L131
	bl	SECURE_log_cond_br
	b	.L127
.L126:
	bl	SECURE_log_cond_br
	ldr	r3, .L136+4
	ldrb	r2, [r3]	@ zero_extendqisi2
	ldrb	r3, [r7, #7]
	eors	r3, r3, r2
	uxtb	r2, r3
	ldr	r3, .L136+4
	strb	r2, [r3]
	movs	r0, #49
	bl	SECURE_record_output_data
.L131:
	bl	SECURE_log_cond_br
	movs	r0, #50
	bl	SECURE_record_output_data
.L130:
	bl	SECURE_log_cond_br
	movs	r0, #51
	bl	SECURE_record_output_data
.L128:
	bl	SECURE_log_cond_br
	movs	r0, #52
	bl	SECURE_record_output_data
	movs	r3, #0
	str	r3, [r7, #12]
	ldr	r3, .L136+8
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #14
	bhi	.L132
	bl	SECURE_log_cond_br
	ldr	r3, .L136+8
	ldrb	r3, [r3]	@ zero_extendqisi2
	mov	r2, r3
	ldr	r3, .L136+12
	movs	r1, #0
	strb	r1, [r3, r2]
	ldr	r10, =endOfTermHandler
	bl	SECURE_log_call
	str	r0, [r7, #12]
.L132:
	bl	SECURE_log_cond_br
	ldr	r3, .L136+16
	ldrb	r3, [r3]	@ zero_extendqisi2
	adds	r3, r3, #1
	uxtb	r2, r3
	ldr	r3, .L136+16
	strb	r2, [r3]
	ldr	r3, .L136+8
	movs	r2, #0
	strb	r2, [r3]
	ldrb	r3, [r7, #7]	@ zero_extendqisi2
	cmp	r3, #42
	ite	eq
	moveq	r3, #1
	movne	r3, #0
	uxtb	r3, r3
	mov	r2, r3
	ldr	r3, .L136+20
	str	r2, [r3]
	ldr	r3, [r7, #12]
	b	.L133
.L129:
	bl	SECURE_log_cond_br
	movs	r0, #53
	bl	SECURE_record_output_data
	ldr	r3, .L136+8
	movs	r2, #0
	strb	r2, [r3]
	ldr	r3, .L136+8
	ldrb	r2, [r3]	@ zero_extendqisi2
	ldr	r3, .L136+16
	strb	r2, [r3]
	ldr	r3, .L136+4
	movs	r2, #0
	strb	r2, [r3]
	ldr	r3, .L136+24
	movs	r2, #2
	strb	r2, [r3]
	ldr	r3, .L136+20
	movs	r2, #0
	str	r2, [r3]
	ldr	r3, .L136+28
	movs	r2, #0
	str	r2, [r3]
	movs	r3, #0
	b	.L133
.L127:
	bl	SECURE_log_cond_br
	movs	r0, #54
	bl	SECURE_record_output_data
	ldr	r3, .L136+8
	ldrb	r3, [r3]	@ zero_extendqisi2
	cmp	r3, #13
	bhi	.L134
	bl	SECURE_log_cond_br
	ldr	r3, .L136+8
	ldrb	r3, [r3]	@ zero_extendqisi2
	adds	r2, r3, #1
	uxtb	r1, r2
	ldr	r2, .L136+8
	strb	r1, [r2]
	mov	r1, r3
	ldr	r2, .L136+12
	ldrb	r3, [r7, #7]
	strb	r3, [r2, r1]
.L134:
	bl	SECURE_log_cond_br
	ldr	r3, .L136+20
	ldr	r3, [r3]
	cmp	r3, #0
	bne	.L135
	bl	SECURE_log_cond_br
	ldr	r3, .L136+4
	ldrb	r2, [r3]	@ zero_extendqisi2
	ldrb	r3, [r7, #7]
	eors	r3, r3, r2
	uxtb	r2, r3
	ldr	r3, .L136+4
	strb	r2, [r3]
.L135:
	bl	SECURE_log_cond_br
	movs	r3, #0
.L133:
	mov	r0, r3
	adds	r7, r7, #16
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L137:
	.align	2
.L136:
	.word	encodedCharCount
	.word	parity
	.word	curTermOffset
	.word	term
	.word	curTermNumber
	.word	isChecksumTerm
	.word	curSentenceType
	.word	sentenceHasFix
	.size	gps_encode, .-gps_encode
	.section	.text.get_position,"ax",%progbits
	.align	1
	.global	get_position
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	get_position, %function
get_position:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	str	r0, [r7, #4]
	str	r1, [r7]
	ldr	r3, [r7, #4]
	cmp	r3, #0
	beq	.L139
	bl	SECURE_log_cond_br
	ldr	r3, .L142
	vldr.32	s15, [r3]
	vcvt.s32.f32	s15, s15
	vmov	r2, s15	@ int
	ldr	r3, [r7, #4]
	str	r2, [r3]
.L139:
	bl	SECURE_log_cond_br
	ldr	r3, [r7]
	cmp	r3, #0
	beq	.L141
	bl	SECURE_log_cond_br
	ldr	r3, .L142+4
	vldr.32	s15, [r3]
	vcvt.s32.f32	s15, s15
	vmov	r2, s15	@ int
	ldr	r3, [r7]
	str	r2, [r3]
.L141:
	bl	SECURE_log_cond_br
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L143:
	.align	2
.L142:
	.word	lat
	.word	lng
	.size	get_position, .-get_position
	.section	.text.f_get_position,"ax",%progbits
	.align	1
	.global	f_get_position
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	f_get_position, %function
f_get_position:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #16
	add	r7, sp, #0
	str	r0, [r7, #4]
	str	r1, [r7]
	add	r2, r7, #8
	add	r3, r7, #12
	mov	r1, r2
	mov	r0, r3
	ldr	r10, =get_position
	bl	SECURE_log_call
	ldr	r3, [r7, #12]
	ldr	r2, .L149
	cmp	r3, r2
	beq	.L145
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #12]
	vmov	s15, r3	@ int
	vcvt.f32.s32	s14, s15
	vldr.32	s13, .L149+4
	vdiv.f32	s15, s14, s13
	b	.L146
.L145:
	bl	SECURE_log_cond_br
	vldr.32	s15, .L149+8
.L146:
	ldr	r3, [r7, #4]
	vstr.32	s15, [r3]
	ldr	r3, [r7, #8]
	ldr	r2, .L149
	cmp	r3, r2
	beq	.L147
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #8]
	vmov	s15, r3	@ int
	vcvt.f32.s32	s14, s15
	vldr.32	s13, .L149+4
	vdiv.f32	s15, s14, s13
	b	.L148
.L147:
	bl	SECURE_log_cond_br
	vldr.32	s15, .L149+8
.L148:
	ldr	r3, [r7]
	vstr.32	s15, [r3]
	adds	r7, r7, #16
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L150:
	.align	2
.L149:
	.word	999999999
	.word	1232348160
	.word	0
	.size	f_get_position, .-f_get_position
	.section	.text.get_datetime,"ax",%progbits
	.align	1
	.global	get_datetime
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	get_datetime, %function
get_datetime:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	str	r0, [r7, #4]
	str	r1, [r7]
	ldr	r3, [r7, #4]
	cmp	r3, #0
	beq	.L152
	bl	SECURE_log_cond_br
	ldr	r3, .L155
	ldr	r2, [r3]
	ldr	r3, [r7, #4]
	str	r2, [r3]
.L152:
	bl	SECURE_log_cond_br
	ldr	r3, [r7]
	cmp	r3, #0
	beq	.L154
	bl	SECURE_log_cond_br
	ldr	r3, .L155+4
	ldr	r3, [r3]
	mov	r2, r3
	ldr	r3, [r7]
	str	r2, [r3]
.L154:
	bl	SECURE_log_cond_br
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L156:
	.align	2
.L155:
	.word	dateValue
	.word	timeVal
	.size	get_datetime, .-get_datetime
	.section	.text.crack_datetime,"ax",%progbits
	.align	1
	.global	crack_datetime
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	crack_datetime, %function
crack_datetime:
	@ args = 12, pretend = 0, frame = 24
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #24
	add	r7, sp, #0
	str	r0, [r7, #12]
	str	r1, [r7, #8]
	str	r2, [r7, #4]
	str	r3, [r7]
	add	r2, r7, #16
	add	r3, r7, #20
	mov	r1, r2
	mov	r0, r3
	ldr	r10, =get_datetime
	bl	SECURE_log_call
	ldr	r3, [r7, #12]
	cmp	r3, #0
	beq	.L158
	bl	SECURE_log_cond_br
	ldr	r2, [r7, #20]
	ldr	r3, .L168
	umull	r1, r3, r3, r2
	lsrs	r3, r3, #5
	movs	r1, #100
	mul	r3, r1, r3
	subs	r3, r2, r3
	mov	r2, r3
	ldr	r3, [r7, #12]
	str	r2, [r3]
	ldr	r3, [r7, #12]
	ldr	r3, [r3]
	ldr	r2, [r7, #12]
	ldr	r2, [r2]
	cmp	r2, #80
	ble	.L159
	bl	SECURE_log_cond_br
	movw	r2, #1900
	b	.L160
.L159:
	bl	SECURE_log_cond_br
	mov	r2, #2000
.L160:
	add	r2, r2, r3
	ldr	r3, [r7, #12]
	str	r2, [r3]
.L158:
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #8]
	cmp	r3, #0
	beq	.L161
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #20]
	ldr	r2, .L168
	umull	r2, r3, r2, r3
	lsrs	r2, r3, #5
	ldr	r3, .L168
	umull	r1, r3, r3, r2
	lsrs	r3, r3, #5
	movs	r1, #100
	mul	r3, r1, r3
	subs	r3, r2, r3
	uxtb	r2, r3
	ldr	r3, [r7, #8]
	strb	r2, [r3]
.L161:
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #4]
	cmp	r3, #0
	beq	.L162
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #20]
	ldr	r2, .L168+4
	umull	r2, r3, r2, r3
	lsrs	r3, r3, #13
	uxtb	r2, r3
	ldr	r3, [r7, #4]
	strb	r2, [r3]
.L162:
	bl	SECURE_log_cond_br
	ldr	r3, [r7]
	cmp	r3, #0
	beq	.L163
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #16]
	ldr	r2, .L168+8
	umull	r2, r3, r2, r3
	lsrs	r3, r3, #18
	uxtb	r2, r3
	ldr	r3, [r7]
	strb	r2, [r3]
.L163:
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #32]
	cmp	r3, #0
	beq	.L164
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #16]
	ldr	r2, .L168+4
	umull	r2, r3, r2, r3
	lsrs	r2, r3, #13
	ldr	r3, .L168
	umull	r1, r3, r3, r2
	lsrs	r3, r3, #5
	movs	r1, #100
	mul	r3, r1, r3
	subs	r3, r2, r3
	uxtb	r2, r3
	ldr	r3, [r7, #32]
	strb	r2, [r3]
.L164:
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #36]
	cmp	r3, #0
	beq	.L165
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #16]
	ldr	r2, .L168
	umull	r2, r3, r2, r3
	lsrs	r2, r3, #5
	ldr	r3, .L168
	umull	r1, r3, r3, r2
	lsrs	r3, r3, #5
	movs	r1, #100
	mul	r3, r1, r3
	subs	r3, r2, r3
	uxtb	r2, r3
	ldr	r3, [r7, #36]
	strb	r2, [r3]
.L165:
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #40]
	cmp	r3, #0
	beq	.L167
	bl	SECURE_log_cond_br
	ldr	r2, [r7, #16]
	ldr	r3, .L168
	umull	r1, r3, r3, r2
	lsrs	r3, r3, #5
	movs	r1, #100
	mul	r3, r1, r3
	subs	r3, r2, r3
	uxtb	r2, r3
	ldr	r3, [r7, #40]
	strb	r2, [r3]
.L167:
	bl	SECURE_log_cond_br
	adds	r7, r7, #24
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L169:
	.align	2
.L168:
	.word	1374389535
	.word	-776530087
	.word	1125899907
	.size	crack_datetime, .-crack_datetime
	.section	.text.stats,"ax",%progbits
	.align	1
	.global	stats
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	stats, %function
stats:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #16
	add	r7, sp, #0
	str	r0, [r7, #12]
	str	r1, [r7, #8]
	str	r2, [r7, #4]
	ldr	r3, [r7, #12]
	cmp	r3, #0
	beq	.L171
	bl	SECURE_log_cond_br
	ldr	r3, .L175
	ldr	r3, [r3]
	mov	r2, r3
	ldr	r3, [r7, #12]
	str	r2, [r3]
.L171:
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #8]
	cmp	r3, #0
	beq	.L172
	bl	SECURE_log_cond_br
	ldr	r3, .L175+4
	ldr	r3, [r3]
	uxth	r2, r3
	ldr	r3, [r7, #8]
	strh	r2, [r3]	@ movhi
.L172:
	bl	SECURE_log_cond_br
	ldr	r3, [r7, #4]
	cmp	r3, #0
	beq	.L174
	bl	SECURE_log_cond_br
	ldr	r3, .L175+8
	ldr	r3, [r3]
	uxth	r2, r3
	ldr	r3, [r7, #4]
	strh	r2, [r3]	@ movhi
.L174:
	bl	SECURE_log_cond_br
	adds	r7, r7, #16
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L176:
	.align	2
.L175:
	.word	encodedCharCount
	.word	passedChecksumCount
	.word	failedChecksumCount
	.size	stats, .-stats
	.section	.text.gpsdump,"ax",%progbits
	.align	1
	.global	gpsdump
	.syntax unified
	.thumb
	.thumb_func
	.fpu fpv5-sp-d16
	.type	gpsdump, %function
gpsdump:
	@ args = 0, pretend = 0, frame = 48
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r4, r7, lr}
	sub	sp, sp, #68
	add	r7, sp, #16
	add	r2, r7, #40
	add	r3, r7, #44
	mov	r1, r2
	mov	r0, r3
	ldr	r10, =get_position
	bl	SECURE_log_call
	add	r2, r7, #32
	add	r3, r7, #36
	mov	r1, r2
	mov	r0, r3
	ldr	r10, =f_get_position
	bl	SECURE_log_call
	add	r2, r7, #24
	add	r3, r7, #28
	mov	r1, r2
	mov	r0, r3
	ldr	r10, =get_datetime
	bl	SECURE_log_call
	add	r4, r7, #13
	add	r2, r7, #14
	add	r1, r7, #15
	add	r0, r7, #16
	add	r3, r7, #10
	str	r3, [sp, #8]
	add	r3, r7, #11
	str	r3, [sp, #4]
	add	r3, r7, #12
	str	r3, [sp]
	mov	r3, r4
	ldr	r10, =crack_datetime
	bl	SECURE_log_call
	adds	r2, r7, #6
	add	r1, r7, #8
	add	r3, r7, #20
	mov	r0, r3
	ldr	r10, =stats
	bl	SECURE_log_call
	adds	r7, r7, #52
	mov	sp, r7
	@ sp needed
	pop	{r4, r7, lr}
	b	SECURE_log_ret
	.size	gpsdump, .-gpsdump
	.global	input_buffer
	.section	.rodata.input_buffer,"a"
	.align	2
	.type	input_buffer, %object
	.size	input_buffer, 46
input_buffer:
	.ascii	"$GPRMC\01210.23,A,-24,N,54,W,15.43,99.9,1234*34\012"
	.ascii	"\000"
	.comm	lt,4,4
	.comm	ln,4,4
	.comm	d,4,4
	.comm	t,4,4
	.comm	c,4,4
	.comm	y,4,4
	.comm	m,1,1
	.comm	da,1,1
	.comm	h,1,1
	.comm	mi,1,1
	.comm	s,1,1
	.comm	hu,1,1
	.comm	se,2,2
	.comm	f,2,2
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
	b	.L179
.L180:
	bl	SECURE_log_cond_br
	ldr	r2, .L181
	ldr	r3, [r7, #4]
	add	r3, r3, r2
	ldrb	r3, [r3]	@ zero_extendqisi2
	mov	r0, r3
	ldr	r10, =gps_encode
	bl	SECURE_log_call
	ldr	r3, [r7, #4]
	adds	r3, r3, #1
	str	r3, [r7, #4]
.L179:
	ldr	r3, [r7, #4]
	cmp	r3, #45
	ble	.L180
	bl	SECURE_log_cond_br
	ldr	r10, =gpsdump
	bl	SECURE_log_call
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, lr}
	b	SECURE_log_ret
.L182:
	.align	2
.L181:
	.word	input_buffer
	.size	application, .-application
	.ident	"GCC: (15:9-2019-q4-0ubuntu1) 9.2.1 20191025 (release) [ARM/arm-9-branch revision 277599]"
