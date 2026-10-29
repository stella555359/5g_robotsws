*** Settings ***
Documentation    This is for SG8 common SISO operation keywords
...              Author: zhenzhen.ren & qingqing.wang
...              Squard: HZ SG8

Library       taf.selenium.sbts    WITH NAME    selenium_coam
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.ue    WITH NAME    taf_ue
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BW_common_case/lib/BW_step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/cell_addition_deletion_online.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py


*** Variables ***
${common_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build
${download_username}    ca_5Gauto
${download_password}    AKCp5bBh9XG9iCkcCJLwt6CHuVdgHPyJVAuB7V6vSHfet7X6ZXfjZRqEMLxn36rfqRfhoQzKc


*** Keywords ***
E2E_TL_Activation_Reset_with_OAM_KPI_SG08
    [Arguments]    ${Max_loop}=${3}
    ${release}    ${download_version}    Get SW release and download version from BTS
    Set test variable    ${download_version}
    Download A54 and T1_A54 package from Artifactory    release=${release}
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    test for time ${index}
        Upgrade BTS to defined package    flag=T1_A54
        ...    defined_package_path=${TS_CASE_LOG_PATH}/${download_version}_release_BTSSM_downloadable_testpackage_T1_A54.zip
        Upgrade BTS to defined package    flag=common_A54
        ...    defined_package_path=${TS_CASE_LOG_PATH}/${download_version}_release_BTSSM_downloadable_A54.zip
    END
    [Teardown]    Run Keywords    Get SW version and check if upgrade in teardown
    ...    AND    run keyword and ignore error   COAM Teardown gnb connections
    ...    AND    Run    rm -rf ${TS_CASE_LOG_PATH}/${download_version}_release_BTSSM_downloadable_testpackage_T1_A54.zip
    ...    AND    Run    rm -rf ${TS_CASE_LOG_PATH}/${download_version}_release_BTSSM_downloadable_A54.zip


Get SW version and check if upgrade in teardown
    ${SW_version}    Get Active SW Version    connection=GNB_OAM
    Run Keyword If    "T1" in '${SW_version}'    Upgrade BTS to defined package    flag=common_A54
    ...    defined_package_path=${TS_CASE_LOG_PATH}/${download_version}_release_BTSSM_downloadable_A54.zip


Get SW release and download version from BTS
    ${sw_slice}    Split String    ${Active_SW_version}    _
    ${release}    Run Keyword If   "_9999_" in '${Active_SW_version}'    Set Variable    SBTS00
    ...    ELSE    Set Variable    ${sw_slice}[0]
    ${download_version}    Run Keyword If    "_9999_" in '${Active_SW_version}'
    ...    Replace String    ${Active_SW_version}    ${sw_slice}[0]    SBTS00
    ...    ELSE    Set Variable    ${Active_SW_version}
    [Return]    ${release}    ${download_version}


Download A54 and T1_A54 package from Artifactory
    [Arguments]    ${release}    ${PACKAGE_PATH}=${TS_CASE_LOG_PATH}
    ${package_regex}    set variable    ${download_version}_release_BTSSM_downloadable_A54.zip
    ${T1_package_regex}    set variable    ${download_version}_release_BTSSM_downloadable_testpackage_T1_A54.zip
    ${package_url}     set variable    ${common_package_link}/${release}/${download_version}/${package_regex}
    log to console    begin to download common A54 package
    ${output}    Run    wget --user ${download_username} --password ${download_password} ${package_url} -nv -P ${PACKAGE_PATH}
    Should Contain    ${output}    ${package_regex}    SW Package Download failed!
    ${T1_package_url}     set variable    ${common_package_link}/${release}/${download_version}/${T1_package_regex}
    log to console    begin to download T1 A54 package
    ${output}    Run    wget --user ${download_username} --password ${download_password} ${T1_package_url} -nv -P ${PACKAGE_PATH}
    Should Contain    ${output}    ${T1_package_regex}    T1 SW Package Download failed!


Upgrade BTS to defined package
    [Arguments]    ${defined_package_path}    ${flag}=T1_A54
    log to console    begin to upgrade BTS to ${flag}
    Connect to gnb coam via ssl
    coam.update_software    sw_package=${defined_package_path}    should_activate=${True}    timeout=7200
    ...    connection=GNB_OAM
    sleep    300s
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    5 min    30 sec    Check all cells info should be onair
    ${SW_version}    Get Active SW Version    connection=GNB_OAM
    Run Keyword If    '${flag}'=='T1_A54'    Should Contain    ${SW_version}    T1
    ...    ELSE    Should Not Contain    ${SW_version}    T1
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...    connection=GNB_OAM
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}
    csn.reset_cache
    sleep   10


Check BTS Status
    [Documentation]    Author: zhenzhen.ren@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM    ${status}=onair
    ${bts_status}    coam.get_bts_statuses    connection=${connection}
    Should Be Equal As Strings    ${bts_status['proceduralState'].lower()}    ${status}


Define BTS negative status
    ${cell_type}    ${cell_list_nr}    ${cell_list_lte}    Check cell type by cell ID
    run keyword if    '${cell_type}'=='nr_lte'    Define BTS negative status with nr_lte type
    run keyword if    '${cell_type}'=='lte_only'    Define BTS negative status with lte_only type
    run keyword if    '${cell_type}'=='nr_only'    Define BTS negative status with nr_only type


Define BTS negative status with nr_lte type
    Define BTS negative status with lte_only type
    Define BTS negative status with nr_only type


Define BTS negative status with lte_only type
    [Arguments]    ${status}=integratedtoran
    ${bts_status}    Get operational State value via COAM    class_name=LNBTS_R    pattern=operationalState
    ${bts_status}=    Convert To Lowercase    ${bts_status}
    ${bts_status}    Evaluate    '${bts_status}'.replace(' ','')
    Should Be Equal As Strings    ${bts_status}    ${status}


Define BTS negative status with nr_only type
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=10
    ${active_alarms_list}    coam.get_active_alarms    connection=${connection}    timeout=${timeout}
    ${active_alarms_num}     Get Length    ${active_alarms_list}
    ${fault_list}    Create List
    FOR  ${alarm}  IN  @{active_alarms_list}
       Exit For Loop If   ${active_alarms_num}==${0}
       append to list    ${fault_list}    ${alarm['faultId']}
    END
    log to console    ${fault_list}
    ${status}    check_special_fault    fault_list=${fault_list}    btstype=${gNb_CuType}
    ${bts_status}    Get operational State value via COAM    class_name=NRBTS_R    pattern=operationalState
    ${bts_status}=    Convert To Lowercase    ${bts_status}
    ${bts_status}    Evaluate    '${bts_status}'.replace(' ','')
    Should Be Equal As Strings    ${bts_status}    ${status}


Check SMOD status
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com
    [Arguments]  ${connection}=GNB_OAM    ${operationalState}=enabled
                 ...    ${adminState}=unlocked    ${usageState}=active    ${proStatus}=configured
    ${smod_status}    coam.get_fsm_info    connection=${connection}
    FOR    ${smod_info}    IN    @{smod_status}
        Should be equal as strings    ${smod_info['status']['operationalState'].lower()}       ${operationalState}
                                  ...  msg=Current bbmod operationalState is not in ${operationalState} status
        Should be equal as strings    ${smod_info['status']['administrativeState'].lower()}    ${adminState}
                                  ...  msg=Current bbmod administrativeState is not in ${adminState} status
        Should be equal as strings    ${smod_info['status']['usageState'].lower()}       ${usageState}
                                  ...  msg=Current bbmod usageState is not in ${usageState} status
        Should be equal as strings    ${smod_info['status']['proceduralStatus'].lower()}       ${proStatus}
                                  ...  msg=Current bbmod proceduralStatus is not in ${proStatus} status
    END


Check BBMOD status
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com
    [Arguments]  ${bbmod_index}=${1}    ${connection}=GNB_OAM    ${operationalState}=enabled
                 ...    ${adminState}=unlocked    ${usageState}=active    ${proStatus}=configured
    ${SMOD_type}    Check SMOD type
    return from keyword if    ${SMOD_type} == 'ASOE' or ${SMOD_type} == 'ASOF'    ${SMOD_type}
    &{bbmod_status}    Get bbmod info by bbmod index     bbmod_index=${bbmod_index}   connection=${connection}
    Should be equal as strings    ${bbmod_status['status']['operationalState'].lower()}       ${operationalState}
                                  ...  msg=Current bbmod operationalState is not in ${operationalState} status
    Should be equal as strings    ${bbmod_status['status']['administrativeState'].lower()}    ${adminState}
                                  ...  msg=Current bbmod administrativeState is not in ${adminState} status
    Should be equal as strings    ${bbmod_status['status']['usageState'].lower()}       ${usageState}
                                  ...  msg=Current bbmod usageState is not in ${usageState} status
    Should be equal as strings    ${bbmod_status['status']['proceduralStatus'].lower()}       ${proStatus}
                                  ...  msg=Current bbmod proceduralStatus is not in ${proStatus} status


Check RMOD status
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com
    [Arguments]  ${rmod_index}=${1}    ${connection}=GNB_OAM    ${operationalState}=enabled
                 ...    ${adminState}=unlocked    ${usageState}=active    ${proStatus}=configured
    ${ru_status}    COAM get ru detial info by ru index     ru_index=${rmod_index}   connection=${connection}
    Should be equal as strings    ${ru_status['status']['administrativeState'].lower()}    ${adminState}
                                  ...  msg=Current RU administrativeState is not in ${adminState} status
    Should be equal as strings    ${ru_status['status']['operationalState'].lower()}    ${operationalState}
                                  ...  msg=Current RU operationalState is not in ${operationalState} status
    Should be equal as strings    ${ru_status['status']['proceduralStatus'].lower()}    ${proStatus}
                                  ...  msg=Current RU proceduralStatus is not in ${proStatus} status
    Should be equal as strings    ${ru_status['status']['usageState'].lower()}    ${usageState}
                                  ...  msg=Current RU proceduralStatus is not in ${usageState} status


