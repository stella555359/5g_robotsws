*** Settings ***
Resource    ./Resource/CB007657_common_keywords.robot
Resource    ../../../resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Variables    ./Resource/7657_variables.py

Documentation
...   author: xiaodan.li
...   contact: xiaodan.li@nokia-sbell.com
...   squad group: SG_03
...   Feature CB007657

Force Tags      5G_SISO    9.1800    10.1800    CRT_21A    CRT_20B    CRT_TRUNK    RAN_5G    RAN_5G_TDD
...    PY36
...    CRT_UTE    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ANDROID_ASIKL_ABILB1_AWHHI_ENB    SBTS00

Suite Setup    Run Keywords
...    robot_common_operations.Common Suite Setup    AND
...    Get gnb release info    AND
...    run keyword if   '${gnb_id}'=='${gnb_instance[0]}'    CI_interface.Common Suite Setup    AND
...    Pre Condition    AND
...    Prepare the enb dyntrig    AND
...    Prepare with COAM classical BTS cell onair    AND
...    Set the attenuation value    att_ports=@{att_ports}    values=${values_trunk}    AND
...    Set the attenuation value    att_ports=@{att_ports_enb}    values=${values_trunk_enb}


Suite Teardown    Run Keywords
...               Run Keyword And Ignore Error    CB007657_common_keywords.Common Suite Teardown for COAM   AND
...               robot_common_operations.Common Suite Teardown

