#####################################################################
#
# CSCB58 Winter 2024 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Adrit Panday, 1007785719, pandayad, adrit.panday@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4
# - Unit height in pixels: 4
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
# 
# Which milestoneshave been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1 - DONE
# - Milestone 2 - DONE
# - Milestone 3 - DONE
# - Milestone 4 - DONE
#
# Which approved features have been implemented for milestone 4?
# (See the assignment handout for the list of additional features)
# 1. A
# 2. B
# 3. F
#
# Link to video demonstration for final submission:
# - https://youtu.be/6iMYa9HRafE
#
# Are you OK with us sharing the video with people outside course staff?
# NO video, but you can share my github link: 
#
# Any additional information that the TA needs to know:
# 1 - # please note that it is my design choice that i dont display any screen and game is just stopped in between
# 
# 2 - # to make game easier and logical, i will not be allowing the doodle to collide onto the spikes on purpose. 
# for example if there is a black evil doodle on your right, you can not press w to collide and decrease health
# reason for doing so is that the purpose of my game is to stick the landing! and not colliding with evil clones
# 
# 3 - # double jump only activates when doodle has taken damage atleast once
# note this deactivates once used, therefore can only be used one time only
# 
# 4 - # for milestone 1c, i have 2 different objects as one is moving(evil clone) and one is stationary(evil clone) which can count as atleast
# 2 different objects according to piazza post @203. you can also consider moving platforms as a different object :-)
# 
#####################################################################

.data
	addressDisplay:	.word	0x10008000	# Base Address for Display
	dataLocation: .word 0x10008C10, 0	# Potition, Acceleration (negative #s to 15)
	s2_global:  .word 0
	s3_global:  .word 0
	collision_count: .word 0
	double_jump: .word 0
	
.text
	# Load Constants & Data 
	lw $s0, addressDisplay
	la $s1, dataLocation
	la $s2, 0
	lw $s3, addressDisplay
	lw $s4, addressDisplay
	lw $s5, addressDisplay
	lw $s6, addressDisplay
	lw $s7, addressDisplay
	la $a0, 0

.eqv	collisions 0	
.eqv	BASE_ADDRESS 0x10008000
.eqv	purple 0x6b1cd4		# Background Color
.eqv	cyan 0xb2eebe			# Doodler Color
.eqv	pink 0xfc2899
.eqv	gold 0xf5d633
.eqv	black 0x000000
.eqv	green 0x00ff00
.eqv	white 0xffffff
	
Game:
	# Game Loop Functions
	jal Clean # Reset Display
	jal Doodle # Draw Data & Bounce Check
	jal Wall1 # Draw left wall
	jal Wall2 # Draw right wall
	jal Floor # Draw the floor of the game
	jal Platform1 # Draw platforms
	jal Platform2
	jal Platform3
	jal movePlat
	jal LastPlatform
	jal moveLast
	jal Clone1
	jal move1
	jal Clone2
	jal Clone3
	jal move3
	jal Clone4
	jal Clone5
	jal check_key_pressed
	jal Gravity
	jal Health
	jal Damage
	jal Win
	
	#syscall functions: https://courses.missouristate.edu/kenvollmar/mars/help/syscallhelp.html
	li $v0, 32 # 32 is for sleep
	li $a0, 50 # sleep for 50 ms
	syscall
	#jal GameOver
	j Game
	
Clean:
	# Load Display info
	li $t0, purple
	move $t1, $s0
	addi $t2, $s0, 16384 # End of Display (128 * 32 = 4096)
	
	cleanWhile:
		# Fill Display with Background
		sw $t0, 0($t1)
		addi $t1, $t1, 4
		bge $t1, $t2, cleanEnd
		j cleanWhile
	cleanEnd:
		jr $ra

Wall1: # 256*63 bottom left and 16382
	li $t0, pink
	move $t1, $s0
	addi $t2, $s0, 16128
	
	Wall1While:
		# Fill Display with Background
		sw $t0, 0($t1)
		addi $t1, $t1, 256
		bge $t1, $t2, Wall1End
		j Wall1While
	Wall1End:
		jr $ra
		
