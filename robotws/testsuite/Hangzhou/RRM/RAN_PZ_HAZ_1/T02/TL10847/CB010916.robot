*** Settings ***
Documentation
...    Author: Sun Shuangfeng
...    Contact: Shuangfeng.f.sun@nokia-sbell.com
...    this file is collect some Common KWs of AIC,you can use it in your case directly.
...    Please do not modify the file without notification to author

Suite Setup    Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    700 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot
Resource          ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot

*** Test Cases ***
CB010916_02_Enabling_and_Modifying_Disabling_Antenna_Port_Re-mapping_for_4_Tx_Cell_4T4R
    [Tags]        CRT      CB010916_02
    [Documentation]
    ...    Author: Shuangfeng.f.sun@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    30.01.2024,shuangfeng.f.sun@nokia-sbell.com, draft
    [Setup]    Case Precondition
#    Modify Single Parameter For Multi-MOs By Delta Plan In vDU
#    ...                                                    mo_list=CHANNEL-1,CHANNEL-3,CHANNEL-5,CHANNEL-7
#    ...                                                    parameter=iqStreamId
#    ...                                                    value_list=3,2,0,1
#    ...                                                    operation=replace
#    ...                                                    value=true
#   ${value_list_true}    Set Variable    ${true}
    @{value_list_true1}    Create List    3    2    0    1
    Modify Parameter For Multi-MOs By Delta Plan In vDU    value_list_true=true    value_list_true1=${value_list_true1}
    sleep    600s
    @{value_list_true1}    Create List    1    0    2    3
    Modify Parameter For Multi-MOs By Delta Plan In vDU    value_list_true=true    value_list_true1=${value_list_true1}
    sleep    300s
    BTS Operation  operation=cell_block  product_type=vdu  bts_index=0  distname_id=NRCELL-3  need_verify=yes
    sleep    120s
    BTS Operation  operation=cell_unblock  product_type=vdu  bts_index=0  distname_id=NRCELL-3  need_verify=yes
    sleep    120s
    @{value_list_true1}    Create List    0    2    1    3
    Modify Parameter For Multi-MOs By Delta Plan In vDU    value_list_true=true    value_list_true1=${value_list_true1}
    sleep    300s
    @{value_list_true1}    Create List    1    3    2    0
    Modify Parameter For Multi-MOs By Delta Plan In vDU    value_list_true=false   value_list_true1=${value_list_true1}
    sleep    600s
    BTS Operation  operation=cell_block  product_type=vdu  bts_index=0  distname_id=NRCELL-3  need_verify=yes
    sleep    120s
    BTS Operation  operation=cell_unblock  product_type=vdu  bts_index=0  distname_id=NRCELL-3  need_verify=yes
    sleep    120s
    @{value_list_true1}    Create List    2    0    3    1
    Modify Parameter For Multi-MOs By Delta Plan In vDU    value_list_true=false    value_list_true1=${value_list_true1}
    sleep    300s
    @{value_list_true1}    Create List    0    1    2    3
    Modify Parameter For Multi-MOs By Delta Plan In vDU    value_list_true=true    value_list_true1=${value_list_true1}
    sleep    300s
    [Teardown]    Case Postcondition

*** Keywords ***
Case Precondition
    log to console    Case Precondition
    Common Test Setup For AIC
    ${NEW_PLAN_NAME}   Get Test Case Name
    Set Test Variable  ${NEW_PLAN_NAME}

Case Postcondition
    log to console    Case Postcondition
    Common Test Teardown For AIC

Modify Parameter For Multi-MOs By Delta Plan In vDU
    [Arguments]   ${value_list_true}    ${value_list_true1}
    @{para_list1}          Create List    actAntPortMap    iqStreamId    iqStreamId    iqStreamId    iqStreamId
    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3
    ...                            MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-1
        ...                        MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-3
            ...                    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5
                ...                MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-7
    @{value_list_true0}    Create List    ${value_list_true}    ${value_list_true1}[0]    ${value_list_true1}[1]
    ...                                    ${value_list_true1}[2]    ${value_list_true1}[3]
    ${out}                Parameter Operation    operation=parameter_update    product_type=vdu
    ...                                          para_list=@{para_list1}    value_list=@{value_list_true0}    mo_list=@{mo_list_vdu}
    Log To Console        VDU paramter update result: ${out}

