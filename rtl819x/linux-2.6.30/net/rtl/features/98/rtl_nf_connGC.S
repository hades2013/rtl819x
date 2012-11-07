	.file	1 "rtl_nf_connGC.c"
	.section .mdebug.abi32
	.previous
#APP
	.macro _ssnop; sll $0, $0, 1; .endm
	.macro _ehb; sll $0, $0, 3; .endm
	.macro mtc0_tlbw_hazard; nop; nop; .endm
	.macro tlbw_use_hazard; nop; nop; nop; .endm
	.macro tlb_probe_hazard; nop; nop; nop; .endm
	.macro irq_enable_hazard; _ssnop; _ssnop; _ssnop;; .endm
	.macro irq_disable_hazard; nop; nop; nop; .endm
	.macro back_to_back_c0_hazard; _ssnop; _ssnop; _ssnop;; .endm
		.macro	raw_local_irq_enable				
	.set	push						
	.set	reorder						
	.set	noat						
	mfc0	$1,$12						
	ori	$1,0x1f						
	xori	$1,0x1e						
	mtc0	$1,$12						
	irq_enable_hazard					
	.set	pop						
	.endm
		.macro	raw_local_irq_disable
	.set	push						
	.set	noat						
	mfc0	$1,$12						
	ori	$1,0x1f						
	xori	$1,0x1f						
	.set	noreorder					
	mtc0	$1,$12						
	irq_disable_hazard					
	.set	pop						
	.endm							

		.macro	raw_local_save_flags flags			
	.set	push						
	.set	reorder						
	mfc0	\flags, $12					
	.set	pop						
	.endm							

		.macro	raw_local_irq_save result			
	.set	push						
	.set	reorder						
	.set	noat						
	mfc0	\result, $12					
	ori	$1, \result, 0x1f				
	xori	$1, 0x1f					
	.set	noreorder					
	mtc0	$1, $12						
	irq_disable_hazard					
	.set	pop						
	.endm							

		.macro	raw_local_irq_restore flags			
	.set	push						
	.set	noreorder					
	.set	noat						
	mfc0	$1, $12						
	andi	\flags, 1					
	ori	$1, 0x1f					
	xori	$1, 0x1f					
	or	\flags, $1					
	mtc0	\flags, $12					
	irq_disable_hazard					
	.set	pop						
	.endm							

#NO_APP
	.globl	drop_priority
	.data
	.align	2
	.type	drop_priority, @object
	.size	drop_priority, 40
drop_priority:
	.byte	8
	.space	1
	.half	60
	.byte	6
	.space	1
	.half	30
	.byte	5
	.space	1
	.half	60
	.byte	7
	.space	1
	.half	120
	.byte	4
	.space	1
	.half	120
	.byte	11
	.space	1
	.half	30
	.byte	1
	.space	1
	.half	90
	.byte	2
	.space	1
	.half	30
	.byte	12
	.space	1
	.half	10
	.byte	3
	.space	1
	.half	120
	.globl	Udp_State_Hash_Head
	.align	2
	.type	Udp_State_Hash_Head, @object
	.size	Udp_State_Hash_Head, 16
Udp_State_Hash_Head:
	.byte	11
	.space	3
	.word	udp_unreply_list
	.byte	12
	.space	3
	.word	udp_assured_list
	.align	2
	.type	udp_assured_list, @object
	.size	udp_assured_list, 8
udp_assured_list:
	.word	udp_assured_list
	.word	udp_assured_list
	.align	2
	.type	udp_unreply_list, @object
	.size	udp_unreply_list, 8
udp_unreply_list:
	.word	udp_unreply_list
	.word	udp_unreply_list
	.globl	Tcp_State_Hash_Head
	.align	2
	.type	Tcp_State_Hash_Head, @object
	.size	Tcp_State_Hash_Head, 88
Tcp_State_Hash_Head:
	.word	0
	.word	0
	.word	1
	.word	syn_sent_list
	.word	2
	.word	syn_recv_list
	.word	3
	.word	established_list
	.word	4
	.word	fin_wait_list
	.word	5
	.word	close_wait_list
	.word	6
	.word	last_ack_list
	.word	7
	.word	time_wait_list
	.word	8
	.word	close_list
	.word	9
	.word	listen_list
	.word	10
	.word	0
	.align	2
	.type	listen_list, @object
	.size	listen_list, 8
listen_list:
	.word	listen_list
	.word	listen_list
	.align	2
	.type	close_list, @object
	.size	close_list, 8
close_list:
	.word	close_list
	.word	close_list
	.align	2
	.type	time_wait_list, @object
	.size	time_wait_list, 8
time_wait_list:
	.word	time_wait_list
	.word	time_wait_list
	.align	2
	.type	last_ack_list, @object
	.size	last_ack_list, 8
last_ack_list:
	.word	last_ack_list
	.word	last_ack_list
	.align	2
	.type	close_wait_list, @object
	.size	close_wait_list, 8
close_wait_list:
	.word	close_wait_list
	.word	close_wait_list
	.align	2
	.type	fin_wait_list, @object
	.size	fin_wait_list, 8
fin_wait_list:
	.word	fin_wait_list
	.word	fin_wait_list
	.align	2
	.type	established_list, @object
	.size	established_list, 8
established_list:
	.word	established_list
	.word	established_list
	.align	2
	.type	syn_recv_list, @object
	.size	syn_recv_list, 8
syn_recv_list:
	.word	syn_recv_list
	.word	syn_recv_list
	.align	2
	.type	syn_sent_list, @object
	.size	syn_sent_list, 8
syn_sent_list:
	.word	syn_sent_list
	.word	syn_sent_list
	.globl	conntrack_max
	.align	2
	.type	conntrack_max, @object
	.size	conntrack_max, 4
conntrack_max:
	.word	100
	.globl	conntrack_min
	.align	2
	.type	conntrack_min, @object
	.size	conntrack_min, 4
conntrack_min:
	.word	0
	.section	.text.conntrack_dointvec,"ax",@progbits
	.align	2
	.globl	conntrack_dointvec
	.ent	conntrack_dointvec
	.type	conntrack_dointvec, @function
conntrack_dointvec:
	.set	nomips16
	.frame	$sp,32,$31		# vars= 0, regs= 2/0, args= 24, gp= 0
	.mask	0x80010000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	addiu	$sp,$sp,-32
	lw	$2,48($sp)
	sw	$16,24($sp)
	move	$16,$5
	sw	$2,16($sp)
	lw	$2,52($sp)
	sw	$31,28($sp)
	jal	proc_dointvec
	sw	$2,20($sp)

	bne	$2,$0,$L1
	move	$3,$2

	beq	$16,$0,$L1
	move	$3,$0

	lui	$2,%hi(nf_conntrack_max)
	move	$5,$0
	lw	$6,%lo(nf_conntrack_max)($2)
	lui	$2,%hi(_prot_limit)
	addiu	$9,$2,%lo(_prot_limit)
	lui	$2,%hi(prot_limit)
	addiu	$8,$2,%lo(prot_limit)
	li	$2,1374355456			# 0x51eb0000
	ori	$7,$2,0x851f
	sll	$3,$5,2
