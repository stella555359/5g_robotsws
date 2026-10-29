*** Settings ***
Documentation    This is for SG8 EnergySaving Exploratory Testing keywords
...              Author: zhenzhen.ren
...              Squard: HZ SG8

Library       taf.selenium.sbts    WITH NAME    selenium_coam
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.ue    WITH NAME    taf_ue
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BW_common_case/lib/BW_step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_SISO_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_powersaving_common_keywords.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py


*** Variables ***
@{EDSM_list}    'AVQQ'  'AVQC'  'AVNB'  'AVHA'
@{nrpgrp}    ${1}

*** Keywords ***
Commissioning SCF And Check BTS On Air
    [Arguments]    ${scf_name}=04131588
    log to console    import scf of ${scf_name}
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _${scf_name}.xml
    COAM Commission with scf file    scf_file_path=${SCF_upload}    timeout=${600}
    Wait until keyword succeeds    15min    180s    Check all cells info should be onair
    log to console    check active and history alarm
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}


add fault to the allowed history fault list
    [Arguments]    ${faultId}
    ${ALLOWED_HISTORY_FAULT_TEMP}    Copy List    ${ALLOWED_HISTORY_FAULT}
    ${fault_dic}    Create Dictionary    faultId=${faultId}
    Append To List     ${ALLOWED_HISTORY_FAULT_TEMP}    ${fault_dic}
    Set test Variable    ${ALLOWED_HISTORY_FAULT}    ${ALLOWED_HISTORY_FAULT_TEMP}


Enable or disbale 04131588 feature flag
    [Arguments]    ${connection}=GNB_OAM    ${value}=true
    wait until keyword succeeds    3x    30s    coam.perform_parameter_recommissioning
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}    parameter=actCellSwitchOnForCmUpdate
    ...    value=${value}    operation=update    connection=${connection}
    sleep    10

Enable or disable all the RMOD energysaving
    [Arguments]    ${connection}=GNB_OAM    ${energySavingMod}=NORMAL
    ${ru_index_list}    Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${ru_type}    Get RU type    ru_index=${ru_index}
        coam.perform_parameter_recommissioning
        ...    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    parameter=energySavingMode
        ...    value=${energySavingMod}    operation=update    connection=${connection}
        sleep    10
    END


Enable Rmod EDSM
    [Arguments]    ${connection}=GNB_OAM    ${energySavingMod}=DEEPSLEEP_EXTREME_SFP
    ${ru_index_list}    Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${ru_type}    Get RU type    ru_index=${ru_index}
        ${status}    Run Keyword And Return Status    should contain
        ...    ${EDSM_list}    '${ru_type}'
        run keyword if   '${status}' == 'True'    coam.perform_parameter_recommissioning
        ...    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    parameter=energySavingMode
        ...    value=${energySavingMod}    operation=update    connection=${connection}
        sleep    10s
    END


ES IWK with Parameter Change IWK with NG link interrupted
    [Arguments]    ${modify_list}    ${Max_loop}=${20}    ${lbpsDuration}=${60}
    Enable or disable all the RMOD energysaving
    ${nr_cell_id_list}    Get All Cell Id    cell_type=nr
    Set test variable    ${nr_cell_id_list}
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    test for time-${index}
        log to console    trigger cell switch off
        Modify lbpsPeriodList to trigger cell switch off    lbpsDuration=${lbpsDuration}
        Wait Until Keyword Succeeds    20min    3min    check all the nr cells enter energysaving or notEnergySaving
        log to console    lock ng link
        Lock Or Unlock NG Links    expected_value=Locked
        check all the nr cells enter energysaving or notEnergySaving
        log to console    modify defined parameters
        Modify Parameters inlcuding L2&L3    modify_list=${modify_list}    test_time=${0}
        check all the nr cells enter energysaving or notEnergySaving
        log to console    unlock ng link
        Lock Or Unlock NG Links    expected_value=Unlocked
        Wait Until Keyword Succeeds    3min    30s    Verify all cells should be onair    cell_type=nr
        Suspended or notSuspended energysaving by coam
        log to console    Modify Parameters inlcuding L2&L3
        Modify Parameters inlcuding L2&L3    modify_list=${modify_list}    test_time=${1}
        log to console    check active and history alarm
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        add fault to the allowed history fault list    faultId=${7107}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
        should be true    ${history_alarm_status}
    END


