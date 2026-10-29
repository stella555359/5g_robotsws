*** Settings ***
Documentation     author: qingqing.zhang
...                 contact:qingqing.zhang@nokia-sbell.com
...                 squad group: SG_03
...                 feature : 5GC001354

Resource     ./../Resources/5GC001354_common_keyword.robot
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001354/Resources/variables.py

Suite Setup    Run Keywords
...            robot_common_operations.Common Suite Setup
...            AND    Run Keyword And Ignore Error    Common Suite Setup for COAM

Suite Teardown    Run Keywords
...               robot_common_operations.Common Suite Teardown    AND
...               Adjust gNB_RU Attenuation    AND
...               Run Keyword And Ignore Error     Common Suite Teardown for COAM    gnb_list=${gnb_list}

*** Variables ***
${enb_golden_scf}     eNB_SCF_FGCR_8315.xml
${protocol_TCP}    tcp
${protocol_UDP}    udp
${scf_path}    /opt/workspace/CRT/Master/SCF_file/
${golden_scf_name}    golden_TDD.xml
${gnb_scf_SBTS24R1_ENB_0000}    golden_TDD_24R1.xml
${gnb_scf_SBTS23R4_ENB_0000}    golden_TDD_23R4.xml
${gnb_scf_SBTS23R3_ENB_0000}    golden_TDD_23R1.xml
${golden_scf_name_gnb2}    golden_FDD.xml
${A002_HO}    A002_intra_HO.pcap
${A002_HO_02}    A002_intra_HO2.pcap
${A003_gnb}     A003_gnb.pcap
${A003_enb}     A003_enb.pcap
${ENB_traffic_34411}    940M
${ENB_traffic_34111}    939M
${ENB_traffic_24211}    939M
${ENB_traffic_A004}    941M
${ENB_traffic_A004_341}    941M
${ENB_traffic_port_34411}    35345
${ENB_traffic_port_34111}    35342
${ENB_traffic_port_24211}    35243
${enb_addr}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${time}    600s
${time_A005}    900s
${expect_dl_tput_A002}    800
${expect_dl_tput_A002_trunk}    700
${expect_dl_tput_A004}    500
${expect_dl_tput_A004_2}    100
${DL_TPUT_Send_A004}    1200M
${expect_dl_tput_A005}    400
${DL_TPUT_Send_A005}    400M
${DL_TPUT_Send_A003}    200M
${expect_dl_tput_A003}    10
${seg_size}    1280
${window}    410K
${process_num}    16
${enb_dist_name}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
${enb_para}    defaultLnRelGnbCellId
@{enb_value}    2    3    1    0
@{gnb_list}    ${0}
@{allow_fault_list}    7523    7107    7311

*** Test Cases ***
#[1]5GC001354_5G_A_001_Retransmission_based_Priosame_link_of_lost_PDCP_PDUs_over_X2-U_interface_with_NSA_FDD_non_GBR_DRB_TCP
#    [Documentation]
#    ...    This test scenario is used to verify same_link_of_lost_PDCP.
#    [Tags]     classical    CRT_TRUNK    CRT_23R1    CRT_23R2
#    [Timeout]    1 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    ${release_info}    Get gnb release
#    power_ue.Prepare UE     ue_type=${ue_type}
#    Run Keyword if    '${tl.gnbs[0].instance_id}' == '34411' or '${release_info}' == '@{branch}[0]'
#    ...    Common Case TestLine Setup    ModifySCF_Aftercommission=True    Modify_Para_Online=${Modify_Para_Online_A001_trunk}
#    ...    ELSE    Common Case TestLine Setup    ModifySCF_Aftercommission=True    Modify_Para_Online=${Modify_Para_Online_A001}
#    ...    Add_Para_Online=${PARAMS_TO_Para_Online_A001_002}
#    UE attach and check
#    Prepare with PM counter time to caculate    period=start
#    Start UDP traffic    dl_throughput=${DL_TPUT_Send_A004}    time=${time_A005}
#    Start traffic to ENB    time=30s
#    Prepare with PM counter time to caculate    period=end
#    sleep    90s
#    Run Keyword And Continue On Failure    Check counter for A001_01
#    Start traffic to ENB    time=200s
#    ${DL_TPUT_LostPdu_true}=    Get average DL through    gnb_index=${0}    dl_expect_throughput_true=${expect_dl_tput_A002}
#    Detach and Stop traffic to UE and ENB
#    Set actLostPduFastRetx as false
#    UE attach and check
#    Prepare with PM counter time to caculate    period=start
#    Start UDP traffic    dl_throughput=${DL_TPUT_Send_A004}    time=${time_A005}
#    Start traffic to ENB    time=30s
#    Prepare with PM counter time to caculate    period=end
#    sleep    90s
#    Run Keyword And Continue On Failure    Check counter for A001_02
#    Start traffic to ENB    time=200s
#    ${DL_TPUT_LostPdu_false}=    Get average DL through    gnb_index=${0}    dl_expect_throughput_true=${expect_dl_tput_A002}
#    Detach and Stop traffic to UE and ENB
#    Should Be True    ${DL_TPUT_LostPdu_true} > ${DL_TPUT_LostPdu_false}-10
#   [Teardown]    Run keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error    Detach and Stop traffic to UE and ENB    AND
#    ...    Check hanging resource for gnb    gnb_ips=@{gnb_ips}     AND
#    ...    Run Keyword And Ignore Error    Test recover

