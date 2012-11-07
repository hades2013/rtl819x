	.file	1 "fastpath_core.c"
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
	.section	.text.arp_req_get_ha,"ax",@progbits
	.align	2
	.globl	arp_req_get_ha
	.ent	arp_req_get_ha
	.type	arp_req_get_ha, @function
arp_req_get_ha:
	.set	nomips16
	.frame	$sp,48,$31		# vars= 8, regs= 5/0, args= 16, gp= 0
	.mask	0x800f0000,-8
	.fmask	0x00000000,0
	addiu	$sp,$sp,-48
	sw	$18,32($sp)
	move	$18,$5
	sw	$4,16($sp)
	lui	$4,%hi(arp_tbl)
	sw	$19,36($sp)
	addiu	$4,$4,%lo(arp_tbl)
	move	$19,$6
	addiu	$5,$sp,16
	move	$6,$18
	sw	$17,28($sp)
	sw	$16,24($sp)
	sw	$31,40($sp)
	.set	noreorder
	.set	nomacro
	jal	neigh_lookup
	li	$17,-6			# 0xfffffffa
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L2
	move	$16,$2
	.set	macro
	.set	reorder

	jal	local_bh_disable
	move	$4,$19
	lbu	$6,256($18)
	.set	noreorder
	.set	nomacro
	jal	memcpy
	addiu	$5,$16,36
	.set	macro
	.set	reorder

	jal	local_bh_enable
#APP
	   

	1:	ll	$3, 72($16)		# atomic_sub_return	
       nop                                             
	subu	$2, $3, 1				
	sc	$2, 72($16)					
	beqz	$2, 2f					
	subu	$2, $3, 1				
	.subsection 2					
2:	b	1b					
	.previous					

	   

#NO_APP
	move	$17,$0
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L2
	move	$4,$16
	.set	macro
	.set	reorder

	jal	neigh_destroy
$L2:
	move	$2,$17
	lw	$31,40($sp)
	lw	$19,36($sp)
	lw	$18,32($sp)
	lw	$17,28($sp)
	lw	$16,24($sp)
	.set	noreorder
	.set	nomacro
	j	$31
	addiu	$sp,$sp,48
	.set	macro
	.set	reorder

	.end	arp_req_get_ha
	.section	.text.cache_timeout,"ax",@progbits
	.align	2
	.ent	cache_timeout
	.type	cache_timeout, @function
cache_timeout:
	.set	nomips16
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	lbu	$2,0($4)
	beq	$2,$0,$L19
	move	$7,$4

	lw	$2,8($4)
	lw	$3,4($4)
	lhu	$4,2($4)
	xor	$3,$3,$2
	srl	$2,$3,16
	xor	$2,$2,$4
	xor	$3,$3,$2
	lui	$2,%hi(max_udp_frag_entry)
	lbu	$5,1($7)
	srl	$4,$3,8
	lw	$2,%lo(max_udp_frag_entry)($2)
	xor	$4,$4,$5
	xor	$3,$3,$4
	addiu	$2,$2,-1
	and	$4,$3,$2
	sll	$2,$4,1
	lw	$6,40($7)
	addu	$2,$2,$4
	sb	$0,0($7)
	lw	$3,44($7)
	beq	$6,$0,$L15
	sll	$5,$2,2

	j	$L16
	sw	$3,44($6)

$L15:
	lui	$2,%hi(udp_cache_table)
	lw	$2,%lo(udp_cache_table)($2)
	lw	$2,0($2)
	addu	$2,$5,$2
	sw	$3,4($2)
$L16:
	lw	$2,40($7)
	sll	$3,$4,1
	lw	$5,44($7)
	addu	$3,$3,$4
	sll	$3,$3,2
	lui	$4,%hi(udp_cache_list_free)
	sw	$2,0($5)
	lui	$2,%hi(udp_cache_table)
	lw	$2,%lo(udp_cache_table)($2)
	addiu	$4,$4,%lo(udp_cache_list_free)
	addiu	$6,$7,48
	lw	$2,0($2)
	addu	$3,$3,$2
	lw	$2,8($3)
	addiu	$2,$2,-1
	sw	$2,8($3)
	sw	$0,48($7)
	lw	$2,4($4)
	sw	$2,52($7)
	lw	$2,4($4)
	sw	$7,0($2)
	lw	$2,8($4)
	sw	$6,4($4)
	addiu	$2,$2,1
	sw	$2,8($4)
$L19:
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	cache_timeout
	.section	.text.udp_fragCache_init,"ax",@progbits
	.align	2
	.globl	udp_fragCache_init
	.ent	udp_fragCache_init
	.type	udp_fragCache_init, @function
udp_fragCache_init:
	.set	nomips16
	.frame	$sp,56,$31		# vars= 16, regs= 6/0, args= 16, gp= 0
	.mask	0x801f0000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
$L25:
$L66:
	addiu	$sp,$sp,-56
	lui	$2,%hi(malloc_sizes+4)
	sw	$19,44($sp)
	move	$19,$4
	sw	$18,40($sp)
	li	$5,32			# 0x20
	sw	$17,36($sp)
	sw	$16,32($sp)
	lui	$16,%hi(udp_cache_table)
	sw	$31,52($sp)
	sw	$20,48($sp)
	lw	$4,%lo(malloc_sizes+4)($2)
	jal	kmem_cache_alloc
	move	$18,$16

	move	$3,$0
	move	$17,$2
	beq	$2,$0,$L20
	sw	$2,%lo(udp_cache_table)($16)

$L75:
$L116:
	lui	$20,%hi(udp_cache_list_free)
	sll	$4,$19,1
	addiu	$3,$20,%lo(udp_cache_list_free)
	addu	$4,$4,$19
	sw	$3,4($3)
	lui	$2,%hi(max_udp_frag_entry)
	sw	$0,8($3)
	sll	$4,$4,2
	li	$5,32			# 0x20
	sw	$19,%lo(max_udp_frag_entry)($2)
	jal	__kmalloc
	sw	$0,%lo(udp_cache_list_free)($20)

	sw	$2,0($17)
	lw	$2,%lo(udp_cache_table)($16)
	lw	$2,0($2)
	beq	$2,$0,$L20
	li	$3,-1			# 0xffffffff

	j	$L119
	slt	$5,$0,$19

$L183:
	j	$L20
	move	$3,$0

$L119:
	beq	$5,$0,$L182
	move	$17,$0

	move	$4,$0
$L124:
	lw	$2,%lo(udp_cache_table)($18)
	addiu	$17,$17,1
	slt	$3,$17,$19
	lw	$2,0($2)
	addu	$2,$4,$2
	sw	$0,8($2)
	lw	$2,%lo(udp_cache_table)($18)
	lw	$2,0($2)
	addu	$2,$4,$2
	sw	$0,0($2)
	lw	$2,%lo(udp_cache_table)($18)
	lw	$2,0($2)
	addu	$2,$4,$2
	addiu	$4,$4,12
	bne	$3,$0,$L124
	sw	$2,4($2)

	move	$17,$0
$L184:
	beq	$5,$0,$L182
	lui	$2,%hi(malloc_sizes+12)

$L132:
$L173:
	li	$5,32			# 0x20
	lw	$4,%lo(malloc_sizes+12)($2)
	jal	kmem_cache_alloc
	addiu	$17,$17,1

	move	$5,$0
	move	$16,$2
	addiu	$4,$2,16
	beq	$2,$0,$L183
	move	$6,$0

	jal	init_timer_key
	nop

	lui	$2,%hi(cache_timeout)
	addiu	$2,$2,%lo(cache_timeout)
	addiu	$3,$20,%lo(udp_cache_list_free)
	sw	$2,28($16)
	addiu	$4,$16,48
	sw	$16,32($16)
	slt	$5,$17,$19
	sw	$0,48($16)
	lw	$2,4($3)
	sw	$2,52($16)
	lw	$2,4($3)
	sw	$16,0($2)
	lw	$2,8($3)
	sw	$4,4($3)
	addiu	$2,$2,1
	j	$L184
	sw	$2,8($3)

$L182:
	li	$3,1			# 0x1
$L20:
	lw	$31,52($sp)
	move	$2,$3
	lw	$20,48($sp)
	lw	$19,44($sp)
	lw	$18,40($sp)
	lw	$17,36($sp)
	lw	$16,32($sp)
	j	$31
	addiu	$sp,$sp,56

	.set	macro
	.set	reorder
	.end	udp_fragCache_init
	.section	.text.FastPath_Hash_NAPT_Entry,"ax",@progbits
	.align	2
	.ent	FastPath_Hash_NAPT_Entry
	.type	FastPath_Hash_NAPT_Entry, @function
FastPath_Hash_NAPT_Entry:
	.set	nomips16
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	srl	$3,$4,16
	srl	$2,$6,16
	xor	$2,$2,$6
	xor	$3,$3,$4
	xor	$3,$3,$2
	lui	$2,%hi(napt_table_list_max)
	lhu	$4,18($sp)
	xor	$3,$3,$5
	xor	$3,$3,$7
	lw	$2,%lo(napt_table_list_max)($2)
	xor	$3,$3,$4
	srl	$4,$3,12
	xor	$3,$3,$4
	addiu	$2,$2,-1
	j	$31
	and	$2,$2,$3

	.set	macro
	.set	reorder
	.end	FastPath_Hash_NAPT_Entry
	.section	.text.rtk_addArp,"ax",@progbits
	.align	2
	.globl	rtk_addArp
	.ent	rtk_addArp
	.type	rtk_addArp, @function
rtk_addArp:
	.set	nomips16
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	j	$31
	move	$2,$0

	.set	macro
	.set	reorder
	.end	rtk_addArp
	.section	.text.rtk_modifyArp,"ax",@progbits
	.align	2
	.globl	rtk_modifyArp
	.ent	rtk_modifyArp
	.type	rtk_modifyArp, @function
rtk_modifyArp:
	.set	nomips16
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	j	$31
	move	$2,$0

	.set	macro
	.set	reorder
	.end	rtk_modifyArp
	.section	.text.rtk_delArp,"ax",@progbits
	.align	2
	.globl	rtk_delArp
	.ent	rtk_delArp
	.type	rtk_delArp, @function
rtk_delArp:
	.set	nomips16
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	j	$31
	li	$2,-4			# 0xfffffffc

	.set	macro
	.set	reorder
	.end	rtk_delArp
	.section	.text.rtk_addRoute,"ax",@progbits
	.align	2
	.globl	rtk_addRoute
	.ent	rtk_addRoute
	.type	rtk_addRoute, @function
rtk_addRoute:
	.set	nomips16
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	j	$31
	move	$2,$0

	.set	macro
	.set	reorder
	.end	rtk_addRoute
	.section	.text.rtk_modifyRoute,"ax",@progbits
	.align	2
	.globl	rtk_modifyRoute
	.ent	rtk_modifyRoute
	.type	rtk_modifyRoute, @function
rtk_modifyRoute:
	.set	nomips16
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	j	$31
	move	$2,$0

	.set	macro
	.set	reorder
	.end	rtk_modifyRoute
	.section	.text.rtk_delRoute,"ax",@progbits
	.align	2
	.globl	rtk_delRoute
	.ent	rtk_delRoute
	.type	rtk_delRoute, @function
rtk_delRoute:
	.set	nomips16
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	j	$31
	li	$2,-4			# 0xfffffffc

	.set	macro
	.set	reorder
	.end	rtk_delRoute
	.section	.text.rtk_addSession,"ax",@progbits
	.align	2
	.globl	rtk_addSession
	.ent	rtk_addSession
	.type	rtk_addSession, @function
rtk_addSession:
	.set	nomips16
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	j	$31
	move	$2,$0

	.set	macro
	.set	reorder
	.end	rtk_addSession
	.section	.text.rtk_delSession,"ax",@progbits
	.align	2
	.globl	rtk_delSession
	.ent	rtk_delSession
	.type	rtk_delSession, @function
rtk_delSession:
	.set	nomips16
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	j	$31
	move	$2,$0

	.set	macro
	.set	reorder
	.end	rtk_delSession
	.section	.text.FastPath_Route,"ax",@progbits
	.align	2
	.globl	FastPath_Route
	.ent	FastPath_Route
	.type	FastPath_Route, @function
FastPath_Route:
	.set	nomips16
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	lui	$2,%hi(route_list_inuse)
	move	$8,$0
	lw	$3,%lo(route_list_inuse)($2)
	move	$7,$0
$L202:
	beq	$3,$0,$L201
	nop

	lw	$5,8($3)
	sltu	$2,$5,$7
	bne	$2,$0,$L197
	and	$6,$4,$5

	lw	$2,4($3)
	bne	$6,$2,$L197
	nop

	move	$7,$5
	addiu	$8,$3,16
$L197:
	lw	$3,44($3)
	j	$L202
	nop

$L201:
	j	$31
	move	$2,$8

	.set	macro
	.set	reorder
	.end	FastPath_Route
	.section	.text.rtk_addNaptConnection,"ax",@progbits
	.align	2
	.globl	rtk_addNaptConnection
	.ent	rtk_addNaptConnection
	.type	rtk_addNaptConnection, @function
rtk_addNaptConnection:
	.set	nomips16
	.frame	$sp,152,$31		# vars= 88, regs= 10/0, args= 24, gp= 0
	.mask	0xc0ff0000,-4
	.fmask	0x00000000,0
	addiu	$sp,$sp,-152
	li	$2,-1			# 0xffffffff
	sw	$23,140($sp)
	move	$23,$7
	sw	$18,120($sp)
	move	$18,$5
	sw	$17,116($sp)
	move	$17,$4
	sw	$31,148($sp)
	sw	$fp,144($sp)
	sw	$22,136($sp)
	sw	$21,132($sp)
	sw	$20,128($sp)
	sw	$19,124($sp)
	sw	$16,112($sp)
	.set	noreorder
	.set	nomacro
	beq	$5,$0,$L203
	sw	$6,160($sp)
	.set	macro
	.set	reorder

	lw	$3,0($4)
	li	$2,17			# 0x11
	lw	$4,20($4)
	li	$5,6			# 0x6
	xori	$3,$3,0x2
	movn	$5,$2,$3		#conditional move  
	.set	noreorder
	.set	nomacro
	jal	filter_addconnect
	sw	$5,72($sp)
	.set	macro
	.set	reorder

	lw	$22,0($17)
	lw	$21,4($17)
	lw	$20,8($17)
	andi	$2,$22,0xffff
	lw	$19,20($17)
	move	$4,$21
	lw	$16,24($17)
	move	$5,$20
	sw	$2,16($sp)
	move	$6,$19
	.set	noreorder
	.set	nomacro
	jal	FastPath_Hash_NAPT_Entry
	move	$7,$16
	.set	macro
	.set	reorder

	lui	$9,%hi(table_napt)
	lw	$3,%lo(table_napt)($9)
	sll	$7,$2,1
	move	$fp,$2
	addu	$2,$7,$2
	lw	$3,0($3)
	sll	$2,$2,2
	addu	$2,$2,$3
	lw	$4,0($2)
