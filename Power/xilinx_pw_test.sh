#!/bin/bash
#!/bin/sh

path=$('pwd')
gpu_num=$(xbutil list | grep xilinx | wc -l)

for (( GPU=0; GPU<$gpu_num; GPU=GPU+1 ));
do
	xbtest -j power.json -d $GPU | tee $path/FPGA_power_$GPU.txt &
done

rm -f $path/connectivity*
