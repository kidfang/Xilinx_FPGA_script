#!/bin/bash
#!/bin/sh

path=$('pwd')
gpu_num=$(xbutil list | grep xilinx | wc -l)
#gpu_num=2

for (( GPU=0; GPU<$gpu_num; GPU=GPU+1 ));
do
#	BDF=$(xbutil list | grep -F ["$GPU"] | awk '{print $2 }')
#	xbtest -j power_test.json -d $BDF | tee $path/FPGA_power_$GPU.txt &
	cat FPGA_power_"$GPU".txt | grep -i temp | tail -n 1

done

#rm -f $path/connectivity*
