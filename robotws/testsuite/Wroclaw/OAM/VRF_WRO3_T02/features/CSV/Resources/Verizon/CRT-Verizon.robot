*** Settings ***
Documentation   Set of test used in testsuite for Verizon teslines.
...             Author:     Tomasz Stawowczyk
...             Contact:    tomasz.stawowczyk@nokia.com

Library     Collections
Library     taf.transport.ssh
Library     taf.hw.pdu    WITH NAME    pdu
Resource    ../../../../common_resources/admin/bts_operations.robot
Resource    ../../../../common_resources/ue/ue_operations.robot
Resource    ../../../../common_resources/attenuator/attenuator.robot


*** Keywords ***
SBTS Random Unshared RMOD Reset
    [Arguments]    ${nb_of_resets}    ${sign}    ${numb}    ${omit}=False
    Collect Infomodel Log From Current Session    target_file_name=${LOG_PATH}/IMS_before_rmod_reset.ims2
    ...    connection=${CONNECTION}
    ${rmods_distNames}    Get List Of Rmods DistNames    sign=${sign}    numb=${numb}    omit=${omit}
    Perform Random Object Reset    ${rmods_distNames}    RMOD    ${nb_of_resets}
    Log    \nEach RMOD reset succesful, no unexpected events!    console=True
    Collect Infomodel Log From Current Session    target_file_name=${LOG_PATH}/IMS_after_rmod_reset.ims2    connection=${CONNECTION}

SBTS BBMOD Lock All Unlock All
    ${object_locked}    Set Variable    False
    Collect Infomodel Log From Current Session    target_file_name=${LOG_PATH}/IMS_before_bbmod_locking.ims2
    ...    connection=${CONNECTION}
    ${bbmods_distNames}    Get List Of Bbmods DistNames
    ${object_locked}    Set Variable    True
    Lock All Objects    ${bbmods_distNames}    BBMOD
    Collect Infomodel Log From Current Session    target_file_name=${LOG_PATH}/IMS_with_bbmods_locked.ims2
    ...    connection=${CONNECTION}
    [Teardown]    Run Keywords    Run Keyword If    ${object_locked}    Unlock All Objects    ${bbmods_distNames}    BBMOD
    ...    AND    Wait Until Keyword Succeeds     1m    30s    Check That The BTS Is Fully Operational
    ...    connection=${CONNECTION}    ignored_alarms=${IGNORED_ALARMS}
    ...    AND    Log    \nLocking/unlocking all BBMODs succesful, no unexpected events!    console=True
    ...    AND    Collect Infomodel Log From Current Session    target_file_name=${LOG_PATH}/IMS_after_bbmod_unlock.ims2
    ...    connection=${CONNECTION}

SBTS Random RMODs Lock Unlock In Loop
    [Arguments]    ${nb_of_locks}    ${sign}    ${numb}    ${omit}=False
    ${something_locked}    Set Variable    False
    Collect Infomodel Log From Current Session    target_file_name=${LOG_PATH}/IMS_before_rmod_locking.ims2
    ...    connection=${CONNECTION}
    ${rmods_distNames}    Get List Of Rmods DistNames    sign=${sign}    numb=${numb}    omit=${omit}
    ${something_locked}    Set Variable    True
    ${locked_rmods}    Lock Random Objects    ${rmods_distNames}    RMOD    ${nb_of_locks}
    Set Test Variable    ${LOCKED_RMODS}    ${locked_rmods}
    Collect Infomodel Log From Current Session    target_file_name=${LOG_PATH}/IMS_with_rmods_locked.ims2
    ...    connection=${CONNECTION}
    [Teardown]    Run Keywords    Run Keyword If    ${something_locked}    Unlock Drawn Objects    ${LOCKED_RMODS}    RMOD
    ...    AND    Collect Infomodel Log From Current Session    target_file_name=${LOG_PATH}/IMS_after_rmod_unlock.ims2
    ...    connection=${CONNECTION}
    ...    AND    Wait Until Keyword Succeeds     1m    30s    Check That The BTS Is Fully Operational
    ...    connection=${CONNECTION}    ignored_alarms=${IGNORED_ALARMS}
    ...    AND    Log    Locking/unlocking each RMOD finished succesful!    console=True

