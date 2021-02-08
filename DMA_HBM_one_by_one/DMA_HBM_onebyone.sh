#!/bin/bash
#!/bin/sh

path=$('pwd')
date_n=$( date | awk '{print $6 "_" $1 "_" $2 "_" $3 "_" $4 }' | sed -n "s/\:/_/g;p" )

mkdir -p $path/$date_n >/dev/null 2>&1

Result_path=$path/$date_n

#du=10
tdm=dma
ty=HBM
#bs=256

gpu_num=$(xbutil list | grep xilinx | wc -l)
##gpu_num=2

#sed -i 's/\"test\_sequence\"\:\[\[10\,\"'"$ty"'\"\,\"all\"\,256\]\]/\"test\_sequence\"\:\[\['"$du"'\,\"'"$ty"'\"\,\"all\"\,'"$bs"'\]\]/g' $path/dma_"$ty".json
echo -e "\n----------- Start "${tdm^^}"_"$ty"_test -----------\n" | tee -a $Result_path/"${tdm^^}"_"$ty"_Summary.txt

for (( GPU=0; GPU<$gpu_num; GPU=GPU+1 ));
do

	GPU_locate=$(($GPU+1))
	FPGA_u280=$(xbutil list | grep -i xilinx | sed -n "$GPU_locate"p | grep -i u280 | wc -l)
	FPGA_u50=$(xbutil list | grep -i xilinx | sed -n "$GPU_locate"p | grep -i u50 | wc -l) 
	Eth_pci_bus=$(xbutil list | grep xilinx | awk '{print $2}' | sed -n "$GPU_locate"p)
	n=$(lspci -vv -s $Eth_pci_bus | grep -i numa | cut -f 3 -d " ")
	c=$(lscpu | grep -i numa | grep -i node"$n" | cut -f 6 -d " ")

	if [ $FPGA_u280 -gt 0  ]; then
		FPGA_ini=u280
		xb_name=xbtest_u280
		test_json="$tdm"_"$ty".json
	elif [ $FPGA_u50 -gt 0 ]; then
		FPGA_ini=u50
		xb_name=xbtest
		test_json="$tdm"_"$ty"_u50.json
	else
		echo -e "Not U280 or U50! skip FPGA"$GPU" and check next one..."
		continue
	fi

#	dmaj=$(cat dma_"$ty".json | grep -i test_sequence | awk '{print $1}')
	taskset -c $c $xb_name -j $path/$test_json -d $GPU > $Result_path/FPGA"$GPU"_"$FPGA_ini"_"$tdm"_"$ty".txt 

#	echo -e "FPGA"$GPU"_DMA_onebyone_test  Duration:$du, Type:$ty, BS:$bs  \n"| tee -a $path/DMA_"$ty"_Summary.txt
	echo -e "FPGA"$GPU"_"$FPGA_ini"_"${tdm^^}"_onebyone_test "| tee -a $Result_path/"${tdm^^}"_"$ty"_Summary.txt
	echo -e "NUMA: $n, Run with CPU core: $c \n" | tee -a $Result_path/"${tdm^^}"_"$ty"_Summary.txt
	cat $Result_path/FPGA"$GPU"_"$FPGA_ini"_"$tdm"_"$ty"* | grep -A 3 "Host <- PCIe <- FPGA" | tee -a $Result_path/"${tdm^^}"_"$ty"_Summary.txt
	echo -e " \n" | tee -a $Result_path/"${tdm^^}"_"$ty"_Summary.txt
	cat $Result_path/FPGA"$GPU"_"$FPGA_ini"_"$tdm"_"$ty"* | grep -i RESULT | tail -n 1 | tee -a $Result_path/"${tdm^^}"_"$ty"_Summary.txt
	echo -e "\n-------------------------\n" | tee -a $Result_path/"${tdm^^}"_"$ty"_Summary.txt

done

rm -f $path/connectivity*

echo -e "\n----------- End "${tdm^^}"_"$ty"_test -----------\n" | tee -a $Result_path/"${tdm^^}"_"$ty"_Summary.txt
