*** Settings ***
Documentation     author: qingqing.zhang
...                 contact:qingqing.zhang@nokia-sbell.com
...                 squad group: SG_03
...                 feature : 5GC001354


Resource     ./../Resources/5GC001354_common_keyword.robot
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001354/Resources/variables.py

Suite Setup    Run Keywords
...            robot_common_operations.Common Suite Setup    AND
...            Run Keyword And Ignore Error    Common Suite Setup for COAM    AND
...            Common Case TestLine Setup    ModifySCF_Beforecommission=True    scf_path=${scf_path}
...            golden_scf_name=${golden_scf_name}    ParamterToModify=${Modify_Para_counter}

Suite Teardown    Run Keywords
...               robot_common_operations.Common Suite Teardown    AND
...               Adjust gNB_RU Attenuation    AND
...               Run Keyword And Ignore Error     Common Suite Teardown for COAM    gnb_index=${gnb_index}    AND
...               Common Case TestLine Setup    is_commission=True
...               golden_scf_name=${golden_scf_name}    scf_path=${scf_path}

*** Variables ***
${enb_golden_scf}     eNB_SCF_FGCR_8315.xml
${protocol_TCP}    tcp
${protocol_UDP}    udp
${scf_path}    /opt/workspace/CRT/Master/SCF_file/
${golden_scf_name}    golden_TDD.xml
${golden_scf_name_gnb2}    golden_FDD.xml
${A002_HO}    A002_intra_HO.pcap
${A002_HO_02}    A002_intra_HO2.pcap
${ENB_traffic_34411}    955M
${ENB_traffic_34111}    939M
${ENB_traffic_24211}    895M
${ENB_traffic_C003_34411}    950M
${ENB_traffic_C003_34111}    940M
${ENB_traffic_C003_24211}    930M
${ENB_traffic_port_34411}    35345
${ENB_traffic_port_34111}    35342
${ENB_traffic_port_24211}    35243
${enb_addr}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${time}    600s
${time_C002}    6000
${time_A05}    180s
${expect_dl_tput_C001}    400
${DL_TPUT_Send_small}    400M
${expect_dl_tput_C001_2}    400
${expect_dl_tput_C003}    800
${DL_TPUT_Send_big}    1200M
${expect_dl_tput_C002}    600
${expect_dl_tput_C002_2}    500
${expect_dl_tput_enb}    10
${seg_size}    1280
${window}    410K
${process_num}    16
@{ALLOWED_FAULT}    61652    61524    61649    9000    4592    4527    1932    4334    61074    61618    4687    4655    4654    6450
${crash_alarm_id}    4383
@{allow_fault_list}    7523    7107    7311
*** Test Cases ***
[1]5GC001354_5G_C_001_DelayThresh1and2Enabled_PDCP_Delay_Threshold_based_PDU_retransmission_over_X2-U_with_NSA_FDD_non_GBR_DRB_UDP
    [Documentation]
    [Tags]    5GC001354-C    CRT_23R1
    [Setup]    robot_common_operations.Common Case Setup
    [Timeout]    2 hours
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Power_ue.Prepare UE     ue_type=${ue_type}
    Common Case TestLine Setup    ModifySCF_Aftercommission=True    Modify_Para_Online=${Modify_Para_Online_C001}
    ...    Add_Para_Online=${PARAMS_TO_Para_Online_C001_002}
    UE attach and check
    Prepare with PM counter time to caculate    period=start
    Start UDP traffic    dl_throughput=${DL_TPUT_Send_small}
    Run Keyword IF    '${gnb_instance}' == '${gnb_id[1]}'
    ...    Check DL TP    dl_expect_throughput=${expect_dl_tput_C001}    cellid=${2}    gnb_index=${0}    duration=180s
    ...    ELSE    Check DL TP    dl_expect_throughput=${expect_dl_tput_C001}    cellid=${1}    gnb_index=${0}    duration=180s
    Power UE stop dl traffic and detach    ue_index=${1}
    Wait until keyword succeeds    5 min    20s    Check Counter for C001
    Run Keyword IF    '${gnb_instance}' == '${gnb_id[1]}'
    ...    Adjust gNB_RU Attenuation    gnb1_cell2_value=${25}    enb_cell1_value=${5}
    ...    ELSE    Adjust gNB_RU Attenuation    gnb1_cell1_value=${40}    enb_cell1_value=${5}
    Attach and check power UE    ue_type=${ue_type}    4G_check=true    ue_index=${1}
    Prepare with PM counter time to caculate    period=start
    Start UDP traffic    dl_throughput=${DL_TPUT_Send_big}
    Run Keyword IF    '${gnb_instance}' == '${gnb_id[1]}'
    ...    Check DL TP    dl_expect_throughput=${expect_dl_tput_C001_2}    cellid=${2}    gnb_index=${0}    duration=180s
    ...    ELSE    Check DL TP    dl_expect_throughput=${expect_dl_tput_C001_2}    cellid=${1}    gnb_index=${0}    duration=180s
    Power UE stop dl traffic and detach    ue_index=${1}
    Wait until keyword succeeds    5 min    20s    Check Counter for C001_2
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    robot_common_operations.Common Case Teardown    AND
    ...    Run Keyword And Ignore Error    Power UE stop dl traffic and detach    ue_index=${1}    AND
