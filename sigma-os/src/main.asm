org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

start:
    jmp main

;
; Prints string to screen
;

puts:
    push si
    push ax

.loop:
    lodsb
    or al, al
    jz .done

    mov ah, 0x0e
    mov bh, 0
    int 0x10

    jmp .loop

.done:
    pop ax
    pop si
    ret

main: 
    ; setup data segments
    mov ax, 0   ; can't write to ds/es directly
    mov ds, ax
    mov es, ax

    ; setup stack
    mov ss, ax
    mov sp, 0x7C00   ; stack grows downwards from loading memory

    ; Print the hello world message once before starting the loop
    mov si, start_msg
    call puts

.input_loop:
    ; Read keypress
    mov ah, 0x00    ; BIOS keystroke function
    int 0x16        ; Blocks until keypress. Character is stored in AL

    cmp al, 0x0D ; check if enter is pressed
    je .handle_enter

    cmp al, 0x08
    je .handle_backspace

    ; If regular key
    ; Echo key back to screen
    mov ah, 0x0e    ; BIOS teletype function
    mov bh, 0       ; Page number
    int 0x10        ; Print character in AL

    jmp .input_loop ; Repeat forever

.handle_enter:
    mov ah, 0x0e
    mov al, 0x0D    ; Carriage Return
    int 0x10
    mov al, 0x0A    ; Line Feed
    int 0x10
    jmp .input_loop

.handle_backspace:
    mov ah, 0x0e
    mov al, 0x08    ; Move cursor back
    int 0x10
    mov al, ' '     ; Print a blank space to erase the character
    int 0x10
    mov al, 0x08    ; Move cursor back again
    int 0x10
    jmp .input_loop

.halt:
    jmp .halt

start_msg: db 'welcome to sigmaOS', ENDL, 0

times 510-($-$$) db 0
dw 0AA55h