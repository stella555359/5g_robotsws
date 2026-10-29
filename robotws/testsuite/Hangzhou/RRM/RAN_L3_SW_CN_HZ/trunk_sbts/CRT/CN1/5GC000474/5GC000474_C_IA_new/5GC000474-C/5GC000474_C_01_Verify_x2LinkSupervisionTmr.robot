*** Settings ***
Documentation     this case is the 5GC000474_C_4304_and_5GSW_CP_EDA003_5GC000474_PR568631 for AP testline
...               \n Author: Carol.An@nokia-sbell.com CASE 5GC000474_C_4304_and_5GSW_CP_EDA_5GC000474_PR568631_shutdownNogNBCellTmr
...               \n Please do not edit the existing KWs in this file without testing.
...               \n PR568631: [21A][NSA][5GC00474][AEQN]counter M55110C00017 Number of SCTP shutdown due to no more gNB cell available pegged
...               \n value when shutdownNogNBCellTmr expired but no SCTP SHUTDOWN send out in wireshark
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT_no_cloud    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...               team-DevHZ5_SG2    owner-junhui.he    release-5G20A    CRT
Resource          ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{delete useless cell}
...    delete:MRBTS-1/NRBTS-1/NRCELL-2
...    delete:MRBTS-1/NRBTS-1/NRCELLGRP-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1
...    NRDU-1:refNrCellGroup=0
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations,accept unknown BCSs

${DEFAULT_TIMER}    1
#${cpif_log}         runtime_DEFAULT.log    ##by xxj
${cpif_log}         runtime_cp_if.log   ##by xxj
${NEW_TIMER}    2
@{setX2LinkSupervisionTmrTo2}    MRBTS-1/NRBTS-1:x2LinkSupervisionTmr=${NEW_TIMER}
@{setX2LinkSupervisionTmrTo1}    MRBTS-1/NRBTS-1:x2LinkSupervisionTmr=${DEFAULT_TIMER}
${Alarm_ID}         7107
${Fault_ID}         7300
${Alarm_detail}    No X2 link available

*** Test Cases ***
5GC000474_C_01_Verify_x2LinkSupervisionTmr_is_started_when_no_X2-C_link_available_and Modification of the parameter via OM
    [Tags]    QC_104312
    Set New Value For x2LinkSupervisionTmr    ${setX2LinkSupervisionTmrTo2}
    Wait x2LinkSupervisionTmr Timeout And Check Alarm Raised And Then Recover    ${NEW_TIMER}
    [Teardown]    Recover Env And Test Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Perform Steps After Onair
    Delta Commission Parameters    ${delete useless cell}

Set New Value For x2LinkSupervisionTmr
    [Arguments]    ${delta_commission_parameter}
    Delta Commission Parameters    ${delta_commission_parameter}

Wait x2LinkSupervisionTmr Timeout And Check Alarm Raised And Then Recover
    [Arguments]     ${Timer}
    Execute Egate Command    x2_link_reset from=1 to=2    ResetResponse    timeout=20s
    Sleep    ${Timer}m    reason=Wait x2LinkSupervisionTmr Timeout
    Check x2LinkSupervisionTmr By CPIF Log    ${Timer}
    Check Alarm Raised
    Recover X2 Link
    Check Alarm Cleared

Check x2LinkSupervisionTmr By CPIF Log
    [Arguments]    ${expected_time_interval}
    Get Cpif Log File Name
    ${expected_time_interval_sec}=    evaluate    ${expected_time_interval}*60
    Check The x2LinkSupervisionTmr Interval By Two Log Messages    ${expected_time_interval_sec}

Get Cpif Log File Name
    ${GNB1_output}    Execute Command On Enb    ls -al /tmp
    ${str}    ${cpif_file_tmp}    Should Match Regexp    ${GNB1_output}    0x(\\d+).*/ram/node_CPIF
    Set Suite Variable    ${cpif_file_name}    BTS1_${cpif_file_tmp.strip()}_runtime.zip
    Get Log From Snapshot With Name    file_name=${cpif_file_name}
    Set Suite Variable    ${local_path_cpif_file}    ${SAVE LOG DIRECTORY}/snapshot/${cpif_log}

Check The x2LinkSupervisionTmr Interval By Two Log Messages
    [Arguments]    ${expected_time_interval}
    ${start_time} =    Get The Start Time Of The String Format
    ...    log_path=${local_path_cpif_file}
    ...    fliter_str=start x2LinkSupervisionTmr timer
    ${end_time} =    Get The End Time Of The String Format
    ...    log_path=${local_path_cpif_file}
    ...    fliter_str=x2LinkSupervisionTmr timed out
    ${delta_time} =    DateTime.subtract date from date    ${end_time}    ${start_time}
    ${time_compare}    evaluate    float(${delta_time}/${expected_time_interval})
    should be true    1.01 >= ${time_compare} >= 0.99

Get The Start Time Of The String Format
    [Arguments]     ${log_path}    ${fliter_str}
    ${get_date} =    Catenate    cat ${log_path} |
    ...    grep '${fliter_str}'|tail -1|cut -d '<' -f 2|cut -d 'T' -f 1
    ${output_date} =    Execute Cmd On Pc    ${get_date}
    ${get_time} =    Catenate    cat ${log_path} |
    ...    grep '${fliter_str}'|tail -1|cut -d '<' -f 2|cut -d 'T' -f 2|cut -d 'Z' -f 1
    ${output_time} =    Execute Cmd On Pc    ${get_time}
    ${output} =    Catenate    ${output_date}    ${output_time}
    ${result} =    DateTime.convert date    ${output}
    [Return]    ${result}

Get The End Time Of The String Format
    [Arguments]     ${log_path}    ${fliter_str}
    ${get_date} =    Catenate    cat ${log_path} |
    ...    grep '${fliter_str}'|tail -1|cut -d '<' -f 2|cut -d 'T' -f 1
    ${output_date} =    Execute Cmd On Pc    ${get_date}
    ${get_time} =    Catenate    cat ${log_path} |
    ...    grep '${fliter_str}'|tail -1|cut -d '<' -f 2|cut -d 'T' -f 2|cut -d 'Z' -f 1
    ${output_time} =    Execute Cmd On Pc    ${get_time}
    ${output} =    Catenate    ${output_date}    ${output_time}
    ${result} =    DateTime.convert date    ${output}
    [Return]    ${result}

Check Alarm Raised
    ${fault}    Create List    fault_id=${Fault_ID}    alarm_id=${Alarm_ID}    fault_name=${Alarm_detail}
    Fm Fault Should Be Raised    ${fault}    120s

Recover X2 Link
    Execute Egate Command    enb_x2_link_up enb=1 target=2    X2AP Link with .* is up    timeout=2min

Check Alarm Cleared
    ${fault}    Create List    fault_id=${Fault_ID}    alarm_id=${Alarm_ID}    fault_name=${Alarm_detail}
    Fm Fault Should Be Cleared    ${fault}    120s

Recover Env And Test Teardown
    Recover X2 Link
    Set New Value For x2LinkSupervisionTmr    ${setX2LinkSupervisionTmrTo1}
    Common Test Teardown And Stop Capture Logs
