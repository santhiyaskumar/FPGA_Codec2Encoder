# FPGA_Codec2Encoder
Hardware Implementation of low-bit rate Codec, Codec2 in Verilog RTL on Cyclone IV FPGA.

Codec2 is an open-source and patent-free audio codec that operates at a compressed lowest bit rate at the publication date of this work. The current implementation is in C and can be run on microprocessors. The key benefit of this core is that it has been developed without any existing commercial ties, and researchers and developers can use this codec for any application without restriction.

This thesis implements a Register Transfer Level (RTL) version of Codec2 on a Field Programmable Gate Array (FPGA) using Verilog HDL. The questions for this exercise are to see what trade-offs in terms of computation speed and silicon area consumption a hardware implementation of the Codec2 encoder on FPGA results in compared to a software implementation running on a microprocessor. We hypothesize that a hardware implementation can be faster than a software implementation on a microprocessor due to custom parallel implementation capabilities possible on FPGA. Also, the creation of this hardware core will allow future chip designers to test and implement Codec2 on other FPGAs and even ASIC versions of this core (if the market demand ever is high enough to justify the high cost of manufacturing ASICs). To verify our hypothesis, we implemented and tested a Codec2 encoder in Verilog and mapped it to Terasic's DE2-115 prototyping board with an Intel Cyclone IV FPGA. We observe and report the speed and area consumption of this implementation and compare it to the Codec2 running on a RaspberryPi, including its ARM processor. From this experiment, we are not conclusively determining that the hardware core is faster than a software implementation, but provide insight for future designers on the capabilities and costs of a hardware implementation of the Codec2.

Learn more about Codec2 :
http://www.rowetel.com/wordpress/?page_id=452

To downlaod run FPGA_Codec2Encoder:
Please refer https://github.com/santhiyaskumar/FPGA_Codec2Encoder/wiki/Codec2_Encoder_2400_Verilog

Detailed implementation steps are discussed in the Thesis document.
Link download the Master Thesis: 

