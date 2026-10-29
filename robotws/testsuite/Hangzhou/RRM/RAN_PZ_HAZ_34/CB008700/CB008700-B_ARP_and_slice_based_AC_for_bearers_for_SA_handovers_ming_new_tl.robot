*** Settings ***
Documentation
...    author: Shi Ming and yayun.zhang
...    contact: ming.shi@nokia-sbell.com and yayun.zhang@nokia-sbell.com
...    squal group: SG03
...    feature: CB008700-B

Force Tags  CA_5G_RRM    RAN_5G    RAN_5G_TDD    CLOUD_5G_CLASSICAL_ANDROID_ASIKL_ABILB1_AAHF_RF_SHARING_ENB
...         STATE_SW_UPLOADED    PY36

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

Suite Setup    Run Keywords    robot_common_operations.Common Suite Setup
...                            AND    Setup Env for test
...                            AND    Common Suite Setup for COAM
...                            AND    Common UE parameter setup
...                            AND    get_release_check_result

Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
...                               AND    Common Suite Teardown for COAM    gnb_list=@{gnb_index}

Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008700/Resources/CB008700_common_keywords_ming_new_tl.robot
Variables    Resources/CB008700_variables.py
Variables    Resources/CB008700_multi_gnb_variables.py
Library      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/get_counters_from_pm_file.py
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot


*** Variables ***
${log_name_B_003_1}    log_name_B_003_1.pcap
${log_name_B_003_2}    log_name_B_003_2.pcap
${log_name_B_003_3}    log_name_B_003_3.pcap
${log_name_B_005_1}    log_name_B_005_1.pcap
${log_name_B_005_2}    log_name_B_005_2.pcap
${log_name_B_005_3}    log_name_B_005_3.pcap
${log_name_B_005_4}    log_name_B_005_4.pcap
${log_name_D_002_1}    log_name_D_002_1.pcap
${log_name_D_002_2}    log_name_D_002_2.pcap     #gnb1 cell1 target HO log
${log_name_D_002_3}    log_name_D_002_3.pcap     #gnb2 cell2 target HO log
${log_name_D_002_4}    log_name_D_002_4.pcap     #gnb2 cell2 normal release log
${log_name_EDA_03533909_1}    log_name_EDA_03533909_1.pcap
${log_name_EDA_03533909_2}    log_name_EDA_03533909_2.pcap
${log_name_EDA_03533909_2_2}    log_name_EDA_03533909_2_2.pcap
${log_name_EDA_03533909_3}    log_name_EDA_03533909_3.pcap
${log_name_EDA_03533909_3_2}    log_name_EDA_03533909_3_2.pcap

${B_002_message_filter}    ngap.emergencyFallbackRequestIndicator == 0 or ngap.radioNetwork == 41

#${ue_type}    samsung

${enb_instance}     ${tl.enbs[0].instance_id}
@{enb_dist_name}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-3    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNMME-0
@{enb_para}    administrativeState    ipAddrPrim

@{cell_id}    0    1    2    3    4    5
@{cell_id_348}    0    1    2    3    4    5    6
#@{multi_gnb_PA}    ${5}    ${22}    ${40}    ${0}    ${35}    ${127}    ${26}    ${30}    ${22}    ${10}    ${20}    ${20}    ${50}    ${15}
@{multi_gnb_PA}    ${5}    ${25}    ${40}    ${0}    ${35}    ${127}    ${26}    ${30}    ${25}    ${10}    ${20}    ${40}    ${45}    ${30}
...    ${50}
@{multi_gnb_PA_358}    ${40}    ${0}    ${30}    ${45}
@{multi_gnb_PA_348}    ${30}    ${0}    ${30}    ${48}
@{multi_gnb_PA_383}    ${38}    ${0}    ${30}    ${50}
@{PA_list}    0    30    45    127
@{value}     ${4}    ${4}    ${1}    ${3}    ${1}    ${3}    ${6}    ${3}    ${1}    ${1}    ${6}    ${3}
@{value2}    ${1}
@{valueB003}     ${3}    ${3}    ${1}    ${3}    ${1}    ${3}    ${6}    ${3}    ${1}    ${1}    ${6}    ${3}
${message_filter1}      nas_5gs.sm.5qi == 9 and f1ap.procedureCode == 12
${message_filter2}      nas_5gs.sm.5qi == 6 and f1ap.procedureCode == 12
${message_filter3}      nas_5gs.sm.5qi == 8 and f1ap.procedureCode == 12
${message_filter4}      nas_5gs.sm.5qi == 7 and f1ap.procedureCode == 12
#${message_filter5}      f1ap.procedureCode == 13 and nr-rrc.physCellId == 38 and nr-rrc.measId == 6
#${message_filter6}      f1ap.procedureCode == 13 and nr-rrc.physCellId == 40
${message_filter7}      f1ap.procedureCode == 13 and nr-rrc.physCellId == 38
${message_filter8}      f1ap.procedureCode == 13 and nr-rrc.physCellId == 383
#${message_filter9}      f1ap.dRBID == 6 and f1ap.procedureCode == 7
#${message_filter10}     f1ap.dRBID == 8 and f1ap.procedureCode == 7
#${message_filter11}     f1ap.dRBID == 7 and f1ap.procedureCode == 7
${message_filter12}     nr-rrc.physCellId == 383 and f1ap.procedureCode == 12
#${message_filter13}     nr-rrc.DRB_Identity == 7 and f1ap.procedureCode == 12
#${message_filter14}     nr-rrc.DRB_Identity == 5 and f1ap.procedureCode == 12
#${message_filter15}     nr-rrc.DRB_Identity == 6 and f1ap.procedureCode == 12
${message_filter16}     nr-rrc.c1 == 1 and f1ap.procedureCode == 13
${message_filter17}     ngap.radioNetwork == 22 and ngap.procedureCode == 30

@{local_ngap_radioNetwork}    22    22    22

#@{DRBs_ToBeReleased}    4    5   6
#@{DRB_Identity}    4    5   6
#@{e1ap_dRB_ID}    4    5    6

${tl_scf_file_name1}    gNB1_Golden_SCF.xml
${tl_scf_file_name2}    gNB2_Golden_SCF.xml

@{gnb_index}    ${0}    ${1}

${dxdata2}    ${tl.ues[0].pdn[0]}
${mdrb_apn_name}    ${tl.ues[0].pdn[1]}
${mdrb1_apn_name}    ${tl.ues[0].pdn[2]}

${X75_dxdata2_location}    959 940
${X75_mdrb_location}    959 1152
${X75_mdrb1_location}    959 1350

${ue_type}                  ${tl.ues[0].capabilities[0]}

${sys_logs_path}    /tmp/btslog2/
${UTE_logs_path}    /home/ute/ERR_WRN_logs/
${testline_name}          null
${base_file}    None
@{filter_list}    None

${Test_PC_IP}          ${tl.test_pc.default_ssh_connection_details.addr}
${Test_PC_username}    ${tl.test_pc.default_ssh_connection_details.username}
${Test_PC_password}    ${tl.test_pc.default_ssh_connection_details.password}

${ue_type_qcom}    ${tl.ues[1].capabilities[0]}

${att_ipaddr_1}    ${tl.attenuator[1].ip_addr}

