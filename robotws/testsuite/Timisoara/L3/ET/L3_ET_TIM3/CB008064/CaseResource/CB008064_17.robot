*** Settings ***
Documentation
...  author : cristinel.sava@nokia.com
...  contact: cristinel.sava@nokia.com   cristinel.sava@nokia.com

Resource    ../../resources/admin.robot
Resource    ../06/Resource/admin6064.robot

*** Variables ***
${setupfail_count}    ${0}
${setupfail_count_limit}    ${1}
${setup_condition}    ${False}
${cell_string}    unknown
${dcap_server_port}    49148
${plmn_Identity}    132006
${cellIdentity}    0000040090
${cell_numbers}    1
${traceId}    000001

*** Keyword ***




CB008064_06_ASIB_PDL_Check_CU-UP_and_CU-UP_and_DU_Trace_Session
    [Documentation]
    ...     This script Check the counter of the report indicated in its name
    ...     It checks the value in a pcap file and in the C4MN report after making a L3 Call
    [Timeout]  4h

    Step3: Check Log CB008064
    Step4: Lock&Unlock and Twice Check
    Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword and Ignore Error      Get mrbtsid from BTS
    ${testline_name}=    Get From Dictionary    ${BTS_Info}    name
    Set Global Variable    ${testline_name}
    Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}      Expected_ERR_WRN_number=10000   Expected_ERR_WRN_diff_number=0
    ...      Expected_ERR_WRN_deviation=0.1
    ...      base_file=${Base_ERR_WRN_csv_path}       UTE_logs_path=${UTE_logs_path}
    ...      check_diff=${True}

CB008064_17_ASIL_check_Alarm_when_TCE_Connect_failed
    [Documentation]
    ...     This script Check 2xAlarms 7115
    ...     rise when TCE connection is failed
 #   Step 0: Preconditions
    Step 1: Check Alarm 7115 and clear it
    sleep    1s

Step 0: Preconditions
    Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
    Log to console    1 Get Scfc File
    Get VM Password
    Log to console    2 Get VM Password
    5G_SW_WRO_Keywords.Get VM IP
    Log to console    3 Get VM IP
    Start Vm Ethernet Interfaces
    Log to console    4 Start Vm Ethernet Interfaces
    Log to console    5 Start UTF
    Run  utf_lab-controller start
    Wait until keyword succeeds  300  30  Find Scfc And Send Delta Commissioning  scfc_filename=delta_json_delete_TCE.json
    Log to console    6 Delta Commissioning Removed TCE objects
    Wait until keyword succeeds  300  30  Find Scfc And Send Delta Commissioning  scfc_filename=add_2xTCE.json
    Log to console    7 Delta Commissioning ADD TCE objects
    Get Scfc File    output_filepath=${OUTPUT_DIR}/scfc_after_delta.xml
    Log to console    8 Get Scfc File scfc_after_delta.xml
    Reach Onair without confirmation   lua_cfg=${CURDIR}/basic.cfg
    sleep    20s
    Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2
    Log to console    9 Site UP


Step 1: Check Alarm 7115 and clear it
    Log  \nStep1: Check Alarm 7115 and clear it  console=true
    Log to console    \nSTOP DCAP to trigger 2x7115 alarms
    Run  utf_lab-controller stop
    sleep    5s
    Check Alarm 7115 and clear it

Check Alarm 7115 and clear it
    [Documentation]    Verify that alarm 7115 appears and optionally start clearing process.

    Log  \nGet Active Alarms Via ADMIN CLI  console=true
#    Modify Resource Search Order    admin6064.Get Active Alarms From BTS 8064
    ${active_alarms}=    admin6064.Get Active Alarms From BTS 8064

    ${count_7115}=       Set Variable    0

    # Count nr of alarmId 7115
    FOR    ${fault}    IN    @{active_alarms}
        ${alarm_id}=    Get From Dictionary    ${fault}    alarmId
        IF    ${alarm_id} == 7115
            ${count_7115}=    Evaluate    ${count_7115} + 1
        END
    END

    # Log la consola
    Log To Console    Total alarms with alarmId 7115: ${count_7115}

    #  Fail if exist count different of 2
    IF    ${count_7115} != 2
        Fail    Nr of active alarms with alarmId 7115 found is ${count_7115} != 2
    END

    [Return]    ${count_7115}


    Log   start dcap to clear 7115   console=${True}
    Wait Until Keyword Succeeds   60   10
    ...   Run   utf_lab-controller start

    Log   \nCheck If Alarm 7115 is cleared.   console=${True}

Lock&Unlock
    log to console    Lock&Unlock
    Start Tcpdump To Get PCMD   pcmd_file=step4.pcap
    Log to console    7 Start Tcpdump step4.pcap
    Lock Single Cell    cell_id=1
    sleep    5s
    Unlock Single Cell    cell_id=1
    sleep    5s
    Lock Single Cell    cell_id=1
    sleep    5s
    Unlock Single Cell    cell_id=1
    sleep    5s

Step3: Check Log CB008064
    log to console    Step3: Check Log
    ${CU_trace_list}     Create List    00:00:01  #  00:00:02    00:00:03    00:00:04    00:00:05
    ${DU_trace_list}     Create List    00:00:01   # 00:00:02    00:00:03    00:00:04    00:00:05
    ${CUUP_trace_list}     Create List    00:00:01  #  00:00:02    00:00:03    00:00:04    00:00:05
    Check TraceIds    trace_list=${CU_trace_list}
    Check TraceIds    trace_list=${DU_trace_list}    trace_type=Du
    Check TraceIds    trace_list=${CUUP_trace_list}    trace_type=CuUp

Step4: Lock&Unlock and Twice Check
    log to console    Step4: Lock&Unlock and Twice Check
    Lock&Unlock
    CB008064_Keywords.Make twice L3CALL And Get ALL PCMD MSG
    Stop Tcpdump To Get PCMD    pcmd_file=step4.pcap
    Log to console    16 Stop Tcpdump To Get PCMD pcmd_file=step4.pcap
    Step3: Check Log CB008064

TC Setup
    Common Test Setup

Common Test Teardown