Wall2: # 256*63 bottom left and 16382
	li $t0, pink
	move $t1, $s0
	addi $t1, $t1, 252
	addi $t2, $s0, 16384
	
	Wall2While:
		# Fill Display with Background
		sw $t0, 0($t1)
		addi $t1, $t1, 256
		bge $t1, $t2, Wall2End
		j Wall2While
	Wall2End:
		jr $ra


Floor: # 256*63 bottom left and 16382
	li $t0, pink
	move $t1, $s0
	addi $t1, $t1, 16128
	addi $t2, $s0, 16384
	
	floorWhile:
		# Fill Display with Background
		sw $t0, 0($t1)
		addi $t1, $t1, 4
		bge $t1, $t2, floorEnd
		j floorWhile
	floorEnd:
		jr $ra

Platform1:
	move $t1, $s0
	addi $t1, $t1, 11796 # 256 * 46 + 20
	addi $t2, $s0, 11896
	
	While1:
		# Fill Display with Background
		sw $t0, 0($t1)
		addi $t1, $t1, 4
		bge $t1, $t2, End1
		j While1

	End1:
		jr $ra
		
Platform2:
	move $t1, $s0
	addi $t1, $t1, 9072 # 256 * 35 + 112
	addi $t2, $s0, 9197
	
	While2:
		# Fill Display with Background
		sw $t0, 0($t1)
		addi $t1, $t1, 4
		bge $t1, $t2, End2
		j While2
		
	End2:
		jr $ra

movePlat:
	move $t1, $s7              # $t1 = addressDisplay
  	addi $t1, $s7, 6500       # $t1 = addressDisplay + 15484 (position of doodle)

    	# Calculate the address of the pixel below the doodle
  	#addi $t1, $t1, 4         # $t1 = addressDisplay + 15484 + 256 (position of pixel below doodle)
	# Load the color value from memory location $t1 into register $t3
	lw $t3, 0($t1)
    	beq $t3, purple, rightP
    	beq $t3, white, leftP
    	
    	jr $ra
    	
	
leftP:
    	addi $s7, $s7, -48
    	jr $ra
    
rightP:
    	addi $s7, $s7, 4
    	jr $ra	
		
						
Platform3:
	move $t1, $s7#7
	li $t3, white
	
	addi $t4, $s0, 6432
	addi $t1, $t1, 6444 # 256 * 25 + 4*16
	sw $t3, 0($t4)
	addi $t4, $s0, 6540
	addi $t2, $s7, 6500
	sw $t3, 0($t4)
	
	While3:
		# Fill Display with Background
		sw $t0, 0($t1)
		addi $t1, $t1, 4
		bge $t1, $t2, End3
		j While3
		
	End3:
		jr $ra

moveLast:
	move $t1, $s6              # $t1 = addressDisplay
  	addi $t1, $s6, 3204       # $t1 = addressDisplay + 15484 (position of doodle)

    	# Calculate the address of the pixel below the doodle
  	#addi $t1, $t1, 4         # $t1 = addressDisplay + 15484 + 256 (position of pixel below doodle)
	# Load the color value from memory location $t1 into register $t3
	lw $t3, 0($t1)
    	beq $t3, purple, rightL
    	beq $t3, white, leftL
    	
    	jr $ra
    	
	
leftL:
    	addi $s6, $s6, -48
    	jr $ra
    
rightL:
    	addi $s6, $s6, 4
    	jr $ra	
				
LastPlatform: # win condition
	#addi $s4, $s4, 4 # rough work
	li $t0, gold
	li $t3, white
	move $t1, $s6
	addi $t4, $s0, 3172
	addi $t1, $t1, 3164 # 256 * 12 + 4*26
	sw $t3, 0($t4)
	addi $t2, $s6, 3204
	addi $t4, $s0, 3264
	sw $t3, 0($t4)
	
	While4:
		# Fill Display with Background
		sw $t0, 0($t1)
		addi $t1, $t1, 4
		bge $t1, $t2, End4
		j While4
		
	End4:
		jr $ra
		
