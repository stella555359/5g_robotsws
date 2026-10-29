*** Settings ***
Documentation    This is for TMO common keywords.
...              Please do not modify the file without notification to author
...              Author: jun.8.chen@nokia-sbell.com

Resource    ./TMO_common_keywords.robot

*** Keywords ***
Perform Reset With HWF Deletion Energy Saving Phase
    [Documentation]    author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${i}
    ${test_phase}    Set Variable    loop_${i}
    ${Duration}      Set Variable If    '${tl_prefix}'=='T073'    55    30
    Common_setup_and_teardown.Create Case Log Path
    run keyword and ignore error    COAM Teardown gnb connections
    uuf_rfrl_common_keywords.Get Iteration Start Time
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
    ${cell_list}    ${lbpsCellList_length}    ${lbpsCellPeriodList_length}    Get The Cell List What Will Be Enter Energy Saving Mode
    Wait Until Keyword Succeeds    1 min    5 sec   Connect to gnb coam via ssl
    Run Keyword And Ignore Error    coam.reset_site    wait_for_reconnection=${True}    connection=GNB_OAM    timeout=600
    sleep   2min
    ${gnb_status_status}   ${gnb_error_log}=    Run Keyword And Ignore Error    Check TMO Gnb Ready And All Cell On Air
    Check Gnb Startup Log
    Check Cell energySavingState    cell_list=${cell_list}    whether_check_energy_saving=${False}
    ${hour}    ${minute}    Get The Time For Energy Saving
    Update Related Parameters For Energy Saving    Duration=${Duration}
    ...                                            Hour=${hour}
    ...                                            Minute=${minute}
    ...                                            lbpsCellList_num=${lbpsCellList_length}
    ...                                            lbpsCellPeriodList_num=${lbpsCellPeriodList_length}
    Wait Until Keyword Succeeds    55 min    60 sec    Check Cell energySavingState    cell_list=${cell_list}
    Check TMO Gnb Ready And All Cell On Air
    Wait Until Keyword Succeeds    5 min    15 sec    Check Cell energySavingState    cell_list=${cell_list}
    ...                                                                               whether_check_energy_saving=${False}
    ${gnb_state}   ${gnb_error_log}=   Run Keyword And Ignore Error
    ...            Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
    ${enb_state}   ${enb_error_log}=   Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
    ...                Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
    ${test_result}    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
    ...               uuf_rfrl_common.Verify Iteration     ${test_phase}   ${enb_state}    ${gnb_status_status}   ${gnb_state}
    ...               ELSE    uuf_rfrl_common.Verify Iteration    ${test_phase}    ${gnb_status_status}   ${gnb_state}
    uuf_rfrl_common_keywords.Get Iteration End Time
	uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=${test_phase}
	Run Keyword If   '${test_result}'=='False'   Collect Snapshot Log in gnb and enb    timeout=${2400}
    Run Keyword If   '${test_result}'=='False'   Fail    Site Reset Failed - ${test_phase}
    [Teardown]      Run Keyword And Ignore Error    COAM Teardown gnb connections

Check Cell energySavingState
    [Documentation]    author: jun.8.chen@nokia-sbell.com
    ...                Check cell status: energySaving or notEnergySaving
    [Arguments]    ${cell_list}    ${connection}=GNB_OAM    ${gnb_index}=${0}    ${whether_check_energy_saving}=${True}
    Wait Until Keyword Succeeds    1min    20sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${cells_info}    coam.get_cells_info    cell_type=nr    timeout=20    connection=${connection}
    ${need_to_check_cell_info_list}    Create List
    FOR    ${cell}    IN    @{cells_info}
        ${cell_index}    Set Variable    ${cell['id']['configuration'].split('-')[-1]}
        ${status}    Run Keyword And Return Status    List Should Contain Value    ${cell_list}    ${cell_index}
        Run Keyword If    ${status}    Append To List    ${need_to_check_cell_info_list}    ${cell}
    END
    Log to console    Start to check cell status
    ${operationalState}    Set Variable If    ${whether_check_energy_saving}    disabled    enabled
    ${energySavingState}    Set Variable If    ${whether_check_energy_saving}    energySaving    notEnergySaving
    FOR    ${item}    IN    @{need_to_check_cell_info_list}
        Run keyword and continue on failure    Should be equal as strings    ${item['status']['operationalState']}    ${operationalState}
        Run keyword and continue on failure    Should Be Equal As Strings    ${item['status']['administrativeState']}    Unlocked
