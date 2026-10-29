*** Settings ***
Documentation
...    author: Shi Ming
...    contact: ming.shi@nokia-sbell.com
...    squal group: SG_03
...    feature: CB008700

Force Tags    CA_5G_RRM
...    PY36

Suite Setup    Run Keywords
...            robot_common_operations.Common Suite Setup
...            AND    Common Suite Setup for COAM
...            AND    Common UE parameter setup
...            AND    Get gnb release info
...            AND    Get sagnb version for selenium
...            AND    Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    ${sw_version}_gNB1_Golden_SCF.xml
...            AND    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${tl_gnb1_scf_${sw_version}}

Suite Teardown    Run Keyword    Common Suite Teardown for COAM    gnb_list=${gnb_list}


Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008700/Resources/CB008700_common_keywords_ming_new_tl.robot
Variables    Resources/CB008700_variables.py
Variables    Resources/CB008700_multi_gnb_variables.py
Library      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/get_counters_from_pm_file.py
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot


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
${nglogname_A15_0}    8700_A15_attach_0.pcap
${nglogname_A15_1}    8700_A15_attach_1.pcap
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
${SCF_path}    /opt/workspace/CRT/Master/SCF_file/
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


@{cell_id}    0    1    2    3    4    5
@{cell_id_348}    0    1    2    3    4    5    6
@{multi_gnb_PA}    ${5}    ${25}    ${40}    ${0}    ${35}    ${127}    ${26}    ${30}    ${25}    ${10}    ${20}    ${40}    ${45}    ${30}
...    ${50}
${ue0_type}        ${tl.ues[0].capabilities[0]}
${ue_type_qcom}    ${tl.ues[1].capabilities[0]}

${att_ipaddr_1}    ${tl.attenuator[1].ip_addr}

*** Test Cases ***
[1]CB008700-A_015_PDU_Session_Resource_Modify_when_ARPbasedAC_enabled_with_ViNR_FALLBACK_VoNR_due_to_5QI-2_no_resource
    [Documentation]
    ...    This user scenarios describe the gNB behavior to remove the 5QI-2 QoS flow of a Video over NR call with FDD.
    ...    This Video over NR call will be downgraded to a Voice over NR Call.
    [Tags]     CB008700-C    CIT_TRUNK     CRT_22R3    CIT_22R4
    [Timeout]    2 hour
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=4291
    AlarmWatchdog.add_allow_alarms    fault_id=4291
    Check UE device status with adb recover    ue_index=${0}
    Check UE device status with adb recover    ue_index=${1}
#    put btslog_ini file to ute
#    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
#    Start capture syslog via btslog on ute
    paras change on BTS
        ...    paras=${CB008700_ciphering_algorithms}
        ...    delta_file_name=${epc_log_path}${CB008700_ciphering_algorithms_json_file}
    IF    ${enb_instance} == ${enb_id}[3]    #TL348
        Online modify parmeters    parameters_to_update=${PARAM_8700_A_015_348}    skip_parameter_relation_errors=${False}
        ###set gnb1 cell1 PA to 5
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[3]
    ELSE IF    ${enb_instance} == ${enb_id}[4]    #TL383
        Online modify parmeters    parameters_to_update=${PARAM_8700_A_015_348}    skip_parameter_relation_errors=${False}
        ###set gnb1 cell1 PA to 5
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[3]
    END
    Power_ue.Prepare UE    ue_type=${ue0_type}    ue_index=${0}
    Wait Until Keyword Succeeds    3x    10s    Run Keywords
    ...    set apn dxdata2
    ...    AND    make WA with Samsung S21
    power_ue.Prepare UE    ue_type=${ue_type_qcom}    ue_index=${1}
    Start capture gNB log on master    filename=${nglogname_A15_0}
    Attach and check power UE    ue_type=${ue0_type}    ue_index=${0}    gnb_index=${0}
    Stop and download Logs on gNB on master    filename=${nglogname_A15_0}
    Start capture gNB log on master    filename=${nglogname_A15_1}
    Step1: UE attach    ue_type=${ue_type_qcom}    ue_index=${1}
    Stop and download Logs on gNB on master    filename=${nglogname_A15_1}
    ${RAN_UE_NGAP_ID_UE0}=    Get RAN_UE_NGAP_ID message    logname=${nglogname_A15_0}
    Set Test Variable    ${RAN_UE_NGAP_ID_UE0}
#    Start capture gNB log on master    filename=${nglogname_A15}
#    Make a VoNR and ViNR call together for all release
#    sleep    60s
#    Stop and download Logs on gNB on master    filename=${nglogname_A15}
    Wait Until Keyword Succeeds    3x    10s    capture logs and make ViNR
    Check the log for 5QI2 failed with no resource   logname=${nglogname_A15}
    Start capture gNB log on master    filename=${nglogname_A15_2}
    Sleep   20s
    hang up VoNR call
    sleep   20s
    Stop and download Logs on gNB on master    filename=${nglogname_A15_2}
    Check wireshark log for VONR Release(U1 and UE2)    logname=${nglogname_A15_2}
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown
    ...    AND    AlarmWatchdog.remove_allow_alarms    fault_id=4291
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${nglogname_A15_0}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${nglogname_A15_1}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${nglogname_A15}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${nglogname_A15_2}
    ...    AND    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot
    ...    AND    recover para and pa value for A15
#    ...    AND    Stop capture syslog via btslog on ute
    ...    AND    hang up VoNR call
    ...    AND    Step4: Detach UE    ue_type=${ue_type_qcom}    ue_index=${1}
    ...    AND    UE.UE Detach     ue_type=${ue_type}     ue_index=${0}
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

get gnb snapshot
    [Arguments]     ${gnb_index}=${0}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    [Teardown]    COAM Teardown gnb connections