$L333:
	beq	$4,$0,$L331
	lw	$2,4($4)
	bne	$2,$22,$L209
	lw	$2,8($4)
	bne	$2,$21,$L209
	lw	$2,12($4)
	bne	$2,$20,$L209
	lw	$3,16($4)
	lw	$2,12($17)
	bne	$3,$2,$L209
	lw	$3,20($4)
	lw	$2,16($17)
	bne	$3,$2,$L209
	lw	$2,24($4)
	bne	$2,$19,$L209
	lw	$2,28($4)
	.set	noreorder
	.set	nomacro
	beq	$2,$16,$L323
	move	$2,$0
	.set	macro
	.set	reorder

$L209:
	lw	$4,36($4)
	j	$L333
$L331:
#APP
	raw_local_irq_save	$2
#NO_APP
	lui	$5,%hi(napt_list_free)
	lw	$8,%lo(napt_list_free)($5)
	.set	noreorder
	.set	nomacro
	beq	$8,$0,$L213
	sw	$2,76($sp)
	.set	macro
	.set	reorder

	lw	$2,0($17)
	lw	$4,44($8)
	sw	$2,4($8)
	lw	$2,4($17)
	lw	$3,48($8)
	sw	$2,8($8)
	lw	$2,8($17)
	sw	$2,12($8)
	lw	$2,12($17)
	sw	$2,16($8)
	lw	$2,16($17)
	sw	$2,20($8)
	lw	$2,20($17)
	sw	$2,24($8)
	lw	$2,24($17)
	sw	$23,32($8)
	sw	$2,28($8)
	li	$2,-1
	.set	noreorder
	.set	nomacro
	beq	$4,$0,$L215
	sb	$2,0($8)
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	j	$L216
	sw	$3,48($4)
	.set	macro
	.set	reorder

$L215:
	addiu	$2,$5,%lo(napt_list_free)
	sw	$3,4($2)
$L216:
	lw	$4,48($8)
	addiu	$5,$5,%lo(napt_list_free)
	lw	$2,44($8)
	lui	$3,%hi(napt_list_inuse)
	addiu	$3,$3,%lo(napt_list_inuse)
	addiu	$6,$8,44
	sw	$2,0($4)
	addu	$4,$7,$fp
	lw	$2,8($5)
	sll	$4,$4,2
	addiu	$7,$8,36
	addiu	$2,$2,-1
	sw	$2,8($5)
	sw	$0,44($8)
	lw	$2,4($3)
	sw	$2,48($8)
	lw	$2,4($3)
	sw	$8,0($2)
	lw	$2,8($3)
	sw	$6,4($3)
	addiu	$2,$2,1
	sw	$2,8($3)
	sw	$0,36($8)
	lw	$2,%lo(table_napt)($9)
	lw	$2,0($2)
	addu	$2,$4,$2
	lw	$2,4($2)
	sw	$2,40($8)
	lw	$2,%lo(table_napt)($9)
	lw	$2,0($2)
	addu	$2,$4,$2
	lw	$2,4($2)
	sw	$8,0($2)
	lw	$2,%lo(table_napt)($9)
	lw	$2,0($2)
	addu	$2,$4,$2
	sw	$7,4($2)
	lw	$2,%lo(table_napt)($9)
	lw	$2,0($2)
	addu	$4,$4,$2
	lw	$2,8($4)
	addiu	$2,$2,1
	sw	$2,8($4)
	li	$2,33
	sb	$2,57($sp)
	li	$2,8
	sb	$2,64($sp)
	sb	$0,56($sp)
	.set	noreorder
	.set	nomacro
	jal	rtl865x_getLanDev
	sb	$0,65($sp)
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	rtl865x_getWanDev
	move	$19,$2
	.set	macro
	.set	reorder

	addiu	$4,$sp,24
	lw	$22,152($18)
	move	$20,$2
	lw	$5,156($18)
	li	$6,6			# 0x6
	lbu	$2,0($22)
	lhu	$3,106($18)
	addiu	$5,$5,6
	andi	$2,$2,0xf
	sll	$2,$2,2
	addu	$23,$22,$2
	.set	noreorder
	.set	nomacro
	jal	memcpy
	sw	$3,100($sp)
	.set	macro
	.set	reorder

	addiu	$4,$sp,32
	lw	$5,156($18)
	.set	noreorder
	.set	nomacro
	jal	memcpy
	li	$6,6			# 0x6
	.set	macro
	.set	reorder

	lw	$4,12($22)
	sw	$4,80($sp)
	lhu	$5,0($23)
	sw	$5,88($sp)
	lw	$2,16($22)
	sw	$2,84($sp)
	lhu	$3,2($23)
	sw	$3,92($sp)
	lw	$4,28($18)
	sw	$4,96($sp)
	sw	$0,28($18)
	lw	$5,4($17)
	lw	$6,20($17)
	lw	$4,8($17)
	srl	$2,$5,8
	srl	$3,$6,16
	xor	$2,$2,$5
	xor	$3,$3,$6
	srl	$4,$4,4
	lw	$5,24($17)
	xor	$2,$2,$3
	xor	$2,$2,$4
	lui	$4,%hi(path_table_list_max)
	xor	$2,$2,$5
	lw	$5,72($sp)
	lw	$3,%lo(path_table_list_max)($4)
	xor	$2,$2,$5
	lui	$5,%hi(path_list_free)
	srl	$4,$2,12
	addiu	$3,$3,-1
	xor	$2,$2,$4
	and	$fp,$3,$2
	lw	$16,%lo(path_list_free)($5)
	lw	$2,140($18)
	.set	noreorder
	.set	nomacro
	beq	$16,$0,$L226
	sw	$2,104($sp)
	.set	macro
	.set	reorder

	lw	$2,0($17)
	sw	$2,4($16)
	lw	$2,4($17)
	sw	$2,16($16)
	lw	$2,8($17)
	sw	$2,12($16)
	lw	$2,20($17)
	sw	$2,20($16)
	lw	$2,24($17)
	sw	$2,8($16)
	lw	$2,12($17)
	sw	$2,24($16)
	lw	$2,16($17)
	sw	$2,28($16)
	lw	$4,20($17)
	sw	$4,32($16)
	lw	$2,24($17)
	.set	noreorder
	.set	nomacro
	jal	FastPath_Route
	sw	$2,36($16)
	.set	macro
	.set	reorder

	sw	$2,44($16)
	li	$2,1
	lw	$4,16($16)
	lw	$3,24($16)
	sb	$2,2($16)
	li	$2,-1
	sb	$2,0($16)
	.set	noreorder
	.set	nomacro
	beq	$4,$3,$L227
	sb	$0,1($16)
	.set	macro
	.set	reorder

	li	$2,1			# 0x1
	sb	$2,1($16)
$L227:
	lw	$3,12($16)
	lw	$2,28($16)
	beq	$3,$2,$L228
	lbu	$2,1($16)
	ori	$2,$2,0x2
	sb	$2,1($16)
$L228:
	sw	$0,48($16)
	addiu	$21,$sp,40
	sw	$0,52($16)
	move	$4,$21
	lw	$2,4($17)
	move	$5,$0
	li	$6,14			# 0xe
	sw	$2,12($22)
	lw	$2,8($17)
	sh	$2,0($23)
	lw	$2,20($17)
	sw	$2,16($22)
	lw	$2,24($17)
	.set	noreorder
	.set	nomacro
	jal	memset
	sh	$2,2($23)
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	beq	$19,$0,$L229
	move	$5,$19
	.set	macro
	.set	reorder

	lw	$4,4($17)
	.set	noreorder
	.set	nomacro
	jal	arp_req_get_ha
	move	$6,$21
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L229
	addiu	$5,$sp,56
	.set	macro
	.set	reorder

	lw	$4,172($18)
	li	$6,2			# 0x2
	.set	noreorder
	.set	nomacro
	jal	memcmp
	addiu	$4,$4,-2
	.set	macro
	.set	reorder

	bne	$2,$0,$L230
	lw	$3,156($18)
	beq	$3,$0,$L230
	lbu	$2,12($3)
	lbu	$3,13($3)
	sll	$2,$2,8
	or	$3,$3,$2
	li	$2,2048			# 0x800
	beq	$3,$2,$L230
	lw	$2,172($18)
	addiu	$2,$2,-22
	sw	$2,156($18)
$L230:
	lw	$4,156($18)
	move	$5,$21
	li	$6,6			# 0x6
	.set	noreorder
	.set	nomacro
	jal	memcpy
	addiu	$4,$4,6
	.set	macro
	.set	reorder

	addiu	$5,$19,320
	lw	$4,156($18)
	.set	noreorder
	.set	nomacro
	jal	memcpy
	li	$6,6			# 0x6
	.set	macro
	.set	reorder

$L229:
	sw	$0,140($18)
	li	$2,2048			# 0x800
	lw	$3,100($sp)
	.set	noreorder
	.set	nomacro
	bne	$3,$2,$L239
	lui	$2,%hi(nf_hooks+128)
	.set	macro
	.set	reorder

	lw	$3,%lo(nf_hooks+128)($2)
	addiu	$2,$2,%lo(nf_hooks+128)
	.set	noreorder
	.set	nomacro
	beq	$3,$2,$L239
	lui	$2,%hi(init_net+204)
	.set	macro
	.set	reorder

	move	$4,$18
	lw	$2,%lo(init_net+204)($2)
	move	$5,$0
	move	$6,$19
	move	$7,$20
	.set	noreorder
	.set	nomacro
	jal	ipt_do_table
	sw	$2,16($sp)
	.set	macro
	.set	reorder

$L239:
	lw	$2,140($18)
	addiu	$21,$sp,40
	move	$4,$21
	move	$5,$0
	sw	$2,48($16)
	li	$6,14			# 0xe
	lw	$2,12($17)
	sw	$2,12($22)
	lw	$2,16($17)
	sh	$2,0($23)
	lw	$2,20($17)
	sw	$2,16($22)
	lw	$2,24($17)
	.set	noreorder
	.set	nomacro
	jal	memset
	sh	$2,2($23)
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	beq	$20,$0,$L244
	move	$5,$20
	.set	macro
	.set	reorder

	lw	$4,20($17)
	.set	noreorder
	.set	nomacro
	jal	arp_req_get_ha
	move	$6,$21
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L244
	addiu	$5,$sp,56
	.set	macro
	.set	reorder

	lw	$4,172($18)
	li	$6,2			# 0x2
	.set	noreorder
	.set	nomacro
	jal	memcmp
	addiu	$4,$4,-2
	.set	macro
	.set	reorder

	bne	$2,$0,$L245
	lw	$3,156($18)
	beq	$3,$0,$L245
	lbu	$2,12($3)
	lbu	$3,13($3)
	sll	$2,$2,8
	or	$3,$3,$2
	li	$2,2048			# 0x800
	beq	$3,$2,$L245
	lw	$2,172($18)
	addiu	$2,$2,-22
	sw	$2,156($18)
$L245:
	lw	$4,156($18)
	move	$5,$21
	.set	noreorder
	.set	nomacro
	jal	memcpy
	li	$6,6			# 0x6
	.set	macro
	.set	reorder

	addiu	$5,$20,320
	lw	$4,156($18)
	li	$6,6			# 0x6
	.set	noreorder
	.set	nomacro
	jal	memcpy
	addiu	$4,$4,6
	.set	macro
	.set	reorder

$L244:
	sw	$0,140($18)
	li	$2,2048			# 0x800
	lw	$4,100($sp)
	.set	noreorder
	.set	nomacro
	bne	$4,$2,$L254
	lui	$2,%hi(nf_hooks+160)
	.set	macro
	.set	reorder

	lw	$3,%lo(nf_hooks+160)($2)
	addiu	$2,$2,%lo(nf_hooks+160)
	.set	noreorder
	.set	nomacro
	beq	$3,$2,$L254
	lui	$2,%hi(init_net+204)
	.set	macro
	.set	reorder

	move	$4,$18
	lw	$2,%lo(init_net+204)($2)
	li	$5,4			# 0x4
	move	$6,$19
	move	$7,$20
	.set	noreorder
	.set	nomacro
	jal	ipt_do_table
	sw	$2,16($sp)
	.set	macro
	.set	reorder

$L254:
	lw	$2,140($18)
	sw	$2,52($16)
	li	$2,6			# 0x6
	lw	$5,72($sp)
	.set	noreorder
	.set	nomacro
	bne	$5,$2,$L259
	lui	$2,%hi(nf_ct_udp_timeout_stream)
	.set	macro
	.set	reorder

	lw	$2,160($sp)
	lbu	$4,176($2)
	jal	tcp_get_timeouts_by_state
	.set	noreorder
	.set	nomacro
	j	$L338
	sw	$2,60($16)
	.set	macro
	.set	reorder

$L259:
	lw	$2,%lo(nf_ct_udp_timeout_stream)($2)
	sw	$2,60($16)
$L338:
	lui	$2,%hi(jiffies)
	lw	$3,160($sp)
	lw	$4,76($16)
	sw	$3,56($16)
	lw	$2,%lo(jiffies)($2)
	lw	$3,72($16)
	.set	noreorder
	.set	nomacro
	beq	$3,$0,$L262
	sw	$2,40($16)
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	j	$L263
	sw	$4,76($3)
	.set	macro
	.set	reorder

$L262:
	lui	$5,%hi(path_list_free)
	addiu	$2,$5,%lo(path_list_free)
	sw	$4,4($2)
$L263:
	lw	$3,76($16)
	lui	$5,%hi(path_list_free)
	lw	$2,72($16)
	addiu	$5,$5,%lo(path_list_free)
	addiu	$7,$16,72
	lui	$6,%hi(table_path)
	sw	$2,0($3)
	lui	$3,%hi(path_list_inuse)
	lw	$2,8($5)
	addiu	$3,$3,%lo(path_list_inuse)
	sll	$4,$fp,1
	addiu	$8,$16,64
	addiu	$2,$2,-1
	addu	$4,$4,$fp
	sw	$2,8($5)
	sll	$4,$4,2
	sw	$0,72($16)
	lw	$2,4($3)
	sw	$2,76($16)
	lw	$2,4($3)
	sw	$16,0($2)
	lw	$2,8($3)
	sw	$7,4($3)
	addiu	$2,$2,1
	sw	$2,8($3)
	sw	$0,64($16)
	lw	$2,%lo(table_path)($6)
	lw	$2,0($2)
	addu	$2,$4,$2
	lw	$2,4($2)
	sw	$2,68($16)
	lw	$2,%lo(table_path)($6)
	lw	$2,0($2)
	addu	$2,$4,$2
	lw	$2,4($2)
	sw	$16,0($2)
	lw	$2,%lo(table_path)($6)
	lw	$2,0($2)
	addu	$2,$4,$2
	sw	$8,4($2)
	lw	$2,%lo(table_path)($6)
	lw	$2,0($2)
	addu	$4,$4,$2
	lw	$2,8($4)
	addiu	$2,$2,1
	sw	$2,8($4)