#        Run keyword and continue on failure    Should Be Equal As Strings    ${item['energySavingState']}    ${energySavingState}
        ${result}    Evaluate    '${item['energySavingState']}'=='${energySavingState}' or '${item['energySavingState']}'=='reducedEnergySaving'
        Run keyword and continue on failure    Should Be True    ${result}
    END
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check RU Should Be SLEEP
    [Documentation]    author: jun.8.chen@nokia-sbell.com
    ...                Check RU status: SLEEP
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=${0}
    Wait Until Keyword Succeeds    1min    20sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    Get length    ${list_RUs}
    Should be true    ${count_RUs}>=1    msg=No RU found
    ${power_State}    Set Variable If    '${stream_version}'=='master'    SLEEP_EXTREME    SLEEP
    FOR    ${RU}    IN    @{list_RUs}
        ${productName}    Set Variable    ${RU['productName']}
        ${powerState}    Set Variable    ${RU['status']['powerState']}
        IF    '${productName}'=='AVHA'
             Run keyword and continue on failure    Should Be Equal As Strings    ${powerState}    ${power_State}
        END
    END
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get The Cell List What Will Be Enter Energy Saving Mode
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=0    ${timeout}=${60}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${managed_objects}    coam.get_managed_objects    class_name=NRPGRP_A    connection=${connection}    timeout=${timeout}
    ${lbpsCellList_length}    Evaluate    len(${managed_objects[0]['parameters']['lbpsPeriodList']})-1
    ${lbpsCellPeriodList_length}    Evaluate    len(${managed_objects[0]['parameters']['lbpsCellPeriodList']})-1
    ${cell_list}    Create List
    FOR    ${item}    IN    @{managed_objects}
        ${lbpsCellList}    Set Variable    ${item['parameters']['lbpsCellList']}
        FOR    ${lbpsCel}    IN    @{lbpsCellList}
            ${lbpsCellSOOrder}    Set Variable    ${lbpsCel['lbpsCellSOOrder']}
            ${cell_id}     Evaluate    str(${lbpsCel['nrCellId']})
            Run Keyword If    ${lbpsCellSOOrder} != 100    Append To List    ${cell_list}    ${cell_id}
        END
    END
    ${cell_list}    Remove Duplicates    ${cell_list}
    [Return]    ${cell_list}    ${lbpsCellList_length}    ${lbpsCellPeriodList_length}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Update Related Parameters For Energy Saving
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]   ${Duration}=30
    ...           ${Hour}=10
    ...           ${Minute}=30
    ...           ${lbpsCellList_num}=6
    ...           ${lbpsCellPeriodList_num}=27
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[0].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[0].global_bts_id}
    ${lbpsPeriodList_context}    Evaluate
    ...    {'lbpsSuspended':'notSuspended','lbpsDuration':'${Duration}','lbpsStartTimeHour':'${Hour}','lbpsStartTimeMinute':'${Minute}'}
    ${lbpsPeriodList}    Create List    ${lbpsPeriodList_context}
    FOR    ${index}    IN RANGE     ${lbpsCellList_num}
        Append To List     ${lbpsPeriodList}    ${lbpsPeriodList_context}
    END
    ${update_lbpsPeriodList}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-0',
    ...    'parameter':'lbpsPeriodList','value':${lbpsPeriodList}},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-1',
    ...    'parameter':'lbpsPeriodList','value':${lbpsPeriodList}},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-2',
    ...    'parameter':'lbpsPeriodList','value':${lbpsPeriodList}}
    ${lbpsCellPeriodList_context}     Evaluate
    ...    {'lbpsCellDuration':'${Duration}','lbpsCellStartTimeHour':'${Hour}','lbpsCellStartTimeMinute':'${Minute}'}
    ${lbpsCellPeriodList}    Create List    ${lbpsCellPeriodList_context}
    FOR    ${index}    IN RANGE     ${lbpsCellPeriodList_num}
        Append To List     ${lbpsCellPeriodList}    ${lbpsCellPeriodList_context}
    END
    ${update_lbpsCellPeriodList}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-0',
    ...    'parameter':'lbpsCellPeriodList','value':${lbpsCellPeriodList}},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-1',
    ...    'parameter':'lbpsCellPeriodList','value':${lbpsCellPeriodList}},
    ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-2',
    ...    'parameter':'lbpsCellPeriodList','value':${lbpsCellPeriodList}}
    ${update_param_list}     Evaluate    [${update_lbpsPeriodList},${update_lbpsCellPeriodList}]
    Update Params Through RestApi    params_need_to_modify=${update_param_list}