#[1]5GC001354_5G_A_002_Retransmission_of_PDCP_PDUs_during_Intra-DU_handover_with_NSA_classicalFR1_nokiaENB_TDD_non_GBR_DRB_UDP
#    [Documentation]
#    [Tags]    CRT_TRUNK    5GC001354-A    CRT_23R1
#    [Setup]     robot_common_operations.Common Case Setup
#    [Timeout]    2 hour
#    power_ue.Prepare UE     ue_type=${ue_type}
#    Common Case TestLine Setup    ModifySCF_Aftercommission=True
#    ...    Modify_Para_Online=${Modify_Para_Online_A002}
#    ...    Add_Para_Online=${Modify_Para_Online_A002_002}
#    Run Keyword if    '${tl.gnbs[0].instance_id}' == '24211'    Adjust gNB_RU Attenuation    gnb1_cell2_value=${0}    enb_cell1_value=${0}
#    ...    ELSE    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    enb_cell1_value=${0}
#    Run Keyword if    '${tl.gnbs[0].instance_id}' == '34111'    Modify the enblte parameter    dist_name=${enb_dist_name}
#    ...     parameter=${enb_para}   value=@{enb_value}[0]    ELSE IF    '${tl.gnbs[0].instance_id}' == '24211'
#    ...     Modify the enblte parameter    dist_name=${enb_dist_name}    parameter=${enb_para}   value=@{enb_value}[2]
#    Wait until keyword succeeds    3X    10s    Attach and check power UE    ue_type=${ue_type}    4G_check=true    ue_index=${1}
#    Start UDP traffic    dl_throughput=${DL_TPUT_Send_A004}
#    Trigger intra HO for A002    filename=${A002_HO}
#    Run Keyword if    '${tl.gnbs[0].instance_id}' == '34411'
#    ...    Check DL TP    dl_expect_throughput=${expect_dl_tput_A002_trunk}    cellid=${2}    gnb_index=${0}    duration=20s
#    ...    ELSE IF    '${tl.gnbs[0].instance_id}' == '34111'
#    ...    Check DL TP    dl_expect_throughput=${expect_dl_tput_A002}    cellid=${2}    gnb_index=${0}    duration=20s
#    ...    ELSE    Check DL TP    dl_expect_throughput=${expect_dl_tput_A002}    cellid=${1}    gnb_index=${0}    duration=20s
#    UE detach and stop traffic
#    Wait until keyword succeeds    5 min    20s    Check Counter for A002_01
#    Check HO process for intragNB    log_name=${A002_HO}
#    Common Case TestLine Setup    ModifySCF_Aftercommission=True
#    ...    Modify_Para_Online=${PARAMS_TO_actLostPduFastRetx_false}
#    ...    Delete_Para_Online=${PARAMS_TO_delete_nsaDrbParam}    Add_Para_Online=${PARAMS_TO_add_nsaDrbParam1}
#    Run Keyword if    '${tl.gnbs[0].instance_id}' == '24211'    Adjust gNB_RU Attenuation    gnb1_cell2_value=${0}    enb_cell1_value=${0}
#    ...    ELSE    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    enb_cell1_value=${0}
#    Wait until keyword succeeds    3X    10s    Attach and check power UE    ue_type=${ue_type}    4G_check=true    ue_index=${1}
#    Start UDP traffic    dl_throughput=${DL_TPUT_Send_A004}
#    Trigger intra HO for A002    filename=${A002_HO_02}
#    Run Keyword if    '${tl.gnbs[0].instance_id}' == '34411'
#    ...    Check DL TP    dl_expect_throughput=${expect_dl_tput_A002_trunk}    cellid=${2}    gnb_index=${0}    duration=20s
#    ...    ELSE IF    '${tl.gnbs[0].instance_id}' == '34111'
#    ...    Check DL TP    dl_expect_throughput=${expect_dl_tput_A002}    cellid=${2}    gnb_index=${0}    duration=20s
#    ...    ELSE    Check DL TP    dl_expect_throughput=${expect_dl_tput_A002}    cellid=${1}    gnb_index=${0}    duration=20s
#    UE detach and stop traffic
#    Wait until keyword succeeds    5 min    20s    Check Counter for A002_02
#    Check HO process for intragNB    log_name=${A002_HO_02}
#    [Teardown]     Run keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error    UE detach and stop traffic    AND
#    ...    Check hanging resource for gnb    gnb_ips=@{gnb_ips}     AND
#    ...    Run Keyword And Ignore Error    Recover eNB defaultLnRelGnbCellId value    AND
#    ...    Run Keyword And Ignore Error    Test recover

