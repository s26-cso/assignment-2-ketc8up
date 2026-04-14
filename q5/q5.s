.section .rodata
filename:
    .asciz "input.txt"
mode:
    .asciz "r"
yes_msg:
    .asciz "Yes"
no_msg:
    .asciz "No"

.text
.globl main

main:
    addi sp, sp, -48
    sd ra, 40(sp)
    sd s0, 32(sp)
    sd s1, 24(sp)
    sd s2, 16(sp)
    sd s3, 8(sp)
    sd s4, 0(sp)

    #opening input.txt in read mode
    la a0, filename
    la a1, mode
    call fopen
    mv s0, a0                  # s0 = FILE *
    beqz s0, .Lprint_no

    #going to the end to get the length of the file
    mv a0, s0
    li a1, 0
    li a2, 2                   #SEEK_END
    call fseek
    bnez a0, .Lclose_no

    mv a0, s0
    call ftell
    mv s1, a0                  #s1=length

    li s2, 0                   # s2 = left index
    addi s3, s1, -1              # s3 = right index

    #empty file is also a palindrome
    blt s3, zero, .Lclose_yes

.Lloop:
    #stop when both pointers meet or cross
    bge s2, s3, .Lclose_yes

    #read the left character
    mv a0, s0
    mv a1, s2
    li a2, 0                   #SEEK_SET
    call fseek
    bnez a0, .Lclose_no

    mv a0, s0
    call fgetc
    mv s4, a0

    #read the right character
    mv a0, s0
    mv a1, s3
    li a2, 0                   #SEEK_SET
    call fseek
    bnez a0, .Lclose_no

    mv a0, s0
    call fgetc

    #if they are different then its not a palindrome
    bne s4, a0, .Lclose_no

    addi s2, s2, 1
    addi s3, s3, -1
    j .Lloop

.Lclose_yes:
    mv a0, s0
    call fclose
    j .Lprint_yes

.Lclose_no:
    mv a0, s0
    call fclose

.Lprint_no:
    la a0, no_msg
    call puts
    li a0, 0
    j .Ldone

.Lprint_yes:
    la a0, yes_msg
    call puts
    li a0, 0

.Ldone:
    ld ra, 40(sp)
    ld s0, 32(sp)
    ld s1, 24(sp)
    ld s2, 16(sp)
    ld s3, 8(sp)
    ld s4, 0(sp)
    addi sp, sp, 48
    ret
