.text

.globl make_node
.globl insert
.globl get
.globl getAtMost

#the node layout:
#0(node) -> int val
#8(node) -> struct Node *left
#16(node) -> struct Node *right

make_node:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd s0, 0(sp)

    #save the val
    mv s0, a0

    #allocate for one node
    li a0, 24
    call malloc

    #if malloc returns NULL
    beqz a0, .Lmake_done

    #here we add the node values
    sw s0, 0(a0)
    sd zero, 8(a0)
    sd zero, 16(a0)

.Lmake_done:
    ld ra, 8(sp)
    ld s0, 0(sp)
    addi sp, sp, 16
    ret

insert:
    addi sp, sp, -32
    sd ra, 24(sp)
    sd s0, 16(sp)
    sd s1, 8(sp)
    sd s2, 0(sp)

    #s0=original root, s1=value to insert, s2=current node.
    mv s0, a0
    mv s1, a1

    #creating the root node
    bnez s0, .Linsert_start
    mv a0, s1
    call make_node
    j .Linsert_done

.Linsert_start:
    mv s2, s0

.Linsert_loop:
    lw t0, 0(s2)

    #here we compare val with the current val
    blt s1, t0, .Linsert_left
    blt t0, s1, .Linsert_right

    #we will do nothing if we come across a duplicate value
    mv a0, s0
    j .Linsert_done

.Linsert_left:
    ld t1, 8(s2)
    bnez t1, .Ladvance_left

    #after we find the insertion spot to be on the left
    mv a0, s1
    call make_node
    sd a0, 8(s2)
    mv a0, s0
    j .Linsert_done

.Ladvance_left:
    mv s2, t1
    j .Linsert_loop

.Linsert_right:
    ld t1, 16(s2)
    bnez t1, .Ladvance_right

    #in case its on the right
    mv a0, s1
    call make_node
    sd a0, 16(s2)
    mv a0, s0
    j .Linsert_done

.Ladvance_right:
    mv s2, t1
    j .Linsert_loop

.Linsert_done:
    ld ra, 24(sp)
    ld s0, 16(sp)
    ld s1, 8(sp)
    ld s2, 0(sp)
    addi sp, sp, 32
    ret

get:
    #traversing the bst until we find val
.Lget_loop:
    beqz a0, .Lget_not_found

    lw t0, 0(a0)
    beq a1, t0, .Lget_found
    blt a1, t0, .Lget_go_left

    ld a0, 16(a0)
    j .Lget_loop

.Lget_go_left:
    ld a0, 8(a0)
    j .Lget_loop

.Lget_found:
    ret

.Lget_not_found:
    li a0, 0
    ret

getAtMost:
    #we are taking default value as -1, will return this if there is no valid value
    li t0, -1

.Latmost_loop:
    beqz a1, .Latmost_done

    lw t1, 0(a1)

    #here we compare the val with the current value
    beq a0, t1, .Latmost_exact
    blt a0, t1, .Latmost_left

    #if current->val<val, then this might be probable, we update the value stored
    mv t0, t1
    ld a1, 16(a1)
    j .Latmost_loop

.Latmost_left:
    ld a1, 8(a1)
    j .Latmost_loop

.Latmost_exact:
    mv t0, t1

.Latmost_done:
    mv a0, t0
    ret