[1]5GC001354_5G_A_003_Retransmission_of_lost_duplicated_PDU_over_X2-U_interface_with_NSA_classicalFR1_nokiaENB_FDD_non_GBR_DRB_UDP
    [Documentation]
    [Tags]    CRT_TRUNK    5GC001354-A    CRT_23R1
    [Setup]    robot_common_operations.Common Case Setup
    [Timeout]    2 hour
    Get gnb release info
    SCF load and commission
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    get_release_check_result
    power_ue.Prepare UE     ue_type=${ue_type}
    Run Keyword if    '${release_info}' == '${branch}[3]'
    ...    Common Case TestLine Setup    ModifySCF_Aftercommission=True    Modify_Para_Online=${Modify_Para_Online_A003}
    ...    Add_Para_Online=${PARAMS_TO_Para_Online_A003_002}
    ...    ELSE    Common Case TestLine Setup    ModifySCF_Aftercommission=True    Modify_Para_Online=${Modify_Para_Online_A003_trunk}
    ...    Add_Para_Online=${PARAMS_TO_Para_Online_A003_002_trunk}
    Wait until keyword succeeds    4x   10s    Check A_003 test case result status
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    robot_common_operations.Common Case Teardown    AND
    ...    Run Keyword And Ignore Error    Snapshot Save    AND
    ...    Run Keyword And Ignore Error    Detach and Stop traffic to UE and ENB    AND
    ...    Run Keyword And Ignore Error    Test recover    AND
    ...    Run Keyword And Ignore Error     SCF recover and commission

#[1]5GC001354_5G_A_004_Retransmission_based_on_FC_of_lost_PDCP_PDUs_over_X2-U_interface_with_NSA_classicalFR1_nokiaENB_TDD_non_GBR_DRB_TCP
#    [Documentation]
#    [Tags]    CRT_TRUNK    5GC001354-A    CRT_23R1
#    [Setup]    robot_common_operations.Common Case Setup
#    [Timeout]    2 hour
#    power_ue.Prepare UE     ue_type=${ue_type}
#    Common Case TestLine Setup    ModifySCF_Aftercommission=True    Modify_Para_Online=${Modify_Para_Online_A004}
#    ...    Add_Para_Online=${Modify_Para_Online_A004_002}
#    UE attach and check
#    Prepare with PM counter time to caculate    period=start
#    Start TCP traffic    dl_throughput=${DL_TPUT_Send_A004}    time=${time_A005}
#    Start traffic to ENB    time=${time}
#    Prepare with PM counter time to caculate    period=end
#    sleep    90s
#    Run Keyword And Continue On Failure    Check Counter for A004_01
#    ${DL_TPUT_LostPdu_true}=    Get average DL through    gnb_index=${0}    dl_expect_throughput_true=${expect_dl_tput_A004}
#    Detach and Stop traffic to UE and ENB    protocol=tcp
#    Snapshot Save
#    Common Case TestLine Setup    ModifySCF_Aftercommission=True
#    ...    Modify_Para_Online=${PARAMS_TO_actLostPduFastRetx_false}
#    ...    Delete_Para_Online=${PARAMS_TO_delete_nsaDrbParam}    Add_Para_Online=${PARAMS_TO_add_nsaDrbParam3}
#    UE attach and check
#    Prepare with PM counter time to caculate    period=start
#    Start TCP traffic    dl_throughput=${DL_TPUT_Send_A004}    time=${time_A005}
#    Start traffic to ENB    time=${time}
#    Prepare with PM counter time to caculate    period=end
#    sleep    90s
#    Run Keyword And Continue On Failure    Check Counter for A004_02
#    ${DL_TPUT_LostPdu_false}=    Get average DL through    gnb_index=${0}    dl_expect_throughput_true=${expect_dl_tput_A004_2}
#    Detach and Stop traffic to UE and ENB    protocol=tcp
#    Should Be True    ${DL_TPUT_LostPdu_true} > ${DL_TPUT_LostPdu_false}-5
#    [Teardown]    Run keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error    Detach and Stop traffic to UE and ENB    protocol=tcp    AND
#    ...    Run Keyword And Ignore Error    Test recover    AND
#    ...    Check hanging resource for gnb    gnb_ips=@{gnb_ips}     AND
#    ...    Run Keyword And Ignore Error     Common Case TestLine Setup    ModifySCF_Aftercommission=True
#    ...    Modify_Para_Online=${PARAMS_TO_actLostPduFastRetx_false}
#    ...    Delete_Para_Online=${PARAMS_TO_delete_nsaDrbParam}    Add_Para_Online=${PARAMS_TO_add_nsaDrbParam4}

