*** Settings ***
Documentation
...    Author: sudi Lou
...    Contact: sudi.lou@nokia-sbell.com

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1

Resource    ./Resource_CB015045.robot
Resource    ../../Resources/Cloud/AIC_Common_Resource.robot

Suite Setup    Run keywords    Common Suite Setup For AIC
...            AND    Config network For Local Env_250
Suite Teardown    Run keywords     Common Suite Teardown For AIC

*** Variables ***
${log_type}    syslog+emil
${SA_UE_ID}    1
${TC25_vdu_delta_file}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB015045/TC25_vDU_Delta_Configuration.json
${TC25_vcu_delta_file}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB015045/TC25_vCU_Delta_Configuration.json
${TC25_recovery_vdu}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB015045/TC25_recovery_vDU.json
${TC25_recovery_vcu}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB015045/TC25_recovery_vCU.json
${TC23_vdu_delta_file}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB015045/TC23_vDU_Delta_Configuration.json
${TC23_vcu_delta_file}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB015045/TC23_vCU_Delta_Configuration.json
${TC23_recovery_vdu}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB015045/TC23_recovery_vDU.json
${TC23_recovery_vcu}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB015045/TC23_recovery_vCU.json
${TC23_B1_related}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB015045/TC23_B1_related_vCU.json

*** Test Cases ***
CB015045_A_CR_25_B1_EPS_fallback_during_Initial_Context_Setup
    [Tags]    QC_238847    TC25
    [Documentation]
    ...    Author: sudi.lou@nokia-sbell.com
    [Setup]    Case Precondition
    start_log_collection    log_type=${log_type}    product_type=vcu
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=vdu
    ...                                      delta_file_path=${TC25_vdu_delta_file}
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=vcu
    ...                                      delta_file_path=${TC25_vcu_delta_file}
    Trigger EPS Fallback during Initial Context Setup    ue_id=${SA_UE_ID}    cell_id=1
    ...    5qi5_qos_flow=1  5qi1_qos_flow=3
    Sleep    1s    reason=wait for the UE to register and trigger EPS fallback
    ${local_file_path}  Log Collection  stop_and_download  ${log_type}  product_type=vcu  bts_index=${0}
    Check EPS Fallback Related Messages    ${local_file_path}
    [Teardown]    Case Postcondition For TC25

CB015045_A_CR_26_B4_Online_modification_of_Feature_Activation_Flag
#CB015045_A_CR_27_B4_ALT1_Online_modification_of_Feature_Activation_Flag_during_PDU_Session_Setup
    [Tags]    QC_238848    TC26
#    [Tags]    TC27    CRT
    [Documentation]
    ...    Author: sudi.lou@nokia-sbell.com
    [Setup]    Case Precondition
    start_log_collection    log_type=${log_type}    product_type=vcu
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=vdu
    ...                                      delta_file_path=${TC25_vdu_delta_file}
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=vcu
    ...                                      delta_file_path=${TC25_vcu_delta_file}
    @{para_list}          Create List    causeOfRelInVoiceFallback
    @{mo_list}        Create List    MRBTS-11073/NRBTS-11073
    @{value_list}    Create List    redirection
    ${out}                Parameter Operation    operation=parameter_update    product_type=vcu
    ...                                          para_list=@{para_list}    value_list=@{value_list}    mo_list=@{mo_list}
    Trigger EPS Fallback during Initial Context Setup    ue_id=${SA_UE_ID}    cell_id=1
    ...    5qi5_qos_flow=1  5qi1_qos_flow=3
#    ${ue_id_list}  Evaluate  list(range(1, 2))    # for TC27
#    Trigger EPS Fallback during PDU Session Setup for Multi UEs with Normal Voice Call    @{ue_id_list}    cell_id=1    # for TC27
#    ...    default_qos_flow=2    5qi5_qos_flow=1  5qi1_qos_flow=3
    Sleep    1s    reason=wait for the UE to register and trigger EPS fallback
    ute_wtssim.Execute Egate Command    cmd=ue_deregister id=${SA_UE_ID} ue_deregister_type=switch_off by=ue
    @{value_list_change}    Create List    fallback
    ${out}                Parameter Operation    operation=parameter_update    product_type=vcu
    ...                                          para_list=@{para_list}    value_list=@{value_list_change}    mo_list=@{mo_list}
    Trigger EPS Fallback during Initial Context Setup    ue_id=${SA_UE_ID}    cell_id=1
    ...    5qi5_qos_flow=1  5qi1_qos_flow=3