Health:
    # Load the address of the global variable s2 into register $t2
    la $t2, s2_global
    la $t4, s3_global

    # Load the value of s2 into register $t3
    lw $t3, 0($t2)
    lw $t5, 0($t4)

    # Check if s2 is equal to 0
    beq $t3, $zero, stat1   # Branch if s2 equals 0
    beq $t5, $zero, stat2   # Branch if s5 equals 0

    # If s2 is not equal to 0, return without performing any actions
    jr $ra

stat1:
    # Perform actions when s2 equals 0
    # Assuming the 'green' value is defined elsewhere in the code
    li $t0, green
    move $t1, $s0
    addi $t1, $s0, 1252   # 256*4 + 4*57
    # Store the 'green' color value
    sw $t0, 0($t1)
    sw $t0, -256($t1)
    sw $t0, -512($t1)
    
    beq $t5, $zero, stat2   # Branch if s5 equals 0
    # Return
    jr $ra
    
stat2:
    # Perform actions when s2 equals 0
    # Assuming the 'green' value is defined elsewhere in the code
    li $t0, green
    move $t1, $s0
    addi $t1, $s0, 1264   # 256*4 + 4*60

    # Store the 'green' color value
    sw $t0, 0($t1)
    sw $t0, -256($t1)
    sw $t0, -512($t1)

    # Return
    jr $ra