#[1]5GC001354_5G_A_005_Duplicate_transmission_of_PDCP_PDU_for_DDDS_handling_during_PDCP_SN_rollover_over_X2-U_interface_with_UDP
#    [Documentation]
#    [Tags]    5GC001354-A    CRT_23R1
#    [Setup]    robot_common_operations.Common Case Setup
#    [Timeout]    2 hour
#    power_ue.Prepare UE     ue_type=${ue_type}
#    Common Case TestLine Setup    ModifySCF_Aftercommission=True    Modify_Para_Online=${Modify_Para_Online_A005}
#    UE attach and check
#    Prepare with PM counter time to caculate    period=start
#    Start UDP traffic    dl_throughput=${DL_TPUT_Send_A005}    time=${time_A005}
#    Run Keyword if    '${tl.gnbs[0].instance_id}' == '34111'
#    ...    Check DL TP    dl_expect_throughput=${expect_dl_tput_A005}    cellid=${2}    gnb_index=${0}    duration=60s
#    ...    ELSE    Check DL TP    dl_expect_throughput=${expect_dl_tput_A005}    cellid=${1}    gnb_index=${0}    duration=60s
#    ${M55355C04007}    ${M55355C05007}=    Wait until keyword succeeds    3 min    20s    Check Counter for A005_01
#    Power UE stop dl traffic and detach    ue_index=${1}
#    Common Case TestLine Setup    ModifySCF_Aftercommission=True    Modify_Para_Online=${Modify_Para_actX2DuplicateTxNSA3x_true}
#        ...    Add_Para_Online=${PARAMS_TO_Para_Online_A005_X2PdcpDuplication}
#    UE attach and check
#    Prepare with PM counter time to caculate    period=start
#    Start UDP traffic    dl_throughput=${DL_TPUT_Send_A005}    time=${time_A005}
#    Run Keyword if    '${tl.gnbs[0].instance_id}' == '34111'
#    ...    Check DL TP    dl_expect_throughput=${expect_dl_tput_A005}    cellid=${2}    gnb_index=${0}    duration=60s
#    ...    ELSE    Check DL TP    dl_expect_throughput=${expect_dl_tput_A005}    cellid=${1}    gnb_index=${0}    duration=60s
#    Prepare with PM counter time to caculate    period=start
#    sleep    90s
#    Run Keyword And Continue On Failure    Check Counter for A005_02
#    ...    M55355C04007_actX2DuplicateTxNSA3x_false=${M55355C04007}
#    ...    M55355C05007_actX2DuplicateTxNSA3x_false=${M55355C05007}
#    Power UE stop dl traffic and detach    ue_index=${1}
#    [Teardown]    Run keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error    Power UE stop dl traffic and detach    ue_index=${1}    AND
#    ...    Run Keyword And Ignore Error    Test recover    AND
#    ...    Check hanging resource for gnb    gnb_ips=@{gnb_ips}

[1]E2E_5GC001354_5G_A_003_Retransmission_of_lost_duplicated_PDU_over_X2-U_interface_with_NSA_classicalFR1_nokiaENB_FDD
    [Documentation]
    [Tags]    CRT_TRUNK    5GC001354-A    CRT_23R1
    [Setup]    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    [Timeout]    2 hour
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Sleep    10s
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    Snapshot Save    AND
    ...    Run Keyword And Ignore Error    robot_common_operations.Common Case Teardown

[1]E2E_5GC001354_5G_C_002_DelayThresh1Enabled_PDCP Delay Threshold based PDU retransmission_over_X2-U_with_NSA_TDD
    [Documentation]
    [Tags]    CRT_TRUNK    5GC001354-C    CRT_23R1
    [Setup]    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    [Timeout]    2 hour
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Sleep    10s
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    Snapshot Save    AND
    ...    Run Keyword And Ignore Error    robot_common_operations.Common Case Teardown

[1]E2E_CB007835_5G_A_004_SA_intergnb_intrafre_TDD_HO_TDD_704_stability
    [Documentation]
    [Tags]    CRT_26R1    CB007835
    [Setup]    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    [Timeout]    2 hour
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Sleep    10s
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    Snapshot Save    AND
    ...    Run Keyword And Ignore Error    robot_common_operations.Common Case Teardown

[1]CB007835_5G_A_007_SA_intragnb_intrafre_FDD_HO_FDD_784_EC_call
    [Documentation]    (case 2 and case 3 already cover)
    [Timeout]    1 hour
    [Tags]    classical    CRT_23R3    CRT_23R2    CRT_TRUNK    CRT_22R4    CRT_23R4
    [Setup]
    Run Keyword And Ignore Error    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    sleep    20s
    [Teardown]    Run Keyword And Ignore Error    robot_common_operations.Common Case Teardown

*** Keywords ***
SCF load and commission
   Run Keyword if    '${release_info}' == '${branch}[2]' or '${release_info}' == '${branch}[0]'
   ...   Common Case TestLine Setup    ModifySCF_Beforecommission=True    scf_path=${scf_path}
   ...   golden_scf_name=${gnb_scf_${release_info}}    ParamterToModify=${Modify_Para_counter}
   ...   ELSE    Common Case TestLine Setup    ModifySCF_Beforecommission=True    scf_path=${scf_path}
   ...   golden_scf_name=${golden_scf_name}    ParamterToModify=${Modify_Para_counter}

