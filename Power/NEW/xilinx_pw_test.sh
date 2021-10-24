#!/bin/bash
#!/bin/sh

path=$('pwd')
gpu_num=$(xbutil list | grep xilinx | wc -l)

for (( GPU=0; GPU<$gpu_num; GPU=GPU+1 ));
do
	BDF=$(xbutil list | grep -F ["$GPU"] | awk '{print $2 }')
	xbtest -j stress.json -d $BDF | tee $path/FPGA_power_$GPU.txt &
done

#rm -f $path/connectivity*