ES IWK with Parameter Change IWK with cell lock
    [Arguments]    ${modify_list}    ${Max_loop}=${20}    ${lbpsDuration}=${60}
    ${nr_cell_id_list}    Get All Cell Id    cell_type=nr
    Set test variable    ${nr_cell_id_list}
    Enable or disable all the RMOD energysaving
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    test for time-${index}
        log to console    trigger cell switch off
        Modify lbpsPeriodList to trigger cell switch off    lbpsDuration=${lbpsDuration}
        Wait Until Keyword Succeeds    20min    3min    check all the nr cells enter energysaving or notEnergySaving
        log to console    lock cells
        lock or unlock all the cells and check status    expected_value=Locked
        check all the nr cells enter energysaving or notEnergySaving    expect_state=notEnergySaving
        log to console    Modify Parameters inlcuding L2&L3
        Modify Parameters inlcuding L2&L3    modify_list=${modify_list}    test_time=${0}
        Check all the Cell lock or unlock status    adminState=locked
        log to console    unlock cells
        lock or unlock all the cells and check status    expected_value=Unlocked
        Wait Until Keyword Succeeds    3min    30s    Verify all cells should be onair    cell_type=nr
        Suspended or notSuspended energysaving by coam
        log to console    Modify Parameters inlcuding L2&L3
        Modify Parameters inlcuding L2&L3    modify_list=${modify_list}    test_time=${1}
        log to console    check active and history alarm
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
        should be true    ${history_alarm_status}
    END


ES Switching on IWK With Parameter change
    [Arguments]    ${modify_list}    ${Max_loop}=${20}    ${lbpsDuration}=${60}
    ${nr_cell_id_list}    Get All Cell Id    cell_type=nr
    Set test variable    ${nr_cell_id_list}
    Enable or disable all the RMOD energysaving
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    test for time-${index}
        log to console    trigger cell switch off
        ${initial_time}    Get Current Date    result_format=%Y%m%d%H%M%S
        log to console    trigger cell switch off
        Modify lbpsPeriodList to trigger cell switch off    lbpsDuration=${lbpsDuration}
        log to console    Modify Parameters inlcuding L2&L3
        Modify Parameters inlcuding L2&L3    modify_list=${modify_list}    test_time=${index}
        Wait Until Keyword Succeeds    3min    30s    Verify all cells should be onair    cell_type=nr
        Wait Until Keyword Succeeds    60min    3min    check all the nr cells enter energysaving or notEnergySaving
        ${index}    Evaluate    ${index} + 1
        ${mid_time}     Get Current Date    result_format=%Y%m%d%H%M%S
        ${diff}         Evaluate    int(${initial_time})+60 * ${lbpsDuration} -int(${mid_time})
        log to console    sleep ${diff},waiting for cell switch on and then modify L2 L3 parameter
        sleep    ${diff} sec
        Modify Parameters inlcuding L2&L3    modify_list=${modify_list}    test_time=${index}
        Wait Until Keyword Succeeds    10min    30s    Verify all cells should be onair    cell_type=nr
        log to console    Modify Parameters inlcuding L2&L3 and then make call
        ${index}    Evaluate    ${index} + 1
        Modify Parameters inlcuding L2&L3    modify_list=${modify_list}    test_time=${index}
        log to console    check active and history alarm and then make call
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
        should be true    ${history_alarm_status}
    END
    Suspended or notSuspended energysaving by coam
    Wait Until Keyword Succeeds    5min    30s    Verify all cells should be onair    cell_type=nr