SCF recover and commission
    Run Keyword if    '${release_info}' == '${branch}[2]' or '${release_info}' == '${branch}[0]'
    ...    Common Case TestLine Setup    is_commission=True
    ...    golden_scf_name=${golden_scf_24R1}    scf_path=${scf_path}
    ...    ELSE    Common Case TestLine Setup    is_commission=True
    ...    golden_scf_name=${golden_scf_name}    scf_path=${scf_path}

Attach UE and start trffice to UE
    [Arguments]    ${DL_TPUT_Send}=800M
    wait until keyword succeeds    3X    10s    Attach and check power UE     ue_type=${ue_type}    4G_check=true
    Power UE Start DL traffic    dl_throughput=${DL_TPUT_Send}    duration=${time}
    sleep    10s

Attach UE and start trffice to UE and ENB
    [Arguments]    ${DL_TPUT_Send}=800M
    wait until keyword succeeds    3X    10s    Attach and check power UE     ue_type=${ue_type}    4G_check=true
    Power UE Start DL traffic    dl_throughput=${DL_TPUT_Send}    duration=${time}    protocol=${protocol_TCP}
    Start traffic to ENB    traffic=${ENB_traffic}    time=${time}    traffic_port=${ENB_traffic_port}
    sleep    10s

Set actLostPduFastRetx as false
    Run Keyword IF    '${gnb_instance}' == '${gnb_id[0]}'
    ...    Common Case TestLine Setup    ModifySCF_Aftercommission=True
    ...    Modify_Para_Online=${PARAMS_TO_actLostPduFastRetx_false}
    ...    Delete_Para_Online=${PARAMS_TO_delete_nsaDrbParam}    Add_Para_Online=${PARAMS_TO_add_nsaDrbParam_trunk}
    ...    ELSE    Common Case TestLine Setup    ModifySCF_Aftercommission=True
    ...    Modify_Para_Online=${PARAMS_TO_actLostPduFastRetx_false}
    ...    Delete_Para_Online=${PARAMS_TO_delete_nsaDrbParam}    Add_Para_Online=${PARAMS_TO_add_nsaDrbParam}

Detach and Stop traffic to UE and ENB
    [Arguments]    ${protocol}=udp
    Stop traffic to ENB
    Power UE stop dl traffic and detach    ue_index=${1}    protocol=${protocol}

Unlock AMF
    Modify parameters online for cases    parameters_to_update=${PARAMETERS_TO_UPDATE_AMF}      WEBUI_COAM=${WEBUI_COAM}

Test recover
    Run Keyword And Ignore Error    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${DL_PORT}

Check counter for A001_01
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_A001}    dic_path=${counter_dic_path_A001}
    ${M55313C04007_LOST_NUM}    Set Variable    ${counter_value_list[0]}
    ${M55355C02007_RETX_NUM}    Set Variable    ${counter_value_list[1]}
    ${M55355C03007_RETX_VOL}    Set Variable    ${counter_value_list[2]}
    ${M55354C02007_F1U_RETX_NUM}    Set Variable    ${counter_value_list[3]}
    ${M55354C03007_F1U_RETX_VOL}    Set Variable    ${counter_value_list[4]}
    Should Be True    300000 > ${M55313C04007_LOST_NUM} > 0
    Should Be True    ${M55313C04007_LOST_NUM} >= ${M55355C02007_RETX_NUM}+${M55354C02007_F1U_RETX_NUM}
    ${LOST_RETX_DIFF}    Evaluate    ${M55313C04007_LOST_NUM}*0.95
    Should Be True    ${LOST_RETX_DIFF} < ${M55355C02007_RETX_NUM}+${M55354C02007_F1U_RETX_NUM}
    Should Be True    6000 > ${M55354C02007_F1U_RETX_NUM} >= 0
    Should Be True    6000 > ${M55354C03007_F1U_RETX_VOL} >= 0
    [Teardown]    COAM Teardown gnb connections

Check counter for A001_02
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_A001}    dic_path=${counter_dic_path_A001}
    ${M55313C04007_LOST_NUM}    Set Variable    ${counter_value_list[0]}
    ${M55355C02007_RETX_NUM}    Set Variable    ${counter_value_list[1]}
    ${M55355C03007_RETX_VOL}    Set Variable    ${counter_value_list[2]}
    ${M55354C02007_F1U_RETX_NUM}    Set Variable    ${counter_value_list[3]}
    ${M55354C03007_F1U_RETX_VOL}    Set Variable    ${counter_value_list[4]}
    Should Be True    20000000 > ${M55313C04007_LOST_NUM} > 0
    Should Be True    ${M55355C02007_RETX_NUM} == 0
    Should Be True    ${M55355C03007_RETX_VOL} == 0
    Should Be True    ${M55354C02007_F1U_RETX_NUM} == 0
    Should Be True    ${M55354C03007_F1U_RETX_VOL} == 0
    [Teardown]    COAM Teardown gnb connections