Check all the Cell status
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=50
                 ...    ${operationalState}=enabled    ${adminState}=unlocked    ${usageState}=active
                 ...    ${proStatus}=configured    ${blockState}=unblocked
    Log to console    Check all NR and LTE cells status
    ${nr_cells_info}   coam.get_cells_info  cell_type=nr    timeout=${timeout}    connection=${connection}
    FOR    ${cell}    IN    @{nr_cells_info}
        Should Be Equal As Strings    ${cell['status']['operationalState'].lower()}    ${operationalState}
        Should Be Equal As Strings    ${cell['status']['administrativeState'].lower()}     ${adminState}
        Should Be Equal As Strings    ${cell['status']['blockingState'].lower()}    ${blockState}
        Should Be Equal As Strings    ${cell['status']['usageState'].lower()}    ${usageState}
        Should Be Equal As Strings    ${cell['status']['proceduralStatus'].lower()}    ${proStatus}
    END
    ${lte_cells_info}   coam.get_cells_info  cell_type=lte    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{lte_cells_info}
        Should Be Equal As Strings    ${cell['status']['operationalState'].lower()}    ${operationalState}
        Should Be Equal As Strings    ${cell['status']['administrativeState'].lower()}     ${adminState}
        Should Be Equal As Strings    ${cell['status']['blockingState'].lower()}    ${blockState}
    END


Check single NR cell status
    [Arguments]   ${cell_idx}=0   ${connection}=GNB_OAM    ${timeout}=20
                 ...    ${operationalState}=enabled    ${adminState}=unlocked    ${usageState}=active
                 ...    ${proStatus}=configured    ${blockState}=unblocked
    Log to console    Check cell ${cell_idx} of ${cell_type} configuration status
    ${cells_info}   coam.get_cells_info    cell_type=nr   timeout=${timeout}    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        run keyword if  '${cell['globalCellId']}'!='${cell_idx}'    Continue For Loop
        Should Be Equal As Strings    ${cell['status']['operationalState'].lower()}    ${operationalState}
        Should Be Equal As Strings    ${cell['status']['administrativeState'].lower()}     ${adminState}
        Should Be Equal As Strings    ${cell['status']['blockingState'].lower()}    ${blockState}
        Should Be Equal As Strings    ${cell['status']['usageState'].lower()}    ${usageState}
        Should Be Equal As Strings    ${cell['status']['proceduralStatus'].lower()}    ${proStatus}
    END


Check single LTE cell status
    [Arguments]   ${cell_idx}=0   ${connection}=GNB_OAM    ${timeout}=20
                 ...    ${operationalState}=enabled    ${adminState}=unlocked
                 ...    ${blockState}=unblocked
    ${cells_info}   coam.get_cells_info    cell_type=lte   timeout=${timeout}    connection=${connection}
    log to console    Check cell ${cell_idx} of ${cell_type} configuration status
    FOR    ${cell}    IN    @{cells_info}
        run keyword if  '${cell['globalCellId']}'!='${cell_idx}'    Continue For Loop
        Should Be Equal As Strings    ${cell['status']['operationalState'].lower()}    ${operationalState}
        Should Be Equal As Strings    ${cell['status']['administrativeState'].lower()}     ${adminState}
        Should Be Equal As Strings    ${cell['status']['blockingState'].lower()}    ${blockState}
    END


Check SMOD type
    Connect to Common Unit Master    alias=ASIK Master
    ${SMOD_info}    csn.execute    ddal -s ddal_sysinfo_module_get_unit_id 0    connection=ASIK Master    timeout=30
    ${SMOD_type}    get_SMOD_type    SMOD_info=${SMOD_info}
    [Return]    ${SMOD_type}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master


General_SISO_BB_Lock_Unlock_SG08
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com;BB_Lock_Unlock and L3 call
    [Arguments]     ${tput_self_define}    ${Max_loop}=${50}    ${target_avg_percent}=${None}    ${min_percent}=${None}
    ...    ${cell_id}=${None}    ${duration}=${120}    ${ui_version}=default    ${with_call}=${True}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    ++++++++++++++++++++++++++++++++++++ Loop ${index} ++++++++++++++++++++++++++++++++++++
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 1 lock BBMOD
        log to console    ---------------------------------------------------------------------------------------
        Connect to gnb coam via ssl
        Lock BB and check status via coam
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 2 unlock BBMOD
        log to console    ---------------------------------------------------------------------------------------
        Unlock BB and check status via coam
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 3 check not exist unexpect alarm
        log to console    ---------------------------------------------------------------------------------------
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        ...    connection=GNB_OAM
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        csn.reset_cache
        sleep    10
    END
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 4 L3 call
    log to console    ---------------------------------------------------------------------------------------
    run keyword if    ${with_call}==${True}    data_transfer_common    tput_self_define=${tput_self_define}    duration=${duration}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    cell_id=${cell_id}    ui_version=${ui_version}
    [Teardown]    run keyword and ignore error   COAM Teardown gnb connections


General_SISO_BB_Lock_Unlock_With_Call_SG08
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com;BB_Lock_Unlock and L3 call
    [Arguments]     ${tput_self_define}    ${Max_loop}=${10}    ${target_avg_percent}=${None}    ${min_percent}=${None}
    ...    ${cell_id}=${None}    ${duration}=${120}    ${ui_version}=default
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    ++++++++++++++++++++++++++++++++++++ Loop ${index} ++++++++++++++++++++++++++++++++++++
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 1 lock BBMOD
        log to console    ---------------------------------------------------------------------------------------
        Connect to gnb coam via ssl
        Lock BB and check status via coam
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 2 unlock BBMOD and L3 call
        log to console    ---------------------------------------------------------------------------------------
        Unlock BB and check status via coam
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 3 check not exist unexpect alarm
        log to console    ---------------------------------------------------------------------------------------
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        ...    connection=GNB_OAM
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        csn.reset_cache
        sleep    10
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 4 L3 call
        log to console    ---------------------------------------------------------------------------------------
        data_transfer_common    tput_self_define=${tput_self_define}    duration=${duration}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    cell_id=${cell_id}    ui_version=${ui_version}
    END
    [Teardown]    run keyword and ignore error   COAM Teardown gnb connections


Lock BB and check status via coam
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com
    [Arguments]     ${connection}=GNB_OAM
    ${bbmod_index_list}    Get All BBmod Index
    FOR  ${bbmod_index}  IN  @{bbmod_index_list}
        coam.lock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${bbmod_index}
        ...    timeout=${120}    connection=${connection}
        sleep    10
        Wait Until Keyword Succeeds    5min    60s    Check BBMOD status    bbmod_index=${bbmod_index}
        ...    adminState=locked
    END
    Wait Until Keyword Succeeds    5min    60s    Define BTS negative status
    Wait Until Keyword Succeeds    5min    60s    Check SMOD status    usageState=idle
    ${ru_index_list}    Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Wait Until Keyword Succeeds    5min    60s    Check RMOD status    rmod_index=${ru_index}    usageState=idle
    END
    Wait Until Keyword Succeeds    5min    60s    Check all the Cell status
    ...    operationalState=disabled    usageState=idle


Unlock BB and check status via coam
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com
    [Arguments]     ${connection}=GNB_OAM
    ${bbmod_index_list}    Get All BBmod Index
    FOR  ${bbmod_index}  IN  @{bbmod_index_list}
        coam.unlock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${bbmod_index}
        ...    timeout=${120}    connection=${connection}
        sleep    10
        Wait Until Keyword Succeeds    5min    60s    Check BBMOD status    bbmod_index=${bbmod_index}
    END
    Wait Until Keyword Succeeds    5min    60s    Check BTS Status
    Wait Until Keyword Succeeds    5min    60s    Check SMOD status
    ${ru_index_list}    Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Wait Until Keyword Succeeds    5min    60s    Check RMOD status    rmod_index=${ru_index}
    END
    Wait Until Keyword Succeeds    5min    60s    Check all the Cell status



General_SISO_BB_Reset_SG08
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com;BB_Reset and L3 call
    [Arguments]     ${tput_self_define}    ${Max_loop}=${50}    ${target_avg_percent}=${None}    ${min_percent}=${None}
    ...    ${cell_id}=${None}    ${duration}=${120}    ${ui_version}=default    ${with_call}=${True}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    ++++++++++++++++++++++++++++++++++++ Loop ${index} ++++++++++++++++++++++++++++++++++++
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 1 reset BBMOD
        log to console    ---------------------------------------------------------------------------------------
        Connect to gnb coam via ssl
        BB reset and check status via coam
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 2 check not exist unexpect alarm
        log to console    ---------------------------------------------------------------------------------------
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        ...    connection=GNB_OAM
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        csn.reset_cache
        sleep    10
    END
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 3 L3 call
    log to console    ---------------------------------------------------------------------------------------
    run keyword if    ${with_call}==${True}    data_transfer_common    tput_self_define=${tput_self_define}    duration=${duration}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    cell_id=${cell_id}    ui_version=${ui_version}
    [Teardown]    run keyword and ignore error   COAM Teardown gnb connections


General_SISO_BB_Reset_With_Call_SG08
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com;BB_Reset and L3 call
    [Arguments]     ${tput_self_define}    ${Max_loop}=${10}    ${target_avg_percent}=${None}    ${min_percent}=${None}
    ...    ${cell_id}=${None}    ${duration}=${120}    ${ui_version}=default
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    ++++++++++++++++++++++++++++++++++++ Loop ${index} ++++++++++++++++++++++++++++++++++++
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 1 reset BBMOD and L3 call
        log to console    ---------------------------------------------------------------------------------------
        Connect to gnb coam via ssl
        BB reset and check status via coam
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 2 check not exist unexpect alarm
        log to console    ---------------------------------------------------------------------------------------
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        ...    connection=GNB_OAM
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        csn.reset_cache
        sleep    10
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 3 L3 call
        log to console    ---------------------------------------------------------------------------------------
        data_transfer_common    tput_self_define=${tput_self_define}    duration=${duration}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    cell_id=${cell_id}    ui_version=${ui_version}
    END
    [Teardown]    run keyword and ignore error   COAM Teardown gnb connections


BB reset and check status via coam
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com
    [Arguments]     ${connection}=GNB_OAM
    ${bbmod_index_list}    Get All BBmod Index
    FOR  ${bbmod_index}  IN  @{bbmod_index_list}
        coam.reset_unit    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${bbmod_index}
        ...    reset_type=Warm    force_radio_reset=${True}    timeout=${300}    connection=${connection}
        sleep    10s
        Wait Until Keyword Succeeds    5min    60s    Check BBMOD status    bbmod_index=${bbmod_index}
    END
    Wait Until Keyword Succeeds    5min    60s    Check BTS Status
    Wait Until Keyword Succeeds    5min    60s    Check SMOD status
    ${ru_index_list}    Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Wait Until Keyword Succeeds    5min    60s    Check RMOD status    rmod_index=${ru_index}
    END
    Wait Until Keyword Succeeds    5min    60s    Check all the Cell status


