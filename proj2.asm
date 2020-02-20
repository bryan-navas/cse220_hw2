# CSE 220 Programming Project #2
# Bryan Navas
# bnavas
# 112244631

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text
strlen:
    #$a0 now holds the ADDRESS of the string we want to count
    li $t0, 0   #counter to keeps track of how many chars are in the loop
    li $t1, 0   #holds the CURRENT character we are working with
    strlen_loop:
    	lbu $t1, 0($a0)		   #loads in the char so we can check if it's the null terminator 
    	beqz $t1, strlen_loop.end  #if we find the null character we jump to the end of the loop
    	
    	addi $t0, $t0, 1  #adds 1 to the counter of how many chars in this string
    	addi $a0, $a0, 1  #adds 1 to the base addr of the string to iterate to next char
    	j strlen_loop
    strlen_loop.end: 
    
    move $v0, $t0   #we set the return value to the counter that held how many chars were in the string
    jr $ra  	    #jump back to the caller


index_of:
    #$a0 holds the address of the string
    #$a1 holds the char we want to find the index of
    
    li $t0, 0    #holds the current char we are working with
    li $t1, 0    #holds the current index   
    indexOf_loop: 
    	lbu $t0, 0($a0)    	        #grabs a character
    	beq $t0, $a1, indexOf_loop.end  #checks if it's the character we want
    	beqz $t0, return_neg1  	        #if we get all the way up to the null terminator we can assume it's not there 
    
    	addi $a0, $a0, 1    #iterates to the next character
    	addi $t1, $t1, 1    #adds 1 to the current index
    	j indexOf_loop
    indexOf_loop.end:
    move $v0, $t1
    jr $ra
    
    return_neg1: 
    #this portion only runs if we reach the end of the string without findind the specified char
    li $v0, -1
    jr $ra


bytecopy:
    #$a0 holds the source array
    #$a1 holds the source_pos
    #$a2 holds the destination array
    #$a3 hold the dest_pos
    #$t0 will hold the length
    lb $t0, 0($sp)  #loading in parameter from stack   
    blt $t0, $0, invalidInput   #if length is less than ZERO it returns -1 
    beq $t0, $0, invalidInput   #if length is equal ZERO it returns -1 
    blt $a1, $0, invalidInput   #if source_pos is less than ZERO it returns -1
    blt $a3, $0, invalidInput   #if dest_pos is less than ZERO it returns -1
    
    add $a0, $a0, $a1  #src = src + src_pos. We jump to where we want to start copying
    add $a2, $a2, $a3  #dest = dest + dest_pos. We just to where we want to start copying
    
    #$t0 will essentially be the number of times it will run (length parameter)
    li $t2, 0  #loop counter
    bytecopy_loop:
	beq $t2, $t0, bytecopy_loop.end  #once the loop has run the max # of times, it will end  
    	lbu $t1, 0($a0)   #loads in a byte from scr_pos in scr array
    	sb $t1, 0($a2)    #stores the byte in dest_pos IN dest array
    	
    	addi $t2, $t2, 1  #adds 1 to the counter of the loop
    	addi $a0, $a0, 1  #adds 1 to iterate to next letter in scr
    	addi $a2, $a2, 1  #adds 1 to iterate to next letter in dest
    
    	j bytecopy_loop
    bytecopy_loop.end:
    
    move $v0, $t0
    jr $ra
    
    #will only run if there is an invalid input	
    invalidInput:
    li $v0, -1
    jr $ra