*** Test Cases ***
#[1]CB008700-B_003_Intra-DU_handover_when_ARP_based_admission_control_enabled_with_RAC_for_Voice_call_success_on_2nd_candidate_cell
#    [Documentation]    This User Scenario is to provide the counters used for measuring SA accessibility.
#    ...    The User scenario creates a counter to measure the success ratio of QosFlows Setup
#    ...    due to incoming handovers. The User scenario is a rerun of multiple scenarios 5G_RAN_USR_RRM_xxx:
#    ...    Intra-gNB Intra-DU HO (5G Control Plane - 5G_RAN_CP_12371397)
#    [Tags]    CB008700-B    CRT_TRUNK    CRT_22R3    CRT_22R4    CRT_23R1
#    [Timeout]    1 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Check UE device exist    ue_index=${0}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=default
#    set apn mdrb
#    Online modify parmeters    parameters_to_update=${PARAM_8700_B_003}
#    ###set gnb1 cell1 PA to 0
#    PA one cell 0 on and set other cell value    cellid=@{cell_id}[1]    set_value=@{multi_gnb_PA}[3]
#    Start capture gNB log on master    filename=${log_name_B_003_1}
#    make WA with Samsung S21
#    Step1: UE attach    ue_type=${ue_type}
#    Wait Until keyword Succeeds    3x    5s    Run Keywords    Step2: UE setup VoNR call
#    ...    AND    sleep    20s
#    ...    AND    check voice call status    status=${2}
#    Stop and download Logs on gNB on master    filename=${log_name_B_003_1}
#    sleep    2s
#    RUN KEYWORD IF    ${enb_instance} == @{enb_id}[5]     #TL358
#    ###set gnb1 cell3 PA to 40   #TL358
#    ...    Change Attenuation value    cell=5Gcell@{cell_id}[3]    value=@{multi_gnb_PA_358}[0]
#    ###set gnb1 cell3 PA to 30   #TL348
#    ...    ELSE IF    ${enb_instance} == @{enb_id}[3]     #TL348
#    ...    Change Attenuation value    cell=5Gcell@{cell_id}[3]    value=@{multi_gnb_PA_348}[0]
#    ###set gnb1 cell3 PA to 38   #TL383
#    ...    ELSE IF    ${enb_instance} == @{enb_id}[4]     #TL383
#    ...    Change Attenuation value    cell=5Gcell@{cell_id}[3]    value=@{multi_gnb_PA_383}[0]
#    ###set gnb1 cell2 PA
#    RUN KEYWORD IF    ${enb_instance} == @{enb_id}[5]
#    ...    Change Attenuation value    cell=5Gcell@{cell_id}[2]    value=@{multi_gnb_PA}[10]    #TL358 set to 20
#    ...    ELSE IF    ${enb_instance} == @{enb_id}[3]
#    ...    Change Attenuation value    cell=5Gcell@{cell_id}[2]    value=@{multi_gnb_PA}[10]    #TL348 set to 20
#    ...    ELSE IF    ${enb_instance} == @{enb_id}[4]
#    ...    Change Attenuation value    cell=5Gcell@{cell_id}[2]    value=@{multi_gnb_PA}[3]    #TL383 set to 0
#    sleep    2s
#    ###set gnb1 cell1 PA to trigger handover to gnb1 cell2,but not GBR Resource
#    Start capture gNB log on master    filename=${log_name_B_003_2}
#    RUN KEYWORD IF    ${enb_instance} == @{enb_id}[5]     #TL358
#    ###set gnb1 cell1 PA to 30db,want to trigger handover to gnb1 cell2,but not GBR Resource  TL358
#    ...    add attenuation for 1db    port1=${5Gcell1_ANT1}    port2=${5Gcell1_ANT2}
#    ...    origin_value=@{multi_gnb_PA_358}[1]    target_value=@{multi_gnb_PA_358}[2]
#    ###set gnb1 cell1 PA to 30db,want to trigger handover to gnb1 cell2,but not GBR Resource  TL383
#    ...    ELSE IF    ${enb_instance} == @{enb_id}[4]    add attenuation for 1db    port1=${5Gcell1_ANT1}    port2=${5Gcell1_ANT2}
#    ...    origin_value=@{multi_gnb_PA_383}[1]    target_value=@{multi_gnb_PA_383}[2]
#    ###set gnb1 cell1 PA to 30db,want to trigger handover to gnb1 cell2,but not GBR Resource  TL348
#    ...    ELSE IF    ${enb_instance} == @{enb_id}[3]    add attenuation for 5db    port1=${5Gcell1_ANT1}    port2=${5Gcell1_ANT2}
#    ...    origin_value=@{multi_gnb_PA_348}[1]    target_value=@{multi_gnb_PA_348}[2]
#    sleep    15s
#    Stop and download Logs on gNB on master    filename=${log_name_B_003_2}
#    sleep    2s
#    Prepare with PM counter time to caculate    period=start
#    ###set gnb1 cell1 PA to handover to gnb1 cell3
#    Start capture gNB log on master    filename=${log_name_B_003_3}
#    RUN KEYWORD IF    ${enb_instance} == @{enb_id}[5]     #TL358
#    ###set gnb1 cell1 PA to 45db,handover to gnb1 cell3   TL358
#    ...    add attenuation for 1db    port1=${5Gcell1_ANT1}    port2=${5Gcell1_ANT2}
#    ...    origin_value=@{multi_gnb_PA_358}[2]    target_value=@{multi_gnb_PA_358}[3]
#    ###set gnb1 cell1 PA to 50db,handover to gnb1 cell3   TL383
#    ...    ELSE IF    ${enb_instance} == @{enb_id}[4]    add attenuation for 1db    port1=${5Gcell1_ANT1}    port2=${5Gcell1_ANT2}
#    ...    origin_value=@{multi_gnb_PA_383}[2]    target_value=@{multi_gnb_PA_383}[3]
#    ###set gnb1 cell1 PA to 48db,handover to gnb1 cell3   TL348
#    ...    ELSE IF    ${enb_instance} == @{enb_id}[3]    add attenuation for 5db    port1=${5Gcell1_ANT1}    port2=${5Gcell1_ANT2}
#    ...    origin_value=@{multi_gnb_PA_348}[2]    target_value=@{multi_gnb_PA_348}[3]
#    sleep    15s
#    Stop and download Logs on gNB on master    filename=${log_name_B_003_3}
#    Prepare with PM counter time to caculate    period=end
#    RUN KEYWORD IF    '${check_result}' != 'True'
#    ...    Check gnb1B003 the PM counter
#    ...    counter_id=${counter_id_B003}    dic_path=${counter_dic_path_B003}    counter_end=${counter_end}    timeout=${600}
#    ...    ELSE
#    ...    Check gnb1B003 the PM counter
#    ...    counter_id=${counter_id_B003}    dic_path=${counter_dic_path_B003_trunk}    counter_end=${counter_end}    timeout=${600}
##    RUN KEYWORD IF    ${enb_instance} != @{enb_id}[0]
##    ...    wait until keyword succeeds    5min    20s    Check gnb1B003 the PM counter
##    ...    counter_id=${counter_id_B003}    dic_path=${counter_dic_path_B003}    counter_end=${counter_end}    timeout=${600}
##    ...    ELSE
##    ...    wait until keyword succeeds    5min    20s    Check gnb1B003 the PM counter
##    ...    counter_id=${counter_id_B003}    dic_path=${counter_dic_path_B003_trunk}    counter_end=${counter_end}    timeout=${600}
#    Check wireshark log for 8700_001
#    Check wireshark log for 8700_002
#    Check wireshark log for 8700_003
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Suite Teardown
#    ...    AND    Step3: UE hang up VoNR call
#    ...    AND    sleep    20s
#    ...    AND    check voice call status    status=${0}
#    ...    AND    Step4: Detach UE    ue_type=${ue_type}
#    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_003_1}
#    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_003_2}
#    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_003_3}
#    ...    AND    Online modify parmeters    parameters_to_update=${PARAM_8700_recover_B_03}
#    ...    AND    PA one cell 0 on and set other cell value    cellid=@{cell_id}[1]    set_value=@{multi_gnb_PA}[0]
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]CB008700-B_005_EC_Intra-DU_handover_when_ARP_based_admission_control_enabled_with_RAC_for_Emergency_call_fail
#    [Documentation]    This User Scenario is to provide the counters used for measuring SA accessibility.
#    ...    The User scenario creates a counter to measure the success ratio of QosFlows Setup
#    ...    due to incoming handovers. The User scenario is a rerun of multiple scenarios 5G_RAN_USR_RRM_xxx:
#    ...    Intra-gNB Intra-DU HO (5G Control Plane - 5G_RAN_CP_12371397)
#    [Tags]    CB008700-B    CRT_TRUNK    CRT_22R3    CRT_22R4    CRT_23R1
#    [Timeout]    40mins
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Check UE device exist    ue_index=${0}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=default
#    set apn mdrb
#    Online modify parmeters    parameters_to_update=${PARAM_8700_B_005}
#    ###set gnb1 cell1 PA to 0
#    PA one cell 0 on and set other cell value    cellid=@{cell_id}[1]    set_value=@{multi_gnb_PA}[3]
#    Start capture gNB log on master    filename=${log_name_B_005_1}
#    make WA with Samsung S21
#    Step1: UE attach    ue_type=${ue_type}
#    Wait Until Keyword Succeeds    3x    5s    Run Keywords    Step2: UE setup EMC call
#    ...    AND    sleep    20s
#    ...    AND    check voice call status    status=${2}
#    Stop and download Logs on gNB on master    filename=${log_name_B_005_1}
#    RUN KEYWORD IF    ${enb_instance} == @{enb_id}[5]     #TL358
#    ###set gnb1 cell3 PA to 40   #TL358
#    ...    Change Attenuation value    cell=5Gcell@{cell_id}[3]    value=@{multi_gnb_PA_358}[0]
#    ###set gnb1 cell3 PA to 30   #TL348
#    ...    ELSE IF    ${enb_instance} == @{enb_id}[3]     #TL348
#    ...    Change Attenuation value    cell=5Gcell@{cell_id}[3]    value=@{multi_gnb_PA_348}[0]
#    ###set gnb1 cell3 PA to 38   #TL383
#    ...    ELSE IF    ${enb_instance} == @{enb_id}[4]     #TL383
#    ...    Change Attenuation value    cell=5Gcell@{cell_id}[3]    value=@{multi_gnb_PA_383}[0]
#    ###set gnb1 cell2 PA
#    RUN KEYWORD IF    ${enb_instance} == @{enb_id}[5]
#    ...    Change Attenuation value    cell=5Gcell@{cell_id}[2]    value=@{multi_gnb_PA}[10]    #TL358 set to 20
#    ...    ELSE IF    ${enb_instance} == @{enb_id}[3]
#    ...    Change Attenuation value    cell=5Gcell@{cell_id}[2]    value=@{multi_gnb_PA}[10]    #TL348 set to 20
#    ...    ELSE IF    ${enb_instance} == @{enb_id}[4]
#    ...    Change Attenuation value    cell=5Gcell@{cell_id}[2]    value=@{multi_gnb_PA}[3]    #TL383 set to 0
#    sleep    5s
#    ###set gnb1 cell1 PA to trigger handover to gnb1 cell2,but not GBR Resource
#    Start capture gNB log on master    filename=${log_name_B_005_2}
#    RUN KEYWORD IF    ${enb_instance} == @{enb_id}[5]     #TL358
#    ###set gnb1 cell1 PA to 30db,want to trigger handover to gnb1 cell2,but not GBR Resource    #TL358
#    ...    add attenuation for 1db    port1=${5Gcell1_ANT1}    port2=${5Gcell1_ANT2}
#    ...    origin_value=@{multi_gnb_PA_358}[1]    target_value=@{multi_gnb_PA_358}[2]
#    ###set gnb1 cell1 PA to 30db,want to trigger handover to gnb1 cell2,but not GBR Resource    #TL383
#    ...    ELSE IF    ${enb_instance} == @{enb_id}[4]    add attenuation for 1db    port1=${5Gcell1_ANT1}    port2=${5Gcell1_ANT2}
#    ...    origin_value=@{multi_gnb_PA_383}[1]    target_value=@{multi_gnb_PA_383}[2]
#    ###set gnb1 cell1 PA to 30db,want to trigger handover to gnb1 cell2,but not GBR Resource    #TL348
#    ...    ELSE IF    ${enb_instance} == @{enb_id}[3]    add attenuation for 5db    port1=${5Gcell1_ANT1}    port2=${5Gcell1_ANT2}
#    ...    origin_value=@{multi_gnb_PA_348}[1]    target_value=@{multi_gnb_PA_348}[2]
#    sleep    5s
#    Stop and download Logs on gNB on master    filename=${log_name_B_005_2}
#    sleep    2s
#    ###set gnb1 cell1 PA to 30db,handover to gnb1 cell3
#    Start capture gNB log on master    filename=${log_name_B_005_3}
#    RUN KEYWORD IF    ${enb_instance} == @{enb_id}[5]     #TL358
#    ###set gnb1 cell1 PA to 45db,handover to gnb1 cell3   TL358
#    ...    add attenuation for 1db    port1=${5Gcell1_ANT1}    port2=${5Gcell1_ANT2}
#    ...    origin_value=@{multi_gnb_PA_358}[2]    target_value=@{multi_gnb_PA_358}[3]
#    ###set gnb1 cell1 PA to 50db,handover to gnb1 cell3   TL383
#    ...    ELSE IF    ${enb_instance} == @{enb_id}[4]    add attenuation for 1db    port1=${5Gcell1_ANT1}    port2=${5Gcell1_ANT2}
#    ...    origin_value=@{multi_gnb_PA_383}[2]    target_value=@{multi_gnb_PA_383}[3]
#    ###set gnb1 cell1 PA to 48db,handover to gnb1 cell3   TL348
#    ...    ELSE IF    ${enb_instance} == @{enb_id}[3]    add attenuation for 5db    port1=${5Gcell1_ANT1}    port2=${5Gcell1_ANT2}
#    ...    origin_value=@{multi_gnb_PA_348}[2]    target_value=@{multi_gnb_PA_348}[3]
#    sleep    5s
#    Stop and download Logs on gNB on master    filename=${log_name_B_005_3}
#    Start capture gNB log on master    filename=${log_name_B_005_4}
#    sleep  5s
#    check voice call status    status=${2}
#    Step3: UE hang up EMC call
#    sleep  20s
#    check voice call status    status=${0}
#    Stop and download Logs on gNB on master    filename=${log_name_B_005_4}
#    Check wireshark log for 8700_B05_001
#    Check wireshark log for 8700_B05_002
#    Check wireshark log for 8700_B05_003
#    Check wireshark log for 8700_B05_004
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Suite Teardown
#    ...    AND    Step3: UE hang up EMC call
#    ...    AND    sleep    20s
#    ...    AND    check voice call status    status=${0}
#    ...    AND    Step4: Detach UE    ue_type=${ue_type}
#    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_005_1}
#    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_005_2}
#    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_005_3}
#    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_005_4}
#    ...    AND    Online modify parmeters    parameters_to_update=${PARAM_8700_recover_B_05}
#    ...    AND    PA one cell 0 on and set other cell value    cellid=@{cell_id}[1]    set_value=@{multi_gnb_PA}[0]
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]CB008700-D_002_NG_handover_when_ARP_based_admission_control_enabled_with_Data_PDU_Session_with_unsupport_SNSSAI_QOS_FLOW
#    [Documentation]    This User Scenario is to provide the counters used for measuring SA accessibility.
#    ...    The User scenario creates a counter to measure the success ratio of QosFlows Setup
#    ...    due to incoming handovers. The User scenario is a rerun of multiple scenarios 5G_RAN_USR_RRM_xxx:
#    ...    Intra-gNB Intra-DU HO (5G Control Plane - 5G_RAN_CP_12371397)
#    [Tags]    CB008700-B    CRT_TRUNK    CRT_22R3    CRT_22R4    CRT_23R1
#    [Timeout]    40mins
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Check UE device status with adb recover    ue_index=${0}
#    Check UE device status with adb recover    ue_index=${1}
#    Check UE device exist    ue_index=${0}
#    Run Keyword If    '${ue_type}' != 'qct_dx50'    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=default
#    Wait Until Keyword Succeeds    3x    10s
#    ...    Run Keyword If    '${ue_type}' == 'samsung' or '${ue_type}' == 'Huawei'   Run Keywords
#    ...    set apn mdrb
#    ...    AND    make WA with Samsung S21
#    ...    ELSE IF    '${ue_type}' == 'qct_dx50'
#    ...    choice required APN on QCOM UE    usedapn=${X75_mdrb_location}   ue_index=${0}
##    ...    Switch QCOM APN to muti DRB    ue_index=${0}    ue_type=${ue_type}    apn_name=${mdrb_apn_name}
#    Run Keyword If    '${ue_type}' == 'qct_dx50'    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=default
#    Online modify parmeters    parameters_to_update=${PARAM_8700_D_002}
#    Online modify parmeters    gnb_index=${1}    parameters_to_update=${PARAM_8700_D_002_2}
#    ###set gnb1 cell1 PA to 5
#    PA one cell 0 on and set other cell value    cellid=@{cell_id}[1]    set_value=@{multi_gnb_PA}[0]
#    Start capture gNB log on master    filename=${log_name_D_002_1}
#    Run Keyword If    '${ue_type}' == 'samsung' or '${ue_type}' == 'Huawei'   make WA with Samsung S21
#    Step1: UE attach    ue_type=${ue_type}
#    Wait Until Keyword Succeeds    3x    5s    Run Keywords    Run Keyword If    '${ue_type}' == 'samsung' or '${ue_type}' == 'Huawei'
#    ...    Step2: UE setup VoNR call
#    ...    ELSE IF    '${ue_type}' == 'qct_dx50'    Make a VoNR call(+6688) on SDX70
#    ...    AND    sleep    20s
#    ...    AND    check voice call status    status=${2}
#    Stop and download Logs on gNB on master    filename=${log_name_D_002_1}
#    sleep    2s
#    Prepare with PM counter time to caculate    period=start
#    ###Inter gnb HO
#    Start capture gNB log on master    filename=${log_name_D_002_2}
#    Start capture gNB log on master    filename=${log_name_D_002_3}    gNB_index=${1}
#    ###set gnb2 cell1 PA
#    RUN KEYWORD IF    ${enb_instance} == @{enb_id}[5]
#    ...    Change Attenuation value    cell=5Gcell@{cell_id}[4]    value=@{multi_gnb_PA}[3]    #TL358 set to 0
#    ...    ELSE IF    ${enb_instance} == @{enb_id}[4]
#    ...    Change Attenuation value    cell=5Gcell@{cell_id}[4]    value=@{multi_gnb_PA}[3]    #TL383 set to 0
#    ...    ELSE IF    ${enb_instance} == @{enb_id}[3]
#    ...    Change Attenuation value    cell=5Gcell@{cell_id}[4]    value=@{multi_gnb_PA}[9]    #TL348 set to 10
#    RUN KEYWORD IF    ${enb_instance} == @{enb_id}[4]
#    ###set gnb1 cell1 PA from 0 to target value(40db)   #TL383
#    ...    add attenuation for 1db    port1=${5Gcell1_ANT1}    port2=${5Gcell1_ANT2}
#    ...    origin_value=@{multi_gnb_PA}[0]    target_value=@{multi_gnb_PA}[11]
#    ###set gnb1 cell1 PA from 0 to target value(10db)   #tl358
#    ...    ELSE IF    ${enb_instance} == @{enb_id}[5]
#    ...    add attenuation for 5db    port1=${5Gcell1_ANT1}    port2=${5Gcell1_ANT2}
#    ...    origin_value=@{multi_gnb_PA}[0]    target_value=@{multi_gnb_PA}[9]
#    ###set gnb1 cell1 PA from 0 to target value(25db)   #tl348
#    ...    ELSE IF    ${enb_instance} == @{enb_id}[3]
#    ...    add attenuation for 5db    port1=${5Gcell1_ANT1}    port2=${5Gcell1_ANT2}
#    ...    origin_value=@{multi_gnb_PA}[0]    target_value=@{multi_gnb_PA}[1]
#    sleep    30s
#    Stop and download Logs on gNB on master    filename=${log_name_D_002_2}
#    Stop and download Logs on gNB on master    filename=${log_name_D_002_3}    gNB_index=${1}
#    Prepare with PM counter time to caculate    period=end
#    ###check counter CELLS/NRCELL-1/NNGCC/NG_FLOW_REL_PART_HO==4, because MDRB include5QI-6/7/8/9 three QOS FLOW
#    RUN KEYWORD IF    '${check_result}' != 'True'
#    ...    Check gnb1 the PM counter     counter_id=${counter_id_D002}    dic_path=${counter_dic_path_D002}    counter_end=${counter_end}
#    ...    ELSE
#    ...    Check gnb1 the PM counter     counter_id=${counter_id_D002}    dic_path=${counter_dic_path_D002_trunk}    counter_end=${counter_end}
#    RUN KEYWORD IF    '${check_result}' != 'True'
#    ...    wait until keyword succeeds    5min    20s    Check gnb2 the PM counter
#    ...    counter_id=${counter_id_D002_2}    dic_path=${counter_dic_path_D002_2}    counter_end=${counter_end}
#    ...    ELSE
#    ...    wait until keyword succeeds    5min    20s    Check gnb2 the PM counter
#    ...    counter_id=${counter_id_D002_2}    dic_path=${counter_dic_path_D002_2_trunk}    counter_end=${counter_end}
#    ###VONR call normal release on gnb2
#    Start capture gNB log on master    filename=${log_name_D_002_4}    gNB_index=${1}
#    sleep  5s
#    check voice call status    status=${2}
#    Step3: UE hang up VoNR call
#    sleep  20s
#    check voice call status    status=${0}
#    Stop and download Logs on gNB on master    filename=${log_name_D_002_4}    gNB_index=${1}
#
#    Check wireshark log for 8700_D02_001
#    Check wireshark log for 8700_D02_002
#    Check wireshark log for 8700_D02_003
#    Check wireshark log for 8700_D02_004
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Suite Teardown
#    ...    AND    Step3: UE hang up VoNR call
#    ...    AND    sleep    20s
#    ...    AND    check voice call status    status=${0}
#    ...    AND    Run Keyword If    '${ue_type}' != 'qct_dx50'    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=default
#    ...    AND    Run Keyword If    '${ue_type}' == 'samsung' or '${ue_type}' == 'Huawei'   make WA with Samsung S21
#    ...    AND    Step4: Detach UE    ue_type=${ue_type}
#    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_D_002_1}
#    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_D_002_2}
#    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_D_002_3}    gNB_index=${1}
#    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_D_002_4}    gNB_index=${1}
#    ...    AND    Online modify parmeters    parameters_to_update=${PARAM_8700_recover_D_02}
#    ...    AND    Online delete parmeters    parameters_to_update=${PARAM_DELETE_8700_D_002}
#    ...    AND    Online modify parmeters    gnb_index=${1}    parameters_to_update=${PARAM_8700_recover_D_02_2}
#    ...    AND    Online delete parmeters    gnb_index=${1}    parameters_to_update=${PARAM_DELETE_8700_D_02_2}
#    ...    AND    PA one cell 0 on and set other cell value    cellid=@{cell_id}[1]    set_value=@{multi_gnb_PA}[0]
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown


