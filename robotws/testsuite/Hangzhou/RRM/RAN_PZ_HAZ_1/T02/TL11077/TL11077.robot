*** Settings ***
Documentation
...    Author: Liu Juan
...    Contact: juan.liu@nokia-sbell.com
...    this file is collect some Common KWs of AIC,you can use it in your case directly.
...    Please do not modify the file without notification to author


Suite Setup    Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot


*** Test Cases ***
CB010413_01_CB008159_NR_Additional_PM_counters_Verify_on_TDD_SA
    [Tags]        CRT      CB008159
    [Documentation]
    ...    Author: Haiying.Ao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    22.03.2024,Haiying.Ao@nokia-sbell.com, draft
    [Setup]        Case Precondition
	#Start Collect Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU
	#Prepare And Attach UE    ue_index=8
    Prepare And Attach Commercial UE    ue_index=0
#	Start Call For UE    ue_index=0    direction=ul
#	Start Call For UE    ue_index=0    direction=dl
	Start VONR Call For UE   ue_index=0
	Sleep  120s
	Stop VONR Call For UE    ue_index=0
#	Stop Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU    vcu_log_name=vcu_wireshark
	#Check Counter For 5GC000784
    [Teardown]        Case Postcondition

CB012601_6_B2_Inter_gNB_XN_handover_UE_redirected_to_FDD_frequency_layer
    [Tags]        CRT      CB012601
    [Documentation]
    ...    Author: Haiying.Ao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    21.05.2024,Haiying.Ao@nokia-sbell.com, draft
    [Setup]        Case Precondition
	#Start Collect Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU
	#Prepare And Attach UE    ue_index=8
    Prepare And Attach Commercial UE    ue_index=0
#	Start Call For UE    ue_index=0    direction=ul
#	Start Call For UE    ue_index=0    direction=dl
	Start VONR Call For UE   ue_index=0
	Sleep  120s
	Stop VONR Call For UE    ue_index=0
#	Stop Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU    vcu_log_name=vcu_wireshark
	#Check Counter For 5GC000784
    [Teardown]        Case Postcondition

CB012601_5_B1_UE_redirected_to_a_FDD_Set_voNrRimAndHubOrUnf_dataHubOrUnf_scenario
    [Tags]        CRT      CB012601
    [Documentation]
    ...    Author: Haiying.Ao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    22.05.2024,Haiying.Ao@nokia-sbell.com, draft
    [Setup]        Case Precondition
	#Start Collect Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU
	#Prepare And Attach UE    ue_index=8
    Prepare And Attach Commercial UE    ue_index=0
#	Start Call For UE    ue_index=0    direction=ul
#	Start Call For UE    ue_index=0    direction=dl
	Start VONR Call For UE   ue_index=0
	Sleep  120s
	Stop VONR Call For UE    ue_index=0
#	Stop Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU    vcu_log_name=vcu_wireshark
	#Check Counter For 5GC000784
    [Teardown]        Case Postcondition

CB012601_1_TDD_Verification_function_Activate_parameters_can_be_modified_online_PDL_is_normal
    [Tags]        CRT      CB012601
    [Documentation]
    ...    Author: Haiying.Ao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    22.05.2024,Haiying.Ao@nokia-sbell.com, draft
    [Setup]        Case Precondition
	#Start Collect Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU
	#Prepare And Attach UE    ue_index=8
    Prepare And Attach Commercial UE    ue_index=0
#	Start Call For UE    ue_index=0    direction=ul
#	Start Call For UE    ue_index=0    direction=dl
	Start VONR Call For UE   ue_index=0
	Sleep  120s
	Stop VONR Call For UE    ue_index=0
#	Stop Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU    vcu_log_name=vcu_wireshark
	#Check Counter For 5GC000784
    [Teardown]        Case Postcondition

CB011169_11_CB009059_CA_TDD_intra_gNB_inter_DU_Verification_downlink_3CC_function
    [Tags]        CRT      CB011169
    [Documentation]
    ...    Author: Haiying.Ao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    22.05.2024,Haiying.Ao@nokia-sbell.com, draft
    [Setup]        Case Precondition
	#Start Collect Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU
	#Prepare And Attach UE    ue_index=8
    Prepare And Attach Commercial UE    ue_index=0
#	Start Call For UE    ue_index=0    direction=ul
#	Start Call For UE    ue_index=0    direction=dl
	Start VONR Call For UE   ue_index=0
	Sleep  120s
	Stop VONR Call For UE    ue_index=0
#	Stop Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU    vcu_log_name=vcu_wireshark
	#Check Counter For 5GC000784
    [Teardown]        Case Postcondition

CB012219_18_CB008917_Activate specific BWP on FDD with PRB pooling - PRB45 - pdschRat0RbgConfig = config2
    [Tags]        CRT      CB012219
    [Documentation]
    ...    Author: Haiying.Ao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    22.05.2024,Haiying.Ao@nokia-sbell.com, draft
    [Setup]        Case Precondition
	#Start Collect Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU
	#Prepare And Attach UE    ue_index=8
    Prepare And Attach Commercial UE    ue_index=0
#	Start Call For UE    ue_index=0    direction=ul
#	Start Call For UE    ue_index=0    direction=dl
	Start VONR Call For UE   ue_index=0
	Sleep  120s
	Stop VONR Call For UE    ue_index=0
#	Stop Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU    vcu_log_name=vcu_wireshark
	#Check Counter For 5GC000784
    [Teardown]        Case Postcondition

CB015045_A_CR_26_B4_Online_modification_of_Feature_Activation_Flag
    [Tags]        CRT      CB015045
    [Documentation]
    ...    Author: Haiying.Ao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    01.02.2025,Haiying.Ao@nokia-sbell.com, draft
    [Setup]        Case Precondition
	#Start Collect Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU
	#Prepare And Attach UE    ue_index=8
    Prepare And Attach Commercial UE    ue_index=0
#	Start Call For UE    ue_index=0    direction=ul
#	Start Call For UE    ue_index=0    direction=dl
	Start VONR Call For UE   ue_index=0
	Sleep  120s
	Stop VONR Call For UE    ue_index=0
#	Stop Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU    vcu_log_name=vcu_wireshark
	#Check Counter For 5GC000784
    [Teardown]        Case Postcondition

CB015045_A_CR_25_B1_EPS_fallback_during_Initial_Context_Setup
    [Tags]        CRT      CB015045
    [Documentation]
    ...    Author: Haiying.Ao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    01.02.2025,Haiying.Ao@nokia-sbell.com, draft
    [Setup]        Case Precondition
	#Start Collect Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU
	#Prepare And Attach UE    ue_index=8
    Prepare And Attach Commercial UE    ue_index=0
#	Start Call For UE    ue_index=0    direction=ul
#	Start Call For UE    ue_index=0    direction=dl
	Start VONR Call For UE   ue_index=0
	Sleep  120s
	Stop VONR Call For UE    ue_index=0
#	Stop Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU    vcu_log_name=vcu_wireshark
	#Check Counter For 5GC000784
    [Teardown]        Case Postcondition