SBTS RMOD Lock All Unlock All
    [Arguments]    ${sign}    ${numb}    ${omit}=False
    ${object_locked}    Set Variable    False
    Collect Infomodel Log From Current Session    target_file_name=${LOG_PATH}/IMS_before_rmod_locking.ims2
    ...    connection=${CONNECTION}
    ${rmods_distNames}    Get List Of Rmods DistNames    sign=${sign}    numb=${numb}    omit=${omit}
    ${object_locked}    Set Variable    True
    Lock All Objects    ${rmods_distNames}    RMOD
    Collect Infomodel Log From Current Session    target_file_name=${LOG_PATH}/IMS_with_rmods_locked.ims2
    ...    connection=${CONNECTION}
    [Teardown]    Run Keywords    Run Keyword If    ${object_locked}    Unlock All Objects    ${rmods_distNames}    RMOD
        ...    AND    Collect Infomodel Log From Current Session
        ...    target_file_name=${LOG_PATH}/IMS_after_rmods_unlock.ims2    connection=${CONNECTION}
        ...    AND    Wait Until Keyword Succeeds     1m    30s    Check That The BTS Is Fully Operational
        ...    connection=${CONNECTION}    ignored_alarms=${IGNORED_ALARMS}
        ...    AND    Log    Locking/unlocking all RMODs finished succesful!    console=True

SBTS LNCEL Block All Unblock All
    Collect Infomodel Log From Current Session    target_file_name=${LOG_PATH}/IMS_before_lncels_blocking.ims2
    ...    connection=${CONNECTION}
    Log    \nBlocking all LTE cells ...    console=True
    ${rat_blocked}    Set Variable    True
    Block All Cells    LTE    timeout=120    connection=${CONNECTION}
    Log    \nAll LNCELs blocked succesfully!    console=True
    Collect Infomodel Log From Current Session    target_file_name=${LOG_PATH}/IMS_all_lncels_blocked.ims2
    ...    connection=${CONNECTION}
    [Teardown]
    Run Keywords    Run Keyword If    ${rat_blocked}    Unblock All Cells    LTE    timeout=120
    ...    connection=${CONNECTION}
    ...    AND    Log    \nUnblocking all LTE cells ...    console=True
    ...    AND    Collect Infomodel Log From Current Session
    ...    target_file_name=${LOG_PATH}/IMS_after_lncels_unblock.ims2    connection=${CONNECTION}
    ...    AND    Wait Until Keyword Succeeds     1m    30s    Check That The BTS Is Fully Operational
    ...    connection=${CONNECTION}    ignored_alarms=${IGNORED_ALARMS}
    ...    AND    Log    \nBlocking/unblocking all LNCELs finished succesful!    console=True

SBTS LNCEL Lock All Unlock All
    ${cell_locked}    Set Variable    False
    Collect Infomodel Log From Current Session    target_file_name=${LOG_PATH}/IMS_before_lncels_locking.ims2
    ...    connection=${CONNECTION}
    ${lncels_distnames}    Get List Of Lncels DistNames
    ${cell_locked}    Set Variable    True
    Lock All Objects    ${lncels_distnames}    LNCEL
    Collect Infomodel Log From Current Session    target_file_name=${LOG_PATH}/IMS_all_lncels_locked.ims2
    ...    connection=${CONNECTION}
    [Teardown]    Run Keywords    Run Keyword If    ${cell_locked}    Unlock All Objects    ${lncels_distnames}    LNCEL
    ...    AND    Collect Infomodel Log From Current Session
    ...    target_file_name=${LOG_PATH}/IMS_after_lncels_unlock.ims2    connection=${CONNECTION}
    ...    AND    Wait Until Keyword Succeeds     1m    30s    Check That The BTS Is Fully Operational
    ...    connection=${CONNECTION}    ignored_alarms=${IGNORED_ALARMS}
    ...    AND    Log    \nLocking/unlocking all LNCELs finished succesful!    console=True