[1]NG_handover_caused_ngrelocoverall_expiry_EDA_03533909
    [Documentation]    EDA_03533909
    [Tags]    CB006898    CB008200    CB007564    CRT_TRUNK
    [Timeout]    1 hour
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=4291
    AlarmWatchdog.add_allow_alarms    fault_id=4291
    Check UE device status with adb recover    ue_index=${0}
    Check UE device exist    ue_index=${0}
    paras change on BTS
        ...    paras=${CB008700_ciphering_algorithms}
        ...    delta_file_name=${epc_log_path}${CB008700_ciphering_algorithms_json_file}
    paras change on BTS
        ...    gnb_index=${1}
        ...    paras=${CB008700_ciphering_algorithms_2}
        ...    delta_file_name=${epc_log_path}${CB008700_ciphering_algorithms_json_file_2}
    IF    ${enb_instance} == ${enb_id}[3]    #TL348
        power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}
        Online modify parmeters    parameters_to_update=${PARAM_EDA_03533909}    skip_parameter_relation_errors=False
        Online modify parmeters    gnb_index=${1}    parameters_to_update=${PARAM_EDA_03533909_2}    skip_parameter_relation_errors=False
        ###set gnb1 cell1 PA to 5
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[3]
    ELSE IF    ${enb_instance} == ${enb_id}[4]    #TL383
        power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}
        Online modify parmeters    parameters_to_update=${PARAM_EDA_03533909}    skip_parameter_relation_errors=False
        Online modify parmeters    gnb_index=${1}    parameters_to_update=${PARAM_EDA_03533909_2}    skip_parameter_relation_errors=False
        ###set gnb1 cell1 PA to 5
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[3]
    END
