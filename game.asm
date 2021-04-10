#####################################################################
#
# CSCB58 Winter 2021 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Rishi Koul, Student Number : 1005697220, UTorID: koulrish
# Bitmap Display Configuration:
# -Unit width in pixels: 8 (update this as needed)
# -Unit height in pixels: 8 (update this as needed)
# -Display width in pixels: 256 (update this as needed)
# -Display height in pixels: 256 (update this as needed)
# -Base Address for Display: 0x10008000 ($gp)
#
# Which milestoneshave been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# -Milestone 1/2/3/4 (choose the one the applies) - 1, 2, 3 and 4
#
# Which approved features have been implemented for milestone 4?
# (See the assignment handout for the list of additional features)
# 1. 2 pickups (to increase health, to devrease speed)
# 2. after some time speed increases
# 3. after some time an enemy ships appears which moves in random order
#
# Link to video demonstration for final submission:
# -(insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
#Are you OK with us sharing the video with people outside course staff?
# -yes / no/ yes, and please share this project githublink as well!
#
# Any additional information that the TA needs to know:
# - the health pickup will only increase the health "once" per collision
# - if you pass the enemny ship safely you will win the game and see a "W" that stand for WIN written on screen
# - passing enemy ship is actually pretty tough because the motion is so random so 
#   collsion will only take place if your ship collides with "central 6 pixel" of enemy ship (this makes it easier to win)


# setting up some variable
.data
plane:    .word    0  # this will store address of the plane
enemy:    .word    0  # this will store address of the plane
enemy_top:    .word    0  # this will store address of the plane
health:    .word    0  # this will store address of the plane
speed:    .word    0  # this will store address of the plane
time:    .word    0  # this will store address of the plane
sec:    .word    0  # this will store address of the plane
obs1:    .word    0	# this will store address of the obstacle 1
obs2:    .word    0	# this will store address of the obstacle 1
obs3:    .word    0	# this will store address of the obstacle 1
counter:	 .word    0	# this will store address of the counter that will take care of no of collisions
dist:    .word    0  # this will store address of the plane

.eqv RED 0xff0000	# store value of colour red
.eqv BLUE 0x0000ff	# store value of colour blue
.eqv GREEN 0x00ff00	# store value of colour green
.eqv BLACK 0x00000000	# store value of colour black
.eqv WHITE 0xffffff	# store value of colour white
.eqv GREY 0x808080	# store value of colour grey
.eqv PURPLE 0X800080

.eqv BASE	0x10008000	# store address of bitmap display

.text

.globl main

main:
# set values of all variables in registers
resetGame:  jal cleanScreen
	   la $t7, sec	# $t7 store the address of bitmap display
	   lw $t5, 0($t7)
	   addi $t5, $zero, 0
	   sw $t5, 0($t7)
	   
	   la $t7, time	# $t7 store the address of bitmap display
	   lw $t5, 0($t7)
	   addi $t5, $zero, 10
	   sw $t5, 0($t7)
	   
	   la $t7, counter	# $t7 store the address of bitmap display
	   addi $t5, $zero, 0	# t5 = 0
	   sw $t5, 0($t7)	# value at address is 0
	   la 	$t7, plane	# t7 contains address of plane
	   li	$t0, BASE		# $t0 stores the base address for display
	   li 	$t1, RED		# $t1 stores the red colour code
	   li 	$t2, GREEN		# $t2 stores the green colour code
	   li 	$t3, BLUE		# $t3 stores the blue colour code
	   li 	$t6, BLACK		# $t3 stores the black colour code
	   li 	$t5, WHITE		# $t3 stores the white colour code
	
################## Designing Health Bar #################

designHealthBar:	li $t6, GREY
			addi $t8, $zero, 3712
			
healthBarLoop:		bge $t8, 4095, designPlane

			la $t5, BASE	# load addr of bitmap
			
			add $t5,$t5, $t8	# t5 = addr of bitmap + 0
			sw   $t6, 0($t5) 	# colour at addr t5 is black
				
			addi $t8, $t8, 4
			j healthBarLoop
			
################## Designing the Plane ##################

# design the initial state of the plane
designPlane:	
	   addi $a2, $zero, 0
	   jal reduceHealth
	   la $t7, counter	# $t7 store the address of bitmap display
	   addi $t5, $zero, 0	# t5 = 0
	   sw $t5, 0($t7)	# value at address is 0
	   la 	$t7, plane	# t7 contains address of plane
	   li	$t0, BASE		# $t0 stores the base address for display
	   li 	$t1, RED		# $t1 stores the red colour code
	   li 	$t2, GREEN		# $t2 stores the green colour code
	   li 	$t3, BLUE		# $t3 stores the blue colour code
	   li 	$t6, BLACK		# $t3 stores the black colour code
	   li 	$t5, WHITE		# $t3 stores the white colour code
	   
	add 	$t9, $zero, $zero # t9 = 0
	addi 	$t9, $zero, 1920	# t9 = 1920, 1920 is the initial address of the plane
	sw	$t9, 0($t7)		# set addr of plane as (1920 + addr of plane)
	jal designPlaneTemp		# j to designPlaneTemp
	j designObstacle1		# j to designObstacle1


# given the address of the plane design it relative to that address	
designPlaneTemp:	
	la $t7, plane	# load address of plane
	la $t5, BASE	# load addr of bitmap
	lw $t9, 0($t7)	# load value of addr of plane
	
	# Design the 1st row of plane
	addi $t9, $t9, 0	# t9 = 0
	add $t5,$t5, $t9 	# t5 = addr of bitmap + 0
	sw   $t6, 0($t5) 	# colour at addr t5 is black
	
	la $t5, BASE	
	addi $t9, $t9, 4
	add $t5,$t5, $t9 
	sw $t1, 0($t5)	
		
	# Design the 2nd row
	lw $t9, 0($t7)
	la $t5, BASE
	addi $t9, $t9, 128
	add $t5,$t5, $t9 
	sw $t2, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, 4
	add $t5,$t5, $t9 
	sw $t1, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, 4
	add $t5,$t5, $t9 
	sw $t1, 0($t5)
	
	# Design the 3rd row
	lw $t9, 0($t7)
	la $t5, BASE
	addi $t9, $t9, 256
	add $t5,$t5, $t9 
	sw $t6, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, 4
	add $t5,$t5, $t9 
	sw $t1, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, 4
	add $t5,$t5, $t9 
	sw $t3, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, 4
	add $t5,$t5, $t9 
	sw $t1, 0($t5)
	
	# Design the 4th row
	
	lw $t9, 0($t7)
	la $t5, BASE
	addi $t9, $t9, 384
	add $t5,$t5, $t9 
	sw $t2, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, 4
	add $t5,$t5, $t9 
	sw $t1, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, 4
	add $t5,$t5, $t9 
	sw $t1, 0($t5)
	
	# Design the 5th row
			
	lw $t9, 0($t7)
	la $t5, BASE
	addi $t9, $t9, 516
	add $t5,$t5, $t9 
	sw $t1, 0($t5)
	
	jr $ra