Verify File System Is Mounted
    Creating Log Directory
    taf.transport.ssh.Connect To  ${BTS_IP}  ${BTS_LOGIN}  ${BTS_PASS}  alias=${CONNECTION}
	${ls_output}    taf.transport.ssh.Execute   ls /ram > ls_content.txt
	Log    \n${ls_output}    console=True
	${ls_status}    taf.transport.ssh.Get Exit Status    ${CONNECTION}
	Should Be Equal As Integers  ${ls_status}  0  msg=ls command ended with an error
	taf.transport.ssh.Download File  ls_content.txt  ${LOG_PATH}/ls_content.txt  connection=${CONNECTION}
	${rm_output}    taf.transport.ssh.Execute    rm ls_content.txt
	Log    \n${rm_output}    console=True
	${rm_status}    taf.transport.ssh.Get Exit Status    ${CONNECTION}
	Should Be Equal As Integers  ${rm_status}  0  msg=rm command ended with an error
	taf.transport.ssh.Disconnect  connection=${CONNECTION}

Power Off/On RRH
    [Arguments]    ${pdu_ip}    ${rmod_pdu_port}    ${rmod_name}    ${pdu_vendor}=EPC    ${pdu_version}=8041-1
    Collect Infomodel Log From Current Session    target_file_name=${LOG_PATH}/IMS_before_power_reset.ims2
    Log    \nPower Off ${rmod_name} RRH and wait till corresponding alarm occures ...   console=True
    pdu.Setup PDU    model=${pdu_vendor}    host=${pdu_ip}    alias=pdu  version=${pdu_version}
    pdu.Power Off    ${rmod_pdu_port}    pdu
    Wait Until Keyword Succeeds     2m    30s    Assert Alarm Active     faultId=10    connection=${CONNECTION}
    Collect Infomodel Log From Current Session    target_file_name=${LOG_PATH}/IMS_with_${rmod_name}_off.ims2
    Log    \n${rmod_name} turned off, expected alarm occured, now turning on ...    console=True
    pdu.Power On    ${rmod_pdu_port}    pdu
    Wait Until Keyword Succeeds     5m    30s    Check That The BTS Is Fully Operational
    ...    connection=${CONNECTION}    ignored_alarms=${IGNORED_ALARMS}
    Log    \n${rmod_name} turned on succesful, no unexpected events!    console=True
    [Teardown]    pdu.Teardown PDU    pdu

Assert Parameter Value And Corresponding Alarm
    [Arguments]    ${parameter}=systemAcctPermEnable    ${alarm}=4655    ${expected_value}=false
    ${value}    Check current parameter value    ${parameter}    filename=${LOG_PATH}/full_scf.xml
    ${actual_value}  Get From List  ${value}  0
    ${lower_value}    Evaluate    '${actual_value}'.lower()
    Should Be True    '${lower_value}' == '${expected_value}'
    Alarm Should be Active In BTS    ${alarm}
    Collect Infomodel Log From Current Session    target_file_name=${LOG_PATH}/IMS_with_FID_4655.ims2
    Log    Parameter ${parameter} has proper value ${expected_value} and expected fault ${alarm} appeared.\n    console=True

Sky Visibility Status Should Be Excellent
    [Arguments]    ${gps_info}
    ${gps_info} =   Get From List  ${gps_info}  0
    ${sky_visibility} =  Get From Dictionary  ${gps_info}  skyVisibility
    Should Be Equal As Strings  ${sky_visibility}  Excellent
    Log  ${sky_visibility}  console=True

