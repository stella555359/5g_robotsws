*** Settings ***
Documentation
...    author: Xing Jing
...    contact: jing.1.xing@nokia-sbell.com
...    squad group: SG_03
...    feature : FGCR_8315


Resource    Resources/FGCR_8315_common_keywords.robot
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/FGCR_8315/Resources/variables.py

Suite Setup    Run Keywords
    ...        robot_common_operations.Common Suite Setup    AND
    ...        Common Suite Setup for COAM    AND
    ...        Commit SCF to eNB    eNB_asik_addr=${eNB_asik_addr}    scf_file=${eNB_SCF}    AND
    ...        Prepare the classical COAM BTS cell onair

Suite Teardown     Run Keywords
...               robot_common_operations.Common Suite Teardown    AND
...               Run Keyword And Ignore Error    Set the env PA as default

*** Variables ***
${tl_scf_filename}    golden_TDD.xml
${eNB_SCF}    eNB_SCF_FGCR_8315.xml
#############case parameter###############
#${biplog}    biplog.pcap
${gNB_log_A4}    gNB_log_A4.pcap
${eNB_log_A4}    eNB_log_A4.pcap
${CellIdentity}    0x0014ae00
${CellIdentity_1}    0x00854900
${CellIdentity_2}    0x0000f201
@{BTSID}    34111    34411    24211
${script_path}       /opt/workspace/bip_scripts
*** Test Cases ***
[1]FGCR_8315_A_4_UE_reselect_to_high_priority_4Gcell_when_it_available
    [Documentation]
    ...    This user scenario describes UE can success receive SIB5 information with IE eutra-multiBandInfoList
    ...    inside from 5G cell.
    [Tags]            CIT_TRUNK    CIT_22R4    CRT_22R1    CRT_22R2    CRT_22R3
    [Timeout]    1 hour
    [Setup]    robot_common_operations.Common Case Setup
    Check UE reselect to high priority 4Gcell
    [Teardown]    run keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Run Keyword And Ignore Error    Case recover

*** Keywords ***
Prepare the test env
    Set the env PA as default
#    Run Keyword If    '${gnb_instance}' == '@{BTSID}[0]'    FGCR_8315_common_keywords.Reset UE Control PC
    huawei UE setup
    huawei UE attach
    huawei UE teardown

Check reselect to target eNB cell
    Modify NIDD parameter for 8315    parameters_to_update=${PARAMETERS_TO_UPDATE_pre}
    Prepare the test env
    Collect Interface Mirroring Bip Collector from WEBUI
    ...    gnb_index=${0}    target_dir=${epc_log_path}    times=1s
    ${biplog}    Get Bip Log Via Interface Mirroring Collector to UTE    target_dir=${epc_log_path}
    Check the BIP log    biplog=${biplog[0]}
    huawei UE setup
    FGCR_8315_common_keywords.Start capture gNB log on master    filename=${gNB_log_A4}
    FGCR_8315_common_keywords.Start to collect the log on eNB    log_name=${eNB_log_A4}
    Change the eNB PA to min
    huawei UE attach
    sleep    60s
    FGCR_8315_common_keywords.Stop and download Logs on gNB on master     filename=${gNB_log_A4}
    FGCR_8315_common_keywords.Stop and download Logs on eNB    log_name=${eNB_log_A4}
    Check the reselect log
    Run Keyword And Ignore Error    huawei UE teardown

Check UE reselect to high priority 4Gcell
    wait until keyword succeeds    3X    5S    Check reselect to target eNB cell

Check the reselect log
    Check the gNB log    log_name=${gNB_log_A4}
    Check the eNB reselect log

Set the env to default value for 21A
    set the eNB PA to max
    set the gNB2 PA as max
    set the gNB1 cell2 PA as max
    set the gNB1 cell1 PA to 0

set the eNB PA to min
    Adjust the HBTE attenuation value    value_1=${5}     value_2=${5}     value_3=${5}
    ...    value_4=${5}    att_port_1=${att_port9_341}
    ...    att_port_2=${att_port10_341}     att_port_3=${att_port11_341}
    ...    att_port_4=${att_port12_341}    atten_ip=${att_ipaddr_1}
    ...    att_api_port=${tl.attenuator[0].port}    vendor=${tl.attenuator[0].vendor}

