*** Settings ***
Documentation
    ...    Author: kefang.sheng
    ...    Contact: kefang.sheng@nokia-sbell.com
    ...    Description: The test case is to verify stability of 5GC000501. The content of this case is gracefull shutdown.
    ...    Deprecated case removed by civen.chen
#
#
#Suite Setup       Common Suite Setup For AIC
#Suite Teardown    Common Suite Teardown For AIC
#Test Setup        Common Test Setup For AIC
#Test Teardown     Common Test Teardown For AIC
#
#Force Tags
#...                CRT
#...                CA_RAN_PZ_HAZ_1
#...                RAN_PZ_HAZ1_SG02_ST_RRM
#...                TA_LEVEL_22
#
#
#Resource    ../../Resources/Cloud/AIC_Common_Resource.robot
#
#*** Variables ***
#${index}                0
#${loop}                 100
#
#
#*** Test Cases ***
#[1]5GC000501_Stability_Graceful_Cell_Shutdown
#    [Tags]    CRT    5GC005792
#    [Documentation]
#    ...    Author: kefang.sheng
#    ...    Contact: kefang.sheng@nokia-sbell.com
#    ...    16.6.2022,kefang.sheng@nokia-sbell.com, CB005792_5GC000501
#
#     Set The Value of actGrflShdn To True
#     Change shutdownStepAmount and shutdownWindow
#
#  	FOR   ${index}   IN RANGE   1    ${loop}
#        Log to Console    \n*** The ${index} time to run the function***
#        Prepare UE0
#        Attach UE0 And Start DL TPUT
#        Check DL Tput By K8s Log
#        Trigger Cell_1 Shutdown
#        Check Cell_1 administrative state is locked
#        Unlock Cell
#        sleep    300s
#        Prepare UE0
#        Attach UE0 And Start DL TPUT
#        Check DL Tput By K8s Log
#        UE Detach    ${ue0_type}    ue_index=${0}
#        sleep    600s
#    END
#
#
#
#
#
#*** Keywords ***
#Set The Value of actGrflShdn to True
#   ${mo_dn}   Set Variable    MRBTS-11079/NRBTS-11079
#   &{parameter_dict_2}    Create Dictionary   actGrflShdn=true
#   &{parameter_dict}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
#   ...                                                                      mo_parameter_dict=&{parameter_dict_2}
#   vDU Login By Rest
#   Run Keyword If  &{parameter_dict} != &{Empty}    VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
#   ...                                          updated_paras_list=${parameter_dict_2}
#   ...                                          operation=replace
#   ...                                          activate=${True}
#   ...                                          force_reset=${False}
#   ...                                          auto_lock_cells=${False}
#   ...                                          wait_vdu_up=${False}
#   vDU Logout By Rest
#
#Change shutdownStepAmount and shutdownWindow
#    ${mo_dn}   Set Variable    MRBTS-11079/NRBTS-11079
#	&{parameter_dict_new}    Create Dictionary   shutdownStepAmount=3   shutdownWindow=30
#    &{parameter_dict}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
#    ...                                                                      mo_parameter_dict=&{parameter_dict_new}
#    vDU Login By Rest
#    Run Keyword If  &{parameter_dict} != &{Empty}    VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
#	...                                          updated_paras_list=${parameter_dict_new}
#	...                                          operation=replace
#	...                                          activate=${True}
#    ...                                          force_reset=${False}
#    ...                                          auto_lock_cells=${False}
#    ...                                          wait_vdu_up=${False}
#    vDU Logout By Rest
#
#
#Trigger Cell_1 Shutdown
#    Log to Console    \n***Trigger Cell_1 Shutdown***
#	${mo_dn}   Set Variable    MRBTS-11079/NRBTS-11079/NRCELL-1
#	&{parameter_dict1}    Create Dictionary   administrativeState=Shutting Down
#    &{parameter_dict2}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
#    ...                                                                      mo_parameter_dict=&{parameter_dict1}
#    vDU Login By Rest
#    Run Keyword If  &{parameter_dict2} != &{Empty}
#    ...             VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
#	...                                          updated_paras_list=${parameter_dict1}
#	...                                          operation=replace
#	...                                          activate=${True}
#    ...                                          force_reset=${False}
#    ...                                          auto_lock_cells=${False}
#    ...                                          wait_vdu_up=${False}
#    sleep    60s
#    vDU Logout By Rest
#
#Check Cell_1 administrative state is locked
#    Log to Console    \n***Check Cell_1 administrative state is locked***
#     ${cell_administrativeState}    ${cell_operationalState}=   vDU Get Specified Cell Status    1
#    should be equal  ${cell_administrativeState}  locked
#    should be equal  ${cell_operationalState}  disabled
#    sleep    60s
#
#
#Prepare UE0
#    Log to Console    \n***start to Prepare UE***
#    ${ue0_type}    translate_power_ue_type_from_testline    ue_index=${0}
#    Set Test Variable    ${ue0_type}
#    Prepare UE    ${ue0_type}    ue_index=${0}
#    sleep    60s
#
#Attach UE0 And Start DL TPUT
#    Log to Console    \n***start to UE Attach***
#    UE Attach    ${ue0_type}    ue_index=${0}
#    Start traffic    ue_type=${ue0_type}    ue_index=${0}    direction=dl    dt_index=${0}
#	...              throughput=800M    duration=120
#    sleep    20s
#
#
#Unlock Cell
#    Log to Console    \n***start to Unlock cell***
#    ${cell_id_list}    Create List    1
#    Unlock Cell In vDU    cell_id_list=${cell_id_list}
#    sleep    30s
#
#
#Check DL Tput By K8s Log
#    Log to Console    \n***start to check Tput***
#    ${dl_l2rt_tput_local_file_path}    Collect And Download K8s Log In vDU    gnb_index=${0}    vdu_index=${0}
#    ...                                      container_name=l2rt    pod_name=up   timeout=${10}
#    Set Test Variable    ${dl_l2rt_tput_local_file_path}
#    ${ave_dl_tput}    ${max_dl_tput}    ${min_dl_tput}    k8s.get_dl_tput_from_k8s_log    ${dl_l2rt_tput_local_file_path}
#    should be true  ${max_dl_tput}>=0
#    sleep    30s