$L15:
	addiu	$5,$5,1
	addu	$2,$3,$8
	slt	$4,$5,3
	lw	$2,0($2)
	addu	$3,$3,$9
	mult	$6,$2
	mflo	$2
	multu	$2,$7
	mfhi	$2
	srl	$2,$2,5
	sw	$2,0($3)
	bne	$4,$0,$L15
	sll	$3,$5,2

	li	$3,-859045888			# 0xcccc0000
	sll	$2,$6,2
	ori	$3,$3,0xcccd
	lui	$4,%hi(rtl_nf_conntrack_threshold)
	multu	$2,$3
	mfhi	$2
	srl	$2,$2,2
	subu	$3,$6,$2
	sltu	$3,$3,65
	bne	$3,$0,$L8
	sw	$2,%lo(rtl_nf_conntrack_threshold)($4)

	addiu	$2,$6,-64
	sw	$2,%lo(rtl_nf_conntrack_threshold)($4)
$L8:
	lui	$2,%hi(nf_conntrack_max)
	lw	$2,%lo(nf_conntrack_max)($2)
	beq	$2,$0,$L16
	lui	$2,%hi(rtl_newGC_session_status_flags)

	lui	$2,%hi(init_net+468)
	lw	$3,%lo(init_net+468)($2)
	lw	$2,%lo(rtl_nf_conntrack_threshold)($4)
	slt	$2,$2,$3
	beq	$2,$0,$L9
	lui	$4,%hi(rtl_newGC_session_status_flags)

	li	$3,3			# 0x3
	lw	$2,%lo(rtl_newGC_session_status_flags)($4)
	beq	$2,$3,$L3
	lui	$2,%hi(jiffies)

	lw	$2,%lo(jiffies)($2)
	sw	$3,%lo(rtl_newGC_session_status_flags)($4)
	lui	$3,%hi(rtl_newGC_session_status_time)
	addiu	$2,$2,1
	j	$L3
	sw	$2,%lo(rtl_newGC_session_status_time)($3)

$L9:
	lui	$2,%hi(rtl_newGC_session_status_flags)
$L16:
	sw	$0,%lo(rtl_newGC_session_status_flags)($2)
$L3:
	move	$3,$0
$L1:
	lw	$31,28($sp)
	move	$2,$3
	lw	$16,24($sp)
	j	$31
	addiu	$sp,$sp,32

	.set	macro
	.set	reorder
	.end	conntrack_dointvec
	.section	.text.conntrack_dointvec_minmax,"ax",@progbits
	.align	2
	.globl	conntrack_dointvec_minmax
	.ent	conntrack_dointvec_minmax
	.type	conntrack_dointvec_minmax, @function
conntrack_dointvec_minmax:
	.set	nomips16
	.frame	$sp,32,$31		# vars= 0, regs= 2/0, args= 24, gp= 0
	.mask	0x80010000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	addiu	$sp,$sp,-32
	lw	$2,48($sp)
	sw	$16,24($sp)
	move	$16,$5
	sw	$2,16($sp)
	lw	$2,52($sp)
	sw	$31,28($sp)
	jal	proc_dointvec_minmax
	sw	$2,20($sp)

	bne	$2,$0,$L17
	move	$3,$2

	beq	$16,$0,$L17
	move	$3,$0

	lui	$2,%hi(nf_conntrack_max)
	move	$5,$0
	lw	$6,%lo(nf_conntrack_max)($2)
	lui	$2,%hi(_prot_limit)
	addiu	$9,$2,%lo(_prot_limit)
	lui	$2,%hi(prot_limit)
	addiu	$8,$2,%lo(prot_limit)
	li	$2,1374355456			# 0x51eb0000
	ori	$7,$2,0x851f
	sll	$3,$5,2
$L31:
	addiu	$5,$5,1
	addu	$2,$3,$8
	slt	$4,$5,3
	lw	$2,0($2)
	addu	$3,$3,$9
	mult	$6,$2
	mflo	$2
	multu	$2,$7
	mfhi	$2
	srl	$2,$2,5
	sw	$2,0($3)
	bne	$4,$0,$L31
	sll	$3,$5,2

	li	$3,-859045888			# 0xcccc0000
	sll	$2,$6,2
	ori	$3,$3,0xcccd
	lui	$4,%hi(rtl_nf_conntrack_threshold)
	multu	$2,$3
	mfhi	$2
	srl	$2,$2,2
	subu	$3,$6,$2
	sltu	$3,$3,65
	bne	$3,$0,$L24
	sw	$2,%lo(rtl_nf_conntrack_threshold)($4)

	addiu	$2,$6,-64
	sw	$2,%lo(rtl_nf_conntrack_threshold)($4)
$L24:
	lui	$2,%hi(nf_conntrack_max)
	lw	$2,%lo(nf_conntrack_max)($2)
	beq	$2,$0,$L32
	lui	$2,%hi(rtl_newGC_session_status_flags)

	lui	$2,%hi(init_net+468)
	lw	$3,%lo(init_net+468)($2)
	lw	$2,%lo(rtl_nf_conntrack_threshold)($4)
	slt	$2,$2,$3
	beq	$2,$0,$L25
	lui	$4,%hi(rtl_newGC_session_status_flags)

	li	$3,3			# 0x3
	lw	$2,%lo(rtl_newGC_session_status_flags)($4)
	beq	$2,$3,$L19
	lui	$2,%hi(jiffies)

	lw	$2,%lo(jiffies)($2)
	sw	$3,%lo(rtl_newGC_session_status_flags)($4)
	lui	$3,%hi(rtl_newGC_session_status_time)
	addiu	$2,$2,1
	j	$L19
	sw	$2,%lo(rtl_newGC_session_status_time)($3)

$L25:
	lui	$2,%hi(rtl_newGC_session_status_flags)
$L32:
	sw	$0,%lo(rtl_newGC_session_status_flags)($2)
$L19:
	move	$3,$0
$L17:
	lw	$31,28($sp)
	move	$2,$3
	lw	$16,24($sp)
	j	$31
	addiu	$sp,$sp,32

	.set	macro
	.set	reorder
	.end	conntrack_dointvec_minmax
	.section	.text.clean_from_lists,"ax",@progbits
	.align	2
	.globl	clean_from_lists
	.ent	clean_from_lists
	.type	clean_from_lists, @function
clean_from_lists:
	.set	nomips16
	.frame	$sp,32,$31		# vars= 0, regs= 3/0, args= 16, gp= 0
	.mask	0x80030000,-8
	.fmask	0x00000000,0
	addiu	$sp,$sp,-32
	sw	$17,20($sp)
	move	$17,$5
	sw	$16,16($sp)
	addiu	$5,$4,4
	sw	$31,24($sp)
	move	$16,$4
	lw	$3,4($4)
	lw	$4,4($5)
	andi	$2,$3,0x1
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L38
	sw	$3,0($4)
	.set	macro
	.set	reorder

	sw	$4,4($3)
