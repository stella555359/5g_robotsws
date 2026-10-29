*** Settings ***
Documentation
...    author: Zhang yayun
...    contact: yayun.zhang@nokia-sbell.com
...    squal group: SG03
...    feature: CB008200-B

Force Tags  CA_5G_RRM    RAN_5G    RAN_5G_TDD    CLOUD_5G_CLASSICAL_ANDROID_ASIKL_ABILB1_AAHF_RF_SHARING_ENB
...         STATE_SW_UPLOADED    PY36
Suite Setup    Run Keywords
...            robot_common_operations.Common Suite Setup
...            AND    Get gnb release info
...            AND    Get sagnb version for selenium
...            AND    Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    ${sw_version}_gNB1_Golden_SCF.xml
#...            AND    Set Suite Variable    ${tl_gnb2_scf_${sw_version}}    ${sw_version}_gNB2_Golden_SCF.xml
#...            AND    Common Case TestLine Setup    is_commission=True    is_commission_for_second_gnb=True    scf_path=${scf_path}
#...                                          golden_scf_name=${tl_gnb1_scf_${sw_version}}    golden_scf_name_gnb2=${tl_gnb2_scf_${sw_version}}
...            AND    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}
...                                 golden_scf_name=${tl_gnb1_scf_${sw_version}}
...            AND    Common Suite Setup for COAM
...            AND    Common UE parameter setup
...            AND    Run Keyword And Ignore Error    Online modify parmeters    parameters_to_update=${PARAM_gnb1_AES}
#...            AND    Run Keyword And Ignore Error    Online modify parmeters    gnb_index=${1}    parameters_to_update=${PARAM_gnb2_AES}

Suite Teardown    Run Keywords
...    robot_common_operations.Common Suite Teardown
...    AND    Run Keyword And Ignore Error    Online modify parmeters    parameters_to_update=${PARAM_recover_gnb1_AES}
#...    AND    Run Keyword And Ignore Error    Online modify parmeters    gnb_index=${1}    parameters_to_update=${PARAM_recover_gnb2_AES}


Resource     Resources/CB008200_common_keywords_new.robot
Variables    Resources/CB008200_variables_new.py
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot


*** Variables ***
${log_name_B_001_1}    log_name_B_001_1.pcap
${log_name_B_001}    log_name_B_001.pcap
${enb_log_name_B_001}    enb_log_name_B_001.pcap
${log_name_B_002}    log_name_B_002.pcap
${enb_log_name_B_002}    enb_log_name_B_002.pcap
${log_name_B_003}    log_name_B_003.pcap
${enb_log_name_B_003}    enb_log_name_B_003.pcap
${log_name_B_007}    log_name_B_007.pcap
${enb_log_name_B_007}    enb_log_name_B_007.pcap
${log_name_B_008}    log_name_B_008.pcap
${log_name_B_009}    log_name_B_009.pcap
${log_name_B_010_1}    log_name_B_010_1.pcap
${log_name_B_010_2}    log_name_B_010_2.pcap
${log_name_B_010}    log_name_B_010.pcap
${log_name_B_011_0}    log_name_B_011_0.pcap
${log_name_B_011_1}    log_name_B_011_1.pcap
${enb_log_name_B_011_1}    enb_log_name_B_011_1.pcap
${log_name_B_011}    log_name_B_011.pcap
${log_name_B_012}    log_name_B_012.pcap
${log_name_B_012_1}    log_name_B_012_1.pcap
${log_name_B_013_1}    log_name_B_013_1.pcap
${log_name_B_013_2}    log_name_B_013_2.pcap
${log_name_B_013_3}    log_name_B_013_3.pcap

${nglogname1}    6112_A_13_UE2_attach.pcap
${nglogname2}    6112_A_13_UE2_VONR.pcap

${B_002_message_filter}    ngap.emergencyFallbackRequestIndicator == 0 or ngap.radioNetwork == 41

${ue_type}    samsung
@{ues_type}    huawei    samsung

${enb_instance}     ${tl.enbs[0].instance_id}
@{enb_dist_name}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNMME-0
@{enb_para}    administrativeState    ipAddrPrim
@{enb_value}    unlocked    locked    10.107.245.164    10.108.225.167

@{cell_id}    0    1    2    3    4    5
@{PA_list}    ${0}    ${30}    ${45}    ${127}    ${10}    ${15}     ${25}

${log_name_A_21}    8700_A_21.pcap
${command_template_with_Z}    {tshark_path} -r {pcap_file} -Y  \"ngap or e1ap or f1ap or xnap or s1ap\"  -T pdml > log.pdml

&{5QI_QoS_1}    5QI=3     RaNet=34
&{5QI_QoS_2}    5QI=7     RaNet=22
&{5QI_QoS_3}    5QI=9     RaNet=22

