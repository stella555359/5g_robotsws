*** Settings ***
Documentation
...    author: fred li
...    contact: fred.li@nokia-sbell.com
...    squad group: NSB MN 5G&SC 5G Pz Verf CN 07 SG
Resource   ./Resource/Common.robot
Resource   ../common/coam_resource.robot
Resource   ./Resource/start_and_stop_trace.resource
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/Resource/coam.robot

Force Tags   SG_07   CA_5G_OAM   CRT   PY36

Suite Setup   CB007039 Common Suite Setup
Suite Teardown   CB007039 Common Suite Teardown

*** Variables ***

*** Test Cases ***
CB007039-A-L2hi-streaming-suspend-with-multiple-nodes
    [Tags]
    [Timeout]    60min
    [Setup]   7039 Case Setup
    Modify Swconfig File
    sleep    5min
    Syslog Capture Start
    Start Dcap Basic trace
    Activate OVLP through WebEM
    sleep   1min
    Deactivate OVLP through WebEM
    sleep   30s
    Stop Dcap Basic trace
    Syslog Capture Stop and Collect
    Validate msg in syslog   Convert L2 streaming CU suspend message|SuspendStreamingResp
    Validate msg in syslog   Convert L2 streaming CU Resume message|handleTraceResumeResp
    [Teardown]   CB007039-A teardown

CB007039-B-Cplane-trace-resume-with-OVL-reduced
    [Tags]
    [Timeout]    60min
    [Setup]   7039 Case Setup
    sleep    5min
    ${position}   Get gNB Position From SCF
    Syslog Capture Start
    Start Dcap Basic trace
    Activate OVLP through WebEM
    ${cpue_id}   Set Variable If   '${position}'=='RightSide'   0x2734   0x1734
    Trigger NR L3 overload    cpue_id=${cpue_id}
    sleep   1min
    Cancel NR Cplane OVL    cpue_id=${cpue_id}
    sleep   6min
    Stop Dcap Basic trace
    Syslog Capture Stop and Collect
    Validate msg in syslog   suspend, zmq/sctp/tm tracing|Message trace suspend
    Validate msg in syslog   resume, zmq/sctp/tm tracing|Message trace resumed
    [Teardown]   CB007039 Case Teardown

CB007039-C-NR-L1-streaming-trace-resume-with-NRT-core-OVL-reduced
    [Tags]
    [Timeout]    60min
    [Setup]   7039 Case Setup
    sleep    5min
    Syslog Capture Start
    Activate OVLP through WebEM								
    Start Dcap Basic trace
    Trigger NR L1 overload
#    sleep   1min
#    Cancel NR L1 overload
    sleep  6min
    Stop Dcap Basic trace
    Syslog Capture Stop and Collect									
    Validate msg in syslog   Handle Suspend Streaming Request for L1 Node:
    Validate msg in syslog   Handle resume streaming request for L1 instance:
#    Log To Console     log to pass
    [Teardown]   CB007039 Case Teardown

CB007039-C-NR-L1-journal-log-resume-with-OVL-reduced
    [Tags]
    [Timeout]    60min
    [Setup]   robot_common_operations.Common Case Setup
#    Syslog Capture Start
#    Activate OVLP through WebEM
#    Trigger NR L1 overload
#    sleep   1min
#    Cancel NR L1 overload
#    sleep   6min
    Collect journal log
    Validate msg in journal log   filtering messages is started
    Validate msg in journal log   filtering messages is stopped
    Log To Console     log to pass
    [Teardown]   robot_common_operations.Common Case Teardown

CB007039-D-LTE-Cplane-trace-suspend-with-OVL
    [Timeout]    60min
    [Setup]   7039 Case Setup
    Activate OVLP through WebEM   BTS_type=enb
    COAM Login
    COAM Backup SCF   file_name=TL${BTSID}.xml
    Run Keyword And Ignore Error   COAM Logout
    Sleep   1min
    Syslog Capture Start
    Modify Venfor file