#    put btslog_ini file to ute
#    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
#    Start capture syslog via btslog on ute
    Start capture gNB log on master    filename=${log_name_EDA_03533909_1}
    IF    ${enb_instance} == ${enb_id}[3]    #TL348
        Step1: UE attach    ue_type=${ue_type}    ue_index=${0}
        Step2: UE setup VoNR call    ue_index=${0}
        Wait Until Keyword Succeeds    20s    5s    check voice call status    status=${2}    ue_index=${0}
    ELSE IF    ${enb_instance} == ${enb_id}[4]    #TL383
        Step1: UE attach    ue_type=${ue_type}    ue_index=${0}
        Step2: UE setup VoNR call    ue_index=${0}
        Wait Until Keyword Succeeds    20s    5s    check voice call status    status=${2}    ue_index=${0}
    END
    Stop and download Logs on gNB on master    filename=${log_name_EDA_03533909_1}
    Prepare with PM counter time to caculate    period=start
    Sleep    1m
    ###Inter gnb HO
    Start capture gNB log on master    filename=${log_name_EDA_03533909_2}
    Start capture gNB log on master    filename=${log_name_EDA_03533909_2_2}    gNB_index=${1}
    ###set gnb2 cell1 PA
    IF    ${enb_instance} == ${enb_id}[3]    #TL348 set to 5
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[6]    value=${multi_gnb_PA}[3]    ip_addr=${att_ipaddr_1}
        add attenuation for 1db 4 port
        ...    port1=${5Gcell1_ANT1}    port2=${5Gcell1_ANT2}    port3=${5Gcell1_ANT3}    port4=${5Gcell1_ANT4}
        ...    origin_value=${multi_gnb_PA}[0]    target_value=${multi_gnb_PA}[14]
    ELSE IF    ${enb_instance} == ${enb_id}[4]    #TL383 set to 0
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[6]    value=${multi_gnb_PA}[3]    ip_addr=${att_ipaddr_1}
        add attenuation for 1db 4 port
        ...    port1=${5Gcell1_ANT1}    port2=${5Gcell1_ANT2}    port3=${5Gcell1_ANT3}    port4=${5Gcell1_ANT4}
        ...    origin_value=${multi_gnb_PA}[0]    target_value=${multi_gnb_PA}[14]
    END
    sleep    30s
    Stop and download Logs on gNB on master    filename=${log_name_EDA_03533909_2}
    Stop and download Logs on gNB on master    filename=${log_name_EDA_03533909_2_2}    gNB_index=${1}
    Prepare with PM counter time to caculate    period=end
    Check wireshark log for EDA_03533909_001
    check gnb counters
    Start capture gNB log on master    filename=${log_name_EDA_03533909_3}
    Start capture gNB log on master    filename=${log_name_EDA_03533909_3_2}    gNB_index=${1}
    sleep  5s
    check voice call status    status=${2}    ue_index=${0}
    Step3: UE hang up VoNR call    ue_index=${0}
    Wait Until Keyword Succeeds    20s    5s    check voice call status    status=${0}    ue_index=${0}
    Stop and download Logs on gNB on master    filename=${log_name_EDA_03533909_3}
    Stop and download Logs on gNB on master    filename=${log_name_EDA_03533909_3_2}    gNB_index=${1}

    Check wireshark log for EDA_03533909_002
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown
    ...    AND    AlarmWatchdog.remove_allow_alarms    fault_id=4291
    ...    AND    Step3: UE hang up VoNR call    ue_index=${0}
    ...    AND    sleep    20s
    ...    AND    check voice call status    status=${0}    ue_index=${0}
    ...    AND    Run Keyword If    ${enb_instance} == ${enb_id}[3]    Step4: Detach UE    ue_type=${ue_type}    ue_index=${0}
    ...    ELSE IF    ${enb_instance} == ${enb_id}[4]    Step4: Detach UE    ue_type=${ue_type}    ue_index=${0}
#    ...    AND    Run Keyword And Ignore Error    Stop capture syslog via btslog on ute
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_EDA_03533909_1}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_EDA_03533909_2}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_EDA_03533909_3}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_EDA_03533909_2_2}    gNB_index=${1}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_EDA_03533909_3_2}    gNB_index=${1}
    ...    AND    recover para and pa value
    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#    ...    AND    Get And Analysis Syslog

*** Keywords ***
get and analysis syslog
    Check ERR Or WRN From Syslog
    ...    sys_logs_path=${sys_logs_path}      Expected_ERR_WRN_deviation=0.2
    ...    Expected_ERR_WRN_diff_number=0
    ...    UTE_logs_path=${UTE_logs_path}      testline=${testline_name}
    ...    base_file=None     Fail_Case=False       Clear_log=False     remove_ERR_WRN_excel=True
    ...    filter_list=None      ignore_list=None      Delete_old_ERR_WRN=20
    ...    FilesSystem=/dev/vda2      Max_used_space_ratio=0.9      check_diff=True
    ...    timeout=30 minutes      Expected_ERR_WRN_number=0

Start capture syslog via btslog on ute
    Start BTSlogs Collection In Log Server
    ...    Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...    Test_PC_password=${Test_PC_password}
    ...    btslog_path=/tmp/btslog2    btslog_launcher=/opt/btslog/btslog_launcher
    ...    btslog_launcher_path=/opt/btslog/btslog
    ...    Login_UTE=False

Stop capture syslog via btslog on ute
    Stop BTSlogs Collection And Download Logs To Log Server
    ...    UTE_syslogs_path=/home/ute/BTS_logs    btslog_path=/tmp/btslog2
    ...    btslog_launcher=/opt/btslog/btslog_launcher    btslog_launcher_path=/opt/btslog/btslog
    ...    Login_UTE=${False}


mtk ue attach on 348
    ${ssRsrp_output}=    reboot ue to attach    ue_index=${1}
    verify ue attach success via ssRsrp    ssRsrp_output=${ssRsrp_output}    dist_name=${NRCELLname}    p_name=physCellId

reboot ue to attach
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${cpc_alias}=cpc_${ue_index}
    UE Reboot with adb command    ue_index=${ue_index}
    wait until keyword succeeds    3min    2s    Connect to control pc enhanced    ue_index=${ue_index}
    sleep    30s
    csn.send_command    command=adb -s ${serial_number} shell dumpsys telephony.registry | grep -i "ssRsrp"    connection=${cpc_alias}
    ${ssRsrp_output}   csn.read_output    connection=${cpc_alias}
    [Teardown]    csn.disconnect    connection=${cpc_alias}
    [Return]    ${ssRsrp_output}

verify ue attach success via ssRsrp
    [Arguments]    ${ssRsrp_output}    ${dist_name}    ${p_name}    ${scf_name}=gNB1_Golden_SCF.xml
    ${mPci_value}=    get_mPci_value_from_adb_command_output    output=${ssRsrp_output}
    ${value}=    Get value of parameter from SCF file    golden_scf_name=${scf_name}    dist_name=${dist_name}    p_name=${p_name}
    Should Be Equal As Strings    ${mPci_value}    ${value}

Switch QCOM APN to muti DRB
    [Arguments]    ${apn_name}    ${ue_index}=${0}    ${ue_type}=${ue_type}
    Get all X70 pointer variable
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${True}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}
    Android UE SwitchApn    ue_index=${ue_index}    apn_name=${apn_name}    #ui_version=${ui_version}
    UE.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Switch APN to muti DRB
    [Arguments]    ${apn_name}    ${ui_version}    ${ue_index}=${0}    ${ue_type}=${ue_type}
    Run Keyword And Ignore Error    Attach and check power UE   ue_type=${ue_type}
    Android UE SwitchApn    ue_index=${ue_index}    apn_name=${apn_name}    ui_version=${ui_version}
    run keyword and ignore error    UE.UE Detach    ue_type=${ue_type}

