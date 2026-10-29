#*** Settings ***
#Documentation      Author: yue.1.gong@nokia-sbell.com     #jia-rebecca.liu@nokia-sbell.com
#...                squad group: SG_03
#...                feature : CB008247
#
#
#Suite Setup    Run Keywords
#...            Run Keyword And Ignore Error     Common Suite Setup for COAM 8247    AND
#...            Load SCF for each TL
#
#Suite Teardown      Run Keyword And Ignore Error     Common Suite Teardown for COAM
#
#
#Resource         ../Resources/CB008247_case_steps_SG3.robot
#
#
#
#*** Variables ***
##${golden_scf}                 MRBTS-354_8247_D_11.xml
##${golden_scf}                     gy_34711_GNB1.xml
#${swconfig_paths}             /opt/workspace/SCF/8247_swconfig/swconfig.txt
#${8247_wireshark_01}          8247_wireshark_01
#${ue_num}                     1
#${nrcellid}                   1
#${Expect_dl_enable}           200
#${tl_36011_scf_gnb1}    gy_36011_GNB1_8247_D11.xml
#${tl_34711_scf_gnb1}    gy_34711_GNB1_8247_D11.xml
#${tl_23311_scf_gnb1}    gy_23311_GNB1_8247_D11.xml
#${tl_36012_scf_gnb2}    gy_36012_GNB2.xml
#${tl_34712_scf_gnb2}    gy_34712_GNB2.xml
#${tl_23312_scf_gnb2}    gy_23312_GNB2.xml
#${enbx2_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-1
#${enb1_gnb1_x2_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-1
#${enb1_def_gnb_dist}     MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
#${enb_def_cell_para}     defaultLnRelGnbCellId
#${eNB_X2_ON_OFF}    administrativeState
#${x2_lock}    locked
#${x2_unloack}    unlocked
#@{BTSID}    36011    34711    23311
#${gnb_instance}     ${tl.gnbs[0].instance_id}
#${ue_type}    ${tl.ues[0].capabilities[0]}
#
#${att_ipaddr}      ${tl.attenuator[0].ip_addr}
#${att_port_1_}                ${tl.attenuator[0].attenuator_ports[1]}
#${att_port_2_}                ${tl.attenuator[0].attenuator_ports[2]}
#${att_port_3_}                ${tl.attenuator[0].attenuator_ports[3]}
#${att_port_4_}                ${tl.attenuator[0].attenuator_ports[4]}
#${att_port_5_}                ${tl.attenuator[0].attenuator_ports[5]}
#${att_port_6_}                ${tl.attenuator[0].attenuator_ports[6]}
#${att_port_7_}                ${tl.attenuator[0].attenuator_ports[7]}
#${att_port_8_}                ${tl.attenuator[0].attenuator_ports[8]}
#${att_port_9_}                ${tl.attenuator[0].attenuator_ports[9]}
#${att_port_10_}                ${tl.attenuator[0].attenuator_ports[10]}
#${att_port_11_}                ${tl.attenuator[0].attenuator_ports[11]}
#${att_port_12_}                ${tl.attenuator[0].attenuator_ports[12]}
#${att_port_13_}                ${tl.attenuator[0].attenuator_ports[13]}
#${att_port_14_}                ${tl.attenuator[0].attenuator_ports[14]}
#${att_port_15_}                ${tl.attenuator[0].attenuator_ports[15]}
#${att_port_16_}                ${tl.attenuator[0].attenuator_ports[16]}
#@{gnb_ips}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
#*** Test Cases ***
#[1]CB008247-D_11_IWK_with_CB007552_Multi_BWP
#    [Documentation]     This test case is to verify the inter-working between CB008247 and CB007552 multi-BWP.
#    ...    TAS SRS should not be configured to UE incapable of big BWP, while TAS SRS should be configured to UE capable of big BWP.
#    ...    Trunk-TL354, 70M--60M
#    [Tags]     CRT_23R1    CRT_TRUNK    CRT_22R4
#    [Setup]
#    robot_common_operations.Common Case Setup
#    Connect and Modify the ENB parameter    value=locked    dist_name=${enb1_gnb1_x2_dist}    parameter=${eNB_X2_ON_OFF}
#    Connect and Modify the ENB parameter    value=1    dist_name=${enb1_def_gnb_dist}    parameter=${enb_def_cell_para}
#    Online modify NIDD on gnb1 and gnb2    Modify_Para_Online=${Lock_gnb1_AMF1}
#    ...    ModifySCF_Aftercommission=True
#    Connect and Modify the ENB parameter    value=unlocked    dist_name=${enb1_gnb1_x2_dist}    parameter=${eNB_X2_ON_OFF}
#    Prepare the atten for each TL
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=S20UI2.5    power_reset=True
#    step3 test procedures
#    step4 case check point
#    [Teardown]    Run Keywords
#    ...    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}    AND
#    ...    Run Keyword And Ignore Error    Online modify NIDD on gnb1 and gnb2    Modify_Para_Online=${Unlock_gnb1_AMF1}
#    ...    ModifySCF_Aftercommission=True    AND
#    ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${0}    AND
#    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
#
#*** Keywords ***
#Load SCF for each TL
#    Run Keyword If    '${gnb_instance}' == '@{BTSID}[0]'
#    ...    Common Case TestLine Setup    is_commission=True    is_commission_for_second_gnb=False     Is_Swconfig=True
#    ...     golden_scf_name=${tl_36011_scf_gnb1}    golden_scf_name_gnb2=${tl_36012_scf_gnb2}
#    ...    swconfig_file=${swconfig_paths}    swconfig_modify=${SWCONFIG_SRS_DEBUG}
#    Run Keyword If    '${gnb_instance}' == '@{BTSID}[1]'
#    ...    Common Case TestLine Setup    is_commission=True    is_commission_for_second_gnb=False     Is_Swconfig=True
##    ...    Enb_commission=True   Enb_commission_For_ENB2=True    enb_scf=${T34721_SCF}    enb2_scf=${T34722_SCF}
#    ...     golden_scf_name=${tl_34711_scf_gnb1}    golden_scf_name_gnb2=${tl_34712_scf_gnb2}
#    ...    swconfig_file=${swconfig_paths}    swconfig_modify=${SWCONFIG_SRS_DEBUG}
#    Run Keyword If    '${gnb_instance}' == '@{BTSID}[2]'
#    ...    Common Case TestLine Setup    is_commission=True    is_commission_for_second_gnb=False     Is_Swconfig=True
#    ...     golden_scf_name=${tl_23311_scf_gnb1}    golden_scf_name_gnb2=${tl_23312_scf_gnb2}
#    ...    swconfig_file=${swconfig_paths}    swconfig_modify=${SWCONFIG_SRS_DEBUG}
#
#Prepare the atten for each TL
#    Run Keyword If    '${gnb_instance}' == '@{BTSID}[0]'
#    ...    Adjust the TL HBTE attenuation value    enb1_cell1_value=${0}   gnb1_cell1_value=${0}
#    Run Keyword If    '${gnb_instance}' == '@{BTSID}[1]'
#    ...    Adjust the TL HBTE attenuation value    enb1_cell1_value=${0}   gnb1_cell1_value=${0}
#    Run Keyword If    '${gnb_instance}' == '@{BTSID}[2]'
#    ...    Adjust the TL HBTE attenuation value    enb1_cell1_value=${0}   gnb1_cell1_value=${0}
#
#
#Adjust the TL HBTE attenuation value
#    [Arguments]    ${enb1_cell1_value}=${127}    ${enb2_cell1_value}=${127}    ${gnb1_cell1_value}=${127}
#    ...    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}
#    ####create cell list#####
#    @{att_ports_enb1_cell1}    Create List    ${att_port_1_}    ${att_port_2_}
#    @{att_ports_enb2_cell1}    Create List    ${att_port_3_}    ${att_port_4_}
#    @{att_ports_gnb1_cell1}    Create List    ${att_port_13_}    ${att_port_14_}
#    ...    ${att_port_15_}    ${att_port_16_}
#    @{att_ports_gnb1_cell2}    Create List    ${att_port_5_}    ${att_port_6_}
#    ...    ${att_port_7_}    ${att_port_8_}
#    @{att_ports_gnb2_cell1}    Create List    ${att_port_9_}    ${att_port_10_}
#    ...    ${att_port_11_}    ${att_port_12_}
#
#    ###create value list####
#    @{values_enb1_cell1}    Create List    ${enb1_cell1_value}    ${enb1_cell1_value}
#    @{values_enb2_cell1}    Create List    ${enb2_cell1_value}    ${enb2_cell1_value}
#    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
#    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
#    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}
#
#    ###Adjust the HBTE attenuation value###
#    Set the attenuation value    att_ports=${att_ports_enb1_cell1}    values=${values_enb1_cell1}
#    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}
#    Set the attenuation value    att_ports=${att_ports_enb2_cell1}    values=${values_enb2_cell1}
#    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}
#    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
#    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}
#    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
#    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}
#    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
#    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}
#
#
#
#Online modify NIDD on gnb1 and gnb2
#    [Arguments]    ${Modify_Para_Online}='NULL'    ${Modify_Para_Online_GNB2}='NULL'
#    ...    ${ModifySCF_Aftercommission}=False    ${ModifySCF_Aftercommission_for_GNB2}=False
#    Common Case TestLine Setup    ModifySCF_Aftercommission=${ModifySCF_Aftercommission}
#    ...    ModifySCF_Aftercommission_for_GNB2=${ModifySCF_Aftercommission_for_GNB2}
#    ...    Modify_Para_Online=${Modify_Para_Online}    Modify_Para_Online_GNB2=${Modify_Para_Online_GNB2}
#    sleep    5s
#
#step1 prepare the envrionment
#    [Arguments]
#    Log to console    step1-1 commission with AMF locked
#    Common Case TestLine Setup     is_commission=True     Is_Swconfig=True    gnb_type='NSA'    is_x2_check_from_gnb_needed=${True}
#    ...                            golden_scf_name=${golden_scf}      swconfig_file=${swconfig_paths}
#    ...                            swconfig_modify=${SWCONFIG_SRS_DEBUG}
#
#
#
##step2 prepare UE
##    [Arguments]        ${ue_index}=${0}        ue_type=${ue_type_1}
##    Log to console    step2 prepare UE
##    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    capatibility_index=${0}    reset_sol=pc_reset    detach_request=${true}
#
#
#step3 test procedures
#    [Arguments]
#    Log to console    step3-1 attach and capture cpiflog
#    ${cpif_log_01}=    Attach UE and capture wiresharklog     wiresharklog=${8247_wireshark_01}    #4g_check=true    ue_type=${ue_type}
#    Log to console    step3-2 detach UE
#    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
#    BuiltIn.Set Test Variable    ${cpif_log_01}
#
#
#Attach UE and capture wiresharklog
#    [Arguments]    ${wiresharklog}     #${4g_check}=${False}    ${ue_index}=${0}
#    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
#    sleep    5s
#    ${cpif_log_path}    Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog}
#    [Return]     ${cpif_log_path}
#
#
#
#step4 case check point
#    Log to console    step4 start check point
#    Check Aperiodic Codebook SRS used    file_path=${cpif_log_01}
#    Check CSIRS CELL specific Used    file_path=${cpif_log_01}
#    Check CSIRS nrofrb    file_path=${cpif_log_01}
#
#
#
#
#Check Aperiodic Codebook SRS used
#    [Arguments]    ${file_path}
#    ${Aperiodic_SRS}    Get Aperiodic SRS From CPIF Log    file_path=${file_path}
#    Should Contain    ${Aperiodic_SRS}    codebook
#
#
#Check CSIRS nrofrb
#    [Arguments]    ${file_path}
#    ${nrofrb}    Get CSI-RS nrofRBs from RRC Message    file_path=${file_path}    nrofPorts=3    csirs_filter=nr-rrc.rrcReconfiguration_element
#    Should Contain    ${nrofrb}    104
#
#
##Case TearDown
##    Run Keywords
##    ...    Run Keyword And Ignore Error     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}    AND
##    ...    Online modify NIDD on gnb1 and gnb2    Modify_Para_Online=${Unlock_gnb1_AMF1}
##    ...    ModifySCF_Aftercommission=True
#