${mdrbapn_cloud}    100    1340
${wap2_APN_cloud}    100    1150
${mdrbapn}    168    1670
${wap2_APN}    168    873
${hostname}    ${tl.ues[0].ssh_connection_details.addr}
${gnb_filter2}    ngap.procedureCode == 26 and ngap.fiveQI == 1
${gnb_filter3}    f1ap.procedureCode == 7 and nr-rrc.drx_Config == 0 and nr-rrc.sn_FieldLength == 1
${value3}    1
${gnb_filter4}    e1ap.procedureCode == 9 and e1ap.dRB_Inactivity_Timer == 600
${value4}    15

####168 873     wap2      huawei
####168 1073    mdrb      huawei
####168 1471    mdrbxj    huawei
@{apn_location}    168 681    168 873    146 717    140 513    93 941    93 743    142 912    168 1073    168 1471
@{diffTL_enb_ID}    36721    38221    911


${sys_logs_path}    /tmp/btslog2/
${UTE_logs_path}    /home/ute/ERR_WRN_logs/
${testline_name}          null
${base_file}    None
@{filter_list}    None

${Test_PC_IP}          ${tl.test_pc.default_ssh_connection_details.addr}
${Test_PC_username}    ${tl.test_pc.default_ssh_connection_details.username}
${Test_PC_password}    ${tl.test_pc.default_ssh_connection_details.password}

${MRBTS_ID}    ${tl.gnbs[0].instance_id}

*** Test Cases ***
[1]CB008200_5G_B_F_SA_Accessibility_counter_001_QosFlow_Setup_Fail_due_to_Voice_Fallback_when_VoNR_disabled
    [Documentation]  This User Scenario is to provide the counters used for measuring SA accessibility.
    ...    The User scenario creates a counter to measure the number of QosFlows that failed to Setup
    ...    due to Voice Fallback. The User scenario is a rerun of 5G_RAN_USR_RRM_1941 for the Fallback
    ...    via redirection of voice call. Meanwhile, This User Scenario is also to provide the counters
    ...    used for measuring SA retainability. The User scenario creates a counter to measure the number
    ...    of QosFlows that were released due to Redirection where the release is initiated by gNB.
    ...    The User scenario is a rerun of 5G_RAN_USR_RRM_1552 for Redirection of Voice call to LTE.
    [Tags]    CB008200-B   CRT_22R3    CIT_22R4
    [Timeout]    1 hour
    [Setup]    robot_common_operations.Common Case Setup
#    ${release_info}    Get sagnb release
    put btslog_ini file to ute
    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
    Start capture syslog via btslog on ute
    Online modify parmeters    parameters_to_update=${PARAM_8200_B_001}
    Online delete parmeters    parameters_to_update=${PARAM_DELETE_8200_B_001}
    comment    set gnb1 cell1 PA to 0
    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${PA_list}[0]    gnb1_cell2_value=${PA_list}[3]
    ...    gnb2_cell1_value=${PA_list}[3]    enb_cell1_value=${PA_list}[3]
    Start capture gNB log on master    filename=${log_name_B_001_1}
    Step1: UE attach    ue_type=${ues_type}[0]
    Stop and download Logs on gNB on master    filename=${log_name_B_001_1}
    comment    set enb cell PA to 0
    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${PA_list}[0]    gnb1_cell2_value=${PA_list}[3]
    ...    gnb2_cell1_value=${PA_list}[3]    enb_cell1_value=${PA_list}[0]
    Prepare with PM counter time to caculate    period=start
    Start capture gNB log on master    filename=${log_name_B_001}
    Start to collect the log on eNB    log_name=${enb_log_name_B_001}    interface=br1
    Step2: UE setup VoNR call
    sleep    20s
    check voice call status    status=${2}
    Stop and download Logs on gNB on master    filename=${log_name_B_001}
    Step3: UE hang up VoNR call
    check voice call status    status=${0}
    Stop and download Logs on eNB    log_name=${enb_log_name_B_001}
    Prepare with PM counter time to caculate    period=end
    Check wireshark log for 001
    Run Keyword If    '${release_info}' == '${branch}[0]'    Check counter for 001
    ...    ELSE IF    '${release_info}' == '${branch}[1]'    Check counter for 001
    ...    ELSE IF    '${release_info}' == '${branch}[2]'    Check counter for 001
    ...    ELSE    Check trunk counter for 001
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown
    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    ...    AND    Step3: UE hang up VoNR call    AND    check voice call status    status=${0}
    ...    AND    Step4: Detach UE    ue_type=${ues_type}[0]
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_001_1}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_001}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on eNB    log_name=${enb_log_name_B_001}
    ...    AND    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${PA_list}[0]    gnb1_cell2_value=${PA_list}[0]
    ...    gnb2_cell1_value=${PA_list}[0]    enb_cell1_value=${PA_list}[0]
    ...    AND    Online modify parmeters    parameters_to_update=${PARAM_8200_recover_B_001}
    ...    AND    Online add parmeters    parameters_to_update=${PARAM_ADD_8200_B_001}    timeout=${300}
    ...    AND    Stop capture syslog via btslog on ute
    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
    ...    AND    get and analysis syslog


