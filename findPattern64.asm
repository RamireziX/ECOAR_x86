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



;r9 - wysokosc wzorca									
;r10 - szerokosc wzorca											
;r11 - adres poczatku tablicy punktow
;r12 - szerokosc obrazka byte					
;r13 - startBMP r13
;r14  - szerokosc okna analizy r14							zapisane
;r15 - wysokosc okna analizy r15								zapisane



;[rbp - 40] - licznik pikseli
;[rbp - 48]	- adres pocatku tablicy punktow



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
	
;rsi - nipotrzebe juz
	mov		[rbp - 40], r8
	mov		[rbp - 48], rcx
	mov		r11, rcx
	
;rcx - wolne


	
	;zapamietanie adresu poczatku tablicy punktow na pozniej
																;
	
	
	xor		r14, r14
	mov		r14d, dword[rdi]
	mov		rax, r14 																	
	sub		r14, r10
	inc		r14
	
	xor		r15, r15
	mov		r15d, dword[rdi + 4]
	sub		r15, r9
	inc		r15
	

	;wyliczenie dlugosci linii w bajtach
	add		rax, 31
	shr		rax, 5
	shl		rax, 2
	mov		r12, rax																	;zapis szerokosci obrazu w bajtach
	
	mov		r13, [rdi + 8]																;poczatek bitmapy
	

	;save patterns
	mov		rbx, 16
	sub		rbx, r10							;edx o ile przesunac w lewo aby wzorzec dosunac do lewej strony drugiego bajtu [ 4 | 3 | 2 | 1]
	
	
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
	
	add		rsi, 4								;przesuniecie na kolejny wzorzec
	dec		rdi
	jnz		save_patterns_loop
	
	
		
;create mask
	mov		rsi, r10							;licznik = rx
	xor		rdi, rdi
	inc		rdi									;edi = 1
	shl		rdi, 15
	
	xor		r8, r8							;ecx = 0


create_mask_loop:
	or		r8, rdi
	shr		rdi, 1
	dec		rsi
	jnz		create_mask_loop
	
	
;r8 - maska


;GLOWNA PETLA
		
	xor		rdx, rdx
	
	
kolejna_linia:
	
	
	mov		rsi, r13;					;rsi - start BMP
	xor		rcx, rcx							;ecx - 
	mov		rdi, r9						;rdi - dekrementowana wysokosc wzorca
	xor		rbx, rbx						;ebx - licznik pikseli w prawo

	
store_data:
	xor		ax, ax							;eax = 0
	mov		al, byte[rsi + rcx]
	shl		ax, 8
	mov		word[rbp + 2 * rdi - 32 - 2], ax
	
	add		rcx, r12
	
	dec		rdi
	jnz		store_data
	
	;[rbp + 2*ecx - 32 - 2]
	


	;;;xor		edx, edx
	
poziomo_z_wczytywaniem:							;#przesuniecie okna porownania w prawo o 1 piksel plus wczytywanie
	mov		rdi, r9						;rdi - dekrementowana wysokosc wzorca
	inc		rsi
	xor		rcx, rcx							;ecx - licznik wierszach

pionowo_z_wczytywaniem:
	;mov		eax, [rbp + 4 * rdi - 64 - 4]
	mov		ax, word[rbp + 2 * rdi - 32 - 2]
	mov		al, byte[rsi + rcx]
	
	add		rcx, r12
	
	
	shl		eax, 1
	mov		word[rbp + 2 * rdi - 32 - 2], ax
	shr		eax, 1
	
;eax - do analizy

	and		ax, r8w					;maskowanie danych
	cmp		ax, word[rbp + 2 * rdi - 16 - 2]
	jne		test_niemaskowanie_z_wczytywaniem
	dec		rdi
	jnz		pionowo_z_wczytywaniem
	

;zapisanie x, y znalezionego wzorca
;edi - adres punktow
	mov		dword [r11], ebx
	mov		dword [r11 + 4], edx
	add		r11, 8
	
	inc		rbx									;x += 1
	cmp		rbx, r14
	je		test_koniec
	
	jmp		poziomo_bez_wczytywania

	
	
niemaskowanie_z_wczytywaniem:								
	mov		ax, word[rbp + 2 * rdi - 32 - 2]
	mov		al, byte[rsi + rcx]
	
	
	add		rcx, r12
	
	
	shl		eax, 1
	mov		word[rbp + 2 * rdi - 32 - 2], ax
	shr		eax, 1
	
test_niemaskowanie_z_wczytywaniem:
	dec		rdi
	jnz		niemaskowanie_z_wczytywaniem
	
	inc		rbx									;x += 1
	cmp		rbx, r14
	je		test_koniec

	
poziomo_bez_wczytywania:						;gdy numer piksela nie jest wielokrotnoscia 8
	mov		rdi, r9						;rdi - dekrementowana wysokosc wzorca
	
	
	
pionowo_bez_wczytywania:
	mov		ax, word[rbp + 2 * rdi - 32 - 2]
	shl		eax, 1
	mov		word[rbp + 2 * rdi - 32 - 2], ax
	shr		eax, 1
	
	and		ax, r8w					;maskowanie danych
	cmp		ax, [rbp + 2 * rdi - 16 - 2]
	jne		test_niemaskowanie_bez_wczytywania
	dec		rdi
	jnz		pionowo_bez_wczytywania
	
		

;zapisanie x, y znalezionego wzorca
;edi - adres punktow
	mov		dword [r11], ebx
	mov		dword [r11 + 4], edx
	add		r11, 8
	
	inc		rbx									;x += 1
	cmp		rbx, r14
	je		test_koniec
	
	
	;sprawdzic podzielnosc przez 8
	
	mov		al, bl
	shr		al, 3
	shl		al, 3
	cmp		al, bl
	jz		poziomo_z_wczytywaniem
	jmp		poziomo_bez_wczytywania
	
	
niemaskowanie_bez_wczytywania:								
	mov		ax, word [rbp + 2 * rdi - 32 - 2]
	shl		ax, 1
	mov		word [rbp + 2 * rdi - 32 - 2], ax
	
test_niemaskowanie_bez_wczytywania:
	dec		rdi
	jnz		niemaskowanie_bez_wczytywania
	
	inc		rbx									;x += 1
	cmp		rbx, r14
	je		test_koniec
	
	
	;sprawdzic podzielnosc przez 8
	
	mov		al, bl
	shr		al, 3
	shl		al, 3
	cmp		al, bl
	jz		poziomo_z_wczytywaniem
	jmp		poziomo_bez_wczytywania
	
test_koniec:
	mov		rax, r13
	add		rax, r12
	mov		r13, rax
	
	inc		rdx
	cmp		rdx, r15
	jl		kolejna_linia
	
	
	
	
		;funkcja zwraca adres poczatku tablicy punktow
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
	
	
	
