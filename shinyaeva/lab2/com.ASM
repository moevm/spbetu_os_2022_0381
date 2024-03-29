TESTPC SEGMENT
   ASSUME CS:TESTPC, DS:TESTPC, ES:NOTHING, SS:NOTHING    
   ORG 100H    ;⠪ ��� ������ ��稭����� � ᬥ饭��� 100 � .com
START: JMP BEGIN      ;�窠 �室� (��⪠)

; �����
MEMORY db  'Memory segment:     ',0DH,0AH,'$'       ;ᥣ����� ���� ������㯭�� �����
MEDIA db 'Segment media address:    ',0DH,0AH,'$'   ;ᥣ����� ���� �।�
TAIL db 'Tail of command line:    ',0DH,0AH,'$'     ;墮�� ���������� ��ப�
EMPTY db 'Tail of command line: [EMPTY]',0DH,0AH,'$';���⮩ 墮��
CONTENT db 'Environment scope content:',0DH,0AH, '$'
END_STRING db 0DH,0AH, '$'
PATH db 'Path:  ',0DH,0AH, '$'

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
;-------------------------------

F1 PROC near
    mov ax, ds:[02h]     

    mov di, offset MEMORY
    add di, 19
    call WRD_TO_HEX
    mov dx, offset MEMORY
    mov AH,09h
    int 21h
    ret
F1 ENDP

F2 PROC near
    mov ax, ds:[2Ch]     

    mov di, offset MEDIA
    add di, 25
    call WRD_TO_HEX
    mov dx, offset MEDIA
    mov AH,09h
    int 21h
    ret
F2 ENDP

F3 PROC near
    mov cx, 0
    mov cl, ds:[80h]   
    mov si, offset TAIL
    add si, 22
    cmp cl, 0          ;�᫨ ����
    je empty_tail 
    mov di, 0
    mov ax, 0
read_tail: 
    mov al, ds:[81h+di]
    inc di
    mov [si], al
    inc si
    loop read_tail     ;横� ���뢠���

    mov dx, offset TAIL
    jmp write_tail
empty_tail:
    mov dx, offset EMPTY
write_tail: 
    mov AH,09h
    int 21h
    ret
F3 ENDP

F4 PROC near
    mov dx, offset CONTENT
    mov AH,09h
    int 21h
    mov di, 0
    mov ds, ds:[2Ch]
read_str:
    cmp byte ptr [di], 0
    je end_str
    mov dl, [di]
    mov ah, 02h
    int 21h
    jmp find_end
end_str:
    cmp byte ptr [di+1],00h
    je find_end
    push ds
    mov cx, cs
    mov ds, cx
    mov dx, offset END_STRING
    mov AH,09h
    int 21h
    pop ds
find_end:
    inc di
    cmp word ptr [di], 0001h
    je read_path
    jmp read_str
read_path:
    push ds
    mov ax, cs
    mov ds, ax
    mov dx, offset PATH
    mov AH,09h
    int 21h
    pop ds
    add di, 2
loop2:
    cmp byte ptr [di], 0
    je break
    mov dl, [di]
    mov ah, 02h
    int 21h
    inc di
    jmp loop2
break:
    ret
F4 ENDP

; ���
BEGIN:
    call F1    ;��।������ ���� ������㯭�� �����
    call F2    ;��।������ ᥣ���⭮�� ���� �।�
    call F3    ;��।������ 墮��
    call F4    ;����砥� ᮤ�ন��� ������ �।� � ����

    xor AL,AL
    mov AH,4Ch
    int 21H
TESTPC ENDS
END START; ����� �����, START - �窠 ��室