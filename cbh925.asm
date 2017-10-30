	.ORIG x3000

;------------------------------TEST VALUES--------------------------------------------------------------------------------------------------
;
;	LD	R6, POINTER	;COMMENT OUT BEFORE SUBMITTING, load test values
;	AND	R5, R5, #0
;	LEA	R5, NUMB1	;R5 <- Address of first test case
;
;
;TESTLP
;	LDR	R7, R5, #0	;load and store test cases
;	STR	R7, R6, #0
;	BRZ	SORTS
;	ADD	R6, R6, #1	;Increment pointer and address of student/grade
;	ADD	R5, R5, #1
;	BR	TESTLP		;keep loading numbers
;
;;	LD	R7, NUMB1	
;;	STR	R7, R6, #0
;;	LD	R7, NUMB2
;;	STR	R7, R6, #1
;;	LD	R7, NUMB3
;;	STR	R7, R6, #2
;;	LD	R7, NUMB4
;;	STR	R7, R6, #3
;;	LD	R7, NUMB5
;;	STR	R7, R6, #4
;;	LD	R7, NUMB6
;;	STR	R7, R6, #5
;;	LD	R7, NUMB7
;;	STR	R7, R6, #6
;;	LD	R7, NUMB8
;;	STR	R7, R6, #7
;;	LD	R7, NUMB9
;;	STR	R7, R6, #8
;;	LD	R7, NUMB10
;;	STR	R7, R6, #9
;;	LD	R7, NUMB11
;;	STR	R7, R6, #10
;;	LD	R7, NUMB12
;;	STR	R7, R6, #11
;
;	
;------------------------------SORT-----------------------------------------------------------------------------------------

SORTS
	LD	R6, IDMASK	;Initialize masks
	LD	R7, GRDMASK
	
	LD	R0, POINTER	;Put starting memory address in both R0, R1
	ADD	R1, R0, #0

	LDR	R2, R0, #0	;If done value at x4300 = 0, finish
	AND	R2, R2, R6
	BRZ	DONESRT
	LDR	R2, R0, #0

LOOP1	LDR	R2, R0, #0

	ADD	R1, R1, #1	;Increment R1 to point to next line of data, load next line of data to R3
	LDR	R3, R1, #0	
	AND	R3, R3, R6	
	BRZ	LOOP2		;if student id in next line of data is 0, done with this round of sorting
	LDR	R3, R1, #0	;must bitmask and unbitmask to check just student id for 0
	
	AND	R3, R3, R7	;bitmask to only compare grades, not IDs
	AND	R2, R2, R7
	NOT	R4, R3		;Convert R3 to negative, in R4
	ADD	R4, R4, #1
	
	ADD	R5, R2, R4	;R2-R4, put in R5. if it's zero or positive, continue to next iteration in Loop1
	BRZP	LOOP1

	LDR	R5, R0, #0	;Swaps the numbers using the values from memory
	LDR	R4, R1, #0
	STR	R5, R1, #0
	STR	R4, R0, #0
	
	BR	LOOP1

LOOP2	ADD	R0, R0, #1	;Increment R0 and R1 for next phase of insertion sort, only sort if id=non-0
	ADD	R1, R0, #0
	LDR	R2, R0, #0
	AND	R2, R2, R6	
	BRNP	LOOP1

DONESRT

;--------------------------NUMBER OF STUDENTS-----------------------------------------------------------------------

	LD	R0, POINTER	;Initialize Pointer and R1
	AND	R1, R1, #0
	

COUNTS

	LDR	R2, R0, #0	;Bitmask for ID and check null
	AND	R2, R2, R6
	BRZ	COUNTF
	
	ADD	R1, R1, #1	;If not null, increment counter
	ADD	R0, R0, #1
	BR	COUNTS

COUNTF
	LD	R0, POINTER	;When null found, store R1 before incrementing again
	STR	R1, R0, #-2	

	ADD	R1, R1, #0	;if Student count >0, continue with finding range and median
	BRNP	RANGES

	ADD	R5, R6, R7	;if studnet count = 0, store the range and median s xFFFF (Add bitmasks to create xFFFF)
	STR	R5, R0, #-3
	STR	R5, R0, #-1
	
	BR	ENDAVG		;if student count =0, now finished

