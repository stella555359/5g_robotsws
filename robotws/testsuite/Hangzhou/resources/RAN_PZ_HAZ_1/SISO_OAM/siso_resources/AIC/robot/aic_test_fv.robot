*** Settings ***
Documentation
...    Author:    Wu Amy;Zhou Qiang;Ding Lisa
...    Maintainer:    Wu Amy;Zhou Qiang;Ding Lisa

Resource    ./bts/aic_bts_common_oam.robot
Resource    ../../l3call.robot
Resource    ./aic_common_interface.robot

*** Keywords ***
vDU Reset
    [Arguments]    ${required_cells}=${Empty}    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}
    Make Tput    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
    vDU Reset VDU And Check Onair For All CUs
    Check RU List Status Should Be As Expected
    Check Alarms In CUs
    Check Alarms In vDUs
    Check Historical Alarms In CUs    additional_allowed_alarms=Matching ServedCell not found over F1-C
    Check Historical Alarms In vDUs
    Make Tput    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}

vDU Template Commissioning
    [Arguments]    ${clear_conf}=${True}
    Run Keyword If    ${clear_conf}    Multi VDUs Clear Configuration With Kuafu
    Template File Commissioning In Multi vDUs
    Wait For All Cells Onair In All vDUs
    vCU Verify All Cells Onair For All CUs
    Check RU List Status Should Be As Expected
    Check Alarms In CUs
    Check Alarms In vDUs
    Check Historical Alarms In CUs
    Check Historical Alarms In vDUs

vDU Cells Block Unblock
    [Arguments]    ${cell_id_list}=${ALL_CELL_LIST}    ${vdu_index}=vDU_0    ${cu_index}=CU_0
    ...    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    FOR    ${cell_id}    IN    @{cell_id_list}
        Make Tput    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${cell_id['phyCellId']}
        ${out}    vdu.block_cell    cell_id=${cell_id['cellId']}
        Wait Until Keyword Succeeds    60    5    vDU Check Block Cell Operation Status
        ...    operation_id=${out["id"]}    expected_status=success
        ${out}    vdu.unblock_cell    cell_id=${cell_id['cellId']}
        Wait Until Keyword Succeeds    60    5    vDU Check Unblock Cell Operation Status
        ...    operation_id=${out["id"]}    expected_status=success
        Make Tput    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${cell_id['phyCellId']}
    END
    Check Alarms In CUs
    Check Alarms In vDUs
    Check Historical Alarms In CUs    additional_allowed_alarms=Cell blocked
    Check Historical Alarms In vDUs    additional_allowed_alarms=Cell blocked
    [Teardown]    Run Keyword And Ignore Error    Logout To vDU By Rest

vDU RF Module Reset
    [Arguments]    ${required_cells}=${Empty}    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}
    vDU Reset All RUs And Check Onair For All CUs
    Check RU List Status Should Be As Expected
    Check Alarms In CUs
    Check Alarms In vDUs
    Check Historical Alarms In CUs    additional_allowed_alarms=Matching ServedCell not found over F1-C:NgGnbInitPartialReset
    Check Historical Alarms In vDUs
    Make Tput    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}


vDU RF Module Power Reset
    [Arguments]    ${required_power_rfs}=${EMPTY}    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${required_cells}=${EMPTY}
    [Documentation]    Author:        amy.wu@nokia-sbell.com
    ...                Maintainer:    amy.wu@nokia-sbell.com
    ${required_power_rfs_list}    Split String    ${required_power_rfs}    :
    ${rf_list}    Set Variable If    "${required_power_rfs}"=="${EMPTY}"    ${USED_FR_SN_LIST}    ${required_power_rfs_list}
    Set Test Variable    ${HAS_CPRIN}    ${False}
    FOR    ${fr_serial_number}    IN    @{rf_list}
        Power Off Radio    ${fr_serial_number}
        Power On Radio    ${fr_serial_number}
    END
    Wait For All Cells Onair In All vDUs
    vCU Verify All Cells Onair For All CUs
    Check RU List Status Should Be As Expected
    Check Alarms In CUs
    Check Alarms In vDUs
    Check Historical Alarms In CUs    additional_allowed_alarms=Matching ServedCell not found over F1-C:NgGnbInitPartialReset
    Check Historical Alarms In vDUs
    Make Tput    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}

    [Teardown]      Power On Radio    ${fr_serial_number}

vDU RF Lock Unlock
    [Arguments]    ${required_cells}=${Empty}    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}
    vDU Lock Unlock All RUs And Check Status For All CUs
    Check Alarms In CUs
    Check Alarms In vDUs
    Check Historical Alarms In CUs
    Check Historical Alarms In vDUs
    Make Tput    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}

SiSo_CM_vDU_Recommissioning
    [Arguments]    ${cu_delta_json}=${Empty}    ${vdu_delta_json}=${Empty}
    ...    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${required_cells}=${EMPTY}
