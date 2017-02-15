;困惑=======================================================================
assume	cs:code,ds:data,ss:stack

data segment
	dw 0123h,0456h,0789h,0abch,0defh,0fedh,0cbah,0987h
data ends

stack segment stack
	dw 0,0,0,0,0,0,0,0
stack ends

code segment

start:		mov ax,stack
		mov ss,ax
		mov sp,16

		mov ax,data
		mov ds,ax
		mov bx,0

		mov cx,8

pushData:	push ds:[bx]
		add bx,2

		loop pushData

		mov bx,0
		mov cx,8
popData:	pop ds:[bx]
		add bx,2
		loop popData

		mov ax,4c00h
		int 21h

code ends

end start
;===========================================================================
;===========================================================================
;困惑(将data数据段push存放0000:0000(bx)中的数据,在使用pop取出其中数据,在进行下一个字节的存取)
assume	cs:code,ds:data,ss:stack

data segment
	dw 0123h,0456h,0789h,0abch,0defh,0fedh,0cbah,0987h
data ends

stack segment stack			;并无使用
	dw 0,0,0,0,0,0,0,0
stack ends


code segment

start:		mov ax,cs		; ss = cs  , sp = 32
		mov ss,ax
		mov sp,32

		mov ax,0 		; ds = 0000 , bx = 0000
		mov ds,ax
		mov bx,0

		mov cx,8		; cx = 0008

popData:	push ds:[bx]		;将0000:0000中的数据放入到 ss:sp 中(即data数据段)
		pop cs:[bx]		;将ss:sp(即data数据段)数据写入cs;bx中(即data数据段)
		add bx,2		;bx指向后两个字节
		loop popData		;循环

;-----------------------------------------------------------
		mov ax,4c00h
		int 21h

code ends

end start
;===========================================================================