$L38:
	li	$2,2097152			# 0x200000
	addiu	$6,$16,52
	ori	$7,$2,0x200
	sw	$7,4($5)
	lw	$3,52($16)
	lw	$4,4($6)
	andi	$2,$3,0x1
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L42
	sw	$3,0($4)
	.set	macro
	.set	reorder

	sw	$4,4($3)
$L42:
	.set	noreorder
	.set	nomacro
	jal	local_bh_disable
	sw	$7,4($6)
	.set	macro
	.set	reorder

	li	$2,6			# 0x6
	lbu	$3,50($16)
	.set	noreorder
	.set	nomacro
	beq	$3,$2,$L48
	slt	$2,$3,7
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L54
	li	$2,17			# 0x11
	.set	macro
	.set	reorder

	li	$2,1			# 0x1
	.set	noreorder
	.set	nomacro
	beq	$3,$2,$L52
	li	$2,6			# 0x6
	.set	macro
	.set	reorder

	j	$L65
$L54:
	.set	noreorder
	.set	nomacro
	beq	$3,$2,$L50
	lui	$2,%hi(prot_counters+8)
	.set	macro
	.set	reorder

	j	$L47
$L48:
	lui	$2,%hi(prot_counters+4)
#APP
	   

	1:	ll	    $3, %lo(prot_counters+4)($2)		# atomic_sub		
       nop                                             
	subu	$3, 1					
	sc	    $3, %lo(prot_counters+4)($2)					
	beqz	$3, 2f					
	.subsection 2					
2:	b	1b					
	.previous					

#NO_APP
	j	$L64
$L50:
#APP
	   

	1:	ll	    $3, %lo(prot_counters+8)($2)		# atomic_sub		
       nop                                             
	subu	$3, 1					
	sc	    $3, %lo(prot_counters+8)($2)					
	beqz	$3, 2f					
	.subsection 2					
2:	b	1b					
	.previous					

#NO_APP
	j	$L64
$L52:
	lui	$2,%hi(prot_counters)
#APP
	   

	1:	ll	    $4, %lo(prot_counters)($2)		# atomic_sub		
       nop                                             
	subu	$4, $3					
	sc	    $4, %lo(prot_counters)($2)					
	beqz	$4, 2f					
	.subsection 2					
2:	b	1b					
	.previous					

#NO_APP
$L64:
#APP
	   

#NO_APP
$L47:
	lbu	$3,50($16)
	li	$2,6			# 0x6
$L65:
	.set	noreorder
	.set	nomacro
	beq	$3,$2,$L56
	li	$2,17			# 0x11
	.set	macro
	.set	reorder

	bne	$3,$2,$L63
$L56:
	move	$4,$16
	.set	noreorder
	.set	nomacro
	jal	clean_from_lists_hooks
	move	$5,$17
	.set	macro
	.set	reorder

	addiu	$5,$16,204
	lw	$4,4($5)
	li	$2,1048576			# 0x100000
	lw	$3,204($16)
	ori	$2,$2,0x100
	sw	$3,0($4)
	sw	$2,204($16)
	li	$2,2097152			# 0x200000
	ori	$2,$2,0x200
	sw	$4,4($3)
	sw	$2,4($5)
	lui	$2,%hi(nf_conntrack_max)
	lw	$2,%lo(nf_conntrack_max)($2)
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L66
	lui	$2,%hi(rtl_newGC_session_status_flags)
	.set	macro
	.set	reorder

	lui	$2,%hi(rtl_nf_conntrack_threshold)
	lw	$3,468($17)
	lw	$2,%lo(rtl_nf_conntrack_threshold)($2)
	slt	$2,$2,$3
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L59
	lui	$4,%hi(rtl_newGC_session_status_flags)
	.set	macro
	.set	reorder

	li	$3,3			# 0x3
	lw	$2,%lo(rtl_newGC_session_status_flags)($4)
	.set	noreorder
	.set	nomacro
	beq	$2,$3,$L61
	lui	$2,%hi(jiffies)
	.set	macro
	.set	reorder

	lw	$2,%lo(jiffies)($2)
	sw	$3,%lo(rtl_newGC_session_status_flags)($4)
	lui	$3,%hi(rtl_newGC_session_status_time)
	addiu	$2,$2,1
	.set	noreorder
	.set	nomacro
	j	$L61
	sw	$2,%lo(rtl_newGC_session_status_time)($3)
	.set	macro
	.set	reorder

$L59:
	lui	$2,%hi(rtl_newGC_session_status_flags)
$L66:
	sw	$0,%lo(rtl_newGC_session_status_flags)($2)
$L61:
	.set	noreorder
	.set	nomacro
	jal	rtl_fp_mark_invalid
	move	$4,$16
	.set	macro
	.set	reorder

$L63:
	jal	local_bh_enable
	move	$4,$16
	lw	$31,24($sp)
	lw	$17,20($sp)
	lw	$16,16($sp)
	.set	noreorder
	.set	nomacro
	j	nf_ct_remove_expectations
	addiu	$sp,$sp,32
	.set	macro
	.set	reorder

	.end	clean_from_lists
	.section	.text.rtl_death_action,"ax",@progbits
	.align	2
	.globl	rtl_death_action
	.ent	rtl_death_action
	.type	rtl_death_action, @function
rtl_death_action:
	.set	nomips16
	.frame	$sp,32,$31		# vars= 0, regs= 3/0, args= 16, gp= 0
	.mask	0x80030000,-8
	.fmask	0x00000000,0
	addiu	$sp,$sp,-32
	lui	$2,%hi(init_net)
	sw	$17,20($sp)
	addiu	$17,$2,%lo(init_net)
	sw	$16,16($sp)
	sw	$31,24($sp)
	lw	$3,200($4)
	.set	noreorder
	.set	nomacro
	beq	$3,$0,$L74
	move	$16,$4
	.set	macro
	.set	reorder

	lbu	$2,8($3)
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L74
	addu	$3,$3,$2
	.set	macro
	.set	reorder

	beq	$3,$0,$L74
	lw	$2,0($3)
	beq	$2,$0,$L74
	lw	$2,64($2)
	beq	$2,$0,$L74
	jal	$2
$L74:
	jal	local_bh_disable
	move	$5,$17
	lw	$3,488($17)
	move	$4,$16
	lw	$2,24($3)
	addiu	$2,$2,1
	.set	noreorder
	.set	nomacro
	jal	clean_from_lists
	sw	$2,24($3)
	.set	macro
	.set	reorder

	jal	local_bh_enable
	beq	$16,$0,$L67
#APP
	   

	1:	ll	$3, 0($16)		# atomic_sub_return	
       nop                                             
	subu	$2, $3, 1				
	sc	$2, 0($16)					
	beqz	$2, 2f					
	subu	$2, $3, 1				
	.subsection 2					
2:	b	1b					
	.previous					

	   

#NO_APP
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L67
	move	$4,$16
	.set	macro
	.set	reorder

	lw	$31,24($sp)
	lw	$17,20($sp)
	lw	$16,16($sp)
	.set	noreorder
	.set	nomacro
	j	nf_conntrack_destroy
	addiu	$sp,$sp,32
	.set	macro
	.set	reorder