#    [Documentation]
#    ...    Author: haoyun-lyle.sheng@nokia-sbell.com
#    ...    Maintainer: haoyun-lyle.sheng@nokia-sbell.com
#    ...    Example:
#    ...    ${reset_para}=["CU_0-vDU_0":{"dist_name1":{'para_name1':'para_value1','para_name2':'para_value2',...},...}]
#    ...    ${online_para}=["CU_0-vDU_0":{"dist_name1":{'para_name1':'para_value1','para_name2':'para_value2',...},...}]
#    ...    ${related_cu_para}={"CU_0":[{"distname1":
#    ...    [{"operation_type":"replace", "parameter_path":"parameter_path1","value":"value1"},...]},...],...}
#    ${cu_para_status}    Run Keyword And Return Status    Should Not Be Empty    ${related_cu_para}
#    ${cu_para}    Run Keyword If    ${cu_para_status}    Evaluate    ${related_cu_para}
#    ${cu_index_list}    Run Keyword If    ${cu_para_status}    Get Dictionary Keys    ${cu_para}
#    ...    ELSE    Create List
#    FOR    ${cu_index}    IN    @{cu_index_list}
#        vCU Multi Parameters Recommission    ${cu_para["${cu_index}"]}    force_reset=${True}    cu_index=${cu_index}
#    END
#    ${reset_para_status}    Run Keyword And Return Status    Should Not Be Empty    ${reset_para}
#    ${reset_para}    Run Keyword If    ${reset_para_status}    Evaluate    ${reset_para}    ELSE    Create List
#    ${reset_vdu_index_list}    Run Keyword If    ${reset_para_status}    Get Dictionary Keys    ${reset_para}
#    ...    ELSE    Create List
#    FOR    ${reset_vdu_index}    IN    @{reset_vdu_index_list}
#        ${vdu_index}    ${cu_index}    Split String    ${reset_vdu_index}    -
#        vDU Multi Parameters Recommission By Delta Plan    ${reset_para["${reset_vdu_index}"]}    operation=replace
#        ...    recommission_type=site_reset    vdu_index=${vdu_index}    cu_index=${cu_index}
#    END
#    ${online_para_status}    Run Keyword And Return Status    Should Not Be Empty    ${online_para}
#    ${online_para}    Run Keyword If    ${online_para_status}    Evaluate    ${online_para}    ELSE    Create List
#    ${online_vdu_index_list}    Run Keyword If    ${reset_para_status}    Get Dictionary Keys    ${online_para}
#    ...    ELSE    Create List
#    FOR    ${online_vdu_index}    IN    @{online_vdu_index_list}
#        ${vdu_index}    ${cu_index}    Split String    ${online_vdu_index}    -
#        vDU Multi Parameters Recommission By Delta Plan    ${online_para["${online_vdu_index}"]}    operation=replace
#        ...    recommission_type=online    vdu_index=${vdu_index}    cu_index=${cu_index}
#    END
    ${cu_para_status}    Run Keyword And Return Status    Should Not Be Empty    ${cu_delta_json}
    ${vdu_para_status}    Run Keyword And Return Status    Should Not Be Empty    ${vdu_delta_json}
    Run Keyword If    ${cu_para_status}
    ...    vCU Multi Parameters Recommission    ${cu_delta_json}
    ...    ELSE IF    ${vdu_para_status}
    ...    vDU Multi Parameters Recommission By Delta Plan    ${vdu_delta_json}
    ...    ELSE    Fail
    Make Tput    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
    Check Alarms In CUs
    Check Alarms In vDUs
    Check Historical Alarms In CUs
    ...    additional_allowed_alarms=Matching ServedCell not found over F1-C
    Check Historical Alarms In vDUs
    ...    additional_allowed_alarms=Previously downloaded plan dp_00000000 was overwritten by a new plan dp_00000000

All vDUs Lock And Unlock
    [Documentation]    Author: haoyun-lyle.sheng@nokia-sbell.com
    ...                Maintainer: haoyun-lyle.sheng@nokia-sbell.com
    [Arguments]    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${required_cells}=${EMPTY}
    Make Tput    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
    ${teardown}    Set Variable    ${True}
    vCU Lock All vDU And Check Result For All CUs
    Check Alarms In CUs
    Check Alarms In vDUs
    vCU Unlock All vDU And Check Result For All CUs
    ${teardown}    Set Variable    ${False}
    Wait For All Cells Onair In All vDUs
    Wait For All Cells Onair In All CUs
    Make Tput    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
    Check Alarms In CUs
    Check Alarms In vDUs
    Check Historical Alarms In CUs
    Check Historical Alarms In vDUs
    [Teardown]    Run Keyword If    ${teardown}    vCU Unlock All vDU And Check Result For All CUs