# given the address of the plane, delete the plane
cleanPlane:	
	la $t7, plane
	la $t5, BASE
	lw $t9, 0($t7)
	
	# Colour the entire 1st row to black
	addi $t9, $t9, 0
	add $t5,$t5, $t9 	
	sw   $t6, 0($t5) 
	
	la $t5, BASE
	addi $t9, $t9, 4
	add $t5,$t5, $t9 
	sw $t6, 0($t5)	
	
	la $t5, BASE
	addi $t9, $t9, 4
	add $t5,$t5, $t9 
	sw $t6, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, 4
	add $t5,$t5, $t9 
	sw $t6, 0($t5)		
	
	# Colour the entire 2nd row to black
	lw $t9, 0($t7)
	la $t5, BASE
	addi $t9, $t9, 128
	add $t5,$t5, $t9 
	sw $t6, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, 4
	add $t5,$t5, $t9 
	sw $t6, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, 4
	add $t5,$t5, $t9 
	sw $t6, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, 4
	add $t5,$t5, $t9 
	sw $t6, 0($t5)
	
	# Colour the entire 3rd row to black
	lw $t9, 0($t7)
	la $t5, BASE
	addi $t9, $t9, 256
	add $t5,$t5, $t9 
	sw $t6, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, 4
	add $t5,$t5, $t9 
	sw $t6, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, 4
	add $t5,$t5, $t9 
	sw $t6, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, 4
	add $t5,$t5, $t9 
	sw $t6, 0($t5)
	
	# Colour the entire 4th row to black
	
	lw $t9, 0($t7)
	la $t5, BASE
	addi $t9, $t9, 384
	add $t5,$t5, $t9 
	sw $t6, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, 4
	add $t5,$t5, $t9 
	sw $t6, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, 4
	add $t5,$t5, $t9 
	sw $t6, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, 4
	add $t5,$t5, $t9 
	sw $t6, 0($t5)
	
	# Colour the entire 5th row to black
			
	lw $t9, 0($t7)
	la $t5, BASE
	addi $t9, $t9, 516
	add $t5,$t5, $t9 
	sw $t6, 0($t5)
	
	
	jr $ra
	
################## Designing the Plane (End) ##################



################## Designing Obstacles ########################

# Given the address of the obstacle stored in ($t7) destroy the obstacle
destroyObstacle:
		 #la $t7, obs1 do this in func
		lw $t5, 0($t7)

		# colour the entire obstacle black 
		li $t0, BASE
		add $t5, $t5, $t0
		addi $t5, $t5, 0
		sw $t6, 0($t5)
		
		addi $t5, $t5, -4
		sw $t6, 0($t5)
		
		addi $t5, $t5, 128
		sw $t6, 0($t5)
		
		addi $t5, $t5, 4
		sw $t6, 0($t5)
		
		jr $ra
		
# Given the address of the obstacle stored in ($t7) design the obstacle
designObstacle: lw $t5, 0($t7)

		# first destroy the present position of the obstacle(else if it is the leftmost part it wont erase from there)
		add $t5, $t5, $t0
		addi $t5, $t5, 0
		sw $t6, 0($t5)
		
		addi $t5, $t5, -4
		sw $t6, 0($t5)
		
		addi $t5, $t5, 128
		sw $t6, 0($t5)
		
		addi $t5, $t5, 4
		sw $t6, 0($t5)
		
		li $v0, 42	# generate a random num bw 1-30 and store it in a0
		li $a0, 1
		li $a1, 27
		syscall		
		
		addi $t9, $zero, 0	
		beq $a2, $t9 this	# if a1 == 0 (obs1) go to this
		addi $t9, $zero, 1
		beq $a2, $t9 this1	# if a1 == 1 (obs2) go to this
		addi $t9, $zero, 2
		beq $a2, $t9 this2	# if a1 == 2 (obs3) go to this
		
here:
		ble $a0, $t9, designObstacle
		
		addi $t9, $t9, 10
		
		bgt $a0, $t9, designObstacle
		
		addi $t5, $zero, 128
		mult $a0, $t5
		mflo $t5
		addi $t5, $t5, -4
		
		sw $t5, 0($t7)
		
		add $t5, $t5, $t0
		
		# then re design the obstacle
		li $t1, 0xffffff
		sw $t1, 0($t5)
		
		addi $t5, $t5, -4
		sw $t1, 0($t5)
		
		addi $t5, $t5, 128
		sw $t1, 0($t5)
		
		addi $t5, $t5, 4
		sw $t1, 0($t5)
		
		jr $ra
		
this: addi $t9, $zero, 0

	j here
this1: addi $t9, $zero, 10

	j here
this2: addi $t9, $zero, 20

	j here

# store the address of obs1 in t7 and call designObstacle
designObstacle1:la $t7, obs1
		addi $a2, $zero, 0
		jal designObstacle
		j designObstacle2
		

# the temp version jumps to moveObstacle1 and not designObstacle2 (this ensures obstacle 2 doesnt get redesigned)
designObstacle1temp:		
		la $t7, obs1
		addi $a2, $zero, 0
		jal designObstacle
		j moveObstacle1
		
# store the address of obs2 in t7 and call designObstacle
designObstacle2:
		la $t7, obs2
		addi $a2, $zero, 1
		jal designObstacle
		j designObstacle3
		
# the temp version jumps to moveObstacle1 and not designObstacle2 (this ensures obstacle 3 doesnt get redesigned)
designObstacle2temp:
		la $t7, obs2
		addi $a2, $zero, 1
		jal designObstacle
		j moveObstacle2
		
# store the address of obs3 in t7 and call designObstacle
designObstacle3:
		la $t7, obs3
		addi $a2, $zero, 2
		jal designObstacle
		j designHealth
		
designObstacle3temp:		
		la $t7, obs3
		addi $a2, $zero, 2
		jal designObstacle
		j moveObstacle3
		
# store the address of obs3 in t7 and call designObstacle
designHealth:	
		li $v0, 42	# generate a random num bw 1-30 and store it in a0
		li $a0, 0
		li $a1, 2
		syscall	
		
		la $t7, health
		add $a2, $zero, $a0
		
		jal designObstacle
		j designSpeed
		
designHealthtemp:
		li $v0, 42	# generate a random num bw 1-30 and store it in a0
		li $a0, 0
		li $a1, 2
		syscall	
		
		la $t7, health
		add $a2, $zero, $a0
		
		jal designObstacle
		j moveHealth
		