#    ...    Check hanging resource for gnb    gnb_ips=@{gnb_ips}     AND
    ...    Run Keyword And Ignore Error    Test recover

[1]5GC001354_5G_C_002_DelayThresh1Enabled_PDCP Delay Threshold based PDU retransmission_over_X2-U_with_NSA_TDD_non_GBR_DRB_TCP_Long_DRX
    [Documentation]
    [Tags]    CRT_TRUNK    5GC001354-C    CRT_23R1
    [Setup]    robot_common_operations.Common Case Setup
    [Timeout]    2 hour
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Power_ue.Prepare UE     ue_type=${ue_type}
    Common Case TestLine Setup    ModifySCF_Aftercommission=True    Modify_Para_Online=${Modify_Para_Online_C002_trunk}
    ...    Add_Para_Online=${PARAMS_TO_Para_Online_C002_002_trunk}    Delete_Para_Online=${PARAMS_TO_delete_pdcpPduRetxDelayThresh2}
    UE attach and check
    Prepare with PM counter time to caculate    period=start
    Start TCP traffic    dl_throughput=${DL_TPUT_Send_big}
    Run Keyword IF    '${gnb_instance}' == '${gnb_id[1]}'
    ...    Check DL TP    dl_expect_throughput=${expect_dl_tput_C002}    cellid=${2}    gnb_index=${0}    duration=180s
    ...    ELSE    Check DL TP    dl_expect_throughput=${expect_dl_tput_C002}    cellid=${1}    gnb_index=${0}    duration=180s
    Power UE stop dl traffic and detach    ue_index=${1}    protocol=tcp
    Run Keyword And Continue On Failure    Wait until keyword succeeds    5 min    20s    Check Counter for C002
    UE attach and check
    Prepare with PM counter time to caculate    period=start
    Start UDP traffic    dl_throughput=${DL_TPUT_Send_big}    time=${time_C002}
    Start traffic to ENB    time=${time_C002}
    Run Keyword IF    '${gnb_instance}' == '${gnb_id[1]}'
    ...    Check DL TP    dl_expect_throughput=${expect_dl_tput_C002_2}    cellid=${2}    gnb_index=${0}    duration=180s
    ...    ELSE    Check DL TP    dl_expect_throughput=${expect_dl_tput_C002_2}    cellid=${1}    gnb_index=${0}    duration=180s
    FOR    ${index}    IN RANGE    3
        Wait until keyword succeeds    5 min    20s    Check Counter for C002_2
        Check DL TP    dl_expect_throughput=${expect_dl_tput_C002_2}    cellid=${1}    gnb_index=${0}    duration=180s
    END
    Detach and Stop traffic to UE and ENB
    ${faultid_list_current}     Run keyword and continue on failure    Get Active Alarm List
    ${faultid_list_history}     Run keyword and continue on failure    Get history Alarm List
    should not contain    ${faultid_list_current}    ${crash_alarm_id}
    should not contain    ${faultid_list_history}    ${crash_alarm_id}
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    Detach and Stop traffic to UE and ENB    protocol=tcp    AND
#    ...    Check hanging resource for gnb    gnb_ips=@{gnb_ips}     AND
    ...    Run Keyword And Ignore Error    Snapshot Save    AND
    ...    Run Keyword And Ignore Error    robot_common_operations.Common Case Teardown   AND
    ...    Run Keyword And Ignore Error     Common Case TestLine Setup    ModifySCF_Aftercommission=True
    ...    Modify_Para_Online=${PARAMS_TO_actLostPduFastRetx_false}
    ...    Delete_Para_Online=${PARAMS_TO_delete_nsaDrbParam}    Add_Para_Online=${PARAMS_TO_add_nsaDrbParam}