CB006047-SR Check Parameters Made A Call And Collect Counters
    Log    == Checking that the parameters actMicroDtx, mdtxAggressiveness and mdtxPdcchSymb have the expected values ==\n
    ...    console=True
    ${actmicrodtx_value}    Check current parameter value    param_name=actMicroDtx    connection=${CONNECTION}
    ...    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${LTE_CELL_ID}    filename=${LOG_PATH}/full_scf.xml
    ${lower_value}    Evaluate    '${actmicrodtx_value[0]}'.lower()
    Should Be True    '${lower_value}' == 'true'
    ${mdtxaggressiveness_value}    Check current parameter value    param_name=mdtxAggressiveness    connection=${CONNECTION}
    ...    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${LTE_CELL_ID}    filename=${LOG_PATH}/full_scf.xml    collect_scf=False
    Should Be True    '${mdtxaggressiveness_value[0]}' == '8'
    ${mdtxpdcchsymb_value}    Check current parameter value    param_name=mdtxPdcchSymb    connection=${CONNECTION}
    ...    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${LTE_CELL_ID}    filename=${LOG_PATH}/full_scf.xml    collect_scf=False
    Should Be True    '${mdtxpdcchsymb_value[0]}' == '3'
    Log    == Parameters set as expected, starting data transfer ==\n    console=True
    Attach Ue And Check The Connection    expected_cell=${EUTRAN_CELL_ID}
    Start Data Transfer    lte_dt    lte_ue    dl    35m    throughput=100 Mbits/sec
    ...    protocol=udp    packet=1400    apn=${APN}
    Sleep    3s    msg=Waiting for call stabilization.
    Check Data Transfer Is Alive    lte_dt
    Log    == Data Transfer is ongoing, collecting counters, it may take a while ... ==\n    console=True
    ${waiting_time}    Count Measurement Period    ${BTS_IP}    15    ${BTS_LOGIN}    ${BTS_PASS}    delta=990
    Log  == Waiting ${waiting_time} seconds till counters will be ready ==\n  console=true
    Sleep    ${waiting_time}s    reason=Wait till counters will be collected.
    Collect PM Counters    target_dir_path=${LOG_PATH}/pm_counter    time_interval=30 min    intervals=15    xml_files_left=2
    ${counters_name}    Create List    M40002C1
    ${counters_dict}    Get Values Of Counters From List    ${LOG_PATH}/pm_counter    ${counters_name}    MRBTS-${BTS_ID}
    Log    == Checking counter values ==\n    console=True
    ${M40002C1_values}    Get From Dictionary    ${counters_dict}    M40002C1
    Should Be True    ${M40002C1_values[1]} > ${M40002C1_values[0]}
        ...  msg=The value of M40002C1 is not increasing as expected!
    [Teardown]    Run keywords
    ...    Run Keyword And Continue On Failure    Stop data transfer    lte_dt
    ...    AND    Detach Ue    lte_ue
    ...    AND    Collect Infomodel Log From Current Session    target_file_name=${LOG_PATH}/IMS_CB006047_feature.ims2

