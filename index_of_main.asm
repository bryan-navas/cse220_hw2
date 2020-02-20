.data
str: .asciiz "g.WDO?s1Htj2X#ydhP$!o6M- Zplz'a;nVTv3Qek7SBIJ=8C,cu@9/Ym4Fxb5AKf(*RU\"rq)%wEN:0LiG"
char: .byte 'a'

.text
.globl main
main:
la $a0, str
lbu $a1, char
jal index_of

move $a0, $v0
li $v0, 1
syscall

li $t0, 9
div $a0, $t0
 

li $a0, '\n'
li $v0, 11
syscall

li $v0, 10
syscall

.include "proj2.asm"
