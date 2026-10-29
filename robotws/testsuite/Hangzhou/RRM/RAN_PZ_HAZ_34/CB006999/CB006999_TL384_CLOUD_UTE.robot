*** Settings ***
Documentation
...    author: yuegong
...    contact: yue.1.gong@nokia-sbell.com
...    squad group: SG_03
...    feature : TL384_CLOUD_UTE

Force Tags    CA_5G_RRM    CRT_TRUNK    RAN_5G    RAN_5G_TDD
...    PY36
...    CRT_UTE    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABIOB1_2xAWHHF_ENB    SBTS00

Suite Setup    Run Keywords
...    robot_common_operations.Common Suite Setup    AND
...    CI_interface.Common Suite Setup    AND
...    Run Keyword And Ignore Error    Common Suite Setup for COAM


Suite Teardown    Run Keywords
...               robot_common_operations.Common Suite Teardown
...    AND        Run Keyword And Ignore Error    Common Suite Teardown for COAM
...    AND        Run Keyword And Ignore Error    COAM Teardown gnb connections


Resource    Resources/CB006999_cloud_common_keywords.robot

*** Variables ***
#${gNB1_6999_A03}          gNB_6999_active.pcap
${gNB1_6999_A05}          gNB_6999_A05_active.pcap
${gNB1_6999_B02}          gNB_6999_B02_active.pcap
${gNB1_1707}          gNB_1707_1.pcap
${gNB1_738_B3}          gNB_738_B3.pcap
${dl_expect}    70
${ul_expect}    5
${dl_throughput}    300M
${ul_throughput}    40M
@{gumistatus}         available    unavailable
${target_APN}    wap2
${source_APN}    wap1
${duration}    800
#[738]
${s1log_B01}    738_B01_S1.pcap
${E1log_B01}    738_B01_E1.pcap
${dl_20M}    260M
${ul_20M}    10M
${dl_e}    250
${ul_e}    8
@{value_counter_B01}    ${0}     ${0}
${enb_instance}     ${tl.enbs[0].instance_id}
${gnb_instance}     ${tl.gnbs[0].instance_id}
${enb1_gnb1_x2_dist}    MRBTS-${gnb_instance}/LNBTS-${enb_instance}/LNADJGNB-0
${eNB_X2_ON_OFF}    administrativeState
${enb1_def_gnb_dist}     MRBTS-${gnb_instance}/LNBTS-${enb_instance}/LNCEL-1
${enb_def_cell_para}     defaultLnRelGnbCellId
#@{gnb_ips}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
#${epc_log_path}    /home/ute/test_results/
${TS_LOG_PATH_BASE}    /home/ute/test_results/
${log_path_ute}    /home/ute/test_results/
${at_com_38411}    5

*** Test Cases ***
[1]CB006999_A_005_handover_after_gnb_receive_ASI_with_actAmfPlannedRemoval_ true _with_amfPlannedRemovalTimer_not_equal_0
    [Documentation]    Purpose of this case is to validate when feature flag is activated,
    ...    NRBTS/amfPlannedRemovalTimer > 0 indicating that the GUAMIs need to be retired till timer expired.
    ...    ZYY:20250124 check with previous owner in TL384 Handover teams chat CB006999_A_005 and CB006999_B_002 are WR KPI case.
    [Tags]    classical    CB006999-A_005    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4
    [Timeout]    1 hour
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107,4681
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Adjust the TL Topyoung attenuation value    gnb1_cell1_value=${10}
    Online modify parmeters    parameters_to_update=${gnb1_Lock_AMF1_Unlock_AMF2_A005}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
    Start capture gNB log on master    filename=${gNB1_6999_A05}   gNB_index=${0}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
    sleep    10s
    start DL UL    ue_index=${1}
    sleep    55s
    Online modify parmeters    parameters_to_update=${gnb1_Unlock_AMF3}
    Check DLUL tput    gnb_index=${0}