$L67:
	lw	$31,24($sp)
	lw	$17,20($sp)
	lw	$16,16($sp)
	.set	noreorder
	.set	nomacro
	j	$31
	addiu	$sp,$sp,32
	.set	macro
	.set	reorder

	.end	rtl_death_action
	.section	.text.rtl_connGC_addList,"ax",@progbits
	.align	2
	.globl	rtl_connGC_addList
	.ent	rtl_connGC_addList
	.type	rtl_connGC_addList, @function
rtl_connGC_addList:
	.set	nomips16
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	lw	$2,156($4)
	lbu	$3,9($2)
	li	$2,6			# 0x6
	.set	noreorder
	.set	nomacro
	beq	$3,$2,$L96
	slt	$2,$3,7
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L113
	li	$2,17			# 0x11
	.set	macro
	.set	reorder

	li	$2,1			# 0x1
	beq	$3,$2,$L109
	.set	noreorder
	.set	nomacro
	j	$31
	move	$2,$0
	.set	macro
	.set	reorder

$L113:
	.set	noreorder
	.set	nomacro
	beq	$3,$2,$L101
	move	$2,$0
	.set	macro
	.set	reorder

	j	$L116
$L96:
	lbu	$3,176($5)
	lui	$2,%hi(Tcp_State_Hash_Head)
	addiu	$2,$2,%lo(Tcp_State_Hash_Head)
	sll	$3,$3,3
	addu	$3,$3,$2
	lw	$4,4($3)
	beq	$4,$0,$L97
	lw	$3,4($4)
	addiu	$2,$5,204
	sw	$4,204($5)
	sw	$2,4($4)
	sw	$2,0($3)
	sw	$3,4($2)
$L97:
	lui	$2,%hi(prot_counters+4)
#APP
	   

		.set	mips3					
1:	ll	$3, %lo(prot_counters+4)($2)		# atomic_add		
       nop                                             
	addu	$3, 1					
	sc	$3, %lo(prot_counters+4)($2)					
	beqz	$3, 2f					
	.subsection 2					
2:	b	1b					
	.previous					
	.set	mips0					

#NO_APP
	j	$L115
$L101:
	lw	$2,100($5)
	addiu	$4,$5,204
	andi	$2,$2,0x2
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L102
	lui	$3,%hi(Udp_State_Hash_Head)
	.set	macro
	.set	reorder

	addiu	$2,$3,%lo(Udp_State_Hash_Head)
	lw	$2,12($2)
	j	$L114
$L102:
	addiu	$2,$3,%lo(Udp_State_Hash_Head)
	lw	$2,4($2)
$L114:
	lw	$3,4($2)
	sw	$2,204($5)
	sw	$4,4($2)
	lui	$2,%hi(prot_counters+8)
	sw	$4,0($3)
	sw	$3,4($4)
#APP
	   

		.set	mips3					
1:	ll	$3, %lo(prot_counters+8)($2)		# atomic_add		
       nop                                             
	addu	$3, 1					
	sc	$3, %lo(prot_counters+8)($2)					
	beqz	$3, 2f					
	.subsection 2					
2:	b	1b					
	.previous					
	.set	mips0					

#NO_APP
	j	$L115
$L109:
	lui	$2,%hi(prot_counters)
#APP
	   

		.set	mips3					
1:	ll	$4, %lo(prot_counters)($2)		# atomic_add		
       nop                                             
	addu	$4, $3					
	sc	$4, %lo(prot_counters)($2)					
	beqz	$4, 2f					
	.subsection 2					
2:	b	1b					
	.previous					
	.set	mips0					

#NO_APP
$L115:
#APP
	   

#NO_APP
	move	$2,$0
$L116:
	j	$31
	.end	rtl_connGC_addList
	.section	.text.__nf_ct_refresh_acct_proto,"ax",@progbits
	.align	2
	.globl	__nf_ct_refresh_acct_proto
	.ent	__nf_ct_refresh_acct_proto
	.type	__nf_ct_refresh_acct_proto, @function
__nf_ct_refresh_acct_proto:
	.set	nomips16
	.frame	$sp,64,$31		# vars= 8, regs= 7/0, args= 24, gp= 0
	.mask	0x803f0000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	addiu	$sp,$sp,-64
	sw	$17,36($sp)
	move	$17,$4
	sw	$21,52($sp)
	move	$21,$6
	sw	$20,48($sp)
	move	$20,$5
	sw	$19,44($sp)
	sw	$18,40($sp)
	sw	$31,56($sp)
	sw	$16,32($sp)
	sw	$0,24($sp)
	lbu	$18,87($sp)
	jal	local_bh_disable
	move	$19,$7

	lw	$2,100($17)
	srl	$2,$2,10
	andi	$2,$2,0x1
	bne	$2,$0,$L153
	nop

	lw	$2,100($17)
	srl	$2,$2,3
	andi	$2,$2,0x1
	bne	$2,$0,$L126
	li	$2,8			# 0x8

	sw	$19,116($17)
	j	$L129
	sw	$2,24($sp)

$L126:
	addiu	$16,$17,108
	jal	del_timer
	move	$4,$16

	beq	$2,$0,$L129
	lui	$2,%hi(jiffies)

	move	$4,$16
	lw	$2,%lo(jiffies)($2)
	addu	$2,$2,$19
	jal	add_timer
	sw	$2,116($17)

	li	$2,8			# 0x8
	sw	$2,24($sp)
	li	$2,6			# 0x6
	beq	$18,$2,$L132
	li	$2,17			# 0x11

	beq	$18,$2,$L137
	nop

	j	$L129
	nop

$L132:
	lw	$3,92($sp)
	lui	$2,%hi(Tcp_State_Hash_Head)
	addiu	$4,$17,204
	addiu	$2,$2,%lo(Tcp_State_Hash_Head)
	sll	$3,$3,3
	lw	$6,4($4)
	addu	$3,$3,$2
	lw	$5,204($17)
	lw	$2,4($3)
	sw	$6,4($5)
	lw	$3,4($2)
	sw	$5,0($6)
	sw	$4,4($2)
	sw	$2,204($17)
	sw	$3,4($4)
	j	$L129
	sw	$4,0($3)

$L137:
	lw	$2,100($17)
	lw	$6,204($17)
	andi	$2,$2,0x2
	beq	$2,$0,$L138
	addiu	$5,$17,204

	lui	$3,%hi(udp_assured_list)
	lw	$2,4($5)
	j	$L152
	addiu	$3,$3,%lo(udp_assured_list)

$L138:
	lui	$3,%hi(udp_unreply_list)
	lw	$2,4($5)
	addiu	$3,$3,%lo(udp_unreply_list)
$L152:
	sw	$2,4($6)
	lw	$4,4($3)
	sw	$6,0($2)
	sw	$5,4($3)
	sw	$3,204($17)
	sw	$4,4($5)
	sw	$5,0($4)
$L129:
	lw	$7,80($sp)
	addiu	$2,$sp,24
	move	$4,$17
	move	$5,$20
	move	$6,$21
	jal	__nf_ct_refresh_acct_proto_hooks
	sw	$2,16($sp)