Win:
	move $t1, $s4              # $t1 = addressDisplay
   	addi $t1, $s4, 15484       # $t1 = addressDisplay + 15484 (position of doodle)
    	lw $t2, 0($t1)             # $t2 = Color of the doodle

    	# Calculate the address of the pixel below the doodle
    	addi $t1, $t1, 256         # $t1 = addressDisplay + 15484 + 256 (position of pixel below doodle)
	lw $t3, 0($t1)
	beq $t3, gold, winner # see if pixel below is gold
	jr $ra
	winner:
		li $t0, black
		move $t1, $s0
		addi $t2, $s0, 16384 # End of Display (128 * 32 = 4096)
	
		cleanWhile2:
		# Fill Display with Background
		sw $t0, 0($t1)
		addi $t1, $t1, 4
		bge $t1, $t2, cleanEnd2
		j cleanWhile2
			cleanEnd2:
			li $t0, gold
			
			# make W
			move $t1, $s0
			addi $t1, $t1, 8984
			sw $t0, 0($t1)
			sw $t0, 4($t1)
			sw $t0, 8($t1)
			sw $t0, 12($t1)
			sw $t0, -4($t1)
			sw $t0, -8($t1)
			sw $t0, -12($t1)
			sw $t0, -256($t1)
			sw $t0, -512($t1)
			sw $t0, -768($t1)
			sw $t0, -1024($t1)
			sw $t0, -1280($t1)
			sw $t0, -240($t1)
			sw $t0, -496($t1)
			sw $t0, -752($t1)
			sw $t0, -1008($t1)
			sw $t0, -1264($t1)
			sw $t0, -1520($t1)
			sw $t0, -1776($t1)
			sw $t0, -2032($t1)
			sw $t0, -272($t1)
			sw $t0, -2064($t1)
			sw $t0, -1808($t1)
			sw $t0, -1552($t1)
			sw $t0, -1296($t1)
			sw $t0, -1040($t1)
			sw $t0, -784($t1)
			sw $t0, -528($t1)
			
			# make I
			move $t1, $s0
			addi $t1, $t1, 9020
			sw $t0, 0($t1)
			sw $t0, -256($t1)
			sw $t0, -512($t1)
			sw $t0, -768($t1)
			sw $t0, -1024($t1)
			sw $t0, -1280($t1)
			sw $t0, -1536($t1)
			sw $t0, -1792($t1)
			sw $t0, -2048($t1)
			
			#make N
			move $t1, $s0
			addi $t1, $t1, 8032
			sw $t0, 0($t1)
			sw $t0, 260($t1)
			sw $t0, 520($t1)
			sw $t0, 780($t1)
			sw $t0, 1040($t1)
			sw $t0, -260($t1)
			sw $t0, -520($t1)
			sw $t0, -780($t1)
			sw $t0, -1040($t1)
			sw $t0, -784($t1)
			sw $t0, -528($t1)
			sw $t0, -272($t1)
			sw $t0, -16($t1)
			sw $t0, 240($t1)
			sw $t0, 496($t1)
			sw $t0, 752($t1)
			sw $t0, 1008($t1)
			sw $t0, 784($t1)
			sw $t0, 528($t1)
			sw $t0, 272($t1)
			sw $t0, 16($t1)
			sw $t0, -240($t1)
			sw $t0, -496($t1)
			sw $t0, -752($t1)
			sw $t0, -1008($t1)
			
			#make N
			move $t1, $s0
			addi $t1, $t1, 8080
			sw $t0, 0($t1)
			sw $t0, 260($t1)
			sw $t0, 520($t1)
			sw $t0, 780($t1)
			sw $t0, 1040($t1)
			sw $t0, -260($t1)
			sw $t0, -520($t1)
			sw $t0, -780($t1)
			sw $t0, -1040($t1)
			sw $t0, -784($t1)
			sw $t0, -528($t1)
			sw $t0, -272($t1)
			sw $t0, -16($t1)
			sw $t0, 240($t1)
			sw $t0, 496($t1)
			sw $t0, 752($t1)
			sw $t0, 1008($t1)
			sw $t0, 784($t1)
			sw $t0, 528($t1)
			sw $t0, 272($t1)
			sw $t0, 16($t1)
			sw $t0, -240($t1)
			sw $t0, -496($t1)
			sw $t0, -752($t1)
			sw $t0, -1008($t1)
			
			# make E
			move $t1, $s0
			addi $t1, $t1, 8112
			sw $t0, 0($t1)
			sw $t0, 4($t1)
			sw $t0, 8($t1)
			sw $t0, 16($t1)
			sw $t0, 12($t1)
			sw $t0, -256($t1)
			sw $t0, -512($t1)
			sw $t0, -768($t1)
			sw $t0, -1024($t1)
			sw $t0, -1020($t1)
			sw $t0, -1016($t1)
			sw $t0, -1012($t1)
			sw $t0, -1008($t1)
			sw $t0, 256($t1)
			sw $t0, 512($t1)
			sw $t0, 768($t1)
			sw $t0, 1024($t1)
			sw $t0, 1028($t1)
			sw $t0, 1032($t1)
			sw $t0, 1036($t1)
			sw $t0, 1040($t1)
			
			# make R
			move $t1, $s0
			addi $t1, $t1, 8148
			sw $t0, 0($t1)
			sw $t0, 4($t1)
			sw $t0, 8($t1)
			sw $t0, 12($t1)
			sw $t0, -256($t1)
			sw $t0, -240($t1)
			sw $t0, -512($t1)
			sw $t0, -496($t1)
			sw $t0, -768($t1)
			sw $t0, -752($t1)
			sw $t0, -1024($t1)
			sw $t0, -1020($t1)
			sw $t0, -1016($t1)
			sw $t0, -1012($t1)
			sw $t0, 256($t1)
			sw $t0, 272($t1)
			sw $t0, 512($t1)
			sw $t0, 528($t1)
			sw $t0, 768($t1)
			sw $t0, 784($t1)
			sw $t0, 1024($t1)
			sw $t0, 1040($t1)
			
			li $v0, 10 # terminate the program gracefully
			syscall
			jr $ra

