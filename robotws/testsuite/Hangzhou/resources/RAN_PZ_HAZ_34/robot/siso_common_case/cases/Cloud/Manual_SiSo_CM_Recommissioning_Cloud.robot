*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_ru.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vcu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_bts.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_throughput.robot

*** Keywords ***
Manual_SiSo_CM_Recommissioning
    [Documentation]    *****************
    ...    - [TEST PURPOSE] The purpose of this test is to verify that BTS can be recommissioned by WebEM correctly.
    ...    Commissioning is done using WebEM and previously created SCF.
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...        1. Get Nrarfcn Value
    ...        2. Recommission the SCF via Modify Parameter
    ...        3. Check all Cells Should Be Onair and L3call
    ...        4. Recovery original value    
    ...        5. Check all Cells Should Be Onair and L3call
    ...    - [EXPECTED RESULTS] The BTS can be recommissioned by WebEM correctly.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | vdu_index | No | The vDU index. Default value is 0. |
    ...    | gnb_index | No | The gNB index. Default value is 0. |
    ...    | nrarfcn_step  | No | The nrarfcn one step value. Default value is int 2. |
    ...    | with_call | No | Flag for l3call. Default value is True. |
    ...    | suite_name | No | The suite name used for customed peak rate. Default value is default. |
    ...    | test_name | No | The test name used for customed peak rate. Default value is default. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 05.06.2024  - Created
    ...    *******************
    ...    * Owner_jiayi.tang@nokia-sbell.com
    ...    * Group: VRF_HAZ3_T02
    ...    *******************
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${with_call}=${True}    ${nrarfcn_step}=${2}    ${suite_name}=default    ${test_name}=default
    ${cell_list}    Cloud Get Cells Id List    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${nrarfcn_value_modified}    Get Nrarfcn Value    vdu_index=${vdu_index}    gnb_index=${gnb_index}    nrarfcn_step=${nrarfcn_step}
    log to console    Recommission the SCF via modify nrarfcn value to add 2 to this value
    ${original_value}    Recommission the SCF via Modify Parameter    modified_value=${nrarfcn_value_modified}
    ...    vdu_index=${vdu_index}    gnb_index=${gnb_index}    cell_index=${cell_list}[0]
    log to console    All Cells Should Be Onair and L3call
    Check Cell Onair and L3call    with_call=${with_call}    suite_name=${suite_name}   test_name=${test_name}
    ...    test_name=${test_name}    suite_name=${suite_name}
    log to console    Recovery original value
    Recovery original value    ${original_value}
    log to console    All Cells Should Be Onair and L3call
    Check Cell Onair and L3call    with_call=${with_call}    suite_name=${suite_name}   test_name=${test_name}

Recommission the SCF via Modify Parameter
    [Arguments]   ${modified_value}    ${vdu_index}=0    ${gnb_index}=0    ${cell_index}=1
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    ${delta_data_list}=    Evaluate    [['MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}', {'nrarfcn':'${modified_value}', }, 'replace']] 
    ${original_value}    vdu_cm_business.delta_commission_step_by_step
    ...      delta_data_list=${delta_data_list}    delta_plan_name='DELTA-PLAN-1'    conn_alias=${conn_alias}
    [Return]    ${original_value}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Recovery original value
    [Arguments]   ${original_value}    ${vdu_index}=0    ${gnb_index}=0    
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    vdu_cm_business.delta_commission_step_by_step   delta_data_list=${original_value}    delta_plan_name='DELTA-PLAN-1'
    ...    conn_alias=${conn_alias}
    [Return]    ${original_value}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Get Nrarfcn Value
    [Arguments]   ${vdu_index}=0    ${gnb_index}=0    ${nrarfcn_step}=${2}
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    ${nrarfcn_value_org}    vdu.search_parameter_of_current_plan    mo_dn=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
    ...    para_name=nrarfcn    vdu_connection=${conn_alias}
    ${nrarfcn_value_org}    Evaluate    int(${nrarfcn_value_org})
    ${nrarfcn_value_modified}    Evaluate    ${nrarfcn_value_org} + ${nrarfcn_step}
    ${nrarfcn_value_modified}    Evaluate    str(${nrarfcn_value_modified})
    [Return]    ${nrarfcn_value_modified}    
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}
    
Check Cell Onair and L3call
    [Arguments]    ${with_call}=${True}    ${suite_name}=default    ${test_name}=default
    Wait Until Keyword Succeeds    15min    5s    All Cells Should Be Onair For All vDUs
    log to console    check cell status should be on air for cu...
    Wait Until Keyword Succeeds     5min    30s    All Cells Should Be Onair For One Specific vCU
    Run Keyword If    ${with_call}    Cloud UE L3 Call And Throughput    cell_list=${cell_index_list}
    ...    suite_name=${suite_name}   test_name=${test_name}
