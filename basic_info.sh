#!/bin/bash
#!/bin/sh

result_output=$('pwd')

mkdir $result_output/Basic_info >/dev/null 2>&1

lshw -c memory -short | tee  $result_output/Basic_info/mem_info.txt
dmidecode -t memory | tee $result_output/Basic_info/mem.txt
dmidecode -t bios | tee $result_output/Basic_info/bios.txt
lspci | grep -i Xilinx | tee $result_output/Basic_info/xilinx_fpga_pcie.txt
lspci -tv | tee $result_output/Basic_info/lspci_tv.txt
lspci -vvvd 10ee: | tee $result_output/Basic_info/lspci_10ee.txt
lspci | tee $result_output/Basic_info/lspci.txt
lspci -vvv | tee $result_output/Basic_info/lspci_vvv.txt
lscpu | tee $result_output/Basic_info/lscpu.txt

$result_output/speed_numa_check_all.sh 8 |  tee $result_output/Basic_info/speed_numa.txt
$result_output/xilinx_FPGA_dump.sh

#xbutil validate | tee $result_output/Basic_info/xbutil_validate.txt
