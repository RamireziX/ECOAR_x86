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

;r9 - height of pattern									
;r10 - width of pattern											
;r11 - address of table of coordinates
;r12 - image width in bytes					
;r13 - startBMP r13
;r14  - width of analyse window r14							saved
;r15 - height of analyse window r15								saved

;[rbp - 40] - pixels counter
;[rbp - 48]	- address of table of coordinates

findPattern:

	push	rbp
	mov		rbp, rsp
	sub		rsp, 48
	
	push	rbx
	push	rdx
	push	rdi
	push	rsi
	
	
	xor		rax, rax
	mov 	eax, 0x0000FFFF
	mov		r9, rsi															
	and		r9, rax

	shr		rsi, 16
	mov		r10, rsi
	and		r10, rax
	
	mov		[rbp - 40], r8
	mov		[rbp - 48], rcx
	mov		r11, rcx
	
;rcx - free

	xor		r14, r14
	mov		r14d, dword[rdi]
	mov		rax, r14 																	
	sub		r14, r10
	inc		r14
	
	xor		r15, r15
	mov		r15d, dword[rdi + 4]
	sub		r15, r9
	inc		r15
	
	;calc line in bytes
	add		rax, 31
	shr		rax, 5
	shl		rax, 2
	mov		r12, rax																	;save width in bytes
	
	mov		r13, [rdi + 8]																;start of bitmap
	
	;save patterns
	mov		rbx, 16
	sub		rbx, r10							;edx how much to move left to left side of second byte [ 4 | 3 | 2 | 1]
	
	mov		rdi, r9							;edi == ry
	mov		rsi, rdx
	
save_patterns_loop:	
	mov		ecx, dword [rsi]
	mov		rax, rbx
	
shift_mask:	
	shl		cx, 1
	dec		rax
 	jnz		shift_mask
	
	mov		word [rbp + 2 * rdi - 16 - 2], cx
	
	add		rsi, 4								;move to next pattern
	dec		rdi
	jnz		save_patterns_loop
	
;create mask
	mov		rsi, r10							;counter = rx
	xor		rdi, rdi
	inc		rdi									;edi = 1
	shl		rdi, 15
	
	xor		r8, r8							;ecx = 0
	
create_mask_loop:
	or		r8, rdi
	shr		rdi, 1
	dec		rsi
	jnz		create_mask_loop
	
;r8 - mask
;;;;;;;;;;;;;;;;;;;;;;;;;;;;MAIN LOOP
		
	xor		rdx, rdx
	
next_line:
	
	mov		rsi, r13;					;rsi - start BMP
	xor		rcx, rcx							;ecx - 
	mov		rdi, r9						;rdi - decremented height of pattern
	xor		rbx, rbx						;ebx - pixels counter right

store_data:
	xor		ax, ax							;eax = 0
	mov		al, byte[rsi + rcx]
	shl		ax, 8
	mov		word[rbp + 2 * rdi - 32 - 2], ax
	
	add		rcx, r12
	
	dec		rdi
	jnz		store_data
	
horizontally_with_load:							;#move analyse window 1 pixel right and load
	mov		rdi, r9						;rdi - decremented height of pattern
	inc		rsi
	xor		rcx, rcx							;ecx - counter lines

vertically_with_load:
	mov		ax, word[rbp + 2 * rdi - 32 - 2]
	mov		al, byte[rsi + rcx]
	add		rcx, r12
	
	shl		eax, 1
	mov		word[rbp + 2 * rdi - 32 - 2], ax
	shr		eax, 1
	
;eax - to analyse

	and		ax, r8w					;masking
	cmp		ax, word[rbp + 2 * rdi - 16 - 2]
	jne		test_nomask_with_load
	dec		rdi
	jnz		vertically_with_load

;save coordinates of found pattern
;edi - address of coordinates
	mov		dword [r11], ebx
	mov		dword [r11 + 4], edx
	add		r11, 8
	
	inc		rbx									;x += 1
	cmp		rbx, r14
	je		test_end
	
	jmp		horizontally_no_load
	
nomask_with_load:								
	mov		ax, word[rbp + 2 * rdi - 32 - 2]
	mov		al, byte[rsi + rcx]
	
	add		rcx, r12
	
	shl		eax, 1
	mov		word[rbp + 2 * rdi - 32 - 2], ax
	shr		eax, 1
	
test_nomask_with_load:
	dec		rdi
	jnz		nomask_with_load
	
	inc		rbx									;x += 1
	cmp		rbx, r14
	je		test_end

horizontally_no_load:						;when pixel number is not divisible by 8
	mov		rdi, r9						;rdi - decremented height of pattern
	
vertically_no_load:
	mov		ax, word[rbp + 2 * rdi - 32 - 2]
	shl		eax, 1
	mov		word[rbp + 2 * rdi - 32 - 2], ax
	shr		eax, 1
	
	and		ax, r8w					;masking
	cmp		ax, [rbp + 2 * rdi - 16 - 2]
	jne		test_nomask_without_load
	dec		rdi
	jnz		vertically_no_load
	
;save coordinates of found pattern
;edi - address of coordinates
	mov		dword [r11], ebx
	mov		dword [r11 + 4], edx
	add		r11, 8
	
	inc		rbx									;x += 1
	cmp		rbx, r14
	je		test_end
	
	;check / 8
	
	mov		al, bl
	shr		al, 3
	shl		al, 3
	cmp		al, bl
	jz		horizontally_with_load
	jmp		horizontally_no_load
	
nomask_no_load:								
	mov		ax, word [rbp + 2 * rdi - 32 - 2]
	shl		ax, 1
	mov		word [rbp + 2 * rdi - 32 - 2], ax
	
test_nomask_without_load:
	dec		rdi
	jnz		nomask_no_load
	
	inc		rbx									;x += 1
	cmp		rbx, r14
	je		test_end
	
	;check / 8
	
	mov		al, bl
	shr		al, 3
	shl		al, 3
	cmp		al, bl
	jz		horizontally_with_load
	jmp		horizontally_no_load
	
test_end:
	mov		rax, r13
	add		rax, r12
	mov		r13, rax
	
	inc		rdx
	cmp		rdx, r15
	jl		next_line
	
		;funct returns address of table of coordinates
	mov		rax, [rbp - 48]
	sub		r11, rax
	shr		r11, 3
	
	mov		rdi, [rbp - 40]
	mov		dword [rdi], r11d
	
	pop		rsi
	pop		rdi
	pop		rdx
	pop		rbx

	mov 	rsp, rbp
	pop 	rbp
	ret
