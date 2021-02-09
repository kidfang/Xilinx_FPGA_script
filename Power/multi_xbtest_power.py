import subprocess
import sys
import argparse
import time
import json
import re
from datetime import datetime
from collections import namedtuple

xbtest_v4_cmdline = ['/opt/xilinx/xbtest/bin/xbtest', '-j', '/home/source/Xilinx_FPGA_script/Power/power_u50.json']

params = {}  # create empty dict
params['xilinx_u280_xdma_201920_3'] = {'xbtest_ver':'v3.2.1', 'cmdline': ['/home/source/multi_xbtest/xbtest_u280', '-j',  '/home/source/Xilinx_FPGA_script/Power/power.json']} #, 'xbtest_dir':xbtest_v3_2_1_dir, 'xbtest_bin':xbtest_v3_2_1_dir+'/bin/xbtest', 'xbtest_json':xbtest_v3_2_1_dir+'xilinx_u200_xdma_201830_2.json',  }
params['xilinx_u250_xdma_201830_2'] = {'xbtest_ver':'v3.2.1', 'cmdline': ['/home/source/multi_xbtest/xbtest_u250', '-j',  '/home/source/Xilinx_FPGA_script/Power/power_u250.json']}
params['xilinx_u50_gen3x16_xdma_201920_3'] = {'xbtest_ver':'v4', 'cmdline': xbtest_v4_cmdline} #, 'xbtest_dir':xbtest_v4_dir, 'xbtest_bin':xbtest_v4_bin, 'xbtest_json':xbtest_v4_dir+'xilinx_u200_xdma_201830_2.json'}

def mixrange(s):  # expand 1,2,3-5,6 into 1,2,3,4,5,6
    r = []
    for i in s.split(','):
        if '-' not in i:
            r.append(int(i))
        else:
            l,h = map(int, i.split('-'))
            r+= range(l,h+1)
    return r

def run_xbutil_dump(idx):
    cmpl = subprocess.run('/opt/xilinx/xrt/bin/xbutil dump -d ' + str(idx), shell=True, check=False, stdout=subprocess.PIPE)
    if cmpl.returncode != 0:  # device is out of range
        if idx ==  0:   # no cards found; assume there is an error
            print(cmpl.stdout)
            exit(1)
        else:
            return None  # indicate that this card doens't exist
    return cmpl.stdout


class DEV:
    def __init__(self, idx):
        self.idx = idx  # device number index
        dump_txt = run_xbutil_dump(self.idx)
        self.dump_before = json.loads(dump_txt)  # convert the json output of xbutil dump into a dict
        self.dsa_name = self.dump_before['board']['info']['dsa_name']
        self.params = params[self.dsa_name]
        self.cmdline = self.params['cmdline'] + ['-d', str(self.idx)]  # add the -d <dev num>
        self.logfilename = 'dev{:d}-{}.log'.format(idx, timestampStr)
        self.logfile = open(self.logfilename, 'w')

    def run_xbtest(self):
        print('executing: ', ' '.join(self.cmdline))
        print('   output captured in: ', self.logfilename)
#i        self.proc = subprocess.Popen(self.cmdline, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True)
        self.proc = subprocess.Popen(self.cmdline, stdout=self.logfile, stderr=subprocess.STDOUT, universal_newlines=True)
        #self.proc = subprocess.Popen(self.cmdline)  #### redirect output to file

    def check_firewalls(self):
        dump_txt = run_xbutil_dump(self.idx)  # run xbutil dump after the tests were run
        if dump_txt == None:
            print('Unable to perform xbutil dump on card', self.idx)
            exit(-1)
        self.dump_after = json.loads(dump_txt)
        # check if there is a newer/different firewall time since before xbtest was run
        print ('Firewall time before = ', self.dump_before['board']['error']['firewall']['firewall_time'])
        print ('Firewall time after = ', self.dump_after['board']['error']['firewall']['firewall_time'])

        if self.dump_before['board']['error']['firewall']['firewall_time'] != self.dump_after['board']['error']['firewall']['firewall_time']:
            print('Firewall {:d} was tripped.  All results for all cards might be invalid.  Check individual logs.'.format(idx))
            return -1
        return 0