*** Variables ***
${tl_scf_filename}    SCF_SBTS00.xml
${gnb_id}    ${tl.gnbs[0].instance_id}
${epc_log_path}    /opt/workspace/CRT/Master/SCF_file/
@{att_ports}    ${5GRU1_ANT1}    ${5GRU1_ANT2}    ${5GRU1_ANT3}    ${5GRU1_ANT4}
${5GRU1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${5GRU1_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${5GRU1_ANT3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${5GRU1_ANT4}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${5GRU1_ANT1_22R2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${5GRU1_ANT2_22R2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${5GRU1_ANT3_22R2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[2].port_no}
${5GRU1_ANT4_22R2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[3].port_no}
${4GRU1_ANT1}    ${tl.attenuator[0].attenuator_ports[5]}
${4GRU1_ANT2}    ${tl.attenuator[0].attenuator_ports[6]}
@{att_ports_enb}    ${4GRU1_ANT1}    ${4GRU1_ANT2}
@{att_ports_22R2}    ${5GRU1_ANT1_22R2}    ${5GRU1_ANT2_22R2}    ${5GRU1_ANT3_22R2}    ${5GRU1_ANT4_22R2}
@{values_trunk}    ${0}    ${0}    ${0}    ${0}
@{values_trunk_7657}    ${16}    ${16}    ${16}    ${16}
@{values_trunk_1354B01}    ${25}    ${25}    ${25}    ${25}
@{values_trunk_good}    ${30}    ${30}    ${30}    ${30}
@{values_trunk_bad}    ${30}    ${30}    ${30}    ${30}
@{values_trunk_enb}    ${0}    ${0}
@{values}    ${23}    ${23}    ${13}    ${13}
@{values_22R2}    ${35}    ${35}    ${35}    ${35}
${time}    360000
@{gnb_instance}    356111    35911    36911
${expect_dl_tput_A005}    280
${DL_TPUT_Send_A005}    280M
${expect_dl_tput_C001}    200
${expect_dl_tput_C001_2}    400
${DL_TPUT_Send_C001}    200M
${expect_counter_value}    100
${protocol_TCP}    tcp
${protocol_UDP}    udp
${time_tcp}    600
${window}    100k
${seg_size}    536
${process_num}    5
${DL_LENGTH}    1400B
${expect_dl_tput_B001_small}        185    #for case2    Ave=213*0.95    Min=213*0.85
${expect_dl_tput_Peak}              750    #for case2    Ave=213*0.95    Min=213*0.85
@{CT_1354_B}    M55355C04007     M55355C05007
@{CT_Bvalues}    0    0    570    605     330    355    575    605     830    865
#${702_CASE_LOG_PATH}      /opt/workspace/CRT/Master/Case_Logs/
${702_RECOVERY_TIMEOUT}    15 min
${ul_throughput}            20M
${ul_expect_throughput}    7
@{allow_fault_list}    7107    7523    4681

*** Test Cases ***
[1]CB007657_A_03_US3_Low_PAPR_Open_Loop_4x4_SU_MIMO_without_beamforming_TDD_CPRI_Peak_NSA_256QAM
    [Documentation]
    ...    This test scenario is used to verify the E2E data transfer functionality of RF in full-panel mode.
    [Tags]     classical    CRT_TRUNK    CRT_22R1    RAN_5G    RAN_5G_TDD    SBTS00    CRT_22R2    CRT_22R3
    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=7107,7523,4681
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Modify gnb parameter and gnb on air of 7657 A03
    Modify gnb parameter and gnb on air    parameters=${PARAMS_TO_actDlLowPAPRoptimizedPrecoding_False}
    ${dl_expect_throughput_true}    ${ul_expect_throughput}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${tl_scf_dir_path}${tl_scf_filename}    cell_id=${1}
    ${list_of_cell_ids}=    Get Cell id list
    Set the attenuation value    att_ports=@{att_ports}    values=${values_trunk_7657}
    Set the attenuation value    att_ports=@{att_ports_enb}    values=${values_trunk_enb}
    Precondition for Sansumg UE    ue_type=${ue_type}    ui_version=S21UI3.1
    ${PAPR_false_output}=     Attach ue and check tput
    ...    dl_expect_throughput=${dl_expect_throughput_false}    list_of_cell_ids=${list_of_cell_ids}
    ${peak_false}=    get peak value    ${PAPR_false_output}
    Modify gnb parameter and gnb on air    parameters=${PARAMS_TO_actDlLowPAPRoptimizedPrecoding_True}
    ${PAPR_true_output}=     Attach ue and check tput
    ...    dl_expect_throughput=${dl_expect_throughput_true}    list_of_cell_ids=${list_of_cell_ids}
    ${peak_true}=    get peak value    ${PAPR_true_output}
    run keyword if   '${gnb_id}'=='${gnb_instance[0]}'    Should be True    ${peak_true} > ${peak_false}
    ...    ELSE    Should be True    ${peak_true} > ${peak_false}    #verify the supplement modify PAPR from false to true
    [Teardown]    Run keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Run Keyword And Ignore Error    Power UE stop dl traffic and detach    AND
    ...    Online modify parmeters    parameters_to_update=${PARAMS_TO_dlMimoMode_close}    AND
    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    ute_log_path=${ute_log_path}    AND
    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

#[1]CB007657_A_17_US4_Low_PAPR_Close_Loop_4x4_SU_MIMO_without_beamforming_TDD_CPRI_Performance_Curve_VS_AWGN_SA
#    [Documentation]
#    ...    This test scenario is used to verify the E2E data transfer functionality of RF in full-panel mode.
#    [Tags]     classical    CRT_TRUNK    RAN_5G    RAN_5G_TDD    SBTS00    CRT_22R2
#    [Setup]    robot_common_operations.Common Case Setup
#    Modify gnb parameter and gnb on air of 7657 A17
#    Modify gnb parameter and gnb on air    parameters=${PARAMS_TO_actDlLowPAPRoptimizedPrecoding_False}
#    ${list_of_cell_ids}=    Get Cell id list
#    run keyword if   '${gnb_id}'=='${gnb_instance[0]}'    Run keywords
#    ...    Set the attenuation value    att_ports=@{att_ports}    values=${values_trunk}    AND
#    ...    Set the attenuation value    att_ports=@{att_ports_enb}    values=${values_trunk_enb}
#    ...    ELSE IF    '${gnb_id}'=='${gnb_instance[2]}'    Set the attenuation value topyoung    att_ports=@{att_ports}
#    ...    values=${values}
#    ...    ELSE    Set the attenuation value topyoung    att_ports=@{att_ports_22R2}    values=${values_22R2}
#    power_ue.Prepare UE     ue_type=${ue_type}
#    ${PAPR_false_output}=     run keyword if   '${gnb_id}'=='${gnb_instance[2]}'    Attach ue and check tput
#    ...    dl_expect_throughput=${dl_expect_throughput_false_22R1}    list_of_cell_ids=${list_of_cell_ids}
#    ...    ELSE    Attach ue and check tput
#    ...    dl_expect_throughput=${dl_expect_throughput_false}    list_of_cell_ids=${list_of_cell_ids}
#    ${peak_false}=    get peak value    ${PAPR_false_output}
#    Modify gnb parameter and gnb on air    parameters=${PARAMS_TO_actDlLowPAPRoptimizedPrecoding_True}
#    ${PAPR_true_output}=     run keyword if   '${gnb_id}'=='${gnb_instance[2]}'    Attach ue and check tput
#    ...    dl_expect_throughput=${dl_expect_throughput_true_22R1}    list_of_cell_ids=${list_of_cell_ids}
#    ...    ELSE    Attach ue and check tput
#    ...    dl_expect_throughput=${dl_expect_throughput_true}    list_of_cell_ids=${list_of_cell_ids}
#    ${peak_true}=    get peak value    ${PAPR_true_output}
#    run keyword if   '${gnb_id}'=='${gnb_instance[0]}'    Should be True    ${peak_true} - ${peak_false} >= ${5}
#    ...    ELSE    Should be True    ${peak_true} - ${peak_false} >= ${5}    #verify the supplement modify PAPR from false to true
#    [Teardown]    Run keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error    Power UE stop dl traffic and detach    AND
#    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    ute_log_path=${ute_log_path}    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

[1]5GC001354_5G_A_005_Duplicate_transmission_of_PDCP_PDU_for_DDDS_handling_during_PDCP_SN_rollover_over_X2-U_interface_with_UDP
    [Documentation]
    [Tags]    CRT_TRUNK    5GC001354-A
    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=7107,7523
    [Timeout]    2 hour
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Precondition for Sansumg UE    ue_type=${ue_type}    ui_version=S21UI3.1
    Common Case TestLine Setup    ModifySCF_Aftercommission=True    Modify_Para_Online=${Modify_Para_Online_A005}
    UE attach and check
    Prepare with PM counter time to caculate    period=start
    Power UE Start DL traffic    dl_throughput=${DL_TPUT_Send_A005}    duration=${time}
    Check DL TP    dl_expect_throughput=${expect_dl_tput_A005}    duration=60s
    Wait until keyword succeeds    5 min    20s    Check Counter for A005_01
    Power UE stop dl traffic and detach
    Common Case TestLine Setup    ModifySCF_Aftercommission=True    Modify_Para_Online=${Modify_Para_actX2DuplicateTxNSA3x_true}
        ...    Add_Para_Online=${PARAMS_TO_Para_Online_A005_X2PdcpDuplication}
    UE attach and check
    Prepare with PM counter time to caculate    period=start
    Power UE Start DL traffic    dl_throughput=${DL_TPUT_Send_A005}    duration=${time}
    Check DL TP    dl_expect_throughput=${expect_dl_tput_A005}    duration=60s
    Wait until keyword succeeds    5 min    20s    Check Counter for A005_02
    Power UE stop dl traffic and detach
    [Teardown]    Run keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Run Keyword And Ignore Error    Power UE stop dl traffic and detach    AND
    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    ute_log_path=${ute_log_path}    AND
    ...    Run Keyword And Ignore Error     Common Case TestLine Setup    ModifySCF_Aftercommission=True
    ...    Modify_Para_Online=${PARAMS_TO_actLostPduFastRetx_false}
    ...    Delete_Para_Online=${PARAMS_TO_delete_nsaDrbParam}    Add_Para_Online=${PARAMS_TO_add_nsaDrbParam}    AND
    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

#[1]5GC001354_5G_B_001_Periodic_duplicate_transmission_of_PDCP_PDU_over_X2-U_interface_with_NSA_classicalFR1_nokiaENB_TDD_non_GBR_DRB_TCP
#    [Documentation]
#    [Tags]    CRT_TRUNK    CRT_22R2    5GC001354-B    CRT_22R3    CRT_22R4    CRT_23R1
#    [Setup]    robot_common_operations.Common Case Setup
#    [Timeout]    2 hour
#    Power_ue.Prepare UE     ue_type=${ue_type}
#    ##check TP and have counter(M55355C04007 M55355C05007 ==0) when actX2DuplicateTxNSA3x disabled. With TCP
#    Common Case TestLine Setup    ModifySCF_Aftercommission=True    Modify_Para_Online=${Modify_Para_Online_B001}
#    UE attach and check    gnb_PA_value=${values_trunk}
#    Power UE Start DL traffic    dl_throughput=${DL_TPUT_Send_C001}    duration=${time_tcp}    protocol=${protocol_TCP}
#    ...    seg_size=${seg_size}    window=${window}    process_num=${process_num}    dl_length=${DL_LENGTH}
#    Check DL TP    dl_expect_throughput=${expect_dl_tput_C001}    duration=180s
#    wait until keyword succeeds    5min    30s
#    ...    Check counters @{CT_1354_B}[0] in @{CT_Bvalues}[0] and @{CT_Bvalues}[0] and @{CT_1354_B}[1] in @{CT_Bvalues}[0] and @{CT_Bvalues}[0]
#    Power UE stop dl traffic and detach
#    ##check TP and have counter(M55355C04007 M55355C05007 200~1000) when actX2DuplicateTxNSA3x enabled. With TCP
#    Common Case TestLine Setup    ModifySCF_Aftercommission=True    Modify_Para_Online=${Modify_Para_actX2DuplicateTxNSA3x_true}
#        ...    Add_Para_Online=${PARAMS_TO_Para_Online_B001_X2PdcpDuplication}
#    UE attach and check    gnb_PA_value=${values_trunk}
#    Power UE Start DL traffic    dl_throughput=${DL_TPUT_Send_C001}    duration=${time_tcp}    protocol=${protocol_TCP}
#    ...    seg_size=${seg_size}    window=${window}    process_num=${process_num}    dl_length=${DL_LENGTH}
#    Check DL TP    dl_expect_throughput=${expect_dl_tput_C001}    duration=180s
#    wait until keyword succeeds    5min    30s
#    ...  Check counters @{CT_1354_B}[0] in @{CT_Bvalues}[2] and @{CT_Bvalues}[3] and @{CT_1354_B}[1] in @{CT_Bvalues}[4] and @{CT_Bvalues}[5]
#    Power UE stop dl traffic and detach
#    ##check Peak UDP TP and have counter(M55355C04007 M55355C05007 ==0) when actX2DuplicateTxNSA3x enabled. With UDP
#    UE attach and check    gnb_PA_value=${values_trunk}
#    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=${time}
#    Check DL TP    dl_expect_throughput=${dl_expect_throughput_true}    duration=180s
#    wait until keyword succeeds    5min    30s
#    ...  Check counters @{CT_1354_B}[0] in @{CT_Bvalues}[0] and @{CT_Bvalues}[1] and @{CT_1354_B}[1] in @{CT_Bvalues}[0] and @{CT_Bvalues}[1]
#    [Teardown]    Run keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error    Power UE stop dl traffic and detach    AND
#    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    ute_log_path=${ute_log_path}    AND
#    ...    Run Keyword And Ignore Error     Common Case TestLine Setup    ModifySCF_Aftercommission=True
#    ...    Modify_Para_Online=${PARAMS_TO_actLostPduFastRetx_false}
#    ...    Delete_Para_Online=${PARAMS_TO_delete_nsaDrbParam}    Add_Para_Online=${PARAMS_TO_add_nsaDrbParam1}    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]5GC001354_5G_C_001_DelayThresh1and2Enabled_PDCP_Delay_Threshold_based_PDU_retransmission_over_X2-U_with_NSA_FDD_non_GBR_DRB_UDP
#    [Documentation]
#    [Tags]    CRT_TRUNK    5GC001354-C    CRT_23R1
#    [Setup]    robot_common_operations.Common Case Setup
#    [Timeout]    2 hours
#    Power_ue.Prepare UE     ue_type=${ue_type}
#    Common Case TestLine Setup    ModifySCF_Aftercommission=True    Modify_Para_Online=${Modify_Para_Online_C001}
#    ...    Add_Para_Online=${PARAMS_TO_Para_Online_C001_002}
#    UE attach and check    gnb_PA_value=${values_trunk}
#    Prepare with PM counter time to caculate    period=start
#    Power UE Start DL traffic    dl_throughput=${DL_TPUT_Send_C001}    duration=${time}
#    Check DL TP    dl_expect_throughput=${expect_dl_tput_C001}    duration=180s
#    Power UE stop dl traffic and detach
#    Run Keyword And Continue On Failure     Wait until keyword succeeds    2 min    20s    Check Counter for C001
#    UE attach and check    gnb_PA_value=${values_trunk_bad}
#    Prepare with PM counter time to caculate    period=start
#    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=${time}
#    Check DL TP    dl_expect_throughput=${expect_dl_tput_C001_2}    duration=180s
#    Power UE stop dl traffic and detach
#    Wait until keyword succeeds    2 min    20s    Check Counter for C001_2
#    [Teardown]    Run keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error    Power UE stop dl traffic and detach    AND
#    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    ute_log_path=${ute_log_path}    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

#[1]5G001707_primary_fiber_and_secondary_fiber_pull_out_pull_in_behavior
#    [Documentation]
#    ...    This case verify the fiber pull in/our, L3 call successfully
#    ...    author:cris.cai
#    [Tags]    Qualcomm    classical    CRT_TRUNK    CRT_22R4    CRT_22R3
#    [Timeout]    1 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Precondition for Sansumg UE    ue_type=${ue_type}    ui_version=S21UI3.1
#    UE attach and check
#    Power UE Start DL traffic    dl_throughput=${DL_TPUT_Send_C001}    duration=${time}
#    Check DL TP    dl_expect_throughput=${expect_dl_tput_C001}    duration=180s
#    Power UE stop dl traffic and detach
#    power_ue.UE Detach    ue_type=${ue_type}
#    sleep    10s
#    UE attach and check
#    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}    duration=${duration}
#    ...    ue_index=${0}    iperf_port=${dl_port}
#    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}    duration=${duration}
#    ...    ue_index=${0}    iperf_port=${ul_port}
#    sleep    120s
#    power_ue.Check throughput    ue_type=${ue_type}    direction=ul
#    ...    throughput=${ul_expect_throughput}    gnb_index=${0}
#    power_ue.Check throughput    ue_type=${ue_type}    direction=dl
#    ...    throughput=${dl_expect_throughput1}    gnb_index=${0}
#    Stop UL DL data transfer    ue_index=${0}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    [Teardown]    Run keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error    Power UE stop dl traffic and detach    AND
#    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    ute_log_path=${ute_log_path}    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

[1]5GC000738_B_03_PM_counters_updated_per_PLMN_when_NR_RAN_sharing_for_Uplane_UL
    [Documentation]
    ...    The purpose of this test case is to verify the PM counters updated Per PLMN when RAN sharing enabled.
    [Tags]     CRT_TRUNK    CRT_22R4    CRT_23R1
    [Timeout]    1 hour
    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=7107,7523
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Precondition for Sansumg UE    ue_type=${ue_type}    ui_version=S21UI3.1
    UE attach and check
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}    duration=${duration}
    ...    ue_index=${0}    iperf_port=${dl_port}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}    duration=${duration}
    ...    ue_index=${0}    iperf_port=${ul_port}
    sleep    120s
    power_ue.Check throughput    ue_type=${ue_type}    direction=ul
    ...    throughput=${ul_expect_throughput}    gnb_index=${0}
    power_ue.Check throughput    ue_type=${ue_type}    direction=dl
    ...    throughput=${dl_expect_throughput1}    gnb_index=${0}
    Stop UL DL data transfer    ue_index=${0}    dl_port=${DL_PORT}    ul_port=${UL_PORT}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
    [Teardown]    Run keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Run Keyword And Ignore Error    Power UE stop dl traffic and detach    AND
    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    ute_log_path=${ute_log_path}    AND
    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown


*** Keywords ***
Modify gnb parameter and gnb on air of 7657 A03
    Online modify parmeters    parameters_to_update=${PARAMS_TO_dlMimoMode_open}
    Online modify parmeters    parameters_to_update=${PARAM_7326_pmax_43}
    Online modify parmeters    parameters_to_update=${PARAMS_TO_dlQam256PowerBackoffSub6}
    Online modify parmeters    parameters_to_update=${Lock_gnb1_AMF1}
    Wait Until Keyword Succeeds    5 min    30 sec     Check the cells status on air    bts_host=${bts_host}
    ...    connection=gnb

Modify gnb parameter and gnb on air of 7657 A17
    Online modify parmeters    parameters_to_update=${PARAMS_TO_dlMimoMode_close}
    Online modify parmeters    parameters_to_update=${PARAM_7326_pmax_43}
    Online modify parmeters    parameters_to_update=${PARAMS_TO_dlQam256PowerBackoffSub6}
    Wait Until Keyword Succeeds    5 min    30 sec     Check the cells status on air    bts_host=${bts_host}
    ...    connection=gnb

COAM gNB Reset site
    Connect to gnb coam via ssl    connection=coam_admin
    coam.reset_site         connection=coam_admin
    COAM Teardown gnb connections    coam_admin

Attach ue and check tput
    [Arguments]    ${dl_expect_throughput}=${dl_expect_throughput}    ${list_of_cell_ids}=${list_of_cell_ids}
    wait until keyword succeeds    3X    10s    Attach and check power UE     ue_type=${ue_type}    4G_check=True
    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=${time}
    sleep    120s
    ${output}    Check single direction throughput    expect_throughput=${dl_expect_throughput}
    ...    list_of_cell_ids=${list_of_cell_ids}    duration=5m    target_avg_percent=0.98
    Power UE stop dl traffic and detach
    [Return]    ${output}

Check Counter for A005_01
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_A005}    dic_path=${counter_dic_path_A005}
    ${M55313C00007_FED_RCV_NUM}    Set Variable    ${counter_value_list}[0]
    ${M55313C04007_lost_X2-U}    Set Variable    ${counter_value_list}[1]
    ${M55355C04007_duplication_X2-U_NUM}    Set Variable    ${counter_value_list}[2]
    ${M55355C05007_duplication_X2-U_volume}    Set Variable    ${counter_value_list}[3]
    ${M55313C08007_data_X2-U_volume}    Set Variable    ${counter_value_list}[4]
    Should Be True    ${M55313C00007_FED_RCV_NUM} == ${0}
    Should Be True    ${M55313C04007_lost_X2-U} == ${0}
    Should Be True    ${M55355C04007_duplication_X2-U_NUM} == ${0}
    Should Be True    ${M55355C05007_duplication_X2-U_volume} == ${0}
    Should Be True    50 < ${M55313C08007_data_X2-U_volume} < 1000
    [Return]    ${M55313C08007_data_X2-U_volume}
    [Teardown]    COAM Teardown gnb connections

Check Counter for A005_02
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_A005}    dic_path=${counter_dic_path_A005}
    ${M55355C04007_duplication_X2-U_NUM_actX2DuplicateTxNSA3x_true}    Set Variable    ${counter_value_list}[2]
    ${M55355C05007_duplication_X2-U_volume_actX2DuplicateTxNSA3x_true}    Set Variable    ${counter_value_list}[3]
    ${M55313C08007_data_X2-U_volume_actX2DuplicateTxNSA3x_true}    Set Variable    ${counter_value_list}[4]
    Should Be True    0 < ${M55355C04007_duplication_X2-U_NUM_actX2DuplicateTxNSA3x_true} < 400
    Should Be True    0 < ${M55355C05007_duplication_X2-U_volume_actX2DuplicateTxNSA3x_true} < 400
    Should Be True    0 < ${M55313C08007_data_X2-U_volume_actX2DuplicateTxNSA3x_true}  < 1000
    [Teardown]    COAM Teardown gnb connections

Check Counter for C001
    Check Counter for 1354_C
    Should Be True    200000000 > ${M55314C02007_PDU_receives_F1-U} > 0
    Should Be True    150000 > ${M55354C06007_exceed_Threshold2_F1-U} >= 0
    Should Be True    200000 > ${M55354C07007_exceed_Threshold2_F1-U_VOL} >= 0
    Should Be True    2000 > ${M55354C04007_exceed_Threshold1_F1-U} >= 0
    Should Be True    3000 > ${M55354C05007_exceed_Threshold1_F1-U_VOL} >= 0
    Should Be True    1000 > ${M55355C06007_exceed_Threshold1_X2-U} >= 0
    Should Be True    1000 > ${M55355C07007_exceed_Threshold1_X2-U_VOL} >= 0
    Should Be True    ${M55355C08007_exceed_Threshold2_X2-U} >= 0
    Should Be True    ${M55355C09007_exceed_Threshold2_X2-U_VOL} >= 0
    Should Be True    ${M55311C46007_discarded} == 0
    Should Be True    ${M55311C47007_discarded_VOL} == 0
    Should Be True    400 > ${exceed_Threshold1_SUM} >= 0
    ${exceed_Threshold1}=    Evaluate    ${M55354C04007_exceed_Threshold1_F1-U} + ${M55355C06007_exceed_Threshold1_X2-U}
    Should Be True    ${exceed_Threshold1_SUM} == ${exceed_Threshold1}
    ${exceed_Threshold2}=    Evaluate    ${M55354C06007_exceed_Threshold2_F1-U} + ${M55355C08007_exceed_Threshold2_X2-U}
    Should Be True    ${exceed_Threshold2_SUM} == ${exceed_Threshold2}

Check Counter for C001_2
    Check Counter for 1354_C
    Should Be True    200000 > ${M55354C06007_exceed_Threshold2_F1-U} > 0
    Should Be True    250000 > ${M55354C07007_exceed_Threshold2_F1-U_VOL} > 0
    Should Be True    10000 > ${M55354C04007_exceed_Threshold1_F1-U} > 0
    Should Be True    10000 > ${M55354C05007_exceed_Threshold1_F1-U_VOL} > 0
    Should Be True    30000 > ${M55355C06007_exceed_Threshold1_X2-U} >= 0
    Should Be True    30000 > ${M55355C07007_exceed_Threshold1_X2-U_VOL} >= 0
    Should Be True    150000 > ${M55355C08007_exceed_Threshold2_X2-U} > 0
    Should Be True    30000 > ${M55355C09007_exceed_Threshold2_X2-U_VOL} > 0
    Should Be True    500000 > ${M55320C23007_not_retransmitted} >= 0
    Should Be True    300000 > ${M55311C46007_discarded} >= 0
    Should Be True    300000 > ${M55311C47007_discarded_VOL} >= 0
    ${exceed_Threshold1_F1U_AND_X2U}    Evaluate    ${M55355C06007_exceed_Threshold1_X2-U} + ${M55354C04007_exceed_Threshold1_F1-U}
    Should Be True    ${exceed_Threshold1_F1U_AND_X2U} >= ${exceed_Threshold1_SUM}
    ${exceed_Threshold2_F1U_AND_X2U}    Evaluate    ${M55354C06007_exceed_Threshold2_F1-U} + ${M55355C08007_exceed_Threshold2_X2-U}
    Should Be True    ${exceed_Threshold2_F1U_AND_X2U} >= ${exceed_Threshold2_SUM}

 Check Counter for 1354_C
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_C003}    dic_path=${counter_dic_path_C003}
    Set suite variable     ${M55320C21001_exceed_Threshold1}    ${counter_value_list}[0]
    Set suite variable    ${M55320C21002_exceed_Threshold1}    ${counter_value_list}[1]
    Set suite variable    ${M55320C21003_exceed_Threshold1}    ${counter_value_list}[2]
    Set suite variable    ${M55320C21004_exceed_Threshold1}    ${counter_value_list}[3]
    Set suite variable    ${M55320C21005_exceed_Threshold1}    ${counter_value_list}[4]
    Set suite variable    ${M55320C21006_exceed_Threshold1}    ${counter_value_list}[5]
    Set suite variable    ${M55320C21007_exceed_Threshold1}    ${counter_value_list}[6]
    Set suite variable    ${M55320C21008_exceed_Threshold1}    ${counter_value_list}[7]
    Set suite variable    ${M55320C21009_exceed_Threshold1}    ${counter_value_list}[8]
    Set suite variable    ${M55320C22001_exceed_Threshold2}    ${counter_value_list}[9]
    Set suite variable    ${M55320C22002_exceed_Threshold2}    ${counter_value_list}[10]
    Set suite variable    ${M55320C22003_exceed_Threshold2}    ${counter_value_list}[11]
    Set suite variable    ${M55320C22004_exceed_Threshold2}    ${counter_value_list}[12]
    Set suite variable    ${M55320C22005_exceed_Threshold2}    ${counter_value_list}[13]v
    Set suite variable    ${M55320C22006_exceed_Threshold2}    ${counter_value_list}[14]
    Set suite variable    ${M55320C22007_exceed_Threshold2}    ${counter_value_list}[15]
    Set suite variable    ${M55320C22008_exceed_Threshold2}    ${counter_value_list}[16]
    Set suite variable    ${M55320C22009_exceed_Threshold2}    ${counter_value_list}[17]
    Set suite variable    ${M55320C23007_not_retransmitted}    ${counter_value_list}[18]
    Set suite variable    ${M55354C04007_exceed_Threshold1_F1-U}    ${counter_value_list}[19]
    Set suite variable    ${M55354C05007_exceed_Threshold1_F1-U_VOL}    ${counter_value_list}[20]
    Set suite variable    ${M55354C06007_exceed_Threshold2_F1-U}    ${counter_value_list}[21]
    Set suite variable    ${M55354C07007_exceed_Threshold2_F1-U_VOL}    ${counter_value_list}[22]
    Set suite variable    ${M55355C06007_exceed_Threshold1_X2-U}    ${counter_value_list}[23]
    Set suite variable    ${M55355C07007_exceed_Threshold1_X2-U_VOL}    ${counter_value_list}[24]
    Set suite variable    ${M55355C08007_exceed_Threshold2_X2-U}    ${counter_value_list}[25]
    Set suite variable    ${M55355C09007_exceed_Threshold2_X2-U_VOL}    ${counter_value_list}[26]
    Set suite variable    ${M55311C46007_discarded}    ${counter_value_list}[27]
    Set suite variable    ${M55311C47007_discarded_VOL}    ${counter_value_list}[28]
    Set suite variable    ${M55313C08007_NR_X2-U_DL}    ${counter_value_list}[29]
    Set suite variable    ${M55314C02007_PDU_receives_F1-U}    ${counter_value_list}[30]
    ${exceed_Threshold2_SUM}    Set Variable    ${0}
    FOR    ${index}    IN RANGE    9    17
        ${exceed_Threshold2_SUM}=    Evaluate    ${exceed_Threshold2_SUM} + ${counter_value_list}[${index}]
        ${index}    Evaluate    ${index} + 1
    END
    Set Suite Variable    ${exceed_Threshold2_SUM}
    ${exceed_Threshold1_SUM}    Set Variable    ${0}
    FOR    ${index}    IN RANGE    0    8
        ${exceed_Threshold1_SUM}=    Evaluate    ${exceed_Threshold1_SUM} + ${counter_value_list}[${index}]
        ${index}    Evaluate    ${index} + 1
    END
    Set Suite Variable    ${exceed_Threshold1_SUM}
    [Teardown]    COAM Teardown gnb connections

