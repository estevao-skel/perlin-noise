section .data
    msg_gen: db "gen: ", 0
    msg_ok:  db " ok", 10, 0

    file_grass: db "grass.ppm", 0
    file_dirt:  db "dirt.ppm", 0
    file_stone: db "stone.ppm", 0
    file_water: db "water.ppm", 0
    file_lava:  db "lava.ppm", 0

    ppm_hdr: db "P6", 10, "256 256", 10, "255", 10

    SIZE equ 256
    BUFSIZE equ SIZE * SIZE * 3

section .bss
    buf: resb BUFSIZE

section .text
    global _start
    extern perlin_init
    extern perlin_fractal

print:
    push rax
    push rdi
    push rdx
    push rcx
    mov rdi, rsi
    xor rcx, rcx
.l: cmp byte [rdi+rcx], 0
    je .w
    inc rcx
    jmp .l
.w: mov rax, 1
    mov rdi, 1
    mov rdx, rcx
    syscall
    pop rcx
    pop rdx
    pop rdi
    pop rax
    ret

save_ppm:
    push rbx
    push r12
    mov rbx, rdi
    mov rax, 2
    mov rdi, rbx
    mov rsi, 577
    mov rdx, 0644o
    syscall
    mov r12, rax
    mov rax, 1
    mov rdi, r12
    lea rsi, [rel ppm_hdr]
    mov rdx, 15
    syscall
    mov rax, 1
    mov rdi, r12
    lea rsi, [rel buf]
    mov rdx, BUFSIZE
    syscall
    mov rax, 3
    mov rdi, r12
    syscall
    pop r12
    pop rbx
    ret

gen_grass:
    push r12
    push r13
    xor r12, r12
.y:
    cmp r12, SIZE
    jge .done
    xor r13, r13
.x:
    cmp r13, SIZE
    jge .ny

    mov rdi, r13
    shr rdi, 3
    mov rsi, r12
    shr rsi, 3
    mov rdx, 4
    push r12
    push r13
    call perlin_fractal
    pop r13
    pop r12

    mov rbx, r12
    imul rbx, SIZE
    add rbx, r13
    lea rbx, [rbx+rbx*2]
    lea rdi, [rel buf]

    mov cl, al
    shr cl, 3
    add cl, 20
    mov [rdi+rbx], cl

    mov cl, al
    shr cl, 2
    add cl, 100
    cmp cl, 255
    jle .g_ok
    mov cl, 255
.g_ok:
    mov [rdi+rbx+1], cl

    mov cl, al
    shr cl, 3
    add cl, 20
    mov [rdi+rbx+2], cl

    inc r13
    jmp .x
.ny:
    inc r12
    jmp .y
.done:
    pop r13
    pop r12
    ret

gen_dirt:
    push r12
    push r13
    xor r12, r12
.y:
    cmp r12, SIZE
    jge .done
    xor r13, r13
.x:
    cmp r13, SIZE
    jge .ny

    mov rdi, r13
    shr rdi, 3
    mov rsi, r12
    shr rsi, 3
    mov rdx, 4
    push r12
    push r13
    call perlin_fractal
    pop r13
    pop r12

    mov rbx, r12
    imul rbx, SIZE
    add rbx, r13
    lea rbx, [rbx+rbx*2]
    lea rdi, [rel buf]

    mov cl, al
    shr cl, 2
    add cl, 100
    mov [rdi+rbx], cl

    mov cl, al
    shr cl, 3
    add cl, 60
    mov [rdi+rbx+1], cl

    mov cl, al
    shr cl, 4
    add cl, 30
    mov [rdi+rbx+2], cl

    inc r13
    jmp .x
.ny:
    inc r12
    jmp .y
.done:
    pop r13
    pop r12
    ret

gen_stone:
    push r12
    push r13
    xor r12, r12
.y:
    cmp r12, SIZE
    jge .done
    xor r13, r13
