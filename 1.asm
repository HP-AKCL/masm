;==========================================================================================
assume cs:code,ds:data,ss:stack

data segment
	;	1个字 = 2个字节 = 16位	1个字节 = 8位
	db	'1975','1976','1977','1978','1979','1980','1981','1982'
	db	'1983','1984','1985','1986','1987','1988','1989','1990'
	db	'1991','1992','1993','1994','1995'
	;year	0	每个数据占用4个字节
	dd	16,22,382,1356,2390,8000,16000,24486,50065,97479,140417
	dd	197514,345980,590827,803530,1183000,1843000,2759000
	dd	3753000,4649000,5937000		; + 30 转化为 十进制
	;summ	84	每个数据占用4个字节	一个dd = 两个dw
	dw	3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037
	dw	5635,8226,11542,14430,15257,17800
	;	168	每个数据占用2个字节	dw 定义的是字型数据

data ends

table segment	stack
		    ;0123456789abcdef
	db 21 dup  ('year summ ne ?? ')
table ends

num segment
	db	9 dup ('0'),0
num ends

stack segment stack				;栈定义		128个字节
	db 64 dup(0)
stack ends

code segment					;代码段定义
	start:	mov ax,stack
		mov ss,ax
		mov sp,64

		call init_reg
		call write_in_table

		call clean_screen
		call init_screen_reg
		call show_time

		mov ax,4C00H			;程序返回
		int 21H
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
show_summ:
		call get__sum

		ret
;---------------------------------------------------------------------------
init_ret_num:
		push ax
		push bx
		push cx
		push es

		mov cx,9
		mov ax,num
		mov es,ax
		mov bx,0
		mov dx,30H
retloopnum:
		mov es:[bx],dl
		inc bx
		loop retloopnum

		pop es
		pop cx
		pop bx
		pop ax
		ret
;---------------------------------------------------------------------------
get__sum:

		mov bx,160*3+15*2
		mov si,0		;16
		mov cx,21
qwewqe:
		push cx
		call init_is_short_div

		call show_div_num
		add si,16
		add bx,160
		pop cx
		loop qwewqe

		call init_ret_num

		mov bx,160*3+30*2
		mov si,5
		mov cx,21
qwewqeq:
		push cx
		call init_is_short_divq

		call show_div_num
		add si,16
		add bx,160
		pop cx
		loop qwewqeq
		
		call init_ret_num

		mov bx,160*3+50*2
		mov si,8
		mov cx,21
qwewqeqw:
		push cx
		call init_is_short_divq

		call show_div_num
		add si,16
		add bx,160
		pop cx
		loop qwewqeqw


		ret
;---------------------------------------------------------------------------
init_is_short_divq:
		push ax
		push bx
		push cx
		push dx
		push ds
		push es
		push si
		push di

		mov ax,table
		mov ds,ax

        	mov ax,num
		mov es,ax
		mov di,9		;0123456789

		mov ax,ds:[si+5]
shortDivq:
		mov cx,10
		mov dx,0
		div cx
		add dx,30H
		mov es:[di],dl
		mov cx,ax
		jcxz shortDivRetq
		dec di
		jmp shortDivq
shortDivRetq:
		pop di
		pop si
		pop es
		pop ds
		pop dx
		pop cx
		pop bx
		pop ax
		ret
;---------------------------------------------------------------------------
show_div_num:
		push ax
		push bx
		push cx
		push dx
		push ds
		push es
		push di
		push si

		mov ax,0B800H
		mov es,ax

		mov ax,num
		mov ds,ax
		mov si,0

		mov cl,ds:[si]
		sub cl,30H
		jcxz get_next_num
		add cl,30H
		jmp next_num

get_next_num:
		inc si
		mov cl,ds:[si]
		sub cl,30H
		jcxz get_next_num
		add cl,30H
		jmp next_num

next_num:
		mov es:[bx],cl
		add bx,2
		inc si
		mov cl,ds:[si]
		jcxz num_end_ret
		jmp next_num
num_end_ret:
		pop si
		pop di
		pop es
		pop ds
		pop dx
		pop cx
		pop bx
		pop ax
		ret
;---------------------------------------------------------------------------
init_is_short_div:
		push ax
		push bx
		push cx
		push dx
		push ds
		push es
		push si
		push di

		mov ax,table
		mov ds,ax

        	mov ax,num
		mov es,ax
		mov di,9		;0123456789

		mov ax,ds:[si+5]
		mov dx,ds:[si+7]

is_short_div:
		mov cx,dx
		jcxz shortDiv
		push ax		;并没有pop
		mov bp,sp
		call long_div
		add sp,2	;与push ax对应
		jmp is_short_div
long_div:
		mov ax,dx
		mov dx,0
		mov cx,10
		div cx
		push ax		;将商push
		mov ax,ss:[bp]
		div cx
		add dx,30H
		mov es:[di],dl
		dec di
		pop dx		;将商pop

		ret
shortDiv:
		mov cx,10
		div cx
		add dx,30H
		mov es:[di],dl
		mov cx,ax
		jcxz shortDivRet
		mov dx,0
		dec di
		jmp shortDiv
shortDivRet:
		pop di
		pop si
		pop es
		pop ds
		pop dx
		pop cx
		pop bx
		pop ax
		ret
;---------------------------------------------------------------------------
clean_screen:
		mov ax,0B800H
		mov es,ax

		mov cx,2000
		mov ax,0720H
		mov bx,0

cleanScreen:	mov es:[bx],ax
		add bx,2
		loop cleanScreen

		ret
;---------------------------------------------------------------------------
init_screen_reg:
		mov ax,0B800H
		mov es,ax
		mov di,160*3+3*2

		mov ax,table
		mov ds,ax
		mov si,0

		ret
;---------------------------------------------------------------------------

show_time:
		call show_year
		call show_summ

		ret

;---------------------------------------------------------------------------
show_year:
		mov cx,21

showYear:	mov bx,0
		push cx
		mov cx,4
showear:
		mov al,ds:[si]
		mov es:[di],al
		inc si
		add di,2
		loop showear

		pop cx
		add si,12
		add di,152
		loop showYear

		ret
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
init_reg:
		mov ax,data
		mov ds,ax
		mov si,0
		mov bx,168

		mov ax,table
		mov es,ax
		mov di,0
		ret
;---------------------------------------------------------------------------
write_in_table:
		mov cx,21

writeInTable:	mov ax,ds:[si]
		mov es:[di],ax
		mov ax,ds:[si+2]
		mov es:[di+2],ax

		mov ax,ds:[si+21*4]
		mov dx,ds:[si+21*4+2]
		mov es:[di+5],ax
		mov es:[di+7],dx

		push ds:[bx]
		pop es:[di+10]

		push cx
		push ax
		push dx
		call num_div
		pop dx
		pop ax
		pop cx

		add si,4
		add bx,2
		add di,16

		loop writeInTable
		ret
;---------------------------------------------------------------------------
num_div:
		div word ptr ds:[bx]
		mov es:[di+13],ax
		ret
;---------------------------------------------------------------------------
code ends

end start
;==========================================================================================

