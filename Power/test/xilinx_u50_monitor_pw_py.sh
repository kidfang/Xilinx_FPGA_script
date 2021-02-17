#!/bin/bash
#!/bin/sh

path=$('pwd')
gpu_num=$(xbutil list | grep xilinx | wc -l)
#FPGA_info_n=Progressing...
#file_name=FPGA_power_
file_name=dev

#sleep 1

for (( GPU=0; GPU<$gpu_num; GPU=GPU+1 ));
do
#	sleep 1
#	FPGA_info_n=Progressing...
	FPGA_info=$(cat $path/$file_name$GPU* | tail -n 1 | grep -i "power" | awk '{print $6 " " $7 " " $9 " " $10 " " $12}')

#######################################################

#	for (( i=0; i<100; i=i+1 ));
#	do
#		if [[ $FPGA_info = *[!\ ]* ]]; then
#                FPGA_info_n=$FPGA_info
#		break 1
# 	        else
#                FPGA_info=$(cat $path/FPGA_power_$GPU.txt | tail -n 1 | grep -i "current Power" | awk '{print $5 " " $6 " " $8 " " $10 " " $11 " " $12 " " $13 " " $14 " " $15}')
#                FPGA_info_n=Progressing...
#		sleep 1
#		continue 1  
#        	fi
#	done

#######################################################
	
#	if [[ $FPGA_info = *[!\ ]* ]]; then 
#	        FPGA_info_n=$FPGA_info
#	else
#		sleep 1
#		FPGA_info=$(cat $path/FPGA_power_$GPU.txt | tail -n 1 | grep -i "current Power" | awk '{print $5 " " $6 " " $8 " " $10 " " $11 " " $12 " " $13 " " $14 " " $15}')
#		FPGA_info_n=$FPGA_info
#		if [[ $FPGA_info = *[!\ ]* ]]; then
#			FPGA_info_n=$FPGA_info
#		else
#			FPGA_info=$(cat $path/FPGA_power_$GPU.txt | grep -i  Result | tail -n 1 | awk '{print $5 " " $6}')
#			FPGA_info_n=$FPGA_info
#		fi
#		FPGA_info_n=Progressing...
#	fi

########################################################

	kk=0

	until [[ $FPGA_info = *[!\ ]* ]]; 
	do
		FPGA_info=$(cat $path/$file_name$GPU* | tail -n 1 | grep -i "power" | awk '{print $6 " " $7 " " $9 " " $10 " " $12 }')
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
#			FPGA_info=$(cat $path/FPGA_power_$GPU.txt | tail -n 1 |  egrep -i "RESULT: ALL TESTS PASSED| RESULT: SOME TESTS FAILED")
		fi

	done

	FPGA_info_n=$FPGA_info
	echo FPGA["$GPU"] $FPGA_info_n

done
