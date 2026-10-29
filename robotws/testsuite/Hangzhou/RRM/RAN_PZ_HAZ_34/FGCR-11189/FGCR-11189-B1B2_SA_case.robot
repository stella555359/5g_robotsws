*** Settings ***
Force Tags    PY36
Documentation
...    author: Rebecca.Liu
...    contact: jia-rebecca.liu@nokia-sbell.com
...    squad group: SG_03
...    feature : FGCR-11189



Suite Setup    Load SCF for each TL for EDA


Suite Teardown    Run Keyword And Ignore Error    Common Suite Teardown for COAM

Resource      ./Resources/FGCR-11189_coam_common_keywords.robot
Variables     ./Resources/Stream_parameter.py
Variables     ./Resources/variables.py
Library       ./Resources/get_qualcomm_pwd.py

*** Variables ***
#${TRUNK_SCF}           TRUNK_SA_11189_DRX_MR_2200.xml
#${SBTS22R3_SCF}        SBTS22R3_SA_11189_DRX_MR_2200.xml
#${SBTS22R2_SCF}        SBTS22R2_SA_11189_DRX_MR_2200.xml
#${SBTS22R4_SCF}        SBTS22R4_SA_11189_DRX_MR_2200.xml
${tl_36011_scf_gnb1}    gy_36011_GNB1.xml
${tl_34711_scf_gnb1}    gy_34711_GNB1.xml
${tl_23311_scf_gnb1}    gy_23311_GNB1.xml
${tl_36012_scf_gnb2}    gy_36012_GNB2.xml
${tl_34712_scf_gnb2}    gy_34712_GNB2.xml
${tl_23312_scf_gnb2}    gy_23312_GNB2.xml
#${swconfig}            /opt/workspace/SCF/swconfig_11189/swconfig.txt
${swconfig_paths}            /opt/workspace/SCF/swconfig_11189/swconfig.txt

${dlexpect_scell}        200
${dlexpect_pcell}        90
${ulexpect_scell}        0
${ulexpect_pcell}        5
${wiresharklog_B1_006}             11189_wireshark_B1_006.pcap
${Aasyslog_B1_006_act}             11189_btslog_B1_006_act.txt
${Aasyslog_B1_006_deact}           11189_btslog_B1_006_deact.txt
${wiresharklog_B1_007_csi}         11189_wireshark_B1_007_csi.pcap
${wiresharklog_B1_007_mg}          11189_wireshark_B1_007_mg.pcap
${Aasyslog_B1_007_act}             11189_btslog_B1_007_act.txt
${Aasyslog_B1_007_deact}           11189_btslog_B1_007_deact.txt
${wiresharklog_B2_004_1}           11189_wireshark_B2_004_1.pcap
${wiresharklog_B2_004_2}           11189_wireshark_B2_004_2.pcap
${Aasyslog_B2_004_act1}            11189_btslog_B2_001_act1.txt
${Aasyslog_B2_004_deact1}          11189_btslog_B2_001_deact1.txt
${Aasyslog_B2_004_act2}            11189_btslog_B2_001_act2.txt
${Aasyslog_B2_004_deact2}          11189_btslog_B2_001_deact2.txt
@{att_value}            0    10    0    45
${command_template_bip}       {tshark_path} -r {pcap_file} -X lua_script:{luashark_path} -Y  \"nr-rrc\" -T pdml
${F1AP_COMMAND}               {tshark_path} -r {pcap_file} -Y  \"f1ap\"  -T pdml
#----574+EDA-----#
${TS_CASE_LOG_PATH}         /opt/workspace/CRT/Master/Case_Logs/
${enb1_gnb2_x2_dist}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNADJGNB-2
${enb2_gnb2_x2_dist}    MRBTS-${tl.enbs[1].instance_id}/LNBTS-${tl.enbs[1].instance_id}/LNADJGNB-2
${eNB1_cell1_distname}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
${eNB2_cell1_distname}    MRBTS-${tl.enbs[1].instance_id}/LNBTS-${tl.enbs[1].instance_id}/LNCEL-1
${enb1_def_gnb_dist}     MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
${enb_def_cell_para}     defaultLnRelGnbCellId
${eNB_X2_ON_OFF}    administrativeState
${eNB_tac}        tac
${nr_ul_expect}        35
${eNB1_x2_log_001}    574_C_001_eNB1.pcap
${eNB2_x2_log_001}    574_C_001_eNB2.pcap
${gNB_x2_log_001}    574_C_001_gNB.pcap
${ul_throughput_574}    100M
@{value_counter_C01}    ${0}     ${0}    ${0}     ${0}
@{value_counter_C011}    ${0}     ${0}    ${0}
@{value_counter_C012}    ${0}
${command_template_X}    {tshark_path} -r {pcap_file} -Y  \"f1ap\"  -T pdml
${command_template_Y}    {tshark_path} -r {pcap_file} -Y \"x2ap\" -T pdml
${command_template_Z}    {tshark_path} -r {pcap_file} -Y  \"e1ap\"  -T pdml
${eNB1_asik_addr}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${eNB2_asik_addr}    ${tl.enbs[1].airscale.common_units[0].lmp_connection.addr}
${gnb2_asik_addr}    ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.addr}
${COMport_TL233}    COM24
${COMport_TL360}    COM9