# store the address of obs3 in t7 and call designObstacle
designSpeed:	
		li $v0, 42	# generate a random num bw 1-30 and store it in a0
		li $a0, 0
		li $a1, 2
		syscall	
		
		la $t7, speed
		add $a2, $zero, $a0
		
		jal designObstacle
		j moveObstacle1
		
designSpeedtemp:
		li $v0, 42	# generate a random num bw 1-30 and store it in a0
		li $a0, 0
		li $a1, 2
		syscall	
		
		la $t7, speed
		add $a2, $zero, $a0
		
		jal designObstacle
		j moveSpeed

incr_total_speed: 
		la $t9, time
		lw $t8 ,0($t9)
		bge $t8, 5, subtract_4
dont_subtract_4: sw $t8, 0($t9)
		
		j after_incr_speed
		
subtract_4: addi $t8, $t8, -5
		j dont_subtract_4

################## Designing Obstacles(END) ########################
		
################## Moving Obstacles ########################
# responsible for movement of the 1st obstacle
moveObstacle1:	la $t9, sec
		lw $t8 ,0($t9)
		addi $t8, $t8, 1
		sw $t8, 0($t9)
		
		beq $t8, 640, AWESOME
		bgt $t8, 640, moveEnemy
		addi $t9, $zero, 256
		div $t8, $t9
		mfhi $t8
		
		
		beq $t8, $zero, incr_total_speed
		
after_incr_speed:
		li $v0, 32
		la $t9, time
		lw $t9, 0($t9)
		move $a0, $t9   # Wait one second (1000 milliseconds)
		syscall
		
		la $t9, obs1
		
		addi $a1, $zero, 0
		jal check_col
		
		la $t7, obs1
		lw $t5, 0($t7)
		
		addi $t8, $zero, 4
		j check_obstacle
		
obstacle_checkpoint: add $t9, $zero, $zero
 		     add $t8, $zero, $zero
 		     
 		
		addi $t5, $t5, -4
		sw $t5, 0($t7)
		addi $t5, $t5, 4
		add $t5, $t5, $t0
		
		li $t1, 0xffffff
		addi $t5, $t5, 0
		sw $t6, 0($t5)
		
		addi $t5, $t5, -4
		sw $t1, 0($t5)
		
		addi $t5, $t5, -4
		sw $t1, 0($t5)
		
		addi $t5, $t5, 128
		sw $t1, 0($t5)
		
		addi $t5, $t5, 4
		sw $t1, 0($t5)
		
		addi $t5, $t5, 4
		sw $t6, 0($t5)
		
		li $v0, 42
		li $a0, 0
		li $a1, 9
		syscall
		
		beq $a0, $zero moveObstacle1
		
# responsible for movement of the 2nd obstacle	
moveObstacle2:	li $v0, 32
		la $t9, time
		lw $t9, 0($t9)
		move $a0, $t9   # Wait one second (1000 milliseconds)
		syscall
		
		la $t9, obs2
		
		addi $a1, $zero, 1
		jal check_col
		
		la $t7, obs2
		lw $t5, 0($t7)
		
		addi $t8, $zero, 4
		j check_obstacle2
		
obstacle2_checkpoint: add $t9, $zero, $zero
 		     add $t8, $zero, $zero
 		     
		addi $t5, $t5, -4
		sw $t5, 0($t7)
		addi $t5, $t5, 4
		add $t5, $t5, $t0
		
		li $t1, 0xffffff
		addi $t5, $t5, 0
		sw $t6, 0($t5)
		
		addi $t5, $t5, -4
		sw $t1, 0($t5)
		
		addi $t5, $t5, -4
		sw $t1, 0($t5)
		
		addi $t5, $t5, 128
		sw $t1, 0($t5)
		
		addi $t5, $t5, 4
		sw $t1, 0($t5)
		
		addi $t5, $t5, 4
		sw $t6, 0($t5)
		
		li $v0, 42
		li $a0, 0
		li $a1, 3
		syscall
		
		beq $a0, $zero moveObstacle2

# responsible for movement of the 3rd obstacle
moveObstacle3:	li $v0, 32
		la $t9, time
		lw $t9, 0($t9)
		move $a0, $t9    # Wait one second (1000 milliseconds)
		syscall
		
		la $t9, obs3
		
		addi $a1, $zero, 2
		jal check_col
		
		la $t7, obs3
		lw $t5, 0($t7)
		
		addi $t8, $zero, 4
		j check_obstacle3
		
obstacle3_checkpoint: add $t9, $zero, $zero
 		     add $t8, $zero, $zero
 		     
		addi $t5, $t5, -4
		sw $t5, 0($t7)
		addi $t5, $t5, 4
		add $t5, $t5, $t0
		
		li $t1, 0xffffff
		addi $t5, $t5, 0
		sw $t6, 0($t5)
		
		addi $t5, $t5, -4
		sw $t1, 0($t5)
		
		addi $t5, $t5, -4
		sw $t1, 0($t5)
		
		addi $t5, $t5, 128
		sw $t1, 0($t5)
		
		addi $t5, $t5, 4
		sw $t1, 0($t5)
		
		addi $t5, $t5, 4
		sw $t6, 0($t5)
		
		li $v0, 42
		li $a0, 0
		li $a1, 6
		syscall
		
		beq $a0, $zero moveObstacle3
		
# responsible for movement of the health obstacle
moveHealth:	la $t9, health
		
		addi $a1, $zero, 3
		jal check_col
		
		la $t7, health
		lw $t5, 0($t7)
		
		addi $t8, $zero, 4
		j check_health
		
health_checkpoint: add $t9, $zero, $zero
 		     add $t8, $zero, $zero
 		
 		li $t1, RED
		addi $t5, $t5, -4
		sw $t5, 0($t7)
		addi $t5, $t5, 4
		add $t5, $t5, $t0
		
		addi $t5, $t5, 0
		sw $t6, 0($t5)
		
		addi $t5, $t5, -4
		sw $t1, 0($t5)
		
		addi $t5, $t5, -4
		sw $t1, 0($t5)
		
		addi $t5, $t5, 128
		sw $t1, 0($t5)
		
		addi $t5, $t5, 4
		sw $t1, 0($t5)
		
		addi $t5, $t5, 4
		sw $t6, 0($t5)
		
		li $v0, 41
		li $a0, 0
		li $a1, 100
		syscall
		
		beq $a0, $zero moveHealth
		
# responsible for movement of the health obstacle
moveSpeed:	la $t9, speed
		
		addi $a1, $zero, 4
		jal check_col
		
		la $t7, speed
		lw $t5, 0($t7)
		
		addi $t8, $zero, 4
		j check_speed
		
