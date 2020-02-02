global findPattern

section .text
;Point* findPattern(imgInfo* pImg, int pSize, int* ptrn, Point* pDst, int* fCnt);

;rdi - imgInfo* pImg, next start bmp							
;rsi - int pSize
;rdx - int* ptrn
;rcx - Point* pDst
;r8 - int* fCnt

;[rbp - 2] - pattern
;[rbp - 4] - pattern
;[rbp - 6] - patter
;[rbp - 8] - pattern
;[rbp - 10] - pattern
;[rbp - 12] - pattern
;[rbp - 14] - pattern
;[rbp - 16] - pattern								[rbp + 2*rcx - 16]

;[rbp - 18] - analyze_data
;[rbp - 20] - analyze_data
;[rbp - 22] - analyze_data
;[rbp - 24] - analyze_data
;[rbp - 26] - analyze_data
;[rbp - 28] - analyze_data
;[rbp - 30] - analyze_data
;[rbp - 32] - analyze_data							[rbp + 2*rcx - 32]



;[rbp - 36] - wysokosc wzorca - r9												zapisane
;[rbp - 40] - szerokosc wzorca -r10												zapisane

;[rbp - 44] - adres poczatku tablicy punktow - r11
;[rbp - 48] - szerokosc obrazka byte - r12

;[rbp - 52] - startBMP r-13

;[rbp - 56] - szerokosc okna analizy r14
;[rbp - 60] - wysokosc okna analizy r15



;word [rbp - 62] - maska




;[rbp - 72] - licznik pikseli



findPattern:


	push	rbp
	mov		rbp, rsp
	sub		rsp, 128
	
	push	rbx
	push	rdx
	push	rdi
	push	rsi
	
	
	xor		rax, rax
	mov 	eax, 0x0000FFFF
	mov		r9, rsi
	and		r8, rax
	
	shr		rsi, 16
	mov		r10, rsi
	and		r10, rax
	
	mov		r11, rcx
	

	
	;zapamietanie adresu poczatku tablicy punktow na pozniej
	mov		[rbp - 72], r8																;zapisanie do licznika punktow
	mov		r13, rdi
	
	
	
	
	
	

	
end:
	pop		rsi
	pop		rdi
	pop		rdx
	pop		rbx
	
	
	mov 	rsp, rbp
	pop 	rbp
	ret
	
	
	