Make 16h Call Check Alarms And Counters
    Log    == Start 16h data transfer and check every half hour to see if the call is active ==\n     console=True
    Attach Ue And Check The Connection    expected_cell=${EUTRAN_CELL_ID}
    Start Data Transfer    lte_dt    lte_ue    dl    17h    throughput=100 Mbits/sec
    ...    protocol=udp    packet=1400    apn=${APN}
    Sleep    3s    msg=Waiting for call stabilization.
    Log    == Data transfer started! ==    console=True
    FOR    ${hour}    IN RANGE    1    33
        Check Data Transfer Is Alive    lte_dt
        Sleep    30m
        ${hours_left}    Evaluate    16 - ${hour}/2
        Log    Call is still going, remaining time is ${hours_left} hours ...\n    console=True
    END
    Log    == 16h transfer has been successful, alarm checks underway ... ==\n     console=True
    ${historical_alarms_info}   Get Historic Alarms   connection=${CONNECTION}
    FOR    ${info}    IN    @{historical_alarms_info}
        ${additionalFaultID_value}    Get From Dictionary    ${info}    additionalFaultID
        ${fault_id_name}    Set Variable    faultId=${additionalFaultID_value}
        List Should Contain Value    ${IGNORED_ALARMS}    ${fault_id_name}
        ...    msg=There was an alarm not included in the list of acceptable alarms, please check in the collected IMS!
    END
    Wait Until Keyword Succeeds     1m    30s    Check That The BTS Is Fully Operational
    ...    connection=${CONNECTION}    ignored_alarms=${IGNORED_ALARMS}
    ${waiting_time}    Count Measurement Period    ${BTS_IP}    15    ${BTS_LOGIN}    ${BTS_PASS}    delta=90
    Log  == Waiting ${waiting_time} seconds till counters will be ready ==\n  console=true
    Sleep    ${waiting_time}s    reason=Wait till counters will be collected.
    Collect PM Counters    target_dir_path=${LOG_PATH}/pm_counter    xml_files_left=4    time_interval=1 hour    intervals=15
    ${counters_list}    Create List    M8020C3    M8001C0    M8012C20    M8006C1
    ${counters_dict}    Get Values Of Counters From List    ${LOG_PATH}/pm_counter    ${counters_list}
    ...                 MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${LTE_CELL_ID}/PLMN-PLMN/MCC-${MCC}/MNC-${MNC}
    Log    == Checking counter values ==\n    console=True
    ${M8020C3_values_list}      Evaluate    [int(x) for x in ${counters_dict['M8020C3']}]
    ${M8001C0_values_list}      Evaluate    [int(x) for x in ${counters_dict['M8001C0']}]
    ${M8012C20_values_list}     Evaluate    [int(x) for x in ${counters_dict['M8012C20']}]
    ${M8006C1_values_list}      Evaluate    [int(x) for x in ${counters_dict['M8006C1']}]
    FOR    ${value}    IN RANGE    4
        Should Be True    ${M8020C3_values_list[${value}]} > 0
        ...  msg=The value of M8020C3 in any of the peariods is not greater than 0!
        Should Be True    ${M8001C0_values_list[${value}]} > 0
        ...  msg=The value of M8001C0 in any of the peariods is not greater than 0!
        Should Be True    ${M8012C20_values_list[${value}]} > 0
        ...  msg=The value of M8012C20 in any of the peariods is not greater than 0!
        Should Be True    ${M8006C1_values_list[${value}]} > 0
        ...  msg=The value of M8006C1 in any of the peariods is not greater than 0!
    END
    Log    == All counters have expected values ==\n    console=True
    [Teardown]    Run keywords
    ...    Run Keyword And Continue On Failure    Stop data transfer    lte_dt
    ...    AND    Detach Ue    lte_ue
    ...    AND    Collect Infomodel Log From Current Session    target_file_name=${LOG_PATH}/IMS_16h_call.ims2