Modify Single Parameter For Multi-MOs By Delta Plan In vDU
    [Arguments]    ${mo_list}    ${parameter}    ${value_list}    ${operation}    ${value}
    ${du_delta_plan_id}    Modify Single Parameter For Single-MO In Delta Plan In vDU    value=${value}
    Modify Single Parameter For Multi-MOs In Delta Plan In vDU
    ...                                                                               delta_plan_id=${du_delta_plan_id}
    ...                                                                               mo_list=${mo_list}
    ...                                                                               operation=${operation}
    ...                                                                               parameter=${parameter}
    ...                                                                               value_list=${value_list}

    Validate And Activate Delta Plan In vDU    delta_plan_id=${du_delta_plan_id}    wait_vdu_up=True

Validate And Activate Delta Plan In vDU
    [Arguments]     ${delta_plan_id}    ${wait_vdu_up}=False
    Log to Console    \n***Start to validate and activate delta plan in vDU***
    vDU Login By Rest
    ${validation_id}    Validate Delta Plan By REST In vDU    plan_id=${delta_plan_id}
    Activate Delta Plan By REST In vDU    plan_id=${delta_plan_id}    wait_vdu_up=${wait_vdu_up}
    #vDU Logout By Rest
    [Teardown]    Run Keyword And Ignore error    vDU Logout By Rest

Modify Single Parameter For Multi-MOs By Delta Plan In vCU
    [Arguments]    ${mo_list}    ${parameter}    ${value_list}

    ${cu_delta_plan_id}    Modify Single Parameter For Multi-MOs In Delta Plan In vCU    mo_list=${mo_list}
    ...                                                                                  parameter=${parameter}
    ...                                                                                  value_list=${value_list}
    Validate And Activate Delta Plan In vCU    delta_plan_id=${cu_delta_plan_id}

Modify Single Parameter For Multi-MOs By Delta Plan In vDU And vCU
    [Arguments]    ${mo_list}    ${parameter}    ${value_list}

    ${cu_delta_plan_id}    Modify Single Parameter For Multi-MOs In Delta Plan In vCU    mo_list=${mo_list}
    ...                                                                                  parameter=${parameter}
    ...                                                                                  value_list=${value_list}
    ${du_delta_plan_id}    Modify Single Parameter For Multi-MOs In Delta Plan In vDU    mo_list=${mo_list}
    ...                                                                                  parameter=${parameter}
    ...                                                                                  value_list=${value_list}
    Validate And Activate Delta Plan In vDU    delta_plan_id=${du_delta_plan_id}
    Check vCU Delta-Plan status
    Validate And Activate Delta Plan In vCU    delta_plan_id=${cu_delta_plan_id}

Modify Single Parameter For Multi-MOs In Delta Plan In vDU
    [Arguments]    ${mo_list}    ${parameter}    ${value_list}    ${delta_plan_id}    ${operation}

    ${du_mo_list}=    Split String    ${mo_list}    ,
    ${du_value_list}=    Split String    ${value_list}    ,
    FOR    ${index}    ${mo}    IN ENUMERATE    @{du_mo_list}
        ${mo_dn}    Set Variable    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/${mo}
        ${value}    Set Variable    ${du_value_list}[${index}]
        log to console    \n***Start to modify ${mo_dn}.${parameter} to ${value} in vDU delta plan.***
        &{parameter_dict}    Create Dictionary   ${parameter}=${value}
        vDU Login By Rest
        Update Parameter By Delta Plan In vDU           plan_id=${delta_plan_id}
        ...                                             mo_dn=${mo_dn}
        ...                                             operation=${operation}
        ...                                             updated_paras_dict=${parameter_dict}
#        &{parameter_dict1}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
#        ...                                                                       mo_parameter_dict=&{parameter_dict}
#        vDU Login By Rest
#        Run Keyword If    &{parameter_dict1} != &{Empty}
#        ...    Update Parameter By Delta Plan In vDU    plan_id=${delta_plan_id}
#        ...                                             mo_dn=${mo_dn}
#        ...                                             updated_paras_dict=${parameter_dict}
        vDU Logout By Rest
    END
    log to console    \n***Successfully modify single parameter for multi-MOs in delta plan in vDU, next to validate and activate.***
    [Teardown]    Run Keyword And Ignore error    vDU Logout By Rest

