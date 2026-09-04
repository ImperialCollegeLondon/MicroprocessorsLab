# VS Code + PICkit 4 Setup for PIC18F87K22 Assembly

## Summary

This document captures the findings from setting up a PIC18 assembly project in VS Code with MPLAB for VS Code, PICkit 4 programmer, and the ICD debugger.

---

## What Works

### Programming the Device

1. **Configuration**: The project is configured for `PIC18F87K22`, `pic-as` v3.10, and `PICkit 4`.
2. **Build**: Click the MPLAB **Build** icon or run `MPLAB: Build Project` from the command palette.
3. **Program**: Click **Program Device** or use `MPLAB: Program Device`.
4. **Result**: The PICkit 4 successfully programs the device with the built HEX file.

### Debugging with Breakpoints

1. **Configuration**: Use the **Debug** configuration in MPLAB Project Properties.
2. **Build**: Use **Debug - Build** to generate debug symbols.
3. **Settings Fix**: Add this to `.vscode/settings.json` to enable breakpoint support:
   ```json
   "debug.allowBreakpointsEverywhere": true
   ```
4. **File Association**: Add this to `.vscode/settings.json`:
   ```json
   "files.associations": {
       "*.s": "pic-as"
   }
   ```
5. **Breakpoints**: Press `F9` or click in the left gutter beside an instruction to set a breakpoint.
6. **Debug**: Click **Start Debugging** to connect the ICD and pause at breakpoints.
7. **Inspection**: While paused, inspect the registers exposed by the adapter in the **Variables/Watch** panel:
   - `TABLAT`, `TBLPTRU`, `TBLPTRH`, `TBLPTRL` (program memory access)
   - `FSR0`, `FSR1`, `FSR2` (RAM pointers)
   - `WREG`, `STATUS` (working register and flags)
  - General RAM symbols such as `counter` and `myArray` are exported, but are not resolved by the VS Code Watch view.

### Symbol Export

Add `global` declarations to [main.s](main.s) so the debugger can resolve variable names:

```asm
global counter, delay_count, myArray
```

After rebuilding, the symbols are present in `out/Simple1/Debug.sym`, but the MPLAB debug adapter does not reliably resolve assembly RAM symbols in the Watch view.

### Debug Build and Linker Map

- Build the **Debug** configuration with **Debug - Build**.
- The Debug image is written to `out/Simple1/Debug.elf`.
- The linker map is written to `_build/Simple1/Debug/output.map`.
- The Debug map includes all four source files, including `LCD.s`, and records:
  - `counter`: RAM address `0x005`
  - `myArray`: RAM range `0x400`-`0x47F`
  - `myTable`: program-memory address `0x1FED8`

The older path `dist/default/debug/MicroprocessorsLab.debug.map` does not apply to the current CMake/Ninja build layout.

### Stepping and Breakpoint Behaviour

PIC18 debugging through the PICkit/MPLAB adapter reports the program counter after an instruction has executed. Consequently, a breakpoint on one instruction may display the following source line. For example, a breakpoint on:

```asm
bcf     CFGS
```

may display the following `bsf EEPGD` line after `bcf` has executed. A breakpoint on a `call` may display the called routine's first line because the call has already executed.

**Step Over** uses a temporary breakpoint at the return address. With consecutive calls, such as:

```asm
call    UART_Setup
call    LCD_Setup
```

the adapter can execute the second call before stopping, which appears to enter `LCD_Setup`. For more predictable stepping, place a harmless spacer instruction between calls while debugging:

```asm
call    UART_Setup
nop
call    LCD_Setup
```

The `nop` breakpoint may display `call LCD_Setup`; this means the `nop` has executed and the LCD call has not yet executed. For normal runs, use **Continue** with a breakpoint after the setup calls instead of relying on source-level Step Over.

---

## Limitations

### Memory Inspector

