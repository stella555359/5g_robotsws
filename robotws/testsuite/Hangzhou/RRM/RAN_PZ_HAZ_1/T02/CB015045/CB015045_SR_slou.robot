*** Settings ***
Documentation
...    Author: sudi Lou
...    Contact: sudi.lou@nokia-sbell.com

Force Tags        QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_O_E_AP_LOOO

Suite Setup    Update bsr package

Resource    ./Resource_CB015045.robot
Resource    ../../Resources/Classical/RRM_Common_Resource.robot

*** Variables ***
${SA_UE_ID}    1
${SA_UE_ID_for_cell3}    81
${TC04_delta_file}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB015045/TC04_Delta_Configuration.json
${TC04_recovery_delta_file}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB015045/TC04_recovery_Delta_Configuration.json
${TC05_delta_file}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB015045/TC05_Delta_Configuration.json
${TC05_recovery_delta_file}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB015045/TC05_recovery_Delta_Configuration.json
${TC06_delta_file}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB015045/TC06_Delta_Configuration.json
${TC06_recovery_delta_file}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB015045/TC06_recovery_Delta_Configuration.json
${TC17_delta_file}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB015045/TC17_Delta_Configuration.json
${TC17_recovery_delta_file}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB015045/TC17_recovery_Delta_Configuration.json
${TC17_to_compare}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB015045/TC17_com_Delta_Configuration.json
${TC17_recovery_to_compare}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB015045/TC17_com_recovery_Delta_Configuration.json
${TC07_TMO_delta_file}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB015045/TMO_TC07_Delta_Configuration_scf.json
${TC07_recovery}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/CB015045/TMO_TC07_recovery.json
${log_type}    syslog+emil


*** Test Cases ***
CB015045_A_SR_04_B1_EPS_fallback_during_Initial_Context_Setup
    [Documentation]
    ...    author: Sudi Lou
    [Tags]    QC_227760    CRT
    [Setup]    Case Precondition For AP    tag=${none}    product_type=gnb    operation=env_setup_sa
    Log To Console    \nstart test
    start_log_collection    log_type=${log_type}
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=gnb
    ...                                      delta_file_path=${TC04_delta_file}
    Trigger EPS Fallback during Initial Context Setup    ue_id=${SA_UE_ID_for_cell3}    cell_id=3
    Sleep    1s    reason=wait for the UE to register and trigger EPS fallback
    ${local_file_path}  Log Collection  stop_and_download  ${log_type}  product_type=gnb  bts_index=${0}
    Check EPS Fallback Related Messages    ${local_file_path}
    [Teardown]  Teardown_for_CB015045_TC04

CB015045_A_SR_05_B1_ALT1_EPS_fallback_during_Initial_Context_Setup_due_to_CU-CP_RAC_failure
    [Documentation]
    ...    author: Sudi Lou
    [Tags]    TC05    NFTA
    Log To Console    \nstart test
    Case Precondition For AP    tag=${none}    product_type=gnb    operation=env_setup_sa
    start_log_collection    log_type=${log_type}
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=gnb
    ...                                      delta_file_path=${TC05_delta_file}
    Trigger EPS Fallback during Initial Context Setup    ue_id=${SA_UE_ID_for_cell3}    cell_id=3
    ${local_file_path}  Log Collection  stop_and_download  ${log_type}  product_type=gnb  bts_index=${0}
    Check EPS Fallback Related Messages    ${local_file_path}
    [Teardown]  Teardown_for_CB015045_TC05

CB015045_A_SR_06_B1_ALT2_EPS_fallback_of_emergency_call_during_Initial_Context_Setup_due_to_CU-CP_RAC_failure
    [Documentation]
    ...    author: Sudi Lou
    [Tags]    TC06    NFTA
    Log To Console    \nstart test
    Case Precondition For AP    tag=${none}    product_type=gnb    operation=env_setup_sa
    start_log_collection    log_type=${log_type}
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=gnb
    ...                                      delta_file_path=${TC06_delta_file}
    Trigger EPS Fallback during Initial Context Setup    ue_id=${SA_UE_ID_for_cell3}    cell_id=3    call_type=emergency
    ${local_file_path}  Log Collection  stop_and_download  ${log_type}  product_type=gnb  bts_index=${0}
    Check EPS Fallback Related Messages    ${local_file_path}
    [Teardown]  Teardown_for_CB015045_TC06