set the eNB PA to max
    Adjust the HBTE attenuation value    value_1=${120}     value_2=${120}     value_3=${120}
    ...    value_4=${120}    att_port_1=${att_port9_341}
    ...    att_port_2=${att_port10_341}     att_port_3=${att_port11_341}
    ...    att_port_4=${att_port12_341}    atten_ip=${att_ipaddr_1}
    ...    att_api_port=${tl.attenuator[0].port}    vendor=${tl.attenuator[0].vendor}

set the gNB2 PA as max
    Adjust the HBTE attenuation value    value_1=${127}     value_2=${127}     value_3=${127}
    ...    value_4=${127}    att_port_1=${att_port5_341}
    ...    att_port_2=${att_port6_341}     att_port_3=${att_port7_341}
    ...    att_port_4=${att_port8_341}    atten_ip=${att_ipaddr_1}
    ...    att_api_port=${tl.attenuator[0].port}    vendor=${tl.attenuator[0].vendor}

set the gNB1 cell2 PA as max
    Adjust the HBTE attenuation value    value_1=${127}     value_2=${127}     value_3=${127}
    ...    value_4=${127}    att_port_1=${att_port3_341}
    ...    att_port_2=${att_port4_341}     att_port_3=${att_port3_341}
    ...    att_port_4=${att_port4_341}    atten_ip=${att_ipaddr_1}
    ...    att_api_port=${tl.attenuator[0].port}    vendor=${tl.attenuator[0].vendor}

set the gNB1 cell1 PA to 0
    Adjust the HBTE attenuation value    value_1=${0}     value_2=${0}     value_3=${0}
    ...    value_4=${0}    att_port_1=${att_port1_341}
    ...    att_port_2=${att_port2_341}     att_port_3=${att_port1_341}
    ...    att_port_4=${att_port2_341}    atten_ip=${att_ipaddr_1}
    ...    att_api_port=${tl.attenuator[0].port}    vendor=${tl.attenuator[0].vendor}

Check the gNB log
    [Arguments]    ${log_name}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${pdu_session_req}=     Catenate    ngap.procedureCode == 29 and ip.dst == ${asik_addr}
    ${pdu_session_req_packets}=    filter_packets_by_expression
    ...    filter_expression=${pdu_session_req}
    ${pdu_session_req_value}=     get_field_value_by_xpath    pdml_list=${pdu_session_req_packets}
    ...                                                xpath=.//ngap.procedureCode
    should be equal    ${pdu_session_req_value[0]}    29
    ${pdu_session_res}=     Catenate    ngap.procedureCode == 29 and ip.src == ${asik_addr}
    ${pdu_session_res_packets}=    filter_packets_by_expression
    ...    filter_expression=${pdu_session_res}
    ${pdu_session_res_value}=     get_field_value_by_xpath    pdml_list=${pdu_session_res_packets}
    ...                                                xpath=.//ngap.procedureCode
    should be equal    ${pdu_session_res_value[0]}    29
    ${UE_release_res}=     Catenate    ngap.procedureCode == 42 and ngap.radioNetwork == 20
    ${UE_release_res_packets}=    filter_packets_by_expression
    ...    filter_expression=${UE_release_res}
    ${UE_release_res_value}=     get_field_value_by_xpath    pdml_list=${UE_release_res_packets}
    ...                                                xpath=.//ngap.procedureCode
    should be equal    ${UE_release_res_value[0]}    42
    ${UE_release_cmd}=     Catenate    ngap.procedureCode == 41 and ip.dst == ${asik_addr}
    ${UE_release_cmd_packets}=    filter_packets_by_expression
    ...    filter_expression=${UE_release_cmd}
    ${UE_release_cmd_value}=     get_field_value_by_xpath    pdml_list=${UE_release_cmd_packets}
    ...                                                xpath=.//ngap.procedureCode
    should be equal    ${UE_release_cmd_value[0]}    41
    ${UE_release_complete}=     Catenate    ngap.procedureCode == 41 and ip.src == ${asik_addr}
    ${UE_release_complete_packets}=    filter_packets_by_expression
    ...    filter_expression=${UE_release_complete}
    ${UE_release_complete_value}=     get_field_value_by_xpath    pdml_list=${UE_release_complete_packets}
    ...                                                xpath=.//ngap.procedureCode
    should be equal    ${UE_release_complete_value[0]}    41