Update Related Parameters For Exit Energy Saving
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]   ${cell_list}
    ...           ${reportAmountCA_value}=r4
    ...           ${qRxLevMin_value}=-50
    ...           ${actBadUplinkRadioRedirect_vlaue}=disabled
    ...           ${ulBlerThresholdRedirectData}=100
    ...           ${ulBlerThresholdRedirectVoNR}=30
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[0].instance_id}
    ${NRBTS_ID}    Set Variable    ${tl.gnbs[0].global_bts_id}
    ${update_param_list}    Create List
    ${ulBler_context}    Evaluate
    ...    {'ulBlerThresholdRedirectData':'${ulBlerThresholdRedirectData}','ulBlerThresholdRedirectVoNR':'${ulBlerThresholdRedirectVoNR}'}
    ${ulBler_list}    Create List    ${ulBler_context}
    FOR    ${cell}    IN     @{cell_list}
        ${cell_update_List}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell}',
        ...    'parameter':'ulBler','value':${ulBler_list}},
        ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell}',
        ...    'parameter':'reportAmountCA','value':'${reportAmountCA_value}'},
        ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell}',
        ...    'parameter':'qRxLevMin','value':'${qRxLevMin_value}'},
        ...    {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell}',
        ...    'parameter':'actBadUplinkRadioRedirect','value':'${actBadUplinkRadioRedirect_vlaue}'}
        ${cell_update_List}    Evaluate    [${cell_update_List}]
        ${update_param_list}    Combine Lists    ${update_param_list}    ${cell_update_List}
    END
    Update Params Through RestApi    params_need_to_modify=${update_param_list}