speed_checkpoint: add $t9, $zero, $zero
 		     add $t8, $zero, $zero
 		
 		li $t1, GREEN
		addi $t5, $t5, -4
		sw $t5, 0($t7)
		addi $t5, $t5, 4
		add $t5, $t5, $t0
		
		addi $t5, $t5, 0
		sw $t6, 0($t5)
		
		addi $t5, $t5, -4
		sw $t1, 0($t5)
		
		addi $t5, $t5, -4
		sw $t1, 0($t5)
		
		addi $t5, $t5, 128
		sw $t1, 0($t5)
		
		addi $t5, $t5, 4
		sw $t1, 0($t5)
		
		addi $t5, $t5, 4
		sw $t6, 0($t5)
		
		li $v0, 42
		li $a0, 0
		li $a1, 6
		syscall
		
		beq $a0, $zero moveSpeed
		
	    
################## Moving Obstacles (END) ########################

	
# wait for keyboard input	
loop:	li $t9, 0xffff0000
	lw $t8, 0($t9)
	
	beq $t8, 1, keypress_happened
	j moveObstacle1

# when input received move the plane accoridinly
keypress_happened: lw $t2, 4($t9) 
		    add $t8, $zero, $zero		
		   beq $t2, 0x64, move_right	# ASCII code of 'a' is 0x61 or 97 in decimal
		   beq $t2, 0x61, move_left
		   beq $t2, 0x73, move_down
		   beq $t2, 0x77, move_up
		   j moveObstacle1

################## Moving Plane ########################

# move the plane to the left	   
move_left: 	# initialize the variables
		la  $t7, plane
		add $t9, $zero, $zero
		add $t4, $zero, $zero
		add $t5, $zero, $zero
		li 	$t1, 0xff0000		# $t1 stores the red colour code
		li 	$t2, 0x00ff00		# $t2 stores the green colour code
		li 	$t3, 0x0000ff		# $t3 stores the blue colour code
		li 	$t6, 0x00000000	

				
		# t5 = addr(plane)
		add $t5, $t7, $zero
		
		# t5 = plane[index]		
		lw $t5, 0($t5)
		
		addi $t8, $zero, 0
		j check_left

 move_left_checkpoint: add $t9, $zero, $zero
 		     add $t8, $zero, $zero
 		     
 		     
		jal cleanPlane
		
		la  $t7, plane
		lw $t9, 0($t7)
		addi $t9, $t9, -4
		sw $t9, 0($t7)
		
		jal designPlaneTemp
		
		
		j moveObstacle1
	   		
# move the plane to the right
move_right: 	# initialize the variables
		la  $t7, plane
		add $t9, $zero, $zero
		add $t4, $zero, $zero
		add $t5, $zero, $zero
		li 	$t1, 0xff0000		# $t1 stores the red colour code
		li 	$t2, 0x00ff00		# $t2 stores the green colour code
		li 	$t3, 0x0000ff		# $t3 stores the blue colour code
		li 	$t6, 0x00000000	
				
		# t5 = addr(plane)
		add $t5, $t7, $zero
		
		# t5 = plane[index]		
		lw $t5, 0($t5)
		
		addi $t8, $zero, 112
		j check_right

 move_right_checkpoint: add $t9, $zero, $zero
 		     add $t8, $zero, $zero
				
		 		     
		jal cleanPlane
		
		la  $t7, plane
		lw $t9, 0($t7)
		addi $t9, $t9, 4
		sw $t9, 0($t7)
		
		jal designPlaneTemp
		
		
		j moveObstacle1
	

# move the plane to  down
move_down: 	# initialize the variables
		la  $t7, plane
		add $t9, $zero, $zero
		add $t4, $zero, $zero
		add $t5, $zero, $zero
		li 	$t1, 0xff0000		# $t1 stores the red colour code
		li 	$t2, 0x00ff00		# $t2 stores the green colour code
		li 	$t3, 0x0000ff		# $t3 stores the blue colour code
		li 	$t6, 0x00000000	
				
		# t5 = addr(plane)
		add $t5, $t7, $zero
		
		# t5 = plane[index]		
		lw $t5, 0($t5)
		
		addi $t8, $zero, 2944
		j check_down

 move_down_checkpoint: add $t9, $zero, $zero
 		     add $t8, $zero, $zero
 		     
		 		     
		jal cleanPlane
		
		la  $t7, plane
		lw $t9, 0($t7)
		addi $t9, $t9, 128
		sw $t9, 0($t7)
		
		jal designPlaneTemp
		
		
		j moveObstacle1
		
# move the plane up
move_up: 	# initialize the variables
		la  $t7, plane
		add $t9, $zero, $zero
		add $t4, $zero, $zero
		add $t5, $zero, $zero
		li 	$t1, 0xff0000		# $t1 stores the red colour code
		li 	$t2, 0x00ff00		# $t2 stores the green colour code
		li 	$t3, 0x0000ff		# $t3 stores the blue colour code
		li 	$t6, 0x00000000	
				
		# t5 = addr(plane)
		add $t5, $t7, $zero
		
		# t5 = plane[index]		
		lw $t5, 0($t5)
		
		add $t8, $zero, $zero
		j check_up

 move_up_checkpoint: add $t9, $zero, $zero
 		     add $t8, $zero, $zero
		 		     
		jal cleanPlane
		
		la  $t7, plane
		lw $t9, 0($t7)
		addi $t9, $t9, -128
		sw $t9, 0($t7)
		
		jal designPlaneTemp
		
		
		j moveObstacle1

################## Moving Plane(END) ########################

################## Making sure obstacle and plane dont go out of screen ########################
# check if plane can go up and not out of bounds
check_up: addi $t9, $zero, 128
	  bge $t8, $t9 move_up_checkpoint
	  beq $t5, $t8 moveObstacle1
	  add $t8, $t8, 4
	  j check_up
	  
# check if plane can go down and not out of bounds
check_down: addi $t9, $zero, 3071  # t8 should be 3456
	    bge $t8, $t9 move_down_checkpoint
	    beq $t5, $t8 moveObstacle1
	    add $t8, $t8, 4
	    j check_down
	    
# check if plane can go right and not out of bounds
check_right: addi $t9, $zero, 4080   # t8 should be 112
	    bge $t8, $t9 move_right_checkpoint
	    beq $t5, $t8 moveObstacle1
	    add $t8, $t8, 128
	    j check_right
	    
# check if plane can go left and not out of bounds
check_left: addi $t9, $zero, 3712   # t8 should be 0
	    bge $t8, $t9 move_left_checkpoint
	    beq $t5, $t8 moveObstacle1
	    add $t8, $t8, 128
	    j check_left 
	    
# check when the 1st obstacle reaches the leftmost part of the screen
check_obstacle: addi $t9, $zero, 3844   # t8 should be 0
	    bge $t8, $t9 obstacle_checkpoint
	    beq $t5, $t8 designObstacle1temp
	    add $t8, $t8, 128
	    j check_obstacle
	    
# check when the 2nd obstacle reaches the leftmost part of the screen
check_obstacle2: addi $t9, $zero, 3844   # t8 should be 0
	    bge $t8, $t9 obstacle2_checkpoint
	    beq $t5, $t8 designObstacle2temp
	    add $t8, $t8, 128
	    j check_obstacle2
	    
# check when the 3rd obstacle reaches the leftmost part of the screen
check_obstacle3: addi $t9, $zero, 3844   # t8 should be 0
	    bge $t8, $t9 obstacle3_checkpoint
	    beq $t5, $t8 designObstacle3temp
	    add $t8, $t8, 128
	    j check_obstacle3

# check when the health obstacle reaches the leftmost part of the screen
check_health: addi $t9, $zero, 3844   # t8 should be 0
	    bge $t8, $t9 health_checkpoint
	    beq $t5, $t8 designHealthtemp
	    add $t8, $t8, 128
	    j check_health

# check when the health obstacle reaches the leftmost part of the screen
check_speed: addi $t9, $zero, 3844   # t8 should be 0
	    bge $t8, $t9 speed_checkpoint
	    beq $t5, $t8 designSpeedtemp
	    add $t8, $t8, 128
	    j check_speed

################## Making sure obstacle and plane dont go out of screen(END) ########################


################## Check for collision ########################
# check if there is a collsion bw plane and obstacle
check_col:   la $t7, plane
	          
	     lw $t8, 0($t7)
	     lw $t5, 0($t9)
	     
	     addi $t1, $t5, -4 # reset this back
	     addi $t2, $t5, 128 # reset this back
	     addi $t3, $t5, 124 # reset this back
	     
loop1:	addi $t8, $t8, 4
	beq $t8, $t5 collision
	beq $t8, $t1 collision
	beq $t8, $t2 collision
	beq $t8, $t3 collision
	
	addi $t8, $t8, 128
	beq $t8, $t5 collision
	beq $t8, $t1 collision
	beq $t8, $t2 collision
	beq $t8, $t3 collision
	
	addi $t8, $t8, -4
	beq $t8, $t5 collision
	beq $t8, $t1 collision
	beq $t8, $t2 collision
	beq $t8, $t3 collision
	
	addi $t8, $t8, 8
	beq $t8, $t5 collision
	beq $t8, $t1 collision
	beq $t8, $t2 collision
	beq $t8, $t3 collision
	
	addi $t8, $t8, 128
	beq $t8, $t5 collision
	beq $t8, $t1 collision
	beq $t8, $t2 collision
	beq $t8, $t3 collision
	
	addi $t8, $t8, 4
	beq $t8, $t5 collision
	beq $t8, $t1 collision
	beq $t8, $t2 collision
	beq $t8, $t3 collision
	
	addi $t8, $t8, -8
	beq $t8, $t5 collision
	beq $t8, $t1 collision
	beq $t8, $t2 collision
	beq $t8, $t3 collision
	
	addi $t8, $t8, 128
	beq $t8, $t5 collision
	beq $t8, $t1 collision
	beq $t8, $t2 collision
	beq $t8, $t3 collision
	
	addi $t8, $t8, -4
	beq $t8, $t5 collision
	beq $t8, $t1 collision
	beq $t8, $t2 collision
	beq $t8, $t3 collision
	
	addi $t8, $t8, 8
	beq $t8, $t5 collision
	beq $t8, $t1 collision
	beq $t8, $t2 collision
	beq $t8, $t3 collision
	
	addi $t8, $t8, 124
	beq $t8, $t5 collision
	beq $t8, $t1 collision
	beq $t8, $t2 collision
	beq $t8, $t3 collision
	
	jr $ra

	
# if there is a collision
collision: 	
		addi $t1, $zero, 4 # reset this back
		beq $a1, $t1, skip_reduce_health
		
		addi $a2, $zero, 1
		jal reduceHealth
		
		li $t0, BASE
		la $t1, counter
		lw $t2, 0($t1)
		
		addi $t3, $zero, 9
		
		bge $t2, $t3 END_GAME
		addi $t2, $t2, 1
		sw $t2, 0($t1)
		
skip_reduce_health: 
		li 	$t1, 0xff0000		# $t1 stores the red colour code
		li 	$t2, 0xff0000		# $t2 stores the green colour code
		li 	$t3, 0xff0000		# $t3 stores the blue colour code
		li 	$t5, 0xff0000
		
		jal designPlaneTemp
		
		li $v0, 32
		li $a0, 200   # Wait one second (1000 milliseconds)
		syscall
		
		  li 	$t1, RED		# $t1 stores the red colour code
	 	  li 	$t2, GREEN		# $t2 stores the green colour code
	 	  li 	$t3, BLUE		# $t3 stores the blue colour code
	 	  li 	$t6, BLACK	
	 	  li 	$t5, WHITE
	 	  
		addi $t1, $zero, 0 # reset this back
	        addi $t2, $zero, 1 # reset this back
	        addi $t3, $zero, 2 # reset this back
	        addi $t4, $zero, 3 # reset this back
		 
		beq $a1, $t1 set_obs1
		beq $a1, $t2 set_obs2
		beq $a1, $t3 set_obs3
		beq $a1, $t4 set_health
		addi $t1, $zero, 4 # reset this back
		beq $a1, $t1, reduce_speed

restart:
		
		jal designObstacle
		
		la $t7, plane
		
		  li 	$t1, RED		# $t1 stores the red colour code
	 	  li 	$t2, GREEN		# $t2 stores the green colour code
	 	  li 	$t3, BLUE		# $t3 stores the blue colour code
	 	  li 	$t6, BLACK	
	 	  li 	$t5, WHITE
		
		jal designPlaneTemp
		
		j moveObstacle1
		
	
set_obs1: la $t7, obs1
	  j restart
set_obs2: la $t7, obs2
	  j restart
set_obs3: la $t7, obs3
	  j restart
set_health: la $t7, health
	  j restart

	    
reduceHealth:	addi $t1, $zero, 3
		beq $a1, 3, incrHealth
		la $t1, counter
		lw $t1, 0($t1)
		addi $t1, $t1, 1
		addi $t2, $zero, 9
		
		sub $t1, $t2, $t1
		
		j createHealth

incrHealth :    la $t1, counter
		lw $t2, 0($t1)
		addi $t2, $t2, -1
		blt $t2, $zero counter_0
		la $t1, counter