#create timestamp for this run
dateTimeObj = datetime.now()
timestampStr = dateTimeObj.strftime("%d-%m-%Y_%H-%M-%S")

parser = argparse.ArgumentParser(description='Multiple XBTEST launcher')
#parser.add_argument('-o', nargs='?', const='*', help='Output file')  # if -o is specified but nothing else, it will be set to '*'
parser.add_argument('-s', '--seq', help='Test each card consecutively instead of concurrently', action='store_true')
parser.add_argument('-d', '--dev', help='Specify range of devices to test.  ex: 3 or 1,3 or 2-7')
#parser.add_argument('-v', type=int, nargs='?', default=0, const=1, help='verbosity (0=default)')  #todo: parser.add_argument('--verbose', '-v', action='count') ?

args = parser.parse_args()
sequential = args.seq

cmpl = subprocess.run('/opt/xilinx/xrt/bin/xbutil scan', shell=True, check=True, stdout=subprocess.PIPE, universal_newlines=True)
#cmpl.stdout.decode('utf-8')
xbutil_scan_text = cmpl.stdout
x = re.findall(r'total (\d+).+, (\d+)', xbutil_scan_text)  # scan for X and Y in "INFO: Found total X card(s), Y are usable"
total = int(x[0][0])
usable = int(x[0][1])
if args.dev:
    dev_list = mixrange(args.dev)
else:
    dev_list = range(usable)

print('Found total {:d} card(s), {:d} are usable'.format(total, usable))
if usable == 0:
	print('Error: No usable cards found')
	exit(-1)
if usable != total:
	print('Warning: Not all cards are usable')

dev = usable * [None]  # dimension device list to correct size
for idx in dev_list:
    o = DEV(idx)
    dev[idx] = o  # save the device object in dev list
    print('Device {:d} is {} and uses xbtest {}'.format(idx, o.dsa_name, o.params['xbtest_ver']))

if sequential:      # run tests on one card at a time
    for idx in dev_list:
        o = dev[idx]
        o.run_xbtest()

        # wait for processes to finish.
        waiting = True
        while waiting:
            waiting = False
            if o.proc.poll() == None:
                waiting = True
                time.sleep(1)
            print('waiting for device ', str(idx))

        failure = False
        if o.proc.returncode != 0:
            failure = True
        print('Device {:d} is {} and returned with code {:d}'.format(idx, o.dsa_name, o.proc.returncode))
        if o.check_firewalls() != 0:
            failure = True
else:  # run tests concurrently on all cards
    # kick off xbtest on each device
    for idx in dev_list:
        o = dev[idx]
        o.run_xbtest()

    # wait for processes to finish.
    waiting = True
    while waiting:
        waiting = False
        waiting_on = ''
        for idx in dev_list:
            o = dev[idx]
            # this doesn't work because readline() is blocking even if no text is available, and workarounds are painful
            # line = o.proc.stdout.readline()
            # if line:
            #     sys.stdout.write('Device {:d}: {}'.format(idx, line))  # output to console
            #     o.logfile.write(line)                                  # output to log file
            # else:
            #     print('no data')
            if o.proc.poll() == None:
                waiting_on += ' ' + str(idx)
                waiting = True
                time.sleep(1)
        print('waiting for device(s) ', waiting_on)

    failure = False
    for idx in dev_list:
        o = dev[idx]
        if o.proc.returncode != 0:
            failure = True
        print('Device {:d} is {} and returned with code {:d}'.format(idx, o.dsa_name, o.proc.returncode))
        if o.check_firewalls() != 0:
            failure = True

if failure:
    print('SOME TESTS FAILED')
    exit(1)
else:
    print('ALL TESTS PASSED')
    exit(0)