EnergySaving Set Parameters And Check Counters
    ${information_log}    Catenate    SEPARATOR=
    ...    \n== Checking that the parameters actLBRTXPowerSaving, actOnlineTXSwitch, lbpsCellSOOrder,
    ...    lbpsCSONCtlEnabled and lbpsLastCellSOEnabled have the expected values ==\n
    Log    ${information_log}    console=True
    ${actLBRTXPowerSaving_value}    Check current parameter value    param_name=actLBRTXPowerSaving
    ...    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}    filename=${LOG_PATH}/full_scf.xml    connection=${CONNECTION}
    Should Be True    '${actLBRTXPowerSaving_value[0]}' == 'true'
    ...    msg=Parameter actLBRTXPowerSaving is not set as true!
    ${actOnlineTXSwitch_value}    Check current parameter value    param_name=actOnlineTXSwitch    collect_scf=False
    ...    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}    filename=${LOG_PATH}/full_scf.xml    connection=${CONNECTION}
    Should Be True    '${actOnlineTXSwitch_value[0]}' == 'true'
    ...    msg=Parameter actOnlineTXSwitch is not set as true!
    ${lbpsCellSOOrder_values}    Check current parameter value    param_name=lbpsCellSOOrder
    ...    filename=${LOG_PATH}/full_scf.xml    list_name=lbpsCellList    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/PSGRP-1
    ...    connection=${CONNECTION}    collect_scf=False
    ${expected_lbpsCellSOOrder_values}    Create List    10    50
    Lists Should Be Equal    ${lbpsCellSOOrder_values}    ${expected_lbpsCellSOOrder_values}
    ...    msg=Values of lbpsCellSOOrder in any of structure are different than expexted 10 and 50!
    ${energysaving_cells}    Check current parameter value    param_name=lnCelId
    ...    filename=${LOG_PATH}/full_scf.xml    list_name=lbpsCellList    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/PSGRP-1
    ...    connection=${CONNECTION}    collect_scf=False
    ${lbpsCSONCtlEnabled_value}    Check current parameter value    param_name=lbpsCSONCtlEnabled    collect_scf=False
    ...    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/PSGRP-1    filename=${LOG_PATH}/full_scf.xml    connection=${CONNECTION}
    Should Be True    '${lbpsCSONCtlEnabled_value[0]}' == 'false'
    ...    msg=Parameter lbpsCSONCtlEnabled is not set as false!
    ${lbpsLastCellSOEnabled_value}    Check current parameter value    param_name=lbpsLastCellSOEnabled    collect_scf=False
    ...    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/PSGRP-1    filename=${LOG_PATH}/full_scf.xml    connection=${CONNECTION}
    Should Be True    '${lbpsLastCellSOEnabled_value[0]}' == 'false'
    ...    msg=Parameter lbpsLastCellSOEnabled is not set as false!

    Log    == Parameters set as expected, starting energy save mode ==\n    console=True
    Create Delta    delta_id=delta_lbpsPeriodList
    Append Complex Item To Delta    MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/PSGRP-1    lbpsPeriodList
    ...    lbpsDayOfWeek=Mon    lbpsDuration=1440    lbpsStartTimeHour=0    lbpsStartTimeMinute=0
    ...    lbpsSuspended=notSuspended    delta_id=delta_lbpsPeriodList
    Append Complex Item To Delta    MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/PSGRP-1    lbpsPeriodList
    ...    lbpsDayOfWeek=Tue  lbpsDuration=1440    lbpsStartTimeHour=0    lbpsStartTimeMinute=0
    ...    lbpsSuspended=notSuspended    delta_id=delta_lbpsPeriodList
    Append Complex Item To Delta    MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/PSGRP-1    lbpsPeriodList
    ...    lbpsDayOfWeek=Wed  lbpsDuration=1440    lbpsStartTimeHour=0    lbpsStartTimeMinute=0
    ...    lbpsSuspended=notSuspended    delta_id=delta_lbpsPeriodList
    Append Complex Item To Delta    MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/PSGRP-1    lbpsPeriodList
    ...    lbpsDayOfWeek=Thu  lbpsDuration=1440    lbpsStartTimeHour=0    lbpsStartTimeMinute=0
    ...    lbpsSuspended=notSuspended    delta_id=delta_lbpsPeriodList
    Append Complex Item To Delta    MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/PSGRP-1    lbpsPeriodList
    ...    lbpsDayOfWeek=Fri  lbpsDuration=1440    lbpsStartTimeHour=0    lbpsStartTimeMinute=0
    ...    lbpsSuspended=notSuspended    delta_id=delta_lbpsPeriodList
    Append Complex Item To Delta    MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/PSGRP-1    lbpsPeriodList
    ...    lbpsDayOfWeek=Sat  lbpsDuration=1440    lbpsStartTimeHour=0    lbpsStartTimeMinute=0
    ...    lbpsSuspended=notSuspended    delta_id=delta_lbpsPeriodList
    Append Complex Item To Delta    MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/PSGRP-1    lbpsPeriodList
    ...    lbpsDayOfWeek=Sun  lbpsDuration=1440    lbpsStartTimeHour=0    lbpsStartTimeMinute=0
    ...    lbpsSuspended=notSuspended    delta_id=delta_lbpsPeriodList
    ${delta}    Get Delta    delta_id=delta_lbpsPeriodList
    Log    ${delta}    console=True
    Perform Delta Recommissioning    ${delta}    alias=${CONNECTION}
    Wait Until Keyword Succeeds    2min    10s    Check That The BTS Is Fully Operational
    ...    connection=${CONNECTION}    ignored_alarms=${IGNORED_ALARMS}

    ${waiting_time}    Count Measurement Period    ${BTS_IP}    15    ${BTS_LOGIN}    ${BTS_PASS}    delta=90
    Log  == Waiting ${waiting_time} seconds till counters will be ready ==\n  console=true
    Sleep    ${waiting_time}s    reason=Wait till counters will be collected.
    Collect PM Counters    target_dir_path=${LOG_PATH}/pm_counter    time_interval=15 min    intervals=15
    ${counters_name}    Create List    M8020C9
    ${counters_dict}    Get Values Of Counters From List    ${LOG_PATH}/pm_counter    ${counters_name}
    ...                 MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${energysaving_cells[0]}/PLMN-PLMN/MCC-${MCC}/MNC-${MNC}
    Log    == Checking counter values ==\n    console=True
    ${M8020C9_value}    Get From Dictionary    ${counters_dict}    M8020C9
    Should Be True    ${M8020C9_value[-1]} > 0
        ...  msg=The value of M8020C9 for LNCEL-${energysaving_cells[0]} is not increasing as expected!
    Log    == All counters have expected values ==\n    console=True
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Remove Delta    delta_id=delta_lbpsPeriodList
    ...    AND    Perform Commissioning    ${BTS_ID}    ${LOG_PATH}/full_scf.xml    connection=${CONNECTION}    timeout=600
    ...    AND    Wait Until Keyword Succeeds     10m    1m    Check That The BTS Is Fully Operational
    ...    connection=${CONNECTION}    ignored_alarms=${IGNORED_ALARMS}