General_SISO_Cell_Block_Unblock_SG08
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com;Cell_Block_Unblock and L3 call
    [Arguments]     ${tput_self_define}    ${Max_loop}=${50}    ${target_avg_percent}=${None}    ${min_percent}=${None}
    ...    ${cell_id}=${None}    ${duration}=${120}    ${ui_version}=default    ${with_call}=${True}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${cell_type}    ${cell_list_nr}    ${cell_list_lte}    Check cell type by cell ID
    Set Test Variable    ${cell_type}
    Set Test Variable    ${cell_list_nr}
    Set Test Variable    ${cell_list_lte}
    ${lnbtsID}    run keyword if    '${cell_type}' != 'nr_only'    Get lnbts ID via online SCF
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    ++++++++++++++++++++++++++++++++++++ Loop ${index} ++++++++++++++++++++++++++++++++++++
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 1 Block cells
        log to console    ---------------------------------------------------------------------------------------
        Connect to gnb coam via ssl
        Block cells and check status via coam
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 2 unBlock cells
        log to console    ---------------------------------------------------------------------------------------
        Unblock cells and check status via coam
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 3 check not exist unexpect alarm
        log to console    ---------------------------------------------------------------------------------------
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        ...    connection=GNB_OAM
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        csn.reset_cache
        sleep    10
    END
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 4 L3 call
    log to console    ---------------------------------------------------------------------------------------
    run keyword if    ${with_call}==${True}    data_transfer_common    tput_self_define=${tput_self_define}    duration=${duration}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    cell_id=${cell_id}    ui_version=${ui_version}
    [Teardown]    run keyword and ignore error   COAM Teardown gnb connections


General_SISO_Cell_Block_Unblock_With_Call_SG08
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com;Cell_Block_Unblock and L3 call
    [Arguments]     ${tput_self_define}    ${Max_loop}=${10}    ${target_avg_percent}=${None}    ${min_percent}=${None}
    ...    ${cell_id}=${None}    ${duration}=${120}    ${ui_version}=default
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${cell_type}    ${cell_list_nr}    ${cell_list_lte}    Check cell type by cell ID
    Set Test Variable    ${cell_type}
    Set Test Variable    ${cell_list_nr}
    Set Test Variable    ${cell_list_lte}
    ${lnbtsID}    run keyword if    '${cell_type}' != 'nr_only'    Get lnbts ID via online SCF
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    ++++++++++++++++++++++++++++++++++++ Loop ${index} ++++++++++++++++++++++++++++++++++++
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 1 Block cells
        log to console    ---------------------------------------------------------------------------------------
        Connect to gnb coam via ssl
        Block cells and check status via coam
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 2 unBlock cells and L3 call
        log to console    ---------------------------------------------------------------------------------------
        Unblock cells and check status via coam
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 3 check not exist unexpect alarm
        log to console    ---------------------------------------------------------------------------------------
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        ...    connection=GNB_OAM
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    case_start_timestamp=${timestamp}    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        csn.reset_cache
        sleep    10
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 4 L3 call
        log to console    ---------------------------------------------------------------------------------------
        data_transfer_common    tput_self_define=${tput_self_define}    duration=${duration}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    cell_id=${cell_id}    ui_version=${ui_version}
    END
    [Teardown]    run keyword and ignore error   COAM Teardown gnb connections


Block nr cells and check cell status
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com
    [Arguments]     ${connection}=GNB_OAM
    FOR    ${cell_index}    IN    @{cell_list_nr}
        coam.block_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}    connection=${connection}
        ...    timeout=60
        sleep    10
        Wait Until Keyword Succeeds    5min    60s    Check single NR cell status    cell_idx=${cell_index}
        ...    operationalState=disabled     usageState=idle    blockState=blocked
    END


Unblock nr cells and check cell status
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com
    [Arguments]     ${connection}=GNB_OAM
    FOR    ${cell_index}    IN    @{cell_list_nr}
        coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}    connection=${connection}
        ...    timeout=60
        sleep    10
        Wait Until Keyword Succeeds    5min    60s    Check single NR cell status    cell_idx=${cell_index}
    END


Block LTE cells and check cell status
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com
    [Arguments]     ${connection}=GNB_OAM
    FOR    ${cell_index}    IN    @{cell_list_lte}
        coam.block_cell    dist_name=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/LNCEL-${cell_index}    connection=${connection}
        ...    timeout=60
        sleep    10
        Wait Until Keyword Succeeds    5min    60s    Check single LTE cell status    cell_idx=${cell_index}
        ...    operationalState=disabled     blockState=blocked
    END


Get lnbts ID via online SCF
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    ${mrbtsID}    ${lnbtsID}    Get mrbtsID and lnbtsID via SCF    scf_path=${scf_path}
    Set test variable    ${lnbtsID}
    [Return]    ${lnbtsID}


Unblock LTE cells and check cell status
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com
    [Arguments]     ${connection}=GNB_OAM
    FOR    ${cell_index}    IN    @{cell_list_lte}
        coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/LNCEL-${cell_index}    connection=${connection}
        ...    timeout=60
        sleep    10
        Wait Until Keyword Succeeds    5min    60s    Check single LTE cell status    cell_idx=${cell_index}
    END


Check cell type by cell ID
    ${cell_list_nr}    Get All Cell Id    cell_type=nr
    ${cell_list_lte}    Get All Cell Id    cell_type=lte
    ${cell_type}    check_cell_type    nrlist=${cell_list_nr}    ltelist=${cell_list_lte}
    [Return]  ${cell_type}    ${cell_list_nr}    ${cell_list_lte}


Block cells and check status via coam
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com
    run keyword if    '${cell_type}' != 'lte_only'    Block nr cells and check cell status
    run keyword if    '${cell_type}' != 'nr_only'    Block LTE cells and check cell status
    Wait Until Keyword Succeeds    5min    60s    Define BTS negative status
    Wait Until Keyword Succeeds    5min    60s    Check SMOD status    usageState=idle
    ${bbmod_index_list}    Get All BBmod Index
    FOR  ${bbmod_index}  IN  @{bbmod_index_list}
        Wait Until Keyword Succeeds    5min    60s    Check BBMOD status    bbmod_index=${bbmod_index}
    END
    ${ru_index_list}    Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Wait Until Keyword Succeeds    5min    60s    Check RMOD status    rmod_index=${ru_index}
        ...    usageState=idle
    END


Unblock cells and check status via coam
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com
    run keyword if    '${cell_type}' != 'lte_only'    Unblock nr cells and check cell status
    run keyword if    '${cell_type}' != 'nr_only'    Unblock LTE cells and check cell status
    Wait Until Keyword Succeeds    5min    60s    Check BTS Status
    Wait Until Keyword Succeeds    5min    60s    Check SMOD status
    ${bbmod_index_list}    Get All BBmod Index
    FOR  ${bbmod_index}  IN  @{bbmod_index_list}
        Wait Until Keyword Succeeds    5min    60s    Check BBMOD status    bbmod_index=${bbmod_index}
    END
    ${ru_index_list}    Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Wait Until Keyword Succeeds    5min    60s    Check RMOD status    rmod_index=${ru_index}
    END


Lock nr cells and check cell status
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com
    [Arguments]     ${connection}=GNB_OAM
    FOR    ${cell_index}    IN    @{cell_list_nr}
        coam.lock    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}
        ...    timeout=${120}    connection=${connection}
        sleep    10
        Wait Until Keyword Succeeds    5min    60s    Check single NR cell status    cell_idx=${cell_index}
        ...    operationalState=disabled     usageState=idle    adminState=locked    proStatus=initialization required
    END


Unlock nr cells and check cell status
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com
    [Arguments]     ${connection}=GNB_OAM
    FOR    ${cell_index}    IN    @{cell_list_nr}
        coam.unlock    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}
        ...    timeout=${120}    connection=${connection}
        sleep    10
        Wait Until Keyword Succeeds    5min    60s    Check single NR cell status    cell_idx=${cell_index}
    END


Lock LTE cells and check cell status
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com
    [Arguments]     ${connection}=GNB_OAM
    FOR    ${cell_index}    IN    @{cell_list_lte}
        coam.lock    dist_name=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/LNCEL-${cell_index}    connection=${connection}
        ...    timeout=${120}
        sleep    10
        Wait Until Keyword Succeeds    5min    60s    Check single LTE cell status    cell_idx=${cell_index}
        ...    operationalState=disabled     adminState=locked
    END


Unlock LTE cells and check cell status
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com
    [Arguments]     ${connection}=GNB_OAM
    FOR    ${cell_index}    IN    @{cell_list_lte}
        coam.unlock    dist_name=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/LNCEL-${cell_index}    connection=${connection}
        ...    timeout=${120}
        sleep    10
        Wait Until Keyword Succeeds    5min    60s    Check single LTE cell status    cell_idx=${cell_index}
    END


General_SISO_Cell_Lock_Unlock_SG08
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com;Cell_Lock_Unlock and L3 call
    [Arguments]     ${tput_self_define}    ${Max_loop}=${50}    ${target_avg_percent}=${None}    ${min_percent}=${None}
    ...    ${cell_id}=${None}    ${duration}=${120}    ${ui_version}=default    ${with_call}=${True}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${cell_type}    ${cell_list_nr}    ${cell_list_lte}    Check cell type by cell ID
    Set Test Variable    ${cell_type}
    Set Test Variable    ${cell_list_nr}
    Set Test Variable    ${cell_list_lte}
    ${lnbtsID}    run keyword if    '${cell_type}' != 'nr_only'    Get lnbts ID via online SCF
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    ++++++++++++++++++++++++++++++++++++ Loop ${index} ++++++++++++++++++++++++++++++++++++
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 1 lock cells
        log to console    ---------------------------------------------------------------------------------------
        Connect to gnb coam via ssl
        Lock cells and check status via coam
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 2 unlock cells
        log to console    ---------------------------------------------------------------------------------------
        Unlock cells and check status via coam
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 3 check not exist unexpect alarm
        log to console    ---------------------------------------------------------------------------------------
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        ...    connection=GNB_OAM
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        csn.reset_cache
        sleep    10
    END
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 4 L3 call
    log to console    ---------------------------------------------------------------------------------------
    run keyword if    ${with_call}==${True}    data_transfer_common    tput_self_define=${tput_self_define}    duration=${duration}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    cell_id=${cell_id}    ui_version=${ui_version}
    [Teardown]    run keyword and ignore error   COAM Teardown gnb connections


