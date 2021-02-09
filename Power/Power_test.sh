#!/bin/bash
#!/bin/sh

path=$('pwd')
date_n=$( date | awk '{print $6 "_" $1 "_" $2 "_" $3 "_" $4 }' | sed -n "s/\:/_/g;p" )

mkdir -p $path/$date_n >/dev/null 2>&1

Result_path=$path/$date_n

python3 $path/multi_xbtest_power.py

rm -f $path/connectivity*
mv $path/dev* $Result_path/

