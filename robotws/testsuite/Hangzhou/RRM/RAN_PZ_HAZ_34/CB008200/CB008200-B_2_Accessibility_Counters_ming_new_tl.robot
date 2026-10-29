*** Settings ***
Documentation
...    author: Shi Ming
...    contact: ming.shi@nokia-sbell.com
...    squal group: SG03
...    feature: CB008200-B

Force Tags  CA_5G_RRM
...    PY36
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot

Suite Setup    Run Keywords
...                            robot_common_operations.Common Suite Setup
...                            AND    Common Suite Setup for COAM
...                            AND    Setup Env for test
...                            AND    Common UE parameter setup
...                            AND    Huawei UE setup    ue_type=${ue_type}    ue_index=${0}
...                            AND    Wait Until Keyword Succeeds    3x    10s    set apn dxdata2
...                            AND    get_release_check_result
...                            AND    paras change on BTS
...                                   paras=${CB008200_ciphering_algorithms}
...                                   delta_file_name=${epc_log_path}${CB008200_ciphering_algorithms_json_file}

Suite Teardown    Run keywords    robot_common_operations.Common Suite Teardown
...                               AND    Common Suite Teardown for COAM    gnb_list=@{gnb_index}
...                               AND    paras change on BTS
...                                      paras=${CB008200_recover_ciphering_algorithms}
...                                      delta_file_name=${epc_log_path}${CB008200_recover_ciphering_algorithms_json_file}


Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008200/Resources/CB008200_common_keywords_ming_new_tl.robot
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008200/Resources/CB008200_variables_ming.py
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008200/Resources/CB008200_multi_gnb_variables_ming.py
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot


*** Variables ***
${log_name_B_001}    log_name_B_001.pcap
${enb_log_name_B_001}    enb_log_name_B_001.pcap
${log_name_B_001_1}    log_name_B_001_1.pcap
${log_name_B_002_attach}    log_name_B_002_attach.pcap
${log_name_B_002_1}    log_name_B_002_1.pcap
${log_name_B_002}    log_name_B_002.pcap
${log_name_B_002_2}    log_name_B_002_2.pcap
${enb_log_name_B_002}    enb_log_name_B_002.pcap
${log_name_B_003}    log_name_B_003.pcap
${enb_log_name_B_003}    enb_log_name_B_003.pcap
${log_name_B_007}    log_name_B_007.pcap
${enb_log_name_B_007}    enb_log_name_B_007.pcap
${log_name_B_008}    log_name_B_008.pcap
${log_name_B_009}    log_name_B_009.pcap
${log_name_B_010_1}    log_name_B_010_1.pcap
${log_name_B_010_2}    log_name_B_010_2.pcap
${log_name_B_010_attach}    log_name_B_010_attach.pcap
${log_name_B_010}    log_name_B_010.pcap
${log_name_B_011_0}    log_name_B_011_0.pcap
${log_name_B_011_1}    log_name_B_011_1.pcap
${enb_log_name_B_011_1}    enb_log_name_B_011_1.pcap
${log_name_B_011}    log_name_B_011.pcap
${log_name_B_012}    log_name_B_012.pcap
${log_name_B_012_1}    log_name_B_012_1.pcap
${log_name_B_013_1}    log_name_B_013_1.pcap
${log_name_B_013_2}    log_name_B_013_2.pcap
${log_name_EDA_04943472_0}    log_name_EDA_04943472_0.pcap
${log_name_EDA_04943472_1}    log_name_EDA_04943472_1.pcap
${log_name_EDA_04943472_2}    log_name_EDA_04943472_2.pcap

${log_name_707_1}    log_name_707_1.pcap

${B_002_message_filter}    ngap.emergencyFallbackRequestIndicator == 0 or ngap.radioNetwork == 41

#${ue_type}    samsung

${enb_instance}     ${tl.enbs[0].instance_id}
@{enb_dist_name}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-3    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNMME-0
@{enb_para}    administrativeState    ipAddrPrim
@{enb_value}    unlocked    locked    10.107.245.164    10.108.225.167

@{cell_id}    0    1    2    3    4    5
@{cell_id_348}    0    1    2    3    4    5    6
@{multi_gnb_PA}    ${5}    ${26}    ${40}    ${0}    ${30}    ${127}    ${15}    ${34}
@{PA_list}    0    30    45    127

${tl_scf_file_name1}    gNB1_Golden_SCF.xml
${tl_scf_file_name2}    gNB2_Golden_SCF.xml

@{gnb_index}    ${0}    ${1}

${dxdata2_apn}    95 943
#${dxdata2_apn_348}    150 943
${dxdata2_apn_348}    95 1030
${click_access_point}    380 1060

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

${MRBTS_ID}    ${tl.gnbs[0].instance_id}

${att_ipaddr_1}    ${tl.attenuator[1].ip_addr}

#@{nr_rrc_eventId_value}    0    1    2
@{nr_rrc_eventId_value}    0    1    1    1    2

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
    [Timeout]    2 hour
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=4291
    AlarmWatchdog.add_allow_alarms    fault_id=4291
    Check UE device status with adb recover    ue_index=${0}
#    put btslog_ini file to ute
#    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
#    Start capture syslog via btslog on ute
    IF    ${enb_instance} == ${enb_id}[3]    #TL348
        Online delete parmeters    parameters_to_update=${PARAM_DELETE_8200_B_001_348}    timeout=${300}
        Online modify parmeters    parameters_to_update=${PARAM_8200_B_001_348}    skip_parameter_relation_errors=False
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
    ELSE IF    ${enb_instance} == ${enb_id}[4]    #TL383
        Online delete parmeters    parameters_to_update=${PARAM_DELETE_8200_B_001_348}    timeout=${300}
        Online modify parmeters    parameters_to_update=${PARAM_8200_B_001_348}    skip_parameter_relation_errors=False
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
    END
    Start capture gNB log on master    filename=${log_name_B_001_1}
    Step1: UE attach    ue_type=${ue_type}
    Stop and download Logs on gNB on master    filename=${log_name_B_001_1}
    comment    set enb cell PA to 0
    IF    ${enb_instance} == ${enb_id}[3]     #TL348
#        Online modify parmeters    parameters_to_update=${PARAM_8200_B_WA_348}    skip_parameter_relation_errors=False
        Change Attenuation value 4 port for multi PAs    cell=4Gcell${cell_id_348}[3]    value=${multi_gnb_PA}[3]
    ELSE IF    ${enb_instance} == ${enb_id}[4]     #TL383
#        Online modify parmeters    parameters_to_update=${PARAM_8200_B_WA_348}    skip_parameter_relation_errors=False
        Change Attenuation value 4 port for multi PAs    cell=4Gcell${cell_id_348}[3]    value=${multi_gnb_PA}[3]
    END
    Prepare with PM counter time to caculate    period=start
    Start capture gNB log on master    filename=${log_name_B_001}
    Step2: UE setup VoNR call
    sleep    20s
    check voice call status    status=${2}
    Step3: UE hang up VoNR call
    check voice call status    status=${0}
    Stop and download Logs on gNB on master    filename=${log_name_B_001}
    Prepare with PM counter time to caculate    period=end
    Check wireshark log for 001
    IF    ${enb_instance} == ${enb_id}[3]     #TL348
        Check counter for 001 348
    ELSE IF    ${enb_instance} == ${enb_id}[4]     #TL383
        Check counter for 001 348
    END
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown
    ...    AND    AlarmWatchdog.remove_allow_alarms    fault_id=4291
    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot via api
    ...    AND    Step3: UE hang up VoNR call
    ...    AND    check voice call status    status=${0}
    ...    AND    Step4: Detach UE    ue_type=${ue_type}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_001_1}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_001}
    ...    AND    recover paras and pa value on B001
#    ...    AND    Stop capture syslog via btslog on ute
    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#    ...    AND    get and analysis syslog