*** Test Cases ***
[1]5GC000574_A_007_without_change_SCG_DL_and_UL_split_mode
    [Documentation]
    ...    This test case is to verify EDA 03266995
    [Tags]      SA     coam     CRT_TRUNK     CRT_22R3    CRT_22R2    CRT_22R4
    [Timeout]    1 hour
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    put btslog_ini file to ute
    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
    Start capture syslog via btslog on ute
    ##FGCR_11189 CASE STEP
    EDA CASE STEP



#[1]FGCR-11189-B2_004_success_DLUL_data_transfer_with_5GC001390_when_2200_enable_on_TDDcell_with_4CSIRS_outside_DRX_on_duration_with_long_PUCCH
#    [Documentation]
#    ...    this test case is to verify 5G-UE is successfully connected to the NR FDD cell as P(S)Cell and configured with FR1-TDD cell as SCell,
#    ...    and DL data transfer via both P(S)Cell and SCell (2200 enable with 4CSIRS), Pcell DRX enable but Scell's CSIRS/CSI report/beam report
#    ...    not inside the DRX on duration at all on SA mode.
#    [Tags]      SA     coam     CRT_TRUNK    CRT_22R3    CRT_22R2    CRT_22R4
#    [Timeout]    1 hour
#    [Setup]
#    Connect and Modify the parameter on enblte     dist_name=${TL372_enbcell_dist}    parameter=administrativeState     value=locked
#    Modify the COAM parameter with admin API 11189    parameters=${PARAM_B2_004}    bts_host=${gnb_BTS_host}
#    Set cell status barred 11189    set_cell_barred=${Barred_GNB1_CELL1}    bts_host=${gnb_BTS_host}
#    Setup and set HBTE attenuation 2 ports 11189    value_1=${${att_value}[0]}    value_2=${${att_value}[0]}
#    Power UE Precondition 11189
#    Start To Capture Wireshark Logs on ASIK 11189    logname=${wiresharklog_B2_004_1}    gnb_index=${0}
#    Attach and check power UE 11189    4g_check=false
#    Prepare and Start Aasyslog capture 11189    log_name=${Aasyslog_B2_004_act1}    gnb_index=${0}
#    Start DL tput and check dl throughput with nrcellid 11189    dlexpect_pcell=${dlexpect_pcell}    dlexpect_scell=${dlexpect_scell}
#    ...    pcellid=${2}    scellid=${1}
#    Start UL tput and check ul throughput with nrcellid 11189    ulexpect_pcell=${ulexpect_pcell}    ulexpect_scell=${ulexpect_scell}
#    ...    pcellid=${2}    scellid=${1}
#    Stop and download Aasyslog 11189    log_name=${Aasyslog_B2_004_act1}    gnb_index=${0}
#    sleep    10s
#    Prepare and Start Aasyslog capture 11189    log_name=${Aasyslog_B2_004_deact1}    gnb_index=${0}
#    Power UE stop ul and dl traffic 11189
#    sleep    5s
#    Stop and download Aasyslog 11189    log_name=${Aasyslog_B2_004_deact1}    gnb_index=${0}
#    sleep    3s
#    Stop and download wireshark Logs on ASIK 11189    logname=${wiresharklog_B2_004_1}    gnb_index=${0}
#    sleep    35s
#    Start To Capture Wireshark Logs on ASIK 11189    logname=${wiresharklog_B2_004_2}    gnb_index=${0}
#    Prepare and Start Aasyslog capture 11189    log_name=${Aasyslog_B2_004_act2}    gnb_index=${0}
#    Start DL tput and check dl throughput with nrcellid 11189    dlexpect_pcell=${dlexpect_pcell}    dlexpect_scell=${dlexpect_scell}
#    ...    pcellid=${2}    scellid=${1}
#    Start UL tput and check ul throughput with nrcellid 11189    ulexpect_pcell=${ulexpect_pcell}    ulexpect_scell=${ulexpect_scell}
#    ...    pcellid=${2}    scellid=${1}
#    Stop and download Aasyslog 11189    log_name=${Aasyslog_B2_004_act2}    gnb_index=${0}
#    sleep    10s
#    Stop and download wireshark Logs on ASIK 11189    logname=${wiresharklog_B2_004_2}    gnb_index=${0}
#    Prepare and Start Aasyslog capture 11189    log_name=${Aasyslog_B2_004_deact2}    gnb_index=${0}
#    Power UE stop ul and dl traffic 11189
#    sleep    5s
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    Stop and download Aasyslog 11189    log_name=${Aasyslog_B2_004_deact2}    gnb_index=${0}
#    Analysis wireshark log B2_004
#    run keyword if    '${release_info}' == '5G21A_GNB_0011'    Analysis Aasyslog 11189 21A    Aasyslog_act=${Aasyslog_B2_004_act1}
#    ...    Aasyslog_deact=${Aasyslog_B2_004_deact1}
#    ...    ELSE    Analysis Aasyslog 11189    Aasyslog_act=${Aasyslog_B2_004_act1}    Aasyslog_deact=${Aasyslog_B2_004_deact1}
#    run keyword if    '${release_info}' == '5G21A_GNB_0011'    Analysis Aasyslog 11189 21A    Aasyslog_act=${Aasyslog_B2_004_act2}
#    ...    Aasyslog_deact=${Aasyslog_B2_004_deact2}
#    ...     ELSE    Analysis Aasyslog 11189    Aasyslog_act=${Aasyslog_B2_004_act2}    Aasyslog_deact=${Aasyslog_B2_004_deact2}
#    [Teardown]    Run Keyword And Ignore Error    Tests Recover 11189 SA

