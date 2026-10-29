import os
import sys
import argparse


class IWFConfigException():
    pass


def handle_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-il', "--iwf_only_launch", default=False)
    return parser.parse_args()


launch_file = "robotws/testsuite/Bangalore/AirPhone/AP_P1Perf/resources/scripts/iwf_launch.py"
pre_config_file = "robotws/testsuite/Bangalore/AirPhone/AP_P1Perf/resources/scripts/iwf_preconfigs.py"
args = handle_args()
print(args.iwf_only_launch)
if args.iwf_only_launch:
    print('true')
    output = os.system('python3 ${EXECDIR}/launch_file')
    if output != 0:
        raise IWFConfigException("iwf laumch failed")
else:
    print('false')
    output = os.system('sudo python3 ${EXECDIR}/pre_config_file')
    if output == 0:
        output = os.system('python3 ${EXECDIR}/launch_file')
        if output != 0:
            raise IWFConfigException("iwf launch failed")
    else:
        raise IWFConfigException("iwf preconfig failed")
