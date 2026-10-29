#*** Settings ***
#Documentation
#...    author: Shi Ming
#...    contact: ming.shi@nokia-sbell.com
#...    squal group: SG03
#...    feature: CB008200-B
#
#Force Tags  CA_5G_RRM    RAN_5G    RAN_5G_TDD    CLOUD_5G_CLASSICAL_ANDROID_ASIKL_ABILB1_AAHF_RF_SHARING_ENB
#...         STATE_SW_UPLOADED    PY36
#Suite Setup    Run Keywords    Setup Env for test    AND
##...                            Common Suite Setup for COAM    AND
#...                             Pre Condition    AND
#...                             Prepare with COAM classical BTS cell onair    tl_scf_filename=${tl_scf_filename}    AND
#...                            Common UE parameter setup
#
#Suite Teardown    Run Keyword    robot_common_operations.Common Suite Teardown
#
#
#Resource     Resources/CB008200_common_keywords.robot
#Variables    Resources/CB008200_variables.py
#Variables    Resources/CB008200_multi_gnb_variables.py
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
#
#
#*** Variables ***
#${log_name_B_001}    log_name_B_001.pcap
#${enb_log_name_B_001}    enb_log_name_B_001.pcap
#${log_name_B_002}    log_name_B_002.pcap
#${enb_log_name_B_002}    enb_log_name_B_002.pcap
#${log_name_B_003}    log_name_B_003.pcap
#${enb_log_name_B_003}    enb_log_name_B_003.pcap
#${log_name_B_007}    log_name_B_007.pcap
#${enb_log_name_B_007}    enb_log_name_B_007.pcap
#${log_name_B_008}    log_name_B_008.pcap
#${log_name_B_009}    log_name_B_009.pcap
#${log_name_B_010_1}    log_name_B_010_1.pcap
#${log_name_B_010_2}    log_name_B_010_2.pcap
#${log_name_B_010}    log_name_B_010.pcap
#${log_name_B_011_0}    log_name_B_011_0.pcap
#${log_name_B_011_1}    log_name_B_011_1.pcap
#${enb_log_name_B_011_1}    enb_log_name_B_011_1.pcap
#${log_name_B_011}    log_name_B_011.pcap
#${log_name_B_012}    log_name_B_012.pcap
#${log_name_B_012_1}    log_name_B_012_1.pcap
#${log_name_B_013_1}    log_name_B_013_1.pcap
#${log_name_B_013_2}    log_name_B_013_2.pcap
#${log_name_B_013_3}    log_name_B_013_3.pcap
#${log_name_A_021}    log_name_A_021.pcap
#${log_name_D_009}    log_name_D_009.pcap
#
#${log_name_784_A21}    log_name_784_A21_success.pcap
#${log_name_784_A21_2}    log_name_784_A21_fail.pcap
#${log_name_784_A11}    log_name_784_A11_fail.pcap
#${log_name_784_A11_1}    log_name_784_A11_epsfallback.pcap
#${log_name_784_A11_2}    log_name_784_A11_enb.pcap
#
#${nglogname1}    6112_A_13_UE2_attach.pcap
#${nglogname2}    6112_A_13_UE2_VONR.pcap
#${log_name_784_A01}        log_name_784_A01.pcap
#${log_name_784_A01_1st}    log_name_784_A01_1st.pcap
#${log_name_784_A01_2st}    log_name_784_A01_2st.pcap
#${log_name_7564_C05}       log_name_7564_C05.pcap
#${log_name_7564_C01}       log_name_7564_C01.pcap
#${enb_log_name_7564_C01}       enb_log_name_7564_C01.pcap
#${log_name_E_001_1}    log_name_E_001_1.pcap
#${log_name_E_001_2}    log_name_E_001_2.pcap
#
#${B_002_message_filter}    ngap.emergencyFallbackRequestIndicator == 0 or ngap.radioNetwork == 41
#
#${ue_type}    samsung
#
#${enb_instance}     ${tl.enbs[0].instance_id}
#@{enb_dist_name}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-3    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNMME-0
#@{enb_para}    administrativeState    ipAddrPrim
#@{enb_value}    unlocked    locked    10.107.245.164    10.110.194.171
#
#@{cell_id}    0    1    2    3    4    5
#@{multi_gnb_PA}    ${5}    ${26}    ${40}    ${0}    ${30}    ${127}
#@{PA_list}    0    30    45    127    25
#
#${log_name_A_21}    8700_A_21.pcap
#${command_template_with_Z}    {tshark_path} -r {pcap_file} -Y  \"(ngap or e1ap or f1ap or xnap or s1ap or x2ap)\"  -T pdml > log.pdml
#
#&{5QI_QoS_1}    5QI=3     RaNet=34
#&{5QI_QoS_2}    5QI=7     RaNet=22
#&{5QI_QoS_3}    5QI=9     RaNet=22
#
#${mdrbapn_cloud}    100    1340
#${wap2_APN_cloud}    100    1150
#${mdrbapn}    100    1430
#${wap2_APN}    100    1215
#${mdrbxjapn_cloud}    100    945
#${hostname}    ${tl.ues[0].ssh_connection_details.addr}
#${gnb_filter2}    ngap.procedureCode == 26 and ngap.fiveQI == 1
#${gnb_filter3}    f1ap.procedureCode == 7 and nr-rrc.drx_Config == 0 and nr-rrc.sn_FieldLength == 0
#${value3}    0
#${gnb_filter4}    e1ap.procedureCode == 9 and e1ap.dRB_Inactivity_Timer == 600
#${value4}    15
#
#${MPS}                   mps-PriorityAccess
#@{mps_value}        ${1}    ${1}    ${1}    ${1}
#@{ICS_mps}          ${1}    ${1}
#${ue_type}                  ${tl.ues[0].capabilities[0]}
#${dl_throughput}            50M
#${DL_TIME}                  9999
#${DL_LENGTH}                1024B
#${DL_PORT}                ${tl.ues[0].iperf_details.port}
#${dlexpect_tp}            50
#
#
#${Case_001_Log}    7564_001.pcap
#${Case_005_Log}    7564_005.pcap
#${counter_end}    5
#${counter_end_1}    10
#${4G_check}    True
#${case001_expected_value}    1
#${case005_expected_value}    1
#${BIP_log}    Case001_BIP
#@{value_A11_0}    ${0}
#@{expected_value_784A01_gnb1}   ${1}    ${1}   ${1}    ${2}    ${2}
#@{expected_value_784A01_gnb1_should_be_1}    ${1}    ${1}   ${1}    ${1}
#@{gnb_ips}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
#${tl_scf_filename}    SCF_SBTS00.xml
#${TS_CASE_SWCONFIG_PATH_cloud}    /home/ute/test_results/swconfig/
#${ute_log_path_cloud}    /home/ute/test_results/
#
#*** Test Cases ***
#[1]CB006112-A_13_Successful_setup_of_VoNR_call_with_FDD_support_short_RLC_SN_by_AES_ciphering
#    [Documentation]    Test case description the gNB behaviour for the successful setup of Voice over NR call with FDD by AMR-WB codec
#    [Tags]    CRT_TRUNK    SBTS00    CRT_UTE   CB006112-A
#    [Setup]    robot_common_operations.Common Case Setup
#    Online modify parmeters    parameters_to_update=${PARAM_6112_A_13}
#    set enb cell    value=@{enb_value}[1]
#    Start capture gNB log on slave    filename=${nglogname1}
#    Step1: UE attach    ue_type=${ue_type}
#    sleep    5s
#    Stop and download the Logs on slave    filename=${nglogname1}
#    sleep    2s
#    Start capture gNB log on slave    filename=${nglogname2}
#    Step2: UE setup VoNR call
#    sleep    20s
#    Step3: UE hang up VoNR call
#    sleep    2s
#    Stop and download the Logs on slave    filename=${nglogname2}
#    make WA with Samsung S21    ue_index=${0}
#    Step4: Detach UE    ue_type=${ue_type}
#    Check IE wireshark log for VONR setup      logname=${nglogname2}    message_filter=${gnb_filter2}
#    Check IE wireshark log for F1 configure    logname=${nglogname2}    message_filter=${gnb_filter3}     value=${value3}
#    Check IE wireshark log for E1_dRB_Inactivity configure    logname=${nglogname2}    message_filter=${gnb_filter4}     value=${value4}
#    [Teardown]     Run Keywords    robot_common_operations.Common Case Teardown    AND
#    ...    Run Keyword And Ignore Error    Stop and download the Logs on slave    filename=${nglogname1}    AND
#    ...    Run Keyword And Ignore Error    Stop and download the Logs on slave    filename=${nglogname2}    AND
#    ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${1}    ute_log_path=${epc_log_path}    AND
#    ...    Online modify parmeters    parameters_to_update=${PARAM_6112_recover_A_13}    AND
#    ...    set enb cell    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]CB008200_5G_B_F_SA_Accessibility_counter_001_QosFlow_Setup_Fail_due_to_Voice_Fallback_when_VoNR_disabled
#   [Documentation]  This User Scenario is to provide the counters used for measuring SA accessibility.
#   ...    The User scenario creates a counter to measure the number of QosFlows that failed to Setup
#   ...    due to Voice Fallback. The User scenario is a rerun of 5G_RAN_USR_RRM_1941 for the Fallback
#   ...    via redirection of voice call. Meanwhile, This User Scenario is also to provide the counters
#   ...    used for measuring SA retainability. The User scenario creates a counter to measure the number
#   ...    of QosFlows that were released due to Redirection where the release is initiated by gNB.
#   ...    The User scenario is a rerun of 5G_RAN_USR_RRM_1552 for Redirection of Voice call to LTE.
#   [Tags]    CB008200-B    CRT_TRUNK    SBTS00    CRT_UTE
#   [Timeout]    1 hour
#   [Setup]    robot_common_operations.Common Case Setup
#   Online modify parmeters    parameters_to_update=${PARAM_8200_B_001}
#   Online delete parmeters    parameters_to_update=${PARAM_DELETE_8200_B_001}
#   set enb cell    value=@{enb_value}[1]
#   Step1: UE attach    ue_type=${ue_type}
#   set enb cell
#   Prepare with PM counter time to caculate    period=start
#   Start capture gNB log on slave    filename=${log_name_B_001}
#   Start to collect the log on eNB    log_name=${enb_log_name_B_001}    interface=br1
#   Step2: UE setup VoNR call
#   sleep    20s
#   check voice call status    status=${2}
#   Stop and download the Logs on slave    filename=${log_name_B_001}
#   Step3: UE hang up VoNR call
#   check voice call status    status=${0}
#   Stop and download Logs on eNB    log_name=${enb_log_name_B_001}
#   Prepare with PM counter time to caculate    period=end
#   Check wireshark log for 001
#   Check counter for 001
#   [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#   ...    Step3: UE hang up VoNR call    AND    check voice call status    status=${0}    AND
#   ...    make WA with Samsung S21    ue_index=${0}    AND
#   ...    Step4: Detach UE    ue_type=${ue_type}    AND
#   ...    Run Keyword And Ignore Error    Stop and download the Logs on slave    filename=${log_name_B_001}    AND
#   ...    Run Keyword And Ignore Error    Stop and download Logs on eNB    log_name=${enb_log_name_B_001}    AND
#   ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${1}    ute_log_path=${epc_log_path}    AND
#   ...    set enb cell    AND
#   ...    Online modify parmeters    parameters_to_update=${PARAM_8200_recover_B_001}    AND
#   ...    Online add parmeters    parameters_to_update=${PARAM_ADD_8200_B_001}    AND
#   ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]CB008200_5G_B_F_SA_Accessibility_counter_003_QosFlow_Setup_Fail_due_to_Emergency_Fallback_via_redirection
#   [Documentation]    This User Scenario is to provide the counters used for measuring SA accessibility.
#   ...    The User scenario creates a counter to measure the number of QosFlows that failed to Setup
#   ...    due to emergency call Fallback. The User scenario is a rerun of 5G_RAN_USR_RRM_1941
#   ...    for the Fallback via redirection of emergency call and 5G_RAN_USR_RRM_3527 for Emergency Fallback.
#   [Tags]   CB008200-B
#   [Timeout]    1 hour
#   [Setup]
#   Online modify parmeters    parameters_to_update=${PARAM_8200_B_003}
#   Online delete parmeters    parameters_to_update=${PARAM_DELETE_8200_B_003}
#   set enb cell    value=@{enb_value}[1]
#   Step1: UE attach    ue_type=${ue_type}
#   set enb cell
#   Prepare with PM counter time to caculate    period=start
#   Start capture gNB log on slave    filename=${log_name_B_003}
#   Start to collect the log on eNB    log_name=${enb_log_name_B_003}
#   Step2: UE setup EMC call
#   sleep    20s
#   check voice call status    status=${2}
#   Step3: UE hang up EMC call
#   check voice call status    status=${0}
#   Stop and download the Logs on slave    filename=${log_name_B_003}
#   Stop and download Logs on eNB    log_name=${enb_log_name_B_003}
#   Prepare with PM counter time to caculate    period=end
#   Check wireshark log for 003
#   Check counter for 003
#   [Teardown]    Run Keywords    Step3: UE hang up EMC call    AND
#   ...    check voice call status    status=${0}    AND    Step4: Detach UE    ue_type=${ue_type}    AND
#   ...    Run Keyword And Ignore Error    Stop and download the Logs on slave    filename=${log_name_B_003}    AND
#   ...    Run Keyword And Ignore Error    Stop and download Logs on eNB    log_name=${enb_log_name_B_003}    AND
#   ...    set enb cell    AND
#   ...    Online modify parmeters    parameters_to_update=${PARAM_8200_recover_B_003}   AND
#   ...    Online add parmeters    parameters_to_update=${PARAM_ADD_8200_B_003}    AND
#   ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]CB008200_5G_B_F_SA_Accessibility_counter_007_QosFlow_Setup_Fail_due_to_Wrong_Message_from_Core_with_unsupported_QoS_combination
#    [Documentation]    This user scenario describes the gNB behaviour for the unsuccessful initiation of the
#    ...    VoNR/Emergency voice call for UE in idle state. If invalid QoS flow combination is NOT supported by gNB,
#    ...    then new QoS flow setup message will be rejected with cause 'invalid QoS Combination'. For detailed
#    ...    procedure refer to 5G_RAN_USR_RRM_2167 and 5G_RAN_USR_RRM_2154 Exception Scenario.
#    ...    Invalid QoS flow combination are as below:
#    ...    For one PDU session, normal QoS flow co-exist with emergency QoS flow. (3GPP 23.501 does not allow this case)
#    ...    For one emergency PDU session, there’s QoS flow other than 5QI 1/5.
#    ...    For one UE, there’re two ore more 5QI 1 QoS flows.
#    [Tags]    CB008200-B    CRT_TRUNK    SBTS00    CRT_UTE
#    [Timeout]    1 hour
#    [Setup]    robot_common_operations.Common Case Setup
#   Online modify parmeters    parameters_to_update=${PARAM_8200_B_007}
#    choice required APN on UE    usedapn=${mdrbxjapn_cloud}    ue_type=${ue_type}    ue_index=${0}
#    make WA with Samsung S21    ue_index=${0}
#    Exit the PCF service
#    Start PCF service    ims=${ims}    ip=${PCF_IP}
#    set enb cell    value=@{enb_value}[1]
#    Step1: UE attach    ue_type=${ue_type}
#    Prepare with PM counter time to caculate    period=start
#    Start capture gNB log on slave    filename=${log_name_B_007}
#    Configure and commit the QoS with 2 5QI1    five_qi=${five_qi}    priorityLevel1=${priorityLevel1}
#    ...    priorityLevel2=${priorityLevel2}    server_ip1=${server_ip1}    server_ip2=${server_ip2}
#    sleep    30s
#    Stop and download the Logs on slave    filename=${log_name_B_007}
#    Prepare with PM counter time to caculate    period=end
#    Check wireshark log for 007
#    Check counter for 007
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#    ...    choice required APN on UE    usedapn=${wap2_APN_cloud}    ue_type=${ue_type}    ue_index=${0}    AND
#    ...    make WA with Samsung S21    AND
#    ...    Step4: Detach UE    ue_type=${ue_type}    AND
#    ...    Run Keyword And Ignore Error    Stop and download the Logs on slave    filename=${log_name_B_007}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on eNB    log_name=${enb_log_name_B_007}    AND
#    ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${1}    ute_log_path=${epc_log_path}    AND
#    ...    set enb cell    AND
#    ...    Exit the PCF service    AND
#   ...    Online modify parmeters    parameters_to_update=${PARAM_8200_recover_B_007}    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]CB008200_5G_B_F_SA_Accessibility_counter_011_VoNR_QosFlow_Setup_when_Inter-RAT_HO_to_LTE
#    [Documentation]    This User Scenario is to provide the counters used for measuring SA accessibility.
#    ...    The User scenario creates a counter to measure the success ratio of QosFlows Setup due to incoming handovers.
#    ...    The User scenario is a rerun of multiple scenarios Inter-RAT HO from LTE (5G Control Plane - 5G_RAN_CP_12361454)
#    [Tags]    CB008200-B    CRT_TRUNK    SBTS00    CRT_UTE
#    [Timeout]    1 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    ${release_info}    Get sagnb release
#    Online modify parmeters    parameters_to_update=${PARAM_8200_B_011}
#    set enb MME IP    value=@{enb_value}[3]
#    set enb cell    value=@{enb_value}[1]
#    ####set gnb1 cell1 PA to 0
#    Recover HBTE attenuation to trigger RLF
#    Start capture gNB log on slave    filename=${log_name_B_011_0}
#    Step1: UE attach    ue_type=${ue_type}    ue_index=${1}
#    Stop and download the Logs on slave    filename=${log_name_B_011_0}
#    set enb cell
#    Start capture gNB log on slave    filename=${log_name_B_011}
#    Step2: UE setup VoNR call    ue_index=${1}
#    sleep    20s
#    check voice call status    ue_index=${1}    status=${2}
#    Stop and download the Logs on slave    filename=${log_name_B_011}
#    Prepare with PM counter time to caculate    period=start
#    Start capture gNB log on slave    filename=${log_name_B_011_1}
#    Start to collect the log on eNB    log_name=${enb_log_name_B_011_1}    interface=br1
#    ###set gnb1 cell1 PA to target value
#    Set HBTE attenuation    target_value=@{PA_list}[1]
#    sleep    30s
#    Stop and download the Logs on slave    filename=${log_name_B_011_1}
#    Stop and download Logs on eNB    log_name=${enb_log_name_B_011_1}
#    Prepare with PM counter time to caculate    period=end
#    Check wireshark log for 011
#   Run keyword if    '${release_info}' == '@{branch}[0]'    Check trunk counter for 011
#   ...    ELSE    Check counter for 011
#   Check counter for 011
#    Check trunk counter for 011
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#    ...    Step3: UE hang up VoNR call    ue_index=${1}    AND    check voice call status    ue_index=${1}    status=${0}    AND
#    ...    make WA with Samsung S21    ue_index=${1}    AND
#    ...    Step4: Detach UE    ue_type=${ue_type}    ue_index=${1}    AND
#    ...    Run Keyword And Ignore Error    Stop and download the Logs on slave    filename=${log_name_B_011_0}    AND
#    ...    Run Keyword And Ignore Error    Stop and download the Logs on slave    filename=${log_name_B_011}    AND
#    ...    Run Keyword And Ignore Error    Stop and download the Logs on slave    filename=${log_name_B_011_1}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on eNB    log_name=${enb_log_name_B_011_1}    AND
#    ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${1}    ute_log_path=${epc_log_path}    AND
#    ...    Online modify parmeters    parameters_to_update=${PARAM_8200_recover_B_011}    AND
#    ...    set enb MME IP    AND    set enb cell    AND
#    ...    Recover HBTE attenuation to trigger RLF    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]CB008200_5G_B_F_SA_Accessibility_counter_013_VoNR_QosFlow_Setup_Attempts_Success_and_release_in_normal_case
#   [Documentation]    This User Scenario is to provide the counters used for measuring SA accessibility.
#   ...    The User sceario creates a counter to measure the number of VoNR QosFlows that attempt to be Setup by the NG.
#   ...    The User scenario is the same as US5GC000786-A#B1 (5G_RAN_USR_RRM_2191) with some modifications.
#   ...    This User Scenario is to provide the counters used for measuring SA accessibility.
#   ...    The User sceario creates a counter to measure the number of VoNR QosFlows that successfully setup by the gNB.
#   ...    The User scenarios of US5GC000786-A#B1 (5G_RAN_USR_RRM_2191) can be re-used here with some modifications.
#   ...    The User scenario creates a counter to measure the number of AMF initiated QosFlows that were released
#   ...    due to no error expected scenario.
#   [Tags]    CB008200-B
#   [Timeout]    1 hour
#   [Setup]
#   Online modify parmeters    parameters_to_update=${PARAM_8200_B_013}
#   set enb cell    value=@{enb_value}[1]
#   Prepare with PM counter time to caculate    period=start
#   Start capture gNB log on slave    filename=${log_name_B_013_1}
#   Step1: UE attach    ue_type=${ue_type}
#   Stop and download the Logs on slave    filename=${log_name_B_013_1}
#   Prepare with PM counter time to caculate    period=end
#   Check wireshark log for 013
#   Check counter for 013_1
#   Prepare with PM counter time to caculate    period=start
#   Start capture gNB log on slave    filename=${log_name_B_013_3}
#   Step2: UE setup VoNR call
#   sleep    20s
#   check voice call status    status=${2}
#   Stop and download the Logs on slave    filename=${log_name_B_013_3}
#   Prepare with PM counter time to caculate    period=end
#   Check wireshark log for 013_3
#   Check counter for 013_3
#   Repeat Keyword    5 times    Repeat check voice call status with UE
#   Prepare with PM counter time to caculate    period=start
#   Start capture gNB log on slave    filename=${log_name_B_013_2}
#   Step3: UE hang up VoNR call
#   check voice call status    status=${0}
#   Stop and download the Logs on slave    filename=${log_name_B_013_2}
#   Prepare with PM counter time to caculate    period=end
#   Check wireshark log for 013_2
#   Check counter for 013_2
#   [Teardown]    Run Keywords    Step3: UE hang up VoNR call    AND    check voice call status    status=${0}    AND
#   ...    Step4: Detach UE    ue_type=${ue_type}    AND
#   ...    Run Keyword And Ignore Error    Stop and download the Logs on slave    filename=${log_name_B_013_1}    AND
#   ...    Run Keyword And Ignore Error    Stop and download the Logs on slave    filename=${log_name_B_013_2}    AND
#   ...    Run Keyword And Ignore Error    Stop and download the Logs on slave    filename=${log_name_B_013_3}    AND
#   ...    set enb cell    AND
#   ...    Online modify parmeters    parameters_to_update=${PARAM_8200_recover_B_013}    AND
#   ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]CB008700-A_021_Counter_ICS_when_ARP_based_admission_control_enabled_with_Data_PDU_Session_including_not_supported_QoS
#    [Documentation]    This user scenario describes Initial Context Setup procedure where AMF requests one or more PDU
#    ...    sessions and needed count of DRBs is not available.This use case does not describe a scenario where AMF requests
#    ...    initial context setup containing both Ue Radio Capabilities and PDU Session(s).Such scenario has been optimised
#    ...    by 3GPP and required dedicated user scenario for better readability.
#    ...    See USBasicCall-C#B2: Initial Context Setup with one or multiple PDU sessions (with UE Radio Capability)
#    [Tags]    CB008700-A    CRT_TRUNK    SBTS00    CRT_UTE
#    [Timeout]    1 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Prepare UE settings    ue_type=${ue_type}
#    Online modify parmeters    parameters_to_update=${PARAM_8700_A_021}
#    set enb cell    value=@{enb_value}[1]
#    Prepare with PM counter time to caculate    period=start
#    Start capture gNB log on slave    filename=${log_name_A_21}
#    UE attach then enable data    ue_type=${ue_type}
#    Stop and download the Logs on slave    filename=${log_name_A_21}
#    Prepare with PM counter time to caculate    period=end
#    Check wireshark log for 8700_A_021    logname=${log_name_A_21}
#    Check counter for 8700_A_021
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#    ...    Recover APN   AND
#    ...    make WA with Samsung S21    ue_index=${0}    AND
#	...    Step4: Detach UE    ue_type=${ue_type}    AND
#    ...    Run Keyword And Ignore Error    Stop and download the Logs on slave    filename=${log_name_A_21}    AND
#    ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${1}    ute_log_path=${epc_log_path}    AND
#    ...    set enb cell    AND
#    ...    Online modify parmeters    parameters_to_update=${PARAM_8700_recover_A_021}    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]CB008698-A_001_ICS_when_gNB_operates_in_SA_mode_UserPreemption_enable_with_EMC_successfully_due_to_enought_emergency_resource
#    [Documentation]    This user scenario describes Initial Context Setup procedure where AMF requests
#    ...    for PDU sessions(emergency resource available,UE initiates the call with RRC-establishmentCause=emergency)
#    [Tags]    CB008698-A    CRT_TRUNK    SBTS00    CRT_UTE
#    [Timeout]    1 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Online modify parmeters    parameters_to_update=${PARAM_8698_A_001}
#    set enb cell    value=@{enb_value}[1]
#    ####set gnb1 cell1 PA to 0
#    Recover HBTE attenuation to trigger RLF
#    Step1: UE attach    ue_type=${ue_type}
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#    ...    make WA with Samsung S21    ue_index=${0}    AND
#    ...    Step4: Detach UE    ue_type=${ue_type}    AND
#    ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${1}    ute_log_path=${epc_log_path}    AND
#    ...    Online modify parmeters    parameters_to_update=${PARAM_8698_recover_A_001}    AND
#    ...    set enb cell    AND
#    ...    Recover HBTE attenuation to trigger RLF    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]CB008698-C_004_ICSR_with_PDU_session_based_on_EC_DRB_preemption_SA_numOfRadioResReservForTempUse_not_fully_used
#    [Documentation]    This user scenario describes Initial Context Setup procedure where AMF requests for PDU sessions
#    [Tags]    CB008698-C    CRT_TRUNK    SBTS00    CRT_UTE
#    [Timeout]    1 hour
#    [Setup]    robot_common_operations.Common Case Setup
#   Online add parmeters    parameters_to_update=${PARAM_ADD_8698_C_004}
#   Online modify parmeters    parameters_to_update=${PARAM_8698_C_004}
#    set enb cell    value=@{enb_value}[1]
#    ####set gnb1 cell1 PA to 0
#    Recover HBTE attenuation to trigger RLF
#    Step1: UE attach    ue_type=${ue_type}
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#    ...    make WA with Samsung S21    ue_index=${0}    AND
#    ...    Step4: Detach UE    ue_type=${ue_type}    AND
#    ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${1}    ute_log_path=${epc_log_path}    AND
#    ...    set enb cell    AND
#    ...    Recover HBTE attenuation to trigger RLF    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#
#[1]CB008232_A_021_ICS_with_PDU_session_success_with_DRBs_reach_maxNumOfNonGBRBearersSA_and_maxNumOfGBRBearersSA_without_preemption_candidate
#    [Documentation]    RRC connection setup can be successful with priority access cause=MPS when only PA resource headroom is available
#    [Tags]    CB008232-A    CRT_TRUNK    SBTS00    CRT_UTE
#    [Timeout]    1 hour
#    [Setup]     robot_common_operations.Common Case Setup
#    Online add parmeters    parameters_to_update=${PARAM_8232_A_021_ADD}
#    Online modify parmeters    parameters_to_update=${PARAM_8232_A_021}
#    set enb cell    value=@{enb_value}[1]
#    Start capture gNB log on slave    filename=${log_name_A_021}
#    Step1: UE attach    ue_type=${ue_type}
#    Stop and download the Logs on slave    filename=${log_name_A_021}
#    Check PM counter for 8232    counter_id=${counter_id_mps}    counter_dic_path=${Trunk_counter_dic_path_mps_GNB1CELL1}
#    ...                          counter_should_value=${mps_value}
#   Check PM counter for 8232    counter_id=${counter_id_mps}    counter_dic_path=${counter_dic_path_mps_GNB1CELL1}
#   ...                          counter_should_value=${mps_value}
#    Check EstablishmentCause from RRC_Setup_Request    file_path=${epc_log_path}${log_name_A_021}    EstablishmentCause_value=${MPS}
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#    ...    make WA with Samsung S21    ue_index=${0}    AND
#    ...    Step4: Detach UE    ue_type=${ue_type}    AND
#    ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${1}    ute_log_path=${epc_log_path}    AND
#    ...    Online delete parmeters    parameters_to_update=${PARAM_8232_delete_A_021}    AND
#    ...    Online modify parmeters    parameters_to_update=${PARAM_8232_recover_A_021}    AND
#    ...    set enb cell    AND
#    ...    Recover HBTE attenuation to trigger RLF    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]CB008232_D_009_SIB1_PRACH_prioritization_with_raPriorityForAccessId=MPS+MCS
#    [Documentation]    RRC connection setup can be successful with priority access cause=MPS when only PA resource headroom is available
#    [Tags]    CB008232-A    CRT_TRUNK    SBTS00    CRT_UTE
#    [Timeout]    1 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Online add parmeters    parameters_to_update=${D_009_ADD_Para}
#    Online modify parmeters    parameters_to_update=${D_009_Modify_Online}
#    NRCellid Set suit varaible for special tl    cellid=${1}
#    set enb cell    value=@{enb_value}[1]
#    Start capture gNB log on slave    filename=${log_name_D_009}
#    Step1: UE attach    ue_type=${ue_type}
#    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=${DL_TIME}
#    ...    dl_length=${DL_LENGTH}    dl_port=${DL_PORT}    ue_index=${0}    process_num=${1}    ue_type=${ue_type}     cap_index=${1}
#    Stop and download the Logs on slave    filename=${log_name_D_009}
#    DL Tput collect and check with nrcellid    cellid=${nrcellid}    dlexpect_tp=${dlexpect_tp}    duration=1m    ue_type=${ue_type}
#    Check PM counter for 8232    counter_id=${counter_id_ICS_mps}    counter_dic_path=${Trunk_counter_dic_path_ICS_mps_GNB1CELL1}
#    ...                          counter_should_value=${ICS_mps}
#   Check PM counter for 8232    counter_id=${counter_id_ICS_mps}    counter_dic_path=${counter_dic_path_ICS_mps_GNB1CELL1}
#   ...                          counter_should_value=${ICS_mps}
#    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${DL_PORT}
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#    ...    make WA with Samsung S21    ue_index=${0}    AND
#    ...    Step4: Detach UE    ue_type=${ue_type}    AND
#    ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${1}    ute_log_path=${epc_log_path}    AND
#    ...    Online delete parmeters    parameters_to_update=${PARAM_8232_delete_D_009}    AND
#    ...    Online modify parmeters    parameters_to_update=${PARAM_8232_recover_D_009}    AND
#    ...    set enb cell    AND
#    ...    Recover HBTE attenuation to trigger RLF    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]CB007564_5G-C_001_CFRA_for_initial_access_sent_preambles
#    [Documentation]    The User scenario to count the Number of times dedicated preambles are sent to Ue for initial.
#    [Tags]    CRT_TRUNK    CB007564    SBTS00    CRT_UTE
#    [Setup]     robot_common_operations.Common Case Setup
#    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_CB007564_01_1}
#    Prepare with PM counter time to caculate    period=start
#    Start capture gNB log on slave    filename=${log_name_7564_C01}
#    Start to collect the log on eNB    log_name=${enb_log_name_7564_C01}    interface=br1
#    Collect Interface Mirroring Bip Collector
#     ...    gnb_index=${0}    target_dir=${epc_log_path}    times=1s
#    ${biplog}    Get Bip Log Via Interface Mirroring Collector To UTE    target_dir=${epc_log_path}
#    Stop and download Logs on eNB    log_name=${enb_log_name_7564_C01}
#    Stop and download the Logs on slave    filename=${log_name_7564_C01}
#    Prepare with PM counter time to caculate    period=end
#    Check counter for 7564_C001
#    Check the 7564_C001 wireshark log    logname=${log_name_7564_C01}
#    Check the webUI BIP log    biplog=${biplog[0]}
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#    ...    make WA with Samsung S21    ue_index=${0}    AND
#    ...    Step4: Detach UE    ue_type=${ue_type}    AND
#    ...    Run Keyword And Ignore Error    Stop and download the Logs on slave    filename=${log_name_7564_C01}    AND
#    ...    Run Keyword And Ignore Error    Stop and download the Logs on slave    filename=${enb_log_name_7564_C01}    AND
#    ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${1}    ute_log_path=${epc_log_path}    AND
#    ...    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_CB007564_01_1_recover}    AND
#    ...    Recover HBTE attenuation to trigger RLF    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]CB007564_5G-C_005_CBRA_for_initial_access_success
#    [Documentation]    The User scenario count the Number of time RA setup is sucessful and the contention is resolved by UL grant
#    ...    addressed to its CRNTI
#    [Tags]    CRT_TRUNK    CB007564    SBTS00    CRT_UTE
#    [Setup]    robot_common_operations.Common Case Setup
#    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_CB007564_05_1}
#    Prepare with PM counter time to caculate    period=start
#    Start capture gNB log on slave   filename=${log_name_7564_C05}
#    Step1: UE attach    ue_type=${ue_type}    4G_check=${True}
#    sleep    5s
#    Stop and download the Logs on slave    filename=${log_name_7564_C05}
#    Prepare with PM counter time to caculate    period=end
#    Check counter for 7564_C005
#    Check the 7564_C005 wireshark log    logname=${log_name_7564_C05}
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#    ...    make WA with Samsung S21    ue_index=${0}    AND
#    ...    Step4: Detach UE    ue_type=${ue_type}    AND
#    ...    Run Keyword And Ignore Error    Stop and download the Logs on slave    filename=${log_name_7564_C05}    AND
#    ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${1}    ute_log_path=${epc_log_path}    AND
#    ...    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_CB007564_05_1_recover}    AND
#    ...    Recover HBTE attenuation to trigger RLF    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]5GC000784_A_21_Verify_ongoing_EC_should_not_be_impact_after_online_change_actIMSEmergency_to_deactivate_2UE
#    [Documentation]
#    [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
#    [Setup]     robot_common_operations.Common Case Setup
#    set enb cell    value=@{enb_value}[1]
#    Online modify parmeters    parameters_to_update=${PARAMETERS_TO_UPDATE_A21_preparation}
#    Step1: UE attach    ue_type=${ue_type}
#    Online modify parmeters    parameters_to_update=${PARAMETERS_TO_UPDATE_A21_1}
#    Make a EC_Modify param_check EC ongoing    nglogname=${log_name_784_A21}
#    ...    parameters_to_update=${PARAMETERS_TO_UPDATE_A21_2}
#    Make a failed EC and check procedure    nglogname=${log_name_784_A21_2}    check_5QI=5
#    Check wireshark log for EC ongoing    logname=${log_name_784_A21}
#
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#    ...    make WA with Samsung S21    ue_index=${0}    AND
#    ...    Step4: Detach UE    ue_type=${ue_type}    AND
#    ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${1}    ute_log_path=${epc_log_path}    AND
#    ...    Online modify parmeters    parameters_to_update=${PARAM_784_recover_A21}    AND
#    ...    set enb cell    AND
#    ...    Recover HBTE attenuation to trigger RLF    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]5GC000784_A_11_Verify_EC_redirect_to_LTE_due_to_ICS_with_5QI5_CU_RAC_failed_and_Verify_emergencyCallFails
#    [Documentation]
#    [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
#    [Setup]    robot_common_operations.Common Case Setup
#    set enb cell    value=@{enb_value}[1]
#    Online modify parmeters    parameters_to_update=${PARAMETERS_TO_UPDATE_A11_preparation}
#    Online modify parmeters    parameters_to_update=${PARAMETERS_TO_UPDATE_COUNTER}
#    Step1: UE attach    ue_type=${ue_type}
#    Online modify parmeters    parameters_to_update=${PARAMETERS_TO_UPDATE_A11_1}
#    Make a failed EC and check procedure    nglogname=${log_name_784_A11}    check_5QI=1
#    Step4: Detach UE    ue_type=${ue_type}
#    Online modify parmeters    parameters_to_update=${PARAMETERS_TO_UPDATE_A11_2}
#    Step1: UE attach    ue_type=${ue_type}
#    Online modify parmeters    parameters_to_update=${PARAMETERS_TO_UPDATE_A11_1}
#    set enb cell    value=@{enb_value}[0]
#    Prepare with PM counter time to caculate    period=start
#    Make a EC and check EPS fallback    logname=${log_name_784_A11_1}    logname_1=${log_name_784_A11_2}
#    Prepare with PM counter time to caculate    period=end
#    sleep    40s
#    Check the PM counter shuould not be zero    counter_id=${counter_id_A11_1}    dic_path=${Trunk_counter_dic_path_A11_1}
#    Check the PM counter should be value
#    ...    counter_id=${counter_id_A11_0}    dic_path=${Trunk_counter_dic_path_A11_0}    value=${value_A11_0}
#   Check the PM counter shuould not be zero    counter_id=${counter_id_A11_1}    dic_path=${counter_dic_path_A11_1}
#   Check the PM counter should be value
#   ...    counter_id=${counter_id_A11_0}    dic_path=${counter_dic_path_A11_0}    value=${value_A11_0}
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#    ...    make WA with Samsung S21    ue_index=${0}    AND
#    ...    Step4: Detach UE    ue_type=${ue_type}    AND
#    ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${1}    ute_log_path=${epc_log_path}    AND
#    ...    Online modify parmeters    parameters_to_update=${PARAM_784_recover_A11}    AND
#    ...    set enb cell    AND
#    ...    Recover HBTE attenuation to trigger RLF    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]5GC000784_A_01_Verify_successful_EC_setup_UE_in_connected_state_with_ongoing_data_service_via_different_NGAP_procedure
#    [Documentation]    The User scenario count the Number of time RA setup is sucessful and the contention is resolved by UL grant
#    ...    addressed to its CRNTI
#    [Tags]    CRT_TRUNK    CB007564    SBTS00    CRT_UTE
#    [Setup]
#    robot_common_operations.Common Case Setup
#    set enb cell    value=@{enb_value}[1]
#    Online modify parmeters    parameters_to_update=${PARAMETERS_TO_UPDATE_A01_pre}
#   Online modify parmeters    parameters_to_update=${PARAMETERS_TO_UPDATE_COUNTER}
#    Start capture gNB log on slave    filename=${log_name_784_A01}
#    Step1: UE attach    ue_type=${ue_type}
#    sleep    5s
#    Stop and download the Logs on slave    filename=${log_name_784_A01}
#    Online modify parmeters    parameters_to_update=${PARAMETERS_TO_UPDATE_A01}
#    Make a EC and check successful procedure    filename=${log_name_784_A01_1st}
#    sleep    5s
#    Prepare with PM counter time to caculate    period=start
#    Make a EC and check successful procedure    filename=${log_name_784_A01_2st}
#    Prepare with PM counter time to caculate    period=end
#    Check counter for A01
#   Check the PM counter shuould be specific value    value=${1}
#   ...    counter_id=${counter_id_A01_should_be_1}    dic_path=${counter_dic_path_A01_should_be_1}
#   Check the PM counter shuould not zero    counter_id=${counter_id_A01_not_zero}    dic_path=${counter_dic_path_A01_not_zero}    value=${1}
#    [Teardown]    run keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    make WA with Samsung S21    ue_index=${0}    AND
#    ...    Step4: Detach UE    ue_type=${ue_type}    AND
#    ...    Run Keyword And Ignore Error    Stop and download the Logs on slave    filename=${log_name_784_A01}    AND
#    ...    Run Keyword And Ignore Error    Stop and download the Logs on slave    filename=${log_name_784_A01_1st}    AND
#    ...    Run Keyword And Ignore Error    Stop and download the Logs on slave    filename=${log_name_784_A01_2st}    AND
#    ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${1}    ute_log_path=${epc_log_path}    AND
#    ...    Online modify parmeters    parameters_to_update=${PARAMETERS_TO_UPDATE_A01_pre_recover}    AND
#    ...    set enb cell    AND
#    ...    Recover HBTE attenuation to trigger RLF    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#[1]CB008200_5G_E_SA_Utilization_counter_001_Average_Peak_Number_of_Connected_5QI-1_UEs
#    [Documentation]    This User Scenario is aimed at defining the Average Number of SA 5QI-1 Ues
#    ...    connected in the network. The counter uses the logic of ref. 5G_CP_ARC_ALG_370.
#    [Tags]    CB008200-C    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4
#    [Timeout]    1 hour
#    [Setup]    robot_common_operations.Common Case Setup
##   Online modify parmeters    parameters_to_update=${PARAM_8200_E_001}
#    set enb cell    value=@{enb_value}[1]
#    ####set gnb1 cell1 PA to 0
##   Recover attenuation to trigger
#    Step1: UE attach    ue_type=${ue_type}
#    Step1: UE attach    ue_type=${ue_type}    ue_index=${1}
#    make WA with Samsung S21    ue_index=${1}
#    Prepare with PM counter time to caculate    period=start
#    Start capture gNB log on slave    filename=${log_name_E_001_1}
#    Step2: UE setup VoNR call
#    sleep    20s
#    check voice call status    status=${2}
#    Stop and download the Logs on slave    filename=${log_name_E_001_1}
#    Start capture gNB log on slave    filename=${log_name_E_001_2}
#    Step2: UE setup VoNR call    ue_index=${1}
#    sleep    20s
#    check voice call status    ue_index=${1}    status=${2}
#    Stop and download the Logs on slave    filename=${log_name_E_001_2}
#    Prepare with PM counter time to caculate    period=end
#    Check counter for E001_1
#    Prepare with PM counter time to caculate    period=start
#    Repeat Keyword    5 times    Repeat check voice call status
#    Prepare with PM counter time to caculate    period=end
#    Check counter for E001_2
#    Prepare with PM counter time to caculate    period=start
#    check voice call status    status=${2}
#    check voice call status    ue_index=${1}    status=${2}
#    Step3: UE hang up VoNR call
#    make WA with Samsung S21    ue_index=${0}
#    Step3: UE hang up VoNR call    ue_index=${1}
#    make WA with Samsung S21    ue_index=${1}
#    sleep    20s
#    check voice call status    status=${0}
#    check voice call status    ue_index=${1}    status=${0}
#    Prepare with PM counter time to caculate    period=end
#    Check counter for E001_3
#    Check wireshark log for E001
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#    ...    Step3: UE hang up VoNR call    AND    check voice call status    status=${0}    AND
#    ...    make WA with Samsung S21    ue_index=${0}    AND
#    ...    Step4: Detach UE    ue_type=${ue_type}    AND
#    ...    Step3: UE hang up VoNR call    ue_index=${1}    AND    check voice call status    ue_index=${1}    status=${0}    AND
#    ...    make WA with Samsung S21    ue_index=${1}    AND
#    ...    Step4: Detach UE    ue_type=${ue_type}    ue_index=${1}    AND
#    ...    Run Keyword And Ignore Error    Stop and download the Logs on slave    filename=${log_name_E_001_1}    AND
#    ...    Run Keyword And Ignore Error    Stop and download the Logs on slave    filename=${log_name_E_001_2}    AND
#    ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${1}    ute_log_path=${epc_log_path}    AND
##   ...    Online modify parmeters    parameters_to_update=${PARAM_8200_recover_E_001}    AND
#    ...    set enb cell    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#*** Keywords ***
##GNB BTS Precondition ##
#Prepare with COAM classical BTS cell onair
#    [Arguments]    ${tl_scf_filename}=${tl_scf_filename}
#    Common Case TestLine Setup    Is_Swconfig=True    is_commission=True
#    ...    swconfig_file=${SWCONFIG_DEFAULT_FILE_PATH}    swconfig_target_path=${TS_CASE_SWCONFIG_PATH}
#    ...    scf_path=${tl_scf_dir_path}    golden_scf_name=${tl_scf_filename}
#    Wait until keyword succeeds    15min   30s    Check the COAM gnb RU status ready
#    sleep    30s
#    Wait Until Keyword Succeeds    5 min    30 sec     Check the cells status on air    bts_host=${bts_host}
#    ...    connection=gnb
#
#Pre Condition
#    [Documentation]    Author: Ren Biyao
#    ...    This keyword will set the default path for scf which will be used for ute cloud or lightweight CI.
#    [Timeout]    20 min
#    [Arguments]
#    ${SCF_PATH}     Get Substring    ${CURDIR}  0  24
#    ${TL_NAME}   set variable if      '${testline_name}' == 'null'    ${CONFIGURATION}    ${testline_name}
#    ${pattern}   Set Variable    7_5(.*)
#    ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
#    ${testlinename}   Set Variable    7_5@{TLNAME}[0]
#    ${CONFIGURATION}    Get Variable Value    ${CONFIGURATION}
#    set suite variable     ${CONFIGURATION}
#    set suite variable     ${SCF_PATH}
#    set suite variable     ${testlinename}
#    Connect to Common Unit Master    alias=ASIK Master
#    Default directory for ute cloud
#   run keyword if    '${CONFIGURATION}' != '${None}' and '${CONFIGURATION}' != 'null'
#   ...    Default directory for ute cloud
#   ...    ELSE    Default directory for lightweight ci
#
#Default directory for ute cloud
#    [Documentation]    Author: Ren Biyao
#    ...     Description: default dir scf and swconfig and log dir for ute cloud.
#    ${cur_dir}    run    pwd
#    set suite variable     ${TS_LOG_PATH_BASE}       ${cur_dir}/../test_results
#    set suite variable     ${SWCONFIG_DEFAULT_FILE_PATH}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/swconfig.txt
#    set suite variable     ${luashark_path}        /opt/luashark/luashark.lua
#    Set Suite Variable    ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH_cloud}
#    Set Suite Variable    ${TS_CASE_SWCONFIG_PATH}    ${TS_CASE_SWCONFIG_PATH_cloud}/swconfig.txt
#    Set Suite Variable    ${ute_log_path}    ${ute_log_path_cloud}
#    Set Suite Variable    ${tl_scf_dir_path}     ${SCF_PATH}/commissionings/HGZ/${testlinename}/
#    Common Suite Setup for COAM
#
#Prepare UE settings
#    [Arguments]    ${ue_type}
#    RUN KEYWORD IF    ${enb_instance} == @{enb_id}[0] or ${enb_instance} == @{enb_id}[2]
#    ...    Prepare UE APN settings    ue_type=${ue_type}    mdrbapn=${mdrbapn}
#    ...    ELSE IF    ${enb_instance} == @{enb_id}[3] or ${enb_instance} == @{enb_id}[4] or ${enb_instance} == @{enb_id}[6]
#    ...    Prepare UE APN settings    ue_type=${ue_type}    mdrbapn=${mdrbapn}
#    ...    ELSE IF    ${enb_instance} == @{enb_id}[1]
#    ...    Prepare UE APN settings    ue_type=${ue_type}    mdrbapn=${mdrbapn_cloud}
#
#Prepare UE APN settings
#    [Arguments]    ${ue_type}    ${mdrbapn}    ${ue_index}=${0}
#    Check UE device exist    ue_index=${ue_index}
#    Huawei UE setup    ue_type=${ue_type}    ue_index=${ue_index}
#    ${5Grach_ed}    Run Keyword And Ignore Error    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
#    set apn to wap2    usedapn=${mdrbapn}
#    Setup UE data status    status=disable
#    Commercial_mobile_phone_adb_common_keywords.Connect to control pc via cygwin    hostname=${hostname}    ue_index=${ue_index}
#    Commercial_mobile_phone_adb_common_keywords.Commercial UE click AIRPLANE once     Home_button=${home}
#
#Recover APN
#    RUN KEYWORD IF    ${enb_instance} == @{enb_id}[0] or ${enb_instance} == @{enb_id}[2]
#    ...    set apn to wap2    usedapn=${wap2_APN}
#    ...    ELSE IF    ${enb_instance} == @{enb_id}[3] or ${enb_instance} == @{enb_id}[4] or ${enb_instance} == @{enb_id}[6]
#    ...    set apn to wap2    usedapn=${wap2_APN}
#    ...    ELSE IF    ${enb_instance} == @{enb_id}[1]
#    ...    set apn to wap2    usedapn=${wap2_APN_cloud}
#
#UE attach then enable data
#    [Arguments]    ${ue_type}    ${ue_index}=${0}
#    Huawei UE setup    ue_type=${ue_type}    ue_index=${ue_index}
#    Commercial_mobile_phone_adb_common_keywords.Connect to control pc via cygwin    hostname=${hostname}    ue_index=${ue_index}
#    Commercial_mobile_phone_adb_common_keywords.Commercial UE click AIRPLANE once     Home_button=${home}
#    ...    airplane=${airplane}    ue_index=${ue_index}    close_task=${close_task}
#    sleep    1s
#    Setup UE data status
#    sleep    30s
#
#Repeat check voice call status with UE
#    check voice call status    status=${2}
#    sleep    1m
#
####check wireshar log
#Check wireshark log for 001
#    Check EPSFB message on gnb    logname=${log_name_B_001}
#    Check EPSFB mesage on enb    logname=${enb_log_name_B_001}
#
#Check wireshark log for 002
#    Check idle EMC fallback message on gnb    logname=${log_name_B_002}
#
#Check wireshark log for 003
#    Check EMC fallback message on gnb    logname=${log_name_B_003}
#    Check EMC fallback message on enb    logname=${enb_log_name_B_003}
#
#Check wireshark log for 007
#    Check invalid QoS Combination message on gnb    logname=${log_name_B_007}
#
#Check wireshark log for 008
#    Check VoNR call failed message with unspecified    logname=${log_name_B_008}
#
#Check wireshark log for 009
#    Check VoNR call success message with intra gnb HO    logname=${log_name_B_009}
#
#Check wireshark log for 010
#    Check VoNR success message    logname=${log_name_B_010}
#    Check VoNR call success message with inter gnb HO source    logname=${log_name_B_010_1}
#    Check VoNR call success message with inter gnb HO target    logname=${log_name_B_010_2}
#
#Check wireshark log for 011
#    Check VoNR success message    logname=${log_name_B_011}
#    check message with B2 event of Inter_RAT HO    logname=${log_name_B_011_1}
#    check message with B2 event of Inter_RAT HO on enb    logname=${enb_log_name_B_011_1}
#    ####2023/03/20 teams chat with yuanxuan and cindy add the EDA(23R3),details refer to Email:Customer AP202206280732380181
#    Check EDA 02836560    logname=${log_name_B_011_0}
#
#Check wireshark log for 012
#    Check VoNR call success message with intra gnb re-establish    logname=${log_name_B_012_1}
#
#Check wireshark log for 013
#    Check attach successful message     logname=${log_name_B_013_1}
#
#Check wireshark log for 013_2
#    Check VoNR release success message    logname=${log_name_B_013_2}
#
#Check wireshark log for 013_3
#    Check VoNR success message    logname=${log_name_B_013_3}
#
#
####check counter on WEBUI
#Check counter for 001
#   RUN KEYWORD IF    ${enb_instance} == @{enb_id}[0]    sleep    1s
#   ...    ELSE    sleep    40s
#    sleep    40s
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_SETUP_FAIL_FALLBACK['counter_id']}
#    ...    dic_path=${NG_FLOW_SETUP_FAIL_FALLBACK['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_SETUP_FAIL_FALLBACK['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP['counter_id']}
#    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_PMQAP['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1['counter_id']}
#    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_5QI1['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${NR_RRC_RELEASE_REDIR_VFB_LTE['counter_id']}
#    ...    dic_path=${NR_RRC_RELEASE_REDIR_VFB_LTE['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NR_RRC_RELEASE_REDIR_VFB_LTE['gnb_id']}
#
#Check counter for 002_1
#    sleep    80s
#    Check inactive counter as expected_value
#    ...    counter_id=${NG_FLOW_REL_GNB_UE_INACTIVITY['counter_id']}
#    ...    dic_path=${NG_FLOW_REL_GNB_UE_INACTIVITY['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_REL_GNB_UE_INACTIVITY['gnb_id']}
#
#Check counter for 002_2
#    sleep    10s
#    Check multi cell of gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_SETUP_FAIL_FALLBACK_2['counter_id']}
#    ...    dic_path=${NG_FLOW_SETUP_FAIL_FALLBACK_2['dic_path']}
#    ...    expected_value=${2}
#    ...    gnb_id=${NG_FLOW_SETUP_FAIL_FALLBACK_2['gnb_id']}
#    Check multi cell of gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_2['counter_id']}
#    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_2['dic_path']}
#    ...    expected_value=${2}
#    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_2['gnb_id']}
#    Check multi cell of gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1_2['counter_id']}
#    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_5QI1_2['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1_2['gnb_id']}
#
#Check counter for 003
#    sleep    40s
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_SETUP_FAIL_FALLBACK['counter_id']}
#    ...    dic_path=${NG_FLOW_SETUP_FAIL_FALLBACK['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_SETUP_FAIL_FALLBACK['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP['counter_id']}
#    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_PMQAP['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1['counter_id']}
#    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_5QI1['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1['gnb_id']}
#
#Check counter for 007
#    sleep    40s
#    Check gnb counter as expected_value
#    ...    counter_id=${Trunk_NG_FLOW_SETUP_FAIL_WRONG_MSG['counter_id']}
#    ...    dic_path=${Trunk_NG_FLOW_SETUP_FAIL_WRONG_MSG['dic_path']}
#    ...    expected_value=${2}
#    ...    gnb_id=${Trunk_NG_FLOW_SETUP_FAIL_WRONG_MSG['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${Trunk_NG_FLOW_STP_FAIL_WRG_MSG_5QI1['counter_id']}
#    ...    dic_path=${Trunk_NG_FLOW_STP_FAIL_WRG_MSG_5QI1['dic_path']}
#    ...    expected_value=${2}
#    ...    gnb_id=${Trunk_NG_FLOW_STP_FAIL_WRG_MSG_5QI1['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${Trunk_NG_FLOW_STP_FAIL_WRG_MSG_PMQAP['counter_id']}
#    ...    dic_path=${Trunk_NG_FLOW_STP_FAIL_WRG_MSG_PMQAP['dic_path']}
#    ...    expected_value=${2}
#    ...    gnb_id=${Trunk_NG_FLOW_STP_FAIL_WRG_MSG_PMQAP['gnb_id']}
#
##Check counter for 007
#   sleep    40s
#   Check gnb counter as expected_value
#   ...    counter_id=${NG_FLOW_SETUP_FAIL_WRONG_MSG['counter_id']}
#   ...    dic_path=${NG_FLOW_SETUP_FAIL_WRONG_MSG['dic_path']}
#   ...    expected_value=${2}
#   ...    gnb_id=${NG_FLOW_SETUP_FAIL_WRONG_MSG['gnb_id']}
#   Check gnb counter as expected_value
#   ...    counter_id=${NG_FLOW_STP_FAIL_WRG_MSG_5QI1['counter_id']}
#   ...    dic_path=${NG_FLOW_STP_FAIL_WRG_MSG_5QI1['dic_path']}
#   ...    expected_value=${2}
#   ...    gnb_id=${NG_FLOW_STP_FAIL_WRG_MSG_5QI1['gnb_id']}
#   Check gnb counter as expected_value
#   ...    counter_id=${NG_FLOW_STP_FAIL_WRG_MSG_PMQAP['counter_id']}
#   ...    dic_path=${NG_FLOW_STP_FAIL_WRG_MSG_PMQAP['dic_path']}
#   ...    expected_value=${2}
#   ...    gnb_id=${NG_FLOW_STP_FAIL_WRG_MSG_PMQAP['gnb_id']}
#
#Check counter for 008
#    sleep    40s
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_SETUP_FAIL_UNSPECIFIED['counter_id']}
#    ...    dic_path=${NG_FLOW_SETUP_FAIL_UNSPECIFIED['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_SETUP_FAIL_UNSPECIFIED['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_SETUP_FAIL_UNSPC_PMQAP['counter_id']}
#    ...    dic_path=${NG_FLOW_SETUP_FAIL_UNSPC_PMQAP['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_SETUP_FAIL_UNSPC_PMQAP['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_SETUP_FAIL_UNSPC_5QI1['counter_id']}
#    ...    dic_path=${NG_FLOW_SETUP_FAIL_UNSPC_5QI1['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_SETUP_FAIL_UNSPC_5QI1['gnb_id']}
#
#Check counter for 009
#    sleep    30s
#    Check multi cell of gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_5QI1_2['counter_id']}
#    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_5QI1_2['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_5QI1_2['gnb_id']}
#    Check multi cell of gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_5QI1_2['counter_id']}
#    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_5QI1_2['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_5QI1_2['gnb_id']}
#    Check multi cell of gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP_2['counter_id']}
#    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_PMQAP_2['dic_path']}
#    ...    expected_value=${3}
#    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP_2['gnb_id']}
#    Check multi cell of gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP_2['counter_id']}
#    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_PMQAP_2['dic_path']}
#    ...    expected_value=${3}
#    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP_2['gnb_id']}
#    Check multi cell of gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO['counter_id']}
#    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO['dic_path']}
#    ...    expected_value=${3}
#    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO['gnb_id']}
#    Check multi cell of gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO['counter_id']}
#    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO['dic_path']}
#    ...    expected_value=${3}
#    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO['gnb_id']}
#
#Check counter for 010
#    sleep    40s
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_5QI1_3['counter_id']}
#    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_5QI1_3['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_5QI1_3['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_5QI1_3['counter_id']}
#    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_5QI1_3['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_5QI1_3['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP_3['counter_id']}
#    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_PMQAP_3['dic_path']}
#    ...    expected_value=${3}
#    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP_3['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP_3['counter_id']}
#    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_PMQAP_3['dic_path']}
#    ...    expected_value=${3}
#    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP_3['gnb_id']}
#
#Check trunk counter for 011
#   RUN KEYWORD IF    ${enb_instance} == @{enb_id}[0]    sleep    2min
#   ...    ELSE    sleep    40s
#    sleep    40s
#    Check gnb counter as expected_value
#    ...    counter_id=${Trunk_NG_FLOW_REL_IRAT_SUC_HO_5QI1['counter_id']}
#    ...    dic_path=${Trunk_NG_FLOW_REL_IRAT_SUC_HO_5QI1['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${Trunk_NG_FLOW_REL_IRAT_SUC_HO_5QI1['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${Trunk_NG_FLOW_REL_IRAT_SUC_HO_PMQAP['counter_id']}
#    ...    dic_path=${Trunk_NG_FLOW_REL_IRAT_SUC_HO_PMQAP['dic_path']}
#    ...    expected_value=${3}
#    ...    gnb_id=${Trunk_NG_FLOW_REL_IRAT_SUC_HO_PMQAP['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${Trunk_NG_FLOW_REL_IRAT_SUC_HO['counter_id']}
#    ...    dic_path=${Trunk_NG_FLOW_REL_IRAT_SUC_HO['dic_path']}
#    ...    expected_value=${3}
#    ...    gnb_id=${Trunk_NG_FLOW_REL_IRAT_SUC_HO['gnb_id']}
#
#Check counter for 011
#   RUN KEYWORD IF    ${enb_instance} == @{enb_id}[0]    sleep    2min
#   ...    ELSE    sleep    40s
#    sleep    40s
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_REL_IRAT_SUC_HO_5QI1['counter_id']}
#    ...    dic_path=${NG_FLOW_REL_IRAT_SUC_HO_5QI1['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_REL_IRAT_SUC_HO_5QI1['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_REL_IRAT_SUC_HO_PMQAP['counter_id']}
#    ...    dic_path=${NG_FLOW_REL_IRAT_SUC_HO_PMQAP['dic_path']}
#    ...    expected_value=${3}
#    ...    gnb_id=${NG_FLOW_REL_IRAT_SUC_HO_PMQAP['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_REL_IRAT_SUC_HO['counter_id']}
#    ...    dic_path=${NG_FLOW_REL_IRAT_SUC_HO['dic_path']}
#    ...    expected_value=${3}
#    ...    gnb_id=${NG_FLOW_REL_IRAT_SUC_HO['gnb_id']}
#
#Check counter for 012
#    sleep    40s
#    Check multi cell of gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_STP_ATT_RES_IADU_PMQAP['counter_id']}
#    ...    dic_path=${NG_FLOW_STP_ATT_RES_IADU_PMQAP['dic_path']}
#    ...    expected_value=${3}
#    ...    gnb_id=${NG_FLOW_STP_ATT_RES_IADU_PMQAP['gnb_id']}
#    Check multi cell of gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_STP_ATT_RES_IADU_5QI1['counter_id']}
#    ...    dic_path=${NG_FLOW_STP_ATT_RES_IADU_5QI1['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_STP_ATT_RES_IADU_5QI1['gnb_id']}
#    Check multi cell of gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_STP_SUC_RES_IADU_PMQAP['counter_id']}
#    ...    dic_path=${NG_FLOW_STP_SUC_RES_IADU_PMQAP['dic_path']}
#    ...    expected_value=${3}
#    ...    gnb_id=${NG_FLOW_STP_SUC_RES_IADU_PMQAP['gnb_id']}
#    Check multi cell of gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_STP_SUC_RES_IADU_5QI1['counter_id']}
#    ...    dic_path=${NG_FLOW_STP_SUC_RES_IADU_5QI1['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_STP_SUC_RES_IADU_5QI1['gnb_id']}
#    Check multi cell of gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_STP_ATT_REEST_IADU['counter_id']}
#    ...    dic_path=${NG_FLOW_STP_ATT_REEST_IADU['dic_path']}
#    ...    expected_value=${3}
#    ...    gnb_id=${NG_FLOW_STP_ATT_REEST_IADU['gnb_id']}
#    Check multi cell of gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_STP_SUC_REEST_IADU['counter_id']}
#    ...    dic_path=${NG_FLOW_STP_SUC_REEST_IADU['dic_path']}
#    ...    expected_value=${3}
#    ...    gnb_id=${NG_FLOW_STP_SUC_REEST_IADU['gnb_id']}
#
#Check counter for 013_1
#    sleep    40s
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_SETUP_ATT_TOT_PMQAP['counter_id']}
#    ...    dic_path=${NG_FLOW_SETUP_ATT_TOT_PMQAP['dic_path']}
#    ...    expected_value=${2}
#    ...    gnb_id=${NG_FLOW_SETUP_ATT_TOT_PMQAP['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_SETUP_ATT_TOT['counter_id']}
#    ...    dic_path=${NG_FLOW_SETUP_ATT_TOT['dic_path']}
#    ...    expected_value=${2}
#    ...    gnb_id=${NG_FLOW_SETUP_ATT_TOT['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_SETUP_SUCC['counter_id']}
#    ...    dic_path=${NG_FLOW_SETUP_SUCC['dic_path']}
#    ...    expected_value=${2}
#    ...    gnb_id=${NG_FLOW_SETUP_SUCC['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_SETUP_SUCC_PMQAP['counter_id']}
#    ...    dic_path=${NG_FLOW_SETUP_SUCC_PMQAP['dic_path']}
#    ...    expected_value=${2}
#    ...    gnb_id=${NG_FLOW_SETUP_SUCC_PMQAP['gnb_id']}
#
#Check counter for 013_3
#    sleep    40s
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_SETUP_ATT_TOT_5QI1['counter_id']}
#    ...    dic_path=${NG_FLOW_SETUP_ATT_TOT_5QI1['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_SETUP_ATT_TOT_5QI1['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_SETUP_SUCC_TOT_5QI1['counter_id']}
#    ...    dic_path=${NG_FLOW_SETUP_SUCC_TOT_5QI1['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_SETUP_SUCC_TOT_5QI1['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_SETUP_ATT_TOT_PMQAP['counter_id']}
#    ...    dic_path=${NG_FLOW_SETUP_ATT_TOT_PMQAP['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_SETUP_ATT_TOT_PMQAP['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_SETUP_ATT_TOT['counter_id']}
#    ...    dic_path=${NG_FLOW_SETUP_ATT_TOT['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_SETUP_ATT_TOT['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_SETUP_SUCC['counter_id']}
#    ...    dic_path=${NG_FLOW_SETUP_SUCC['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_SETUP_SUCC['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_SETUP_SUCC_PMQAP['counter_id']}
#    ...    dic_path=${NG_FLOW_SETUP_SUCC_PMQAP['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_SETUP_SUCC_PMQAP['gnb_id']}
#
#Check counter for 013_2
#    sleep    40s
#    Check gnb counter greater expected_value
#    ...    counter_id=${NG_FLOW_CON_SESSION_TIME_PMQAP['counter_id']}
#    ...    dic_path=${NG_FLOW_CON_SESSION_TIME_PMQAP['dic_path']}
#    ...    expected_value=${3600}
#    ...    gnb_id=${NG_FLOW_CON_SESSION_TIME_PMQAP['gnb_id']}
#    Check gnb counter greater expected_value
#    ...    counter_id=${NG_FLOW_CONNECTED_SESSION_TIME['counter_id']}
#    ...    dic_path=${NG_FLOW_CONNECTED_SESSION_TIME['dic_path']}
#    ...    expected_value=${3600}
#    ...    gnb_id=${NG_FLOW_CONNECTED_SESSION_TIME['gnb_id']}
#    Check gnb counter greater expected_value
#    ...    counter_id=${NG_FLOW_SESSION_DUR_NORM_5QI1['counter_id']}
#    ...    dic_path=${NG_FLOW_SESSION_DUR_NORM_5QI1['dic_path']}
#    ...    expected_value=${3600}
#    ...    gnb_id=${NG_FLOW_SESSION_DUR_NORM_5QI1['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_REL_AMF_NORMAL_5QI1['counter_id']}
#    ...    dic_path=${NG_FLOW_REL_AMF_NORMAL_5QI1['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_REL_AMF_NORMAL_5QI1['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_REL_AMF_NORMAL_PMQAP['counter_id']}
#    ...    dic_path=${NG_FLOW_REL_AMF_NORMAL_PMQAP['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_REL_AMF_NORMAL_PMQAP['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_REL_NORMAL_5QI1['counter_id']}
#    ...    dic_path=${NG_FLOW_REL_NORMAL_5QI1['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_REL_NORMAL_5QI1['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_REL_AMF_NORMAL['counter_id']}
#    ...    dic_path=${NG_FLOW_REL_AMF_NORMAL['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_REL_AMF_NORMAL['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_REL_PMQAP['counter_id']}
#    ...    dic_path=${NG_FLOW_REL_PMQAP['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_REL_PMQAP['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_REL_NORMAL_PMQAP['counter_id']}
#    ...    dic_path=${NG_FLOW_REL_NORMAL_PMQAP['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_REL_NORMAL_PMQAP['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_REL['counter_id']}
#    ...    dic_path=${NG_FLOW_REL['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_REL['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${NG_FLOW_REL_NORMAL['counter_id']}
#    ...    dic_path=${NG_FLOW_REL_NORMAL['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${NG_FLOW_REL_NORMAL['gnb_id']}
#
#Check wireshark log for 8700_A_021
#    [Arguments]    ${logname}
#    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
#    ...    command_template=${command_template_with_Y}    alias=test
#    ${pduResetupreq} =    Catenate    (ngap.procedureCode == 29 and ngap.fiveQI)
#    ${filtered_packets}=    filter_packets_by_expression
#    ...    filter_expression=${pduResetupreq}    pcap_parser=test
#    ${qos_id_req}=    get_field_value_by_xpath    xpath=.//ngap.qosFlowIdentifier  pcap_parser=test
#    ${5qi_value}=    get_field_value_by_xpath    xpath=.//ngap.fiveQI  pcap_parser=test
#    ${Pri_ARP}=    get_field_value_by_xpath    xpath=.//ngap.priorityLevelARP  pcap_parser=test
#    ${qos_num}=    get length    ${qos_id_req}
#    should be equal    ${qos_num}    ${5}
#    should be equal    ${5qi_value}    ${Pri_ARP}
#    FOR    ${qos_index}    IN RANGE    ${qos_num}
#        run keyword if     ${Pri_ARP[${qos_index}]}==3    Set Suite Variable    ${5QI3_qos}    ${qos_id_req[${qos_index}]}
#        run keyword if     ${Pri_ARP[${qos_index}]}==7    Set Suite Variable    ${5QI7_qos}    ${qos_id_req[${qos_index}]}
#        run keyword if     ${Pri_ARP[${qos_index}]}==9    Set Suite Variable    ${5QI9_qos}    ${qos_id_req[${qos_index}]}
#    END
#    ${pduResetupresp} =    Catenate    (ngap.procedureCode == 29 and ngap.qosFlowFailedToSetupList)
#    ${filtered_packets}=    filter_packets_by_expression
#    ...    filter_expression=${pduResetupresp}    pcap_parser=test
#    ${qos_id_resp}=    get_field_value_by_xpath    xpath=.//ngap.qosFlowIdentifier  pcap_parser=test
#    ${qos_id_resp_failed}    create List    ${qos_id_resp[-3]}   ${qos_id_resp[-2]}   ${qos_id_resp[-1]}
#    ${radioNetwork}=    get_field_value_by_xpath    xpath=.//ngap.radioNetwork  pcap_parser=test
#    FOR    ${qos_failed_index}    IN RANGE    ${3}
#        run keyword if 	  ${qos_id_resp_failed[${qos_failed_index}]}== ${5QI3_qos}
#    ...		should be equal    ${radioNetwork[${qos_failed_index}]}    34
#        run keyword if 	  ${qos_id_resp_failed[${qos_failed_index}]}== ${5QI7_qos}
#    ...		should be equal    ${radioNetwork[${qos_failed_index}]}    22
#        run keyword if 	  ${qos_id_resp_failed[${qos_failed_index}]}== ${5QI9_qos}
#    ...		should be equal    ${radioNetwork[${qos_failed_index}]}    22
#    END
#
#
#
#Setup UE data status
#    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${status}=enable
#    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
#    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
#    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
#    sleep   5s
#    csn.send_command    command=adb -s ${serial_number} shell svc data ${status}    connection=cygwin${ue_index}
#    sleep   2s
#    csn.disconnect      connection=cygwin${ue_index}
#
##Check counter for 8700_A_021
#   sleep    40s
#   Check gnb counter greater expected_value
#   ...    counter_id=${SA_PART_ADMISSION['counter_id']}
#   ...    dic_path=${SA_PART_ADMISSION['dic_path']}
#   ...    expected_value=${1}
#   ...    gnb_id=${SA_PART_ADMISSION['gnb_id']}
#   Check gnb counter greater expected_value
#   ...    counter_id=${NG_FLOW_SETUP_ATT_TOT_PMQAP['counter_id']}
#   ...    dic_path=${NG_FLOW_SETUP_ATT_TOT_PMQAP['dic_path']}
#   ...    expected_value=${6}
#   ...    gnb_id=${NG_FLOW_SETUP_ATT_TOT_PMQAP['gnb_id']}
#   Check gnb counter greater expected_value
#   ...    counter_id=${NG_FLOW_SETUP_SUCC_PMQAP['counter_id']}
#   ...    dic_path=${NG_FLOW_SETUP_SUCC_PMQAP['dic_path']}
#   ...    expected_value=${3}
#   ...    gnb_id=${NG_FLOW_SETUP_SUCC_PMQAP['gnb_id']}
#   Check gnb counter as expected_value
#   ...    counter_id=${NG_FLOW_SETUP_FAIL_RRNA_PMQAP['counter_id']}
#   ...    dic_path=${NG_FLOW_SETUP_FAIL_RRNA_PMQAP['dic_path']}
#   ...    expected_value=${2}
#   ...    gnb_id=${NG_FLOW_SETUP_FAIL_RRNA_PMQAP['gnb_id']}
#   Check gnb counter as expected_value
#   ...    counter_id=${NG_FLOW_SETUP_ATT_TOT['counter_id']}
#   ...    dic_path=${NG_FLOW_SETUP_ATT_TOT['dic_path']}
#   ...    expected_value=${6}
#   ...    gnb_id=${NG_FLOW_SETUP_ATT_TOT['gnb_id']}
#   Check gnb counter as expected_value
#   ...    counter_id=${NG_FLOW_SETUP_SUCC['counter_id']}
#   ...    dic_path=${NG_FLOW_SETUP_SUCC['dic_path']}
#   ...    expected_value=${3}
#   ...    gnb_id=${NG_FLOW_SETUP_SUCC['gnb_id']}
#   Check gnb counter as expected_value
#   ...    counter_id=${NG_FLOW_SETUP_FAIL_RRNA['counter_id']}
#   ...    dic_path=${NG_FLOW_SETUP_FAIL_RRNA['dic_path']}
#   ...    expected_value=${2}
#   ...    gnb_id=${NG_FLOW_SETUP_FAIL_RRNA['gnb_id']}
#
#Check counter for 8700_A_021
#    sleep    40s
#    Check gnb counter greater expected_value
#    ...    counter_id=${Trunk_SA_PART_ADMISSION['counter_id']}
#    ...    dic_path=${Trunk_SA_PART_ADMISSION['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${Trunk_SA_PART_ADMISSION['gnb_id']}
#    Check gnb counter greater expected_value
#    ...    counter_id=${Trunk_NG_FLOW_SETUP_ATT_TOT_PMQAP['counter_id']}
#    ...    dic_path=${Trunk_NG_FLOW_SETUP_ATT_TOT_PMQAP['dic_path']}
#    ...    expected_value=${6}
#    ...    gnb_id=${Trunk_NG_FLOW_SETUP_ATT_TOT_PMQAP['gnb_id']}
#    Check gnb counter greater expected_value
#    ...    counter_id=${Trunk_NG_FLOW_SETUP_SUCC_PMQAP['counter_id']}
#    ...    dic_path=${Trunk_NG_FLOW_SETUP_SUCC_PMQAP['dic_path']}
#    ...    expected_value=${3}
#    ...    gnb_id=${Trunk_NG_FLOW_SETUP_SUCC_PMQAP['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${Trunk_NG_FLOW_SETUP_FAIL_RRNA_PMQAP['counter_id']}
#    ...    dic_path=${Trunk_NG_FLOW_SETUP_FAIL_RRNA_PMQAP['dic_path']}
#    ...    expected_value=${2}
#    ...    gnb_id=${Trunk_NG_FLOW_SETUP_FAIL_RRNA_PMQAP['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${Trunk_NG_FLOW_SETUP_ATT_TOT['counter_id']}
#    ...    dic_path=${Trunk_NG_FLOW_SETUP_ATT_TOT['dic_path']}
#    ...    expected_value=${6}
#    ...    gnb_id=${Trunk_NG_FLOW_SETUP_ATT_TOT['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${Trunk_NG_FLOW_SETUP_SUCC['counter_id']}
#    ...    dic_path=${Trunk_NG_FLOW_SETUP_SUCC['dic_path']}
#    ...    expected_value=${3}
#    ...    gnb_id=${Trunk_NG_FLOW_SETUP_SUCC['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${Trunk_NG_FLOW_SETUP_FAIL_RRNA['counter_id']}
#    ...    dic_path=${Trunk_NG_FLOW_SETUP_FAIL_RRNA['dic_path']}
#    ...    expected_value=${2}
#    ...    gnb_id=${Trunk_NG_FLOW_SETUP_FAIL_RRNA['gnb_id']}
#
#Check IE wireshark log for F1 configure
#    [Arguments]    ${logname}    ${message_filter}   ${value}
#    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
#    ${filter_expression}=     Catenate    ${message_filter}
#    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
#    ${nr_rrc_sn_FieldLength}=     cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
#    ...                                                xpath=.//nr-rrc.sn_FieldLength
#    ###2023022 Chat with huanghai,change rlcUMDrbSNLength from rlcUm12bitSN to rlcUm6bitSN
#    should be equal    ${nr_rrc_sn_FieldLength[0]}    0
#
#Check IE wireshark log for E1_dRB_Inactivity configure
#    [Arguments]    ${logname}    ${message_filter}   ${value}
#    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
#    ${filter_expression}=     Catenate    ${message_filter}
#    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
#    ${e1ap_dRB_Inactivity_Timer}=     cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
#    ...                                                xpath=.//e1ap.dRB_Inactivity_Timer
#    should be equal    ${e1ap_dRB_Inactivity_Timer[0]}    600
#
#Check IE wireshark log for VONR setup
#    [Arguments]    ${logname}    ${message_filter}
#    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
#    ${filter_expression}=     Catenate    ${message_filter}
#    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
#    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
#    should be equal    ${ngap_fiveQI[0]}    1
#
#Test recover
#    run keyword and ignore error    UE.UE Detach    ue_type=${ue_type}
#    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#Check counter for 7564_001
#    Check gnb counter as expected_value for 7564
#    ...    counter_id=${DED_PREAMBL_SENT_CFRA_INIT['counter_id']}
#    ...    dic_path=${DED_PREAMBL_SENT_CFRA_INIT['dic_path']}
#    ...    expected_value=${case001_expected_value}
#    ...    gnb_id=${DED_PREAMBL_SENT_CFRA_INIT['gnb_id']}
#    ...    counter_end=${counter_end_1}
#    Check gnb counter as expected_value for 7564
#    ...    counter_id=${INIT_MSG2_ACK_CFRA['counter_id']}
#    ...    dic_path=${INIT_MSG2_ACK_CFRA['dic_path']}
#    ...    expected_value=${case001_expected_value}
#    ...    gnb_id=${INIT_MSG2_ACK_CFRA['gnb_id']}
#    ...    counter_end=${counter_end_1}
#    Check gnb counter as expected_value for 7564
#    ...    counter_id=${DED_PREAMBL_USED_CFRA_INIT['counter_id']}
#    ...    dic_path=${DED_PREAMBL_USED_CFRA_INIT['dic_path']}
#    ...    expected_value=${case001_expected_value}
#    ...    gnb_id=${DED_PREAMBL_USED_CFRA_INIT['gnb_id']}
#    ...    counter_end=${counter_end_1}
#
#Check counter for 7564_005
#    Check gnb counter as expected_value for 7564
#    ...    counter_id=${RA_CB_INIT_RESOLVED['counter_id']}
#    ...    dic_path=${RA_CB_INIT_RESOLVED['dic_path']}
#    ...    expected_value=${case005_expected_value}
#    ...    gnb_id=${RA_CB_INIT_RESOLVED['gnb_id']}
#    ...    counter_end=${counter_end}
#    Check gnb counter as expected_value for 7564
#    ...    counter_id=${RA_MSG3_RECEP_INIT['counter_id']}
#    ...    dic_path=${RA_MSG3_RECEP_INIT['dic_path']}
#    ...    expected_value=${case005_expected_value}
#    ...    gnb_id=${RA_MSG3_RECEP_INIT['gnb_id']}
#    ...    counter_end=${counter_end}
#
###5GC00784 #####
#Make a EC_Modify param_check EC ongoing
#    [Arguments]    ${nglogname}    ${parameters_to_update}    ${ue_index}=${0}
#    Start capture gNB log on slave    filename=${nglogname}
#    Connect to control pc via cygwin    ue_index=${ue_index}
#    Step2: UE setup EMC call
#    Online modify parmeters    parameters_to_update=${parameters_to_update}
#    sleep    10s
#    Stop and download the Logs on slave    filename=${nglogname}
#    csn.disconnect      connection=cygwin
#    [Teardown]    kill the call procedure
#
#Check wireshark log for EC ongoing
#    [Arguments]    ${logname}
#    Check wireshark log for EC setup    logname=${logname}
#    Check wireshark log for EC 5QI 5    logname=${logname}
#    Check wireshark log for EC 5QI 1    logname=${logname}
#    Check wireshark log for EC not release unusual    logname=${logname}
#
#Make a failed EC and check procedure
#    [Arguments]    ${nglogname}    ${check_5QI}    ${ue_index}=${0}
#    Start capture gNB log on slave    filename=${nglogname}
#    Connect to control pc via cygwin    ue_index=${ue_index}
#    Step2: UE setup EMC call
#    sleep    5s
#    Stop and download the Logs on slave    filename=${nglogname}
#    Run keyword If    '${check_5QI}'=='1'    Check wireshark log for failed VoNR call_5QI1    logname=${nglogname}
#    Run keyword If    '${check_5QI}'=='5'    Check wireshark log for failed VoNR call_5QI5    logname=${nglogname}
#    csn.disconnect      connection=cygwin
#    [Teardown]    kill the call procedure
#
#Check wireshark log for failed VoNR call_5QI1
#    [Arguments]    ${logname}
#    Check wireshark log for VoNR    logname=${logname}
#    ...    message_filter=(ngap.procedureCode == 26 and ngap.radioNetwork == 22)
#    ...    xpath_filter=ngap.radioNetwork    expect_value=22
#
#Check wireshark log for failed VoNR call_5QI5
#    [Arguments]    ${logname}
#    Check wireshark log for VoNR    logname=${logname}
#    ...    message_filter=(ngap.procedureCode == 29 and ngap.radioNetwork == 22)
#    ...    xpath_filter=ngap.radioNetwork    expect_value=22
#
#Make a EC and check EPS fallback
#    [Arguments]    ${logname}    ${logname_1}    ${ue_index}=${0}
#    Start capture gNB log on slave    filename=${logname}
#    Start to collect the log on eNB    log_name=${logname_1}
#    Connect to control pc via cygwin    ue_index=${ue_index}
#    Step2: UE setup EMC call
#    sleep    3s
#    Step3: UE hang up EMC call
#    Stop and download the Logs on slave    filename=${logname}
#    Stop and download Logs on eNB    log_name=${logname_1}
#    Check wireshark log for EC EPS fallback    gnblogname=${logname}    enblogname=${logname_1}
#
#Check wireshark log for EC EPS fallback
#    [Arguments]    ${gnblogname}    ${enblogname}
#    log to console    check gnb PDU ResourceModify cause for 5qi1 fail
#    Check wireshark log for VoNR    logname=${gnblogname}
#    ...    message_filter=(ngap.procedureCode == 26 and ngap.radioNetwork == 41)
#    ...    xpath_filter=ngap.radioNetwork    expect_value=41
#    log to console    check gnb UEcontextReleaseRequest for redirection
#    Check wireshark log for VoNR    logname=${gnblogname}
#    ...    message_filter=(ngap.procedureCode == 42)
#    ...    xpath_filter=ngap.radioNetwork    expect_value=41
#    log to console    check gnb UEcontextReleaseRequest for redirection
#    Check wireshark log for VoNR    logname=${gnblogname}
#    ...    message_filter=(ngap.NGAP_PDU == 1 and ngap.procedureCode == 41)
#    ...    xpath_filter=ngap.procedureCode    expect_value=41
#    log to console    check enb TAU
#    Check wireshark log for VoNR    logname=${enblogname}
#    ...    command_template=${command_template_with_Y}
#    ...    message_filter=(s1ap.procedureCode == 12 and s1ap.RRC_Establishment_Cause == 0)
#    ...    xpath_filter=s1ap.RRC_Establishment_Cause    expect_value=0
#    Check wireshark log for VoNR    logname=${enblogname}
#    ...    command_template=${command_template_with_Y}
#    ...    message_filter=(s1ap.procedureCode == 9 and nas_eps.nas_msg_emm_type == 73)
#    ...    xpath_filter=nas_eps.nas_msg_emm_type    expect_value=0x49
#
#Check counter for A01
#    sleep    40s
#    Check the PM counter shuould be value
#    ...    gnb_index=${0}    counter_id=${counter_id_A01_should_be_1}    dic_path=${Trunk_counter_dic_path_A01_should_be_1}
#    ...    value=${expected_value_784A01_gnb1_should_be_1}
#    Check the PM counter shuould be value
#    ...    gnb_index=${0}    counter_id=${counter_id_A01_not_zero}    dic_path=${Trunk_counter_dic_path_A01_not_zero}
#    ...    value=${expected_value_784A01_gnb1}
#   Check the PM counter shuould be value
#   ...    gnb_index=${0}    counter_id=${counter_id_A01_should_be_1}    dic_path=${counter_dic_path_A01_should_be_1}
#   ...    value=${expected_value_784A01_gnb1_should_be_1}
#   Check the PM counter shuould be value
#   ...    gnb_index=${0}    counter_id=${counter_id_A01_not_zero}    dic_path=${counter_dic_path_A01_not_zero}
#   ...    value=${expected_value_784A01_gnb1}
#
#Check the 7564_C001 wireshark log
#    [Arguments]    ${logname}
#    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${log_name}    command_template=${command_template_with_Y}    alias=test6
#    ${CFRA}=    Catenate    x2ap.procedureCode == 27 and nr-rrc.ra_PreambleIndex == 56
#    ${CFRA_packets}=    cap.filter_packets_by_expression    filter_expression=${CFRA}    pcap_parser=test6
#    ${CFRA_value}=    cap.get_field_value_by_xpath    xpath=.//nr-rrc.ra_PreambleIndex    pcap_parser=test6
#    should be equal   ${CFRA_value[0]}    56
#
#Check the 7564_C005 wireshark log
#    [Arguments]    ${logname}    ${command_template}=${command_template_with_Y}
#    ${all_packets}=    cap.load_pcap_file       pcap_file=${epc_log_path}${logname}    command_template=${command_template}    alias=test6
#    ${CFRA}=    Catenate    x2ap.procedureCode == 27 and nr-rrc.ra_PreambleIndex
#    ${CFRA_packets}=    cap.filter_packets_by_expression    filter_expression=${CFRA}    pcap_parser=test6
#    ${CFRA_value}=    cap.get_field_value_by_xpath    xpath=.//nr-rrc.ra_PreambleIndex    pcap_parser=test6
#    should be empty    ${CFRA_value}
#
#Check counter for 7564_C005
#    sleep    40s
#    Check gnb counter as expected_value
#    ...    counter_id=${Trunk_RA_CB_INIT_RESOLVED['counter_id']}
#    ...    dic_path=${Trunk_RA_CB_INIT_RESOLVED['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${Trunk_RA_CB_INIT_RESOLVED['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${Trunk_RA_MSG3_RECEP_INIT['counter_id']}
#    ...    dic_path=${Trunk_RA_MSG3_RECEP_INIT['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${Trunk_RA_MSG3_RECEP_INIT['gnb_id']}
#
##Check counter for 7564_C005
#   sleep    40s
#   Check gnb counter as expected_value
#   ...    counter_id=${RA_CB_INIT_RESOLVED['counter_id']}
#   ...    dic_path=${RA_CB_INIT_RESOLVED['dic_path']}
#   ...    expected_value=${1}
#   ...    gnb_id=${RA_CB_INIT_RESOLVED['gnb_id']}
#   Check gnb counter as expected_value
#   ...    counter_id=${RA_MSG3_RECEP_INIT['counter_id']}
#   ...    dic_path=${RA_MSG3_RECEP_INIT['dic_path']}
#   ...    expected_value=${1}
#   ...    gnb_id=${RA_MSG3_RECEP_INIT['gnb_id']}
#
#Check counter for 7564_C001
#    sleep    40s
#    Check gnb counter as expected_value
#    ...    counter_id=${Trunk_DED_PREAMBL_SENT_CFRA_INIT['counter_id']}
#    ...    dic_path=${Trunk_DED_PREAMBL_SENT_CFRA_INIT['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${Trunk_DED_PREAMBL_SENT_CFRA_INIT['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${Trunk_INIT_MSG2_ACK_CFRA['counter_id']}
#    ...    dic_path=${Trunk_INIT_MSG2_ACK_CFRA['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${Trunk_INIT_MSG2_ACK_CFRA['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${Trunk_DED_PREAMBL_USED_CFRA_INIT['counter_id']}
#    ...    dic_path=${Trunk_DED_PREAMBL_USED_CFRA_INIT['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${Trunk_DED_PREAMBL_USED_CFRA_INIT['gnb_id']}
#
##Check counter for 7564_C001
#   sleep    40s
#   Check gnb counter as expected_value
#   ...    counter_id=${DED_PREAMBL_SENT_CFRA_INIT['counter_id']}
#   ...    dic_path=${DED_PREAMBL_SENT_CFRA_INIT['dic_path']}
#   ...    expected_value=${1}
#   ...    gnb_id=${DED_PREAMBL_SENT_CFRA_INIT['gnb_id']}
#   Check gnb counter as expected_value
#   ...    counter_id=${INIT_MSG2_ACK_CFRA['counter_id']}
#   ...    dic_path=${INIT_MSG2_ACK_CFRA['dic_path']}
#   ...    expected_value=${1}
#   ...    gnb_id=${INIT_MSG2_ACK_CFRA['gnb_id']}
#   Check gnb counter as expected_value
#   ...    counter_id=${DED_PREAMBL_USED_CFRA_INIT['counter_id']}
#   ...    dic_path=${DED_PREAMBL_USED_CFRA_INIT['dic_path']}
#   ...    expected_value=${1}
#   ...    gnb_id=${DED_PREAMBL_USED_CFRA_INIT['gnb_id']}
#
#Collect Interface Mirroring Bip Collector
#    [Documentation]
#    ...                :param target_file_name: (str) – name of collector
#    ...                :param interface: (str) – L1-L2 or L2Hi-L2Lo
#    ...                :param destination : (str) – Local or Remote
#    ...                :param webservice: (dict) – Configuration of collector/host: base url IP/user: username, defaults to “Nemuadmin”
#    ...                                            password: password, defaults to “nemuuser”/port: port, default 443
#    ...                :param nr_phy_cell_ids: str) (nr_phy_cell_ids Union(list,) – (Optional) list of physical cell ids.
#    ...                          If given ensure cell is on air before running the setup. If not given it will check nr_cell_dns
#    ...                          like: 50,51, (Select max 8 cells), if nr_phy_cell_ids set as "None", means collect the logs of all cells.
#    [Arguments]    ${target_dir}    ${target_file_name}=l1l2bip_log
#    ...            ${nr_phy_cell_ids}=None
#    ...            ${gnb_index}=0
#    ...            ${timeout}=600
#    ...            ${interface}=L1-L2
#    ...            ${destination}=Local
#    ...            ${host_ip}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
#    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
#    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
#    ...            ${times}=1s
#    ${webservice}=  Create Dictionary    host=${host_ip}
#    ...                                  user=${username}
#    ...                                  password=${password}
#    ...                                  port=443
#    l1l2bip.create_interface_mirroring_l1l2bip_collector    name=${target_file_name}
#    ...                                                     webservice=${webservice}
#    ...                                                     interface=${interface}
#    ...                                                     destination=${destination}
#    ...                                                     nr_phy_cell_ids=${nr_phy_cell_ids}
#    ...                                                     target_file_name=${target_file_name}
#    ...                                                     timeout=${timeout}
#    core.setup_collectors    names=${target_file_name}
#    core.start_collectors    names=${target_file_name}
#    Step1: UE attach   ue_type=${ue_type}    4G_check=${4G_check}
#    sleep    ${times}
#    core.stop_collectors        names=${target_file_name}
#    core.collect_collectors   names=${target_file_name}    target_dir=${target_dir}
#    core.teardown_collectors    names=${target_file_name}
#    l1l2bip.set_suite_alias    ${target_file_name}
#
#Check the webUI BIP log
#    [Arguments]    ${biplog}
#    ${all_packets}=    cap.Load Pcap File    pcap_file=${biplog}    alias=test
#    ${filter_expression}=    Catenate    uldata_prachreceiveind and UlData_detectedPrachPreambles_t.prachPreambleIndex==56
#    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test
#    ${PreambleIndex}=    cap.Get Field Value By Xpath    xpath=.//UlData_detectedPrachPreambles_t.prachPreambleIndex    pcap_parser=test
#    Should Be Equal    ${PreambleIndex[0]}    56
#
#choice required APN on UE
#    [Arguments]    ${usedapn}    ${ue_type}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
#    ...    ${data_enable}=false    ${status}=enable
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
#    set apn to wap2    usedapn=${usedapn}    ue_index=${ue_index}
#    Run Keyword If    '${data_enable}'=='false'    Comment    Do not operate UE data button
#    ...    ELSE IF    '${data_enable}'=='true'    Setup UE data status    status=${status}
#    make airplane mode to enable    ue_index=${ue_index}
#
##make airplane mode to enable
#   [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
#   log to console    enable airplane mode
#   Connect to control pc via cygwin    ue_index=${ue_index}
#   ${passed} =    Check airplane mode status on    ue_index=${ue_index}
#   run keyword if    '${passed}'=='${False}'
#       ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
#       ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
#       ...    close_task=${close_task}
#
#Check EDA 02836560
#    [Arguments]    ${logname}
#    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
#    ${filter_expression}=     Catenate    f1ap.procedureCode == 12 and  lte-rrc.FreqBandIndicator_r11 == 2
#    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
#    ${FreqBandIndicator_r11}=     cap.get_field_value_by_xpath   xpath=.//lte-rrc.FreqBandIndicator_r11    pcap_parser=test6
#    should be equal    ${FreqBandIndicator_r11[0]}    2
#
##Check counter for E001_1
#   sleep    40s
#   Check gnb counter as expected_value
#   ...    counter_id=${PEAK_NUMBER_OF_UE_5QI1['counter_id']}
#   ...    dic_path=${PEAK_NUMBER_OF_UE_5QI1['dic_path']}
#   ...    expected_value=${2}
#   ...    gnb_id=${PEAK_NUMBER_OF_UE_5QI1['gnb_id']}
#   Check gnb counter greater expected_value
#   ...    counter_id=${AVE_NUMBER_OF_UE_5QI1['counter_id']}
#   ...    dic_path=${AVE_NUMBER_OF_UE_5QI1['dic_path']}
#   ...    expected_value=${1}
#   ...    gnb_id=${AVE_NUMBER_OF_UE_5QI1['gnb_id']}
#   Check gnb counter as expected_value
#   ...    counter_id=${AVE_NUMBER_OF_UE_5QI1_DENOM['counter_id']}
#   ...    dic_path=${AVE_NUMBER_OF_UE_5QI1_DENOM['dic_path']}
#   ...    expected_value=${300}
#   ...    gnb_id=${AVE_NUMBER_OF_UE_5QI1_DENOM['gnb_id']}
#
#Check counter for E001_1
#    sleep    40s
#    Check gnb counter as expected_value
#    ...    counter_id=${Trunk_PEAK_NUMBER_OF_UE_5QI1['counter_id']}
#    ...    dic_path=${Trunk_PEAK_NUMBER_OF_UE_5QI1['dic_path']}
#    ...    expected_value=${2}
#    ...    gnb_id=${Trunk_PEAK_NUMBER_OF_UE_5QI1['gnb_id']}
#    Check gnb counter greater expected_value
#    ...    counter_id=${Trunk_AVE_NUMBER_OF_UE_5QI1['counter_id']}
#    ...    dic_path=${Trunk_AVE_NUMBER_OF_UE_5QI1['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${Trunk_AVE_NUMBER_OF_UE_5QI1['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${Trunk_AVE_NUMBER_OF_UE_5QI1_DENOM['counter_id']}
#    ...    dic_path=${Trunk_AVE_NUMBER_OF_UE_5QI1_DENOM['dic_path']}
#    ...    expected_value=${300}
#    ...    gnb_id=${Trunk_AVE_NUMBER_OF_UE_5QI1_DENOM['gnb_id']}
#
##Check counter for E001_2
#   sleep    40s
#   Check gnb counter as expected_value
#   ...    counter_id=${PEAK_NUMBER_OF_UE_5QI1['counter_id']}
#   ...    dic_path=${PEAK_NUMBER_OF_UE_5QI1['dic_path']}
#   ###   2022/10/13 02611195,chart with 8200Spec,according to PR,modify counter from 0 to 2:when VONR keep ongiong,counter will also keep.
#   ...    expected_value=${2}
#   ...    gnb_id=${PEAK_NUMBER_OF_UE_5QI1['gnb_id']}
#   Check gnb counter as expected_value
#   ...    counter_id=${AVE_NUMBER_OF_UE_5QI1['counter_id']}
#   ...    dic_path=${AVE_NUMBER_OF_UE_5QI1['dic_path']}
#   ...    expected_value=${600}
#   ...    gnb_id=${AVE_NUMBER_OF_UE_5QI1['gnb_id']}
#   Check gnb counter as expected_value
#   ...    counter_id=${AVE_NUMBER_OF_UE_5QI1_DENOM['counter_id']}
#   ...    dic_path=${AVE_NUMBER_OF_UE_5QI1_DENOM['dic_path']}
#   ...    expected_value=${300}
#   ...    gnb_id=${AVE_NUMBER_OF_UE_5QI1_DENOM['gnb_id']}
#
#Check counter for E001_2
#    sleep    40s
#    Check gnb counter as expected_value
#    ...    counter_id=${Trunk_PEAK_NUMBER_OF_UE_5QI1['counter_id']}
#    ...    dic_path=${Trunk_PEAK_NUMBER_OF_UE_5QI1['dic_path']}
#    ###   2022/10/13 02611195,chart with 8200Spec,according to PR,modify counter from 0 to 2:when VONR keep ongiong,counter will also keep.
#    ...    expected_value=${2}
#    ...    gnb_id=${Trunk_PEAK_NUMBER_OF_UE_5QI1['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${Trunk_AVE_NUMBER_OF_UE_5QI1['counter_id']}
#    ...    dic_path=${Trunk_AVE_NUMBER_OF_UE_5QI1['dic_path']}
#    ...    expected_value=${600}
#    ...    gnb_id=${Trunk_AVE_NUMBER_OF_UE_5QI1['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${Trunk_AVE_NUMBER_OF_UE_5QI1_DENOM['counter_id']}
#    ...    dic_path=${Trunk_AVE_NUMBER_OF_UE_5QI1_DENOM['dic_path']}
#    ...    expected_value=${300}
#    ...    gnb_id=${Trunk_AVE_NUMBER_OF_UE_5QI1_DENOM['gnb_id']}
#
##Check counter for E001_3
#   sleep    40s
#   Check gnb counter as expected_value
#   ...    counter_id=${PEAK_NUMBER_OF_UE_5QI1['counter_id']}
#   ...    dic_path=${PEAK_NUMBER_OF_UE_5QI1['dic_path']}
#   ...    expected_value=${2}
#   ...    gnb_id=${PEAK_NUMBER_OF_UE_5QI1['gnb_id']}
#   Check gnb counter greater expected_value
#   ...    counter_id=${AVE_NUMBER_OF_UE_5QI1['counter_id']}
#   ...    dic_path=${AVE_NUMBER_OF_UE_5QI1['dic_path']}
#   ...    expected_value=${1}
#   ...    gnb_id=${AVE_NUMBER_OF_UE_5QI1['gnb_id']}
#   Check gnb counter as expected_value
#   ...    counter_id=${AVE_NUMBER_OF_UE_5QI1_DENOM['counter_id']}
#   ...    dic_path=${AVE_NUMBER_OF_UE_5QI1_DENOM['dic_path']}
#   ...    expected_value=${300}
#   ...    gnb_id=${AVE_NUMBER_OF_UE_5QI1_DENOM['gnb_id']}
#
#Check counter for E001_3
#    sleep    40s
#    Check gnb counter as expected_value
#    ...    counter_id=${Trunk_PEAK_NUMBER_OF_UE_5QI1['counter_id']}
#    ...    dic_path=${Trunk_PEAK_NUMBER_OF_UE_5QI1['dic_path']}
#    ...    expected_value=${2}
#    ...    gnb_id=${Trunk_PEAK_NUMBER_OF_UE_5QI1['gnb_id']}
#    Check gnb counter greater expected_value
#    ...    counter_id=${Trunk_AVE_NUMBER_OF_UE_5QI1['counter_id']}
#    ...    dic_path=${Trunk_AVE_NUMBER_OF_UE_5QI1['dic_path']}
#    ...    expected_value=${1}
#    ...    gnb_id=${Trunk_AVE_NUMBER_OF_UE_5QI1['gnb_id']}
#    Check gnb counter as expected_value
#    ...    counter_id=${Trunk_AVE_NUMBER_OF_UE_5QI1_DENOM['counter_id']}
#    ...    dic_path=${Trunk_AVE_NUMBER_OF_UE_5QI1_DENOM['dic_path']}
#    ...    expected_value=${300}
#    ...    gnb_id=${Trunk_AVE_NUMBER_OF_UE_5QI1_DENOM['gnb_id']}
#
#Check wireshark log for E001
#    Check VoNR success message    logname=${log_name_E_001_1}
#    Check VoNR success message    logname=${log_name_E_001_2}
#
#Repeat check voice call status
#    check voice call status    status=${2}
#    check voice call status    ue_index=${1}    status=${2}
#    sleep    1m
