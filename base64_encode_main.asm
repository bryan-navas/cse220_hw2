.data
encoded_str: .ascii "This is random garbage! Notice that it is not null-terminated! You should not be seeing this text!"
str: .asciiz "Let's hear it for MIPS! Goooooo MIPS!"
base64_table: .asciiz "HWegnLO7mM0Q6XwTplBduqSNJsZhkrf25cUoE49bAvPtz8IKDyVjiYC31/+axFRG"
trash: .ascii "random garbage"

.text
.globl main
main:
la $a0, encoded_str
la $a1, str
la $a2, base64_table
jal base64_encode

move $a0, $v0
li $v0, 1
syscall

li $a0, '\n'
li $v0, 11
syscall

la $a0, encoded_str
li $v0, 4
syscall

li $a0, '\n'
li $v0, 11
syscall

li $v0, 10
syscall

.include "proj2.asm"