SISO vDU Startup With Delayed RF Link
    [Documentation]    Author: haoyun-lyle.sheng@nokia-sbell.com
    ...                Maintainer: haoyun-lyle.sheng@nokia-sbell.com
    [Arguments]    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${required_cells}=${EMPTY}
    FOR    ${vdu}    IN    @{VDU_LIST}
        ${cu_index}    ${vdu_index}    Split String     ${vdu}    -
        vDU Startup With Delayed RF Link    vdu_index=${vdu_index}    cu_index=${cu_index}
    END
    Make Tput    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
    Check Alarms In CUs
    Check Alarms In vDUs
    Check Historical Alarms In CUs    additional_allowed_alarms=Matching ServedCell not found over F1-C
    Check Historical Alarms In vDUs    additional_allowed_alarms=No connection to unit:Unit power reset

SiSO Collect RFSW logs from RU into snapshot
    [Arguments]    ${ru_account}=${EMPTY}
    FOR    ${vdu}    IN    @{VDU_LIST}
        ${cu_index}    ${vdu_index}    Split String    ${vdu}    -
        ${full_snapshot_path}    Save VDU Snapshot    coverage=full    vdu_index=${vdu_index}    cu_index=${cu_index}
        ${full_snapshot_path_size}    Get File Size    ${full_snapshot_path}
        ${unzip_full_snapshot_path}    check_xml_exist_technical_logs    ${full_snapshot_path}
        Check All RFSWs Log In Snapshot    ${unzip_full_snapshot_path}    ru_account=${ru_account}
        Create snapshot and cancel it during creation    vdu_index=${vdu_index}    cu_index=${cu_index}
        ${full_snapshot_path2}    Save VDU Snapshot    coverage=full    vdu_index=${vdu_index}    cu_index=${cu_index}
        ${full_snapshot_path2_size}    Get File Size    ${full_snapshot_path2}
        Should Be True    ${full_snapshot_path2_size}>${full_snapshot_path_size}
        ${minor_snapshot_path}    Save VDU Snapshot    coverage=minor    vdu_index=${vdu_index}    cu_index=${cu_index}
        ${unzip_minor_snapshot_path}    check_xml_exist_technical_logs    ${minor_snapshot_path}
        Check All RFSWs Log In Minor Snapshot    ${unzip_minor_snapshot_path}
    END

SiSo Online Cell Deletion Addition
    [Arguments]    ${cells}    ${required_cells}=${EMPTY}    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}
    [Documentation]
    ...    Author: amy.wu@nokia-sbell.com
    ...    Maintainer: amy.wu@nokia-sbell.com
    ${cell_vdu_dict}    Create Cell Vdu Dictionary    ${cells}
    ${cell_vdu_list}    Get Dictionary Keys    ${cell_vdu_dict}
    FOR    ${vdu}    IN    @{cell_vdu_list}
        ${cu_index}    ${vdu_index}    Split String    ${vdu}    -
        ${vdu_cell_num}    Get Length    ${NODE_CFG["${cu_index}"]["${vdu_index}"]["phyCellId_list"]}
        ${cell_list}    Get From Dictionary    ${cell_vdu_dict}    ${cu_index}-${vdu_index}
        Delete Cells In vDU    ${cell_list}    ${vdu_index}    ${cu_index}
        ${cells_summary}    vDU Get Cells Summary    vdu_index=${vdu_index}    cu_index=${cu_index}
        Should Be True    ${vdu_cell_num}-${cell_list.__len__()}==${cells_summary['availability_status']['on_line']}
        Remove Values From List    ${ALL_CELL_LIST}    @{cell_list}
        ${required_cells_after}    Remove Cells    ${required_cells}    ${cell_list}
        Make Tput    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells_after}
        Add Cells In vDU    ${cell_list}    ${vdu_index}    ${cu_index}
        ${cells_summary}    vDU Get Cells Summary    vdu_index=${vdu_index}    cu_index=${cu_index}
        Should Be True    ${vdu_cell_num}==${cells_summary['availability_status']['on_line']}
        Append To List    ${ALL_CELL_LIST}    @{cell_list}
        Make Tput    required_cells=${required_cells}    extra_peak_rate_config=${extra_peak_rate_config}
    END

vDU RANNIC Reset
    [Arguments]    ${mrbts_id}    ${required_cells}=${Empty}
    ...    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}
    vDU Reset Rannic And Check Onair For All CUs    ${mrbts_id}
    vDU Lock Unlock All RUs And Check Status For All CUs
    Check RU List Status Should Be As Expected
    Check Alarms In CUs
    Check Alarms In vDUs
    Check Historical Alarms In CUs    additional_allowed_alarms=Matching ServedCell not found over F1-C
    Check Historical Alarms In vDUs
    Make Tput    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