#[1]CB008200_5G_B_F_SA_Accessibility_counter_002_QosFlow_Setup_Fail_due_to_Successful_Emergency_Fallback_when_UE_in_IDLE
#    [Documentation]  This User Scenario is to provide the counters used for measuring SA accessibility.
#    ...    The User scenario creates a counter to measure the number of QosFlows that failed to Setup
#    ...    due to Voice Fallback. The User scenario is a rerun of 5G_RAN_USR_RRM_3527 for Emergency Fallback.
#    [Tags]    CB008200-B    CIT_TRUNK    CRT_22R2    CRT_22R3    CIT_22R4    CIT_23R1
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup    allowed_faults_ids=4291
#    AlarmWatchdog.add_allow_alarms    fault_id=4291
#    Check UE device status with adb recover    ue_index=${0}
##    Check UE device status with adb recover    ue_index=${1}
#    IF    ${enb_instance} == ${enb_id}[3]     #TL348
#        Online delete parmeters    parameters_to_update=${PARAM_DELETE_8200_B_002_348}
#        Online modify parmeters    parameters_to_update=${PARAM_8200_B_002_348}    skip_parameter_relation_errors=False
#        ###set gnb1 cell1 PA to 0
#        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
#    ELSE IF    ${enb_instance} == ${enb_id}[4]     #TL383
#        online delete and add list parameter    gnb_index=${0}
#        Online delete parmeters    parameters_to_update=${PARAM_DELETE_8200_B_002_383}
#        IF    '${release_info}' == 'SBTS24R3_ENB_0000'
#            Online modify parmeters    parameters_to_update=${PARAM_8200_B_002_383_24R3}    skip_parameter_relation_errors=False
#        ELSE IF    '${release_info}' == 'SBTS25R1_ENB_0000' or '${release_info}' == 'SBTS25R2_ENB_0000'
#            Online modify parmeters    parameters_to_update=${PARAM_8200_B_002_383}    skip_parameter_relation_errors=False
#        ELSE
#            Online modify parmeters    parameters_to_update=${PARAM_8200_B_002_25R3_383}    skip_parameter_relation_errors=False
#        END
#        PA one cell 0 on and set other cell value 4 port    cellid=${cell_id}[1]    set_value=${multi_gnb_PA}[0]
#    END
#    UE attach and make data disable and check
#    IF    ${enb_instance} == ${enb_id}[3]     #TL348
#        Online modify parmeters    parameters_to_update=${PARAM_8200_B_002_WA_348}    skip_parameter_relation_errors=False
#    ELSE IF    ${enb_instance} == ${enb_id}[4]     #TL383
#        Online modify parmeters    parameters_to_update=${PARAM_8200_B_002_WA}    skip_parameter_relation_errors=False
#    END
#    put btslog_ini file to ute
#    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
#    Start capture syslog via btslog on ute
#    Wait Until Keyword Succeeds    3x    10s    setup emc call and check
#    Start capture gNB log on master    filename=${log_name_B_002}
#    Prepare with PM counter time to caculate    period=start
#    Sleep    45s
#    ####set gnb1 cell3 and enb cell1 PA to 0
#    IF    ${enb_instance} == ${enb_id}[3]     #TL348
#        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[3]    ip_addr=${att_ipaddr_1}
#        Change Attenuation value 4 port for multi PAs    cell=4Gcell${cell_id_348}[3]    value=${multi_gnb_PA}[3]
#    ELSE IF    ${enb_instance} == ${enb_id}[4]     #TL383
#        Change Attenuation value 4 port    cell=5Gcells${cell_id}[2]    value=${multi_gnb_PA}[3]    #TL383
#        Change Attenuation value 4 port    cell=4Gcells${cell_id}[1]    value=${multi_gnb_PA}[3]
#    END
#    Sleep    15s
#    ####set gnb1 cell1 PA to 127
#    IF    ${enb_instance} == ${enb_id}[3]     #TL348
##        Set attenuation to trigger
#        Change Attenuation value 4 port for multi PAs    cell=5Gcell1    value=${127}
#    ELSE IF    ${enb_instance} == ${enb_id}[4]     #TL383
#        Change Attenuation value 4 port    cell=5Gcells1    value=${127}
#    END
#    sleep    30s
#    Stop and download Logs on gNB on master    filename=${log_name_B_002}
#    Stop capture syslog via btslog on ute
#    Prepare with PM counter time to caculate    period=end
#    Check wireshark log for 002
#    IF    ${enb_instance} == ${enb_id}[3]     #TL348
#        Check counter for 002_2
#    ELSE IF    ${enb_instance} == ${enb_id}[4]     #TL383
#        Check counter for 002_2 tl383
#    END
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
#    ...    AND    AlarmWatchdog.remove_allow_alarms    fault_id=4291
#    ...    AND    Step3: UE hang up EMC call
#    ...    AND    sleep    5m
#    ...    AND    check voice call status    status=${0}
#    ...    AND    Setup UE data status    status=enable
#    ...    AND    Step4: Detach UE    ue_type=${ue_type}
#    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_002_attach}
#    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_002_1}
#    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_002}
#    ...    AND    recover paras and pa value
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#    ...    AND    Run Keyword And Ignore Error    Stop capture syslog via btslog on ute
#    ...    AND    Run Keyword And Ignore Error    Common Case Teardown for COAM
#    ...    AND    get and analysis syslog

#[1]CB008200_5G_B_F_SA_Accessibility_counter_009_VoNR_QosFlow_Setup_when_Intra-gNB_Intra-DU_HO
#    [Documentation]    This User Scenario is to provide the counters used for measuring SA accessibility.
#    ...    The User scenario creates a counter to measure the success ratio of QosFlows Setup
#    ...    due to incoming handovers. The User scenario is a rerun of multiple scenarios 5G_RAN_USR_RRM_xxx:
#    ...    Intra-gNB Intra-DU HO (5G Control Plane - 5G_RAN_CP_12371397)
#    [Tags]    CB008200-B    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1
#    [Timeout]    1 hour
#    [Setup]
#    Online modify parmeters    parameters_to_update=${PARAM_8200_B_009}
#    ###set gnb1 cell1 PA to 5
#    robot_common_operations.Common Case Setup
#    Check UE device status with adb recover    ue_index=${0}
#    Check UE device status with adb recover    ue_index=${1}
#    PA one cell 0 on and set other cell value    cellid=@{cell_id}[1]
#    CB008200_common_keywords_ming_new_tl.Prepare UE For MTK80    ue_index=${1}    cap_index=${0}
#    CB008200_common_keywords_ming_new_tl.Do UE Attach    ue_index=${1}
#    CB008200_common_keywords_ming_new_tl.Verify UE Attach Success
#    Wait Until Keyword Succeeds    3x    5s    Run Keywords
#    ...    Make a VoNR call(+6688) on mtk80    ue_index=${1}
#    ...    AND    sleep    20s
#    ...    AND    check voice call status    status=${2}    ue_index=${1}
#    ###set gnb1 cell3 PA to 0
#    Change Attenuation value    cell=5Gcell@{cell_id}[3]    value=@{multi_gnb_PA}[6]
#    Prepare with PM counter time to caculate    period=start
#    Start capture gNB log on master    filename=${log_name_B_009}
#    add attenuation for 1db    port1=${5Gcell1_ANT1}    port2=${5Gcell1_ANT2}
#    ...    origin_value=@{multi_gnb_PA}[3]    target_value=@{multi_gnb_PA}[2]
#    sleep    30s
#    Stop and download Logs on gNB on master    filename=${log_name_B_009}
#    Prepare with PM counter time to caculate    period=end
#    Check wireshark log for 009
#    Check counter for 009
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
#    ...    AND    Step3: UE hang up VoNR call    ue_index=${1}
#    ...    AND    check voice call status    status=${0}    ue_index=${1}
#    ...    AND    CB008200_common_keywords_ming_new_tl.Do UE Detach    ue_index=${1}
#    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_009}
#    ...    AND    Online modify parmeters    parameters_to_update=${PARAM_8200_recover_B_009}
#    ...    AND    PA one cell 0 on and set other cell value    cellid=@{cell_id}[1]
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