scramble_encrypt:
    #$a0 will contain cyphertext 
    #$a1 will contain plaintext (NT)
    #$a2 will contain the alphabet (will always be 52 chars, NT)
    
    li $t0, 0  #keeps track of how many letters were encrypted
    scram_encryptLoop:
    	lbu $t1, 0($a1)   #load a character from plaintext
    	beqz $t1, scram_encryptLoop.end
    	li $t2, 65	#temp to hold value of ASCII 65 'A'
    	blt $t1, $t2, nonAlph
    	li $t2, 122     #temp to hold value of ASCII 122 'z'
    	bge $t1, $t2, nonAlph
    	
    	#if we get to this point it's between 65 and 122 inclusive
    	li $t2, 90      #temp to hold value of ASCII 90 'Z'
    	ble $t1, $t2, isUpper   #branches if it's a char btwn A-Z
    	#at this point it's btwn 91-122 
    	li $t2, 96
    	ble $t1, $t2, nonAlph   #if it's btwn 91 and 96 it's non alph
    	j isLower   #if it's neither of those cases above, it must be lowercase
    	
    	isUpper:
    	addi $t1, $t1, -65      #we subtract 65 to make it correspond to alphabet.
    				#EXAMPLE: 'D' is ASCII 68 and we want to make it 3. ABCDE.... D is the 3 index (0 based)
        add $a2, $a2, $t1	#this adds the letter to the alphabet address so we get the nth one   
        lbu $t3, 0($a2)		#loads the byte in the nth element so we can set it in cyphertext
        sb $t3, 0($a0)
        sub $a2, $a2, $t1       #puts the address back where it started
        
        addi $a1, $a1, 1    #iterates to next character in plaintxt
        addi $t0, $t0, 1    #adds 1 to how many chars we've changed
        addi $a0, $a0, 1    #adds 1 to cyphertxt so next time a char is replaced it will do the next one        
        j scram_encryptLoop
    	
    	isLower:
    	addi $t1, $t1, -71      #same logic as uppercase
    	add $a2, $a2, $t1	#this adds the letter to the alphabet address so we get the nth one   
        lbu $t3, 0($a2)		#loads the byte in the nth element so we can set it in cyphertext
        sb $t3, 0($a0)
        sub $a2, $a2, $t1       #puts the address back where it started
        
        addi $a1, $a1, 1    #iterates to next character in plaintxt
        addi $t0, $t0, 1    #adds 1 to how many chars we've changed
        addi $a0, $a0, 1    #adds 1 to cyphertxt so next time a char is replaced it will do the next one	
    	
    	j scram_encryptLoop
    	nonAlph:
    	#branches here if  it's not A-Z nor a-z
    	sb $t1, 0($a0)   #stores the unchanged character in cyphertxt
    	addi $a1, $a1, 1    #iterates to next character in plaintxt
        addi $a0, $a0, 1    #adds 1 to cyphertxt so next time a char is replaced it will do the next one
 
    	j scram_encryptLoop
    scram_encryptLoop.end:
    lbu $t4, 0($a1)  #this null terminates the string
    sb $t4, 0($a0)
    
    move $v0, $t0
    jr $ra


scramble_decrypt:
    #$a0 will contain plaintxt (NT) 
    #$a1 will contain cyphertext
    #$a2 will contain the alphabet (will always be 52 chars, NT)
    addi $sp, $sp, -24   #save registers
    sw $s0, 0($sp)
    sw $ra, 4($sp)
    sw $s1, 8($sp)   #will hold "current_char"
    sw $s2, 12($sp)  #holds $a0 so it isnt lost
    sw $s3, 16($sp)  #holds $a1
    sw $s4, 20($sp)  #holds $a2
  
    li $s0, 0  #keeps track of how many letters were decrypted
    move $s2, $a0  #this will now hold 'plaintext' parameter
    move $s3, $a1  #this will now hold 'ciphertext' parameter
    move $s4, $a2  #this will now hold 'alphabet' parameter
    scram_decryptLoop:
    	lbu $s1, 0($s3)  #this loads in a char from ciphertext	
    	beqz $s1, scram_decryptLoop.end  #ends the loop once we reach null termination
    	move $a0, $s4   #sets the parameter for index_of
    	move $a1, $s1    #sets the other parameter, the char we want to find    	
    	jal index_of	
    	move $t0, $v0   #puts the return of index_of into $t1
    	
    	li $t1, -1
    	beq $t0, $t1, d.nonAlph  #IF index is -1 it's non alph bc it wast found
    	li $t1, 25
    	ble $t0, $t1, d.isUpper  #IF index is 0-25 it's uppercase
    	li $t1, 26
    	bge $t0, $t1, d.isLower  #IF index is greater or equal to 26, it's LC
    	d.isUpper:
    		addi $t0, $t0, 65 #similar logic to encrypt
    		sb $t0, 0($s2)    #we put the unencrypter letter in plaintxt
    		
    		addi $s2, $s2, 1  #iterates to next letter in plaintxt
    		addi $s3, $s3, 1  #iterates to next letter in cipher
    		addi $s0, $s0, 1  #adds 1 to how many letters decrypted
		j scram_decryptLoop 	
    	d.isLower:
    		addi $t0, $t0, 71 #similar logic to encrypt
    		sb $t0, 0($s2)    #we put the unencrypter letter in plaintxt
    		
    		addi $s2, $s2, 1  #iterates to next letter in plaintxt
    		addi $s3, $s3, 1  #iterates to next letter in cipher
    		addi $s0, $s0, 1  #adds 1 to how many letters decrypted
		j scram_decryptLoop
    	d.nonAlph:
    		sb $s1, 0($s2)    #we put the unchanged letter in plaintxt 		
    		addi $s2, $s2, 1  #iterates to next letter in plaintxt
    		addi $s3, $s3, 1  #iterates to next letter in cipher
		j scram_decryptLoop	
    scram_decryptLoop.end:
    lbu $t0, 0($s3)  #this null terminates the string
    sb $t0, 0($s2)
    
    move $v0, $s0 
    
    lw $s0, 0($sp)
    lw $ra, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)  #holds $a0 so it isnt lost
    lw $s3, 16($sp)  #holds $a1
    lw $s4, 20($sp)  #holds $a2
    addi $sp, $sp, 24   #put back registers
      
    jr $ra
    