Check Counter for A002_01
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_A002}    dic_path=${counter_dic_path_A002}
    ${M55354C00007_retransmitted_F1-U_NUM}    Set Variable    ${counter_value_list}[0]
    ${M55354C01007_retransmitted_F1-U_volume}    Set Variable    ${counter_value_list}[1]
    ${M55355C00007_retransmitted_X2-U_NUM}    Set Variable    ${counter_value_list}[2]
    ${M55355C01007_retransmitted_X2-U_volume}    Set Variable    ${counter_value_list}[3]
    Should Be True    7000 > ${M55354C00007_retransmitted_F1-U_NUM} > 10
    Should Be True    7000 > ${M55354C01007_retransmitted_F1-U_volume} > 10
    Should Be True    1000 > ${M55355C00007_retransmitted_X2-U_NUM} > 100
    Should Be True    1000 > ${M55355C01007_retransmitted_X2-U_volume} > 100
    [Teardown]    COAM Teardown gnb connections

Check Counter for A002_02
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_A002}    dic_path=${counter_dic_path_A002}
    ${M55354C00007_retransmitted_F1-U_NUM}    Set Variable    ${counter_value_list}[0]
    ${M55354C01007_retransmitted_F1-U_volume}    Set Variable    ${counter_value_list}[1]
    ${M55355C00007_retransmitted_X2-U_NUM}    Set Variable    ${counter_value_list}[2]
    ${M55355C01007_retransmitted_X2-U_volume}    Set Variable    ${counter_value_list}[3]
    Should Be True    6000 > ${M55354C00007_retransmitted_F1-U_NUM} > 0
    Should Be True    6000 > ${M55354C01007_retransmitted_F1-U_volume} > 0
    Should Be True    ${M55355C00007_retransmitted_X2-U_NUM} == 0
    Should Be True    ${M55355C01007_retransmitted_X2-U_volume} == 0
    [Teardown]    COAM Teardown gnb connections

Check Counter for A003 for trunk
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_A003}    dic_path=${counter_dic_path_A003}
    ${M55355C04007_duplication_X2-U_NUM}    Set Variable    ${counter_value_list}[0]
    ${M55355C05007_duplication_X2-U_volume}    Set Variable    ${counter_value_list}[1]
    ${M55354C02007_retransmitted_F1-U}    Set Variable    ${counter_value_list}[2]
    ${M55355C02007_retransmitted_X2-U}    Set Variable    ${counter_value_list}[3]
    ${M55313C08007_data_X2-U_volume}    Set Variable    ${counter_value_list}[4]
    ${M55313C04007_duplication_lost_X2-U}    Set Variable    ${counter_value_list}[5]
    ${M55314C02007_data_F1-U}    Set Variable    ${counter_value_list}[6]
    ${M55313C13007_data_X2-U_NUM}    Set Variable    ${counter_value_list}[7]
    ${M55323C04007_lost_F1-U}    Set Variable    ${counter_value_list}[8]
    ${M55311C46007_discarded}     Set Variable    ${counter_value_list}[9]
    ${M55313C09007_data_during_initial}    Set Variable    ${counter_value_list}[10]
    ${M55311C47007_discarded_VOL}    Set Variable    ${counter_value_list}[11]
    Should Be True    4000 < ${M55355C04007_duplication_X2-U_NUM} < 100000
    Should Be True    4000 < ${M55355C05007_duplication_X2-U_volume} < 100000
    Should Be True    4000 < ${M55313C08007_data_X2-U_volume} < 80000
    Should Be True    4000 < ${M55313C13007_data_X2-U_NUM} < 80000
#    Should Be True    ${M55355C04007_duplication_X2-U_NUM} == ${M55313C13007_data_X2-U_NUM}
#    Should Be True    ${M55355C05007_duplication_X2-U_volume} == ${M55313C08007_data_X2-U_volume}
    Should Be True    ${M55311C46007_discarded} == 0
    Should Be True    ${M55354C02007_retransmitted_F1-U} == 0
    Should Be True    ${M55355C02007_retransmitted_X2-U} == 0
    Should Be True    0 < ${M55313C04007_duplication_lost_X2-U} < 10000
    Should Be True    2000000 < ${M55314C02007_data_F1-U}  < 8000000
    Should Be True    ${M55323C04007_lost_F1-U} == 0
    Should Be True    ${M55311C46007_discarded} == 0
    Should Be True    ${M55311C47007_discarded_VOL} == 0
    Should Be True    ${M55313C09007_data_during_initial} == 0
    [Teardown]    COAM Teardown gnb connections