*** Keywords ***
FGCR_11189 CASE STEP
    Modify the COAM parameter with admin API 11189    parameters=${PARAM_B1_007}    bts_host=${gnb_BTS_host}
    Set cell status barred 11189    set_cell_barred=${Barred_GNB1_CELL1}    bts_host=${gnb_BTS_host}
    Prepare the atten for each TL
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
    sleep    10s
    Start capture gNB log on master    filename=${wiresharklog_B1_007_csi}   gNB_index=${0}
    Wait Until Keyword Succeeds    15min    60s    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${0}
    Stop and download the Logs    filename=${wiresharklog_B1_007_csi}   gNB_index=${0}
    Prepare and Start Aasyslog capture 11189    log_name=${Aasyslog_B1_007_act}    gnb_index=${0}
    Start DL tput and check dl throughput with nrcellid 11189    dlexpect_pcell=${dlexpect_pcell}    dlexpect_scell=${dlexpect_scell}
    ...    pcellid=${2}    scellid=${1}    ue_index=${1}
    Start UL tput and check ul throughput with nrcellid 11189    ulexpect_pcell=${ulexpect_pcell}    ulexpect_scell=${ulexpect_scell}
    ...    pcellid=${2}    scellid=${1}    ue_index=${1}
    Stop and download Aasyslog 11189    log_name=${Aasyslog_B1_007_act}    gnb_index=${0}
    sleep    5s
    Start capture gNB log on master    filename=${wiresharklog_B1_007_mg}   gNB_index=${0}
    sleep    5s
    Prepare the atten for each TL for mg
    sleep    10s
    Prepare the atten for each TL
    sleep    10s
    Stop and download the Logs    filename=${wiresharklog_B1_007_mg}   gNB_index=${0}
    Prepare and Start Aasyslog capture 11189    log_name=${Aasyslog_B1_007_deact}    gnb_index=${0}
    Power UE stop ul and dl traffic 11189
    sleep    10s
    Stop and download Aasyslog 11189    log_name=${Aasyslog_B1_007_deact}    gnb_index=${0}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
    Analysis wireshark log B1_007    wiresharklog1=${wiresharklog_B1_007_csi}    wiresharklog2=${wiresharklog_B1_007_mg}
    Analysis Aasyslog 11189    Aasyslog_act=${Aasyslog_B1_007_act}    Aasyslog_deact=${Aasyslog_B1_007_deact}
    [Teardown]    Run Keyword And Ignore Error    Tests Recover 11189 SA

