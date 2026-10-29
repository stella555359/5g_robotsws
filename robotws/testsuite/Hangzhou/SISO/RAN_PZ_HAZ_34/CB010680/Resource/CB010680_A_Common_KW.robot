*** Settings ***
Documentation    this is common keyword used for CB0101680-A siso opertation

Library    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010680/Resource/CB010680_SRS_BIP.py
Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010680/Resource/CB010680_A_Params.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/SISO_common_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/common_variables.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010680/Resource/CB010680_BIP.robot

*** Keywords ***
CB010680 Common Teardown
    SISO_common_operation.Common Case Teardown    bts_host=${gNB_ip}
    Run Keyword If    "${TEST_STATUS}"=="FAIL"    Setup Commission SCF    scf_name=${EMPTY}    timeout=600
    Run Keyword And Ignore Error    Check GNB on air And alarm    bts_host=${gNB_ip}
    ...    allowed_list=${allowed_alarm_list}    time=20min

CB010680_A Common Teardown With TMO SCF Restore
    Run Keyword If    "${TEST_STATUS}"=="FAIL"    Save Snapshot    bts_host=${gNB_ip}
    Run Keyword And Ignore Error    Setup Commission SCF    scf_name=${EMPTY}    timeout=600
    Run Keyword And Ignore Error    Check GNB on air And alarm    bts_host=${gNB_ip}    allowed_list=${allowed_alarm_list}    time=20min
    SISO_common_operation.Common Case Teardown    bts_host=${gNB_ip}
    Run Keyword If    "${TEST_STATUS}"=="FAIL"    Save Snapshot    bts_host=${gNB_ip}

CB010680_D Common Teardown
    SISO_common_operation.Common Case Teardown    bts_host=${gNB_ip}
    Check Fault 6832 SAS Server Lost
    Run Keyword If    "${TEST_STATUS}"=="FAIL"    Setup Commission SCF    scf_name=_D    timeout=600
    Run Keyword And Ignore Error    Check GNB on air And alarm    bts_host=${gNB_ip}
    ...    allowed_list=${allowed_alarm_list}    time=20min    interval=180

Modify Parameters with coam
    [Arguments]    ${input_list}    ${delta_id}=update_parameter    ${connection}=GNB_OAM
    coam.create_delta    delta_id=${delta_id}
    Log to console    start modify parameters:\n
    FOR    ${item}  IN    @{input_list}
        ${operation}    get from dictionary    ${item}    operation
        Run keyword if    '${operation}'=='update'
        ...    coam.append_parameter_update_to_delta    dist_name=${item['dist_name']}    parameter=${item['parameter']}
        ...    value=${item['value']}    delta_id=${delta_id}
        Run keyword if    '${operation}'=='delete'
        ...    coam.append_parameter_delete_to_delta    dist_name=${item['dist_name']}    parameter=${item['parameter']}
        ...    delta_id=${delta_id}
        Run keyword if    '${operation}'=='update_object'
        ...    coam.append_managed_object_to_delta    dist_name=${item['dist_name']}
        ...    operation=update    delta_id=${delta_id}
        Run keyword if    '${operation}'=='delete_object'
        ...    coam.append_managed_object_to_delta    dist_name=${item['dist_name']}
        ...    operation=delete    delta_id=${delta_id}
        Run keyword if    '${operation}'=='create_object'
        ...    coam.append_managed_object_to_delta    dist_name=${item['dist_name']}
        ...    operation=create    delta_id=${delta_id}
        Log to console    Add task - ${operation}: ${item['dist_name']}.${item['parameter']}=${item['value']}
    END
    ${delta_file}    coam.get_delta    delta_id=${delta_id}
    ${timeout}    set variable    300
    Log to console    Perform parameters via delta_id:${delta_id} is ongoing, timeout ${timeout}s.
    coam.perform_delta_recommissioning
    ...    delta_file=${delta_file}
    ...    skip_parameter_relation_errors=${False}
    ...    should_activate=${True}
    ...    timeout=${timeout}
    ...    connection=${connection}
    Log to console    Perform parameters done.
    [Teardown]    run keyword and ignore error    coam.remove_delta    delta_id=${delta_id}

Get srsForPositioning For Specfic Cell
    [Arguments]    ${bts_host}    ${username}    ${password}    ${cell_id}    ${cSRS_PRBs}=${272}    ${connection}=GNB_OAM
    Log To Console    Get srsForPositioning For Specfic Cell ${cell_id}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    ...    connection=${connection}
    ${dist_name}    Set Variable    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id}
    ${parameter_list}    Create List    srsForPositioning    actPRBBlanking    nbrOfBlankedPRBsLowEdgeDL
    ...    nbrOfBlankedPRBsHighEdgeDL    nbrOfBlankedPRBsHighEdgeUL    nbrOfBlankedPRBsLowEdgeUL
    ${srsForPositioning}    coam.get_parameter_by_distname    dist_name=${dist_name}    parameter_list=${parameter_list}
    ...    include_children=${False}    connection=${connection}
    ${srsConfig}    Set Variable    ${srsForPositioning[0]['parameters']['srsForPositioning']}
    ${actPRBBlanking}    Set Variable    ${srsForPositioning[0]['parameters']['actPRBBlanking']}
    ${nbrOfBlankedPRBsLowEdgeDL}    Set Variable    ${srsForPositioning[0]['parameters']['nbrOfBlankedPRBsLowEdgeDL']}
    ${nbrOfBlankedPRBsHighEdgeDL}    Set Variable    ${srsForPositioning[0]['parameters']['nbrOfBlankedPRBsHighEdgeDL']}
    ${nbrOfBlankedPRBsHighEdgeUL}    Set Variable    ${srsForPositioning[0]['parameters']['nbrOfBlankedPRBsHighEdgeUL']}
    ${nbrOfBlankedPRBsLowEdgeUL}    Set Variable    ${srsForPositioning[0]['parameters']['nbrOfBlankedPRBsLowEdgeUL']}
    ${startPrb}    Evaluate    int(${nbrOfBlankedPRBsLowEdgeDL})
    ${prbNum}    Evaluate    ${cSRS_PRBs}-int(${nbrOfBlankedPRBsHighEdgeDL})-int(${nbrOfBlankedPRBsLowEdgeDL})
    Log To Console    Current srsForPositioning is: ${srsForPositioning[0]} ${startPrb} ${prbNum}
    [Return]    ${srsConfig[0]}    ${startPrb}    ${prbNum}

