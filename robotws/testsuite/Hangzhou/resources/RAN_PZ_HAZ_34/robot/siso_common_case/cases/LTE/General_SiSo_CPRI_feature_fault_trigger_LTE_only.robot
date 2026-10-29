*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/scf_comm_operation.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/coam.robot

*** Variables ***

*** Keywords ***
General_SiSo_CPRI_feature_fault_trigger_LTE_only
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify Power Saving percentage measured in Idle Load
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 12.05.2023 - - Created
    ...    - 30.08.2023 - - Modified by https://jiradc.ext.net.nokia.com/browse/WESTLAKE-7965
    ...    need more than one ru
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    add fault to the history allowed fault list    faultId=${4677}
    ${flag}    run keyword and return status    Should contain    ${TEST_TAGS}[0]    S-
    ${SCF_Path}    run keyword if    ${flag}      Replace String    ${Golden_SCF_Path}    .xml    _${TEST_TAGS}[0].xml
        ...           ELSE    set variable     ${Golden_SCF_Path}
    run keyword if    ${flag}      Commissioning SCF And Check On Air for Common    scf_path=${SCF_Path}
    ${origin_params}    format cpri timing offset
    ${modify_params}    Get frame start offest modify parameters list with different value
    ...    ru_1_frameStartOffset=${3000}    ru_2_frameStartOffset=${4000}
    ...    ru_1_sfnOffset=${0}    ru_2_sfnOffset=${0}
    Modify Parameters On Webem  modify_params=${modify_params}
    log to console  \n Wait For Fault 4677 Present
    Wait until keyword succeeds    5min    10s    Expect Fault Should Present    faultId=${4677}
    sleep    1min
    Check Cell Info with Fault    faultId=${4677}
    ${modify_params}    Get frame start offest modify parameters list with different value
    ...    ru_1_frameStartOffset=${3000}    ru_2_frameStartOffset=${3000}
    ...    ru_1_sfnOffset=${0}    ru_2_sfnOffset=${0}
    Modify Parameters On Webem  modify_params=${modify_params}
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    ${modify_params}    Get frame start offest modify parameters list with different value
    ...    ru_1_frameStartOffset=${3000}    ru_2_frameStartOffset=${9302.34}
    ...    ru_1_sfnOffset=${0}    ru_2_sfnOffset=${-1}
    Modify Parameters On Webem  modify_params=${modify_params}
    log to console  \n Wait For Fault 4677 Present
    Wait until keyword succeeds    5min    10s    Expect Fault Should Present    faultId=${4677}
    sleep    1min
    Check Cell Info with Fault    faultId=${4677}
    ${modify_params}    Get frame start offest modify parameters list with different value
    ...    ru_1_frameStartOffset=${9302.34}    ru_2_frameStartOffset=${9302.34}
    ...    ru_1_sfnOffset=${-1}    ru_2_sfnOffset=${-1}
    Modify Parameters On Webem  modify_params=${modify_params}
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    [Teardown]    run keywords    Modify Parameters On Webem  modify_params=${origin_params}    AND
    ...    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}

format cpri timing offset
    [Arguments]    ${cell_type}=lte
    ${modify_params}  create list
    ${item}    create dictionary    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate CPRI-N cell timing offset    p_name=actCellTimingOffsetCpriN    value=false
    append to list  ${modify_params}  ${item}
    ${item}    create dictionary    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/BBCAP-1
    ...    filter_param=SMOD board configuration type    p_name=smodBoardConfigType    value=LTETDD_NRTDD
    append to list  ${modify_params}  ${item}
    ${origin_params}    generate origion parameters    modify_params=${modify_params}
    Modify Parameters On Webem  modify_params=${modify_params}
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    [Return]  ${origin_params}

Get frame start offest modify parameters list with different value
    [Arguments]    ${cell_type}=lte    ${ru_1_frameStartOffset}=${3000}    ${ru_2_frameStartOffset}=${4000}
    ...   ${ru_1_sfnOffset}=${0}   ${ru_2_sfnOffset}=${0}
    ${ru_index_list}    get all ru index
    ${modify_params}    create list
    ${cell_id_list_with_ru_1}    Get All Cell Id   ru_index=${ru_index_list[0]}    cell_type=${cell_type}
    ${modify_params_1}    Get CPRI offest modify parameters list    cell_id_list=${cell_id_list_with_ru_1}
    ...    frameStartOffset=${ru_1_frameStartOffset}    sfnOffset=${ru_1_sfnOffset}    cell_type=${cell_type}
    ${modify_params}    combine lists    ${modify_params}    ${modify_params_1}
    ${cell_id_list_with_ru_2}    Get All Cell Id   ru_index=${ru_index_list[1]}    cell_type=${cell_type}
    ${modify_params_2}    Get CPRI offest modify parameters list    cell_id_list=${cell_id_list_with_ru_2}
    ...    frameStartOffset=${ru_2_frameStartOffset}    sfnOffset=${ru_2_sfnOffset}    cell_type=${cell_type}
    ${modify_params}    combine lists    ${modify_params}     ${modify_params_2}
    [Return]  ${modify_params}

Check Cell Info with Fault
    [Arguments]    ${faultId}    ${connection}=GNB_OAM    ${cell_type}=lte
    @{alarms}    coam.get_active_alarms    connection=${connection}
    ${with_fault_cells}    create list
    FOR    ${alarm}    IN    @{alarms}
        ${id}    get from dictionary    ${alarm}    faultId
        continue for loop if    '${id}'!='${faultId}'
        ${configObjectName}    get from dictionary    ${alarm}    configObjectName
        ${get_list}    get regexp matches    ${configObjectName}    LNCEL-(.)    1
        ${cell_id}    convert to integer    ${get_list[0]}
        append to list    ${with_fault_cells}    ${cell_id}
    END
    ${cell_list}    get all cell id    cell_type=${cell_type}
    remove values from list    ${cell_list}    @{with_fault_cells}
    FOR    ${cell_id}    IN    @{with_fault_cells}
        ${cell_info_dict}    Get All SBTS Cells Status Info classified by cellidx    cell_type=${cell_type}    connection=${connection}
        should be equal as strings    ${cell_info_dict[${cell_id}]['operationalState'].lower()}    disabled
    END
    FOR    ${cell_id}    IN    @{cell_list}
        ${cell_info_dict}    Get All SBTS Cells Status Info classified by cellidx    cell_type=${cell_type}    connection=${connection}
        should be equal as strings    ${cell_info_dict[${cell_id}]['operationalState'].lower()}    enabled
    END