$L226:
	lw	$5,12($17)
	lw	$6,20($17)
	srl	$3,$5,16
	lw	$4,24($17)
	srl	$2,$6,8
	xor	$3,$3,$5
	xor	$2,$2,$6
	srl	$4,$4,4
	xor	$2,$2,$3
	lw	$5,16($17)
	xor	$2,$2,$4
	lui	$4,%hi(path_table_list_max)
	xor	$2,$2,$5
	lw	$5,72($sp)
	lw	$3,%lo(path_table_list_max)($4)
	xor	$2,$2,$5
	lui	$5,%hi(path_list_free)
	srl	$4,$2,12
	addiu	$3,$3,-1
	lw	$16,%lo(path_list_free)($5)
	xor	$2,$2,$4
	.set	noreorder
	.set	nomacro
	beq	$16,$0,$L267
	and	$fp,$3,$2
	.set	macro
	.set	reorder

	lw	$2,0($17)
	sw	$2,4($16)
	lw	$2,20($17)
	sw	$2,16($16)
	lw	$2,24($17)
	sw	$2,12($16)
	lw	$2,12($17)
	sw	$2,20($16)
	lw	$2,16($17)
	sw	$2,8($16)
	lw	$2,20($17)
	sw	$2,24($16)
	lw	$2,24($17)
	sw	$2,28($16)
	lw	$4,4($17)
	sw	$4,32($16)
	lw	$2,8($17)
	.set	noreorder
	.set	nomacro
	jal	FastPath_Route
	sw	$2,36($16)
	.set	macro
	.set	reorder

	sw	$2,44($16)
	li	$2,2
	lw	$4,20($16)
	lw	$3,32($16)
	sb	$2,2($16)
	li	$2,-1
	sb	$2,0($16)
	.set	noreorder
	.set	nomacro
	beq	$4,$3,$L268
	sb	$0,1($16)
	.set	macro
	.set	reorder

	li	$2,4			# 0x4
	sb	$2,1($16)
$L268:
	lw	$3,8($16)
	lw	$2,36($16)
	beq	$3,$2,$L269
	lbu	$2,1($16)
	ori	$2,$2,0x8
	sb	$2,1($16)
$L269:
	sw	$0,48($16)
	addiu	$21,$sp,40
	sw	$0,52($16)
	move	$4,$21
	lw	$2,20($17)
	move	$5,$0
	li	$6,14			# 0xe
	sw	$2,12($22)
	lw	$2,24($17)
	sh	$2,0($23)
	lw	$2,12($17)
	sw	$2,16($22)
	lw	$2,16($17)
	.set	noreorder
	.set	nomacro
	jal	memset
	sh	$2,2($23)
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	beq	$20,$0,$L270
	move	$5,$20
	.set	macro
	.set	reorder

	lw	$4,20($17)
	.set	noreorder
	.set	nomacro
	jal	arp_req_get_ha
	move	$6,$21
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L270
	addiu	$5,$sp,56
	.set	macro
	.set	reorder

	lw	$4,172($18)
	li	$6,2			# 0x2
	.set	noreorder
	.set	nomacro
	jal	memcmp
	addiu	$4,$4,-2
	.set	macro
	.set	reorder

	bne	$2,$0,$L271
	lw	$3,156($18)
	beq	$3,$0,$L271
	lbu	$2,12($3)
	lbu	$3,13($3)
	sll	$2,$2,8
	or	$3,$3,$2
	li	$2,2048			# 0x800
	beq	$3,$2,$L271
	lw	$2,172($18)
	addiu	$2,$2,-22
	sw	$2,156($18)
$L271:
	lw	$4,156($18)
	move	$5,$21
	li	$6,6			# 0x6
	.set	noreorder
	.set	nomacro
	jal	memcpy
	addiu	$4,$4,6
	.set	macro
	.set	reorder

	addiu	$5,$20,320
	lw	$4,156($18)
	.set	noreorder
	.set	nomacro
	jal	memcpy
	li	$6,6			# 0x6
	.set	macro
	.set	reorder

$L270:
	sw	$0,140($18)
	li	$2,2048			# 0x800
	lw	$3,100($sp)
	.set	noreorder
	.set	nomacro
	bne	$3,$2,$L280
	lui	$2,%hi(nf_hooks+128)
	.set	macro
	.set	reorder

	lw	$3,%lo(nf_hooks+128)($2)
	addiu	$2,$2,%lo(nf_hooks+128)
	.set	noreorder
	.set	nomacro
	beq	$3,$2,$L280
	lui	$2,%hi(init_net+204)
	.set	macro
	.set	reorder

	move	$4,$18
	lw	$2,%lo(init_net+204)($2)
	move	$5,$0
	move	$6,$20
	move	$7,$19
	.set	noreorder
	.set	nomacro
	jal	ipt_do_table
	sw	$2,16($sp)
	.set	macro
	.set	reorder

$L280:
	lw	$2,140($18)
	addiu	$21,$sp,40
	move	$4,$21
	move	$5,$0
	sw	$2,48($16)
	li	$6,14			# 0xe
	lw	$2,20($17)
	sw	$2,12($22)
	lw	$2,24($17)
	sh	$2,0($23)
	lw	$2,4($17)
	sw	$2,16($22)
	lw	$2,8($17)
	.set	noreorder
	.set	nomacro
	jal	memset
	sh	$2,2($23)
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	beq	$19,$0,$L285
	move	$5,$19
	.set	macro
	.set	reorder

	lw	$4,4($17)
	.set	noreorder
	.set	nomacro
	jal	arp_req_get_ha
	move	$6,$21
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L285
	addiu	$5,$sp,56
	.set	macro
	.set	reorder

	lw	$4,172($18)
	li	$6,2			# 0x2
	.set	noreorder
	.set	nomacro
	jal	memcmp
	addiu	$4,$4,-2
	.set	macro
	.set	reorder

	bne	$2,$0,$L286
	lw	$3,156($18)
	beq	$3,$0,$L286
	lbu	$2,12($3)
	lbu	$3,13($3)
	sll	$2,$2,8
	or	$3,$3,$2
	li	$2,2048			# 0x800
	beq	$3,$2,$L286
	lw	$2,172($18)
	addiu	$2,$2,-22
	sw	$2,156($18)
$L286:
	lw	$4,156($18)
	move	$5,$21
	.set	noreorder
	.set	nomacro
	jal	memcpy
	li	$6,6			# 0x6
	.set	macro
	.set	reorder

	addiu	$5,$19,320
	lw	$4,156($18)
	li	$6,6			# 0x6
	.set	noreorder
	.set	nomacro
	jal	memcpy
	addiu	$4,$4,6
	.set	macro
	.set	reorder

$L285:
	sw	$0,140($18)
	li	$2,2048			# 0x800
	lw	$4,100($sp)
	.set	noreorder
	.set	nomacro
	bne	$4,$2,$L295
	lui	$2,%hi(nf_hooks+160)
	.set	macro
	.set	reorder

	lw	$3,%lo(nf_hooks+160)($2)
	addiu	$2,$2,%lo(nf_hooks+160)
	.set	noreorder
	.set	nomacro
	beq	$3,$2,$L295
	lui	$2,%hi(init_net+204)
	.set	macro
	.set	reorder

	move	$4,$18
	lw	$2,%lo(init_net+204)($2)
	li	$5,4			# 0x4
	move	$6,$20
	move	$7,$19
	.set	noreorder
	.set	nomacro
	jal	ipt_do_table
	sw	$2,16($sp)
	.set	macro
	.set	reorder

$L295:
	lw	$2,140($18)
	sw	$2,52($16)
	li	$2,6			# 0x6
	lw	$5,72($sp)
	.set	noreorder
	.set	nomacro
	bne	$5,$2,$L300
	lui	$2,%hi(nf_ct_udp_timeout_stream)
	.set	macro
	.set	reorder

	lw	$2,160($sp)
	lbu	$4,176($2)
	jal	tcp_get_timeouts_by_state
	.set	noreorder
	.set	nomacro
	j	$L339
	sw	$2,60($16)
	.set	macro
	.set	reorder

$L300:
	lw	$2,%lo(nf_ct_udp_timeout_stream)($2)
	sw	$2,60($16)
$L339:
	lui	$2,%hi(jiffies)
	lw	$3,160($sp)
	lw	$4,76($16)
	sw	$3,56($16)
	lw	$2,%lo(jiffies)($2)
	lw	$3,72($16)
	.set	noreorder
	.set	nomacro
	beq	$3,$0,$L303
	sw	$2,40($16)
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	j	$L304
	sw	$4,76($3)
	.set	macro
	.set	reorder

$L303:
	lui	$5,%hi(path_list_free)
	addiu	$2,$5,%lo(path_list_free)
	sw	$4,4($2)
$L304:
	lw	$3,76($16)
	lui	$5,%hi(path_list_free)
	lw	$2,72($16)
	addiu	$5,$5,%lo(path_list_free)
	addiu	$7,$16,72
	lui	$6,%hi(table_path)
	sw	$2,0($3)
	lui	$3,%hi(path_list_inuse)
	lw	$2,8($5)
	addiu	$3,$3,%lo(path_list_inuse)
	sll	$4,$fp,1
	addiu	$8,$16,64
	addiu	$2,$2,-1
	addu	$4,$4,$fp
	sw	$2,8($5)
	sll	$4,$4,2
	sw	$0,72($16)
	lw	$2,4($3)
	sw	$2,76($16)
	lw	$2,4($3)
	sw	$16,0($2)
	lw	$2,8($3)
	sw	$7,4($3)
	addiu	$2,$2,1
	sw	$2,8($3)
	sw	$0,64($16)
	lw	$2,%lo(table_path)($6)
	lw	$2,0($2)
	addu	$2,$4,$2
	lw	$2,4($2)
	sw	$2,68($16)
	lw	$2,%lo(table_path)($6)
	lw	$2,0($2)
	addu	$2,$4,$2
	lw	$2,4($2)
	sw	$16,0($2)
	lw	$2,%lo(table_path)($6)
	lw	$2,0($2)
	addu	$2,$4,$2
	sw	$8,4($2)
	lw	$2,%lo(table_path)($6)
	lw	$2,0($2)
	addu	$4,$4,$2
	lw	$2,8($4)
	addiu	$2,$2,1
	sw	$2,8($4)
$L267:
	lw	$4,156($18)
	addiu	$5,$sp,24
	li	$6,6			# 0x6
	.set	noreorder
	.set	nomacro
	jal	memcpy
	addiu	$4,$4,6
	.set	macro
	.set	reorder

	addiu	$5,$sp,32
	lw	$4,156($18)
	.set	noreorder
	.set	nomacro
	jal	memcpy
	li	$6,6			# 0x6
	.set	macro
	.set	reorder

	lw	$2,104($sp)
	sw	$2,140($18)
	lw	$3,80($sp)
	sw	$3,12($22)
	lw	$4,88($sp)
	sh	$4,0($23)
	lw	$5,84($sp)
	sw	$5,16($22)
	lw	$2,92($sp)
	sh	$2,2($23)
	lw	$3,96($sp)
	.set	noreorder
	.set	nomacro
	beq	$19,$0,$L311
	sw	$3,28($18)
	.set	macro
	.set	reorder

#APP
	   

	1:	ll	    $2, 452($19)		# atomic_sub		
       nop                                             
	subu	$2, 1					
	sc	    $2, 452($19)					
	beqz	$2, 2f					
	.subsection 2					
2:	b	1b					
	.previous					

	   

#NO_APP
$L311:
	beq	$20,$0,$L314
#APP
	   

	1:	ll	    $2, 452($20)		# atomic_sub		
       nop                                             
	subu	$2, 1					
	sc	    $2, 452($20)					
	beqz	$2, 2f					
	.subsection 2					
2:	b	1b					
	.previous					

	   

#NO_APP
$L314:
	lw	$4,76($sp)
	xori	$2,$4,0x1
	andi	$2,$2,0x1
	beq	$2,$0,$L318
	.set	noreorder
	.set	nomacro
	j	$L337
	move	$2,$4
	.set	macro
	.set	reorder

$L318:
	lw	$2,76($sp)
$L337:
#APP
	raw_local_irq_restore	$2
#NO_APP
	.set	noreorder
	.set	nomacro
	j	$L203
	move	$2,$0
	.set	macro
	.set	reorder

$L213:
	lw	$5,76($sp)
	xori	$2,$5,0x1
	andi	$2,$2,0x1
	beq	$2,$0,$L325
	.set	noreorder
	.set	nomacro
	j	$L336
	move	$2,$5
	.set	macro
	.set	reorder

$L325:
	lw	$2,76($sp)
$L336:
#APP
	raw_local_irq_restore	$2
#NO_APP
	li	$2,-1			# 0xffffffff
$L323:
$L203:
	lw	$31,148($sp)
	lw	$fp,144($sp)
	lw	$23,140($sp)
	lw	$22,136($sp)
	lw	$21,132($sp)
	lw	$20,128($sp)
	lw	$19,124($sp)
	lw	$18,120($sp)
	lw	$17,116($sp)
	lw	$16,112($sp)
	.set	noreorder
	.set	nomacro
	j	$31
	addiu	$sp,$sp,152
	.set	macro
	.set	reorder

	.end	rtk_addNaptConnection
	.section	.text.rtk_delNaptConnection,"ax",@progbits
	.align	2
	.globl	rtk_delNaptConnection
	.ent	rtk_delNaptConnection
	.type	rtk_delNaptConnection, @function
rtk_delNaptConnection:
	.set	nomips16
	.frame	$sp,64,$31		# vars= 0, regs= 9/0, args= 24, gp= 0
	.mask	0x80ff0000,-8
	.fmask	0x00000000,0
	addiu	$sp,$sp,-64
	li	$3,17			# 0x11
	sw	$23,52($sp)
	li	$23,6			# 0x6
	sw	$16,24($sp)
	move	$16,$4
	sw	$31,56($sp)
	sw	$22,48($sp)
	sw	$21,44($sp)
	sw	$20,40($sp)
	sw	$19,36($sp)
	sw	$18,32($sp)
	sw	$17,28($sp)
	lw	$2,0($4)
	xori	$2,$2,0x2
	movn	$23,$3,$2		#conditional move  
#APP
	raw_local_irq_save	$17
