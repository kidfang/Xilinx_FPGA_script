#!/bin/bash
#!/bin/sh

path=$('pwd')

#du=10
ty=DDR
#bs=256

gpu_num=$(xbutil list | grep xilinx | wc -l)
##gpu_num=2

#sed -i 's/\"test\_sequence\"\:\[\[10\,\"'"$ty"'\"\,\"all\"\,256\]\]/\"test\_sequence\"\:\[\['"$du"'\,\"'"$ty"'\"\,\"all\"\,'"$bs"'\]\]/g' $path/dma_"$ty".json
echo -e "\n----------- Start MEM_"$ty"_test -----------\n" | tee -a $path/MEM_"$ty"_Summary.txt

for (( GPU=0; GPU<$gpu_num; GPU=GPU+1 ));
do

	GPU_locate=$(($GPU+1))
	Eth_pci_bus=$(xbutil list | grep xilinx | awk '{print $2}' | sed -n "$GPU_locate"p)
	n=$(lspci -vv -s $Eth_pci_bus | grep -i numa | cut -f 3 -d " ")
	c=$(lscpu | grep -i numa | grep -i node"$n" | cut -f 6 -d " ")
	memj=$(cat mem_"$ty".json | grep -i test_sequence | awk '{print $1 $2}')
	taskset -c $c xbtest -j $path/mem_"$ty".json -d $GPU > $path/FPGA"$GPU"_mem_"$ty".txt 

#	echo -e "FPGA"$GPU"_MEM_onebyone_test  Duration:$du, Type:$ty, BS:$bs  \n"| tee -a $path/MEM_"$ty"_Summary.txt
	echo -e "FPGA"$GPU"_MEM_onebyone_test "| tee -a $path/MEM_"$ty"_Summary.txt
	echo -e "NUMA: $n, Run with CPU core: $c \n" | tee -a $path/MEM_"$ty"_Summary.txt
	cat $path/FPGA"$GPU"_mem_"$ty"* | grep -i "Average Read  Bandwidth" | tee -a $path/MEM_"$ty"_Summary.txt
	echo -e " \n" | tee -a $path/MEM_"$ty"_Summary.txt
	cat $path/FPGA"$GPU"_mem_"$ty"* | grep -i RESULT | tail -n 1 | tee -a $path/MEM_"$ty"_Summary.txt
	echo -e "\n-------------------------\n" | tee -a $path/MEM_"$ty"_Summary.txt

done

rm -f $path/connectivity*

echo -e "\n----------- End MEM_"$ty"_test -----------\n" | tee -a $path/MEM_"$ty"_Summary.txt