EDA CASE STEP
    log to console     \n*** start test EDA case step ***\n
    get quaclomm username and pwd
    Set Test Variable     ${ue_index}    ${2}
#    Set Test Variable     ${COMport}    ${COMport_TL360}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'    Set Test Variable     ${COMport}    ${COMport_TL233}
    ...    ELSE IF    '${gnb_instance}' == '${BTSID}[0]'    Set Test Variable     ${COMport}    ${COMport_TL360}
#    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
#    ...    Set Test Variable     ${ue_index}    ${2}
    ${GNB2_CELLID}    COAM Get nrcellid with lcrid     lcrid=${1}    gnb_index=${1}
    Connect and Modify the ENB parameter
    ...    enb_index=${0}    value=locked    dist_name=${enb1_gnb2_x2_dist}    parameter=${eNB_X2_ON_OFF}
    Connect and Modify the ENB parameter
    ...    enb_index=${1}    value=locked    dist_name=${enb2_gnb2_x2_dist}    parameter=${eNB_X2_ON_OFF}
    Connect and Modify the ENB parameter    value=3    dist_name=${enb1_def_gnb_dist}    parameter=${enb_def_cell_para}
    Connect and Modify the ENB parameter
    ...    enb_index=${0}    value=unlocked    dist_name=${enb1_gnb2_x2_dist}    parameter=${eNB_X2_ON_OFF}
    Connect and Modify the ENB parameter
    ...    enb_index=${1}    value=unlocked    dist_name=${enb2_gnb2_x2_dist}    parameter=${eNB_X2_ON_OFF}
    Prepare the atten for each TL FOR EDA
    Connect and Modify the ENB parameter
    ...    enb_index=${1}    value=21000    dist_name=${eNB2_cell1_distname}    parameter=${eNB_tac}
    Online modify NIDD on gnb1 and gnb2    Modify_Para_Online_GNB2=${LOCK_GNB2_AMF}
    ...    ModifySCF_Aftercommission_for_GNB2=True
    Prepare LKC and get license    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    ui_version=S20UI2.5    power_reset=True
    Start to collect the log on eNB    log_name=${eNB1_x2_log_001}    eNB_index=${0}
    Start to collect the log on eNB    log_name=${eNB2_x2_log_001}    eNB_index=${1}
    Start capture gNB log on master    filename=${gNB_x2_log_001}   gNB_index=${1}
    Wait Until Keyword Succeeds    10min    40s    Attach and check power UE    ue_type=${ue_type}
    ...    ue_index=${ue_index}    gnb_index=${1}    4G_check=True
    Set Suite Variable     ${iperf_button}     800 350
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput_574}    duration=${ul_time}
    ...    iperf_port=${ul_port}    ue_index=${ue_index}
    Capture QXDM log by COMport    ue_index=${ue_index}    QXDM_log_name=before_ho_lte    COMport=${COMport}
    5G isf decoder to txt and save to local    ue_index=${ue_index}    QXDM_log_name=before_ho_lte
    Check the UL throughput    ul_expected_throughput=${nr_ul_expect}    cell_id=${GNB2_CELLID}    gnb_index=${1}
    Deal uldata with hdf    QXDM_log_name=before_ho_lte    lte_ul_expect=30000
    Change PA to Menb Handover
    Capture QXDM log by COMport    ue_index=${ue_index}    QXDM_log_name=after_ho_lte    COMport=${COMport}
    5G isf decoder to txt and save to local    ue_index=${ue_index}    QXDM_log_name=after_ho_lte
    Check the UL throughput    ul_expected_throughput=${nr_ul_expect}    cell_id=${GNB2_CELLID}    gnb_index=${1}
    Deal uldata with hdf    QXDM_log_name=after_ho_lte    lte_ul_expect=30000
    Stop and download Logs on eNB    log_name=${eNB1_x2_log_001}    eNB_index=${0}
    Stop and download Logs on eNB    log_name=${eNB2_x2_log_001}    eNB_index=${1}
    Stop and download the Logs    filename=${gNB_x2_log_001}   gNB_index=${1}
    wait until keyword succeeds    8min    29s    Check the relocation counters C011
    wait until keyword succeeds    8min    29s    Check the relocation counters C010
    wait until keyword succeeds    8min    29s    Check the relocation counters C012
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    Check the logs when actInterMeNBMobility equal to true for 1200    eNB1_x2_log=${eNB1_x2_log_001}
    ...    eNB2_x2_log=${eNB2_x2_log_001}    gNB_x2_log=${gNB_x2_log_001}
    Stop capture syslog via btslog on ute
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Run Keyword And Ignore Error    release lkc license    AND
    ...    Run Keyword And Ignore Error
    ...    Stop and download Logs on eNB    log_name=${eNB1_x2_log_001}    eNB_index=${0}    AND
    ...    Run Keyword And Ignore Error
    ...    Stop and download Logs on eNB    log_name=${eNB2_x2_log_001}    eNB_index=${1}    AND
    ...    Run Keyword And Ignore Error
    ...    Stop and download the Logs    filename=${gNB_x2_log_001}   gNB_index=${1}    AND
    ...    Connect and Modify the ENB parameter
    ...    enb_index=${1}    value=20000    dist_name=${eNB2_cell1_distname}    parameter=${eNB_tac}    AND
    ...    Online modify NIDD on gnb1 and gnb2    Modify_Para_Online_GNB2=${UNLOCK_GNB2_AMF}
    ...    ModifySCF_Aftercommission_for_GNB2=True    AND
    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}    AND
    ...    Adjust the TL HBTE attenuation value    AND
    ...    Hanging resource test    AND
    ...    Run Keyword And Ignore Error    Stop capture syslog via btslog on ute    AND
    ...    get and analysis syslog    AND
    ...    Run Keyword And Ignore Error    Common Case Teardown for COAM