EDSM after multiple RU reset
    [Arguments]    ${Max_loop}=${20}
    ${nr_cell_id_list}    Get All Cell Id    cell_type=nr
    Set test variable    ${nr_cell_id_list}
    Enable Rmod EDSM
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    ++++++++++++++++++++++++++++++++++++ Loop ${index} ++++++++++++++++++++++++++++++++++++
        Connect to gnb coam via ssl
        log to console    Step 1 Reset all RUs
        Reset all RMOD via coam
        sleep    10
        log to console    Step 2 All SMODs BBMODs RMODs and Cells onair
        All SMODs BBMODs RMODs and Cells should be onair
        Sleep    30
        log to console    Step 3 check not exist unexpect alarm
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        csn.reset_cache
    END
    lock or unlock all the cells and check status    expected_value=Locked
    Wait Until Keyword Succeeds    8min    120s    Special RMODs power state should be correct    expect_state=SLEEP_EXTREME
    log to console    sleep 10min after enter EDS
    sleep    10min
    lock or unlock all the cells and check status    expected_value=Unlocked    flag=False
    Wait Until Keyword Succeeds    10min    120s    Verify all cells should be onair    cell_type=nr
    Special RMODs power state should be correct
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=GNB_OAM
    should be true    ${history_alarm_status}
    [Teardown]    run keyword and ignore error   COAM Teardown gnb connections


EDSM after multiple snapshot
    [Arguments]    ${Max_loop}=${20}
    ${nr_cell_id_list}    Get All Cell Id    cell_type=nr
    Set test variable    ${nr_cell_id_list}
    Enable Rmod EDSM
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    ++++++++++++++++++++++++++++++++++++ Loop ${index} ++++++++++++++++++++++++++++++++++++
        Connect to gnb coam via ssl
        Save Coam Snapshot and rename    timeout=${1800}
        log to console    start to check active and history alarm
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        sleep    30
        csn.reset_cache
    END
    lock or unlock all the cells and check status    expected_value=Locked
    Wait Until Keyword Succeeds    8min    120s    Special RMODs power state should be correct    expect_state=SLEEP_EXTREME
    log to console    sleep 10min after enter EDS
    sleep    10min
    lock or unlock all the cells and check status    expected_value=Unlocked    flag=False
    Wait Until Keyword Succeeds    10min    120s    Verify all cells should be onair    cell_type=nr
    Special RMODs power state should be correct
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=GNB_OAM
    should be true    ${history_alarm_status}
    [Teardown]    run keyword and ignore error   COAM Teardown gnb connections


Save Coam Snapshot and rename
    [Arguments]    ${target_dir}=${OUTPUT DIR}     ${coverage}=Full    ${force}=${True}     ${timeout}=1500
    log to console    start to collect snapshot logs
    ${snapshot_path}      Set Variable    ${target_dir}/Snapshot_test.zip
    ${log_status}         Run Keyword And Return Status    coam.Get Snapshot
    ...                   target_file_name=${snapshot_path}
    ...                   coverage=${coverage}
    ...                   force=${force}
    ...                   connection=GNB_OAM
    ...                   timeout=${timeout}
    Run Keyword If        ${log_status}    Log To Console    Collecting Snapshot [DONE]


Special RMODs power state should be correct
    [Arguments]    ${expect_state}=AWAKE
    log to console    check RMOD power state should be ${expect_state}
    ${ru_index_list}    Get All RU Index    connection=GNB_OAM
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${ru_index}    Convert To Integer    ${ru_index}
        ${ru_type}    Get RU type    ru_index=${ru_index}
        ${status}    Run Keyword And Return Status    should contain
        ...    ${EDSM_list}    '${ru_type}'
        ${powerState}    SG8 get RU Power State by ru index    ru_index=${ru_index}
        run keyword if   '${status}' == 'True'    Should Be Equal As Strings    ${powerState}    ${expect_state}
    END


lock or unlock all the cells and check status
    [Documentation]    zhenzhen.ren@nokia-sbell.com
    ...     para:  ${expected_value} should be 'Locked' or 'Unlocked'
    [Arguments]    ${connection}=GNB_OAM    ${expected_value}=Locked    ${flag}=True
    log to console    start to lock or unlock cells,expect value is ${expected_value}
    ${value_list}    create list
    FOR    ${cell_index}    IN    @{nr_cell_id_list}
        ${value_dic}      create dictionary
        ...    dist_name    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}
        ...    parameter    administrativeState
        ...    value    ${expected_value}
        append to list    ${value_list}    ${value_dic}
    END
    ${delta_file}=   coam_parameter.create_update_parameters_delta    parameters=${value_list}    connection=${connection}
    ...    timeout=${30}
    coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}    connection=${connection}
    sleep    30s
    run keyword if    '${flag}'=='True'    Check all the Cell lock or unlock status    adminState=${expected_value}