#    make amf-zhou maitain on amf account and alarm 7115 will be raised    status=@{gumistatus}[1]
#    Android UE SwitchApn    ue_index=${1}    apn_name=${target_APN}    ui_version=one ui 3.1
    sleep    10s
    Check DLUL tput    gnb_index=${0}
    Stop UL DL data transfer    ue_index=${1}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
    Stop and download the Logs    filename=${gNB1_6999_A05}   gNB_index=${0}
    [Teardown]    Run Keywords
#    ...    Run Keyword And Ignore Error    Android UE SwitchApn    ue_index=${1}    apn_name=${source_APN}    ui_version=one ui 3.1
    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}    AND
    ...    run keyword and ignore error    Stop and download the Logs    filename=${gNB1_6999_A05}   gNB_index=${0}    AND
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Test recover

[1]CB006999_B_002_gnb_receive_UE_TNLA_BINDING_RELEASE_REQUEST_without _backupAMFname_in_ASI_with_actAmfPlannedRemoval _true
    [Documentation]    AMF STATUS INDICATION has been received and processing is ongoing, with all GUAMIs using
    ...    the Timer approach.  amfPlannedRemovalTimer duration has still not expired for the specific AMF/GUAMI
    ...    associated with the UE Context.  UE TNLA BINDING RELEASE REQUEST message is received by the UE Context,
    ...    indicating that the binding has to be released immediately (current usage stopped immediately).
    ...    There are no ongoing procedures over the NGAP interface.
    ...    ZYY:20250124 check with previous owner in TL384 Handover teams chat CB006999_A_005 and CB006999_B_002 are WR KPI case.
    [Tags]    classical    CB006999-A_005    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4
    [Timeout]    1 hour
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Adjust the TL Topyoung attenuation value    gnb1_cell1_value=${10}
    Online modify parmeters    parameters_to_update=${gnb1_Lock_AMF1_Unlock_AMF2_B002}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
    Start capture gNB log on master    filename=${gNB1_6999_B02}   gNB_index=${0}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
    sleep    10s
    start DL UL    ue_index=${1}
    sleep    155s
    Check DLUL tput    gnb_index=${0}
    Stop UL DL data transfer    ue_index=${1}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
    Stop and download the Logs    filename=${gNB1_6999_B02}   gNB_index=${0}
    [Teardown]    Run Keywords
#    ...    Run Keyword And Ignore Error    Android UE SwitchApn    ue_index=${1}    apn_name=${source_APN}    ui_version=one ui 3.1
    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}    AND
    ...    run keyword and ignore error    Stop and download the Logs    filename=${gNB1_6999_B02}   gNB_index=${0}   AND
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Test recover

#[1]CB006999_A_003_gnb_trigger_reselection_immediately_after_receive_ASI_with_actAmfPlannedRemoval_set_ true_ with_amfPlannedRemovalTimer_0
#    [Documentation]    Purpose of this case is to validate when feature flag is activated,
#    ...    NRBTS/amfPlannedRemovalTimer = 0 indicating that the GUAMIs= unavailable need to be retired immediately.
#    [Tags]    classical    CB006999-A_003    CRT_TRUNK    RAN_5G    RAN_5G_TDD    SBTS00    CRT_UTE
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Adjust the TL Topyoung attenuation value    gnb1_cell1_value=${10}
#    Online modify parmeters    parameters_to_update=${gnb1_Lock_AMF1_Unlock_AMF2}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${gNB1_6999_A03}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    sleep    10s
#    start DL UL    ue_index=${0}
##    sleep    60s
#    Online modify parmeters    parameters_to_update=${gnb1_Unlock_AMF3}
#    Check DLUL tput    gnb_index=${0}
#    make amf-zhou maitain on amf account and alarm 7115 will be raised    status=@{gumistatus}[1]
#    sent atcmd on cpc to trigger ul behaviour    COM_port=${at_com_38411}     ue_index=${0}
#    sleep    10s
#    Check DLUL tput    gnb_index=${0}
#    Stop UL DL data transfer    ue_index=${0}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    Stop and download the Logs    filename=${gNB1_6999_A03}   gNB_index=${0}
#    ##wait until keyword succeeds    10min    30s    Check the 6999 counters A003
#    Run Keyword And Ignore Error    Check the 6999 counters A003
#    [Teardown]    Run Keywords
#    ...    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
##    ...    AND    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${0}
#    ...    AND    Test recover

