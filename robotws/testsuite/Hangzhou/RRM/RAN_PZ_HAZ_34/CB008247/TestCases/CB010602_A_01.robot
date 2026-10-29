*** Settings ***
Documentation      Author: jia-rebecca.liu@nokia-sbell.com
...                squad group: SG_03
...                feature : CB010602


Suite Setup       Run Keyword     Common Suite Setup for COAM 8247    ParamterToModify=${Lock_GNBCELL}
#
Suite Teardown          Run Keyword    Common Suite Teardown for COAM

Resource         ../Resources/CB008247_case_steps_SG3.robot



*** Variables ***
${10602_wireshark_01}              10602_wireshark_01
${B4003_wireshark_01}              B4003_wireshark_01
${B4003_wireshark_02}              B4003_wireshark_02
${C007_wireshark_01}               C007_wireshark_01
${dlexpect_tp_3741199999}               1100
${dl_tput_multiue_3741199999}           1300M
@{throughput_C007_3741199999}           860     500     100
${Gnb_cell_dist_3741199999}             MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
${physical_cellid_3741199999}           374
${allow_fault_list}                     6327

*** Test Cases ***
[1]CB010602A_01_B2_Single_UE_Beam_power_balance_rank4_8x4_UE_specific_CSIRS
    [Documentation]
    ...    Beam power balanced was extened to 8x4/4x4 and rank=3/4.L2PS will dynamic adjust pdsch power between two beams.
    ...    New counter was updated for Number of Beam Power Offset used for rank3 and rank4
    [Tags]     10602
    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=6327
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    step1 prepare the envrionment 10602
    step2 prepare UE and MCS 10602
    step3 test procedures 10602
    step4 case check point 10602
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Case TearDown    Modify_Para_Online=${ONLine_Recovery_10602_${MRBTS_ID}}

#[1]CB008247-5G-B#B4_003_power_control_verification_for_specific_CSIRS_frequency _multiplexing
#    [Documentation]
#    ...    B4_003:Purpose of this case is to validate power control of cell specific CSIRS frequency multiplexing
#    ...    with actCsirsMultiplexing enable.
#    ...    B4_001: Purpose of this case is to validate 4 cell specific CSIRS frequency multiplexing correct, can check it with 8247
#    ...    disable or use rdNumberOfUeCsirsSymbol=0 to trigger cell specific CSIRS allocation if 8247 enabled.
#    [Tags]     B4003
#    [Setup]
#    robot_common_operations.Common Case Setup
#    step1 prepare the envrionment B4003
#    step2 prepare UE and MCS B4003
#    step3 test procedures B4003
#    step4 case check point B4003
#    [Teardown]    Run Keywords
#    ...    robot_common_operations.Common Case Teardown    AND
#    ...    Case TearDown    Modify_Para_Online=${ONLine_Recovery_B4003_${MRBTS_ID}}

*** Keywords ***
step1 prepare the envrionment 10602
    [Arguments]

    Log to console    \n*** modify scf and commission ***
    Common Case TestLine Setup     ModifySCF_Aftercommission=True
    ...                            Modify_Para_Online=${ONLine_MODIFY_10602_${MRBTS_ID}}
#    ...                            Lock_ENB_Need=True
#    ...                            enb_dist_name=${enb_dist_LNCEL1_cellBarred}
#    ...                            enb_parameter=${enb_cellBarred}
#    ...                            enb_value=barred
    Check alarm and save snapshot     ALLOWED_FAULT=@{ALLOWED_FAULT_ID}    log_path=${epc_log_path}
#    ${params_dict}    Create Dictionary    actCsirsMultiplexing=${1}
    ${params_dict}    Create Dictionary    trsMCS=${9}    SslotMCS=${24}
    Connect to gnb coam via ssl
    ${new_scf_file_path}    COAM Download scf from cluster
    ${dl_expect_throughput_nrdim}    ${ul_expect_throughput}    nrdim.Get Theoretical Throughput
