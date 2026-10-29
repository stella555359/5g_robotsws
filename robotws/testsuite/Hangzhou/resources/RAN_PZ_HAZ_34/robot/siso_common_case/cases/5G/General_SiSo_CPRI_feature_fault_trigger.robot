*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
*** Variables ***

*** Keywords ***
General_SiSo_CPRI_feature_fault_trigger
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify Power Saving percentage measured in Idle Load
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 12.05.2023 - - Created
    ...    - 30.08.2023 - - Modified by https://jiradc.ext.net.nokia.com/browse/WESTLAKE-7965
    ...    - 20.05.2024 - - Modified by Fan Kaihui: https://jiradc.ext.net.nokia.com/browse/LEOPARD-1989
    ...    need more than one ru
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    add fault to the history allowed fault list    faultId=${4677}
    Selenium Login And Disable Screen Lock
    disable cpri timing offset
    # Disable BbPool Parameters
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
    ...    ru_1_frameStartOffset=${3000}    ru_2_frameStartOffset=${2302.34}
    ...    ru_1_sfnOffset=${0}    ru_2_sfnOffset=${0}
    Modify Parameters On Webem  modify_params=${modify_params}
    log to console  \n Wait For Fault 4677 Present
    Wait until keyword succeeds    5min    10s    Expect Fault Should Present    faultId=${4677}
    sleep    1min
    Check Cell Info with Fault    faultId=${4677}
    ${modify_params}    Get frame start offest modify parameters list with different value
    ...    ru_1_frameStartOffset=${2302.34}    ru_2_frameStartOffset=${2302.34}
    ...    ru_1_sfnOffset=${0}    ru_2_sfnOffset=${0}
    Modify Parameters On Webem  modify_params=${modify_params}
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    [Teardown]    Run keywords    disable cpri timing offset    AND    Selenium Logout And Close Browser

disable cpri timing offset
    [Arguments]    ${cell_type}=nr
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate CPRI-N cell timing offset    abbr=actCellTimingOffsetCpriN    new_value=false
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}

Disable BbPool Parameters
    [Arguments]  ${actBbPoolExtensionTddFr1}=false  ${actBbPoolTddFr1}=false
    ...   ${actBbPoolTddFr1AlgEnh}=false  ${actBbPoolTddFr1Enh}=false
    log to console  \n change to actBbPoolExtensionTddFr1:${actBbPoolExtensionTddFr1};actBbPoolTddFr1:${actBbPoolTddFr1}
    log to console  \n actBbPoolTddFr1AlgEnh:${actBbPoolTddFr1AlgEnh};actBbPoolTddFr1Enh:${actBbPoolTddFr1Enh}
    ${modify_params}  Get BbPool Parameters  ${actBbPoolExtensionTddFr1}  ${actBbPoolTddFr1}  ${actBbPoolTddFr1AlgEnh}  ${actBbPoolTddFr1Enh}
    Modify Parameters On Webem  modify_params=${modify_params}
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}

Get BbPool Parameters
    [Arguments]  ${actBbPoolExtensionTddFr1}=false  ${actBbPoolTddFr1}=false
    ...   ${actBbPoolTddFr1AlgEnh}=false  ${actBbPoolTddFr1Enh}=false
    ${modify_params}    create list
    ${item_BbPoolExtension}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    ...    filter_param=Activate baseband resource pooling FR1 TDD extension  p_name=actBbPoolExtensionTddFr1  value=${actBbPoolExtensionTddFr1}
    ${item_BbPool}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    ...    filter_param=Activate baseband resource pooling FR1 TDD    p_name=actBbPoolTddFr1    value=${actBbPoolTddFr1}
    ${item_BbPoolAlgEnh}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    ...    filter_param=Activate enhanced algorithm of baseband resource pooling FR1 TDD
    ...   p_name=actBbPoolTddFr1AlgEnh  value=${actBbPoolTddFr1AlgEnh}
    ${item_BbPoolEnh}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    ...    filter_param=Activate baseband resource pooling FR1 TDD enhancements    p_name=actBbPoolTddFr1Enh    value=${actBbPoolTddFr1Enh}
    append to list  ${modify_params}  ${item_BbPoolExtension}
    append to list  ${modify_params}  ${item_BbPool}
    append to list  ${modify_params}  ${item_BbPoolAlgEnh}
    append to list  ${modify_params}  ${item_BbPoolEnh}
    [Return]  ${modify_params}

Get frame start offest modify parameters list with different value
    [Arguments]    ${cell_type}=nr    ${ru_1_frameStartOffset}=${3000}    ${ru_2_frameStartOffset}=${4000}
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
    ${cell_id_list_with_ru_2_lte}    Get All Cell Id   ru_index=${ru_index_list[1]}    cell_type=lte
    ${modify_params_3}    Get CPRI offest modify parameters list    cell_id_list=${cell_id_list_with_ru_2_lte}
    ...    frameStartOffset=${ru_2_frameStartOffset}    sfnOffset=${ru_2_sfnOffset}    cell_type=lte
    ${modify_params}    combine lists    ${modify_params}     ${modify_params_3}
    [Return]  ${modify_params}

Check Cell Info with Fault
    [Arguments]    ${faultId}    ${connection}=GNB_OAM    ${cell_type}=nr    ${timeout}=60
    @{alarms}    coam.get_active_alarms    connection=${connection}
    ${with_fault_cells}    create list
    FOR    ${alarm}    IN    @{alarms}
        ${id}    get from dictionary    ${alarm}    faultId
        continue for loop if    '${id}'!='${faultId}'
        ${configObjectName}    get from dictionary    ${alarm}    configObjectName
        ${get_list}    get regexp matches    ${configObjectName}    NRCELL-(.)    1
        ${cell_id}    convert to integer    ${get_list[0]}
        append to list    ${with_fault_cells}    ${cell_id}
    END
    ${cell_list}    get all cell id
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    Run Keyword And Return Status    Should Contain Any    ${sw_version}    12.400    14.400    22R1    22R2    21B
    ${disabled}    Set Variable If    ${result}    Disabled    disabled
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        ${cellID}    Set Variable    ${item['id']['configuration'].split('-')[-1]}
        Set To Dictionary    ${cell_list_info}    ${cellID}=${item['status']}
    END
    remove values from list    ${cell_list}    @{with_fault_cells}
    FOR    ${cell_id}    IN    @{with_fault_cells}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell_id}']['operationalState']}    ${disabled}
    END
    FOR    ${cell_id}    IN    @{cell_list}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell_id}']['operationalState']}    ${enabled}
    END