capture logs and make ViNR
    Start capture gNB log on master    filename=${nglogname_A15}
    Make a VoNR and ViNR call together for all release
    sleep    60s
    [Teardown]    Stop and download Logs on gNB on master    filename=${nglogname_A15}

Make a VoNR and ViNR call together for all release
    IF    ${enb_instance} == ${enb_id}[3]    #TL348
        Make a VoNR and ViNR call together from UE1    phone_number=${tl.ues[0].sec_key}
        Sleep    5s
        check voice call status    ue_index=${0}    status=${2}
    ELSE IF    ${enb_instance} == ${enb_id}[4]    #TL383
        Make a VoNR and ViNR call together from UE1    phone_number=${tl.ues[0].sec_key}
        Sleep    5s
        check voice call status    ue_index=${0}    status=${2}
    END
    [Teardown]    Run Keyword If    '${KEYWORD STATUS}' == 'FAIL'    hang up VoNR call    ue_index=${1}

Make a VoNR and ViNR call together from UE1
    [Arguments]    ${phone_number}=13100011554
#    Power_ue.Prepare UE    ue_type=${ue0_type}    ue_index=${0}
    Get VoNR and ViNR pointer variable with Samsung S23 and SDX80
#    unlock MT UE    ue_index=${1}
    Make a VoNR and ViNR call    ue_index=${1}    phone_number=${phone_number}
    answer ViNR call    ue_index=${0}

Get VoNR and ViNR pointer variable with Samsung S23 and SDX80
    Set Suite Variable    ${Enter_Make_ViNR_button_T}    472 888
#    Set Suite Variable    ${Make_ViNR_button_T}    875 1219
    Set Suite Variable    ${answer_ViNR_button}    232 1766 232 1208
#    Set Suite Variable    ${switch_to_VoNR}    914 1746
#    Set Suite Variable    ${trigger_button}    735 1805
#    Set Suite Variable    ${hang_up_VoNR_and_ViNR}    588 1982
#    Set Suite Variable    ${Make_ViNR_button_S}    254 1728

unlock MT UE
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error
    ...    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin${ue_index}
    sleep   2s
    [Teardown]    csn.disconnect    connection=cygwin${ue_index}

Make a VoNR and ViNR call
    [Arguments]    ${ue_index}=${0}   ${phone_number}=13100011554    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error
    ...    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####make VoNR and ViNR call together#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.DIAL tel:+86${phone_number}
    ...    connection=cygwin${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${Enter_Make_ViNR_button_T}    connection=cygwin${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${Enter_Make_ViNR_button_T}    connection=cygwin${ue_index}
    sleep    2s
    [Teardown]    csn.disconnect    connection=cygwin${ue_index}

answer ViNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input swipe ${answer_ViNR_button}    connection=cygwin${ue_index}
    sleep    2s
    [Teardown]    csn.disconnect    connection=cygwin${ue_index}

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
#    ${PDUSessionResourceModifyResponse} =    Catenate
#    ...    (ngap.NGAP_PDU == 1 and ngap.procedureCode == 26) && (ngap.RAN_UE_NGAP_ID == ${RAN_UE_NGAP_ID_UE0})
    Log To Console    check PDUSessionResourceModifyResponse
    ${PDUSessionResourceModifyResponse_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression    filter_expression=${PDUSessionResourceModifyResponse}    pcap_parser=test6
    should be equal    ${PDUSessionResourceModifyResponse_status}    ${True}
    ${filtered_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${PDUSessionResourceModifyResponse}    pcap_parser=test6
    ${ngap_qosFlowAddOrModifyResponseList} =    cap.get_field_value_by_xpath    xpath=.//ngap.qosFlowAddOrModifyResponseList    pcap_parser=test6
#    Should be equal    ${ngap_qosFlowAddOrModifyResponseList[1]}    1
#    Should be equal    ${ngap_qosFlowAddOrModifyResponseList[0]}    1
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

set apn dxdata2
    RUN KEYWORD IF    ${enb_instance} != ${enb_id}[2]
    ...    run keywords    Set Suite Variable    ${close_task}    538 1874
    ...    AND    set apn with special method    usedapn=${dxdata2_apn_348}    location_apn=${click_access_point}
    ...    ELSE    set apn to wap2    usedapn=${dxdata2_apn}

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

recover para and pa value for A15
    paras change on BTS
        ...    paras=${CB008700_recover_ciphering_algorithms}
        ...    delta_file_name=${epc_log_path}${CB008700_recover_ciphering_algorithms_json_file}
    IF    ${enb_instance} == ${enb_id}[3]    #TL348
        Online modify parmeters    parameters_to_update=${PARAM_8700_recover_A_015_348}    skip_parameter_relation_errors=${False}
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
    ELSE IF    ${enb_instance} == ${enb_id}[4]    #TL383
        Online modify parmeters    parameters_to_update=${PARAM_8700_recover_A_015_348}    skip_parameter_relation_errors=${False}
        PA one cell 0 on and set other cell value 4 port for T348    cellid=${cell_id_348}[1]    set_value=${multi_gnb_PA}[0]
    END

Get gnb release info
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}

Get RAN_UE_NGAP_ID message
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ${PDUSessionResourceSetupResponse}=     Catenate    (ngap.NGAP_PDU == 1) && (ngap.procedureCode == 29)
    ${PDUSessionResourceSetupResponse_packets}=    cap.filter_packets_by_expression    filter_expression=${PDUSessionResourceSetupResponse}
    ${RAN_UE_NGAP_ID}=     cap.get_field_value_by_xpath    pdml_list=${PDUSessionResourceSetupResponse_packets}
    ...                                                xpath=.//ngap.RAN_UE_NGAP_ID
    [Return]    ${RAN_UE_NGAP_ID}[0]