Modify Single Parameter For Single-MO In Delta Plan In vDU
    [Arguments]   ${parameter}=actAntPortMap    ${value}=true
    ...           ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3
    vDU Login By Rest
    ${delta_plan_name}    get unique id    prefix=TA_delta_plan    precise=LOW
    ${delta_plan_id}    ${action_id}    Generate Delta Plan In vDU    plan_name=${delta_plan_name}    plan_description=TA
    vDU Logout By Rest
    &{parameter_dict}    Create Dictionary   ${parameter}=${value}
    &{parameter_dict1}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
    ...                                                                      mo_parameter_dict=&{parameter_dict}
    vDU Login By Rest

    Run Keyword If    &{parameter_dict1} != &{Empty}
    ...    Update Parameter By Delta Plan In vDU    plan_id=${delta_plan_id}
    ...                                             mo_dn=${mo_dn}
    ...                                             updated_paras_dict=${parameter_dict}
    vDU Logout By Rest
    log to console     \n***Successfully modify single parameter for single-MO in delta plan in vDU.***
    [Return]    ${delta_plan_id}
    [Teardown]    Run Keyword And Ignore error    vDU Logout By Rest

Modify Single Parameter For Multi-MOs In Delta Plan In vCU
    [Arguments]    ${mo_list}    ${parameter}    ${value_list}

    ${cu_mo_list}=    Split String    ${mo_list}    ,
    ${cu_value_list}=    Split String    ${value_list}    ,
    Login To vCU By Rest
    ${delta_plan_name}    get unique id    prefix=TA_delta_plan    precise=LOW
    ${delta_plan_id}    Generate Delta Plan In vCU
    Logout To vCU By Rest
    FOR    ${index}    ${mo}    IN ENUMERATE    @{cu_mo_list}
        ${mo_dn}    Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/${mo}
        ${value}    Set Variable    ${cu_value_list}[${index}]
        log to console    \n***Start to modify ${mo_dn}.${parameter} to ${value} in vCU delta plan.***
        &{vcu_param}    create dictionary    operation_type=replace    parameter_path=/${parameter}
        ...                                                                     value=${value}
        @{updated_vcu_param}    Create List    ${vcu_param}
        ${para_value}=    Get Parameters Of Current Plan Via Rest    parameter_name=${parameter}
        ...                                                          mo_dn=${mo_dn}
        Run Keyword If    "${para_value}"!="${value}"
            ...    Online Update Single Mo Parameters Via Rest In vCU    para_list=${updated_vcu_param}
            ...                                                          mo_dn=${mo_dn}
            ...                                                          delta_plan_id=${delta_plan_id}
        Logout To vCU By Rest
    END

    log to console    \n***Successfully modify single parameter for multi-MOs in delta plan in vCU, next to validate and activate.***
    [Return]    ${delta_plan_id}
    [Teardown]    Run Keyword And Ignore error    Logout To vCU By Rest

Modify Parameters By Delta Plan
    [Arguments]   ${ne}=vDU    ${parameter}=actAntPortMap    ${value}=true
    ...           ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3
    Run Keyword If    '${ne}'=='vDU'    Modify Parameters By Delta Plan In vDU    parameter=${parameter}
    ...                                                                           value=${value}
    ...                                                                           mo_dn=${mo_dn}
    ...            ELSE IF   '${ne}'=='vCU'    Modify Parameters By Delta Plan In vCU    parameter=${parameter}
    ...                                                                                  value=${value}
    ...                                                                                  mo_dn=${mo_dn}
    ...            ELSE IF   '${ne}'=='all'    Modify Parameters By Delta Plan In vCU And vDU    parameter=${parameter}
    ...                                                                                   value=${value}
    ...                                                                                   mo_dn=${mo_dn}

Modify Parameters By Delta Plan In vDU
    [Arguments]   ${parameter}=actCDrx    ${value}=true    ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3
    &{parameter_dict}    Create Dictionary   ${parameter}=${value}
    &{parameter_dict1}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
    ...                                                                      mo_parameter_dict=&{parameter_dict}
    vDU Login By Rest
    Run Keyword If    &{parameter_dict1} != &{Empty}    VDU Online Modify Parameters By Delta Plan REST
    ...                                          mo_dn=${mo_dn}
    ...                                          updated_paras_list=${parameter_dict}
    ...                                          operation=replace
    ...                                          activate=${True}
    ...                                          force_reset=${False}
    ...                                          auto_lock_cells=${False}
    ...                                          wait_vdu_up=${False}
    vDU Logout By Rest
    [Teardown]    Run Keyword And Ignore error    vDU Logout By Rest

