*** Settings ***
Documentation    Author: Ming Shi
...              Contact: ming.shi@nokia-sbell.com

Library    taf.sbts.oam.coam.admin   WITH NAME    coam
Library    taf.transport.ssh    WITH NAME    csn
Library    BuiltIn
Library    String
Library    OperatingSystem
Library    DateTime
Library    Collections
Library    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_Regression/SISO_Resource/SiSo_common_keywords.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_Regression/SISO_Resource/ping_pang_common_keywords.robot


*** Keywords ***
Test start for siso cases
    ${allowed_faults_ids_string}=    get_allowed_faults_ids_string    value_allowed_faults_ids_list=${allowed_faults_ids}
    robot_common_operations.Common Case Setup    allowed_faults_ids=${allowed_faults_ids_string}
    FOR    ${fault_id}    IN    @{allowed_faults_ids}
        AlarmWatchdog.add_allow_alarms    fault_id=${fault_id}
    END
    ${name}=    Evaluate    '${TEST NAME}'
    Set Test Variable    ${name}

Connect with BTS
    [Documentation]    Connect to the BTS.
    [Arguments]
    ...   ${bts_port}=443    ${connection}=GNB_OAM    ${gnb_index}=0
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    ${use_ssl}=${True}    ${update_interval}=5000    ${admin_api_log_dir}=''
    ...    ${bundle_path}=${None}    ${release}=${None}    ${timeout}=30    ${trim_logs}=${False}    ${user_node_path}=${None}
    coam.connect_to    bts_host=${bts_host}    bts_port=${bts_port}    username=${username}    password=${password}
    ...    use_ssl=${use_ssl}    update_interval=${update_interval}    admin_api_log_dir=${admin_api_log_dir}
    ...    name=${connection}    bundle_path=${bundle_path}    release=${release}    timeout=${timeout}
    ...    trim_logs=${trim_logs}    user_node_path=${user_node_path}

Disconnect with BTS
    [Documentation]    Disconnect from the BTS.
    [Arguments]    ${connection}=GNB_OAM
    coam.teardown    connection=${connection}

Block BTS
    [Documentation]    Block the BTS.
    ...    dist_name (string) – (optional) DEPRECATED. This keyword blocks only the BTS now.
    ...    If you want to block a component, please use dedicated keyword - block_cell, block_all_cells, block_rat, block_gsmtrx.
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=60    ${detailed_output}=${False}
    ${Block_feedback}=    coam.block    connection=${connection}    timeout=${timeout}    detailed_output=${detailed_output}
    [Return]    ${Block_feedback}

Unblock BTS
    [Documentation]    Unblock the BTS.
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=60    ${detailed_output}=${False}    ${wait_for_reconnection}=${True}
    ${Unblock_feedback}=    coam.unblock    connection=${connection}    timeout=${timeout}    detailed_output=${detailed_output}
    ...    wait_for_reconnection=${wait_for_reconnection}
    [Return]    ${Unblock_feedback}

Block all cells with BTS
    [Documentation]    Block all cells with the BTS.
    ...    rat (string) – RAT technology cells to block. <NR, LTE, WCDMA, GSM, TETRA>
    [Arguments]    ${rat}=NR    ${connection}=GNB_OAM    ${timeout}=60    ${detailed_output}=${False}
    ${Block_cells_feedback}=    coam.block_all_cells    rat=${rat}    connection=${connection}    timeout=${timeout}
    ...    detailed_output=${detailed_output}
    [Return]    ${Block_cells_feedback}

Unblock all cells with BTS
    [Documentation]    Unblock all cells with the BTS.
    [Arguments]    ${rat}=NR    ${connection}=GNB_OAM    ${timeout}=60    ${detailed_output}=${False}
    ${Unblock_cells_feedback}=    coam.unblock_all_cells    rat=${rat}    connection=${connection}    timeout=${timeout}
    ...    detailed_output=${detailed_output}
    [Return]    ${Unblock_cells_feedback}

Block cell with BTS
    [Documentation]    Block cell with the BTS.
    [Arguments]    ${dist_name}    ${connection}=GNB_OAM    ${timeout}=600    ${detailed_output}=${False}
    ${Block_cell_feedback}=    coam.block_cell    dist_name=${dist_name}    connection=${connection}    timeout=${timeout}
    ...    detailed_output=${detailed_output}
    [Return]    ${Block_cell_feedback}

Unblock cell with BTS
    [Documentation]    Unblock cell with the BTS.
    [Arguments]    ${dist_name}    ${connection}=GNB_OAM    ${timeout}=600    ${detailed_output}=${False}
    ${Unblock_cell_feedback}=    coam.unblock_cell    dist_name=${dist_name}    connection=${connection}    timeout=${timeout}
    ...    detailed_output=${detailed_output}
    [Return]    ${Unblock_cell_feedback}

Block RAT with BTS
    [Documentation]    Block RAT with the BTS.
    ...    rat (string) – RAT to block. [“NR”|”LTE”|”WCDMA”|”GSM”]
    [Arguments]    ${rat}=NR    ${connection}=GNB_OAM    ${timeout}=60
    ${Block_rat_feedback}=    coam.block_rat    rat=${rat}    connection=${connection}    timeout=${timeout}
    [Return]    ${Block_rat_feedback}

