#include <os/task.h>
.text
.globl sys_call
.globl divide_error,single_step_exception,nmi,breakpoint_exception,overflow
.globl bounds_check,inval_opcode,copr_not_available,double_fault,copr_seg_overrun,inval_tss
.globl segment_not_present,stack_exception,general_protection,page_fault,untitled,copr_error,exception
.globl hwint00,hwint01,hwint02,hwint03,hwint04,hwint05,hwint06,hwint07,hwint08,hwint09,hwint10
.globl hwint11,hwint12,hwint13,hwint14,hwint15
.globl call_after_fork, sys_call_table

.macro save
	push  %es
	push  %ds
	pushl %eax
	pushl %ebp
	pushl %edi
	pushl %esi
	pushl %edx
	pushl %ecx
	pushl %ebx
.endm

.macro save_no_err_code
	pushl $-1
	save
.endm

.macro GET_CURRENT_EBX
	movl %esp, %ebx
	andl $~4095, %ebx
.endm
.macro enter_kernel
	movw %ss, %bx
	movw %bx, %ds
	movw %bx, %es
	movl %esp, %ebp

	GET_CURRENT_EBX
	incl TASK_LEVEL(%ebx)
.endm

.macro Exception num
	enter_kernel

	pushl %ebp
	pushl $\num
	pushl $(leave_kernel_8)
	jmp do_isr
.endm
	
//异常处理
divide_error:
	save_no_err_code
	Exception 0
single_step_exception:
	save_no_err_code
	Exception 1
nmi:
	save_no_err_code
	Exception 2
breakpoint_exception:
	save_no_err_code
	Exception 3
overflow:
	save_no_err_code
	Exception 4
bounds_check:
	save_no_err_code
	Exception 5
inval_opcode:
	save_no_err_code
	Exception 6
copr_not_available:
	save_no_err_code
	Exception 7
double_fault:
	save
	Exception 8
copr_seg_overrun:
	save_no_err_code
	Exception 9
inval_tss:
	save
	Exception 10
segment_not_present:
	save
	Exception 11
stack_exception:
	save
	Exception 12
general_protection:
	save
	Exception 13
page_fault:
	save
	Exception 14
untitled:
	save
	Exception 15
copr_error:
	save_no_err_code
	Exception 16

//硬件中断处理
.macro hwint num
	save_no_err_code
	enter_kernel

	pushl %ebp
	pushl $\num
	pushl $(leave_kernel_8)
	jmp do_isr
.endm

hwint00:
	hwint 32
hwint01:
	hwint 33
hwint02:
	hwint 34
hwint03:
	hwint 35
hwint04:
	hwint 36
hwint05:
	hwint 37
hwint06:
	hwint 38
hwint07:
	hwint 39
hwint08:
	hwint 40
hwint09:
	hwint 41
hwint10:
	hwint 42
hwint11:
	hwint 43
hwint12:
	hwint 44
hwint13:
	hwint 45
hwint14:
	hwint 46
hwint15:
	hwint 47

#define NR_SYSCALLS 40
bad_info:
	.string "bad sys call"
sys_call:
	save_no_err_code
	enter_kernel
	cmpl $(NR_SYSCALLS), %eax
	jae  1f
	call  *sys_call_table(,%eax,4)
	movl %eax, 24(%esp)
	jmp leave_kernel
1:	push $(bad_info)
	push $(bad_info)
	push $0
	push $(bad_info)
	call __panic

call_after_fork:
	GET_CURRENT_EBX
	movl $0, TASK_LEVEL(%ebx)
	jmp pre_ret


leave_kernel_8:
	addl $8, %esp
leave_kernel:
	GET_CURRENT_EBX
	decl TASK_LEVEL(%ebx)
	jz   3f
	jmp  4f
3:	cmpl $0, TASK_RESCHED(%ebx)
	jz   4f
	cli
	movl $0, TASK_RESCHED(%ebx)
	call task_sched
4:	movl %ebp, %esp
pre_ret:
	popl %ebx
	popl %ecx
	popl %edx
	popl %esi
	popl %edi
	popl %ebp
	popl %eax
	pop  %ds
	pop  %es
	addl $4, %esp
	iretl


sys_call_table:
	.long 0	                /* 0 */
	.long 0
	.long 0
	.long 0
	.long 0
	.long 0                 /* 5 */
	.long 0
	.long sys_sbrk
	.long sys_fork
	.long sys_exit
	.long sys_get_ticks	/* 10 */
	.long sys_get_utime
	.long sys_get_stime
	.long sys_waitpid
	.long sys_execve
	.long 0			/* 15 */
	.long 0
	.long sys_gettime
	.long 0
	.long sys_pause
	.long 0			/* 20 */
	.long 0
	.long sys_getpid
	.long sys_getppid
	.long sys_shm_get
	.long sys_shm_at	/* 25 */
	.long sys_shm_dt
	.long sys_shm_free
	.long sys_open
	.long sys_read
	.long sys_write		/* 30 */
	.long sys_close
	.long sys_nice
	.long sys_vfork
	.long sys_ioctl
	.long sys_dup2		/* 35 */
	.long sys_mknod
	.long sys_readdir
	.long sys_fstat
	.long sys_lseek