jback:		sw $t2, 0($t1)

		la $t1, counter
		lw $t1, 0($t1)
		addi $t1, $t1, 0
		
		addi $t2, $zero, 9
		
		sub $t1, $t2, $t1
		
		j createHealth

counter_0 : 
		addi $t2, $zero, 0
		j jback
		
createHealth:	addi $t2, $zero, 0
		li $t0, BASE
		addi $t0, $t0, 3864

healthLoop:	li $t5, GREEN 	
		ble $t2, $t1, changeColour
		addi $t1, $zero, 9
healthLoop2:    
		beq $a2, $zero setGreen
		li $t5, BLACK
skip: ble $t2, $t1, changeColourToBlack
		
		
		addi $t1, $zero, 3
		jr $ra 

setGreen : li $t5, GREEN
	   j skip

changeColourToBlack:	 sw $t5, 0($t0)
			sw $t5, 4($t0)
			addi $t0, $t0, 8
			addi $t2, $t2, 1
			j healthLoop2
changeColour:
		sw $t5, 0($t0)
		sw $t5, 4($t0)
		
		addi $t0, $t0, 8
		addi $t2, $t2, 1
		j healthLoop
		
reduce_speed: la $t9, time
	       lw $t1, 0($t9)
	       addi $t1, $t1, 1
	       sw $t1, 0($t9)
	       
	       la $t7, speed
	       j restart
		
################## Check collision(END) ########################

################## Display END GAME ############################

# end the game if the plane crashes more than 10 times 	
END_GAME:  jal cleanPlane
		jal cleanEnemyShip

	  la $t7, obs1 
	  jal destroyObstacle
	  
	  la $t7, obs2 
	  jal destroyObstacle
	  
	  la $t7, obs3
	  jal destroyObstacle
	  
	  la $t7, health
	  jal destroyObstacle
	  
	  la $t7, speed
	  jal destroyObstacle
	  
	  li $t9, 0xffff0000
	  lw $t8, 0($t9)
	  
 li $t0, BASE # $t0 stores the base address for display 
  li $t1, WHITE # $t1 STORES HWITE
  addi $t0,$t0,1552
  
  sw $t1, ($t0)
  sw $t1, -256($t0)
  sw $t1, -128($t0)
  sw $t1, 128($t0)
  sw $t1, 256($t0)
  
  sw $t1, -252($t0)
  sw $t1, -248($t0)
  sw $t1, -244($t0)
  sw $t1, -240($t0)
  
  sw $t1, 260($t0)
  sw $t1, 264($t0)
  sw $t1, 268($t0)
  sw $t1, 272($t0)
  
  sw $t1, 144($t0)
  sw $t1, 16($t0)
  sw $t1, 12($t0)
  sw $t1, 8($t0)
  
  #print a
        addi $t0,$t0,280
  sw $t1, ($t0)
  sw $t1, -128($t0)
  sw $t1, -256($t0)
  sw $t1, -384($t0)
  sw $t1, -512($t0)
  sw $t1, -508($t0)
  sw $t1, -504($t0)
  sw $t1, -500($t0)
  sw $t1, -496($t0)
  
  sw $t1, -368($t0)
  sw $t1, -240($t0)
  
  sw $t1, -244($t0)
  sw $t1, -248($t0)
  sw $t1, -252($t0)
  sw $t1, -256($t0)
  sw $t1, -112($t0)
  sw $t1, 16($t0)
  
  #print m
  addi $t0,$t0,24
  sw $t1,($t0)
   sw $t1, -128($t0)
  sw $t1, -256($t0)
  sw $t1, -384($t0)
  sw $t1, -512($t0)
  sw $t1, -508($t0)
  sw $t1, -504($t0)
   sw $t1, -376($t0)
   sw $t1, -248($t0)
   sw $t1, -120($t0)
   sw $t1, 8($t0)
  sw $t1, -500($t0)
  sw $t1, -496($t0)
  
   sw $t1, -368($t0)
  sw $t1, -240($t0)
   sw $t1, -112($t0)
  sw $t1, 16($t0)
  
  #print e
  addi $t0,$t0,24
  sw $t1,($t0)
   sw $t1, -128($t0)
  sw $t1, -256($t0)
     sw $t1, -252($t0)
     sw $t1, -248($t0)
     sw $t1, -244($t0)
     sw $t1, -240($t0)
  sw $t1, -384($t0)
  sw $t1, -512($t0)
  
  sw $t1, -508($t0)
  sw $t1, -504($t0)
  sw $t1, -500($t0)
  sw $t1, -496($t0)
  
   sw $t1, 4($t0)
   sw $t1, 8($t0)
   sw $t1, 12($t0)
   sw $t1, 16($t0)
 
  # print o
  li $t0, BASE
  addi $t0,$t0,2704
  sw $t1,($t0)
   sw $t1, -128($t0)
  sw $t1, -256($t0)
  sw $t1, -384($t0)
  sw $t1, -512($t0)
   sw $t1, -508($t0)
  sw $t1, -504($t0)
  sw $t1, -500($t0)
  sw $t1, -496($t0)
   sw $t1, -368($t0)
  sw $t1, -240($t0)
  sw $t1, -112($t0)
  sw $t1, 16($t0)
  sw $t1, 12($t0)
  sw $t1, 8($t0)
  sw $t1, 4($t0)
  
  #print v
  addi $t0,$t0,24
  sw $t1,8($t0)
  sw $t1, -124($t0)
  sw $t1, -256($t0)
   sw $t1, -384($t0)
  sw $t1, -512($t0)
  
  sw $t1, -496($t0)
  sw $t1, -368($t0)
  sw $t1, -240($t0)
   sw $t1, -116($t0)
   
  #print e
  addi $t0,$t0,24
  sw $t1,($t0)
   sw $t1, -128($t0)
  sw $t1, -256($t0)
     sw $t1, -252($t0)
     sw $t1, -248($t0)
     sw $t1, -244($t0)
     sw $t1, -240($t0)
  sw $t1, -384($t0)
  sw $t1, -512($t0)
  
  sw $t1, -508($t0)
  sw $t1, -504($t0)
  sw $t1, -500($t0)
  sw $t1, -496($t0)
  
   sw $t1, 4($t0)
   sw $t1, 8($t0)
   sw $t1, 12($t0)
   sw $t1, 16($t0)
   
   #print R
   addi $t0,$t0,24
   sw $t1,($t0)
   sw $t1, -128($t0)
  sw $t1, -256($t0)
  sw $t1, -384($t0)
  sw $t1, -512($t0)
   sw $t1, -508($t0)
  sw $t1, -504($t0)
  sw $t1, -500($t0)
  sw $t1, -496($t0)
   sw $t1, -368($t0)
  
   sw $t1, -252($t0)
   sw $t1, -124($t0)
   sw $t1, -248($t0)
   sw $t1, 8($t0)
    sw $t1, -244($t0)
    sw $t1, -240($t0)
  