Android UE SwitchApn
    [Documentation]
    ...    Note: Use the keyword must be ensure that UE UI Menu is English language
    ...    str ui_version: mobile ui version.
    ...        e.g Magic UI 3.1.1, have tested on honor CDY-AN90 1080x2400,
    ...            EMUI 10.1.0, have tested on huawei mate30 LIO-AN00 1176x2400.
    ...            Qualcomm qti lahaina for arm64 ue do not have UI, so this field equal to '' or ${None}
    ...           if mobile is mtk peturs, pass 'petrus' as ui_version.
    [Arguments]       ${ue_index}=${0}    ${host}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${username}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${password}=${tl.ues[${ue_index}].ssh_connection_details.password}     ${ui_version}=${None}
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${apn_name}=mdrb    ${ue_alias}=UE_${ue_index}
    android_mobile.setup
    ...               ui_version=${ui_version}    host=${host}    username=${username}
    ...               password=${password}    port=22     serial_number=${serial_number}    alias=${UE_alias}
    run keyword and ignore error    android_mobile.switch_apn       apn_name=${apn_name}   mobile=${UE_alias}
    android_mobile.teardown       mobile=${UE_alias}

Get all X70 pointer variable
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    953 1385
    Set Suite Variable    ${close_task}    523 272
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    480 860
    Set Suite Variable    ${iperf_button}    720 312
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${brand}    qti

choice required APN on QCOM UE
    [Arguments]    ${usedapn}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Get all X70 pointer variable
    set Qcom apn to wap2    usedapn=${usedapn}    ue_index=${ue_index}
    make airplane mode to enable    ue_index=${ue_index}
    Connect to control pc via cygwin    ue_index=${ue_index}
    #### KEYCODE_APP_SWITCH,recent APP application
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin
    #### clear all KEYCODE_APP_SWITCH,recent APP application
    FOR  ${i}    IN RANGE    ${9}
        csn.send_command    command=adb -s ${serial_number} shell input swipe 100 1300 900 1300    connection=cygwin
        sleep    1s
    END
    sleep    2s
    FOR  ${i}    IN RANGE    ${2}
        csn.send_command    command=adb -s ${serial_number} shell input tap 241 1076    connection=cygwin
        sleep   1s
    END
    csn.disconnect    connection=cygwin

set Qcom apn to wap2
    [Arguments]    ${usedapn}=${wap2apn}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Set Suite Variable    ${apnset1}    ${usedapn}
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${True}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}
    Connect to control pc via cygwin    ue_index=${ue_index}    alias=cygwin
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   2s
    #### KEYCODE_APP_SWITCH,recent APP application
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin
    #### clear all KEYCODE_APP_SWITCH,recent APP application
    FOR  ${i}    IN RANGE    ${9}
        csn.send_command    command=adb -s ${serial_number} shell input swipe 100 1300 900 1300    connection=cygwin
        sleep    1s
    END
    sleep    2s
    FOR  ${i}    IN RANGE    ${2}
        csn.send_command    command=adb -s ${serial_number} shell input tap 241 1076    connection=cygwin
        sleep   1s
    END
    sleep   2s
    ####1.APN setting
    ####1.1 setting
    csn.send_command    command=adb -s ${serial_number} shell am start com.android.settings/com.android.settings.Settings$ApnSettingsActivity
    ...    connection=cygwin
    ####1.2 Network&internet
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 447 938    connection=cygwin
    sleep   2s
    ####1.3 SIMs
    csn.send_command    command=adb -s ${serial_number} shell input tap 323 1205    connection=cygwin
    sleep   2s
    ####1.4 T-Mobile
    csn.send_command    command=adb -s ${serial_number} shell input tap 337 736    connection=cygwin
    sleep   2s
    ####1.5 swipe Access Point Names
    FOR  ${i}    IN RANGE    ${4}
        csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=cygwin
        sleep    1s
    END
    ####1.6 click Access Point Names
    csn.send_command    command=adb -s ${serial_number} shell input tap 486 1604    connection=cygwin
    sleep   2s
    ####1.6 switch Access Point Names
    csn.send_command    command=adb -s ${serial_number} shell input tap ${apnset1}    connection=cygwin
    sleep   2s
    [Teardown]    csn.disconnect    connection=cygwin

Make a VoNR call(+6688) on SDX70
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=cygwin${ue_index}
    sleep    2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+${phone_number}
    ...    connection=cygwin${ue_index}
    sleep   1s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

Make a VoNR call(+6688) on SDX80
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=cygwin${ue_index}
    sleep    2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+${phone_number}
    ...    connection=cygwin${ue_index}
    sleep   1s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

Make a VoNR call(+6688) on mtk80
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input swipe 259 1954 342 1059    connection=cygwin${ue_index}
    sleep    2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+${phone_number}
    ...    connection=cygwin${ue_index}
    sleep   1s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

check gnb counters
    sleep    1m    reason=wait pm file generated
    IF    ${enb_instance} == ${enb_id}[3]    #TL348
        check KPI via pm file    kpi_path=${CURDIR}/Resources    KPI_file=EDA_03533909_counters.txt
        ...    para_index=${1}    index=${0}    counter_values=${counter_value_EDA_03533909}
        check KPI via pm file on gnb2    kpi_path=${CURDIR}/Resources    KPI_file=EDA_03533909_counters.txt
        ...    para_index=${1}    index=${1}    counter_values=${counter_value_EDA_03533909_2}
    ELSE IF    ${enb_instance} == ${enb_id}[4]    #TL383
        check KPI via pm file    kpi_path=${CURDIR}/Resources    KPI_file=EDA_03533909_counters.txt
        ...    para_index=${1}    index=${0}    counter_values=${counter_value_EDA_03533909}
        check KPI via pm file on gnb2    kpi_path=${CURDIR}/Resources    KPI_file=EDA_03533909_counters.txt
        ...    para_index=${1}    index=${1}    counter_values=${counter_value_EDA_03533909_2}
    END

check KPI via pm file
    [Arguments]     ${kpi_path}    ${KPI_file}    ${para_index}    ${index}=${0}    ${counter_values}=${counter_value_EDA_03533909}
    ${dict_kpi_value}=    get dict kpi from pm file
    ...    kpi_path=${kpi_path}    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    Should Be Equal    ${dict_kpi_value['NG_FLOW_REL']}    ${counter_values}[0]
    Should Be Equal    ${dict_kpi_value['NG_FLOW_REL_PMQAP']}    ${counter_values}[1]
    Should Be Equal    ${dict_kpi_value['NG_FLOW_REL_GNB_UE_LOST']}    ${counter_values}[2]
    Should Be Equal    ${dict_kpi_value['NG_FLOW_REL_GNB_UE_LOST_5QI1']}    ${counter_values}[3]
    Should Be Equal    ${dict_kpi_value['NG_FLOW_REL_GNB_UE_LOST_PMQAP']}    ${counter_values}[4]
#    Should Be Equal    ${dict_kpi_value['NG_FLOW_REL']}    ${drb_num}
#    Should Be Equal    ${dict_kpi_value['NG_FLOW_REL_PMQAP']}    ${drb_num}
#    Should Be Equal    ${dict_kpi_value['NG_FLOW_REL_GNB_UE_LOST']}    ${drb_num}
#    ${num}=    Evaluate    math.ceil(${drb_num}/3)    modules=math
#    Should Be Equal    ${dict_kpi_value['NG_FLOW_REL_GNB_UE_LOST_5QI1']}    ${num}
#    Should Be Equal    ${dict_kpi_value['NG_FLOW_REL_GNB_UE_LOST_PMQAP']}    ${drb_num}

check KPI via pm file on gnb2
    [Arguments]     ${kpi_path}    ${KPI_file}    ${para_index}    ${index}=${0}    ${counter_values}=${counter_value_EDA_03533909}
    ${dict_kpi_value}=    get dict kpi from pm file
    ...    kpi_path=${kpi_path}    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    Should Be Equal    ${dict_kpi_value['NG_FLOW_REL']}    ${counter_values}[0]
    Should Be Equal    ${dict_kpi_value['NG_FLOW_REL_PMQAP']}    ${counter_values}[1]
    Should Be Equal    ${dict_kpi_value['NG_FLOW_REL_GNB_UE_LOST']}    ${counter_values}[2]
    Should Be Equal    ${dict_kpi_value['NG_FLOW_REL_GNB_UE_LOST_5QI1']}    ${counter_values}[3]
    Should Be Equal    ${dict_kpi_value['NG_FLOW_REL_GNB_UE_LOST_PMQAP']}    ${counter_values}[4]

get dict kpi from pm file
    [Arguments]    ${index}=${0}    ${bts_ip}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.addr}
    ...    ${bts_username}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.username}
    ...    ${bts_password}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.password}
    ...    ${kpi_path}=${CURDIR}
    ...    ${KPI_file}=EDA_03533909_counters.txt
    ...    ${para_index}=${2}
    ${newest_xml_file}=    get_newest_pm_xml_file    ip=${bts_ip}    username=${bts_username}    password=${bts_password}
    ...    connection=gNB${index}    local_path=${epc_log_path}
    ${dict_kpi_value}=    calculate_dict_kpis_from_pm_file    pm_xml_file=${newest_xml_file}
    ...    kpi_file=${kpi_path}/${KPI_file}    para_index=${para_index}
    [Return]    ${dict_kpi_value}


set apn dxdata2
    RUN KEYWORD IF    ${enb_instance} != ${enb_id}[5]
    ...    run keywords    Set Suite Variable    ${close_task}    538 1874
    ...    AND    set apn with special method    usedapn=${dxdata2_apn_348}    location_apn=${click_access_point}
    ...    ELSE    set apn to wap2    usedapn=${dxdata2_apn}

