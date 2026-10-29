from testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.l2_trace import remove_file, remove_files
import subprocess
import os
import re


def check_if_transmission_changed(transmission,
                                  path='testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy'):
    csv_files = [os.path.join(path, x) for x in os.listdir(path) if re.search('csv', x)]
    exception_counter = 0
    for record in csv_files:
        if transmission == 'LTE_TO_NR':
            try:
                output = subprocess.check_output('cat {} | grep RESUME'.format(record), shell=True)
            except Exception:
                exception_counter += 1
            if exception_counter == len(csv_files):
                assert False, "Missing UL_RESUME flag in TTI Trace logs."
        if transmission == 'NR_TO_LTE':
            try:
                output = subprocess.check_output('cat {} | grep RLO'.format(record), shell=True)
            except Exception:
                exception_counter += 1
            if exception_counter == len(csv_files):
                assert False, "Missing UL_RLO flag in TTI Trace logs."
    remove_file('testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/vm_tti_trace/vm_tti_trace.pcap')
    remove_files(csv_files)
