	.file	"writer.c"
# GNU C17 (Ubuntu 11.4.0-1ubuntu1~22.04.2) version 11.4.0 (x86_64-linux-gnu)
#	compiled by GNU C version 11.4.0, GMP version 6.2.1, MPFR version 4.1.0, MPC version 1.2.1, isl version isl-0.24-GMP

# GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
# options passed: -mtune=generic -march=x86-64 -fasynchronous-unwind-tables -fstack-protector-strong -fstack-clash-protection -fcf-protection
	.text
	.globl	file_dir
	.bss
	.align 8
	.type	file_dir, @object
	.size	file_dir, 8
file_dir:
	.zero	8
	.globl	file_desc
	.align 4
	.type	file_desc, @object
	.size	file_desc, 4
file_desc:
	.zero	4
	.section	.rodata
.LC0:
	.string	"1:'%c' \n"
.LC1:
	.string	"2:'%c' \n"
.LC2:
	.string	"3:'%c' \n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB6:
	.cfi_startproc
	endbr64	
	pushq	%rbp	#
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp	#,
	.cfi_def_cfa_register 6
	subq	$32, %rsp	#,
	movl	%edi, -20(%rbp)	# argc, argc
	movq	%rsi, -32(%rbp)	# argv, argv
# finder-app/writer.c:55:   int   path_str_lnth = strlen (argv[1]);
	movq	-32(%rbp), %rax	# argv, tmp100
	addq	$8, %rax	#, _1
# finder-app/writer.c:55:   int   path_str_lnth = strlen (argv[1]);
	movq	(%rax), %rax	# *_1, _2
	movq	%rax, %rdi	# _2,
	call	strlen@PLT	#
# finder-app/writer.c:55:   int   path_str_lnth = strlen (argv[1]);
	movl	%eax, -4(%rbp)	# _3, path_str_lnth
# finder-app/writer.c:57:   printf("1:'%c' \n", argv[1][0]);
	movq	-32(%rbp), %rax	# argv, tmp101
	addq	$8, %rax	#, _4
	movq	(%rax), %rax	# *_4, _5
# finder-app/writer.c:57:   printf("1:'%c' \n", argv[1][0]);
	movzbl	(%rax), %eax	# *_5, _6
# finder-app/writer.c:57:   printf("1:'%c' \n", argv[1][0]);
	movsbl	%al, %eax	# _6, _7
	movl	%eax, %esi	# _7,
	leaq	.LC0(%rip), %rax	#, tmp102
	movq	%rax, %rdi	# tmp102,
	movl	$0, %eax	#,
	call	printf@PLT	#
# finder-app/writer.c:58:   printf("2:'%c' \n", argv[2][0]);
	movq	-32(%rbp), %rax	# argv, tmp103
	addq	$16, %rax	#, _8
	movq	(%rax), %rax	# *_8, _9
# finder-app/writer.c:58:   printf("2:'%c' \n", argv[2][0]);
	movzbl	(%rax), %eax	# *_9, _10
# finder-app/writer.c:58:   printf("2:'%c' \n", argv[2][0]);
	movsbl	%al, %eax	# _10, _11
	movl	%eax, %esi	# _11,
	leaq	.LC1(%rip), %rax	#, tmp104
	movq	%rax, %rdi	# tmp104,
	movl	$0, %eax	#,
	call	printf@PLT	#
# finder-app/writer.c:59:   printf("3:'%c' \n", argv[2][1]);
	movq	-32(%rbp), %rax	# argv, tmp105
	addq	$16, %rax	#, _12
	movq	(%rax), %rax	# *_12, _13
# finder-app/writer.c:59:   printf("3:'%c' \n", argv[2][1]);
	addq	$1, %rax	#, _14
	movzbl	(%rax), %eax	# *_14, _15
# finder-app/writer.c:59:   printf("3:'%c' \n", argv[2][1]);
	movsbl	%al, %eax	# _15, _16
	movl	%eax, %esi	# _16,
	leaq	.LC2(%rip), %rax	#, tmp106
	movq	%rax, %rdi	# tmp106,
	movl	$0, %eax	#,
	call	printf@PLT	#
# finder-app/writer.c:108:   return 0;
	movl	$0, %eax	#, _23
# finder-app/writer.c:109: }
	leave	
	.cfi_def_cfa 7, 8
	ret	
	.cfi_endproc
.LFE6:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04.2) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:
