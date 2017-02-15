;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;问题： 显示时钟时 无法进行操作
;	更改时钟 无法将时间更改
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;*****************************************************************************************
;*****************************************************************************************
; 中断 int 19H 在 0:7E00H 处 实现
;1.列出功能选项，让用户通过键盘进行选择，界面如下。
;	 1)	reset pc		;重新启动计算机
;	 2)	start system		;引导现有的操作系统
;	 3)	clock			;进入时钟程序
;	 4)	set clock		;设置时间
;1.	用户输入 '1' 后重新启动计算机	(考虑FFFF:0)
;2.	用户输入 '2' 引导现有的操作系统	(考虑硬盘C的0道0面1扇区)
;3.	用户输入 '3' 动态显示当前的日期，时间	(无限读取CMOS)
;		按下 F1 后，改变显示颜色，
;		按下 Esc 后，返回到主选单	(利用键盘中断)
;4.	用户输入 '4' 改变当前的日期，时间，更改后返回到主选单	(输入字符串)
;*****************************************************************************************
;*****************************************************************************************
;===========================================================================================
assume cs:code,ss:stack

stack segment stack
	db	256 dup (0)
stack ends

code segment
	start:
		mov bx,stack
		mov ss,bx
		mov sp,256
;int 7CH 中断设置------------------------------------------------------------
		call cpy_new_init7CH
		call set_new_init7CH
		int 7CH
;----------------------------------------------------------------------------
		mov ax,4C00H
		int 21H
;----------------------------------------------------------------------------
;实现功能--------------------------------------------------------------------
;int 7CH 中断 内容-----------------------------------------------------------
new_init7CH:
		call clean_screen
		jmp show_menue
;***********************************************************************
;***********************************************************************
;***********************************************************************
ABLE1:	db	'1)     reset pc',0H		;重新启动计算机
ABLE2:	db	'2)     start system',0H	;引导现有的操作系统
ABLE3:	db	'3)     clock',0H		;进入时钟程序
ABLE4:	db	'4)     set clock',0H		;设置时间
;********************************************************
MENUE	dw	OFFSET ABLE1 - OFFSET new_init7CH + 7E00H
	dw	OFFSET ABLE2 - OFFSET new_init7CH + 7E00H
	dw	OFFSET ABLE3 - OFFSET new_init7CH + 7E00H
	dw	OFFSET ABLE4 - OFFSET new_init7CH + 7E00H
;********************************************************
TIME_STYLE	db	'YY/MM/DD HH:MM:SS',0
TIME_ADDR	dw	9,8,7,4,2,0
;********************************************************
SET_TIME_STYLE	db	'00 00 00 00 00 00'
;********************************************************
MENUE_ABLE	dw	OFFSET able_1 - OFFSET new_init7CH + 7E00H
		dw	OFFSET able_2 - OFFSET new_init7CH + 7E00H
		dw	OFFSET able_3 - OFFSET new_init7CH + 7E00H
		dw	OFFSET able_4 - OFFSET new_init7CH + 7E00H
;********************************************************
RESTART		db	'RESTART PC',0
;***********************************************************************
;***********************************************************************
;***********************************************************************
;////////////////////////////////////////////////////////////////////////////
;------------------------------------------------------------------
;显示能够选择的功能------------------------------------------------
show_menue:
		call init_show_menue_reg
		call show_show_menue
;键盘输入--------------------------------
		mov ah,0H		;mov ah,0
		int 16H			;int 16H  输入 3
;		mov al,3		;   与  mov al,3 的结果不同
					; 已解决
		call show_able_num	;显示输入的 功能号
;处理输入的功能号  调用相应的功能--------
		mov bx,0
		mov es,bx
		sub al,31H		;键盘读取的是 ASCII码 需要将其转换为 数字(-30H)
		mov bl,al
		add bl,bl
		mov ax,OFFSET MENUE_ABLE - OFFSET new_init7CH + 7E00H
		add bx,ax
		call word ptr es:[bx]
		iret
;--------------------------------------------------
;显示输入的功能号----------------------------------
show_able_num:
		call init_show_able_num_reg
		mov es:[di],al
		ret

init_show_able_num_reg:
		mov bx,0B800H
		mov es,bx
		mov di,160*5

		ret
;////////////////////////////////////////////////////////////////////////////
;--------------------------------------------------
;--------------------------------------------------
;功能 2 引导现有的操作系统-------------------------
able_2:
		jmp show_menue		; 从功能程序返回 不能使用 ret
;////////////////////////////////////////////////////////////////////////////
;--------------------------------------------------
;--------------------------------------------------
;功能 1 重新启动计算机-----------------------------
able_1:

get_able_1:
		call init_able_1

		call show_able_1
		jmp show_menue
;------------------------------------
show_able_1:
		mov dl,ds:[si]
		cmp dl,0
		je ShowAble1Ret
		mov es:[di],dl
		inc si
		add di,2
		jmp show_able_1
ShowAble1Ret:
		ret
;------------------------------------
init_able_1:
		mov bx,0B800H
		mov es,bx
		mov di,160*10

		mov bx,0
		mov ds,bx
		mov si,OFFSET RESTART - OFFSET new_init7CH + 7E00H
		ret
