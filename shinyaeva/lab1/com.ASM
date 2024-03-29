TESTPC SEGMENT
   ASSUME CS:TESTPC, DS:TESTPC, ES:NOTHING, SS:NOTHING    
   ORG 100H    ;⠪ ��� ������ ��稭����� � ᬥ饭��� 100 � .com
START: JMP BEGIN      ;�窠 �室� (��⪠)

; �����
T_PC db  'Type: PC',0DH,0AH,'$'
T_PC_XT db 'Type: PC/XT',0DH,0AH,'$'
T_AT db  'Type: AT',0DH,0AH,'$'
T_PS2_M30 db 'Type: PS2 ������ 30',0DH,0AH,'$'
T_PS2_M50_60 db 'Type: PS2 ������ 50 ��� 60',0DH,0AH,'$'
T_PS2_M80 db 'Type: PS2 ������ 80',0DH,0AH,'$'
T_P�_JR db 'Type: P�jr',0DH,0AH,'$'
T_PC_C db 'Type: PC Convertible',0DH,0AH,'$'

VERSION db 'Version:  .  ',0DH,0AH,'$'
OEM db  'OEM:  ',0DH,0AH,'$'
USER db  'User:        $'

; ��楤���
;-----------------------------------------------------
TETR_TO_HEX PROC near
   and AL,0Fh
   cmp AL,09
   jbe next
   add AL,07
next:
   add AL,30h
   ret
TETR_TO_HEX ENDP
;-------------------------------
BYTE_TO_HEX PROC near
;���� � AL ��ॢ������ � ��� ᨬ���� ���. �᫠ � AX
    push CX
    mov AH,AL
    call TETR_TO_HEX
    xchg AL,AH
    mov CL,4
    shr AL,CL
    call TETR_TO_HEX ;� AL ����� ���
    pop CX ;� AH ������
    ret
BYTE_TO_HEX ENDP
;-------------------------------
WRD_TO_HEX PROC near
;��ॢ�� � 16 �/� 16-� ࠧ�來��� �᫠
; � AX - �᫮, DI - ���� ��᫥����� ᨬ����
    push BX
    mov BH,AH
    call BYTE_TO_HEX
    mov [DI],AH
    dec DI
    mov [DI],AL
    dec DI
    mov AL,BH
    call BYTE_TO_HEX
    mov [DI],AH
    dec DI
    mov [DI],AL
    pop BX
    ret
WRD_TO_HEX ENDP
;--------------------------------------------------
BYTE_TO_DEC PROC near
; ��ॢ�� � 10�/�, SI - ���� ���� ����襩 ����
    push CX
    push DX
    xor AH,AH
    xor DX,DX
    mov CX,10
loop_bd:
    div CX
    or DL,30h
    mov [SI],DL
    dec SI
    xor DX,DX
    cmp AX,10
    jae loop_bd
    cmp AL,00h
    je end_l
    or AL,30h
    mov [SI],AL
end_l:
    pop DX
    pop CX
    ret
BYTE_TO_DEC ENDP
;-------------------------------
PC_TYPE PROC near
    mov ax, 0f000h       ;����砥� ����� ������ 
    mov es, ax
    mov al, es:[0fffeh]  ;ᬥ饭��

    cmp al, 0ffh         ;�ࠢ������
    je pc
    cmp al, 0feh
    je pc_xt
    cmp al, 0fbh
    je pc_xt
    cmp al, 0fch
    je pc_at
    cmp al, 0fah
    je pc_ps2_m30
    cmp al, 0f8h
    je pc_ps2_m80
    cmp al, 0fdh
    je pc_jr 
    cmp al, 0f9h
    je pc_conv
pc:
    mov dx, offset T_PC
    jmp write
pc_xt:
    mov dx, offset T_PC_XT
    jmp write
pc_at:
    mov dx, offset T_AT
    jmp write
pc_ps2_m30:
    mov dx, offset T_PS2_M30
    jmp write
pc_ps2_m50_60:
    mov dx, offset T_PS2_M50_60
    jmp write
pc_ps2_m80:
    mov dx, offset T_PS2_M80
    jmp write
pc_jr:
    mov dx, offset T_P�_JR
    jmp write
pc_conv:
    mov dx, offset T_PC_C
    jmp write
write:
    mov AH,09h
    int 21h
    ret
PC_TYPE ENDP

OS PROC near
    ;�����
    mov ah, 30h
    int 21h
    push ax
    mov si, offset VERSION
    add si, 9       ;ᬥ饭��
    call BYTE_TO_DEC
    pop ax
    mov al, ah
    add si, 3       ;ᬥ饭��
    call BYTE_TO_DEC
    mov dx, offset VERSION
    mov AH,09h      ;�뢮�
    int 21h
	
    ;�਩�� ����� OEM
    mov si, offset OEM
    add si, 5      ;ᬥ饭�� 
    mov al, bh
    call BYTE_TO_DEC
    mov dx, offset OEM
    mov AH,09h     ;�뢮�
    int 21h
	
    ;�਩�� ����� ���짮��⥫�
    mov di, offset USER
    add di, 11     ;ᬥ饭��
    mov ax, cx
    call WRD_TO_HEX
    mov al, bl
    call BYTE_TO_HEX
    sub di, 2
    mov [di], ax
    mov dx, offset USER
    mov AH,09h     ;�뢮�
    int 21h
    ret

OS ENDP

; ���
BEGIN:
   call PC_TYPE
   call OS

   xor AL,AL
   mov AH,4Ch
   int 21H
TESTPC ENDS
END START; ����� �����, START - �窠 ��室