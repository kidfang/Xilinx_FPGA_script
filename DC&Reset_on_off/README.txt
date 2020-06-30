1. Please copy Power_cycle.service to /lib/systemd/system/
 
# cp Power_cycle.service /lib/systemd/system/

2. Copy reboot.sh to /usr/bin/

# cp reboot.sh /usr/bin/

3. Modify the permission

# chmod -R 777 /usr/bin/reboot.sh

4. Modify reboot.sh parameters for the test

# vi /usr/bin/reboot.sh

5. Enable service to start the test

# systemctl enable Power_cycle.service
# systemctl start Power_cycle.service

6. After test completed, disable service

# systemctl disable Power_cycle.service