3 Attempts Of eNB Resets With LTE Calls And Alarms Checking
    Require Ue    ue_alias=lte_ue    capabilities=REAL_UE
    FOR    ${index}    IN RANGE    1    4
        Log    == Start ${index} iteration of data transfer ==\n     console=True
        Attach Ue    lte_ue
        ${current_ue_cell}  Get Ue Info    lte_ue    cell_id
        Should Match    ${current_ue_cell}    ${EUTRAN_CELL_ID}
        ...    msg=UE attached to another cell than expected!
        Start Data Transfer    lte_dt    lte_ue    dl    3h    throughput=100 Mbits/sec
        ...    protocol=udp    packet=1400    apn=${APN}
        Sleep    3s    msg=Waiting for call stabilization.
        Log    == Data transfer started, first check after 30 minutes! ==    console=True
        FOR    ${hour}    IN RANGE    1    5
            Check Data Transfer Is Alive    lte_dt
            Sleep    30m
            ${hours_left}    Evaluate    2 - ${hour}/2
            Run Keyword If    ${hours_left} != 0.0
            ...    Log    Call is still going, remaining time is ${hours_left} hours ...\n    console=True
        END
        Log    == 2h transfer has been successful, alarm checks underway ... ==\n     console=True
        ${historical_alarms_info}   Get Historic Alarms   connection=${CONNECTION}
        FOR    ${info}    IN    @{historical_alarms_info}
            ${additionalFaultID_value}    Get From Dictionary    ${info}    additionalFaultID
            ${fault_id_name}    Set Variable    faultId=${additionalFaultID_value}
            List Should Contain Value    ${IGNORED_ALARMS}    ${fault_id_name}
            ...    msg=There was an alarm not included in the list of acceptable alarms, please check in the collected IMS!
        END
        Wait Until Keyword Succeeds     1m    30s    Check That The BTS Is Fully Operational
        ...    connection=${CONNECTION}    ignored_alarms=${IGNORED_ALARMS}
        Run Keyword And Continue On Failure    Stop data transfer    lte_dt
        Run Keyword And Continue On Failure    Detach Ue    lte_ue
        Reset Site    connection=${CONNECTION}
        Wait Until Keyword Succeeds     10m    1m    Check That The BTS Is Fully Operational
        ...    connection=${CONNECTION}    ignored_alarms=${IGNORED_ALARMS}
        Log    == ${index} iteration finished succesful ==\n     console=True
    END
    Log    == All iterations finished succesful ==\n    console=True
    [Teardown]    Run keywords
    ...    Run Keyword And Continue On Failure    Stop data transfer    lte_dt
    ...    AND    Run Keyword And Continue On Failure    Detach Ue    lte_ue
    ...    AND    Collect Infomodel Log From Current Session    target_file_name=${LOG_PATH}/IMS_6h_call.ims2
