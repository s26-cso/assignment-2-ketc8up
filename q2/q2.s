.section .rodata
fmt_first:
    .asciz "%d"
fmt_rest:
    .asciz " %d"

.text
.globl main

main:
    addi sp, sp, -64
    sd ra, 56(sp)
    sd s0, 48(sp)
    sd s1, 40(sp)
    sd s2, 32(sp)
    sd s3, 24(sp)
    sd s4, 16(sp)
    sd s5, 8(sp)
    sd s6, 0(sp)

    #s0=argv, s1=number of input elements
    mv s0, a1
    addi s1, a0, -1

    #keeping these as NULL in the beginning so free(NULL) is safe
    li s2, 0      # values
    li s3, 0      # result
    li s4, 0      # stack of indices

    #if there are no numbers, just print a newline
    blt zero, s1, .Lalloc_arrays
    li a0, 10
    call putchar
    li a0, 0
    j .Lcleanup

.Lalloc_arrays:
    #allocate values[n]
    slli a0, s1, 2
    call malloc
    mv s2, a0
    beqz s2, .Lalloc_fail

    #allocate result[n]
    slli a0, s1, 2
    call malloc
    mv s3, a0
    beqz s3, .Lalloc_fail

    #allocate stack[n], this stack stores indices
    slli a0, s1, 2
    call malloc
    mv s4, a0
    beqz s4, .Lalloc_fail

    #convert argv into integers and store them in values[]
    li s5, 0
.Lparse_loop:
    bge s5, s1, .Lcompute
    slli t0, s5, 3
    add t0, s0, t0
    ld a0, 8(t0)
    call atoi
    slli t1, s5, 2
    add t1, s2, t1
    sw a0, 0(t1)
    addi s5, s5, 1
    j .Lparse_loop

.Lcompute:
    #top=-1, and i starts from n-1
    li t0, -1
    addi t1, s1, -1

.Louter:
    blt t1, zero, .Lprint_first

    #current value is values[i]
    slli t2, t1, 2
    add t3, s2, t2
    lw t4, 0(t3)

    #pop till the top of stack points to something strictly greater
.Lpop_loop:
    blt t0, zero, .Lno_greater
    slli t5, t0, 2
    add t5, s4, t5
    lw t6, 0(t5)
    slli a2, t6, 2
    add a2, s2, a2
    lw a3, 0(a2)
    bge t4, a3, .Lpop_one
    j .Lhave_greater

.Lpop_one:
    addi t0, t0, -1
    j .Lpop_loop

.Lno_greater:
    li a2, -1
    add t2, s3, t2
    sw a2, 0(t2)
    j .Lpush_index

.Lhave_greater:
    add t2, s3, t2
    sw t6, 0(t2)

.Lpush_index:
    addi t0, t0, 1
    slli t5, t0, 2
    add t5, s4, t5
    sw t1, 0(t5)
    addi t1, t1, -1
    j .Louter

.Lprint_first:
    lw a1, 0(s3)
    la a0, fmt_first
    call printf

    li s5, 1
.Lprint_rest:
    bge s5, s1, .Lprint_newline
    slli t0, s5, 2
    add t0, s3, t0
    lw a1, 0(t0)
    la a0, fmt_rest
    call printf
    addi s5, s5, 1
    j .Lprint_rest

.Lprint_newline:
    li a0, 10
    call putchar

    #free the arrays before returning
    mv a0, s2
    call free
    mv a0, s3
    call free
    mv a0, s4
    call free

    li a0, 0
    j .Lcleanup

.Lalloc_fail:
    mv a0, s2
    call free
    mv a0, s3
    call free
    mv a0, s4
    call free
    li a0, 1

.Lcleanup:
    ld ra, 56(sp)
    ld s0, 48(sp)
    ld s1, 40(sp)
    ld s2, 32(sp)
    ld s3, 24(sp)
    ld s4, 16(sp)
    ld s5, 8(sp)
    ld s6, 0(sp)
    addi sp, sp, 64
    ret