Check the eNB log
    [Arguments]    ${log_name}    ${CellIdentity}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${TAU_rsq}=     Catenate    s1ap.procedureCode == 12 and s1ap.CellIdentity == ${CellIdentity}
    ${TAU_rsq_packets}=    filter_packets_by_expression
    ...    filter_expression=${TAU_rsq}
    ${TAU_rsq_value}=     get_field_value_by_xpath    pdml_list=${TAU_rsq_packets}
    ...                                                xpath=.//s1ap.CellIdentity
    should be equal    ${TAU_rsq_value[0]}    ${CellIdentity}
    ${TAU_accept}=     Catenate    s1ap.procedureCode == 9 and ip.dst == ${eNB_asik_addr}
    ${TAU_accept_packets}=    filter_packets_by_expression
    ...    filter_expression=${TAU_accept}
    ${TAU_accept_value}=     get_field_value_by_xpath    pdml_list=${TAU_accept_packets}
    ...                                                xpath=.//s1ap.procedureCode
    should be equal    ${TAU_accept_value[0]}    9
    ${TAU_complete}=     Catenate    s1ap.procedureCode == 13 and s1ap.CellIdentity == ${CellIdentity}
    ${TAU_complete_packets}=    filter_packets_by_expression
    ...    filter_expression=${TAU_complete}
    ${TAU_complete_value}=     get_field_value_by_xpath    pdml_list=${TAU_complete_packets}
    ...                                                xpath=.// s1ap.CellIdentity
    should be equal    ${TAU_complete_value[-1]}    ${CellIdentity}

Check the eNB reselect log
    ${release_info}    Get gnb release
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'    Check the eNB log    log_name=${eNB_log_A4}
    ...    CellIdentity=${CellIdentity}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'    Check the eNB log    log_name=${eNB_log_A4}
    ...    CellIdentity=${CellIdentity_1}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'    Check the eNB log    log_name=${eNB_log_A4}
    ...    CellIdentity=${CellIdentity_2}

Capture BIP log
    ${release_info}    Get gnb release
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'    Collect Interface Mirroring Bip Collector from WEBUI
    ...    gnb_index=${0}    target_dir=${epc_log_path}    times=1s
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'    Collect Interface Mirroring Bip Collector from WEBUI
    ...    gnb_index=${0}    target_dir=${epc_log_path}    times=1s
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'    bip capture on ABIO and download to UTE
    ...    script_path=${script_path}

Check the BIP log
    [Arguments]    ${biplog}
    ${release_info}    Get gnb release
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'    Check the SIB5 contain eutra multiBandInfoList
    ...    biplog=${biplog}    band_1=${3}    band_2=${5}    cellid_1=${40}    cellid_2=${38}
    ...    Priority_1=${7}    Priority_2=${3}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'    Check the SIB5 contain eutra multiBandInfoList
    ...    biplog=${biplog}    band_1=${4}    band_2=${3}    cellid_1=${0}    cellid_2=${1}
    ...    Priority_1=${3}    Priority_2=${7}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'    Check the SIB5 contain eutra multiBandInfoList
    ...    biplog=${biplog}    band_1=${4}    band_2=${3}    cellid_1=${70}    cellid_2=${69}
    ...    Priority_1=${3}    Priority_2=${7}

Set the env PA as default
    ${release_info}    Get gnb release
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'    Set the env to default value for 21A
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'    Set the env to default value for master
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'    Set the env to default value for 21B

Change the eNB PA to min
    ${release_info}    Get gnb release
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'    set the eNB PA to min
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'    Set the eNB PA as min for master
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'    Adjust LTE_Cells HBTE Attenuation to min


Set the env to default value for master
    Set the eNB PA as max for master
    Set the gNB2 PA to max for master
    Set the gNB1 PA to 0 for master