Damage:
	move $t1, $s4              # $t1 = addressDisplay
   	addi $t1, $s4, 15484       # $t1 = addressDisplay + 15484 (position of doodle)
    	lw $t2, 0($t1)             # $t2 = Color of the doodle

    	# Calculate the address of the pixel below the doodle
    	addi $t1, $t1, 256         # $t1 = addressDisplay + 15484 + 256 (position of pixel below doodle)
	# Load the color value from memory location $t1 into register $t3
	move $t7, $s2
	beq, $t7, 0, first_health
	beq, $t7, 1, second_health
	beq, $t7, 6, second_health
	lw $t3, 0($t1)
	beq $t3, black, over # see if pixel below is black
	move $t1, $s4              # $t1 = addressDisplay
   	addi $t1, $s4, 15220 # check for left side of doodle
   	lw $t3, 0($t1)
	beq $t3, black, over
	move $t1, $s4              # $t1 = addressDisplay
   	addi $t1, $s4, 15236 #check for right side of doodle
   	lw $t3, 0($t1)
	beq $t3, black, over
	jr $ra
	over: # end game screen also here
		li $t0, black
		move $t1, $s0
		addi $t2, $s0, 16384 # End of Display (128 * 32 = 4096)
	
		cleanWhile1:
		# Fill Display with Background
		sw $t0, 0($t1)
		addi $t1, $t1, 4
		bge $t1, $t2, cleanEnd1
		j cleanWhile1
			cleanEnd1:
			li $t0, pink
			
			# make B
			move $t1, $s0
			addi $t1, $t1, 8004
			sw $t0, 0($t1)
			sw $t0, 4($t1)
			sw $t0, 8($t1)
			sw $t0, 16($t1)
			sw $t0, 12($t1)
			sw $t0, -256($t1)
			sw $t0, -240($t1)
			sw $t0, -512($t1)
			sw $t0, -496($t1)
			sw $t0, -768($t1)
			sw $t0, -752($t1)
			sw $t0, -1024($t1)
			sw $t0, -1020($t1)
			sw $t0, -1016($t1)
			sw $t0, -1012($t1)
			sw $t0, 256($t1)
			sw $t0, 272($t1)
			sw $t0, 512($t1)
			sw $t0, 528($t1)
			sw $t0, 768($t1)
			sw $t0, 784($t1)
			sw $t0, 1024($t1)
			sw $t0, 1028($t1)
			sw $t0, 1032($t1)
			sw $t0, 1036($t1)
			
			#make Y
			move $t1, $s0
			addi $t1, $t1, 8048
			sw $t0, 4($t1)
			sw $t0, 8($t1)
			sw $t0, 16($t1)
			sw $t0, 12($t1)
			sw $t0, -256($t1)
			sw $t0, -240($t1)
			sw $t0, -512($t1)
			sw $t0, -496($t1)
			sw $t0, -768($t1)
			sw $t0, -752($t1)
			sw $t0, -1024($t1)
			sw $t0, -1008($t1)
			sw $t0, 272($t1)
			sw $t0, 528($t1)
			sw $t0, 784($t1)
			sw $t0, 1028($t1)
			sw $t0, 1032($t1)
			sw $t0, 1036($t1)
			sw $t0, 1040($t1)
			
			# make E
			move $t1, $s0
			addi $t1, $t1, 8092
			sw $t0, 0($t1)
			sw $t0, 4($t1)
			sw $t0, 8($t1)
			sw $t0, 16($t1)
			sw $t0, 12($t1)
			sw $t0, -256($t1)
			sw $t0, -512($t1)
			sw $t0, -768($t1)
			sw $t0, -1024($t1)
			sw $t0, -1020($t1)
			sw $t0, -1016($t1)
			sw $t0, -1012($t1)
			sw $t0, -1008($t1)
			sw $t0, 256($t1)
			sw $t0, 512($t1)
			sw $t0, 768($t1)
			sw $t0, 1024($t1)
			sw $t0, 1028($t1)
			sw $t0, 1032($t1)
			sw $t0, 1036($t1)
			sw $t0, 1040($t1)
			
			li $v0, 10 # terminate the program gracefully
			syscall
			jr $ra
		#li $v0, 10 # terminate the program gracefully
		#syscall
		#jr $ra
	second_health:
    		lw $t3, 0($t1)
		beq $t3, black, noo1 # see if pixel below is black
		lw $t3, 0($t1)
		beq $t3, black, noo1 # see if pixel below is black
		move $t1, $s4              # $t1 = addressDisplay
   		addi $t1, $s4, 15220 # check for left side of doodle
   		lw $t3, 0($t1)
		beq $t3, black, noo1
		move $t1, $s4              # $t1 = addressDisplay
   		addi $t1, $s4, 15236 #check for right side of doodle
   		lw $t3, 0($t1)
   		beq $t3, black, noo1
		jr $ra
		noo1:
    			la $t2, s3_global

			li $t3, 1          # Load the value 1
			sw $t3, 0($t2)     # Store the value 1 into the memory location pointed to by s2_global
			addi $s4, $s4, -4352
			addi $s2, $s2, 1
			li $v0, 32 # 32 is for sleep
			li $a0, 50 # sleep for 50 ms
			syscall
			jr $ra
	first_health:
		lw $t3, 0($t1)
		beq $t3, black, noo # see if pixel below is black
		lw $t3, 0($t1)
		beq $t3, black, noo # see if pixel below is black
		move $t1, $s4              # $t1 = addressDisplay
   		addi $t1, $s4, 15220 # check for left side of doodle
   		lw $t3, 0($t1)
		beq $t3, black, noo
		move $t1, $s4              # $t1 = addressDisplay
   		addi $t1, $s4, 15236 #check for right side of doodle
   		lw $t3, 0($t1)
   		beq $t3, black, noo
		jr $ra
		noo:
			# Load the address of s2_global into register $t2
			la $t2, s2_global

			# Store the value 1 into the memory location pointed to by s2_global
			li $t3, 1          # Load the value 1
			sw $t3, 0($t2)     # Store the value 1 into the memory location pointed to by s2_global
			addi $s4, $s4, -4352
			addi $s2, $s2, 1
			li $v0, 32 # 32 is for sleep
			li $a0, 50 # sleep for 50 ms
			syscall
			jr $ra