[1]CB008200_5G_B_F_SA_Accessibility_counter_011_VoNR_QosFlow_Setup_when_Inter-RAT_HO_to_LTE
    [Documentation]    This User Scenario is to provide the counters used for measuring SA accessibility.
    ...    The User scenario creates a counter to measure the success ratio of QosFlows Setup due to incoming handovers.
    ...    The User scenario is a rerun of multiple scenarios Inter-RAT HO from LTE (5G Control Plane - 5G_RAN_CP_12361454)
    [Tags]    CB008200-B    CRT_22R3    CIT_22R4
    [Timeout]    1 hour
    [Setup]    robot_common_operations.Common Case Setup
#    ${release_info}    Get sagnb release
    Online modify parmeters    parameters_to_update=${PARAM_8200_B_011}
    ####2023/03/20 teams chat with yuanxuan and cindy add the EDA(23R3),details refer to Email:Customer AP202206280732380181
    ####2023/05/08 Chang the EDA from TL029 to TL382
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Online modify parmeters    parameters_to_update=${PARAM_8200_B_011_EDA}
    ...    ELSE       Sleep    1s
    Comment    set gnb1 cell1 PA to 0
    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    Start capture gNB log on master    filename=${log_name_B_011_0}
    Step1: UE attach    ue_type=${ues_type}[0]
    Stop and download Logs on gNB on master    filename=${log_name_B_011_0}
    Start capture gNB log on master    filename=${log_name_B_011}
    Step2: UE setup VoNR call
    sleep    20s
    check voice call status    status=${2}
    Stop and download Logs on gNB on master    filename=${log_name_B_011}
    ####set enb cell PA to 0
#    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}    enb_cell1_value=${0}
    Prepare with PM counter time to caculate    period=start
    put btslog_ini file to ute
    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
    Start capture syslog via btslog on ute
    Start capture gNB log on master    filename=${log_name_B_011_1}
    Start to collect the log on eNB    log_name=${enb_log_name_B_011_1}    interface=br1
    Comment     gnb1 cell1 PA to XXdb to trigger HO Inter RAT to LTE
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${25}    enb_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${15}    enb_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${15}    enb_cell1_value=${0}
    sleep    30s
    Stop and download Logs on gNB on master    filename=${log_name_B_011_1}
    Stop and download Logs on eNB    log_name=${enb_log_name_B_011_1}
    Stop capture syslog via btslog on ute
    Prepare with PM counter time to caculate    period=end
    Comment     Add EDA 02836560
    Check wireshark log for 011
    Run Keyword If    '${release_info}' == '${branch}[0]'    Check counter for 011
    ...    ELSE IF    '${release_info}' == '${branch}[1]'    Check counter for 011
    ...    ELSE IF    '${release_info}' == '${branch}[2]'    Check counter for 011
    ...    ELSE    Check trunk counter for 011
    check inter rat ho kpi    para_index=${1}
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot    AND
    ...    Step3: UE hang up VoNR call    AND    check voice call status    status=${0}    AND
    ...    Step4: Detach UE    ue_type=${ues_type}[0]    AND
    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_011_0}    AND
    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_011}    AND
    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_011_1}    AND
    ...    Run Keyword And Ignore Error    Stop and download Logs on eNB    log_name=${enb_log_name_B_011_1}    AND
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}   gnb1_cell2_value=${0}
    ...    gnb2_cell1_value=${0}    enb_cell1_value=${0}   AND
    ...    Online modify parmeters    parameters_to_update=${PARAM_8200_recover_B_011}    AND
    ...    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Online modify parmeters
    ...    parameters_to_update=${PARAM_8200_recover_B_011_EDA}
    ...    ELSE       Sleep    1s      AND
    ...    Run Keyword And Ignore Error    Stop capture syslog via btslog on ute    AND
    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown    AND
    ...    get and analysis syslog