;////////////////////////////////////////////////////////////////////////////
;--------------------------------------------------
;--------------------------------------------------
;功能 4 设置时钟-----------------------------------
able_4:
		call init_get_bale_4
		call get_able_4
		call init_get_bale_4
		call set_able_4
		ret
;------------------------------------
set_able_4:
		mov cx,6
SetAble4Loop:
		mov al,es:[bx]
		out 70H,al
		mov ax,es:[si]
		shl al,1
		shl al,1
		shl al,1
		shl al,1
		or al,ah
		out 71H,al
		inc bx
		add si,2
		loop SetAble4Loop
		ret
;输入时间 例如(160206210312)---------
get_able_4:
		mov cx,12
GetAble4Num:
		mov ah,0
		int 16H
		mov es:[si],al
		mov ds:[di],al
		inc si
		add di,2
		loop GetAble4Num
		ret
;初始化 bale_4 ----------------------
init_get_bale_4:
		mov bx,0
		mov es,bx
		mov si,OFFSET SET_TIME_STYLE - OFFSET new_init7CH + 7E00H

		mov bx,0B800H
		mov ds,bx
		mov di,160*7

		mov bx,OFFSET TIME_ADDR - OFFSET new_init7CH + 7E00H
		ret
;////////////////////////////////////////////////////////////////////////////
;--------------------------------------------------
;--------------------------------------------------
;功能 3 显示时钟-----------------------------------
able_3:
show_able_3_loop:
		call init_get_able_3
		call get_able_3

		call init_show_able_3
		call show_able_3

		jmp show_able_3_loop
		ret
;------------------------------------
init_get_able_3:
		mov bx,0
		mov es,bx
		mov di,OFFSET TIME_STYLE - OFFSET new_init7CH +7E00H
		mov si,OFFSET TIME_ADDR  - OFFSET new_init7CH +7E00H
		ret
;将时间 处理过后 放入TIME_STYLE中----
get_able_3:
		mov cx,6
get_able3:
		mov ax,0
		mov al,es:[si]
		out 70H,al
		in al,71H
		mov ah,al
		and al,00001111B
		shr ah,1
		shr ah,1
		shr ah,1
		shr ah,1
		add al,30H
		add ah,30H
		mov es:[di],ah
		mov es:[di+1],al
		add si,2
		add di,3
		loop get_able3
		ret
;------------------------------------
init_show_able_3:
		mov bx,0B800H
		mov es,bx
		mov di,160*20

		mov bx,0
		mov ds,bx
		mov si,OFFSET TIME_STYLE - OFFSET new_init7CH +7E00H
		ret
;------------------------------------
show_able_3:
		mov dl,ds:[si]
		cmp dl,0
		je ShowAble3Ret
		mov es:[di],dl
		inc si
		add di,2
		jmp show_able_3
ShowAble3Ret:
		ret
;--------------------------------------------------
;--------------------------------------------------
;--------------------------------------------------
;////////////////////////////////////////////////////////////////////////////
;------------------------------------------------------------------
;显示菜单功能------------------------------------------------------
;初始化菜单--------------------------------------------------------
init_show_menue_reg:
		mov bx,0B800H
		mov es,bx
		mov si,160*10 + 20*2

		mov bx,0
		mov ds,bx
		mov di,OFFSET MENUE - OFFSET new_init7CH + 7E00H
		ret
;将菜单显示在屏幕上的指定位置--------
show_show_menue:
		mov cx,4
		mov ax,0
		mov bx,ds:[di]
ShowShowMenue:
		mov dl,ds:[bx]
		cmp dl,0
		je ShowNextShowMenue
		mov es:[si],dl
		inc bx
		add si,2
		add ax,2
		jmp ShowShowMenue
ShowNextShowMenue:
		add di,2
		sub si,ax
		add si,160
		mov bx,ds:[di]
		mov ax,0
		loop ShowShowMenue
		ret
;////////////////////////////////////////////////////////////////////////////
;------------------------------------------------------------------
;清屏--------------------------------------------------------------
clean_screen:
		call init_clean_screen_reg
		call show_clean_screen
		ret
;------------------------------------
show_clean_screen:

ShowCleanScreen:
		mov es:[di],dx
		add di,2
		loop ShowCleanScreen

		ret
;------------------------------------
init_clean_screen_reg:
		mov bx,0B800H
		mov es,bx
		mov di,0
		mov cx,2000
		mov dx,0720H
		ret
;////////////////////////////////////////////////////////////////////////////
new_init7CH_end:
		nop
;////////////////////////////////////////////////////////////////////////////
;将 int 7CH中断中的内容复制到 0:7E00中---------------------------------------
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
cpy_new_init7CH:
		mov bx,cs
		mov ds,bx
		mov si,OFFSET new_init7CH

		mov bx,0
		mov es,bx
		mov di,7E00H

		mov cx,OFFSET new_init7CH_end - OFFSET new_init7CH
		cld
		rep movsb
		ret
;////////////////////////////////////////////////////////////////////////////
;设置 int 7CH 中断向量表-----------------------------------------------------
set_new_init7CH:
		mov bx,0
		mov es,bx

		cli
		mov word ptr es:[7CH*4],7E00H
		mov word ptr es:[7CH*4+2],0
		sti
		ret
;----------------------------------------------------------------------------
code ends

end start
;===========================================================================================