#[1]5GC001354_5G_C_003_DelayThresh1and2Enabled_PDCP Delay Threshold based PDU retransmission_over_X2-U_with_NSA_TDD_non_GBR_DRB_TCP_throughput
#    [Documentation]
#    [Tags]    CRT_TRUNK    5GC001354-C    CRT_23R1
#    [Setup]    robot_common_operations.Common Case Setup
#    [Timeout]    2 hour
#    Power_ue.Prepare UE     ue_type=${ue_type}
#    Common Case TestLine Setup    ModifySCF_Aftercommission=True    Modify_Para_Online=${Modify_Para_Online_C003}
#    ...    Add_Para_Online=${PARAMS_TO_Para_Online_C003_002}
#    UE attach and check
#    Prepare with PM counter time to caculate    period=start
#    Start UDP traffic    dl_throughput=${DL_TPUT_Send_big}    time=${time_C002}
#    Start traffic to ENB    time=${time_C002}    traffic=${ENB_traffic_C003_${gnb_instance}}
#    Run Keyword IF    '${gnb_instance}' == '${gnb_id[1]}'
#    ...    Check DL TP    dl_expect_throughput=${expect_dl_tput_C003}    cellid=${2}    gnb_index=${0}    duration=180s
#    ...    ELSE    Check DL TP    dl_expect_throughput=${expect_dl_tput_C003}    cellid=${1}    gnb_index=${0}    duration=180s
#    Run Keyword And Continue On Failure    Wait until keyword succeeds    5 min    20s    Check Counter for C003
#    :FOR    ${index}    IN RANGE    1
#    \    Prepare with PM counter time to caculate    period=end
#    \    sleep    80s
#    \    Run Keyword And Continue On Failure    Wait until keyword succeeds    5 min    20s    Check Counter for C003
#    Run Keyword IF    '${gnb_instance}' == '${gnb_id[1]}'
#    ...    Check DL TP    dl_expect_throughput=${expect_dl_tput_C003}    cellid=${2}    gnb_index=${0}    duration=180s
#    ...    ELSE    Check DL TP    dl_expect_throughput=${expect_dl_tput_C003}    cellid=${1}    gnb_index=${0}    duration=180s
#    Detach and Stop traffic to UE and ENB
#    [Teardown]    Run keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error    Detach and Stop traffic to UE and ENB    AND
#    ...    Check hanging resource for gnb    gnb_ips=@{gnb_ips}     AND
#    ...    Run Keyword And Ignore Error    Test recover


*** Keywords ***
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

Detach and Stop traffic to UE and ENB
    [Arguments]    ${protocol}=udp    ${ue_index}=${1}
    Stop traffic to ENB
    Power UE stop dl traffic and detach    ue_index=${ue_index}    protocol=${protocol}

Unlock AMF
    Modify parameters online for cases    parameters_to_update=${PARAMETERS_TO_UPDATE_AMF}      WEBUI_COAM=${WEBUI_COAM}

Test recover
    Run Keyword And Ignore Error    Snapshot Save
    Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${DL_PORT}
	Run Keyword And Ignore Error    COAM Teardown gnb connections

Check Counter for C001
    Check Counter for 1354_C
    Should Be True    2000000000 > ${M55314C02007_PDU_receives_F1-U} > 0
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
    Should Be True    2000000 > ${M55354C06007_exceed_Threshold2_F1-U} > 0
    Should Be True    2000000 > ${M55354C07007_exceed_Threshold2_F1-U_VOL} > 0
    Should Be True    40000 > ${M55354C04007_exceed_Threshold1_F1-U} > 0
    Should Be True    40000 > ${M55354C05007_exceed_Threshold1_F1-U_VOL} > 0
    Should Be True    40000 > ${M55355C06007_exceed_Threshold1_X2-U} >= 0
    Should Be True    40000 > ${M55355C07007_exceed_Threshold1_X2-U_VOL} >= 0
    Should Be True    400000 > ${M55355C08007_exceed_Threshold2_X2-U} > 0
    Should Be True    400000 > ${M55355C09007_exceed_Threshold2_X2-U_VOL} > 0
    Should Be True    40000 > ${M55320C23007_not_retransmitted} >= 0
    Should Be True    300000 > ${M55311C46007_discarded} > 0
    Should Be True    300000 > ${M55311C47007_discarded_VOL} > 0
    ${exceed_Threshold1_F1U_AND_X2U}    Evaluate    ${M55355C06007_exceed_Threshold1_X2-U} + ${M55354C04007_exceed_Threshold1_F1-U}
    Should Be True    ${exceed_Threshold1_F1U_AND_X2U} >= ${exceed_Threshold1_SUM}
    ${exceed_Threshold2_F1U_AND_X2U}    Evaluate    ${M55354C06007_exceed_Threshold2_F1-U} + ${M55355C08007_exceed_Threshold2_X2-U}
    Should Be True    ${exceed_Threshold2_F1U_AND_X2U} >= ${exceed_Threshold2_SUM}