#[1]CB008200_5G_B_F_SA_Accessibility_counter_007_QosFlow_Setup_Fail_due_to_Wrong_Message_from_Core_with_unsupported_QoS_combination
#    [Documentation]    This user scenario describes the gNB behaviour for the unsuccessful initiation of the
#    ...    VoNR/Emergency voice call for UE in idle state. If invalid QoS flow combination is NOT supported by gNB,
#    ...    then new QoS flow setup message will be rejected with cause 'invalid QoS Combination'. For detailed
#    ...    procedure refer to 5G_RAN_USR_RRM_2167 and 5G_RAN_USR_RRM_2154 Exception Scenario.
#    ...    Invalid QoS flow combination are as below:
#    ...    For one PDU session, normal QoS flow co-exist with emergency QoS flow. (3GPP 23.501 does not allow this case)
#    ...    For one emergency PDU session, there’s QoS flow other than 5QI 1/5.
#    ...    For one UE, there’re two ore more 5QI 1 QoS flows.
#    [Tags]    CB008200-B    CRT_22R3    CRT_22R4
#    [Timeout]    1 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    choice required APN on UE    usedapn=@{apn_location}[8]    ue_type=@{ues_type}[0]    ue_index=${0}
##    Online modify parmeters    parameters_to_update=${PARAM_8200_B_007}
#    Exit the PCF service
#    Start PCF service    ims=${new_ims}    ip=${PCF_IP}
#    ####set gnb1 cell1 PA to 0
#    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[0]    gnb1_cell2_value=@{PA_list}[3]
#    ...    gnb2_cell1_value=@{PA_list}[3]    enb_cell1_value=@{PA_list}[3]
#    Step1: UE attach    ue_type=@{ues_type}[0]
#    Prepare with PM counter time to caculate    period=start
#    Start capture gNB log on master    filename=${log_name_B_007}
#    Configure and commit the QoS with 2 5QI1    five_qi=${five_qi}    priorityLevel1=${priorityLevel1}
#    ...    priorityLevel2=${priorityLevel2}    server_ip1=${server_ip1}    server_ip2=${server_ip2}
#    sleep    30s
#    Stop and download Logs on gNB on master    filename=${log_name_B_007}
#    Prepare with PM counter time to caculate    period=end
#    Check wireshark log for 007
#    Check counter for 007
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    choice required APN on UE    usedapn=@{apn_location}[1]    ue_type=@{ues_type}[0]
#    ...    ue_index=${0}    AND
#    ...    Step4: Detach UE    ue_type=@{ues_type}[0]    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_007}    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on eNB    log_name=${enb_log_name_B_007}    AND
##    ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${2}    AND
#    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    AND
#    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[0]    gnb1_cell2_value=@{PA_list}[0]
#    ...    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[0]    AND
#    ...    Exit the PCF service    AND
##    ...    Online modify parmeters    parameters_to_update=${PARAM_8200_recover_B_007}    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown


#[1]CB008700-A_021_Counter_ICS_when_ARP_based_admission_control_enabled_with_Data_PDU_Session_including_not_supported_QoS
#    [Documentation]    This user scenario describes Initial Context Setup procedure where AMF requests one or more PDU
#    ...    sessions and needed count of DRBs is not available.This use case does not describe a scenario where AMF requests
#    ...    initial context setup containing both Ue Radio Capabilities and PDU Session(s).Such scenario has been optimised
#    ...    by 3GPP and required dedicated user scenario for better readability.
#    ...    See USBasicCall-C#B2: Initial Context Setup with one or multiple PDU sessions (with UE Radio Capability)
#    [Tags]    CB008700-A     CRT_22R4    CRT_22R3
#    [Timeout]    1 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Prepare UE settings    ue_type=@{ues_type}[0]
#    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[0]    gnb1_cell2_value=@{PA_list}[3]
#    ...    gnb2_cell1_value=@{PA_list}[3]    enb_cell1_value=@{PA_list}[3]
#    Online modify parmeters    parameters_to_update=${PARAM_8700_A_021}
#    Prepare with PM counter time to caculate    period=start
#    Start capture gNB log on master    filename=${log_name_A_21}
#    UE attach then enable data    ue_type=${ue_type}
#    Stop and download Logs on gNB on master    filename=${log_name_A_21}
#    Prepare with PM counter time to caculate    period=end
#    Check wireshark log for 8700_A_021    logname=${log_name_A_21}
#    Check counter for 8700_A_021
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Recover APN   AND
#	...    Step4: Detach UE    ue_type=@{ues_type}[0]    AND
#    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_A_21}    AND
##    ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${2}    AND
#    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    AND
#    ...    Online modify parmeters    parameters_to_update=${PARAM_8700_recover_A_021}    AND
#    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[0]    gnb1_cell2_value=@{PA_list}[0]
#    ...    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[0]    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown


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
#    ...    Check_RF_Log=True

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

COAM Save snapshot
    get gnb snapshot    gnb_index=${0}
    get gnb snapshot    gnb_index=${1}

get gnb snapshot
    [Arguments]     ${gnb_index}=${0}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}
#    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    [Teardown]    COAM Teardown gnb connections

choice required APN on UE
    [Arguments]    ${usedapn}    ${ue_type}    ${ue_index}=${0}    #${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${data_enable}=false    ${status}=enable
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    set apn to wap2    usedapn=${usedapn}    ue_index=${ue_index}
    Run Keyword If    '${data_enable}'=='false'    Comment    Do not operate UE data button
    ...    ELSE IF    '${data_enable}'=='true'    Setup UE data status    status=${status}
    make airplane mode to enable    ue_index=${ue_index}

make airplane mode to enable
    [Arguments]    ${ue_index}=${0}    #${serial_number}=${tl.ues[${ue_index}].serial_number}
    log to console    enable airplane mode
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${False}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}

Prepare UE settings
    [Arguments]    ${ue_type}
    RUN KEYWORD IF    ${enb_instance} == ${enb_id}[7]
    ...    Prepare UE APN settings    ue_type=${ue_type}    mdrbapn=${mdrbapn}
    ...    ELSE IF    ${enb_instance} == ${enb_id}[5]
    ...    Prepare UE APN settings    ue_type=${ue_type}    mdrbapn=${mdrbapn}

