#ifndef _ARCH_CONFIG_H_
#define _ARCH_CONFIG_H_
#include <lib/klib.h>

/* about timer */
#include <drv/pit_i8253.h>
#define timer_dev_desc (i8253_dev_desc)
#define TIMER_CMD_SETFREQ I8253_CMD_SETFREQ

/* about rtc */
#include <drv/cmos.h>
#define rtc_dev_desc (cmos_dev_desc)
#define RTC_CMD_READ (CMOS_CMD_READ_RTC)

/* about PIC */
#include <os/pic.h>

#define IRQ_0           0
#define IRQ_8           8

#define IRQ_TIMER		0
#define IRQ_KB			1
#define IRQ_MOUSE		12


/* about memory */
#define PAGE_SHIFT 12
#define PAGE_SIZE  (1 << PAGE_SHIFT)
#define PAGE_MASK  (~(PAGE_SIZE - 1))
#define PDE_COUNT  1024
#define PTE_COUNT  1024

static inline void *__task_addr()
{
	return kmalloc(1024*1024);
}
#define task_addr		__task_addr()

#define message_buffer		0x800000
#define message_buffer_len	0x100000
#define kmalloc_mem_start	0x900000

#define page_info_addr		0xe00000

#define kernel_brk		0x1000000
#define app_entry		(kernel_brk+0x100)
#define app_start		(kernel_brk)
#define usr_stack_top		0x80000000
#define	max_usr_pde		(usr_stack_top/PAGE_SIZE/PDE_COUNT)
#define normal_stack_size	0x1000000	//16M

/* realmode */
void real_mode_int(int vec,int *eax,int *ebx);
#endif /* _ARCH_CONFIG_H_ */