$L153:
	jal	local_bh_enable
	nop

	lw	$31,56($sp)
	lw	$21,52($sp)
	lw	$20,48($sp)
	lw	$19,44($sp)
	lw	$18,40($sp)
	lw	$17,36($sp)
	lw	$16,32($sp)
	j	$31
	addiu	$sp,$sp,64

	.set	macro
	.set	reorder
	.end	__nf_ct_refresh_acct_proto
	.section	.text.drop_one_conntrack,"ax",@progbits
	.align	2
	.globl	drop_one_conntrack
	.ent	drop_one_conntrack
	.type	drop_one_conntrack, @function
drop_one_conntrack:
	.set	nomips16
	.frame	$sp,64,$31		# vars= 0, regs= 9/0, args= 24, gp= 0
	.mask	0x80ff0000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	addiu	$sp,$sp,-64
	sw	$31,56($sp)
	sw	$23,52($sp)
	sw	$22,48($sp)
	sw	$21,44($sp)
	sw	$20,40($sp)
	sw	$19,36($sp)
	sw	$18,32($sp)
	sw	$17,28($sp)
	sw	$16,24($sp)
	lhu	$3,16($4)
	sltu	$2,$3,1024
	bne	$2,$0,$L154
	li	$2,1			# 0x1

	li	$6,8080			# 0x1f90
	beq	$3,$6,$L154
	nop

	lhu	$3,36($4)
	sltu	$2,$3,1024
	bne	$2,$0,$L154
	li	$2,1			# 0x1

	beq	$3,$6,$L154
	nop

	lhu	$3,16($5)
	sltu	$2,$3,1024
	bne	$2,$0,$L154
	li	$2,1			# 0x1

	beq	$3,$6,$L154
	nop

	lhu	$3,36($5)
	sltu	$2,$3,1024
	bne	$2,$0,$L154
	li	$2,1			# 0x1

	beq	$3,$6,$L154
	li	$7,-268435456			# 0xf0000000

	lw	$3,20($4)
	li	$8,-536870912			# 0xe0000000
	and	$2,$3,$7
	lw	$4,0($4)
	beq	$2,$8,$L391
	li	$6,-1			# 0xffffffff

	beq	$3,$6,$L154
	li	$2,1			# 0x1

	beq	$4,$0,$L154
	nop

	lw	$3,20($5)
	lw	$5,0($5)
	and	$2,$3,$7
	beq	$2,$8,$L154
	li	$2,1			# 0x1

	beq	$3,$6,$L154
	nop

	beq	$5,$0,$L154
	lui	$3,%hi(prot_counters+4)

	lui	$2,%hi(_prot_limit+4)
	lw	$2,%lo(_prot_limit+4)($2)
	lw	$3,%lo(prot_counters+4)($3)
	slt	$2,$2,$3
	beq	$2,$0,$L444
	lui	$2,%hi(_prot_limit+8)

	jal	local_bh_disable
	move	$19,$0

	lui	$3,%hi(drop_priority)
$L446:
	sll	$2,$19,2
	addiu	$3,$3,%lo(drop_priority)
	addu	$2,$2,$3
	lbu	$3,0($2)
	sltu	$2,$3,10
	beq	$2,$0,$L183
	lui	$2,%hi(Tcp_State_Hash_Head)

	sll	$3,$3,3
	addiu	$2,$2,%lo(Tcp_State_Hash_Head)
	addu	$3,$3,$2
	lw	$18,4($3)
	lw	$4,0($18)
	beq	$4,$18,$L183
	move	$17,$4

$L434:
	beq	$17,$18,$L183
	addiu	$16,$17,-204

	li	$12,-268435456			# 0xf0000000
	lw	$6,32($16)
	li	$11,-536870912			# 0xe0000000
	lhu	$10,28($16)
	and	$2,$6,$12
	lhu	$7,48($16)
	lhu	$8,76($16)
	lhu	$9,96($16)
	lw	$4,12($16)
	lw	$5,60($16)
	lw	$3,80($16)
	beq	$2,$11,$L189
	and	$2,$3,$12

	beq	$2,$11,$L189
	nop

	bne	$4,$3,$L445
	sltu	$2,$10,1024

	beq	$6,$5,$L189
	nop

$L445:
	bne	$2,$0,$L189
	sltu	$2,$7,1024

	bne	$2,$0,$L189
	sltu	$2,$8,1024

	bne	$2,$0,$L189
	sltu	$2,$9,1024

	bne	$2,$0,$L189
	li	$2,8080			# 0x1f90

	beq	$10,$2,$L189
	nop

	beq	$7,$2,$L189
	nop

	beq	$8,$2,$L189
	nop

	beq	$9,$2,$L189
	nop

	jal	del_timer
	addiu	$4,$17,-96

	bne	$2,$0,$L409
	nop

$L189:
	lw	$17,0($17)
	j	$L434
	nop

$L183:
	addiu	$19,$19,1
	sltu	$2,$19,10
	bne	$2,$0,$L446
	lui	$3,%hi(drop_priority)

	jal	local_bh_enable
	nop

	lui	$2,%hi(_prot_limit+8)
$L444:
	lui	$3,%hi(prot_counters+8)
	lw	$2,%lo(_prot_limit+8)($2)
	lw	$3,%lo(prot_counters+8)($3)
	slt	$2,$2,$3
	beq	$2,$0,$L213
	nop

	jal	local_bh_disable
	move	$19,$0

	lui	$3,%hi(drop_priority)
$L448:
	sll	$2,$19,2
	addiu	$3,$3,%lo(drop_priority)
	addu	$2,$2,$3
	lbu	$3,0($2)
	sltu	$2,$3,11
	bne	$2,$0,$L219
	lui	$2,%hi(Udp_State_Hash_Head)

	sll	$3,$3,3
	addiu	$2,$2,%lo(Udp_State_Hash_Head)
	addu	$3,$3,$2
	lw	$18,-84($3)
	lw	$4,0($18)
	beq	$4,$18,$L219
	move	$17,$4

$L435:
	beq	$17,$18,$L219
	addiu	$16,$17,-204

	li	$12,-268435456			# 0xf0000000
	lw	$6,32($16)
	li	$11,-536870912			# 0xe0000000
	lhu	$10,28($16)
	and	$2,$6,$12
	lhu	$7,48($16)
	lhu	$8,76($16)
	lhu	$9,96($16)
	lw	$4,12($16)
	lw	$5,60($16)
	lw	$3,80($16)
	beq	$2,$11,$L225
	and	$2,$3,$12

	beq	$2,$11,$L225
	nop

	bne	$4,$3,$L447
	sltu	$2,$10,1024

	beq	$6,$5,$L225
	nop

$L447:
	bne	$2,$0,$L225
	sltu	$2,$7,1024

	bne	$2,$0,$L225
	sltu	$2,$8,1024

	bne	$2,$0,$L225
	sltu	$2,$9,1024

	bne	$2,$0,$L225
	li	$2,8080			# 0x1f90

	beq	$10,$2,$L225
	nop

	beq	$7,$2,$L225
	nop

	beq	$8,$2,$L225
	nop

	beq	$9,$2,$L225
	nop

	jal	del_timer
	addiu	$4,$17,-96

	bne	$2,$0,$L409
	nop

