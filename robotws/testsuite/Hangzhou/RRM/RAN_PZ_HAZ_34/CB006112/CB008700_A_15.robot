*** Settings ***
Documentation
...    author: Xingjing
...    contact: jing.1.xing@nokia-sbell.com
...    squal group: SG_03
...    feature: CB008700

Force Tags    CA_5G_RRM
...    PY36

Suite Setup    Run Keywords
...            robot_common_operations.Common Suite Setup
...            AND    Common Suite Setup for COAM
...            AND    Get gnb release info
...            AND    Get sagnb version for selenium
...            AND    Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    ${sw_version}_gNB1_Golden_SCF.xml
#...            AND    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${tl_scf_${release_info}}
...            AND    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${tl_gnb1_scf_${sw_version}}
...            AND    Prepare the default PA

Suite Teardown    Run Keyword    Common Suite Teardown for COAM    gnb_list=${gnb_list}
#...            Run Keyword And Ignore Error     Recover the test env


Resource    Resources/CB006112_common_keywords.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Variables    Resources/variables.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot


*** Variables ***
${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}     ${tl.gnbs[0].cu.oam_http_connection_details.password}
${asik_addr}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${asik_username}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${asik_password}     ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${enb_address}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${enb_username}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${enb_password}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
${WEBUI2_COAM}    https://${tl.gnbs[1].cu.oam_http_connection_details.addr}
${WEBUI2_NAME}    ${tl.gnbs[1].cu.oam_http_connection_details.username}
${WEBUI2_PWD}     ${tl.gnbs[1].cu.oam_http_connection_details.password}
${asik2_addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
${asik2_username}    ${tl.gnbs[1].cu.oam_ssh_connection_details.username}
${asik2_password}     ${tl.gnbs[1].cu.oam_ssh_connection_details.password}

${nglogname_A15}    8700_A15.pcap
${nglogname_A15_0}    8700_A15_attach.pcap
${nglogname_A15_2}    8700_A15_2.UERelease.pcap


${enb_instance}     ${tl.enbs[0].instance_id}
@{different_redirFreqEutra_value}    4200    4300
@{diffTL_enb_ID}    36721    38221    911    5395
${enbvoiceTDD_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNBTS_TDD-0
${enbvoiceFDD_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNBTS_FDD-0
${enbvoice_para}    actConvVoice
@{enbvoice_value}    true    false
${phone_number_TL343_1}    ${tl.ues[0].sec_key}    #####18001006306
${phone_number_TL343_2}    ${tl.ues[1].sec_key}    #####18001006378
${phone_number_TL382_1}    ${tl.ues[0].sec_key}    #####18001006306
${phone_number_TL382_2}    ${tl.ues[1].sec_key}    #####18001006378
${phone_number_TL367_1}    ${tl.ues[0].sec_key}    #####18001006408
${phone_number_TL367_2}    ${tl.ues[1].sec_key}    #####18001006377

@{maxNumOfGBRBearersSA}    0    1    10    200

${5GRU0_ANT9}     ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}    #int  gnb2 PA
${5GRU0_ANT10}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}    #int  gnb2 PA
${5GRU0_ANT11}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}    #int  gnb1 cell2 PA
${5GRU0_ANT12}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}    #int  gnb1 cell2 PA
${5GRU0_ANT7}     ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}    #int  gnb1 cell1 PA TL382
${5GRU0_ANT8}     ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}    #int  gnb1 cell1 PA TL382
${5GRU0_ANT5}     ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}    #int  gnb2 Cell1 PA  TL343
${5GRU0_ANT6}     ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}     #int  gnb2 Cell1 PA  TL343
${5GRU0_ANT15}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}    #int  gnb1 cell1 PA  TL367
${5GRU0_ANT16}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}    #int  gnb1 cell1 PA  TL367
##PA
@{PA_value}    ${0}    ${0}  #int list
${att_ipaddr}               ${tl.attenuator[2].ip_addr}    #TL382 GNB1 cell 1 PA P7P8
${att_api_port}             ${tl.attenuator[2].port}     #TL382 GNB1 cell 1 PA P7P8
${att_ipaddr2}               ${tl.attenuator[1].ip_addr}
${att_api_port2}             ${tl.attenuator[1].port}
${att_ipaddr3}               ${tl.attenuator[0].ip_addr}
${att_api_port3}             ${tl.attenuator[0].port}
@{att_connection_port}    ${5GRU0_ANT9}    ${5GRU0_ANT10}    ${5GRU0_ANT11}    ${5GRU0_ANT12}    #${5GRU0_ANT3}    ${5GRU0_ANT4}
@{att_connection_port343}    ${5GRU0_ANT5}    ${5GRU0_ANT6}
@{att_connection_port382}    ${5GRU0_ANT7}    ${5GRU0_ANT8}
@{att_connection_port367}    ${5GRU0_ANT15}    ${5GRU0_ANT16}
${HBTE_max_value}           ${120}
${vendor}                    ${tl.attenuator[0].vendor}

