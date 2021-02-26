bits 32

%define get_pixel 		_get_pixel
%define get_width 		_get_width
%define get_height 		_get_height
%define find_markers 	_find_markers
%define measure_marker 	_measure_marker
%define bytes_per_row 	_bytes_per_row

global get_pixel
global get_width
global get_height
global find_markers
global measure_marker
global bytes_per_row

SECTION .text 
	align 4

%define black 00000000h
%define bytes_per_pixel 3
%define header_size 54
%define header_width_offset 18
%define header_height_offset 22

; method: int find_markers(unsigned char* bitmap, unsigned int* x_pos, unsigned int* y_pos)
%define bitmap 	ebp+8
%define x 		ebp+12
%define y 		ebp+16
%define sw 		ebp+20
%define sh 		ebp+24
%define thick 	ebp+28

%define i 		ebp-4
%define j 		ebp-8
%define ci 		ebp-12
%define cj 		ebp-16

_measure_marker:
	push 	ebp
	mov 	ebp, esp
	;
	sub		esp, 16
	;
	
	mov		dword [i], 0
	mov		dword [j], 0
	mov		dword [ci], 0
	mov		dword [cj], 0	
	
	push	dword [y]
	push	dword [x]
	push	dword [bitmap]
	call	get_pixel
	add		esp, 12
	cmp		eax, black
	jne		_measure_marker_white
	
_measure_marker_black:

	mov		eax, dword [x]
	mov		dword [i], eax
	_loop_logic_a:
		mov		eax, dword [i]
		mov		ecx, dword [x]
		add		ecx, dword [sw]
		cmp		eax, ecx
		jge		_loop_break_a
		
		push	dword [y]
		push	dword [i]
		push	dword [bitmap]
		call	get_pixel
		add		esp, 12
		cmp		eax, black
		jne		_loop_break_a
		
		mov		eax, dword [ci]
		inc		eax
		mov		dword [ci], eax
		
		mov		eax, dword [i]
		inc		eax
		mov		dword [i], eax
		
		jmp		_loop_logic_a		
	_loop_break_a:
	
	
	mov		eax, dword [y]
	mov		dword [j], eax
	_loop_logic_b:
		mov		eax, dword [j]
		mov		ecx, dword [y]
		sub		ecx, dword [sh]
		cmp		eax, ecx
		jle		_loop_break_b
		
		push	dword [j]
		push	dword [x]
		push	dword [bitmap]
		call	get_pixel
		add		esp, 12
		cmp		eax, black
		jne		_loop_break_b
		
		mov		eax, dword [cj]
		inc		eax
		mov		dword [cj], eax
		
		mov		eax, dword [j]
		dec		eax
		mov		dword [j], eax
		
		jmp		_loop_logic_b		
	_loop_break_b:
	
	mov		eax, dword [ci]
	mov		ecx, dword [cj]
	cmp		eax, ecx
	jne		_measure_marker_error
	
	mov		eax, dword [ci]
	mov		ecx, dword [sw]
	cmp		eax, ecx
	jne		_measure_marker_error
	
	mov		eax, dword [cj]
	mov		ecx, dword [sh]
	cmp		eax, ecx
	jne		_measure_marker_error
	
	mov		eax, dword [thick]
	inc		eax
	push	eax
	mov		eax, dword [sh]
	dec		eax
	push	eax
	mov		eax, dword [sw]
	dec		eax
	push	eax	
	mov		eax, dword [y]
	dec		eax
	push	eax
	mov		eax, dword [x]
	inc		eax
	push	eax
	push	dword [bitmap]
	call	_measure_marker
	add		esp, 24

	jmp		_measure_marker_return
_measure_marker_white:
	
	mov		eax, dword [x]
	mov		dword [i], eax
	_loop_logic_c:
		mov		eax, dword [i]
		mov		ecx, dword [x]
		add		ecx, dword [sw]
		cmp		eax, ecx
		jge		_loop_break_c
		
		push	dword [y]
		push	dword [i]
		push	dword [bitmap]
		call	get_pixel
		add		esp, 12
		cmp		eax, black
		je		_loop_break_c
		
		mov		eax, dword [ci]
		inc		eax
		mov		dword [ci], eax
		
		mov		eax, dword [i]
		inc		eax
		mov		dword [i], eax
		
		jmp		_loop_logic_c
	_loop_break_c:
	
	
	mov		eax, dword [y]
	mov		dword [j], eax
	_loop_logic_d:
		mov		eax, dword [j]
		mov		ecx, dword [y]
		sub		ecx, dword [sh]
		cmp		eax, ecx
		jle		_loop_break_d
		
		push	dword [j]
		push	dword [x]
		push	dword [bitmap]
		call	get_pixel
		add		esp, 12
		cmp		eax, black
		je		_loop_break_d
		
		mov		eax, dword [cj]
		inc		eax
		mov		dword [cj], eax
		
		mov		eax, dword [j]
		dec		eax
		mov		dword [j], eax
		
		jmp		_loop_logic_d		
	_loop_break_d:
	
	mov		eax, dword [ci]
	mov		ecx, dword [cj]
	cmp		eax, ecx
	jne		_measure_marker_error
	
	mov		eax, dword [ci]
	mov		ecx, dword [sw]
	cmp		eax, ecx
	jne		_measure_marker_error
	
	mov		eax, dword [cj]
	mov		ecx, dword [sh]
	cmp		eax, ecx
	jne		_measure_marker_error
	
	mov		eax, dword [thick]
	dec		eax

	jmp		_measure_marker_return