*** Keywords ***
Case Precondition
    log to console    Case Precondition
    Common Test Setup For AIC
    ${vdu_hostname_dict}    ${vdu_username_dict}    ${vdu_password_dict}    ${vdu_ns_dict}
    ...                                               Get SSH Connection Infor For Multiple vDU With Different vCU
    Set Test Variable    ${vdu_hostname_dict}
    Set Test Variable    ${vdu_username_dict}
    Set Test Variable    ${vdu_password_dict}
    Set Test Variable    ${vdu_ns_dict}
    ${vcu_hostname_list}  ${vcu_username_list}  ${vcu_password_list}  ${vcu_ns_list}
    ...                                               Get SSH Connection Infor For Multiple vCU K8s Master
    Set Test Variable    ${vcu_hostname_list}
    Set Test Variable    ${vcu_username_list}
    Set Test Variable    ${vcu_password_list}
    Set Test Variable    ${vcu_ns_list}
    ${NEW_PLAN_NAME}     Get Test Case Name
    Set Test Variable    ${NEW_PLAN_NAME}

Case Postcondition
    log to console    Case Postcondition
    Common Test Teardown For AIC
    run keyword and ignore error  Stop Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU
    ...                                                 vcu_log_name=vcu_wireshark
    run keyword and ignore error  Detach UE    ue_index=0

5GC001630 Postcondition
    log to console    Case Postcondition
    Common Test Teardown For AIC
    run keyword and ignore error  Unlock One NG-C Links In vCU
    run keyword and ignore error  Detach UE    ue_index=0
    run keyword and ignore error  Detach UE    ue_index=1

CB007077_NG Postcondition
    log to console    Case Postcondition
    Common Test Teardown For AIC
    run keyword and ignore error  Unlock One X2 Link In vCU
    run keyword and ignore error  Detach UE    ue_index=1

CB007886 Postcondition
    log to console    Case Postcondition
    Common Test Teardown For AIC
    run keyword and ignore error  Stop Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU
    ...                                                 vcu_log_name=vcu_wireshark

5GC002300 Postcondition
    log to console    Case Postcondition
    run keyword and ignore error  Modify Parameters By Delta Plan    ne=vDU    parameter=actEirpControl    value=false
    Common Test Teardown For AIC
    run keyword and ignore error  Stop Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU
    ...                                                 vcu_log_name=vcu_wireshark
    run keyword and ignore error  Detach UE    ue_index=0

5GC002060 Postcondition
    log to console    Case Postcondition
    run keyword and ignore error  Set DrxLongCycle To Be Bigger Than 80ms
    Common Test Teardown For AIC
    run keyword and ignore error  Stop Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU
    ...                                                 vcu_log_name=vcu_wireshark
    run keyword and ignore error  Detach UE    ue_index=0

5GC002637 Postcondition
    log to console    Case Postcondition
    Run Keyword If Test Failed    Collect K8s Log With Cprt
    Run Keyword If Test Failed    Collect K8s Log With Cpue
    Run Keyword If Test Failed    Stop Trace Log By Dcap    ne_type=vcu    gnb_index=0    vdu_index=0
    ${vdu_zip_file_path}    Run Keyword If Test Failed    Save Trace Log By Dcap    ne_type=vdu    gnb_index=0    vdu_index=0
    ${vcu_zip_file_path}    Run Keyword If Test Failed    Save Trace Log By Dcap    ne_type=vcu    gnb_index=0    vdu_index=0
    Run Keyword And Ignore Error    Detach UE    ue_index=${0}

CB008021 Postcondition
    log to console    Case Postcondition
    run keyword and ignore error  Modify Parameters By Delta Plan    ne=all    parameter=actNrUlRipMeasurement
	...                                            value=disabled    mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    Common Test Teardown For AIC
    run keyword and ignore error  Detach UE    ue_index=1

Modify Parameters By Delta Plan
    [Arguments]   ${ne}=vDU    ${parameter}=actCDrx    ${value}=true
    ...           ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
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
    [Arguments]   ${parameter}=actCDrx    ${value}=true    ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
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

Set DrxLongCycle Be Smaller Than 80ms
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    &{parameter_dict}    Create Dictionary   actCDrx=true
    &{parameter_dict1}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
    ...                                                                      mo_parameter_dict=&{parameter_dict}
    vDU Login By Rest
    Run Keyword If    '&{parameter_dict1}' != '{}'    VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
    ...                                          updated_paras_list=${parameter_dict}
    ...                                          operation=replace
    ...                                          activate=${True}
    ...                                          force_reset=${False}
    ...                                          auto_lock_cells=${False}
    ...                                          wait_vdu_up=${False}
    vDU Logout By Rest
    &{drxProfile1_delta_dict}   create dictionary     drxProfile1=${None}
    ...                                   drxProfile1/0/drxInactivityTimer=40ms
    ...                                   drxProfile1/1/drxLongCycle=40ms
    ...                                   drxProfile1/2/drxOnDurationTimer=10ms
    ...                                   drxProfile1/3/drxRetransTimerDl=16slot
    ...                                   drxProfile1/4/drxRetransTimerUl=16slot
	VDU Online Modify Staged Parameters By Rest    mo_dn=${mo_dn}
	...                                          updated_paras_dict=${drxProfile1_delta_dict}
    wait until keyword succeeds  600s  10s    vDU Check All Cells Status Should Be Onair For All DUs    gnb_index=${0}
    [Teardown]    Run Keyword And Ignore error    vDU Logout By Rest

Set DrxLongCycle To Be Bigger Than 80ms
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    &{parameter_dict}    Create Dictionary   actCDrx=true
    &{parameter_dict1}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
    ...                                                                      mo_parameter_dict=&{parameter_dict}
    vDU Login By Rest
    Run Keyword If  &{parameter_dict1} != &{Empty}    VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
    ...                                          updated_paras_list=${parameter_dict}
    ...                                          operation=replace
    ...                                          activate=${True}
    ...                                          force_reset=${False}
    ...                                          auto_lock_cells=${False}
    ...                                          wait_vdu_up=${False}
    vDU Logout By Rest
    &{drxProfile1_delta_dict}   create dictionary     drxProfile1=${None}
    ...                                   drxProfile1/0/drxInactivityTimer=80ms
    ...                                   drxProfile1/1/drxLongCycle=160ms
    ...                                   drxProfile1/2/drxOnDurationTimer=10ms
    ...                                   drxProfile1/3/drxRetransTimerDl=0slot
    ...                                   drxProfile1/4/drxRetransTimerUl=0slot
    &{csi_delta_list}   create dictionary     periodicCsiAcquisition=${None}
    ...                                   periodicCsiAcquisition/0/drxInactivityTimer=40ms
    ...                                   drxProfile1/1/csiReportPeriodicity=slots160
	VDU Online Modify Staged Parameters By Rest    mo_dn=${mo_dn}
	...                                          updated_paras_dict=${drxProfile1_delta_dict}
    wait until keyword succeeds  600s  10s    vDU Check All Cells Status Should Be Onair For All DUs    gnb_index=${0}
    [Teardown]    Run Keyword And Ignore error    vDU Logout By Rest


Start Collect Wireshark Log
    [Arguments]    ${container_name}=cpif    ${pod_name}=cpif    ${NE}=vDU    ${gnb_index}=${0}    ${index}=${0}
    Run Keyword If    '${NE}'=='vCU'    Start Collect Wireshark Log In vCU
    ...                                                           container_name=${container_name}
    ...                                                           pod_name=${pod_name}
    ...                                                           index=${index}
    ...       ELSE IF    '${NE}'=='vDU'    Start Collect Wireshark Log In vDU
    ...                                                           container_name=${container_name}
    ...                                                           pod_name=${pod_name}
    ...                                                           gnb_index=${gnb_index}
    ...                                                           index=${index}
    ...       ELSE IF    '${NE}'=='all'    Start Collect Wireshark Log Both vCU And vDU
    ...                                                           container_name=${container_name}
    ...                                                           vdu_pod_name=cprt
    ...                                                           vcu_pod_name=cpif
    ...                                                           gnb_index=${gnb_index}
    ...                                                           index=${index}
    ...       ELSE IF    '${NE}'=='Multi_vDU'    Start Collect Wireshark Log Inter vDU
    ...                                                           container_name=${container_name}
    ...                                                           pod_name=${pod_name}
    ...                                                           gnb_index=${gnb_index}
    ...                                                           gnb2_index=${gnb_index}
    ...                                                           index=${index}