Analysis wireshark log B1_007
    [Arguments]    ${wiresharklog1}    ${wiresharklog2}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${wiresharklog1}    tshark_path=${tshark_path}
    ...    command_template=${F1AP_COMMAND}
    ${filter_expression}=    Catenate     f1ap.procedureCode == 7 && nr-rrc.sCellToAddModList == 1 && nr-rrc.rlc_BearerToAddModList == 1
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
    ${nrofPorts}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.nrofPorts
    ${number of P8}=    get count    ${nrofPorts}    3
    should contain any    '${number of P8}'    1    2    4
    ${cdm_Type}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.cdm_Type
    should contain    ${cdm_Type}    2
    ${density}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.density
    should contain    ${density}    1
    ${n1-n2}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.n1_n2
    run keyword if    '${number of P8}'=='1'     should be true    '${n1-n2}[0]'=='2'
    run keyword if    '${number of P8}'=='2'     should be true    '${n1-n2}[0]'=='1'
    run keyword if    '${number of P8}'=='4'     should be true    '${n1-n2}[0]'=='1'
    ${cdm_Type}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.cdm_Type
    should contain    ${cdm_Type}    2
    ${density}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.density
    should contain    ${density}    1
    ${filter_expression_7}=    Catenate     f1ap.procedureCode == 7
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression_7}
    ${drx_setup}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.drx_Config
    should contain    ${drx_setup}    1
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${wiresharklog2}    tshark_path=${tshark_path}
    ...    command_template=${F1AP_COMMAND}
    ${filter_expression}=    Catenate    f1ap.procedureCode == 7
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
    ${drx_release}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.drx_Config
    should contain    ${drx_release}    0
    ${MG_setup}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.gapUE
    should contain    ${MG_setup}    1
    ${MG_release}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.gapUE
    should contain    ${MG_release}    0