stop_flicker: 	 li $t9, 0xffff0000
	  lw $t8, 0($t9)
 	beq $t8, 1, keypress_happened_end
	  j stop_flicker
	  
# restart the game if 'p' is pressed
keypress_happened_end: lw $t2, 4($t9) 
		    add $t8, $zero, $zero
		    add $t0, $zero, $zero		# this assumes $t9 is set to 0xfff0000from before
		     addi $t1, $zero, 4095
		   beq $t2, 0x70, resetGame	# ASCII code of 'a' is 0x61 or 97 in decimal
		   j stop_flicker
		   
################## Display END GAME (END) ############################

################## Design Enemy Ship and Move it Randomly ############################
AWESOME: la $t7, obs1
	 jal destroyObstacle
	 
	 la $t7, obs2
	 jal destroyObstacle
	 
	 la $t7, obs3
	 jal destroyObstacle
	 
	 la $t7, health
	 jal destroyObstacle
	 
	 la $t7, speed
	 jal destroyObstacle
	 	   
	 la 	$t7, enemy	
	 li	$t0, BASE		# $t0 stores the base address for display
	 li 	$t1, PURPLE		# $t1 stores the red colour code
	 li 	$t2, RED		# $t2 stores the green colour code
	 li 	$t3, BLUE		# $t3 stores the blue colour code
	 li 	$t6, BLACK		# $t3 stores the black colour code
	
	la 	$t7, enemy_top	# t7 contains address of plane
	add 	$t9, $zero, $zero # t9 = 0
	addi 	$t9, $zero, 120	# t9 = 1920, 1920 is the initial address of the plane
	sw	$t9, 0($t7)		# set addr of plane as (1920 + addr of plane)
	
	la 	$t7, enemy	# t7 contains address of plane
	add 	$t9, $zero, $zero # t9 = 0
	addi 	$t9, $zero, 2040	# t9 = 1920, 1920 is the initial address of the plane
	sw	$t9, 0($t7)		# set addr of plane as (1920 + addr of plane)
	jal createEnemyShipTemp		# j to designPlaneTemp
	
	 j moveEnemy
	 
createEnemyShipTemp:	
	 li 	$t1, PURPLE		
	 li 	$t2, RED		
	 li 	$t3, BLUE		
	 li 	$t6, BLACK		
	 
	la $t7, enemy	
	la $t5, BASE	
	lw $t9, 0($t7)	
	
	# Design the 1st row of plane
	addi $t9, $t9, 0	
	add $t5,$t5, $t9 	
	sw   $t6, 0($t5) 	
	
	la $t5, BASE	
	addi $t9, $t9, -4
	add $t5,$t5, $t9 
	sw $t1, 0($t5)	
		
	# Design the 2nd row
	lw $t9, 0($t7)
	la $t5, BASE
	addi $t9, $t9, 128
	add $t5,$t5, $t9 
	sw $t2, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, -4
	add $t5,$t5, $t9 
	sw $t1, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, -4
	add $t5,$t5, $t9 
	sw $t1, 0($t5)
	
	# Design the 3rd row
	lw $t9, 0($t7)
	la $t5, BASE
	addi $t9, $t9, 256
	add $t5,$t5, $t9 
	sw $t6, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, -4
	add $t5,$t5, $t9 
	sw $t1, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, -4
	add $t5,$t5, $t9 
	sw $t3, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, -4
	add $t5,$t5, $t9 
	sw $t1, 0($t5)
	
	# Design the 4th row
	
	lw $t9, 0($t7)
	la $t5, BASE
	addi $t9, $t9, 384
	add $t5,$t5, $t9 
	sw $t2, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, -4
	add $t5,$t5, $t9 
	sw $t1, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, -4
	add $t5,$t5, $t9 
	sw $t1, 0($t5)
	
	# Design the 5th row
			
	lw $t9, 0($t7)
	la $t5, BASE
	addi $t9, $t9, 508
	add $t5,$t5, $t9 
	sw $t1, 0($t5)
	
	jr $ra

cleanEnemyShip:	

	li 	$t6, BLACK		
	la $t7, enemy	
	la $t5, BASE	
	lw $t9, 0($t7)	
	
	# Design the 1st row of plane
	addi $t9, $t9, 0	
	add $t5,$t5, $t9 
	sw   $t6, 0($t5) 	
	
	la $t5, BASE	
	addi $t9, $t9, -4
	add $t5,$t5, $t9 
	sw $t6, 0($t5)	
		
	# Design the 2nd row
	lw $t9, 0($t7)
	la $t5, BASE
	addi $t9, $t9, 128
	add $t5,$t5, $t9 
	sw $t6, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, -4
	add $t5,$t5, $t9 
	sw $t6, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, -4
	add $t5,$t5, $t9 
	sw $t6, 0($t5)
	
	# Design the 3rd row
	lw $t9, 0($t7)
	la $t5, BASE
	addi $t9, $t9, 256
	add $t5,$t5, $t9 
	sw $t6, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, -4
	add $t5,$t5, $t9 
	sw $t6, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, -4
	add $t5,$t5, $t9 
	sw $t6, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, -4
	add $t5,$t5, $t9 
	sw $t6, 0($t5)
	
	# Design the 4th row
	
	lw $t9, 0($t7)
	la $t5, BASE
	addi $t9, $t9, 384
	add $t5,$t5, $t9 
	sw $t6, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, -4
	add $t5,$t5, $t9 
	sw $t6, 0($t5)
	
	la $t5, BASE
	addi $t9, $t9, -4
	add $t5,$t5, $t9 
	sw $t6, 0($t5)
	
	# Design the 5th row
			
	lw $t9, 0($t7)
	la $t5, BASE
	addi $t9, $t9, 508
	add $t5,$t5, $t9 
	sw $t6, 0($t5)
	
	jr $ra
	
moveEnemy: 
		li $v0, 32
		li $a0, 500   # Wait
		syscall
		
	    la $t9, enemy_top
	    lw $t8, 0($t9)
	    
	    addi $t8, $t8, -4
	    sw $t8, 0($t9)
	    
	    addi $t1, $t8, -12
	    addi $t9, $zero, 128
	    
	    div $t1, $t9
	    mfhi $t1
	    beq $t1, $zero, VICTORY
	       
	    li $v0, 42	# generate a random num bw 0-25 and store it in a0
	    li $a0, 10
	    li $a1, 25
	    syscall
	    
	    addi $t1, $zero, 128
	    mult $t1, $a0
	    mflo $t1
	    add $t1, $t8, $t1
	    
	    la $t9, enemy
	    lw $t8, 0($t9)
	    
	    jal cleanEnemyShip
	    
	    la $t9, enemy
	    sw $t1, 0($t9)
	    
	    jal createEnemyShipTemp
	    jal checkEnemyShipCollision
		
	   j loop