#NO_APP
	lw	$4,20($4)
	jal	filter_delconnect
	lw	$22,0($16)
	lw	$21,4($16)
	lw	$20,8($16)
	andi	$2,$22,0xffff
	lw	$19,20($16)
	move	$4,$21
	lw	$18,24($16)
	move	$5,$20
	move	$6,$19
	sw	$2,16($sp)
	.set	noreorder
	.set	nomacro
	jal	FastPath_Hash_NAPT_Entry
	move	$7,$18
	.set	macro
	.set	reorder

	lui	$10,%hi(table_napt)
	lw	$3,%lo(table_napt)($10)
	sll	$8,$2,1
	move	$6,$2
	addu	$2,$8,$2
	lw	$3,0($3)
	sll	$2,$2,2
	addu	$2,$2,$3
	lw	$5,0($2)
	.set	noreorder
	.set	nomacro
	beq	$5,$0,$L395
	lui	$2,%hi(napt_list_inuse)
	.set	macro
	.set	reorder

	lui	$24,%hi(path_list_inuse)
	addiu	$9,$2,%lo(napt_list_inuse)
	lui	$2,%hi(napt_list_free)
	addiu	$7,$2,%lo(napt_list_free)
$L387:
	lw	$2,4($5)
	bne	$2,$22,$L346
	lw	$2,8($5)
	bne	$2,$21,$L346
	lw	$2,12($5)
	bne	$2,$20,$L346
	lw	$3,16($5)
	lw	$2,12($16)
	bne	$3,$2,$L346
	lw	$3,20($5)
	lw	$2,16($16)
	bne	$3,$2,$L346
	lw	$2,24($5)
	bne	$2,$19,$L346
	lw	$2,28($5)
	bne	$2,$18,$L346
	lw	$2,36($5)
	sb	$0,0($5)
	lw	$4,40($5)
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L349
	addu	$3,$8,$6
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	j	$L350
	sw	$4,40($2)
	.set	macro
	.set	reorder

$L349:
	lw	$2,%lo(table_napt)($10)
	sll	$3,$3,2
	lw	$2,0($2)
	addu	$3,$3,$2
	sw	$4,4($3)
$L350:
	lw	$2,36($5)
	sll	$3,$6,1
	lw	$4,40($5)
	addu	$3,$3,$6
	sll	$3,$3,2
	sw	$2,0($4)
	lui	$2,%hi(table_napt)
	lw	$2,%lo(table_napt)($2)
	lw	$2,0($2)
	addu	$3,$3,$2
	lw	$2,8($3)
	addiu	$2,$2,-1
	sw	$2,8($3)
	lw	$2,44($5)
	lw	$3,48($5)
	beq	$2,$0,$L352
	.set	noreorder
	.set	nomacro
	j	$L353
	sw	$3,48($2)
	.set	macro
	.set	reorder

$L352:
	sw	$3,4($9)
$L353:
	lw	$3,48($5)
	addiu	$4,$5,44
	lw	$2,44($5)
	lui	$18,%hi(path_table_list_max)
	lui	$12,%hi(table_path)
	sw	$2,0($3)
	lw	$2,8($9)
	addiu	$2,$2,-1
	sw	$2,8($9)
	sw	$0,44($5)
	lw	$2,4($7)
	sw	$2,48($5)
	lw	$2,4($7)
	sw	$5,0($2)
	lw	$2,8($7)
	sw	$4,4($7)
	addiu	$2,$2,1
	sw	$2,8($7)
	lw	$8,4($16)
	lw	$7,20($16)
	lw	$11,8($16)
	srl	$2,$8,8
	srl	$3,$7,16
	xor	$2,$2,$8
	xor	$3,$3,$7
	srl	$4,$11,4
	xor	$2,$2,$3
	lw	$10,24($16)
	xor	$2,$2,$4
	lw	$4,%lo(path_table_list_max)($18)
	xor	$2,$2,$10
	xor	$2,$2,$23
	addiu	$4,$4,-1
	srl	$3,$2,12
	xor	$2,$2,$3
	and	$6,$4,$2
	lw	$3,%lo(table_path)($12)
	sll	$2,$6,1
	addu	$2,$2,$6
	lw	$3,0($3)
	sll	$2,$2,2
	addu	$3,$2,$3
	lw	$5,0($3)
	.set	noreorder
	.set	nomacro
	beq	$5,$0,$L357
	move	$4,$2
	.set	macro
	.set	reorder

	lui	$2,%hi(path_list_free)
	addiu	$6,$2,%lo(path_list_free)
	move	$13,$4
	addiu	$9,$24,%lo(path_list_inuse)
	li	$14,1			# 0x1
	move	$15,$12
$L367:
	lw	$3,4($5)
	lw	$2,0($16)
	bne	$3,$2,$L358
	lbu	$2,2($5)
	bne	$2,$14,$L358
	lw	$2,16($5)
	bne	$2,$8,$L358
	lw	$2,12($5)
	bne	$2,$11,$L358
	lw	$3,24($5)
	lw	$2,12($16)
	bne	$3,$2,$L358
	lw	$3,28($5)
	lw	$2,16($16)
	bne	$3,$2,$L358
	lw	$2,20($5)
	bne	$2,$7,$L358
	lw	$2,8($5)
	bne	$2,$10,$L358
	lw	$2,64($5)
	sb	$0,0($5)
	lw	$3,68($5)
	beq	$2,$0,$L361
	.set	noreorder
	.set	nomacro
	j	$L362
	sw	$3,68($2)
	.set	macro
	.set	reorder

$L361:
	lw	$2,%lo(table_path)($12)
	lw	$2,0($2)
	addu	$2,$4,$2
	sw	$3,4($2)
$L362:
	lw	$3,68($5)
	lw	$2,64($5)
	sw	$2,0($3)
	lw	$2,%lo(table_path)($15)
	lw	$3,0($2)
	addu	$3,$13,$3
	lw	$2,8($3)
	addiu	$2,$2,-1
	sw	$2,8($3)
	lw	$3,72($5)
	lw	$2,76($5)
	beq	$3,$0,$L364
	.set	noreorder
	.set	nomacro
	j	$L365
	sw	$2,76($3)
	.set	macro
	.set	reorder

$L364:
	sw	$2,4($9)
$L365:
	lw	$2,72($5)
	addiu	$4,$5,72
	lw	$3,76($5)
	sw	$2,0($3)
	lw	$2,8($9)
	addiu	$2,$2,-1
	sw	$2,8($9)
	sw	$0,72($5)
	lw	$2,4($6)
	sw	$2,76($5)
	lw	$2,4($6)
	sw	$5,0($2)
	lw	$2,8($6)
	sw	$4,4($6)
	addiu	$2,$2,1
	.set	noreorder
	.set	nomacro
	j	$L357
	sw	$2,8($6)
	.set	macro
	.set	reorder

$L358:
	lw	$5,64($5)
	bne	$5,$0,$L367
$L357:
	lw	$8,20($16)
	lui	$10,%hi(table_path)
	lw	$7,12($16)
	lw	$12,24($16)
	srl	$2,$8,8
	srl	$3,$7,16
	xor	$2,$2,$8
	xor	$3,$3,$7
	srl	$4,$12,4
	xor	$2,$2,$3
	lw	$11,16($16)
	xor	$2,$2,$4
	lw	$4,%lo(path_table_list_max)($18)
	xor	$2,$2,$11
	xor	$2,$2,$23
	addiu	$4,$4,-1
	srl	$3,$2,12
	xor	$2,$2,$3
	and	$6,$4,$2
	lw	$3,%lo(table_path)($10)
	sll	$2,$6,1
	addu	$2,$2,$6
	lw	$3,0($3)
	sll	$2,$2,2
	addu	$3,$2,$3
	lw	$5,0($3)
	beq	$5,$0,$L370
	move	$4,$2
	lui	$2,%hi(path_list_free)
	addiu	$9,$24,%lo(path_list_inuse)
	addiu	$6,$2,%lo(path_list_free)
	move	$13,$4
	li	$14,2			# 0x2
	move	$15,$10
$L380:
	lw	$3,4($5)
	lw	$2,0($16)
	bne	$3,$2,$L371
	lbu	$2,2($5)
	bne	$2,$14,$L371
	lw	$2,20($5)
	bne	$2,$7,$L371
	lw	$2,8($5)
	bne	$2,$11,$L371
	lw	$2,24($5)
	bne	$2,$8,$L371
	lw	$2,28($5)
	bne	$2,$12,$L371
	lw	$3,32($5)
	lw	$2,4($16)
	bne	$3,$2,$L371
	lw	$3,36($5)
	lw	$2,8($16)
	bne	$3,$2,$L371
	lw	$2,64($5)
	sb	$0,0($5)
	lw	$3,68($5)
	beq	$2,$0,$L374
	.set	noreorder
	.set	nomacro
	j	$L375
	sw	$3,68($2)
	.set	macro
	.set	reorder

$L374:
	lw	$2,%lo(table_path)($10)
	lw	$2,0($2)
	addu	$2,$4,$2
	sw	$3,4($2)
$L375:
	lw	$3,68($5)
	lw	$2,64($5)
	sw	$2,0($3)
	lw	$2,%lo(table_path)($15)
	lw	$3,0($2)
	addu	$3,$13,$3
	lw	$2,8($3)
	addiu	$2,$2,-1
	sw	$2,8($3)
	lw	$3,72($5)
	lw	$2,76($5)
	beq	$3,$0,$L377
	.set	noreorder
	.set	nomacro
	j	$L378
	sw	$2,76($3)
	.set	macro
	.set	reorder

$L377:
	sw	$2,4($9)
$L378:
	lw	$2,72($5)
	addiu	$4,$5,72
	lw	$3,76($5)
	sw	$2,0($3)
	lw	$2,8($9)
	addiu	$2,$2,-1
	sw	$2,8($9)
	sw	$0,72($5)
	lw	$2,4($6)
	sw	$2,76($5)
	lw	$2,4($6)
	sw	$5,0($2)
	lw	$2,8($6)
	sw	$4,4($6)
	addiu	$2,$2,1
	.set	noreorder
	.set	nomacro
	j	$L370
	sw	$2,8($6)
	.set	macro
	.set	reorder

$L371:
	lw	$5,64($5)
	bne	$5,$0,$L380
$L370:
#APP
	raw_local_irq_restore	$17
#NO_APP
	.set	noreorder
	.set	nomacro
	j	$L340
	move	$2,$0
	.set	macro
	.set	reorder

$L346:
	lw	$5,36($5)
	bne	$5,$0,$L387
$L395:
#APP
	raw_local_irq_restore	$17
#NO_APP
	li	$2,-4			# 0xfffffffc
$L340:
	lw	$31,56($sp)
	lw	$23,52($sp)
	lw	$22,48($sp)
	lw	$21,44($sp)
	lw	$20,40($sp)
	lw	$19,36($sp)
	lw	$18,32($sp)
	lw	$17,28($sp)
	lw	$16,24($sp)
	.set	noreorder
	.set	nomacro
	j	$31
	addiu	$sp,$sp,64
	.set	macro
	.set	reorder

	.end	rtk_delNaptConnection
	.section	.text.rtk_idleNaptConnection,"ax",@progbits
	.align	2
	.globl	rtk_idleNaptConnection
	.ent	rtk_idleNaptConnection
	.type	rtk_idleNaptConnection, @function
rtk_idleNaptConnection:
	.set	nomips16
	.frame	$sp,8,$31		# vars= 0, regs= 1/0, args= 0, gp= 0
	.mask	0x00010000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	addiu	$sp,$sp,-8
	move	$7,$4
	sw	$16,0($sp)
	li	$11,6			# 0x6
	lw	$8,4($4)
	lui	$16,%hi(path_table_list_max)
	lw	$6,20($4)
	lui	$25,%hi(table_path)
	lw	$13,8($4)
	srl	$2,$8,8
	srl	$3,$6,16
	xor	$2,$2,$8
	xor	$3,$3,$6
	srl	$4,$13,4
	lw	$12,0($7)
	xor	$2,$2,$3
	lw	$10,24($7)
	xor	$2,$2,$4
	li	$3,17			# 0x11
	xori	$4,$12,0x2
	movn	$11,$3,$4		#conditional move  
	xor	$2,$2,$10
	xor	$2,$2,$11
	lw	$4,%lo(path_table_list_max)($16)
	srl	$3,$2,12
	xor	$2,$2,$3
	addiu	$4,$4,-1
	and	$4,$4,$2
	lw	$3,%lo(table_path)($25)
	sll	$2,$4,1
	addu	$2,$2,$4
	lw	$4,0($3)
	sll	$2,$2,2
	lui	$3,%hi(jiffies)
	addu	$2,$2,$4
	lw	$4,0($2)
	lw	$14,%lo(jiffies)($3)
	beq	$4,$0,$L403
	li	$2,-16777216			# 0xff000000

	subu	$9,$14,$5
	ori	$24,$2,0x100
	ori	$15,$2,0xff00
$L407:
	lw	$2,4($4)
	bne	$2,$12,$L404
	nop

	lw	$2,0($4)
	and	$2,$2,$15
	bne	$2,$24,$L404
	nop

	lw	$2,16($4)
	bne	$2,$8,$L404
	nop

	lw	$2,12($4)
	bne	$2,$13,$L404
	nop

	lw	$3,24($4)
	lw	$2,12($7)
	bne	$3,$2,$L404
	nop

	lw	$3,28($4)
	lw	$2,16($7)
	bne	$3,$2,$L404
	nop

	lw	$2,20($4)
	bne	$2,$6,$L404
	nop

	lw	$2,8($4)
	bne	$2,$10,$L404
	nop

	lw	$6,40($4)
	subu	$2,$9,$6
	bgez	$2,$L403
	nop

	j	$L417
	nop

$L404:
	lw	$4,64($4)
	bne	$4,$0,$L407
	nop

$L403:
	lw	$8,20($7)
	lw	$6,12($7)
	lw	$12,24($7)
	srl	$2,$8,8
	srl	$3,$6,16
	xor	$2,$2,$8
	xor	$3,$3,$6
	srl	$4,$12,4
	xor	$2,$2,$3
	lw	$10,16($7)
	xor	$2,$2,$4
	lw	$4,%lo(path_table_list_max)($16)
	xor	$2,$2,$10
	xor	$2,$2,$11
	addiu	$4,$4,-1
	srl	$3,$2,12
	xor	$2,$2,$3
	and	$4,$4,$2
	lw	$3,%lo(table_path)($25)
	sll	$2,$4,1
	addu	$2,$2,$4
	lw	$3,0($3)
	sll	$2,$2,2
	addu	$2,$2,$3
	lw	$4,0($2)
	beq	$4,$0,$L410
	li	$2,-16777216			# 0xff000000

	subu	$9,$14,$5
	ori	$13,$2,0x200
	ori	$11,$2,0xff00