Start Collect Wireshark Log In vCU
    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cpif    ${index}=${0}
    Log to Console    \n***Start Wireshark Log In vCU***
    Start Wireshark Log In vCU   container_name=${container_name}
    ...                          pod_name=${pod_name}
    ...                          timeout=${10}
    ...                          protocol=sctp
    ...                          interface=any
    ...                          hostname=${vcu_hostname_list[${index}]}
    ...                          username=${vcu_username_list[${index}]}
    ...                          password=${vcu_password_list[${index}]}
    ...                          namespace=${vcu_ns_list[${index}]}

Start Collect Wireshark Log In vDU
    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cprt    ${gnb_index}=${0}    ${index}=${0}
    Log to Console    \n***Start Wireshark Log In vCU***
    Start Wireshark Log In vDU   container_name=${container_name}
    ...                          pod_name=${pod_name}
    ...                          timeout=${10}
    ...                          protocol=sctp
    ...                          interface=any
    ...                          hostname=${vdu_hostname_dict['vcu_${gnb_index}_vdu_hostname'][${index}]}
    ...                          username=${vdu_username_dict['vcu_${gnb_index}_vdu_username'][${index}]}
    ...                          password=${vdu_password_dict['vcu_${gnb_index}_vdu_password'][${index}]}
    ...                          namespace=${vdu_ns_dict['vcu_${gnb_index}_vdu_ns'][${index}]}

Start Collect Wireshark Log Both vCU And vDU
    [Arguments]    ${container_name}=cprt    ${vdu_pod_name}=cprt    ${vcu_pod_name}=cpif
    ...            ${gnb_index}=${0}    ${index}=${0}
    Log to Console    \n***Start Wireshark Log In vCU***
    Start Wireshark Log In vCU   container_name=${container_name}
    ...                          pod_name=${vcu_pod_name}
    ...                          timeout=${10}
    ...                          protocol=sctp
    ...                          interface=any
    ...                          hostname=${vcu_hostname_list[${index}]}
    ...                          username=${vcu_username_list[${index}]}
    ...                          password=${vcu_password_list[${index}]}
    ...                          namespace=${vcu_ns_list[${index}]}
    Start Wireshark Log In vDU   container_name=${container_name}
    ...                          pod_name=${vdu_pod_name}
    ...                          timeout=${10}
    ...                          protocol=sctp
    ...                          interface=any
    ...                          hostname=${vdu_hostname_dict[vcu_${gnb_index}_vdu_hostname][${index}]}
    ...                          username=${vdu_hostname_dict[vcu_${gnb_index}_vdu_hostname][${index}]}
    ...                          password=${vdu_hostname_dict[vcu_${gnb_index}_vdu_hostname][${index}]}
    ...                          namespace=${vdu_hostname_dict[vcu_${gnb_index}_vdu_hostname][${index}]}

Start Collect Wireshark Log Inter vDU
    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cprt    ${gnb_index}=${0}
    ...            ${gnb2_index}=${0}    ${index}=${0}
    Log to Console    \n***Start Wireshark Log In vCU***
    Start Wireshark Log In vDU   container_name=${container_name}
    ...                          pod_name=${pod_name}
    ...                          timeout=${10}
    ...                          protocol=sctp
    ...                          interface=any
    ...                          hostname=${vdu_hostname_dict['vcu_${gnb_index}_vdu_hostname'][${index}]}
    ...                          username=${vdu_username_dict['vcu_${gnb_index}_vdu_username'][${index}]}
    ...                          password=${vdu_password_dict['vcu_${gnb_index}_vdu_password'][${index}]}
    ...                          namespace=${vdu_ns_dict['vcu_${gnb_index}_vdu_ns'][${index}]}
    Start Wireshark Log In vDU   container_name=${container_name}
    ...                          pod_name=${pod_name}
    ...                          timeout=${10}
    ...                          protocol=sctp
    ...                          interface=any
    ...                          hostname=${vdu_hostname_dict['vcu_${gnb2_index}_vdu_hostname'][${index}]}
    ...                          username=${vdu_username_dict['vcu_${gnb2_index}_vdu_username'][${index}]}
    ...                          password=${vdu_password_dict['vcu_${gnb2_index}_vdu_password'][${index}]}
    ...                          namespace=${vdu_ns_dict['vcu_${gnb2_index}_vdu_ns'][${index}]}

Prepare And Attach UE
    [Arguments]    ${ue_index}=${8}    ${ui_version}=default
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
    Log to Console    \n***Prepare UE***
    Prepare UE    ${ue_${ue_index}_type}    ue_index=${ue_index}    ui_version=${ui_version}
    UE Attach    ${ue_${ue_index}_type}    ue_index=${ue_index}    verify_attach=True
    [Return]     ${ue_${ue_index}_type}

Prepare And Attach Commercial UE
    [Arguments]    ${ue_index}=${0}    ${ui_version}=MATE40PROUI1.0
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
    Log to Console    \n***Prepare UE***
    Prepare UE    ${ue_${ue_index}_type}    ue_index=${ue_index}    ui_version=${ui_version}
    UE Attach    ${ue_${ue_index}_type}    ue_index=${ue_index}    verify_attach=True
    [Return]     ${ue_${ue_index}_type}

Attach UE
    [Arguments]    ${ue_index}=${0}
    Log to Console    \n***UE Attach***
    UE Attach    ${ue_${ue_index}_type}    ue_index=${ue_index}    verify_attach=True
    sleep    60s    reason=wait attach UE Successfully

Stop Wireshark Log
    [Arguments]    ${container_name}=cpif    ${pod_name}=cpif    ${NE}=vDU
    ...            ${vcu_log_name}=vcu_wireshark    ${vdu_log_name}=vdu_wireshark
    Run Keyword If    '${NE}'=='vDU'    Stop Wireshark Log In vDU
    ...                                                           container_name=${container_name}
    ...                                                           pod_name=${pod_name}
    ...                                                           vdu_log_name=${vdu_log_name}
    ...    ELSE IF    '${NE}'=='vCU'    Stop Wireshark Log In vCU
    ...                                                           container_name=${container_name}
    ...                                                           pod_name=${pod_name}
    ...                                                           vcu_log_name=${vcu_log_name}
    ...    ELSE IF    '${NE}'=='all'    Stop Wireshark Log Both vCU And vDU
    ...                                                           container_name=${container_name}
    ...                                                           pod_name=${pod_name}
    ...                                                           vcu_log_name=${vcu_log_name}
    ...                                                           vdu_log_name=${vdu_log_name}

Stop Wireshark Log In vDU
    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cpif    ${vdu_log_name}=vdu_wireshark
    ${wireshark_local_file_path_vDU}    Stop Wireshark Log And Download To K8s Master In vDU   gnb_index=${0}
    ...                                                                    container_name=${container_name}
    ...                                                                    pod_name=${pod_name}
    ...                                                                    timeout=${10}
    ...                                                                    log_name=${vdu_log_name}
    Set Test Variable    ${wireshark_local_file_path_vDU}