Update windowDuration For AVHA Power State
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=${0}    ${Duration}=1440
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[0].instance_id}
    Wait Until Keyword Succeeds    1min    20sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    Get length    ${list_RUs}
    Should be true    ${count_RUs}>=1    msg=No RU found
    @{ru_index_list}    Create List
    FOR    ${RU}    IN    @{list_RUs}
        ${productName}    Set Variable    ${RU['productName']}
        ${rmod_index}   Set variable   ${RU['id']['configuration'].split('RMOD-')[-1]}
        IF    '${productName}'=='AVHA'
             Append To List    ${ru_index_list}    ${rmod_index}
        END
    END
    ${update_param_list}    Create List
    ${deepSleepTimeSchedule_context}    Evaluate
    ...    {'dayOfWeek':'Every day','startTime':'00:00','windowDuration':'${Duration}'}
    ${deepSleepTimeSchedule_list}    Create List    ${deepSleepTimeSchedule_context}
    FOR    ${ru_index}    IN     @{ru_index_list}
        ${update_List}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}',
        ...    'parameter':'deepSleepTimeSchedule','value':${deepSleepTimeSchedule_list}},
        ${update_List}    Evaluate    [${update_List}]
        ${update_param_list}    Combine Lists    ${update_param_list}    ${update_List}
    END
    Update Params Through RestApi    params_need_to_modify=${update_param_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get The Time For Energy Saving
    [Documentation]   jun.8.chen@nokia-sbell.com
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${origin_time}    robot.libraries.DateTime.convert_date    ${timestamp}    datetime
    ${minute}    set variable    ${origin_time.minute}
    ${hour}    set variable    ${origin_time.hour}
    [Return]    ${hour}    ${minute}

Perform Reset with HWF deletion On LTE
    [Documentation]    author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${i}
    ${test_phase}    Set Variable    loop_${i}
    Common_setup_and_teardown.Create Case Log Path
    run keyword and ignore error    COAM Teardown gnb connections
    uuf_rfrl_common_keywords.Get Iteration Start Time
    uuf_rfrl_oam_kpi.Setup Admin Connection For KPI IMS
    Wait Until Keyword Succeeds    1 min    5 sec   Connect to eNB via ssl    enb_index=${0}    connection=enblte_reset
    Run Keyword And Ignore Error    coam.reset_site    connection=enblte_reset
    Sleep   5min
    ${enb_status_status}   ${enb_error_log}=    Run Keyword And Ignore Error    Verify All Enbs Cell On Air    timeout=5 min
    Check Enb Startup Log
    ${gnb_state}   ${gnb_error_log}=   Run Keyword And Ignore Error
    ...            Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
    ${enb_state}   ${enb_error_log}=   Run Keyword And Ignore Error    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
    ...                Check ENB On Air And Unexpect Alarm Should Not Exist without snapshot
    ${test_result}    Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'
    ...               uuf_rfrl_common.Verify Iteration     ${test_phase}   ${enb_state}    ${enb_status_status}   ${gnb_state}
    ...               ELSE    uuf_rfrl_common.Verify Iteration    ${test_phase}    ${enb_status_status}   ${gnb_state}
    uuf_rfrl_common_keywords.Get Iteration End Time
	uuf_rfrl_oam_kpi.Calculate Proper Oam Kpi    test_phase=${test_phase}
	Run Keyword If   '${test_result}'=='False'   Collect Snapshot Log in gnb and enb    timeout=${2400}
    Run Keyword If   '${test_result}'=='False'   Fail    Site Reset Failed - ${test_phase}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    AND
    ...                           Run Keyword And Ignore Error    coam.teardown    connection=enblte_reset

Check GNB And Enb Whether Need To Load SCF
    [Documentation]    author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${gnb_id}=${0}    ${connection}=GNB_OAM${gnb_id}    ${timeout}=${900}
    ...            ${enb_index}=${0}    ${connection_enb}=enblte
    ${btsName_in_gnb}    ${gnb_swVersion}    Get BtsName and SwVersion    gnb_id=${gnb_id}
    ...                                                                   connection=${connection}
    ...                                                                   timeout=${timeout}
    ${version_in_gnb}    Get Current SW Version From Version Name    active_version=${gnb_swVersion}
    ${btsName_output}    OperatingSystem.Run    cat ${SCF_PATH_ON_UTE}/${tl_prefix}_gNB_${version_in_gnb}.xml | grep -i btsName
    ${btsName_in_scf}    Set Variable    ${btsName_output.split("</")[0].split(">")[-1]}
    ${is_commission_gnb}    Set Variable If    '${btsName_in_gnb}'=='${btsName_in_scf}'    ${False}    ${True}
    ${btsName_in_enb}    ${enb_swVersion}    Get BtsName And Version From ENB    enb_index=${enb_index}
    ...                                                                          enb_connection=${connection_enb}
    ...                                                                          timeout=${timeout}
    ${version_in_enb}    Get Current SW Version From Version Name    active_version=${enb_swVersion}
    ${enb_btsName_output}    OperatingSystem.Run    cat ${SCF_PATH_ON_UTE}/${tl_prefix}_FDDeNB_${version_in_enb}.xml | grep -i btsName
    ${enb_btsName_in_scf}    Set Variable    ${enb_btsName_output.split("</")[0].split(">")[-1]}
    ${is_commission_enb}    Set Variable If    '${btsName_in_enb}'=='${enb_btsName_in_scf}'    ${False}    ${True}
    [Return]    ${is_commission_gnb}    ${is_commission_enb}    ${version_in_gnb}    ${version_in_enb}

Reboot Samsung UE
    [Documentation]  This keyword is turn on airplane mode on UE
    ...    2026-02-02 Jiao Jasper:
    [Arguments]     ${ue_PC_addr}=10.57.150.237    ${UE_SN}=R3CRC011CQD    ${UEPC}=UEPC
    csn.Connect to    hostname=${ue_PC_addr}
    ...               username=mn5gran
    ...               password=nokia123@
    ...               alias=${UEPC}
    csn.execute    command=adb -s ${UE_SN} reboot    connection=UEPC
    sleep    5s
    [Teardown]    csn.disconnect    connection=UEPC

Reboot UEs of PC237
    ${UE_SN_list}    Create List    R3CRC011CQD
    FOR    ${UE_SN}    IN    @{UE_SN_list}
        Run Keyword And Ignore Error    Reboot Samsung UE    ue_PC_addr=10.57.150.237     UE_SN=${UE_SN}
    END

Reboot UEs of PC209
    ${UE_SN_list}    Create List    R5CY63ZEMNV    R5CY93A1AQB    RFCXC0GGJAT    RFCY81SRFAP
    FOR    ${UE_SN}    IN    @{UE_SN_list}
        Run Keyword And Ignore Error    Reboot Samsung UE    ue_PC_addr=10.57.130.209     UE_SN=${UE_SN}
    END

Reboot UEs of PC142
    ${UE_SN_list}    Create List    M90E1151    M90E1574
    FOR    ${UE_SN}    IN    @{UE_SN_list}
        Run Keyword And Ignore Error    Reboot Samsung UE   ue_PC_addr=10.57.130.142    UE_SN=${UE_SN}
    END

Reboot UEs of PC163
    ${UE_SN_list}    Create List    M90E1129    M90E1169
    FOR    ${UE_SN}    IN    @{UE_SN_list}
        Run Keyword And Ignore Error    Reboot Samsung UE    ue_PC_addr=10.57.130.163    UE_SN=${UE_SN}
    END

Trun On AIRPLANE Mode On UE
    [Documentation]  This keyword is turn on airplane mode on UE
    ...    2026-02-02 Jiao Jasper:
    [Arguments]     ${ue_PC_addr}=10.57.130.228    ${UE_SN}=e4156499    ${UEPC}=UEPC
    csn.Connect to    hostname=${ue_PC_addr}
    ...               username=mn5gran
    ...               password=nokia123@
    ...               alias=${UEPC}
    csn.execute    command=adb devices    connection=UEPC
    sleep    1s
    csn.execute    command=adb -s ${UE_SN} shell settings put global airplane_mode_on 1    connection=UEPC
    sleep    1s
    csn.execute    command=adb -s ${UE_SN} shell am broadcast -a android.intent.action.AIRPLANE_MODE --ez state true    connection=UEPC
    sleep    3s
    [Teardown]    csn.disconnect    connection=UEPC

Trun Off AIRPLANE Mode On UE
    [Documentation]  This keyword is turn off airplane mode on UE
    ...    2026-02-02 Jiao Jasper:
    [Arguments]     ${ue_PC_addr}=10.57.130.228    ${UE_SN}=e4156499    ${UEPC}=UEPC
    csn.Connect to    hostname=${ue_PC_addr}
    ...               username=mn5gran
    ...               password=nokia123@
    ...               alias=${UEPC}
    csn.execute    command=adb devices    connection=UEPC
    sleep    1s
    csn.execute    command=adb -s ${UE_SN} shell settings put global airplane_mode_on 0     connection=UEPC
    sleep    1s
    csn.execute    command=adb -s ${UE_SN} shell am broadcast -a android.intent.action.AIRPLANE_MODE --ez state false    connection=UEPC
    sleep    3s
    [Teardown]    csn.disconnect    connection=UEPC

Reboot CPEs of T073
    [Documentation]  This keyword is turn off airplane mode on UE
    ...    2026-02-02 Jiao Jasper:
    [Arguments]     ${ue_PC_addr}=10.57.156.56    ${UEPC}=UEPC
    csn.Connect to    hostname=${ue_PC_addr}
    ...               username=spark
    ...               password=spark
    ...               alias=${UEPC}
    csn.execute    /cygdrive/c/python38/python.exe ue_operatin_script/uebox_operation.py -a reset -p 46,44,55,58,45    connection=UEPC
    sleep    60s
    [Teardown]    csn.disconnect    connection=UEPC

Initial UEs of T073
    Reboot UEs of PC237
    sleep    5s
    Reboot UEs of PC142
    sleep    5s
    Reboot UEs of PC163
    sleep    5s
    Trun On AIRPLANE Mode On UE
    sleep    5s
    Trun Off AIRPLANE Mode On UE
    sleep    5s
    Reboot CPEs of T073

Initial UEs of T077
    Reboot UEs of PC237
    sleep    5s
    Reboot UEs of PC142
    sleep    5s
    Reboot UEs of PC163
    sleep    5s