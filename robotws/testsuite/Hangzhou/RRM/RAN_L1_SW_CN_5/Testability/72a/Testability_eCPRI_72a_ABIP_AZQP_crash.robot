*** Settings ***
Documentation
...    Author:  Yanqing.li
...    Contact: yanqing.li@nokia-sbell.com
...    Feature: testability_eCPRI_72a
...    Release: 25R1
Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../../resources/common_resources.robot
Force Tags    5G_RAN_TDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}    6450    6540    2087    # crash is triggerd in case, fault-2087 will be raised.
${scfc_file}    Testability_ABIP_1xAZQP_NRTDD_1xNRCEL_72a_${btsid}.xml
${ue_index}    UE_2

*** Test Cases ***
Testability_TC01_NR_FR1_TDD_eCPRI_ABIP_72a_arm_crash
    [Tags]    ABIP    SMAwave    Trunk    ArmCrash    Testability    Crash
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}Testability${/}${scfc_file}
    SMAwave UE attach    rat=5G    cell_id=None    band=78    specific_UE_index=${ue_index}
    SMAwave Start Data Traffic    100M    20M    udp    1000
    SMAwave Verify throughput for DL and UL    100M    20M    30%    5G    78
    ${crash_time}    Get Time    result_format=%Y-%m-%d %H:%M:%S
    Set Test Variable    ${crash_time}
    ${pid}    connect_and_execute_command_on_bbmod    ABIP    thor_1    pgrep -f l1_application_rt| tail -n 1
    connect_and_execute_command_on_bbmod    ABIP    thor_1    kill -s SEGV ${pid}
    sleep    60s
    Wait Until Keyword Succeeds     390s    30s    Check If All Cells Are OnAir
    [Teardown]    Run keywords    SMAwave Stop Data And Detach    AND    Case Teardown And Check Crash In Logs    arm

Testability_TC02_NR_FR1_TDD_eCPRI_ABIP_72a_MHAB_crash
    [Tags]    ABIP    SMAwave    Trunk    MHABCrash    Testability    Crash
    ## To enable print ru(all made node) udp log to SYSLOG via serial port: ip:3232261320(192.168.100.200); port:51000
    ## Connect And Execute Command On Ru   <ru>   echo -e "0x10041 = 2\n0x10042 = 3232261320\n0x10043 = 51000" |sudo tee -a /mnt/runtime/swconfig.txt
    ## PR846643::WA to disable RU power on reset function, need to add a fime named por_executed in RU made: /mnt/runtime/por_executed
    Connect And Execute Command On Ru    AZQP    sudo touch /mnt/runtime/por_executed

    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}Testability${/}${scfc_file}
    SMAwave UE attach    rat=5G    cell_id=None    band=78    specific_UE_index=${ue_index}
    SMAwave Start Data Traffic    100M    20M    udp    1000
    SMAwave Verify throughput for DL and UL    100M    20M    30%    5G    78
    ${crash_time}    Get Time    result_format=%Y-%m-%d %H:%M:%S
    Set Test Variable    ${crash_time}
    # connect_and_execute_command_on_bbmod    ABIP    thor_1    devmem 0X87E040041D00 64 1
    connect_and_execute_command_on_bbmod    ABIP    thor_1    confmgmtbrowser write CommonPhy mxabCrashTestFlag 38
    sleep    60s
    Wait Until Keyword Succeeds     390s    30s    Check If All Cells Are OnAir
    [Teardown]    Run keywords    SMAwave Stop Data And Detach    AND    Case Teardown And Check Crash In Logs    mhab

Testability_TC03_NR_FR1_TDD_eCPRI_ABIP_72a_MDAB_crash
    [Tags]    ABIP    SMAwave    Trunk    MDABCrash    Testability    Crash
    Append To List    ${L1_ERR_whitelist}    logIdCrashHandling
    Append To List    ${L1_WRN_whitelist}    checkPuschExpiredEvents
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}Testability${/}${scfc_file}
    SMAwave UE attach    rat=5G    cell_id=None    band=78    specific_UE_index=${ue_index}
    SMAwave Start Data Traffic    100M    20M    udp    1000
    SMAwave Verify throughput for DL and UL    100M    20M    30%    5G    78
    ${crash_time}    Run    date +"%Y-%m-%dT%H"
    Set Test Variable    ${crash_time}
    connect_and_execute_command_on_bbmod    ABIP    thor_1    devmem 0x87E044701600 64 1
    sleep    60s
    Wait Until Keyword Succeeds     390s    30s    Check If All Cells Are OnAir
    [Teardown]    Run keywords    SMAwave Stop Data And Detach    AND    Case Teardown And Check Crash In Logs    mdab

