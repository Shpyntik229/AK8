TITLE STRMENU (EXE)
	.MODEL SMALL
	.STACK 64
	.DATA
;-------------------------------------------------------------------------
TOPROW EQU 08 ;Верхній рядок меню
BOTROW EQU 12 ;Нижній рядок меню
LEFCOL EQU 26 ;Лівий стовпчик меню
ATTRIB DB ? ; Атрибути екрану
ROW DB 00 ;Рядок екрану 
SHADOW DB 19 DUP(0DBH);
MENU DB 0C9H, 17 DUP(0CDH), 0BBH
	DB 0BAH, ' Print group     ',0BAH
	DB 0BAH, ' Calculate       ',0BAH
	DB 0BAH, ' Make beep       ',0BAH
	DB 0C8H, 17 DUP(0CDH), 0BCH
PROMPT DB 'To select an item, use <Up/Down Arrow>'
	DB ' and press <Enter>.'
	DB 13, 10, 'Press <Esc> to exit.'
	
group_data db "Group 3: Sachko, Sachko, Horduz", '$'
text_clear db 60 DUP(' '), '$'
text_beep db "Beeeeep!", '$'

a1 DB -7
a2 DB 3
a3 DB 2
a4 DB 4
a5 DB 3
time EQU 130
divider EQU 2705   ; 1190000 МГц / 440 Гц = 2705 
.386 ;-------------------------------------------------------------------
	.CODE
A10MAIN PROC FAR
	MOV AX,@data
	MOV DS,AX
	MOV ES,AX
	CALL Q10CLEAR ; Очистка екрану
	MOV ROW,BOTROW+4
A20:
	CALL B10MENU ;Вивід меню
	MOV ROW,TOPROW+1 ;Вибір верхнього пункту меню
	; у якості початкового значення
	MOV ATTRIB,16H ;Переключення зображення в інв..
	CALL D10DISPLY ;Відображення
	CALL C10INPUT ;Вибір з меню
	JMP A20 ;
A10MAIN ENDP
;-------------------------------------------------------------------------
; Вивід рамки, меню і запрошення…
;-------------------------------------------------------------------------
B10MENU PROC NEAR
	PUSHA ;
	MOV AX,1301H ;
	MOV BX,0060H ;
	LEA BP,SHADOW ;
	MOV CX,19 ;
	MOV DH,TOPROW+1 ;
	MOV DL,LEFCOL+1 ;
B20: INT 10H
 ;;;;;
	INC DH ;Наступний рядок
	CMP DH,BOTROW+2 ;
	JNE B20 ;
	MOV ATTRIB,71H ;
	MOV AX,1300H ;
	MOVZX BX,ATTRIB ;
	LEA BP,MENU ;
	MOV CX,19
	MOV DH,TOPROW ;Рядок
	MOV DL,LEFCOL ;Стовпчик
B30:
	INT 10H
	ADD BP,19 ;
	INC DH ;
	CMP DH,BOTROW+1 ;
	JNE B30 ;
	MOV AX,1301H ;
	MOVZX BX,ATTRIB ;
	LEA BP,PROMPT ;
	MOV CX,79 ;
	MOV DH,BOTROW+4 ;
	MOV DL,00 ;
	INT 10H
	POPA ;‚
	RET
B10MENU ENDP
;-------------------------------------------------------------------------
; Натискування клавиш, управління через клавиші і ENTER
; для вибору пункту меню і клавіші ESC для виходу
;-------------------------------------------------------------------------
C10INPUT PROC NEAR
	PUSHA ;
C20: MOV AH,10H ;Запитати один символ з кл.
	INT 16H ;
	CMP AH,50H ;Стрілка до низу
	JE C30
	CMP AH,48H ;Стрілка до гори ?
	JE C40
	CMP AL,0DH ;Натистнено ENTER?
	JE C90
	CMP AL,1BH ;Натиснено ESCAPE?
	JE C80 ; Вихід
	JMP C20 ;Жодна не натиснена, повторення
