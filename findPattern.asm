global findPattern

section .text
;Point* findPattern(imgInfo* pImg, int pSize, int* ptrn, Point* pDst, int* fCnt);

;[ebp + 8] - imgInfo* pImg, next start bmp							
;[ebp + 12] - int pSize
;[ebp + 16] - int* ptrn
;[ebp + 20] - Point* pDst
;[ebp + 24] - int* fCnt



;[ebp - 4] - pattern
;[ebp - 8] - pattern
;[ebp - 12] - patter
;[ebp - 16] - pattern
;[ebp - 20] - pattern
;[ebp - 24] - pattern
;[ebp - 28] - pattern
;[ebp - 32] - pattern								[ebp + 4*ecx - 32]

;[ebp - 36] - analyze_data
;[ebp - 40] - analyze_data
;[ebp - 44] - analyze_data
;[ebp - 48] - analyze_data
;[ebp - 52] - analyze_data
;[ebp - 56] - analyze_data
;[ebp - 60] - analyze_data
;[ebp - 64] - analyze_data							[ebp + 4*ecx - 64]


;[ebp - 68] - wysokosc wzorca
;[ebp - 72] - szerokosc wzorca

;[ebp - 76] - szerokosc obrazka pix
;[ebp - 80] - wysokosc obrazka
;[ebp - 84] - szerokosc obrazka byte

;[ebp - 88] - maska
;[ebp - 92] - startBMP

;[ebp - 96] - szerokosc okna analizy
;[ebp - 100] - wysokosc okna analizy
;[ebp - 104] - o ile przesunac w lewo aby wzorzec dosunac do lewej strony drugiego bajtu [ 4 | 3 | 2 | 1]

;

findPattern:


	push	ebp
	mov		ebp, esp
	sub		esp, 120
	

	
	push	ebx
	push	edx
	push	edi
	push	esi
	
	
	
	mov		ebx, [ebp + 8]						;zaladowanie adresu obrazka
	
	mov		eax, [ebx + 8]						;poczatek bitmapy
	mov		[ebp - 92], eax
	
	mov		eax, [ebx + 4]						;wczytanie wysokosci obrazka w pixelach
	mov		[ebp - 80], eax
	mov		edi, eax							;edi - wysokosc obrazka w pikselach
	
	mov		eax, [ebx]						;wczytanie szerokosci obrazka w pixelach
	mov		[ebp - 76], eax
	mov		esi, eax

	
	;lineBytes = ((pInfo->width + 31) >> 5) << 2; // line size in bytes

	add		eax, 31
	shr		eax, 5
	shl		eax, 2
	
	mov		[ebp - 84], eax						;zapis szerokosci obrazka w bajtach
	
	mov 	ecx, 0x0000FFFF
	mov		eax, [ebp + 12]
	mov 	ebx, eax
	and		ebx, ecx							;int ry = pSize & 0x0000FFFF;
	mov		[ebp - 68], ebx						;ebx - wysokosc wzorca
	
	sub		edi, ebx
	inc		edi									;edi - wysokosc okna analizy
	mov		[ebp - 100], edi					
	

	shr		eax, 16								;int rx = pSize >> 16;
	and 	eax, ecx
	mov 	[ebp - 72], eax	
	
	sub		esi, eax
	inc		esi
	mov		[ebp - 96], esi
	
	
	
	
	
	
	
	
;create mask
	mov		ecx, eax							;licznik = rx
	xor		edi, edi
	inc		edi									;edi = 1
	shl		edi, 15
	
	xor		esi, esi							;esi = 0
	

create_mask_loop:
	or		esi, edi
	shr		edi, 1
	dec		ecx
	jnz		create_mask_loop
	
	mov		[ebp - 88], esi						;save mask
	
;save patterns
	mov		edx, 16
	sub		edx, eax							;edx o ile przesunac
	
	mov		[ebp - 104], edx;					
	
	mov		edi, ebx							;edi == ry
	mov		esi, [ebp + 16]
save_patterns_loop:	
	mov		ecx, [esi]
	mov		eax, edx
	
shift_mask:	
	shl		ecx, 1
	dec		eax
 	jnz		shift_mask
	
	mov		[ebp + 4 * edi - 32 - 4], ecx
	
	add		esi, 4								;przesuniecie na kolejny wzorzec
	dec		edi
	jnz		save_patterns_loop
	
	
;GLOWNA PETLA
	
	
kolejna_linia:
	
	
	mov		esi, [ebp - 92];					;edi - start BMP
	xor		ecx, ecx							;ecx - licznik wierszach
	mov		edi, [ebp - 68]						;edi - dekrementowana wysokosc wzorca
	xor		ebx, ebx							;licznik pikseli w prawo
		
	
store_data:
	xor		eax, eax							;eax = 0
	mov		al, byte[esi + ecx]
	shl		eax, 8
	mov		[ebp + 4 * edi - 64 - 4], eax
	
	
	xor		eax, eax
	mov		byte[esi + ecx], al
	
	
	add		ecx, [ebp - 84]
	dec		edi
	jnz		store_data
	
	

	;;;xor		edx, edx
	
poziomo_z_wczytywaniem:							;#przesuniecie okna porownania w prawo o 1 piksel plus wczytywanie
	mov		edi, [ebp - 68]						;edi - dekrementowana wysokosc wzorca
	inc		esi
	xor		ecx, ecx							;ecx - licznik wierszach

pionowo_z_wczytywaniem:
	mov		eax, [ebp + 4 * edi - 64 - 4]
	mov		al, byte[esi + ecx]
	;;;mov		byte[esi + ecx], dl
	
	shl		eax, 1
	mov		[ebp + 4 * edi - 64 - 4], eax
	shr		eax, 1
	
;eax - do analizy

	and		eax, [ebp - 88]					;maskowanie danych
	cmp		eax, [ebp + 4 * edi - 32 - 4]
	jne		test_niemaskowanie_z_wczytywaniem
	dec		edi
	jnz		pionowo_z_wczytywaniem
	
	
;zapis punktow
;ebx
;bl

	
	inc		ebx									;x += 1
	
	
test_niemaskowanie_z_wczytywaniem:

	

	
	
	
	
	
	
	
	
	
	


	

	
	
	
	
	
	
	




	
	
	
	
	
	
	
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

	
	
	
	
	
	
	
	
	
	
end2:	
	

	
	
	
	
	
	mov		ecx, [ebp + 24]
	mov		[ecx], eax
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
end:
	pop		esi
	pop		edi
	pop		edx
	pop		ebx
	
	
	mov 	esp, ebp
	pop 	ebp
	ret
	
	
	