*** Keywords ***
Case Teardown And Check Crash In Logs
    [Arguments]    ${crash_type}
    Should Be True    '${crash_type.lower()}' in ('arm', 'mdab', 'mhab')    [ERROR] ${crash_type} should be 'arm' | 'mdab' | 'mhab'.
    ${L1_ERR_rt_message_num}=     Count Syslog messages    regexp=ERR/l1_application_rt    alias=enb_testSetup
    ${L1_ERR_nrt_message_num}=    Count Syslog messages    regexp=ERR/l1_application_nrt    alias=enb_testSetup
    ${L1_ERR_nrt_message_num}=    Count Syslog messages    regexp=ERR/l1_application    alias=enb_testSetup
    ${L1_WRN_rt_message_num}=     Count Syslog messages    regexp=WRN/l1_application_rt    alias=enb_testSetup
    ${L1_WRN_nrt_message_num}=    Count Syslog messages    regexp=WRN/l1_application_nrt    alias=enb_testSetup
    ${L1_WRN_nrt_message_num}=    Count Syslog messages    regexp=WRN/l1_application    alias=enb_testSetup
    Check L1 ERR and WRN in syslog

    ${crash_regexp}    Run Keyword If    '${crash_type.lower()}'=='arm'    Set Variable    Handling signal
    ...    ELSE IF    '${crash_type.lower()}'=='mhab'    Set Variable    Handling Isolate MHAB eo
    ...    ELSE IF    '${crash_type.lower()}'=='mdab'    Set Variable    Handling Isolate MDAB eo
    ...    ELSE    Fail    [ ERROR ] No '${crash_type}' crash type implemented.
    ${isCrash}    Run Keyword And Return Status    ute_syslog.Message Should Exist In Syslog File    regexp=${crash_regexp}     alias=enb_testSetup
    Run Keyword If    ${isCrash}    Log To Console    [ERROR] ${crash_type.upper()}Crash is NOT filtered in syslog.

    Run Keyword And Ignore Error    Stop Collect GNB Syslog    ${TEST_LOG_DIR}
    Run Keyword And Ignore Error    ute_syslog.Teardown All Aliases For Syslog
    Get Alarms State    alarm_management=Active
    Get Alarms State    alarm_management=Historic
    Run Keyword And Ignore Error    sbts_admin.teardown    connection=${connection}
    Run Keyword And Ignore Error    WebUI disconnection    suite

    ${snapshot}    Save Snapshot Via WebUI

    Run Keyword If    '${crash_type.lower()}'=='arm'    Check ARM crash In Snapshot    ${snapshot}    ${crash_time}
    ...    ELSE IF    '${crash_type.lower()}'=='mhab'    Check MHAB crash In Snapshot    ${snapshot}    ${crash_time}
    ...    ELSE    Check MDAB crash In Snapshot    ${snapshot}    # ${crash_time}

    Filter And Check DU L1 Journal Log    ${snapshot}
    Filter And Check RU L1 Runtime Log    ${snapshot}