$L414:
	lw	$3,4($4)
	lw	$2,0($7)
	bne	$3,$2,$L411
	nop

	lw	$2,0($4)
	and	$2,$2,$11
	bne	$2,$13,$L411
	nop

	lw	$2,20($4)
	bne	$2,$6,$L411
	nop

	lw	$2,8($4)
	bne	$2,$10,$L411
	nop

	lw	$2,24($4)
	bne	$2,$8,$L411
	nop

	lw	$2,28($4)
	bne	$2,$12,$L411
	nop

	lw	$3,32($4)
	lw	$2,4($7)
	bne	$3,$2,$L411
	nop

	lw	$3,36($4)
	lw	$2,8($7)
	bne	$3,$2,$L411
	nop

	lw	$6,40($4)
	subu	$2,$9,$6
	bgez	$2,$L410
	nop

$L417:
	lw	$3,56($4)
	addu	$2,$6,$5
	li	$4,-1			# 0xffffffff
	j	$L398
	sw	$2,116($3)

$L411:
	lw	$4,64($4)
	bne	$4,$0,$L414
	nop

$L410:
	move	$4,$0
$L398:
	lw	$16,0($sp)
	move	$2,$4
	j	$31
	addiu	$sp,$sp,8

	.set	macro
	.set	reorder
	.end	rtk_idleNaptConnection
	.section	.text.rtl_fpTimer_update,"ax",@progbits
	.align	2
	.globl	rtl_fpTimer_update
	.ent	rtl_fpTimer_update
	.type	rtl_fpTimer_update, @function
rtl_fpTimer_update:
	.set	nomips16
	.frame	$sp,72,$31		# vars= 32, regs= 5/0, args= 16, gp= 0
	.mask	0x800f0000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	addiu	$sp,$sp,-72
	lui	$2,%hi(jiffies)
	sw	$16,48($sp)
	move	$16,$4
	sw	$31,64($sp)
	sw	$19,60($sp)
	sw	$18,56($sp)
	sw	$17,52($sp)
	lbu	$3,50($4)
	lw	$19,%lo(jiffies)($2)
	li	$2,17			# 0x11
	bne	$3,$2,$L419
	li	$2,6			# 0x6

	lw	$2,100($4)
	andi	$2,$2,0x2
	beq	$2,$0,$L420
	li	$18,1			# 0x1

	lui	$2,%hi(nf_ct_udp_timeout_stream)
	lw	$17,%lo(nf_ct_udp_timeout_stream)($2)
	j	$L422
	nop

$L420:
	lui	$2,%hi(nf_ct_udp_timeout)
	lw	$17,%lo(nf_ct_udp_timeout)($2)
	j	$L422
	nop

$L419:
	bne	$3,$2,$L418
	li	$2,-1			# 0xffffffff

	lbu	$4,176($4)
	sltu	$2,$4,6
	beq	$2,$0,$L418
	li	$2,-1			# 0xffffffff

	jal	tcp_get_timeouts_by_state
	li	$18,2			# 0x2

	move	$17,$2
$L422:
	lw	$10,12($16)
	lw	$8,80($16)
	lw	$9,60($16)
	lw	$7,32($16)
	bne	$10,$8,$L425
	addiu	$4,$sp,16

	lhu	$2,76($16)
	lhu	$3,48($16)
	move	$5,$17
	lhu	$6,28($16)
	sw	$18,16($sp)
	sw	$9,20($sp)
	sw	$2,24($sp)
	sw	$7,28($sp)
	sw	$3,32($sp)
	j	$L433
	sw	$8,36($sp)

$L425:
	bne	$7,$9,$L418
	li	$2,-1			# 0xffffffff

	lhu	$2,28($16)
	addiu	$4,$sp,16
	lhu	$3,96($16)
	move	$5,$17
	lhu	$6,76($16)
	sw	$18,16($sp)
	sw	$10,20($sp)
	sw	$2,24($sp)
	sw	$8,28($sp)
	sw	$3,32($sp)
	sw	$7,36($sp)
$L433:
	jal	rtk_idleNaptConnection
	sw	$6,40($sp)

	beq	$2,$0,$L430
	addu	$5,$19,$17

	jal	rtl_check_for_acc
	move	$4,$16

	j	$L418
	move	$2,$0

$L430:
	li	$2,-1			# 0xffffffff
$L418:
	lw	$31,64($sp)
	lw	$19,60($sp)
	lw	$18,56($sp)
	lw	$17,52($sp)
	lw	$16,48($sp)
	j	$31
	addiu	$sp,$sp,72

	.set	macro
	.set	reorder
	.end	rtl_fpTimer_update
	.section	.text.rtl_br_fdb_time_update,"ax",@progbits
	.align	2
	.globl	rtl_br_fdb_time_update
	.ent	rtl_br_fdb_time_update
	.type	rtl_br_fdb_time_update, @function
rtl_br_fdb_time_update:
	.set	nomips16
	.frame	$sp,40,$31		# vars= 8, regs= 3/0, args= 16, gp= 0
	.mask	0x80030000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	addiu	$sp,$sp,-40
	move	$4,$0
	sw	$16,24($sp)
	move	$16,$5
	move	$5,$6
	li	$6,2			# 0x2
	sw	$31,32($sp)
	jal	rtl_get_hw_fdb_age
	sw	$17,28($sp)

	move	$3,$2
	li	$2,300			# 0x12c
	beq	$3,$2,$L437
	lui	$2,%hi(jiffies)

	sltu	$2,$3,301
	beq	$2,$0,$L440
	li	$2,450			# 0x1c2

	li	$2,150			# 0x96
	beq	$3,$2,$L438
	lui	$2,%hi(jiffies)

	j	$L435
	nop

$L440:
	bne	$3,$2,$L435
	lui	$2,%hi(jiffies)

	lw	$2,%lo(jiffies)($2)
	j	$L435
	sw	$2,24($16)

$L437:
	lw	$2,%lo(jiffies)($2)
	j	$L445
	addiu	$2,$2,-15000

$L438:
	lw	$2,%lo(jiffies)($2)
	addiu	$2,$2,-30000
$L445:
	sw	$2,24($16)
$L435:
	lbu	$2,1112($17)
	beq	$2,$0,$L442
	nop

	lw	$5,1080($17)
	j	$L444
	nop

$L442:
	lw	$5,1088($17)
$L444:
	lw	$2,24($16)
	lui	$3,%hi(jiffies)
	lw	$3,%lo(jiffies)($3)
	addu	$2,$2,$5
	subu	$3,$3,$2
	li	$2,-1			# 0xffffffff
	slt	$3,$3,0
	lw	$31,32($sp)
	movn	$2,$0,$3		#conditional move
	lw	$17,28($sp)
	lw	$16,24($sp)
	j	$31
	addiu	$sp,$sp,40

	.set	macro
	.set	reorder
	.end	rtl_br_fdb_time_update
	.section	.text.rtl_fp_dev_queue_xmit_check,"ax",@progbits
	.align	2
	.globl	rtl_fp_dev_queue_xmit_check
	.ent	rtl_fp_dev_queue_xmit_check
	.type	rtl_fp_dev_queue_xmit_check, @function
rtl_fp_dev_queue_xmit_check:
	.set	nomips16
	.frame	$sp,24,$31		# vars= 0, regs= 2/0, args= 16, gp= 0
	.mask	0x80010000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	addiu	$sp,$sp,-24
	lui	$2,%hi(l2tp_tx_id_hook)
	sw	$16,16($sp)
	sw	$31,20($sp)
	lw	$2,%lo(l2tp_tx_id_hook)($2)
	beq	$2,$0,$L447
	move	$16,$4

	jal	$2
	nop

$L447:
	lui	$2,%hi(sync_tx_pptp_gre_seqno_hook)
	lw	$2,%lo(sync_tx_pptp_gre_seqno_hook)($2)
	beq	$2,$0,$L448
	move	$4,$16

	jal	$2
	nop

$L448:
	lw	$31,20($sp)
	move	$2,$0
	lw	$16,16($sp)
	j	$31
	addiu	$sp,$sp,24

	.set	macro
	.set	reorder
	.end	rtl_fp_dev_queue_xmit_check
	.section	.text.rtl_fp_dev_hard_start_xmit_check,"ax",@progbits
	.align	2
	.globl	rtl_fp_dev_hard_start_xmit_check
	.ent	rtl_fp_dev_hard_start_xmit_check
	.type	rtl_fp_dev_hard_start_xmit_check, @function
rtl_fp_dev_hard_start_xmit_check:
	.set	nomips16
	.frame	$sp,24,$31		# vars= 0, regs= 1/0, args= 16, gp= 0
	.mask	0x80000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
	addiu	$sp,$sp,-24
	lui	$2,%hi(gQosEnabled)
	sw	$31,16($sp)
	lw	$2,%lo(gQosEnabled)($2)
	bne	$2,$0,$L450
	lui	$2,%hi(l2tp_tx_id_hook)

	lw	$2,%lo(l2tp_tx_id_hook)($2)
	beq	$2,$0,$L450
	nop

	jal	$2
	nop

$L450:
	lw	$31,16($sp)
	move	$2,$0
	j	$31
	addiu	$sp,$sp,24

	.set	macro
	.set	reorder
	.end	rtl_fp_dev_hard_start_xmit_check
	.rdata
	.align	2
$LC0:
	.ascii	"lo\000"
	.section	.text.enter_fast_path,"ax",@progbits
	.align	2
	.globl	enter_fast_path
	.ent	enter_fast_path
	.type	enter_fast_path, @function
enter_fast_path:
	.set	nomips16
	.frame	$sp,88,$31		# vars= 24, regs= 10/0, args= 24, gp= 0
	.mask	0xc0ff0000,-4
	.fmask	0x00000000,0
	addiu	$sp,$sp,-88
	li	$2,1			# 0x1
	sw	$fp,80($sp)
	move	$fp,$4
	sw	$22,72($sp)
	sw	$31,84($sp)
	sw	$23,76($sp)
	sw	$21,68($sp)
	sw	$20,64($sp)
	sw	$19,60($sp)
	sw	$18,56($sp)
	sw	$17,52($sp)
	sw	$16,48($sp)
	lw	$18,152($4)
	sw	$2,24($sp)
	li	$2,6			# 0x6
	sw	$0,28($sp)
	sw	$0,32($sp)
	lbu	$21,9($18)
	.set	noreorder
	.set	nomacro
	beq	$21,$2,$L455
	move	$22,$0
	.set	macro
	.set	reorder

	li	$2,17			# 0x11
	.set	noreorder
	.set	nomacro
	bne	$21,$2,$L452
	move	$4,$0
	.set	macro
	.set	reorder

$L455:
	lbu	$2,0($18)
	move	$4,$18
	move	$6,$fp
	andi	$2,$2,0xf
	sll	$2,$2,2
	addu	$23,$18,$2
	.set	noreorder
	.set	nomacro
	jal	fast_path_pre_process_check
	move	$5,$23
	.set	macro
	.set	reorder

	move	$5,$2
	move	$4,$2
	li	$2,6			# 0x6
	bne	$5,$2,$L452
	lhu	$7,6($18)
	lui	$4,%hi($LC0)
	lw	$19,12($18)
	lw	$20,16($18)
	lhu	$8,0($23)
	lhu	$11,2($23)
	lw	$3,24($fp)
	.set	noreorder
	.set	nomacro
	bne	$21,$5,$L457
	andi	$6,$7,0xffff
	.set	macro
	.set	reorder

	addiu	$2,$4,%lo($LC0)
	move	$5,$3
#APP
	.set	noreorder
	.set	noat
	lbu	$3,($5)
1:	lbu	$1,($2)
	addiu	$5,1
	bne	$1,$3,2f
	addiu	$2,1
	bnez	$3,1b
	lbu	$3,($5)
	move	$3,$1
2:	subu	$3,$1
3:	.set	at
	.set	reorder
#NO_APP
	.set	noreorder
	.set	nomacro
	beq	$3,$0,$L452
	move	$4,$0
	.set	macro
	.set	reorder

	andi	$2,$6,0x3fff
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L463
	li	$3,1			# 0x1
	.set	macro
	.set	reorder

	xori	$2,$6,0x2000
	.set	noreorder
	.set	nomacro
	j	$L463
	sltu	$3,$2,1
	.set	macro
	.set	reorder

$L631:
	lw	$5,24($4)
	lhu	$6,30($4)
	j	$L468
$L463:
	li	$2,1			# 0x1
	.set	noreorder
	.set	nomacro
	bne	$3,$2,$L649
	andi	$2,$7,0x3fff
	.set	macro
	.set	reorder

	lw	$3,12($23)
	li	$2,65536			# 0x10000
	and	$2,$3,$2
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L465
	li	$2,393216			# 0x60000
	.set	macro
	.set	reorder

	srl	$2,$19,8
	srl	$3,$20,16
	andi	$9,$8,0xffff
	xor	$3,$3,$20
	xor	$2,$2,$19
	srl	$4,$9,4
	xor	$2,$2,$3
	andi	$8,$11,0xffff
	xor	$2,$2,$4
	andi	$7,$21,0xffff
	xor	$2,$2,$8
	lui	$10,%hi(path_table_list_max)
	xor	$2,$2,$7
	lui	$11,%hi(table_path)
	lw	$3,%lo(path_table_list_max)($10)
	srl	$4,$2,12
	xor	$2,$2,$4
	addiu	$3,$3,-1
	and	$4,$3,$2
	lw	$3,%lo(table_path)($11)
	sll	$2,$4,1
	addu	$2,$2,$4
	lw	$3,0($3)
	sll	$2,$2,2
	addu	$2,$2,$3
	lw	$4,0($2)
	beq	$4,$0,$L475
	li	$3,255			# 0xff
$L473:
	lw	$2,12($4)
	bne	$2,$9,$L469
	lw	$2,8($4)
	bne	$2,$8,$L469
	lw	$2,16($4)
	bne	$2,$19,$L469
	lw	$2,20($4)
	bne	$2,$20,$L469
	lbu	$2,0($4)
	.set	noreorder
	.set	nomacro
	bne	$2,$3,$L469
	li	$2,1			# 0x1
	.set	macro
	.set	reorder

	lbu	$3,2($4)
	.set	noreorder
	.set	nomacro
	beq	$3,$2,$L631
	sb	$0,0($4)
	.set	macro
	.set	reorder

	lw	$5,32($4)
	lhu	$6,38($4)
	j	$L468
$L469:
	lw	$4,64($4)
	bne	$4,$0,$L473
	.set	noreorder
	.set	nomacro
	j	$L452
	move	$4,$0
	.set	macro
	.set	reorder