#[1]5G001707_primary_fiber_and_secondary_fiber_pull_out_pull_in_behavior
#    [Documentation]
#    ...    This case verify the fiber pull in/our, L3 call successfully
#    ...    author:cris.cai
#    [Tags]    Qualcomm    classical    CRT_TRUNK    CRT_22R4    CRT_22R3
#    [Timeout]    1 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Adjust the TL Topyoung attenuation value    gnb1_cell1_value=${10}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${gNB1_1707}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    sleep    2s
#    start DL UL    ue_index=${0}
#    sleep    155s
#    Check DLUL tput    gnb_index=${0}
#    Stop UL DL data transfer    ue_index=${0}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    Stop and download the Logs    filename=${gNB1_1707}   gNB_index=${0}
#    [Teardown]    Run keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error    Power UE stop dl traffic and detach    AND
###    ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${0}    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]5GC000738_B_03_PM_counters_updated_per_PLMN_when_NR_RAN_sharing_for_Uplane_UL
#    [Documentation]
#    ...    The purpose of this test case is to verify the PM counters updated Per PLMN when RAN sharing enabled.
#    [Tags]     CRT_TRUNK    CRT_22R4    CRT_23R1
#    [Timeout]    1 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Adjust the TL Topyoung attenuation value    gnb1_cell1_value=${10}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#    Start capture gNB log on master    filename=${gNB1_738_B3}   gNB_index=${0}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    sleep    10s
#    start DL UL    ue_index=${0}
#    sleep    155s
#    Check DLUL tput    gnb_index=${0}
#    Stop UL DL data transfer    ue_index=${0}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    Stop and download the Logs    filename=${gNB1_738_B3}   gNB_index=${0}
#    [Teardown]    Run keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error    Power UE stop dl traffic and detach    AND
###    ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${0}   AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown


#[1]5GC000738_B_01_PM_counters_updated_per_PLMN_when_NR_RAN_sharing_for_Cplane
#    [Documentation]
#    ...    The purpose of this test case is to verify the PM counters updated Per PLMN when RAN sharing enabled
#    [Tags]     Qualcomm    classical    CIT_TRUNK    CDRT    CIT_23R1
#    [Timeout]    1 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Connect and Modify the ENB parameter    value=locked    dist_name=${enb1_gnb1_x2_dist}    parameter=${eNB_X2_ON_OFF}
#    Connect and Modify the ENB parameter    value=1    dist_name=${enb1_def_gnb_dist}    parameter=${enb_def_cell_para}
#    Online modify parmeters    parameters_to_update=${gnb1_Lock_AMF1}
#    Connect and Modify the ENB parameter    value=unlocked    dist_name=${enb1_gnb1_x2_dist}    parameter=${eNB_X2_ON_OFF}
#    Adjust the TL HBTE attenuation value    gnb1_cell1_value=${30}    enb1_cell1_value=${10}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#    Start to collect the log on eNB    log_name=${s1log_B01}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}
#    sleep    10s
#    Wait Until Keyword Succeeds    10min    40s    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}
#    Wait until keyword succeeds    16 min    30s    Check counter for B01
#    start DL UL    ue_index=${0}    dl_throughput=${dl_20M}    ul_throughput=${ul_20M}
#    sleep    6s
#    Check DLUL tput
#    Stop UL DL data transfer    ue_type=${ue_type}    ue_index=${0}
#    Stop and download Logs on eNB    log_name=${s1log_B01}
#    ${M_plmn}    run keyword and return status    Wait until keyword succeeds    1 min    20s   Check counter for B01-1
#    RUN KEYWORD IF    '${M_plmn}'=='None'    Wait until keyword succeeds    1 min    20s   Check counter for B01-2
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error     Stop and download Logs on eNB    log_name=${s1log_B01}    AND
#    ...    Online modify parmeters    parameters_to_update=${gnb1_Unlock_AMF1}    AND
#    ...    Stop UL DL data transfer    ue_type=${ue_type}    ue_index=${0}    AND
#    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}    AND
#    ...    check hanging resource for per UE on gnb    gnb_ips=${gnb_ips}    UE_Type_Index=${0}    AND
#    ...    Run Keyword And Ignore Error    Hanging resource test    AND
#    ...    Run Keyword And Ignore Error    Common Case Teardown for COAM