Check ARM crash In Snapshot
    [Arguments]    ${snapshot}    ${crash_time}
    ${node_id}    Get Node Id    ABIP    thor_1
    ${coredump_files_dict}    Extract Specific Logs From Snapshot    coredump    ${snapshot}    ${node_id.strip('0x')}
    Get And Check Specific Logs Size    ${coredump_files_dict}    startswith=journal.l1_application_rt    endswith=.txt
    Get And Check Specific Logs Size    ${coredump_files_dict}    startswith=core.l1_application_rt    endswith=.gz
    Get And Check Specific Logs Size    ${coredump_files_dict}    startswith=ArmCrash_PSMLog_ctrl.bin    endswith=.mem.gz
    Get And Check Specific Logs Size    ${coredump_files_dict}    startswith=ArmCrash_PSMLog_entries.bin    endswith=.mem.gz
    Get And Check Specific Logs Size    ${coredump_files_dict}    startswith=CellBufferContextRt    endswith=.mem.gz
    Get And Check Specific Logs Size    ${coredump_files_dict}    startswith=CellContextRt    endswith=.mem.gz
    Get And Check Specific Logs Size    ${coredump_files_dict}    startswith=GlobalContextRt    endswith=.mem.gz

    ${servicefailures_files_dict}    Extract Specific Logs From Snapshot    servicefailures    ${snapshot}    ${node_id.strip('0x')}
    Get And Check Specific Logs Size    ${servicefailures_files_dict}    startswith=ArmCrash_PSMLog_ctrl.bin    endswith=.mem
    Get And Check Specific Logs Size    ${servicefailures_files_dict}    startswith=ArmCrash_PSMLog_entries.bin    endswith=.mem

    # ${l1acrashtrace_files_dict}    Extract Specific Logs From Snapshot    l1acrashtrace    ${snapshot}    ${node_id.strip('0x')}
    # Get And Check Specific Logs Size    ${l1acrashtrace_files_dict}    startswith=historyBufferFhFastArea
    # Get And Check Specific Logs Size    ${l1acrashtrace_files_dict}    startswith=historyBufferNrDlFastArea
    # Get And Check Specific Logs Size    ${l1acrashtrace_files_dict}    startswith=historyBufferNrUlFastArea

    ${rpramjournal_files_dict}    Extract rpramjournal Logs In Local rpram From Snapshot    ${snapshot}    ${node_id.strip('0x')}
    ...    ${crash_time}    ARM
    Get And Check Specific Logs Size    ${rpramjournal_files_dict}    endswith=previous_boot_running_journal.txt.gz

Check MHAB crash In Snapshot
    [Arguments]    ${snapshot}    ${crash_time}
    ${node_id}    Get Node Id    ABIP    thor_1
    ${mhab_crash_files_dict}    Extract Specific Logs From Snapshot    mhab_crash_files    ${snapshot}    ${node_id.strip('0x')}
    # Get And Check Specific Logs Size    ${mhab_crash_files_dict}    startswith=crashTrace    # need to be clarified with R&D
    Get And Check Specific Logs Size    ${mhab_crash_files_dict}    startswith=ID_00000001_PSMLog_ctrl.bin
    Get And Check Specific Logs Size    ${mhab_crash_files_dict}    startswith=ID_00000001_PSMLog_entries.bin
    Get And Check Specific Logs Size    ${mhab_crash_files_dict}    startswith=historyBufferL1CommonMabLog1

    ${rpramjournal_files_dict}    Extract rpramjournal Logs In Local rpram From Snapshot    ${snapshot}    ${node_id.strip('0x')}
    ...    ${crash_time}    MHAB
    Get And Check Specific Logs Size    ${rpramjournal_files_dict}    endswith=previous_boot_running_journal.txt.gz

Check MDAB crash In Snapshot
    [Arguments]    ${snapshot}    # ${crash_time}
    ${node_id}    Get Node Id    ABIP    thor_1
    ${mdab_crash_files_dict}    Extract Specific Logs From Snapshot    mdab_crash_files    ${snapshot}    ${node_id.strip('0x')}
    Get And Check Specific Logs Size    ${mdab_crash_files_dict}    startswith=ID_00004000_PSMLog_ctrl.bin
    Get And Check Specific Logs Size    ${mdab_crash_files_dict}    startswith=ID_00004000_PSMLog_entries.bin
    Get And Check Specific Logs Size    ${mdab_crash_files_dict}    startswith=ID_00004000_copyMdabCrashBuffer.bin
    Get And Check Specific Logs Size    ${mdab_crash_files_dict}    startswith=historyBufferL1CommonMabLog1

    Log To Console    [ INFO ]Skipping to check 134D_rpramjournal_*_previous_boot_running_journal.txt.gz due to DU MDABAutoHealing enabled(default).
    # ${rpramjournal_files_dict}    Extract rpramjournal Logs In Local rpram From Snapshot    ${snapshot}    ${node_id.strip('0x')}    ${crash_time}
    # Get And Check Specific Logs Size    ${rpramjournal_files_dict}    endswith=previous_boot_running_journal.txt.gz