.x:
    cmp r13, SIZE
    jge .ny

    mov rdi, r13
    shr rdi, 3
    mov rsi, r12
    shr rsi, 3
    mov rdx, 5
    push r12
    push r13
    call perlin_fractal
    pop r13
    pop r12

    mov rbx, r12
    imul rbx, SIZE
    add rbx, r13
    lea rbx, [rbx+rbx*2]
    lea rdi, [rel buf]

    mov cl, al
    shr cl, 1
    add cl, 100
    mov [rdi+rbx], cl
    mov [rdi+rbx+1], cl
    mov [rdi+rbx+2], cl

    inc r13
    jmp .x
.ny:
    inc r12
    jmp .y
.done:
    pop r13
    pop r12
    ret

gen_water:
    push r12
    push r13
    xor r12, r12
.y:
    cmp r12, SIZE
    jge .done
    xor r13, r13
.x:
    cmp r13, SIZE
    jge .ny

    mov rdi, r13
    shr rdi, 3
    mov rsi, r12
    shr rsi, 3
    mov rdx, 3
    push r12
    push r13
    call perlin_fractal
    pop r13
    pop r12

    mov rbx, r12
    imul rbx, SIZE
    add rbx, r13
    lea rbx, [rbx+rbx*2]
    lea rdi, [rel buf]

    mov cl, al
    shr cl, 3
    add cl, 25
    mov [rdi+rbx], cl

    mov cl, al
    shr cl, 3
    add cl, 80
    mov [rdi+rbx+1], cl

    mov cl, al
    shr cl, 2
    add cl, 180
    mov [rdi+rbx+2], cl

    inc r13
    jmp .x
.ny:
    inc r12
    jmp .y
.done:
    pop r13
    pop r12
    ret

gen_lava:
    push r12
    push r13
    xor r12, r12
.y:
    cmp r12, SIZE
    jge .done
    xor r13, r13
.x:
    cmp r13, SIZE
    jge .ny

    mov rdi, r13
    shr rdi, 3
    mov rsi, r12
    shr rsi, 3
    mov rdx, 3
    push r12
    push r13
    call perlin_fractal
    pop r13
    pop r12

    mov rbx, r12
    imul rbx, SIZE
    add rbx, r13
    lea rbx, [rbx+rbx*2]
    lea rdi, [rel buf]

    mov cl, al
    shr cl, 1
    add cl, 200
    cmp cl, 255
    jle .r_ok
    mov cl, 255
.r_ok:
    mov [rdi+rbx], cl

    mov cl, al
    shr cl, 2
    add cl, 80
    mov [rdi+rbx+1], cl

    mov cl, al
    shr cl, 4
    mov [rdi+rbx+2], cl

    inc r13
    jmp .x
.ny:
    inc r12
    jmp .y
.done:
    pop r13
    pop r12
    ret

_start:
    call perlin_init

    lea rsi, [rel msg_gen]
    call print
    lea rsi, [rel file_grass]
    call print
    call gen_grass
    lea rdi, [rel file_grass]
    call save_ppm
    lea rsi, [rel msg_ok]
    call print

    lea rsi, [rel msg_gen]
    call print
    lea rsi, [rel file_dirt]
    call print
    call gen_dirt
    lea rdi, [rel file_dirt]
    call save_ppm
    lea rsi, [rel msg_ok]
    call print

    lea rsi, [rel msg_gen]
    call print
    lea rsi, [rel file_stone]
    call print
    call gen_stone
    lea rdi, [rel file_stone]
    call save_ppm
    lea rsi, [rel msg_ok]
    call print

    lea rsi, [rel msg_gen]
    call print
    lea rsi, [rel file_water]
    call print
    call gen_water
    lea rdi, [rel file_water]
    call save_ppm
    lea rsi, [rel msg_ok]
    call print

    lea rsi, [rel msg_gen]
    call print
    lea rsi, [rel file_lava]
    call print
    call gen_lava
    lea rdi, [rel file_lava]
    call save_ppm
    lea rsi, [rel msg_ok]
    call print

    mov rax, 60
    xor rdi, rdi
    syscall