#[1]CB008247-D_11_IWK_with_CB007552_Multi_BWP
#    [Documentation]     This test case is to verify the inter-working between CB008247 and CB007552 multi-BWP.
#    ...    TAS SRS should not be configured to UE incapable of big BWP, while TAS SRS should be configured to UE capable of big BWP.
#    ...    Trunk-TL354, 70M--60M
#    [Tags]    classical    CB006999-A_003    CRT_TRUNK    RAN_5G    RAN_5G_TDD    SBTS00    CRT_UTE
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Adjust the TL Topyoung attenuation value    gnb1_cell1_value=${10}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    sleep    10s
#    start DL UL    ue_index=${0}
#    sleep    155s
#    Check DLUL tput    gnb_index=${0}
#    Stop UL DL data transfer    ue_index=${0}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#    [Teardown]    Run Keywords
#    ...    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
###    ...    AND    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${0}
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown


*** Keywords ***
Test recover
    #wait until keyword succeeds    10 min    5 sec    Connect to AMF-ZHOU account    alias=UTE
    #csn.execute    command=cmm amfGuamiStatusAdmin modify AMF5-zhou --maintenanceTimer 0 --guamiStatus supported
    #...    connection=UTE    #turn on amf account
#    run keyword and ignore error    Stop and download the Logs    filename=${gNB1_6999_A03}    gNB_index=${0}
    Online modify parmeters    parameters_to_update=${gnb1_recover_AMF}
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

start DL UL
    [Arguments]        ${ue_index}=${0}
    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=${duration}    ue_index=${ue_index}
#    sleep    15s
#    Power UE Start UL traffic    ul_throughput=${ul_throughput}    duration=${duration}    ue_index=${ue_index}

Check DLUL tput
    [Arguments]    ${gnb_index}=${0}
    ${cell1_id}=    COAM Get nrcellid with lcrid    lcrid=${1}    gnb_index=${0}
    ${list_of_cell_ids}    Create list    ${cell1_id}
    ${tput_log}    power_ue.Collect Tput    duration=1m    ue_type=${ue_type}    gnb_index=${gnb_index}
    power_ue.Check Tput    direction=DL    cells=${list_of_cell_ids}    log=${tput_log}    ue_type=${ue_type}
    ...    target_throughput=${dl_expect}
#    power_ue.Check Tput    direction=UL    cells=${list_of_cell_ids}    log=${tput_log}   ue_type=${ue_type}
#    ...    target_throughput=${ul_expect}


#Hanging resource test
#    [Arguments]    ${gnb_ips}=${gnb_ips}    ${ue_index}=${0}
#    [Documentation]    hanging resource test
#    [Timeout]    1hour
#    Check hanging resource for gnb    gnb_ips=${gnb_ips}    ue_index=${ue_index}

#[5GC000738]
Check counter for B01
    Check the PM counter should be greater than 1
    ...    gnb_index=${0}    counter_id=${counter_id_B01}
    ...    dic_path=${counter_dic_path_B01}    value=${value_counter_B01}

Check counter for B01-1
    Check the PM counter should be greater than 1
    ...    gnb_index=${0}    counter_id=${counter_id_B01_1}
    ...    dic_path=${counter_dic_path_B01_1}    value=${value_counter_B01}

Check counter for B01-2
    Check the PM counter should be greater than 1
    ...    gnb_index=${0}    counter_id=${counter_id_B01_2}
    ...    dic_path=${counter_dic_path_B01_2}    value=${value_counter_B01}

#[CB0006999]
Check the 6999 counters A003
    Check the PM counter should be matached
    ...    gnb_index=${0}    counter_id=${counter_id_6999_A003}
    ...    dic_path=${counter_dic_path_6999_A003}    value=${value_counter_6999_A003}