General_SISO_Cell_Lock_Unlock_With_Call_SG08
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com;Cell_Lock_Unlock and L3 call
    [Arguments]     ${tput_self_define}    ${Max_loop}=${10}    ${target_avg_percent}=${None}    ${min_percent}=${None}
    ...    ${cell_id}=${None}    ${duration}=${120}    ${ui_version}=default
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${cell_type}    ${cell_list_nr}    ${cell_list_lte}    Check cell type by cell ID
    Set Test Variable    ${cell_type}
    Set Test Variable    ${cell_list_nr}
    Set Test Variable    ${cell_list_lte}
    ${lnbtsID}    run keyword if    '${cell_type}' != 'nr_only'    Get lnbts ID via online SCF
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    ++++++++++++++++++++++++++++++++++++ Loop ${index} ++++++++++++++++++++++++++++++++++++
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 1 lock cells
        log to console    ---------------------------------------------------------------------------------------
        Connect to gnb coam via ssl
        Lock cells and check status via coam
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 2 unlock cells and L3 call
        log to console    ---------------------------------------------------------------------------------------
        Unlock cells and check status via coam
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 3 check not exist unexpect alarm
        log to console    ---------------------------------------------------------------------------------------
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        ...    connection=GNB_OAM
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        csn.reset_cache
        sleep    10
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 4 L3 call
        log to console    ---------------------------------------------------------------------------------------
        data_transfer_common    tput_self_define=${tput_self_define}    duration=${duration}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    cell_id=${cell_id}    ui_version=${ui_version}
    END
    [Teardown]    run keyword and ignore error   COAM Teardown gnb connections


General_SISO_NR_Cell_Online_delete_add_SG08
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com,Cell_Online_delete_add and L3 call,only support NR cell;the
    ...    default online_delete_add cell list is [1],please define cell list if needed,make sure delete cell won't cause
    ...    pdl errors
    [Arguments]     ${tput_self_define}    ${Max_loop}=${50}    ${target_avg_percent}=${None}    ${min_percent}=${None}
    ...    ${addition_deletion_list}=${None}    ${cell_id}=${None}    ${duration}=${120}    ${ui_version}=default
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${cell_list_nr}    Get All Cell Id    cell_type=nr
    ${cell_len}    get length    ${cell_list_nr}
    return from keyword if    '${cell_len}' == '1'    ${cell_list_nr}
    ${addition_deletion_list}    get_add_delete_list    define_list=${addition_deletion_list}
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 1 the addition_deletion_list is ${addition_deletion_list}
    log to console    ---------------------------------------------------------------------------------------
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    ++++++++++++++++++++++++++++++++++++ Loop ${index} ++++++++++++++++++++++++++++++++++++
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 2 Online Cell addition deletion with define cell list
        log to console    ---------------------------------------------------------------------------------------
        Connect to gnb coam via ssl
        Online Cell addition deletion with define cell list    addition_deletion_list=${addition_deletion_list}
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 3 check not exist unexpect alarm
        log to console    ---------------------------------------------------------------------------------------
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        ...    connection=GNB_OAM
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        csn.reset_cache
        sleep    10
    END
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 4 L3 call
    log to console    ---------------------------------------------------------------------------------------
    data_transfer_common    tput_self_define=${tput_self_define}    duration=${duration}    cell_id=${cell_id}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    ui_version=${ui_version}
    [Teardown]    run keyword and ignore error   COAM Teardown gnb connections


General_SISO_NR_Cell_Online_delete_add_With_Call_SG08
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com,Cell_Online_delete_add and L3 call,only support NR cell;the
    ...    default online_delete_add cell list is [1],please define cell list if needed,make sure delete cell won't cause
    ...    pdl errors
    [Arguments]     ${tput_self_define}    ${Max_loop}=${10}    ${target_avg_percent}=${None}    ${min_percent}=${None}
    ...    ${addition_deletion_list}=${None}    ${cell_id}=${None}    ${duration}=${120}    ${ui_version}=default
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${cell_list_nr}    Get All Cell Id    cell_type=nr
    ${cell_len}    get length    ${cell_list_nr}
    return from keyword if    '${cell_len}' == '1'    ${cell_list_nr}
    ${addition_deletion_list}    get_add_delete_list    define_list=${addition_deletion_list}
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 1 the addition_deletion_list is ${addition_deletion_list}
    log to console    ---------------------------------------------------------------------------------------
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    ++++++++++++++++++++++++++++++++++++ Loop ${index} ++++++++++++++++++++++++++++++++++++
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 2 Online Cell addition deletion with define cell list
        log to console    ---------------------------------------------------------------------------------------
        Connect to gnb coam via ssl
        Online Cell addition deletion with define cell list    addition_deletion_list=${addition_deletion_list}
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 3 check not exist unexpect alarm
        log to console    ---------------------------------------------------------------------------------------
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        ...    connection=GNB_OAM
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        csn.reset_cache
        sleep    10
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 4 L3 call
        log to console    ---------------------------------------------------------------------------------------
        data_transfer_common    tput_self_define=${tput_self_define}    duration=${duration}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    cell_id=${cell_id}    ui_version=${ui_version}
    END
    [Teardown]    run keyword and ignore error   COAM Teardown gnb connections


Online Cell addition deletion with define cell list
    [Arguments]    ${addition_deletion_list}
    FOR  ${cell_index}  IN  @{addition_deletion_list}
        Online Cell addition deletion    addition_deletion_cell=${cell_index}
        sleep    10s
    END
    All SMODs BBMODs RMODs and Cells should be onair


Lock cells and check status via coam
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com
    run keyword if    '${cell_type}' != 'lte_only'    Lock nr cells and check cell status
    run keyword if    '${cell_type}' != 'nr_only'    Lock lte cells and check cell status
    Wait Until Keyword Succeeds    5min    60s    Define BTS negative status
    Wait Until Keyword Succeeds    5min    60s    Check SMOD status    usageState=idle
    ${bbmod_index_list}    Get All BBmod Index
    FOR  ${bbmod_index}  IN  @{bbmod_index_list}
        Wait Until Keyword Succeeds    5min    60s    Check BBMOD status    bbmod_index=${bbmod_index}
    END
    ${ru_index_list}    Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Wait Until Keyword Succeeds    5min    60s    Check RMOD status    rmod_index=${ru_index}
        ...    usageState=idle
    END


Unlock cells and check status via coam
    [Documentation]   Author:zhenzhen.ren@nokia-sbell.com
    run keyword if    '${cell_type}' != 'lte_only'    Unlock nr cells and check cell status
    run keyword if    '${cell_type}' != 'nr_only'    Unlock lte cells and check cell status
    Wait Until Keyword Succeeds    5min    60s    Check BTS Status
    Wait Until Keyword Succeeds    5min    60s    Check SMOD status
    ${bbmod_index_list}    Get All BBmod Index
    FOR  ${bbmod_index}  IN  @{bbmod_index_list}
        Wait Until Keyword Succeeds    5min    60s    Check BBMOD status    bbmod_index=${bbmod_index}
    END
    ${ru_index_list}    Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Wait Until Keyword Succeeds    5min    60s    Check RMOD status    rmod_index=${ru_index}
    END


All SMODs BBMODs RMODs and Cells should be onair
    Wait Until Keyword Succeeds    10min    60s    Check SMOD status
    ${bbmod_index_list}    Get All BBmod Index
    FOR  ${bbmod_index}  IN  @{bbmod_index_list}
        Wait Until Keyword Succeeds    10min    60s    Check BBMOD status    bbmod_index=${bbmod_index}
    END
    ${ru_index_list}    Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Wait Until Keyword Succeeds    10min    60s    Check RMOD status    rmod_index=${ru_index}
    END
    Wait Until Keyword Succeeds    10min    60s    check bts status by coam SG8
    Wait Until Keyword Succeeds    5min    60s    Check all the Cell status

General_SISO_Site_Reset_SG08
    [Documentation]   site reset and L3 call
    [Arguments]     ${tput_self_define}    ${target_avg_percent}=${None}    ${min_percent}=${None}    ${cell_id}=${None}
    ...    ${duration}=${120}    ${Max_loop}=${50}    ${ui_version}=default    ${with_call}=${True}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    ++++++++++++++++++++++++++++++++++++ Loop ${index} ++++++++++++++++++++++++++++++++++++
        Connect to gnb coam via ssl
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 1 Reset site
        log to console    ---------------------------------------------------------------------------------------
        coam.reset_site   connection=GNB_OAM
        sleep    30
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 2 All SMODs BBMODs RMODs and Cells onair
        log to console    ---------------------------------------------------------------------------------------
        All SMODs BBMODs RMODs and Cells should be onair
        Sleep    30
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 3 check not exist unexpect alarm
        log to console    ---------------------------------------------------------------------------------------
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        csn.reset_cache
    END
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 4 L3 call
    log to console    ---------------------------------------------------------------------------------------
    run keyword if    ${with_call}==${True}    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    loop_times=${1}    duration=${duration}
    ...    ui_version=${ui_version}
    [Teardown]    run keyword and ignore error   COAM Teardown gnb connections

General_SISO_Site_Reset_With_Call_SG08
    [Documentation]   site reset and L3 call
    [Arguments]     ${tput_self_define}    ${target_avg_percent}=${None}    ${min_percent}=${None}    ${cell_id}=${None}
    ...    ${duration}=${120}    ${Max_loop}=${10}    ${ui_version}=default
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    ++++++++++++++++++++++++++++++++++++ Loop ${index} ++++++++++++++++++++++++++++++++++++
        Connect to gnb coam via ssl
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 1 Reset site
        log to console    ---------------------------------------------------------------------------------------
        coam.reset_site   connection=GNB_OAM
        sleep    30
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 2 All SMODs BBMODs RMODs and Cells onair
        log to console    ---------------------------------------------------------------------------------------
        All SMODs BBMODs RMODs and Cells should be onair
        Sleep    30
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 3 check not exist unexpect alarm
        log to console    ---------------------------------------------------------------------------------------
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 4 L3 call
        log to console    ---------------------------------------------------------------------------------------
        data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id}    target_avg_percent=${target_avg_percent}
        ...    min_percent=${min_percent}    loop_times=${1}    duration=${duration}    ui_version=${ui_version}
        csn.reset_cache
    END
    [Teardown]    run keyword and ignore error   COAM Teardown gnb connections

Reset all RMOD via coam
    ${ru_index_list}    Get All RU Index    connection=GNB_OAM
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${ru_index}    Convert To Integer    ${ru_index}
        coam.reset_unit    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    force_radio_reset=${True}
        ...    timeout=${600}    connection=GNB_OAM
        sleep    5s
    END