Doodle:
	
	li $t0, cyan
	#addi $s0, $s0, 256 # keeping this line just pushes the screen down. this goes infinitely if i got this line in clean func.
	move $t1, $s4 
	addi $t1, $s4, 15484 # spawn point of doodle
			     # update the info in $t1
	sw $t0, 0($t1)
	sw $t0, -252($t1)
	sw $t0, -260($t1)
	sw $t0, -512($t1)
	sw $t0, -768($t1)
	sw $t0, -764($t1)
	sw $t0, -760($t1)
	sw $t0, -772($t1)
	sw $t0, -776($t1)
	sw $t0, -516($t1)
	sw $t0, -520($t1)
	sw $t0, -508($t1)
	sw $t0, -504($t1)
	sw $t0, -256($t1)
	
	jr $ra
	
check_key_pressed:
	# Load the memory location where keystroke events are signaled
	li $t9, 0xffff0000
	lw $t8, 0($t9)

	# Check if a keystroke event has occurred (value of 1 indicates a key has been pressed)
	beq $t8, 1, pressed
	jr $ra
	pressed:
   	 	# Load the ASCII value of the pressed key
    		lw $t2, 4($t9)  # Load the next word in memory (contains ASCII value of the pressed key)
    
   		# Check if the pressed key is 'd' (ASCII code of 'd' is 0x64 or 100 in decimal)
   		li $t0, 0x64    # ASCII value for 'd'
   		li $t1, 97 # ASCII value for 'a'
   		li $t3, 119 # ASCII value for 'w'
   		li $t4, 114 # ASCII value for 'r'
   		li $t5, 113 # ASCII value for '	q'

   		# Compare the ASCII value of the pressed key with 'd'
   		beq $t2, $t0, handle_input1
		beq $t2, $t1, handle_input2
		beq $t2, $t3, handle_input3
		beq $t2, $t4, handle_input4
		beq $t2, $t5, handle_input5
		jr $ra