Check all the Cell lock or unlock status
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=50    ${adminState}=unlocked
    Log to console    Check all NR and LTE cells status
    ${nr_cells_info}   coam.get_cells_info  cell_type=nr    timeout=${timeout}    connection=${connection}
    FOR    ${cell}    IN    @{nr_cells_info}
        Should Be Equal As Strings    ${cell['status']['administrativeState'].lower()}     ${adminState.lower()}
    END
    ${lte_cells_info}   coam.get_cells_info  cell_type=lte    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{lte_cells_info}
        Should Be Equal As Strings    ${cell['status']['administrativeState'].lower()}     ${adminState.lower()}
    END


Suspended or notSuspended energysaving by coam
    [Arguments]    ${connection}=GNB_OAM    ${value}=suspended
    ${suspendvalue_dic}      create dictionary    lbpsSuspended    ${value}
    ${suspendvalue_list}    create list    ${suspendvalue_dic}
    ${value_list}    create list
    FOR    ${nrpgrp_index}    IN    @{nrpgrp}
        ${value_dic}      create dictionary
        ...    dist_name    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${nrpgrp_index}
        ...    parameter    lbpsPeriodList
        ...    value    ${suspendvalue_list}
        append to list    ${value_list}   ${value_dic}
    END
    ${delta_file}=   coam_parameter.create_update_parameters_delta    parameters=${value_list}    connection=${connection}
    coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}    connection=${connection}
    sleep    30s



Modify lbpsPeriodList to trigger cell switch off
    [Arguments]    ${lbpsDuration}=${60}
    ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
    ${Week}    ${startTime}    get_deepsleep_start_time    hour=${lbpsStartTimeHour}    minute=${lbpsStartTimeMinute}
    log to console    begin to modify lbpsDayOfWeek,lbpsStartTimeHour,etc to local time
    FOR    ${nrpgrp_index}    IN    @{nrpgrp}
        ${nrpgrp_index}    Convert To Integer    ${nrpgrp_index}
        SG8 common Change lbpsPeriodList by Coam    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${nrpgrp_index}
        ...    lbpsDayOfWeek=${Week}    lbpsStartTimeHour=${lbpsStartTimeHour}
        ...    lbpsStartTimeMinute=${lbpsStartTimeMinute}    lbpsDuration=${lbpsDuration}
    END
    sleep    5min




check all the nr cells enter energysaving or notEnergySaving
    [Arguments]    ${expect_state}=energySaving
    log to console    check cell energysaving status should be '${expect_state}'
    FOR    ${cell_index}    IN    @{nr_cell_id_list}
        ${cell_index}    Convert To Integer    ${cell_index}
        Check cell EnergySaving state via COAM    expect_energySavingState=${expect_state}    cellID=${cell_index}
    END


Lock Or Unlock NG Links
    [Documentation]    zhenzhen.ren@nokia-sbell.com
    ...     para:  ${expected_value} should be 'Locked' or 'Unlocked'
    [Arguments]    ${connection}=GNB_OAM    ${expected_value}=Locked    ${timeout}=300
    selenium login and disable screen lock
    @{SERVEDAMF_A}    coam.get_managed_objects    class_name=SERVEDAMF_A    connection=${connection}
    ${amf_numbers}    Get Length     ${SERVEDAMF_A}
    FOR    ${amf_num}   IN RANGE    1      ${amf_numbers}+1
        Run Keyword If    '${expected_value}'=='Locked'   Wait Until Keyword Succeeds    3 min    5 sec    coam.lock_ng_link
        ...      dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/SERVEDAMF-${amf_num}
        ...      timeout=${timeout}   connection=${connection}
        ...    ELSE IF    '${expected_value}'=='Unlocked'   Wait Until Keyword Succeeds    3 min    5 sec    coam.unlock_ng_link
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/SERVEDAMF-${amf_num}    timeout=${timeout}
        ...    connection=${connection}
        ${nglink_status}    selenium_coam.get_parameter_value
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/SERVEDAMF-${amf_num}
        ...    filter_param=Administrative state    abbr=administrativeState
        should be equal as strings    ${nglink_status}    ${expected_value}
        sleep    10
    END
    [Teardown]    run keyword and ignore error    selenium logout and close browser