base64_encode:
    #$a0 will have encoded str
    #$a1 will have str
    #$a2 will have table
    addi $sp, $sp, -8	# save registers on stack
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    
    li $s0, 0  #loop counter
    li $s1, 0  #current 24bit string
    e.base64Loop:
    	lbu $t1, 0($a1)  #gets the first letter from str
    	beqz $t1, e.base64Loop.end
	lbu $t2, 1($a1)  #gets the second letter from str
	beqz $t2, secondEmpty
	lbu $t3, 2($a1)  #gets the third letter from str
	beqz $t3, thirdEmpty
	
	noEmpty: #this means of the 3 letters, none are the null terminator
	#none of the 3 letters has a null terminator
	sll $s1, $t1, 24  #this puts 24 0's on left 
	
	sll $t4, $t2, 24  #shifts left then right for second char 
	srl $t4, $t4, 8   #we now have 8 zeros in front
	add $s1, $s1, $t4 #we add it to our current collection of 24 bits
	
	sll $t4, $t3, 24  #shifts left then right for third char 
	srl $t4, $t4, 16   #we now have 8 zeros in front
	add $s1, $s1, $t4 #we add it to our current collection of 24 bits
	
	#at this point, the first 3 letters are stored in $s1 side by side
	andi $t1, $s1, 0xFC000000   #$t1 now has the first 6bits of $s1
	srl $t1, $t1, 26  #26 zeros in front of $t1, it holds an actual number
	andi $t2, $s1, 0x3F00000   #$t2 now has the next 6 bits of $s1
	srl $t2, $t2, 20  #makes this an actual number
	andi $t3, $s1, 0xFC000     #$t3 has the next 6 bits
	srl $t3, $t3, 14  #makes this an actual number
	andi $t4, $s1, 0x3F00      #$t4 has the last 6bits
	srl $t4, $t4, 8  #makes this an actual number
	
	add $a2, $a2, $t1     #this adds an offset to base table to get char
	lbu $t0, 0($a2)	      #now $t0 has proper char from base_table
	sub $a2, $a2, $t1     #put back the pointer to table
	sb $t0, 0($a0)        #places char from table into encoded_str
	
	add $a2, $a2, $t2     #this adds an offset to base table to get char
	lbu $t0, 0($a2)	      #now $t0 has proper char from base_table
	sub $a2, $a2, $t2    #put back the pointer to table
	sb $t0, 1($a0)        #places char from table into encoded_str
	
	add $a2, $a2, $t3     #this adds an offset to base table to get char
	lbu $t0, 0($a2)	      #now $t0 has proper char from base_table
	sub $a2, $a2, $t3    #put back the pointer to table
	sb $t0, 2($a0)        #places char from table into encoded_str
	
	add $a2, $a2, $t4     #this adds an offset to base table to get char
	lbu $t0, 0($a2)	      #now $t0 has proper char from base_table
	sub $a2, $a2, $t4    #put back the pointer to table
	sb $t0, 3($a0)        #places char from table into encoded_str
	
	addi $a1, $a1, 3   #adds 3 to str so we can grab the next 3 chars
	addi $a0, $a0, 4   #adds 4 to encoded_str for next iteration
	addi $s0, $s0, 4   #adds 4 to the loop counter bc it added 4 chars
	j e.base64Loop
	
	secondEmpty: #the second of the 3 letters has a null terminator
	#this means it will need 2 equal signs
	sll $s1, $t1, 24  #puts 24 0's on the left
	andi $t1, $s1, 0xFC000000   #$t1 now has the first 6bits of $s1
	srl $t1, $t1, 26  #26 zeros in front of $t1, it holds an actual number
	andi $t2, $s1, 0x3F00000   #$t2 now has the next 6 bits of $s1
	srl $t2, $t2, 20  #makes this an actual number
	
	add $a2, $a2, $t1     #this adds an offset to base table to get char
	lbu $t0, 0($a2)	      #now $t0 has proper char from base_table
	sub $a2, $a2, $t1     #put back the pointer to table
	sb $t0, 0($a0)        #places char from table into encoded_str
	
	add $a2, $a2, $t2     #this adds an offset to base table to get char
	lbu $t0, 0($a2)	      #now $t0 has proper char from base_table
	sub $a2, $a2, $t2    #put back the pointer to table
	sb $t0, 1($a0)        #places char from table into encoded_str
	
	li $t0, '='	#adds 2 paddings at end
	sb $t0, 2($a0)
	sb $t0, 3($a0)
	addi $a0, $a0, 4
	addi $s0, $s0, 4   #adds 2 chars and 2 '=' signs	
	
	j e.base64Loop.end						
	thirdEmpty: #the third letter of the 3 has a null terminator
	#first 2 chars have a letter
	#$t1 has first char	
	#$t2 has second char
	sll $s1, $t1, 24  #this puts 24 0's on left 
	sll $t4, $t2, 24  #shifts left then right for second char 
	srl $t4, $t4, 8   #we now have 8 zeros in front
	add $s1, $s1, $t4 #we add it to our current collection of 24 bits
	
	andi $t1, $s1, 0xFC000000   #$t1 now has the first 6bits of $s1
	srl $t1, $t1, 26  #26 zeros in front of $t1, it holds an actual number
	andi $t2, $s1, 0x3F00000   #$t2 now has the next 6 bits of $s1
	srl $t2, $t2, 20  #makes this an actual number
	andi $t3, $s1, 0xFC000     #$t3 has the next 6 bits
	srl $t3, $t3, 14  #makes this an actual number		
	add $a2, $a2, $t1     #this adds an offset to base table to get char
	lbu $t0, 0($a2)	      #now $t0 has proper char from base_table
	sub $a2, $a2, $t1     #put back the pointer to table
	sb $t0, 0($a0)        #places char from table into encoded_str
	add $a2, $a2, $t2     #this adds an offset to base table to get char
	lbu $t0, 0($a2)	      #now $t0 has proper char from base_table
	sub $a2, $a2, $t2    #put back the pointer to table
	sb $t0, 1($a0)        #places char from table into encoded_str

	add $a2, $a2, $t3     #this adds an offset to base table to get char
	lbu $t0, 0($a2)	      #now $t0 has proper char from base_table
	sub $a2, $a2, $t3    #put back the pointer to table
	sb $t0, 2($a0)        #places char from table into encoded_str
	li $t0, '='
	sb $t0, 3($a0)
	addi $a0, $a0, 4		
	addi $s0, $s0, 4   #adds 2 chars and 2 '=' signs
    e.base64Loop.end:
    li $t0, '\0'
    sb $t0, 0($a0)
    move $v0, $s0
    
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    addi $sp, $sp, 8	#put registers back 
    jr $ra


