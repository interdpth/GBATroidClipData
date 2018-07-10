
.gba
.open "zm.gba","Metroid.gba",0x8000000

.definelabel XInPixels, 0x30013E8
.definelabel SamusPose ,0x30013D4
.definelabel HeightFromGround, 0x030013EC
.definelabel Horizontalpos , 0x030013E6
.definelabel FacingState, 0x030013E2
.definelabel Movingmomentum , 0x030013EA
.definelabel ReturnLocation, 0x805A82E
.definelabel HackedClip, 0x8760D38
.definelabel lowGrav, 0x98

//Hijack
.org 0x0805A824
LDR R1, =HackedClip
MOV PC, R1
nop
.pool

//Behaviors?
.org 0x085D9296
.byte 1
.byte 1
.byte 0xC

//Types
.org 0x085D93DC
.byte 0x56 ; V
.byte 0
.byte 0x57 ; W
.byte 0
.byte 0x58 ; X
.byte 0
.byte 0x59 ; Y
.byte 0
.byte 0x5A ; Z
.byte 0
.byte 0x5B ; [
.byte 0
.byte 0x5C ; \
.byte 0
.byte 0x5D ;
.byte 0
.byte 0x42 ; B
.byte 0
.byte 0x41 ; A
.byte 0
.byte 0x43 ; C

//i think cre uses a different table,
//in this case 0x40=0

.org 0x8760D38
.align
	MOV R2, R8
	LDR R1, [R2,#8]
	LSL R0, R0, #1
	ADD R0, R0, R1
	LDRH R3, [R0]
	LDR R1, =SamusPose
	CMP R3, #0x56
HorizontalHalfTile:

	BNE Clip0x57
	LDRH R0, [R1,#(HeightFromGround - 0x30013D4)]
	ADD R0, #4
	STRH R0, [R1,#(HeightFromGround - 0x30013D4)]
	//un
	Clip0x57 :
	CMP R3, #0x57
	BNE Clip0x58
	LDRH R0, [R1,#(HeightFromGround - 0x30013D4)]
	SUB R0, #4
	STRH R0, [R1,#(HeightFromGround - 0x30013D4)]

Clip0x58 :
	CMP R3, #0x58
	BNE Clip0x59
	LDRH R0, [R1,#(Horizontalpos - 0x30013D4)]
	ADD R0, #4
	STRH R0, [R1,#(Horizontalpos - 0x30013D4)]

Clip0x59: 
	CMP R3, #0x59
	BNE Clip0x5a
	LDRH R0, [R1,#(Horizontalpos - 0x30013D4)]
	SUB R0, #4
	STRH R0, [R1,#(Horizontalpos - 0x30013D4)]

Clip0x5a: 
	CMP R3, #0x5A
	BNE Clip0x5B
	LDRH R0, [R1,#(XInPixels - 0x30013D4)]
	ADD R0, #2
	STRH R0, [R1,#(XInPixels - 0x30013D4)]
	LDRH R0, [R1,#(HeightFromGround - 0x30013D4)]
	CMP R0, #0xB0
	BLT Clip0x5B
	mov R0, #0x68
	STRH R0, [R1,#(HeightFromGround - 0x30013D4)]

Clip0x5B:
	CMP R3, #0x5B
	BNE Clip0x5C
	mov R0, #0x16
	LDRSH R0, [R1,R0]
	NEG R0, R0
	STRH R0, [R1,#(Movingmomentum - 0x30013D4)]
	LDRB R0, [R1,#(FacingState - 0x30013D4)]
	mov R3, #0x30
	EOR R0, R3

StoreFacingState:
	STRB R0, [R1,#0xE]

EndOfFunc :

LDR R1, =ReturnLocation
MOV PC, R1


Clip0x5C:
CMP R3, #0x5C
BNE Clip0x5D
LDRB R0, [R1]
CMP R0, #0x22
BEQ IncreaseMomentumHeight
CMP R0, #0x26
BNE EndOfFunc

IncreaseMomentumHeight:
mov R0, #0x16
LDRSH R0, [R1,R0]
LSL R0, R0, #1
STRH R0, [R1,#(Movingmomentum - 0x30013D4)]
mov R0, #0x18
LDRSH R0, [R1,R0]
LSL R0, R0, #1
STRH R0, [R1,#(HeightFromGround - 0x30013D4)]
B EndOfFunc

Clip0x5D:
	CMP R3, #0x5D
	BNE EndOfFunc
	B b8760DD6
// ---------------------------------------------------------------------------

IncreaseHeightAndFaceState:
	LDRSH R0, [R1,R0]
	ASR R0, R0, #1
	STRH R0, [R1,#0x16]
	mov R0, #0x18
	LDRSH R0, [R1,R0]
	ASR R0, R0, #1
	STRH R0, [R1,#0x18]
	B StoreFacingState

b8760DD6:
LDRB R0, [R1]
CMP R0, #0x22
BEQ Return
CMP R0, #0x26
BNE EndOfFunc

Return:
MOV R0, #0x16
B IncreaseHeightAndFaceState
.pool
.close