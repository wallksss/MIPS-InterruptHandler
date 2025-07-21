# MIPS Interrupt and Exception Handler

This project provides a basic but comprehensive interrupt and exception handler for the MIPS32 architecture, designed to be run and tested within the MARS (MIPS Assembler and Runtime Simulator) environment. It demonstrates fundamental concepts of low-level operating system design, including context switching, exception cause identification, and handling of both synchronous exceptions and asynchronous hardware interrupts.

## Project Overview

The system is composed of two main parts:
1.  `handler.asm`: A kernel-level handler responsible for catching, identifying, and managing all exceptions and interrupts. It is loaded at the MIPS-designated exception vector address (`0x80000180`).
2.  `main.asm`: A user-level test program that intentionally triggers a series of different exceptions to demonstrate that the handler works correctly. After triggering exceptions, it enables keyboard interrupts and enters an infinite loop, simulating a process waiting for I/O.

### Key Features
*   **Handles Multiple Exceptions**: Catches and reports various common exceptions, including:
    *   Arithmetic Overflow (`Ov`)
    *   Bad Address on Load (`AdEL`)
    *   Bad Address on Store (`AdES`)
    *   Breakpoint (`Bp`)
    *   Trap (`Tr`)
*   **Hardware Interrupt Handling**: Implements a handler for keyboard input using Memory-Mapped I/O (MMIO).
*   **Context Safety**: Properly saves and restores the user program's context (registers) on a dedicated kernel stack, ensuring the user program can resume correctly after the handler finishes.
*   **Coprocessor 0 Interaction**: Uses CP0 registers (`Cause`, `Status`, `EPC`) to determine the cause of an exception and to manage the system state.
*   **Educational Focus**: The code is well-commented and structured to serve as a learning tool for students of computer architecture and operating systems.

## Technologies Used
*   **MIPS32 Assembly Language**
*   **MARS (MIPS Assembler and Runtime Simulator)**: The project is designed specifically for the MARS simulator.

## How to Install and Execute

### Prerequisites
*   **Java Runtime Environment (JRE)**: MARS is a Java application and requires a JRE to run.
*   **MARS Simulator**: You must have the MARS simulator. You can download it from its [https://dpetersanderson.github.io/](official page).

### Step-by-Step Instructions

1.  **Configure MARS to Use the Custom Handler**:
    *   Launch the MARS simulator (`Mars4_5.jar` or similar).
    *   In the menu bar, navigate to **Settings** -> **Exception Handler**.
    *   In the dialog box that appears, check the box labeled **Include this exception handler file in all assemble operations**.
    *   Click the `...` button and select the `handler.asm` file from this project.
    *   Click "OK" to save the settings. MARS is now configured to automatically use `handler.asm` as the exception handler for any program you run.

2.  **Open and Run the Test Program**:
    *   In the menu bar, go to **File** -> **Open...** and select the `main.asm` file.
    *   Assemble the program by clicking the **Assemble** icon (screwdriver and wrench) or by pressing `F3`.
    *   Open the MMIO tool by navigating to **Tools** -> **Keyboard and Display MMIO Simulator**.
    *   A new window will appear. Click the **Connect to MIPS** button inside this window.

3.  **Observe the Execution**:
    *   Run the program by clicking the **Run** icon (green play button) or by pressing `F5`.
    *   In the **MARS Messages** console at the bottom of the main window, you will see output from the handler as `main.asm` triggers each exception in sequence (overflow, bad address, etc.).
    *   After the exceptions are handled, the program will appear to be "stuck" in its infinite loop.
    *   Now, click inside the text area of the **Keyboard and Display MMIO Simulator** window and type something. Each key you press will trigger a hardware interrupt, and the handler will print the character you typed to the **MARS Messages** console.
