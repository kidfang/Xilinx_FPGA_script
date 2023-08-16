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
numactl -H | tee $result_output/Basic_info/numactl_H.txt

speed_numa_check_all.sh 8 |  tee $result_output/Basic_info/speed_numa.txt

cat /var/log/dmesg > $result_output/Basic_info/dmesg_check_all.txt
cat /var/log/dmesg | egrep -i "error|fail" > $result_output/Basic_info/dmesg_check.txt

xball xbmgmt examine -r all | tee $result_output/Basic_info/xbmgmt_examine_all.txt
xball xbutil examine --report all | tee $result_output/Basic_info/xbutil_examine_all.txt
xball xbutil validate --verbose --batch | tee $result_output/Basic_info/xbutil_validate.txt
