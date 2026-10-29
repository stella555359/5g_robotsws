*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/site_prepare.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/scf_comm_operation.robot

*** Variables ***

*** Keywords ***
General_Micro-DTx_activate_with_traffic_concentration_and_CRG_activate_together
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The user scenario describes existing and new feature NIDD parameter setting to enable micro-Dtx
    ...    and propagation to U-Plane components during startup
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 11.04.2020 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]    ${ru_index}=1    ${with_call}=${True}   ${dl_tp}=205    ${ul_tp}=26
    ...    ${target_avg_percent}=0.85    ${min_percent}=0.75
    ${flag}    run keyword and return status    Should contain    ${TEST_TAGS}[0]    S-
    ${SCF_Path}    run keyword if    ${flag}      Replace String    ${Golden_SCF_Path}    .xml    _${TEST_TAGS}[0].xml
        ...           ELSE    set variable     ${Golden_SCF_Path}
    run keyword if    ${flag}      Commissioning SCF And Check On Air for Common    scf_path=${SCF_Path}
    ${cell_id_list}  Get All Cell Id  cell_type=${cell_type}
    log to console   \n get Power Measurement
    ${power_meassure_1}  Get RMOD Power Measurement  ru_index=${ru_index}
    log to console   \n enable actMicroDtx
    ${modify_params}  Get actMicroDTX modify parameters list  cell_id_list=${cell_id_list}  new_value=true
    Modify Parameters On Webem  modify_params=${modify_params}
    sleep  30
    log to console   \n enable CRG
    ${modify_crgpr}  generate crgpr parameter list
    Active CRGPR via Webem  cell_id_list=${cell_id_list}  modify_crgpr=${modify_crgpr}
    sleep  30
    log to console   \n get Power Measurement
    ${power_meassure_2}  Get RMOD Power Measurement  ru_index=${ru_index}
    log to console   \n UE peak call
    run keyword if  ${with_call}    Simple UE L3 Call And Throughput    cell_list=${cell_id_list}     dl_tp=${dl_tp}
    ...    ul_tp=${ul_tp}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    scf_path=${SCF_Path}
    log to console   \n enable traffic
    ${modify_params}  Get Trafficconcentration modify parameters list  cell_id_list=${cell_id_list}  new_value=true
    Modify Parameters On Webem  modify_params=${modify_params}
    sleep  30
    log to console   \n get Power Measurement
    ${power_meassure_3}  Get RMOD Power Measurement  ru_index=${ru_index}
    log to console   \n UE peak call
    run keyword if  ${with_call}    Simple UE L3 Call And Throughput    cell_list=${cell_id_list}     dl_tp=${dl_tp}
    ...    ul_tp=${ul_tp}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    scf_path=${SCF_Path}
    log to console   \n enable ETWS
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}
    ...     filter_param=Activation ETWS support    abbr=actETWS    new_value=true
    sleep  30
    log to console   \n get Power Measurement
    ${power_meassure_4}  Get RMOD Power Measurement  ru_index=${ru_index}
    log to console   \n UE peak call
    run keyword if  ${with_call}    Simple UE L3 Call And Throughput    cell_list=${cell_id_list}     dl_tp=${dl_tp}
    ...    ul_tp=${ul_tp}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    scf_path=${SCF_Path}
    log to console   \n disable ETWS
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}
    ...     filter_param=Activation ETWS support    abbr=actETWS    new_value=false
    sleep  30
    log to console   \n enable CMAS
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}
    ...     filter_param=Activation CMAS support    abbr=actCMAS    new_value=true
    sleep  30
    ${power_meassure_5}  Get RMOD Power Measurement  ru_index=${ru_index}
    run keyword if  ${with_call}    Simple UE L3 Call And Throughput    cell_list=${cell_id_list}     dl_tp=${dl_tp}
    ...    ul_tp=${ul_tp}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    scf_path=${SCF_Path}

generate crgpr parameter list
    ${modify_crgpr}  create list
    ${item}  create dictionary  groupId=${1}  groupShare=${50}    mcc=${505}  mnc=${2}  mncLength=${2}
    append to list  ${modify_crgpr}  ${item}
    ${item}  create dictionary  groupId=${2}  groupShare=${50}    mcc=${262}  mnc=${3}  mncLength=${2}
    append to list  ${modify_crgpr}  ${item}
    [Return]  ${modify_crgpr}