Check Counter for A003
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_A003}    dic_path=${counter_dic_path_A003_branch}
    ${M55355C04007_duplication_X2-U_NUM}    Set Variable    ${counter_value_list}[0]
    ${M55355C05007_duplication_X2-U_volume}    Set Variable    ${counter_value_list}[1]
    ${M55354C02007_retransmitted_F1-U}    Set Variable    ${counter_value_list}[2]
    ${M55355C02007_retransmitted_X2-U}    Set Variable    ${counter_value_list}[3]
    ${M55313C08007_data_X2-U_volume}    Set Variable    ${counter_value_list}[4]
    ${M55313C04007_duplication_lost_X2-U}    Set Variable    ${counter_value_list}[5]
    ${M55314C02007_data_F1-U}    Set Variable    ${counter_value_list}[6]
    ${M55313C13007_data_X2-U_NUM}    Set Variable    ${counter_value_list}[7]
    ${M55323C04007_lost_F1-U}    Set Variable    ${counter_value_list}[8]
    ${M55311C46007_discarded}     Set Variable    ${counter_value_list}[9]
    ${M55313C09007_data_during_initial}    Set Variable    ${counter_value_list}[10]
    ${M55311C47007_discarded_VOL}    Set Variable    ${counter_value_list}[11]
    Should Be True    7000 < ${M55355C04007_duplication_X2-U_NUM} < 80000
    Should Be True    7000 < ${M55355C05007_duplication_X2-U_volume} < 80000
    Should Be True    ${M55354C02007_retransmitted_F1-U} == 0
    Should Be True    ${M55355C02007_retransmitted_X2-U} == 0
    [Teardown]    COAM Teardown gnb connections

Check Counter for A004_01
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_A004}    dic_path=${counter_dic_path_A004}
    ${M55323C04007_lost_F1-U}    Set Variable    ${counter_value_list}[0]
    ${M55314C02007_received_F1-U}    Set Variable    ${counter_value_list}[1]
    ${M55313C04007_lost_X2-U}    Set Variable    ${counter_value_list}[2]
    ${M55313C08007_X2-U_SNT_volume}    Set Variable    ${counter_value_list}[3]
    ${M55313C13007_X2-U_SNT_NUM}    Set Variable    ${counter_value_list}[4]
    ${M55355C04007_duplication_X2-U_NUM}    Set Variable    ${counter_value_list}[5]
    ${M55355C05007_duplication_X2-U_volume}    Set Variable    ${counter_value_list}[6]
    ${M55354C02007_retransmitted_F1-U}    Set Variable    ${counter_value_list}[7]
    ${M55355C02007_retransmitted_X2-U}    Set Variable    ${counter_value_list}[8]
    Should Be True    ${M55323C04007_lost_F1-U} == 0
    Should Be True    250000000 > ${M55314C02007_received_F1-U} > 0
    Should Be True    200000 > ${M55313C04007_lost_X2-U} > 0
    Should Be True    500000 > ${M55313C08007_X2-U_SNT_volume} > 0
    Should Be True    500000 > ${M55313C13007_X2-U_SNT_NUM} > 0
    Should Be True    300 > ${M55355C04007_duplication_X2-U_NUM} >= 0
    Should Be True    300 > ${M55355C05007_duplication_X2-U_volume} >= 0
    Should Be True    200000 > ${M55354C02007_retransmitted_F1-U} > 0
    Should Be True    20000 > ${M55355C02007_retransmitted_X2-U} >= 0
    ${retransmitted_SUM}    Evaluate    ${M55354C02007_retransmitted_F1-U} + ${M55355C02007_retransmitted_X2-U}
    Should Be True    ${M55313C04007_lost_X2-U} >= ${retransmitted_SUM}
    ${LOST_RETX_DIFF}    Evaluate    ${M55313C04007_lost_X2-U}*0.95
    Should Be True    ${LOST_RETX_DIFF} < ${retransmitted_SUM}
    [Teardown]    COAM Teardown gnb connections

Check Counter for A004_02
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_A004}    dic_path=${counter_dic_path_A004}
    ${M55323C04007_lost_F1-U}    Set Variable    ${counter_value_list}[0]
    ${M55314C02007_received_F1-U}    Set Variable    ${counter_value_list}[1]
    ${M55313C04007_lost_X2-U}    Set Variable    ${counter_value_list}[2]
    ${M55313C08007_X2-U_GTP_volume}    Set Variable    ${counter_value_list}[3]
    ${M55313C08008_X2-U_GTP_NUM}    Set Variable    ${counter_value_list}[4]
    ${M55355C04007_duplication_X2-U_NUM}    Set Variable    ${counter_value_list}[5]
    ${M55355C05007_duplication_X2-U_volume}    Set Variable    ${counter_value_list}[6]
    ${M55354C02007_retransmitted_F1-U}    Set Variable    ${counter_value_list}[7]
    ${M55355C02007_retransmitted_X2-U}    Set Variable    ${counter_value_list}[8]
    Should Be True    ${M55323C04007_lost_F1-U} == 0
    Should Be True    25000000 > ${M55314C02007_received_F1-U} > 0
    Should Be True    200000 > ${M55313C04007_lost_X2-U} > 0
    Should Be True    200000 > ${M55313C08007_X2-U_GTP_volume} > 0
    Should Be True    200000 > ${M55313C08008_X2-U_GTP_NUM} > 0
    Should Be True    300 > ${M55355C04007_duplication_X2-U_NUM} >= 0
    Should Be True    300 > ${M55355C05007_duplication_X2-U_volume} >= 0
    Should Be True    ${M55354C02007_retransmitted_F1-U} == 0
    Should Be True    ${M55355C02007_retransmitted_X2-U} == 0
    [Teardown]    COAM Teardown gnb connections