handle_input1:
   	# Handle the input d (increment $s4 by 4)
   	move $t1, $s4              # $t1 = addressDisplay
  	addi $t1, $s4, 15484       # $t1 = addressDisplay + 15484 (position of doodle)

    	# Calculate the address of the pixel next to the doodle
  	addi $t1, $t1, 12         # $t1 = addressDisplay + 15484 + 4 (position of pixel below doodle)
	# Load the color value from memory location $t1 into register $t3
	lw $t3, 0($t1)
    	beq $t3, purple, moveR
    	jr $ra
moveR:
	addi $s4, $s4, 4
    	jr $ra
    	
handle_input2:
    	# Handle the input a (increment $s4 by 4)
    	move $t1, $s4              # $t1 = addressDisplay
  	addi $t1, $s4, 15484       # $t1 = addressDisplay + 15484 (position of doodle)

    	# Calculate the address of the pixel next to the doodle
  	addi $t1, $t1, -12         # $t1 = addressDisplay + 15484 + 4 (position of pixel below doodle)
	# Load the color value from memory location $t1 into register $t3
	lw $t3, 0($t1)
    	beq $t3, purple, moveL
    	jr $ra
moveL:
    	addi $s4, $s4, -4
    	jr $ra
    	
handle_input3:
   	# Handle the input w (increment $s4 by 4)
   	move $t1, $s4              # $t1 = addressDisplay
  	addi $t1, $s4, 15484       # $t1 = addressDisplay + 15484 (position of doodle)

    	# Calculate the address of the pixel below the doodle
  	addi $t1, $t1, 256         # $t1 = addressDisplay + 15484 + 256 (position of pixel below doodle)
	# Load the color value from memory location $t1 into register $t3
	lw $t3, 0($t1)
	move $t5, $s2
	
	beq $t3, pink, jump
	beq, $t5, 1, doubleJump
	beq, $t5, 2, doubleJump
    	
    	jr $ra
    		
doubleJump:
	# only activates when doodle has taken damage atleast once
	# note this deactivates once used, therefore can only be used one time only
    	addi $s4, $s4, -4352
    	addi $s2, $s2, 5
    	jr $ra	

handle_input4:
    	# Handle the input r (reset)
    	# first reset health
    	# Load the address of s2_global into register $t2
	la $t2, s2_global

	# Store the value 1 into the memory location pointed to by s2_global
	li $t3, 0     # Load the value 0
	sw $t3, 0($t2) # Store the value 0 into the memory location pointed to by s2_global

	# Load the address of s3_global into register $t2
	la $t2, s3_global
	sw $t3, 0($t2) # Store the value 0 into the memory location pointed to by s3_global

	move $s4, $s0 # Copy value from $s0 to $s4
	
	beq, $s2, 1, minus
		minus:
			li $s2, 0
			jr $ra
    	jr $ra

handle_input5:
# please note that it is my design choice that i dont display any screen and game is just stopped in between
	# Handle the input q (quit)
    	li $v0, 10 # terminate the program gracefully
	syscall
	jr $ra
jump:
    	addi $s4, $s4, -4352
    	jr $ra	
	
move1:
   	move $t1, $s3              # $t1 = addressDisplay
  	addi $t1, $s3, 11552       # $t1 = addressDisplay + 15484 (position of doodle)

    	# Calculate the address of the pixel below the doodle
  	addi $t1, $t1, 256         # $t1 = addressDisplay + 15484 + 256 (position of pixel below doodle)
	# Load the color value from memory location $t1 into register $t3
	lw $t3, 0($t1)
    	beq $t3, pink, left
    	beq $t3, purple, right
    	jr $ra
    	
	
left:
    	addi $s3, $s3, -4
    	jr $ra
    
right:
    	addi $s3, $s3, 16
    	jr $ra
	
Clone1:
	li $t0, black
	addi $t1, $s3, 11552

	sw $t0, 0($t1)
	sw $t0, -252($t1)
	sw $t0, -260($t1)
	sw $t0, -264($t1)
	sw $t0, -512($t1)
	sw $t0, -768($t1)
	sw $t0, -516($t1)
	sw $t0, -508($t1)
	sw $t0, -256($t1)
	sw $t0, -248($t1)
	sw $t0, -4($t1)
	sw $t0, -8($t1)
	sw $t0, 4($t1)
	sw $t0, 8($t1)
	
	jr $ra
	
