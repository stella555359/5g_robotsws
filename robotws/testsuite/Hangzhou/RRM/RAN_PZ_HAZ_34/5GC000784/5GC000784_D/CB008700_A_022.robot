*** Settings ***
Force Tags    PY36
Documentation     author: Xing Jing
...                 contact: jing.1.xing@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB008700_A

Resource    ../5GC000784_C/Resources/5GC000784_common_keyword_xiaomi.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Variables    ../5GC000784_C/Resources/5GC00784_C_variables.py



Suite Setup    run keywords
...    robot_common_operations.Common Suite Setup    AND
...    Common Suite Setup for COAM 784    AND
...    Load SCF 8700_A    AND
...    get_release_check_result

Suite Teardown    Run Keywords
...            robot_common_operations.Common Suite Teardown    AND
...            Run Keyword And Ignore Error    COAM Teardown gnb connections    AND
...            Adjust gNB_RU Attenuation


*** Variables ***
${SCF_path}    /opt/workspace/CRT/Master/SCF_file/
${epc_log_path}       /opt/workspace/CRT/Master/Case_Logs/
${tl_scf_filename_784B}    7326_784_SCF.xml
${tl_scf_filename_784B_2}    7326_784_SCF_gnb2.xml
${interface_gnb}    any
${interface_enb}    any
${nglogname1}    CB008700_A_022.pcap
${nglogname2}    CB008700_A_022_1.pcap
@{att_value}    0    120    8
${ue_index}    2
${nomal_call_number}    +6688
${EC_number}    911
@{expected_value_A22_gnb1}    ${1}    ${1}    ${1}    ${1}    ${5}    ${2}    ${5}    ${4}    ${1}
@{gnb_list_8700_A22}    ${0}    ${1}


*** Test Cases ***
[1]CB008700-A_022_Counter_ICS_when_ARP_based_admission_control_enabled_with_VoNR_PDU_Session_and_EMC_PDU_Session
    [Documentation]    Test case description the gNB behaviour for the successful setup of Emergency call after hold on
    ...                a VONR
    [Tags]    CRT_TRUNK    CB008700-A    CRT_22R3    CRT_22R4
    [Setup]
    robot_common_operations.Common Case Setup
    Modify the parameters for case A22
    wait until keyword succeeds    3X   10s    Trigger RRC Reestablishment Event
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    run keyword and ignore error    Tests Recover for case


*** Keywords ***
Modify the parameters for case A22
    Modify NIDD parameter on gnb    parameters_to_update=${PARAMETERS_TO_UPDATE_8700_A_22_1}    timeout=${300}
    wait until keyword succeeds    15min   60s    Check the gnb2 cell status onair    gnb_index=${0}
    Modify NIDD parameter on gnb    parameters_to_update=${PARAMETERS_TO_UPDATE_8700_A_22_2}    gnb_index=${1}    timeout=${300}
    wait until keyword succeeds    15min   60s    Check the gnb2 cell status onair    gnb_index=${1}

Trigger RRC Reestablishment Event
    Adjust gNB_RU Attenuation    gnb2_cell1_value=${0}
    Precondition for Sansumg UE    ue_type=${ue_type}    ui_version=S21UI3.1
#    put btslog_ini file to ute
#    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
#    Start capture syslog via btslog on ute
    Prepare with PM counter time to caculate    period=start
    sleep    40s
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname1}    interface=${interface_gnb}    gnb_index=${1}
    Attach and check power UE    ue_type=${ue_type}    gnb_index=${1}
    Make a VoNR call(+6688) samsung
    Make EMC call on samsung UE
    sleep    10s
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname1}    gnb_index=${1}
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname2}    interface=${interface_gnb}    gnb_index=${0}
    Adjust one port attenuation    gnb1_cell1_value=${0}
    Adjust one port attenuation    gnb2_cell1_value=${127}
    sleep    120s
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname2}    gnb_index=${0}
    Prepare with PM counter time to caculate    period=end
    Check counter for A22