$L468:
	.set	noreorder
	.set	nomacro
	beq	$5,$0,$L475
	li	$2,1			# 0x1
	.set	macro
	.set	reorder

	lbu	$3,2($4)
	.set	noreorder
	.set	nomacro
	bne	$3,$2,$L476
	srl	$3,$19,16
	.set	macro
	.set	reorder

	srl	$2,$20,8
	srl	$3,$5,16
	xor	$3,$3,$5
	xor	$2,$2,$20
	xor	$2,$2,$3
	srl	$3,$8,4
	xor	$2,$2,$3
	.set	noreorder
	.set	nomacro
	j	$L636
	xor	$2,$2,$6
	.set	macro
	.set	reorder

$L476:
	srl	$2,$5,8
	xor	$3,$3,$19
	xor	$2,$2,$5
	xor	$2,$2,$3
	srl	$3,$6,4
	xor	$2,$2,$3
	xor	$2,$2,$9
$L636:
	xor	$2,$2,$7
	lw	$3,%lo(path_table_list_max)($10)
	srl	$4,$2,12
	xor	$2,$2,$4
	addiu	$3,$3,-1
	and	$4,$3,$2
	lw	$2,%lo(table_path)($11)
	sll	$3,$4,1
	addu	$3,$3,$4
	lw	$2,0($2)
	sll	$3,$3,2
	addu	$3,$3,$2
	lw	$4,0($3)
	beq	$4,$0,$L475
	li	$3,255			# 0xff
$L484:
	lw	$2,24($4)
	bne	$2,$20,$L482
	lw	$2,28($4)
	bne	$2,$8,$L482
	lw	$2,32($4)
	bne	$2,$19,$L482
	lw	$2,36($4)
	bne	$2,$9,$L482
	lbu	$2,0($4)
	bne	$2,$3,$L482
	sb	$0,0($4)
$L482:
	lw	$4,64($4)
	bne	$4,$0,$L484
$L475:
	.set	noreorder
	.set	nomacro
	j	$L452
	move	$4,$0
	.set	macro
	.set	reorder

$L465:
	and	$2,$3,$2
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L452
	move	$4,$0
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	j	$L649
	andi	$2,$7,0x3fff
	.set	macro
	.set	reorder

$L457:
	addiu	$2,$4,%lo($LC0)
	move	$5,$3
#APP
	.set	noreorder
	.set	noat
	lbu	$3,($5)
1:	lbu	$1,($2)
	addiu	$5,1
	bne	$1,$3,2f
	addiu	$2,1
	bnez	$3,1b
	lbu	$3,($5)
	move	$3,$1
2:	subu	$3,$1
3:	.set	at
	.set	reorder
#NO_APP
	.set	noreorder
	.set	nomacro
	beq	$3,$0,$L452
	move	$4,$0
	.set	macro
	.set	reorder

	andi	$2,$7,0x3fff
$L649:
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L650
	srl	$3,$20,16
	.set	macro
	.set	reorder

	li	$2,8192			# 0x2000
	.set	noreorder
	.set	nomacro
	bne	$6,$2,$L490
	andi	$2,$6,0x2000
	.set	macro
	.set	reorder

	li	$2,1			# 0x1
	.set	noreorder
	.set	nomacro
	j	$L491
	sw	$2,28($sp)
	.set	macro
	.set	reorder

$L490:
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L651
	xor	$3,$19,$20
	.set	macro
	.set	reorder

	lw	$4,32($sp)
	andi	$3,$6,0x1fff
	li	$2,1			# 0x1
	movn	$4,$2,$3		#conditional move
	sw	$4,32($sp)
$L491:
	xor	$3,$19,$20
$L651:
	lui	$2,%hi(max_udp_frag_entry)
	lhu	$7,4($18)
	srl	$4,$3,16
	lw	$5,%lo(max_udp_frag_entry)($2)
	andi	$6,$21,0x00ff
	xor	$4,$4,$7
	xor	$3,$3,$4
	addiu	$5,$5,-1
	srl	$2,$3,8
	xor	$2,$2,$6
	xor	$3,$3,$2
	lui	$2,%hi(udp_cache_table)
	and	$3,$3,$5
	lw	$4,%lo(udp_cache_table)($2)
	sll	$2,$3,1
	addu	$2,$2,$3
	lw	$3,0($4)
	sll	$2,$2,2
	addu	$2,$2,$3
	lw	$4,0($2)
	.set	noreorder
	.set	nomacro
	beq	$4,$0,$L500
	move	$22,$0
	.set	macro
	.set	reorder

	li	$3,1			# 0x1
$L499:
	lhu	$2,2($4)
	bne	$2,$7,$L496
	lw	$2,4($4)
	bne	$2,$19,$L496
	lw	$2,8($4)
	bne	$2,$20,$L496
	lbu	$2,1($4)
	bne	$2,$6,$L496
	lbu	$2,0($4)
	beq	$2,$3,$L632
$L496:
	lw	$4,40($4)
	.set	noreorder
	.set	nomacro
	bne	$4,$0,$L499
	move	$22,$0
	.set	macro
	.set	reorder

	j	$L500
$L632:
	.set	noreorder
	.set	nomacro
	beq	$4,$0,$L500
	move	$22,$4
	.set	macro
	.set	reorder

	lw	$5,28($sp)
	lhu	$8,12($4)
	lhu	$11,14($4)
	.set	noreorder
	.set	nomacro
	bne	$5,$0,$L650
	srl	$3,$20,16
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	j	$L650
	sw	$0,24($sp)
	.set	macro
	.set	reorder

$L500:
	lw	$2,28($sp)
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L452
	move	$4,$0
	.set	macro
	.set	reorder

	srl	$3,$20,16
$L650:
	srl	$2,$19,8
	sw	$3,36($sp)
	xor	$2,$2,$19
	xor	$3,$3,$20
	xor	$2,$2,$3
	srl	$3,$8,4
	xor	$2,$2,$3
	lui	$3,%hi(path_table_list_max)
	xor	$2,$2,$11
	xor	$2,$2,$21
	lw	$4,%lo(path_table_list_max)($3)
	srl	$3,$2,12
	xor	$2,$2,$3
	addiu	$4,$4,-1
	and	$4,$4,$2
	lui	$2,%hi(table_path)
	lw	$3,%lo(table_path)($2)
	sll	$2,$4,1
	addu	$2,$2,$4
	lw	$3,0($3)
	sll	$2,$2,2
	addu	$2,$2,$3
	lw	$16,0($2)
$L637:
	.set	noreorder
	.set	nomacro
	beq	$16,$0,$L630
	move	$4,$18
	.set	macro
	.set	reorder

	lw	$2,12($16)
	bne	$2,$8,$L507
	lw	$2,8($16)
	bne	$2,$11,$L507
	lw	$2,16($16)
	bne	$2,$19,$L507
	lw	$2,20($16)
	.set	noreorder
	.set	nomacro
	bne	$2,$20,$L507
	li	$2,255			# 0xff
	.set	macro
	.set	reorder

	lbu	$3,0($16)
	.set	noreorder
	.set	nomacro
	bne	$3,$2,$L507
	li	$2,2			# 0x2
	.set	macro
	.set	reorder

	lw	$3,4($16)
	.set	noreorder
	.set	nomacro
	bne	$3,$2,$L652
	li	$2,1			# 0x1
	.set	macro
	.set	reorder

	li	$2,6			# 0x6
	.set	noreorder
	.set	nomacro
	beq	$21,$2,$L509
	li	$2,1			# 0x1
	.set	macro
	.set	reorder

$L652:
	.set	noreorder
	.set	nomacro
	bne	$3,$2,$L507
	li	$2,17			# 0x11
	.set	macro
	.set	reorder

	bne	$21,$2,$L507
$L509:
	lw	$5,32($16)
	move	$4,$fp
	lbu	$7,1($18)
	move	$6,$19
	lw	$2,24($fp)
	sw	$8,40($sp)
	sw	$11,44($sp)
	.set	noreorder
	.set	nomacro
	jal	ip_route_input
	sw	$2,16($sp)
	.set	macro
	.set	reorder

	lw	$8,40($sp)
	lw	$11,44($sp)
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L452
	move	$4,$0
	.set	macro
	.set	reorder

	lw	$3,28($fp)
	lw	$2,48($3)
	bne	$2,$0,$L514
	lw	$2,44($3)
	beq	$2,$0,$L644
$L514:
	lw	$2,72($3)
	lw	$3,84($fp)
	sltu	$2,$2,$3
	.set	noreorder
	.set	nomacro
	bne	$2,$0,$L644
	li	$2,6			# 0x6
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	beq	$21,$2,$L518
	addiu	$17,$23,16
	.set	macro
	.set	reorder

	lhu	$3,6($23)
	addiu	$2,$23,6
	move	$17,$0
	movn	$17,$2,$3		#conditional move  
$L518:
	lw	$4,28($sp)
	.set	noreorder
	.set	nomacro
	beq	$4,$0,$L521
	xor	$3,$19,$20
	.set	macro
	.set	reorder

	lui	$2,%hi(max_udp_frag_entry)
	lhu	$10,4($18)
	srl	$4,$3,16
	lw	$5,%lo(max_udp_frag_entry)($2)
	andi	$9,$21,0x00ff
	xor	$4,$4,$10
	lui	$6,%hi(udp_cache_list_free)
	xor	$3,$3,$4
	andi	$4,$8,0xffff
	srl	$2,$3,8
	addiu	$5,$5,-1
	xor	$2,$2,$9
	andi	$7,$11,0xffff
	lw	$8,%lo(udp_cache_list_free)($6)
	xor	$3,$3,$2
	.set	noreorder
	.set	nomacro
	bne	$8,$0,$L524
	and	$11,$3,$5
	.set	macro
	.set	reorder

$L644:
	lw	$4,28($fp)
	jal	dst_release
	move	$4,$0
	.set	noreorder
	.set	nomacro
	j	$L452
	sw	$0,28($fp)
	.set	macro
	.set	reorder

$L524:
	lw	$5,48($8)
	li	$2,1
	sh	$10,2($8)
	sb	$9,1($8)
	sh	$4,12($8)
	sh	$7,14($8)
	sb	$2,0($8)
	sw	$19,4($8)
	sw	$20,8($8)
	lw	$3,52($8)
	.set	noreorder
	.set	nomacro
	beq	$5,$0,$L527
	addiu	$2,$6,%lo(udp_cache_list_free)
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	j	$L528
	sw	$3,52($5)
	.set	macro
	.set	reorder

$L527:
	sw	$3,4($2)
$L528:
	lw	$4,52($8)
	addiu	$6,$6,%lo(udp_cache_list_free)
	lw	$2,48($8)
	lui	$5,%hi(udp_cache_table)
	sll	$3,$11,1
	addiu	$7,$8,40
	sw	$2,0($4)
	addu	$3,$3,$11
	lw	$2,8($6)
	sll	$3,$3,2
	addiu	$4,$8,16
	addiu	$2,$2,-1
	sw	$2,8($6)
	sw	$0,40($8)
	lw	$2,%lo(udp_cache_table)($5)
	lw	$2,0($2)
	addu	$2,$3,$2
	lw	$2,4($2)
	sw	$2,44($8)
	lw	$2,%lo(udp_cache_table)($5)
	lw	$2,0($2)
	addu	$2,$3,$2
	lw	$2,4($2)
	sw	$8,0($2)
	lw	$2,%lo(udp_cache_table)($5)
	lw	$2,0($2)
	addu	$2,$3,$2
	sw	$7,4($2)
	lw	$2,%lo(udp_cache_table)($5)
	lw	$2,0($2)
	addu	$3,$3,$2
	lw	$2,8($3)
	addiu	$2,$2,1
	sw	$2,8($3)
	lui	$2,%hi(jiffies)
	lw	$2,%lo(jiffies)($2)
	addiu	$2,$2,1000
	.set	noreorder
	.set	nomacro
	jal	add_timer
	sw	$2,24($8)
	.set	macro
	.set	reorder

	j	$L530
$L521:
	lw	$5,32($sp)
	beq	$5,$0,$L530
	.set	noreorder
	.set	nomacro
	jal	del_timer
	addiu	$4,$22,16
	.set	macro
	.set	reorder

	lw	$2,8($22)
	lw	$3,4($22)
	lhu	$4,2($22)
	xor	$3,$3,$2
	srl	$2,$3,16
	xor	$2,$2,$4
	xor	$3,$3,$2
	lui	$2,%hi(max_udp_frag_entry)
	lbu	$5,1($22)
	srl	$4,$3,8
	lw	$2,%lo(max_udp_frag_entry)($2)
	xor	$4,$4,$5
	lw	$6,40($22)
	xor	$3,$3,$4
	addiu	$2,$2,-1
	sb	$0,0($22)
	lw	$4,44($22)
	.set	noreorder
	.set	nomacro
	beq	$6,$0,$L534
	and	$5,$3,$2
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	j	$L535
	sw	$4,44($6)
	.set	macro
	.set	reorder

$L534:
	lui	$3,%hi(udp_cache_table)
	sll	$2,$5,1
	lw	$3,%lo(udp_cache_table)($3)
	addu	$2,$2,$5
	sll	$2,$2,2
	lw	$3,0($3)
	addu	$2,$2,$3
	sw	$4,4($2)
$L535:
	lw	$4,44($22)
	sll	$3,$5,1
	lw	$2,40($22)
	addu	$3,$3,$5
	sll	$3,$3,2
	addiu	$5,$22,48
	sw	$2,0($4)
	lui	$2,%hi(udp_cache_table)
	lw	$2,%lo(udp_cache_table)($2)
	lui	$4,%hi(udp_cache_list_free)
	addiu	$4,$4,%lo(udp_cache_list_free)
	lw	$2,0($2)
	addu	$3,$3,$2
	lw	$2,8($3)
	addiu	$2,$2,-1
	sw	$2,8($3)
	sw	$0,48($22)
	lw	$2,4($4)
	sw	$2,52($22)
	lw	$2,4($4)
	sw	$22,0($2)
	lw	$2,8($4)
	sw	$5,4($4)
	addiu	$2,$2,1
	sw	$2,8($4)
$L530:
	lbu	$3,1($16)
	sltu	$2,$3,13
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L599
	sll	$2,$3,2
	.set	macro
	.set	reorder

	lui	$3,%hi($L622)
	addiu	$3,$3,%lo($L622)
	addu	$2,$2,$3
	lw	$2,0($2)
	j	$2
	.rdata
	.align	2
$L622:
	.word	$L539
	.word	$L541
	.word	$L556
	.word	$L556
	.word	$L570
	.word	$L599
	.word	$L599
	.word	$L599
	.word	$L585
	.word	$L599
	.word	$L599
	.word	$L599
	.word	$L585
	.section	.text.enter_fast_path