UE attach and check
    [Arguments]    ${gnb_PA_value}=${values_trunk}
    Set the attenuation value    att_ports=@{att_ports}    values=${gnb_PA_value}
    Set the attenuation value    att_ports=@{att_ports_enb}    values=${values_trunk_enb}
    wait until keyword succeeds    3X    10s    Attach and check power UE     ue_type=${ue_type}    4G_check=true

Check DL TP
    [Arguments]    ${dl_expect_throughput}    ${duration}=180s
    ${list_of_cell_ids}=    Get Cell id list
    ${output}    Check single direction throughput    expect_throughput=${dl_expect_throughput}
    ...    list_of_cell_ids=${list_of_cell_ids}    duration=${duration}

Check counters ${counter_id1} in ${value1} and ${value2} and ${counter_id2} in ${value3} and ${value4}
#    Log To Console     Check counters
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}
    ...    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id1}
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${value1}
    should be true   ${values[-1]}<=${value2}
    ${counters2}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id2}
    ${values2}    get dictionary values   ${counters2}
    log  The latest one is: ${values2[-1]}
    should be true   ${values2[-1]}>=${value3}
    should be true   ${values2[-1]}<=${value4}
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    Kill firefox process

Calculate BTS or ru reset pass rate
    [Documentation]  Author: Jack Zeng
    ...              Description: this keyword is used for calculate the pass rate of BTS or RU after reset given times
    ...                           ${reset_type}: optional,value can be 'bts' or 'ru'
    ...                           ${reset_times}: given the reset times
    [Arguments]    ${reset_type}    ${reset_times}
    ${fail_times}    Set variable    ${0}
    FOR    ${0}    IN RANGE    ${reset_times}
        Run keyword if    '${reset_type}' == 'bts'    Perform BTS Site Reset
        ...    ELSE IF    '${reset_type}' == 'ru'    Perform gnb RU Reset
        ...    ELSE    Fail    ${reset_type} is invalid input,please retype!
        sleep    180s
        ${status}    run keyword and return status    Wait until cluster is on cell on air status    timeout=${702_RECOVERY_TIMEOUT}
        ...    is_all_cells_checking_needed=${True}
        ${fail_times}    Run keyword if    ${status}==${False}    Evaluate    ${fail_times}+1    ELSE    set variable    ${fail_times}
    END
    ${pass_rate}    Evaluate    (1-${fail_times}/${reset_times})*100
    Log to console    reset ${reset_type} ${reset_times} times,fail ${fail_times} times,pass rate is ${pass_rate}%
    Should be true    ${pass_rate}>90

Perform gnb RU Reset
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${ru_index}=${1}   ${download_dir}=${TS_CASE_LOG_PATH}
    ${ru_index}  Convert To Integer    ${ru_index}
    COAM Navigate to login page via webUI   download_dir=${download_dir}    gnb_index=${0}
    selenium_coam.reset_ru  ru_index=${ru_index}
    [Teardown]  COAM selenium logout