Unblock RAT with BTS
    [Documentation]    Unblock RAT with the BTS.
    [Arguments]    ${rat}=NR    ${connection}=GNB_OAM    ${timeout}=60
    ${Unblock_rat_feedback}=    coam.unblock_rat    rat=${rat}    connection=${connection}    timeout=${timeout}
    [Return]    ${Unblock_rat_feedback}

Lock required dist_name with BTS
    [Documentation]    Lock required dist_name with the BTS.
    ...    dist_name (Union[str, list]) – dist_name of <BBMOD|RMOD|ASIRMOD|TTRX_ST|LANE|NRDU|NRCELL|NRCELLGRP|LNCEL distName>
    ...    From SBTS22R4 it could be list of items. Should be None when technology is specified
    ...    technology (str) – one of <LTE, TETRA, NR, ALL> - should be None when dist_name is specified.
    ...    lock_RU, lock_baseband, lock_bts, lock_cell, Deprecated. Use lock instead.
    [Arguments]    ${dist_name}    ${connection}=GNB_OAM    ${timeout}=600    ${technology}=${None}    ${detailed_output}=${False}
    ${Lock_response}=    coam.lock    dist_name=${dist_name}    connection=${connection}    timeout=${timeout}
    ...    technology=${technology}    detailed_output=${detailed_output}
    [Return]    ${Lock_response}

Unlock required dist_name with BTS
    [Documentation]    Unlock required dist_name with the BTS.
    [Arguments]    ${dist_name}    ${connection}=GNB_OAM    ${timeout}=600    ${technology}=${None}    ${detailed_output}=${False}
    ${Unlock_response}=    coam.unlock    dist_name=${dist_name}    connection=${connection}    timeout=${timeout}
    ...    technology=${technology}    detailed_output=${detailed_output}
    [Return]    ${Unlock_response}

Lock NG link with BTS
    [Documentation]    Lock NG link with the BTS.
    [Arguments]    ${dist_name}    ${connection}=GNB_OAM    ${timeout}=600
    ${Lock_feedback}=    coam.lock_ng_link    dist_name=${dist_name}    connection=${connection}    timeout=${timeout}
    [Return]    ${Lock_feedback}

Unlock NG link with BTS
    [Documentation]    Unlock NG link with the BTS.
    [Arguments]    ${dist_name}    ${connection}=GNB_OAM    ${timeout}=600
    ${Unlock_feedback}=    coam.unlock_ng_link    dist_name=${dist_name}    connection=${connection}    timeout=${timeout}
    [Return]    ${Unlock_feedback}

Commission scf with BTS
    [Documentation]    Commission scf with the BTS.
    [Arguments]    ${scf_file}    ${bts_id}=${None}    ${connection}=GNB_OAM    ${timeout}=600    ${skip_parameter_relation_errors}=${False}
    ...    ${should_activate}=${True}
    ${commissioning_status}=    coam.perform_commissioning    bts_id=${bts_id}    scf_file=${scf_file}
    ...    connection=${connection}    timeout=${timeout}    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}
    [Return]    ${commissioning_status}

Power reset with BTS
    [Documentation]    Power reset with the BTS.
    ...    Power reset procedure introduced in CB007040 feature
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=1200    ${reset_with_snapshot}=${None}    ${wait_for_reconnection}=${None}
    ...    ${detailed_output}=${False}    ${cold_reset_secondary_core_via_backplane}=${None}
    ...    ${graceful_cell_shutdown}=${None}
    ${Power_reset_feedback}=    coam.power_reset    connection=${connection}    timeout=${timeout}
    ...    reset_with_snapshot=${reset_with_snapshot}    wait_for_reconnection=${wait_for_reconnection}
    ...    detailed_output=${detailed_output}    cold_reset_secondary_core_via_backplane=${cold_reset_secondary_core_via_backplane}
    ...    graceful_cell_shutdown=${graceful_cell_shutdown}
    [Return]    ${Power_reset_feedback}

RAT reset with BTS
    [Documentation]    RAT reset with the BTS.
    ...    rat_type (str) – RAT name - 5G, LTE, WCDMA or GSM
    ...    reset_type (str) – [“Soft”|”Hard”] <optional, default value is Soft>. Available from NF-CB008880
    ...    Return list:
    ...    RAT reset status For example:
    ...    [{‘id’: ‘/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-1’},
    ...    {‘confirmationNode’: {‘distName’: ‘/MRBTS-1/RAT-1/URI-1/SESSION-1/RESET_IND-1/ACK-1’,
    ...    ‘parameters’: {}}, ‘indicationDistName’: ‘/MRBTS-1/RAT-1/URI-1/SESSION-1/RESET_IND-1’,
    ...    ‘ resultNode’: {‘distName’: ‘/MRBTS-1/RAT-1/URI-1/SESSION-1/RESET_IND-1/RESULT-1’, ‘parameters’: {‘status’: ‘Succeeded’}}}]
    [Arguments]    ${rat_type}=NR    ${connection}=GNB_OAM    ${timeout}=600    ${graceful_cell_shutdown}=${None}
    ...    ${reset_type}=Soft
    ${RAT_reset_status}=    coam.rat_reset    rat_type=${rat_type}    connection=${connection}    timeout=${timeout}
    ...    graceful_cell_shutdown=${graceful_cell_shutdown}    reset_type=${reset_type}
    [Return]    ${RAT_reset_status}