#    Stop capture syslog via btslog on ute
    Check wireshark log for hold on and successful EC procedure    logname=${nglogname1}
    Check wireshark log for qosFlowFailed due to GBRBearers limit    logname=${nglogname1}    logname1=${nglogname2}
    [Teardown]    Run keywords
#    ...    Run Keyword And Ignore Error    Stop capture syslog via btslog on ute    AND
#    ...    get and analysis syslog    AND
    ...    run keyword and ignore error    hang up EMC call on samsung UE    AND
    ...    run keyword and ignore error    hang up VoNR call samsung    AND
    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname1}    gnb_index=${1}    AND
    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname2}    gnb_index=${0}    AND
    ...    run keyword and ignore error     Detach the test UE

Update gNB_RU Attenuation
    [Arguments]    ${value1}
    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'
    ...    Adjust the tl HBTE1 attenuation value   tl=${376}    value1=${value1}
    ...    ELSE IF    '${gnb_instance}'=='${gnb_id[2]}'
    ...    Adjust the tl HBTE1 attenuation value    tl=${388}    value1=${value1}
    ...    ELSE    Adjust the tl HBTE1 attenuation value    tl=${377}    value1=${value1}


Check wireshark log for hold on and successful EC procedure
    [Arguments]    ${logname}
    Check wireshark log for EC setup    logname=${logname}
    Check wireshark log for EC 5QI 5    logname=${logname}
    Check wireshark log for EC 5QI 1    logname=${logname}
    Check wireshark log for VONR and EC unrelease        logname=${logname}

Check wireshark log for VONR and EC unrelease
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_Y}
	...    alias=test6
    ###Check wireshark log for EMC unrelease
    ${filter_expression}=     Catenate    (ngap.nas == 0 and ngap.procedureCode == 28)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_nas}=     cap.Get Field Value By Xpath    xpath=.//ngap.nas    pcap_parser=test6
    Should Not Contain    ${ngap_nas}    0
    ###Check wireshark log for VONR unrelease
    ${filter_expression}=     Catenate     (ngap.nas == 0 and ngap.procedureCode == 26)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_nas}=     cap.Get Field Value By Xpath    xpath=.//ngap.nas    pcap_parser=test6
    Should Not Contain    ${ngap_nas}    0

Check wireshark log for qosFlowFailed due to GBRBearers limit
    [Arguments]    ${logname}    ${logname1}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_Y}
    ...    alias=test6
    ${qos_request}=    Catenate    (ngap.procedureCode == 26 and ngap.NGAP_PDU == 0)
    ${qos_request_packets}=    cap.filter_packets_by_expression    filter_expression=${qos_request}    pcap_parser=test6
    ${qosFlowIdentifier_voice}=    cap.get_field_value_by_xpath    xpath=.//ngap.qosFlowIdentifier    pcap_parser=test6

    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname1}    command_template=${command_template_Y}
    ...    alias=test6
    ${qos_request}=    Catenate    (ngap.procedureCode == 14 and ngap.priorityLevelARP == 1)
    ${qos_request_packets}=    cap.filter_packets_by_expression    filter_expression=${qos_request}    pcap_parser=test6
    ${qos_id_req}=    cap.get_field_value_by_xpath    xpath=.//ngap.qosFlowIdentifier  pcap_parser=test6
    ${5qi_value}=    cap.get_field_value_by_xpath    xpath=.//ngap.fiveQI  pcap_parser=test6
    should contain x times    ${5qi_value}    1    2
    ${Pri_ARP}=    cap.get_field_value_by_xpath    xpath=.//ngap.priorityLevelARP  pcap_parser=test6
    ${QoSFail}=    Catenate    (ngap.procedureCode == 14 and ngap.radioNetwork == 22)
    ${QoSFail_packets}=    cap.filter_packets_by_expression    filter_expression=${QoSFail}    pcap_parser=test6
    ${QoSFail_value}=    cap.get_field_value_by_xpath    xpath=.//ngap.radioNetwork   pcap_parser=test6
    should be equal   ${QoSFail_value[0]}    22
    ${qos_id_rep}=    cap.get_field_value_by_xpath    xpath=.//ngap.qosFlowIdentifier  pcap_parser=test6
   	should contain    ${qos_id_rep}    ${qosFlowIdentifier_voice[0]}