Check Counter for C002
    Check Counter for 1354_A and B
    Check Counter for 1354_C
    Should Be True    ${M55313C04007_LOST_NUM} == 0
    Should Be True    ${M55323C04007_lost_F1-U} == 0
    Should Be True    ${M55355C02007_RETX_NUM} == 0
    Should Be True    ${M55355C03007_RETX_VOL} == 0
    Should Be True    ${M55354C02007_F1U_RETX_NUM} == 0
    Should Be True    ${M55354C03007_F1U_RETX_VOL} == 0
    Should Be True    20  > ${M55355C04007_duplication_X2-U_NUM} >= 0
    Should Be True    20  > ${M55355C05007_duplication_X2-U_volume} >= 0
    Should Be True    20  > ${M55311C46007_discarded} >= 0
    Should Be True    20  > ${M55311C47007_discarded_VOL} >= 0
    Should Be True    ${M55354C06007_exceed_Threshold2_F1-U} == 0
    Should Be True    ${M55354C07007_exceed_Threshold2_F1-U_VOL} == 0
    Should Be True    ${M55355C08007_exceed_Threshold2_X2-U} == 0
    Should Be True    ${M55355C09007_exceed_Threshold2_X2-U_VOL} == 0
    Should Be True    1000000 > ${M55354C04007_exceed_Threshold1_F1-U} > 0
    Should Be True    1000000 > ${M55354C05007_exceed_Threshold1_F1-U_VOL} > 0
    Should Be True    1000000 > ${M55355C06007_exceed_Threshold1_X2-U} >= 0
    Should Be True    1000000 >${M55355C07007_exceed_Threshold1_X2-U_VOL} >= 0
    Should Be True    10000000 > ${M55320C23007_not_retransmitted} > 0
    Should Be True    ${exceed_Threshold2_SUM} == 0
    ${exceed_Threshold1_F1U_AND_X2U}    Evaluate    ${M55355C06007_exceed_Threshold1_X2-U} + ${M55354C04007_exceed_Threshold1_F1-U}
    Should Be True    ${exceed_Threshold1_F1U_AND_X2U} >= ${exceed_Threshold1_SUM}

Check Counter for C002_2
    Check Counter for 1354_A and B
    Check Counter for 1354_C
    Should Be True    480000 > ${M55313C04007_LOST_NUM} > 0
    Should Be True    480000 > ${M55355C02007_RETX_NUM} > 0
    Should Be True    ${M55313C04007_LOST_NUM} >= ${M55355C02007_RETX_NUM}
    Should Be True    480000 > ${M55355C03007_RETX_VOL} > 0
    Should Be True    ${M55323C04007_lost_F1-U} == 0
    Should Be True    450000 > ${M55354C02007_F1U_RETX_NUM} >= 0
    Should Be True    450000 > ${M55354C03007_F1U_RETX_VOL} >= 0
    Should Be True    2000 > ${M55355C04007_duplication_X2-U_NUM} >= 0
    Should Be True    2000 > ${M55355C05007_duplication_X2-U_volume} >= 0
    Should Be True    ${M55311C46007_discarded} == 0
    Should Be True    ${M55311C47007_discarded_VOL} == 0
    Should Be True    ${M55354C06007_exceed_Threshold2_F1-U} == 0
    Should Be True    ${M55354C07007_exceed_Threshold2_F1-U_VOL} == 0
    Should Be True    ${M55355C08007_exceed_Threshold2_X2-U} == 0
    Should Be True    ${M55355C09007_exceed_Threshold2_X2-U_VOL} == 0
    Should Be True    800000 > ${M55354C04007_exceed_Threshold1_F1-U} > 0
    Should Be True    800000 > ${M55354C05007_exceed_Threshold1_F1-U_VOL} > 0
    Should Be True    800000 > ${M55355C06007_exceed_Threshold1_X2-U} >= 0
    Should Be True    800000 > ${M55355C07007_exceed_Threshold1_X2-U_VOL} >= 0
    Should Be True    3200000 > ${M55320C23007_not_retransmitted} > 0
    Should Be True    ${exceed_Threshold2_SUM} == 0
    ${exceed_Threshold1_F1U_AND_X2U}    Evaluate    ${M55355C06007_exceed_Threshold1_X2-U} + ${M55354C04007_exceed_Threshold1_F1-U}
    Should Be True    ${exceed_Threshold1_F1U_AND_X2U} >= ${exceed_Threshold1_SUM}