Stop Wireshark Log In vCU
    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cpif    ${vcu_log_name}=vcu_wireshark
    ${wireshark_local_file_path_vCU}    Stop Wireshark Log And Download To K8s Master In vCU   gnb_index=${0}
    ...                                                                    container_name=${container_name}
    ...                                                                    pod_name=${pod_name}
    ...                                                                    timeout=${10}
    ...                                                                    log_name=${vcu_log_name}
    Set Test Variable    ${wireshark_local_file_path_vCU}

Stop Wireshark Log Both vCU And vDU
    [Arguments]    ${container_name}=cpif    ${pod_name}=cpif
    ...            ${vcu_log_name}=vcu_wireshark    ${vdu_log_name}=vdu_wireshark
    ${wireshark_local_file_path_vCU}    Stop Wireshark Log And Download To K8s Master In vCU   gnb_index=${0}
    ...                                                                    container_name=${container_name}
    ...                                                                    pod_name=${pod_name}
    ...                                                                    timeout=${10}
    ...                                                                    log_name=${vcu_log_name}
    Set Test Variable    ${wireshark_local_file_path_vCU}
    ${wireshark_local_file_path_vDU}    Stop Wireshark Log And Download To K8s Master In vDU   gnb_index=${0}
    ...                                                                    container_name=${container_name}
    ...                                                                    pod_name=${pod_name}
    ...                                                                    timeout=${10}
    ...                                                                    log_name=${vdu_log_name}
    Set Test Variable    ${wireshark_local_file_path_vDU}

Check Wireshark Log
    [Arguments]    ${input_file}=${wireshark_local_file_path_vCU}
    ${filter_list} =    Create list    f1ap.service_state == 0
    ${expect_message}=    Create list    UEContextReleaseCommand
    ${filter_length}    get length    ${filter_list}
    FOR    ${index}    IN RANGE    ${filter_length}
        ${result} =    Analysis Wireshark Log    input_file=${input_file}
        ...                                      filter_expression=${filter_list[${index}]}
        should contain    ${result}    ${expect_message[${index}]}
    END

Check Wireshark Log For CB007886In
    [Arguments]    ${input_file}=${wireshark_local_file_path_vCU}
    ${filter_list} =    Create list    f1ap.service_state == 0
    ${expect_message}=    Create list    GNBDUConfigurationUpdate
    ${filter_length}    get length    ${filter_list}
    FOR    ${index}    IN RANGE    ${filter_length}
        ${result} =    Analysis Wireshark Log    input_file=${input_file}
        ...                                      filter_expression=${filter_list[${index}]}
        should contain    ${result}    ${expect_message[${index}]}
    END

Check Wireshark Log For CB007886Out
    [Arguments]    ${input_file}=${wireshark_local_file_path_vCU}
    ${filter_list} =    Create list    f1ap.Served_Cells_To_Delete_List == 1
    ${expect_message}=    Create list    GNBDUConfigurationUpdate
    ${filter_length}    get length    ${filter_list}
    FOR    ${index}    IN RANGE    ${filter_length}
        ${result} =    Analysis Wireshark Log    input_file=${input_file}
        ...                                      filter_expression=${filter_list[${index}]}
        should contain    ${result}    ${expect_message[${index}]}
    END

Check Wireshark Log For 5GC000784
    ${wireshark_local_file_path}    Stop Wireshark Log And Download To K8s Master In vCU
    ${filter} =    catenate    ngap.priorityLevelARP == 1
    ${result} =    Analysis Wireshark Log    input_file=${wireshark_local_file_path}
	...                                      filter_expression=${filter}
	should contain      ${result}      PDUSessionResourceSetupRequest

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

Lock vDU ID-CB009881-CD-6-recommend
    ${du_id_list}=    Create List    1
    Lock vDU In vCU    du_id_list=${du_id_list}    gnb_index=0
    Get vDU Status In vCU    expected_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRDU-1   compare_value=Locked

Lock NG-C Links In vCU
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SERVEDAMF-1
    &{param}    create dictionary    operation_type=replace    parameter_path=/administrativeState
    ...                                                                         value=Locked
    @{updated_param}    Create List    ${param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=administrativeState
    ...                                                   updated_paras_dict=${updated_param}
    ...                                                   compare_value=Locked
    ...                                                   mo_dn=${mo_dn}

Unlock NG-C Links In vCU
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SERVEDAMF-1
    &{param}    create dictionary    operation_type=replace    parameter_path=/administrativeState
    ...                                                                         value=Unlocked
    @{updated_param}    Create List    ${param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=administrativeState
    ...                                                   updated_paras_dict=${updated_param}
    ...                                                   compare_value=Unlocked
    ...                                                   mo_dn=${mo_dn}
    wait until keyword succeeds    10min    20s    Check All Cells On Air In vCU


Start Call For UE
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}    ${direction}=dl    ${throughput}=110M
    Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=${direction}    dt_index=${ue_index}
	...              throughput=${throughput}    duration=${600}
	sleep    5s    reason=wait call sucessfully

Start Call For 5GC002300
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}    ${direction}=dl    ${throughput}=110M
    Log To Console    ${throughput}
    Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=${direction}    dt_index=${ue_index}
	...              throughput=110M    duration=${720}
	sleep    5s    reason=wait call sucessfully

Detach UE
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_${ue_index}_type}
    UE Detach    ${ue_type}    ue_index=${ue_index}
    sleep    60s    reason=wait detach UE Successfully

Check Counter For CB007077
    Sleep    400s    reason=wait generate counter
    ${cu_counter_id_list1}    Create List    M55138C00014    M55138C00019
    ${cu_counter_id_length1}    get length    ${cu_counter_id_list1}
    ${cu_counter_values_final_list}    Create List
    Log to Console    \n***when cell is barred, PEAK_NUMBER_OF_SA_RRC_USERS is 0,so the two counters value is 0***
    FOR    ${index}    IN RANGE    ${cu_counter_id_length1}
        ${counter_values_final1}    Check Counter For vCU   counter_id=${cu_counter_id_list1[${index}]}
        ...                                            measurement_id=55138
        ...                                            dimension_dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
        ...                                            expected_value=${-1}
        ...                                            get_number=5
        ${index}    Evaluate    ${index} + ${1}
    END


Check Counter For 5GC002060
    Sleep    360s    reason=wait generate counter
    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    &{type1_counter_dict}    create dictionary    counterId=M55308C11001,M55308C11002
    ...                                           dimDN=${dim_dn}/NRCELL-1
    ...                                           ne=vDU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    ${counter_list}    Create List    ${type1_counter_dict}

    FOR    ${counter}    IN    @{counter_list}
        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
        ${ne}    Set Variable   ${counter['ne']}

        Run Keyword If    '${ne}'=='vDU'     Check Counter In vDU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
        ...    ELSE IF    '${ne}'=='vCU'    Check Counter In vCU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
    END

Check Counter For 5GC000784
    Sleep    600s    reason=wait generate counter
    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    &{type1_counter_dict}    create dictionary    counterId=M55118C04014,M55118C04015,M55125C09025,M55125C09026,M55125C09027,M55125C09028,M55125C09029
    ...                                           dimDN=${dim_dn}/NRCELL-1
    ...                                           ne=vCU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    ${type1_counter_list}    Create List    ${type1_counter_dict}

    FOR    ${counter}    IN    @{type1_counter_list}
        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
        ${ne}    Set Variable   ${counter['ne']}

        Run Keyword If    '${ne}'=='vDU'     Check Counter In vDU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
        ...    ELSE IF    '${ne}'=='vCU'    Check Counter In vCU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
    END