General_SISO_RU_Reset_SG08
    [Documentation]   ru reset and L3 call
    [Arguments]     ${tput_self_define}    ${Max_loop}=${50}    ${target_avg_percent}=${None}    ${min_percent}=${None}    ${cell_id}=${None}
    ...    ${duration}=${120}    ${ui_version}=default    ${with_call}=${True}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    ++++++++++++++++++++++++++++++++++++ Loop ${index} ++++++++++++++++++++++++++++++++++++
        Connect to gnb coam via ssl
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 1 Reset all RUs
        log to console    ---------------------------------------------------------------------------------------
        Reset all RMOD via coam
        sleep    10
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 2 All SMODs BBMODs RMODs and Cells onair
        log to console    ---------------------------------------------------------------------------------------
        All SMODs BBMODs RMODs and Cells should be onair
        Sleep    30
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 3 check not exist unexpect alarm
        log to console    ---------------------------------------------------------------------------------------
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        csn.reset_cache
    END
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 4 L3 call
    log to console    ---------------------------------------------------------------------------------------
    run keyword if    ${with_call}==${True}     data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    loop_times=${1}    duration=${duration}
    ...    ui_version=${ui_version}
   [Teardown]    run keyword and ignore error   COAM Teardown gnb connections

General_SISO_RU_Reset_With_Call_SG08
    [Documentation]   ru reset and L3 call
    [Arguments]     ${tput_self_define}    ${Max_loop}=${10}    ${target_avg_percent}=${None}    ${min_percent}=${None}    ${cell_id}=${None}
    ...    ${duration}=${120}    ${ui_version}=default
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    ++++++++++++++++++++++++++++++++++++ Loop ${index} ++++++++++++++++++++++++++++++++++++
        Connect to gnb coam via ssl
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 1 Reset all RUs
        log to console    ---------------------------------------------------------------------------------------
        Reset all RMOD via coam
        sleep    10
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 2 All SMODs BBMODs RMODs and Cells onair
        log to console    ---------------------------------------------------------------------------------------
        All SMODs BBMODs RMODs and Cells should be onair
        Sleep    30
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 3 check not exist unexpect alarm
        log to console    ---------------------------------------------------------------------------------------
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 4 L3 call
        log to console    ---------------------------------------------------------------------------------------
        data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id}    target_avg_percent=${target_avg_percent}
        ...    min_percent=${min_percent}    loop_times=${1}    duration=${duration}    ui_version=${ui_version}
        csn.reset_cache
    END
    [Teardown]    run keyword and ignore error   COAM Teardown gnb connections

Reset rat SG08
    [Arguments]     ${connection}=GNB_OAM
    ${cell_type}    ${cell_list_nr}    ${cell_list_lte}    Check cell type by cell ID
    Run Keyword If    '${cell_type}' == 'lte_only' or '${cell_type}' == 'nr_lte'
    ...    coam.rat_reset       rat_type=LTE     timeout=300    connection=${connection}
    Run Keyword If    '${cell_type}' == 'nr_only' or '${cell_type}' == 'nr_lte'
    ...    coam.rat_reset       rat_type=NR     timeout=300    connection=${connection}

General_SISO_RAT_Reset_SG08
    [Documentation]   rat reset and L3 call
    [Arguments]     ${tput_self_define}    ${Max_loop}=${50}    ${target_avg_percent}=${None}    ${min_percent}=${None}    ${cell_id}=${None}
    ...    ${duration}=${120}    ${ui_version}=default    ${with_call}=${True}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    ++++++++++++++++++++++++++++++++++++ Loop ${index} ++++++++++++++++++++++++++++++++++++
        Connect to gnb coam via ssl
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 1 Reset all rats
        log to console    ---------------------------------------------------------------------------------------
        Reset rat SG08
        sleep    10
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 2 All SMODs BBMODs RMODs and Cells onair
        log to console    ---------------------------------------------------------------------------------------
        All SMODs BBMODs RMODs and Cells should be onair
        Sleep    30
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 3 check not exist unexpect alarm
        log to console    ---------------------------------------------------------------------------------------
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        csn.reset_cache
    END
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 4 L3 call
    log to console    ---------------------------------------------------------------------------------------
    run keyword if    ${with_call}==${True}    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    loop_times=${1}    duration=${duration}
    ...    ui_version=${ui_version}
   [Teardown]    run keyword and ignore error   COAM Teardown gnb connections

General_SISO_RAT_Reset_With_Call_SG08
    [Documentation]   rat reset and L3 call
    [Arguments]     ${tput_self_define}    ${Max_loop}=${10}    ${target_avg_percent}=${None}    ${min_percent}=${None}    ${cell_id}=${None}
    ...    ${duration}=${120}    ${ui_version}=default
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    ++++++++++++++++++++++++++++++++++++ Loop ${index} ++++++++++++++++++++++++++++++++++++
        Connect to gnb coam via ssl
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 1 Reset all rats
        log to console    ---------------------------------------------------------------------------------------
        Reset rat SG08
        sleep    10
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 2 All SMODs BBMODs RMODs and Cells onair
        log to console    ---------------------------------------------------------------------------------------
        All SMODs BBMODs RMODs and Cells should be onair
        Sleep    30
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 3 check not exist unexpect alarm
        log to console    ---------------------------------------------------------------------------------------
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 4 L3 call
        log to console    ---------------------------------------------------------------------------------------
        data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id}    target_avg_percent=${target_avg_percent}
        ...    min_percent=${min_percent}    loop_times=${1}    duration=${duration}    ui_version=${ui_version}
        csn.reset_cache
    END
    [Teardown]    run keyword and ignore error   COAM Teardown gnb connections

Get operational State value via COAM
    [Arguments]     ${class_name}    ${pattern}    ${connection}=GNB_OAM
    ${MO_A}    coam.get_managed_objects    class_name=${class_name}    connection=${connection}
    ${distname}    Set variable    ${MO_A[0]['distName']}
    ${dict_pattern}     coam.get_parameters    dist_name=${distname}    pattern=${pattern}    connection=${connection}
    ${pattern_value}    set variable     ${dict_pattern['${pattern}']}
    [Return]    ${pattern_value}

check bts status LTE
    [Arguments]    ${status}=onair
    ${bts_status}    Get operational State value via COAM    class_name=LNBTS_R    pattern=operationalState
    ${bts_status}=    Convert To Lowercase    ${bts_status}
    Should Be Equal As Strings    ${bts_status}    ${status}

check bts status NR
    [Arguments]    ${status}=onair
    ${bts_status}    Get operational State value via COAM    class_name=NRBTS_R    pattern=operationalState
    ${bts_status}=    Convert To Lowercase    ${bts_status}
    Should Be Equal As Strings    ${bts_status}    ${status}

check bts status by coam SG8
    [Arguments]    ${lte_status}=onair    ${nr_status}=onair
    ${cell_type}    ${cell_list_nr}    ${cell_list_lte}    Check cell type by cell ID
    Run Keyword If    '${cell_type}' == 'lte_only' or '${cell_type}' == 'nr_lte'
    ...    check bts status LTE    status=${lte_status}
    Run Keyword If    '${cell_type}' == 'nr_only' or '${cell_type}' == 'nr_lte'
    ...    check bts status NR    status=${nr_status}

Check status after lock all RMODs
    Wait Until Keyword Succeeds    10min    60s    Check SMOD status    usageState=idle
    ${bbmod_index_list}    Get All BBmod Index
    FOR  ${bbmod_index}  IN  @{bbmod_index_list}
        Wait Until Keyword Succeeds    10min    60s    Check BBMOD status    bbmod_index=${bbmod_index}
    END
    ${ru_index_list}    Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Wait Until Keyword Succeeds    10min    60s    Check RMOD status    rmod_index=${ru_index}    adminState=locked    usageState=idle
    END
    Wait Until Keyword Succeeds    10min    60s    check bts status by coam SG8    lte_status=integrated to ran    nr_status=configured
    Wait Until Keyword Succeeds    5min    60s    Check all the Cell status    operationalState=disabled    usageState=idle

Lock all RMODs SG08
    ${ru_index_list}    Get All RU Index    connection=GNB_OAM
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${ru_index}    Convert To Integer    ${ru_index}
        coam.lock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    timeout=${300}    connection=GNB_OAM
        sleep    5s
        wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${ru_index}
    END

Unlock all RMODs SG08
    ${ru_index_list}    Get All RU Index    connection=GNB_OAM
    ${status}    run keyword and return status  Expect Fault Should Present    faultId=4687
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${ru_index}    Convert To Integer    ${ru_index}
        coam.unlock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    timeout=${300}    connection=GNB_OAM
        Run Keyword If  ${status}==${True}    wait until keyword succeeds    10min    20sec    RU Should Be Offline    ru_index=${ru_index}
        wait until keyword succeeds    10min    20sec    RU Should Be Online    ru_index=${ru_index}
        sleep    5s
    END

General_SISO_RU_Lock_Unlock_loop_SG08
    [Documentation]   lock unlock RU and L3 call
    [Arguments]     ${tput_self_define}    ${Max_loop}=${50}    ${target_avg_percent}=${None}    ${min_percent}=${None}    ${cell_id}=${None}
    ...    ${duration}=${120}    ${ui_version}=default    ${with_call}=${True}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    ++++++++++++++++++++++++++++++++++++ Loop ${index} ++++++++++++++++++++++++++++++++++++
        Connect to gnb coam via ssl
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 1 Lock all RMODs
        log to console    ---------------------------------------------------------------------------------------
        Lock all RMODs SG08
        sleep    10
        Check status after lock all RMODs
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        sleep    30
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 2 unLock all RMODs
        log to console    ---------------------------------------------------------------------------------------
        Unlock all RMODs SG08
        sleep    10
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 3 All SMODs BBMODs RMODs and Cells onair
        log to console    ---------------------------------------------------------------------------------------
        All SMODs BBMODs RMODs and Cells should be onair
        Sleep    30
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 4 check not exist unexpect alarm
        log to console    ---------------------------------------------------------------------------------------
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        csn.reset_cache
    END
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 5 L3 call
    log to console    ---------------------------------------------------------------------------------------
    run keyword if    ${with_call}==${True}    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    loop_times=${1}    duration=${duration}
    ...    ui_version=${ui_version}
   [Teardown]    run keyword and ignore error   COAM Teardown gnb connections


