### HMMV - High-speed Move Memory to VRAM

* Opcode: $C0
* Description: In the MSX2 (V9938) Video Display Processor, HMMV is used to rapidly fill a specified rectangular block of VRAM with a single byte. It is referred to as "high-speed" because it writes data directly byte-by-byte instead of performing logical operations pixel-by-pixel, making it the most efficient way to clear a screen or an entire VRAM page.