Check Any One Value In Multiple Counters for 5GC000503
    Sleep    360s    reason=wait generate counter
    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}

    ${DL_PDCP_NUM_counter}    Generate Counter PIId    start_id=M55314C02001    stop_id=M55314C02020
    ${DL_PDCP_VOL_counter}    Generate Counter PIId    start_id=M55314C03001    stop_id=M55314C03020
    ${UL_PDCP_NUM_counter}    Generate Counter PIId    start_id=M55314C04001    stop_id=M55314C04020
    ${UL_PDCP_VOL_counter}    Generate Counter PIId    start_id=M55314C05001    stop_id=M55314C05020
    ${MAX_DL_PDCP_counter}    Generate Counter PIId    start_id=M55314C14001    stop_id=M55314C14020
    ${MAX_UL_PDCP_counter}    Generate Counter PIId    start_id=M55314C16001    stop_id=M55314C16020

    &{type1_counter_dict}    create dictionary    counterId=${DL_PDCP_NUM_counter}
    ...                                           dimDN=${dim_dn}/NRDU-1
    ...                                           ne=vDU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    &{type2_counter_dict}    create dictionary    counterId=${DL_PDCP_VOL_counter}
    ...                                           dimDN=${dim_dn}/NRDU-1
    ...                                           ne=vDU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    &{type3_counter_dict}    create dictionary    counterId=${UL_PDCP_NUM_counter}
    ...                                           dimDN=${dim_dn}/NRDU-1
    ...                                           ne=vDU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    &{type4_counter_dict}    create dictionary    counterId=${UL_PDCP_VOL_counter}
    ...                                           dimDN=${dim_dn}/NRDU-1
    ...                                           ne=vDU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    &{type6_counter_dict}    create dictionary    counterId=${MAX_DL_PDCP_counter}
    ...                                           dimDN=${dim_dn}/NRDU-1
    ...                                           ne=vDU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0

    ${counter_list}    Create List    ${type1_counter_dict}    ${type2_counter_dict}     ${type3_counter_dict}
    ...    ${type4_counter_dict}    ${type6_counter_dict}
    FOR    ${counter}    IN    @{counter_list}
        ${ne}    Set Variable   ${counter['ne']}
        Run Keyword If    '${ne}'=='vDU'     Check Any One Value In Multiple Counters In vDU
        ...                                                         counter_id_list=${counter['counterId']}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
        ...    ELSE IF    '${ne}'=='vCU'    Check Any One Value In Multiple Counters In vCU
        ...                                                         counter_id_list=${counter['counterId']}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
    END

Check Counter For 5GC002300
    Sleep    600s    reason=wait generate counter
    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    &{type1_counter_dict}    create dictionary    counterId=M55324C00101,M55324C00201,M55324C00301,M55324C00401,M55324C00501
    ...                                           dimDN=${dim_dn}/NRCELL-1
    ...                                           ne=vDU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    &{type2_counter_dict}    create dictionary    counterId=M55324C00601,M55324C00701,M55324C00800,M55324C00801,M55324C00802
    ...                                           dimDN=${dim_dn}/NRCELL-1
    ...                                           ne=vDU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    ${type1_counter_list}    Create List    ${type1_counter_dict}
    ${type2_counter_list}    Create List    ${type2_counter_dict}

    FOR    ${counter}    IN    @{type1_counter_list}
        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
        ${ne}    Set Variable   ${counter['ne']}

        Run Keyword If    '${ne}'=='vDU'     Check Counter In vDU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
        ...    ELSE IF    '${ne}'=='vCU'    Check Counter In vCU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
    END

    FOR    ${counter}    IN    @{type2_counter_list}
        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
        ${ne}    Set Variable   ${counter['ne']}

        Run Keyword If    '${ne}'=='vDU'     Check Counter In vDU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
        ...    ELSE IF    '${ne}'=='vCU'    Check Counter In vCU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
    END

Check SA Counter For 46002
    Sleep    300s    reason=wait generate counter
    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    &{type1_counter_dict}    create dictionary    counterId=M55338C00001,M55338C00002
    ...                                           dimDN=${dim_dn}/NRCELL-1/MCC-460/MNC-02
    ...                                           ne=vDU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    &{type2_counter_dict}    create dictionary    counterId=M55326C01001,M55326C02007,M55326C01002,M55326C03007
    ...                                           dimDN=${dim_dn}/MCC-460/MNC-02
    ...                                           ne=vCU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    &{type3_counter_dict}    create dictionary    counterId=M55145C00220,M55145C00223
    ...                                           dimDN=${dim_dn}/NRCELL-1/MCC-460/MNC-02
    ...                                           ne=vCU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    &{type4_counter_dict}    create dictionary    counterId=M55149C01003
    ...                                           dimDN=${dim_dn}/MCC-460/MNC-02/SST-1/SD-13714341
    ...                                           ne=vCU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    ${type1_counter_list}    Create List    ${type1_counter_dict}
    ${type2_counter_list}    Create List    ${type2_counter_dict}
    ${type3_counter_list}    Create List    ${type3_counter_dict}
    ${type4_counter_list}    Create List    ${type4_counter_dict}

    FOR    ${counter}    IN    @{type1_counter_list}
        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
        ${ne}    Set Variable   ${counter['ne']}

        Run Keyword If    '${ne}'=='vDU'     Check Counter In vDU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
        ...    ELSE IF    '${ne}'=='vCU'    Check Counter In vCU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
    END

    FOR    ${counter}    IN    @{type2_counter_list}
        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
        ${ne}    Set Variable   ${counter['ne']}

        Run Keyword If    '${ne}'=='vDU'     Check Counter In vDU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
        ...    ELSE IF    '${ne}'=='vCU'    Check Counter In vCU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
    END

    FOR    ${counter}    IN    @{type3_counter_list}
        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
        ${ne}    Set Variable    ${counter['ne']}

        Run Keyword If    '${ne}'=='vDU'    Check Counter In vDU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
        ...    ELSE IF    '${ne}'=='vCU'    Check Counter In vCU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
    END

    FOR    ${counter}    IN    @{type4_counter_list}
        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
        ${ne}    Set Variable    ${counter['ne']}

        Run Keyword If    '${ne}'=='vDU'    Check Counter In vDU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
        ...    ELSE IF    '${ne}'=='vCU'    Check Counter In vCU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
    END

Check SA Counter For 26203
    Sleep    600s    reason=wait generate counter
    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    &{type1_counter_dict}    create dictionary    counterId=M55338C00001,M55338C00002
    ...                                           dimDN=${dim_dn}/NRCELL-1/MCC-262/MNC-03
    ...                                           ne=vDU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    &{type2_counter_dict}    create dictionary    counterId=M55326C01001,M55326C02005
    ...                                           dimDN=${dim_dn}/MCC-262/MNC-03
    ...                                           ne=vCU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    &{type3_counter_dict}    create dictionary    counterId=M55145C00220,M55145C00223
    ...                                           dimDN=${dim_dn}/NRCELL-1/MCC-262/MNC-03
    ...                                           ne=vCU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    ${type1_counter_list}    Create List    ${type1_counter_dict}
    ${type2_counter_list}    Create List    ${type2_counter_dict}
    ${type3_counter_list}    Create List    ${type3_counter_dict}

    FOR    ${counter}    IN    @{type1_counter_list}
        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
        ${ne}    Set Variable   ${counter['ne']}

        Run Keyword If    '${ne}'=='vDU'     Check Counter In vDU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
        ...    ELSE IF    '${ne}'=='vCU'    Check Counter In vCU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
    END

    FOR    ${counter}    IN    @{type2_counter_list}
        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
        ${ne}    Set Variable   ${counter['ne']}

        Run Keyword If    '${ne}'=='vDU'     Check Counter In vDU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
        ...    ELSE IF    '${ne}'=='vCU'    Check Counter In vCU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
    END

    FOR    ${counter}    IN    @{type3_counter_list}
        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
        ${ne}    Set Variable   ${counter['ne']}

        Run Keyword If    '${ne}'=='vDU'     Check Counter In vDU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
        ...    ELSE IF    '${ne}'=='vCU'    Check Counter In vCU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
    END