Reset with BTS
    [Documentation]    Reset with the BTS.
    ...    reset_coverage (str) – Site|Bts. Note: since CNI-88723, the “Bts” option was removed.
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=600    ${reset_coverage}=Site    ${wait_for_reconnection}=${True}
    ...    ${detailed_output}=${False}
    ${reset_status}=    coam.reset    connection=${connection}    timeout=${timeout}    reset_coverage=${reset_coverage}
    ...    wait_for_reconnection=${wait_for_reconnection}    detailed_output=${detailed_output}
    [Return]    ${reset_status}

Reset all cells with BTS
    [Documentation]    Reset all cells with the BTS.
    ...    technology (str) – NR, LTE, WCDMA or GSM
    [Arguments]    ${technology}=NR    ${connection}=GNB_OAM    ${timeout}=60    ${detailed_output}=${False}
    ${Reset_cells_feedback}=    coam.reset_all_cells    technology=${technology}    connection=${connection}    timeout=${timeout}
    ...    detailed_output=${detailed_output}
    [Return]    ${Reset_cells_feedback}

Reset cell with BTS
    [Documentation]    Reset cell with the BTS.
    ...    cell_id (str) – NRCEL|LNCEL|WNCEL|GNCEL distName
    [Arguments]    ${cell_id}    ${connection}=GNB_OAM    ${timeout}=120    ${detailed_output}=${False}
    ...    ${graceful_cell_shutdown}=${None}
    ${Reset_cell_feedback}=    coam.reset_cell    cell_id=${cell_id}    connection=${connection}    timeout=${timeout}
    ...    detailed_output=${detailed_output}    graceful_cell_shutdown=${graceful_cell_shutdown}
    [Return]    ${Reset_cell_feedback}

Reset site with BTS
    [Documentation]    Reset site with the BTS.
    ...    Site reset status. Examples of returned statuses: ‘Requested’, ‘Accepted’, ‘Waiting for response’,
    ...    ‘Completed’, ‘Rejected’ or dict response if detailed_output is set to True.
    ...    reset_without_ru (bool) – Optional - default value: false) //Added since CB012446-B.
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=600    ${detailed_output}=${False}    ${wait_for_reconnection}=${True}
    ...    ${graceful_cell_shutdown}=${None}    ${reset_without_ru}=${None}
    ${Reset_site_status}=    coam.reset_site    connection=${connection}    timeout=${timeout}    detailed_output=${detailed_output}
    ...    wait_for_reconnection=${wait_for_reconnection}    graceful_cell_shutdown=${graceful_cell_shutdown}
    ...    reset_without_ru=${reset_without_ru}
    [Return]    ${Reset_site_status}

