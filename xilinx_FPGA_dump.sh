#!/bin/bash
#!/bin/sh

path=$('pwd')
num=$(xbutil list | grep xilinx | wc -l)

mkdir -p $path/FPGA_dump_all >/dev/null 2>&1
mkdir -p $path/FPGA_query_all >/dev/null 2>&1

for (( i=0; i<$num; i=i+1 ));
do	

	echo -e "\n----------- Start Saving the FPGA"$i" status log  -----------\n"
	xbutil dump -d $i > $path/FPGA_dump_all/FPGA"$i"_dump_log.txt
	xbutil query -d $i > $path/FPGA_query_all/FPGA"$i"_query_log.txt
	
	echo -e "\n----------- FPGA"$i" ECC check  -----------\n" >> $path/FPGA_query_all/ECC_check_summary.txt
	xbutil query -d $i | grep -A 38 "Firewall Last Error Status" >> $path/FPGA_query_all/ECC_check_summary.txt
	echo -e "\n-------------------------------------------\n" >> $path/FPGA_query_all/ECC_check_summary.txt
done

cat $path/FPGA_dump_all/FPGA* | grep -i sc_version > $path/FPGA_dump_all/FPGA_sc_version.txt