$L541:
	lw	$3,24($16)
	srl	$2,$19,16
	andi	$6,$19,0xffff
	addu	$6,$6,$2
	andi	$2,$3,0xffff
	subu	$6,$6,$2
	srl	$3,$3,16
	lhu	$2,10($18)
	subu	$6,$6,$3
	addu	$6,$6,$2
	.set	noreorder
	.set	nomacro
	bgez	$6,$L543
	andi	$2,$6,0xffff
	.set	macro
	.set	reorder

	subu	$6,$0,$6
	sra	$2,$6,16
	andi	$3,$6,0xffff
	addu	$6,$2,$3
	sra	$2,$6,16
	addu	$6,$6,$2
	nor	$2,$0,$6
	.set	noreorder
	.set	nomacro
	j	$L542
	sh	$2,10($18)
	.set	macro
	.set	reorder

$L543:
	sra	$3,$6,16
	addu	$6,$3,$2
	sra	$2,$6,16
	addu	$6,$6,$2
	sh	$6,10($18)
$L542:
	lw	$2,24($sp)
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L560
	li	$2,17			# 0x11
	.set	macro
	.set	reorder

	bne	$21,$2,$L546
	beq	$17,$0,$L560
	lhu	$6,0($17)
	beq	$6,$0,$L560
	lw	$2,12($18)
	lw	$3,24($16)
	srl	$4,$2,16
	andi	$5,$2,0xffff
	addu	$5,$5,$4
	andi	$2,$3,0xffff
	subu	$5,$5,$2
	srl	$3,$3,16
	subu	$5,$5,$3
	.set	noreorder
	.set	nomacro
	j	$L645
	addu	$5,$5,$6
	.set	macro
	.set	reorder

$L546:
	lw	$2,12($18)
	lw	$3,24($16)
	srl	$4,$2,16
	andi	$5,$2,0xffff
	addu	$5,$5,$4
	andi	$2,$3,0xffff
	subu	$5,$5,$2
	srl	$3,$3,16
	lhu	$2,0($17)
	subu	$5,$5,$3
	addu	$5,$5,$2
$L645:
	.set	noreorder
	.set	nomacro
	bgez	$5,$L553
	andi	$2,$5,0xffff
	.set	macro
	.set	reorder

	subu	$5,$0,$5
	sra	$2,$5,16
	andi	$3,$5,0xffff
	addu	$5,$2,$3
	sra	$2,$5,16
	addu	$5,$5,$2
	nor	$2,$0,$5
	.set	noreorder
	.set	nomacro
	j	$L560
	sh	$2,0($17)
	.set	macro
	.set	reorder

$L553:
	sra	$3,$5,16
	addu	$5,$3,$2
	sra	$2,$5,16
	addu	$5,$5,$2
	.set	noreorder
	.set	nomacro
	j	$L560
	sh	$5,0($17)
	.set	macro
	.set	reorder

$L556:
	lw	$3,24($16)
	srl	$2,$19,16
	andi	$6,$19,0xffff
	addu	$6,$6,$2
	andi	$2,$3,0xffff
	subu	$6,$6,$2
	srl	$3,$3,16
	lhu	$2,10($18)
	subu	$6,$6,$3
	addu	$6,$6,$2
	.set	noreorder
	.set	nomacro
	bgez	$6,$L558
	andi	$2,$6,0xffff
	.set	macro
	.set	reorder

	subu	$6,$0,$6
	sra	$2,$6,16
	andi	$3,$6,0xffff
	addu	$6,$2,$3
	sra	$2,$6,16
	addu	$6,$6,$2
	nor	$2,$0,$6
	.set	noreorder
	.set	nomacro
	j	$L557
	sh	$2,10($18)
	.set	macro
	.set	reorder

$L558:
	sra	$3,$6,16
	addu	$6,$3,$2
	sra	$2,$6,16
	addu	$6,$6,$2
	sh	$6,10($18)
$L557:
	lw	$3,24($sp)
	.set	noreorder
	.set	nomacro
	beq	$3,$0,$L560
	li	$2,17			# 0x11
	.set	macro
	.set	reorder

	bne	$21,$2,$L561
	beq	$17,$0,$L566
	lhu	$6,0($17)
	beq	$6,$0,$L566
	lw	$2,12($18)
	lw	$3,24($16)
	srl	$4,$2,16
	andi	$5,$2,0xffff
	addu	$5,$5,$4
	andi	$2,$3,0xffff
	subu	$5,$5,$2
	srl	$3,$3,16
	lhu	$4,0($23)
	subu	$5,$5,$3
	lw	$2,28($16)
	addu	$5,$5,$4
	subu	$5,$5,$2
	.set	noreorder
	.set	nomacro
	j	$L646
	addu	$5,$5,$6
	.set	macro
	.set	reorder

$L561:
	lw	$2,12($18)
	lw	$3,24($16)
	srl	$4,$2,16
	andi	$5,$2,0xffff
	addu	$5,$5,$4
	andi	$2,$3,0xffff
	subu	$5,$5,$2
	srl	$3,$3,16
	lhu	$2,0($23)
	subu	$5,$5,$3
	lw	$3,28($16)
	addu	$5,$5,$2
	lhu	$2,0($17)
	subu	$5,$5,$3
	addu	$5,$5,$2
$L646:
	.set	noreorder
	.set	nomacro
	bgez	$5,$L568
	andi	$2,$5,0xffff
	.set	macro
	.set	reorder

	subu	$5,$0,$5
	sra	$2,$5,16
	andi	$3,$5,0xffff
	addu	$5,$2,$3
	sra	$2,$5,16
	addu	$5,$5,$2
	nor	$2,$0,$5
	.set	noreorder
	.set	nomacro
	j	$L566
	sh	$2,0($17)
	.set	macro
	.set	reorder

$L568:
	sra	$3,$5,16
	addu	$5,$3,$2
	sra	$2,$5,16
	addu	$5,$5,$2
	sh	$5,0($17)
$L566:
	lw	$2,28($16)
	sh	$2,0($23)
$L560:
	lw	$2,24($16)
	.set	noreorder
	.set	nomacro
	j	$L539
	sw	$2,12($18)
	.set	macro
	.set	reorder

$L570:
	lw	$2,32($16)
	andi	$6,$20,0xffff
	lw	$5,36($sp)
	andi	$3,$2,0xffff
	srl	$2,$2,16
	addu	$4,$6,$5
	subu	$4,$4,$3
	lhu	$3,10($18)
	subu	$4,$4,$2
	addu	$4,$4,$3
	.set	noreorder
	.set	nomacro
	bgez	$4,$L572
	andi	$2,$4,0xffff
	.set	macro
	.set	reorder

	subu	$4,$0,$4
	sra	$2,$4,16
	andi	$3,$4,0xffff
	addu	$4,$2,$3
	sra	$2,$4,16
	addu	$4,$4,$2
	nor	$2,$0,$4
	.set	noreorder
	.set	nomacro
	j	$L571
	sh	$2,10($18)
	.set	macro
	.set	reorder

$L572:
	sra	$3,$4,16
	addu	$4,$3,$2
	sra	$2,$4,16
	addu	$4,$4,$2
	sh	$4,10($18)
$L571:
	lw	$2,24($sp)
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L643
	li	$2,17			# 0x11
	.set	macro
	.set	reorder

	bne	$21,$2,$L575
	beq	$17,$0,$L643
	lhu	$5,0($17)
	beq	$5,$0,$L643
	lw	$2,32($16)
	lw	$3,36($sp)
	addu	$4,$6,$3
	andi	$3,$2,0xffff
	subu	$4,$4,$3
	srl	$2,$2,16
	subu	$4,$4,$2
	addu	$4,$4,$5
	.set	noreorder
	.set	nomacro
	bgez	$4,$L578
	sra	$3,$4,16
	.set	macro
	.set	reorder

	subu	$4,$0,$4
	sra	$2,$4,16
	andi	$3,$4,0xffff
	addu	$4,$2,$3
	sra	$2,$4,16
	addu	$4,$4,$2
	.set	noreorder
	.set	nomacro
	j	$L640
	nor	$2,$0,$4
	.set	macro
	.set	reorder

$L578:
	andi	$2,$4,0xffff
	addu	$4,$3,$2
	sra	$2,$4,16
	addu	$4,$4,$2
	.set	noreorder
	.set	nomacro
	j	$L643
	sh	$4,0($17)
	.set	macro
	.set	reorder

$L575:
	lw	$2,32($16)
	lw	$4,36($sp)
	andi	$3,$2,0xffff
	srl	$2,$2,16
	addu	$5,$6,$4
	subu	$5,$5,$3
	lhu	$4,0($17)
	subu	$5,$5,$2
	addu	$5,$5,$4
	.set	noreorder
	.set	nomacro
	bgez	$5,$L582
	andi	$2,$5,0xffff
	.set	macro
	.set	reorder

	subu	$5,$0,$5
	sra	$2,$5,16
	andi	$3,$5,0xffff
	addu	$5,$2,$3
	sra	$2,$5,16
	addu	$5,$5,$2
	nor	$2,$0,$5
$L640:
	.set	noreorder
	.set	nomacro
	j	$L643
	sh	$2,0($17)
	.set	macro
	.set	reorder

$L582:
	sra	$3,$5,16
	addu	$5,$3,$2
	sra	$2,$5,16
	addu	$5,$5,$2
	.set	noreorder
	.set	nomacro
	j	$L643
	sh	$5,0($17)
	.set	macro
	.set	reorder

$L585:
	lw	$2,32($16)
	andi	$5,$20,0xffff
	lw	$3,36($sp)
	addu	$4,$5,$3
	andi	$3,$2,0xffff
	subu	$4,$4,$3
	srl	$2,$2,16
	lhu	$3,10($18)
	subu	$4,$4,$2
	addu	$4,$4,$3
	.set	noreorder
	.set	nomacro
	bgez	$4,$L587
	andi	$2,$4,0xffff
	.set	macro
	.set	reorder

	subu	$4,$0,$4
	sra	$2,$4,16
	andi	$3,$4,0xffff
	addu	$4,$2,$3
	sra	$2,$4,16
	addu	$4,$4,$2
	nor	$2,$0,$4
	.set	noreorder
	.set	nomacro
	j	$L586
	sh	$2,10($18)
	.set	macro
	.set	reorder

$L587:
	sra	$3,$4,16
	addu	$4,$3,$2
	sra	$2,$4,16
	addu	$4,$4,$2
	sh	$4,10($18)
$L586:
	lw	$4,24($sp)
	.set	noreorder
	.set	nomacro
	beq	$4,$0,$L643
	li	$2,17			# 0x11
	.set	macro
	.set	reorder

	bne	$21,$2,$L590
	beq	$17,$0,$L595
	lhu	$6,0($17)
	beq	$6,$0,$L595
	lw	$2,32($16)
	lw	$3,36($sp)
	lhu	$4,2($23)
	addu	$5,$5,$3
	andi	$3,$2,0xffff
	subu	$5,$5,$3
	srl	$2,$2,16
	subu	$5,$5,$2
	lw	$2,36($16)
	addu	$5,$5,$4
	subu	$5,$5,$2
	.set	noreorder
	.set	nomacro
	j	$L647
	addu	$5,$5,$6
	.set	macro
	.set	reorder

$L590:
	lw	$2,32($16)
	lw	$4,36($sp)
	andi	$3,$2,0xffff
	srl	$2,$2,16
	addu	$5,$5,$4
	subu	$5,$5,$3
	lhu	$4,2($23)
	subu	$5,$5,$2
	lw	$3,36($16)
	addu	$5,$5,$4
	lhu	$2,0($17)
	subu	$5,$5,$3
	addu	$5,$5,$2
$L647:
	.set	noreorder
	.set	nomacro
	bgez	$5,$L597
	andi	$2,$5,0xffff
	.set	macro
	.set	reorder

	subu	$5,$0,$5
	sra	$2,$5,16
	andi	$3,$5,0xffff
	addu	$5,$2,$3
	sra	$2,$5,16
	addu	$5,$5,$2
	nor	$2,$0,$5
	.set	noreorder
	.set	nomacro
	j	$L595
	sh	$2,0($17)
	.set	macro
	.set	reorder

$L597:
	sra	$3,$5,16
	addu	$5,$3,$2
	sra	$2,$5,16
	addu	$5,$5,$2
	sh	$5,0($17)
$L595:
	lw	$2,36($16)
	.set	noreorder
	.set	nomacro
	j	$L643
	sh	$2,2($23)
	.set	macro
	.set	reorder

$L599:
	lw	$2,24($16)
	srl	$7,$19,16
	andi	$6,$19,0xffff
	andi	$3,$2,0xffff
	addu	$4,$6,$7
	subu	$4,$4,$3
	srl	$2,$2,16
	lhu	$3,10($18)
	subu	$4,$4,$2
	addu	$4,$4,$3
	.set	noreorder
	.set	nomacro
	bgez	$4,$L601
	andi	$2,$4,0xffff
	.set	macro
	.set	reorder

	subu	$4,$0,$4
	sra	$2,$4,16
	andi	$3,$4,0xffff
	addu	$4,$2,$3
	sra	$2,$4,16
	addu	$4,$4,$2
	nor	$2,$0,$4
	.set	noreorder
	.set	nomacro
	j	$L600
	sh	$2,10($18)
	.set	macro
	.set	reorder

$L601:
	sra	$3,$4,16
	addu	$4,$3,$2
	sra	$2,$4,16
	addu	$4,$4,$2
	sh	$4,10($18)
$L600:
	lw	$2,32($16)
	andi	$8,$20,0xffff
	lw	$5,36($sp)
	andi	$3,$2,0xffff
	srl	$2,$2,16
	addu	$4,$8,$5
	subu	$4,$4,$3
	lhu	$3,10($18)
	subu	$4,$4,$2
	addu	$4,$4,$3
	.set	noreorder
	.set	nomacro
	bgez	$4,$L604
	andi	$2,$4,0xffff
	.set	macro
	.set	reorder

	subu	$4,$0,$4
	sra	$2,$4,16
	andi	$3,$4,0xffff
	addu	$4,$2,$3
	sra	$2,$4,16
	addu	$4,$4,$2
	nor	$2,$0,$4
	.set	noreorder
	.set	nomacro
	j	$L603
	sh	$2,10($18)
	.set	macro
	.set	reorder

$L604:
	sra	$3,$4,16
	addu	$4,$3,$2
	sra	$2,$4,16
	addu	$4,$4,$2
	sh	$4,10($18)
$L603:
	lw	$2,24($sp)
	.set	noreorder
	.set	nomacro
	beq	$2,$0,$L606
	li	$2,17			# 0x11
	.set	macro
	.set	reorder

	bne	$21,$2,$L607
	beq	$17,$0,$L615
	lhu	$5,0($17)
	.set	noreorder
	.set	nomacro
	beq	$5,$0,$L615
	addu	$6,$6,$7
	.set	macro
	.set	reorder

	lw	$2,24($16)
	lhu	$4,0($23)
	andi	$3,$2,0xffff
	srl	$2,$2,16
	subu	$6,$6,$3
	subu	$6,$6,$2
	lw	$2,28($16)
	addu	$6,$6,$4
	subu	$6,$6,$2
	addu	$6,$6,$5
	.set	noreorder
	.set	nomacro
	bgez	$6,$L610
	sra	$3,$6,16
	.set	macro
	.set	reorder

	subu	$6,$0,$6
	sra	$2,$6,16
	andi	$3,$6,0xffff
	addu	$6,$2,$3
	sra	$2,$6,16
	addu	$6,$6,$2
	nor	$2,$0,$6
	.set	noreorder
	.set	nomacro
	j	$L609
	sh	$2,0($17)
	.set	macro
	.set	reorder