Reset Unit with BTS
    [Documentation]    Reset Unit with the BTS.
    ...    dist_name – Dist name of unit to reset which is runtime view dist name like:
    ...    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/GNSSE_R-1.
    ...    reset_type (str) – <Soft, Hard, Warm, PowerReset> (optional - default value for GNSSE, GNSSI, ALD,
    ...    TTMOD should be Hard, and Warm for BBMOD. It is set as ‘Soft’ by default due to legacy reasons.
    ...    Since CB010884-B, resetType with “Warm” and “PowerReset” value are only valid for BBMOD reset.
    ...    And BBMOD reset can only support warm reset/power reset.
    [Arguments]    ${dist_name}    ${reset_type}=Soft    ${connection}=GNB_OAM    ${timeout}=600    ${detailed_output}=${False}
    ...    ${force_radio_reset}=${None}    ${graceful_cell_shutdown}=${None}
    ${Reset_unit_status}=    coam.reset_unit    dist_name=${dist_name}    connection=${connection}    timeout=${timeout}
    ...    detailed_output=${detailed_output}    reset_type=${reset_type}    force_radio_reset=${force_radio_reset}
    ...    graceful_cell_shutdown=${graceful_cell_shutdown}
    [Return]    ${Reset_unit_status}

Reset bbpool with BTS
    [Documentation]    Reset bbpool with the BTS.
    ...    bbpool_array (list) – Array of bbpools dist_names to be reset, i.e.:
    ...    [“MRBTS-1/MNL-1/MNLENT-1/BBADM-1/BBPOOL-1”, “MRBTS-1/MNL-1/MNLENT-1/BBADM-1/BBPOOL-2”] :
    ...    param Union[str, int] timeout: Time to wait for positive procedure result. :param Union[AdminConnection,str]
    ...    connection: AdminConnection object or if used, string name alias..
    [Arguments]    ${bbpool_array}    ${connection}=GNB_OAM    ${timeout}=60
    ${Reset_bbpool_result}=    coam.reset_bbpool    bbpool_array=${bbpool_array}    connection=${connection}    timeout=${timeout}
    [Return]    ${Reset_bbpool_result}

# perform_delta_recommissioning(delta_file[, ...])

# perform_object_recommissioning(dist_name, ...)

# perform_parameter_recommissioning(dist_name, ...)

# rollback_software([timeout, ...])

# update_software(sw_package[, ...])

Get info with BTS
    [Documentation]    Get info with the BTS.
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=10    ${detailed_output}=${False}
    ${Dictionary_data}=    coam.get_bts_info    connection=${connection}    timeout=${timeout}    detailed_output=${detailed_output}
    [Return]    ${Dictionary_data}

Get cell list info
    [Documentation]    Get cell list info.
    ...    Union[list, dict] RAT dictionary with cell list parameters or full api response when detailed_output is True
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=10    ${detailed_output}=${False}
    ${cell_list_info}=    coam.get_cell_list    connection=${connection}    timeout=${timeout}    detailed_output=${detailed_output}
    [Return]    ${cell_list_info}

Get cells info with BTS
    [Documentation]    Get cells info with the BTS.
    ...    Dictionary with data for each available cell of given type or full api response
    ...    cell_type (str) – Cell type of given RAT: “lte”, “wcdma”, “gsm”, “nr” (5G). Default: “nr”.
    [Arguments]    ${cell_type}=nr    ${connection}=GNB_OAM    ${timeout}=10    ${detailed_output}=${False}
    ${Dictionary_data}=    coam.get_cells_info    cell_type=${cell_type}    connection=${connection}
    ...    timeout=${timeout}    detailed_output=${detailed_output}
    [Return]    ${Dictionary_data}

Check systemModule status
    [Arguments]    ${connection}=GNB_OAM
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${detected_info}    coam.get_detected_hw_info    connection=${connection}
    Set Suite Variable    ${detected_info}
    @{list_systemModules}    Set variable    ${detected_info['systemModules']}
    ${count_systemModules}    Get length    ${list_systemModules}
    Should be true    ${count_systemModules}>=${1}    msg=Check systemModule status failed as total systemModule number is less than 1
    FOR  ${systemModule}  IN  @{list_systemModules}
        Run keyword and continue on failure    Should be equal as strings    ${systemModule['status']['administrativeState']}    ${unlocked}
                                      ...  msg=Current systemModule administrativeState is not in Unlocked status
        Run keyword and continue on failure    Should be equal as strings    ${systemModule['status']['operationalState']}    ${enabled}
                                      ...  msg=Current systemModule operationalState is not in enabled status
        Run keyword and continue on failure    Should be equal as strings    ${systemModule['status']['proceduralStatus']}    configured
                                      ...  msg=Current systemModule proceduralStatus is not in configured status
        Run keyword and continue on failure    Should be equal as strings    ${systemModule['status']['usageState']}    Active
                                      ...  msg=Current systemModule usageState is not in Active status
    END

Check basebandModule status
    [Arguments]    ${connection}=GNB_OAM
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${detected_info}    coam.get_detected_hw_info    connection=${connection}
    Set Suite Variable    ${detected_info}
    @{list_basebandModules}    Set variable    ${detected_info['basebandModules']}
    ${count_basebandModules}    Get length    ${list_basebandModules}
    Should be true    ${count_basebandModules}>=${1}    msg=Check basebandModule status failed as total basebandModule number is less than 1
    FOR  ${basebandModule}  IN  @{list_basebandModules}
        Run keyword and continue on failure    Should be equal as strings    ${basebandModule['status']['administrativeState']}    ${unlocked}
                                      ...  msg=Current basebandModule administrativeState is not in Unlocked status
        Run keyword and continue on failure    Should be equal as strings    ${basebandModule['status']['operationalState']}    ${enabled}
                                      ...  msg=Current basebandModule operationalState is not in enabled status
        Run keyword and continue on failure    Should be equal as strings    ${basebandModule['status']['proceduralStatus']}    configured
                                      ...  msg=Current basebandModule proceduralStatus is not in configured status
        Run keyword and continue on failure    Should be equal as strings    ${basebandModule['status']['usageState']}    Active
                                      ...  msg=Current basebandModule usageState is not in Active status
    END

Check radioModule status
    [Arguments]    ${connection}=GNB_OAM
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${detected_info}    coam.get_detected_hw_info    connection=${connection}
    Set Suite Variable    ${detected_info}
    @{list_radioModules}    Set variable    ${detected_info['radioModules']['rmod']}
    ${count_radioModules}    Get length    ${list_radioModules}
    Should be true    ${count_radioModules}>=${1}    msg=Check radioModule status failed as total radioModule number is less than 1
    FOR  ${radioModule}  IN  @{list_radioModules}
        Run keyword and continue on failure    Should be equal as strings    ${radioModule['status']['administrativeState']}    ${unlocked}
                                      ...  msg=Current radioModule administrativeState is not in Unlocked status
        Run keyword and continue on failure    Should be equal as strings    ${radioModule['status']['operationalState']}    ${enabled}
                                      ...  msg=Current radioModule operationalState is not in enabled status
        Run keyword and continue on failure    Should be equal as strings    ${radioModule['status']['proceduralStatus']}    configured
                                      ...  msg=Current radioModule proceduralStatus is not in configured status
        Run keyword and continue on failure    Should be equal as strings    ${radioModule['status']['usageState']}    Active
                                      ...  msg=Current radioModule usageState is not in Active status
    END

Check cell status
    [Arguments]    ${cell_type}=nr    ${connection}=GNB_OAM    ${timeout}=30
    ${unlocked}    Set Variable If    '${cell_type}' == 'nr' or '${cell_type}' == 'gsm'    Unlocked    unlocked
    ${enabled}    Set Variable If    '${cell_type}' == 'nr'    enabled    enabled
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    ${count_cell}    Get length    ${cell_info}
    Should be true    ${count_cell}>=${1}    msg=Check cell status failed as total cell number is less than 1
    FOR  ${cell}  IN  @{cell_info}
        Run keyword    Should be equal as strings    ${cell}[status][administrativeState]    ${unlocked}
                                      ...  msg=Current radioModule administrativeState is not in Unlocked status
        Run keyword    Should be equal as strings    ${cell}[status][operationalState]    ${enabled}
                                      ...  msg=Current radioModule operationalState is not in enabled status
        Run keyword If    '${cell_type}' == 'nr'    Should be equal as strings    ${cell}[status][proceduralStatus]    configured
                                      ...  msg=Current radioModule proceduralStatus is not in configured status
        Run keyword If    '${cell_type}' == 'nr' or '${cell_type}' == 'gsm'
                                      ...  Should be equal as strings    ${cell}[status][usageState]    Active
                                      ...  msg=Current radioModule usageState is not in Active status
    END

Check cell failed status after lock
    [Arguments]    ${cell_type}=nr    ${connection}=GNB_OAM    ${timeout}=30
    ${locked}    Set Variable If    '${cell_type}' == 'nr'    Locked    locked
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    ${count_cell}    Get length    ${cell_info}
    Should be true    ${count_cell}>=${1}    msg=Check cell status failed as total cell number is less than 1
    FOR  ${cell}  IN  @{cell_info}
        Run keyword    Should be equal as strings    ${cell}[status][administrativeState]    ${locked}
                                      ...  msg=Current radioModule administrativeState is not in Unlocked status
        Run keyword    Should be equal as strings    ${cell}[status][operationalState]    disabled
                                      ...  msg=Current radioModule operationalState is not in enabled status
        Run keyword If    '${cell_type}' == 'nr'    Should be equal as strings    ${cell}[status][proceduralStatus]   	initialization required
                                      ...  msg=Current radioModule proceduralStatus is not in initialization required status
        Run keyword If    '${cell_type}' == 'nr'    Should be equal as strings    ${cell}[status][usageState]    Idle
                                      ...  msg=Current radioModule usageState is not in Idle status
    END

Check cell failed status
    [Arguments]    ${cell_type}=nr    ${connection}=GNB_OAM    ${timeout}=30
#    ${Unlocked}    Set Variable If    '${cell_type}' == 'nr'    Unlocked    unlocked
    ${Unlocked}    Set Variable If    '${cell_type}' == 'nr' or '${cell_type}' == 'gsm'    Unlocked    unlocked
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    ${count_cell}    Get length    ${cell_info}
    Should be true    ${count_cell}>=${1}    msg=Check cell status failed as total cell number is less than 1
    FOR  ${cell}  IN  @{cell_info}
        Run keyword    Should be equal as strings    ${cell}[status][administrativeState]    ${Unlocked}
                                      ...  msg=Current radioModule administrativeState is not in Unlocked status
        Run keyword    Should be equal as strings    ${cell}[status][operationalState]    disabled
                                      ...  msg=Current radioModule operationalState is not in disabled status
        Run keyword If    '${cell_type}' == 'nr'    Should be equal as strings    ${cell}[status][proceduralStatus]    configured
                                      ...  msg=Current radioModule proceduralStatus is not in configured status
        Run keyword If    '${cell_type}' == 'nr'    Should be equal as strings    ${cell}[status][usageState]    Idle
                                      ...  msg=Current radioModule usageState is not in Idle status
    END

Check cell failed status after ng link locked only
    [Arguments]    ${cell_type}=nr    ${connection}=GNB_OAM    ${timeout}=30
#    ${Unlocked}    Set Variable If    '${cell_type}' == 'nr'    Unlocked    unlocked
    ${Unlocked}    Set Variable If    '${cell_type}' == 'nr' or '${cell_type}' == 'gsm'    Unlocked    unlocked
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    ${count_cell}    Get length    ${cell_info}
    Should be true    ${count_cell}>=${1}    msg=Check cell status failed as total cell number is less than 1
    FOR  ${cell}  IN  @{cell_info}
        Run keyword    Should be equal as strings    ${cell}[status][administrativeState]    ${Unlocked}
                                      ...  msg=Current radioModule administrativeState is not in Unlocked status
        Run keyword    Should be equal as strings    ${cell}[status][operationalState]    enabled
                                      ...  msg=Current radioModule operationalState is not in enabled status
        Run keyword If    '${cell_type}' == 'nr'    Should be equal as strings    ${cell}[status][proceduralStatus]    configured
                                      ...  msg=Current radioModule proceduralStatus is not in configured status
        Run keyword If    '${cell_type}' == 'nr'    Should be equal as strings    ${cell}[status][usageState]    Active
                                      ...  msg=Current radioModule usageState is not in Active status
        Run keyword If    '${cell_type}' == 'nr'    Should be equal as strings    ${cell}[status][barringStatus]    barred
                                      ...  msg=Current radioModule usageState is not in barred status
    END

Check cell failed status after ng link unlocked only
    [Arguments]    ${cell_type}=nr    ${connection}=GNB_OAM    ${timeout}=30
#    ${Unlocked}    Set Variable If    '${cell_type}' == 'nr'    Unlocked    unlocked
    ${Unlocked}    Set Variable If    '${cell_type}' == 'nr' or '${cell_type}' == 'gsm'    Unlocked    unlocked
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    ${count_cell}    Get length    ${cell_info}
    Should be true    ${count_cell}>=${1}    msg=Check cell status failed as total cell number is less than 1
    FOR  ${cell}  IN  @{cell_info}
        Run keyword    Should be equal as strings    ${cell}[status][administrativeState]    ${Unlocked}
                                      ...  msg=Current radioModule administrativeState is not in Unlocked status
        Run keyword    Should be equal as strings    ${cell}[status][operationalState]    enabled
                                      ...  msg=Current radioModule operationalState is not in enabled status
        Run keyword If    '${cell_type}' == 'nr'    Should be equal as strings    ${cell}[status][proceduralStatus]    configured
                                      ...  msg=Current radioModule proceduralStatus is not in configured status
        Run keyword If    '${cell_type}' == 'nr'    Should be equal as strings    ${cell}[status][usageState]    Active
                                      ...  msg=Current radioModule usageState is not in Active status
        Run keyword If    '${cell_type}' == 'nr'    Should be equal as strings    ${cell}[status][barringStatus]    unbarred
                                      ...  msg=Current radioModule usageState is not in unbarred status
    END

loop check alarms
    FOR    ${per_time}    IN RANGE    ${check_alarms_times}
        Get and check fault id
        Sleep    10s
    END

loop Get alarms to check
    FOR    ${per_time}    IN RANGE    ${check_alarms_times}
        Get alarms to check
        Sleep    10s
    END

Get alarms to check
    [Arguments]     ${connection}=GNB_OAM
    ${activate_alarms}=    coam.get_active_alarms    connection=${connection}
    ${count_alarm}    Get length    ${activate_alarms}
#    Should be true    ${count_alarm}>=${1}    msg=Check cell status failed as total cell number is less than 1
   FOR  ${alarm}  IN  @{activate_alarms}
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '10'
                                      ...  msg=Current alarm faultId is equal 10
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4527'
                                      ...  msg=Current alarm faultId is equal 4527
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4341'
                                      ...  msg=Current alarm faultId is equal 4341
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '1900'
                                      ...  msg=Current alarm faultId is equal 1900
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '6450'
                                      ...  msg=Current alarm faultId is equal 6450
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '16'
                                      ...  msg=Current alarm faultId is equal 16
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '1806'
                                      ...  msg=Current alarm faultId is equal 1806
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '1868'
                                      ...  msg=Current alarm faultId is equal 1868
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4352'
                                      ...  msg=Current alarm faultId is equal 4352
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4383'
                                      ...  msg=Current alarm faultId is equal 4383
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '6911'
                                      ...  msg=Current alarm faultId is equal 6911
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4590'
                                      ...  msg=Current alarm faultId is equal 4590
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4681'
                                      ...  msg=Current alarm faultId is equal 4681
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '2087'
                                      ...  msg=Current alarm faultId is equal 2087
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '1815'
                                      ...  msg=Current alarm faultId is equal 1815
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '248'
                                      ...  msg=Current alarm faultId is equal 248
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '250'
                                      ...  msg=Current alarm faultId is equal 250
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '6502'
                                      ...  msg=Current alarm faultId is equal 6502
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4341'
                                      ...  msg=Current alarm faultId is equal 4341
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '1850'
                                      ...  msg=Current alarm faultId is equal 1850
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4539'
                                      ...  msg=Current alarm faultId is equal 4539
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4663'
                                      ...  msg=Current alarm faultId is equal 4663
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '9100'
                                      ...  msg=Current alarm faultId is equal 9100
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4261'
                                      ...  msg=Current alarm faultId is equal 4261
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '7516'
                                      ...  msg=Current alarm faultId is equal 7516
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '23'
                                      ...  msg=Current alarm faultId is equal 23
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '2056'
                                      ...  msg=Current alarm faultId is equal 2056
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '1907'
                                      ...  msg=Current alarm faultId is equal 1907
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '1981'
                                      ...  msg=Current alarm faultId is equal 1981
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '1920'
                                      ...  msg=Current alarm faultId is equal 1920
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4547'
                                      ...  msg=Current alarm faultId is equal 4547
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '1811'
                                      ...  msg=Current alarm faultId is equal 1811
    END
    ${history_alarms}=    coam.get_historic_alarms    timeout=${300}    connection=${connection}    load_history=${True}
    FOR  ${fault}  IN  @{history_alarms}
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '10'
                                      ...  msg=Current alarm faultId is equal 10
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4527'
                                      ...  msg=Current alarm faultId is equal 4527
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4341'
                                      ...  msg=Current alarm faultId is equal 4341
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '1900'
                                      ...  msg=Current alarm faultId is equal 1900
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '6450'
                                      ...  msg=Current alarm faultId is equal 6450
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '16'
                                      ...  msg=Current alarm faultId is equal 16
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '1806'
                                      ...  msg=Current alarm faultId is equal 1806
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '1868'
                                      ...  msg=Current alarm faultId is equal 1868
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4352'
                                      ...  msg=Current alarm faultId is equal 4352
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4383'
                                      ...  msg=Current alarm faultId is equal 4383
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '6911'
                                      ...  msg=Current alarm faultId is equal 6911
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4590'
                                      ...  msg=Current alarm faultId is equal 4590
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4681'
                                      ...  msg=Current alarm faultId is equal 4681
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '2087'
                                      ...  msg=Current alarm faultId is equal 2087
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '1815'
                                      ...  msg=Current alarm faultId is equal 1815
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '248'
                                      ...  msg=Current alarm faultId is equal 248
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '250'
                                      ...  msg=Current alarm faultId is equal 250
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '6502'
                                      ...  msg=Current alarm faultId is equal 6502
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4341'
                                      ...  msg=Current alarm faultId is equal 4341
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '1850'
                                      ...  msg=Current alarm faultId is equal 1850
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4539'
                                      ...  msg=Current alarm faultId is equal 4539
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4663'
                                      ...  msg=Current alarm faultId is equal 4663
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '9100'
                                      ...  msg=Current alarm faultId is equal 9100
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4261'
                                      ...  msg=Current alarm faultId is equal 4261
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '7516'
                                      ...  msg=Current alarm faultId is equal 7516
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '23'
                                      ...  msg=Current alarm faultId is equal 23
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '2056'
                                      ...  msg=Current alarm faultId is equal 2056
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '1907'
                                      ...  msg=Current alarm faultId is equal 1907
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '1981'
                                      ...  msg=Current alarm faultId is equal 1981
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '1920'
                                      ...  msg=Current alarm faultId is equal 1920
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4547'
                                      ...  msg=Current alarm faultId is equal 4547
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '1811'
                                      ...  msg=Current alarm faultId is equal 1811
    END

Get and check fault id
    [Arguments]     ${connection}=GNB_OAM
    ${activate_alarms}=    coam.get_active_alarms    connection=${connection}
    ${count_alarm}    Get length    ${activate_alarms}
#    Should be true    ${count_alarm}>=${1}    msg=Check cell status failed as total cell number is less than 1
    @{active_faultID_list}=    Create List
    @{history_faultID_list}=    Create List
    FOR  ${alarm}  IN  @{activate_alarms}
        Append To List    ${active_faultID_list}    ${alarm}[faultId]
    END
    ${history_alarms}=    coam.get_historic_alarms    timeout=${300}    connection=${connection}    load_history=${True}
    FOR  ${fault}  IN  @{history_alarms}
        Append To List    ${history_faultID_list}    ${fault}[faultId]
    END
    ${is_unexpected_active_fault}    ${unexpected_active_fault_id}=    check_fault_is_existed    detected_fault_id=${active_faultID_list}
    ${is_unexpected_history_fault}    ${unexpected_history_fault_id}=    check_fault_is_existed    detected_fault_id=${history_faultID_list}
    IF    ${is_unexpected_active_fault} == ${True}
        Fail    Unexpected active fault id is found: ${unexpected_active_fault_id}
    END
    IF    ${is_unexpected_history_fault} == ${True}
        Fail    Unexpected history fault id is found: ${unexpected_history_fault_id}
    END

Get required fault to check
    [Arguments]     ${connection}=GNB_OAM
    ${activate_alarms}=    coam.get_active_alarms    connection=${connection}
    ${count_alarm}    Get length    ${activate_alarms}
    Should be true    ${count_alarm}>=${1}    msg=Check cell status failed as total cell number is less than 1
    ${faultID_list}=    Create List
    FOR  ${alarm}  IN  @{activate_alarms}
        Append To List    ${faultID_list}    ${alarm}[faultId]
    END
    List Should Contain Value    ${faultID_list}    ${7107}
    # 7523 is not visible now, update: 2025.09.04
#    List Should Contain Value    ${faultID_list}    ${7523}

Save snapshot with BTS
    [Documentation]    Save snapshot with the BTS.
    [Arguments]  ${connection}=GNB_OAM    ${log_path}=${epc_log_path}     ${timeout}=${360}
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_file_path}    Set variable    ${log_path}/snapshot_rest_api_${timestamp}.zip
    coam.get_snapshot    target_file_name=${snapshot_file_path}    connection=${connection}    timeout=${timeout}
    [Return]    ${snapshot_file_path}