set apn mdrb
    RUN KEYWORD IF    ${enb_instance} != ${enb_id}[5]
    ...    run keywords    Set Suite Variable    ${close_task}    538 1874
    ...    AND    set apn with special method    usedapn=${muiltdrb_348}    location_apn=${click_access_point}
    ...    ELSE    set apn to wap2    usedapn=${muiltdrb}

make WA with Samsung S21
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   2s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep   4s
    #####Samsung S21 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cygwin
    sleep    2s
    [Teardown]    csn.disconnect    connection=cygwin

Check wireshark log for 8700_D02_001
    Check gnb1 soure two slice    logname=${log_name_D_002_1}

Check gnb1 soure two slice
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File
    ...    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y_without}    alias=test6
    ${filter_expression}=    RUN KEYWORD IF    ${enb_instance} == ${enb_id}[3] or ${enb_instance} == ${enb_id}[5]    # TL348 or TL358
    ...    Catenate    (nas_5gs.cmn.dnn == "mdrb.nokia.com") and (nas_5gs.mm.mm_sd == 000001)
    ...    ELSE    Catenate    (nas_5gs.cmn.dnn == "mdrb.nokia.com") and (nas_5gs.mm.mm_sd == 128)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${mdrb_mm_sd}=     cap.Get Field Value By Xpath    xpath=.//nas_5gs.mm.mm_sd    pcap_parser=test6
    RUN KEYWORD IF    ${enb_instance} == ${enb_id}[3] or ${enb_instance} == ${enb_id}[5]    # TL348 or TL358
    ...    Should Contain    '${mdrb_mm_sd}'    1
    ...    ELSE    Should Contain    '${mdrb_mm_sd}'    128
    ${filter_expression}=     Catenate    (nas_5gs.cmn.dnn == "ims") and (nas_5gs.mm.mm_sd == 13714341)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ims_mm_sd}=     cap.Get Field Value By Xpath    xpath=.//nas_5gs.mm.mm_sd    pcap_parser=test6
    Should Contain    '${ims_mm_sd}'    13714341

Check wireshark log for 8700_D02_002
    Check gnb1 soure HandoverRequired and HandoverCommand PDU Session    logname=${log_name_D_002_2}

Check gnb1 soure HandoverRequired and HandoverCommand PDU Session
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ###HandoverRequired
    ${filter_expression}=     Catenate    (ngap.pDUSessionID == 1) and (ngap.id == 61)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${pDUSessionID1}=     cap.Get Field Value By Xpath    xpath=.//ngap.pDUSessionID    pcap_parser=test6
    Should Contain    '${pDUSessionID1}'    1
    ${filter_expression}=     Catenate    (ngap.pDUSessionID == 2) and (ngap.id == 61)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${pDUSessionID2}=     cap.Get Field Value By Xpath    xpath=.//ngap.pDUSessionID    pcap_parser=test6
    Should Contain    '${pDUSessionID2}'    2
    ###cause is radioNetwork: handover-desirable-for-radio-reason (16)
    ${filter_expression}=     Catenate        (ngap.radioNetwork == 16) and (ngap.procedureCode == 12)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_radioNetwork}=     cap.Get Field Value By Xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${ngap_radioNetwork[0]}    16
    ###HandoverCommand
    ###FOR IMS PDU SESSION -2 create success--- because target only config support SNSSAI sST = 01 / sD: d143a5；
    ${filter_expression}=     Catenate    (ngap.id == 59) and (ngap.pDUSessionID == 2)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${HandoverCommand_pDUSessionID2}=     cap.Get Field Value By Xpath    xpath=.//ngap.pDUSessionID    pcap_parser=test6
    Should Contain    '${HandoverCommand_pDUSessionID2}'    2
    ###FOR MRDB PDU SESSION -1 due to not support on gnb2，show PDUSessionResourceToReleaseListHOCmd
    #${filter_expression}=     Catenate    ngap.transport == 0 and ngap.pDUSessionID == 1
    #### for SRNSUP-132589
    ${filter_expression}=     Catenate    (ngap.radioNetwork == 7) && (ngap.pDUSessionID == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    #${ngap_transport}=     cap.Get Field Value By Xpath    xpath=.//ngap.transport   pcap_parser=test6
    ${ngap_radioNetwork}=     cap.Get Field Value By Xpath    xpath=.//ngap.radioNetwork   pcap_parser=test6
    #Should Be Equal    ${ngap_transport[0]}    0
    Should Be Equal    ${ngap_radioNetwork[0]}    7

Check wireshark log for 8700_D02_003
    Check target HandoverRequired PDU Session and PDU sessions with not supported S-NSSAI not admitted   logname=${log_name_D_002_3}

Check target HandoverRequired PDU Session and PDU sessions with not supported S-NSSAI not admitted
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ###HandoverRequest
    ${filter_expression}=     Catenate    (ngap.pDUSessionID == 1) and (ngap.PDUSessionResourceSetupListHOReq == 2)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${pDUSessionID1}=     cap.Get Field Value By Xpath    xpath=.//ngap.pDUSessionID    pcap_parser=test6
    Should Contain    '${pDUSessionID1}'    1
    ${filter_expression}=     Catenate    (ngap.pDUSessionID == 2) and (ngap.PDUSessionResourceSetupListHOReq == 2)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${pDUSessionID2}=     cap.Get Field Value By Xpath    xpath=.//ngap.pDUSessionID    pcap_parser=test6
    Should Contain    '${pDUSessionID2}'    2
    ###check HandoverRequest include two PDU SESSION 1/2 and cause is radioNetwork: handover-desirable-for-radio-reason (16)
    ${filter_expression}=     Catenate        (ngap.procedureCode == 13) and (ngap.radioNetwork == 16)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_radioNetwork}=     cap.Get Field Value By Xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${ngap_radioNetwork[0]}    16
    ###HandoverRequestAckknowledge
    ###PDU sessions with not supported S-NSSAI not admitted,Cause Group set to "Radio Network Layer" and Cause value set to "Slice(s) not supported"
    ${filter_expression}=     Catenate    (ngap.PDUSessionResourceAdmittedList == 1) and (ngap.pDUSessionID == 2)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${Ack_pDUSessionID2}=     cap.Get Field Value By Xpath    xpath=.//ngap.pDUSessionID    pcap_parser=test6
    Should Contain    '${Ack_pDUSessionID2}'    2
    ###check HandoverRequestAckknowledge slice not support
    ${filter_expression}=     Catenate       (ngap.pDUSessionID == 1) and (ngap.radioNetwork == 39) and (ngap.procedureCode == 13)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_radioNetwork}=     cap.Get Field Value By Xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${ngap_radioNetwork[0]}    39

Check wireshark log for 8700_D02_004
    Check VONR Normal release    logname=${log_name_D_002_4}

Check wireshark log for EDA_03533909_001
    Check soure HandoverRequired HandoverCommand PDU Session and UEContextReleaseRequest    logname=${log_name_EDA_03533909_2}

Check wireshark log for EDA_03533909_002
    Check VONR Normal release    logname=${log_name_EDA_03533909_3_2}

Check soure HandoverRequired HandoverCommand PDU Session and UEContextReleaseRequest
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ###HandoverRequired
    ${filter_expression}=     Catenate    (ngap.id == 61)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${pDUSessionID}=     cap.Get Field Value By Xpath    xpath=.//ngap.pDUSessionID    pcap_parser=test6
#    ${pDUSessionID}=    Evaluate    list(set(${pDUSessionID}))
    ${pDUSessionID}=    Remove Duplicates    ${pDUSessionID}
    ${length}=    Get Length    ${pDUSessionID}
    Should Be Equal As Integers    ${length}    2
    ###cause is radioNetwork: handover-desirable-for-radio-reason (16)
    ${filter_expression}=     Catenate        (ngap.radioNetwork == 16) and (ngap.procedureCode == 12)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_radioNetwork}=     cap.Get Field Value By Xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${ngap_radioNetwork[0]}    16
    ###HandoverCommand
    ${filter_expression}=     Catenate    (ngap.id == 59)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${HandoverCommand_pDUSessionID}=     cap.Get Field Value By Xpath    xpath=.//ngap.pDUSessionID    pcap_parser=test6
#    ${length}=    Get Length    ${HandoverCommand_pDUSessionID}
#    Should Be Equal As Integers    ${length}    2
    IF    ${enb_instance} == ${enb_id}[3]    #TL348
        ${length}=    Get Length    ${HandoverCommand_pDUSessionID}
        Should Be Equal As Integers    ${length}    2
    ELSE IF    ${enb_instance} == ${enb_id}[4]    #TL383
#        ${origin_length}=    Get Length    ${HandoverCommand_pDUSessionID}
#        ${HandoverCommand_pDUSessionIDs}    Remove Duplicates    ${HandoverCommand_pDUSessionID}
#        ${length}=    Get Length    ${HandoverCommand_pDUSessionIDs}
#        Should Be Equal As Integers    ${length}    2
#        ${multiple_times}    Evaluate    ${origin_length} / ${length}
#        Set Test Variable    ${multiple_times}
        ${length}=    Get Length    ${HandoverCommand_pDUSessionID}
        Should Be Equal As Integers    ${length}    2
    END
    # radioNetwork: tngrelocoverall-expiry (9)
    ${filter_expression}=     Catenate    (ngap.radioNetwork == 9)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_radioNetwork}=     cap.Get Field Value By Xpath    xpath=.//ngap.radioNetwork   pcap_parser=test6
    Should Be Equal    ${ngap_radioNetwork[0]}    9


Check wireshark log for 8700_B05_001
    Check gnb1 cell1 Multidrb    logname=${log_name_B_005_1}    message_filter1=${message_filter1}    message_filter2=${message_filter2}
    ...    message_filter3=${message_filter3}    message_filter4=${message_filter4}

Check wireshark log for 8700_B05_002
    RUN KEYWORD IF    ${enb_instance} == ${enb_id}[5] or ${enb_instance} == ${enb_id}[3]    #TL358 or TL348
    ...    Check EMC gnb1 cell1 to cell2 HO Measurement for TL358     logname=${log_name_B_005_2}
    ...    ELSE    Check EMC gnb1 cell1 to cell2 HO Measurement    logname=${log_name_B_005_2}
    Check EMC gnb1 cell1 to cell2 HO not success     logname=${log_name_B_005_2}

