.data
theArray:
	.word 0 33 123 -66 332 -1 -223 453 9 45 -78
sp_sanity_check_prompt_1:
        .asciiz "\nSP ENTER VALUE: "
sp_sanity_check_prompt_2:
        .asciiz "\nSP EXIT VALUE: "
print_s_register_prompt:
        .asciiz "\nS REGISTERS: "
convention:
    .asciiz "\nMy Convention Check\n"
space:
        .asciiz " "
newline:
        .asciiz "\n"

.text
ConventionCheck:
        addi    $t0, $0, -1
        addi    $t1, $0, -1
        addi    $t2, $0, -1
        addi    $t3, $0, -1
        addi    $t4, $0, -1
        addi    $t5, $0, -1
        addi    $t6, $0, -1
        addi    $t7, $0, -1
        ori     $v0, $0, 4
        la      $a0, convention
        syscall
        addi $v0, $zero, -1
        addi $v1, $zero, -1
        addi $a0, $zero, -1
        addi $a1, $zero, -1
        addi $a2, $zero, -1
        addi $a3, $zero, -1
        addi $k0, $zero, -1
        addi $k1, $zero, -1
        jr      $ra

print_s_registers:
        la $a0, print_s_register_prompt
        li $v0, 4
        syscall

        # print s0, followed by a space
        move $a0, $s0
        li $v0, 1
        syscall
        la $a0, space
        li $v0, 4
        syscall
        
        # print s1, followed by a space
        move $a0, $s1
        li $v0, 1
        syscall
        la $a0, space
        li $v0, 4
        syscall

        # print s2, followed by a space
        move $a0, $s2
        li $v0, 1
        syscall
        la $a0, space
        li $v0, 4
        syscall

        # print s3, followed by a space
        move $a0, $s3
        li $v0, 1
        syscall
        la $a0, space
        li $v0, 4
        syscall

        # print s4, followed by a space
        move $a0, $s4
        li $v0, 1
        syscall
        la $a0, space
        li $v0, 4
        syscall

        # print s5, followed by a space
        move $a0, $s5
        li $v0, 1
        syscall
        la $a0, space
        li $v0, 4
        syscall

        # print s6, followed by a space
        move $a0, $s6
        li $v0, 1
        syscall
        la $a0, space
        li $v0, 4
        syscall

        # print s7, followed by a newline
        move $a0, $s7
        li $v0, 1
        syscall
        la $a0, newline
        li $v0, 4
        syscall

        jr $ra

        # Doesn't take any parameters
sp_sanity_check_1:
        la $a0, sp_sanity_check_prompt_1
        li $v0, 4
        syscall
        move $a0, $sp
        li $v0, 1
        syscall
        jr $ra
        
sp_sanity_check_2:
        la $a0, sp_sanity_check_prompt_2
        li $v0, 4
        syscall
        move $a0, $sp
        li $v0, 1
        syscall
        jr $ra

sanity_check_end:
        # save ra
        addi $sp, $sp, -4
        sw $ra, 0($sp)

        jal sp_sanity_check_2
        jal print_s_registers
        
        # restore $ra and return
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra

sanity_check_start:
        # save ra
        addi $sp, $sp, -4
        sw $ra, 0($sp)

        jal sp_sanity_check_1
        jal print_s_registers
        
        # restore $ra and return
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra

main:
        jal sanity_check_start
        la $a0, theArray
        li $a1, 11
        jal PrintReverse
        jal sanity_check_end
        li $v0, 10
        syscall
        