Modify Parameters inlcuding L2&L3
    [Documentation]    zhenzhen.ren@nokia-sbell.com
    ...     para:  ${modify_list} should be a list including 'ssbFrequency' ,'actBadUplinkRadioRedirect',
    ...    'ngSetupRespTmr','actDl256Qam','dllaTargetBlerVoNR','qRxLevMin','Pmax'
    [Arguments]    ${modify_list}    ${test_time}=${0}
    FOR    ${parameter}    IN    @{modify_list}
        run keyword if    ${parameter}=='ssbFrequency'    Modify ssbFrequency    test_time=${test_time}
        run keyword if    ${parameter}=='actBadUplinkRadioRedirect'
        ...    Modify actBadUplinkRadioRedirect and ulBlerThresholdRedirectData and ulBlerThresholdRedirectVoNR
        ...    test_time=${test_time}
        run keyword if    ${parameter}=='ngSetupRespTmr'    Modify ngSetupRespTmr    test_time=${test_time}
        run keyword if    ${parameter}=='actDl256Qam'    Modify actDl256Qam    test_time=${test_time}
        run keyword if    ${parameter}=='dllaTargetBlerVoNR'    Modify dllaTargetBlerVoNR    test_time=${test_time}
        run keyword if    ${parameter}=='qRxLevMin'    Modify qRxLevMin    test_time=${test_time}
        run keyword if    ${parameter}=='Pmax'    Modify Pmax    test_time=${test_time}
        run keyword if    ${parameter}=='actDlDynSwitchAlloc'    Modify actDlDynSwitchAlloc    test_time=${test_time}
    END


Modify ssbFrequency
    [Arguments]    ${connection}=GNB_OAM    ${test_time}=${0}
    ${ssbFrequency_list}     Create List
    ${value}    Set Variable If    ${test_time}%2==0     39    30
    FOR    ${cell_index}    IN    @{nr_cell_id_list}
        ${ssbFrequency_dic}      create dictionary
        ...    dist_name    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}/NRHOIF-1
        ...    parameter    ssbFrequency
        ...    value    ${value}
        append to list    ${ssbFrequency_list}    ${ssbFrequency_dic}
    END
    ${delta_file}=   coam_parameter.create_update_parameters_delta    parameters=${ssbFrequency_list}    connection=${connection}
    coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}    connection=${connection}
    sleep    30s


Modify actBadUplinkRadioRedirect and ulBlerThresholdRedirectData and ulBlerThresholdRedirectVoNR
    [Arguments]    ${connection}=GNB_OAM    ${test_time}=${0}
    ${act_value}    Set Variable If    ${test_time}%2==0    highUlBlerBased    disabled
    ${ulBler_value}    Set Variable If    ${test_time}%2==0     39    30
    ${value_dic}      create dictionary
        ...    ulBlerThresholdRedirectData    ${ulBler_value}
        ...    ulBlerThresholdRedirectVoNR    ${ulBler_value}
    ${value_list}    Create List    ${value_dic}
    ${parameter_list}    Create List
    FOR    ${cell_index}    IN    @{nr_cell_id_list}
        ${parameter_dic}    create dictionary
        ...    dist_name    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}
        ...    parameter    actBadUplinkRadioRedirect
        ...    value    ${act_value}
        append to list    ${parameter_list}    ${parameter_dic}
        ${parameter_dic}    create dictionary
        ...    dist_name    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}
        ...    parameter    ulBler
        ...    value    ${value_list}
        append to list    ${parameter_list}    ${parameter_dic}
    END
    ${delta_file}=   coam_parameter.create_update_parameters_delta    parameters=${parameter_list}    connection=${connection}
    coam_parameter.perform_scf_delta_commission    delta_file=${delta_file['updated']}    connection=${connection}
    sleep    30s