Get lcrID And pci For Specfic Cell
    [Arguments]    ${bts_host}    ${username}    ${password}    ${cell_id}    ${connection}=GNB_OAM
    Log To Console    Get lcrID And pci For Specfic Cell ${cell_id}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    ...    connection=${connection}
    ${dist_name}    Set Variable    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id}
    ${parameter_list}    Create List    nrCellId    lcrId    physCellId
    ${cellInfo}    coam.get_parameter_by_distname    dist_name=${dist_name}    parameter_list=${parameter_list}
    ...    include_children=${False}    connection=${connection}
    ${nrCellId}    Set Variable    ${cellInfo[0]['parameters']['nrCellId']}
    ${lcrId}    Set Variable    ${cellInfo[0]['parameters']['lcrId']}
    ${physCellId}    Set Variable    ${cellInfo[0]['parameters']['physCellId']}
    Log To Console    Current lcrID:${lcrId} pci:${physCellId} nrCellId:${nrCellId}
    [Return]    ${nrCellId}    ${lcrId}    ${physCellId}

Get actHPPosMethodOptList For Specfic Cell
    [Arguments]    ${bts_host}    ${username}    ${password}    ${cell_id}    ${connection}=GNB_OAM
    Log To Console    Get ActHPPosMethodOptList For Specfic Cell ${cell_id}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    ...    connection=${connection}
    ${dist_name}    Set Variable    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id}
    ${parameter_list}    Create List    actHPPosMethodOptList
    ${actHPPosMethodOptList}    coam.get_parameter_by_distname    dist_name=${dist_name}    parameter_list=${parameter_list}
    ...    include_children=${False}    connection=${connection}
    #[{'distName': 'MRBTS-37611/NRBTS-37611/NRCELL-1', 'parameters': {'actHPPosMethodOptList': ['UL-TDOA']}}]" ]
    ${value}    Set Variable    ${actHPPosMethodOptList[0]['parameters']['actHPPosMethodOptList']}
    Log To Console    Current actHPPosMethodOptList is: ${value}
    [Return]    ${value}

Online Enable actHPPosMethodOptList For Specfic Cell
    [Arguments]    ${bts_host}    ${username}    ${password}    ${cell_id}    ${connection}=GNB_OAM
    Log To Console    Online Enable ActHPPosMethodOptList For Specfic Cell ${cell_id}
    ${actHPposMethodOptList}    Get actHPPosMethodOptList For Specfic Cell    bts_host=${bts_host}    username=${username}
    ...    password=${password}    cell_id=${cell_id}    connection=${connection}
    ${dist_name}    Set Variable    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id}
    ${parameter}    Set Variable    actHPPosMethodOptList
    ${fea_enable}    Create List    UL-TDOA
    ${fea_disabled}   Create List    disabled
    Run Keyword If    ${actHPposMethodOptList}!=${fea_disabled}    Log To Console    actHPPosMethodOptList is already enabled
    ...    ELSE    coam.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=${parameter}
    ...    operation=update    value=${fea_enable}    skip_parameter_relation_errors=True    should_activate=True    connection=${connection}
    ${actHPposMethodOptList}    Get actHPPosMethodOptList For Specfic Cell    bts_host=${bts_host}    username=${username}
    ...    password=${password}    cell_id=${cell_id}    connection=${connection}
    Should Be Equal    ${actHPposMethodOptList}    ${fea_enable}

Online Disable actHPPosMethodOptList For Specfic Cell
    [Arguments]    ${bts_host}    ${username}    ${password}    ${cell_id}    ${connection}=GNB_OAM
    Log To Console    Online Disable ActHPPosMethodOptList For Specfic Cell ${cell_id}
    ${actHPposMethodOptList}    Get actHPPosMethodOptList For Specfic Cell    bts_host=${bts_host}    username=${username}
    ...    password=${password}    cell_id=${cell_id}    connection=${connection}
    ${dist_name}    Set Variable    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id}
    ${parameter}    Set Variable   actHPPosMethodOptList
    ${fea_disabled}   Create List    disabled
    Run Keyword If    ${actHPposMethodOptList}==${fea_disabled}    Log To Console    actHPPosMethodOptList is already disabled
    ...    ELSE    coam.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=${parameter}
    ...    operation=update    value=${fea_disabled}   skip_parameter_relation_errors=True    should_activate=True    connection=${connection}
    ${actHPposMethodOptList}    Get actHPPosMethodOptList For Specfic Cell    bts_host=${bts_host}    username=${username}
    ...    password=${password}    cell_id=${cell_id}    connection=${connection}
    Should Be Equal    ${actHPposMethodOptList}    ${fea_disabled}