${epc_log_path}    /opt/workspace/CIT/Master/Case_Logs/
${SCF_path}    /opt/workspace/CRT/Master/SCF_file/golden SCF/
${SCF_file_name}    Configuration_scf_GNB1_CB008698.xml
${enb_path}    /tmp
${ngap_filter}    ngap
${s1ap_filter}    s1ap
${index0}    0
${index1}    1
${index2}    2

@{expected_value}    0    1    2    380    300    3000    8
@{full_path}    CELLS/NRCELL-1/NRRCC/NR_RRC_RELEASE_REDIR_VFB_LTE

${ue_type}    huawei
${template_file}    sip

## filter command for coverting PDML
${command_template_with_Y}    {tshark_path} -r {pcap_file} -Y  \"ngap or e1ap or f1ap or xnap or s1ap\"  -T pdml
${gnb_filter1}    ngap.procedureCode == 26 && ngap.nas == 0

${att_ipaddr_36721}    ${tl.attenuator[0].ip_addr}
${att_ipaddr_911}      ${tl.attenuator[0].ip_addr}
${att_ipaddr_38221}    ${tl.attenuator[0].ip_addr}
${att_port_1_36721}     ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_36721}     ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3_36721}     ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4_36721}     ${tl.attenuator[0].attenuator_ports[4]}
${att_port_5_36721}     ${tl.attenuator[0].attenuator_ports[5]}
${att_port_6_36721}     ${tl.attenuator[0].attenuator_ports[6]}
${att_port_7_36721}     ${tl.attenuator[0].attenuator_ports[7]}
${att_port_8_36721}     ${tl.attenuator[0].attenuator_ports[8]}
${att_port_1_911}       ${tl.attenuator[0].attenuator_ports[9]}
${att_port_2_911}       ${tl.attenuator[0].attenuator_ports[10]}
${att_port_3_911}       ${tl.attenuator[0].attenuator_ports[11]}
${att_port_4_911}       ${tl.attenuator[0].attenuator_ports[12]}
${att_port_5_911}       ${tl.attenuator[0].attenuator_ports[13]}
${att_port_6_911}       ${tl.attenuator[0].attenuator_ports[14]}
${att_port_7_911}       ${tl.attenuator[0].attenuator_ports[15]}
${att_port_8_911}       ${tl.attenuator[0].attenuator_ports[16]}
${att_port_1_38221}     ${tl.attenuator[0].attenuator_ports[9]}
${att_port_2_38221}     ${tl.attenuator[0].attenuator_ports[10]}
${att_port_3_38221}     ${tl.attenuator[0].attenuator_ports[11]}
${att_port_4_38221}     ${tl.attenuator[0].attenuator_ports[12]}
${att_port_5_38221}     ${tl.attenuator[0].attenuator_ports[13]}
${att_port_6_38221}     ${tl.attenuator[0].attenuator_ports[14]}
${att_port_7_38221}     ${tl.attenuator[0].attenuator_ports[15]}
${att_port_8_38221}     ${tl.attenuator[0].attenuator_ports[16]}
#@{diffTL_enb_ID}    36721    38221    911
#${att_connection_port}       ${tl.attenuator.attenuation_port_numbers}


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
[1]CB008700-A_015_PDU_Session_Resource_Modify_when_ARPbasedAC_enabled_with_ViNR_FALLBACK_VoNR_due_to_5QI-2_no_resource
    [Documentation]
    ...    This user scenarios describe the gNB behavior to remove the 5QI-2 QoS flow of a Video over NR call with FDD.
    ...    This Video over NR call will be downgraded to a Voice over NR Call.
    [Tags]     CB008700-C    CIT_TRUNK     CRT_22R3    CIT_22R4
    [Timeout]    1 hour
    [Setup]    robot_common_operations.Common Case Setup
    Check UE exist