General_SISO_RU_Lock_Unlock_loop_With_Call_SG08
    [Documentation]   lock unlock RU and L3 call
    [Arguments]     ${tput_self_define}    ${Max_loop}=${10}    ${target_avg_percent}=${None}    ${min_percent}=${None}    ${cell_id}=${None}
    ...    ${duration}=${120}    ${ui_version}=default
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    ++++++++++++++++++++++++++++++++++++ Loop ${index} ++++++++++++++++++++++++++++++++++++
        Connect to gnb coam via ssl
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 1 Lock all RMODs
        log to console    ---------------------------------------------------------------------------------------
        Lock all RMODs SG08
        sleep    10
        Check status after lock all RMODs
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 2 unLock all RMODs
        log to console    ---------------------------------------------------------------------------------------
        Unlock all RMODs SG08
        sleep    10
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 3 All SMODs BBMODs RMODs and Cells onair
        log to console    ---------------------------------------------------------------------------------------
        All SMODs BBMODs RMODs and Cells should be onair
        Sleep    30
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 4 check not exist unexpect alarm
        log to console    ---------------------------------------------------------------------------------------
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 5 L3 call
        log to console    ---------------------------------------------------------------------------------------
        data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id}    target_avg_percent=${target_avg_percent}
        ...    min_percent=${min_percent}    loop_times=${1}    duration=${duration}    ui_version=${ui_version}
        csn.reset_cache
    END
    [Teardown]    run keyword and ignore error   COAM Teardown gnb connections

Block rat SG08
    [Arguments]     ${connection}=GNB_OAM
    ${cell_type}    ${cell_list_nr}    ${cell_list_lte}    Check cell type by cell ID
    Run Keyword If    '${cell_type}' == 'lte_only' or '${cell_type}' == 'nr_lte'
    ...    coam.block_rat    rat=LTE     timeout=300    connection=${connection}
    Run Keyword If    '${cell_type}' == 'nr_only' or '${cell_type}' == 'nr_lte'
    ...    coam.block_rat    rat=NR     timeout=300    connection=${connection}

UnBlock rat SG08
    [Arguments]     ${connection}=GNB_OAM
    ${cell_type}    ${cell_list_nr}    ${cell_list_lte}    Check cell type by cell ID
    Run Keyword If    '${cell_type}' == 'lte_only' or '${cell_type}' == 'nr_lte'
    ...    coam.unblock_rat    rat=LTE     timeout=300    connection=${connection}
    Run Keyword If    '${cell_type}' == 'nr_only' or '${cell_type}' == 'nr_lte'
    ...    coam.unblock_rat    rat=NR     timeout=300    connection=${connection}

Check status after block all rats
    Wait Until Keyword Succeeds    10min    60s    Check SMOD status    usageState=idle
    ${bbmod_index_list}    Get All BBmod Index
    FOR  ${bbmod_index}  IN  @{bbmod_index_list}
        Wait Until Keyword Succeeds    10min    60s    Check BBMOD status    bbmod_index=${bbmod_index}
    END
    ${ru_index_list}    Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Wait Until Keyword Succeeds    10min    60s    Check RMOD status    rmod_index=${ru_index}    adminState=unlocked    usageState=idle
    END
    Wait Until Keyword Succeeds    10min    60s    check bts status by coam SG8    lte_status=integrated to ran    nr_status=configured
    Wait Until Keyword Succeeds    5min    60s    Check all the Cell status    operationalState=disabled    usageState=idle    blockState=blocked

General_SISO_RAT_Block_Unblock_SG08
    [Documentation]   block unblock all rats and L3 call
    [Arguments]     ${tput_self_define}    ${Max_loop}=${50}    ${target_avg_percent}=${None}    ${min_percent}=${None}    ${cell_id}=${None}
    ...    ${duration}=${120}    ${ui_version}=default    ${with_call}=${True}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    ++++++++++++++++++++++++++++++++++++ Loop ${index} ++++++++++++++++++++++++++++++++++++
        Connect to gnb coam via ssl
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 1 Block all rats
        log to console    ---------------------------------------------------------------------------------------
        Block rat SG08
        sleep    10
        Check status after block all rats
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        sleep    30
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 2 unBlock all rats
        log to console    ---------------------------------------------------------------------------------------
        UnBlock rat SG08
        sleep    10
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 3 All SMODs BBMODs RMODs and Cells onair
        log to console    ---------------------------------------------------------------------------------------
        All SMODs BBMODs RMODs and Cells should be onair
        Sleep    30
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 4 check not exist unexpect alarm
        log to console    ---------------------------------------------------------------------------------------
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        csn.reset_cache
    END
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 5 L3 call
    log to console    ---------------------------------------------------------------------------------------
    run keyword if    ${with_call}==${True}    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    loop_times=${1}    duration=${duration}
    ...    ui_version=${ui_version}
   [Teardown]    run keyword and ignore error   COAM Teardown gnb connections

General_SISO_RAT_Block_Unblock_With_Call_SG08
    [Documentation]   block unblock all rats and L3 call
    [Arguments]     ${tput_self_define}    ${Max_loop}=${50}    ${target_avg_percent}=${None}    ${min_percent}=${None}    ${cell_id}=${None}
    ...    ${duration}=${120}    ${ui_version}=default
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    ++++++++++++++++++++++++++++++++++++ Loop ${index} ++++++++++++++++++++++++++++++++++++
        Connect to gnb coam via ssl
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 1 Block all rats
        log to console    ---------------------------------------------------------------------------------------
        Block rat SG08
        sleep    10
        Check status after block all rats
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        sleep    30
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 2 unBlock all rats
        log to console    ---------------------------------------------------------------------------------------
        UnBlock rat SG08
        sleep    10
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 3 All SMODs BBMODs RMODs and Cells onair
        log to console    ---------------------------------------------------------------------------------------
        All SMODs BBMODs RMODs and Cells should be onair
        Sleep    30
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 4 check not exist unexpect alarm
        log to console    ---------------------------------------------------------------------------------------
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 5 L3 call
        log to console    ---------------------------------------------------------------------------------------
        data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id}    target_avg_percent=${target_avg_percent}
        ...    min_percent=${min_percent}    loop_times=${1}    duration=${duration}    ui_version=${ui_version}
        csn.reset_cache
    END
    [Teardown]    run keyword and ignore error   COAM Teardown gnb connections

Power off all RMODs SG08
    ${ru_index_list}    Get All RU Index    connection=GNB_OAM
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${ru_index}    Convert To Integer    ${ru_index}
        Perform RU Power Off    ru_index=${ru_index}
        Wait Until Keyword Succeeds    10min    1min    RU Should Be Power Off    ru_index=${ru_index}
    END

Power on all RMODs SG08
    ${ru_index_list}    Get All RU Index    connection=GNB_OAM
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${ru_index}    Convert To Integer    ${ru_index}
        Perform RU Power On    ru_index=${ru_index}
        Wait Until Keyword Succeeds    10min    1min    RU Should Be Online    ru_index=${ru_index}
    END

General_SISO_RU_Power_Reset_SG08
    [Documentation]   power off or on all RUs and L3 call
    [Arguments]     ${tput_self_define}    ${Max_loop}=${50}    ${target_avg_percent}=${None}    ${min_percent}=${None}    ${cell_id}=${None}
    ...    ${duration}=${120}    ${ui_version}=default    ${with_call}=${True}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    ++++++++++++++++++++++++++++++++++++ Loop ${index} ++++++++++++++++++++++++++++++++++++
        Connect to gnb coam via ssl
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 1 Power off all RMODs
        log to console    ---------------------------------------------------------------------------------------
        Power off all RMODs SG08
        sleep    60
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 2 Power on all RMODs
        log to console    ---------------------------------------------------------------------------------------
        Power on all RMODs SG08
        sleep    10
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 3 All SMODs BBMODs RMODs and Cells onair
        log to console    ---------------------------------------------------------------------------------------
        All SMODs BBMODs RMODs and Cells should be onair
        Sleep    30
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 4 check not exist unexpect alarm
        log to console    ---------------------------------------------------------------------------------------
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        csn.reset_cache
    END
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 5 L3 call
    log to console    ---------------------------------------------------------------------------------------
    run keyword if    ${with_call}==${True}    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    loop_times=${1}    duration=${duration}
    ...    ui_version=${ui_version}
   [Teardown]    run keyword and ignore error   COAM Teardown gnb connections

General_SISO_RU_Power_Reset_With_Call_SG08
    [Documentation]   power off or on all RUs and L3 call
    [Arguments]     ${tput_self_define}    ${Max_loop}=${50}    ${target_avg_percent}=${None}    ${min_percent}=${None}    ${cell_id}=${None}
    ...    ${duration}=${120}    ${ui_version}=default
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    FOR    ${index}    IN RANGE    ${Max_loop}
        log to console    ++++++++++++++++++++++++++++++++++++ Loop ${index} ++++++++++++++++++++++++++++++++++++
        Connect to gnb coam via ssl
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 1 Power off all RMODs
        log to console    ---------------------------------------------------------------------------------------
        Power off all RMODs SG08
        sleep    60
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 2 Power on all RMODs
        log to console    ---------------------------------------------------------------------------------------
        Power on all RMODs SG08
        sleep    10
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 3 All SMODs BBMODs RMODs and Cells onair
        log to console    ---------------------------------------------------------------------------------------
        All SMODs BBMODs RMODs and Cells should be onair
        Sleep    30
	    log to console    ---------------------------------------------------------------------------------------
        log to console    Step 4 check not exist unexpect alarm
        log to console    ---------------------------------------------------------------------------------------
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist With Event Time
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    case_start_timestamp=${timestamp}    connection=GNB_OAM
        should be true    ${history_alarm_status}
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 5 L3 call
        log to console    ---------------------------------------------------------------------------------------
        data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id}    target_avg_percent=${target_avg_percent}
        ...    min_percent=${min_percent}    loop_times=${1}    duration=${duration}    ui_version=${ui_version}
        csn.reset_cache
    END
    [Teardown]    run keyword and ignore error   COAM Teardown gnb connections