Check Counter for A005_01
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_A005}    dic_path=${counter_dic_path_A005}
    ${M55313C00007_FED_RCV_NUM}    Set Variable    ${counter_value_list}[0]
    ${M55313C04007_lost_X2-U}    Set Variable    ${counter_value_list}[1]
    ${M55355C04007_duplication_X2-U_NUM}    Set Variable    ${counter_value_list}[2]
    ${M55355C05007_duplication_X2-U_volume}    Set Variable    ${counter_value_list}[3]
    Should Be True    ${M55313C00007_FED_RCV_NUM} == ${0}
    Should Be True    ${M55313C04007_lost_X2-U} == ${0}
    Should Be True    50 < ${M55355C04007_duplication_X2-U_NUM} < 400
    Should Be True    50 < ${M55355C05007_duplication_X2-U_volume} < 400
    [Return]    ${M55355C04007_duplication_X2-U_NUM}    ${M55355C05007_duplication_X2-U_volume}
    [Teardown]    COAM Teardown gnb connections

Check Counter for A005_02
    [Arguments]    ${M55355C04007_actX2DuplicateTxNSA3x_false}    ${M55355C05007_actX2DuplicateTxNSA3x_false}
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_A005}    dic_path=${counter_dic_path_A005}
    ${M55355C04007_duplication_X2-U_NUM_actX2DuplicateTxNSA3x_true}    Set Variable    ${counter_value_list}[2]
    ${M55355C05007_duplication_X2-U_volume_actX2DuplicateTxNSA3x_true}    Set Variable    ${counter_value_list}[3]
    Should Be True    50 < ${M55355C04007_duplication_X2-U_NUM_actX2DuplicateTxNSA3x_true} < 400
    Should Be True    50 < ${M55355C05007_duplication_X2-U_volume_actX2DuplicateTxNSA3x_true} < 400
    Should Be True    ${M55355C04007_duplication_X2-U_NUM_actX2DuplicateTxNSA3x_true} >= ${M55355C04007_actX2DuplicateTxNSA3x_false}
    Should Be True    ${M55355C05007_duplication_X2-U_volume_actX2DuplicateTxNSA3x_true} >= ${M55355C05007_actX2DuplicateTxNSA3x_false}-3
    [Teardown]    COAM Teardown gnb connections

Recover eNB defaultLnRelGnbCellId value
    Run Keyword if    '${tl.gnbs[0].instance_id}' == '34111'    Modify the enblte parameter    dist_name=${enb_dist_name}
    ...     parameter=${enb_para}   value=${enb_value}[1]     ELSE IF    '${tl.gnbs[0].instance_id}' == '24211'
    ...     Modify the enblte parameter    dist_name=${enb_dist_name}    parameter=${enb_para}   value=${enb_value}[3]

Check A_003 test case result status
    Start capture gNB log on master    filename=${A003_gnb}
    UE attach and check
    Prepare with PM counter time to caculate    period=start
    Start UDP traffic    dl_throughput=${DL_TPUT_Send_A003}
    Start traffic to ENB    time=${time}
    Stop and download the Logs    filename=${A003_gnb}
    Run Keyword IF    '${gnb_instance}' == '${gnb_id[1]}'
    ...    Check DL TP    dl_expect_throughput=${expect_dl_tput_A003}    cellid=${2}    gnb_index=${0}
    ...    ELSE    Check DL TP    dl_expect_throughput=${expect_dl_tput_A003}    cellid=${1}    gnb_index=${0}
    Detach and Stop traffic to UE and ENB
    Run Keyword If    '${check_result}' != 'True'
    ...    Wait until keyword succeeds    5 min    10s    Check Counter for A003    ELSE
    ...    Wait until keyword succeeds    5 min    10s    Check Counter for A003 for trunk

Trigger intra HO for A002
    [Arguments]    ${filename}
    Start to collect the log on eNB    log_name=${filename}
    Prepare with PM counter time to caculate    period=start
    Run Keyword if    '${tl.gnbs[0].instance_id}' == '24211'   Run Keywords
    ...    Adjust gNB_RU Attenuation    gnb1_cell1_value=${35}    gnb1_cell2_value=${35}    enb_cell1_value=${0}    AND
    ...    Adjust gNB_RU Attenuation    gnb1_cell1_value=${15}    gnb1_cell2_value=${35}    enb_cell1_value=${0}    AND
    ...    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb1_cell2_value=${125}    enb_cell1_value=${0}
    ...    ELSE   Run Keywords
    ...    Adjust gNB_RU Attenuation    gnb1_cell1_value=${15}    gnb1_cell2_value=${10}    enb_cell1_value=${0}    AND
    ...    Adjust gNB_RU Attenuation    gnb1_cell1_value=${35}    gnb1_cell2_value=${5}    enb_cell1_value=${0}    AND
    ...    Adjust gNB_RU Attenuation    gnb1_cell1_value=${127}    gnb1_cell2_value=${0}    enb_cell1_value=${0}
    Stop and download Logs on eNB    log_name=${filename}
    Sleep    10s
