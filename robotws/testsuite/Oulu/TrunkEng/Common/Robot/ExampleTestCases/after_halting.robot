*** Settings ***

Documentation
...   Author:   Jere Jacklin

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/Common/Robot/TestKeywords/after_halting.robot

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown


*** Variables ***
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
${COLLECT_LOGS}         Always

# Parameter for default snapshot & ims collection keyword
${WAIT_TIME}            300

# (Default) Parameters for pcap log collection keyword:
${smod_tcpdump}    tcpdump -i any   # tcpdump command for SMOD, -i sets the interface to listen on
${smod_file}       /tmp/smod.pcap   # name of file to be saved to destination folder, in this case /tmp/ on the SMOD
${smod_address}    192.168.255.129
${PCAP_WAIT_TIME}  900              # Time to wait before stopping pcap log collection (seconds)
${also_bbmod}      ${False}         # If True, also collect pcap logs from the specified BBMOD
${bbmod_tcpdump}   tcpdump -i any   # tcpdump command for BBMOD, -i sets the interface to listen on
${bbmod_address}   fsp-1a           # address of the BBMOD, can either be fsp-1a/fsp-2b/etc or IPv6 format x:x:x:x:x:x:x:x
${bbmod_file}      /tmp/bbmod.pcap  # name of file to be saved to destination folder, in this case /tmp/ on the BBMOD
${only_bbmod}      ${False}         # If True, only collect pcap logs from the specified BBMOD but not on SMOD

# EXAMPLE USAGE OF THIS FILE:
# Find a syslog print that that will stop the test execution with 100% certainty and make sure syslog collection is on
# in your test case. After that you can run your test case manually in the following format in the terminal:

# robot -L TRACE -v HALT_TEST:'YOUR_SYSLOG_PRINT_HERE' PATH_TO_YOUR_TEST_CASE_HERE;
# pkill admin; echo "starting after_halting";
# robot -L TRACE -t 'Wait And Collect Snapshot After Halting' testsuite/Oulu/TrunkEng/Common/Robot/ExampleTestCases/after_halting.robot

# Make sure that the prior lines are sent in one command and make sure to specify the correct keyword with the -t option

*** Test Cases ***
Wait And Collect Snapshot After Halting
    [Documentation]  Wait for ${WAIT_TIME} seconds and collect snapshot and ims.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_TIME}
        ...    name=Wait And Collect Snapshot After Halting
        ...    test_case=1
        ...    loops=1
		...    keywords=Wait And Collect Snapshot After Halting
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

Collect Pcap Logs After Halting
    [Documentation]  Collect pcap logs from SMOD (and/or BBMOD) after waiting for ${PCAP_WAIT_TIME} seconds.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${smod_tcpdump}  ${smod_file}  ${smod_address}  ${PCAP_WAIT_TIME}  ${also_bbmod}
        ...    ${bbmod_tcpdump}  ${bbmod_address}  ${bbmod_file}  ${only_bbmod}
        ...    name=Collect Pcap Logs After Halting
        ...    test_case=1
        ...    loops=1
		...    keywords=Collect Pcap Logs After Halting
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}