$L225:
	lw	$17,0($17)
	j	$L435
	nop

$L219:
	addiu	$19,$19,1
	sltu	$2,$19,10
	bne	$2,$0,$L448
	lui	$3,%hi(drop_priority)

	jal	local_bh_enable
	nop

	j	$L213
	nop

$L409:
	jal	local_bh_enable
	nop

	jal	rtl_death_action
	move	$4,$16

	j	$L443
	lui	$4,%hi(rtl_newGC_session_status_flags)

$L213:
	jal	local_bh_disable
	move	$19,$0

	lui	$22,%hi(drop_priority)
$L453:
	sll	$21,$19,2
	addiu	$2,$22,%lo(drop_priority)
	addu	$2,$21,$2
	lbu	$2,0($2)
	sltu	$3,$2,10
	beq	$3,$0,$L257
	sll	$4,$2,3

	lui	$2,%hi(Tcp_State_Hash_Head)
	addiu	$2,$2,%lo(Tcp_State_Hash_Head)
	addu	$2,$4,$2
	lw	$18,4($2)
	lw	$4,0($18)
	beq	$4,$18,$L290
	li	$23,3			# 0x3

	move	$17,$4
	move	$20,$0
$L436:
	beq	$17,$18,$L290
	addiu	$16,$17,-204

	li	$12,-268435456			# 0xf0000000
	lw	$6,32($16)
	li	$11,-536870912			# 0xe0000000
	and	$2,$6,$12
	lhu	$7,28($16)
	lhu	$8,48($16)
	lhu	$9,76($16)
	lhu	$10,96($16)
	lw	$4,12($16)
	lw	$5,60($16)
	lw	$3,80($16)
	beq	$2,$11,$L263
	addiu	$20,$20,1

	and	$2,$3,$12
	beq	$2,$11,$L263
	nop

	bne	$4,$3,$L449
	sltu	$2,$7,1024

	beq	$6,$5,$L263
	nop

$L449:
	bne	$2,$0,$L263
	sltu	$2,$8,1024

	bne	$2,$0,$L263
	sltu	$2,$9,1024

	bne	$2,$0,$L263
	sltu	$2,$10,1024

	bne	$2,$0,$L263
	li	$2,8080			# 0x1f90

	beq	$7,$2,$L263
	nop

	beq	$8,$2,$L263
	nop

	beq	$9,$2,$L263
	nop

	beq	$10,$2,$L263
	lui	$2,%hi(jiffies)

	addiu	$3,$22,%lo(drop_priority)
	lw	$4,%lo(jiffies)($2)
	addu	$3,$21,$3
	lw	$2,116($16)
	lhu	$3,2($3)
	subu	$2,$2,$4
	srl	$2,$2,7
	sltu	$3,$3,$2
	bne	$3,$0,$L450
	slt	$2,$20,1025

	jal	del_timer
	addiu	$4,$17,-96

	beq	$2,$0,$L450
	slt	$2,$20,1025

	move	$4,$16
	move	$5,$19
	move	$6,$0
	li	$7,1			# 0x1
	jal	__drop_one_conntrack_process_hooks1
	sw	$23,16($sp)

	move	$3,$2
	li	$2,1			# 0x1
	beq	$3,$2,$L410
	li	$2,2			# 0x2

	beq	$3,$2,$L437
	move	$5,$19

	move	$4,$16
	move	$6,$0
	li	$7,1			# 0x1
	jal	__drop_one_conntrack_process_hooks2
	sw	$23,16($sp)

	slt	$2,$20,1025
$L450:
	beq	$2,$0,$L313
	move	$3,$0

$L263:
	lw	$17,0($17)
	j	$L436
	nop

$L410:
	jal	local_bh_enable
	nop

	jal	rtl_death_action
	move	$4,$16

$L437:
	j	$L313
	li	$3,1			# 0x1

$L257:
	lui	$2,%hi(Udp_State_Hash_Head)
	addiu	$2,$2,%lo(Udp_State_Hash_Head)
	addu	$2,$4,$2
	lw	$18,-84($2)
	lw	$4,0($18)
	beq	$4,$18,$L290
	li	$23,12			# 0xc

	move	$17,$4
	move	$20,$0
$L438:
	beq	$17,$18,$L290
	addiu	$16,$17,-204

	li	$12,-268435456			# 0xf0000000
	lw	$6,32($16)
	li	$11,-536870912			# 0xe0000000
	and	$2,$6,$12
	lhu	$7,28($16)
	lhu	$8,48($16)
	lhu	$9,76($16)
	lhu	$10,96($16)
	lw	$4,12($16)
	lw	$5,60($16)
	lw	$3,80($16)
	beq	$2,$11,$L294
	addiu	$20,$20,1

	and	$2,$3,$12
	beq	$2,$11,$L294
	nop

	bne	$4,$3,$L451
	sltu	$2,$7,1024

	beq	$6,$5,$L294
	nop

$L451:
	bne	$2,$0,$L294
	sltu	$2,$8,1024

	bne	$2,$0,$L294
	sltu	$2,$9,1024

	bne	$2,$0,$L294
	sltu	$2,$10,1024

	bne	$2,$0,$L294
	li	$2,8080			# 0x1f90

	beq	$7,$2,$L294
	nop

	beq	$8,$2,$L294
	nop

	beq	$9,$2,$L294
	nop

	beq	$10,$2,$L294
	lui	$2,%hi(jiffies)

	addiu	$3,$22,%lo(drop_priority)
	lw	$4,%lo(jiffies)($2)
	addu	$3,$21,$3
	lw	$2,116($16)
	lhu	$3,2($3)
	subu	$2,$2,$4
	srl	$2,$2,7
	sltu	$3,$3,$2
	bne	$3,$0,$L452
	slt	$2,$20,1025

	jal	del_timer
	addiu	$4,$17,-96

	beq	$2,$0,$L452
	slt	$2,$20,1025

	move	$4,$16
	move	$5,$19
	move	$6,$0
	li	$7,1			# 0x1
	jal	__drop_one_conntrack_process_hooks1
	sw	$23,16($sp)

	move	$3,$2
	li	$2,1			# 0x1
	beq	$3,$2,$L410
	li	$2,2			# 0x2

	beq	$3,$2,$L437
	move	$5,$19

	move	$4,$16
	move	$6,$0
	li	$7,1			# 0x1
	jal	__drop_one_conntrack_process_hooks2
	sw	$23,16($sp)

	slt	$2,$20,1025
$L452:
	beq	$2,$0,$L313
	move	$3,$0

$L294:
	lw	$17,0($17)
	j	$L438
	nop

$L290:
	move	$3,$0
$L313:
	li	$2,1			# 0x1
	beq	$3,$2,$L250
	addiu	$19,$19,1

	sltu	$2,$19,10
	bne	$2,$0,$L453
	lui	$22,%hi(drop_priority)

	jal	local_bh_enable
	move	$19,$0

	jal	local_bh_disable
	lui	$22,%hi(drop_priority)