Modify Parameters By Delta Plan In vCU
    [Arguments]   ${parameter}=actCDrx    ${value}=true    ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    &{vcu_param}    create dictionary    operation_type=replace    parameter_path=/${parameter}
    ...                                                                         value=${value}
    @{updated_vcu_param}    Create List    ${vcu_param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=${parameter}
    ...                                                   updated_paras_dict=${updated_vcu_param}
    ...                                                   compare_value=${value}
    ...                                                   mo_dn=${mo_dn}

Modify Parameters By Delta Plan In vCU And vDU
    [Arguments]   ${parameter}=actCDrx    ${value}=true    ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    &{vcu_param}    create dictionary    operation_type=replace    parameter_path=/${parameter}
    ...                                                                         value=${value}
    @{updated_vcu_param}    Create List    ${vcu_param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=${parameter}
    ...                                                   updated_paras_dict=${updated_vcu_param}
    ...                                                   compare_value=${value}
    ...                                                   mo_dn=${mo_dn}
    &{parameter_dict}    Create Dictionary   ${parameter}=${value}
    &{parameter_dict1}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
    ...                                                                      mo_parameter_dict=&{parameter_dict}
    vDU Login By Rest
    Run Keyword If  &{parameter_dict1} != &{Empty}
    ...             VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
    ...                                          updated_paras_list=${parameter_dict}
    ...                                          operation=replace
    ...                                          activate=${True}
    ...                                          force_reset=${False}
    ...                                          auto_lock_cells=${False}
    ...                                          wait_vdu_up=${False}
    vDU Logout By Rest

Get DL Call Avg Tput
    [Arguments]    ${ue_index}=${0}    ${period}=10s
    ${dl_tp}    ${ul_tp}    Get Average Throughput    ue_index=${ue_index}    period=${period}
    ${avg_dl_tput}    Evaluate    ${dl_tp}/1048576
    [Return]    ${avg_dl_tput}

Start DL traffic by index
    [Arguments]    ${ue_index}=${0}
    Start traffic    ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    direction=dl   dt_index=${0}
    ...              throughput=10M    duration=${600}

Prepare UE as M80
    [Arguments]    ${ue_index}=${1}
    Log to Console    \n***Prepare M80***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
    Log to Console    \n***Prepare UE***
    Prepare UE    ${ue_type}    ue_index=${ue_index}    ui_version=default
    Log to Console    \n***UE Prepared...***
    [Return]     ${ue_${ue_index}_type}

Attach UE as M80
    [Arguments]    ${ue_index}=${1}
    Log to Console    \n***M80 attach***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
    UE Attach    ${ue_type}    ue_index=${ue_index}    verify_attach=True
    Log to Console    \n***UE Attached...***

Prepare And Attach UE
    [Arguments]    ${ue_index}=${0}    ${ui_version}=default
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
    Log to Console    \n***Prepare UE***
    Prepare UE    ${ue_${ue_index}_type}    ue_index=${ue_index}    ui_version=${ui_version}
    UE Attach    ${ue_${ue_index}_type}    ue_index=${ue_index}    verify_attach=True
    [Return]     ${ue_${ue_index}_type}

Start Call For UE
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}    ${direction}=dl
    Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=${direction}    dt_index=${ue_index}
    ...              throughput=110M    duration=${600}

Lock Cell From vDU
    [Arguments]    ${cell_id}=1
    ${cell_id_list}    Run Keyword If    '${cell_id}'=='all'    Get Cell ID List    vdu_index=0    gnb_index=0
    ...                ELSE    Create List    ${cell_id}
    Lock Cell In vDU    cell_id_list=${cell_id_list}

Unlock Cell From vDU
    [Arguments]    ${cell_id}=1
    ${cell_id_list}    Run Keyword If    '${cell_id}'=='all'    Get Cell ID List    vdu_index=0    gnb_index=0
    ...                ELSE    Create List    ${cell_id}
    Unlock Cell In vDU    cell_id_list=${cell_id_list}

Detach UE
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_${ue_index}_type}
    UE Detach    ${ue_type}    ue_index=${ue_index}
    sleep    60s    reason=wait detach UE Successfully