commissioning and check status
    [Arguments]    ${scf_file}    ${timeout}    ${skip_parameter_relation_errors}=${False}
    ...    ${connection}=${connection}    ${is_pdl_checking_needed}=${True}
    ${commissioning_status}=    Commission scf with BTS    scf_file=${scf_file}    timeout=${timeout}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}    connection=${connection}
    Should be equal as strings
    ...    ${commissioning_status}[commissioningResult][activationResult][resultNode][parameters][result]    Success
    ...    msg=Commissioned with error exists, activation result is not in success status.    ignore_case=${True}
    Should be equal as strings    ${commissioning_status}[validationResult][niddValidationResult][status]    OK
    ...    msg=Commissioned with error exists, nidd validation result is not in OK status    ignore_case=${True}
    run keyword and continue on failure    Run keyword if    ${is_pdl_checking_needed}==${True}
    ...    Should be equal as strings    ${commissioning_status}[validationResult][pdlValidationResult][status]    OK
    ...        msg=Commissioned with error exists, pdl validation result is not in OK status.    ignore_case=${True}
    BuiltIn.Log    Commission with scf file via rest API successfully.
    [Return]    ${commissioning_status}

Check X2 link status
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=600
    @{MOs_lteenb_a}    coam.get_managed_objects    class_name=LTEENB_A    connection=${connection}    timeout=${timeout}
    @{MOs_lteenb_r}    coam.get_managed_objects    class_name=LTEENB_R    connection=${connection}    timeout=${timeout}
    &{dict_x2LinkLock}     coam.get_parameters    dist_name=${MOs_lteenb_a[0]['distName']}  pattern=x2LinkLock    connection=${connection}
    &{dict_x2LinkStatus}    coam.get_parameters    dist_name=${MOs_lteenb_r[0]['distName']}  pattern=x2LinkStatus    connection=${connection}
    should be equal as strings    ${dict_x2LinkLock['x2LinkLock']}    unlocked    msg=x2LinkLock is not in unlocked status    ignore_case=${True}
    should be equal as strings    ${dict_x2LinkStatus['x2LinkStatus']}    available    msg=x2LinkStatus is not in available status
    ...                            ignore_case=${True}