$L458:
	sll	$21,$19,2
	addiu	$2,$22,%lo(drop_priority)
	addu	$2,$21,$2
	lbu	$2,0($2)
	sltu	$3,$2,10
	beq	$3,$0,$L327
	sll	$4,$2,3

	lui	$2,%hi(Tcp_State_Hash_Head)
	addiu	$2,$2,%lo(Tcp_State_Hash_Head)
	addu	$2,$4,$2
	lw	$18,4($2)
	lw	$4,0($18)
	beq	$4,$18,$L360
	li	$23,3			# 0x3

	move	$17,$4
	move	$20,$0
$L439:
	beq	$17,$18,$L360
	addiu	$16,$17,-204

	li	$12,-268435456			# 0xf0000000
	lw	$6,32($16)
	li	$11,-536870912			# 0xe0000000
	and	$2,$6,$12
	lhu	$7,28($16)
	lhu	$8,48($16)
	lhu	$9,76($16)
	lhu	$10,96($16)
	lw	$4,12($16)
	lw	$5,60($16)
	lw	$3,80($16)
	beq	$2,$11,$L333
	addiu	$20,$20,1

	and	$2,$3,$12
	beq	$2,$11,$L333
	nop

	bne	$4,$3,$L454
	sltu	$2,$7,1024

	beq	$6,$5,$L333
	nop

$L454:
	bne	$2,$0,$L333
	sltu	$2,$8,1024

	bne	$2,$0,$L333
	sltu	$2,$9,1024

	bne	$2,$0,$L333
	sltu	$2,$10,1024

	bne	$2,$0,$L333
	li	$2,8080			# 0x1f90

	beq	$7,$2,$L333
	nop

	beq	$8,$2,$L333
	nop

	beq	$9,$2,$L333
	nop

	beq	$10,$2,$L333
	lui	$2,%hi(jiffies)

	addiu	$3,$22,%lo(drop_priority)
	lw	$4,%lo(jiffies)($2)
	addu	$3,$21,$3
	lw	$2,116($16)
	lhu	$3,2($3)
	subu	$2,$2,$4
	srl	$2,$2,9
	sltu	$3,$3,$2
	bne	$3,$0,$L455
	slt	$2,$20,1025

	jal	del_timer
	addiu	$4,$17,-96

	beq	$2,$0,$L455
	slt	$2,$20,1025

	move	$4,$16
	move	$5,$19
	li	$6,2			# 0x2
	move	$7,$0
	jal	__drop_one_conntrack_process_hooks1
	sw	$23,16($sp)

	move	$3,$2
	li	$2,1			# 0x1
	beq	$3,$2,$L415
	li	$2,2			# 0x2

	beq	$3,$2,$L440
	move	$5,$19

	move	$4,$16
	li	$6,2			# 0x2
	move	$7,$0
	jal	__drop_one_conntrack_process_hooks2
	sw	$23,16($sp)

	slt	$2,$20,1025
$L455:
	beq	$2,$0,$L383
	move	$3,$0

$L333:
	lw	$17,0($17)
	j	$L439
	nop

$L415:
	jal	local_bh_enable
	nop

	jal	rtl_death_action
	move	$4,$16

$L440:
	j	$L383
	li	$3,1			# 0x1

$L327:
	lui	$2,%hi(Udp_State_Hash_Head)
	addiu	$2,$2,%lo(Udp_State_Hash_Head)
	addu	$2,$4,$2
	lw	$18,-84($2)
	lw	$4,0($18)
	beq	$4,$18,$L360
	li	$23,12			# 0xc

	move	$17,$4
	move	$20,$0
$L441:
	beq	$17,$18,$L360
	addiu	$16,$17,-204

	li	$12,-268435456			# 0xf0000000
	lw	$6,32($16)
	li	$11,-536870912			# 0xe0000000
	and	$2,$6,$12
	lhu	$7,28($16)
	lhu	$8,48($16)
	lhu	$9,76($16)
	lhu	$10,96($16)
	lw	$4,12($16)
	lw	$5,60($16)
	lw	$3,80($16)
	beq	$2,$11,$L364
	addiu	$20,$20,1

	and	$2,$3,$12
	beq	$2,$11,$L364
	nop

	bne	$4,$3,$L456
	sltu	$2,$7,1024

	beq	$6,$5,$L364
	nop

$L456:
	bne	$2,$0,$L364
	sltu	$2,$8,1024

	bne	$2,$0,$L364
	sltu	$2,$9,1024

	bne	$2,$0,$L364
	sltu	$2,$10,1024

	bne	$2,$0,$L364
	li	$2,8080			# 0x1f90

	beq	$7,$2,$L364
	nop

	beq	$8,$2,$L364
	nop

	beq	$9,$2,$L364
	nop

	beq	$10,$2,$L364
	lui	$2,%hi(jiffies)

	addiu	$3,$22,%lo(drop_priority)
	lw	$4,%lo(jiffies)($2)
	addu	$3,$21,$3
	lw	$2,116($16)
	lhu	$3,2($3)
	subu	$2,$2,$4
	srl	$2,$2,9
	sltu	$3,$3,$2
	bne	$3,$0,$L457
	slt	$2,$20,1025

	jal	del_timer
	addiu	$4,$17,-96

	beq	$2,$0,$L457
	slt	$2,$20,1025

	move	$4,$16
	move	$5,$19
	li	$6,2			# 0x2
	move	$7,$0
	jal	__drop_one_conntrack_process_hooks1
	sw	$23,16($sp)

	move	$3,$2
	li	$2,1			# 0x1
	beq	$3,$2,$L415
	li	$2,2			# 0x2

	beq	$3,$2,$L440
	move	$5,$19

	move	$4,$16
	li	$6,2			# 0x2
	move	$7,$0
	jal	__drop_one_conntrack_process_hooks2
	sw	$23,16($sp)

	slt	$2,$20,1025
$L457:
	beq	$2,$0,$L383
	move	$3,$0

$L364:
	lw	$17,0($17)
	j	$L441
	nop

$L360:
	move	$3,$0
$L383:
	li	$2,1			# 0x1
	beq	$3,$2,$L250
	addiu	$19,$19,1

	sltu	$2,$19,10
	bne	$2,$0,$L458
	lui	$22,%hi(drop_priority)

	j	$L433
	nop

$L250:
	lui	$4,%hi(rtl_newGC_session_status_flags)
$L443:
	lw	$2,%lo(rtl_newGC_session_status_flags)($4)
	bne	$2,$0,$L391
	nop

	lui	$2,%hi(jiffies)
	lw	$3,%lo(jiffies)($2)
	li	$2,3			# 0x3
	sw	$2,%lo(rtl_newGC_session_status_flags)($4)
	lui	$2,%hi(rtl_newGC_session_status_time)
	addiu	$3,$3,1
	sw	$3,%lo(rtl_newGC_session_status_time)($2)
$L391:
	j	$L154
	li	$2,1			# 0x1