$L610:
	andi	$2,$6,0xffff
	addu	$6,$3,$2
	sra	$2,$6,16
	addu	$6,$6,$2
	sh	$6,0($17)
$L609:
	lw	$3,36($sp)
	lw	$2,32($16)
	.set	noreorder
	.set	nomacro
	j	$L648
	addu	$5,$8,$3
	.set	macro
	.set	reorder

$L607:
	lw	$2,24($16)
	addu	$6,$6,$7
	lhu	$4,0($23)
	andi	$3,$2,0xffff
	srl	$2,$2,16
	subu	$6,$6,$3
	subu	$6,$6,$2
	lw	$3,28($16)
	addu	$6,$6,$4
	lhu	$2,0($17)
	subu	$6,$6,$3
	addu	$6,$6,$2
	.set	noreorder
	.set	nomacro
	bgez	$6,$L617
	andi	$2,$6,0xffff
	.set	macro
	.set	reorder

	subu	$6,$0,$6
	sra	$2,$6,16
	andi	$3,$6,0xffff
	addu	$6,$2,$3
	sra	$2,$6,16
	addu	$6,$6,$2
	nor	$2,$0,$6
	.set	noreorder
	.set	nomacro
	j	$L616
	sh	$2,0($17)
	.set	macro
	.set	reorder

$L617:
	sra	$3,$6,16
	addu	$6,$3,$2
	sra	$2,$6,16
	addu	$6,$6,$2
	sh	$6,0($17)
$L616:
	lw	$4,36($sp)
	lw	$2,32($16)
	addu	$5,$8,$4
$L648:
	andi	$3,$2,0xffff
	srl	$2,$2,16
	subu	$5,$5,$3
	lhu	$4,2($23)
	subu	$5,$5,$2
	lw	$3,36($16)
	addu	$5,$5,$4
	lhu	$2,0($17)
	subu	$5,$5,$3
	addu	$5,$5,$2
	.set	noreorder
	.set	nomacro
	bgez	$5,$L620
	andi	$2,$5,0xffff
	.set	macro
	.set	reorder

	subu	$5,$0,$5
	sra	$2,$5,16
	andi	$3,$5,0xffff
	addu	$5,$2,$3
	sra	$2,$5,16
	addu	$5,$5,$2
	nor	$2,$0,$5
	.set	noreorder
	.set	nomacro
	j	$L615
	sh	$2,0($17)
	.set	macro
	.set	reorder

$L620:
	sra	$3,$5,16
	addu	$5,$3,$2
	sra	$2,$5,16
	addu	$5,$5,$2
	sh	$5,0($17)
$L615:
	lw	$2,28($16)
	sh	$2,0($23)
	lw	$2,36($16)
	sh	$2,2($23)
$L606:
	lw	$2,24($16)
	sw	$2,12($18)
$L643:
	lw	$2,32($16)
	sw	$2,16($18)
$L539:
	lw	$3,104($fp)
	li	$2,-805371904			# 0xcfff0000
	ori	$2,$2,0xffff
	and	$3,$3,$2
	lw	$2,28($fp)
	sw	$3,104($fp)
	lw	$2,12($2)
	sw	$2,24($fp)
	lw	$5,48($16)
	lw	$6,52($16)
	.set	noreorder
	.set	nomacro
	jal	fastpath_set_qos_mark
	move	$4,$fp
	.set	macro
	.set	reorder

	lui	$2,%hi(jiffies)
	lw	$2,%lo(jiffies)($2)
	move	$4,$18
	move	$5,$23
	move	$6,$fp
	.set	noreorder
	.set	nomacro
	jal	fast_path_post_process_xmit_check
	sw	$2,40($16)
	.set	macro
	.set	reorder

	li	$3,1			# 0x1
	.set	noreorder
	.set	nomacro
	beq	$2,$3,$L452
	li	$4,1			# 0x1
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	jal	ip_finish_output3
	move	$4,$fp
	.set	macro
	.set	reorder

	.set	noreorder
	.set	nomacro
	j	$L452
	li	$4,1			# 0x1
	.set	macro
	.set	reorder

$L507:
	lw	$16,64($16)
	j	$L637
$L630:
	lw	$2,24($fp)
	move	$5,$23
	move	$6,$fp
	sw	$2,136($fp)
	lw	$31,84($sp)
	lw	$fp,80($sp)
	lw	$23,76($sp)
	lw	$22,72($sp)
	lw	$21,68($sp)
	lw	$20,64($sp)
	lw	$19,60($sp)
	lw	$18,56($sp)
	lw	$17,52($sp)
	lw	$16,48($sp)
	.set	noreorder
	.set	nomacro
	j	fast_path_post_process_return_check
	addiu	$sp,$sp,88
	.set	macro
	.set	reorder

$L452:
	lw	$31,84($sp)
	move	$2,$4
	lw	$fp,80($sp)
	lw	$23,76($sp)
	lw	$22,72($sp)
	lw	$21,68($sp)
	lw	$20,64($sp)
	lw	$19,60($sp)
	lw	$18,56($sp)
	lw	$17,52($sp)
	lw	$16,48($sp)
	.set	noreorder
	.set	nomacro
	j	$31
	addiu	$sp,$sp,88
	.set	macro
	.set	reorder

	.end	enter_fast_path
	.section	.text.init_table_napt,"ax",@progbits
	.align	2
	.globl	init_table_napt
	.ent	init_table_napt
	.type	init_table_napt, @function
init_table_napt:
	.set	nomips16
	.frame	$sp,64,$31		# vars= 16, regs= 7/0, args= 16, gp= 0
	.mask	0x803f0000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
$L658:
$L699:
	addiu	$sp,$sp,-64
	lui	$2,%hi(malloc_sizes+4)
	sw	$21,52($sp)
	move	$21,$5
	sw	$19,44($sp)
	li	$5,32			# 0x20
	sw	$18,40($sp)
	move	$18,$4
	sw	$17,36($sp)
	sw	$16,32($sp)
	lui	$16,%hi(table_napt)
	sw	$31,56($sp)
	sw	$20,48($sp)
	lw	$4,%lo(malloc_sizes+4)($2)
	jal	kmem_cache_alloc
	move	$19,$16

	li	$3,-1			# 0xffffffff
	move	$17,$2
	beq	$2,$0,$L653
	sw	$2,%lo(table_napt)($16)

$L709:
$L750:
	lui	$2,%hi(napt_list_inuse)
	lui	$20,%hi(napt_list_free)
	sll	$4,$18,1
	addiu	$3,$2,%lo(napt_list_inuse)
	addiu	$6,$20,%lo(napt_list_free)
	addu	$4,$4,$18
	sw	$0,%lo(napt_list_inuse)($2)
	sll	$4,$4,2
	sw	$3,4($3)
	lui	$2,%hi(napt_table_list_max)
	sw	$0,8($3)
	li	$5,32			# 0x20
	sw	$6,4($6)
	sw	$0,8($6)
	sw	$18,%lo(napt_table_list_max)($2)
	jal	__kmalloc
	sw	$0,%lo(napt_list_free)($20)

	sw	$2,0($17)
	lw	$2,%lo(table_napt)($16)
	lw	$2,0($2)
	beq	$2,$0,$L653
	li	$3,-1			# 0xffffffff

	j	$L753
	move	$16,$0

$L817:
	j	$L653
	li	$3,-2			# 0xfffffffe

$L753:
	blez	$18,$L814
	nop

	move	$4,$0
$L758:
	lw	$2,%lo(table_napt)($19)
	addiu	$16,$16,1
	slt	$3,$16,$18
	lw	$2,0($2)
	addu	$2,$4,$2
	sw	$0,8($2)
	lw	$2,%lo(table_napt)($19)
	lw	$2,0($2)
	addu	$2,$4,$2
	sw	$0,0($2)
	lw	$2,%lo(table_napt)($19)
	lw	$2,0($2)
	addu	$2,$4,$2
	addiu	$4,$4,12
	bne	$3,$0,$L758
	sw	$2,4($2)

$L814:
	blez	$21,$L816
	move	$16,$0

$L812:
$L766:
$L807:
	lui	$2,%hi(malloc_sizes+12)
	li	$5,32			# 0x20
	lw	$4,%lo(malloc_sizes+12)($2)
	jal	kmem_cache_alloc
	addiu	$16,$16,1

	addiu	$4,$20,%lo(napt_list_free)
	move	$3,$2
	addiu	$5,$2,44
	beq	$2,$0,$L817
	slt	$6,$16,$21

	sw	$0,44($2)
	lw	$2,4($4)
	sw	$2,48($3)
	lw	$2,4($4)
	sw	$3,0($2)
	lw	$2,8($4)
	sw	$5,4($4)
	addiu	$2,$2,1
	bne	$6,$0,$L812
	sw	$2,8($4)

$L816:
	move	$3,$0
$L653:
	lw	$31,56($sp)
	move	$2,$3
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
	.end	init_table_napt
	.section	.text.init_table_path,"ax",@progbits
	.align	2
	.globl	init_table_path
	.ent	init_table_path
	.type	init_table_path, @function
init_table_path:
	.set	nomips16
	.frame	$sp,64,$31		# vars= 16, regs= 7/0, args= 16, gp= 0
	.mask	0x803f0000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	
$L823:
$L864:
	addiu	$sp,$sp,-64
	lui	$2,%hi(malloc_sizes+4)
	sw	$21,52($sp)
	move	$21,$5
	sw	$19,44($sp)
	li	$5,32			# 0x20
	sw	$18,40($sp)
	move	$18,$4
	sw	$17,36($sp)
	sw	$16,32($sp)
	lui	$16,%hi(table_path)
	sw	$31,56($sp)
	sw	$20,48($sp)
	lw	$4,%lo(malloc_sizes+4)($2)
	jal	kmem_cache_alloc
	move	$19,$16

	li	$3,-1			# 0xffffffff
	move	$17,$2
	beq	$2,$0,$L818
	sw	$2,%lo(table_path)($16)

$L874:
$L915:
	lui	$2,%hi(path_list_inuse)
	lui	$20,%hi(path_list_free)
	sll	$4,$18,1
	addiu	$3,$2,%lo(path_list_inuse)
	addiu	$6,$20,%lo(path_list_free)
	addu	$4,$4,$18
	sw	$0,%lo(path_list_inuse)($2)
	sll	$4,$4,2
	sw	$3,4($3)
	lui	$2,%hi(path_table_list_max)
	sw	$0,8($3)
	li	$5,32			# 0x20
	sw	$6,4($6)
	sw	$0,8($6)
	sw	$18,%lo(path_table_list_max)($2)
	jal	__kmalloc
	sw	$0,%lo(path_list_free)($20)

	sw	$2,0($17)
	lw	$2,%lo(table_path)($16)
	lw	$2,0($2)
	beq	$2,$0,$L818
	li	$3,-1			# 0xffffffff

	j	$L918
	move	$16,$0

$L982:
	j	$L818
	li	$3,-2			# 0xfffffffe

$L918:
	blez	$18,$L979
	nop

	move	$4,$0
$L923:
	lw	$2,%lo(table_path)($19)
	addiu	$16,$16,1
	slt	$3,$16,$18
	lw	$2,0($2)
	addu	$2,$4,$2
	sw	$0,8($2)
	lw	$2,%lo(table_path)($19)
	lw	$2,0($2)
	addu	$2,$4,$2
	sw	$0,0($2)
	lw	$2,%lo(table_path)($19)
	lw	$2,0($2)
	addu	$2,$4,$2
	addiu	$4,$4,12
	bne	$3,$0,$L923
	sw	$2,4($2)

$L979:
	blez	$21,$L981
	move	$16,$0

$L977:
$L931:
$L972:
	lui	$2,%hi(malloc_sizes+20)
	li	$5,32			# 0x20
	lw	$4,%lo(malloc_sizes+20)($2)
	jal	kmem_cache_alloc
	addiu	$16,$16,1

	addiu	$4,$20,%lo(path_list_free)
	move	$3,$2
	addiu	$5,$2,72
	beq	$2,$0,$L982
	slt	$6,$16,$21

	sw	$0,72($2)
	lw	$2,4($4)
	sw	$2,76($3)
	lw	$2,4($4)
	sw	$3,0($2)
	lw	$2,8($4)
	sw	$5,4($4)
	addiu	$2,$2,1
	bne	$6,$0,$L977
	sw	$2,8($4)

$L981:
	move	$3,$0
$L818:
	lw	$31,56($sp)
	move	$2,$3
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
	.end	init_table_path
	.globl	route_list_inuse
	.section	.bss
	.align	2
	.type	route_list_inuse, @object
	.size	route_list_inuse, 12
route_list_inuse:
	.space	12
	.globl	route_list_free
	.align	2
	.type	route_list_free, @object
	.size	route_list_free, 12
route_list_free:
	.space	12
	.globl	napt_list_inuse
	.align	2
	.type	napt_list_inuse, @object
	.size	napt_list_inuse, 12
napt_list_inuse:
	.space	12
	.globl	napt_list_free
	.align	2
	.type	napt_list_free, @object
	.size	napt_list_free, 12
napt_list_free:
	.space	12
	.globl	table_napt
	.align	2
	.type	table_napt, @object
	.size	table_napt, 4
table_napt:
	.space	4
	.local	napt_table_list_max
	.comm	napt_table_list_max,4,4
	.globl	path_list_inuse
	.align	2
	.type	path_list_inuse, @object
	.size	path_list_inuse, 12
path_list_inuse:
	.space	12
	.globl	path_list_free
	.align	2
	.type	path_list_free, @object
	.size	path_list_free, 12
path_list_free:
	.space	12
	.globl	table_path
	.align	2
	.type	table_path, @object
	.size	table_path, 4
table_path:
	.space	4
	.local	path_table_list_max
	.comm	path_table_list_max,4,4
	.globl	udp_cache_list_free
	.align	2
	.type	udp_cache_list_free, @object
	.size	udp_cache_list_free, 12
udp_cache_list_free:
	.space	12
	.globl	udp_cache_table
	.align	2
	.type	udp_cache_table, @object
	.size	udp_cache_table, 4
udp_cache_table:
	.space	4
	.local	max_udp_frag_entry
	.comm	max_udp_frag_entry,4,4
	.ident	"GCC: (GNU) 3.4.6-1.3.6"