Check X2 link status from GNB
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=600
    ${bts_info}=    Get info with BTS    connection=${connection}
    ${is_x2_check_from_gnb_needed} 	  Set Variable If	  '${bts_info}[gNbCuType]' == 'SA'    ${False}    ${True}
    Run keyword if    ${is_x2_check_from_gnb_needed}==${True}
    ...    Wait until keyword succeeds    ${timeout}    5s    Check X2 link status    connection=${connection}

check if ASOD or ASOE or ASOF or ASOG or ASOH testline
    [Arguments]    ${gnb_index}=${0}    ${alias}=GNB_SSH   ${timeout}=5s    ${retry_interval}=1s
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.password}
    Run Keyword And Ignore Error   csn.disconnect    connection=${alias}
    Wait until keyword succeeds    ${timeout}    ${retry_interval}    csn.connect_to
    ...    hostname=${bts_host}    username=${username}    password=${password}   alias=${alias}
    Sleep    2s
    ${gnb_card_info}=    csn.execute    command=ddal -s ddal_sysinfo_module_get_unit_id 0
    ...    connection=${alias}
    ${ret_asod}    run keyword and return status    should contain    ${gnb_card_info}    ASOD
    ${ret_asoe}    run keyword and return status    should contain    ${gnb_card_info}    ASOE
    ${ret_asof}    run keyword and return status    should contain    ${gnb_card_info}    ASOF
    ${ret_asog}    run keyword and return status    should contain    ${gnb_card_info}    ASOG
    ${ret_asoh}    run keyword and return status    should contain    ${gnb_card_info}    ASOH
    ${ret}    Set variable if  (${ret_asod} or ${ret_asoe} or ${ret_asof} or ${ret_asog} or ${ret_asoh})   ${True}   ${False}
    [Teardown]    run keyword and ignore error    csn.disconnect    connection=${alias}
    [Return]    ${ret}