Get actPRBBlanking For Specfic Cell
    [Arguments]    ${bts_host}    ${username}    ${password}    ${cell_id}    ${connection}=GNB_OAM
    Log To Console    Get actPRBBlanking For Specfic Cell ${cell_id}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    ...    connection=${connection}
    ${dist_name}    Set Variable    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id}
    ${parameter_list}    Create List    actPRBBlanking
    ${actPRBBlanking}    coam.get_parameter_by_distname    dist_name=${dist_name}    parameter_list=${parameter_list}
    ...    include_children=${False}    connection=${connection}
    ${value}    Set Variable    ${actPRBBlanking[0]['parameters']['actPRBBlanking']}
    Log To Console    Current actPRBBlanking is: ${value}
    [Return]    ${value}

Get nrCellIdentity For Specfic Cell
    [Arguments]    ${bts_host}    ${username}    ${password}    ${cell_id}    ${connection}=GNB_OAM
    Log To Console    Get nrCellIdentity For Specfic Cell ${cell_id}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    ...    connection=${connection}
    ${dist_name}    Set Variable    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id}
    ${parameter_list}    Create List    nrCellIdentity
    ${actPRBBlanking}    coam.get_parameter_by_distname    dist_name=${dist_name}    parameter_list=${parameter_list}
    ...    include_children=${False}    connection=${connection}
    ${value}    Set Variable    ${actPRBBlanking[0]['parameters']['nrCellIdentity']}
    Log To Console    Current nrCellIdentity is: ${value}
    [Return]    ${value}

Online Enable actPRBBlanking For Specfic Cell
    [Arguments]    ${bts_host}    ${username}    ${password}    ${cell_id}    ${connection}=GNB_OAM
    Log To Console    Online Enable actPRBBlanking For Specfic Cell ${cell_id}
    ${actPRBBlanking}    Get actPRBBlanking For Specfic Cell    bts_host=${bts_host}    username=${username}
    ...    password=${password}    cell_id=${cell_id}    connection=${connection}
    ${fea_enable}    Set Variable    ${True}
    ${fea_disabled}  Set Variable    ${False}
    Run Keyword If    ${actPRBBlanking}!=${fea_disabled}    Log To Console    actPRBBlanking is already enabled
    ...    ELSE    Enable prbBlanking And Modify Srs Parameter   bts_host=${bts_host}    username=${username}
    ...    password=${password}    cell_id=${cell_id}    connection=${connection}
    ${actPRBBlanking}    Get actPRBBlanking For Specfic Cell    bts_host=${bts_host}    username=${username}
    ...    password=${password}    cell_id=${cell_id}    connection=${connection}
    Should Be Equal    ${actPRBBlanking}    ${fea_enable}

Enable prbBlanking And Modify Srs Parameter
    [Arguments]    ${bts_host}    ${username}    ${password}    ${cell_id}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    ...    connection=${connection}
    ${CELL_DN}    Set Variable    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id}
    ${actPrbBlanking_ENABLE_PARAM}    update_parameters_dn    cell_dn=${CELL_DN}    params=${actPrbBlanking_ENABLE_PARAM}
    Modify Parameters with coam    input_list=${actPrbBlanking_ENABLE_PARAM}    connection=${connection}
    [Teardown]   run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Online Disable actPRBBlanking For Specfic Cell
    [Arguments]    ${bts_host}    ${username}    ${password}    ${cell_id}    ${connection}=GNB_OAM
    Log To Console    Online Disable actPRBBlanking For Specfic Cell ${cell_id}
    ${actPRBBlanking}    Get actPRBBlanking For Specfic Cell    bts_host=${bts_host}    username=${username}
    ...    password=${password}    cell_id=${cell_id}    connection=${connection}
    ${fea_disabled}   Set Variable    ${False}
    Run Keyword If    ${actPRBBlanking}==${fea_disabled}    Log To Console    actPRBBlanking is already disabled
    ...    ELSE    Disable prbBlanking And Modify Srs Parameter    bts_host=${bts_host}    username=${username}
    ...    password=${password}    cell_id=${cell_id}    connection=${connection}
    ${actPRBBlanking}    Get actPRBBlanking For Specfic Cell    bts_host=${bts_host}    username=${username}
    ...    password=${password}    cell_id=${cell_id}    connection=${connection}
    Should Be Equal    ${actPRBBlanking}    ${fea_disabled}

Online SRS Change For Disable actPRBBlanking For Specfic Cell
    [Arguments]    ${bts_host}    ${username}    ${password}    ${cell_id}    ${connection}=GNB_OAM
    Log To Console    Online Disable actPRBBlanking For Specfic Cell ${cell_id}
    ${actPRBBlanking}    Get actPRBBlanking For Specfic Cell    bts_host=${bts_host}    username=${username}
    ...    password=${password}    cell_id=${cell_id}    connection=${connection}
    ${fea_disabled}   Set Variable    ${False}
    Run Keyword If    ${actPRBBlanking}!=${fea_disabled}    Disable prbBlanking And Modify Srs Parameter Only
    ...    bts_host=${bts_host}    username=${username}    password=${password}    cell_id=${cell_id}    connection=${connection}
    ...    ELSE    Log To Console    actPRBBlanking is already disabled
    ${actPRBBlanking}    Get actPRBBlanking For Specfic Cell    bts_host=${bts_host}    username=${username}
    ...    password=${password}    cell_id=${cell_id}    connection=${connection}
    Should Be Equal    ${actPRBBlanking}    ${fea_disabled}