Clone2:
	#move $t1, $s0
	addi $t1, $s0, 11596

	sw $t0, 0($t1)
	sw $t0, -252($t1)
	sw $t0, -260($t1)
	sw $t0, -264($t1)
	sw $t0, -512($t1)
	sw $t0, -768($t1)
	sw $t0, -516($t1)
	sw $t0, -508($t1)
	sw $t0, -256($t1)
	sw $t0, -248($t1)
	sw $t0, -4($t1)
	sw $t0, -8($t1)
	sw $t0, 4($t1)
	sw $t0, 8($t1)
	
	jr $ra
	
move3:
   	move $t1, $s5              # $t1 = addressDisplay
  	addi $t1, $s5, 8860       # $t1 = addressDisplay + 15484 (position of doodle)

    	# Calculate the address of the pixel below the doodle
  	addi $t1, $t1, 256         # $t1 = addressDisplay + 15484 + 256 (position of pixel below doodle)
	# Load the color value from memory location $t1 into register $t3
	lw $t3, 0($t1)
    	beq $t3, pink, jump1
    	beq $t3, purple, fall1
    	jr $ra
    	
	
jump1:
    	addi $s5, $s5, -768
    	jr $ra
    
fall1:
    	addi $s5, $s5, 256
    	jr $ra
	
Clone3:
	#move $t1, $s0
	addi $t1, $s5, 8860 

	sw $t0, 0($t1)
	sw $t0, -252($t1)
	sw $t0, -260($t1)
	sw $t0, -264($t1)
	sw $t0, -512($t1)
	sw $t0, -768($t1)
	sw $t0, -516($t1)
	sw $t0, -508($t1)
	sw $t0, -256($t1)
	sw $t0, -248($t1)
	sw $t0, -4($t1)
	sw $t0, -8($t1)
	sw $t0, 4($t1)
	sw $t0, 8($t1)
	
	jr $ra
	
Clone4:
	#move $t1, $s0
	addi $t1, $s0, 8900 

	sw $t0, 0($t1)
	sw $t0, -252($t1)
	sw $t0, -260($t1)
	sw $t0, -264($t1)
	sw $t0, -512($t1)
	sw $t0, -768($t1)
	sw $t0, -516($t1)
	sw $t0, -508($t1)
	sw $t0, -256($t1)
	sw $t0, -248($t1)
	sw $t0, -4($t1)
	sw $t0, -8($t1)
	sw $t0, 4($t1)
	sw $t0, 8($t1)
	
	jr $ra
	
Clone5:
	#move $t1, $s0
	addi $t1, $s0, 6220 

	sw $t0, 0($t1)
	sw $t0, -252($t1)
	sw $t0, -260($t1)
	sw $t0, -264($t1)
	sw $t0, -512($t1)
	sw $t0, -768($t1)
	sw $t0, -516($t1)
	sw $t0, -508($t1)
	sw $t0, -256($t1)
	sw $t0, -248($t1)
	sw $t0, -4($t1)
	sw $t0, -8($t1)
	sw $t0, 4($t1)
	sw $t0, 8($t1)
	
	jr $ra
	
Gravity:
    # Load relevant addresses
    move $t1, $s4              # $t1 = addressDisplay
    addi $t1, $s4, 15484       # $t1 = addressDisplay + 15484 (position of doodle)
    lw $t2, 0($t1)             # $t2 = Color of the doodle

    # Calculate the address of the pixel below the doodle
    addi $t1, $t1, 256         # $t1 = addressDisplay + 15484 + 256 (position of pixel below doodle)
	# Load the color value from memory location $t1 into register $t3
	lw $t3, 0($t1)
	beq $t3, purple, fall
	jr $ra
	
fall:
    # Loop to make the doodle fall until it reaches a pink-colored platform
    addi $s4, $s4, 256
    jr $ra