################## Design Enemy Ship and Move it Randomly (END) ############################

################## Check for enemy ship collision ############################
checkEnemyShipCollision:
		la $t9, enemy
		lw $t1, 0($t9)
		
		la $t7, plane
		lw $t8, 0($t7)
		
		addi $t1, $t1, -4
		
		add $s0, $t1, 128
		add $s1, $t1, 256
		add $s2, $t1, 384
		add $s3, $s0, -4
		add $s4, $s1, -4
		add $s5, $s2, -4
		
		
	addi $t8, $t8, 4
	beq $t8, $s0 ship_collision
	beq $t8, $s1 ship_collision
	beq $t8, $s2 ship_collision
	beq $t8, $s3 ship_collision
	beq $t8, $s4 ship_collision
	beq $t8, $s5 ship_collision

	
	addi $t8, $t8, 128
	beq $t8, $s0 ship_collision
	beq $t8, $s1 ship_collision
	beq $t8, $s2 ship_collision
	beq $t8, $s3 ship_collision
	beq $t8, $s4 ship_collision
	beq $t8, $s5 ship_collision
	
	addi $t8, $t8, -4
	beq $t8, $s0 ship_collision
	beq $t8, $s1 ship_collision
	beq $t8, $s2 ship_collision
	beq $t8, $s3 ship_collision
	beq $t8, $s4 ship_collision
	beq $t8, $s5 ship_collision
	
	addi $t8, $t8, 8
	beq $t8, $s0 ship_collision
	beq $t8, $s1 ship_collision
	beq $t8, $s2 ship_collision
	beq $t8, $s3 ship_collision
	beq $t8, $s4 ship_collision
	beq $t8, $s5 ship_collision
	
	addi $t8, $t8, 128
	beq $t8, $s0 ship_collision
	beq $t8, $s1 ship_collision
	beq $t8, $s2 ship_collision
	beq $t8, $s3 ship_collision
	beq $t8, $s4 ship_collision
	beq $t8, $s5 ship_collision
	
	addi $t8, $t8, 4
	beq $t8, $s0 ship_collision
	beq $t8, $s1 ship_collision
	beq $t8, $s2 ship_collision
	beq $t8, $s3 ship_collision
	beq $t8, $s4 ship_collision
	beq $t8, $s5 ship_collision
	
	addi $t8, $t8, -8
	beq $t8, $s0 ship_collision
	beq $t8, $s1 ship_collision
	beq $t8, $s2 ship_collision
	beq $t8, $s3 ship_collision
	beq $t8, $s4 ship_collision
	beq $t8, $s5 ship_collision
	
	addi $t8, $t8, 128
	beq $t8, $s0 ship_collision
	beq $t8, $s1 ship_collision
	beq $t8, $s2 ship_collision
	beq $t8, $s3 ship_collision
	beq $t8, $s4 ship_collision
	beq $t8, $s5 ship_collision
	
	addi $t8, $t8, -4
	beq $t8, $s0 ship_collision
	beq $t8, $s1 ship_collision
	beq $t8, $s2 ship_collision
	beq $t8, $s3 ship_collision
	beq $t8, $s4 ship_collision
	beq $t8, $s5 ship_collision
	
	addi $t8, $t8, 8
	beq $t8, $s0 ship_collision
	beq $t8, $s1 ship_collision
	beq $t8, $s2 ship_collision
	beq $t8, $s3 ship_collision
	beq $t8, $s4 ship_collision
	beq $t8, $s5 ship_collision
	
	addi $t8, $t8, 124
	beq $t8, $s0 ship_collision
	beq $t8, $s1 ship_collision
	beq $t8, $s2 ship_collision
	beq $t8, $s3 ship_collision
	beq $t8, $s4 ship_collision
	beq $t8, $s5 ship_collision
	
	jr $ra

ship_collision:
		li 	$t1, RED		
		li 	$t2, RED		
		li 	$t3, RED		
		li 	$t5, RED
				
		jal designPlaneTemp
		
		li $v0, 32
		li $a0, 500   # Wait 
		syscall
		
		j END_GAME
		
################## Check for enemy ship collision (END) ############################

################## Display W that stands for WIN ############################
VICTORY:
		jal cleanPlane
		jal cleanEnemyShip
	  
	  li $t9, 0xffff0000
	  lw $t8, 0($t9)
	  
 li $t0, BASE # $t0 stores the base address for display 
  li $t1, WHITE # $t1 STORES HWITE
  addi $t0,$t0,1552
  
  #print v
  addi $t0,$t0,24
  
  sw $t1, -640($t0)
  sw $t1,8($t0)
  sw $t1, -124($t0)
  sw $t1, -256($t0)
   sw $t1, -384($t0)
  sw $t1, -512($t0)
  
  sw $t1, -496($t0)
  sw $t1, -368($t0)
  sw $t1, -240($t0)
   sw $t1, -116($t0)
   
   sw $t1, -108($t0)
   sw $t1, 24($t0)
   sw $t1, -100($t0)
   sw $t1, -224($t0)
   sw $t1, -352($t0)
   sw $t1, -480($t0)
   sw $t1, -608($t0)

  
stop_flicker_2: 	 li $t9, 0xffff0000
	  lw $t8, 0($t9)
 	beq $t8, 1, keypress_happened_end_2
	  j stop_flicker_2
	  
# restart the game if 'p' is pressed
keypress_happened_end_2: lw $t2, 4($t9) 
		    add $t8, $zero, $zero
		    add $t0, $zero, $zero		# this assumes $t9 is set to 0xfff0000from before
		     addi $t1, $zero, 4095
		   beq $t2, 0x70, resetGame	# ASCII code of 'a' is 0x61 or 97 in decimal
		   j stop_flicker_2

################## Display W that stands for WIN(END) ############################

################## Clean screen ############################

cleanScreen: la $t0, BASE
		addi $t1, $zero, 0
cleanScreenCond:
		ble $t1, 3968, cleanScreenLoop
		
		jr $ra
		
cleanScreenLoop: la $t0, BASE
		li $t6, BLACK
		add $t0, $t0, $t1
		sw $t6, 0($t0)
		
		addi $t1, $t1, 4
		
		j cleanScreenCond
		
################## Clean screen(END) ############################

EXIT:	li $v0, 10 # terminate the program gracefully
	syscall