###cell1 to cell2 not contain UE Context Modification Request,RRC Reconfiguration IE
Check EMC gnb1 cell1 to cell2 HO not success
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${UeModify_req_filter}    Catenate    f1ap.procedureCode == 7 and nr-rrc.eventId == 2 and nr-rrc.physCellId == 38
    ${UeModify_req_packets}    cap.filter_packets_by_expression    filter_expression=${UeModify_req_filter}
    ${eventId}=    cap.get_field_value_by_xpath    pdml_list=${UeModify_req_packets}
    ...                                                xpath=.//nr-rrc.eventId
    should be empty    ${eventId}

Check EMC gnb1 cell1 to cell2 HO Measurement
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    f1ap.procedureCode == 13 and nr-rrc.physCellId == 38 and nr-rrc.measId == 6
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.physCellId    pcap_parser=test6
    Should Be Equal    ${ngap_fiveQI[0]}    38
    ${filter_expression}=     Catenate    f1ap.procedureCode == 13 and nr-rrc.physCellId == 40 and nr-rrc.measId == 6
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.physCellId    pcap_parser=test6
    Should Be Equal    ${ngap_fiveQI[1]}    40

Check EMC gnb1 cell1 to cell2 HO Measurement for TL358
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    f1ap.procedureCode == 13 and nr-rrc.physCellId == 38 and nr-rrc.measId == 6
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.physCellId    pcap_parser=test6
    Should Be Equal    ${ngap_fiveQI[0]}    38
    ${filter_expression}     Catenate    f1ap.procedureCode == 13 and nr-rrc.physCellId == 382 and nr-rrc.measId == 6
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.physCellId    pcap_parser=test6
    Should Be Equal    ${ngap_fiveQI[1]}    382

Check wireshark log for 8700_B05_003
    Check EMC gnb1 cell1 to cell3 HO Measurement    logname=${log_name_B_005_3}
    Check EMC gnb1 cell1 to cell3 HO not success    logname=${log_name_B_005_3}

###cell1 to cell3not contain UE Context Modification Request,RRC Reconfiguration IE
Check EMC gnb1 cell1 to cell3 HO not success
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${UeModify_req_filter}    Catenate    f1ap.procedureCode == 7 and nr-rrc.eventId == 2 and nr-rrc.physCellId == 38
    ${UeModify_req_packets}    cap.filter_packets_by_expression    filter_expression=${UeModify_req_filter}
    ${eventId}=    cap.get_field_value_by_xpath    pdml_list=${UeModify_req_packets}
    ...                                                xpath=.//nr-rrc.eventId
    should be empty    ${eventId}

Check EMC gnb1 cell1 to cell3 HO Measurement
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    f1ap.procedureCode == 13 and nr-rrc.physCellId == 38
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.physCellId    pcap_parser=test6
    Should Be Equal    ${ngap_fiveQI[0]}    38
    ${filter_expression}=     Catenate    f1ap.procedureCode == 13 and nr-rrc.physCellId == 383
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.physCellId    pcap_parser=test6
    Should Be Equal    ${ngap_fiveQI[1]}    383

Check wireshark log for 8700_B05_004
    Check EMC Normal release    logname=${log_name_B_005_4}

Check EMC Normal release
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    ngap.nas == 0 and ngap.procedureCode == 28
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_nas}=     cap.Get Field Value By Xpath    xpath=.//ngap.nas    pcap_parser=test6
    Should Be Equal    ${ngap_nas[0]}    0

Check VONR Normal release
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    (ngap.nas == 0) and (ngap.procedureCode == 26)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_nas}=     cap.Get Field Value By Xpath    xpath=.//ngap.nas    pcap_parser=test6
    Should Be Equal    ${ngap_nas[0]}    0

Check wireshark log for 8700_001
    Check gnb1 cell1 Multidrb    logname=${log_name_B_003_1}    message_filter1=${message_filter1}    message_filter2=${message_filter2}
    ...    message_filter3=${message_filter3}    message_filter4=${message_filter4}

Check gnb1 cell1 Multidrb
    [Arguments]    ${logname}    ${message_filter1}    ${message_filter2}    ${message_filter3}    ${message_filter4}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    ${message_filter1}
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//nas_5gs.sm.5qi    pcap_parser=test6
    Should Contain    '${ngap_fiveQI}'    9
    ${filter_expression}=     Catenate    ${message_filter2}
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//nas_5gs.sm.5qi    pcap_parser=test6
    Should Contain    '${ngap_fiveQI}'    6
    ${filter_expression}=     Catenate    ${message_filter3}
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//nas_5gs.sm.5qi    pcap_parser=test6
    Should Contain    '${ngap_fiveQI}'    8
    ${filter_expression}=     Catenate    ${message_filter4}
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//nas_5gs.sm.5qi    pcap_parser=test6
    Should Contain    '${ngap_fiveQI}'    7

Check wireshark log for 8700_002
    RUN KEYWORD IF    ${enb_instance} == ${enb_id}[5] or ${enb_instance} == ${enb_id}[3]     #TL358 or TL348
    ...    Check EMC gnb1 cell1 to cell2 HO Measurement for TL358     logname=${log_name_B_003_2}
    ...    ELSE    Check EMC gnb1 cell1 to cell2 HO Measurement    logname=${log_name_B_003_2}
#    Check gnb1 cell2 Measurement report message with intra gnb HO    logname=${log_name_B_003_2}    message_filter5=${message_filter5}
#    ...    message_filter6=${message_filter6}

Check gnb1 cell2 Measurement report message with intra gnb HO
    [Arguments]    ${logname}    ${message_filter5}    ${message_filter6}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    ${message_filter5}
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.physCellId    pcap_parser=test6
    Should Be Equal    ${ngap_fiveQI[0]}    38
    ${filter_expression}=     Catenate    ${message_filter6}
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.physCellId    pcap_parser=test6
    Should Be Equal    ${ngap_fiveQI[1]}    40

Check gnb1B003 the PM counter
    [Arguments]    ${counter_id}    ${dic_path}    ${timeout}=${300}
    sleep    30s
    ${counter_lenth}    Get Length    ${counter_id}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    FOR  ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM    dic_path=${dic_path[${index}]}
        ...    timeout=${timeout}
#        Should be true    ${counter_value}[0]    ${valueB003[${index}]}
        ${counter_latest}    get slice from list    ${counter_value}    0    3
        Should Contain    ${counter_latest}    ${valueB003[${index}]}
    END
    [Teardown]    COAM Teardown gnb connections

#Check gnb1B003 the PM counter
#    [Arguments]    ${counter_id}    ${dic_path}    ${counter_end}    ${timeout}=${300}
#    ${counter_lenth}    Get Length    ${counter_id}
#    Connect to gnb coam via ssl    bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
#    ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
#    ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
#    FOR  ${index}    IN RANGE    ${counter_lenth}
#        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM    dic_path=${dic_path[${index}]}
#        ...    timeout=${timeout}
#        ${counter_latest}    get slice from list    ${counter_value}    0    ${counter_end}
#        Should Contain    ${counter_latest}    ${valueB003[${index}]}
#    END
#    [Teardown]    COAM Teardown gnb connections

Check gnb1 the PM counter
    [Arguments]    ${counter_id}    ${dic_path}    ${timeout}=${300}
    sleep    30s
    ${counter_lenth}    Get Length    ${counter_id}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    FOR  ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM    dic_path=${dic_path[${index}]}
        ...    timeout=${timeout}
        Should be true    ${counter_value}[0]    ${value[${index}]}
    END
    [Teardown]    COAM Teardown gnb connections

#Check gnb1 the PM counter
#    [Arguments]    ${counter_id}    ${dic_path}    ${counter_end}    ${timeout}=${300}
#    sleep    30s
#    ${counter_lenth}    Get Length    ${counter_id}
#    Connect to gnb coam via ssl    bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
#    ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
#    ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
#    FOR  ${index}    IN RANGE    ${counter_lenth}
#        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM    dic_path=${dic_path[${index}]}
#        ...    timeout=${timeout}
#        ${counter_latest}    get slice from list    ${counter_value}    0    ${counter_end}
#        Should Contain    ${counter_latest}    ${value[${index}]}
#    END
#    [Teardown]    COAM Teardown gnb connections

Check gnb2 the PM counter
    [Arguments]    ${counter_id}    ${dic_path}    ${timeout}=${300}
    ${counter_lenth}    Get Length    ${counter_id}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[1].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[1].cu.oam_http_connection_details.password}
    FOR  ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM    dic_path=${dic_path[${index}]}
        ...    timeout=${timeout}
        Should be true    ${counter_value}[0]    ${value2[${index}]}
    END
    [Teardown]    COAM Teardown gnb connections

#Check gnb2 the PM counter
#    [Arguments]    ${counter_id}    ${dic_path}    ${counter_end}    ${timeout}=${300}
#    ${counter_lenth}    Get Length    ${counter_id}
#    Connect to gnb coam via ssl    bts_host=${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
#    ...    username=${tl.gnbs[1].cu.oam_http_connection_details.username}
#    ...    password=${tl.gnbs[1].cu.oam_http_connection_details.password}
#    FOR  ${index}    IN RANGE    ${counter_lenth}
#        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM    dic_path=${dic_path[${index}]}
#        ...    timeout=${timeout}
#        ${counter_latest}    get slice from list    ${counter_value}    0    ${counter_end}
#        Should Contain    ${counter_latest}    ${value2[${index}]}
#    END
#    [Teardown]    COAM Teardown gnb connections

Check common gnb the PM counter
    [Arguments]    ${counter_id}    ${gnb_index}    ${dic_path}    ${check_value}    ${timeout}=${300}
    ${counter_lenth}    Get Length    ${counter_id}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[1].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[1].cu.oam_http_connection_details.password}
    FOR  ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM    dic_path=${dic_path[${index}]}
        ...    timeout=${timeout}
        Should be true    ${counter_value}[0]    ${check_value[${index}]}
    END
    [Teardown]    COAM Teardown gnb connections