#    ...     scf_path=/opt/workspace/SCF/MRBTS-${MRBTS_ID}_${release_info}.xml    cell_id=${1}
    ...     scf_path=${new_scf_file_path}    cell_id=${37401}
    ...     mod_params=${params_dict}
    log to console    ${dl_expect_throughput_nrdim}
    Set Suite Variable      ${dl_expect_throughput_nrdim}
    ${pci_id}    Get physCellId from SCF    golden_scf_name=MRBTS-${MRBTS_ID}_${release_info}.xml    scf_path=/opt/workspace/SCF/
    ...                                     cell_index=${37401}
    Set Suite Variable    ${pci_id}
    sleep    180s

step2 prepare UE and MCS 10602
    [Arguments]
    ...            ${Test_PC_IP}=${tl.test_pc.default_ssh_connection_details.addr}
    ...            ${Test_PC_username}=${tl.test_pc.default_ssh_connection_details.username}
    ...            ${Test_PC_password}=${tl.test_pc.default_ssh_connection_details.password}
    Log to console    \n*** prepare MCS ***
    ${cprtPatternIdDict}     Get BeampatternIdDict From CPRT Logs new version    cell_idx=${37401}
    Set Test Variable    ${cprtPatternIdDict}
    NRCellid Set suit varaible    cellid=${2}
    MCS SETUP AND SET ATT 10602
    Prepare MultiUE with client
    Run Keyword And Ignore error    put btslog_ini file to ute
    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog

step3 test procedures 10602
    Log to console    \n*** attach ue and capture cpiflog ***
    ${cpif_log_10602}=    attach UE and capture wiresharklog with new way    wiresharklog=${10602_wireshark_01}
    Log to console    \n*** start traffic and capture biplog ***
    ${10602_bip_01}=    Start Traffic And Capture Biplog with new way    dlexpect_tp=${dl_expect_throughput_nrdim}
    ...                                                                  aa_sys_addr=${aa_sys_addr_${MRBTS_ID}}
    ...                                                                  dl_throughput=${dl_tput_multiue_${MRBTS_ID}}
    ...                                                                  duration=5m    target_avg_percent=0.98    min_percent=0.85
    ...                                                                  target_file_name=10602_bip_01
    ...                                                                  nr_phy_cell_ids=${physical_cellid_${MRBTS_ID}}
    Log to console    \n*** stop ue traffic and mcs teardown ***
    BuiltIn.Set Test Variable    ${10602_bip_01}
    BuiltIn.Set Test Variable    ${cpif_log_10602}
    [Teardown]    stop traffic and MCS teardown with new way         mcs_type=${mcs_type}

step4 case check point 10602
    Log to console    \n*** check point ***
    Check PM counter for 10602    counter_id=${counter_id_10602_Trunk}    counter_dic_path=${counter_dic_path_10602_Trunk}
    DFTBeam Should Be Used In BIP with mcshark    file_path=${10602_bip_01}
    Check PUSCH used DFT beam with mcshark    file_path=${10602_bip_01}
    Check CSIRS UE specific Used    file_path=${cpif_log_10602}
    Check bestbeampoweroffset    file_path=${10602_bip_01}
    ...                          pci_id=${pci_id}

MCS SETUP AND SET ATT 10602
    [Arguments]
    ${mcs_type}=    mcs_common.Get MCS Type
    set suite variable      ${mcs_type}
    Run keyword if    '${mcs_type}'=='haojin'    HAOJIN MCS SETUP AND SET ATT for ONE UE    mcs_type=${mcs_type}
    ...    vertical_distance=${2.1}   horizontal_distance=${0.5}
    ...    att_value_1=${25}     att_value_2=${30}
    ...    P1_out=${13}    P2_out=${14}    vertical_1=${96}    horizontal_1=${5}
    ...    P3_out=${15}    P4_out=${16}    vertical_2=${96}    horizontal_2=${15}
    Run keyword if    '${mcs_type}'=='hbte'      HBTE MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
    ...    vertical_distance=${2.1}   horizontal_distance=${0.5}
    ...    att_value1=${30}    att_value2=${35}    vertical_angle=${96}
    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${5}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${15}

####                          B4003                               ####
step1 prepare the envrionment B4003
    [Arguments]
    Log to console    step1-1 modify scf and commission
    Common Case TestLine Setup     ModifySCF_Aftercommission=True
    ...                            Modify_Para_Online=${ONLine_MODIFY_B4003_${MRBTS_ID}}
    ...                            Lock_ENB_Need=True
    ...                            enb_dist_name=${enb_dist_LNCEL1_cellBarred}
    ...                            enb_parameter=${enb_cellBarred}
    ...                            enb_value=barred
    Check alarm and save snapshot     ALLOWED_FAULT=@{ALLOWED_FAULT_ID}    log_path=${epc_log_path}
    sleep    180s
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}

