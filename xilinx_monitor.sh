#!/bin/bash

#num=8

num=$(xbutil list | grep xilinx | wc -l)

for (( i=0; i<$num; i=i+1 ));
do
	j=$(($i+1))
	xli_pbf=$(xbutil list | grep xilinx | awk '{print $1 " " $2}' | sed -n "$j"p)
	xli_sn=$(xbutil dump -d $i | grep -i serial_number | awk -F "[\"\"]" '{print $4}')
	xli_tmp=$(xbutil dump -d $i | grep -i fpga_temp | awk -F "[\"\"]" '{print $4}')
	xli_pw=$(xbutil dump -d $i | grep -i '"power":' | awk -F "[\"\"]" '{print $4}')
	xli_pw_max=$(xbutil dump -d $i | grep -i max_power | awk -F "[\"\"]" '{print $4}')

	echo "$xli_pbf | $xli_sn | $xli_tmp degrees C | "$xli_pw"W / $xli_pw_max"
done

#echo $(cat temp.txt)
