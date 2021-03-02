/*
 *  * Copyright (c) 2004 Xilinx, Inc.  All rights reserved.
 *
 * Xilinx, Inc.
 * XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" AS A 
 * COURTESY TO YOU.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
 * ONE POSSIBLE   IMPLEMENTATION OF THIS FEATURE, APPLICATION OR 
 * STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION 
 * IS FREE FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE 
 * FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION
 * XILINX EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO 
 * THE ADEQUACY OF THE IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO 
 * ANY WARRANTIES OR REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE 
 * FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY 
 * AND FITNESS FOR A PARTICULAR PURPOSE.
 */

/*
 * Xilinx EDK 8.1.02 EDK_I.20.4
 *
 * This file is a sample test application
 *
 * This application is intended to test and/or illustrate some 
 * functionality of your system.  The contents of this file may
 * vary depending on the IP in your system and may use existing
 * IP driver functions.  These drivers will be generated in your
 * XPS project when you run the "Generate Libraries" menu item
 * in XPS.
 *
 * Your XPS project directory is at:
 *    C:\projects\a2600_mb\xilinx\edk\
 */


// Located in: microblaze_0/include/xparameters.h
#include "xparameters.h"
#include "xgpio_l.h"
#include "stdio.h"
#include "xutil.h"

//====================================================