General_DATA_transfer_SG08_Config
    [Arguments]    ${mrbtsId}    ${nrbtsId}    ${lnBtsId}=${None}    ${tput_define_nr}=${None}    ${tput_define_lte}=${None}
    ...    ${qRxLevMin_call_nr}=${-65}    ${qRxLevMin_other_nr}=${-22}    ${qRxLevMin_call_lte}=${-130}    ${qRxLevMin_other_lte}=${-44}
    ...    ${target_avg_percent_nr}=${None}    ${min_percent_nr}=${None}    ${target_avg_percent_lte}=${None}    ${min_percent_lte}=${None}
    ...    ${protocol}=udp    ${duration}=${300}    ${tput_from}=tool    ${loop_times}=${2}
    ...    ${process_num_ul}=1    ${ui_version}=default    ${scf_name}=${None}    ${omit_time_lte}=10
    ...    ${connection}=GNB_OAM    ${pa_call_default}=${None}
    ${ru_cells_mapping_with_call}    Get Ru and Cells Mapping With Call    tput_define_nr=${tput_define_nr}    tput_define_lte=${tput_define_lte}
    @{ru_ids}    Get Dictionary Keys    ${ru_cells_mapping_with_call}
    FOR    ${id}    IN    @{ru_ids}
        ${cells_call}    Get Random Cell For Call From RU    ru_cells_mapping_with_call=${ru_cells_mapping_with_call}    ru_index=${id}
        Make Call For Cells Random Selected From RU    cells_call=${cells_call}      mrbtsId=${mrbtsId}     nrbtsId=${nrbtsId}
        ...   lnBtsId=${lnBtsId}    nr_cell_all=${nr_cell_all}    lte_cell_all=${lte_cell_all}    tput_define_nr=${tput_define_nr}
        ...   tput_define_lte=${tput_define_lte}    qRxLevMin_call_nr=${qRxLevMin_call_nr}    qRxLevMin_other_nr=${qRxLevMin_other_nr}
        ...   qRxLevMin_call_lte=${qRxLevMin_call_lte}    qRxLevMin_other_lte=${qRxLevMin_other_lte}
        ...   target_avg_percent_nr=${target_avg_percent_nr}    min_percent_nr=${min_percent_nr}    target_avg_percent_lte=${target_avg_percent_lte}
        ...   min_percent_lte=${min_percent_lte}    protocol=${protocol}    duration=${duration}
        ...   tput_from=${tput_from}    loop_times=${loop_times}     process_num_ul=${process_num_ul}    ui_version=${ui_version}
        ...   scf_name=${scf_name}   omit_time_lte=${omit_time_lte}    connection=${connection}    pa_call_default=${pa_call_default}
    END

General_RAT_RESET_SG08_Config
    [Arguments]    ${mrbtsId}    ${nrbtsId}    ${lnBtsId}=${None}    ${tput_define_nr}=${None}    ${tput_define_lte}=${None}
    ...    ${qRxLevMin_call_nr}=${-65}    ${qRxLevMin_other_nr}=${-22}    ${qRxLevMin_call_lte}=${-130}    ${qRxLevMin_other_lte}=${-44}
    ...    ${target_avg_percent_nr}=${None}    ${min_percent_nr}=${None}    ${target_avg_percent_lte}=${None}    ${min_percent_lte}=${None}
    ...    ${protocol}=udp    ${duration}=${600}    ${tput_from}=tool    ${loop_times}=${2}
    ...    ${process_num_ul}=1    ${ui_version}=default    ${scf_name}=${None}    ${omit_time_lte}=10
    ...    ${connection}=GNB_OAM    ${pa_call_default}=${None}
    ${ru_cells_mapping_with_call}    Get Ru and Cells Mapping With Call    tput_define_nr=${tput_define_nr}    tput_define_lte=${tput_define_lte}
    @{ru_ids}    Get Dictionary Keys    ${ru_cells_mapping_with_call}
    ${nr_cells_num}    get length    ${nr_cell_all}
    ${lte_cells_num}    get length    ${lte_cell_all}
    run keyword if    ${nr_cells_num}!=0    Run keywords    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock    AND
    ...    NR RAT Reset    connection=${connection}    AND
    ...    run keyword and ignore error    Selenium Logout And Close Browser    AND
    ...    All SMODs BBMODs RMODs and Cells should be onair    AND
    ...    General_DATA_transfer_SG08_Config    mrbtsId=${mrbtsId}     nrbtsId=${nrbtsId}    lnBtsId=${lnBtsId}    tput_define_nr=${tput_define_nr}
    ...    tput_define_lte=${tput_define_lte}    qRxLevMin_call_nr=${qRxLevMin_call_nr}    qRxLevMin_other_nr=${qRxLevMin_other_nr}
    ...    qRxLevMin_call_lte=${qRxLevMin_call_lte}    qRxLevMin_other_lte=${qRxLevMin_other_lte}
    ...    target_avg_percent_nr=${target_avg_percent_nr}    min_percent_nr=${min_percent_nr}    target_avg_percent_lte=${target_avg_percent_lte}
    ...    min_percent_lte=${min_percent_lte}    protocol=${protocol}    duration=${duration}
    ...    tput_from=${tput_from}    loop_times=${loop_times}     process_num_ul=${process_num_ul}    ui_version=${ui_version}
    ...    scf_name=${scf_name}   omit_time_lte=${omit_time_lte}    connection=${connection}    pa_call_default=${pa_call_default}
    run keyword if    ${lte_cells_num}!=0    Run keywords    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock    AND
    ...    LTE RAT Reset    connection=${connection}    AND
    ...    run keyword and ignore error    Selenium Logout And Close Browser    AND
    ...    All SMODs BBMODs RMODs and Cells should be onair    AND
    ...    General_DATA_transfer_SG08_Config    mrbtsId=${mrbtsId}     nrbtsId=${nrbtsId}    lnBtsId=${lnBtsId}    tput_define_nr=${tput_define_nr}
    ...    tput_define_lte=${tput_define_lte}    qRxLevMin_call_nr=${qRxLevMin_call_nr}    qRxLevMin_other_nr=${qRxLevMin_other_nr}
    ...    qRxLevMin_call_lte=${qRxLevMin_call_lte}    qRxLevMin_other_lte=${qRxLevMin_other_lte}
    ...    target_avg_percent_nr=${target_avg_percent_nr}    min_percent_nr=${min_percent_nr}    target_avg_percent_lte=${target_avg_percent_lte}
    ...    min_percent_lte=${min_percent_lte}    protocol=${protocol}    duration=${duration}
    ...    tput_from=${tput_from}    loop_times=${loop_times}     process_num_ul=${process_num_ul}    ui_version=${ui_version}
    ...    scf_name=${scf_name}   omit_time_lte=${omit_time_lte}    connection=${connection}    pa_call_default=${pa_call_default}

General_SISO_RU_Lock_Unlock_SG08_Config
    [Arguments]    ${mrbtsId}    ${nrbtsId}    ${lnBtsId}=${None}
    ...    ${tput_define_nr}=${None}    ${tput_define_lte}=${None}    ${qRxLevMin_call_nr}=${-65}    ${qRxLevMin_other_nr}=${-22}
    ...    ${qRxLevMin_call_lte}=${-130}    ${qRxLevMin_other_lte}=${-44}    ${target_avg_percent_nr}=${None}    ${min_percent_nr}=${None}
    ...    ${target_avg_percent_lte}=${None}    ${min_percent_lte}=${None}
    ...    ${protocol}=udp    ${duration}=${600}    ${tput_from}=tool    ${loop_times}=${2}
    ...    ${process_num_ul}=1    ${ui_version}=default    ${scf_name}=${None}    ${omit_time_lte}=10
    ...    ${connection}=GNB_OAM    ${pa_call_default}=${None}    ${check_on_air}=${False}
    ${ru_cells_mapping_with_call}    Get Ru and Cells Mapping With Call    tput_define_nr=${tput_define_nr}    tput_define_lte=${tput_define_lte}
    @{cell_all}    Evaluate    @{nr_cell_all}+@{lte_cell_all}
    log to console    check number of ru that should be make call
    @{ru_ids}    Get Dictionary Keys    ${ru_cells_mapping_with_call}
    ${ru_num}    get length    ${ru_ids}
    log to console    ru number: ${ru_num}
    #    if ru number is more than 1, lock a ru, random select a cell under another ru to make call;
    #    then, unlock this ru, random select a cell under this ru to  make call
    #    if run number is 1, lock and unlock a ru, random select a cell under this ru to make call
    run keyword if    ${ru_num} > 1    lock ru and make call under another ru    mrbtsId=${mrbtsId}    nrbtsId=${nrbtsId}    lnBtsId=${lnBtsId}
    ...    tput_define_nr=${tput_define_nr}    tput_define_lte=${tput_define_lte}    qRxLevMin_call_nr=${qRxLevMin_call_nr}
    ...    qRxLevMin_other_nr=${qRxLevMin_other_nr}    qRxLevMin_call_lte=${qRxLevMin_call_lte}    qRxLevMin_other_lte=${qRxLevMin_other_lte}
    ...    target_avg_percent_nr=${target_avg_percent_nr}      min_percent_nr=${min_percent_nr}    check_on_air=${check_on_air}
    ...    target_avg_percent_lte=${target_avg_percent_lte}    min_percent_lte=${min_percent_lte}    protocol=${protocol}    duration=${duration}
    ...    tput_from=${tput_from}    loop_times=${loop_times}    process_num_ul=${process_num_ul}    ui_version=${ui_version}
    ...    scf_name=${scf_name}    omit_time_lte=${omit_time_lte}    connection=${connection}    pa_call_default=${pa_call_default}
    ...    ELSE    lock unlock ru and make call under this ru    mrbtsId=${mrbtsId}    nrbtsId=${nrbtsId}    lnBtsId=${lnBtsId}
    ...    tput_define_nr=${tput_define_nr}    tput_define_lte=${tput_define_lte}    qRxLevMin_call_nr=${qRxLevMin_call_nr}
    ...    qRxLevMin_other_nr=${qRxLevMin_other_nr}    qRxLevMin_call_lte=${qRxLevMin_call_lte}    qRxLevMin_other_lte=${qRxLevMin_other_lte}
    ...    target_avg_percent_nr=${target_avg_percent_nr}      min_percent_nr=${min_percent_nr}    check_on_air=${True}
    ...    target_avg_percent_lte=${target_avg_percent_lte}    min_percent_lte=${min_percent_lte}    protocol=${protocol}    duration=${duration}
    ...    tput_from=${tput_from}    loop_times=${loop_times}    process_num_ul=${process_num_ul}    ui_version=${ui_version}
    ...    scf_name=${scf_name}    omit_time_lte=${omit_time_lte}    connection=${connection}    pa_call_default=${pa_call_default}
    [Teardown]    Run keywords    Run keyword and ignore error    Unlock RUs By Coam    mrbtsID=${mrbtsID}    ru_list=${ru_ids}    AND
    ...    Wait until keyword succeeds    1min    30s    verify all cells should be onair

