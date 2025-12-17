section .data
    align 16
    perm_table:
        db 151,160,137,91,90,15,131,13,201,95,96,53,194,233,7,225
        db 140,36,103,30,69,142,8,99,37,240,21,10,23,190,6,148
        db 247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32
        db 57,177,33,88,237,149,56,87,174,20,125,136,171,168,68,175
        db 74,165,71,134,139,48,27,166,77,146,158,231,83,111,229,122
        db 60,211,133,230,220,105,92,41,55,46,245,40,244,102,143,54
        db 65,25,63,161,1,216,80,73,209,76,132,187,208,89,18,169
        db 200,196,135,130,116,188,159,86,164,100,109,198,173,186,3,64
        db 52,217,226,250,124,123,5,202,38,147,118,126,255,82,85,212
        db 207,206,59,227,47,16,58,17,182,189,28,42,223,183,170,213
        db 119,248,152,2,44,154,163,70,221,153,101,155,167,43,172,9
        db 129,22,39,253,19,98,108,110,79,113,224,232,178,185,112,104
        db 218,246,97,228,251,34,242,193,238,210,144,12,191,179,162,241
        db 81,51,145,235,249,14,239,107,49,192,214,31,181,199,106,157
        db 184,84,204,176,115,121,50,45,127,4,150,254,138,236,205,93
        db 222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180

section .bss
    perm: resb 512
    current_seed: resq 1

section .text
    global perlin_init
    global perlin_get
    global perlin_fractal

; init c/ seed=0
perlin_init:
    push rdi
    xor rdi, rdi
    call perlin_init_seed
    pop rdi
    ret

; init c/ seed customizada | RDI=seed
    global perlin_init_seed
perlin_init_seed:
    push rsi
    push rdi
    push rcx
    push rax
    push rbx

    lea rax, [rel current_seed]
    mov [rax], rdi
    mov rbx, rdi

    mov rcx, 256
    lea rsi, [rel perm_table]
    lea rdi, [rel perm]
.copy_loop:
    lodsb
    xor al, bl
    rol rbx, 8
    stosb
    loop .copy_loop

    mov rcx, 256
    lea rsi, [rel perm]
    lea rdi, [rel perm + 256]
    rep movsb

    pop rbx
    pop rax
    pop rcx
    pop rdi
    pop rsi
    ret

; white noise | RAX=[0-255]
perlin_get:
    push rbx
    push r12

    mov rax, rdi
    and rax, 0xFF
    mov r12, rax

    mov rbx, rsi
    and rbx, 0xFF

    lea rcx, [rel perm]

    ; hash1
    movzx rax, byte [rcx + r12]
    xor rax, rbx
    and rax, 0xFF
    movzx rax, byte [rcx + rax]

    ; hash2
    add r12, 37
    and r12, 0xFF
    xor rbx, 73
    and rbx, 0xFF

    movzx rdx, byte [rcx + r12]
    xor rdx, rbx
    and rdx, 0xFF
    movzx rdx, byte [rcx + rdx]

    xor rax, rdx
    add rax, rdx
    shr rax, 1

    pop r12
    pop rbx
    ret

; multi-octave | max 4 octaves p/ 16x16
perlin_fractal:
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 16

    mov r12, rdi
    mov r13, rsi
    mov r14, rdx

    cmp r14, 1
    jge .octaves_ok
    mov r14, 1
.octaves_ok:
    cmp r14, 4
    jle .octaves_max_ok
    mov r14, 4
.octaves_max_ok:

    xor r15, r15
    xor rbx, rbx

    mov r8, 3
    mov r9, 256

    xor r10, r10

.loop:
    cmp r10, r14
    jge .normalize

    mov rax, r12
    shr rax, 1
    imul rax, r8
    mov rdi, rax

    mov rax, r13
    shr rax, 1
    imul rax, r8
    mov rsi, rax

    mov [rsp], r8
    mov [rsp+8], r9

    call perlin_get

    mov r8, [rsp]
    mov r9, [rsp+8]

    imul rax, r9
    shr rax, 8
    add r15, rax

    add rbx, r9

    shr r9, 1

    mov rax, r8
    imul rax, 3
    mov r8, rax

    inc r10
    jmp .loop

.normalize:
    mov rax, r15
    imul rax, 255

    test rbx, rbx
    jz .return_zero

    xor rdx, rdx
    div rbx

    and rax, 0xE0

    cmp rax, 255
    jle .in_range
    mov rax, 255
    jmp .in_range

.return_zero:
    xor rax, rax

.in_range:
    add rsp, 16
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

; contraste c/ bias | RDI=val RSI=min RDX=max
    global perlin_contrast
perlin_contrast:
    push rbx
    push rcx
    push r12

    mov r12, rdi

    ; bias: val^1.5 aprox
    mov rax, rdi
    imul rax, rdi
    shr rax, 8

    mov rbx, rax
    shr rbx, 1
    add rbx, 1

    mov rax, rax
    xor rdx, rdx
    div rbx
    add rax, rbx
    shr rax, 1

    imul rax, r12
    shr rax, 4

    cmp rax, 255
    jle .bias_ok
    mov rax, 255
.bias_ok:

    mov rdi, rax

    mov rax, rdx
    sub rax, rsi
    mov rbx, rax

    mov rax, rdi
    imul rax, rbx
    mov rcx, 255
    xor rdx, rdx
    div rcx

    add rax, rsi

    pop r12
    pop rcx
    pop rbx
    ret

; posterize | RDI=val RSI=levels
    global perlin_posterize
perlin_posterize:
    push rbx
    push rdx

    mov rax, 256
    xor rdx, rdx
    div rsi
    mov rbx, rax

    mov rax, rdi
    xor rdx, rdx
    div rbx

    imul rax, rbx

    cmp rax, 255
    jle .ok
    mov rax, 255
.ok:

    pop rdx
    pop rbx
    ret