CB015045_A_SR_07_B2_EPS_fallback_during_PDU_Session_Setup
    [Documentation]
    ...    author: Sudi Lou
    [Tags]    QC_227762    CRT
    [Setup]    Case Precondition For AP    tag=${none}    product_type=gnb    operation=env_setup_sa
    Log To Console    \nstart test
    start_log_collection    log_type=${log_type}
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=gnb
    ...                                      delta_file_path=${TC04_delta_file}
    ${ue_id_list}  Evaluate  list(range(81, 82))
    Trigger EPS Fallback during PDU Session Setup    @{ue_id_list}    cell_id=3
    Sleep    1s    reason=wait for the UE to register and trigger EPS fallback
    ${local_file_path}  Log Collection  stop_and_download  ${log_type}  product_type=gnb  bts_index=${0}
    Check EPS Fallback Related Messages    ${local_file_path}
    [Teardown]  Teardown_for_CB015045_TC04

CB015045_A_SR_07_to_compare_on_TMO
    [Documentation]
    ...    author: Sudi Lou
    [Tags]    TMO_TC07
    Log To Console    \nstart test
#    Case Precondition for TMO
    start_log_collection    log_type=${log_type}
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=gnb
    ...                                      delta_file_path=${TC07_TMO_delta_file}
    ${ue_id_list}  Evaluate  list(range(31, 32))
    Trigger EPS Fallback during PDU Session Setup    @{ue_id_list}    cell_id=3
    Sleep    1s    reason=wait for the UE to register and trigger EPS fallback
    ${local_file_path}  Log Collection  stop_and_download  ${log_type}  product_type=gnb  bts_index=${0}
    [Teardown]  Teardown_for_CB015045_TC04

CB015045_A_SR_08_B2_ALT1_EPS_fallback_during_PDU_Session_Setup_due_to_CU-CP_RAC_failure
    [Documentation]
    ...    author: Sudi Lou
    [Tags]    TC08    NFTA
    Log To Console    \nstart test
    Case Precondition For AP    tag=${none}    product_type=gnb    operation=env_setup_sa
    start_log_collection    log_type=${log_type}
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=gnb
    ...                                      delta_file_path=${TC05_delta_file}
    Sleep    3s    reason=wait for the log collection start
#    Trigger EPS Fallback during PDU Session Setup for a Normal Voice Call    ue_id=${SA_UE_ID_for_cell3}    cell_id=3
    ${ue_id_list}  Evaluate  list(range(81, 82))
    Trigger EPS Fallback during PDU Session Setup    @{ue_id_list}    cell_id=3
    Sleep    3s    reason=wait for the UE to register and trigger EPS fallback
    ${local_file_path}  Log Collection  stop_and_download  ${log_type}  product_type=gnb  bts_index=${0}
    Check EPS Fallback Related Messages    ${local_file_path}
    [Teardown]  Teardown_for_CB015045_TC05

CB015045_A_SR_09_B2_ALT2_EPS_fallback_of_emergency_call_during_PDU_Session_Setup_due_to_CU-CP_RAC_failure
    [Documentation]
    ...    author: Sudi Lou
    [Tags]    TC09    NFTA
    Log To Console    \nstart test
    Case Precondition For AP    tag=${none}    product_type=gnb    operation=env_setup_sa
    start_log_collection    log_type=${log_type}
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=gnb
    ...                                      delta_file_path=${TC06_delta_file}
    Sleep    3s    reason=wait for the log collection start
    Trigger EPS Fallback during PDU Session Setup    ue_id=${SA_UE_ID_for_cell3}    cell_id=3    call_type=emergency
    Sleep    3s    reason=wait for the UE to register and trigger EPS fallback
    ${local_file_path}  Log Collection  stop_and_download  ${log_type}  product_type=gnb  bts_index=${0}
    Check EPS Fallback Related Messages    ${local_file_path}
    [Teardown]  Teardown_for_CB015045_TC06