#    ${ue_id_list}  Evaluate  list(range(1, 2))    # for TC27
#    Trigger EPS Fallback during PDU Session Setup for Multi UEs with Normal Voice Call    @{ue_id_list}    cell_id=1    # for TC27
#    ...    default_qos_flow=2    5qi5_qos_flow=1  5qi1_qos_flow=3
    Sleep    1s    reason=wait for the UE to register and trigger EPS fallback
    ${local_file_path}  Log Collection  stop_and_download  ${log_type}  product_type=vcu  bts_index=${0}
    Check EPS Fallback Related Messages    ${local_file_path}
    [Teardown]    Case Postcondition for TC25

CB015045_A_CR_23_PM_counters_for_EPS_fallback_due_to_CU-CP_RAC_failure
#EPS_fallback_due_to_VoNR_disabled_in_gNB_during_PDU_session_modify
    [Documentation]
    ...    author: Sudi Lou
    [Tags]    TC23    NFTA
#    [Tags]    knife_test
    [Setup]    Case Precondition
    Log To Console    \nstart test
    start_log_collection    log_type=${log_type}    product_type=vcu
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=vdu
    ...                                      delta_file_path=${TC23_vdu_delta_file}
#    ...                                      delta_file_path=${TC25_vdu_delta_file}    #for knife test
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=vcu
    ...                                      delta_file_path=${TC23_vcu_delta_file}
#    ...                                      delta_file_path=${TC25_vcu_delta_file}    #for knife test

    log to console  \nTrigger EPS Fallback during Initial Context Setup for a Normal Voice Call
    Trigger EPS Fallback during Initial Context Setup    ue_id=${SA_UE_ID}    cell_id=1
    ...    5qi5_qos_flow=1  5qi1_qos_flow=3
    Sleep    1s    reason=wait for the UE to trigger EPS fallback
    ute_wtssim.Execute Egate Command    cmd=ue_deregister id=${SA_UE_ID} ue_deregister_type=switch_off by=ue

    log to console  \nTrigger EPS Fallback during PDU Session Setup for Multi UEs with Normal Voice Call
    ${ue_id_list}  Evaluate  list(range(1, 2))
    Trigger EPS Fallback during PDU Session Setup    @{ue_id_list}    cell_id=1
    ...    default_qos_flow=2    5qi5_qos_flow=1  5qi1_qos_flow=3
    Sleep    1s    reason=wait for the UE to trigger EPS fallback
    ute_wtssim.Execute Egate Command    cmd=ue_deregister id=${SA_UE_ID} ue_deregister_type=switch_off by=ue

    ${out}            Parameter Operation    operation=delta_plan_update   product_type=vcu
    ...                                      delta_file_path=${TC23_B1_related}
    log to console  \nTrigger EPS Fallback during PDU Session modify for Multi UEs with Normal Voice Call
    ${ue_id_list}  Evaluate  list(range(1, 2))
    Trigger EPS Fallback during PDU Session Modify Based B1 Measurement    @{ue_id_list}    cell_id=1
    ...    default_qos_flow=2    5qi5_qos_flow=1  5qi1_qos_flow=3
    Sleep    1s    reason=wait for the UE to trigger EPS fallback
    ute_wtssim.Execute Egate Command    cmd=ue_deregister id=${SA_UE_ID} ue_deregister_type=switch_off by=ue

    ${local_file_path}  Log Collection  stop_and_download  ${log_type}  product_type=vcu  bts_index=${0}
    Check EPS Fallback Related Messages    ${local_file_path}
    [Teardown]  Case Postcondition For TC25

*** Keywords ***
Case Precondition
    Case Precondition For AP    tag=${none}    product_type=vdu    operation=env_setup_sa
    Common Test Setup For AIC
    Log To Console  \n===Case Precondition Finished===

Case Postcondition for TC25
    Log To Console    \nstop test
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=vdu
    ...                                      delta_file_path=${TC25_recovery_vdu}
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=vcu
    ...                                      delta_file_path=${TC25_recovery_vcu}
    ute_wtssim.Execute Egate Command    cmd=ue_deregister id=${SA_UE_ID} ue_deregister_type=switch_off by=ue
    ${local_file_path}    Run Keyword And Ignore Error  Log Collection  stop_and_download  ${log_type}  product_type=vcu
      ...    bts_index=${0}
    Common Test Teardown For AIC
    Case Postcondition For AP