Disable prbBlanking And Modify Srs Parameter
    [Arguments]    ${bts_host}    ${username}    ${password}    ${cell_id}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    ...    connection=${connection}
    ${CELL_DN}    Set Variable    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id}
    ${actPrbBlanking_DISABLE_PARAM}    update_parameters_dn    cell_dn=${CELL_DN}    params=${actPrbBlanking_DISABLE_PARAM}
    Modify Parameters with coam    input_list=${actPrbBlanking_DISABLE_PARAM}    connection=${connection}
    [Teardown]   run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Disable prbBlanking And Modify Srs Parameter Only
    [Arguments]    ${bts_host}    ${username}    ${password}    ${cell_id}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    ...    connection=${connection}
    ${CELL_DN}    Set Variable    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id}
    ${SRS_CHANGE_ONLY_PARAM}    update_parameters_dn    cell_dn=${CELL_DN}    params=${SRS_CHANGE_ONLY_PARAM}
    Modify Parameters with coam    input_list=${SRS_CHANGE_ONLY_PARAM}    connection=${connection}
    [Teardown]   run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Get NRCELL ID List Via Admin CLI
    [Arguments]    ${bts_host}    ${username}    ${password}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    ...    connection=${connection}
    ${nr_cell_list}=    Get All Cell Id    cell_type=nr    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    [Return]    ${nr_cell_list}

SupperCell Number And Subcell Number Should Be Expected
    [Arguments]    ${bts_host}    ${username}    ${password}    ${supper_cell_num}    ${subcell_num_list}    ${connection}=GNB_OAM
    Log To Console    Expected SupperCell Number is ${supper_cell_num} and Subcell Number is ${subcell_num_list}
    ${nr_cell_list}=    Get NRCELL ID List Via Admin CLI    bts_host=${bts_host}    username=${username}    password=${password}
    ...    connection=${connection}
    ${nr_cell_num}    Get Length    ${nr_cell_list}
    Log To Console    Current SupperCell Number is ${nr_cell_num}
    Should Be Equal As Numbers    ${nr_cell_num}    ${supper_cell_num}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    ...    connection=${connection}
    FOR    ${cell_id}    IN     @{nr_cell_list}
            ${dist_name}    Set Variable    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id}
            ${parameter_list}    Create List    numOfSuperSubCells
            ${cellInfo}    coam.get_parameter_by_distname    dist_name=${dist_name}    parameter_list=${parameter_list}
            ...    include_children=${False}    connection=${connection}
            ${numOfSuperSubCells}    Set Variable    ${cellInfo[0]['parameters']['numOfSuperSubCells']}
            ${cell_index}    Get Index From List    ${nr_cell_list}    ${cell_id}
            Log To Console    Current Subcell Number is ${numOfSuperSubCells} for cell-${cell_id}
            Should Be Equal As Numbers    ${numOfSuperSubCells}    ${subcell_num_list[${cell_index}]}
    END

    [Teardown]   run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

RAT Reset Via Admin CLI And Check Cell Onair
    [Arguments]    ${bts_host}    ${rat_type}    ${connection}=GNB_OAM
    ...    ${graceful_cell_shutdown}=${False}    ${reset_type}=Soft    ${allowed_list}=@{empty_list}    ${time_out}=240
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    coam.rat_reset    rat_type=${rat_type}    graceful_cell_shutdown=${graceful_cell_shutdown}    reset_type=${reset_type}
    ...    timeout=${time_out}    connection=${connection}
    ${result}    Run Keyword And Return Status    Check GNB on air And alarm    bts_host=${bts_host}
    ...    allowed_list=${allowed_list}   time=${time_out}
    Run Keyword If    '${result}'=='${False}'    run keyword and continue on failure    Save Snapshot    bts_host=${bts_host}
    run keyword if    '${result}'=='${False}'    run keyword and continue on failure    Capture RU log    bts_host=${bts_host}
    Should Be True    '${result}'=='${True}'

    [Teardown]   run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