step2 prepare UE and MCS B4003
    [Arguments]
#    ...            ${Test_PC_IP}=${tl.test_pc.default_ssh_connection_details.addr}
#    ...            ${Test_PC_username}=${tl.test_pc.default_ssh_connection_details.username}
#    ...            ${Test_PC_password}=${tl.test_pc.default_ssh_connection_details.password}
    Log to console    step2 prepare MCS
    ${cprtPatternIdDict}    Get BeampatternIdDict From CPRT Logs new version    cell_idx=${1}
    Set Test Variable    ${cprtPatternIdDict}
    NRCellid Set suit varaible    cellid=${1}
    MCS SETUP AND SET ATT B4003
    Prepare MultiUE with client
#    Run Keyword And Ignore error    put btslog_ini file to ute
#    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
#    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
#    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
#    ...      Test_PC_password=${Test_PC_password}
#    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
#    ...      btslog_launcher_path=/opt/btslog/btslog

step3 test procedures B4003
    Log to console    step3 test procedures
    Log to console    step3-1 attach ue and capture cpiflog for 1st time
    ${cpif_log_B4003_01}=    attach UE and capture wiresharklog with new way    wiresharklog=${B4003_wireshark_01}
    Log to console    step3-2 detach ue0
    Detach UE without traffic with new way
    Log to console    step3-3 modify ssPbchBlockPower from 10 to 15 online
    modify the parameters for case     parameters=${Modify_sspbchpower_${MRBTS_ID}}
    Check alarm and save snapshot     ALLOWED_FAULT=@{ALLOWED_FAULT_ID}    log_path=${epc_log_path}
    sleep    180s
    Log to console    step3-4 attach ue and capture cpiflog for 2nd time
    ${cpif_log_B4003_02}=    attach UE and capture wiresharklog with new way    wiresharklog=${B4003_wireshark_02}
    Log to console    step3-5 start ue traffic and capture biplog
    ${B4003_bip_01}=    Start Traffic And Capture Biplog with new way     dlexpect_tp=${dlexpect_tp_${MRBTS_ID}}
    ...                                                                   aa_sys_addr=${aa_sys_addr_${MRBTS_ID}}
    ...                                                                   dl_throughput=${dl_tput_multiue_${MRBTS_ID}}
    ...                                                                   target_file_name=B4003_bip_01
    Log to console    step3-6 stop ue traffic and mcs teardown
    BuiltIn.Set Test Variable    ${B4003_bip_01}
    BuiltIn.Set Test Variable    ${cpif_log_B4003_01}
    BuiltIn.Set Test Variable    ${cpif_log_B4003_02}
    [Teardown]    stop traffic and MCS teardown with new way         mcs_type=${mcs_type}

step4 case check point B4003
    Log to console    step4 start check point
    DFTBeam Should Be Used In BIP with mcshark    file_path=${B4003_bip_01}
    Check TAS SRS Is Used in RRC Message    file_path=${cpif_log_B4003_01}
    Check CodeBook SRS Is Used in RRC Message    file_path=${cpif_log_B4003_02}    srs_ResourceSet=2
    Check srsForBeamMgmt Is Same in SCF And RRC Message    file_path=${cpif_log_B4003_02}    cell_idx=${1}
    Check PUSCH used DFT beam with mcshark    file_path=${B4003_bip_01}
    Check CSIRS CELL specific Used    file_path=${cpif_log_B4003_02}
    Check CSI-RS nrofRBs changed after modify the sspbchpower B4003
    Check CELL Specific CSI-RS FDMed B4003