Prepare UE APN settings
    [Arguments]    ${ue_type}    ${mdrbapn}    ${ue_index}=${0}
    Check UE device exist    ue_index=${ue_index}
    Huawei UE setup    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed}    Run Keyword And Ignore Error    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    set apn to wap2    usedapn=${mdrbapn}
    Setup UE data status    status=disable
    Commercial_mobile_phone_adb_common_keywords.Connect to control pc via cygwin    hostname=${hostname}    ue_index=${ue_index}
    Commercial_mobile_phone_adb_common_keywords.Commercial UE click AIRPLANE once     Home_button=${home}

Recover APN
    RUN KEYWORD IF    ${enb_instance} == ${enb_id}[7]
    ...    set apn to wap2    usedapn=${wap2_APN}
    ...    ELSE IF    ${enb_instance} == ${enb_id}[5]
    ...    set apn to wap2    usedapn=${wap2_APN}

UE attach then enable data
    [Arguments]    ${ue_type}    ${ue_index}=${0}
    Huawei UE setup    ue_type=${ue_type}    ue_index=${ue_index}
    Commercial_mobile_phone_adb_common_keywords.Connect to control pc via cygwin    hostname=${hostname}    ue_index=${ue_index}
    Commercial_mobile_phone_adb_common_keywords.Commercial UE click AIRPLANE once     Home_button=${home}
    ...    airplane=${airplane}    ue_index=${ue_index}    close_task=${close_task}
    sleep    1s
    Setup UE data status
    sleep    30s

Repeat check voice call status with UE
    check voice call status    status=${2}
    sleep    1m

###check wireshar log
Check wireshark log for 001
    Check EPSFB message on gnb    logname=${log_name_B_001}
    Check EPSFB mesage on enb    logname=${enb_log_name_B_001}

Check wireshark log for 002
    Check idle EMC fallback message on gnb    logname=${log_name_B_002}

Check wireshark log for 003
    Check EMC fallback message on gnb    logname=${log_name_B_003}
    Check EMC fallback message on enb    logname=${enb_log_name_B_003}

Check wireshark log for 007
    Check invalid QoS Combination message on gnb    logname=${log_name_B_007}

Check wireshark log for 008
    Check VoNR call failed message with unspecified    logname=${log_name_B_008}

Check wireshark log for 009
    Check VoNR call success message with intra gnb HO    logname=${log_name_B_009}

Check wireshark log for 010
    Check VoNR success message    logname=${log_name_B_010}
    Check VoNR call success message with inter gnb HO source    logname=${log_name_B_010_1}
    Check VoNR call success message with inter gnb HO target    logname=${log_name_B_010_2}

Check wireshark log for 011
    Check VoNR success message    logname=${log_name_B_011}
    check message with B2 event of Inter_RAT HO    logname=${log_name_B_011_1}
    check message with B2 event of Inter_RAT HO on enb    logname=${enb_log_name_B_011_1}
    ####2023/03/20 teams chat with yuanxuan and cindy add the EDA(23R3),details refer to Email:Customer AP202206280732380181
    ####2023/05/08 Chang the EDA from TL029 to TL382
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Check EDA 02836560    logname=${log_name_B_011_0}
    ...    ELSE       Sleep    1s

Check wireshark log for 012
    Check VoNR call success message with intra gnb re-establish    logname=${log_name_B_012_1}

Check wireshark log for 013
    Check attach successful message     logname=${log_name_B_013_1}

Check wireshark log for 013_2
    Check VoNR release success message    logname=${log_name_B_013_2}

Check wireshark log for 013_3
    Check VoNR success message    logname=${log_name_B_013_3}