RAT Reset Via Admin CLI And Check Cell Disabed
    [Documentation]    expect cell status is still disabled after rat reset for some specfic scenario
    [Arguments]    ${bts_host}    ${rat_type}    ${connection}=GNB_OAM
    ...    ${graceful_cell_shutdown}=${False}    ${reset_type}=Soft    ${allowed_list}=@{empty_list}    ${time_out}=240
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    coam.rat_reset    rat_type=${rat_type}    graceful_cell_shutdown=${graceful_cell_shutdown}    reset_type=${reset_type}
    ...    timeout=${time_out}    connection=${connection}
    ${result}    Run Keyword And Return Status    Check GNB on air And alarm    bts_host=${bts_host}
    ...    allowed_list=${allowed_list}   time=${time_out}
    Should Be True    '${result}'=='${False}'
    [Teardown]   run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Lock or Unlock Cell And Check Status
    [Arguments]  ${allowed_list}    ${BTS_ID}=${TL_BTS_ID}   ${NRBTS_ID}=${TL_NRBTS_ID}    ${lock_cell_id_list}=${empty_list}
    ...    ${lock_flag}=${True}    ${bts_host}=${gnb_ip}     ${unlock_cell_id_list}=${empty_list}
    ${operate_cell_id_list}    Set Variable If    ${lock_flag}    ${lock_cell_id_list}    ${unlock_cell_id_list}
    Lock Or Unlock Mulite Cell     cell_id_list=${operate_cell_id_list}    lock_flag=${lock_flag}
    ...    bts_host=${bts_host}    BTS_ID=${BTS_ID}    NRBTS_ID=${NRBTS_ID}
    ${expect_item_status_dict}    create dictionary
    FOR  ${cell_id}  IN    @{lock_cell_id_list}
        Set to dictionary    ${expect_item_status_dict}    NRCELL-${cell_id}=${Cell_lock_status}
    END
    FOR  ${cell_id}  IN   @{unlock_cell_id_list}
        Set to dictionary    ${expect_item_status_dict}    NRCELL-${cell_id}=${Cell_unlock_status}
    END
    Check All RU or Cell Status    expect_item_status_dict=${expect_item_status_dict}    if_ru=${False}    bts_host=${bts_host}
    Check Alarm List on BTS    bts_host=${bts_host}    allowed_list=${allowed_list}

Lock or Unlock Mulite Cell
    [Arguments]  ${cell_id_list}    ${BTS_ID}    ${NRBTS_ID}    ${bts_host}    ${lock_flag}=${True}    ${connection}=GNB_OAM    ${timeout}=120
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    FOR  ${cell_id}  IN  @{cell_id_list}
        ${dist_name}    Set Variable    MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        Run keyword if    ${lock_flag}==${True}    Log To Console    Lock Cell-${cell_id}
        ...    ELSE    Log To Console    Unlock Cell-${cell_id}
        Run keyword if    ${lock_flag}==${True}    perform_cell_lock_via_admin    cell_id=${cell_id}
        ...    lock_timeout=${timeout}    connection=${connection}
        ...    ELSE    perform_cell_unlock_via_admin    cell_id=${cell_id}       lock_timeout=120    connection=${connection}
        sleep    2s
    END
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Cell Reset Via Admin CLI And Check Cell Onair
    [Arguments]    ${allowed_list}   ${cell_id_list}    ${BTS_ID}    ${NRBTS_ID}    ${bts_host}    ${connection}=reset_cell    ${timeout}=120
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    FOR  ${cell_id}  IN  @{cell_id_list}
        ${dist_name}    Set Variable    MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        Log To Console    Reset Cell-${cell_id}
        coam.reset_cell    cell_id=${dist_name}    connection=${connection}  timeout=${timeout}  graceful_cell_shutdown=${False}
        sleep    2s
    END
    ${expect_item_status_dict}    create dictionary
    FOR  ${cell_id}  IN    @{nr_cell_list}
        Set to dictionary    ${expect_item_status_dict}    NRCELL-${cell_id}=${Cell_unlock_status}
    END
    Check All RU or Cell Status    expect_item_status_dict=${expect_item_status_dict}    if_ru=${False}    bts_host=${bts_host}
    Check Alarm List on BTS    bts_host=${bts_host}    allowed_list=${allowed_list}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

###CB010680_A_013_site_block_for_Precise_Positioning_ABIP_SupperCell_with_RU_ACCESS_only###
Lock or Unlock RU And Check Status
    [Arguments]  ${lock_RU_id_list}=${empty_list}     ${unlock_RU_id_list}=${empty_list}
    ...    ${lock_flag}=${True}    ${bts_host}=${gnb_ip}    ${allowed_list}=${empty_list}
    ${operate_ru_id_list}    Set Variable If    ${lock_flag}    ${lock_RU_id_list}    ${unlock_RU_id_list}
    # Lock Or UnLock Multiple RU Via Admin CLI    RMOD_id_list=${operate_ru_id_list}    lock_flag=${lock_flag}    bts_host=${bts_host}
    Lock or UnLock Multiple RU Via CM Delta Plan    RMOD_id_list=${operate_ru_id_list}    lock_flag=${lock_flag}    bts_host=${bts_host}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${bts_host}
    ${expect_item_status_dict}    create dictionary
    FOR  ${item}  IN    @{lock_RU_id_list}
        Set to dictionary    ${expect_item_status_dict}    RMOD-${item}=${RU_lock_status}
    END
    FOR  ${item1}  IN   @{unlock_RU_id_list}
        Set to dictionary    ${expect_item_status_dict}    RMOD-${item1}=${RU_unlock_status}
    END
    Check All RU or Cell Status    expect_item_status_dict=${expect_item_status_dict}    if_ru=${True}    bts_host=${bts_host}