base64_decode:
    #$a0 holds decoded_str
    #$a1 holds encoded_str
    #$a2 holds base_64
    addi $sp, $sp, 24
    sw $ra, 0($sp)
    sw $s0, 4($sp)  #this will hold "current_str"
    sw $s1, 8($sp)  #this will hold $a0 "decoded_str"
    sw $s2, 12($sp) #this will hold $a1 "encoded_str"
    sw $s3, 16($sp) #this will hold $a2 "base64_table"
    sw $s4, 20($sp) #this will hold "loop counter"
      
    move $s1, $a0   #decoded_str
    move $s2, $a1   #encoded_str
    move $s3, $a2   #base64_table
    
    li $s0, 0  #sets current_str initially to 0
    li $s4, 0  #setting loop counter to 0
    d.base64Loop:
        lbu $t0, 0($s2)  #load the first char from encoded_str
        beqz $t0, d.base64Loop.end  #multiples of 4 so we can be assured NT will be the first one in 4 char sequence
    	lbu $t1, 1($s2) #load in second char
    	lbu $t2, 2($s2) #load in third char
    	li $t5, 61      #61 is the ascii char for '='
    	beq $t2, $t5, EQ.3.4  #if the third char is an '=' branch here
    	
    	lbu $t3, 3($s2) #load in the fourth character   
    	beq $t3, $t5, EQ.4   #if the fourth string is an '=' branch here	
    	
    	noEQ:    #no equals sign in any of the 4 chars
    		move $a0, $s3  #sets the first parameter to index_of to b64_table
    		move $a1, $t0  #sets the second parameter to first char in 4 char sequence
    		jal index_of
    		#$v0 now contains index of first char in table
    		sll $s0, $v0, 26  #adds 26 ZEROs on the left side "XXXXXX000...000"
    		
    		lbu $t0, 1($s2) #assume all $t registers are trashed and load in second char again
    		move $a0, $s3   #assume first parameter is also trashed so load it in again
    		move $a1, $t0   #load in second parameter
    		jal index_of
    		#$v0 now contains index of second char in table
    		sll $t0, $v0, 26  #adds 26 ZEROs on the left side "XXXXXX000...000"
    		srl $t0, $t0, 6   #add 6 ZEROs on the right side
    		add $s0, $s0, $t0 #adds in the proper place to current_char
    		
    		lbu $t0, 2($s2) #assume all $t registers are trashed and load in third char again
    		move $a0, $s3   #assume first parameter is also trashed so load it in again
    		move $a1, $t0   #load in second parameter
    		jal index_of
    		#$v0 now contains index of third char in table
    		sll $t0, $v0, 26  #adds 26 ZEROs on the left side "XXXXXX000...000"
    		srl $t0, $t0, 12   #add 12 ZEROs on the right side
    		add $s0, $s0, $t0 #adds in the proper place to current_char
    		
    		lbu $t0, 3($s2) #assume all $t registers are trashed and load in fourth char again
    		move $a0, $s3   #assume first parameter is also trashed so load it in again
    		move $a1, $t0   #load in second parameter
    		jal index_of
    		#$v0 now contains index of third char in table
    		sll $t0, $v0, 26  #adds 26 ZEROs on the left side "XXXXXX000...000"
    		srl $t0, $t0, 18   #add 12 ZEROs on the right side
    		add $s0, $s0, $t0 #adds in the proper place to current_char
    		
    		#$s0 now has 4 6bit binary nums in a row and we want to turn that into 3 segments of 8bit
    		andi $t0, $s0, 0xFF000000 #this grabs the first 8 bits
    		srl $t0, $t0, 24
    		sb $t0, 0($s1) #stores it in decoded_str
    		andi $t0, $s0, 0xFF0000 #grabs the next 8bits after that
    		srl $t0, $t0, 16
    		sb $t0, 1($s1) #stores it in decoded_str
    		andi $t0, $s0, 0xFF00 #grabs the next 8bits after that
    		srl $t0, $t0, 8
    		sb $t0, 2($s1) #stores it in decoded_str
    		
    		addi $s1, $s1, 3  #adds 3 to decoded_str addr  
    		addi $s4, $s4, 3  #adds 3 to the counter
    		addi $s2, $s2, 4  #adds 4 to encoded_str  
    		j d.base64Loop
    	EQ.4:    #there is an equal sign on the 4th character
    		move $a0, $s3  #sets the first parameter to index_of to b64_table
    		move $a1, $t0  #sets the second parameter to first char in 4 char sequence
    		jal index_of
    		#$v0 now contains index of first char in table
    		sll $s0, $v0, 26  #adds 26 ZEROs on the left side "XXXXXX000...000"
    		
    		lbu $t0, 1($s2) #assume all $t registers are trashed and load in second char again
    		move $a0, $s3   #assume first parameter is also trashed so load it in again
    		move $a1, $t0   #load in second parameter
    		jal index_of
    		#$v0 now contains index of second char in table
    		sll $t0, $v0, 26  #adds 26 ZEROs on the left side "XXXXXX000...000"
    		srl $t0, $t0, 6   #add 6 ZEROs on the right side
    		add $s0, $s0, $t0 #adds in the proper place to current_char
    		
    		lbu $t0, 2($s2) #assume all $t registers are trashed and load in third char again
    		move $a0, $s3   #assume first parameter is also trashed so load it in again
    		move $a1, $t0   #load in second parameter
    		jal index_of
    		#$v0 now contains index of third char in table
    		sll $t0, $v0, 26  #adds 26 ZEROs on the left side "XXXXXX000...000"
    		srl $t0, $t0, 12   #add 12 ZEROs on the right side
    		add $s0, $s0, $t0 #adds in the proper place to current_char
    		
    		#the next char is an equal signs so we can ignore it
    		andi $t0, $s0, 0xFF000000 #this grabs the first 8 bits
    		srl $t0, $t0, 24
    		sb $t0, 0($s1) #stores it in decoded_str
    		andi $t0, $s0, 0xFF0000 #grabs the next 8bits after that
    		srl $t0, $t0, 16
    		sb $t0, 1($s1) #stores it in decoded_str
    		
    		
    		
    		addi $s4, $s4, 2  #adds 2 to the counter
    		addi $s1, $s1, 2  
    		j d.base64Loop.end
    	EQ.3.4:  #there is an equal sign in the third and fourth char
    		move $a0, $s3  #sets the first parameter to index_of to b64_table
    		move $a1, $t0  #sets the second parameter to first char in 4 char sequence
    		jal index_of
    		#$v0 now contains index of first char in table
    		sll $s0, $v0, 26  #adds 26 ZEROs on the left side "XXXXXX000...000"
    		
    		lbu $t0, 1($s2) #assume all $t registers are trashed and load in second char again
    		move $a0, $s3   #assume first parameter is also trashed so load it in again
    		move $a1, $t0   #load in second parameter
    		jal index_of
    		#$v0 now contains index of second char in table
    		sll $t0, $v0, 26  #adds 26 ZEROs on the left side "XXXXXX000...000"
    		srl $t0, $t0, 6   #add 6 ZEROs on the right side
    		add $s0, $s0, $t0 #adds in the proper place to current_char
    		
    		andi $t0, $s0, 0xFF000000 #this grabs the first 8 bits
    		srl $t0, $t0, 24
    		sb $t0, 0($s1) #stores it in decoded_str
    		
    		addi $s4, $s4, 1
    		addi $s1, $s1, 1
    d.base64Loop.end:
    move $v0, $s4 
    li $t0, '\0'
    sb $t0, 0($s1)
    
    #puts everything back from stack
    lw $ra, 0($sp)
    lw $s0, 4($sp) 
    lw $s1, 8($sp)  
    lw $s2, 12($sp) 
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    addi $sp, $sp, -24
    
    jr $ra

