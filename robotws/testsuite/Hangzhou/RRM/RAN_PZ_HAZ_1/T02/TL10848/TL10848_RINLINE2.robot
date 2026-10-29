*** Settings ***
Documentation
...    Author: Wei Cici
...    Contact: cici.wei@nokia-sbell.com
...    this file is collect some Common KWs of AIC,you can use it in your case directly.
...    Please do not modify the file without notification to author
...    Deprecated case removed by civen.chen

#
#Suite Setup    Common Suite Setup For AIC
#Suite Teardown    Common Suite Teardown For AIC
#
#Force Tags
#...      CRT             #Tag Item
#...      RAN_PZ_HAZ_1             #Competence Area
#...      RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
#...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]
#
#Test Timeout    600 minutes
#
#Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
#Resource          ../../T02/Common_Case/common_resource_new.robot
#
#*** Test Cases ***
#CB010411_5GC000747_Successful_ETWS_primary_notification_broadcast
#    [Tags]      CRT    5GC000747_ETWS_primary    Thor_debug_ok
#    [Documentation]
#    ...    Author: sudi.lou@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    8.2.2023,sudi.lou@nokia-sbell.com, draft
#    [Setup]      Case Precondition
#	@{para_list}          Create List    actETWS
#    @{mo_list_vcu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    @{value_list_true}    Create List    true
#    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
#    ...                  mo_list_vdu=@{mo_list_vcu}    product_type=vcu
#    Prepare And Attach UE    ue_index=1
#    Set Mobile Data    ue_index=1    state=off    connection=cygwin
#    Start Collect Wireshark Log    NE=all
#    Trigger CMAS Notification For SIB6
#    Sleep    5s    reason=wait logs to be generated
#    Stop Wireshark Log    NE=all
#    Check Write Replace Warning In Log    input_file=${wireshark_local_file_path_vCU}    sib_type=SIB6
#    Check Counter For ETWS
#    [Teardown]    5GC000747_ETWS_primary Postcondition
#
#CB010411_5GC002645_PWS_Restart_Indication
#    [Tags]      CRT    5GC002645
#    [Documentation]
#    ...    Author: juan.liu@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    16.1.2024,juan.liu@nokia-sbell.com, draft
#    [Setup]      Case Precondition
#	@{para_list}          Create List    pwsRestIndEnabled
#    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    @{value_list_true}    Create List    true
#    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
#    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vdu
#    @{para_list}          Create List    actCMAS
#    @{mo_list_vcu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    @{value_list_true}    Create List    true
#    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
#    ...                  mo_list_vdu=@{mo_list_vcu}    product_type=vcu
#    Prepare And Attach UE    ue_index=2    ui_version=S21
#    Start Collect Wireshark Log    NE=all
#    Trigger CMAS Notification
#    Lock Cell
#    Unlock Cell
#    Stop Wireshark Log    NE=all
#    Check Counter For 5GC002645
#    [Teardown]    5GC002645 Postcondition
#
#CB010411_CB008120_Successful_inter-gNB_NG_based_handover_when_Slice_configuration_with_SST_value_from_new_range
#    [Tags]    CRT    CB008120
#    [Documentation]
#    ...    Author: juan.liu@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    16.1.2024,juan.liu@nokia-sbell.com, draft
#    [Setup]    Case Precondition
#    Lock Xn Link
#    Prepare And Attach UE    ue_index=1
#    Start Call For UE    ue_index=1    direction=dl
#    Start Collect Wireshark Log In Target vCU
#    Trigger intra Fre inter gnb based Handover For CB008120
#    Stop target Wireshark Log
#    Check SST And NG HO In Wireshark
#    Check Counter For NG A3 Handover    sst=2
#    [Teardown]    CB008120 Postcondition
#
#CB010414_CB008737_A_02_testing_scenarios_related_to_reset_VDU
#    [Tags]    CRT   CB008737_A
#    [Documentation]
#    ...    Author: cici.wei@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    20.5.2024,cici.wei@nokia-sbell.com, draft
#    [Setup]      Case Precondition
#	@{para_list}          Create List    actSshToRanNic
#    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
#    @{value_list_true}    Create List    true
#    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
#    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vdu
#    Update Service Account Passwd In vDU By Rest Api    username=serviceuser    new_password=Nokia@123
#
#    ${rannic_r_dn}    Set Variable   MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/RNICMOD_R-1
#    Config SSH Tunnel    dist_name=${rannic_r_dn}    operation=Enable
#    Check Service Account SSH State    ssh_mode_type=RNICMOD    dist_name=${rannic_r_dn}    expected_status=Activated
#    ${l1commproxy_k8s_log}    Collect Container Log    pod_name=ahm    container_name=l1commproxy
#    Check ssh tunnel configuration in Log    log_path=${l1commproxy_k8s_log}
#    ${rannic_conn}    Connect Ru Or Rannic Via SSH Tunnel Port    ssh_type=RNICMOD    password=Nokia@123
#    ...                                                    ssh_mode_dist_name=${rannic_r_dn}
#    Set Test Variable    ${rannic_conn}
#	Reset vDU With Check Cell On Air    need_check_on_air=${True}
#	@{para_list}          Create List    actSshToRanNic
#    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
#    @{value_list_true}    Create List    false
#    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
#    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vdu
#    Run Keyword And Ignore Error    Check Ssh Session Status    ${rannic_conn}
#    ${l1commproxy_k8s_log_new}    Collect Container Log    pod_name=ahm    container_name=l1commproxy
# #   Check Sshd Session Status in Log    log_path=${l1commproxy_k8s_log_new}    session_status=closed
#    [Teardown]    CB008737_B Postcondition
#
#CB011169_03_CB012533-A_verification_of_migration_of_DFT_beams_power_threshold_parameters_while_upgrading_SW_from_N-1_to_N_release
#	[Tags]    CRT   CB011169
#    [Documentation]
#    ...    Author: cici.wei@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    20.5.2024,cici.wei@nokia-sbell.com, draft
#    [Setup]      Case Precondition
#	@{para_list}          Create List    dftBeamDiffThresholdH
#    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#    @{value_list_true}    Create List    15
#    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
#    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vdu
#	@{para_list}          Create List    dftBeamDiffThresholdV
#    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#    @{value_list_true}    Create List    15
#    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
#    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vdu
#	Prepare And Attach UE    ue_index=1
#    [Teardown]    CB011169 Postcondition
#
#CB011178_Successful_Intra_DU_handover_between_FDD_TDD_cells_with_emergency_and_data_traffic
#    [Tags]    CRT    CB011178_HO
#    [Documentation]
#    ...    Author: juan.liu@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    16.1.2024,juan.liu@nokia-sbell.com, draft
#    [Setup]    Case Precondition
##    Adjust The Signal Via PA    10846_cell1=20    10846_cell2=120
#    Start Collect Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU
##    Prepare And Attach UE    ue_index=0
##    Start Call For UE    ue_index=0    direction=dl
##    Start Emergency Call For UE   ue_index=0
##    Adjust The Signal Via PA    10846_cell2=30
##    Trigger A3 Handover FDD To TDD Cell
##    Check Counter For FDD To TDD
##    Stop VONR Call For UE    ue_index=0
##    Adjust The Signal Via PA    10846_cell1=120    10846_cell2=10
##    Prepare And Attach UE    ue_index=0
##    Start Call For UE    ue_index=0    direction=dl
##    Adjust The Signal Via PA    10846_cell1=20
##    Trigger A3 Handover TDD To FDD Cell
#    Stop Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU
#    [Teardown]    CB011178_HO Postcondition
#
#CB012125_17_Recalculate_feature_using_online_WEBEM_with_actual_configuration_conf21
#    [Tags]    CRT    CB012125_17
#    [Documentation]
#    ...    Author: juan.liu@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    [Setup]    CB012125 Case Precondition
#    Download FCE For Current SW
#    Install Valid FCE And Verify Result
#    ${list_FCE_features}    Get FCE Feature List
#    Select Expected FCE From Droplist    expected_FCE_feature_name=${list_FCE_features[0]}
#    Calculate On CA Page And Get Results
#    Get FCT Caculate Result
#    Prepare And Attach UE    ue_index=2    ui_version=S21
#    Start Call For UE    ue_index=2    direction=dl
#    [Teardown]    Case Postcondition
#
#*** Keywords ***
#Case Precondition
#    log to console    Case Precondition
#    Common Test Setup For AIC
###    Adjust The Signal Via PA    10749_cell1=10
###    Verify Attenuation Value is updated    port    value
#CB008033 Precondition
#    log to console    Case Precondition
#    Common Test Setup For AIC
#    Adjust The Signal Via PA    10848_cell1=0
#
#5GC000704 Precondition
#    log to console    Case Precondition
#    Common Test Setup For AIC
#    Online Modify HO Meas Parametrs in vCU    a3_meas=none    a5_meas=rsrp
#
#CB008120 Postcondition
#    log to console    Case Postcondition
#    Unlock Xn Link
#    Adjust The Signal Via PA    10848_cell1=0
#    Run Keyword And Ignore Error    Stop Wireshark In vCU   gnb_index=${1}
#    ...                                                     alias=target_vcu_master
#    ...                                                     hostname=${ip_list[1]}
#    ...                                                     username=${username_list[1]}
#    ...                                                     password=${password_list[1]}
#    ...                                                     namespace=${ns_list[1]}
#    Run Keyword And Ignore Error    Detach UE    ue_index=1
#    Common Test Teardown For AIC
#
#CB011178_HO Postcondition
#    log to console    Case Postcondition
#    Common Test Teardown For AIC
#    run keyword and ignore error  Stop Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU
#
#Get SSH Connection Info of gNB
#    ${vdu_hostname_dict}    ${vdu_username_dict}    ${vdu_password_dict}    ${vdu_ns_dict}
#    ...                                               Get SSH Connection Infor For Multiple vDU With Different vCU
#    Set suite variable    ${vdu_hostname_dict}
#    Set suite variable    ${vdu_username_dict}
#    Set suite variable    ${vdu_password_dict}
#    Set suite variable    ${vdu_ns_dict}
#    ${vcu_hostname_list}  ${vcu_username_list}  ${vcu_password_list}  ${vcu_ns_list}
#    ...                                               Get SSH Connection Infor For Multiple vCU K8s Master
#    Set suite variable    ${vcu_hostname_list}
#    Set suite variable    ${vcu_username_list}
#    Set suite variable    ${vcu_password_list}
#    Set suite variable    ${vcu_ns_list}
#
#Update X2 Links locking state
#    [Arguments]    ${value}=unlocked
#    ${MRBTS1_ID}    Set Variable   ${MRBTS_ID_list}[1]
#    ${dim_dn1}    Set Variable   MRBTS-${MRBTS1_ID}/NRBTS-${MRBTS1_ID}
#    Modify Parameters By Delta Plan In vCU    parameter=x2LinkLock    value=${value}    mo_dn=${dim_dn1}/LTEENB-0
#    ...                                       gnb_index=${1}
#
#CB011169 Postcondition
#    log to console    Case Postcondition
#    Run Keyword And Ignore Error    Detach UE    ue_index=1
#    Common Test Teardown For AIC
#
#5GC000747_ETWS_primary Postcondition
#    log to console    Case Postcondition
#    Run Keyword And Ignore Error    Stop Wireshark In vCU
#    ...                             hostname=${vdu_hostname_dict['vcu_0_vdu_hostname'][0]}
#    ...                             username=${vdu_username_dict['vcu_0_vdu_username'][0]}
#    ...                             password=${vdu_password_dict['vcu_0_vdu_password'][0]}
#    ...                             namespace=${vdu_ns_dict['vcu_0_vdu_ns'][0]}
#    ...                             pod_name=cprt
#    Run Keyword And Ignore Error    Stop Wireshark In vCU
#    ...                                               hostname=${vcu_hostname_list[0]}
#    ...                                               username=${vcu_username_list[0]}
#    ...                                               password=${vcu_password_list[0]}
#    ...                                               namespace=${vcu_ns_list[0]}
##    Set Mobile Data    serial_number=H4K5T20A30008277    state=on    connection=cygwin
#    Set Mobile Data    ue_index=1    state=on    connection=cygwin
#    Run Keyword And Ignore Error    Detach UE    ue_index=1
#    Common Test Teardown For AIC
#	Modify Parameters By Delta Plan In vCU    parameter=actETWS    value=flase
#	...                                mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#
#5GC002645 Postcondition
#    log to console    Case Postcondition
#    Run Keyword And Ignore Error    Stop Wireshark In vCU
#    ...                             hostname=${vdu_hostname_dict['vcu_0_vdu_hostname'][0]}
#    ...                             username=${vdu_username_dict['vcu_0_vdu_username'][0]}
#    ...                             password=${vdu_password_dict['vcu_0_vdu_password'][0]}
#    ...                             namespace=${vdu_ns_dict['vcu_0_vdu_ns'][0]}
#    ...                             pod_name=cprt
#    Run Keyword And Ignore Error    Stop Wireshark In vCU
#    ...                                               hostname=${vcu_hostname_list[0]}
#    ...                                               username=${vcu_username_list[0]}
#    ...                                               password=${vcu_password_list[0]}
#    ...                                               namespace=${vcu_ns_list[0]}
#    Run Keyword And Ignore Error    Detach UE    ue_index=2
#    Modify Parameters By Delta Plan    ne=vDU    parameter=pwsRestIndEnabled    value=flase
#    ...                                mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    Modify Parameters By Delta Plan    ne=vCU    parameter=actCMAS    value=flase
#    ...                                mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    Common Test Teardown For AIC
#
#CB008737_B Postcondition
#    log to console    Auto Sync Postcondition
#    Run Keyword And Ignore Error    basic.master_close    alias=${rannic_conn}
#    Modify Parameters By Delta Plan    ne=vDU    parameter=actSshToRanNic    value=false
#    ...                                mo_dn=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
#    Common Test Teardown For AIC
#
#Case Postcondition
#    log to console    Case Postcondition
#    Common Test Teardown For AIC
#    run keyword and ignore error  Stop Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU
#    run keyword and ignore error  Detach UE    ue_index=2
#
#Prepare And Attach UE
#    [Arguments]    ${ue_index}=${0}    ${ui_version}=MATE40PROUI1.0
#    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
#    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
#    Log to Console    \n***Prepare UE***
#    Prepare UE    ${ue_${ue_index}_type}    ue_index=${ue_index}    ui_version=${ui_version}
#    UE Attach    ${ue_${ue_index}_type}    ue_index=${ue_index}    verify_attach=True
#    [Return]     ${ue_${ue_index}_type}
#
#Detach UE
#    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_${ue_index}_type}
#    UE Detach    ${ue_type}    ue_index=${ue_index}
#
#Start Call For UE
#    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}    ${direction}=dl
#    Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=${direction}    dt_index=${ue_index}
#	...              throughput=110M    duration=${600}
#
#Check VONR Call Status after HO
#    [Arguments]      ${expected_status}=hold
#    Log to Console    \n***Check VONR Call Status after HO***
#    ${vc_status} =    Check VONR Call Status    vc_alias=VC_1
#    should be equal    "${vc_status}"  "${expected_status}"   The status of Voice Call is not expected!
#
#Check Data Transfer Status
#    [Arguments]      ${expected_status}=alive      ${dt_name}=DT_DL
#    Log to Console    \n***Check Data Transfer Status***
#    ${output}    Run Keyword and Return Status    Check Data Transfer Is Alive    dt_name=${dt_name}
#    ${dt_status}    Set Variable If    ${output}==True    alive
#    ...                                ${output}==False    dead
#    Log    Data Transfer with dt_name ${dt_name} status: ${dt_status}
#    should be equal    "${dt_status}"  "${expected_status}"   The status of Data Transfer is not expected!
#
#Check Any One Value In Multiple Counters In vDU
#    [Arguments]    ${counter_id_list}    ${dim_dn}    ${gnb_index}=0
#    ...            ${comparison}=greater    ${expected_value}=0    ${get_number}=3
#    Log to Console    \n***check any one value in multiple counters in vDU***
#    ${status}=   set variable   False
#    ${counter_values_final_list}    Create List
#    FOR    ${counter_id}    IN    @{counter_id_list}
#        ${counter_values_final_list}    Run Keyword And Ignore Error    Check Counter For vDU
#        ...                                            counter_id=${counter_id}
#        ...                                            dimension_dn=${dim_dn}
#        ...                                            comparison=${comparison}
#        ...                                            expected_value=${expected_value}
#        ...                                            get_number=${get_number}
#        ...                                            gnb_index=${gnb_index}
#        ${status}=    set variable if    '${counter_values_final_list[0]}'=='PASS'    True
#        exit for loop if    '${status}'=='True'
#    END
#    should be equal    ${status}    True    Check counter value failed!
#
#Check Counter In vDU
#    [Arguments]    ${counter_id_list}    ${dim_dn}    ${gnb_index}=0
#    ...            ${comparison}=greater    ${expected_value}=0    ${get_number}=3
#    Log to Console    \n***check counter in vDU***
#    FOR    ${counter_id}    IN    @{counter_id_list}
#        Check Counter For vDU   counter_id=${counter_id}
#        ...                     dimension_dn=${dim_dn}
#        ...                     comparison=${comparison}
#        ...                     expected_value=${expected_value}
#        ...                     get_number=${get_number}
#        ...                     gnb_index=${gnb_index}
#    END
#
#Check Counter In vCU
#    [Arguments]    ${counter_id_list}    ${dim_dn}    ${gnb_index}=0
#    ...            ${comparison}=greater    ${expected_value}=0    ${get_number}=3
#    Log to Console    \n***check counter in vCU***
#    FOR    ${counter_id}    IN    @{counter_id_list}
#        @{words}=    split string    ${counter_id}   C
#        ${mea_id}=   Fetch From Right    ${words[0]}  M
#
#        Check Counter For vCU   counter_id=${counter_id}
#        ...                     measurement_id=${mea_id}
#        ...                     dimension_dist_name=${dim_dn}
#        ...                     comparison=${comparison}
#        ...                     expected_value=${expected_value}
#        ...                     get_number=${get_number}
#        ...                     gnb_index=${gnb_index}
#    END
#
#Start Collect Wireshark Log
#    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cpif    ${NE}=vDU    ${gnb_index}=${0}
#    ...            ${gnb2_index}=${1}
#	log    ${gnb2_index} is not used
#    Run Keyword If    '${NE}'=='vCU'    Start Collect Wireshark Log In vCU
#    ...                                                           container_name=${container_name}
#    ...                                                           pod_name=${pod_name}
#    ...                                                           index=${gnb_index}
#    ...       ELSE IF    '${NE}'=='vDU'    Start Collect Wireshark Log In vDU
#    ...                                                           container_name=${container_name}
#    ...                                                           pod_name=${pod_name}
#    ...                                                           gnb_index=${gnb_index}
#    ...       ELSE IF    '${NE}'=='all'    Start Collect Wireshark Log Both vCU And vDU
#    ...                                                           container_name=${container_name}
#    ...                                                           vdu_pod_name=cprt
#    ...                                                           vcu_pod_name=cpif
#    ...                                                           gnb_index=${gnb_index}
#    ...       ELSE IF    '${NE}'=='Multi_vDU'    Start Collect Wireshark Log For Multi vDU
#    ...                                                           container_name=${container_name}
#    ...                                                           pod_name=${pod_name}
#    ...                                                           gnb_index=${gnb_index}
#    ...       ELSE IF    '${NE}'=='Multi_vCU'    Start Collect Wireshark Log For Multi vCU
#    ...                                                           container_name=${container_name}
#    ...                                                           pod_name=${pod_name}
#    ...                                                           gnb_index=${gnb_index}
#
#Start Collect Wireshark Log In vCU
#    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cpif    ${index}=${0}
#    Log to Console    \n***Start Wireshark Log In vCU***
#    Start Wireshark Log In vCU   container_name=${container_name}
#    ...                          pod_name=${pod_name}
#    ...                          timeout=${10}
#    ...                          protocol=sctp
#    ...                          interface=any
#    ...                          hostname=${vcu_hostname_list[${index}]}
#    ...                          username=${vcu_username_list[${index}]}
#    ...                          password=${vcu_password_list[${index}]}
#    ...                          namespace=${vcu_ns_list[${index}]}
#
#Start Collect Wireshark Log In vDU
#    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cprt    ${gnb_index}=${0}    ${index}=${0}
#    Log to Console    \n***Start Wireshark Log In vCU***
#    Start Wireshark Log In vDU   container_name=${container_name}
#    ...                          pod_name=${pod_name}
#    ...                          timeout=${10}
#    ...                          protocol=sctp
#    ...                          interface=any
#    ...                          hostname=${vdu_hostname_dict['vcu_${gnb_index}_vdu_hostname'][${index}]}
#    ...                          username=${vdu_username_dict['vcu_${gnb_index}_vdu_username'][${index}]}
#    ...                          password=${vdu_password_dict['vcu_${gnb_index}_vdu_password'][${index}]}
#    ...                          namespace=${vdu_ns_dict['vcu_${gnb_index}_vdu_ns'][${index}]}
#
#Start Collect Wireshark Log Both vCU And vDU
#    [Arguments]    ${container_name}=nwmgmt    ${vdu_pod_name}=cprt    ${vcu_pod_name}=cpif
#    ...            ${gnb_index}=${0}
#    Log to Console    \n***Start Wireshark Log In vCU***
#    Start Wireshark Log In vCU   container_name=${container_name}
#    ...                          pod_name=${vcu_pod_name}
#    ...                          timeout=${10}
#    ...                          protocol=sctp
#    ...                          interface=any
#    ...                          hostname=${vcu_hostname_list[${gnb_index}]}
#    ...                          username=${vcu_username_list[${gnb_index}]}
#    ...                          password=${vcu_password_list[${gnb_index}]}
#    ...                          namespace=${vcu_ns_list[${gnb_index}]}
#    Start Wireshark Log In vDU   container_name=${container_name}
#    ...                          pod_name=${vdu_pod_name}
#    ...                          timeout=${10}
#    ...                          protocol=sctp
#    ...                          interface=any
#    ...                          hostname=${vdu_hostname_dict['vcu_${gnb_index}_vdu_hostname'][${index1}]}
#    ...                          username=${vdu_username_dict['vcu_${gnb_index}_vdu_username'][${index1}]}
#    ...                          password=${vdu_password_dict['vcu_${gnb_index}_vdu_password'][${index1}]}
#    ...                          namespace=${vdu_ns_dict['vcu_${gnb_index}_vdu_ns'][${index1}]}
#
#Start Collect Wireshark Log For Multi vDU
#    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cprt    ${gnb_index}=${0}
#    ...            ${gnb2_index}=${0}    ${index}=${0}    ${index1}=${0}
#    Log to Console    \n***Start Wireshark Log In vCU***
#    Start Wireshark Log In vDU   container_name=${container_name}
#    ...                          pod_name=${pod_name}
#    ...                          timeout=${10}
#    ...                          protocol=sctp
#    ...                          interface=any
#    ...                          hostname=${vdu_hostname_dict['vcu_${gnb_index}_vdu_hostname'][${index}]}
#    ...                          username=${vdu_username_dict['vcu_${gnb_index}_vdu_username'][${index}]}
#    ...                          password=${vdu_password_dict['vcu_${gnb_index}_vdu_password'][${index}]}
#    ...                          namespace=${vdu_ns_dict['vcu_${gnb_index}_vdu_ns'][${index}]}
#    Start Wireshark Log In vDU   container_name=${container_name}
#    ...                          pod_name=${pod_name}
#    ...                          timeout=${10}
#    ...                          protocol=sctp
#    ...                          interface=any
#    ...                          hostname=${vdu_hostname_dict['vcu_${gnb2_index}_vdu_hostname'][${index1}]}
#    ...                          username=${vdu_username_dict['vcu_${gnb2_index}_vdu_username'][${index1}]}
#    ...                          password=${vdu_password_dict['vcu_${gnb2_index}_vdu_password'][${index1}]}
#    ...                          namespace=${vdu_ns_dict['vcu_${gnb2_index}_vdu_ns'][${index1}]}
#
#Start Collect Wireshark Log For Multi vCU
#    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cpif    ${gnb_index}=${0}    ${gnb2_index}=${1}
#    Log to Console    \n***Start Wireshark Log In vCU***
#    Start Wireshark Log In vCU   container_name=${container_name}
#    ...                          pod_name=${pod_name}
#    ...                          timeout=${10}
#    ...                          protocol=sctp
#    ...                          interface=any
#    ...                          hostname=${vcu_hostname_list[${gnb_index}]}
#    ...                          username=${vcu_username_list[${gnb_index}]}
#    ...                          password=${vcu_password_list[${gnb_index}]}
#    ...                          namespace=${vcu_ns_list[${gnb_index}]}
#
#    Start Wireshark Log In vCU   container_name=${container_name}
#    ...                          pod_name=${pod_name}
#    ...                          timeout=${10}
#    ...                          protocol=sctp
#    ...                          interface=any
#    ...                          hostname=${vcu_hostname_list[${gnb2_index}]}
#    ...                          username=${vcu_username_list[${gnb2_index}]}
#    ...                          password=${vcu_password_list[${gnb2_index}]}
#    ...                          namespace=${vcu_ns_list[${gnb2_index}]}
#
#Adjust The Signal Via PA
#    [Arguments]    ${10848_cell1}=63    ${10848_cell2}=63    ${10848_cell3}=63    ${10875_cell1}=63
#    Log to console    Adjust The Signal Via PA
#    ${attenuation_channels}    Get Attenuation port    RU_id=0    du_id=0
#    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
#    &{channels_to_modify}    create dictionary    ${attenuation_channels[0]}=${10848_cell1}    ${attenuation_channels[1]}=${10848_cell1}
#    ...                                          ${attenuation_channels[2]}=${10848_cell2}    ${attenuation_channels[3]}=${10848_cell2}
#    ...                                          ${attenuation_channels[4]}=${10848_cell3}    ${attenuation_channels[5]}=${10848_cell3}
#    ...                                          ${attenuation_channels[6]}=${10875_cell1}    ${attenuation_channels[7]}=${10875_cell1}
#    ...                                          ${attenuation_channels[8]}=${10875_cell1}
#    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
#    sleep    3s    reason=wait signal stable
#    Log to console    attenuation change complete
#
#Check Attenuation Value
#    Log to console    Adjust The Signal Via PA
#    ${attenuation_channels}    Get Attenuation port    RU_id=0    du_id=0
#    Verify Attenuation Value is updated
#
#Trigger intra Fre inter gnb based Handover For CB008120
#    [Arguments]    ${vendor}=HBTE    ${source_cell}=15    ${target_cell}=0    ${adjust_step}=2
#    Log to console    \n***Start to Trigger intra Fre inter gnb based Handover***
#    ${attenuation_channels}    Get Attenuation port    RU_id=0    du_id=0
#    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=${vendor}    du_id=0
#
#
#    FOR    ${index}    IN RANGE    5    ${source_cell}    ${adjust_step}
#        #    10848 cell1 source cell channels
#        &{source_cell_channels}    create dictionary    ${attenuation_channels[0]}=${index}
#        ...                                             ${attenuation_channels[1]}=${index}
#
#        Modify Attenuation Value    ${source_cell_channels}    RU_id=0    du_id=0
#        sleep    1s    reason=wait signal stable
#
#        #    10875 cell1 target cell channels
#        ${target_cell_index}    Evaluate    ${source_cell}-${index}
#        exit for loop if    ${target_cell_index}<${target_cell}
#        &{target_cell_channels}    create dictionary    ${attenuation_channels[6]}=${target_cell_index}
#        ...                                             ${attenuation_channels[7]}=${target_cell_index}
#        ...                                             ${attenuation_channels[8]}=${target_cell_index}
#        Modify Attenuation Value    ${target_cell_channels}    RU_id=0    du_id=0
#        sleep    1s    reason=wait signal stable
#
#    END
#    Log to console    \n***Stop to Trigger intra Fre inter gnb based Handover***
#
#Trigger intra Fre inter gnb based Handover
#    [Arguments]    ${vendor}=HBTE    ${source_cell}=43    ${target_cell}=0    ${adjust_step}=3
#    Log to console    \n***Start to Trigger intra Fre inter gnb based Handover***
#    ${attenuation_channels}    Get Attenuation port    RU_id=0    du_id=0
#    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=${vendor}    du_id=0
#
#
#    FOR    ${index}    IN RANGE    13    ${source_cell}    ${adjust_step}
#        #    10848 cell1 source cell channels
#        &{source_cell_channels}    create dictionary    ${attenuation_channels[0]}=${index}
#        ...                                             ${attenuation_channels[1]}=${index}
#
#        Modify Attenuation Value    ${source_cell_channels}    RU_id=0    du_id=0
#        sleep    1s    reason=wait signal stable
#
#        #    10875 cell1 target cell channels
#        ${target_cell_index}    Evaluate    ${source_cell}-${index}
#        exit for loop if    ${target_cell_index}<${target_cell}
#        &{target_cell_channels}    create dictionary    ${attenuation_channels[6]}=${target_cell_index}
#        ...                                             ${attenuation_channels[7]}=${target_cell_index}
#        ...                                             ${attenuation_channels[8]}=${target_cell_index}
#        Modify Attenuation Value    ${target_cell_channels}    RU_id=0    du_id=0
#        sleep    1s    reason=wait signal stable
#
#    END
#
#    Log to console    \n***Stop to Trigger intra Fre inter gnb based Handover***
#
#Trigger intra Fre intra gnb based Handover
#    [Arguments]    ${vendor}=HBTE    ${source_cell}=43    ${target_cell}=0    ${adjust_step}=3
#    Log to console    Start to Trigger intra Fre intra gnb based Handover
#    ${attenuation_channels}    Get Attenuation port    RU_id=0    du_id=0
#    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=${vendor}    du_id=0
#
#    FOR    ${index}    IN RANGE    13    ${source_cell}    ${adjust_step}
#        #    10848 cell1 source cell channels
#        &{source_cell_channels}    create dictionary    ${attenuation_channels[0]}=${index}
#        ...                                             ${attenuation_channels[1]}=${index}
#
#        Modify Attenuation Value    ${source_cell_channels}    RU_id=0    du_id=0
#        sleep    1s    reason=wait signal stable
#
#        #    10848 cell2 target cell channels
#        ${target_cell_index}    Evaluate    ${source_cell}-${index}
#        exit for loop if    ${target_cell_index}<${target_cell}
#        &{target_cell_channels}    create dictionary    ${attenuation_channels[2]}=${target_cell_index}
#        ...                                             ${attenuation_channels[3]}=${target_cell_index}
#        Modify Attenuation Value    ${target_cell_channels}    RU_id=0    du_id=0
#        sleep    1s    reason=wait signal stable
#    END
#
#    Log to console    Stop to Trigger intra Fre intra gnb based Handover
#
#Trigger inter Fre inter gnb based Handover
#    [Arguments]    ${vendor}=HBTE    ${source_cell}=43    ${target_cell}=0    ${adjust_step}=3
#    Log to console    \n***Start to triger inter Fre inter gnb based Handover***
#    ${attenuation_channels}    Get Attenuation port    RU_id=0    du_id=0
#    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=${vendor}    du_id=0
#
#    FOR    ${index}    IN RANGE    13    ${source_cell}    ${adjust_step}
#		#    10848 cell3 source cell channels
#        &{source_cell_channels}    create dictionary    ${attenuation_channels[4]}=${index}
#        ...                                             ${attenuation_channels[5]}=${index}
#
#        Modify Attenuation Value    ${source_cell_channels}    RU_id=0    du_id=0
#        sleep    1s    reason=wait signal stable
#    END
#
#    #    10875 cell1 target cell channels
#    &{target_cell_channels}    create dictionary    ${attenuation_channels[6]}=${target_cell}
#    ...                                             ${attenuation_channels[7]}=${target_cell}
#    ...                                             ${attenuation_channels[8]}=${target_cell}
#    Modify Attenuation Value    ${target_cell_channels}    RU_id=0    du_id=0
#    sleep    3s    reason=wait signal stable
#
#    Log to console    \n***Stop to triger inter Fre inter gnb based Handover***
#
#Trigger Intra DU inter frequency VONR HO
#        [Arguments]    ${vendor}=HBTE    ${source_cell}=43    ${target_cell}=0    ${adjust_step}=3
#    Log to console    Start to trigger Intra DU inter frequency VONR HO
#    ${attenuation_channels}    Get Attenuation port    RU_id=0    du_id=0
#    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=${vendor}    du_id=0
#
#    FOR    ${index}    IN RANGE    13    ${source_cell}    ${adjust_step}
#        #    10848 cell1 source cell channels
#        &{source_cell_channels}    create dictionary    ${attenuation_channels[0]}=${index}
#        ...                                             ${attenuation_channels[1]}=${index}
#
#        Modify Attenuation Value    ${source_cell_channels}    RU_id=0    du_id=0
#        sleep    1s    reason=wait signal stable
#
#        #    10848 cell3 target cell channels
#        ${target_cell_index}    Evaluate    ${source_cell}-${index}
#        exit for loop if    ${target_cell_index}<${target_cell}
#        &{target_cell_channels}    create dictionary    ${attenuation_channels[4]}=${target_cell_index}
#        ...                                             ${attenuation_channels[5]}=${target_cell_index}
#        Modify Attenuation Value    ${target_cell_channels}    RU_id=0    du_id=0
#        sleep    1s    reason=wait signal stable
#    END
#
#    Log to console    Stop to trigger Intra DU inter frequency VONR HO
#
#Stop Wireshark Log
#    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cpif    ${NE}=vDU    ${gnb_index}=${0}
#    ...            ${index}=${0}    ${index1}=${1}
#    ...            ${vdu_pod_name}=cprt    ${vcu_pod_name}=cpif
#    Run Keyword If    '${NE}'=='vDU'    Stop Wireshark Log In vDU
#    ...                                                           container_name=${container_name}
#    ...                                                           pod_name=${pod_name}
#    ...                                                           gnb_index=${gnb_index}
#    ...                                                           index=${index}
#    ...    ELSE IF    '${NE}'=='vCU'    Stop Wireshark Log In vCU
#    ...                                                           container_name=${container_name}
#    ...                                                           pod_name=${pod_name}
#    ...                                                           index=${index}
#    ...    ELSE IF    '${NE}'=='all'    Stop Wireshark Log Both vCU And vDU
#    ...                                                           container_name=${container_name}
#    ...                                                           vdu_pod_name=${vdu_pod_name}
#    ...                                                           vcu_pod_name=${vcu_pod_name}
#    ...                                                           gnb_index=${gnb_index}
#    ...                                                           index=${index}
#    ...    ELSE IF    '${NE}'=='Multi_vDU'    Stop Wireshark Log For Multi vDU
#    ...                                                           container_name=${container_name}
#    ...                                                           pod_name=${pod_name}
#    ...                                                           gnb_index=${gnb_index}
#    ...                                                           index=${index}
#    ...                                                           index1=${index1}
#    ...    ELSE IF    '${NE}'=='Multi_vCU'    Stop Wireshark Log For Multi vCU
#    ...                                                           container_name=${container_name}
#    ...                                                           pod_name=${pod_name}
#    ...                                                           index=${index}
#    ...                                                           index1=${index1}
#
#Stop Wireshark Log In vDU
#    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cpif    ${gnb_index}=${0}    ${index}=${0}
#    ${wireshark_local_file_path_vDU}    Stop Wireshark Log And Download To K8s Master In vDU
#    ...                          container_name=${container_name}
#    ...                          pod_name=${pod_name}
#    ...                          timeout=${10}
#    ...                          hostname=${vdu_hostname_dict['vcu_${gnb_index}_vdu_hostname'][${index}]}
#    ...                          username=${vdu_username_dict['vcu_${gnb_index}_vdu_username'][${index}]}
#    ...                          password=${vdu_password_dict['vcu_${gnb_index}_vdu_password'][${index}]}
#    ...                          namespace=${vdu_ns_dict['vcu_${gnb_index}_vdu_ns'][${index}]}
#    Set Test Variable    ${wireshark_local_file_path_vDU}
#
#Stop Wireshark Log In vCU
#    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cpif    ${index}=${0}
#    ${wireshark_local_file_path_vCU}    Stop Wireshark Log And Download To K8s Master In vCU
#    ...                                               container_name=${container_name}
#    ...                                               pod_name=${pod_name}
#    ...                                               timeout=${10}
##    ...                                               log_name=${vcu_log_name}
#    ...                                               hostname=${vcu_hostname_list[${index}]}
#    ...                                               username=${vcu_username_list[${index}]}
#    ...                                               password=${vcu_password_list[${index}]}
#    ...                                               namespace=${vcu_ns_list[${index}]}
#    Set Test Variable    ${wireshark_local_file_path_vCU}
#
#Stop Wireshark Log Both vCU And vDU
#    [Arguments]    ${container_name}=nwmgmt    ${vdu_pod_name}=cprt    ${vcu_pod_name}=cpif    ${gnb_index}=${0}
#    ...            ${index}=${0}    ${index1}=${0}
#    ${wireshark_local_file_path_vDU}    Stop Wireshark Log And Download To K8s Master In vDU
#    ...                          container_name=${container_name}
#    ...                          pod_name=${vdu_pod_name}
#    ...                          timeout=${10}
#    ...                          hostname=${vdu_hostname_dict['vcu_${gnb_index}_vdu_hostname'][${index1}]}
#    ...                          username=${vdu_username_dict['vcu_${gnb_index}_vdu_username'][${index1}]}
#    ...                          password=${vdu_password_dict['vcu_${gnb_index}_vdu_password'][${index1}]}
#    ...                          namespace=${vdu_ns_dict['vcu_${gnb_index}_vdu_ns'][${index1}]}
#    Set Test Variable    ${wireshark_local_file_path_vDU}
#    ${wireshark_local_file_path_vCU}    Stop Wireshark Log And Download To K8s Master In vCU
#    ...                                               container_name=${container_name}
#    ...                                               pod_name=${vcu_pod_name}
#    ...                                               timeout=${10}
#    ...                                               hostname=${vcu_hostname_list[${index}]}
#    ...                                               username=${vcu_username_list[${index}]}
#    ...                                               password=${vcu_password_list[${index}]}
#    ...                                               namespace=${vcu_ns_list[${index}]}
#    Set Test Variable    ${wireshark_local_file_path_vCU}
#
#Stop Wireshark Log Both vCU And vDU on Source gNB
#    [Arguments]    ${container_name}=nwmgmt    ${vdu_pod_name}=cprt    ${vcu_pod_name}=cpif    ${gnb_index}=${0}
#    ...            ${index}=${0}    ${index1}=${0}
#    ${source_vCU}    Stop Wireshark Log And Download To K8s Master In vCU
#    ...                                               container_name=${container_name}
#    ...                                               pod_name=${vcu_pod_name}
#    ...                                               timeout=${10}
#    ...                                               hostname=${vcu_hostname_list[${index}]}
#    ...                                               username=${vcu_username_list[${index}]}
#    ...                                               password=${vcu_password_list[${index}]}
#    ...                                               namespace=${vcu_ns_list[${index}]}
#    Set Test Variable    ${source_vCU}
#    ${source_vDU}    Stop Wireshark Log And Download To K8s Master In vDU
#    ...                          container_name=${container_name}
#    ...                          pod_name=${vdu_pod_name}
#    ...                          timeout=${10}
#    ...                          hostname=${vdu_hostname_dict['vcu_${gnb_index}_vdu_hostname'][${index1}]}
#    ...                          username=${vdu_username_dict['vcu_${gnb_index}_vdu_username'][${index1}]}
#    ...                          password=${vdu_password_dict['vcu_${gnb_index}_vdu_password'][${index1}]}
#    ...                          namespace=${vdu_ns_dict['vcu_${gnb_index}_vdu_ns'][${index1}]}
#    Set Test Variable    ${source_vDU}
#
#Stop Wireshark Log Both vCU And vDU on Target gNB
#    [Arguments]    ${container_name}=nwmgmt    ${vdu_pod_name}=cprt    ${vcu_pod_name}=cpif    ${gnb_index}=${0}
#    ...            ${index}=${0}    ${index1}=${0}
#    ${target_vCU}    Stop Wireshark Log And Download To K8s Master In vCU
#    ...                                               container_name=${container_name}
#    ...                                               pod_name=${vcu_pod_name}
#    ...                                               timeout=${10}
#    ...                                               hostname=${vcu_hostname_list[${index}]}
#    ...                                               username=${vcu_username_list[${index}]}
#    ...                                               password=${vcu_password_list[${index}]}
#    ...                                               namespace=${vcu_ns_list[${index}]}
#    Set Test Variable    ${target_vCU}
#    ${target_vDU}    Stop Wireshark Log And Download To K8s Master In vDU
#    ...                          container_name=${container_name}
#    ...                          pod_name=${vdu_pod_name}
#    ...                          timeout=${10}
#    ...                          hostname=${vdu_hostname_dict['vcu_${gnb_index}_vdu_hostname'][${index1}]}
#    ...                          username=${vdu_username_dict['vcu_${gnb_index}_vdu_username'][${index1}]}
#    ...                          password=${vdu_password_dict['vcu_${gnb_index}_vdu_password'][${index1}]}
#    ...                          namespace=${vdu_ns_dict['vcu_${gnb_index}_vdu_ns'][${index1}]}
#    Set Test Variable    ${target_vDU}
#
#Stop Wireshark Log For Multi vDU
#    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cpif    ${gnb_index}=${0}
#    ...            ${index}=${0}    ${index1}=${0}
#    ${wireshark_local_file_path_vDU}    Stop Wireshark Log And Download To K8s Master In vDU
#    ...                          container_name=${container_name}
#    ...                          pod_name=${pod_name}
#    ...                          timeout=${10}
#    ...                          hostname=${vdu_hostname_dict['vcu_${gnb_index}_vdu_hostname'][${index}]}
#    ...                          username=${vdu_username_dict['vcu_${gnb_index}_vdu_username'][${index}]}
#    ...                          password=${vdu_password_dict['vcu_${gnb_index}_vdu_password'][${index}]}
#    ...                          namespace=${vdu_ns_dict['vcu_${gnb_index}_vdu_ns'][${index}]}}
#    ${wireshark_local_file_path_vDU}    Stop Wireshark Log And Download To K8s Master In vDU
#    ...                          container_name=${container_name}
#    ...                          pod_name=${pod_name}
#    ...                          timeout=${10}
#    ...                          hostname=${vdu_hostname_dict[vcu_${gnb_index}_vdu_hostname][${index1}]}
#    ...                          username=${vdu_hostname_dict[vcu_${gnb_index}_vdu_hostname][${index1}]}
#    ...                          password=${vdu_hostname_dict[vcu_${gnb_index}_vdu_hostname][${index1}]}
#    ...                          namespace=${vdu_hostname_dict[vcu_${gnb_index}_vdu_hostname][${index1}]}
#    Set Test Variable    ${wireshark_local_file_path_vDU}
#
#Stop Wireshark Log For Multi vCU
#    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cpif    ${index}=${0}    ${index1}==${1}
#    ${Source_vCU_wireshark}    Stop Wireshark Log And Download To K8s Master In vCU
#    ...                                               container_name=${container_name}
#    ...                                               pod_name=${pod_name}
#    ...                                               timeout=${10}
#    ...                                               hostname=${vcu_hostname_list[${index}]}
#    ...                                               username=${vcu_username_list[${index}]}
#    ...                                               password=${vcu_password_list[${index}]}
#    ...                                               namespace=${vcu_ns_list[${index}]}
#    Set Test Variable    ${Source_vCU_wireshark}
#    ${Target_vCU_wireshark}    Stop Wireshark Log And Download To K8s Master In vCU
#    ...                                               container_name=${container_name}
#    ...                                               pod_name=${pod_name}
#    ...                                               timeout=${10}
#    ...                                               hostname=${vcu_hostname_list[${index1}]}
#    ...                                               username=${vcu_username_list[${index1}]}
#    ...                                               password=${vcu_password_list[${index1}]}
#    ...                                               namespace=${vcu_ns_list[${index1}]}
#    Set Test Variable    ${Target_vCU_wireshark}
#
#Check NG HO Notify In Wireshark
#    [Arguments]      ${log_path}=${capture_file_path}
#    Log to Console    \n***Check NG HO Notify In Wireshark***
#    ${ngho_filter} =    catenate    ngap.HandoverNotify_element
#    ${result} =    Analysis Wireshark Log    input_file=${log_path}
#	...                                      filter_expression=${ngho_filter}
#	should contain    ${result}    HandoverNotify
#
#Stop Cpue Log
#    sleep    30s    reason=wait cpue log generate
#    Log to Console    \n***Collect And Download Cpue Log In vCU***
#    ${cpue_log}    Collect And Download K8s Log In vCU    gnb_index=${0}    vdu_index=${0}    container_name=cpue
#    ...                                                          pod_name=cpue    timeout=${10}    duration=300s
##    ...                                                          pod_name=cpue    timeout=${10}    duration=120s
#    Set Test Variable    ${cpue_log}
#
#Check HO status in Cpue Log
#    Log to Console    \n***Starting Check Error In Cpue log***
#    ${ho_errors}    Get HO Error In Cpue log    log_path=${cpue_log}
##    Should Be Empty    ${ho_errors}
#    Run Keyword And Ignore Error    Should Be Empty    ${ho_errors}
#	Run Keyword If    ${ho_errors}     Log to Console    \n***No HO Errors In Cpue log***
#	...    ELSE                        Log to Console    \n***HO Errors Exist In Cpue log, Please check***
#
#Get HO Error In Cpue log
#    [Arguments]      ${log_path}
#    Log to Console    \n***Filter HO Errors From Cpue log***
#    ${errors_checklist}    create list    no security result received
#    ...                                ProtocolError
#    ...                                Handover Preparation Failure
#    ...                                SaRadioLinkFailureService
#    ...                                handoverFailure
#    &{errors_dict}    Create Dictionary
#
#    FOR    ${error}    IN    @{errors_checklist}
#         ${error_output}    OperatingSystem.Run    command=cat ${log_path} | grep -a "${error}"
#         ${error_output_length}    get length    ${error_output}
#         run keyword if    ${error_output_length}>0
#         ...    Set To Dictionary    ${errors_dict}    ${error}=${error_output}
#    END
#    [Return]    &{errors_dict}
#
#Online Modify HO Meas Parametrs in vCU
#    [Arguments]    ${gnb_index}=${0}    ${a3_meas}=rsrp    ${a5_meas}=none    ${config_cell}=NRCELL-1
#    Log to Console    \n***Online Modify HO Meas Parametrs in vCU***
#    ${mo_dn_cell}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/${config_cell}
#    &{a5_meas_para}    Create Dictionary    operation_type=replace
#    ...                     parameter_path=/a5MeasEnabled
#    ...                     value=${a5_meas}
#    &{a3_meas_para}    Create Dictionary    operation_type=replace
#    ...                     parameter_path=/a3MeasEnabled
#    ...                     value=${a3_meas}
#    ${init_paras}    Create list    ${a5_meas_para}    ${a3_meas_para}
#    ${filtered_paras}    Create list
#
#    FOR    ${para}    IN    @{init_paras}
#        ${para_name_list} =    split_string    ${para['parameter_path']}    /
#        ${para_name} =    Get From List    ${para_name_list}    -1
#
#        ${scf_para_value}=    Get Parameters Of Current Plan Via Rest    parameter_name=${para_name}
#        ...                                                              gnb_index=${gnb_index}
#        ...                                                              mo_dn=${mo_dn_cell}
#
#        Run Keyword If    "${scf_para_value}"!="${para['value']}"    append to list    ${filtered_paras}    ${para}
#    END
#
#    ${filtered_paras_length}    get length    ${filtered_paras}
#    Run Keyword If    ${filtered_paras_length}!=0    Modify Paras and activate Delta Plan
#    ...                                             delta_plan_name=delta_plan
#    ...                                             paras_list=${filtered_paras}
#    ...                                             mo_dn=${mo_dn_cell}
#    ...    ELSE
#        ...     Log to Console    \n***Parameters already meet the requirements and do not need to be modified!***
#
#Modify Multiple Parameters By Delta Plan
#    [Arguments]    ${paras_list}=none    ${mo_dn}=none    ${delta_plan_id}=none
#    ${uuid}   _Get Specifical MO UUID In vCU    plan_id=${delta_plan_id}    mo_dn=${mo_dn}
#
#    FOR    ${para}    IN    @{paras_list}
#        ${para_name_list} =    split_string    ${para['parameter_path']}    /
#        ${para_name} =    Get From List    ${para_name_list}    -1
#        @{para_change_list}    Create List    ${para}
#
#        Online Update Single Mo Parameters Via Rest without Get UUID In vCU
#        ...                                                       para_list=${para_change_list}
#        ...                                                       mo_dn=${mo_dn}
#        ...                                                       delta_plan_id=${delta_plan_id}
#        ...                                                       uuid=${uuid}
#    END
#
#Modify Paras and activate Delta Plan
#    [Arguments]    ${gnb_index}=${0}    ${delta_plan_name}=none    ${paras_list}=none    ${mo_dn}=none
#    Login To vCU By Rest    gnb_index=${gnb_index}
#    ${delta_plan_id}=    Online Generate Delta Plan Via Rest In vCU    delta_plan_name=${delta_plan_name}
#    Modify Multiple Parameters By Delta Plan    paras_list=${paras_list}    mo_dn=${mo_dn}
#    ...                                         delta_plan_id=${delta_plan_id}
#    Validate and Activate Delata Plan For vCU    delta_plan_id=${delta_plan_id}
#    [Teardown]   Login To vCU By Rest    gnb_index=${gnb_index}
#
#Modify Parameters By Delta Plan In vCU
#    [Arguments]   ${parameter}=actCDrx    ${value}=true    ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#    ...           ${gnb_index}=${0}
#    Log to Console    \n***Modify Parameters By Delta Plan In vCU***
#    &{vcu_param}    create dictionary    operation_type=replace    parameter_path=/${parameter}
#    ...                                                                         value=${value}
#    @{updated_vcu_param}    Create List    ${vcu_param}
#    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=${parameter}
#    ...                                                   updated_paras_dict=${updated_vcu_param}
#    ...                                                   compare_value=${value}
#    ...                                                   mo_dn=${mo_dn}
#    ...                                                   gnb_index=${gnb_index}
#
#Set vDU Parametrs For 5GC001349
#    [Arguments]    ${operation}=recover    ${frame_stru}=semiStatic    ${frame_shift}=None
#    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    ${mo_dn_cell}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#    ${mo_dn_gpr}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELLGRP-1
#
#    &{other_paras_dict}    Create Dictionary
#    Run Keyword If    '${operation}' == 'set'
#        ...         Set To Dictionary    ${other_paras_dict}    numberOfTransmittedSsBlocks=4 beams
#        ...                                         beamSet/0/basicBeamSet=beamSet_4
#        ...                                         msg1FrequencyStart=19
#        ...                                         type0CoresetConfigurationIndex=12
#        ...                                         type0SearchSpaceConfigurationIndex=5
#        ...                                         prachConfigurationIndex=9
#        ...                                         zeroCorrelationZoneConfig=12
#        ...                                         actPrachMultiplexing=false
#    ...    ELSE IF    '${operation}' == 'recover'
#        ...         Set To Dictionary    ${other_paras_dict}    numberOfTransmittedSsBlocks=6 beams
#        ...                                         beamSet/0/basicBeamSet=beamSet_6
#        ...                                         msg1FrequencyStart=4
#        ...                                         type0CoresetConfigurationIndex=10
#        ...                                         type0SearchSpaceConfigurationIndex=4
#        ...                                         prachConfigurationIndex=98
#        ...                                         zeroCorrelationZoneConfig=13
#        ...                                         actPrachMultiplexing=true
#    ...    ELSE
#        ...     Log to Console    \n***This ${operation} is not supported!***
#
#    &{ssb_para_dict}    Create Dictionary
#    ${ssb_value}=    Pop From Dictionary    ${other_paras_dict}    numberOfTransmittedSsBlocks
#    Set To Dictionary    ${ssb_para_dict}    numberOfTransmittedSsBlocks=${ssb_value}
#
#    Log to Console    \n***Upload new scf***
#    ${PLAN_ID}    ${ACTION_ID}    ${VALIDATION_ID}    Upload New SCF And Validate
#    Set Test Variable    ${PLAN_ID}
#
#    Set Framestru Paras in vDU    frame_stru=${frame_stru}    frame_shift=${frame_shift}
#    ...                           plan_id=${PLAN_ID}    mo_dn=${mo_dn}
#    ...                           mo_dn_cell=${mo_dn_cell}
#
#    vDU Login By Rest
#    Update Staged Plan Parameter    plan_id=${PLAN_ID}    mo_dn=${mo_dn_gpr}
#        ...                                       updated_paras_dict=${ssb_para_dict}
#        ...                                       operation=replace
#    Update Staged Plan Parameter    plan_id=${PLAN_ID}    mo_dn=${mo_dn_cell}
#        ...                                       updated_paras_dict=${other_paras_dict}
#        ...                                       operation=replace
#
#    Log to Console    \n***Start validate plan***
#    ${VALIDATION_ID}    Validate Plan By REST    plan_id=${PLAN_ID}
#
#    Log to Console    \n***Start activate plan***
#    Activate Plan By REST    ${PLAN_ID}
#
#    wait until keyword succeeds  600s  10s    vDU Check All Cells Status Should Be Onair For All DUs    gnb_index=${0}
#
#Set Framestru Paras in vDU
#    [Arguments]    ${frame_stru}=semiStatic    ${frame_shift}=None
#    ...            ${plan_id}=None    ${mo_dn}=MRBTS-10749/NRBTS-10749
#    ...            ${mo_dn_cell}=MRBTS-10749/NRBTS-10749/NRCELL-1    ${vdu_index}=0    ${gnb_index}=0
#    Log to Console    \n***Set framestru paras In vDU***
#    ${frame_para_name} =    Set Variable     tddFrameStructure/0/frameStructureType
#    ${manda_paras}   ${option_paras} =    Get Framestru Paras Dicts    frame_stru=${frame_stru}    frame_shift=${frame_shift}
#    ...                                                                mo_dn=${mo_dn}
#
#    vDU Login By Rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}
#    ${current_frame_value}=    Online Get VDU Parameter Value     ${mo_dn_cell}    ${frame_para_name}
#
#    Update Staged Plan Parameter    plan_id=${plan_id}    mo_dn=${mo_dn_cell}
#        ...                                       updated_paras_dict=${manda_paras}
#        ...                                       operation=replace
#
#    Log to Console    \n***Change the frameStructureType from ${current_frame_value} to ${frame_stru}!***
#    Run Keyword If    '${current_frame_value}' == 'semiStatic' and '${frame_stru}' == 'semiStatic'
##    semiStatic to semiStatic
#        ...       Log to Console    \n***the ${frame_stru} does not have option paras!***
#    ...    ELSE IF    '${current_frame_value}' == 'semiStatic' and '${frame_stru}' == 'tdLte'
##    semiStatic to tdLte
#        ...       Update Staged Plan Parameter    plan_id=${plan_id}    mo_dn=${mo_dn_cell}
#        ...                                       updated_paras_dict=${option_paras}
#        ...                                       operation=add
#    ...    ELSE IF    '${current_frame_value}' == 'tdLte' and '${frame_stru}' == 'tdLte'
##    tdLte to tdLte
#        ...       Update Staged Plan Parameter    plan_id=${plan_id}    mo_dn=${mo_dn_cell}
#        ...                                       updated_paras_dict=${option_paras}
#        ...                                       operation=replace
#    ...    ELSE IF    '${current_frame_value}' == 'tdLte' and '${frame_stru}' == 'semiStatic'
##    tdLte to semiStatic
#        ...       Update Staged Plan Parameter    plan_id=${plan_id}    mo_dn=${mo_dn_cell}
#        ...                                       updated_paras_dict=${option_paras}
#        ...                                       operation=remove
#    ...    ELSE
#        ...     Log to Console    \n***This operation is not supported!***
#    [Teardown]    vDU Logout By Rest    vdu_index=${vdu_index}
#
#Get Framestru Paras Dicts
#    [Arguments]    ${frame_stru}=semiStatic    ${frame_shift}=None    ${mo_dn}=MRBTS-10749/NRBTS-10749
#    &{framestru_manda_paras} =    Run Keyword If    '${frame_stru}' == 'tdLte' and '${frame_shift}' == '0ms'
#    #    tdlte framestructure 0ms frameshift
#        ...    Get FrameStru Mandatory Paras Dict    frame_stru=${frame_stru}    guard_period=6Symbols
#        ...                                          bwpdn0=7    bwpdn1=77    mo_dn=${mo_dn}
#    ...    ELSE IF    '${frame_stru}' == 'tdLte' and '${frame_shift}' == '3ms'
#    #    tdlte framestructure 3ms frameshift
#        ...    Get FrameStru Mandatory Paras Dict    frame_stru=${frame_stru}    guard_period=6Symbols
#        ...                                          bwpdn0=8    bwpdn1=87    mo_dn=${mo_dn}
#    ...    ELSE IF    '${frame_stru}'=='semiStatic'
#    #    semiStatic framestructure
#        ...    Get FrameStru Mandatory Paras Dict    frame_stru=${frame_stru}    bwpdn0=5    bwpdn1=57    mo_dn=${mo_dn}
#    ...    ELSE    Log to Console    \n***This frameStructureType ${frame_stru} ${frame_shift} is not supported yet!***
#
#    &{framestru_option_paras} =    Get FrameStru Option Paras Dict    frame_shift=${frame_shift}
#
#    [Return]    &{framestru_manda_paras}    &{framestru_option_paras}
#
#Get FrameStru Mandatory Paras Dict
#    [Arguments]    ${frame_stru}=semiStatic    ${guard_period}=2Symbols    ${uldldataslot_ratio}=1/4
#    ...    ${bwpdn0}=5    ${bwpdn1}=57    ${mo_dn}=MRBTS-10749/NRBTS-10749
#    &{parameter_dict}   create dictionary     tddFrameStructure/0/frameStructureType=${frame_stru}
#        ...                                   tddFrameStructure/0/guardPeriodLength=${guard_period}
#        ...                                   tddFrameStructure/0/ulDlDataSlotRatio=${uldldataslot_ratio}
#        ...                                   cellBwpList/0/bwpDN=${mo_dn}/BWP_PROFILE-${bwpdn0}
#        ...                                   cellBwpList/1/bwpDN=${mo_dn}/BWP_PROFILE-${bwpdn1}
#    [Return]    &{parameter_dict}
#
#Get FrameStru Option Paras Dict
#    [Arguments]    ${frame_shift}=3ms    ${tdlte_uldlconfig}=tdLteConfig2
#    &{parameter_dict}   create dictionary     tddFrameStructure/0/lteToNrFrameShift=${frame_shift}
#        ...                                   tddFrameStructure/0/tdLteUlDlConfig=${tdlte_uldlconfig}
#    [Return]    &{parameter_dict}
#
#Trigger CMAS Notification
#    Log to console    start to trigger cmas
#    CMAS Notification    amf=${amf1-amf1-zheng}
#    ...                          message_identifier=4372    serial_number=51
#    ...                          repetition_period=5
#    ...                          number_of_broadcasts_requested=${10}
#    ...                          connection=${cbctest_alias}
#	...                          nr_of_bits_g_node_b_id=22
#    ...                          cell_id=177733633
##    ...                          cell_id=176111617
#    ...                          test_amf_name=test_amf_RRM3.py
#    Log to console    stop to trigger cmas
#
#Trigger CMAS Notification For SIB6
#    Log to console    start to trigger cmas
#    CMAS Notification    amf=${amf1-amf1-zheng}
#    ...                          message_identifier=50    serial_number=51
#    ...                          repetition_period=5
#    ...                          number_of_broadcasts_requested=${10}
#    ...                          connection=${cbctest_alias}
#	...                          nr_of_bits_g_node_b_id=22
#    ...                          cell_id=177733633
##    ...                          cell_id=176111617
#    ...                          test_amf_name=test_etws6_RRM3.py
#    Log to console    stop to trigger cmas
#
#
#Trigger PWS Cancel
#    CMAS PWS Cancel        amf=&{amf1-amf1-zheng}
#    ...                    nr_of_bits_g_node_b_id=22
#    ...                    cell_id=176111617
#    ...                    connection=${cbctest_alias}
#
#Check Write Replace Warning In Log
#    [Arguments]    ${input_file}=${wireshark_local_file_path_vCU}    ${sib_type}=SIB8
#    Log to Console    \n***Check if AMF sends WriteReplaceWarningRequest to gNB-CU-CP
#    ${request_filter} =    catenate      ngap.WriteReplaceWarningRequest_element
#    ${result} =    Analysis Wireshark Log    input_file=${input_file}
#	...                                      filter_expression=${request_filter}
#	should contain    ${result}    WriteReplaceWarningRequest
#
#    Log to Console    \n***Check if Write Replace Warning is broadcast
#    ${sib_filter} =    catenate      f1ap.sIBtype
##    ${sib8_filter} =    catenate      f1ap.sIBtype
#    ${result} =    Analysis Wireshark Log    input_file=${input_file}
#	...                                      filter_expression=${sib_filter}
##	...                                      filter_expression=${sib8_filter}
#	should contain    ${result}    ${sib_type}
#
#    Log to Console    \n***Check if gNB-DU sends WriteReplaceWarningResponse to gNB-CU-CP
#	${response_filter} =    catenate      f1ap.WriteReplaceWarningResponse_element
#	${result} =    Analysis Wireshark Log    input_file=${input_file}
#	...                                      filter_expression=${response_filter}
#	should contain    ${result}    WriteReplaceWarningResponse
#
#	Log to Console    \n***Check if gNB-CU-CP sends WriteReplaceWarningResponse to AMF with BroadcastCompletedAreaList
#	${response_filter} =    catenate      ngap.BroadcastCompletedAreaList
#	${result} =    Analysis Wireshark Log    input_file=${input_file}
#	...                                      filter_expression=${response_filter}
#	should contain    ${result}    WriteReplaceWarningResponse
#
#Check ETWS In Log
#    [Arguments]    ${input_file}=${wireshark_local_file_path_vCU}
#    Log to Console    \n***Check if AMF sends WriteReplaceWarningRequest to gNB-CU-CP
#    ${request_filter} =    catenate      ngap.WriteReplaceWarningRequest_element
#    ${result} =    Analysis Wireshark Log    input_file=${input_file}
#	...                                      filter_expression=${request_filter}
#	should contain    ${result}    WriteReplaceWarningRequest
#
#    Log to Console    \n***Check if SIB8(CMAS) is broadcast
#    ${sib8_filter} =    catenate      f1ap.sIBtype
#    ${result} =    Analysis Wireshark Log    input_file=${input_file}
#	...                                      filter_expression=${sib8_filter}
#	should contain    ${result}    SIB8
#
#    Log to Console    \n***Check if gNB-DU sends WriteReplaceWarningResponse to gNB-CU-CP
#	${response_filter} =    catenate      f1ap.WriteReplaceWarningResponse_element
#	${result} =    Analysis Wireshark Log    input_file=${input_file}
#	...                                      filter_expression=${response_filter}
#	should contain    ${result}    WriteReplaceWarningResponse
#
#	Log to Console    \n***Check if gNB-CU-CP sends WriteReplaceWarningResponse to AMF with BroadcastCompletedAreaList
#	${response_filter} =    catenate      ngap.BroadcastCompletedAreaList
#	${result} =    Analysis Wireshark Log    input_file=${input_file}
#	...                                      filter_expression=${response_filter}
#	should contain    ${result}    WriteReplaceWarningResponse
#
#Check Counter For Successful_CMAS
#    Sleep    360s    reason=wait generate counter
#    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
#    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    Log to Console    \n***Check M55119C02001(NNGCB_WRWR_REQ_RECD), M55119C02002(NNGCB_WRWR_RESP_SENT) counters
#    &{type1_counter_dict}    create dictionary    counterId=M55119C02001,M55119C02002
#    ...                                           dimDN=${dim_dn}
#    ...                                           ne=vCU
#    ...                                           gnbIndex=0
#    ...                                           comparison=greater
#    ...                                           value=0
#    &{type2_counter_dict}    create dictionary    counterId=M55119C02006
#    ...                                           dimDN=${dim_dn}
#    ...                                           ne=vCU
#    ...                                           gnbIndex=0
#    ...                                           comparison=equal
#    ...                                           value=0
#
#    ${counter_list}    Create List    ${type1_counter_dict}    ${type2_counter_dict}
#
#    FOR    ${counter}    IN    @{counter_list}
#        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
#        ${ne}    Set Variable   ${counter['ne']}
#
#        Run Keyword If    '${ne}'=='vDU'     Check Counter In vDU    counter_id_list=${counter_id_list}
#        ...                                                         dim_dn=${counter['dimDN']}
#        ...                                                         gnb_index=${counter['gnbIndex']}
#        ...                                                         comparison=${counter['comparison']}
#        ...                                                         expected_value=${counter['value']}
#        ...                                                         get_number=3
#        ...    ELSE IF    '${ne}'=='vCU'    Check Counter In vCU    counter_id_list=${counter_id_list}
#        ...                                                         dim_dn=${counter['dimDN']}
#        ...                                                         gnb_index=${counter['gnbIndex']}
#        ...                                                         comparison=${counter['comparison']}
#        ...                                                         expected_value=${counter['value']}
#        ...                                                         get_number=3
#    END
#
#Check Counter For ETWS
#    Sleep    360s    reason=wait generate counter
#    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
#    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    Log to Console    \n***Check M55119C02001(NNGCB_WRWR_REQ_RECD), M55119C02002(NNGCB_WRWR_RESP_SENT) counters
#    &{type1_counter_dict}    create dictionary    counterId=M55119C02001,M55119C02002
#    ...                                           dimDN=${dim_dn}
#    ...                                           ne=vCU
#    ...                                           gnbIndex=0
#    ...                                           comparison=greater
#    ...                                           value=0
#    ${counter_list}    Create List    ${type1_counter_dict}
#
#    FOR    ${counter}    IN    @{counter_list}
#        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
#        ${ne}    Set Variable   ${counter['ne']}
#
#        Run Keyword If    '${ne}'=='vDU'     Check Counter In vDU    counter_id_list=${counter_id_list}
#        ...                                                         dim_dn=${counter['dimDN']}
#        ...                                                         gnb_index=${counter['gnbIndex']}
#        ...                                                         comparison=${counter['comparison']}
#        ...                                                         expected_value=${counter['value']}
#        ...                                                         get_number=3
#        ...    ELSE IF    '${ne}'=='vCU'    Check Counter In vCU    counter_id_list=${counter_id_list}
#        ...                                                         dim_dn=${counter['dimDN']}
#        ...                                                         gnb_index=${counter['gnbIndex']}
#        ...                                                         comparison=${counter['comparison']}
#        ...                                                         expected_value=${counter['value']}
#        ...                                                         get_number=3
#    END
#
#Check Carrier Bandwidth In Wireshark
#    [Arguments]      ${log_path}=${capture_file_path}
#    Log to Console    \n***Check Carrier Bandwidth In Wireshark***
#    ${source_chBw_filter} =    catenate    f1ap.UEContextSetupRequest_element
#    ${target_chbw_filter} =    catenate    f1ap.UEContextSetupResponse_element
#    ${source_chBw}=    Run
#    ...    tshark -Y "${source_chBw_filter}" -T fields -e nr-rrc.carrierBandwidth -r ${log_path}
#    ${target_chbw}=    Run
#    ...    tshark -Y "${target_chbw_filter}" -T fields -e nr-rrc.carrierBandwidth -r ${log_path}
#
#    ${source_chbw_value}    Get carrierBandwidth Value    chbw=${source_chBw}
#    ${target_chbw_value}    Get carrierBandwidth Value    chbw=${target_chbw}
#    should not be equal    ${source_chbw_value}    ${target_chbw_value}
#
#Get carrierBandwidth Value
#    [Arguments]    ${chbw}
#	${chbw_list}=    split_string    ${chbw}    ,
#    ${chbw_value}    set variable    ${chbw_list}[0]
#    [return]    ${chbw_value}
#
#Modify Parameters By Delta Plan In vCU And vDU
#    [Arguments]   ${parameter}=actCDrx    ${value}=true    ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3
#    log to console    \n***Modify Parameters By Delta Plan In vCU***
#    &{vcu_param}    create dictionary    operation_type=replace    parameter_path=/${parameter}
#    ...                                                                         value=${value}
#    @{updated_vcu_param}    Create List    ${vcu_param}
#    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=${parameter}
#    ...                                                   updated_paras_dict=${updated_vcu_param}
#    ...                                                   compare_value=${value}
#    ...                                                   mo_dn=${mo_dn}
#
#    log to console    \n***Modify Parameters By Delta Plan In vDU***
#    &{parameter_dict}    Create Dictionary   ${parameter}=${value}
#    &{parameter_dict1}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
#    ...                                                                      mo_parameter_dict=&{parameter_dict}
#    vDU Login By Rest
#    Run Keyword If  &{parameter_dict1} != &{Empty}
#    ...             VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
#	...                                          updated_paras_list=${parameter_dict}
#    ...                                          auto_lock_cells=${False}
#    ...                                          wait_vdu_up=${True}
#
#Get Ssh Info
#    [Arguments]    ${ne_type}=vdu   ${gnb_index}=0    ${vdu_index}=0
#    &{ssh_info}=    Run Keyword If   '${ne_type.upper()}'=='VDU'    create dictionary
#    ...                                      hostname=${vdu_hostname_dict['vcu_${gnb_index}_vdu_hostname'][${vdu_index}]}
#    ...                                      username=${vdu_username_dict['vcu_${gnb_index}_vdu_username'][${vdu_index}]}
#    ...                                      password=${vdu_password_dict['vcu_${gnb_index}_vdu_password'][${vdu_index}]}
#    ...                                      namespace=${vdu_ns_dict['vcu_${gnb_index}_vdu_ns'][${vdu_index}]}
#    ...    ELSE IF   '${ne_type.upper()}'=='VCU'    create dictionary
#    ...                                      hostname=${vcu_hostname_list[${gnb_index}]}
#    ...                                      username=${vcu_username_list[${gnb_index}]}
#    ...                                      password=${vcu_password_list[${gnb_index}]}
#    ...                                      namespace=${vcu_ns_list[${gnb_index}]}
#    [return]    ${ssh_info}
#
#Get WebEM Info
#    [Arguments]    ${ne_type}=vdu   ${gnb_index}=0    ${vdu_index}=0
#    ${oam_httpaddr}    Set Variable If    '${ne_type.upper()}'=='VDU'
#    ...                 ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
#    ...                                   '${ne_type.upper()}'=='VCU'
#    ...                 ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
#
#    ${oam_web_ip}    set variable if    ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
#    &{webem_info}=    create dictionary    host=${oam_web_ip}    username=Nemuadmin    password=Nokia@123    port=443
#    [return]    ${webem_info}
#
#Start Capture Log By Dcap
#    [Arguments]    ${dcap_ip}    ${alias}=dcap    ${ne_type}=vdu   ${vdu_custom_profile}=${None}   ${vcu_custom_profile}=${None}
#    ...            ${gnb_index}=0    ${vdu_index}=0
#    ${ssh_info}    Get Ssh Info    ne_type=${ne_type}   gnb_index=${gnb_index}    vdu_index=${vdu_index}
#    ${webem_info}    Get WebEM Info    ne_type=${ne_type}   gnb_index=${gnb_index}    vdu_index=${vdu_index}
#
#    Update DCAP Controller White List
#    ...                     hostname=${ssh_info['hostname']}
#    ...                     username=${ssh_info['username']}
#    ...                     password=${ssh_info['password']}
#    ...                     namespace=${ssh_info['namespace']}
#    ...                     dcap_ip=${dcap_ip}    operation_type=add
#
#    Connect To DCAP    host=${dcap_ip}     port=443    username=dcapuser
#    ...                password=dcapadmin!    alias=${alias}
#    Make Sure BTS Integrated In DCAP    ${webem_info}
#
#    ${trace_id}    Run Keyword If   '''${vdu_custom_profile}'''!='''${None}''' and '''${vcu_custom_profile}'''=='''${None}'''
#    ...         Start Trace In DCAP    ${webem_info}    vdu_custom_profile=${vdu_custom_profile}
#    ...  ELSE IF  '''${vdu_custom_profile}'''=='''${None}''' and '''${vcu_custom_profile}'''!='''${None}'''
#    ...         Start Trace In DCAP    ${webem_info}    vcu_custom_profile=${vcu_custom_profile}
#    [Return]    ${trace_id}
#
#Check Drx config Info In Wireshark
#    [Arguments]      ${log_path}    ${drx_long_cycle}
#    Log to Console    \n***Check Drx config Info In Wireshark***
#    ${drx_filter}    Set Variable If    '${drx_long_cycle}'=='40ms'    nr-rrc.drx_LongCycleStartOffset==3
#    ...                                 '${drx_long_cycle}'=='160ms'    nr-rrc.drx_LongCycleStartOffset==9
#    ${result} =    Analysis Wireshark Log    input_file=${log_path}
#	...                                      filter_expression=${drx_filter}
#	should contain    ${result}    UEContextModificationResponse
#
#Modify Parameters By Delta Plan
#    [Arguments]   ${ne}=vDU    ${parameter}=actCDrx    ${value}=true
#    ...           ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#    Run Keyword If    '${ne}'=='vDU'    Modify Parameters By Delta Plan In vDU    parameter=${parameter}
#    ...                                                                           value=${value}
#    ...                                                                           mo_dn=${mo_dn}
#    ...            ELSE IF   '${ne}'=='vCU'    Modify Parameters By Delta Plan In vCU    parameter=${parameter}
#    ...                                                                                  value=${value}
#    ...                                                                                  mo_dn=${mo_dn}
#    ...            ELSE IF   '${ne}'=='all'    Modify Parameters By Delta Plan In vCU And vDU    parameter=${parameter}
#    ...                                                                                   value=${value}
#
#Modify Parameters By Delta Plan In vDU
#    [Arguments]   ${parameter}=actCDrx    ${value}=true    ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#    &{parameter_dict}    Create Dictionary   ${parameter}=${value}
#    &{parameter_dict1}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
#    ...                                                                      mo_parameter_dict=&{parameter_dict}
#    vDU Login By Rest
#    Run Keyword If    &{parameter_dict1} != &{Empty}    VDU Online Modify Parameters By Delta Plan REST
#    ...                                          mo_dn=${mo_dn}
#    ...                                          updated_paras_list=${parameter_dict}
#    ...                                          operation=replace
#    ...                                          activate=${True}
#    ...                                          force_reset=${False}
#    ...                                          auto_lock_cells=${False}
#    ...                                          wait_vdu_up=${False}
#    vDU Logout By Rest
#    [Teardown]    Run Keyword And Ignore error    vDU Logout By Rest
#
#Lock Cell
#    ${cell_id_list}    Create List    1
#    Lock Cell In vDU    cell_id_list=${cell_id_list}
#
#Unlock Cell
#    ${cell_id_list}    Create List    1
#    Unlock Cell In vDU    cell_id_list=${cell_id_list}
#
#Check Counter For 5GC002645
#    Sleep    360s    reason=wait generate counter
#    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
#    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    Log to Console    \n***Check M55119C02006(NNGCB_PWS_REST_IND_SENT) counter
#    &{type1_counter_dict}    create dictionary    counterId=M55119C02006
#    ...                                           dimDN=${dim_dn}
#    ...                                           ne=vCU
#    ...                                           gnbIndex=0
#    ...                                           comparison=greater
#    ...                                           value=0
#    ${counter_list}    Create List    ${type1_counter_dict}
#
#    FOR    ${counter}    IN    @{counter_list}
#        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
#        ${ne}    Set Variable   ${counter['ne']}
#
#        Run Keyword If    '${ne}'=='vDU'     Check Counter In vDU    counter_id_list=${counter_id_list}
#        ...                                                         dim_dn=${counter['dimDN']}
#        ...                                                         gnb_index=${counter['gnbIndex']}
#        ...                                                         comparison=${counter['comparison']}
#        ...                                                         expected_value=${counter['value']}
#        ...                                                         get_number=3
#        ...    ELSE IF    '${ne}'=='vCU'    Check Counter In vCU    counter_id_list=${counter_id_list}
#        ...                                                         dim_dn=${counter['dimDN']}
#        ...                                                         gnb_index=${counter['gnbIndex']}
#        ...                                                         comparison=${counter['comparison']}
#        ...                                                         expected_value=${counter['value']}
#        ...                                                         get_number=3
#    END
#
#Check Counter for CB008033_intra-gNB_Intra-DU_for_SA_VoNR
#    Log to Console    \n*******Wait and check counters
#    Sleep    360s    reason=wait generate counter
#    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
#    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    &{type1_counter_dict}    create dictionary    counterId=M55153C00001,M55153C00002
#    ...                                           dimDN=${dim_dn}/NRCELL-1/NRCI-177733635/MCC-262/MNC-03
#    ...                                           ne=vCU
#    ...                                           gnbIndex=0
#    ...                                           comparison=greater
#    ...                                           value=0
#    &{type2_counter_dict}    create dictionary    counterId=M55177C00003,M55177C00004,M55177C00005,M55177C00011,M55177C00012
#    ...                                           dimDN=${dim_dn}/NRCELL-1
#    ...                                           ne=vCU
#    ...                                           gnbIndex=0
#    ...                                           comparison=greater
#    ...                                           value=0
#    ${counter_list}    Create List    ${type1_counter_dict}    ${type2_counter_dict}
#
#    FOR    ${counter}    IN    @{counter_list}
#        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
#        ${ne}    Set Variable   ${counter['ne']}
#
#        Run Keyword If    '${ne}'=='vDU'     Check Counter In vDU    counter_id_list=${counter_id_list}
#        ...                                                         dim_dn=${counter['dimDN']}
#        ...                                                         gnb_index=${counter['gnbIndex']}
#        ...                                                         comparison=${counter['comparison']}
#        ...                                                         expected_value=${counter['value']}
#        ...                                                         get_number=3
#        ...    ELSE IF    '${ne}'=='vCU'    Check Counter In vCU    counter_id_list=${counter_id_list}
#        ...                                                         dim_dn=${counter['dimDN']}
#        ...                                                         gnb_index=${counter['gnbIndex']}
#        ...                                                         comparison=${counter['comparison']}
#        ...                                                         expected_value=${counter['value']}
#        ...                                                         get_number=3
#    END
#
#Check Service Account SSH State
#    [Arguments]    ${ssh_mode_type}    ${dist_name}    ${expected_status}
#    Log to Console    \n***Check Service Account SSH State***
#    ${port_status}    Get SSH Tunnel Status    ssh_mode_type=${ssh_mode_type}    dist_name=${dist_name}
#    should be equal    "${port_status}"  "${expected_status}"   The state of service account ssh is not expected!
#
#Collect Container Log
#    [Arguments]    ${pod_name}    ${container_name}    ${duration}=180s
#    sleep    60s    reason=wait ${container_name} container log generate
#    Log to Console    \n***Collect And Download ${container_name} container Log In vDU***
#    ${container_log}    Collect And Download K8s Log In vDU    gnb_index=${0}    vdu_index=${0}
#    ...                                                    container_name=${container_name}    pod_name=${pod_name}
#    ...                                                    duration=${duration}
#    [Return]    ${container_log}
#
#Check ssh tunnel configuration in Log
#    [Arguments]    ${log_path}
#    Log to Console    \n***Check ssh tunnel configuration in ${log_path} Log***
#    ${tunnel_filter}    Set Variable    6tunnelmanager
#    ${output}    OperatingSystem.Run    command=cat ${log_path} | grep -a "${tunnel_filter}"
#    should contain    ${output}    setRannicSshTunnelConfiguration
#
#Check Ssh Session Status
#    [Arguments]    ${conn}
#    ${contents}=    tafssh.execute   lslogins -u   connection=${conn}
#    Log To Console  ${contents}
#
#Check Sshd Session Status in Log
#    [Arguments]    ${log_path}    ${session_status}=closed
#    Log to Console    \n***Check Sshd Session Status in ${log_path} Log***
#    ${sshd_filter}    Set Variable    sshd
#    ${output}    OperatingSystem.Run    command=cat ${log_path} | grep -a "${sshd_filter}"
#    should contain    ${output}    session ${session_status} for user serviceuser
#
#Check Account Ssh Sync in Log
#    [Arguments]    ${log_path}
#    Log to Console    \n***Check Account Ssh Sync in ${log_path} Log***
#    ${ssh_sync_filter}    Set Variable    syscomSshSyncMsgHandler
#    ${output}    OperatingSystem.Run    command=cat ${log_path} | grep -a "${ssh_sync_filter}"
#    should contain    ${output}    receive account ssh sync request
#    should contain    ${output}    finished ssh sync handler
#
#Lock Xn Link
#    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRADJGNB-1
#    &{param}    create dictionary    operation_type=replace    parameter_path=/administrativeState
#    ...                                                                         value=Locked
#    @{updated_param}    Create List    ${param}
#    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=administrativeState
#    ...                                                   updated_paras_dict=${updated_param}
#    ...                                                   compare_value=Locked
#    ...                                                   mo_dn=${mo_dn}
#
#Unlock Xn Link
#    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRADJGNB-1
#    &{param}    create dictionary    operation_type=replace    parameter_path=/administrativeState
#    ...                                                                         value=Unlocked
#    @{updated_param}    Create List    ${param}
#    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=administrativeState
#    ...                                                   updated_paras_dict=${updated_param}
#    ...                                                   compare_value=Unlocked
#    ...                                                   mo_dn=${mo_dn}
#
#Start Collect Wireshark Log In Target vCU
#    [Arguments]    ${alias}=target_vcu_master
#    ${ip_list}  ${username_list}  ${password_list}  ${ns_list}    Get SSH Connection Infor For Multiple vCU K8s Master
#    Set Test Variable    ${ip_list}
#    Set Test Variable    ${username_list}
#    Set Test Variable    ${password_list}
#    Set Test Variable    ${ns_list}
#    Log to Console    \n***Start Wireshark Log In Target vCU***
#    Start Wireshark Log In vCU   gnb_index=${1}
#    ...                          alias=${alias}
#    ...                          hostname=${ip_list[1]}
#    ...                          username=${username_list[1]}
#    ...                          password=${password_list[1]}
#    ...                          namespace=${ns_list[1]}
#
#Stop target Wireshark Log
#    Log to Console    Stop Wireshark Log
#    ${target_log_path}   Stop Wireshark Log And Download To K8s Master In vCU   gnb_index=${1}
#    ...                                                                    log_name=target_vcu
#    ...                                                                    alias=target_vcu_master
#    ...                                                                    hostname=${ip_list[1]}
#    ...                                                                    username=${username_list[1]}
#    ...                                                                    password=${password_list[1]}
#    ...                                                                    namespace=${ns_list[1]}
#    Set Test Variable    ${target_log_path}
#
#Check SST And NG HO In Wireshark
#    [Arguments]      ${target_log_path}=${target_log_path}
#    Check SST In Wireshark    log_path=${target_log_path}
#    Check NG HO Notify In Wireshark    log_path=${target_log_path}
#
#Check SST In Wireshark
#    [Arguments]      ${log_path}=/home/ute/cpif_source_vcu.pcap
#    Log to Console    \n***Check SST in wireshark***
#    ${sst_filter} =    catenate    (nas_5gs.mm.sst == 2)|| (e1ap.sST == 02)|| (f1ap.sST == 02)|| (ngap.sST == 02)
#    ${result} =    Analysis Wireshark Log    input_file=${log_path}
#	...                                      filter_expression=${sst_filter}
#	${protocol_list}    Create List    E1AP    F1AP    NGAP
#    FOR    ${protocol}    IN    @{protocol_list}
#        should contain    ${result}    ${protocol}
#        Log to Console    \n***Configured sst is delivered towards ${protocol}***
#    END
#
#Check Counter For NG A3 Handover
#    [Arguments]    ${sst}=1
#    Sleep    400s    reason=wait generate counter
#    Log to Console    \n***check counter for source cell in vcu***
#    ${MRBTS1_ID}    Set Variable   ${MRBTS_ID_list}[1]
#    ${cu_counter_id_list}    Create List    M55125C07512
#    FOR    ${cu_counter_id}    IN    @{cu_counter_id_list}
#        ${counter_values_final}    Check Counter For vCU   counter_id=${cu_counter_id}
#        ...                                            measurement_id=55125
#        ...                                            dimension_dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#        ...                                            expected_value=0
#        ...                                            get_number=3
#    END
#
#    ${cu_counter_id_list}    Create List    M55149C03001    M55149C03002    M55149C03003
#    FOR    ${cu_counter_id}    IN    @{cu_counter_id_list}
#        ${counter_values_final}    Check Counter For vCU   counter_id=${cu_counter_id}
#        ...                                            measurement_id=55149
#        ...                                            dimension_dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/MCC-262/MNC-03/SST-${sst}/SD-13714341
#        ...                                            expected_value=0
#        ...                                            get_number=3
#    END
#
#    ${cu_counter_id_list}    Create List    M55153C00501    M55153C00502    M55153C00503
#    FOR    ${cu_counter_id}    IN    @{cu_counter_id_list}
#        ${counter_values_final}    Check Counter For vCU   counter_id=${cu_counter_id}
#        ...                                            measurement_id=55153
#        ...                                            dimension_dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1/NRCI-178176001/MCC-262/MNC-03
#        ...                                            expected_value=0
#        ...                                            get_number=3
#    END
#
#    Log to Console    \n***check counter for target cell in vcu***
#    ${cu_counter_id_list}    Create List    M55125C07503    M55125C07504    M55125C07520
#    FOR    ${cu_counter_id}    IN    @{cu_counter_id_list}
#        ${counter_values_final}    Check Counter For vCU   counter_id=${cu_counter_id}
#        ...                                            measurement_id=55125
#        ...                                            dimension_dist_name=MRBTS-${MRBTS1_ID}/NRBTS-${MRBTS1_ID}/NRCELL-1
#        ...                                            expected_value=0
#        ...                                            get_number=3
#        ...                                            gnb_index=1
#    END
#
######################################### CB008120_Xn########################################
#Stop Wireshark Log And Check Inter Gnb HO With Slice
#    Log to Console    Stop Wireshark Log And Check Inter Gnb HO
#    ${local_file_path}    Stop Wireshark Log And Download To K8s Master In vCU
#    ${source_slice_filter} =    catenate    xnap.sst == 02||xnap.radioNetwork == 1
#    ${xn_ho} =    Analysis Wireshark Log    input_file=${local_file_path}
#	...                                      filter_expression=${source_slice_filter}
#	should contain    ${xn_ho}    HandoverRequest
#	${source_xn_filter} =    catenate    xnap.Target2SourceNG_RANnodeTranspContainer
#    ${xn_ho} =    Analysis Wireshark Log    input_file=${local_file_path}
#	...                                      filter_expression=${source_xn_filter}
#	should contain    ${xn_ho}    HandoverRequestAcknowledge
#
#Check Counter For Xn A3 Handover
#    Sleep    360s    reason=wait generate counter
#    Log to Console    \n***check counter for source cell in vcu***
#    ${MRBTS1_ID}    Set Variable   ${MRBTS_ID_list}[1]
#    ${cu_counter_id_list}    Create List    M55143C00001    M55143C00004
#    FOR    ${cu_counter_id}    IN    @{cu_counter_id_list}
#        ${counter_values_final}    Check Counter For vCU   counter_id=${cu_counter_id}
#        ...                                            measurement_id=55143
#        ...                                            dimension_dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#        ...                                            expected_value=0
#        ...                                            get_number=3
#    END
#
#    Log to Console    \n***check counter for target cell in vcu***
#    ${cu_counter_id_list}    Create List    M55143C00005    M55143C00006
#    FOR    ${cu_counter_id}    IN    @{cu_counter_id_list}
#        ${counter_values_final}    Check Counter For vCU   counter_id=${cu_counter_id}
#        ...                                            measurement_id=55143
#        ...                                            dimension_dist_name=MRBTS-${MRBTS1_ID}/NRBTS-${MRBTS1_ID}/NRCELL-1
#        ...                                            expected_value=0
#        ...                                            get_number=3
#        ...                                            gnb_index=1
#    END
#
#Adjust The Signal Via PA To Trigger Inter Gnb HO
#    [Arguments]    ${10848_cell1}=63    ${10875_cell1}=0
#    Log to console    Adjust The Signal Via PA
#    ${attenuation_channels}    Get Attenuation port    RU_id=0    du_id=0
#    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
#    &{channels_to_modify}    create dictionary    ${attenuation_channels[0]}=${10848_cell1}
#    ...                                           ${attenuation_channels[1]}=${10848_cell1}
#    ...                                           ${attenuation_channels[6]}=${10875_cell1}
#    ...                                           ${attenuation_channels[7]}=${10875_cell1}
#    ...                                           ${attenuation_channels[8]}=${10875_cell1}
#    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
#    sleep    10s
#    Log to console    attenuation change complete
#
#Set New Password For RU On Webem
#    [Arguments]    ${username}=serviceuser    ${new_password}=Qwer@12345
#    Log To Console    \n***Set New Password For RU On Webem***
#    ${serviceuser_info}    Update Service Account Passwd In vDU By Rest Api    username=${username}
#    ...                    new_password=${new_password}
#
#Try To Connect Ru with New Password
#    [Arguments]     ${password}=Qwer@12345
#    Log To Console    \n***Try To Connect Ru with Default Password***
#    ${expected_error}    Set Variable    No match found*
#    Run Keyword And Expect Error    ${expected_error}    SSH Ru By VDU Container    ru_password=${password}
#
#Check SSH Connection Status
#    [Arguments]  ${conn}
#    Log To Console    \*** Check ssh connection status
#    ${cmd}=    Catenate    lslogins -u
#    tafssh.Execute    command=${cmd}    connection=${conn}
#
#Check SSH Rort Status
#    [Arguments]    ${ssh_mode_type}=RMOD    ${expected_status}=Deactivated
#    ...            ${dist_name}=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
#    Log To Console    \*** Check SSH Rort Status
#    ${port_status}    Get SSH Tunnel Status    ssh_mode_type=${ssh_mode_type}    dist_name=${dist_name}
#    should be equal    ${port_status}    ${expected_status}    The port status is not the expected status
#
#Download FCE For Current SW
#    log to console  Download FCE For Current SW
#    Open WEBEM and Login    URL=https://${mplan_ip}      # TL10846
#    ${fce_worker}  ${fct_files}  Download FCE Modules For vDU    trunk_prefix=vDUCNF25R1
#    ${PDCCH_fct_name}    Unzip FCT    ${TEST_LOG_DIRECTORY}/${fct_files}
#    Set Test Variable    ${fce_worker}
#    Set Test Variable    ${fct_files}
#    Set Test Variable    ${PDCCH_fct_name}
#
#Unzip FCT
#    [Arguments]    ${zip_file}
#    ${rc}    ${out_put}    OperatingSystem.Run and Return RC and Output    unzip -o ${zip_file} -d ${TEST_LOG_DIRECTORY}
#    Should Be Equal As Integers    ${rc}    ${0}
#    ${PDCCH_FCT_NAME}    Should Match Regexp    ${out_put}    \\w+PDCCH\\w+\\.xlsx
#	${PUCCH_FCT_NAME}    Should Match Regexp    ${out_put}    \\w+PUCCH\\w+\\.xlsx
#    OperatingSystem.File Should Exist    ${TEST_LOG_DIRECTORY}/${PDCCH_FCT_NAME}
#    OperatingSystem.File Should Exist    ${TEST_LOG_DIRECTORY}/${PUCCH_FCT_NAME}
#    [Return]    ${PDCCH_FCT_NAME}    ${PUCCH_FCT_NAME}
#
#Install Valid FCE And Verify Result
#    Log To Console    Install Valid FCE And Verify Result    console=True
#    ${error_message}    Install FCE    fce_worker_file=${TEST_LOG_DIRECTORY}/${fce_worker}
#    Should Be Empty    ${error_message}
#    Check FCE Feature List Not Empty
#
#Check FCE Feature List Not Empty
#    ${FCE_Feature_list}    Get FCE Feature List
#    Should Not Be Empty    ${FCE_Feature_list}
#
#Select Expected FCE From Droplist
#    [Arguments]    ${expected_FCE_feature_name}
#    Log To Console    Select Expected FCE From Droplist    console=True
#    ${FCE_list_object}    Select Feature In Configuration Automation    ${expected_FCE_feature_name}
#    Set Test Variable    ${FCE_list_object}
#
#Check Actual Full Configuration Selected As Default
#    Log    Check Actual Full Configuration Selected As Default   console=True
#    ${list_plan}    ${current_plan}    Get Plan Options From WebEM CA
#    Should Be Equal As Strings    ${current_plan}    ${default_plan_name}
#    Select Plan On CA    ${default_plan_name}
#
#Download FCE Modules For vDU
#    [Arguments]    ${trunk_prefix}=vDUCNF23R4
#    ${active_sw_version}    Get vDU Version
#    ${current_prefix}    Set Variable    ${active_sw_version.split('_')[0].strip()}
#    ${current_release}    Set Variable If    "${current_prefix}" == "${trunk_prefix}"    vDUCNF00    ${current_prefix}
#    ${version_num}    Fetch From Right    ${active_sw_version}    _
#    ${current_version}    Set Variable    ${current_release}_${version_num}
#    ${fce_worker}    ${fct_files}    Download FCE And FCT Tools    target_version=${current_version}    target_download_path=${TEST_LOG_DIRECTORY}
#    ...    release_name=${current_release}    clean_folder=${FALSE}
#    [Return]    ${fce_worker}    ${fct_files}
#
#Download FCE And FCT Tools
#    [Arguments]    ${target_version}    ${target_download_path}=/home/ute/Downloads    ${release_name}=vDUCNF00    ${clean_folder}=${TRUE}
#    ${download_command}    Set Variable    sudo wget --progress=dot:giga -T 600 -t 2
#    ${download_source_path}    Set Variable
#    ...    https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/${release_name}
#    ${status}    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${target_download_path}
#    Run Keyword If    ${status}    OperatingSystem.Create Directory    ${target_download_path}
#    ${remove_files_cmd}    Set Variable    sudo rm -rf ${target_download_path}/*
#    Run Keyword If    ${clean_folder}    OperatingSystem.Run    ${remove_files_cmd}
#    ${fce_worker}    Set Variable    ${target_version}_fce-worker.zip
#    ${fct_files}    Set Variable    ${target_version}_fct-files.zip
#    Log To Console    \nStart Download FCE For ${target_version}...........
#    ${output}    Wait Until Keyword Succeeds    5m    5s    OperatingSystem.Run
#    ...    ${download_command} ${download_source_path}/${target_version}/${fce_worker} -O ${target_download_path}/${fce_worker}
##    Should Contain    ${output}    100%
#    Log To Console    \nComplete Download FCE For ${target_version}...........
#    Log To Console    \nStart Download FCT For ${target_version}...........
#    ${output}    Wait Until Keyword Succeeds    5m    5s    OperatingSystem.Run
#    ...    ${download_command} ${download_source_path}/${target_version}/${fct_files} -O ${target_download_path}/${fct_files}
##    Should Contain    ${output}    100%
#    Log To Console    \nComplete Download FCT For ${target_version}...........
#    OperatingSystem.File Should Exist    ${target_download_path}/${fce_worker}
#    OperatingSystem.File Should Exist    ${target_download_path}/${fct_files}
#    [Return]    ${fce_worker}    ${fct_files}
#
#Check Parameters after Case
#    ${check_result}    Create List
#    ${Check_status}    Run Keyword And Return Status    Check Paging Parameters In Full Plan    targetCell=NRCELL-2
#    ...    PAGING_Parameters_Checklist=${Paging_Parameters}
#    Append to List    ${check_result}    ${Check_status}
#    ${Check_status}    Run Keyword And Return Status    Check PDCCH Parameters In Full Plan    targetCell=NRCELL-2
#    ...    PDCCH_Parameters_Checklist=${PDCCH_Parameters}
#    Append to List    ${check_result}    ${Check_status}
#    [Return]    ${check_result}
#
#CB012125 Case Precondition
#    Log To Console    Case Precondition
#    ${time}    Get Time    epoch
#    Import Library    XML    use_lxml=True    WITH NAME    L_XML
#    ${scf_content}    L_XML.Parse Xml    ${COMMISSIONING_PATH}
#    ${NRBTS_RELEASE}    L_XML.Get Element Attribute    ${scf_content}    version    .//managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]
#    Set Test Variable    ${NRBTS_RELEASE}    com.nokia.srbts.nrbts:${NRBTS_RELEASE.split("_")[0]}
#    ${elements_nrcell}    L_XML.Get Elements    ${scf_content}    .//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
#    ${LIST_NRCELL_DN}    Create List
#    FOR    ${element}    IN    @{elements_nrcell}
#    ${dn}    L_XML.Get Element Attribute    ${element}    distName
#    Append To List    ${LIST_NRCELL_DN}    ${dn}
#    END
#    Set Test Variable    ${LIST_NRCELL_DN}
#    Common Test Setup For AIC
#    ${vdu_hostname_dict}    ${vdu_username_dict}    ${vdu_password_dict}    ${vdu_ns_dict}
#    ...                                               Get SSH Connection Infor For Multiple vDU With Different vCU
#    Set Test Variable    ${vdu_hostname_dict}
#    Set Test Variable    ${vdu_username_dict}
#    Set Test Variable    ${vdu_password_dict}
#    Set Test Variable    ${vdu_ns_dict}
#    ${vcu_hostname_list}  ${vcu_username_list}  ${vcu_password_list}  ${vcu_ns_list}
#    ...                                               Get SSH Connection Infor For Multiple vCU K8s Master
#    Set Test Variable    ${vcu_hostname_list}
#    Set Test Variable    ${vcu_username_list}
#    Set Test Variable    ${vcu_password_list}
#    Set Test Variable    ${vcu_ns_list}
#    ${NEW_PLAN_NAME}     Get Test Case Name
#    Set Test Variable    ${NEW_PLAN_NAME}
#    Set Test Variable    ${NEW_PLAN_NAME}
#
#Online Change miNrRlfPerCell to 5min
#    @{para_list}          Create List    miNrRlfPerCell
#    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPMRNL-1
#    @{value_list_true}    Create List    5min
#    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
#    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vcu
#
#Parameter Updated Both VDU And VCU
#    @{para_list}          Create List    actCDrx
#    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
#    @{value_list_true}    Create List    true
#    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
#    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vdu
#    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
#    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vcu