General_SISO_Cell_Block_Unblock_SG08_Config
    [Arguments]    ${mrbtsId}    ${nrbtsId}    ${lnBtsId}=${None}    ${tput_define_nr}=${None}    ${tput_define_lte}=${None}
    ...    ${qRxLevMin_call_nr}=${-65}    ${qRxLevMin_other_nr}=${-22}    ${qRxLevMin_call_lte}=${-130}    ${qRxLevMin_other_lte}=${-44}
    ...    ${target_avg_percent_nr}=${None}    ${min_percent_nr}=${None}    ${target_avg_percent_lte}=${None}    ${min_percent_lte}=${None}
    ...    ${protocol}=udp    ${duration}=${600}    ${tput_from}=tool    ${loop_times}=${2}    ${process_num_ul}=1    ${ui_version}=default
    ...    ${scf_name}=${None}    ${omit_time_lte}=10    ${connection}=GNB_OAM    ${pa_call_default}=${None}    ${check_on_air}=${False}
    AlarmWatchdog.add_allow_alarms    fault_id=49
    ${tput_define_nr}    run keyword if    ${tput_define_nr}!=${None}    get_self_define_tput_by_release    tput_info=${tput_define_nr}
    ...    ELSE    set variable    ${tput_define_nr}
    ${tput_define_lte}    run keyword if    ${tput_define_lte}!=${None}    get_self_define_tput_by_release    tput_info=${tput_define_lte}
    ...    ELSE    set variable    ${tput_define_lte}
    ${target_avg_percent_nr}    Run Keyword If    ${target_avg_percent_nr}==${None}    get_avg_expect_rate    ELSE
    ...    set variable    ${target_avg_percent_nr}
    ${min_percent_nr}    Run keyword If    ${min_percent_nr}==${None}    get_min_expect_rate    ELSE
    ...    set variable    ${min_percent_nr}
    ${target_avg_percent_lte}    Run Keyword If    ${target_avg_percent_lte}==${None}    get_avg_expect_rate    ELSE
    ...    set variable    ${target_avg_percent_lte}
    ${min_percent_lte}    Run keyword If    ${min_percent_lte}==${None}    get_min_expect_rate    ELSE
    ...    set variable    ${min_percent_lte}
    ${ru_cells_mapping_with_call}    Get Ru and Cells Mapping With Call    tput_define_nr=${tput_define_nr}    tput_define_lte=${tput_define_lte}
    ${numbers}    ${cell_lists}    get_all_cells_id_with_call    ru_cells_mapping_with_call=${ru_cells_mapping_with_call}
    ${cell_info}    set variable   ${cell_lists}[0]
    ${cell_type}    set variable    ${cell_info.split("_")[0]}
    ${cell_id}    set variable    ${cell_info.split("_")[1]}
    run keyword if    ${numbers} >1    cell_block_unblock_with_two_random_cells    cell_lists=${cell_lists}    mrbtsId=${mrbtsId}
    ...    nrbtsId=${nrbtsId}    lnBtsId=${lnBtsId}    tput_define_nr=${tput_define_nr}    tput_define_lte=${tput_define_lte}
    ...    qRxLevMin_call_nr=${qRxLevMin_call_nr}    qRxLevMin_call_lte=${qRxLevMin_call_lte}    qRxLevMin_other_lte=${qRxLevMin_other_lte}
    ...    target_avg_percent_nr=${target_avg_percent_nr}    min_percent_nr=${min_percent_nr}    target_avg_percent_lte=${target_avg_percent_lte}
    ...    min_percent_lte=${min_percent_lte}    protocol=${protocol}    duration=${duration}    tput_from=${tput_from}
    ...    loop_times=${loop_times}    process_num_ul=${process_num_ul}    ui_version=${ui_version}    scf_name=${scf_name}
    ...    omit_time_lte=${omit_time_lte}    connection=${connection}    pa_call_default=${pa_call_default}    check_on_air=${check_on_air}
    ...    ELSE IF    ${numbers}==1 and '${cell_type}'=='nr'    run keywords    Set qRxLevMin For Nr Call    mrbtsId=${mrbtsId}    nrbtsId=${nrbtsId}
    ...    nr_cell_all=${nr_cell_all}    cell_id_call=${cell_id}    qRxLevMin_call=${qRxLevMin_call_nr}    qRxLevMin_other=${qRxLevMin_other_nr}
    ...    connection=${connection}    check_on_air=${check_on_air}    AND    cell_block_unblock_nr    tput_self_define=${tput_define_nr}
    ...    mrbtsId=${mrbtsId}    nrbtsId=${nrbtsId}    cell_id=${cell_id}    target_avg_percent=${target_avg_percent_nr}
    ...    min_percent=${min_percent_nr}    protocol=${protocol}    duration=${duration}    tput_from=${tput_from}    loop_times=${loop_times}
    ...    process_num_ul=${process_num_ul}    ui_version=${ui_version}    scf_name=${scf_name}    connection=${connection}
    ...    pa_call_default=${pa_call_default}
    ...    ELSE IF    ${numbers}==1 and '${cell_type}'=='lte'    run keywords    Set qRxLevMin For Lte Call    mrbtsId=${mrbtsId}
    ...    lnBtsId=${lnBtsId}    lte_cell_all=${lte_cell_all}    cell_id_call=${cell_id}    qRxLevMin_call=${qRxLevMin_call_lte}
	...    qRxLevMin_other=${qRxLevMin_other_lte}    connection=${connection}    check_on_air=${check_on_air}    AND    cell_block_unblock_lte
    ...    tput_self_define=${tput_define_lte}    mrbtsId=${mrbtsId}    lnBtsId=${lnBtsId}    cell_id=${cell_id}
    ...    target_avg_percent=${target_avg_percent_lte}    min_percent=${min_percent_lte}    duration=${duration}    omit_time=${omit_time_lte}
    ...    pa_call_default=${pa_call_default}    scf_name=${scf_name}
    [Teardown]    Run keywords    Run keyword and ignore error    Unblock NR Cells By Coam    mrbtsID=${mrbtsID}    nrbtsID=${nrbtsID}
    ...    cell_list=${nr_cell_all}    AND     Run keyword and ignore error    Unblock LTE Cells By Coam    mrbtsID=${mrbtsID}    lnBtsId=${lnBtsId}
    ...    cell_list=${lte_cell_all}    AND     Wait until keyword succeeds    1min    30s    verify all cells should be onair    AND
    ...    Run keyword and ignore error    AlarmWatchdog.remove_allow_alarms    fault_id=49

General_SISO_BB_Lock_Unlock_SG08_Config
    [Arguments]    ${mrbtsId}    ${nrbtsId}    ${lnBtsId}=${None}    ${tput_define_nr}=${None}    ${tput_define_lte}=${None}
    ...    ${qRxLevMin_call_nr}=${-65}    ${qRxLevMin_other_nr}=${-22}    ${qRxLevMin_call_lte}=${-130}    ${qRxLevMin_other_lte}=${-44}
    ...    ${target_avg_percent_nr}=${None}    ${min_percent_nr}=${None}    ${target_avg_percent_lte}=${None}    ${min_percent_lte}=${None}
    ...    ${protocol}=udp    ${duration}=${600}    ${tput_from}=tool    ${loop_times}=${2}
    ...    ${process_num_ul}=1    ${ui_version}=default    ${scf_name}=${None}    ${omit_time_lte}=10
    ...    ${connection}=GNB_OAM    ${pa_call_default}=${None}
    ${ru_cells_mapping_with_call}    Get Ru and Cells Mapping With Call    tput_define_nr=${tput_define_nr}    tput_define_lte=${tput_define_lte}
    @{ru_ids}    Get Dictionary Keys    ${ru_cells_mapping_with_call}
    Lock BB and check status via coam
    Unlock BB and check status via coam
    General_DATA_transfer_SG08_Config    mrbtsId=${mrbtsId}     nrbtsId=${nrbtsId}    lnBtsId=${lnBtsId}    tput_define_nr=${tput_define_nr}
    ...   tput_define_lte=${tput_define_lte}    qRxLevMin_call_nr=${qRxLevMin_call_nr}    qRxLevMin_other_nr=${qRxLevMin_other_nr}
    ...   qRxLevMin_call_lte=${qRxLevMin_call_lte}    qRxLevMin_other_lte=${qRxLevMin_other_lte}
    ...   target_avg_percent_nr=${target_avg_percent_nr}    min_percent_nr=${min_percent_nr}    target_avg_percent_lte=${target_avg_percent_lte}
    ...   min_percent_lte=${min_percent_lte}    protocol=${protocol}    duration=${duration}
    ...   tput_from=${tput_from}    loop_times=${loop_times}     process_num_ul=${process_num_ul}    ui_version=${ui_version}
    ...   scf_name=${scf_name}   omit_time_lte=${omit_time_lte}    connection=${connection}    pa_call_default=${pa_call_default}
    [Teardown]    Run keyword and ignore error    Unlock BB and check status via coam

General_SISO_RF_Module_Power_Reset_SG08_Config
    [Arguments]    ${mrbtsId}    ${nrbtsId}    ${lnBtsId}=${None}    ${tput_define_nr}=${None}    ${tput_define_lte}=${None}
    ...    ${qRxLevMin_call_nr}=${-65}    ${qRxLevMin_other_nr}=${-22}    ${qRxLevMin_call_lte}=${-130}    ${qRxLevMin_other_lte}=${-44}
    ...    ${target_avg_percent_nr}=${None}    ${min_percent_nr}=${None}    ${target_avg_percent_lte}=${None}    ${min_percent_lte}=${None}
    ...    ${protocol}=udp    ${duration}=${600}    ${tput_from}=tool    ${loop_times}=${2}
    ...    ${process_num_ul}=1    ${ui_version}=default    ${scf_name}=${None}    ${omit_time_lte}=10
    ...    ${connection}=GNB_OAM    ${pa_call_default}=${None}
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Reset    ru_index=${ru_index}
        Wait Until Keyword Succeeds    8min    15s    RU Should Be Offline    ru_index=${ru_index}
    END
    Wait Until Keyword Succeeds    10min    30s    verify all cells should be onair
    General_DATA_transfer_SG08_Config    mrbtsId=${mrbtsId}     nrbtsId=${nrbtsId}    lnBtsId=${lnBtsId}    tput_define_nr=${tput_define_nr}
    ...   tput_define_lte=${tput_define_lte}    qRxLevMin_call_nr=${qRxLevMin_call_nr}    qRxLevMin_other_nr=${qRxLevMin_other_nr}
    ...   qRxLevMin_call_lte=${qRxLevMin_call_lte}    qRxLevMin_other_lte=${qRxLevMin_other_lte}
    ...   target_avg_percent_nr=${target_avg_percent_nr}    min_percent_nr=${min_percent_nr}    target_avg_percent_lte=${target_avg_percent_lte}
    ...   min_percent_lte=${min_percent_lte}    protocol=${protocol}    duration=${duration}
    ...   tput_from=${tput_from}    loop_times=${loop_times}     process_num_ul=${process_num_ul}    ui_version=${ui_version}
    ...   scf_name=${scf_name}   omit_time_lte=${omit_time_lte}    connection=${connection}    pa_call_default=${pa_call_default}
