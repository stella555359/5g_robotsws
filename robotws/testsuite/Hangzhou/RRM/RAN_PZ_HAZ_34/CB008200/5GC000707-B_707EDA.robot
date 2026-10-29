*** Settings ***
Documentation
...    author: Zhang Yayun
...    contact: Yayun.zhang@nokia-sbell.com
...    squal group: SG03
...    feature: CB008200-B

Force Tags  CA_5G_RRM    RAN_5G    RAN_5G_TDD    CLOUD_5G_CLASSICAL_ANDROID_ASIKL_ABILB1_AAHF_RF_SHARING_ENB
...         STATE_SW_UPLOADED    PY36
Suite Setup    Run Keywords
...            robot_common_operations.Common Suite Setup
...            AND    Get gnb release info
...            AND    Get sagnb version for selenium
...            AND    Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    ${sw_version}_gNB1_Golden_SCF.xml
#...            AND    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${tl_scf_${release_info}}
...            AND    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${tl_gnb1_scf_${sw_version}}
...            AND    Common Suite Setup for COAM
...            AND    Common UE parameter setup
...            AND    Run Keyword And Ignore Error    Online modify parmeters    parameters_to_update=${PARAM_gnb1_AES}

Suite Teardown    Run Keywords
...    robot_common_operations.Common Suite Teardown
...    AND    Run Keyword And Ignore Error    Online modify parmeters    parameters_to_update=${PARAM_recover_gnb1_AES}


Resource     Resources/CB008200_common_keywords_new.robot
Variables    Resources/CB008200_variables_new.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot


*** Variables ***
${tl_scf_file_name1_golden}    Configuration_scf_GNB1_EDA.xml
${log_name_707_1}    log_name_707_1.pcap
@{ues_type}    huawei    samsung
@{PA_list}    ${0}    ${30}    ${45}    ${127}
${command_template_with_Z}    {tshark_path} -r {pcap_file} -Y  \"ngap or e1ap or f1ap or xnap or s1ap\"  -T pdml > log.pdml
${hostname}    ${tl.ues[0].ssh_connection_details.addr}
@{diffTL_enb_ID}    36721    38221    911
${enb_instance}     ${tl.enbs[0].instance_id}
#@{nr_rrc_eventId_value}    0    1
@{nr_rrc_eventId_value}    0    1    2
@{nr_rrc_carrierFreq_value}    1699

${sys_logs_path}    /tmp/btslog2/
${UTE_logs_path}    /home/ute/ERR_WRN_logs/
${testline_name}          null
${base_file}    None
@{filter_list}    None

${Test_PC_IP}          ${tl.test_pc.default_ssh_connection_details.addr}
${Test_PC_username}    ${tl.test_pc.default_ssh_connection_details.username}
${Test_PC_password}    ${tl.test_pc.default_ssh_connection_details.password}

*** Test Cases ***
[1]5GC000707-B_001_alternative bands can be used to compute mapped EARFCN while defined band not supported by ue in RHOIR earfcnValue
    [Documentation]    This user scenario validates the functionality for B2 success conifg while the narfcn not support by ue that configed
    ...    in NOHOIR nrarfcn. It's can mapped earfcn (ue support arfcn)is used to configure B2 measurement in the UE
    [Tags]    CB008200-B    CRT    TRUNK
    [Timeout]    1 hour
    [Setup]    robot_common_operations.Common Case Setup
    Comment     set gnb1 cell2 PA to 0
    Start capture syslog via btslog on ute
    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${PA_list}[3]    gnb1_cell2_value=${PA_list}[0]
    ...    gnb2_cell1_value=${PA_list}[3]    enb_cell1_value=${PA_list}[3]
    Start capture gNB log on master    filename=${log_name_707_1}
    Step1: UE attach    ue_type=${ues_type}[0]    ue_index=${1}
    Comment    set gnb1 cell2 PA to 45
    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${PA_list}[3]    gnb1_cell2_value=${PA_list}[2]
    ...    gnb2_cell1_value=${PA_list}[3]    enb_cell1_value=${PA_list}[3]
    sleep    30s
    Stop and download Logs on gNB on master    filename=${log_name_707_1}
    Stop capture syslog via btslog on ute
    Check wireshark log for 707EDA    logname=${log_name_707_1}
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Step4: Detach UE    ue_type=${ues_type}[0]    ue_index=${1}   AND
    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_707_1}    AND
    ...    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot    AND
    ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${PA_list}[0]    gnb1_cell2_value=${PA_list}[0]
    ...    gnb2_cell1_value=${PA_list}[0]    enb_cell1_value=${PA_list}[0]    AND
    ...    Run Keyword And Ignore Error    Stop capture syslog via btslog on ute    AND
    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown    AND
    ...    get and analysis syslog

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

#Check wireshark log for 707EDA
#    [Arguments]    ${logname}
#    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}   alias=test6
#    ${filter_expression}=     Catenate    nr-rrc.eventId == 1 and f1ap.procedureCode == 12 and nr-rrc.reportConfig == 1
#    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
#    ${nr_rrc_eventId}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.eventId    pcap_parser=test6
#    should contain     ${nr_rrc_eventId}    1
#    should contain     ${nr_rrc_eventId}    0
#    Sort List    ${nr_rrc_eventId}
#    Lists Should be Equal    ${nr_rrc_eventId}    ${nr_rrc_eventId_value}
#    ${filter_expression}=     Catenate    nr-rrc.measObject == 1 and f1ap.procedureCode == 12
#    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
#    ${nr_rrc_carrierFreq}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.carrierFreq    pcap_parser=test6
#    Lists Should be Equal        ${nr_rrc_carrierFreq}    ${nr_rrc_carrierFreq_value}
#    should not contain     ${nr_rrc_carrierFreq}    3900

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
    get gnb snapshot    gnb_index=${1}

get gnb snapshot
    [Arguments]     ${gnb_index}=${0}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}
#    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    [Teardown]    COAM Teardown gnb connections

make airplane mode to enable
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Log    ${serial_number}
    log to console    enable airplane mode
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${False}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}

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
Setup UE data status
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${status}=enable
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell svc data ${status}    connection=cygwin${ue_index}
    sleep   2s
    csn.disconnect      connection=cygwin${ue_index}