Modify ngSetupRespTmr
    [Arguments]    ${connection}=GNB_OAM    ${test_time}=${0}
    ${value}    Set Variable If    ${test_time}%2==0     139    130
    coam.perform_parameter_recommissioning
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}    parameter=ngSetupRespTmr
    ...    value=${value}    operation=update    connection=${connection}
    sleep    10


Modify actDl256Qam
    [Arguments]    ${connection}=GNB_OAM    ${test_time}=${0}
    ${256qam_list}     Create List
    ${qam_value}    Set Variable If    ${test_time}%2==0     false    true
    FOR    ${cell_index}    IN    @{nr_cell_id_list}
        ${256qam_dic}      create dictionary
        ...    dist_name    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}
        ...    parameter    actDl256Qam
        ...    value    ${qam_value}
        append to list    ${256qam_list}    ${256qam_dic}
        ${256qam_dic}      create dictionary
        ...    dist_name    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}
        ...    parameter    actDlLaDynBlerTarget
        ...    value    ${qam_value}
        append to list    ${256qam_list}    ${256qam_dic}
    END
    ${delta_file}=   coam_parameter.create_update_parameters_delta    parameters=${256qam_list}    connection=${connection}
    coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}    connection=${connection}
    sleep    30s


Modify dllaTargetBlerVoNR
    [Arguments]    ${connection}=GNB_OAM    ${test_time}=${0}
    ${BlerVoNR_list}     Create List
    ${value}    Set Variable If    ${test_time}%2==0     3    2
    FOR    ${cell_index}    IN    @{nr_cell_id_list}
        ${BlerVoNR_dic}      create dictionary
        ...    dist_name    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}
        ...    parameter    dllaTargetBlerVoNR
        ...    value    ${value}
        append to list    ${BlerVoNR_list}    ${BlerVoNR_dic}
    END
    ${delta_file}=   coam_parameter.create_update_parameters_delta    parameters=${BlerVoNR_list}    connection=${connection}
    coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}    connection=${connection}
    sleep    30s


Modify Pmax
    [Arguments]    ${connection}=GNB_OAM    ${test_time}=${0}
    ${Pmax_list}     Create List
    ${value}    Set Variable If    ${test_time}%2==0     290    300
    FOR    ${cell_index}    IN    @{nr_cell_id_list}
        ${Pmax_dic}      create dictionary
        ...    dist_name    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}
        ...    parameter    pMax
        ...    value    ${value}
        append to list    ${Pmax_list}    ${Pmax_dic}
    END
    ${delta_file}=   coam_parameter.create_update_parameters_delta    parameters=${Pmax_list}    connection=${connection}
    coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}    connection=${connection}
    ...    timeout=${300}
    sleep    30s


Modify qRxLevMin
    [Arguments]    ${connection}=GNB_OAM    ${test_time}=${0}
    ${levmin_list}     Create List
    ${value}    Set Variable If    ${test_time}%2==0     -39    -40
    FOR    ${cell_index}    IN    @{nr_cell_id_list}
        ${levmin_dic}      create dictionary
        ...    dist_name    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}
        ...    parameter    qRxLevMin
        ...    value    ${value}
        append to list    ${levmin_list}    ${levmin_dic}
    END
    ${delta_file}=   coam_parameter.create_update_parameters_delta    parameters=${levmin_list}    connection=${connection}
    coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}    connection=${connection}
    sleep    30s


Modify actDlDynSwitchAlloc
    [Arguments]    ${connection}=GNB_OAM    ${test_time}=${0}
    ${SwitchAlloc_list}     Create List
    ${SwitchAlloc_value}    Set Variable If    ${test_time}%2==0     false    true
    FOR    ${cell_index}    IN    @{nr_cell_id_list}
        ${SwitchAlloc_dic}      create dictionary
        ...    dist_name    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}
        ...    parameter    actDlDynSwitchAlloc
        ...    value    ${SwitchAlloc_value}
        append to list    ${SwitchAlloc_list}    ${SwitchAlloc_dic}
    END
    ${delta_file}=   coam_parameter.create_update_parameters_delta    parameters=${SwitchAlloc_list}    connection=${connection}
    coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}    connection=${connection}
    sleep    30s