check per module status
    [Arguments]    ${gnb_index}=${0}
    Wait Until Keyword Succeeds    5min    10s    Check systemModule status
    ${check_result}=    check if ASOD or ASOE or ASOF or ASOG or ASOH testline    gnb_index=${gnb_index}
    Run Keyword If    ${check_result} == ${False}
    ...    Wait Until Keyword Succeeds    10min    10s    Check basebandModule status
    ...    ELSE    Log to console    Skip the status checking for ABIL as the blade type is ASOD or ASOE or ASOF or ASOG or ASOH
    Wait Until Keyword Succeeds    10min    10s    Check radioModule status

get_allowed_faults_ids_string
    [Arguments]    ${value_allowed_faults_ids_list}
    ${allowed_faults_ids_string}=    convert_list_to_string    para_list=${value_allowed_faults_ids_list}
    [Return]    ${allowed_faults_ids_string}

upload the tmp file
    [Arguments]
    ...    ${filename}=dump_oip_signals.sh
    ...    ${gnb_file_path}=/ffs/run/config//toor4nsn/
    ...    ${home_path}=/home/ute/Downloads/
    ...    ${gnb_index}=${0}
    ...    ${connection}=GNB_SSH
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.password}
    csn.connect_to
    ...    hostname=${bts_host}    username=${username}    password=${password}   alias=${connection}
    sleep    2
    csn.Upload File   remote_path=${gnb_file_path}${filename}   local_path=${home_path}${filename}   connection=${connection}
    sleep    2
    [Teardown]    csn.disconnect    connection=${connection}