#[1]CB008200_5G_B_F_SA_Accessibility_counter_010_VoNR_QosFlow_Setup_when_Inter-gNB_Xn_HO
#    [Documentation]    This User Scenario is to provide the counters used for measuring SA accessibility.
#    ...    The User scenario creates a counter to measure the success ratio of QosFlows Setup due to incoming handovers.
#    ...    The User scenario is a rerun of multiple scenarios Inter-gNB Xn HO (5G Control Plane - 5G_RAN_CP_12788):
#    ...    a UE for which Inter-frequency A3/A5 measurements have been configured sends a Inter-frequency A3/A5 measurement
#    ...    report and gNB performs handover based on the measurement report to a cell in the same gNB-DU.
#    [Tags]    CB008200-B    CIT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CIT_23R1
#    [Timeout]    2 hour
#    [Setup]
#    robot_common_operations.Common Case Setup    allowed_faults_ids=4291
#    AlarmWatchdog.add_allow_alarms    fault_id=4291
#    Check UE device status with adb recover    ue_index=${0}
##    Check UE device status with adb recover    ue_index=${1}
#    Online modify parmeters    gnb_index=${1}    parameters_to_update=${PARAM_8200_B_010_2}    skip_parameter_relation_errors=False
#    ###set gnb1 cell1 PA to 5
#    IF    ${enb_instance} == ${enb_id}[3]    #TL348
#        Online modify parmeters    parameters_to_update=${PARAM_8200_B_010_1_348}    skip_parameter_relation_errors=False
#        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
#    ELSE IF    ${enb_instance} == ${enb_id}[4]    #TL383
#        Online modify parmeters    parameters_to_update=${PARAM_8200_B_010_1}    skip_parameter_relation_errors=False
#        PA one cell 0 on and set other cell value 4 port    cellid=${cell_id}[1]    set_value=${multi_gnb_PA}[0]
#    END
#    Start capture gNB log on master    filename=${log_name_B_010_attach}
#    Step1: UE attach    ue_type=${ue_type}
#    Stop and download Logs on gNB on master    filename=${log_name_B_010_attach}
#    Start capture gNB log on master    filename=${log_name_B_010}
#    Wait Until Keyword Succeeds    3x    5s    Run Keywords    Run Keyword If    '${ue_type}' == 'samsung' or '${ue_type}' == 'Huawei'
#    ...    Step2: UE setup VoNR call
#    ...    ELSE IF    '${ue_type}' == 'qct_dx50'    Make a VoNR call(+6688) on SDX70
#    ...    AND    sleep    20s
#    ...    AND    check voice call status    status=${2}
#    Stop and download Logs on gNB on master    filename=${log_name_B_010}
#    Prepare with PM counter time to caculate    period=start
#    put btslog_ini file to ute
#    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
#    Start capture syslog via btslog on ute
#    Start capture gNB log on master    filename=${log_name_B_010_1}
#    Start capture gNB log on master    filename=${log_name_B_010_2}    gNB_index=${1}
#    ###set gnb2 cell1 PA to 15    #TL348
#    IF    ${enb_instance} == ${enb_id}[3]     #TL348
#        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[6]    value=${multi_gnb_PA}[3]    ip_addr=${att_ipaddr_1}
#        add attenuation for 5db 4 port    port1=${5Gcell1_ANT1}    port2=${5Gcell1_ANT2}    port3=${5Gcell1_ANT3}    port4=${5Gcell1_ANT4}
#        ...    origin_value=${multi_gnb_PA}[3]    target_value=${multi_gnb_PA}[7]
#    ###set gnb2 cell1 PA to 5    #TL383
#    ELSE IF    ${enb_instance} == ${enb_id}[4]     #TL383
#        Change Attenuation value    cell=5Gcells${cell_id}[4]    value=${multi_gnb_PA}[0]
#        ###set gnb1 cell1 PA to 40db,handover to gnb2 cell1   TL383
#        add attenuation for 5db 4 port    port1=${5Gcells1_ANT1}    port2=${5Gcells1_ANT2}    port3=${5Gcells1_ANT3}    port4=${5Gcells1_ANT4}
#        ...    origin_value=${multi_gnb_PA}[3]    target_value=${multi_gnb_PA}[4]
#    END
#    sleep    30s
#    Stop and download Logs on gNB on master    filename=${log_name_B_010_1}
#    Stop and download Logs on gNB on master    filename=${log_name_B_010_2}    gNB_index=${1}
#    Stop capture syslog via btslog on ute
#    Prepare with PM counter time to caculate    period=end
#    Check wireshark log for 010
#    IF    ${enb_instance} == ${enb_id}[3]     #TL348
#        Check counter for 010 348
#    ELSE IF    ${enb_instance} == ${enb_id}[4]     #TL383
#        Check counter for 010
#    END
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
#    ...    AND    AlarmWatchdog.remove_allow_alarms    fault_id=4291
#    ...    AND    Step3: UE hang up VoNR call
#    ...    AND    sleep    20s
#    ...    AND    check voice call status    status=${0}
#    ...    AND    Step4: Detach UE    ue_type=${ue_type}
#    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_010_attach}
#    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_010}
#    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_010_1}
#    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_010_2}    gNB_index=${1}
#    ...    AND    recover paras and pa value on B010
#    ...    AND    Run Keyword And Ignore Error    Stop capture syslog via btslog on ute
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#    ...    AND    get and analysis syslog

[1]CB008200_5G_B_F_SA_Accessibility_counter_011_VoNR_QosFlow_Setup_when_Inter-RAT_HO_to_LTE
    [Documentation]    This User Scenario is to provide the counters used for measuring SA accessibility.
    ...    The User scenario creates a counter to measure the success ratio of QosFlows Setup due to incoming handovers.
    ...    The User scenario is a rerun of multiple scenarios Inter-RAT HO from LTE (5G Control Plane - 5G_RAN_CP_12361454)
    [Tags]    CB008200-B    CRT_22R3    CIT_22R4
    [Timeout]    3 hour
    robot_common_operations.Common Case Setup    allowed_faults_ids=4291
    AlarmWatchdog.add_allow_alarms    fault_id=4291
    Check UE device status with adb recover    ue_index=${0}
    steps for EDA_04943472    is_64Qam_CELL=both
#    steps for EDA_04943472    is_64Qam_CELL=400
#    steps for EDA_04943472    is_64Qam_CELL=700
    ####2023/03/20 teams chat with yuanxuan and cindy add the EDA(23R3),details refer to Email:Customer AP202206280732380181
    ####2023/05/08 Chang the EDA from TL029 to TL382
    ####2025/06/23 Chang the EDA from TL382 to TL348/TL383
    Online modify parmeters    parameters_to_update=${PARAM_8200_B_011_EDA}    skip_parameter_relation_errors=False
    IF    ${enb_instance} == ${enb_id}[3]    #TL348
        Online modify parmeters    parameters_to_update=${PARAM_8200_B_011_348}    skip_parameter_relation_errors=False
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[5]    set_value=${multi_gnb_PA}[3]
    ELSE IF    ${enb_instance} == ${enb_id}[4]    #TL383
        Online modify parmeters    parameters_to_update=${PARAM_8200_B_011_348}    skip_parameter_relation_errors=False
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[5]    set_value=${multi_gnb_PA}[3]
    END
#    put btslog_ini file to ute
#    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
#    Start capture syslog via btslog on ute
    Start capture gNB log on master    filename=${log_name_B_011_0}
    Step1: UE attach    ue_type=${ue_type}
    Stop and download Logs on gNB on master    filename=${log_name_B_011_0}
    Prepare with PM counter time to caculate    period=start
    Start capture gNB log on master    filename=${log_name_B_011}
    Step2: UE setup VoNR call
    sleep    20s
    check voice call status    status=${2}
    Stop and download Logs on gNB on master    filename=${log_name_B_011}
    Prepare with PM counter time to caculate    period=end
    # CNI-136169 02396060 ADD 2025/12/23
    check CNI136169 counters    para_index=${3}
    Prepare with PM counter time to caculate    period=start
    Start capture gNB log on master    filename=${log_name_B_011_1}
    Comment     gnb1 cell1 PA to XXdb to trigger HO Inter RAT to LTE
    IF    ${enb_instance} == ${enb_id}[3]    #TL348
        Change Attenuation value 4 port for multi PAs    cell=4Gcell${cell_id_348}[3]    value=${multi_gnb_PA}[3]
        Sleep    5s
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[2]    ip_addr=${att_ipaddr_1}
    ELSE IF    ${enb_instance} == ${enb_id}[4]    #TL383
        Change Attenuation value 4 port for multi PAs    cell=4Gcell${cell_id_348}[3]    value=${multi_gnb_PA}[3]
        Sleep    5s
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[2]    ip_addr=${att_ipaddr_1}
    END
    sleep    30s
    Stop and download Logs on gNB on master    filename=${log_name_B_011_1}
    Prepare with PM counter time to caculate    period=end
    Comment     Add EDA 02836560
    Check wireshark log for 011
    IF    ${enb_instance} == ${enb_id}[3]     #TL348
        Check counter for 011 348
        check inter rat ho kpi    para_index=${3}
    ELSE IF    ${enb_instance} == ${enb_id}[4]     #TL383
        Check counter for 011 348
        check inter rat ho kpi    para_index=${3}
    END
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown
    ...    AND    AlarmWatchdog.remove_allow_alarms    fault_id=4291
    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot via api
    ...    AND    Step3: UE hang up VoNR call
    ...    AND    check voice call status    status=${0}
    ...    AND    Step4: Detach UE    ue_type=${ue_type}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_011_0}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_011}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_011_1}
