;=====================================================================================
;OFFSET可以取标号的地址(即 一个 是 地址 的 数据)
;指令 也是一种存贮在内存中的 数据 ,可以被读取、覆盖
assume cs:code,ss:stack

stack segment stack
	db 128 dup (0)
stack ends

code segment
	start:	mov ax,stack				;
		mov ss,ax				;
		mov sp,128				;stack段  ss  sp

		call cpy_Tetris				;跳转到cpy_Tetris

		mov ax,4C00H				;程序返回
		int 21H					;
;--------------------------------------------------------------------------
Tetris:		call clear_screen
		mov ax,4C00H				;程序返回
		int 21H					;

clear_screen:	mov bx,1000H
		mov bx,1000H
		mov bx,1000H
		mov bx,1000H
		mov bx,1000H

		ret

Tetris_end:	nop					;空指令
;--------------------------------------------------------------------------
cpy_Tetris:	mov bx,cs				;
		mov ds,bx				;ds = cs
		mov si,OFFSET Tetris			;si = Tetris所在的地址

		mov bx,0 				;bx = 0
		mov es,bx				;es = 0
		mov di,7E00H				;di = 7E00H

		mov cx,OFFSET Tetris_end - Tetris	;cx = 相差的字节数(3)
		cld					;
		rep movsh				;

		ret					;

code ends

end start
;=====================================================================================
;rep movsh	error A2066: Must have instruction after prefix
;==============================================================================
;==========================================================================================
;asm格式，H代表16进制，没有则代表10进制
;程序执行后，ax 中的值为多少？
;应该用call指令的原理来分析，不要再debug中单步跟踪来验证
;单步跟踪的结果，不能代表cpu的实际执行效果	(理论)ax = 3
assume cs:code

stack segment stack			; data段数据	16个字节
	dw	0,0,0,0			;dw 0,0,0,0	0,2,4,6
	dw	0,0,0,0			;dw 0,0,0,0	8,A,C,E
stack ends

code segment				;代码段定义
	start:	mov ax,stack		; 076D:0000 B86C07
		mov ss,ax		; 076D:0003 8ED0
		mov sp,16		; 076D:0005 BC1000
					;
		mov ds,ax		; 076D:0008 8ED8
		mov ax,0 		; 076D:000A B80000
					; ds = ax = ss   sp = 16
					; ax = 0
		call word ptr ds:[0EH]	; 076D:000D FF160E00
					; push ip(0011) -> ss:[sp]
					; ds:[0EH] = ss:[0EH]
					; ip = 0011H
					;
		inc ax			; 076D:0011 40
		inc ax			; 076D:0012 40
		inc ax			; 076D:0013 40

;---------------------------------------------------------------------------
		mov ax,4c00h			;程序返回
		int 21h

code ends

end start
;==========================================================================================
;============================================================================
;在指定的位置，用指定的颜色，显示一个字符串
; dh = 行号	dl = 列数
; cl = 颜色
; ds:si 指向字符串首地址
assume cs:code,ds:data,ss:stack

data segment
	db	'welcome to masm!',0
data ends

stack segment stack
	db	128 dup (0)
stack ends

code segment
	start:	mov ax,data
		mov ds,ax

		mov ax,stack
		mov ss,ax
		mov sp,128

		call init_reg

		call clean_screen

		call show_string

		call up_letter
;=================================================================================
		mov ax,4C00H		;程序返回
		int 21H
;=================================================================================
up_letter:	mov si,0
		mov di,160*11+40*2
showUpletter:	mov cx,0
		mov cl,ds:[si]
		jcxz upLetterend
		and cl,11011111B
		mov ch,07H
		mov es:[di],cx
		inc si
		add di,2
		jmp showUpletter
upLetterend:
		ret
;=================================================================================
show_string:	

showString:	mov cx,0
		mov cl,ds:[si]
		jcxz stringRet
		mov ch,07H
		mov es:[di],cx
		inc si
		add di,2
		jmp showString
stringRet:
		ret
;=================================================================================
clean_screen:	mov bx,0 		;清屏
		mov cx,2000
		mov ax,0720H
cleanScreen:	mov es:[bx],ax
		add bx,2
		loop cleanScreen
		ret
;=================================================================================
init_reg:	mov ax,0B800H		;寄存器初始化
		mov es,ax
		mov di,160*10+40*2	;确定显示位置
		mov si,0 		;data数据地址
		ret
;=================================================================================
code ends

end start
;无法正常显示'!'
;======================================================================================
