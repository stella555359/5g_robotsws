*** Settings ***
Documentation
...    author: lei wang
...    contact: lei.24.wang@nokia-sbell.com
...    squad group: NSB MN 5G&SC 5G Pz Verf CN 07 SG
Resource   ./Resource/Common.robot
Resource   ../common/coam_resource.robot
Resource   ./Resource/start_and_stop_trace.resource
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/Resource/coam.robot

Force Tags   SG_07   CA_5G_OAM   CRT   PY36

Suite Setup   CB007039 Common Suite Setup
Suite Teardown   CB007039 Common Suite Teardown

*** Variables ***
@{ALL_TEST_STATUS}


*** Test Cases ***
[1]CB010575_CB007039_CRT
    [Timeout]    5h
    [Setup]     robot_common_operations.Common Case Setup
#   L2hi is common to all env
    Run Keyword And Continue On Failure    common-CB007039_L2hi-streaming-resume-with-multiple-nodes
#   cp is not common, need to change bsh_id target and cpue_id target
#    Run Keyword And Continue On Failure    common-CB007039-Cplane-trace-resume-with-OVL-reduced
#   l1 is not common, need to change bsh_id target
#    Run Keyword And Continue On Failure    common-CB007039_L1_journal_log_ovl_handle
    [Teardown]    robot_common_operations.Common Case Teardown

*** Keywords ***
CB007039-A teardown
    Install Swconfig File
    Run Keyword If   $KEYWORD_STATUS=='FAIL'    Run Keyword And Ignore Error    Screenshot for case fail
    Run Keyword If   $KEYWORD_STATUS=='FAIL'    Run Keyword And Ignore Error    Save Snapshot logs On COAM  IP_WEBUI=${WEBUI_ADDR}
    Run Keyword If   $KEYWORD_STATUS=='FAIL'    Run Keyword And Ignore Error    Stop Dcap Basic trace
    Run Keyword If   $KEYWORD_STATUS=='FAIL'    Run Keyword And Ignore Error    Syslog Capture Stop and Collect
    Run Keyword And Ignore Error   WEBUI LOGOUT
    Run Keyword And Ignore Error   COAM Logout

CB007039 Case Teardown
    Run Keyword If   $KEYWORD_STATUS=='FAIL'    Run Keyword And Ignore Error    Screenshot for case fail
    Run Keyword If   $KEYWORD_STATUS=='FAIL'    Run Keyword And Ignore Error    Save Snapshot logs On COAM  IP_WEBUI=${WEBUI_ADDR}
    Run Keyword If   $KEYWORD_STATUS=='FAIL'    Run Keyword And Ignore Error    Stop Dcap Basic trace
    Run Keyword If   $KEYWORD_STATUS=='FAIL'    Run Keyword And Ignore Error    Syslog Capture Stop and Collect
    Run Keyword And Ignore Error   WEBUI LOGOUT
    Run Keyword And Ignore Error   COAM Logout
    robot_common_operations.Common Case Teardown

CB007039 Common Suite Setup
    log to console  \n***CI_interface.Common Suite Setup for COAM on UTE***
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup
    ${current_status}   ${orig_gnb_swconfig}   Check and Add Flag in Swconfig File
    Set Suite Variable   ${FLAG_STATUS}   ${current_status}
    Set Suite Variable   ${ORIG_GNB_SWCONFIG}

CB007039 Common Suite Teardown
    run keyword if  not ${FLAG_STATUS}   Upload Swconfig File to gNB   swconfig_path=${ORIG_GNB_SWCONFIG}
	robot_common_operations.Common Suite Teardown

common-CB007039_L2hi-streaming-resume-with-multiple-nodes
    [Timeout]    60min
    7039 Case Setup
    Modify Swconfig File
    sleep    5min
    Syslog Capture Start
    Start Dcap Basic trace for UTE
    Activate OVLP through WebEM
    sleep   1min
    Deactivate OVLP through WebEM
    sleep   30s
    Stop Dcap Basic trace
    Syslog Capture Stop and Collect
    Validate msg in syslog   suspend L2Streaming
    Validate msg in syslog   try resuming all l1&l2 suspending streamings
    [Teardown]   CB007039-A teardown

common-CB007039-Cplane-trace-resume-with-OVL-reduced
    [Timeout]    60min
    7039 Case Setup
    sleep    5min
#    ${position}   Get gNB Position From SCF
    Syslog Capture Start
    Start Dcap Basic trace for UTE
    Activate OVLP through WebEM
    Trigger NR L3 overload via bsh    cpue_id=0x1731
    sleep   1min
    Cancel NR Cplane OVL via bsh    cpue_id=0x1731
    sleep   6min
    Stop Dcap Basic trace
    Syslog Capture Stop and Collect
    Validate msg in syslog   Message trace suspend
    Validate msg in syslog   Message trace resumed
    [Teardown]   CB007039 Case Teardown
#
common-CB007039_L1_journal_log_ovl_handle
    [Timeout]    60min
    7039 Case Setup
    sleep    5min
    Syslog Capture Start
    Activate OVLP through WebEM
    Start Dcap Basic trace for UTE
    Trigger NR L1 overload via bsh
    sleep  6min
    Cancel NR L1 overload via bsh
    Stop Dcap Basic trace
    Syslog Capture Stop and Collect
    Collect journal log via bsh
    Validate msg in syslog   Handle Suspend Streaming Request for L1 Node:
    Validate msg in syslog   Handle resume streaming request for L1 instance:
#    Collect journal log
    Validate msg in journal log   filtering messages is started
    Validate msg in journal log   filtering messages is stopped
#    Log To Console     log to pass
    [Teardown]   CB007039 Case Teardown
