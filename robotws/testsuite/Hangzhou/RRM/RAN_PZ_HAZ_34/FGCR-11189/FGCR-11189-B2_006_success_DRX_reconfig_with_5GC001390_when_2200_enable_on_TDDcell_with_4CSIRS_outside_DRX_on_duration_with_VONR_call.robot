# *** Settings ***
# Force Tags    PY36
# Documentation
# ...    author: Rebecca.Liu
# ...    contact: jia-rebecca.liu@nokia-sbell.com
# ...    squad group: SG_03
# ...    feature : FGCR-11189
# 
# 
# Suite Setup    Run Keywords
# ...             Run Keyword And Ignore Error     Common Suite Setup for 11189    AND
# ...            Load SCF for each TL
# 
# Suite Teardown    Run Keyword And Ignore Error    Common Suite Teardown for COAM
# 
# Resource      ./Resources/FGCR-11189_coam_common_keywords.robot
# Variables     ./Resources/variables.py
# Variables     ./Resources/Stream_parameter.py
# 
# *** Variables ***
# #${tl_36011_scf_gnb1}    gy_36011_GNB1_11189_B1B2.xml
# #${tl_34711_scf_gnb1}    gy_34711_GNB1_11189_B1B2.xml
# #${tl_23311_scf_gnb1}    gy_23311_GNB1_11189_B1B2.xml
# ${tl_36011_scf_gnb1}    gy_36011_GNB1.xml
# ${tl_34711_scf_gnb1}    gy_34711_GNB1.xml
# ${tl_23311_scf_gnb1}    gy_23311_GNB1.xml
# ${tl_36012_scf_gnb2}    gy_36012_GNB2.xml
# ${tl_34712_scf_gnb2}    gy_34712_GNB2.xml
# ${tl_23312_scf_gnb2}    gy_23312_GNB2.xml
# ${swconfig_paths}            /opt/workspace/SCF/swconfig_11189/swconfig.txt
# #${Trunk_SCF_B2_006}                TRUNK_SA_11189_B2_006.xml
# #${SBTS22R3_SCF_B2_006}             SBTS22R3_SA_11189_B2_006.xml
# #${SBTS22R2_SCF_B2_006}             SBTS22R2_SA_11189_B2_006.xml
# #${SBTS22R4_SCF_B2_006}             SBTS22R4_SA_11189_B2_006.xml
# ${wiresharklog_B2_006}           11189_wireshark_B2_006.pcap
# ${wiresharklog_B2_006_vonr}      11189_wireshark_B2_006_vonr.pcap
# ${Aasyslog_B2_006_act}           11189_btslog_B2_006_act.txt
# ${Aasyslog_B2_006_deact}         11189_btslog_B2_006_deact.txt
# ${dlexpect_scell}        200
# ${dlexpect_pcell}        90
# @{att_value}            0    10    30    65
# ${command_template_bip}       {tshark_path} -r {pcap_file} -X lua_script:{luashark_path} -Y  \"nr-rrc\" -T pdml
# ${epc_log_path}        /home/ute/TAF/
# ${wiresharklog}        x2f1_sctp_log.pcap
# ${F1AP_COMMAND}        {tshark_path} -r {pcap_file} -Y  \"f1ap\"  -T pdml
# ${E1AP_COMMAND}        {tshark_path} -r {pcap_file} -Y  \"e1ap\"  -T pdml
# ${ulexpect_scell}        0
# ${ulexpect_pcell}        5
# 
# *** Test Cases ***
# [1]FGCR-11189-B2_006_success_DRX_reconfig_with_5GC001390_when_2200_enable_on_TDDcell_with_4CSIRS_outside_DRX_on_duration_with_VONR_call
#     [Documentation]
#     ...    this test case is to verify 5G-UE is successfully connected to the NR FDD cell as P(S)Cell and configured with FR1-TDD cell as SCell,
#     ...    and DL data transfer via both P(S)Cell and SCell (2200 enable with 4CSIRS), Pcell DRX enable but Scell's Scell CSIRS/CSI report/beam
#     ...    report not inside the DRX on duration at all on SA mode.DRX recofniguration should be right before and after VONR call.
#     [Tags]      SA     coam     CRT_TRUNK    CRT_22R3    CRT_22R2    CRT_22R4
#     [Timeout]    1 hour
#     [Setup]
#     robot_common_operations.Common Case Setup
#     Modify the COAM parameter with admin API 11189    parameters=${PARAM_B1_007}    bts_host=${gnb_BTS_host}
#     Set cell status barred 11189    set_cell_barred=${Barred_GNB1_CELL1}    bts_host=${gnb_BTS_host}
#     Prepare the atten for each TL
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#     sleep    10s
#     Start capture gNB log on master    filename=${wiresharklog_B2_006}   gNB_index=${0}
#     Wait Until Keyword Succeeds    15min    60s    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#     Stop and download the Logs    filename=${wiresharklog_B2_006}   gNB_index=${0}
#     Prepare and Start Aasyslog capture 11189    log_name=${Aasyslog_B2_006_act}    gnb_index=${0}
#     Start DL tput and check dl throughput with nrcellid 11189    dlexpect_pcell=${dlexpect_pcell}    dlexpect_scell=${dlexpect_scell}
#     ...    pcellid=${2}    scellid=${1}    ue_index=${1}
#     Start UL tput and check ul throughput with nrcellid 11189    ulexpect_pcell=${ulexpect_pcell}    ulexpect_scell=${ulexpect_scell}
#     ...    pcellid=${2}    scellid=${1}    ue_index=${1}
#     Stop and download Aasyslog 11189    log_name=${Aasyslog_B2_006_act}    gnb_index=${0}
#     sleep    5s
#     Start capture gNB log on master    filename=${wiresharklog_B2_006_vonr}   gNB_index=${0}
#     Log to console    make a VONR call
#     Make a VoNR call(+4488) 11189    ue_index=${1}
#     sleep    10s
#     Log to console    hang up VONR call
#     hang up VoNR call 11189    ue_index=${1}
#     sleep    10s
#     Stop and download the Logs    filename=${wiresharklog_B2_006_vonr}   gNB_index=${0}
#     sleep    5s
#     Power UE check DL throughput with nrcellid 11189    dlexpect=${dlexpect_pcell}    cellid=${2}
#     Power UE check DL throughput with nrcellid 11189    dlexpect=${dlexpect_scell}    cellid=${1}
#     Prepare and Start Aasyslog capture 11189    log_name=${Aasyslog_B2_006_deact}    gnb_index=${0}
#     power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${DL_PORT}    ue_index=${1}
#     sleep    2s
#     Stop and download Aasyslog 11189    log_name=${Aasyslog_B2_006_deact}    gnb_index=${0}
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#     Analysis wireshark log 11189 B2_006
#     Analysis Aasyslog 11189     Aasyslog_act=${Aasyslog_B2_006_act}    Aasyslog_deact=${Aasyslog_B2_006_deact}
#     [Teardown]    Run Keyword And Ignore Error     Tests Recover 11189 B2_006
# 
# 
# 
# 
# *** Keywords ***
# Analysis wireshark log 11189 B2_006
#     ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${wiresharklog_B2_006}    tshark_path=${tshark_path}
#     ...    command_template=${F1AP_COMMAND}
#     ${filter_expression}=    Catenate     nr-rrc.sCellToAddModList == 1 && nr-rrc.drx_Config == 1 && nr-rrc.rlc_BearerToAddModList == 4
#     ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
#     ${nrofPorts}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.nrofPorts
#     ${number of P8}=    get count    ${nrofPorts}    3
#     should contain any    '${number of P8}'    1    2    4
#     ${cdm_Type}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.cdm_Type
#     should contain    ${cdm_Type}    2
#     ${density}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.density
#     should contain    ${density}    1
#     ${n1-n2}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.n1_n2
#     run keyword if    '${number of P8}'=='1'     should be true    '${n1-n2}[0]'=='2'
#     run keyword if    '${number of P8}'=='2'     should be true    '${n1-n2}[0]'=='1'
#     run keyword if    '${number of P8}'=='4'     should be true    '${n1-n2}[0]'=='1'
#     ${drx_setup}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.drx_Config
#     should contain    ${drx_setup}    1
#     ${drx_inactivitytimer}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.drx_InactivityTimer
#     should contain    ${drx_inactivitytimer}    14
#     ${drx_LongCycleStartOffset}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.drx_LongCycleStartOffset
#     should contain    ${drx_LongCycleStartOffset}    9
#     ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${wiresharklog_B2_006}    tshark_path=${tshark_path}
#     ...    command_template=${E1AP_COMMAND}
#     ${filter_expression}=    Catenate    e1ap.procedureCode == 8 || e1ap.procedureCode == 9
#     ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
#     ${fiveQI7}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//e1ap.fiveQI
#     should contain    ${fiveQI7}    7
#     ${fiveQI5}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//e1ap.fiveQI
#     should contain    ${fiveQI5}    5
#     ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${wiresharklog_B2_006_vonr}    tshark_path=${tshark_path}
#     ...    command_template=${E1AP_COMMAND}
#     ${filter_expression}=    Catenate     e1ap.procedureCode == 9
#     ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
#     ${fiveQI1}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//e1ap.fiveQI
#     should contain    ${fiveQI1}    1
#     ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${wiresharklog_B2_006_vonr}    tshark_path=${tshark_path}
#     ...    command_template=${F1AP_COMMAND}
#     ${filter_expression_drx_profile2}=    Catenate     nr-rrc.drx_Config == 1
#     ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression_drx_profile2}
#     ${drx_inactivitytimer}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.drx_InactivityTimer
#     should contain    ${drx_inactivitytimer}    6
#     should contain    ${drx_inactivitytimer}    14
#     ${drx_LongCycleStartOffset}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.drx_LongCycleStartOffset
#     should contain    ${drx_LongCycleStartOffset}    3
#     should contain    ${drx_LongCycleStartOffset}    9
# 
# Analysis Aasyslog 11189
#     [Arguments]     ${Aasyslog_act}    ${Aasyslog_deact}
#     ${handleMacCe}=    Run    command=cat ${epc_log_path}/${Aasyslog_act} | grep -a "handleMacCe"
#     ${scell_activate}     set variable    ${handleMacCe.split('sCellMask:')[1]}
#     Run Keyword If    '${gnb_instance}' == '@{BTSID}[0]'    Should Contain x times    ${scell_activate}    0x2    2
#     Run Keyword If    '${gnb_instance}' == '@{BTSID}[1]'    Should Contain x times    ${scell_activate}    0x2    2
#     Run Keyword If    '${gnb_instance}' == '@{BTSID}[2]'    Should Contain x times    ${scell_activate}    0x2    2
#     #sCellMask    0x2 scell activate
#     ${sendMacCe}=    Run    command=cat ${epc_log_path}/${Aasyslog_deact} | grep -a "sendMacCe"
#     ${scell_deactivate}     set variable    ${sendMacCe.split('sCellMask:')[1]}
#     Should Contain x times    ${scell_deactivate}    0x0    1          #scell deactivate
# 
# Analysis Aasyslog 11189 21A
#     [Arguments]    ${Aasyslog_act}    ${Aasyslog_deact}
#     ${handleMacCe}=    Run    command=cat ${epc_log_path}/${Aasyslog_act} | grep -a "handleMacCe"
#     ${scell_activate}     set variable    ${handleMacCe.split('handleMacCe')[1]}
#     Should Contain x times    ${scell_activate}    done    1         #scell activate
#     ${sendMacCe}=    Run    command=cat ${epc_log_path}/${Aasyslog_deact} | grep -a "handleDeactivationReq"
#     ${scell_deactivate}     set variable    ${sendMacCe.split('handleDeactivationReq')[1]}
#     Should Contain x times    ${scell_deactivate}    done    1          #scell deactivate
# 
# Tests Recover 11189 B2_006
#     Get product brand
#     Power UE stop dl traffic and detach 11189
#     hang up VoNR call 11189
#     check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${0}
#     CI_interface.Common Case Teardown