Check NSA Counter For 26203
    Sleep    600s    reason=wait generate counter
    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    &{type1_counter_dict}    create dictionary    counterId=M55338C00001,M55338C00002
    ...                                           dimDN=${dim_dn}/NRCELL-1/MCC-262/MNC-03
    ...                                           ne=vDU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    &{type2_counter_dict}    create dictionary    counterId=M55326C01001,M55326C02005
    ...                                           dimDN=${dim_dn}/MCC-262/MNC-03
    ...                                           ne=vCU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    ${type1_counter_list}    Create List    ${type1_counter_dict}
    ${type2_counter_list}    Create List    ${type2_counter_dict}

    FOR    ${counter}    IN    @{type1_counter_list}
        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
        ${ne}    Set Variable   ${counter['ne']}

        Run Keyword If    '${ne}'=='vDU'     Check Counter In vDU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
        ...    ELSE IF    '${ne}'=='vCU'    Check Counter In vCU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
    END

    FOR    ${counter}    IN    @{type2_counter_list}
        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
        ${ne}    Set Variable   ${counter['ne']}

        Run Keyword If    '${ne}'=='vDU'     Check Counter In vDU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
        ...    ELSE IF    '${ne}'=='vCU'    Check Counter In vCU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
    END

Check Counter For 5GC002637
    Sleep    900s    reason=wait generate counter
    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    &{type1_counter_dict}    create dictionary    counterId=M55350C00007,M55350C01007,M55350C03007,M55350C02001,M55350C04001,M55350C07001,M55350C08001
    ...                                           dimDN=${dim_dn}/NRCELL-1
    ...                                           ne=vCU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    ${counter_list}    Create List    ${type1_counter_dict}

    FOR    ${counter}    IN    @{counter_list}
        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
        ${ne}    Set Variable   ${counter['ne']}

        Run Keyword If    '${ne}'=='vDU'     Check Counter In vDU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
        ...    ELSE IF    '${ne}'=='vCU'    Check Counter In vCU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
    END

Check Counter For 5GC000749
    Sleep    300s    reason=wait generate counter
    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    &{type1_counter_dict}    create dictionary    counterId=M55124C02501
    ...                                           dimDN=${dim_dn}/NRCELL-1
    ...                                           ne=vCU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    ${type1_counter_list}    Create List    ${type1_counter_dict}

    FOR    ${counter}    IN    @{type1_counter_list}
        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
        ${ne}    Set Variable   ${counter['ne']}

        Run Keyword If    '${ne}'=='vDU'     Check Counter In vDU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
        ...    ELSE IF    '${ne}'=='vCU'    Check Counter In vCU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
    END

Check Counter In vDU
    [Arguments]    ${counter_id_list}    ${dim_dn}    ${gnb_index}=0
    ...            ${comparison}=greater    ${expected_value}=0    ${get_number}=3
    Log to Console    \n***check counter in vDU***
    FOR    ${counter_id}    IN    @{counter_id_list}
        Check Counter For vDU   counter_id=${counter_id}
        ...                     dimension_dn=${dim_dn}
        ...                     comparison=${comparison}
        ...                     expected_value=${expected_value}
        ...                     get_number=${get_number}
        ...                     gnb_index=${gnb_index}
    END

Check Counter In vCU
    [Arguments]    ${counter_id_list}    ${dim_dn}    ${gnb_index}=0
    ...            ${comparison}=greater    ${expected_value}=0    ${get_number}=3
    Log to Console    \n***check counter in vCU***
    FOR    ${counter_id}    IN    @{counter_id_list}
        @{words}=    split string    ${counter_id}   C
        ${mea_id}=   Fetch From Right    ${words[0]}  M

        Check Counter For vCU   counter_id=${counter_id}
        ...                     measurement_id=${mea_id}
        ...                     dimension_dist_name=${dim_dn}
        ...                     comparison=${comparison}
        ...                     expected_value=${expected_value}
        ...                     get_number=${get_number}
        ...                     gnb_index=${gnb_index}
    END

Check Any One Value In Multiple Counters
    Sleep    360s    reason=wait generate counter
    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}

    ${avg_ul_rip_counter}    Generate Counter PIId    start_id=M55360C00000    stop_id=M55360C00272
    ${max_ul_rip_counter}    Generate Counter PIId    start_id=M55360C01000    stop_id=M55360C01272

    &{type1_counter_dict}    create dictionary    counterId=${avg_ul_rip_counter}
    ...                                           dimDN=${dim_dn}/NRCELL-1
    ...                                           ne=vDU
    ...                                           gnbIndex=0
    ...                                           comparison=less
    ...                                           value=0
    &{type2_counter_dict}    create dictionary    counterId=${max_ul_rip_counter}
    ...                                           dimDN=${dim_dn}/NRCELL-1
    ...                                           ne=vDU
    ...                                           gnbIndex=0
    ...                                           comparison=less
    ...                                           value=0
    ${counter_list}    Create List    ${type1_counter_dict}    ${type2_counter_dict}
    FOR    ${counter}    IN    @{counter_list}
        ${ne}    Set Variable   ${counter['ne']}
        Run Keyword If    '${ne}'=='vDU'     Check Any One Value In Multiple Counters In vDU
        ...                                                         counter_id_list=${counter['counterId']}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
        ...    ELSE IF    '${ne}'=='vCU'    Check Any One Value In Multiple Counters In vCU
        ...                                                         counter_id_list=${counter['counterId']}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
    END

Check Any One Value In Multiple Counters In vDU
    [Arguments]    ${counter_id_list}    ${dim_dn}    ${gnb_index}=0
    ...            ${comparison}=greater    ${expected_value}=0    ${get_number}=3
    Log to Console    \n***check any one value in multiple counters in vDU***
    ${status}=   set variable   False
    ${counter_values_final_list}    Create List
    FOR    ${counter_id}    IN    @{counter_id_list}
        ${counter_values_final_list}    Run Keyword And Ignore Error    Check Counter For vDU
        ...                                            counter_id=${counter_id}
        ...                                            dimension_dn=${dim_dn}
        ...                                            comparison=${comparison}
        ...                                            expected_value=${expected_value}
        ...                                            get_number=${get_number}
        ...                                            gnb_index=${gnb_index}
        ${status}=    set variable if    '${counter_values_final_list[0]}'=='PASS'    True
        exit for loop if    '${status}'=='True'
    END
    should be equal    ${status}    True    Check counter value failed!