;--------------------------RANGE------------------------------------------------------------------------------------

RANGES
	LD	R0, POINTER	;Initialize R0, R1 <- M[R0]
	LDR	R1, R0, #0
	
	AND	R2, R2, #0	;Prepare for left bitshift, R2 as counter
	ADD	R2, R2, #8
	
BTSHFT	
	ADD	R1, R1, R1	;Bitshift highest grade to 15:9
	ADD	R2, R2, #-1

	BRP	BTSHFT	
	
	LDR	R3, R0, #-2	;Find address of lowest grade
	ADD	R4, R3, R0
	ADD	R4, R4, #-1
	LDR	R5, R4, #0

	AND	R5, R5, R7	;Mask lowest grade
	
	ADD	R1, R5, R1	;add lowest grade to highest grade to concatenate, store at x4000
	STR	R1, R0, #-3 	



;--------------------------MEDIAN-----------------------------------------------------------------------------------

	LD	R0, POINTER	;Initialize pointer to R0, Load number of students into R3
	LDR	R3, R0, #-2
	
DIVID
	AND	R4, R3, #1	;Check if odd, if so subtract 1 to make even
	BRZ	CLEAR5
	ADD	R3, R3, #-1

CLEAR5
	AND	R5, R5, #0	;reset division counter

SUBLOP
	ADD	R3, R3, #0	;subtraction loop with R5 as counter, answer
	BRZ	MEDIAN
	ADD	R5, R5, #1
	ADD	R3, R3, #-2	
	BRNZP	SUBLOP

MEDIAN
	ADD	R4, R4, #0	;Check if odd or even, even, go to average section
	BRZ	AVG
	
	LD	R0, POINTER	;if odd, find the middle number by adding half of total number (rounded down) to first address x4003 and storing that number
	ADD	R1, R0, R5
	LDR	R1, R1, #0	
	AND	R1, R1, R7	;Grademask
	STR	R1, R0, #-1	;Store result in x4002

	BR	ENDAVG
	

AVG
	LD	R0, POINTER

	ADD	R1, R0, R5	;Find the middle two numbers (x4003 + 1/2 total and x4003 + 1/2 total -1), add them together, and divide the result by 2
	LDR	R1, R1, #0
	ADD	R2, R0, R5
	ADD	R2, R2, #-1
	LDR	R2, R2, #0

	AND	R2, R2, R7	;Grademasks for actual values to be averaged
	AND	R1, R1, R7
	
	ADD	R3, R1, R2

DIVID2
	AND	R4, R3, #1	;Divide result by 2 - Reusing code from earlier divide, see comments there
	BRZ	CLEAR52
	ADD	R3, R3, #-1

CLEAR52
	AND	R5, R5, #0

SUBLOP2
	ADD	R3, R3, #0
	BRZ	EVNSTR
	ADD	R5, R5, #1
	ADD	R3, R3, #-2	
	BRNZP	SUBLOP2
	
EVNSTR
	STR	R5, R0, #-1	;Store result in x4002
	


ENDAVG

;----------------------------------------------------------------------------------------------------

	HALT

POINTER	.FILL	x4003
IDMASK	.FILL	XFF00
GRDMASK	.FILL	X00FF

;;NUMB1	.FILL	x0163
;;NUMB2	.FILL	X1264
;;NUMB3	.FILL	X2261
;;NUMB4	.FILL	X3162
;;NUMB5	.FILL	XB560
;;NUMB6	.FILL	X1060
;;NUMB7	.FILL	X0160
;;NUMB8	.FILL	X4C20
;;NUMB9	.FILL	X2820
;;NUMB10	.FILL	X1C21
;;NUMB11	.FILL	X0019
;;NUMB12	.FILL	X0B22

;NUMB1

;;	
.FILL	x3257

;	.FILL 	x2233

;	.FILL 	x123F

;	.FILL 	x4415

;	.FILL 	x8800

;	.FILL 	x5517

;	.FILL 	x613D

;	.FILL 	x4361

;	.FILL 	x8705

;	.FILL 	x173D

;	.FILL 	x0099

;	.FILL	X0000

.END