Tests Recover for case
    Modify NIDD parameter on gnb    parameters_to_update=${PARAMETERS_TO_RECOVER_8700_A_22}    gnb_index=${0}
    Modify NIDD parameter on gnb    parameters_to_update=${PARAMETERS_TO_RECOVER_8700_A_22_1}    gnb_index=${1}
    Check hanging resource for gnb    gnb_ips=${gnb_ips}
    Run keyword and ignore error    CI_interface.Common Case Teardown

Detach the test UE
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${0}

Check wireshark log for VONR hold on successful
    [Arguments]    ${logname}   ${value}=30
    ${nomal_call_pdu_id}    Get filtered value    logname=${logname}    command_template=${command_template_Y}
    ...    message_filter=ngap.fiveQI == 1 and ngap.priorityLevelARP == 3
    ...    xpath_filter=ngap.pDUSessionID
    Check timer differ    logname=${logname}
    ...    message_filter=ngap.fiveQI == 1 and frame.time and ngap.priorityLevelARP == 1
    ...    message_filter1=ngap.nas == 0 and ngap.pDUSessionID == ${nomal_call_pdu_id[0]}
    ...    value=${value}
    ...    value=${value}

Hold on VONR and make an emergency
    [Arguments]    ${ue_index}=${0}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    hold on an VONR
    sleep    5s
    Start a emergency call
    sleep    40s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}


Check counter for A22
    [Arguments]
    sleep    60s
    RUN KEYWORD IF    '${check_result}' == 'True'    Check the PM counter shuould be value
    ...    gnb_index=${0}    counter_id=${counter_id_A22_gNB1}    dic_path=${counter_dic_path_A22_gNB1_Trunk}
    ...    value=${expected_value_A22_gnb1}
    ...    ELSE    Check the PM counter shuould be value
    ...    gnb_index=${0}    counter_id=${counter_id_A22_gNB1}    dic_path=${counter_dic_path_A22_gNB1}
    ...    value=${expected_value_A22_gnb1}


Check gnb counter as expected_value
    [Arguments]    ${counter_id}    ${dic_path}    ${expected_value}    ${gnb_id}=${1}    ${counter_end}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].cu.oam_ssh_connection_details.addr}
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${dic_path}
    ${counter_latest}    get slice from list    ${counter_value}    0    ${counter_end}
    should contain    '${counter_latest}'   ${expected_value}
    [Teardown]    COAM Teardown gnb connections

Prepare with PM counter time to caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    300-${utc0}%300
    sleep    ${left_timer}

Load SCF 8700_A
    Run keyword If    ${gnb_instance}=='37611'    Prepare with COAM classical two BTS cell onair
    ...    ELSE    Modify and Load SCF

Modify and Load SCF
    ${release}=    Get sagnb release title
    @{scf_list}    Create List
    ${scf_gnb1}    Only Modify SCF before Perform Commission    gnb_index=${0}    scf_path=${SCF_path}
    ...    golden_scf_name=${tl_scf_filename1}_${release}.xml    ListToAdd=${LIST_TO_MODIFY_GNB1_8700_A22}
    ...    ParamterToModify=${ParamterToModify_GNB1_8700_A22}
    ...    ParameterToDelete=${ParameterToDelete_GNB1_8700_A22}
    Append to List    ${scf_list}    ${scf_gnb1}    ${SCF_path}${tl_scf_filename2}_${release}.xml
    Log to console    Start to modify scf files and commission, please wait...
    Multi-gNB commission    index_list=${gnb_list_8700_A22}    scf_list=${scf_list}