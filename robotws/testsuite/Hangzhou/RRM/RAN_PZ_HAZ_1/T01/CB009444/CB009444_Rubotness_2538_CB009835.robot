*** Settings ***
Documentation
    ...    Author: kefang.sheng
    ...    Contact: kefang.sheng@nokia-sbell.com
    ...    Description: The test case is to verify Stability Customer basic configration. The content of this case is site reset, RF reset, cell lock.
    ...    Deprecated case removed by civen.chen
#
#Suite Setup       Common Suite Setup For AIC
##Suite Teardown    Common Suite Teardown For AIC
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
#Resource    ../Resources/RRM2_Resource.robot
#
#*** Variables ***
#${index}                0
#${loop_RF_reset}           10
#${loop_CB009835}           4
#
#*** Test Cases ***
#[1][2.0] CB009444_5GC002538_F_InterWorking_2Beam_8x4MIMO_TwoUEs_NSA
#    [Tags]    QC_545312       QCD_MN_RAN      QCP_RAN_ST
#    [Documentation]
#    ...    Author: zhixia.qin@nokia-sbell.com
#    ...    history change: 17/03/2023,Qin zhixia,initial version
#    ...    17.3.2023,zhixia.qin@nokia-sbell.com, draft
#    ...    using beamforming to test. celltype=8DL4UL
#    ${dl_expected_tput}  Set Variable   1
#    Check TPut is higher than disable 2538     ${dl_expected_tput}
#
##    [Teardown]    case teardown 1
#
#[2]CB009444_Rubotness_RF_Reset
#    [Tags]    QC_542095       QCD_MN_RAN      QCP_RAN_ST
#    [Documentation]
#    ...    Author: kefang.sheng
#    ...    Contact: kefang.sheng@nokia-sbell.com
#    ...    1.9.2022,kefang.sheng@nokia-sbell.com
#
#     Log to Console    \n*** Stability_RF_Reset***
#  	FOR   ${index}   IN RANGE   1    ${loop_RF_reset}
#         Log to Console    \n*** The ${index} time to run the function***
#         Reset RU With Check Cell On Air
#	     Check both vDU and vCU cells should be onair
#    END
#
##    ${ue_alias}=    Prepare Dingli UE0
##    Attach Dingli Ue0 And Start DL TPUT	    ${ue_alias}
##    sleep    60s
##    AIC_UE.pioneer.Check Throughput     direction=dl    ue_alias=${ue_alias}    expected_throughput=1
##   [Teardown]    case teardown 1
#
#[1]CB009835_Block_UnBlock_Cell
#    [Tags]    QC_548382       QCD_MN_RAN      QCP_RAN_ST
#    [Documentation]
#    ...    Author: kefang.sheng
#    ...    Contact: kefang.sheng@nokia-sbell.com
#    ...    1.9.2022,kefang.sheng@nokia-sbell.com
#
#     Log to Console    \n*** Block_UnBlock_Cell***
#  	FOR   ${index}   IN RANGE   1    ${loop_CB009835}
#         Log to Console    \n*** The ${index} time to run the function***
#         Block Cell In vDU
#         sleep    10s
#         Unblock Cell In vDU
#	     Check both vDU and vCU cells should be onair
#    END
##    [Teardown]    case teardown 1
#
#[2]CB009835_RF_Reset
#    [Tags]    QC_548384       QCD_MN_RAN      QCP_RAN_ST
#    [Documentation]
#    ...    Author: kefang.sheng
#    ...    Contact: kefang.sheng@nokia-sbell.com
#    ...    1.9.2022,kefang.sheng@nokia-sbell.com
#
#     Log to Console    \n*** RF_Reset***
#  	FOR   ${index}   IN RANGE   1    ${loop_CB009835}
#         Log to Console    \n*** The ${index} time to run the function***
#         Reset RU With Check Cell On Air
#	     Check both vDU and vCU cells should be onair
#    END
##    [Teardown]    case teardown 1
#
#[3]CB009835_vDU_Reset
#    [Tags]    QC_548383       QCD_MN_RAN      QCP_RAN_ST
#    [Documentation]
#    ...    Author: kefang.sheng
#    ...    Contact: kefang.sheng@nokia-sbell.com
#    ...    1.9.2022,kefang.sheng@nokia-sbell.com
#
#     Log to Console    \n*** vDU_Reset***
#  	FOR   ${index}   IN RANGE   1    ${loop_CB009835}
#         Log to Console    \n*** The ${index} time to run the function***
#         Reset vDU With Check Cell On Air    need_check_on_air=${True}
#	     Check both vDU and vCU cells should be onair
#    END
##    [Teardown]    case teardown 1
#
#
#[1][1.0] CB009444_5GC001086-F_Single_UE_L3_Call_with_DRX_1cell
#    [Tags]    QC_603353       QCD_MN_RAN      QCP_RAN_ST
#    [Documentation]
#    ...    Author: zhixia.qin@nokia-sbell.com
#    ...    history change: 30/05/2023,Qin zhixia,initial version
#    ...    30.5.2023,zhixia.qin@nokia-sbell.com, draft
#    ...    using beamforming to test. celltype=4DL4UL
#    ${ul_expected_bler}  Set Variable   5
#    Check UL BLER enable 1086    ${ul_expected_bler}
#
#[1][1.0] CB009444_5GC001086-A_Verify_OAM_NIDD_Modification
#    [Tags]    QC_603358       QCD_MN_RAN      QCP_RAN_ST
#    [Documentation]
#    ...    Author: zhixia.qin@nokia-sbell.com
#    ...    history change: 30/05/2023,Qin zhixia,initial version
#    ...    30.5.2023,zhixia.qin@nokia-sbell.com, draft
#    ...    using beamforming to test. celltype=8DL4UL
#    Set The Value of actUlSrsBm true for NRCELL-1 and NRCELL-2
#    wait until keyword succeeds    300    10    vDU Check All Cells Status Should Be Onair
#    Set The Value of actUlSrsBm false for NRCELL-1 and NRCELL-2
#    wait until keyword succeeds    300    10    vDU Check All Cells Status Should Be Onair
#	Set The Value of actUlSrsBm to true for NRCELL-1
#	wait until keyword succeeds    300    10    vDU Check All Cells Status Should Be Onair
#	Set The Value of actUlSrsBm to false for NRCELL-1
#	wait until keyword succeeds    300    10    vDU Check All Cells Status Should Be Onair
#	Set The Value of actUlSrsBm to true for NRCELL-2
#	wait until keyword succeeds    300    10    vDU Check All Cells Status Should Be Onair
#	Set The Value of actUlSrsBm to false for NRCELL-2
#	wait until keyword succeeds    300    10    vDU Check All Cells Status Should Be Onair
#
#*** Keywords ***
#
#Prepare Dingli UE0
#    @{UEs_info}=    AIC_UE.pioneer.Detect UE and get UEs info
#    ${ue_index}    set variable    ${UEs_info[0]}[eqindex]
#    ${imei}        set variable    ${UEs_info[0]}[imei]
#    ${ue_alias}        set variable    ue_${ue_index}
#    AIC_UE.pioneer.Prepare UE    imei=${imei}    ue_alias=${ue_alias}
#    [Return]    ${ue_alias}
#
#Attach Dingli Ue0 And Start DL TPUT
#    [Arguments]        ${ue_alias}
#    AIC_UE.pioneer.UE Attach    ue_alias=${ue_alias}
#    sleep  5s
#    AIC_UE.pioneer.Start DL Traffic    dl_time=90     dl_port=8018
#        ...                   dl_throughput=800M   dl_length=1024B
#
#Attach Dingli Ue0 And Start UL TPUT
#    [Arguments]        ${ue_alias}
#    pioneer.UE Attach    ue_alias=${ue_alias}
#    sleep  5s
#    pioneer.Start UL Traffic    address=10.101.2.23    buffersize=200    port=5013    ue_alias=${ue_alias}
#
#Check both vDU and vCU cells should be onair
#    Log To Console    \n*** check on air state in cu ***
#    wait until keyword succeeds    900    20
#    ...        Check All Cells On Air In vCU
#    Log To Console    \n*** check on air state in du ***
#    wait until keyword succeeds    900    20
#    ...        vDU Check All Cells Status Should Be Onair
#
#Check TPut is higher than disable 2538
#    [Arguments]        ${dl_expcted_tput}
#    Log To Console    ${dl_expcted_tput}
#    Log to Console    \n***enable 2538***
#    Enable 5GC002538
#    wait until keyword succeeds    300    10    vDU Check All Cells Status Should Be Onair
#    ${ue_alias}=    Prepare Dingli UE0
#    Attach Dingli Ue0 And Start DL TPUT	    ${ue_alias}
#    sleep    60s
#    ${tput_pdsch_on}=    AIC_UE.pioneer.Check Throughput     direction=dl    ue_alias=${ue_alias}    expected_throughput=1
#    log to console         ${tput_pdsch_on}
#    Run Keyword And Ignore Error    Stop call    ${ue_alias}
#    Log to Console    \n***disable 2538***
#    Disable 5GC002538
#    wait until keyword succeeds    300    10    vDU Check All Cells Status Should Be Onair
#    Attach Dingli Ue0 And Start DL TPUT	    ${ue_alias}
#    sleep    60s
#    ${tput_pdsch_off}=    AIC_UE.pioneer.Check Throughput     direction=dl    ue_alias=${ue_alias}    expected_throughput=1
#    log to console         ${tput_pdsch_off}
#    Run Keyword And Ignore Error    Stop call    ${ue_alias}
#    Compare Tput    ${tput_pdsch_on}    ${tput_pdsch_off}
#
#Compare Tput
#    [Arguments]         ${tput_pdsch_on}     ${tput_pdsch_off}
#    log to console      Compare Trughputs
#    should be true    ${tput_pdsch_on} > ${tput_pdsch_off}
#
#Stop call
#    [Arguments]        ${ue_alias}
#     Run Keyword And Ignore Error    AIC_UE.pioneer.Start DL Traffic   ue_alias=${ue_alias}
#
#Case Teardown 1
#    Run Keyword And Ignore Error    Stop call    ${ue_alias}
#
#Enable 5GC002538
#    Set The Value of actPdschRmCsirsForTracking to true
#
#Disable 5GC002538
#    Set The Value of actPdschRmCsirsForTracking to false
#
#Set The Value of actPdschRmCsirsForTracking to ${value}
#   ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2
#   &{parameter_dict_new}    Create Dictionary   actPdschAtSsbSlots=${value}    actPdschRmCsirsForTracking=${value}
#   &{parameter_dict}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
#   ...                                                                      mo_parameter_dict=&{parameter_dict_new}
#   vDU Login By Rest
#   Run Keyword If  &{parameter_dict} != &{Empty}    VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
#    ...                                          updated_paras_list=${parameter_dict_new}
#   vDU Logout By Rest
#
#Enable 5GC001086
#    Set The Value of actUlSrsBm to true for NRCELL-2
#
#Disable 5GC001086
#    Set The Value of actUlSrsBm to false for NRCELL-2
#
#Set The Value of actUlSrsBm to ${value} for ${CELL_index}
#   ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/${CELL_index}
#   &{parameter_dict_new}    Create Dictionary   actUlSrsBm=${value}
#   &{parameter_dict}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
#   ...                                                                      mo_parameter_dict=&{parameter_dict_new}
#   vDU Login By Rest
#   Run Keyword If  &{parameter_dict} != &{Empty}    VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
#    ...                                          updated_paras_list=${parameter_dict_new}
#   vDU Logout By Rest
#
#Set The Value of actUlSrsBm ${value} for NRCELL-1 and NRCELL-2
#    ${mo_dn_1}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#    ${mo_dn_2}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2
#    &{parameter_dict_new}    Create Dictionary   actUlSrsBm=${value}
#    &{parameter_dict_1}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn_1}
#    ...                                                                      mo_parameter_dict=&{parameter_dict_new}
#    &{parameter_dict_2}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn_2}
#    ...                                                                      mo_parameter_dict=&{parameter_dict_new}
#    vDU Login By Rest
#    ${delta_plan_name}    get unique id    prefix=TA_delta_plan    precise=LOW
#    ${plan_id}    ${action_id}    Generate Delta Plan In vDU    plan_name=${delta_plan_name}    plan_description=TA
#    Run Keyword If  &{parameter_dict_1} != &{Empty}   Update Parameter By Delta Plan In vDU    plan_id=${planid}
#    ...    mo_dn=${mo_dn_1}    updated_paras_dict=${parameter_dict_new}    operation=replace
#    Run Keyword If  &{parameter_dict_2} != &{Empty}   Update Parameter By Delta Plan In vDU    plan_id=${planid}
#    ...    mo_dn=${mo_dn_2}    updated_paras_dict=${parameter_dict_new}    operation=replace
#    ${validation_id}    Validate Delta Plan By REST In vDU    plan_id=${planid}
#    Activate Delta Plan By REST In vDU    plan_id=${plan_id}    force_reset=${True}
#    ...    auto_lock_cells=${True}    timeout=60    wait_vdu_up=${False}
#
#Check UL BLER enable 1086
#    [Arguments]        ${ul_expected_bler}
#    Log to Console    \n***enable 1086***
#    Enable 5GC001086
#    wait until keyword succeeds    360    10    vDU Check All Cells Status Should Be Onair
#    @{UEs_info}=    AIC_UE.pioneer.Detect UE and get UEs info
#    ${ue_alias}   set variable    UE_${0}
#    @{ue_ul_param_list}   Create List    NR PUSCH BLER
#    AIC_UE.pioneer.Prepare UE     imei=${UEs_info[0]}[imei]    ue_alias=${ue_alias}
#    AIC_UE.pioneer.UE Attach    ue_alias=${ue_alias}
#    Run Keyword And Ignore Error    pioneer.Start UL Traffic    address=10.101.2.23    buffersize=200    port=5013    ue_alias=${ue_alias}
#    sleep    20s
#    ${res_data}   AIC_UE.pioneer.Get Parameter Summary Statistics Result    ue_param_list=${ue_ul_param_list}    ue_alias=${ue_alias}
#    ${bler_value}   set variable   ${res_data["Param"]["NR PUSCH BLER"]["Avg"]}
#    should be true    ${bler_value}<${ul_expected_bler}
#    AIC_UE.pioneer.Check Throughput     direction=ul    ue_alias=${ue_alias}    expected_throughput=${30}
#    Run Keyword And Ignore Error    AIC_UE.pioneer.Stop UL Traffic   ue_alias=${ue_alias}
#    Log to Console    \n***disable 1086***
#    Disable 5GC001086
#    wait until keyword succeeds    360    10    vDU Check All Cells Status Should Be Onair
#
#Compare UL BLER
#    [Arguments]         ${ul_actual_bler}     ${ul_expected_bler}
#    log to console      Compare bler
#    should be true    ${ul_actual_bler} < ${ul_expected_bler}