CB015045_A_SR_18_robustness_EPS_fallback_due_Multiple_UE_triggering_normal_voice_call
    [Documentation]
    ...    author: Sudi Lou
    [Tags]    TC18    NFTA
    Log To Console    \nstart test
    Case Precondition For AP    tag=${none}    product_type=gnb    operation=env_setup_sa
    start_log_collection    log_type=${log_type}
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=gnb
#    ...                                      delta_file_path=${TC04_delta_file}
    ...                                      delta_file_path=${TC05_delta_file}
    ${ue_id_list}  Evaluate  list(range(81, 84))
    Trigger EPS Fallback during PDU Session Setup    @{ue_id_list}    cell_id=3
    Sleep    1s    reason=wait for the UE to register and trigger EPS fallback
    ${local_file_path}  Log Collection  stop_and_download  ${log_type}  product_type=gnb  bts_index=${0}
    [Teardown]  Teardown_for_CB015045_TC05

CB015045_A_SR_17_B5_EPS_fallback_due_to_emergency_call_RAC_failure_with_established_normal_voice_call
    [Documentation]
    ...    author: Sudi Lou
    [Tags]    TC17    NFTA
    Log To Console    \nstart test
    Case Precondition For AP    tag=${none}    product_type=gnb    operation=env_setup_sa
    start_log_collection    log_type=${log_type}
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=gnb
#    ...                                      delta_file_path=${TC17_delta_file}
    ...                                      delta_file_path=${TC17_to_compare}
#    ${ue_id_list}  Evaluate  list(range(81, 82))
    Trigger EPS Fallback for an Emergency Call with normal voice call established    ue_id=${SA_UE_ID_for_cell3}    cell_id=3
    Sleep    1s    reason=wait for the UE to register and trigger EPS fallback
    ${local_file_path}  Log Collection  stop_and_download  ${log_type}  product_type=gnb  bts_index=${0}
    [Teardown]  Teardown_for_CB015045_TC05

*** Keywords ***
Case Precondition for RJIO
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=600s
    ...                   customer=RJIO_SA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_5_2

Teardown_for_CB015045_TC04
    Log To Console    \nstop test
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=gnb
#    ...                                      delta_file_path=${TC07_recovery}
    ...                                      delta_file_path=${TC04_recovery_delta_file}
    ute_wtssim.Execute Egate Command    cmd=ue_deregister id=${SA_UE_ID_for_cell3} ue_deregister_type=switch_off by=ue
    ${local_file_path}    Run Keyword And Ignore Error  Log Collection  stop_and_download  ${log_type}  product_type=gnb
      ...    bts_index=${0}
    HAZ TC02 Get SCF Internal Id By Scout  no_ute=False
    Case Postcondition For AP

Case Precondition for TMO
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sansa
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=1200s
    ...                   customer=TMO_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65

Teardown_for_CB015045_TC05
    Log To Console    \nstop test
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=gnb
#    ...                                      delta_file_path=${TC17_recovery_delta_file}
#    ...                                      delta_file_path=${TC17_recovery_to_compare}
    ...                                      delta_file_path=${TC05_recovery_delta_file}
    ute_wtssim.Execute Egate Command    cmd=ue_deregister id=${SA_UE_ID_for_cell3} ue_deregister_type=switch_off by=ue
    ${local_file_path}    Run Keyword And Ignore Error  Log Collection  stop_and_download  ${log_type}  product_type=gnb
      ...    bts_index=${0}
    HAZ TC02 Get SCF Internal Id By Scout  no_ute=False
    Case Postcondition For AP

Teardown_for_CB015045_TC06
    Log To Console    \nstop test
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=gnb
    ...                                      delta_file_path=${TC06_recovery_delta_file}
    ute_wtssim.Execute Egate Command    cmd=ue_deregister id=${SA_UE_ID_for_cell3} ue_deregister_type=switch_off by=ue
    ${local_file_path}    Run Keyword And Ignore Error  Log Collection  stop_and_download  ${log_type}  product_type=gnb
      ...    bts_index=${0}
    HAZ TC02 Get SCF Internal Id By Scout  no_ute=False
    Case Postcondition For AP