Lock or UnLock Multiple RU Via CM Delta Plan
    [Arguments]    ${RMOD_id_list}   ${lock_flag}=${True}    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${RMOD_DN_Lst}    Create List
    FOR  ${RMOD_id}  IN  @{RMOD_id_list}
        ${dist_name}    Set Variable    MRBTS-${TL_BTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_id}
        Run keyword if    ${lock_flag}==${True}    Log To Console    Lock RMOD-${RMOD_id}
        ...    ELSE    Log To Console    UnLock RMOD-${RMOD_id}
        Append To List    ${RMOD_DN_Lst}    ${dist_name}
    END
    ${rmod_para_list}    Run keyword if    ${lock_flag}==${True}    generate_rmod_lock_cm_list    rmod_dn_list=${RMOD_DN_Lst}
        ...    ELSE    generate_rmod_unlock_cm_list    rmod_dn_list=${RMOD_DN_Lst}
    Modify Parameters with coam    input_list=${rmod_para_list}    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Lock or UnLock Multiple RU Via Admin CLI
    [Arguments]    ${RMOD_id_list}   ${lock_flag}=${True}    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM    ${timeout}=60
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    FOR  ${RMOD_id}  IN  @{RMOD_id_list}
        ${dist_name}    Set Variable    MRBTS-${TL_BTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_id}
        Run keyword if    ${lock_flag}==${True}    Log To Console    Lock RMOD-${RMOD_id}
        ...    ELSE    Log To Console    UnLock RMOD-${RMOD_id}
        Run keyword if    ${lock_flag}==${True}    coam.lock    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
        ...    ELSE    coam.unlock    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
        sleep    2s
    END
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Get All RU Index Via Admin CLI
    [Arguments]    ${bts_host}    ${username}    ${password}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}    connection=${connection}
    ${all_ru_list}=    Get All RU Index    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    [Return]    ${all_ru_list}

Get All BBMOD Index Via Admin CLI
    [Arguments]    ${bts_host}    ${username}    ${password}    ${connection}=Get_BBMOD_Id
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}    connection=${connection}
    ${bb_mode_list}=    Get All BBmod Index    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    [Return]    ${bb_mode_list}

Lock or Unlock BB And Check Status
    [Arguments]  ${lock_BB_id_list}=${empty_list}     ${unlock_BB_id_list}=${empty_list}
    ...    ${lock_flag}=${True}    ${bts_host}=${gnb_ip}    ${allowed_list}=${empty_list}    ${connection}=GNB_OAM
    ${operate_bb_id_list}    Set Variable If    ${lock_flag}    ${lock_BB_id_list}    ${unlock_BB_id_list}
    Lock or UnLock Multiple BB    BBMOD_id_list=${operate_bb_id_list}    lock_flag=${lock_flag}    bts_host=${bts_host}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${bts_host}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${expect_item_status_dict}    create dictionary
    FOR  ${item}  IN    @{lock_BB_id_list}
        Wait Until Keyword Succeeds    5min    10s    bbmod Should Be Locked    bbmod_index=${item}
        Set to dictionary    ${expect_item_status_dict}    BBMOD-${item}=${Cell_disable_status}
    END
    FOR  ${item}  IN   @{unlock_BB_id_list}
        Wait Until Keyword Succeeds    5min    5s    bbmod Should Be unLocked    bbmod_index=${item}
        Set to dictionary    ${expect_item_status_dict}    BBMOD-${item}=${Cell_enable_status}
    END
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Lock or UnLock Multiple BB
    [Arguments]    ${BBMOD_id_list}   ${lock_flag}=${True}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM    ${timeout}=120
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    FOR  ${BBMOD_id}  IN  @{BBMOD_id_list}
        ${dist_name}    Set Variable    MRBTS-${TL_BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${BBMOD_id}
        Run keyword if    ${lock_flag}==${True}    Log To Console    Lock BBMOD-${BBMOD_id}
        ...    ELSE    Log To Console    UnLock BBMOD-${BBMOD_id}
        Run keyword if    ${lock_flag}==${True}    coam.lock    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
        ...    ELSE    coam.unlock    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
        sleep    2s
    END
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Block Site Via Admin CLI And Check Alarm
    [Arguments]    ${bts_host}    ${username}    ${password}    ${connection}=GNB_OAM
    Log To Console    Start block Station......
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    ...    connection=${connection}
    coam.block    connection=${connection}    timeout=180
    Wait For Expect Fault Present   faultId=${50}   timeout=120
    [Teardown]   run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Unblock Site Via Admin CLI And Check Alarm
    [Arguments]    ${bts_host}    ${username}    ${password}    ${connection}=GNB_OAM
    Log To Console    Start unblock Station......
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    ...    connection=${connection}
    coam.unblock    connection=${connection}    wait_for_reconnection={True}    timeout=360
    Wait For Expect Fault To Disappear    faultId=${50}    timeout=180
    [Teardown]   run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Selenium Update nGRanAccessPointPosition Element
    [Arguments]    ${cell_id}    ${node_index}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=NG RAN access point position    new_value=${1}    node_index=${node_index}    abbr=altitude
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=NG RAN access point position    new_value=${1}    node_index=${node_index}    abbr=degreesOfLatitude
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=NG RAN access point position    new_value=${1}    node_index=${node_index}    abbr=degreesOfLongitude
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=NG RAN access point position    new_value=${1}    node_index=${node_index}    abbr=orientationOfMajorAxis
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=NG RAN access point position    new_value=${1}    node_index=${node_index}    abbr=uncertaintyAltitude
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=NG RAN access point position    new_value=${1}    node_index=${node_index}    abbr=uncertaintySemiMajor
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=NG RAN access point position    new_value=${1}    node_index=${node_index}    abbr=uncertaintySemiMinor

Change allowSlowPrbPoolingStatNdmSrs
    [Arguments]    ${bts_host}    ${ndm_srs}={True}    ${connection}=GNB_OAM
    ${parameter_list}    Create List
    ${parameter_dict}    Create dictionary
    ...    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}
    ...    parameter=allowSlowPrbPoolingStatNdmSrs
    ...    value=${ndm_srs}
    ...    operation=update
    Append to list    ${parameter_list}    ${parameter_dict}
    Modify Parameters with json    bts_host=${bts_host}    input_list=${parameter_list}    connection=GNB_COAM
    [Teardown]   run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Online Change allowSlowPrbPoolingStatNdmSrs For NRBTS
    [Arguments]    ${bts_host}    ${username}    ${password}    ${ndm_srs_flag}    ${connection}=GNB_OAM
    Log To Console    Online Enable allowSlowPrbPoolingStatNdmSrs For NRBTS
    ${allowSlowPrbPoolingStatNdmSrs}    Get allowSlowPrbPoolingStatNdmSrs For NRBTS    bts_host=${bts_host}    username=${username}
    ...    password=${password}    connection=${connection}
    Run Keyword If    ${allowSlowPrbPoolingStatNdmSrs}==${ndm_srs_flag}
    ...    Log To Console    allowSlowPrbPoolingStatNdmSrs is same as ${ndm_srs_flag}, no need to change
    ...    ELSE    Change allowSlowPrbPoolingStatNdmSrs   bts_host=${bts_host}    ndm_srs=${ndm_srs_flag}    connection=${connection}
    ${allowSlowPrbPoolingStatNdmSrs}    Wait Until Keyword Succeeds    300s    15s    Get allowSlowPrbPoolingStatNdmSrs For NRBTS
    ...    bts_host=${bts_host}    username=${username}    password=${password}    connection=${connection}
    Should Be Equal    ${allowSlowPrbPoolingStatNdmSrs}    ${ndm_srs_flag}

