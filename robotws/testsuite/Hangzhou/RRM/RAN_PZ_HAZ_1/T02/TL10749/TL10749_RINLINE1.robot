*** Settings ***
Documentation
...    Author: sudi lou
...    Contact: sudi.lou@nokia-sbell.com
...    this file is collect some Common KWs of AIC,you can use it in your case directly.
...    Please do not modify the file without notification to author
...    Deprecated case removed by civen.chen

#
#Suite Setup    Run keywords    Common Suite Setup For AIC
#...            AND      Get SSH Connection Info of gNB
#Suite Teardown    Run keywords    Common Suite Teardown For AIC
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
#
#
#
#*** Test Cases ***
#5GC000786_Successful_Intra_frequency_Intra_DU_Intra_gNB_handover_based_on_A3_measurements_with_5QI_1_and_5QI_5_and_optionally_5QI_2
#    [Tags]      CRT    5GC000786_HO    CB009881
#    [Documentation]
#    ...    Author: sudi.lou@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    20.10.2022,sudi.lou@nokia-sbell.com, draft
#    [Setup]      Case Precondition
#    Start Collect Wireshark Log    NE=all
#    Prepare And Attach UE    ue_index=0
#    Start VONR Call For UE    ue_index=0
#    Start Call For UE    ue_index=0    direction=dl
#    Start Call For UE    ue_index=0    direction=ul
#    Sleep    5s    reason=wait call stable
#    Trigger intra Fre intra gnb based Handover
#    Stop Wireshark Log    NE=all
#    Stop Cpue Log
#    Check HO status in Cpue Log
#    Check VONR Call Status after HO
#    Stop L2rt Log And Check DL Tput
#    Check Counter For 5GC000786_HO
#    [Teardown]      5GC000786 Postcondition
#
#5GC000704_Successful_intra_frequency_intra_DU_intra_gNB_handover_based_on_A5_measurements
#    [Tags]      CRT    5GC000704_intraDU    CB009881
#    [Documentation]
#    ...    Author: sudi.lou@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    20.10.2022,sudi.lou@nokia-sbell.com, draft
#    [Setup]      5GC000704 Precondition
#    Prepare And Attach UE    ue_index=0
#    Start Call For UE    ue_index=0    direction=dl
#    Trigger intra Fre intra gnb based Handover
#    Stop Cpue Log
#    Check HO status in Cpue Log
#    Stop L2rt Log And Check DL Tput
#    Check Counter For 5GC000704_intraDU
#    [Teardown]      5GC000704 Postcondition
#
#CB009881_5GC000705_Successful_intra-frequency_inter-gNB_NG_based_handover_based_on_A3_or_A5_measurements_with_ROHC_enabled
#    [Tags]      CRT    5GC000705_ROHC    CB009881    inter_gnb
#    [Documentation]
#    ...    Author: sudi.lou@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    20.10.2022,sudi.lou@nokia-sbell.com, draft
#    [Setup]      5GC000705 Precondition
#    Start Collect Wireshark Log    NE=Multi_vCU
#    Prepare And Attach UE    ue_index=2
#    Start VONR Call For UE    ue_index=2    capabilities=OPPO
#    Start Call For UE    ue_index=2    direction=dl
#    Sleep    5s    reason=wait call stable
#    Trigger intra Fre inter gnb based Handover
#    Stop Wireshark Log    NE=Multi_vCU
#    Check NG HO Notify In Wireshark    log_path=${Target_vCU_wireshark}
#    Stop Cpue Log
#    Check HO status in Cpue Log
#    Check VONR Call Status after HO
#    Check Counter for 5GC000705
#    [Teardown]    5GC000705 Postcondition
#
#CB009881_5GC000704_Successful_Intra_frequency_Inter_gNB_handover_based_on_A5_measurements_with_5QI_1_and_5QI_5
#    [Tags]      CRT    5GC000704_Xn    CB009881    inter_gnb
#    [Documentation]
#    ...    Author: sudi.lou@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    20.10.2022,sudi.lou@nokia-sbell.com, draft
#    [Setup]      5GC000704_Xn Precondition
#    Start Collect Wireshark Log    NE=Multi_vCU
#    Prepare And Attach UE    ue_index=0
#    Start VONR Call For UE    ue_index=0
#    Sleep    5s    reason=wait call stable
#    Trigger intra Fre inter gnb based Handover
#    Stop Wireshark Log    NE=Multi_vCU
#    Stop Cpue Log
#    Check HO status in Cpue Log
#    Check VONR Call Status after HO
#    Check Counter For 5GC000704_Xn
#    [Teardown]      5GC000704_Xn Postcondition
#
#CB009881_Latency_of_TDD_SA_Inter-gNB_Handover_via_NG_with_6beams
#    [Tags]      CRT    Latency    CB009881    inter_gnb
#    [Documentation]
#    ...    Author: sudi.lou@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    20.10.2022,sudi.lou@nokia-sbell.com, draft
#    [Setup]      5GC000705 Precondition
#    ${loop_latency_list}    create list
#    FOR    ${index}    IN RANGE    3
#        Log to Console    \n***Start to trigger NG based HO for ${index} time***
#        Start Collect Wireshark Log    NE=all    gnb_index=0    index=0    index1=0
#        Start Collect Wireshark Log    NE=all    gnb_index=1    index=1    index1=0
#        Prepare And Attach UE    ue_index=0
#        Start Call For UE    ue_index=0    direction=dl
#        Trigger intra Fre inter gnb based Handover
#        Stop Wireshark Log Both vCU And vDU on Source gNB    gnb_index=0    index=0
#        Stop Wireshark Log Both vCU And vDU on Target gNB    gnb_index=1    index=1
#        Check NG HO Notify In Wireshark    log_path=${target_vCU}
#        # &{latency_dict}    Create Dictionary
#        ${latency_dict}    Get Latency And Interruption In Wireshark
#        append to list    ${loop_latency_list}    ${latency_dict}
#        Detach UE    ue_index=${0}
#        Adjust The Signal Via PA    10749_cell1=0
#    END
#    Check Average Lantency    latency_list=${loop_latency_list}
#    [Teardown]      Latency Postcondition
#
#5GC001349_B PRACH format 0 FDM with PUxCH in TDD FR1
#    [Tags]      CRT    5GC001349    CB009881
#    [Documentation]
#    ...    Author: sudi.lou@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    20.10.2022,sudi.lou@nokia-sbell.com, draft
#    [Setup]      Case Precondition
#    Set vDU Parametrs For 5GC001349   operation=set    frame_stru=tdLte    frame_shift=0ms
#    Prepare And Attach UE    ue_index=0
#    Check Counter for 5GC001349
#    [Teardown]      5GC001349 Postcondition
#
#CB009444_CB008021_TDD_SA_activation_and_Verification_PM_Counters_for_Scheduled_and_Non-scheduled_PRB_values
#    [Tags]      CRT    CB008021    CB009444
#    [Documentation]
#    ...    Author: sudi.lou@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    8.2.2023,sudi.lou@nokia-sbell.com, draft
#    [Setup]      Case Precondition
#    Prepare And Attach UE    ue_index=0
#    Start Call For UE    ue_index=0    direction=ul
#    Check Any One Value In Multiple Counters
#    [Teardown]      CB008021 Postcondition
#
#CB009444_5GC000746_Successful_CMAS_notification_procedure
#    [Tags]      CRT    5GC000746_CMAS    CB009444
#    [Documentation]
#    ...    Author: sudi.lou@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    8.2.2023,sudi.lou@nokia-sbell.com, draft
#    [Setup]      Case Precondition
#    Modify Parameters By Delta Plan In vCU    parameter=actCMAS    value=true
#    ...                                mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    Prepare And Attach UE    ue_index=0
#    Set Mobile Data    ue_index=0    state=on    connection=cygwin
#    Start Call For UE    ue_index=0    direction=ul
#    Start Collect Wireshark Log    NE=all
#    Trigger CMAS Notification
#    Sleep    5s    reason=wait logs to be generated
#    Stop Wireshark Log    NE=all
#    Check Write Replace Warning In Log    input_file=${wireshark_local_file_path_vCU}    sib_type=SIB8
#    Check Counter For Successful_CMAS
#    [Teardown]    5GC000746_CMAS Postcondition
#
#CB009444_5GC000746_Vierfy_PWS_CANCEL_REQUEST_with_Cancel_All_Warning_Messages_Indicator_set_to_true_and_WarningAreaList_is_included
#    [Tags]      CRT    5GC000746_PWS_Cancel    CB009444
#    [Documentation]
#    ...    Author: sudi.lou@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    8.2.2023,sudi.lou@nokia-sbell.com, draft
#    [Setup]      Case Precondition
#    Modify Parameters By Delta Plan In vCU    parameter=actCMAS    value=true
#    ...                                mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    Prepare And Attach UE    ue_index=0
#    Set Mobile Data    ue_index=0    state=off    connection=cygwin
#    Start Collect Wireshark Log    NE=all
#    Trigger CMAS Notification
#    Trigger PWS Cancel
#    Sleep    5s    reason=wait logs to be generated
#    Stop Wireshark Log    NE=all
#    Check PWS Cancel    input_file=${wireshark_local_file_path_vCU}
#    Check Counter For PWS_Cancel
#    [Teardown]    5GC000746_CMAS_cancel Postcondition
#
#CB009444_5GC000747_Successful_ETWS_primary_notification_broadcast
#    [Tags]      CRT    5GC000747_ETWS_primary    CB009444
#    [Documentation]
#    ...    Author: sudi.lou@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    8.2.2023,sudi.lou@nokia-sbell.com, draft
#    [Setup]      Case Precondition
#    Modify Parameters By Delta Plan In vCU    parameter=actETWS    value=true
#    ...                                mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    Prepare And Attach UE    ue_index=0
#    Set Mobile Data    ue_index=0    state=off    connection=cygwin
#    Start Collect Wireshark Log    NE=all
#    Trigger CMAS Notification For SIB6
#    Sleep    5s    reason=wait logs to be generated
#    Stop Wireshark Log    NE=all
#    Check Write Replace Warning In Log    input_file=${wireshark_local_file_path_vCU}    sib_type=SIB6
#    Check Counter For ETWS
#    [Teardown]    5GC000747_ETWS_primary Postcondition
#
#CB009444_5GC000747_Successful_ETWS_secondary_notification_broadcast
#    [Tags]      CRT    5GC000747_ETWS_secondary    CB009444
#    [Documentation]
#    ...    Author: sudi.lou@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    3.3.2023,sudi.lou@nokia-sbell.com, draft
#    [Setup]      Case Precondition
#    Modify Parameters By Delta Plan In vCU    parameter=actETWS    value=true
#    ...                                mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    Prepare And Attach UE    ue_index=0
#    Start Collect Wireshark Log    NE=all
#    Trigger CMAS Notification For SIB7
#    Sleep    5s    reason=wait logs to be generated
#    Stop Wireshark Log    NE=all
#    Check Write Replace Warning In Log    input_file=${wireshark_local_file_path_vCU}    sib_type=SIB7
#    Check Counter For ETWS
#    [Teardown]    5GC000747_ETWS Postcondition
#
#CB009444_5GC000706_TDD_SA_Successful_Inter-frequency_Inter-gNB_XN_based_handover_during_source_and_target_cells_with_different_Bandwidths
#    [Tags]      CRT    5GC000706    inter_gnb
#    [Documentation]
#    ...    Author: sudi.lou@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    3.4.2023,sudi.lou@nokia-sbell.com, draft
#    [Setup]      5GC000706 Precondition
#    Start Collect Wireshark Log    NE=Multi_vCU
#    Prepare And Attach UE    ue_index=0
#    Start Call For UE    ue_index=0    direction=dl
#    Trigger inter Fre inter gnb based Handover
#    Stop Wireshark Log    NE=Multi_vCU
#    Check Carrier Bandwidth In Wireshark    log_path=${Target_vCU_wireshark}
#    Stop Cpue Log
#    Check HO status in Cpue Log
#    Check Counter for 5GC000706
#    [Teardown]    5GC000706 Postcondition
#
#CB009444_5GC000705_TDD_SA_Successful_inter-frequency_inter-gNB_NG_based_handover_based_on_A3_or_A5_measurements_with_ROHC_enabled
#    [Tags]      CRT    5GC000705_interFreq
#    [Documentation]
#    ...    Author: sudi.lou@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    3.4.2023,sudi.lou@nokia-sbell.com, draft
#    [Setup]      5GC000705 Precondition
#    Adjust The Signal Via PA    10749_cell3=0
#    Start Collect Wireshark Log    NE=Multi_vCU
#    Prepare And Attach UE    ue_index=1
#    Start VONR Call For UE    ue_index=1    capabilities=REAL_ANDROID_UE
#    Start Call For UE    ue_index=1    direction=dl
#    Sleep    5s    reason=wait call stable
#    Trigger inter Fre inter gnb based Handover
#    Stop Wireshark Log    NE=Multi_vCU
#    Check NG HO Notify In Wireshark    log_path=${Target_vCU_wireshark}
#    Stop Cpue Log
#    Check HO status in Cpue Log
#    Check VONR Call Status after HO
#    Check Counter for 5GC000705_interFreq
#    [Teardown]    5GC000705_interFreq Postcondition
#
#CB009444_5GC000503_counters_verification_with_SA_UE
#    [Tags]      CRT    5GC000503    CB009444
#    [Documentation]
#    ...    Author: xiaotao.zhou@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    4.4.2023,xiaotao.zhou@nokia-sbell.com, draft
#    [Setup]      Case Precondition
#    Adjust The Signal Via PA    10749_cell1=30
#    Prepare And Attach UE    ue_index=0
#    Start Call For UE    ue_index=0    direction=ul
#    Start Call For UE    ue_index=0    direction=dl
#    Check Any One Value In Multiple Counters for 5GC000503
#    [Teardown]      5GC000786 Postcondition
#
#CB010412-D_CB008737_B_01_Feature_activation_and_deactivation_the_serviceability_of_all_RAN_NIC_devices_connected_to_vDU
#    [Tags]      CRT    Feature_enable_disable
#    [Documentation]
#    ...    Author: sudi.lou@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    20.10.2022,mengli.yang@nokia-sbell.com, draft
#    [Setup]      Case Precondition
#    ${rannic_mo_dn}    Set Variable   MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
#    Modify Parameters By Delta Plan    ne=vDU    parameter=actSshToRanNic    value=true    mo_dn=${rannic_mo_dn}
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
#
#    Modify Parameters By Delta Plan    ne=vDU    parameter=actSshToRanNic    value=false    mo_dn=${rannic_mo_dn}
#    Run Keyword And Ignore Error    Check Ssh Session Status    ${rannic_conn}
#    ${l1commproxy_k8s_log_new}    Collect Container Log    pod_name=ahm    container_name=l1commproxy
#    Check Sshd Session Status in Log    log_path=${l1commproxy_k8s_log_new}    session_status=closed
#    [Teardown]      CB008737_B Postcondition
#
#CB008737_B_02_Automatic_synchronization_of_service_user_account_information_from_vDU_to_all_RAN_NIC_connected_to_vDU
#    [Tags]      CRT    Auto_Sync
#    [Documentation]
#    ...    Author: sudi.lou@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    20.10.2022,mengli.yang@nokia-sbell.com, draft
#    [Setup]      Case Precondition
#    ${rannic_mo_dn}    Set Variable   MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
#    Modify Parameters By Delta Plan    ne=vDU    parameter=actSshToRanNic    value=true    mo_dn=${rannic_mo_dn}
#    Update Service Account Passwd In vDU By Rest Api    username=serviceuser    new_password=Nokia@123
#    ${oamfh_k8s_log}    Collect Container Log    pod_name=oamfh    container_name=oamfh
#    Check Account Ssh Sync in Log    log_path=${oamfh_k8s_log}
#
#    ${rannic_r_dn}    Set Variable   MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/RNICMOD_R-1
#    Reset Rannic By Rest Api    rannic_r_dn=${rannic_r_dn}
#    wait until keyword succeeds  360s  10s    vDU Check All Cells Status Should Be Onair For All DUs
#    Config SSH Tunnel    dist_name=${rannic_r_dn}    operation=Enable
#    Check Service Account SSH State    ssh_mode_type=RNICMOD    dist_name=${rannic_r_dn}    expected_status=Activated
#    ${l1commproxy_k8s_log}    Collect Container Log    pod_name=ahm    container_name=l1commproxy
#    Check ssh tunnel configuration in Log    log_path=${l1commproxy_k8s_log}
#    ${rannic_conn}    Connect Ru Or Rannic Via SSH Tunnel Port    ssh_type=RNICMOD    password=Nokia@123
#    ...                                                    ssh_mode_dist_name=${rannic_r_dn}
#    Set Test Variable    ${rannic_conn}
#
#    Modify Parameters By Delta Plan    ne=vDU    parameter=actSshToRanNic    value=false    mo_dn=${rannic_mo_dn}
#    Modify Parameters By Delta Plan    ne=vDU    parameter=actSshToRanNic    value=true    mo_dn=${rannic_mo_dn}
#    Update Service Account Passwd In vDU By Rest Api    username=serviceuser    new_password=Nokia@456
#    ${oamfh_k8s_log_new}    Collect Container Log    pod_name=oamfh    container_name=oamfh
#    Check Account Ssh Sync in Log    log_path=${oamfh_k8s_log_new}
#    [Teardown]      CB008737_B Postcondition
#
#CB008737_B_04_SSH_access_activation_and_then_deactivation_to_RAN_NIC_connected_to_vDU_with_Listing_the_open_SSH_ports
#    [Tags]      CRT    SSH_access_activation_deactivation
#    [Documentation]
#    ...    Author: sudi.lou@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    20.10.2022,mengli.yang@nokia-sbell.com, draft
#    [Setup]      Case Precondition
#    ${rannic_mo_dn}    Set Variable   MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
#    Modify Parameters By Delta Plan    ne=vDU    parameter=actSshToRanNic    value=true    mo_dn=${rannic_mo_dn}
#    Update Service Account Passwd In vDU By Rest Api    username=serviceuser    new_password=Nokia@123
#    ${rannic_r_dn}    Set Variable   MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/RNICMOD_R-1
#    Config SSH Tunnel    dist_name=${rannic_r_dn}    operation=Enable
#
#    ${l1commproxy_k8s_log}    Collect Container Log    pod_name=ahm    container_name=l1commproxy
#    Check ssh tunnel configuration in Log    log_path=${l1commproxy_k8s_log}
#    ${rannic_conn}    Connect Ru Or Rannic Via SSH Tunnel Port    ssh_type=RNICMOD    password=Nokia@123
#    ...                                                    ssh_mode_dist_name=${rannic_r_dn}
#    Set Test Variable    ${rannic_conn}
#
#    Config SSH Tunnel    dist_name=${rannic_r_dn}    operation=Disable
#    Check Service Account SSH State    ssh_mode_type=RNICMOD    dist_name=${rannic_r_dn}    expected_status=Deactivated
#    Run Keyword And Ignore Error    Check Ssh Session Status    ${rannic_conn}
#    ${l1commproxy_k8s_log_new}    Collect Container Log    pod_name=ahm    container_name=l1commproxy
#    Check ssh tunnel configuration in Log    log_path=${l1commproxy_k8s_log_new}
#    Check Sshd Session Status in Log    log_path=${l1commproxy_k8s_log_new}    session_status=closed
#    [Teardown]      CB008737_B Postcondition
#
#CB010411_CB008033_TDD_SA_Successful_Inter_frequency_Intra_DU_Intra_gNB_handover_with_VONR
#    [Tags]      Intra_DU_inter_frequency_VONR_HO
#    [Documentation]
#    ...    Author: shunxin.jin@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    27.11.2023,shunxin.jin@nokia-sbell.com, draft
#    [Setup]      Case Precondition
##    ${dcap_server}    Set Variable    10.56.221.45
##    ${vcu_profile}    Create List    flowTracerVcu
##    Log to Console    \n*******Start caputring emillogs
##    ${vcu_trace_id}    Start Capture Log By Dcap    dcap_ip=${dcap_server}    alias=dcap    ne_type=vcu
##    ...                                             vcu_custom_profile=${vcu_profile}    gnb_index=0    vdu_index=0
##    Log to Console    \n*******Start doing case operations
#	Prepare And Attach UE    ue_index=2
#    Start VONR Call For UE    ue_index=2    capabilities=OPPO
#    Sleep    5s    reason=wait call stable
#    Trigger inter Fre intra gnb based Handover
##    Log to Console    \n*******Stop doing case operations
##    Log to Console    \n*******Stop caputring emillogs
##    Stop Trace Log By Dcap    ne_type=vcu    gnb_index=0    vdu_index=0
##    ${vcu_zip_file_path}    Save Trace Log By Dcap    ne_type=vcu    gnb_index=0    vdu_index=0
#    Stop Cpue Log
#    Check HO status in Cpue Log
#    Check VONR Call Status after HO    expected_status=hold
#	Stop VONR Call    ue_type=commercial    vc_alias=VC_1
#	Log to Console    \n*******Call Stopped
#    Check Counter For CB008033_intra-gNB_Intra-DU_for_SA_VoNR
#    [Teardown]      CB008033 Postcondition
#
#*** Keywords ***
#Case Precondition
#    log to console    Case Precondition
#    Common Test Setup For AIC
##    Adjust The Signal Via PA    10749_cell1=0
##    Verify Attenuation Value is updated    port    value
#
#5GC000704 Precondition
#    log to console    Case Precondition
#    Common Test Setup For AIC
#    Online Modify HO Meas Parametrs in vCU    a3_meas=none    a5_meas=rsrp
#
#5GC000704_Xn Precondition
#    log to console    Case Precondition
#    Common Test Setup For AIC
#    Online Modify HO Meas Parametrs in vCU    a3_meas=none    a5_meas=rsrp
#    Check Xn Link Status    expected_admin_state=unlocked      expected_link_status=available
#    Update X2 Links locking state    value=locked
#
#5GC000705 Precondition
#    log to console    Case Precondition
#    Common Test Setup For AIC
#    Modify Parameters By Delta Plan In vCU
#    ...    parameter=administrativeState    value=Locked    mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRADJGNB-1
#    Check Xn Link Status    expected_admin_state=locked      expected_link_status=unavailable
#    Update X2 Links locking state    value=locked
#
#5GC000706 Precondition
#    log to console    Case Precondition
#    Common Test Setup For AIC
#    Check Xn Link Status    expected_admin_state=unlocked      expected_link_status=available
##    Modify Parameters By Delta Plan In vCU And vDU    parameter=chBw    value=50MHz
#    Adjust The Signal Via PA    10749_cell3=0
#    Update X2 Links locking state    value=locked
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
#5GC001349 Postcondition
#    log to console    Case Postcondition
#    Run Keyword And Ignore Error    Detach UE    ue_index=0
#    Common Test Teardown For AIC
#    Set vDU Parametrs For 5GC001349   operation=recover
#
#5GC000705 Postcondition
#    log to console    Case Postcondition
#    Run Keyword And Ignore Error    Stop Wireshark In vCU
#    ...                                               hostname=${vcu_hostname_list[0]}
#    ...                                               username=${vcu_username_list[0]}
#    ...                                               password=${vcu_password_list[0]}
#    ...                                               namespace=${vcu_ns_list[0]}
#    Run Keyword And Ignore Error    Stop Wireshark In vCU
#    ...                                               hostname=${vcu_hostname_list[1]}
#    ...                                               username=${vcu_username_list[1]}
#    ...                                               password=${vcu_password_list[1]}
#    ...                                               namespace=${vcu_ns_list[1]}
#    Run Keyword And Ignore Error    Detach UE    ue_index=2
#    Run Keyword And Ignore Error    Adjust The Signal Via PA    10749_cell1=0
##    Common Test Teardown For AIC
#    Update X2 Links locking state    value=unlocked
#    Modify Parameters By Delta Plan In vCU
#    ...    parameter=administrativeState    value=Unlocked    mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRADJGNB-1
#    Check Xn Link Status    expected_admin_state=unlocked      expected_link_status=available
#
#5GC000705_interFreq Postcondition
#    log to console    Case Postcondition
#    Run Keyword And Ignore Error    Stop Wireshark In vCU
#    ...                                               hostname=${vcu_hostname_list[0]}
#    ...                                               username=${vcu_username_list[0]}
#    ...                                               password=${vcu_password_list[0]}
#    ...                                               namespace=${vcu_ns_list[0]}
#    Run Keyword And Ignore Error    Stop Wireshark In vCU
#    ...                                               hostname=${vcu_hostname_list[1]}
#    ...                                               username=${vcu_username_list[1]}
#    ...                                               password=${vcu_password_list[1]}
#    ...                                               namespace=${vcu_ns_list[1]}
#    Run Keyword And Ignore Error    Detach UE    ue_index=1
#    Run Keyword And Ignore Error    Adjust The Signal Via PA    10749_cell1=0
##    Common Test Teardown For AIC
#    Update X2 Links locking state    value=unlocked
#    Modify Parameters By Delta Plan In vCU
#    ...    parameter=administrativeState    value=Unlocked    mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRADJGNB-1
#    Check Xn Link Status    expected_admin_state=unlocked      expected_link_status=available
#
#5GC000704_Xn Postcondition
#    log to console    Case Postcondition
#    Run Keyword And Ignore Error    Stop Wireshark In vCU
#    ...                                               hostname=${vcu_hostname_list[0]}
#    ...                                               username=${vcu_username_list[0]}
#    ...                                               password=${vcu_password_list[0]}
#    ...                                               namespace=${vcu_ns_list[0]}
#    Run Keyword And Ignore Error    Stop Wireshark In vCU
#    ...                                               hostname=${vcu_hostname_list[1]}
#    ...                                               username=${vcu_username_list[1]}
#    ...                                               password=${vcu_password_list[1]}
#    ...                                               namespace=${vcu_ns_list[1]}
#    Run Keyword And Ignore Error    Detach UE    ue_index=${0}
#    Run Keyword And Ignore Error    Adjust The Signal Via PA    10749_cell1=0
##    Common Test Teardown For AIC
#    Online Modify HO Meas Parametrs in vCU    a3_meas=rsrp    a5_meas=none
#    Update X2 Links locking state    value=unlocked
#
#5GC000704 Postcondition
#    log to console    Case Postcondition
#    Run Keyword And Ignore Error    Detach UE    ue_index=${0}
#    Run Keyword And Ignore Error    Adjust The Signal Via PA    10749_cell1=0
##    Common Test Teardown For AIC
#    Online Modify HO Meas Parametrs in vCU    a3_meas=rsrp    a5_meas=none
#
#5GC000786 Postcondition
#    log to console    Case Postcondition
#    Run Keyword And Ignore Error    Detach UE    ue_index=${0}
#    Run Keyword And Ignore Error    Adjust The Signal Via PA    10749_cell1=0
##    Common Test Teardown For AIC
#
#Latency Postcondition
#    log to console    Case Postcondition
#    Run Keyword And Ignore Error    Stop Wireshark In vCU
#    ...                             hostname=${vdu_hostname_dict['vcu_0_vdu_hostname'][0]}
#    ...                             username=${vdu_username_dict['vcu_0_vdu_username'][0]}
#    ...                             password=${vdu_password_dict['vcu_0_vdu_password'][0]}
#    ...                             namespace=${vdu_ns_dict['vcu_0_vdu_ns'][0]}
#    ...                             pod_name=cprt
#    Run Keyword And Ignore Error    Stop Wireshark In vCU
#    ...                             hostname=${vdu_hostname_dict['vcu_1_vdu_hostname'][0]}
#    ...                             username=${vdu_username_dict['vcu_1_vdu_username'][0]}
#    ...                             password=${vdu_password_dict['vcu_1_vdu_password'][0]}
#    ...                             namespace=${vdu_ns_dict['vcu_1_vdu_ns'][0]}
#    ...                             pod_name=cprt
#    Run Keyword And Ignore Error    Stop Wireshark In vCU
#    ...                             hostname=${vcu_hostname_list[0]}
#    ...                             username=${vcu_username_list[0]}
#    ...                             password=${vcu_password_list[0]}
#    ...                             namespace=${vcu_ns_list[0]}
#    ...                             pod_name=cprt
#    Run Keyword And Ignore Error    Stop Wireshark In vCU
#    ...                             hostname=${vcu_hostname_list[1]}
#    ...                             username=${vcu_username_list[1]}
#    ...                             password=${vcu_password_list[1]}
#    ...                             namespace=${vcu_ns_list[1]}
#    Run Keyword And Ignore Error    Detach UE    ue_index=${0}
#    Run Keyword And Ignore Error    Adjust The Signal Via PA    10749_cell1=0
##    Common Test Teardown For AIC
#    Update X2 Links locking state    value=unlocked
#    Run Keyword And Ignore Error    Modify Parameters By Delta Plan In vCU
#    ...    parameter=administrativeState    value=Unlocked    mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRADJGNB-1
#    Check Xn Link Status    expected_admin_state=unlocked      expected_link_status=available
#
#CB008021 Postcondition
#    log to console    Case Postcondition
#    Run Keyword And Ignore Error    Detach UE    ue_index=${0}
#    Common Test Teardown For AIC
#
#5GC000746_CMAS Postcondition
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
#    Run Keyword And Ignore Error    Detach UE    ue_index=0
###    Common Test Teardown For AIC
#    Modify Parameters By Delta Plan In vCU    parameter=actCMAS    value=flase
#	...                                mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#
#5GC000746_CMAS_cancel Postcondition
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
#    Set Mobile Data    ue_index=0    state=on    connection=cygwin
#    Run Keyword And Ignore Error    Detach UE    ue_index=0
###    Common Test Teardown For AIC
#    Modify Parameters By Delta Plan In vCU    parameter=actCMAS    value=flase
#	...                                mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
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
#    Set Mobile Data    ue_index=0    state=on    connection=cygwin
#    Run Keyword And Ignore Error    Detach UE    ue_index=0
###    Common Test Teardown For AIC
#	Modify Parameters By Delta Plan In vCU    parameter=actETWS    value=flase
#	...                                mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#
#5GC000747_ETWS Postcondition
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
#    Run Keyword And Ignore Error    Detach UE    ue_index=0
###    Common Test Teardown For AIC
#	Modify Parameters By Delta Plan In vCU    parameter=actETWS    value=flase
#	...                                mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#
#CB008737_B Postcondition
#    log to console    Auto Sync Postcondition
#    Run Keyword And Ignore Error    basic.master_close    alias=${rannic_conn}
#    Modify Parameters By Delta Plan    ne=vDU    parameter=actSshToRanNic    value=false
#    ...                                mo_dn=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
#    Common Test Teardown For AIC
#
#CB008033 Postcondition
#    log to console    Case Postcondition
#    Run Keyword And Ignore Error    Detach UE    ue_index=2
#    Run Keyword And Ignore Error    Adjust The Signal Via PA    10749_cell1=10
##    Common Test Teardown For AIC
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
#Prepare Commercial UE
#    [Arguments]    ${ue_index}=${0}    ${ui_version}=MATE40PROUI1.0
#    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
#    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
#    Log to Console    \n***Prepare UE***
#    Prepare UE    ${ue_${ue_index}_type}    ue_index=${ue_index}    ui_version=${ui_version}
#    [Return]     ${ue_${ue_index}_type}
#
#Detach UE
#    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_${ue_index}_type}
#    UE Detach    ${ue_type}    ue_index=${ue_index}
#
#Start VONR Call For UE
#    [Arguments]    ${ue_index}=${0}    ${capabilities}=huawei1
##    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}    ${capabilities}=huawei1
#    Start VONR Call    ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    vc_alias=VC_1    call_number=004488
##    Start VONR Call    ue_type=${ue_type}    ue_index=${ue_index}    vc_alias=VC_1    call_number=004488
#    ...            duration=600s    capabilities=${capabilities}
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
#Stop L2rt Log And Check DL Tput
#    [Arguments]      ${gnb_index}=${0}    ${vdu_index}=${0}
#    Log to Console    \n***Check DL Tput***
#    ${dl_l2rt_tput_log}    Collect And Download K8s Log In vDU    gnb_index=${gnb_index}    vdu_index=${vdu_index}
#    ...                                      container_name=l2rt    pod_name=l2rt   timeout=${10}    duration=120s
#    Set Test Variable    ${dl_l2rt_tput_log}
#
#    Log to Console    \n***Check DL Tput In Cell NRCELL-2***
#    ${ave_dl_tput}    ${max_dl_tput}    ${min_dl_tput}    k8s.get_dl_tput_from_k8s_log
#    ...                                                          log_path=${dl_l2rt_tput_log}
#    ...                                                           cell_id=176111618
#    should be true  ${max_dl_tput}>10
#
##    ${cell_id_dict}    Get NR Cell Identity Dict    gnb_index=${gnb_index}    vdu_index=${vdu_index}
##    FOR    ${cell_name}     IN    @{cell_id_dict}
##        Log to Console    \n***Check DL Tput In Cell ${cell_name}***
##        ${ave_dl_tput}    ${max_dl_tput}    ${min_dl_tput}    k8s.get_dl_tput_from_k8s_log
##        ...                                                          log_path=${dl_l2rt_tput_log}
##        ...                                                           cell_id=${cell_id_dict['${cell_name}']}
###        should be true  ${max_dl_tput}>10
##    END
#
#Start Bip Log In vDU ID-CB009881-CG-14
#    Start Bip Log    gnb_index=${0}    vdu_index=${0}    container_name=l2hi    pod_name=l2nrt
#    ...              pod_prefix=po-cran1    container_prefix=ctr-cran1    port_name=l2biphi
#    ...              timeout=${10}
#
##Start L1hi Bip Log
##    Start Bip Log    gnb_index=${0}    vdu_index=${0}    container_name=l2rt    pod_name=l2nrt
##    ...              pod_prefix=po-cran1    container_prefix=ctr-cran1    port_name=l1up    timeout=${10}
#
#Check Counter for 5GC001349
#    Sleep    360s    reason=wait generate counter
#    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
#    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    &{type1_counter_dict}    create dictionary    counterId=M55306C00001,M55306C00002,M55306C00003,M55306C00004
#    ...                                           dimDN=${dim_dn}/NRCELL-1
#    ...                                           ne=vDU
#    ...                                           gnbIndex=0
#    ...                                           comparison=greater
#    ...                                           value=0
#    &{type2_counter_dict}    create dictionary    counterId=M55306C03001,M55306C06001
#    ...                                           dimDN=${dim_dn}/NRCELL-1
#    ...                                           ne=vDU
#    ...                                           gnbIndex=0
#    ...                                           comparison=greater
#    ...                                           value=0
#    ${type1_counter_list}    Create List    ${type1_counter_dict}
#    ${type2_counter_list}    Create List    ${type2_counter_dict}
#
#    FOR    ${counter}    IN    @{type1_counter_list}
#        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
#
#        Check any one value in multiple counters In vDU    counter_id_list=${counter_id_list}
#        ...                                                dim_dn=${counter['dimDN']}
#        ...                                                gnb_index=${counter['gnbIndex']}
#        ...                                                comparison=${counter['comparison']}
#        ...                                                expected_value=${counter['value']}
#        ...                                                get_number=3
#    END
#
#    FOR    ${counter}    IN    @{type2_counter_list}
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
#Check Counter for 5GC000705
#    Sleep    360s    reason=wait generate counter
#    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
#    ${MRBTS1_ID}    Set Variable   ${MRBTS_ID_list}[1]
#    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    ${dim_dn1}    Set Variable   MRBTS-${MRBTS1_ID}/NRBTS-${MRBTS1_ID}
#    &{type1_counter_dict}    create dictionary
#    ...                      counterId=M55124C06001,M55124C06002,M55125C07502,M55125C07512,M55125C07514,M55125C07523,M55125C07525
#    ...                      dimDN=${dim_dn}/NRCELL-1
#    ...                      ne=vCU
#    ...                      gnbIndex=0
#    ...                      comparison=greater
#    ...                      value=0
#    &{type2_counter_dict}    create dictionary
#    ...                      counterId=M55135C01001,M55135C01002,M55320C19001,M55320C19002,M55320C19003,M55320C19004
#    ...                      dimDN=${dim_dn}
#    ...                      ne=vCU
#    ...                      gnbIndex=0
#    ...                      comparison=greater
#    ...                      value=0
#    &{type3_counter_dict}    create dictionary
#    ...                      counterId=M55125C07503,M55125C07504,M55125C09524,M55125C09525
#    ...                      dimDN=${dim_dn1}/NRCELL-1
#    ...                      ne=vCU
#    ...                      gnbIndex=1
#    ...                      comparison=greater
#    ...                      value=0
#    ${counter_list}    Create List    ${type1_counter_dict}    ${type2_counter_dict}    ${type3_counter_dict}
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
#Check Counter for 5GC000704_Xn
#    Sleep    360s    reason=wait generate counter
#    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
#    ${MRBTS1_ID}    Set Variable   ${MRBTS_ID_list}[1]
#    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    ${dim_dn1}    Set Variable   MRBTS-${MRBTS1_ID}/NRBTS-${MRBTS1_ID}
#    &{type1_counter_dict}    create dictionary    counterId=M55128C01001,M55128C01002
#    ...                                           dimDN=${dim_dn}
#    ...                                           ne=vCU
#    ...                                           gnbIndex=0
#    ...                                           comparison=greater
#    ...                                           value=0
#    &{type2_counter_dict}    create dictionary    counterId=M55143C00001,M55143C00004,M55147C00002
#    ...                                           dimDN=${dim_dn}/NRCELL-1
#    ...                                           ne=vCU
#    ...                                           gnbIndex=0
#    ...                                           comparison=greater
#    ...                                           value=0
#    &{type3_counter_dict}    create dictionary    counterId=M55145C00341,M55145C00342
#    ...                                           dimDN=${dim_dn}/NRCELL-1/MCC-262/MNC-03
#    ...                                           ne=vCU
#    ...                                           gnbIndex=0
#    ...                                           comparison=greater
#    ...                                           value=0
#    &{type4_counter_dict}    create dictionary    counterId=M55143C00005,M55143C00006
#    ...                                           dimDN=${dim_dn1}/NRCELL-1
#    ...                                           ne=vCU
#    ...                                           gnbIndex=1
#    ...                                           comparison=greater
#    ...                                           value=0
#    &{type5_counter_dict}    create dictionary    counterId=M55145C00361,M55145C00362
#    ...                                           dimDN=${dim_dn1}/NRCELL-1/MCC-262/MNC-03
#    ...                                           ne=vCU
#    ...                                           gnbIndex=1
#    ...                                           comparison=greater
#    ...                                           value=0
#    ${counter_list}    Create List    ${type1_counter_dict}    ${type2_counter_dict}    ${type3_counter_dict}
#    ...                               ${type4_counter_dict}    ${type5_counter_dict}
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
#Check Counter for 5GC000704_intraDU
#    Sleep    360s    reason=wait generate counter
#    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
#    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    &{type1_counter_dict}    create dictionary    counterId=M55145C00301,M55145C00302
#    ...                                           dimDN=${dim_dn}/NRCELL-1/MCC-262/MNC-03
#    ...                                           ne=vCU
#    ...                                           gnbIndex=0
#    ...                                           comparison=greater
#    ...                                           value=0
#    &{type2_counter_dict}    create dictionary    counterId=M55147C00002
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
#Check Counter for 5GC000786_HO
#    Sleep    360s    reason=wait generate counter
#    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
#    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
##    &{type1_counter_dict}    create dictionary    counterId=M55142C00007,M55142C00008
##    ...                                           dimDN=${dim_dn}/NRCELL-1
##    ...                                           ne=vCU
##    ...                                           gnbIndex=0
##    ...                                           comparison=greater
##    ...                                           value=0
#    &{type1_counter_dict}    create dictionary    counterId=M55147C00001
#    ...                                           dimDN=${dim_dn}/NRCELL-1
#    ...                                           ne=vCU
#    ...                                           gnbIndex=0
#    ...                                           comparison=greater
#    ...                                           value=0
#    &{type2_counter_dict}    create dictionary    counterId=M55125C09524,M55125C09525
#    ...                                           dimDN=${dim_dn}/NRCELL-2
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
#    ...            ${gnb2_index}=${1}    ${index}=${0}    ${index1}=${0}
#    Run Keyword If    '${NE}'=='vCU'    Start Collect Wireshark Log In vCU
#    ...                                                           container_name=${container_name}
#    ...                                                           pod_name=${pod_name}
#    ...                                                           index=${gnb_index}
#    ...       ELSE IF    '${NE}'=='vDU'    Start Collect Wireshark Log In vDU
#    ...                                                           container_name=${container_name}
#    ...                                                           pod_name=${pod_name}
#    ...                                                           gnb_index=${gnb_index}
#    ...                                                           index=${index}
#    ...       ELSE IF    '${NE}'=='all'    Start Collect Wireshark Log Both vCU And vDU
#    ...                                                           container_name=${container_name}
#    ...                                                           vdu_pod_name=cprt
#    ...                                                           vcu_pod_name=cpif
#    ...                                                           gnb_index=${gnb_index}
#    ...                                                           index=${index}
#    ...                                                           index1=${index1}
#    ...       ELSE IF    '${NE}'=='Multi_vDU'    Start Collect Wireshark Log For Multi vDU
#    ...                                                           container_name=${container_name}
#    ...                                                           pod_name=${pod_name}
#    ...                                                           gnb_index=${gnb_index}
#    ...                                                           gnb2_index=${gnb2_index}
#    ...                                                           index=${index}
#    ...                                                           index1=${index1}
#    ...       ELSE IF    '${NE}'=='Multi_vCU'    Start Collect Wireshark Log For Multi vCU
#    ...                                                           container_name=${container_name}
#    ...                                                           pod_name=${pod_name}
#    ...                                                           gnb_index=${gnb_index}
#    ...                                                           gnb2_index=${gnb2_index}
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
#    ...            ${gnb_index}=${0}    ${index}=${0}    ${index1}=${0}
#    Log To Console    ${index}
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
#    [Arguments]    ${10749_cell1}=63    ${10749_cell2}=63    ${10749_cell3}=63    ${10766_cell1}=63
#    Log to console    Adjust The Signal Via PA
#    ${attenuation_channels}    Get Attenuation port    RU_id=0    du_id=0
#    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
#    &{channels_to_modify}    create dictionary    ${attenuation_channels[0]}=${10749_cell2}    ${attenuation_channels[1]}=${10749_cell2}
#    ...                                          ${attenuation_channels[2]}=${10749_cell1}    ${attenuation_channels[3]}=${10749_cell1}
#    ...                                          ${attenuation_channels[4]}=${10766_cell1}
#    ...                                          ${attenuation_channels[5]}=${10749_cell3}    ${attenuation_channels[6]}=${10749_cell3}
#    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
#    sleep    3s    reason=wait signal stable
#    Log to console    attenuation change complete
#
#Check Attenuation Value
#    Log to console    Adjust The Signal Via PA
#    ${attenuation_channels}    Get Attenuation port    RU_id=0    du_id=0
#    Verify Attenuation Value is updated
#
#Trigger intra Fre inter gnb based Handover
#    [Arguments]    ${vendor}=HBTE    ${source_cell}=43    ${target_cell}=0    ${adjust_step}=3
#    Log to console    \n***Start to Trigger intra Fre inter gnb based Handover***
#    ${attenuation_channels}    Get Attenuation port    RU_id=0    du_id=0
#    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=${vendor}    du_id=0
#
#
#    FOR    ${index}    IN RANGE    13    ${source_cell}    ${adjust_step}
#        #    10749 cell1 source cell channels
#        &{source_cell_channels}    create dictionary    ${attenuation_channels[2]}=${index}
#        ...                                             ${attenuation_channels[3]}=${index}
#
#        Modify Attenuation Value    ${source_cell_channels}    RU_id=0    du_id=0
#        sleep    1s    reason=wait signal stable
#
#        #    10766 cell1 target cell channels
#        ${target_cell_index}    Evaluate    ${source_cell}-${index}
#        exit for loop if    ${target_cell_index}<${target_cell}
#        &{target_cell_channels}    create dictionary    ${attenuation_channels[4]}=${target_cell_index}
#        Modify Attenuation Value    ${target_cell_channels}    RU_id=0    du_id=0
#        sleep    1s    reason=wait signal stable
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
#        #    10749 cell1 source cell channels
#        &{source_cell_channels}    create dictionary    ${attenuation_channels[2]}=${index}
#        ...                                             ${attenuation_channels[3]}=${index}
#
#        Modify Attenuation Value    ${source_cell_channels}    RU_id=0    du_id=0
#        sleep    1s    reason=wait signal stable
#
#        #    10749 cell2 target cell channels
#        ${target_cell_index}    Evaluate    ${source_cell}-${index}
#        exit for loop if    ${target_cell_index}<${target_cell}
#        &{target_cell_channels}    create dictionary    ${attenuation_channels[0]}=${target_cell_index}
#        ...                                             ${attenuation_channels[1]}=${target_cell_index}
#        Modify Attenuation Value    ${target_cell_channels}    RU_id=0    du_id=0
#        sleep    1s    reason=wait signal stable
#    END
#
#    Log to console    Stop to Trigger intra Fre intra gnb based Handover
#
#Trigger inter Fre inter gnb based Handover
#    [Arguments]    ${vendor}=HBTE    ${source_cell}=43    ${target_cell}=0    ${adjust_step}=3
#    Log to console    \n***Start to Trigger inter Fre inter gnb based Handover***
#    ${attenuation_channels}    Get Attenuation port    RU_id=0    du_id=0
#    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=${vendor}    du_id=0
#
#    FOR    ${index}    IN RANGE    13    ${source_cell}    ${adjust_step}
#        #    10749 cell3 source cell channels
#        &{source_cell_channels}    create dictionary    ${attenuation_channels[5]}=${index}
#        ...                                             ${attenuation_channels[6]}=${index}
#
#        Modify Attenuation Value    ${source_cell_channels}    RU_id=0    du_id=0
#        sleep    1s    reason=wait signal stable
#
#        #    10766 cell1 target cell channels
#        ${target_cell_index}    Evaluate    ${source_cell}-${index}
#        exit for loop if    ${target_cell_index}<${target_cell}
#        &{target_cell_channels}    create dictionary    ${attenuation_channels[4]}=${target_cell_index}
#        Modify Attenuation Value    ${target_cell_channels}    RU_id=0    du_id=0
#        sleep    1s    reason=wait signal stable
#    END
#
#    Log to console    \n***Stop to Trigger inter Fre inter gnb based Handover***
#
#Trigger inter Fre intra gnb based Handover
#    [Arguments]    ${vendor}=HBTE    ${source_cell}=43    ${target_cell}=0    ${adjust_step}=3
#    Log to console    \n***Start to Trigger inter Fre inter gnb based Handover***
#    ${attenuation_channels}    Get Attenuation port    RU_id=0    du_id=0
#    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=${vendor}    du_id=0
#
#    FOR    ${index}    IN RANGE    13    ${source_cell}    ${adjust_step}
#        #    10749 cell1 source cell channels
#        &{source_cell_channels}    create dictionary    ${attenuation_channels[2]}=${index}
#        ...                                             ${attenuation_channels[3]}=${index}
#
#        Modify Attenuation Value    ${source_cell_channels}    RU_id=0    du_id=0
#        sleep    1s    reason=wait signal stable
#
#        #    10749 cell3 target cell channels
#        ${target_cell_index}    Evaluate    ${source_cell}-${index}
#        exit for loop if    ${target_cell_index}<${target_cell}
#        &{target_cell_channels}    create dictionary    ${attenuation_channels[5]}=${target_cell_index}
#        ...                                             ${attenuation_channels[6]}=${target_cell_index}
#        Modify Attenuation Value    ${target_cell_channels}    RU_id=0    du_id=0
#        sleep    1s    reason=wait signal stable
#    END
#
#    Log to console    \n***Stop to Trigger inter Fre inter gnb based Handover***
#
#Stop Wireshark Log
#    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cpif    ${NE}=vDU    ${gnb_index}=${0}
#    ...            ${gnb2_index}=${0}    ${index}=${0}    ${index1}=${1}
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
#    ...                                                           gnb2_index=${gnb2_index}
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
#    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cpif    ${gnb_index}=${0}    ${gnb2_index}=${0}
#    ...            ${index}=${0}    ${index1}=${0}
#    Log To Console    ${gnb2_index}
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
#Get Latency And Interruption In Wireshark
#    [Arguments]      ${target_log_path}=${target_vCU}
#    ...              ${source_log_path}=${source_vCU}
#    &{lantency_dict}    Create Dictionary
#
#    Log to Console    \n***Calculate Total Delay***
#    ${first_time}    ${second_time}     Calculate Latency Based On Wireshark Log    local_file_path1=${target_log_path}
#    ...                 local_file_path2=${target_log_path}
#    ...                 first_filter=ngap.HandoverRequest_element
#    ...                 second_filter=ngap.HandoverNotify_element
#    ${total_delay}    Evaluate   ${second_time[0]}-${first_time[0]}
#
#    Log to Console    \n***Calculate Transport Delay***
#    ${first_time}    ${second_time}    Calculate Latency Based On Wireshark Log    local_file_path1=${target_log_path}
#    ...                 local_file_path2=${source_log_path}
#    ...                 first_filter=ngap.HandoverRequestAcknowledge_element
#    ...                 second_filter=ngap.HandoverCommand_element
#    ${transport_delay}    Evaluate   ${second_time[0]}-${first_time[0]}
#
##    Core network processing estimated value
#    ${cn_delay}    set variable    0.002
#    Log to Console    \n***Calculate Latency***
#    ${latency_delay}    Evaluate   ${total_delay}-${transport_delay}+${cn_delay}
#
#    Log to Console    \n***Calculate Interruption***
#    ${first_time}    ${second_time}     Calculate Latency Based On Wireshark Log     local_file_path1=${target_log_path}
#    ...                 local_file_path2=${target_log_path}
#    ...                 first_filter=ngap.HandoverRequestAcknowledge_element
#    ...                 second_filter=ngap.HandoverNotify_element
#    ${sub_time1}    Evaluate   ${second_time[-1]}-${first_time[-1]}
#
#    ${first_time}    ${second_time}     Calculate Latency Based On Wireshark Log     local_file_path1=${source_log_path}
#    ...                 local_file_path2=${source_log_path}
#    ...                 first_filter=ngap.HandoverCommand_element
#    ...                 second_filter=e1ap.BearerContextModificationRequest_element
#    ${sub_time2}    Evaluate   ${second_time[-1]}-${first_time[-1]}
#
#    ${interruption_delay}    Evaluate   ${sub_time1}-${sub_time2}
#    ${DL_data_start_latency}    set variable    0.0028
#    ${UL_data_start_latency}    set variable    0.0032
#    ${dl_data_int}    Evaluate   ${interruption_delay}+${DL_data_start_latency}-${transport_delay}
#    ${ul_data_int}    Evaluate   ${interruption_delay}+${UL_data_start_latency}-${transport_delay}
#
#    Set To Dictionary    ${lantency_dict}    latency_delay=${latency_delay}
#    ...                                      dl_data_int=${dl_data_int}
#    ...                                      ul_data_int=${ul_data_int}
#    [return]    ${lantency_dict}
#
#Calculate Latency Based On Wireshark Log
#    [Arguments]    ${local_file_path1}=/home/ute/vcu_10749.pcap
#    ...            ${local_file_path2}=/home/ute/vcu_10749.pcap
#    ...            ${first_filter}=ngap.id == 29&&ngap.handoverRequiredTransfer == 00
#    ...            ${second_filter}=ngap.id == 29&&ngap.handoverCommandTransfer == 00
#	${first_time}=    Run
#    ...    tshark -Y "${first_filter}" -T fields -e frame.time_epoch -r ${local_file_path1}
#    ${second_time}=    Run
#    ...    tshark -Y "${second_filter}" -T fields -e frame.time_epoch -r ${local_file_path2}
#    ${first_time}=   Get Regexp Matches    ${first_time}   \\d{10}.\\d{9}
#    ${second_time}=   Get Regexp Matches    ${second_time}   \\d{10}.\\d{9}
#    [return]    ${first_time}    ${second_time}
#
#Check Average Lantency
#    [Arguments]    ${latency_list}=None
#    ${list_length}    get length    ${latency_list}
#    ${sum_lantency}    set variable  0
#    ${sum_dl}    set variable  0
#    ${sum_ul}    set variable  0
#    FOR    ${latency_dict}    IN    @{latency_list}
#        ${sum_lantency}    Evaluate    ${sum_lantency} + ${latency_dict['latency_delay']}
#        ${sum_dl}    Evaluate    ${sum_dl} + ${latency_dict['dl_data_int']}
#        ${sum_ul}    Evaluate    ${sum_ul} + ${latency_dict['ul_data_int']}
#    END
#    ${ava_lantency}    Evaluate    ${sum_lantency}/${list_length}
#    ${ava_dl}    Evaluate    ${sum_dl}/${list_length}
#    ${ava_ul}    Evaluate    ${sum_ul}/${list_length}
#
##    Latency <= 116.5ms
#    Should Be True    ${ava_lantency} <= 0.1165
##    DL data interruption <= 97.9ms
#    Should Be True    ${ava_dl} <= 0.0979
##    UL data interruption <= 98ms
#    Should Be True    ${ava_ul} <= 0.098
#
#Stop Cpue Log
#    sleep    30s    reason=wait cpue log generate
#    Log to Console    \n***Collect And Download Cpue Log In vCU***
#    ${cpue_log}    Collect And Download K8s Log In vCU    gnb_index=${0}    vdu_index=${0}    container_name=cpue
#    ...                                                          pod_name=cpue    timeout=${10}    duration=120s
#    Set Test Variable    ${cpue_log}
#
#Check HO status in Cpue Log
#    Log to Console    \n***Check Error In Cpue log***
#    ${ho_errors}    Get HO Error In Cpue log    log_path=${cpue_log}
##    Should Be Empty    ${ho_errors}
#    Run Keyword And Ignore Error    Should Be Empty    ${ho_errors}
#
#Get HO Error In Cpue log
#    [Arguments]      ${log_path}
#    Log to Console    \n***Check HO Error in Cpue log***
#    ${errors_checklist}    create list    no security result received
#    ...                                ProtocolError
#    ...                                Handover Preparation Failure
#    ...                                SaRadioLinkFailureService
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
#    ...                           plan_id=${PLAN_ID}    mo_dn=${mo_dn_cell}
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
#    ...            ${plan_id}=None    ${mo_dn}=MRBTS-10749/NRBTS-10749/NRCELL-1
#    ...            ${vdu_index}=0    ${gnb_index}=0
#    Log to Console    \n***Set framestru paras In vDU***
#    ${frame_para_name} =    Set Variable     tddFrameStructure/0/frameStructureType
#    ${manda_paras}   ${option_paras} =    Get Framestru Paras Dicts    frame_stru=${frame_stru}    frame_shift=${frame_shift}
#
#    vDU Login By Rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}
#    ${current_frame_value}=    Online Get VDU Parameter Value     ${mo_dn}    ${frame_para_name}
#
#    Update Staged Plan Parameter    plan_id=${plan_id}    mo_dn=${mo_dn}
#        ...                                       updated_paras_dict=${manda_paras}
#        ...                                       operation=replace
#
#    Log to Console    \n***Change the frameStructureType from ${current_frame_value} to ${frame_stru}!***
#    Run Keyword If    '${current_frame_value}' == 'semiStatic' and '${frame_stru}' == 'semiStatic'
##    semiStatic to semiStatic
#        ...       Log to Console    \n***the ${frame_stru} does not have option paras!***
#    ...    ELSE IF    '${current_frame_value}' == 'semiStatic' and '${frame_stru}' == 'tdLte'
##    semiStatic to tdLte
#        ...       Update Staged Plan Parameter    plan_id=${plan_id}    mo_dn=${mo_dn}
#        ...                                       updated_paras_dict=${option_paras}
#        ...                                       operation=add
#    ...    ELSE IF    '${current_frame_value}' == 'tdLte' and '${frame_stru}' == 'tdLte'
##    tdLte to tdLte
#        ...       Update Staged Plan Parameter    plan_id=${plan_id}    mo_dn=${mo_dn}
#        ...                                       updated_paras_dict=${option_paras}
#        ...                                       operation=replace
#    ...    ELSE IF    '${current_frame_value}' == 'tdLte' and '${frame_stru}' == 'semiStatic'
##    tdLte to semiStatic
#        ...       Update Staged Plan Parameter    plan_id=${plan_id}    mo_dn=${mo_dn}
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
#Check Any One Value In Multiple Counters
#    Sleep    360s    reason=wait generate counter
#    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
#    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#
#    ${avg_ul_rip_counter}    Generate Counter PIId    start_id=M55360C00000    stop_id=M55360C00272
#    ${max_ul_rip_counter}    Generate Counter PIId    start_id=M55360C01000    stop_id=M55360C01272
#
#    &{type1_counter_dict}    create dictionary    counterId=${avg_ul_rip_counter}
#    ...                                           dimDN=${dim_dn}/NRCELL-1
#    ...                                           ne=vDU
#    ...                                           gnbIndex=0
#    ...                                           comparison=less
#    ...                                           value=0
#    &{type2_counter_dict}    create dictionary    counterId=${max_ul_rip_counter}
#    ...                                           dimDN=${dim_dn}/NRCELL-1
#    ...                                           ne=vDU
#    ...                                           gnbIndex=0
#    ...                                           comparison=less
#    ...                                           value=0
#    ${counter_list}    Create List    ${type1_counter_dict}    ${type2_counter_dict}
#    FOR    ${counter}    IN    @{counter_list}
#        ${ne}    Set Variable   ${counter['ne']}
#        Run Keyword If    '${ne}'=='vDU'     Check Any One Value In Multiple Counters In vDU
#        ...                                                         counter_id_list=${counter['counterId']}
#        ...                                                         dim_dn=${counter['dimDN']}
#        ...                                                         gnb_index=${counter['gnbIndex']}
#        ...                                                         comparison=${counter['comparison']}
#        ...                                                         expected_value=${counter['value']}
#        ...                                                         get_number=3
#        ...    ELSE IF    '${ne}'=='vCU'    Check Any One Value In Multiple Counters In vCU
#        ...                                                         counter_id_list=${counter['counterId']}
#        ...                                                         dim_dn=${counter['dimDN']}
#        ...                                                         gnb_index=${counter['gnbIndex']}
#        ...                                                         comparison=${counter['comparison']}
#        ...                                                         expected_value=${counter['value']}
#        ...                                                         get_number=3
#    END
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
#Check Any One Value In Multiple Counters In vCU
#    [Arguments]    ${counter_id_list}    ${dim_dn}    ${gnb_index}=0
#    ...            ${comparison}=greater    ${expected_value}=0    ${get_number}=3
#    Log to Console    \n***check any one value in multiple counters in vCU***
#    ${status}=   set variable   False
#    ${counter_values_final_list}    Create List
#    FOR    ${counter_id}    IN    @{counter_id_list}
#        @{words}=    split string    ${counter_id}   C
#        ${mea_id}=   Fetch From Right    ${words[0]}  M
#        ${counter_values_final_list}    Run Keyword And Ignore Error    Check Counter For vCU
#        ...                                            counter_id=${counter_id}
#        ...                                            measurement_id=${mea_id}
#        ...                                            dimension_dist_name=${dim_dn}
#        ...                                            comparison=${comparison}
#        ...                                            expected_value=${expected_value}
#        ...                                            get_number=${get_number}
#        ...                                            gnb_index=${gnb_index}
#        ${status}=    set variable if    '${counter_values_final_list[0]}'=='PASS'    True
#        exit for loop if    '${status}'=='True'
#    END
#    should be equal    ${status}    True    Check counter value failed!
#
#Trigger CMAS Notification
#    Log to console    start to trigger cmas
#    CMAS Notification    amf=${amf1-amf1-zheng}
#    ...                          message_identifier=4372    serial_number=51
#    ...                          repetition_period=5
#    ...                          number_of_broadcasts_requested=${10}
#    ...                          connection=${cbctest_alias}
#	...                          nr_of_bits_g_node_b_id=22
#    ...                          cell_id=176111617
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
#    ...                          cell_id=176111617
#    ...                          test_amf_name=test_etws6_RRM3.py
#    Log to console    stop to trigger cmas
#
#Trigger CMAS Notification For SIB7
#    Log to console    start to trigger cmas
#    CMAS Notification    amf=${amf1-amf1-zheng}
#    ...                          message_identifier=50    serial_number=51
#    ...                          repetition_period=5
#    ...                          number_of_broadcasts_requested=${10}
#    ...                          connection=${cbctest_alias}
#	...                          nr_of_bits_g_node_b_id=22
#    ...                          cell_id=176111617
#    ...                          test_amf_name=test_etws7_RRM3.py
#    Log to console    stop to trigger cmas
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
#Check PWS Cancel
#    [Arguments]    ${input_file}=${wireshark_local_file_path_vCU}
#    Log to Console    \n***Check if AMF sends PWSCancelRequest to gNB-CU-CP
#    ${PWSCancelRequest_filter} =    Catenate    ngap.PWSCancelRequest_element
#    ${result} =    Analysis Wireshark Log    input_file=${input_file}
#	...                                      filter_expression=${PWSCancelRequest_filter}
#	should contain    ${result}    PWSCancelRequest
#
#    Log to Console    \n***Check if gNB-CU-CP sends PWSCancelRequest to gNB-DU to cancel all CMAS broadcasting
#    ${PWSCancelRequest_filter} =    Catenate    f1ap.PWSCancelRequest_element
#    ${result} =    Analysis Wireshark Log    input_file=${input_file}
#	...                                      filter_expression=${PWSCancelRequest_filter}
#	should contain    ${result}    PWSCancelRequest
#
#    Log to Console    \n***Check if gNB-DU sends PWSCancelResponse to gNB-CU-CP
#    ${PWSCancelResponse_filter} =    Catenate    f1ap.PWSCancelResponse_element
#    ${result} =    Analysis Wireshark Log    input_file=${input_file}
#	...                                      filter_expression=${PWSCancelResponse_filter}
#	should contain    ${result}    PWSCancelResponse
#
#    Log to Console    \n***Check if gNB-CU-CP sends PWSCancelResponse with Broadcast Cancelled Area List IE to AMF
#    ${PWSCancelResponse_filter} =    Catenate    ngap.PWSCancelResponse_element
#    ${result} =    Analysis Wireshark Log    input_file=${input_file}
#	...                                      filter_expression=${PWSCancelResponse_filter}
#	should contain    ${result}    PWSCancelResponse
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
#Check Counter For PWS_Cancel
#    Sleep    360s    reason=wait generate counter
#    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
#    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    Log to Console    \n***Check M55119C02004(NNGCB_PWS_CAN_REQ_RECD), M55119C02005(NNGCB_PWS_CAN_RESP_SENT) counters
#    &{type1_counter_dict}    create dictionary    counterId=M55119C02004,M55119C02005
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
#Check Counter for 5GC000706
#    Sleep    360s    reason=wait generate counter
#    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
#    ${MRBTS1_ID}    Set Variable   ${MRBTS_ID_list}[1]
#    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    ${dim_dn1}    Set Variable   MRBTS-${MRBTS1_ID}/NRBTS-${MRBTS1_ID}
#    &{type1_counter_dict}    create dictionary    counterId=M55147C00024,M55143C00001,M55143C00004
#    ...                                           dimDN=${dim_dn}/NRCELL-3
#    ...                                           ne=vCU
#    ...                                           gnbIndex=0
#    ...                                           comparison=greater
#    ...                                           value=0
#    &{type2_counter_dict}    create dictionary    counterId=M55143C00005,M55143C00006
#    ...                                           dimDN=${dim_dn1}/NRCELL-1
#    ...                                           ne=vCU
#    ...                                           gnbIndex=1
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
#5GC000706 Postcondition
#    log to console    Case Postcondition
#    Run Keyword And Ignore Error    Stop Wireshark In vCU
#    ...                                               hostname=${vcu_hostname_list[0]}
#    ...                                               username=${vcu_username_list[0]}
#    ...                                               password=${vcu_password_list[0]}
#    ...                                               namespace=${vcu_ns_list[0]}
#    Run Keyword And Ignore Error    Stop Wireshark In vCU
#    ...                                               hostname=${vcu_hostname_list[1]}
#    ...                                               username=${vcu_username_list[1]}
#    ...                                               password=${vcu_password_list[1]}
#    ...                                               namespace=${vcu_ns_list[1]}
#    Run Keyword And Ignore Error    Detach UE    ue_index=${0}
#    Run Keyword And Ignore Error    Adjust The Signal Via PA    10749_cell1=0
#    Update X2 Links locking state    value=unlocked
##    Modify Parameters By Delta Plan In vCU And vDU    parameter=chBw    value=100MHz
###    Common Test Teardown For AIC
#
#Check Counter for 5GC000705_interFreq
#    Sleep    360s    reason=wait generate counter
#    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
#    ${MRBTS1_ID}    Set Variable   ${MRBTS_ID_list}[1]
#    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    ${dim_dn1}    Set Variable   MRBTS-${MRBTS1_ID}/NRBTS-${MRBTS1_ID}
#    &{type1_counter_dict}    create dictionary
#    ...                      counterId=M55147C00024,M55124C06001,M55124C06002,M55125C07501,M55125C07512,M55125C07513,M55125C07522,M55125C07525
#    ...                      dimDN=${dim_dn}/NRCELL-3
#    ...                      ne=vCU
#    ...                      gnbIndex=0
#    ...                      comparison=greater
#    ...                      value=0
#    &{type2_counter_dict}    create dictionary
#    ...                      counterId=M55135C01001,M55135C01002,M55320C19001,M55320C19002,M55320C19003,M55320C19004
#    ...                      dimDN=${dim_dn}
#    ...                      ne=vCU
#    ...                      gnbIndex=0
#    ...                      comparison=greater
#    ...                      value=0
#    &{type3_counter_dict}    create dictionary
#    ...                      counterId=M55125C07503,M55125C07504,M55125C09524,M55125C09525
#    ...                      dimDN=${dim_dn1}/NRCELL-1
#    ...                      ne=vCU
#    ...                      gnbIndex=1
#    ...                      comparison=greater
#    ...                      value=0
#    ${counter_list}    Create List    ${type1_counter_dict}    ${type2_counter_dict}    ${type3_counter_dict}
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
#Check Any One Value In Multiple Counters for 5GC000503
#    Sleep    360s    reason=wait generate counter
#    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
#    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#
#    ${DL_PDCP_NUM_counter}    Generate Counter PIId    start_id=M55314C02001    stop_id=M55314C02020
#    ${DL_PDCP_VOL_counter}    Generate Counter PIId    start_id=M55314C03001    stop_id=M55314C03020
#    ${UL_PDCP_NUM_counter}    Generate Counter PIId    start_id=M55314C04001    stop_id=M55314C04020
#    ${UL_PDCP_VOL_counter}    Generate Counter PIId    start_id=M55314C05001    stop_id=M55314C05020
#    ${MAX_DL_PDCP_counter}    Generate Counter PIId    start_id=M55314C14001    stop_id=M55314C14020
#    ${MAX_UL_PDCP_counter}    Generate Counter PIId    start_id=M55314C16001    stop_id=M55314C16020
#
#    &{type1_counter_dict}    create dictionary    counterId=${DL_PDCP_NUM_counter}
#    ...                                           dimDN=${dim_dn}/NRDU-1
#    ...                                           ne=vDU
#    ...                                           gnbIndex=0
#    ...                                           comparison=greater
#    ...                                           value=0
#    &{type2_counter_dict}    create dictionary    counterId=${DL_PDCP_VOL_counter}
#    ...                                           dimDN=${dim_dn}/NRDU-1
#    ...                                           ne=vDU
#    ...                                           gnbIndex=0
#    ...                                           comparison=greater
#    ...                                           value=0
#    &{type3_counter_dict}    create dictionary    counterId=${UL_PDCP_NUM_counter}
#    ...                                           dimDN=${dim_dn}/NRDU-1
#    ...                                           ne=vDU
#    ...                                           gnbIndex=0
#    ...                                           comparison=greater
#    ...                                           value=0
#    &{type4_counter_dict}    create dictionary    counterId=${UL_PDCP_VOL_counter}
#    ...                                           dimDN=${dim_dn}/NRDU-1
#    ...                                           ne=vDU
#    ...                                           gnbIndex=0
#    ...                                           comparison=greater
#    ...                                           value=0
#    &{type6_counter_dict}    create dictionary    counterId=${MAX_DL_PDCP_counter}
#    ...                                           dimDN=${dim_dn}/NRDU-1
#    ...                                           ne=vDU
#    ...                                           gnbIndex=0
#    ...                                           comparison=greater
#    ...                                           value=0
#
#    ${counter_list}    Create List    ${type1_counter_dict}    ${type2_counter_dict}     ${type3_counter_dict}
#    ...    ${type4_counter_dict}    ${type6_counter_dict}
#    FOR    ${counter}    IN    @{counter_list}
#        ${ne}    Set Variable   ${counter['ne']}
#        Run Keyword If    '${ne}'=='vDU'     Check Any One Value In Multiple Counters In vDU
#        ...                                                         counter_id_list=${counter['counterId']}
#        ...                                                         dim_dn=${counter['dimDN']}
#        ...                                                         gnb_index=${counter['gnbIndex']}
#        ...                                                         comparison=${counter['comparison']}
#        ...                                                         expected_value=${counter['value']}
#        ...                                                         get_number=3
#        ...    ELSE IF    '${ne}'=='vCU'    Check Any One Value In Multiple Counters In vCU
#        ...                                                         counter_id_list=${counter['counterId']}
#        ...                                                         dim_dn=${counter['dimDN']}
#        ...                                                         gnb_index=${counter['gnbIndex']}
#        ...                                                         comparison=${counter['comparison']}
#        ...                                                         expected_value=${counter['value']}
#        ...                                                         get_number=3
#    END
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
#Check Account Ssh Sync in Log
#    [Arguments]    ${log_path}
#    Log to Console    \n***Check Account Ssh Sync in ${log_path} Log***
#    ${ssh_sync_filter}    Set Variable    syscomSshSyncMsgHandler
#    ${output}    OperatingSystem.Run    command=cat ${log_path} | grep -a "${ssh_sync_filter}"
#    should contain    ${output}    receive account ssh sync request
#    should contain    ${output}    finished ssh sync handler
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
#Stop Trace Log By Dcap
#    [Arguments]    ${ne_type}=vdu    ${gnb_index}=0    ${vdu_index}=0
#    Log To Console    ${gnb_index}
#    Log To Console    ${vdu_index}
#    ${webem_info}    Get WebEM Info    ne_type=${ne_type}   gnb_index=0    vdu_index=0
#    Stop Trace In DCAP    btsip=${webem_info['host']}
#
#Save Trace Log By Dcap
#    [Arguments]    ${ne_type}=vdu    ${gnb_index}=0    ${vdu_index}=0
#    Log To Console    ${gnb_index}
#    Log To Console    ${vdu_index}
#    ${webem_info}    Get WebEM Info    ne_type=${ne_type}   gnb_index=0    vdu_index=0
#    #    Download trace file is option when your case passed
#    ${trace_file_path}    Download Trace File    btsip=${webem_info['host']}
##    @{zip_file_path}    List Files In Directory    ${trace_file_path}    *.zip
#    [Return]    ${trace_file_path}
##    [Return]    ${trace_file_path}/@{zip_file_path}[0]
#
#Check Counter for CB008033_intra-gNB_Intra-DU_for_SA_VoNR
#    Log to Console    \n*******Wait and check counters
#    Sleep    360s    reason=wait generate counter
#    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
#    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#    &{type1_counter_dict}    create dictionary    counterId=M55153C00001,M55153C00002
#    ...                                           dimDN=${dim_dn}/NRCELL-1/NRCI-176111619/MCC-262/MNC-03
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