Check Counter for C003
    Check Counter for 1354_A and B
    Check Counter for 1354_C
    Should Be True    60000 > ${M55354C04007_exceed_Threshold1_F1-U} > 0
    Should Be True    60000 > ${M55354C05007_exceed_Threshold1_F1-U_VOL} > 0
    Should Be True    5000 > ${M55355C06007_exceed_Threshold1_X2-U} >= 0
    Should Be True    6000 > ${M55355C07007_exceed_Threshold1_X2-U_VOL} >= 0
    Should Be True    20000 > ${M55355C08007_exceed_Threshold2_X2-U} > 0
    Should Be True    20000 > ${M55355C09007_exceed_Threshold2_X2-U_VOL} > 0
    Should Be True    400000 > ${M55354C06007_exceed_Threshold2_F1-U} > 0
    Should Be True    500000 > ${M55354C07007_exceed_Threshold2_F1-U_VOL} > 0
    Should Be True    50000 > ${M55320C23007_not_retransmitted} >= 0
    Should Be True    50000 > ${M55311C46007_discarded} > 0
    Should Be True    50000 > ${M55311C47007_discarded_VOL} > 0
    ${exceed_Threshold1_F1U_AND_X2U}    Evaluate    ${M55355C06007_exceed_Threshold1_X2-U} + ${M55354C04007_exceed_Threshold1_F1-U}
    Should Be True    ${exceed_Threshold1_F1U_AND_X2U} >= ${exceed_Threshold1_SUM}
    ${exceed_Threshold2_F1U_AND_X2U}    Evaluate    ${M55354C06007_exceed_Threshold2_F1-U} + ${M55355C08007_exceed_Threshold2_X2-U}
    Should Be True    ${exceed_Threshold2_F1U_AND_X2U} >= ${exceed_Threshold2_SUM}
    Should Be True    600000 > ${M55313C04007_LOST_NUM} > 0
    Should Be True    ${M55313C04007_LOST_NUM} > ${M55355C02007_RETX_NUM}+${M55354C02007_F1U_RETX_NUM}
    ${LOST_RETX_DIFF}    Evaluate    ${M55313C04007_LOST_NUM}*0.95
    Should Be True    ${LOST_RETX_DIFF} < ${M55355C02007_RETX_NUM}+${M55354C02007_F1U_RETX_NUM}
    Should Be True    50000 > ${M55354C02007_F1U_RETX_NUM} >= 0
    Should Be True    50000 > ${M55354C03007_F1U_RETX_VOL} >= 0


Check Counter for 1354_C
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_C003}    dic_path=${counter_dic_path_C003_trunk}
#    ...    ELSE    Get the all PM counter value
#    ...    gnb_index=${0}    counter_id=${counter_id_C003}    dic_path=${counter_dic_path_C003}
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
    Set suite variable    ${M55320C22005_exceed_Threshold2}    ${counter_value_list}[13]
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

Check Counter for 1354_A and B
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${0}    counter_id=${counter_id_A_AND_B}    dic_path=${counter_dic_path_A_AND_B_trunk}
#    ...    ELSE    Get the all PM counter value
#    ...    gnb_index=${0}    counter_id=${counter_id_A_AND_B}    dic_path=${counter_dic_path_A_AND_B}
    Set Suite Variable    ${M55313C04007_LOST_NUM}    ${counter_value_list}[0]
    Set Suite Variable    ${M55323C04007_lost_F1-U}    ${counter_value_list}[1]
    Set Suite Variable    ${M55355C02007_RETX_NUM}    ${counter_value_list}[2]
    Set Suite Variable    ${M55355C03007_RETX_VOL}    ${counter_value_list}[3]
    Set Suite Variable    ${M55354C02007_F1U_RETX_NUM}    ${counter_value_list}[4]
    Set Suite Variable    ${M55354C03007_F1U_RETX_VOL}    ${counter_value_list}[5]
    Set Suite Variable    ${M55355C04007_duplication_X2-U_NUM}    ${counter_value_list}[6]
    Set Suite Variable    ${M55355C05007_duplication_X2-U_volume}    ${counter_value_list}[7]
    [Teardown]    COAM Teardown gnb connections