bifid_encrypt:
    lw $t0, 0($sp)  #grabs index_buffer
    lw $t1, 4($sp)  #grabs block_buffer

    addi $sp, $sp, -48
    sw $ra, 0($sp)   #saves $ra 
    sw $s0, 4($sp)  #this will keep $a0
    sw $s1, 8($sp)  #this will keep $a1
    sw $s2, 16($sp)  #this will keep $a2
    sw $s3, 20($sp)  #this will keep $a3
    sw $s4, 24($sp)
    sw $s5, 28($sp)  
    sw $s6, 32($sp)  #keep row pointer
    sw $s7, 36($sp)  #keep col pointer
    #40($sp) holds the length of plaintext
    #44($sp) will hold return val
    move $s0, $a0   #keeps ciphertext
    move $s1, $a1   #keeps plaintext
    move $s2, $a2   #keeps key_square
    move $s3, $a3   #keeps period
    move $s4, $t0   #keeps index_buffer
    move $s5, $t1   #keeps block_buffer
    
    #$s6 ->pointer to first half of index_buffer   ROW
    #$s7 ->pointer to second half of index_buffer  COLUMNS
    move $s6, $s4            #$s6 = index_buffer
    
    move $a0, $s1
    jal strlen
    add $s7, $s4, $v0          #$s7 = index_buffer + (length of plaintext)
    sw $v0, 40($sp)   #length of plaintext will now be stored here
    
    step1Loop:
    	move $a0, $s2
	lbu $a1, 0($s1)  #load character from plain_text to put into index_of
	beqz $a1, step1Loop.end  #end condition for loop
	jal index_of
	li, $t0, 9
	div $v0, $t0   #now 'hi' register has column and 'lo' has the row
	
	mflo, $t0
	sb $t0, 0($s6)   #first half of buffer, holds all the rows
	mfhi, $t0
	sb $t0, 0($s7)   #second half of buffer, holds all the columns
	
	addi $s6, $s6, 1  #adds 1 to iterate
	addi $s7, $s7, 1 
	addi $s1, $s1, 1  #gets the next character from plain_text
		
	j step1Loop
    step1Loop.end:         
                
    #at this point all the indexes are in index_buffer
    lw $t0, 40($sp)  #loads in the length of plaintext
    div $t0, $s3   #divides plaintext.length by period
    #lo - the quotient
    #hi - the remainder  
    sub $s6, $s6, $t0   #subtract the length of plaintext to put back pointer after part 1 loop
    sub $s7, $s7, $t0   #same as above ^
    
    mflo $t0     #get quotient
    mfhi $t1     #gets remainder
    sw $t0, 44($sp)
    beqz $t1, skipAdd  #this means there is no remainder and no partial blocks
    addi $t0, $t0, 1 
    sw $t0, 44($sp)     #if there is a remainder we add 1 to quotient 
    
    skipAdd:
    
    addi $sp, $sp, -16   #frees up places to store variables
    mflo $t0
    sw $t0, 0($sp)
    li $t1, 0
    sw $t1, 4($sp)  
    li $t0, 0
    sw $t0, 8($sp) 
    mfhi $t0
    sw $t0, 12($sp)
    
    
    #0($sp) will hold 'lo' or max times loop will run
    #4(#sp) will hold loop counter  
    #8($sp) will hold src_pos
    #12($sp) will hold 'hi' or remainder
    step2Loop:
    lw $t0, 0($sp)   #loads the max from the stack
    lw $t1, 4($sp)   #loads counter from the stack
    beq $t0, $t1, step2Loop.end #when the loop runs the max # of times it will end
    
    	move $a0, $s6    #sets src to $s6: beginning of index buffer (ROW)
    	lw $a1, 8($sp)   #loads in src_pos
    	move $a2, $s5    #sets dest to block buffer
    	li $a3, 0        #sets dest_pos to 0
    	move $t0, $s3    #sets length to period
    	addi $sp, $sp, -4
    	sw $t0, 0($sp)
    	jal bytecopy
    	addi $sp, $sp, 4
    	#^^this section of code copies the first 'period' number of indexes to block buffer
    	
    	move $a0, $s7    #sets src to $s7: beginning of index buffer (COL)
    	lw $a1, 8($sp)   #loads in src_pos
    	move $a2, $s5    #sets dest to block buffer
    	move $a3, $s3        #sets dest_pos to 7
    	move $t0, $s3    #sets length to period
    	addi $sp, $sp, -4
    	sw $t0, 0($sp)
    	jal bytecopy
    	addi $sp, $sp, 4
  					
    li $t0, 0 #loop counter
    move $t1, $s5  #puts block_buffer in $t1 so we dont change addr
    move $t7, $s0  #puts ciphertext in $t7 so we dont change addr
    #$s3 is max times loop will run (period)							
    e.encodingLoop:
    beq $t0, $s3, e.encodingLoop.end
    lbu $t2, 0($t1)  #loads in first number from block_buffer (ROW) = *i*
    lbu $t3, 1($t1)  #loads in second char from block_buffer (COL) = *j*

    
    
    #addr = base_addr + (i*9 + j)
    li $t4, 9   #number of columns
    mul $t5, $t2, $t4 #i * num_columns
    add $t5, $t5, $t3 #i * num_columns + j
    add $t5, $t5, $s2 #base_addr + (i*9 + j)
    lbu $t6, 0($t5) #load from addr we just calculated
    sb $t6, 0($t7) #store it in ciphertext
    
    addi $t1, $t1, 2  #adds 2 to our copy of block_buffer base addr
    addi $t0, $t0, 1  #adds 1 to our counter
    addi $t7, $t7, 1  #add 1 to the copy of ciphertext addr
    j e.encodingLoop
    e.encodingLoop.end:
    
    add $s0, $s0, $s3  #adds period to ciphertext so it will encode next 7 
    
    lw $t0, 4($sp)    #loads counter from stack
    addi $t0, $t0, 1  #adds 1 to the counter
    sw $t0, 4($sp)    #puts it back into the stack
    
    lw $t0, 8($sp)     #loads in src_pos from stack
    add $t0, $t0, $s3  #adds period
    sw $t0, 8($sp)     #puts it back into the stack
    j step2Loop
    step2Loop.end:
      
    #$s6 and $s7 are still pointing to the beginning of index_buffer
    #we want to add (PERIOD * QUOTIENT) to those to get last partial block
    lw $t0, 0($sp) #gets 'lo' or quotient
    mul $t0, $t0, $s3   #$t0 = quotient TIMES period
    add $s6, $s6, $t0
    add $s7, $s7, $t0
    
    lw $t0, 12($sp)  #load the remainder into $t1
    beqz $t0, skipREM #if remainder is equal to 0, skip the next loop
    	
    	
    	#sets up block_buffer for partial block
    	#-----------
    	
    	move $a0, $s6    #sets src to $s6: partial of index_buffer (ROW)
    	li $a1, 0        #loads in src_pos
    	move $a2, $s5    #sets dest to block buffer
    	li $a3, 0        #sets dest_pos to 0
    	lw $t0, 12($sp)  #sets length to remainder
    	addi $sp, $sp, -4
    	sw $t0, 0($sp)
    	jal bytecopy
    	addi $sp, $sp, 4
    	
    	move $a0, $s7    #sets src to $s6: partial of index_buffer (ROW)
    	li $a1, 0
    	move $a2, $s5    #sets dest to block buffer
    	li $a3, 0
    	add $a3, $a3, $t0     #adds remainder
    	lw $t0, 12($sp)  #sets length to remainder
    	addi $sp, $sp, -4
    	sw $t0, 0($sp)
    	jal bytecopy
    	addi $sp, $sp, 4
    
    	#-------------
    	
    	
    	
    	#$t0 will be max times loop runs
    	lw $t0, 12($sp)  #load the remainder into $t1
    	li $t1, 0  #counter
    	REMLoop:
    	beq $t1, $t0, REMLoop.end
    	
    	lbu $t2, 0($s5)  #loads in from partial row block (ROW) = *i*
    	lbu $t3, 1($s5)  #loads in from partial col block (COL) = *j*
    
    	
   	#addr = base_addr + (i*9 + j)
    	li $t4, 9   #number of columns
	mul $t5, $t2, $t4 #i * num_columns
	add $t5, $t5, $t3 #i * num_columns + j
	add $t5, $t5, $s2 #base_addr + (i*9 + j)
	lbu $t6, 0($t5) #load from addr we just calculated
	sb $t6, 0($s0) #store it in ciphertext
	
	addi $t1, $t1, 1  #adds 1 to counter
	addi $s5, $s5, 2
	addi $s0, $s0, 1 
    	j REMLoop
    	REMLoop.end:  
    skipREM:
    addi $sp, $sp, 16  #places stack back after step 2
    
    lw $t0, 44($sp)
    move $v0, $t0
    
    li $t0, '\0'
    sb $t0, 0($s0) #slaps on a null terminator at the end
    
    lw $ra, 0($sp)   
    lw $s0, 4($sp)  
    lw $s1, 8($sp)  
    lw $s2, 16($sp)  
    lw $s3, 20($sp)  
    lw $s4, 24($sp)
    lw $s5, 28($sp)  
    lw $s6, 32($sp)  
    lw $s7, 36($sp)    
    addi $sp, $sp, 48  #puts things back at the stack from the beginning  
    jr $ra
bifid_decrypt:
	jr $ra


#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