int main (void) {


   //printf("-- Entering main() --\r\n");

   /* 
    * MemoryTest routine will not be run for the memory at 
    * 0x00000000 (dlmb_cntlr)
    * because it is being used to hold a part of this application program
    */

    #define SYSTEM_RESET         0xA0
    #define GAME_START_PRESSED   0xA1
    #define GAME_START_RELEASED  0xA2
    #define GAME_SEL_PRESSED     0xA3
    #define GAME_SEL_RELEASED    0xA4
    #define UPLOAD_MODE          0xA5
    #define SET_LEFT_DIFF        0xA6
    #define CLEAR_LEFT_DIFF      0xA7
    #define SET_RIGHT_DIFF       0xA8
    #define CLEAR_RIGHT_DIFF     0xA9
    #define SET_COLOR            0xAA
    #define CLEAR_COLOR          0xAB
    #define ROM_EMULATOR_BAR     0x20040000

    #define ATARI_STD_2K         2048
    #define ATARI_STD_4K         4096
    #define ATARI_STD_8K         8192
    #define ATARI_STD_16K        16384
    #define ATARI_STD_32K        32768

    // Key critical bytes that we need to watch for.
    //const unsigned char SYSTEM_RESET        = 0xA0;
    //const unsigned char GAME_START_PRESSED  = 0xA1;
    //const unsigned char GAME_START_RELEASED = 0xA2;
    //const unsigned char GAME_SEL_PRESSED    = 0xA3;
    //const unsigned char GAME_SEL_RELEASED   = 0xA4;
    //const unsigned char UPLOAD_MODE         = 0xA5;
    //const unsigned char SET_LEFT_DIFF       = 0xA6;
    //const unsigned char CLEAR_LEFT_DIFF     = 0xA7;
    //const unsigned char SET_RIGHT_DIFF      = 0xA8;
    //const unsigned char CLEAR_RIGHT_DIFF    = 0xA9;
    //const unsigned char SET_COLOR           = 0xAA;
    //const unsigned char CLEAR_COLOR         = 0xAB;
    

    const    char       running     = 1;
    unsigned char       in_char;
    unsigned char*      mem_ptr     = (unsigned char *)ROM_EMULATOR_BAR;
    unsigned char*      char_ptr    = (unsigned char *)ROM_EMULATOR_BAR;
    unsigned short int  inbound     = 0;
    char                byte_cnt    = 1;
    char                mode        = 0;
    unsigned int        gpioreg     = 0xffffffff;
    unsigned int        length      = 0;
    char                got_len_low = 0;
             int        xfer_cnt    = 0;
             int        block_cnt   = 0;
    


    // Loop for all eternity
    while (running == 1) {

        // We will not do anything until we receive the instruction
        // to wake up...
        if (mode == 0) {

            in_char = XUartLite_RecvByte(XPAR_RS232_BASEADDR);
            xil_printf("Got Value 0x%x\n",in_char);

            if (in_char == SYSTEM_RESET) {

                xil_printf("You woke up the Atari...good\n");
                mode = 1;
            }

        // Mode where we are receiving a length...
        } else if (mode == 2) {

            in_char = XUartLite_RecvByte(XPAR_RS232_BASEADDR);

            // First bytes received when we are receiving a file
            // indicate the length of the file...
            if (got_len_low == 0) {

                length = (unsigned int)in_char;
                got_len_low = 1;

            } else {

                length = (((unsigned int)in_char << 8) | length);
                xil_printf("Got Length %d\n",length);

                // Clear out bits that indicate bankswitching...
                gpioreg = (gpioreg & 0xffff00ff);
                
                // Set up the bankswitch method based on length
                switch (length)
                {

                    case ATARI_STD_2K  : gpioreg = (gpioreg | (0x00 << 8));
                                         XGpio_mWriteReg(XPAR_GENERIC_GPIO_BASEADDR,0,gpioreg);
                                         break;

                    case ATARI_STD_4K  : gpioreg = (gpioreg | (0x01 << 8));
                                         XGpio_mWriteReg(XPAR_GENERIC_GPIO_BASEADDR,0,gpioreg);
                                         break;

                    case ATARI_STD_8K  : gpioreg = (gpioreg | (0xF8 << 8));
                                         XGpio_mWriteReg(XPAR_GENERIC_GPIO_BASEADDR,0,gpioreg);
                                         break;

                    case ATARI_STD_16K : gpioreg = (gpioreg | (0xF6 << 8));
                                         XGpio_mWriteReg(XPAR_GENERIC_GPIO_BASEADDR,0,gpioreg);
                                         break;

                    case ATARI_STD_32K : gpioreg = (gpioreg | (0xf4 << 8));
                                         XGpio_mWriteReg(XPAR_GENERIC_GPIO_BASEADDR,0,gpioreg);
                                         break;

                }

                // Set bit six...
                gpioreg = (gpioreg | 0x00000040);

                // Write GPIO back with the proper bit cleared...
                XGpio_mWriteReg(XPAR_GENERIC_GPIO_BASEADDR,0,gpioreg);

                got_len_low = 0;
                mode = 3;
                mem_ptr = (unsigned char *)ROM_EMULATOR_BAR;
                byte_cnt  = 0;
                block_cnt = 0;
                
            }

        // Here we load the inbound bytes into memory
        } else if (mode == 3) {

            for (xfer_cnt = 0; xfer_cnt < length; xfer_cnt++) {

                in_char = (char)XUartLite_RecvByte(XPAR_RS232_BASEADDR);
                byte_cnt++; // Increment byte counter
                //inbound = ((in_char << ((2-byte_cnt) * 8)) | inbound);
                *mem_ptr = (unsigned char)in_char;
                mem_ptr++;
                
                //// See if we need to commit the current dword to memory...       	 
                //if (byte_cnt == 2) {
                //    *mem_ptr = inbound;
                //    mem_ptr = mem_ptr++;
                //    inbound = 0;
                //    byte_cnt = 0;
                //}

                if (xfer_cnt == 1000) {xil_printf("got 1000 bytes\n");}
                if (xfer_cnt == 2000) {xil_printf("got 2000 bytes\n");}
                if (xfer_cnt == 3000) {xil_printf("got 3000 bytes\n");}
                if (xfer_cnt == 4000) {xil_printf("got 4000 bytes\n");}

            }

            // Clear bit six...
            //for (xfer_cnt = 0; xfer_cnt < length; xfer_cnt++) {
            //for (xfer_cnt = 0; xfer_cnt < length; xfer_cnt++) {

              
            //    in_char = *char_ptr;
            //    xil_printf("Address 0x%x : 0x%x\n", char_ptr, in_char);
            //    char_ptr++;
                 
           // }






            gpioreg = (gpioreg & 0xffffffbf);
            // Write GPIO back with the proper bit cleared...
            XGpio_mWriteReg(XPAR_GENERIC_GPIO_BASEADDR,0,gpioreg);
            xil_printf("Got file!!!", xfer_cnt);

            // We're done receiving bytes...
            mode = 1;

        // Here we simply listen for requests to change the state of the
        // program or assert/deassert GPIO....        
        } else {

            in_char = XUartLite_RecvByte(XPAR_RS232_BASEADDR);
            xil_printf("Got Value 0x%x\n",in_char);

            switch (in_char) 
            {

                // When we get a system reset, we simply
                // Put the core Atari system into reset and
                // place all GPIO back into a high state.
                case SYSTEM_RESET        : 

                     // Put Atari 2600 component into "hardware" reset mode
                     xil_printf("You put the Atari to sleep...\n");
                     mode = 0;
                     break;   

                // In this case, we must pull the game start signal low.
                case GAME_START_PRESSED  :

                     // Clear bit zero...
                     gpioreg = (gpioreg & 0xfffffffe);

                     // Write GPIO back with the proper bit cleared...
                     XGpio_mWriteReg(XPAR_GENERIC_GPIO_BASEADDR,0,gpioreg);
               
                     break;   

                // In this case we must pull the game start signal high.
                case GAME_START_RELEASED :

                     // Set bit zero...
                     gpioreg = (gpioreg | 0x00000001);
                     // Write GPIO back with the proper bit cleared...
                     XGpio_mWriteReg(XPAR_GENERIC_GPIO_BASEADDR,0,gpioreg);

                     break;   

                // Pull game select signal low.
                case GAME_SEL_PRESSED    :

                     // Clear bit one...
                     gpioreg = (gpioreg & 0xfffffffd);
                     // Write GPIO back with the proper bit cleared...
                     XGpio_mWriteReg(XPAR_GENERIC_GPIO_BASEADDR,0,gpioreg);

                     break;   

                // Pull the game select signal high.
                case GAME_SEL_RELEASED   :

                     // Set bit zero...
                     gpioreg = (gpioreg | 0x00000002);
                     // Write GPIO back with the proper bit cleared...
                     XGpio_mWriteReg(XPAR_GENERIC_GPIO_BASEADDR,0,gpioreg);

                     break;   

                // Enter the mode where we transfer a game to memory.
                case UPLOAD_MODE         :

                     xil_printf("Receiving File!\n");
                     
                     //Switch the mode so that we can receive files.
                     mode = 2;

                     break;   

                // Pull Diff. A bit high
                case SET_LEFT_DIFF       :

                     // Set bit three...
                     gpioreg = (gpioreg | 0x00000008);
                     // Write GPIO back with the proper bit cleared...
                     XGpio_mWriteReg(XPAR_GENERIC_GPIO_BASEADDR,0,gpioreg);

                     break;   

                // Pull Diff. A bit low
                case CLEAR_LEFT_DIFF     :

                     // Clear bit three...
                     gpioreg = (gpioreg & 0xfffffff7);
                     // Write GPIO back with the proper bit cleared...
                     XGpio_mWriteReg(XPAR_GENERIC_GPIO_BASEADDR,0,gpioreg);
                     break;   

                // Pull Diff. B bit high
                case SET_RIGHT_DIFF      :

                     // Set bit three...
                     gpioreg = (gpioreg | 0x00000004);
                     // Write GPIO back with the proper bit cleared...
                     XGpio_mWriteReg(XPAR_GENERIC_GPIO_BASEADDR,0,gpioreg);
                     break;   

                // Pull Diff. B bit low
                case CLEAR_RIGHT_DIFF    :

                     // Clear bit two...
                     gpioreg = (gpioreg & 0xfffffffb);
                     // Write GPIO back with the proper bit cleared...
                     XGpio_mWriteReg(XPAR_GENERIC_GPIO_BASEADDR,0,gpioreg);
                     break;   

                // Pull Color/BW bit high
                case SET_COLOR           :

                     // Set bit five...
                     gpioreg = (gpioreg | 0x00000010);
                     // Write GPIO back with the proper bit cleared...
                     XGpio_mWriteReg(XPAR_GENERIC_GPIO_BASEADDR,0,gpioreg);
                     break;   

                // Pull Color/BW bit low
                case CLEAR_COLOR         :

                     // Clear bit five...
                     gpioreg = (gpioreg & 0xffffffef);
                     // Write GPIO back with the proper bit cleared...
                     XGpio_mWriteReg(XPAR_GENERIC_GPIO_BASEADDR,0,gpioreg);
                     break;   

                default                  : 
                     xil_printf("Unknown request received\n");
                     break;

            }

        }

   }

   return 0;
}

