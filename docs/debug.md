# Debug Interface

## Commands

- `OO OO` is always a 16 bit little endian offset
- `LL LL` is always a 16 bit little endian length
- `WW WW` is a generic 16 bit little endian value
- `BB` is a generic byte value
- `AN` is either ACK (0x06) or NAK (0x15) for success/failure marking
- `……` is a placeholder for byte sequence of undefined length

| Command     | Send                | Receive                            | Desc                                                   |
| ----------- | ------------------- | ---------------------------------- | ------------------------------------------------------ |
| `reset`     | `00`                | -                                  | Resets the whole system.                               |
| `softreset` | `01`                | `AN`                               | Resets the cpu.                                        |
| `read8`     | `02 OO OO`          | `BB AN`                            | Reads a single byte from memory.                       |
| `write8`    | `03 OO OO BB`       | `AN`                               | Writes a single byte to memory.                        |
| `read16`    | `04 OO OO`          | `WW WW AN`                         | Reads a single word from memory.                       |
| `write16`   | `05 OO OO WW WW`    | `AN`                               | Writes a single word to memory.                        |
| `halt`      | `06`                | `AN`                               | Halts the CPU execution.                               |
| `tick`      | `07`                | `AN`                               | Steps the CPU for a single clock cycle.                |
| `step`      | `08`                | `AN`                               | Steps the CPU for a single instruction.                |
| `resume`    | `09`                | `AN`                               | Resumes the CPU execution.                             |
| `load`      | `0A OO OO LL LL ……` | `AN`                               | Loads sequential data into memory.                     |
| `dump`      | `0B OO OO LL LL`    | `…… AN`                            | Sends all data between 0xOOOO and 0xOOOO+0xLLLL        |
| `regdump`   | `0C`                | `WW WW WW WW WW WW WW WW WW WW AN` | Dumps all CPU register values. Sends SP, BP, IP, FR,IR |
| `intr`      | `0D BB`             | `AN`                               | Triggers the interrupt given by the byte.              |