#    put btslog_ini file to ute
#    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
    Start capture syslog via btslog on ute
    Online modify parmeters    parameters_to_update=${PARAM_8700_A_015}
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname_A15_0}    interface=any
    UEs attach
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname_A15_0}
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname_A15}    interface=any
    Make a VoNR and ViNR call together for all release
    sleep    60s
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname_A15}
    Check the log for 5QI2 failed with no resource   logname=${nglogname_A15}
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname_A15_2}    interface=any
    Sleep   20s
    hang up VoNR call
    sleep   20s
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname_A15_2}
    Check wireshark log for VONR Release(U1 and UE2)    logname=${nglogname_A15_2}
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown
    ...    AND    sleep    20s
    ...    AND    hang up VoNR call
    ...    AND    UEs detach
    ...    AND    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname_A15_0}
    ...    AND    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname_A15}
    ...    AND    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname_A15_2}
    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    ...    AND    Online modify parmeters    parameters_to_update=${PARAM_8700_recover_A_015}
    ...    AND    Run Keyword And Ignore Error    Recory the default PA
    ...    AND    Stop capture syslog via btslog on ute
    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
    ...    AND    get and analysis syslog


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
    ...    Check_RF_Log=True

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

Check wireshark log for VONR Release(U1 and UE2)
    [Arguments]    ${logname}
    Comment    include two VONR normal release
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    ngap.nas == 0 and ngap.procedureCode == 26
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_nas}=     cap.Get Field Value By Xpath    xpath=.//ngap.nas    pcap_parser=test6
    should contain x times    ${ngap_nas}    0    2
    Comment    include two VONR success response
    ${filter_expression}=     Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_NGAP_PDU}=     cap.Get Field Value By Xpath    xpath=.//ngap.NGAP_PDU    pcap_parser=test6
    should contain x times    ${ngap_NGAP_PDU}    1    2


COAM Save snapshot
    get gnb snapshot    gnb_index=${0}
    get gnb snapshot    gnb_index=${1}

get gnb snapshot
    [Arguments]     ${gnb_index}=${0}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}
#    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    [Teardown]    COAM Teardown gnb connections

Prepare the test env
    locked LTE cell
    Lock The Second gNB
    Lock The second cell of First gNB

Prepare the default PA
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}

Recory the default PA
    run keyword if   '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation
    ...        gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    gnb2_cell1_value=${0}    enb_cell1_value=${0}
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation
    ...        gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    gnb2_cell1_value=${0}    enb_cell1_value=${0}
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation
    ...        gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    gnb2_cell1_value=${0}    enb_cell1_value=${0}

Adjust HBTE gNB_eNB_RU Attenuation
    [Arguments]    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}    ${enb_cell1_value}=${127}
    Run Keyword If     '${enb_instance}'=='${diffTL_enb_ID}[0]'
    ...    Adjust the tl HBTE attenuation value    tl=${diffTL_enb_ID}[0]
    ...    gnb1_cell1_value=${gnb1_cell1_value}    gnb1_cell2_value=${gnb1_cell2_value}
    ...    gnb2_cell1_value=${gnb2_cell1_value}    enb_cell1_value=${enb_cell1_value}
    ...    ELSE    sleep    1s
	Run Keyword If     '${enb_instance}'=='${diffTL_enb_ID}[2]'
    ...    Adjust the tl HBTE attenuation value    tl=${diffTL_enb_ID}[2]
    ...    gnb1_cell1_value=${gnb1_cell1_value}    gnb1_cell2_value=${gnb1_cell2_value}
    ...    gnb2_cell1_value=${gnb2_cell1_value}    enb_cell1_value=${enb_cell1_value}
    ...    ELSE    sleep    1s
    Run Keyword If     '${enb_instance}'=='${diffTL_enb_ID}[1]'
    ...    Adjust the tl HBTE attenuation value    tl=${diffTL_enb_ID}[2]
    ...    gnb1_cell1_value=${gnb1_cell1_value}    gnb1_cell2_value=${gnb1_cell2_value}
    ...    gnb2_cell1_value=${gnb2_cell1_value}    enb_cell1_value=${enb_cell1_value}
    ...    ELSE    sleep    1s