Analysis wireshark log B1_006
    [Arguments]    ${wiresharklog}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${wiresharklog}    tshark_path=${tshark_path}
    ...    command_template=${F1AP_COMMAND}
    ${filter_expression}=    Catenate     f1ap.procedureCode == 7 && nr-rrc.sCellToAddModList == 1 && nr-rrc.rlc_BearerToAddModList == 1
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
    ${cdm_Type}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.cdm_Type
    should contain    ${cdm_Type}    2
    ${density}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.density
    should contain    ${density}    1
    ${nrofPorts}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.nrofPorts
    ${number of P8}=    get count    ${nrofPorts}    3
    should contain any    '${number of P8}'    1    2    4
    ${n1-n2}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.n1_n2
    run keyword if    '${number of P8}'=='1'     should be true    '${n1-n2}[0]'=='2'
    run keyword if    '${number of P8}'=='2'     should be true    '${n1-n2}[0]'=='1'
    run keyword if    '${number of P8}'=='4'     should be true    '${n1-n2}[0]'=='1'

Analysis Aasyslog 11189
    [Arguments]    ${Aasyslog_act}    ${Aasyslog_deact}
    ${handleMacCe}=    Run    command=cat ${epc_log_path}/${Aasyslog_act} | grep -a "handleMacCe"
    ${scell_activate}     set variable    ${handleMacCe.split('sCellMask:')[1]}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'    Should Contain x times    ${scell_activate}    0x2    2
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'    Should Contain x times    ${scell_activate}    0x2    2
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'    Should Contain x times    ${scell_activate}    0x2    2
    #sCellMask    0x2 scell activate
    ${sendMacCe}=    Run    command=cat ${epc_log_path}/${Aasyslog_deact} | grep -a "sendMacCe"
    ${scell_deactivate}     set variable    ${sendMacCe.split('sCellMask:')[1]}
    Should Contain x times    ${scell_deactivate}    0x0    1          #scell deactivate

Analysis Aasyslog 11189 21A
    [Arguments]    ${Aasyslog_act}    ${Aasyslog_deact}
    ${handleMacCe}=    Run    command=cat ${epc_log_path}/${Aasyslog_act} | grep -a "handleMacCe"
    ${scell_activate}     set variable    ${handleMacCe.split('handleMacCe')[1]}
    Should Contain x times    ${scell_activate}    done    1         #scell activate
    ${sendMacCe}=    Run    command=cat ${epc_log_path}/${Aasyslog_deact} | grep -a "handleDeactivationReq"
    ${scell_deactivate}     set variable    ${sendMacCe.split('handleDeactivationReq')[1]}