Check wireshark log for 8700_003
     Check wireshark log for 8700_003_support    logname=${log_name_B_003_1}
     Check gnb1 cell3 B003 dedicated checkpoint    logname=${log_name_B_003_3}    message_filter7=${message_filter7}
     ...    message_filter8=${message_filter8}         message_filter12=${message_filter12}        message_filter16=${message_filter16}
     ...    message_filter17=${message_filter17}

Check wireshark log for 8700_003_support
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    ngap.priorityLevelARP == 7 and ngap.procedureCode == 14
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//ngap.priorityLevelARP    pcap_parser=test6
    ${filter_expression}=     Catenate    ngap.priorityLevelARP == 7 and ngap.procedureCode == 29
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQIs}=     cap.Get Field Value By Xpath    xpath=.//ngap.priorityLevelARP    pcap_parser=test6
    ${passed}    Run Keyword And Return Status    Should Not Be Empty    ${ngap_fiveQI}
    Run Keyword If    ${passed}    Set Suite Variable    ${PriorityLevelARP_id}    ${ngap_fiveQI}
    ...    ELSE    Set Suite Variable    ${PriorityLevelARP_id}    ${ngap_fiveQIs}
    ${counter_lenth}    Get Length    ${PriorityLevelARP_id}
    FOR  ${index}    IN RANGE    ${counter_lenth}
        ${MIN_ARP_List}=    Run Keyword If    ${PriorityLevelARP_id[${index}]}<7    Set Variable     ${index}
        Run Keyword If    ${MIN_ARP_List}    Set Suite Variable    ${MIN_List}    ${MIN_ARP_List}
        ...    ELSE    sleep    1s
    END
    ${filter_expression}=     Catenate    e1ap.dRB_ID == 4 and e1ap.dRB_To_Setup_List_NG_RAN == 4 and e1ap.procedureCode == 8
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${e1ap_dRB_ID}=     cap.Get Field Value By Xpath    xpath=.//e1ap.dRB_ID    pcap_parser=test6
    ${filter_expression}=     Catenate    e1ap.dRB_ID == 5 and e1ap.dRB_To_Setup_Mod_List_NG_RAN == 4 and e1ap.procedureCode == 9
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${e1ap_dRB_IDs}=     cap.Get Field Value By Xpath    xpath=.//e1ap.dRB_ID    pcap_parser=test6
    ${passed}    Run Keyword And Return Status    Should Not Be Empty    ${e1ap_dRB_ID}
    Run Keyword If    ${passed}    Run Keywords    Set Suite Variable    ${e1ap_dRB_ID_List}    ${e1ap_dRB_ID}
    ...    AND    Remove Values From List    ${e1ap_dRB_ID_List}    ${e1ap_dRB_ID}[${MIN_List}]
    ...    ELSE    Run Keywords    Set Suite Variable    ${e1ap_dRB_ID_List}    ${e1ap_dRB_IDs}
    ...    AND    Remove Values From List    ${e1ap_dRB_ID_List}    ${e1ap_dRB_IDs}[${MIN_List}]
    Sort List    ${e1ap_dRB_ID_List}
    Set Suite Variable    ${e1ap_dRB_ID_List}

Check gnb1 cell3 B003 dedicated checkpoint
    [Arguments]    ${logname}    ${message_filter7}    ${message_filter8}    ${message_filter12}    ${message_filter16}    ${message_filter17}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ###check Intra HO Measurement report  physCellId source cell1 38 and target cell3 383
    ${filter_expression}=     Catenate    ${message_filter7}
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.physCellId    pcap_parser=test6
    Should Be Equal    ${ngap_fiveQI[0]}    38
    ${filter_expression}=     Catenate    ${message_filter8}
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.physCellId    pcap_parser=test6
    Should Be Equal    ${ngap_fiveQI[1]}    383
    ###check UE Context Modification Request Item 6 id-DRBs-ToBeReleased-List
    ${filter_expression}=     Catenate    f1ap.dRBID == 4 and f1ap.procedureCode == 7
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${f1ap_dRBID}=     cap.Get Field Value By Xpath    xpath=.//f1ap.dRBID    pcap_parser=test6
    ${f1ap_dRBID_last_3values}    get slice from list    ${f1ap_dRBID}    3     6
    Sort List    ${f1ap_dRBID_last_3values}
#    List Should Contain Sub List    ${ngap_fiveQI}   ${DRBs_ToBeReleased}
    Lists Should be Equal    ${f1ap_dRBID_last_3values}    ${e1ap_dRB_ID_List}
    ###check check Intra HO and release 3DRBs RRC reconfiguration
    ${filter_expression}=     Catenate    ${message_filter12}
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.physCellId    pcap_parser=test6
    Should Be Equal    ${ngap_fiveQI[0]}    383
    ${filter_expression}=     Catenate    nr-rrc.DRB_Identity == 4 and f1ap.procedureCode == 12
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.DRB_Identity    pcap_parser=test6
    ${filter_expression}=     Catenate    nr-rrc.DRB_Identity == 5 and f1ap.procedureCode == 12
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQIs}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.DRB_Identity    pcap_parser=test6
    ${passed}    Run Keyword And Return Status    Should Not Be Empty    ${ngap_fiveQI}
    Run Keyword If    ${passed}    Run Keywords    Sort List    ${ngap_fiveQI}
    ...    AND    Lists Should be Equal    ${ngap_fiveQI}    ${e1ap_dRB_ID_List}
    ...    ELSE    Run Keywords    Sort List    ${ngap_fiveQIs}
    ...    AND    Lists Should be Equal    ${ngap_fiveQIs}    ${e1ap_dRB_ID_List}
#    Sort List    ${ngap_fiveQI}
##    List Should Contain Sub List    ${ngap_fiveQI}   ${DRB_Identity}
##    List Should Contain Sub List    ${ngap_fiveQI}    ${e1ap_dRB_ID_Sort_List}
#    Lists Should be Equal    ${ngap_fiveQI}    ${e1ap_dRB_ID_List}
    ###check  RRC reconfiguration complete
    ${filter_expression}=     Catenate    ${message_filter16}
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.c1    pcap_parser=test6
    Should Be Equal    ${ngap_fiveQI[0]}    1
    ###check  PDU Session Resource Notify message
    ${filter_expression}=     Catenate    ${message_filter17}
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_radioNetwork}=     cap.Get Field Value By Xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${ngap_radioNetwork}    ${local_ngap_radioNetwork}
    ###check Intra HO UE Context Modification Request
    ${UeModify_req_filter}    Catenate    f1ap.procedureCode == 7 and nr-rrc.eventId == 2 and nr-rrc.physCellId == 38
    ${UeModify_req_packets}    cap.filter_packets_by_expression    filter_expression=${UeModify_req_filter}    pcap_parser=test6
    ${eventId}=    cap.get_field_value_by_xpath      xpath=.//nr-rrc.eventId    pcap_parser=test6
    Should Not Be Empty    ${eventId}
    ###check Intra HO UE Context Modification Response
    ${UeModify_res_filter}    Catenate    f1ap.protocolIEs == 5
    ${UeModify_res_packets}    cap.filter_packets_by_expression    filter_expression=${UeModify_res_filter}    pcap_parser=test6
    ${UeModify_res}    cap.get_field_value_by_xpath    xpath=.//f1ap.procedureCode    pcap_parser=test6
    Should Be Equal    ${UeModify_res[0]}    7
    ###check Bearer Context Setup Request/ Bearer Context Setup Response
    ${filter_expression}=     Catenate    e1ap.dRB_To_Remove_List_NG_RAN == 3 and e1ap.dRB_ID == 4
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//e1ap.dRB_To_Remove_List_NG_RAN//e1ap.dRB_ID   pcap_parser=test6
    Sort List    ${ngap_fiveQI}
    Lists Should be Equal    ${ngap_fiveQI}    ${e1ap_dRB_ID_List}
#    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//e1ap.dRB_ID   pcap_parser=test6
#    ${ngap_fiveQI_last_3values}    get slice from list    ${ngap_fiveQI}    3     6
#    Sort List    ${ngap_fiveQI_last_3values}
##    List Should Contain Sub List    ${ngap_fiveQI}   ${e1ap_dRB_ID}
#    Lists Should be Equal    ${ngap_fiveQI_last_3values}    ${e1ap_dRB_ID_List}

Repeat check voice call status with UE
    check voice call status    status=${2}
    sleep    1m

recover para and pa value
    paras change on BTS
        ...    paras=${CB008700_recover_ciphering_algorithms}
        ...    delta_file_name=${epc_log_path}${CB008700_recover_ciphering_algorithms_json_file}
    paras change on BTS
        ...    gnb_index=${1}
        ...    paras=${CB008700_recover_ciphering_algorithms_2}
        ...    delta_file_name=${epc_log_path}${CB008700_recover_ciphering_algorithms_json_file_2}
    IF    ${enb_instance} == ${enb_id}[3]    #TL348
        Online modify parmeters    parameters_to_update=${PARAM_recover_EDA_03533909}    skip_parameter_relation_errors=False
        Online modify parmeters    gnb_index=${1}    parameters_to_update=${PARAM_recover_EDA_03533909_2}    skip_parameter_relation_errors=False
        Online delete parmeters    gnb_index=${1}    parameters_to_update=${PARAM_DELETE_EDA_03533909_2}
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
    ELSE IF    ${enb_instance} == ${enb_id}[4]    #TL383
        Online modify parmeters    parameters_to_update=${PARAM_recover_EDA_03533909}    skip_parameter_relation_errors=False
        Online modify parmeters    gnb_index=${1}    parameters_to_update=${PARAM_recover_EDA_03533909_2}    skip_parameter_relation_errors=False
        Online delete parmeters    gnb_index=${1}    parameters_to_update=${PARAM_DELETE_EDA_03533909_2}
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
    END