Check Any One Value In Multiple Counters In vCU
    [Arguments]    ${counter_id_list}    ${dim_dn}    ${gnb_index}=0
    ...            ${comparison}=greater    ${expected_value}=0    ${get_number}=3
    Log to Console    \n***check any one value in multiple counters in vCU***
    ${status}=   set variable   False
    ${counter_values_final_list}    Create List
    FOR    ${counter_id}    IN    @{counter_id_list}
        @{words}=    split string    ${counter_id}   C
        ${mea_id}=   Fetch From Right    ${words[0]}  M
        ${counter_values_final_list}    Run Keyword And Ignore Error    Check Counter For vCU
        ...                                            counter_id=${counter_id}
        ...                                            measurement_id=${mea_id}
        ...                                            dimension_dist_name=${dim_dn}
        ...                                            comparison=${comparison}
        ...                                            expected_value=${expected_value}
        ...                                            get_number=${get_number}
        ...                                            gnb_index=${gnb_index}
        ${status}=    set variable if    '${counter_values_final_list[0]}'=='PASS'    True
        exit for loop if    '${status}'=='True'
    END
    should be equal    ${status}    True    Check counter value failed!

Check Counter In vDU And vCU
    [Arguments]    ${expected_value}=0    ${get_number}=5    ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    ...            ${du_counter_id_list}=M55308C11001    ${cu_counter_id_list}=M55147C00024    ${gnb_index}=0
    Sleep    300s    reason=wait generate counter
    ${du_counter_values_final_list}    Create List
    FOR    ${du_counter_id}    IN    @{du_counter_id_list}
        ${du_counter_values_final_list}    Check Counter For vDU   counter_id=${du_counter_id}
        ...                                            dimension_dn=${mo_dn}
        ...                                            expected_value=${expected_value}
        ...                                            get_number=${get_number}
        ...                                            gnb_index=${gnb_index}
    END
    @{words}=    split string  ${cu_counter_id_list[0]}   C
    ${mea_id}=   Fetch From Right  ${words[0]}  M
    ${cu_counter_values_final_list}    Create List
    FOR    ${cu_counter_id}    IN    @{cu_counter_id_list}
        ${cu_counter_values_final_list}    Check Counter For vCU   counter_id=${cu_counter_id}
        ...                                            measurement_id=${mea_id}
        ...                                            dimension_dist_name=${mo_dn}
        ...                                            expected_value=${expected_value}
        ...                                            get_number=${get_number}
        ...                                            gnb_index=${gnb_index}
    END

Start VONR Call For UE
    [Arguments]    ${ue_index}=${8}     ${capabilities}=huawei1
    Start VONR Call    ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    vc_alias=VC_1    call_number=004488
    ...            duration=600s    capabilities=${capabilities}



Start VONR Call Without Require UE
    [Arguments]    ${ue_index}=${0}
#    ute_ue.detach_ue    UE_${ue_index}
#    ute_ue.attach_ue    UE_${ue_index}
#    Sleep    5
#    Detach UE0
#    Attach UE0
    Start Voice Call    vc_alias=VC_1   ue_alias=UE_${ue_index}    to=004488    duration=600s

Start Emergency Call For UE
    [Arguments]    ${ue_index}=${0}     ${capabilities}=huawei1
    Log To Console    \n***Start Emergency call***
    Start VONR Call    ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    vc_alias=VC_1    call_number=911
    ...            duration=600s    capabilities=${capabilities}

Stop VONR Call For UE
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}
    Log To Console    \n*** Stop VONR Call***
    Stop VONR Call    ue_type=${ue_type}      vc_alias=VC_1

Check VONR Call
    [Arguments]      ${expected_status}=hold
    Log to Console    \n***Check VONR Call Status***
    ${vc_status} =    Check VONR Call Status    vc_alias=VC_1
    should be equal    "${vc_status}"  "${expected_status}"   The status of Voice Call is not expected!

Get DL Call Avg Tput
    [Arguments]    ${ue_index}=${0}
    ${dl_tp}    ${ul_tp}    Get Average Throughput    ue_index=${ue_index}    period=${period}
    ${avg_dl_tput}    Evaluate    ${dl_tp}/1048576
    [Return]    ${avg_dl_tput}

Check DL Call Status
    [Arguments]    ${ue_index}=${0}
    ${dl_tp}    ${ul_tp}    Get Average Throughput    ue_index=${ue_index}
    ${avg_dl_tput}    Evaluate    ${dl_tp}/1048576
    Should Be True  ${avg_dl_tput}>10

Check Emergency Call Status
    [Arguments]      ${expected_status}=hold
    Log to Console    \n***Check Emergency Call Status***
    ${vc_status} =    Check VONR Call Status    vc_alias=VC_1
    should be equal    "${vc_status}"  "${expected_status}"   The status of Emergency Call is not expected!

Check Cell Is Actived
    [Arguments]        ${expected_value}=1
    ${cell_number}    Get VDU Cell Number From SCF    vdu_index=${0}    gnb_index=${0}
    ${alias}=    get unique id
    vDU Login By Rest    vdu_index=${0}    gnb_index=${0}    alias=${alias}
    ${vdu_cells_summary}=    vdu.get_vdu_cells_summary    vdu_connection=${alias}
    ${expected_value}    set variable    ${cell_number}
    ${enabled_number}    set variable    ${vdu_cells_summary['basic_cells_summary']['operational_state']['enabled']}
    should be equal     "${enabled_number}"    "${expected_value}"    Cell State is not expected

Check Cell Is Deactived
    [Arguments]        ${expected_value}=1
    ${cell_number}    Get VDU Cell Number From SCF    vdu_index=${0}    gnb_index=${0}
    ${alias}=    get unique id
    vDU Login By Rest    vdu_index=${0}    gnb_index=${0}    alias=${alias}
    ${vdu_cells_summary}=    vdu.get_vdu_cells_summary    vdu_connection=${alias}
    ${expected_value}     set variable    ${cell_number}
    ${disabled_number}    set variable    ${vdu_cells_summary['basic_cells_summary']['operational_state']['disabled']}
    should be equal     "${disabled_number}"    "${expected_value}"    Cell State is not expected

Check SNSSAI Status
    Log To Console     check Slice status
    [Arguments]    ${gnb_index}=0    ${expected_admin_value}=Unlocked    ${expected_operational_value}=enabled
    ...            ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SNSSAI-1
    ${parameter1_name}    set variable    administrativeState
    ${parameter2_name}    set variable    operationalState
    ${para_value1}    Get Parameters Of Current Plan Via Rest    parameter_name=${parameter1_name}
    ...              gnb_index=${gnb_index}    mo_dn=${mo_dn}
    Should Be True    "${para_value1}" == "${expected_admin_value}"
    ${para_value2}    Get Parameters Of Current Plan Via Rest    parameter_name=${parameter2_name}
    ...              gnb_index=${gnb_index}    mo_dn=${mo_dn}
    Should Be True    "${para_value2}" == "${expected_operational_value}"

Remove SNSSAI_2 Of TAC in vCU
    Log To Console     Remove Slice_2 with TAC in vCU
    ${mo_dn}     Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/TRACKINGAREA-1
    &{param}    create dictionary     operation_type=remove    parameter_path=/snssaiDNList/1
    ...                         value=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SNSSAI-2
    @{updated_param}     Create List    ${param}

    Login To vCU By Rest    gnb_index=${0}
    Online Modify Single Mo Parameters Via Rest In vCU     para_list=${updated_param}    mo_dn=${mo_dn}
    [Teardown]  Logout To vCU By Rest

Add SNSSAI_2 with TAC in vCU
    Log To Console     Add Slice_2 with TAC in vCU
    ${mo_dn}     Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/TRACKINGAREA-1
    &{param}    create dictionary     operation_type=add    parameter_path=/snssaiDNList/1
    ...                         value=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SNSSAI-2
    @{updated_param}     Create List    ${param}

    Login To vCU By Rest    gnb_index=${0}
    Online Modify Single Mo Parameters Via Rest In vCU     para_list=${updated_param}    mo_dn=${mo_dn}
    [Teardown]  Logout To vCU By Rest