Set the eNB PA as max for master
#    Adjust the Attenuation Value    atten_ip=${att_ipaddr_2}   value_1=${120}    value_2=${120}
#    ...    port_1=${4GRU_ANT11}    port_2=${4GRU_ANT11}
    Adjust the HBTE attenuation value    value_1=${120}     value_2=${120}     value_3=${120}
    ...    value_4=${120}    att_port_1=${HBTE_eNB_att_port14}
    ...                 att_port_2=${HBTE_eNB_att_port15}     att_port_3=${HBTE_eNB_att_port14}
    ...             att_port_4=${HBTE_eNB_att_port16}    atten_ip=${att_ipaddr_1}

Set the eNB PA as min for master
    Adjust the HBTE attenuation value    value_1=${0}     value_2=${0}     value_3=${0}
    ...    value_4=${0}    att_port_1=${HBTE_eNB_att_port14}
    ...                 att_port_2=${HBTE_eNB_att_port15}     att_port_3=${HBTE_eNB_att_port14}
    ...             att_port_4=${HBTE_eNB_att_port16}    atten_ip=${att_ipaddr_1}
#    Adjust the Attenuation Value    atten_ip=${att_ipaddr_2}   value_1=${0}    value_2=${0}
#    ...    port_1=${4GRU_ANT11}    port_2=${4GRU_ANT11}

Set the gNB2 PA to max for master
    Adjust the HBTE attenuation value    value_1=${127}     value_2=${127}     value_3=${127}
    ...    value_4=${127}    att_port_1=${HBTE_att_port_9}
    ...                 att_port_2=${HBTE_att_port_10}     att_port_3=${HBTE_att_port_11}
    ...             att_port_4=${HBTE_att_port_12}    atten_ip=${att_ipaddr_1}
    Adjust the HBTE attenuation value    value_1=${127}     value_2=${127}     value_3=${127}
    ...    value_4=${127}    att_port_1=${HBTE_att_port_13}
    ...                 att_port_2=${HBTE_att_port_14}     att_port_3=${HBTE_att_port_15}
    ...             att_port_4=${HBTE_att_port_16}    atten_ip=${att_ipaddr_1}

Set the gNB1 PA to 0 for master
    Adjust the HBTE attenuation value    value_1=${0}     value_2=${0}     value_3=${120}
    ...    value_4=${120}    att_port_1=${HBTE_gNB1_att_port1}
    ...                 att_port_2=${HBTE_gNB1_att_port2}     att_port_3=${HBTE_gNB1_att_port9}
    ...             att_port_4=${HBTE_gNB1_att_port10}    atten_ip=${att_ipaddr_1}

Set the env to default value for 21B
    Adjust gNB2_FDD_Cells HBTE Attenuation to max
    Adjust LTE_Cells HBTE Attenuation to max
    Adjust gNB1_TDD_Cell1 HBTE Attenuation to value

Adjust gNB2_FDD_Cells HBTE Attenuation to max
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${21B_att_port_5}      att_port_2=${21B_att_port_6}
    ...     att_port_3=${21B_att_port_7}     att_port_4=${21B_att_port_8}    atten_ip=${atten_ip}
    ...        value_1=${120}    value_2=${120}   value_3=${120}    value_4=${120}

Adjust LTE_Cells HBTE Attenuation to min
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${21B_att_port_13}      att_port_2=${21B_att_port_14}
    ...     att_port_3=${21B_att_port_13}     att_port_4=${21B_att_port_14}    atten_ip=${atten_ip}
    ...        value_1=${0}    value_2=${0}   value_3=${0}    value_4=${0}

Adjust LTE_Cells HBTE Attenuation to max
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${21B_att_port_13}      att_port_2=${21B_att_port_14}
    ...     att_port_3=${21B_att_port_13}     att_port_4=${21B_att_port_14}    atten_ip=${atten_ip}
    ...        value_1=${120}    value_2=${120}   value_3=${120}    value_4=${120}

Adjust gNB1_TDD_Cell1 HBTE Attenuation to value
    [Arguments]    ${value}=${0}
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${21B_att2_port_5}      att_port_2=${21B_att2_port_6}
    ...     att_port_3=${21B_att2_port_5}     att_port_4=${21B_att2_port_6}    atten_ip=${atten_ip}
    ...        value_1=${value}    value_2=${120}   value_3=${value}    value_4=${120}