#    ...    AND    Run Keyword And Ignore Error    Stop capture syslog via btslog on ute
    ...    AND    Online modify parmeters    parameters_to_update=${PARAM_8200_recover_B_011_EDA}    skip_parameter_relation_errors=False
    ...    AND    recover paras and pa value on B011
    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#    ...    AND    get and analysis syslog

#[1]CB008200_5G_B_F_SA_Accessibility_counter_012_VoNR_QosFlow_Setup_when_intra_gNB_re-establish
#    [Documentation]    This User scenario is to provide counters used for measuring SA accessibility.
#    ...    The User scenario creates counters to measure the success ratio of QosFlows Setup and Setup success
#    ...    due to intra Du / intra-gNB rrc reestablshment.
#    [Tags]    CB008200-B    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1
#    [Timeout]    1 hour
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Check UE device status with adb recover    ue_index=${0}
#    Check UE device status with adb recover    ue_index=${1}
#    Online modify parmeters    parameters_to_update=${PARAM_8200_B_012}
#    ###set gnb1 cell1 PA to 0
#    PA one cell 0 on and set other cell value    cellid=@{cell_id}[1]
#    CB008200_common_keywords_ming_new_tl.Prepare UE For MTK80    ue_index=${1}    cap_index=${0}
#    CB008200_common_keywords_ming_new_tl.Do UE Attach    ue_index=${1}
#    CB008200_common_keywords_ming_new_tl.Verify UE Attach Success
#    Start capture gNB log on master    filename=${log_name_B_012}
#    Wait Until Keyword Succeeds    3x    5s    Run Keywords
#    ...    Make a VoNR call(+6688) on mtk80    ue_index=${1}
#    ...    AND    sleep    20s
#    ...    AND    check voice call status    status=${2}    ue_index=${1}
#    ###set gnb1 cell3 PA to 0
##    Change Attenuation value    cell=5Gcell@{cell_id}[3]    value=@{multi_gnb_PA}[6]
#    Change Attenuation value    cell=5Gcell@{cell_id}[3]    value=@{multi_gnb_PA}[3]
#    Stop and download Logs on gNB on master    filename=${log_name_B_012}
#    Prepare with PM counter time to caculate    period=start
#    Start capture gNB log on master    filename=${log_name_B_012_1}
#    ###set gnb1 cell1 PA to 127
#    Set attenuation to trigger
#    sleep    30s
#    Stop and download Logs on gNB on master    filename=${log_name_B_012_1}
#    Prepare with PM counter time to caculate    period=end
#    Check wireshark log for 012
#    Check counter for 012
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown
#    ...    AND    Step3: UE hang up VoNR call    ue_index=${1}
#    ...    AND    check voice call status    status=${0}    ue_index=${1}
#    ...    AND    CB008200_common_keywords_ming_new_tl.Do UE Detach    ue_index=${1}
#    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_012}
#    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_012_1}
#    ...    AND    Run Keyword If    '${enb_instance}' == '@{enb_id}[4]'
#    ...    Online modify parmeters    parameters_to_update=${PARAM_8200_recover_B_012_383}
#    ...    ELSE    Online modify parmeters    parameters_to_update=${PARAM_8200_recover_B_012}
#    ...    AND    PA one cell 0 on and set other cell value    cellid=@{cell_id}[1]
#    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

[1]5GC000707-B_001_alternative bands can be used to compute mapped EARFCN while defined band not supported by ue in RHOIR earfcnValue
    [Documentation]    This user scenario validates the functionality for B2 success conifg while the narfcn not support by ue that configed
    ...    in NRHOIR nrarfcn. It's can mapped earfcn (ue support arfcn)is used to configure B2 measurement in the UE
    [Tags]    CB008200-B    CRT    TRUNK
    [Timeout]    1 hour
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=4291
    AlarmWatchdog.add_allow_alarms    fault_id=4291
    Check UE device status with adb recover    ue_index=${0}
    Comment     set gnb1 cell2 PA to 0
#    put btslog_ini file to ute
#    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
#    Start capture syslog via btslog on ute
    IF    ${enb_instance} == ${enb_id}[3]    #TL348
        Online modify parmeters    parameters_to_update=${PARAM_707_348}    skip_parameter_relation_errors=False
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[5]    set_value=${multi_gnb_PA}[3]
    ELSE IF    ${enb_instance} == ${enb_id}[4]    #TL383
        Online modify parmeters    parameters_to_update=${PARAM_707_348}    skip_parameter_relation_errors=False
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[5]    set_value=${multi_gnb_PA}[3]
    END
    Start capture gNB log on master    filename=${log_name_707_1}
    Step1: UE attach    ue_type=${ue_type}
    Prepare with PM counter time to caculate    period=start
    Sleep    1m
    Comment    set gnb1 cell2 PA to 45
    IF    ${enb_instance} == ${enb_id}[3]    #TL348
        Change Attenuation value 4 port for multi PAs    cell=4Gcell${cell_id_348}[3]    value=${multi_gnb_PA}[3]
        Sleep    5s
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[2]    ip_addr=${att_ipaddr_1}
    ELSE IF    ${enb_instance} == ${enb_id}[4]    #TL383
        Change Attenuation value 4 port for multi PAs    cell=4Gcell${cell_id_348}[3]    value=${multi_gnb_PA}[3]
        Sleep    5s
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[2]    ip_addr=${att_ipaddr_1}
    END
    sleep    30s
    Stop and download Logs on gNB on master    filename=${log_name_707_1}
#    Stop capture syslog via btslog on ute
    Prepare with PM counter time to caculate    period=end
    Check counter for 707 348
    check inter rat ho kpi for 707    para_index=${3}
    Check wireshark log for 707EDA    logname=${log_name_707_1}
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown
    ...    AND    AlarmWatchdog.remove_allow_alarms    fault_id=4291
    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    ...    AND    Step4: Detach UE    ue_type=${ue_type}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_707_1}
    ...    AND    recover paras and pa value on 707
#    ...    AND    Run Keyword And Ignore Error    Stop capture syslog via btslog on ute
    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#    ...    AND    get and analysis syslog

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
    sleep    5s    reason=Qcom UE need more time to unlock the phone
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

Make a EMC call on SDX70
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=911
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=cygwin${ue_index}
    sleep    5s    reason=Qcom UE need more time to unlock the phone
    #####make EMC call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.DIAL    connection=cygwin${ue_index}
    Sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input text ${phone_number}    connection=cygwin${ue_index}
    Sleep    2s
    # Qcom UE click the call button(Dialing keys)
    csn.send_command    command=adb -s ${serial_number} shell input tap 526 2129    connection=cygwin${ue_index}
    sleep   1s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

set apn dxdata2
    Set Suite Variable    ${close_task}    538 1874
    set apn with special method    usedapn=${dxdata2_apn_348}    location_apn=${click_access_point}

###check wireshar log
Check wireshark log for 001
    Check EPSFB message on gnb    logname=${log_name_B_001}
    Check EPSFB mesage on enb    logname=${log_name_B_001}

Check wireshark log for 002_1
    check into idle status    logname=${log_name_B_002_1}

Check wireshark log for 002
    Check idle EMC fallback message on gnb    logname=${log_name_B_002}

Check wireshark log for 003
    Check EMC fallback message on gnb    logname=${log_name_B_003}

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
    check message with B2 event of Inter_RAT HO on enb    logname=${log_name_B_011_1}
    Check EDA 02836560    logname=${log_name_B_011_0}

Check wireshark log for 012
    Check VoNR call success message with intra gnb re-establish    logname=${log_name_B_012_1}

Check wireshark log for 013
    Check VoNR success message    logname=${log_name_B_013_1}
    Check VoNR release success message    logname=${log_name_B_013_2}