###check counter on WEBUI
Check trunk counter for 001
    sleep    40s
    Check gnb counter as expected_value
    ...    counter_id=${Trunk24R2_NG_FLOW_SETUP_FAIL_FALLBACK['counter_id']}
    ...    dic_path=${Trunk24R2_NG_FLOW_SETUP_FAIL_FALLBACK['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${Trunk24R2_NG_FLOW_SETUP_FAIL_FALLBACK['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${Trunk24R2_NG_FLOW_STP_FAIL_FALBACK_PMQAP['counter_id']}
    ...    dic_path=${Trunk24R2_NG_FLOW_STP_FAIL_FALBACK_PMQAP['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${Trunk24R2_NG_FLOW_STP_FAIL_FALBACK_PMQAP['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${Trunk24R2_NG_FLOW_STP_FAIL_FALBACK_5QI1['counter_id']}
    ...    dic_path=${Trunk24R2_NG_FLOW_STP_FAIL_FALBACK_5QI1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${Trunk24R2_NG_FLOW_STP_FAIL_FALBACK_5QI1['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${Trunk24R2_NR_RRC_RELEASE_REDIR_VFB_LTE['counter_id']}
    ...    dic_path=${Trunk24R2_NR_RRC_RELEASE_REDIR_VFB_LTE['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${Trunk24R2_NR_RRC_RELEASE_REDIR_VFB_LTE['gnb_id']}

Check counter for 001
#    RUN KEYWORD IF    ${enb_instance} == @{enb_id}[0]    sleep    1s
#    ...    ELSE    sleep    40s
    sleep    40s
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_FAIL_FALLBACK['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_FAIL_FALLBACK['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_SETUP_FAIL_FALLBACK['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_PMQAP['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_5QI1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NR_RRC_RELEASE_REDIR_VFB_LTE['counter_id']}
    ...    dic_path=${NR_RRC_RELEASE_REDIR_VFB_LTE['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NR_RRC_RELEASE_REDIR_VFB_LTE['gnb_id']}

Check counter for 002_1
    sleep    80s
    Check inactive counter as expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_UE_INACTIVITY['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_UE_INACTIVITY['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_REL_GNB_UE_INACTIVITY['gnb_id']}

Check counter for 002_2
    sleep    10s
    Check multi cell of gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_FAIL_FALLBACK_2['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_FAIL_FALLBACK_2['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${NG_FLOW_SETUP_FAIL_FALLBACK_2['gnb_id']}
    Check multi cell of gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_2['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_2['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_2['gnb_id']}
    Check multi cell of gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1_2['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_5QI1_2['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1_2['gnb_id']}

Check counter for 003
    sleep    40s
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_FAIL_FALLBACK['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_FAIL_FALLBACK['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_SETUP_FAIL_FALLBACK['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_PMQAP['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_5QI1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1['gnb_id']}

Check counter for 007
    sleep    40s
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_FAIL_WRONG_MSG['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_FAIL_WRONG_MSG['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${NG_FLOW_SETUP_FAIL_WRONG_MSG['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_WRG_MSG_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_WRG_MSG_5QI1['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${NG_FLOW_STP_FAIL_WRG_MSG_5QI1['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_WRG_MSG_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_WRG_MSG_PMQAP['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${NG_FLOW_STP_FAIL_WRG_MSG_PMQAP['gnb_id']}

Check counter for 008
    sleep    40s
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_FAIL_UNSPECIFIED['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_FAIL_UNSPECIFIED['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_SETUP_FAIL_UNSPECIFIED['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_FAIL_UNSPC_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_FAIL_UNSPC_PMQAP['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_SETUP_FAIL_UNSPC_PMQAP['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_FAIL_UNSPC_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_FAIL_UNSPC_5QI1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_SETUP_FAIL_UNSPC_5QI1['gnb_id']}

Check counter for 009
    sleep    30s
    Check multi cell of gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_5QI1_2['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_5QI1_2['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_5QI1_2['gnb_id']}
    Check multi cell of gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_5QI1_2['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_5QI1_2['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_5QI1_2['gnb_id']}
    Check multi cell of gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP_2['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_PMQAP_2['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP_2['gnb_id']}
    Check multi cell of gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP_2['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_PMQAP_2['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP_2['gnb_id']}
    Check multi cell of gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO['gnb_id']}
    Check multi cell of gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO['gnb_id']}

Check counter for 010
    sleep    40s
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_5QI1_3['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_5QI1_3['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_5QI1_3['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_5QI1_3['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_5QI1_3['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_5QI1_3['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP_3['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_PMQAP_3['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP_3['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP_3['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_PMQAP_3['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP_3['gnb_id']}

Check trunk counter for 011
    sleep    40s
    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_REL_IRAT_SUC_HO_5QI1['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_REL_IRAT_SUC_HO_5QI1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${Trunk_NG_FLOW_REL_IRAT_SUC_HO_5QI1['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_REL_IRAT_SUC_HO_PMQAP['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_REL_IRAT_SUC_HO_PMQAP['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${Trunk_NG_FLOW_REL_IRAT_SUC_HO_PMQAP['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${Trunk_NG_FLOW_REL_IRAT_SUC_HO['counter_id']}
    ...    dic_path=${Trunk_NG_FLOW_REL_IRAT_SUC_HO['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${Trunk_NG_FLOW_REL_IRAT_SUC_HO['gnb_id']}


Check counter for 011
#    RUN KEYWORD IF    ${enb_instance} == @{enb_id}[0]    sleep    2min
#    ...    ELSE    sleep    40s
    sleep    40s
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_IRAT_SUC_HO_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_IRAT_SUC_HO_5QI1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_REL_IRAT_SUC_HO_5QI1['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_IRAT_SUC_HO_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_REL_IRAT_SUC_HO_PMQAP['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_REL_IRAT_SUC_HO_PMQAP['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_IRAT_SUC_HO['counter_id']}
    ...    dic_path=${NG_FLOW_REL_IRAT_SUC_HO['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_REL_IRAT_SUC_HO['gnb_id']}

Check counter for 012
    sleep    40s
    Check multi cell of gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_RES_IADU_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_RES_IADU_PMQAP['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_ATT_RES_IADU_PMQAP['gnb_id']}
    Check multi cell of gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_RES_IADU_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_RES_IADU_5QI1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_ATT_RES_IADU_5QI1['gnb_id']}
    Check multi cell of gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_RES_IADU_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_RES_IADU_PMQAP['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_SUC_RES_IADU_PMQAP['gnb_id']}
    Check multi cell of gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_RES_IADU_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_RES_IADU_5QI1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_SUC_RES_IADU_5QI1['gnb_id']}
    Check multi cell of gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_REEST_IADU['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_REEST_IADU['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_ATT_REEST_IADU['gnb_id']}
    Check multi cell of gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_REEST_IADU['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_REEST_IADU['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_SUC_REEST_IADU['gnb_id']}

Check counter for 013_1
    sleep    40s
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_ATT_TOT_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_ATT_TOT_PMQAP['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${NG_FLOW_SETUP_ATT_TOT_PMQAP['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_ATT_TOT['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_ATT_TOT['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${NG_FLOW_SETUP_ATT_TOT['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_SUCC['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_SUCC['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${NG_FLOW_SETUP_SUCC['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_SUCC_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_SUCC_PMQAP['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${NG_FLOW_SETUP_SUCC_PMQAP['gnb_id']}

Check counter for 013_3
    sleep    40s
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_ATT_TOT_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_ATT_TOT_5QI1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_SETUP_ATT_TOT_5QI1['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_SUCC_TOT_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_SUCC_TOT_5QI1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_SETUP_SUCC_TOT_5QI1['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_ATT_TOT_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_ATT_TOT_PMQAP['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_SETUP_ATT_TOT_PMQAP['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_ATT_TOT['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_ATT_TOT['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_SETUP_ATT_TOT['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_SUCC['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_SUCC['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_SETUP_SUCC['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_SUCC_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_SUCC_PMQAP['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_SETUP_SUCC_PMQAP['gnb_id']}

Check counter for 013_2
    sleep    40s
    Check gnb counter greater expected_value
    ...    counter_id=${NG_FLOW_CON_SESSION_TIME_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_CON_SESSION_TIME_PMQAP['dic_path']}
    ...    expected_value=${3600}
    ...    gnb_id=${NG_FLOW_CON_SESSION_TIME_PMQAP['gnb_id']}
    Check gnb counter greater expected_value
    ...    counter_id=${NG_FLOW_CONNECTED_SESSION_TIME['counter_id']}
    ...    dic_path=${NG_FLOW_CONNECTED_SESSION_TIME['dic_path']}
    ...    expected_value=${3600}
    ...    gnb_id=${NG_FLOW_CONNECTED_SESSION_TIME['gnb_id']}
    Check gnb counter greater expected_value
    ...    counter_id=${NG_FLOW_SESSION_DUR_NORM_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_SESSION_DUR_NORM_5QI1['dic_path']}
    ...    expected_value=${3600}
    ...    gnb_id=${NG_FLOW_SESSION_DUR_NORM_5QI1['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_AMF_NORMAL_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_AMF_NORMAL_5QI1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_REL_AMF_NORMAL_5QI1['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_AMF_NORMAL_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_REL_AMF_NORMAL_PMQAP['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_REL_AMF_NORMAL_PMQAP['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_NORMAL_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_NORMAL_5QI1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_REL_NORMAL_5QI1['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_AMF_NORMAL['counter_id']}
    ...    dic_path=${NG_FLOW_REL_AMF_NORMAL['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_REL_AMF_NORMAL['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_REL_PMQAP['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_REL_PMQAP['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_NORMAL_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_REL_NORMAL_PMQAP['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_REL_NORMAL_PMQAP['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL['counter_id']}
    ...    dic_path=${NG_FLOW_REL['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_REL['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_NORMAL['counter_id']}
    ...    dic_path=${NG_FLOW_REL_NORMAL['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_REL_NORMAL['gnb_id']}

Check wireshark log for 8700_A_021
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ...    command_template=${command_template_with_Y}    alias=test
    ${pduResetupreq} =    Catenate    ngap.procedureCode == 29 and ngap.fiveQI
    ${filtered_packets}=    filter_packets_by_expression
    ...    filter_expression=${pduResetupreq}    pcap_parser=test
    ${qos_id_req}=    get_field_value_by_xpath    xpath=.//ngap.qosFlowIdentifier  pcap_parser=test
    ${5qi_value}=    get_field_value_by_xpath    xpath=.//ngap.fiveQI  pcap_parser=test
    ${Pri_ARP}=    get_field_value_by_xpath    xpath=.//ngap.priorityLevelARP  pcap_parser=test
    ${qos_num}=    get length    ${qos_id_req}
    should be equal    ${qos_num}    ${5}
    should be equal    ${5qi_value}    ${Pri_ARP}
    FOR    ${qos_index}    IN RANGE    ${qos_num}
        run keyword if     ${Pri_ARP[${qos_index}]}==3    Set Suite Variable    ${5QI3_qos}    ${qos_id_req[${qos_index}]}
        run keyword if     ${Pri_ARP[${qos_index}]}==7    Set Suite Variable    ${5QI7_qos}    ${qos_id_req[${qos_index}]}
        run keyword if     ${Pri_ARP[${qos_index}]}==9    Set Suite Variable    ${5QI9_qos}    ${qos_id_req[${qos_index}]}
    END
    ${pduResetupresp} =    Catenate    ngap.procedureCode == 29 and ngap.qosFlowFailedToSetupList
    ${filtered_packets}=    filter_packets_by_expression
    ...    filter_expression=${pduResetupresp}    pcap_parser=test
    ${qos_id_resp}=    get_field_value_by_xpath    xpath=.//ngap.qosFlowIdentifier  pcap_parser=test
    ${qos_id_resp_failed}    create List    ${qos_id_resp[-3]}   ${qos_id_resp[-2]}   ${qos_id_resp[-1]}
    ${radioNetwork}=    get_field_value_by_xpath    xpath=.//ngap.radioNetwork  pcap_parser=test
    FOR    ${qos_failed_index}    IN RANGE    ${3}
        run keyword if 	  ${qos_id_resp_failed[${qos_failed_index}]}== ${5QI3_qos}
    ...		should be equal    ${radioNetwork[${qos_failed_index}]}    34
        run keyword if 	  ${qos_id_resp_failed[${qos_failed_index}]}== ${5QI7_qos}
    ...		should be equal    ${radioNetwork[${qos_failed_index}]}    22
        run keyword if 	  ${qos_id_resp_failed[${qos_failed_index}]}== ${5QI9_qos}
    ...		should be equal    ${radioNetwork[${qos_failed_index}]}    22
    END

Setup UE data status
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${status}=enable
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell svc data ${status}    connection=cygwin${ue_index}
    sleep   2s
    csn.disconnect      connection=cygwin${ue_index}

Check counter for 8700_A_021
    sleep    40s
    Check gnb counter greater expected_value
    ...    counter_id=${SA_PART_ADMISSION['counter_id']}
    ...    dic_path=${SA_PART_ADMISSION['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${SA_PART_ADMISSION['gnb_id']}
    Check gnb counter greater expected_value
    ...    counter_id=${NG_FLOW_SETUP_ATT_TOT_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_ATT_TOT_PMQAP['dic_path']}
    ...    expected_value=${6}
    ...    gnb_id=${NG_FLOW_SETUP_ATT_TOT_PMQAP['gnb_id']}
    Check gnb counter greater expected_value
    ...    counter_id=${NG_FLOW_SETUP_SUCC_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_SUCC_PMQAP['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_SETUP_SUCC_PMQAP['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_FAIL_RRNA_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_FAIL_RRNA_PMQAP['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${NG_FLOW_SETUP_FAIL_RRNA_PMQAP['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_ATT_TOT['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_ATT_TOT['dic_path']}
    ...    expected_value=${6}
    ...    gnb_id=${NG_FLOW_SETUP_ATT_TOT['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_SUCC['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_SUCC['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_SETUP_SUCC['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_FAIL_RRNA['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_FAIL_RRNA['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${NG_FLOW_SETUP_FAIL_RRNA['gnb_id']}

Check IE wireshark log for F1 configure
    [Arguments]    ${logname}    ${message_filter}   #${value}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
    ${nr_rrc_sn_FieldLength}=     cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//nr-rrc.sn_FieldLength
    should be equal    ${nr_rrc_sn_FieldLength[0]}    1

Check IE wireshark log for E1_dRB_Inactivity configure
    [Arguments]    ${logname}    ${message_filter}   #${value}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
    ${e1ap_dRB_Inactivity_Timer}=     cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//e1ap.dRB_Inactivity_Timer
    should be equal    ${e1ap_dRB_Inactivity_Timer[0]}    600

Check IE wireshark log for VONR setup
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
    should be equal    ${ngap_fiveQI[0]}    1

Check EDA 02836560
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    f1ap.procedureCode == 12 and  lte-rrc.FreqBandIndicator_r11 == 3
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${FreqBandIndicator_r11}=     cap.get_field_value_by_xpath   xpath=.//lte-rrc.FreqBandIndicator_r11    pcap_parser=test6
    should be equal    ${FreqBandIndicator_r11[0]}    3

check inter rat ho kpi
    [Arguments]    ${para_index}=${2}
    ${dict_inter_rat_ho_kpi}=    get dict kpi from pm file   KPI_file=CB008200_counters.txt    para_index=${para_index}
    Should Be Equal As Numbers    ${dict_inter_rat_ho_kpi}[NR_5195a]    ${1.0}
    Should Be Equal As Numbers    ${dict_inter_rat_ho_kpi}[NR_5423a]    ${0.0}
    Should Be Equal As Numbers    ${dict_inter_rat_ho_kpi}[NR_5424a]    ${0.0}
    Should Be Equal As Numbers    ${dict_inter_rat_ho_kpi}[NR_5425a]    ${0.0}
    Should Be Equal As Integers    ${dict_inter_rat_ho_kpi}[NNGCC_IRATHO_CANCEL]    ${0}
    Should Be Equal As Integers    ${dict_inter_rat_ho_kpi}[NNGCC_IRATHO_EXE_SUC]    ${1}
    Should Be Equal As Integers    ${dict_inter_rat_ho_kpi}[NNGCC_UE_CTX_REL_RELOC_OVERALL]    ${0}
    Should Be Equal As Integers    ${dict_inter_rat_ho_kpi}[NNGCC_IRATHO_CANCEL_ACK_RCVD]    ${0}