C30:
	MOV ATTRIB,71H ;Кольор символів
	CALL D10DISPLY ;
	INC ROW ;
	CMP ROW,BOTROW-1 ;
	JBE C50 ;
	MOV ROW,TOPROW+1 ;
	JMP C50
C40:
	MOV ATTRIB,71H ;Кольор символів і екрану
	CALL D10DISPLY ;
	;
	DEC ROW
	CMP ROW,TOPROW+1 ;
	JAE C50 ;
	MOV ROW,BOTROW-1 ;
C50:
	MOV ATTRIB,17H ;Кольор символів
	CALL D10DISPLY ;
	JMP C20
C80:
	MOV AX,4C00H
	INT 21H
C90:
	CMP ROW, 9
	JE B1
	CMP ROW, 10
	JE B2
	CMP ROW, 11
	JE B3
B1:
	CALL CLEARLINE
	CALL PRINTGROUP
	JMP BE
B2:
	CALL CLEARLINE
	CALL CALCULATE
	JMP BE
B3:
	CALL CLEARLINE
	CALL BEEP
BE:
	POPA
	RET
C10INPUT ENDP
;-------------------------------------------------------------------------
; Забарвлення виділеного рядка
;-------------------------------------------------------------------------
D10DISPLY PROC NEAR
	PUSHA
	MOVZX AX,ROW
	SUB AX,TOPROW
	IMUL AX,19
	LEA SI,MENU+1
	ADD SI,AX
	MOV AX,1300H
	MOVZX BX,ATTRIB
	MOV BP,SI
	MOV CX,17
	MOV DH,ROW
	MOV DL,LEFCOL+1
	INT 10H
	POPA
	RET
D10DISPLY ENDP
;------------------------------------------------------------------------
; Очищення екрану
;------------------------------------------------------------------------
Q10CLEAR PROC NEAR
	PUSHA
	MOV AX,0600H
	MOV BH,61H
	MOV CX,00
	MOV DX,184FH
	INT 10H
	POPA
	RET
Q10CLEAR ENDP

PRINTGROUP PROC
	PUSHA
	MOV AH, 09H
	MOV DX, OFFSET group_data
	INT 21H
	POPA
	RET
PRINTGROUP ENDP

CLEARLINE PROC
	PUSHA
	MOV AH, 03H ;Визначення положення курсору
	MOV BH, 0
	INT 10H 
	
	MOV AX, 1300H ;Заповнення рядка пробілами
	MOV CX, 60
	MOV BX, 60H
	LEA BP, text_clear
	INT 10H 
	POPA
	RET
CLEARLINE ENDP

CALCULATE PROC
	PUSHA
	mov ah, [a1]
	mov al, [a2]
	add al, ah      ;al = al + ah
	
	mov ah, [a3]	
	imul ah         ;ax = al * ah

	mov bl, [a4]
	idiv bl         ;al = ax / bl
		
	mov ah, [a5]
	add al, ah      ;al = al + ah
	
	mov ah, 02h     ;команда виводу символу
	mov dl, al		
	add dl, 30h		;dl + 48 = ASCII-код 
	int 21h
	POPA
	RET
CALCULATE ENDP

BEEP PROC
	PUSHA
	MOV AH, 09H
	MOV DX, OFFSET text_beep
	INT 21H
	;---Задання дільника частоти системного таймеру-------------------
	mov ax, divider
	out 42h, al
	mov al, ah
	out 42h, al
	
	;---Перевід динаміку у ввімкнений стан----------------------------
	in al, 61h
	or al, 3
	out 61h, al
	
	push cx
	mov cx, time
outer:
	push cx
	mov cx, 0FFFFh
	loop $
	pop cx
	loop outer
	pop cx
	
	;---Перевід динаміка у вимкнений стан-----------------------------
	and al, 11111100b
	out 61h, al
	POPA
	RET
BEEP ENDP

END A10MAIN