_measure_marker_error:
	mov		eax, -1
_measure_marker_return:
	;
	add		esp, 16
	;
	leave
	ret
	
	

; method: int measure_marker(unsigned char* bitmap, int x, int y, int sw, int sh, int thicc)
%define bitmap 	ebp+8
%define x_pos 	ebp+12
%define y_pos 	ebp+16

%define px 		ebp-4
%define py 		ebp-8
%define sw 		ebp-12
%define sh 		ebp-16

%define i 		ebp-20
%define j 		ebp-24
%define x 		ebp-28
%define y 		ebp-32
%define found 	ebp-36

%define w 		ebp-40
%define h 		ebp-44

_find_markers:
	push 	ebp
	mov 	ebp, esp
	;
	sub		esp, 44
	;
	
	mov		dword [px], 0
	mov		dword [py], 0
	mov		dword [sw], 0
	mov		dword [sh], 0
	mov		dword [i], 0
	mov		dword [j], 0
	mov		dword [x], 0
	mov		dword [y], 0
	mov		dword [found], 0
	
	push	dword [bitmap]
	call	get_width
	add		esp, 4
	mov		dword [w], eax
	
	push	dword [bitmap]
	call	get_height
	add		esp, 4
	mov		dword [h], eax
	
	
	mov		dword [y], 0
	for_y:
		mov		eax, dword [y]
		mov		ecx, dword [h]
		cmp		eax, ecx
		jge		for_y_break

		mov		dword [x], 0
		for_x:
			mov		eax, dword [x]
			mov		ecx, dword [w]
			cmp		eax, ecx
			jge		for_x_break


			push	dword [y]
			push	dword [x]
			push	dword [bitmap]
			call	get_pixel
			add		esp, 12
			cmp		eax, black
			jne		for_x_continue			
			
			mov		eax, dword [y]
			dec		eax
			push	eax
			push	dword [x]
			push	dword [bitmap]
			call	get_pixel
			add		esp, 12
			cmp		eax, black
			je		for_x_continue
			
			
			mov		eax, dword [y]
			mov		dword [i], eax
			mov		dword [sh], 0
			_loop_logic_e:
				mov		eax, dword [i]
				mov		ecx, dword [h]
				cmp		eax, ecx
				jge		_loop_break_e
				
				push	dword [i]
				push	dword [x]
				push	dword [bitmap]
				call	get_pixel
				add		esp, 12
				cmp		eax, black
				jne		_loop_break_e
			
				mov		eax, dword [sh]
				inc		eax
				mov		dword [sh], eax
			
				mov		eax, dword [i]
				inc		eax
				mov		dword [i], eax
				
				jmp		_loop_logic_e
			_loop_break_e:
			
					
			mov		eax, dword [y]
			mov		dword [j], eax
			_loop_logic_f:
				mov		eax, dword [j]
				mov		ecx, dword [h]
				cmp		eax, ecx
				jge		_loop_break_f
				
				push	dword [j]
				mov		eax, dword [x]
				dec		eax
				push	eax
				push	dword [bitmap]
				call	get_pixel
				add		esp, 12
				cmp		eax, black
				je		_loop_break_f
			
				mov		eax, dword [j]
				inc		eax
				mov		dword [j], eax
				
				jmp		_loop_logic_f
			_loop_break_f:
			
			
			mov		eax, dword [i]
			mov		ecx, dword [j]
			cmp		eax, ecx
			jg		for_x_continue
			
			
			mov		eax, dword [i]
			dec		eax
			mov		dword [py], eax
			
			mov		eax, dword [x]
			mov		dword [px], eax
			
			
			mov		eax, dword [x]
			mov		dword [i], eax
			mov		dword [sw], 0
			_loop_logic_g:
				mov		eax, dword [i]
				mov		ecx, dword [w]
				cmp		eax, ecx
				jge		_loop_break_g
				
				push	dword [py]
				push	dword [i]
				push	dword [bitmap]
				call	get_pixel
				add		esp, 12
				cmp		eax, black
				jne		_loop_break_g
			
				mov		eax, dword [sw]
				inc		eax
				mov		dword [sw], eax
			
				mov		eax, dword [i]
				inc		eax
				mov		dword [i], eax
				
				jmp		_loop_logic_g
			_loop_break_g:
			
			
			mov		eax, dword [x]
			mov		dword [j], eax
			_loop_logic_h:
				mov		eax, dword [j]
				mov		ecx, dword [w]
				cmp		eax, ecx
				jge		_loop_break_h
				
				mov		eax, dword[py]
				inc		eax
				push	eax
				push	dword [j]
				push	dword [bitmap]
				call	get_pixel
				add		esp, 12
				cmp		eax, black
				je		_loop_break_h
			
				mov		eax, dword [j]
				inc		eax
				mov		dword [j], eax
				
				jmp		_loop_logic_h
			_loop_break_h:
			
			
			mov		eax, dword [i]
			mov		ecx, dword [j]
			cmp		eax, ecx
			jg		for_x_continue
			
			
			mov		eax, dword [sw]
			mov		ecx, dword [sh]
			cmp		eax, ecx
			jg		for_x_continue
			
			
			push	1
			mov		eax, dword [sh]
			dec		eax
			push	eax
			mov		eax, dword [sw]
			dec		eax
			push	eax
			mov		eax, dword [py]
			dec		eax
			push	eax
			mov		eax, dword [px]
			inc		eax
			push	eax
			push	dword [bitmap]
			call	measure_marker
			add		esp, 24
			
			
			cmp		eax, -1
			je		for_x_continue
			
			mov		ecx, dword [sw]
			dec		ecx
			cmp		eax, ecx
			jge		for_x_continue
			
			
			mov		eax, dword [found]
			shl		eax, 2
			add		eax, dword [x_pos]
			mov		ecx, dword [px]
			mov		[eax], ecx
			
			mov		eax, dword [found]
			shl		eax, 2
			add		eax, dword [y_pos]
			mov		ecx, dword [py]
			mov		[eax], ecx
			
			mov		eax, dword [found]
			inc		eax
			mov		dword [found], eax	
			
			for_x_continue:
		
			mov		eax, dword [x]
			inc		eax
			mov		dword [x], eax
			jmp		for_x
		for_x_break:


		mov		eax, dword [y]
		inc		eax
		mov		dword [y], eax
		jmp		for_y
	for_y_break:
	
	mov		eax, dword [found]
	