###check counter on WEBUI
Check counter for 001 348
    sleep    40s
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_FAIL_FALLBACK_348['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_FAIL_FALLBACK_348['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_SETUP_FAIL_FALLBACK_348['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_348['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_348['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_348['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1_348['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_5QI1_348['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1_348['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NR_RRC_RELEASE_REDIR_VFB_LTE_348['counter_id']}
    ...    dic_path=${NR_RRC_RELEASE_REDIR_VFB_LTE_348['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NR_RRC_RELEASE_REDIR_VFB_LTE_348['gnb_id']}

Check counter for 001 383
    sleep    40s
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_FAIL_FALLBACK_383['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_FAIL_FALLBACK_383['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_SETUP_FAIL_FALLBACK_383['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_383['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_383['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_383['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1_383['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_5QI1_383['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1_383['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NR_RRC_RELEASE_REDIR_VFB_LTE_383['counter_id']}
    ...    dic_path=${NR_RRC_RELEASE_REDIR_VFB_LTE_383['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NR_RRC_RELEASE_REDIR_VFB_LTE_383['gnb_id']}

Check counter for 002_1_348
    [Arguments]      ${counter_index}=${0}    ${timeout}=60
    sleep    40s
    Run Keyword If    '${check_result}' != 'True'
    ...    Check gnb counter greater expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_UE_INACTIVITY_348['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_UE_INACTIVITY_348['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_REL_GNB_UE_INACTIVITY_348['gnb_id']}
    ...    counter_index=${counter_index}
    ...    timeout=${timeout}
    ...    ELSE
    ...    Check gnb counter greater expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_UE_INACTIVITY_trunk_348['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_UE_INACTIVITY_trunk_348['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_REL_GNB_UE_INACTIVITY_trunk_348['gnb_id']}
    ...    counter_index=${counter_index}
    ...    timeout=${timeout}

Check counter for 002_1
    [Arguments]      ${counter_index}=${0}    ${timeout}=60
    sleep    40s
    Run Keyword If    '${check_result}' != 'True'
    ...    Check gnb counter greater expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_UE_INACTIVITY['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_UE_INACTIVITY['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_REL_GNB_UE_INACTIVITY['gnb_id']}
    ...    counter_index=${counter_index}
    ...    timeout=${timeout}
    ...    ELSE
    ...    Check gnb counter greater expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_UE_INACTIVITY_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_UE_INACTIVITY_trunk['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_REL_GNB_UE_INACTIVITY_trunk['gnb_id']}
    ...    counter_index=${counter_index}
    ...    timeout=${timeout}

Check counter for 002_2
    sleep    60s
    Run Keyword If    '${check_result}' != 'True'    run keywords
    ...    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_FAIL_FALLBACK_2_348['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_FAIL_FALLBACK_2_348['dic_path']}
    ...    expected_value=${ICSF_length}
    ...    gnb_id=${NG_FLOW_SETUP_FAIL_FALLBACK_2_348['gnb_id']}
    ...    timeout=${600}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_2_348['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_2_348['dic_path']}
    ...    expected_value=${ICSF_length}
    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_2_348['gnb_id']}
    ...    timeout=${600}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1_2_348['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_5QI1_2_348['dic_path']}
    ...    expected_value=${ICSF_length}/2
    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1_2_348['gnb_id']}
    ...    timeout=${600}
    ...    ELSE    run keywords
    ...    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_FAIL_FALLBACK_2_trunk_348['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_FAIL_FALLBACK_2_trunk_348['dic_path']}
    ...    expected_value=${ICSF_length}
    ...    gnb_id=${NG_FLOW_SETUP_FAIL_FALLBACK_2_trunk_348['gnb_id']}
    ...    timeout=${600}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_2_trunk_348['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_2_trunk_348['dic_path']}
    ...    expected_value=${ICSF_length}
    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_2_trunk_348['gnb_id']}
    ...    timeout=${600}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1_2_trunk_348['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_5QI1_2_trunk_348['dic_path']}
    ...    expected_value=${ICSF_length}/2
    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1_2_trunk_348['gnb_id']}
    ...    timeout=${600}

Check counter for 002_2 tl383
    sleep    60s
    Run Keyword If    '${check_result}' != 'True'    run keywords
    ...    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_FAIL_FALLBACK_2_383['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_FAIL_FALLBACK_2_383['dic_path']}
    ...    expected_value=${ICSF_length}
    ...    gnb_id=${NG_FLOW_SETUP_FAIL_FALLBACK_2_383['gnb_id']}
    ...    timeout=${600}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_2_383['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_2_383['dic_path']}
    ...    expected_value=${ICSF_length}
    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_2_383['gnb_id']}
    ...    timeout=${600}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1_2_383['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_5QI1_2_383['dic_path']}
    ...    expected_value=${ICSF_length}/2
    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1_2_383['gnb_id']}
    ...    timeout=${600}
    ...    ELSE    run keywords
    ...    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_FAIL_FALLBACK_2_trunk_383['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_FAIL_FALLBACK_2_trunk_383['dic_path']}
    ...    expected_value=${ICSF_length}
    ...    gnb_id=${NG_FLOW_SETUP_FAIL_FALLBACK_2_trunk_383['gnb_id']}
    ...    timeout=${600}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_2_trunk_383['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_2_trunk_383['dic_path']}
    ...    expected_value=${ICSF_length}
    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_2_trunk_383['gnb_id']}
    ...    timeout=${600}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1_2_trunk_383['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_5QI1_2_trunk_383['dic_path']}
    ...    expected_value=${ICSF_length}/2
    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1_2_trunk_383['gnb_id']}
    ...    timeout=${600}

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
    Run Keyword If    '${check_result}' != 'True'    run keywords
    ...    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_5QI1_2['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_5QI1_2['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_5QI1_2['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_5QI1_2['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_5QI1_2['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_5QI1_2['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP_2['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_PMQAP_2['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP_2['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP_2['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_PMQAP_2['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP_2['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO['gnb_id']}
    ...    ELSE    run keywords
    ...    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_5QI1_2_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_5QI1_2_trunk['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_5QI1_2_trunk['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_5QI1_2_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_5QI1_2_trunk['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_5QI1_2_trunk['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP_2_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_PMQAP_2_trunk['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP_2_trunk['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP_2_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_PMQAP_2_trunk['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP_2_trunk['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_trunk['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_trunk['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_trunk['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_trunk['gnb_id']}

Check counter for 010 348
    sleep    40s
    Run Keyword If    '${check_result}' != 'True'    run keywords
    ...    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_5QI1_3_348['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_5QI1_3_348['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_5QI1_3_348['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_5QI1_3_348['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_5QI1_3_348['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_5QI1_3_348['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP_3_348['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_PMQAP_3_348['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP_3_348['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP_3_348['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_PMQAP_3_348['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP_3_348['gnb_id']}
    ...    ELSE    run keywords
    ...    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_5QI1_3_trunk_348['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_5QI1_3_trunk_348['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_5QI1_3_trunk_348['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_5QI1_3_trunk_348['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_5QI1_3_trunk_348['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_5QI1_3_trunk_348['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP_3_trunk_348['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_PMQAP_3_trunk_348['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP_3_trunk_348['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP_3_trunk_348['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_PMQAP_3_trunk_348['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP_3_trunk_348['gnb_id']}

Check counter for 010
    sleep    40s
    Run Keyword If    '${check_result}' != 'True'    run keywords
    ...    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_5QI1_3['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_5QI1_3['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_5QI1_3['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_5QI1_3['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_5QI1_3['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_5QI1_3['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP_3['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_PMQAP_3['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP_3['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP_3['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_PMQAP_3['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP_3['gnb_id']}
    ...    ELSE    run keywords
    ...    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_5QI1_3_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_5QI1_3_trunk['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_5QI1_3_trunk['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_5QI1_3_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_5QI1_3_trunk['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_5QI1_3_trunk['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP_3_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_PMQAP_3_trunk['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP_3_trunk['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP_3_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_PMQAP_3_trunk['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP_3_trunk['gnb_id']}

Check counter for 011
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

Check counter for 011 348
    sleep    40s
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_IRAT_SUC_HO_5QI1_348['counter_id']}
    ...    dic_path=${NG_FLOW_REL_IRAT_SUC_HO_5QI1_348['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_REL_IRAT_SUC_HO_5QI1_348['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_IRAT_SUC_HO_PMQAP_348['counter_id']}
    ...    dic_path=${NG_FLOW_REL_IRAT_SUC_HO_PMQAP_348['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_REL_IRAT_SUC_HO_PMQAP_348['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_IRAT_SUC_HO_348['counter_id']}
    ...    dic_path=${NG_FLOW_REL_IRAT_SUC_HO_348['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_REL_IRAT_SUC_HO_348['gnb_id']}

Check counter for 011 383
    sleep    40s
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_IRAT_SUC_HO_5QI1_383['counter_id']}
    ...    dic_path=${NG_FLOW_REL_IRAT_SUC_HO_5QI1_383['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_REL_IRAT_SUC_HO_5QI1_383['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_IRAT_SUC_HO_PMQAP_383['counter_id']}
    ...    dic_path=${NG_FLOW_REL_IRAT_SUC_HO_PMQAP_383['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_REL_IRAT_SUC_HO_PMQAP_383['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_IRAT_SUC_HO_383['counter_id']}
    ...    dic_path=${NG_FLOW_REL_IRAT_SUC_HO_383['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_REL_IRAT_SUC_HO_383['gnb_id']}

Check counter for 012
    sleep    40s
    Run Keyword If    '${check_result}' != 'True'    run keywords
    ...    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_RES_IADU_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_RES_IADU_PMQAP['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_ATT_RES_IADU_PMQAP['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_RES_IADU_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_RES_IADU_5QI1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_ATT_RES_IADU_5QI1['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_RES_IADU_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_RES_IADU_PMQAP['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_SUC_RES_IADU_PMQAP['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_RES_IADU_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_RES_IADU_5QI1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_SUC_RES_IADU_5QI1['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_REEST_IADU['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_REEST_IADU['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_ATT_REEST_IADU['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_REEST_IADU['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_REEST_IADU['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_SUC_REEST_IADU['gnb_id']}
    ...    ELSE    run keywords
    ...    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_RES_IADU_PMQAP_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_RES_IADU_PMQAP_trunk['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_ATT_RES_IADU_PMQAP_trunk['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_RES_IADU_5QI1_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_RES_IADU_5QI1_trunk['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_ATT_RES_IADU_5QI1_trunk['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_RES_IADU_PMQAP_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_RES_IADU_PMQAP_trunk['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_SUC_RES_IADU_PMQAP_trunk['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_RES_IADU_5QI1_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_RES_IADU_5QI1_trunk['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_SUC_RES_IADU_5QI1_trunk['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_REEST_IADU_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_REEST_IADU_trunk['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_ATT_REEST_IADU_trunk['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_REEST_IADU_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_REEST_IADU_trunk['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_SUC_REEST_IADU_trunk['gnb_id']}

Check counter for 013
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

Check counter for 707 348
    sleep    1m
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_IRAT_SUC_HO_5QI1_348['counter_id']}
    ...    dic_path=${NG_FLOW_REL_IRAT_SUC_HO_5QI1_348['dic_path']}
    ...    expected_value=${0}
    ...    gnb_id=${NG_FLOW_REL_IRAT_SUC_HO_5QI1_348['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_IRAT_SUC_HO_PMQAP_348['counter_id']}
    ...    dic_path=${NG_FLOW_REL_IRAT_SUC_HO_PMQAP_348['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${NG_FLOW_REL_IRAT_SUC_HO_PMQAP_348['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_IRAT_SUC_HO_348['counter_id']}
    ...    dic_path=${NG_FLOW_REL_IRAT_SUC_HO_348['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${NG_FLOW_REL_IRAT_SUC_HO_348['gnb_id']}

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

UE attach and make data disable and check
    Start capture gNB log on master    filename=${log_name_B_002_attach}
    Run Keyword If    '${ue_type}' == 'samsung' or '${ue_type}' == 'Huawei'    make WA with Samsung S21
    Step1: UE attach    ue_type=${ue_type}
    Stop and download Logs on gNB on master    filename=${log_name_B_002_attach}
    Prepare with PM counter time to caculate    period=start
    Start capture gNB log on master    filename=${log_name_B_002_1}
    Setup UE data status    status=disable
    sleep    10s
    Stop and download Logs on gNB on master    filename=${log_name_B_002_1}
    Prepare with PM counter time to caculate    period=end
    ####check RRC idle log
    Check wireshark log for 002_1
    IF    ${enb_instance} == ${enb_id}[3]     #TL348
        Check counter for 002_1_348    counter_index=${0}    timeout=${300}
    ELSE IF    ${enb_instance} == ${enb_id}[4]     #TL383
        Check counter for 002_1    counter_index=${0}    timeout=${300}
    END
#    Run Keyword If    '${ue_type}' != 'qct_dx50'    Check counter for 002_1    counter_index=${0}
#    ...    ELSE    Check counter for 002_1    counter_index=${1}

online delete and add list parameter
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    online operate list parameter    parameters=${LIST_PARAM_DELETE_8200_B_002}    operation=delete
    online operate list parameter    parameters=${LIST_PARAM_ADD_8200_B_002}    operation=update    skip_parameter_relation_errors=False
    [Teardown]    COAM Teardown gnb connections

online update recover list parameter
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    online operate list parameter    parameters=${LIST_PARAM_RECOVER_8200_B_002}    operation=update    skip_parameter_relation_errors=False
    [Teardown]    COAM Teardown gnb connections

recover paras and pa value on B001
    IF    ${enb_instance} == ${enb_id}[3]     #TL348
        Online delete parmeters    parameters_to_update=${PARAM_recover_delete_gnb1_8200_B_001_348}    timeout=${300}
        Online modify parmeters    parameters_to_update=${PARAM_8200_recover_B_001_348}    skip_parameter_relation_errors=False
        check cell on-air status
        Sleep    1m
        Online add parmeters    parameters_to_update=${PARAM_ADD_8200_B_001_348}    timeout=${300}
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
    ELSE IF    ${enb_instance} == ${enb_id}[4]     #TL383
        Online delete parmeters    parameters_to_update=${PARAM_recover_delete_gnb1_8200_B_001_348}    timeout=${300}
        Online modify parmeters    parameters_to_update=${PARAM_8200_recover_B_001_348}    skip_parameter_relation_errors=False
        check cell on-air status
        Sleep    1m
        Online add parmeters    parameters_to_update=${PARAM_ADD_8200_B_001_348}    timeout=${300}
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
    END

recover paras and pa value
    IF    ${enb_instance} == ${enb_id}[3]     #TL348
        Online add parmeters    parameters_to_update=${PARAM_ADD_8200_B_002_348}    timeout=${300}
        Online modify parmeters    parameters_to_update=${PARAM_8200_recover_B_002_348}    skip_parameter_relation_errors=False
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
    ELSE IF    ${enb_instance} == ${enb_id}[4]     #TL383
        IF    '${release_info}' == 'SBTS24R3_ENB_0000' or '${release_info}' == 'SBTS25R1_ENB_0000' or '${release_info}' == 'SBTS25R2_ENB_0000'
            Online modify parmeters    parameters_to_update=${PARAM_8200_recover_B_002_383}    skip_parameter_relation_errors=False
        ELSE
            Online modify parmeters    parameters_to_update=${PARAM_8200_recover_B_002_25R3_383}    skip_parameter_relation_errors=False
        END
        Online add parmeters    parameters_to_update=${PARAM_ADD_8200_B_002_383}    timeout=${300}
        online update recover list parameter    gnb_index=${0}
        PA one cell 0 on and set other cell value 4 port    cellid=${cell_id}[1]    set_value=${multi_gnb_PA}[0]
    END

recover paras and pa value on B010
    IF    ${enb_instance} == ${enb_id}[3]     #TL348
        Online modify parmeters    parameters_to_update=${PARAM_8200_recover_B_010_1_348}    skip_parameter_relation_errors=False
        Online modify parmeters
        ...    gnb_index=${1}    parameters_to_update=${PARAM_8200_recover_B_010_2_348}    skip_parameter_relation_errors=False
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
    ELSE IF    ${enb_instance} == ${enb_id}[4]     #TL383
        Online modify parmeters    parameters_to_update=${PARAM_8200_recover_B_010_1}    skip_parameter_relation_errors=False
        Online modify parmeters
        ...    gnb_index=${1}    parameters_to_update=${PARAM_8200_recover_B_010_2_383}    skip_parameter_relation_errors=False
        PA one cell 0 on and set other cell value 4 port    cellid=${cell_id}[1]    set_value=${multi_gnb_PA}[0]
    END

recover paras and pa value on B011
    IF    ${enb_instance} == ${enb_id}[3]     #TL348
        Online modify parmeters    parameters_to_update=${PARAM_8200_recover_B_011_348}    skip_parameter_relation_errors=False
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
    ELSE IF    ${enb_instance} == ${enb_id}[4]     #TL383
        Online modify parmeters    parameters_to_update=${PARAM_8200_recover_B_011_348}    skip_parameter_relation_errors=False
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
    END

recover paras and pa value on 707
    IF    ${enb_instance} == ${enb_id}[3]     #TL348
        Online modify parmeters    parameters_to_update=${PARAM_707_recover_348}    skip_parameter_relation_errors=False
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
    ELSE IF    ${enb_instance} == ${enb_id}[4]     #TL383
        Online modify parmeters    parameters_to_update=${PARAM_707_recover_348}    skip_parameter_relation_errors=False
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
    END

setup emc call and check
    setup EMC call and capture wireshark log
    ${status}=    Run Keyword And Return Status    check emc call if setup success    logname=${log_name_B_002_2}
    IF    ${status} == ${False}
        Step3: UE hang up EMC call
        sleep    20s
        check voice call status    status=${0}
        Fail    msg=EMC call not success
    ELSE IF    ${status} == ${True}
        Log    message=EMC call success
        check voice call status    status=${2}
    END

setup EMC call and capture wireshark log
    Start capture gNB log on master    filename=${log_name_B_002_2}
    Step2: UE setup EMC call
    sleep    20s
    check voice call status    status=${2}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_B_002_2}

check emc call if setup success
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ...    command_template=${command_template_with_Y}    alias=test6
    ${ics_pdu_accept} =    Catenate    ((ngap.NGAP_PDU == 0) && (ngap.procedureCode == 14)) && (ngap.priorityLevelARP == 1)
    Log    check InitialContextSetupRequest, DL NAS transport, PDU session establishment accept
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${ics_pdu_accept}    pcap_parser=test6
    ${ngap_priorityLevelARP}=    get_field_value_by_xpath    xpath=.//ngap.priorityLevelARP    pcap_parser=test6
    Should Be Equal    ${ngap_priorityLevelARP[0]}    1

    ${Code26_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log    check PDUSessionResourceModifyRequest
    ${Code26_0_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code26_0}    pcap_parser=test6
    should be equal    ${Code26_0_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_0}    pcap_parser=test6
    ${ngap_fiveQI}=    get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
    Should Be Equal    ${ngap_fiveQI[0]}    1

check CNI136169 counters
    [Arguments]    ${para_index}=${2}
    ${CNI136169_counters}=    get kpis of kpi file return dict kpi from pm file   KPI_file=CNI136169_counters.yml    para_index=${para_index}
    ${all_values}=    Evaluate    ${CNI136169_counters}.values()
    FOR    ${value}    IN    @{all_values}
        Should Be Equal As Numbers    ${value}    ${0}
    END

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

check inter rat ho kpi for 707
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
    Should Be Equal As Integers    ${dict_inter_rat_ho_kpi}[NG_FLOW_REL_IRAT_SUC_HO_PMQAP]    ${2}
    Should Be Equal As Integers    ${dict_inter_rat_ho_kpi}[NG_FLOW_REL_IRAT_FAIL_HO_PMQAP]    ${0}
    Should Be Equal As Integers    ${dict_inter_rat_ho_kpi}[NG_FLOW_REL_IRAT_SUC_HO]    ${2}
    Should Be Equal As Integers    ${dict_inter_rat_ho_kpi}[NG_FLOW_REL_IRAT_SUC_HO_5QI1]    ${0}

Check wireshark log for 707EDA
    [Arguments]    ${logname}
    ${nr_rrc_eventId_list}    Create List
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}   alias=test6
#    ${filter_expression}=     Catenate    nr-rrc.eventId == 1 and f1ap.procedureCode == 12 and nr-rrc.reportConfig == 1
    ${filter_expression}=     Catenate    (( f1ap.procedureCode == 12) && (nr-rrc.reportConfigId == 1)) && (nr-rrc.eventId == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_eventId}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.eventId    pcap_parser=test6
    should contain     ${nr_rrc_eventId}    1
    FOR    ${i}    IN    @{nr_rrc_eventId}
        Append To List    ${nr_rrc_eventId_list}    ${i}
    END
    ${filter_expression}=     Catenate    f1ap.procedureCode == 12 && nr-rrc.eventId == 0
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_eventId}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.eventId    pcap_parser=test6
    should contain     ${nr_rrc_eventId}    0
    FOR    ${i}    IN    @{nr_rrc_eventId}
        Append To List    ${nr_rrc_eventId_list}    ${i}
    END
    Sort List    ${nr_rrc_eventId_list}
    Lists Should be Equal    ${nr_rrc_eventId_list}    ${nr_rrc_eventId_value}
    ${filter_expression}=     Catenate    nr-rrc.measObject == 1 and f1ap.procedureCode == 12
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_carrierFreq}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.carrierFreq    pcap_parser=test6
#    Lists Should be Equal        ${nr_rrc_carrierFreq}    ${nr_rrc_carrierFreq_value}
    should not contain     ${nr_rrc_carrierFreq}    3900

COAM Save snapshot
    get gnb snapshot    gnb_index=${0}

get gnb snapshot
    [Arguments]     ${gnb_index}=${0}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    [Teardown]    COAM Teardown gnb connections

steps for EDA_04943472
    [Arguments]    ${is_64Qam_CELL}=both
    IF    '${is_64Qam_CELL}' == 'both'
        Online modify parmeters    parameters_to_update=${PARAM_EDA_04943472_CELL_ALL_64Qam_348}    skip_parameter_relation_errors=False
    ELSE IF    '${is_64Qam_CELL}' == '400'
        Online modify parmeters    parameters_to_update=${PARAM_EDA_04943472_CELL_400_64Qam_348}    skip_parameter_relation_errors=False
    ELSE IF    '${is_64Qam_CELL}' == '700'
        Online modify parmeters    parameters_to_update=${PARAM_EDA_04943472_CELL_700_64Qam_348}    skip_parameter_relation_errors=False
    END
    PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[3]
    UE attach and capture
    Prepare with PM counter time to caculate    period=start
    UE make voice and capture
    Prepare with PM counter time to caculate    period=end
    Sleep   1m
    IF    '${is_64Qam_CELL}' == 'both' or '${is_64Qam_CELL}' == '400'
        check CQI counters    para_index=${1}    is_256Qam_enable=${False}
    ELSE IF    '${is_64Qam_CELL}' == '700'
        check CQI counters    para_index=${1}    is_256Qam_enable=${True}
    END
    Prepare with PM counter time to caculate    period=start
    UE handover and capture
    Prepare with PM counter time to caculate    period=end
    Sleep   1m
    IF    '${is_64Qam_CELL}' == 'both' or '${is_64Qam_CELL}' == '700'
        check CQI counters    para_index=${3}    is_256Qam_enable=${False}
    ELSE IF    '${is_64Qam_CELL}' == '400'
        check CQI counters    para_index=${3}    is_256Qam_enable=${True}
    END
    [Teardown]    Run Keywords    Step3: UE hang up VoNR call
    ...    AND    Sleep    20s
    ...    AND    check voice call status    status=${0}
    ...    AND    Step4: Detach UE    ue_type=${ue_type}
    ...    AND    paras recover for EDA_04943472    is_64Qam_CELL=${is_64Qam_CELL}

paras recover for EDA_04943472
    [Arguments]    ${is_64Qam_CELL}=both
    IF    '${is_64Qam_CELL}' == 'both'
        Online modify parmeters    parameters_to_update=${PARAM_recover_EDA_04943472_CELL_ALL_64Qam_348}    skip_parameter_relation_errors=False
    ELSE IF    '${is_64Qam_CELL}' == '400'
        Online modify parmeters    parameters_to_update=${PARAM_recover_EDA_04943472_CELL_400_64Qam_348}    skip_parameter_relation_errors=False
    ELSE IF    '${is_64Qam_CELL}' == '700'
        Online modify parmeters    parameters_to_update=${PARAM_recover_EDA_04943472_CELL_700_64Qam_348}    skip_parameter_relation_errors=False
    END

UE attach and capture
    Start capture gNB log on master    filename=${log_name_EDA_04943472_0}
    Step1: UE attach    ue_type=${ue_type}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_EDA_04943472_0}

UE make voice and capture
    Start capture gNB log on master    filename=${log_name_EDA_04943472_1}
    Step2: UE setup VoNR call
    sleep    20s
    check voice call status    status=${2}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_EDA_04943472_1}

UE handover and capture
    Start capture gNB log on master    filename=${log_name_EDA_04943472_2}
    Comment     gnb1 cell1 PA to XXdb to trigger HO
    IF    ${enb_instance} == ${enb_id}[3]    #TL348
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[3]    ip_addr=${att_ipaddr_1}
        Sleep    5s
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[1]    value=${multi_gnb_PA}[2]
    ELSE IF    ${enb_instance} == ${enb_id}[4]    #TL383
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[5]    value=${multi_gnb_PA}[3]    ip_addr=${att_ipaddr_1}
        Sleep    5s
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cell_id_348}[1]    value=${multi_gnb_PA}[2]
    END
    sleep    30s
    check voice call status    status=${2}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_EDA_04943472_2}

check CQI counters
    [Arguments]    ${para_index}=${1}    ${is_256Qam_enable}=${True}
    ${kpi}=    get dict kpi from pm file   KPI_file=EDA_04943472_counters.txt    para_index=${para_index}
    ${sum_64_cqi_0_2}=    Evaluate
    ...    ${kpi}[WB_CQI_64TBL_5QI1_CQI_00]+${kpi}[WB_CQI_64TBL_5QI1_CQI_01]+${kpi}[WB_CQI_64TBL_5QI1_CQI_02]
    ${sum_64_cqi_3_5}=    Evaluate
    ...    ${kpi}[WB_CQI_64TBL_5QI1_CQI_03]+${kpi}[WB_CQI_64TBL_5QI1_CQI_04]+${kpi}[WB_CQI_64TBL_5QI1_CQI_05]
    ${sum_64_cqi_6_9}=    Evaluate
    ...    ${kpi}[WB_CQI_64TBL_5QI1_CQI_06]+${kpi}[WB_CQI_64TBL_5QI1_CQI_07]+${kpi}[WB_CQI_64TBL_5QI1_CQI_08]+${kpi}[WB_CQI_64TBL_5QI1_CQI_09]
    ${sum_64_cqi_10_13}=    Evaluate
    ...    ${kpi}[WB_CQI_64TBL_5QI1_CQI_10]+${kpi}[WB_CQI_64TBL_5QI1_CQI_11]+${kpi}[WB_CQI_64TBL_5QI1_CQI_12]+${kpi}[WB_CQI_64TBL_5QI1_CQI_13]
    ${sum_64_cqi_14_15}=    Evaluate
    ...    ${kpi}[WB_CQI_64TBL_5QI1_CQI_14]+${kpi}[WB_CQI_64TBL_5QI1_CQI_15]
    ${sum_64_cqi_all}=    Evaluate
    ...    ${sum_64_cqi_0_2}+${sum_64_cqi_3_5}+${sum_64_cqi_6_9}+${sum_64_cqi_10_13}+${sum_64_cqi_14_15}
    ${sum_64_cqi_123_pmqap}=    Evaluate
    ...    ${kpi}[WB_CQI_64TBL_CQI_BIN01_PMQAP] + ${kpi}[WB_CQI_64TBL_CQI_BIN02_PMQAP] + ${kpi}[WB_CQI_64TBL_CQI_BIN03_PMQAP]
    ${sum_64_cqi_45_pmqap}=    Evaluate
    ...    ${kpi}[WB_CQI_64TBL_CQI_BIN04_PMQAP] + ${kpi}[WB_CQI_64TBL_CQI_BIN05_PMQAP]
    ${sum_64_cqi_all_pmqap}=    Evaluate    ${sum_64_cqi_123_pmqap} + ${sum_64_cqi_45_pmqap}
    ${sum_256_cqi_0_2}=    Evaluate
    ...    ${kpi}[WB_CQI_256TBL_5QI1_CQI_00]+${kpi}[WB_CQI_256TBL_5QI1_CQI_01]+${kpi}[WB_CQI_256TBL_5QI1_CQI_02]
    ${sum_256_cqi_3_5}=    Evaluate
    ...    ${kpi}[WB_CQI_256TBL_5QI1_CQI_03]+${kpi}[WB_CQI_256TBL_5QI1_CQI_04]+${kpi}[WB_CQI_256TBL_5QI1_CQI_05]
    ${sum_256_cqi_6_9}=    Evaluate
    ...    ${kpi}[WB_CQI_256TBL_5QI1_CQI_06]+${kpi}[WB_CQI_256TBL_5QI1_CQI_07]+${kpi}[WB_CQI_256TBL_5QI1_CQI_08]+${kpi}[WB_CQI_256TBL_5QI1_CQI_09]
    ${sum_256_cqi_10_13}=    Evaluate
    ...    ${kpi}[WB_CQI_256TBL_5QI1_CQI_10]+${kpi}[WB_CQI_256TBL_5QI1_CQI_11]+${kpi}[WB_CQI_256TBL_5QI1_CQI_12]+${kpi}[WB_CQI_256TBL_5QI1_CQI_13]
    ${sum_256_cqi_14_15}=    Evaluate
    ...    ${kpi}[WB_CQI_256TBL_5QI1_CQI_14]+${kpi}[WB_CQI_256TBL_5QI1_CQI_15]
    ${sum_256_cqi_all}=    Evaluate
    ...    ${sum_256_cqi_0_2}+${sum_256_cqi_3_5}+${sum_256_cqi_6_9}+${sum_256_cqi_10_13}+${sum_256_cqi_14_15}
    ${sum_256_cqi_123_pmqap}=    Evaluate
    ...    ${kpi}[WB_CQI_256TBL_CQI_BIN01_PMQAP] + ${kpi}[WB_CQI_256TBL_CQI_BIN02_PMQAP] + ${kpi}[WB_CQI_256TBL_CQI_BIN03_PMQAP]
    ${sum_256_cqi_45_pmqap}=    Evaluate
    ...    ${kpi}[WB_CQI_256TBL_CQI_BIN04_PMQAP] + ${kpi}[WB_CQI_256TBL_CQI_BIN05_PMQAP]
    ${sum_256_cqi_all_pmqap}=    Evaluate    ${sum_256_cqi_123_pmqap} + ${sum_256_cqi_45_pmqap}
    IF    ${is_256Qam_enable} == ${True}
        Should Be True    ${sum_64_cqi_all} == 0
        Should Be True    ${sum_64_cqi_all_pmqap} == 0
        Should Be True    ${sum_256_cqi_all} > 0
        Should Be True    ${sum_256_cqi_all_pmqap} > 0
        Should Be True    ${kpi}[WB_CQI_256TBL_CQI_BIN01_PMQAP] >= ${sum_256_cqi_0_2}
        Should Be True    ${kpi}[WB_CQI_256TBL_CQI_BIN02_PMQAP] >= ${sum_256_cqi_3_5}
        Should Be True    ${kpi}[WB_CQI_256TBL_CQI_BIN03_PMQAP] >= ${sum_256_cqi_6_9}
        Should Be True    ${kpi}[WB_CQI_256TBL_CQI_BIN04_PMQAP] >= ${sum_256_cqi_10_13}
        Should Be True    ${kpi}[WB_CQI_256TBL_CQI_BIN05_PMQAP] >= ${sum_256_cqi_14_15}
    ELSE
        Should Be True    ${sum_256_cqi_all} == 0
        Should Be True    ${sum_256_cqi_all_pmqap} == 0
        Should Be True    ${sum_64_cqi_all} > 0
        Should Be True    ${sum_64_cqi_all_pmqap} > 0
        Should Be True    ${kpi}[WB_CQI_64TBL_CQI_BIN01_PMQAP] >= ${sum_64_cqi_0_2}
        Should Be True    ${kpi}[WB_CQI_64TBL_CQI_BIN02_PMQAP] >= ${sum_64_cqi_3_5}
        Should Be True    ${kpi}[WB_CQI_64TBL_CQI_BIN03_PMQAP] >= ${sum_64_cqi_6_9}
        Should Be True    ${kpi}[WB_CQI_64TBL_CQI_BIN04_PMQAP] >= ${sum_64_cqi_10_13}
        Should Be True    ${kpi}[WB_CQI_64TBL_CQI_BIN05_PMQAP] >= ${sum_64_cqi_14_15}
    END