#    Should Contain x times    ${scell_deactivate}    done    1          #scell deactivate

Analysis wireshark log B2_004
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${wiresharklog_B2_004_1}    tshark_path=${tshark_path}
    ...    command_template=${F1AP_COMMAND}
    ${filter_expression}=    Catenate    (nr-rrc.sCellToAddModList == 1 && nr-rrc.drx_Config == 1) && (nr-rrc.rlc_BearerToAddModList == 3)
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
    ${nrofPorts}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.nrofPorts
    ${number of P8}=    get count    ${nrofPorts}    3
    should contain any    '${number of P8}'    1    2    4
    ${cdm_Type}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.cdm_Type
    should contain    ${cdm_Type}    2
    ${density}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.density
    should contain    ${density}    1
    ${n1-n2}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.n1_n2
    run keyword if    '${number of P8}'=='1'     should be true    '${n1-n2}[0]'=='2'
    run keyword if    '${number of P8}'=='2'     should be true    '${n1-n2}[0]'=='1'
    run keyword if    '${number of P8}'=='4'     should be true    '${n1-n2}[0]'=='1'
    ${drx_setup}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.drx_Config
    should contain    ${drx_setup}    1
    ${longpucch}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.format
    should contain    ${longpucch}    1
    should contain    ${longpucch}    3
#    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${wiresharklog_B2_004_2}    tshark_path=${tshark_path}
#    ...    command_template=${F1AP_COMMAND}
#    ${filter_expression}=    Catenate    (nr-rrc.sCellToAddModList == 1 && nr-rrc.drx_Config == 1) && (nr-rrc.rlc_BearerToAddModList == 3)
#    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
#    ${nrofPorts}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.nrofPorts
#    ${number of P8}=    get count    ${nrofPorts}    3
#    should contain any    '${number of P8}'    1    2    4
#    ${cdm_Type}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.cdm_Type
#    should contain    ${cdm_Type}    2
#    ${density}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.density
#    should contain    ${density}    1
#    ${n1-n2}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.n1_n2
#    run keyword if    '${number of P8}'=='1'     should be true    '${n1-n2}[0]'=='2'
#    run keyword if    '${number of P8}'=='2'     should be true    '${n1-n2}[0]'=='1'
#    run keyword if    '${number of P8}'=='4'     should be true    '${n1-n2}[0]'=='1'
#    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
#    ${drx_setup}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.drx_Config
#    should contain    ${drx_setup}    1

Analysis wireshark log B2_004 21A
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${wiresharklog_B2_004_1}    tshark_path=${tshark_path}
    ...    command_template=${F1AP_COMMAND}
    ${filter_expression}=    Catenate    (nr-rrc.sCellToAddModList == 1 && nr-rrc.drx_Config == 1) && (nr-rrc.rlc_BearerToAddModList == 3)
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
    ${nrofPorts}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.nrofPorts
    ${number of P8}=    get count    ${nrofPorts}    3
    should contain any    '${number of P8}'    1    2    4
    ${cdm_Type}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.cdm_Type
    should contain    ${cdm_Type}    2
    ${density}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.density
    should contain    ${density}    1
    ${n1-n2}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.n1_n2
    run keyword if    '${number of P8}'=='1'     should be true    '${n1-n2}[0]'=='2'
    run keyword if    '${number of P8}'=='2'     should be true    '${n1-n2}[0]'=='1'
    run keyword if    '${number of P8}'=='4'     should be true    '${n1-n2}[0]'=='1'
    ${drx_setup}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.drx_Config
    should contain    ${drx_setup}    1
    ${longpucch}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nr-rrc.format
    should contain    ${longpucch}    1
    should contain    ${longpucch}    3

get quaclomm username and pwd
    [Documentation]   Author: Liu Jia
    ${LKC_LOGIN_USER}    ${LKC_LOGIN_PWD}      read_qualcomm_usr
    set suite variable    ${LKC_LOGIN_USER}
    set suite variable    ${LKC_LOGIN_PWD}