Get allowSlowPrbPoolingStatNdmSrs For NRBTS
    [Arguments]    ${bts_host}    ${username}    ${password}    ${connection}=GNB_OAM
    Log To Console    Get allowSlowPrbPoolingStatNdmSrs For NRBTS
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    ...    connection=${connection}
    ${dist_name}    Set Variable    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}
    ${parameter_list}    Create List    allowSlowPrbPoolingStatNdmSrs
    ${srs_ndm_infor}    coam.get_parameter_by_distname    dist_name=${dist_name}    parameter_list=${parameter_list}
    ...    include_children=${False}    connection=${connection}
    ${value}    Set Variable    ${srs_ndm_infor[0]['parameters']['allowSlowPrbPoolingStatNdmSrs']}
    Log To Console    Current allowSlowPrbPoolingStatNdmSrs is: ${value}
    [Return]    ${value}

Online Change smodBoardConfigType To Lock Resource
    [Arguments]    ${bts_host}    ${is_full}=${True}    ${1868_num}=${0}
    ${para_value}    set variable if    ${is_full}    NRTDD    NRFDD_NRTDD
    ${parameter_list}    Create List
    ${parameter_dict}    Create dictionary
    ...    dist_name=MRBTS-${TL_BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/BBCAP-1
    ...    parameter=smodBoardConfigType
    ...    value=${para_value}
    ...    operation=update
    Append to list    ${parameter_list}    ${parameter_dict}
    Modify Parameters with json    bts_host=${bts_host}    input_list=${parameter_list}    connection=GNB_COAM
    Run keyword if    ${is_full}    Check GNB on air And alarm    bts_host=${bts_host}    allowed_list=${Allowed_list}
    ...    ELSE    Wait Until Keyword Succeeds    300s    15s    Check GNB Alarm Num As Expected
    ...    bts_host=${bts_host}    expected_alarm=${1868}    expected_alarm_number=${1868_num}

Check GNB Alarm Num As Expected
    [Arguments]    ${bts_host}    ${expected_alarm}    ${expected_alarm_number}
    Log to console    Check GNB alarm as expected
    ${actual_fault_id_list}    ${history_id_list}    Get Alarm on BTS    bts_host=${bts_host}    connection=alarm_coam
    ${alarm_count}    count values in list    ${actual_fault_id_list}    ${expected_alarm}
    List Should Contain Value    ${actual_fault_id_list}    ${expected_alarm}
    Should be True    ${alarm_count}==${expected_alarm_number}
    Append to list    ${allowed_list}    ${expected_alarm}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${bts_host}
    Remove Values From List    ${allowed_list}    ${expected_alarm}

Make a VoNR call(+6688)
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${during}=90s
    log to console    \n *** Make a VoNR call(+6688)
    ssh.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    ssh.send_command   connection=cygwin${ue_index}
    ...   command=adb -s ${serial_number} shell dumpsys window | grep -E \"mAwake|isStatusBarKeyguard|mShowingLockscreen\"
    sleep   2s
    ${output}   ssh.read_output   connection=cygwin${ue_index}
    Run Keyword If   ${output.lower().count('mawake=false')}>0
    ...    ssh.send_command    command=adb -s ${serial_number} shell input keyevent 82    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    ssh.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=cygwin${ue_index}
    sleep   2s
    #####make VoNR call#####
    ssh.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+6688
    ...    connection=cygwin${ue_index}
    sleep    ${during}

Get All NRCELL DN From BTS
    [Arguments]    ${gnb_index}=${0}    ${connection}=cell_caom
    Connect to gnb coam via ssl    gnb_index=${gnb_index}    connection=${connection}
    ${cellinfo_list}    coam.get_cells_info    cell_type=nr    connection=${connection}
    ${NRCELL_List}    create list
    FOR    ${cell_item}    IN    @{cellinfo_list}
        ${NRCELL_distname}    set variable    ${cell_item}[id][configuration]
        Append to list    ${NRCELL_List}    ${NRCELL_distname}
    END
    Log to console    NRCELL_list: ${NRCELL_List}
    [Return]    ${NRCELL_List}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

UE Attach and check log
    [Arguments]    ${ue_inex}=0    ${pci}=none    ${subcell_num}=${0}    ${srs_cell_num}=${0}
    ${ue_index_list}    Create List    ${ue_inex}
    ${log_time}   Get Current Date   result_format=%Y_%m_%d_%H_%M_%S
    Set Test Variable    ${log_time}
    CB010680_BIP.Start Catch TCPDUMP SCTP Log    filename=ngc_${log_time}.pcap
    CB010680_UE.UE Attach    gnb_index=${0}    ue_index=${ue_inex}
    Start Common Capture BIP log    target_file_name=bip_srs_${log_time}
    Trigger SRS Measurement From LMF   ue_index=${ue_inex}
    Sleep    3s
    ${pcap_log_path_lst}    End Common Capture BIP log and Download    target_dir=${OUTPUT_DIR}/${TEST NAME}    target_file_name=bip_srs_${log_time}
    ${srsConfig}    ${startPrb}    ${prbNum}    Get srsForPositioning For Specfic Cell    bts_host=${gNB_ip}
    ...     username=${gNB_username}    password=${gNB_password}    cell_id=${1}
    CB010680_BIP.Stop And Copy TCPDUMP To UTE    filename=ngc_${log_time}.pcap
    Check BIP Log SRS TOE Is Expected    pcap_log_path=${pcap_log_path_lst[0]}
    ...    srsUePeriodicity=${srsConfig['srsUePeriodicity']}    csrs=${srsConfig['cSRS']}    expected_startPrb=${startPrb}
    ...    pci=${pci}    subcell_num=${subcell_num}    srs_cell_num=${srs_cell_num}
    [Teardown]    UE stop traffic and detach    ue_index_list=${ue_index_list}

modify the parameter case CB010680
    [Arguments]    ${bts_host}    ${username}    ${password}    ${connection}=GNB_OAM    ${input_list}=None
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    ...    connection=${connection}
    Modify Parameters with coam     input_list=${input_list}    connection=${connection}
    [Teardown]   run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Specfic Paramter Setting For TMO IWK From Normal To SupperCell
    [Arguments]    ${nrcell_id}=${1}
    # NRBTS.actFlexibleBISlotDurationMode -> disabled
    # NRCELL.actNrRim->disabled
    # NRCELL.actIncUlPdcchCapacity -> false
    # NRCELL.actBadUplinkRadioRedirect  ->disabled
    # NRCELL.actBadUlRadioHoRej -->disabled
    # NRCELL.actEirpControl -> false
    # delete MO MRBTS-37611/NRBTS-37611/NRCELL-1/NRRIM_PROFILE-1
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}
    ...    filter_param=Activate flexible bidirectional slot duration mode
    ...    new_value=disabled    abbr=actFlexibleBISlotDurationMode

    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${nrcell_id}
    ...    filter_param=Activate NR remote interference management  new_value=disabled    abbr=actNrRim
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${nrcell_id}
    ...    filter_param=Activate PDCCH increased uplink capacity  new_value=false    abbr=actIncUlPdcchCapacity
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${nrcell_id}
    ...    filter_param=Activate bad UL radio based redirection  new_value=disabled    abbr=actBadUplinkRadioRedirect
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${nrcell_id}
    ...    filter_param=Activate HO rejection due to poor UL radio conditions  new_value=disabled    abbr=actBadUlRadioHoRej
    selenium_coam.set_parameter_value    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${nrcell_id}
    ...    filter_param=Activate EIRP control    new_value=false    abbr=actEirpControl

    selenium_coam.remove_element    dist_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${nrcell_id}
    ...    filter_param=List of EIRP control power reduction factor per cell segment    node_index=${0}
    ...    abbr=eirpControlPowerReductionFactorList

    selenium_coam.remove_object    object_name=MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRCELL-${nrcell_id}/NRRIM_PROFILE-1

Check IF NRDRX For Specfic ID Existed
    [Arguments]    ${bts_host}    ${username}    ${password}    ${id}    ${connection}=GNB_OAM
    Log To Console    Get actPRBBlanking For Specfic NRSRX ${id}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    ...    connection=${connection}
    ${dist_name}    Set Variable    MRBTS-${TL_BTS_ID}/NRBTS-${TL_NRBTS_ID}/NRDRX-${id}
    ${parameter_list}    Create List    drxLongCycle
    ${drxLongCycle}    coam.get_parameter_by_distname    dist_name=${dist_name}    parameter_list=${parameter_list}
    ...    include_children=${False}    connection=${connection}
    Log To Console    Current drxLongCycle is: ${drxLongCycle}
    # if MO existed return false, else return true
    ${length}    Get Length    ${drxLongCycle}
    Run Keyword If    ${length}==0    Set Test Variable    ${value}    True
    ...    ELSE    Set Test Variable    ${value}    False
    [Return]    ${value}
