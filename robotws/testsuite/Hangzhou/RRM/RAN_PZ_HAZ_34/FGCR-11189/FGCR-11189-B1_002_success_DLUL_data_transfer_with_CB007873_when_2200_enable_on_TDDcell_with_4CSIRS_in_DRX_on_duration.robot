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
# Suite Teardown    Run Keywords
# ...    Run Keyword And Ignore Error    Common Suite Teardown for 11189    AND
# ...    Run Keyword And Ignore Error    Common Suite Teardown for COAM    gnb_index=${0}
# 
# Resource      ./Resources/FGCR-11189_coam_common_keywords.robot
# Variables     ./Resources/Stream_parameter.py
# Variables     ./Resources/variables.py
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
# 
# ${dlexpect_scell}        200
# ${dlexpect_pcell}        70
# ${dlexpect_scell1}        220
# ${dlexpect_pcell1}        70
# ${ulexpect_scell}        0
# ${ulexpect_pcell}        10
# @{att_value}       0     10     30     65
# ${command_template_bip}       {tshark_path} -r {pcap_file} -X lua_script:{luashark_path} -Y  \"nr-rrc\" -T pdml
# ${wiresharklog_B1_002_csi}         11189_wireshark_B1_002_csi.pcap
# ${wiresharklog_B1_002_mg}          11189_wireshark_B1_002_mg.pcap
# ${Aasyslog_B1_002_act}           11189_Aasyslog_B1_002_act.txt
# ${Aasyslog_B1_002_deact}         11189_Aasyslog_B1_002_deact.txt
# ${X2AP_COMMAND}      {tshark_path} -r {pcap_file} -Y  \"x2ap\"  -T pdml
# ${enb1_gnb1_x2_dist}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNADJGNB-1
# ${enb2_gnb1_x2_dist}    MRBTS-${tl.enbs[1].instance_id}/LNBTS-${tl.enbs[1].instance_id}/LNADJGNB-1
# ${eNB_X2_ON_OFF}    administrativeState
# ${enb1_def_gnb_dist}     MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
# ${enb2_def_gnb_dist}     MRBTS-${enb2_instance}/LNBTS-${enb2_instance}/LNCEL-1
# ${enb_def_cell_para}     defaultLnRelGnbCellId
# ${enb_instance}    ${tl.enbs[0].instance_id}
# ${enb2_instance}    ${tl.enbs[1].instance_id}
# 
# *** Test Cases ***
# [1]FGCR-11189-B1_002_success_DLUL_data_transfer_with_CB007873_when_2200_enable_on_TDDcell_with_4CSIRS_in_DRX_on_duration
#     [Documentation]
#     ...    this test case is to verify 5G-UE is successfully connected to the NR FDD cell as P(S)Cell and configured with FR1-TDD cell
#     ...    (2200 enable with 4 csiresource) as SCell, and DL data transfer is possible via both P(S)Cell and SCell with 2200 enable with
#     ...    4 csiresource and within DRX on duration in NSA mode.
#     [Tags]      NSA     CRT_TRUNK    CRT_23R1    CRT_22R3    CRT_22R4
#     [Timeout]    1 hour
#     [Setup]
#     robot_common_operations.Common Case Setup
#     Connect and Modify the ENB parameter
#     ...    enb_index=${1}    value=locked    dist_name=${enb2_gnb1_x2_dist}    parameter=${eNB_X2_ON_OFF}
#     Connect and Modify the ENB parameter    value=2    dist_name=${enb2_def_gnb_dist}    parameter=${enb_def_cell_para}
#     ...    enb_index=${1}
#     Modify the COAM parameter with admin API 11189    parameters=${LOCK_GNB1_AMF}    bts_host=${gnb_BTS_host}
#     Connect and Modify the ENB parameter
#     ...    enb_index=${1}    value=unlocked    dist_name=${enb2_gnb1_x2_dist}    parameter=${eNB_X2_ON_OFF}
#     Prepare the atten for each TL NSA
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#     sleep    10s
#     Start capture gNB log on master    filename=${wiresharklog_B1_002_csi}   gNB_index=${0}
#     Wait Until Keyword Succeeds    15min    60s    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
#     Stop and download the Logs    filename=${wiresharklog_B1_002_csi}   gNB_index=${0}
#     Prepare and Start Aasyslog capture 11189    log_name=${Aasyslog_B1_002_act}    gnb_index=${0}
#     Start DL tput and check dl throughput with nrcellid 11189
#     ...    dlexpect_pcell=${dlexpect_pcell1}    dlexpect_scell=${dlexpect_scell1}    pcellid=${2}    scellid=${1}    ue_index=${1}
#     Stop and download Aasyslog 11189    log_name=${Aasyslog_B1_002_act}    gnb_index=${0}
# #    Start UL tput and check ul throughput with nrcellid 11189    ulexpect_pcell=${ulexpect_pcell}    ulexpect_scell=${ulexpect_scell}
# #    ...    pcellid=${2}    scellid=${1}
#     sleep    5s
#     Start capture gNB log on master    filename=${wiresharklog_B1_002_mg}   gNB_index=${0}
#     sleep    5s
#     Prepare the atten for each TL for mg NSA
#     sleep    40s
#     Prepare the atten for each TL NSA
#     sleep    10s
#     DL Tput check with nrcellid 11189    dlexpect_tp=${dlexpect_pcell}    cellid=${2}
#     DL Tput check with nrcellid 11189    dlexpect_tp=${dlexpect_scell}    cellid=${1}
#     Stop and download the Logs    filename=${wiresharklog_B1_002_mg}   gNB_index=${0}
#     Prepare and Start Aasyslog capture 11189    log_name=${Aasyslog_B1_002_deact}    gnb_index=${0}
#     Power UE stop ul and dl traffic 11189
#     sleep    10s
#     Stop and download Aasyslog 11189    log_name=${Aasyslog_B1_002_deact}    gnb_index=${0}
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#     Analysis wireshark log 11189
#     Analysis Aasyslog 11189    Aasyslog_act=${Aasyslog_B1_002_act}    Aasyslog_deact=${Aasyslog_B1_002_deact}
#     [Teardown]    Run Keyword And Ignore Error    Tests Recover 11189 NSA
# 
# 
# 
# *** Keywords ***
# Analysis wireshark log 11189
#     ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${wiresharklog_B1_002_csi}    tshark_path=${tshark_path}
#     ...    command_template=${X2AP_COMMAND}
#     ${filter_expression}=    Catenate     x2ap.procedureCode == 27 || x2ap.procedureCode == 30
#     ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
#     ${nrofPorts}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.nrofPorts
#     should contain any    ${nrofPorts}    1    2    4
#     ${number of P8}=    get count    ${nrofPorts}    3
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
#     ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${wiresharklog_B1_002_mg}    tshark_path=${tshark_path}
#     ...    command_template=${X2AP_COMMAND}
#     ${filter_expression}=    Catenate    x2ap.procedureCode == 29 || x2ap.procedureCode == 30
#     ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
#     ${drx_release}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.drx_Config
#     should contain    ${drx_release}    0
#     ${MG_setup}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.measGapConfig
#     should contain    ${MG_setup}    1
#     ${MG_release}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.measGapConfig
#     should contain    ${MG_release}    0
# 
# Analysis Aasyslog 11189
#     [Arguments]    ${Aasyslog_act}    ${Aasyslog_deact}
#     ${handleMacCe}=    Run    command=cat ${epc_log_path}/${Aasyslog_act} | grep -a "handleMacCe"
#     ${scell_activate}     set variable    ${handleMacCe.split('sCellMask:')[1]}
#     Run Keyword If    '${gnb_instance}' == '@{BTSID}[0]'    Should Contain x times    ${scell_activate}    0x2    2
#     Run Keyword If    '${gnb_instance}' == '@{BTSID}[1]'    Should Contain x times    ${scell_activate}    0x2    2
#     Run Keyword If    '${gnb_instance}' == '@{BTSID}[2]'    Should Contain x times    ${scell_activate}    0x2    2
#     #sCellMask    0x2 scell activate
#     ${sendMacCe}=    Run    command=cat ${epc_log_path}/${Aasyslog_deact} | grep -a "sendMacCe"
#     ${scell_deactivate}     set variable    ${sendMacCe.split('sCellMask:')[1]}
#     Should Contain x times    ${scell_deactivate}    0x0    1          #scell deactivate