- **Program Memory**: Can view as raw hex bytes, but no disassembly.
- **Data Memory/RAM**: Displays `FF` or a blank value; not compatible with PIC18 memory spaces.
- **Workaround**: Use the linker map to determine addresses:
  - `counter`: RAM `0x005`
  - `myArray`: RAM `0x400`–`0x47F` (confirmed from `_build/Simple1/Debug/output.map`)
  - `myTable`: Program memory `0x1FED8`
  - At breakpoints, inspect `TABLAT`, `FSR0`, and pointer registers instead.

The Watch expression `*(unsigned char *)0x005` returns `E_FAILED`, and entering `0x005` produces no value. This confirms that the current debug adapter does not support C-style memory dereferences or direct PIC18 data-memory inspection in VS Code.

### Disassembly View

- **Not Available**: The installed MPLAB debug adapter does not expose a disassembly or program-memory view.
- **Workaround**: Use **MPLAB X IDE** for detailed program-memory inspection:
  ```text
  Window → PIC Memory Views → Program Memory
  ```

### Syntax Highlighting

- **Limited Grammar**: The PIC-AS language mode does not provide complete syntax colouring.
- **Affects**: Mnemonics, directives, and operands may not highlight consistently.
- **Workaround**:
  - Keep `.s` files associated with `pic-as` for correct build/debug configuration.
  - Consider installing a third-party **PIC/MPASM assembly** extension for better colours (but test integration with MPLAB first).
  - Use MPLAB X for full IDE support if colouring is critical.

---

## Project-Specific Configuration

### File: `.vscode/settings.json`

```json
{
    "mplab.clangd.compileCommandsDir": "${workspaceFolder}\\_build\\Simple1\\default",
    "files.associations": {
        "*.s": "pic-as"
    },
    "debug.allowBreakpointsEverywhere": true,
    "memory-inspector.debugTypes": [
        "arm-debugger",
        "embedded-debug",
        "gdb",
        "mplab-core-da"
    ]
}
```

### MPLAB Project Properties

- **Device**: `PIC18F87K22`
- **Tool**: `PICkit 4`
- **Configurations**: `default` (production build), `Debug` (debug build with symbols)
- **Debug Startup**: Use system settings (should stop at entry point `rst`).

---

## Typical Workflow

1. **Edit** assembly source in VS Code.
2. **Build** the Debug configuration.
3. **Set breakpoint** on an instruction (e.g., `lfsr 0, myArray` or `tblrd*+`).
4. **Connect** PICkit 4 to the ICSP pins and USB.
5. **Power** the target board externally.
6. **Start Debugging** from the MPLAB sidebar.
7. **Inspect** exposed registers at breakpoints using the Variables/Watch panel; use `TABLAT` and `FSR0` for the table-copy loop.
8. **Continue** to progress through setup and subroutine calls. Use **Step Over** cautiously around consecutive calls.
9. **Stop** debugging when complete.

---

## When to Use MPLAB X IDE

- Detailed program-memory inspection with disassembly.
- SFR and peripheral registers.
- Full EEPROM and configuration memory views.
- Advanced profiling and real-time watches.
- More mature PIC18 syntax highlighting.

---

## Key Files

- [main.s](main.s) — Main program entry point.
- [UART.s](UART.s) — UART setup and transmission.
- [LCD.s](LCD.s) — LCD setup and data write.
- [config.s](config.s) — Configuration bits for PIC18F87K22.
- [.vscode/settings.json](.vscode/settings.json) — VS Code workspace settings.
- [.vscode/Simple1.mplab.json](.vscode/Simple1.mplab.json) — MPLAB project metadata.
- [_build/Simple1/Debug/output.map](_build/Simple1/Debug/output.map) — Linker map with symbol addresses.

---

## Notes

- The PICkit 4 connects via standard ICSP pins: `MCLR/VPP`, `VDD`, `VSS`, `PGC`, `PGD`.
- UART output appears on `RC6` at 9600 baud, 8-N-1; connect a USB-to-UART adapter separately to observe console output.
- LCD output appears on `RB0`–`RB5` (4-bit mode).
- This setup is suitable for rapid compile-test-debug cycles within VS Code for assembly-level development on PIC18.