$L433:
	jal	local_bh_enable
	nop

	lui	$4,%hi(rtl_newGC_session_status_flags)
	lw	$2,%lo(rtl_newGC_session_status_flags)($4)
	li	$3,1			# 0x1
	beq	$2,$3,$L393
	lui	$2,%hi(jiffies)

	lw	$2,%lo(jiffies)($2)
	sw	$3,%lo(rtl_newGC_session_status_flags)($4)
	lui	$3,%hi(rtl_newGC_session_status_time)
	addiu	$2,$2,200
	sw	$2,%lo(rtl_newGC_session_status_time)($3)
$L393:
	move	$2,$0
$L154:
	lw	$31,56($sp)
	lw	$23,52($sp)
	lw	$22,48($sp)
	lw	$21,44($sp)
	lw	$20,40($sp)
	lw	$19,36($sp)
	lw	$18,32($sp)
	lw	$17,28($sp)
	lw	$16,24($sp)
	j	$31
	addiu	$sp,$sp,64

	.set	macro
	.set	reorder
	.end	drop_one_conntrack
	.section	.text.rtl_nf_conn_GC_init,"ax",@progbits
	.align	2
	.globl	rtl_nf_conn_GC_init
	.ent	rtl_nf_conn_GC_init
	.type	rtl_nf_conn_GC_init, @function
rtl_nf_conn_GC_init:
	.set	nomips16
	.frame	$sp,24,$31		# vars= 0, regs= 2/0, args= 16, gp= 0
	.mask	0x80010000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	lui	$2,%hi(Tcp_State_Hash_Head)
	addiu	$sp,$sp,-24
	addiu	$2,$2,%lo(Tcp_State_Hash_Head)
	li	$5,10			# 0xa
	sw	$31,20($sp)
	addiu	$2,$2,4
	sw	$16,16($sp)
$L465:
	lw	$3,0($2)
	addiu	$5,$5,-1
	beq	$3,$0,$L462
	addiu	$2,$2,8

	sw	$3,4($3)
	sw	$3,0($3)
$L462:
	bgez	$5,$L465
	nop

	lui	$2,%hi(Udp_State_Hash_Head)
	li	$5,1			# 0x1
	addiu	$2,$2,%lo(Udp_State_Hash_Head)
	addiu	$2,$2,4
$L471:
	lw	$3,0($2)
	addiu	$5,$5,-1
	beq	$3,$0,$L468
	addiu	$2,$2,8

	sw	$3,4($3)
	sw	$3,0($3)
$L468:
	bgez	$5,$L471
	lui	$16,%hi(prot_limit)

	move	$5,$0
	li	$6,12			# 0xc
	jal	memset
	addiu	$4,$16,%lo(prot_limit)

	lui	$2,%hi(prot_counters)
	addiu	$7,$2,%lo(prot_counters)
	lui	$2,%hi(_prot_limit)
	addiu	$6,$2,%lo(_prot_limit)
	move	$5,$0
	sll	$2,$5,2
$L494:
	addiu	$5,$5,1
	addu	$4,$2,$6
	slt	$3,$5,3
	addu	$2,$2,$7
	sw	$0,0($2)
	sw	$0,0($4)
	bne	$3,$0,$L494
	sll	$2,$5,2

	lui	$2,%hi(nf_conntrack_max)
	addiu	$3,$16,%lo(prot_limit)
	lw	$6,%lo(nf_conntrack_max)($2)
	lui	$2,%hi(_prot_limit)
	addiu	$10,$2,%lo(_prot_limit)
	li	$2,2			# 0x2
	sw	$2,%lo(prot_limit)($16)
	li	$2,90			# 0x5a
	sw	$2,4($3)
	li	$2,1374355456			# 0x51eb0000
	lui	$7,%hi(rtl_newGC_session_status_flags)
	ori	$8,$2,0x851f
	li	$2,60			# 0x3c
	move	$9,$3
	sw	$2,8($3)
	move	$5,$0
	sw	$0,%lo(rtl_newGC_session_status_flags)($7)
	sll	$3,$5,2
$L495:
	addiu	$5,$5,1
	addu	$2,$3,$9
	slt	$4,$5,3
	lw	$2,0($2)
	addu	$3,$3,$10
	mult	$6,$2
	mflo	$2
	multu	$2,$8
	mfhi	$2
	srl	$2,$2,5
	sw	$2,0($3)
	bne	$4,$0,$L495
	sll	$3,$5,2

	li	$3,-859045888			# 0xcccc0000
	sll	$2,$6,2
	ori	$3,$3,0xcccd
	lui	$4,%hi(rtl_nf_conntrack_threshold)
	multu	$2,$3
	mfhi	$2
	srl	$2,$2,2
	subu	$3,$6,$2
	sltu	$3,$3,65
	bne	$3,$0,$L481
	sw	$2,%lo(rtl_nf_conntrack_threshold)($4)

	addiu	$2,$6,-64
	sw	$2,%lo(rtl_nf_conntrack_threshold)($4)
$L481:
	lui	$2,%hi(nf_conntrack_max)
	lw	$2,%lo(nf_conntrack_max)($2)
	beq	$2,$0,$L482
	lui	$2,%hi(init_net+468)

	lw	$3,%lo(init_net+468)($2)
	lw	$2,%lo(rtl_nf_conntrack_threshold)($4)
	slt	$2,$2,$3
	beq	$2,$0,$L482
	li	$3,3			# 0x3

	lw	$2,%lo(rtl_newGC_session_status_flags)($7)
	beq	$2,$3,$L485
	lui	$2,%hi(jiffies)

	lw	$2,%lo(jiffies)($2)
	sw	$3,%lo(rtl_newGC_session_status_flags)($7)
	lui	$3,%hi(rtl_newGC_session_status_time)
	addiu	$2,$2,1
	j	$L485
	sw	$2,%lo(rtl_newGC_session_status_time)($3)

$L482:
	sw	$0,%lo(rtl_newGC_session_status_flags)($7)
$L485:
	jal	rtl_nf_conn_GC_init_hooks
	nop

	move	$2,$0
	lw	$31,20($sp)
	lw	$16,16($sp)
	j	$31
	addiu	$sp,$sp,24

	.set	macro
	.set	reorder
	.end	rtl_nf_conn_GC_init
	.globl	rtl_nf_conntrack_threshold
	.section	.bss
	.align	2
	.type	rtl_nf_conntrack_threshold, @object
	.size	rtl_nf_conntrack_threshold, 4
rtl_nf_conntrack_threshold:
	.space	4
	.globl	rtl_newGC_session_status_flags
	.section	.dram-fwd,"aw",@progbits
	.align	2
	.type	rtl_newGC_session_status_flags, @object
	.size	rtl_newGC_session_status_flags, 4
rtl_newGC_session_status_flags:
	.space	4
	.globl	rtl_newGC_session_status_time
	.align	2
	.type	rtl_newGC_session_status_time, @object
	.size	rtl_newGC_session_status_time, 4
rtl_newGC_session_status_time:
	.space	4
	.globl	prot_limit
	.section	.bss
	.align	2
	.type	prot_limit, @object
	.size	prot_limit, 12
prot_limit:
	.space	12
	.local	prot_counters
	.comm	prot_counters,12,4
	.local	_prot_limit
	.comm	_prot_limit,12,4
	.ident	"GCC: (GNU) 3.4.6-1.3.6"