MCS SETUP AND SET ATT B4003
    [Arguments]
    ${mcs_type}=    mcs_common.Get MCS Type
    set suite variable      ${mcs_type}
    Run keyword if    '${mcs_type}'=='haojin'    HAOJIN MCS SETUP AND SET ATT for ONE UE    mcs_type=${mcs_type}
    ...    att_value_1=${25}     att_value_2=${25}
    ...    P1_out=${13}    P2_out=${14}    vertical_1=${96}    horizontal_1=${5}
    ...    P3_out=${15}    P4_out=${16}    vertical_2=${96}    horizontal_2=${15}
    Run keyword if    '${mcs_type}'=='hbte'      HBTE MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
    ...    vertical_distance=${2.0}   horizontal_distance=${0.5}
    ...    att_value1=${30}    att_value2=${30}    vertical_angle=${96}
    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${5}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${15}

Check CSI-RS nrofRBs changed after modify the sspbchpower B4003
    ${nrofRBs0}    Get CSI-RS nrofRBs from RRC Message    file_path=${cpif_log_B4003_01}    nrofPorts=3
    ...                                                   csirs_filter=nr-rrc.rrcReconfiguration_element
    ${nrofRBs1}    Get CSI-RS nrofRBs from RRC Message    file_path=${cpif_log_B4003_02}    nrofPorts=3
    ...                                                   csirs_filter=nr-rrc.rrcReconfiguration_element
    ${nrofRBs_before}      convert to number     ${nrofRBs0[0]}
    ${nrofRBs_after}       convert to number     ${nrofRBs1[0]}
    should be true     ${nrofRBs_before} > ${nrofRBs_after}

Check CELL Specific CSI-RS FDMed B4003
    ${CSIRS_FDomain_1}    Get CELL Spcific CSI-RS frequencyDomainAllocation    file_path=${cpif_log_B4003_02}    num=1
    ${CSIRS_FDomain_2}    Get CELL Spcific CSI-RS frequencyDomainAllocation    file_path=${cpif_log_B4003_02}    num=2
    ${CSIRS_FDomain_3}    Get CELL Spcific CSI-RS frequencyDomainAllocation    file_path=${cpif_log_B4003_02}    num=3
    ${CSIRS_FDomain_4}    Get CELL Spcific CSI-RS frequencyDomainAllocation    file_path=${cpif_log_B4003_02}    num=4
    ${CSIRS_TDomain_1}    Get CELL Specific CSI-RS TimeDomainAllocation    file_path=${cpif_log_B4003_02}    num=1
    ${CSIRS_TDomain_2}    Get CELL Specific CSI-RS TimeDomainAllocation    file_path=${cpif_log_B4003_02}    num=2
    ${CSIRS_TDomain_3}    Get CELL Specific CSI-RS TimeDomainAllocation    file_path=${cpif_log_B4003_02}    num=3
    ${CSIRS_TDomain_4}    Get CELL Specific CSI-RS TimeDomainAllocation    file_path=${cpif_log_B4003_02}    num=4
    Should Be True    '${CSIRS_FDomain_1[0]}' == '${CSIRS_FDomain_2[0]}'
    Should Be True    '${CSIRS_FDomain_3[0]}' == '${CSIRS_FDomain_4[0]}'
    Should Be True    '${CSIRS_TDomain_1[0]}' == '${CSIRS_TDomain_3[0]}'
    Should Be True    '${CSIRS_TDomain_2[0]}' == '${CSIRS_TDomain_4[0]}'


Case TearDown
    [Arguments]     ${gnb_list}=${gnb_list}    ${log_path}=${epc_log_path}
    ...     ${Modify_Para_Online}='NULL'
    Run Keyword And Ignore Error     Common Case TestLine Setup     ModifySCF_Aftercommission=True
    ...                                                             Modify_Para_Online=${Modify_Para_Online}
#    ...                                                             Lock_ENB_Need=True
#    ...                                                             enb_dist_name=${enb_dist_LNCEL1_cellBarred}
#    ...                                                             enb_parameter=${enb_cellBarred}
#    ...                                                             enb_value=notBarred
    Run Keyword And Ignore Error     stop traffic and detach UE
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure
    ...    COAM Save all gnb snapshot via api    gnb_list=${gnb_list}    log_path=${log_path}
#    Run Keyword And Ignore error    Stop BTSlogs Collection And Download Logs To Log Server
#    run keyword and continue on failure     Check ERR Or WRN From Syslog    sys_logs_path=${UTE_syslogs_path}
    Run keyword and ignore error    Tear down the all connections
    Run keyword and ignore error    CI_interface.Common Case Teardown