#    Syslog Capture Start
#    Activate OVLP through WebEM   BTS_type=enb
    Start Dcap Basic trace   BTS_custom_profile=${enb_custom_type}   BTS_type=enb
    sleep   8min
    Make massive attachs   50
    sleep   8min
    [Teardown]   Run Keywords   Stop Dcap Basic trace
    ...   AND   Syslog Capture Stop and Collect
    ...   AND   Validate msg in syslog   New overload level received
    ...   AND   Validate msg in syslog   handleOverloadMsg: Applications which reported overload
    ...   AND   Validate msg in syslog   handleOverloadMsg: No applications reported overload
    ...   AND   Validate msg in syslog   Debug and info traces disabled due to trace overload protection
    ...   AND   Validate msg in syslog   Debug and info traces enabled
    ...   AND   Deactivate OVLP through WebEM   BTS_type=enb
    ...   AND   CB007039 Case Teardown

CB007039-E-LTE-UP-trace-suspend-with-OVL
    [Timeout]    60min
    [Setup]   7039 Case Setup
    Should not contain port 15300
    Activate OVLP through WebEM   BTS_type=enb
    sleep   1min
    Start Dcap Basic trace   BTS_custom_profile=${enb_custom_type}   BTS_type=enb
    sleep   1min
    Should contain port 15300
    [Teardown]   Run Keywords   Stop Dcap Basic trace
    ...   AND   Deactivate OVLP through WebEM   BTS_type=enb
    ...   AND   CB007039 Case Teardown
*** Keywords ***
CB007039-A teardown
    Install Swconfig File
    Run Keyword If   $KEYWORD_STATUS=='FAIL'    Run Keyword And Ignore Error    Screenshot for case fail
    Run Keyword If   $KEYWORD_STATUS=='FAIL'    Run Keyword And Ignore Error    Save Snapshot logs On COAM  IP_WEBUI=${WEBUI_ADDR}
    Run Keyword And Ignore Error   WEBUI LOGOUT
    Run Keyword And Ignore Error   COAM Logout
    robot_common_operations.Common Case Setup

CB007039 Case Teardown
    Run Keyword And Ignore Error   COAM Logout
    Run Keyword If   $KEYWORD_STATUS=='FAIL'    Run Keyword And Ignore Error    Screenshot for case fail
    Run Keyword If   $KEYWORD_STATUS=='FAIL'    Run Keyword And Ignore Error    Save Snapshot logs On COAM  IP_WEBUI=${WEBUI_ADDR}
    robot_common_operations.Common Case Teardown

Get gNB Position From SCF
    Wait Until Keyword Succeeds   5m   1m   COAM Login   alias=BTS
#    Wait Until Keyword Succeeds   5m   1m   COAM Check BTS OnAir
    COAM Backup Full SCF   connection=BTS
    ${local_xml}   XML.Parse XML   ${OUTPUT_DIR}/full_commission.xml
    ${status}   Run Keyword And Ignore Error   XML.Get Element Text   ${local_xml}
    ...   xpath=cmData/managedObject[@class="com.nokia.srbts.eqm:SMOD"]/p[@name="positionInSubrack"]
    ${position}   Set Variable If   '${status}[0]'=='FAIL'   LeftSide   ${status}[1]
    [Return]  ${position}
    [Teardown]  Run Keyword And Ignore Error   COAM Logout   connection=BTS

CB007039 Common Suite Setup
    robot_common_operations.Common Suite Setup
    ${current_status}   ${orig_gnb_swconfig}   Check and Add Flag in Swconfig File
    Set Suite Variable   ${FLAG_STATUS}   ${current_status}
    Set Suite Variable   ${ORIG_GNB_SWCONFIG}

CB007039 Common Suite Teardown
    robot_common_operations.Common Suite Teardown
    run keyword if  not ${FLAG_STATUS}   Upload Swconfig File to gNB   swconfig_path=${ORIG_GNB_SWCONFIG}