Adjust the tl HBTE attenuation value
    [Arguments]     ${tl}=${tl}    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}
    ...    ${enb_cell1_value}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell1}    Create List    ${att_port_1_${tl}}     ${att_port_2_${tl}}
    @{att_ports_gnb1_cell2}    Create List    ${att_port_3_${tl}}     ${att_port_4_${tl}}
    @{att_ports_gnb2_cell1}    Create List    ${att_port_5_${tl}}     ${att_port_6_${tl}}
    @{att_ports_enb_cell1}     Create List    ${att_port_7_${tl}}     ${att_port_8_${tl}}

    ###create value list####
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}
    @{values_enb_cell1}     Create List    ${enb_cell1_value}     ${enb_cell1_value}     ${enb_cell1_value}     ${enb_cell1_value}

    ###Adjust the HBTE attenuation value###
	set suite variable    ${att_api_port}    ${att_api_port3}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${att_port_1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${att_port_1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}
    Set the attenuation value    att_ports=${att_ports_enb_cell1}     values=${values_enb_cell1}
    ...    att_connection_port=${att_port_1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}



Recover the test env
    Unlock The second cell of First gNB
    Unlocked LTE cell
    Unlock The Second gNB

Make a VoNR and ViNR call together for all release
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Make a VoNR and ViNR call together from UE2
    ...    phone_number=${phone_number_TL343_1}
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Make a VoNR and ViNR call together from UE2
    ...    phone_number=${phone_number_TL382_1}
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Make a VoNR and ViNR call together from UE2
    ...    phone_number=${phone_number_TL367_1}

Make a VoNR and ViNR call together from UE2
    [Arguments]    ${phone_number}=18001006306    ${ue_index}=${1}
    power_ue.Prepare UE    ue_type=${ue_type}
    Get VoNR and ViNR pointer variable
    Make a VoNR and ViNR call    ue_index=${ue_index}    phone_number=${phone_number}
    answer ViNR call    ue_index=${0}

Check the log for 5QI2 failed with no resource
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6
    ${PDUSessionResourceModifyRequest} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log To Console    check fiveQI value on PDUSessionResourceModifyRequest message
    ${PDUSessionResourceModifyRequest_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${PDUSessionResourceModifyRequest}    pcap_parser=test6
    should be equal    ${PDUSessionResourceModifyRequest_status}    ${True}
    ${filtered_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${PDUSessionResourceModifyRequest}    pcap_parser=test6
    ${ngap_fiveQI}=    cap.get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
    ${Qos_Id}=    cap.get_field_value_by_xpath    xpath=.//ngap.qosFlowIdentifier    pcap_parser=test6
    Should Contain    ${ngap_fiveQI}    1
    Should Contain    ${ngap_fiveQI}    2
    @{Qos_Id_list}    create list
    ${5QI_num}    get length    ${ngap_fiveQI}
    FOR    ${req_qos_index}    IN RANGE    	${5QI_num}
      run keyword if    ${ngap_fiveQI[${req_qos_index}]}== ${2}
    ...    append to list    ${Qos_Id_list}    ${Qos_Id[${req_qos_index}]}
    END
    ${5QI2_qos_id}    get length   ${Qos_Id_list}
    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check PDUSessionResourceModifyResponse
    ${PDUSessionResourceModifyResponse_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${PDUSessionResourceModifyResponse}    pcap_parser=test6
    should be equal    ${PDUSessionResourceModifyResponse_status}    ${True}
    ${filtered_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${PDUSessionResourceModifyResponse}    pcap_parser=test6
    ${ngap_qosFlowAddOrModifyResponseList} =    cap.get_field_value_by_xpath    xpath=.//ngap.qosFlowAddOrModifyResponseList    pcap_parser=test6
    Should be equal    ${ngap_qosFlowAddOrModifyResponseList[1]}    1
    ${res_Qos_Id}=    cap.get_field_value_by_xpath    xpath=.//ngap.qosFlowIdentifier    pcap_parser=test6
    ${ngap_radioNetwork}=    cap.get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    should not contain    ${ngap_radioNetwork}    21
#	Should Contain X Times    ${ngap_radioNetwork}    22   3
    ${qos_num}=    get length    ${res_Qos_Id}
    FOR    ${qos_index}    IN RANGE    	${qos_num}
      run keyword if   ${res_Qos_Id[${qos_index}]}==${Qos_Id_list[1]}
    ...    should be true    ${ngap_radioNetwork[${0}]}    22
    END

    ${filter_expression}=     Catenate    (ngap.procedureCode == 26 and ngap.id == 65 and ngap.radioNetwork == 22)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_radioNetwork2}=     cap.Get Field Value By Xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
	Should Contain     ${ngap_radioNetwork2}    22
	${filter_expression}=     Catenate    ngap.procedureCode == 26 and ngap.id == 64 and ngap.nas == 0
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_nas}=     cap.Get Field Value By Xpath    xpath=.//ngap.nas    pcap_parser=test6
	Should Contain     ${ngap_nas}    0


#Check the log for 5QI2 failed with no resource
#    [Arguments]    ${logname}
#    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
#    ...    command_template=${command_template_with_Y}    alias=test6
#    ${PDUSessionResourceModifyRequest} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
#    Log To Console    check fiveQI value on PDUSessionResourceModifyRequest message
#    ${PDUSessionResourceModifyRequest_status} =    run_keyword_and_return_status
#    ...    cap.filter_packets_by_expression    filter_expression=${PDUSessionResourceModifyRequest}    pcap_parser=test6
#    should be equal    ${PDUSessionResourceModifyRequest_status}    ${True}
#    ${filtered_packets}=    cap.filter_packets_by_expression
#    ...    filter_expression=${PDUSessionResourceModifyRequest}    pcap_parser=test6
#    ${ngap_fiveQI}=    cap.get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
#    ${Qos_Id}=    cap.get_field_value_by_xpath    xpath=.//ngap.qosFlowIdentifier    pcap_parser=test6
#    Should Contain    ${ngap_fiveQI}    1
#    Should Contain    ${ngap_fiveQI}    2
#    @{Qos_Id_list}    create list
#    ${5QI_num}    get length    ${ngap_fiveQI}
#    FOR    ${req_qos_index}    IN RANGE    	${5QI_num}
#      run keyword if    ${ngap_fiveQI[${req_qos_index}]}== ${2}
#    ...    append to list    ${Qos_Id_list}    ${Qos_Id[${req_qos_index}]}
#    END
#    ${5QI2_qos_id}    get length   ${Qos_Id_list}
#    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
#    Log To Console    check PDUSessionResourceModifyResponse
#    ${PDUSessionResourceModifyResponse_status} =    run_keyword_and_return_status
#    ...    cap.filter_packets_by_expression    filter_expression=${PDUSessionResourceModifyResponse}    pcap_parser=test6
#    should be equal    ${PDUSessionResourceModifyResponse_status}    ${True}
#    ${filtered_packets}=    cap.filter_packets_by_expression
#    ...    filter_expression=${PDUSessionResourceModifyResponse}    pcap_parser=test6
#    ${ngap_qosFlowAddOrModifyResponseList} =    cap.get_field_value_by_xpath    xpath=.//ngap.qosFlowAddOrModifyResponseList    pcap_parser=test6
#    Should be equal    ${ngap_qosFlowAddOrModifyResponseList[1]}    1
#    ${res_Qos_Id}=    cap.get_field_value_by_xpath    xpath=.//ngap.qosFlowIdentifier    pcap_parser=test6
#    ${ngap_radioNetwork}=    cap.get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
#    should not contain    ${ngap_radioNetwork}    21
##	Should Contain X Times    ${ngap_radioNetwork}    22   3
#    ${qos_num}=    get length    ${res_Qos_Id}
#    FOR    ${qos_index}    IN RANGE    	${qos_num}
#      run keyword if   ${res_Qos_Id[${qos_index}]}==${Qos_Id_list[1]}
#    ...    should be true    ${ngap_radioNetwork[${0}]}    22
#    END

Online modify parmeters
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}    ${timeout}=${300}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update}    timeout=${timeout}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Lock The second cell of First gNB
    Connect to gnb coam via ssl    bts_host=${LOCAL_MASTER_IP}    connection=gnb1
    coam.lock    dist_name=${distname_id_1}/NRCELL-2    connection=gnb1    timeout=180s
    coam.teardown    connection=gnb1

Unlock The second cell of First gNB
    Connect to gnb coam via ssl    bts_host=${LOCAL_MASTER_IP}    connection=gnb1
    coam.unlock    dist_name=${distname_id_1}/NRCELL-2    connection=gnb1    timeout=180s
    coam.teardown    connection=gnb1

Lock The first cell of First gNB
    Connect to gnb coam via ssl    bts_host=${LOCAL_MASTER_IP}    connection=gnb1
    coam.lock    dist_name=${distname_id_1}/NRCELL-1    connection=gnb1    timeout=180s
    coam.teardown    connection=gnb1

Unlock The first cell of First gNB
    Connect to gnb coam via ssl    bts_host=${LOCAL_MASTER_IP}    connection=gnb1
    coam.unlock    dist_name=${distname_id_1}/NRCELL-1    connection=gnb1    timeout=180s
    coam.teardown    connection=gnb1