Check Modify Parameter Status
    [Arguments]    ${mo_dn}    ${para_name}    ${expect_value}    ${gnb_index}=${0}
    vDU Login By Rest    gnb_index=${gnb_index}
    ${value}=    Online Get VDU Parameter Value     ${mo_dn}    ${para_name}
    Log To Console    \n*** Get the value of ${para_name} is ${value} from vDU***
    Should Be True    "${value}" == "${expect_value}"    Modify Parameters Failed
    [Teardown]    vDU Logout By Rest    vdu_index=0

Compare Historical Alarms And Generate Difference
    [Arguments]   ${NE_TYPE}
    ${origin_alarm_file}    Set Variable    ${TEST_LOG_DIRECTORY}/${NE_TYPE}_alarm_setup/${NE_TYPE}_historical_alarm.csv
    ${target_alarm_file}    Set Variable    ${TEST_LOG_DIRECTORY}/${NE_TYPE}_alarm_teardown/${NE_TYPE}_historical_alarm.csv
    ${add_alarms}    ${clear_alarms}    aic_param.compare_alarms    ${origin_alarm_file}    ${target_alarm_file}
    ${file}    create_a_file    log_path=${TEST_LOG_DIRECTORY}/${NE_TYPE}_alarm_diff
    ...                         file_name=${NE_TYPE}_historical_alarm_diff.csv
    aic_param.store_alarms_to_csvfile    ${add_alarms}    ${file}
    aic_param.store_alarms_to_csvfile    ${clear_alarms}    ${file}

Collect K8s Log With Cprt
    sleep    30s    reason=wait cpue log generate
    Log to Console    \n***Collect And Download Cpue Log In vCU***
    ${cprt_log}    Collect And Download K8s Log In vDU    gnb_index=${0}    vdu_index=${0}    container_name=cprt
    ...                                                          pod_name=cprt    timeout=${10}    duration=300s
    Set Test Variable    ${cprt_log}

Collect K8s Log With Cpue
    sleep    30s    reason=wait cpue log generate
    Log to Console    \n***Collect And Download Cpue Log In vCU***
    ${cpue_log}    Collect And Download K8s Log In vCU    gnb_index=${0}    vdu_index=${0}    container_name=cpue
    ...                                                          pod_name=cpue    timeout=${10}    duration=300s
    Set Test Variable    ${cpue_log}

Lock All NG-C Links
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SERVEDAMF-1
    ${mo_dn1}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SERVEDAMF-2
    ${mo_dn2}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SERVEDAMF-3
    &{param}    create dictionary    operation_type=replace    parameter_path=/administrativeState
    ...                                                                         value=Locked
    @{updated_param}    Create List    ${param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=administrativeState
    ...                                                   updated_paras_dict=${updated_param}
    ...                                                   compare_value=Locked
    ...                                                   mo_dn=${mo_dn}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=administrativeState
    ...                                                   updated_paras_dict=${updated_param}
    ...                                                   compare_value=Locked
    ...                                                   mo_dn=${mo_dn1}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=administrativeState
    ...                                                   updated_paras_dict=${updated_param}
    ...                                                   compare_value=Locked
    ...                                                   mo_dn=${mo_dn2}
    sleep    60s    reason=wait generate counter

Lock X2 Links In vCU
    [Arguments]    ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/LTEENB-0
    &{param}    create dictionary    operation_type=replace    parameter_path=/x2LinkLock
    ...                                                                         value=locked
    @{updated_param}    Create List    ${param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=x2LinkLock
    ...                                                   updated_paras_dict=${updated_param}
    ...                                                   compare_value=locked
    ...                                                   mo_dn=${mo_dn}

Unlock X2 Links In vCU
    [Arguments]    ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/LTEENB-0
    &{param}    create dictionary    operation_type=replace    parameter_path=/x2LinkLock
    ...                                                                         value=unlocked
    @{updated_param}    Create List    ${param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=x2LinkLock
    ...                                                   updated_paras_dict=${updated_param}
    ...                                                   compare_value=unlocked
    ...                                                   mo_dn=${mo_dn}
    Sleep    240s    reason=wait x2 link available

Unlock One NG-C Links In vCU
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SERVEDAMF-1
    &{param}    create dictionary    operation_type=replace    parameter_path=/administrativeState
    ...                                                                         value=Unlocked
    @{updated_param}    Create List    ${param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=administrativeState
    ...                                                   updated_paras_dict=${updated_param}
    ...                                                   compare_value=Unlocked
    ...                                                   mo_dn=${mo_dn}
    wait until keyword succeeds    10min    20s    Check All Cells On Air In vCU

Check NG Links Status
    [Arguments]    ${gnb_index}=0    ${expected_value1}=Unlocked    ${expected_value2}=Active
    ...            ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SERVEDAMF-1
    ${parameter1_name}    set variable    administrativeState
    ${parameter2_name}    set variable    ngLinkStatus
    ${para_value1}    Get Parameters Of Current Plan Via Rest    parameter_name=${parameter1_name}
    ...              gnb_index=${gnb_index}    mo_dn=${mo_dn}
    Should Be True    "${para_value1}" == "${expected_value1}"
    ${para_value2}    Get Parameters Of Current Plan Via Rest    parameter_name=${parameter2_name}
    ...              gnb_index=${gnb_index}    mo_dn=${mo_dn}
    Should Be True    "${para_value2}" == "${expected_value2}"

Unlock One X2 Link In vCU
    [Arguments]    ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/LTEENB-0
    &{param}    create dictionary    operation_type=replace    parameter_path=/x2LinkLock
    ...                                                                         value=unlocked
    @{updated_param}    Create List    ${param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=x2LinkLock
    ...                                                   updated_paras_dict=${updated_param}
    ...                                                   compare_value=unlocked
    ...                                                   mo_dn=${mo_dn}
    Sleep    240s    reason=wait x2 link available

Check Wireshark For CB008926
    [Arguments]    ${input_file}=${wireshark_local_file_path_vCU}
    ${filter_list} =    Create list      f1ap.ResetType == 1
    ${expect_message}=    Create list    Reset
    ${filter_length}    get length    ${filter_list}
    FOR    ${index}    IN RANGE    ${filter_length}
        ${result} =    Analysis Wireshark Log    input_file=${input_file}
        ...                                      filter_expression=${filter_list[${index}]}
        should contain    ${result}    ${expect_message[${index}]}
    END

Delete Pod In VDU
    [Arguments]  ${gnb_index}=0      ${vdu_index}=0      ${pod_name}=l2nrt     ${alias}=vdu_master
    ${hostname}    Set Variable    ${vdu_hostname_dict['vcu_${gnb_index}_vdu_hostname'][${vdu_index}]}
    ${username}    Set Variable    ${vdu_username_dict['vcu_${gnb_index}_vdu_username'][${vdu_index}]}
    ${password}    Set Variable    ${vdu_password_dict['vcu_${gnb_index}_vdu_password'][${vdu_index}]}
    ${namespace}   Set Variable    ${vdu_ns_dict['vcu_${gnb_index}_vdu_ns'][${vdu_index}]}
    Delete Pod   pod_name=${pod_name}    alias=${alias}
    ...                          hostname=${hostname}
    ...                          username=${username}
    ...                          password=${password}
    ...                          namespace=${namespace}