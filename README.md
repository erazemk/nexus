# Nexus

Nexus is an interpreter for a custom programming language, made for Xilinx's Nexys A7 FPGA.


## Design

![](Nexus.png)

## Language syntax

The syntax is very simple and supports programming some of Nexys A7's outputs, such as LEDs.

Syntax: `[INSTRUCTION] (PARAMETERS)`

### LEDs

Syntax: `LED [id] [state]`
- `state` is either `ON` or `OFF`

Examples:
```
LED 0 ON
LED 1 OFF
```


## License

The project is licensed under the [MIT license](LICENSE).
