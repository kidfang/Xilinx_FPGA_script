#!/bin/bash
#!/bin/sh

path=$('pwd')
gpu_num=$(xbutil list | grep xilinx | wc -l)
#file_name=FPGA_power_
file_name=dev

for (( GPU=0; GPU<$gpu_num; GPU=GPU+1 ));
do
	FPGA_info=$(cat $path/$file_name$GPU* | tail -n 1 | grep -i "current Power" | awk '{print $5 " " $6 " " $8 " " $10 " " $11 " " $12 " " $13 " " $14 " " $15}')
	kk=0

	until [[ $FPGA_info = *[!\ ]* ]]; 
	do
		FPGA_info=$(cat $path/$file_name$GPU* | tail -n 1 | grep -i "current Power" | awk '{print $5 " " $6 " " $8 " " $10 " " $11 " " $12 " " $13 " " $14 " " $15}')
		FPGA_end_check=$(cat $path/$file_name$GPU* | egrep -i "RESULT: ALL TESTS PASSED| RESULT: SOME TESTS FAILED")
		if [[ $FPGA_info = *[!\ ]* ]]; then
			FPGA_info_n=$FPGA_info
		elif [[ $FPGA_end_check = *[!\ ]* ]]; then
			FPGA_info=$FPGA_end_check
		elif [ $kk -gt 100 ]; then
			FPGA_info="Test Initializing or End, or get something wrong.."
		else
			sleep 0.01
			kk=$(($kk +1))
		fi

	done

	FPGA_info_n=$FPGA_info
	echo FPGA["$GPU"] $FPGA_info_n
done