_find_markers_return:
	;
	add		esp, 44
	;
	leave
	ret
	
	

; method: int get_width(unsigned char* bitmap)
%define bitmap 	ebp+8
_get_width:
	push 	ebp
	mov 	ebp, esp
	;
	mov		ecx, dword [bitmap]
	add		ecx, header_width_offset
	mov		eax, dword [ecx]	
	;
	leave
	ret
	
	
; method: int get_height(unsigned char* bitmap)
%define bitmap 	ebp+8
_get_height:
	push 	ebp
	mov 	ebp, esp
	;
	mov		ecx, dword [bitmap]
	add		ecx, header_height_offset
	mov		eax, dword [ecx]	
	;
	leave
	ret
	
	
; method: int bytes_per_row(unsigned char* bitmap)
%define bitmap 	ebp+8

%define result 	ebp-4
%define remain 	ebp-8
_bytes_per_row:
	push 	ebp
	mov 	ebp, esp
	;
	sub		esp, 8
	;
	
	push	dword [bitmap]
	call	get_width
	add		esp, 4
	imul	eax, bytes_per_pixel
	
	mov		ecx, eax
	and		ecx, 3
	
	cmp		ecx, 0
	je		_bytes_per_row_noremain
	
	add		eax, 4
	sub		eax, ecx
	
_bytes_per_row_noremain:
	;
	add		esp, 8
	;
	leave
	ret
	
	
; method: unsigned int get_pixel(unsigned char* bitmap, int x, int y)
%define bitmap 	ebp+8
%define x 	ebp+12
%define y 	ebp+16
_get_pixel:
	push 	ebp
	mov 	ebp, esp
	;

	push	dword [bitmap]
	call	bytes_per_row
	add		esp, 4
	
	mov		ecx, dword [y]
	imul	eax, ecx
	
	mov		ecx, dword [x]
	imul	ecx, bytes_per_pixel
	
	add		eax, ecx
	
	mov		ecx, dword [bitmap]
	add		ecx, header_size
	
	mov		edx, 0
	add		edx, eax
	add		edx, ecx
	
	mov		eax, dword [edx]
	and		eax, 00FFFFFFh
	
	;
	leave
	ret