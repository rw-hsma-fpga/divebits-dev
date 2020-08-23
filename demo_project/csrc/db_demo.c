#include <stdio.h>
#include "xil_printf.h"
#include "xio.h"
#include "xuartlite.h"
#include "xparameters.h"


// UartLite driver instance
XUartLite Uart;

// Pointer/Array to DiveBits AXI Slave with 4 constant 32-bit registers
volatile u32 *divebits_const_regs = (volatile u32*) XPAR_DIVEBITS_AXI_4_CONSTANT_REGISTERS_0_S00_AXI_BASEADDR;

// Pointer/Array to AXI BRAM (512 x 32b) that has been initialized by divebits_BlockRAM_init
volatile u32 *BRAM = (volatile u32*) XPAR_BRAM_0_BASEADDR;


int main()
{
    int i;

    // Initialize UartLite driver and wait until TX FIFO is empty;
	// this allows the DiveBits AXI Master to send its message first
	XUartLite_Initialize(&Uart, XPAR_UARTLITE_0_DEVICE_ID);
	while(XUartLite_IsSending(&Uart));

	xil_printf("^  Sent to UART by DiveBits AXI Write Master  ^\r\n");

    xil_printf("\r\nMicroBlaze up and running for DiveBits demonstration...\r\n\r\n");

    xil_printf("Contents of divebits_AXI_4_constant_registers\r\n");
    xil_printf("4 read-only 32-bit registers at address 0x%08X:\r\n", XPAR_DIVEBITS_AXI_4_CONSTANT_REGISTERS_0_S00_AXI_BASEADDR);
    xil_printf("---------------------------------------------------\r\n");
    xil_printf("Register 0: 0x%08X\r\n", divebits_const_regs[0]);
    xil_printf("Register 1: 0x%08X\r\n", divebits_const_regs[1]);
    xil_printf("Register 2: 0x%08X\r\n", divebits_const_regs[2]);
    xil_printf("Register 3: 0x%08X\r\n", divebits_const_regs[3]);


    xil_printf("\r\nContent of AXI BRAM (512 x 32b) initialized by divebits_BlockRAM_init:\r\n");
    xil_printf("---------------------------------------------------------------------------------------------------");

    u32 line_addr = XPAR_BRAM_0_BASEADDR;
    for (i = 0; i < 512; i++)
    {
    	if (i%8 == 0)
    	{
    		xil_printf("\r\n@%08X:  ", line_addr);
    		line_addr += 32;
    	}
    	xil_printf("0x%08X ", BRAM[i]);
    }

    xil_printf("\r\n\r\nDiveBits demonstration finished.\r\n");
    return 0;
}
