.model small
.stack 100h
.data
	a dw ?
	b dw ?
	s1 db 'Enter divisor:',10,13,'$'
	s2 db 'Enter dividend:',10,13,'$'
	s3 db 'Quotient: $'
	s4 db 10,13,'Remainder: $'
	err db 'Error! Division by zero.$'
	ten dw 10
.code
main:
	write_signed_num PROC
		push cx
		push dx

		test ax, 8000h
		jz w_go_to_cycle
			neg ax
			push ax
			mov ah, 02h
			mov dl, '-'
			int 21h

			pop ax
		w_go_to_cycle:

		mov cx, 0
		w_cycle1:
			mov dx, 0
			div ten
			push dx
			inc cx
			cmp ax, 0
			jnz w_cycle1

		w_cycle2:
			mov ah, 02h
			pop dx
			add dx, '0'
			int 21h
			dec cx
			cmp cx, 0
			jnz w_cycle2

		pop dx
		pop cx
		ret
	write_signed_num ENDP

	read_signed_num PROC
		push bx
		push cx
		push dx
		push si

		mov bx, 0
		push 0
		mov ch, 0
		mov si, 0

		r_cycle1:
			mov ah, 08h
			int 21h

			mov cl, al

			cmp cl, 8
			jnz r_check_esc
				cmp bx, 1
				jnz r_check_empty
					mov si, 0
				r_check_empty:
					cmp bx, 0
				jz r_check_esc
					mov dx, 0
					pop ax
					div ten
					push ax

					mov ah, 02h
					mov dl, 8
					int 21h
					mov dl, 32
					int 21h
					mov dl, 8
					int 21h

					dec bx
					jmp r_cycle1
			r_check_esc:

			cmp cl, 27
			jnz r_check_minus
				pop ax
				push 0
				mov si, 0

				r_cycle2:
					cmp bx, 0
					jz r_write_char
					dec bx
					mov ah, 02h
					mov dl, 8
					int 21h
					mov dl, 32
					int 21h
					mov dl, 8
					int 21h
					jmp r_cycle2
				r_write_char:

				mov ah, 02h
				mov dl, 8

				jmp r_cycle1
			r_check_minus:

			jmp r_continue
				r_cycle1_a:
				jmp r_cycle1
			r_continue:

			cmp cl, '-'
			jnz r_check_enter
				cmp bx, 0
				jnz r_cycle1
					mov ah, 02h
					mov dl, '-'
					int 21h
					inc bx
					mov si, 1
					jmp r_cycle1
			r_check_enter:

			cmp cl, 13
			jnz r_check_some
				cmp bx, 0
				jz r_check_some
				cmp bx, 1
				jnz r_enter_pressed
				cmp si, 0
				jz r_enter_pressed
			r_check_some:

			cmp si, 0
			jnz r_continue8
				pop ax
				cmp ax, 0
				push ax
				jnz r_continue9
					cmp bx, 1
					jnz r_continue9
						jmp r_cycle1_a
			r_continue8:
				cmp cl, '0'
				jnz r_continue9
					cmp bx, 1
					jz r_cycle1_a
			r_continue9:

			sub cl, '0'
			jc r_cycle1_a

			cmp cl, 10
			jnc r_cycle1_a

		 	pop ax
			mov dx, 0

			mul ten
			jnc r_check_sign
				div ten
				push ax
				jmp r_cycle1_a
			r_check_sign:

			test ax, 8000h
			jz r_add_num
				div ten
				push ax
				jmp r_cycle1_a
			r_add_num:

			add ax, cx
			test ax, 8000h
			jz finish
				cmp si, 0
				jz r_if_positive
					cmp ax, 8000h
					jz finish
				r_if_positive:
					sub ax, cx
					div ten
					push ax
					jmp r_cycle1_a
			finish:

			push ax

			inc bx
			add cl, '0'
			mov ah, 02h
			mov dl, cl
			int 21h

			jmp r_cycle1_a
		r_enter_pressed:

		mov ah, 02h
		mov dl, 13
		int 21h
		mov dl, 10
		int 21h

		pop ax

		cmp si, 0
		jz r_continue14
			neg ax
		r_continue14:

		pop si
		pop dx
		pop cx
		pop bx
		ret
	read_signed_num ENDP

	start:
		mov ax, @data
		mov ds, ax

		mov ah, 09
		lea dx, s1
		int 21h

		call read_signed_num
		mov a, ax

		mov ah, 09
		lea dx, s2
		int 21h

		call read_signed_num
		mov b, ax

		cmp ax, 0
		jz if0
			mov ah, 09
			lea dx, s3
			int 21h

			mov dx, 0
			mov ax, a
			mov bx, b
			cwd
			idiv b
			mov bx, dx

			call write_signed_num

			mov ah, 09
			lea dx, s4
			int 21h

			mov ax, bx
			call write_signed_num

			jmp r_finish
		if0:
			mov ah, 09h
			lea dx, err
			int 21h
		r_finish:

		mov ax, 4c00h
		int 21h
	end start
end main
