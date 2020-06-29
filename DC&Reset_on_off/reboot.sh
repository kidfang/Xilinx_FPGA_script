#!/bin/bash
# value to identify the detected data

Result_path=/root/xilinx_test/Reboot  	# Path to save test log
Reboot_time=43200			# Time for your reboot or powercycle test (sec)
scsi_num=2                		# Type "lsscsi | wc -l" to chek your scsi drive number
GPU_num=20                		# Type "lspci | grep -i Xilinx | wc -l" to chek your GPU detected amount
Test_type=1               		# Input 0 for Powercycle, 1 for Reboot test

w=$( lspci | grep -i xilinx | wc -l )                    # AMD GPU card need change to vega

# Besure as follows command result all 0, before start this test!!!
# dmesg | grep -i corrected | wc -l
# ipmitool sel list | grep -i interrupt | wc -l

###################################################################
########### Please Modify above parameter for your test ###########
###################################################################
###################################################################
###################################################################
###################################################################

modprobe ipmi_si
modprobe ipmi_devintf

sleep 5

mkdir -p $Result_path >/dev/null 2>&1

s=$( ipmitool sel list | grep -i interrupt )
t=$( ipmitool sel list | wc -l )
u=$( dmesg | grep -i corrected | wc -l )
v=$( ipmitool sel list | grep -i interrupt | wc -l )
x=$( lsscsi | wc -l )
y=$( cat $Result_path/count.txt )
z=$( ls $Result_path | grep count.txt | wc -l )

# Detect the reboot count number

if [ $z -eq 0 ];then
        touch $Result_path/count.txt
        touch $Result_path/rebootrec.txt
        echo 0 > $Result_path/count.txt
        date +%s > $Result_path/start_time.txt
	sleep 10
	init 6
else
        echo "$y"
        y=$((y+1))
        echo $y > $Result_path/count.txt
fi

# Detect the IPMI is fully logged and cleared

if [ $t -eq 1024 ];then
        ipmitool sel clear
else
        echo "continue"
fi

Start_time=$(cat $Result_path/start_time.txt)
End_time=$(date +%s)
During_time=$(($End_time-$Start_time))

echo $Start_time
echo $End_time
echo $During_time

if [ $Test_type -eq 0 ];then
        Test_name=powercycle
else
        Test_name=reboot
fi

if [ $x -eq $scsi_num ];then
        if [ $w -eq $GPU_num ];then
                if [ $v -eq 0 ] && [ $u -eq 0 ];then

                        date >> $Result_path/rebootrec.txt
                        echo PASS >> $Result_path/rebootrec.txt

                                if [ $During_time -le $Reboot_time ];then
                                        if [ $Test_type -eq 0 ];then
                                                sleep 10
                                                ipmitool chassis power cycle
                                        else
                                                sleep 10
                                                init 6
                                        fi
                                else
                                        Start_time_d=$(date +%Y-%m-%d\ %H:%M:%S -d "1970-01-01 UTC $Start_time seconds")
                                        End_time_d=$(date +%Y-%m-%d\ %H:%M:%S -d "1970-01-01 UTC $End_time seconds")
                                        echo "Start_time: $Start_time_d" >> $Result_path/rebootrec.txt
                                        echo "End_time: $End_time_d" >> $Result_path/rebootrec.txt
                                        echo "Test time: $During_time sec" >> $Result_path/rebootrec.txt
                                        sleep 10
                                        dmesg | egrep -i "error|fail|fatal|warn|wrong|bug|fault^default" > $Result_path/dmesg_"$Test_name"_done.txt
                                        dmesg > $Result_path/dmesg_"$Test_name"_done_all.txt
                                        ipmitool sel elist > $Result_path/ipmi_"$Test_name"_done_eventlog.txt
                                        exit 0
                                fi

                else
                        echo $u > $Result_path/OSevent_"$Test_name".txt
                        echo $s > $Result_path/IPMIevent_"$Test_name".txt
                        dmesg | egrep -i "error|fail|fatal|warn|wrong|bug|fault^default" > $Result_path/dmesg_error_"$Test_name".txt
                        dmesg > $Result_path/dmesg_error_all_"$Test_name".txt
                        ipmitool sel elist > $Result_path/ipmi_eventlog_"$Test_name".txt
                        exit 0
                fi
        else
                echo $w > $Result_path/FPGAcounterr_"$Test_name".txt
                lspci | grep -i Xilinx > $Result_path/FPGA_list_"$Test_name".txt
		dmesg | egrep -i "error|fail|fatal|warn|wrong|bug|fault^default" > $Result_path/dmesg_error_"$Test_name".txt
                dmesg > $Result_path/dmesg_error_all_"$Test_name".txt
                ipmitool sel elist > $Result_path/ipmi_eventlog_"$Test_name".txt
                exit 0
        fi
else
        echo {Other error or stopped by user}
        dmesg | egrep -i "error|fail|fatal|warn|wrong|bug|fault^default" > $Result_path/dmesg_"$Test_name"_scsi_num_abnormal.txt
        dmesg > $Result_path/dmesg_"$Test_name"_scsi_num_abnormal_all.txt
        ipmitool sel elist > $Result_path/ipmi_"$Test_name"_scsi_num_abnormal_eventlog.txt
        exit 0
fi
