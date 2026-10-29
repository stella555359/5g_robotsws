# *** Settings ***
# Documentation      Author: jia-rebecca.liu@nokia-sbell.com
# ...                squad group: SG_03
# ...                feature : CB008232
# 
# 
# Suite Setup         Run keywords
# ...    robot_common_operations.Common Suite Setup    AND
# ...    Run Keyword And Ignore Error       8232 Suite Setup
# 
# Suite Teardown      Run keywords
# ...    robot_common_operations.Common Suite Teardown    AND
# ...    Run Keyword And Ignore Error       Common Suite Teardown for COAM
# 
# 
# Resource         ../Resources/CB008232_keywords.robot
# 
# 
# *** Variables ***
# @{dlexpect_tp}           130    45   90
# ${MO_sig}                mo-Signalling
# ${MPS}                   mps-PriorityAccess
# ${HPA}                   highPriorityAccess
# ${pre-emption}           release-due-to-pre-emption
# ${wiresharklog_01}        wiresharklog_01
# ${wiresharklog_02}        wiresharklog_02
# ${wiresharklog_03}        wiresharklog_03
# ${APN2}                   wap1.nokia.com
# @{hpa_value}        ${1}    ${1}    ${1}    ${1}
# @{mps_value}        ${1}    ${1}    ${1}    ${1}
# @{ICS_mps}          ${2}    ${2}
# @{ICS_hpa}          ${2}    ${2}
# ${ra_P_MPS+MCS}     c0
# ${ra_P_MPS}         80
# ${ra_P_MCS}         40
# ${APN1_trunk}       wap1
# ${APN1_23R1}        wap2
# 
# 
# *** Test Cases ***
# [1]CB008232_A_052_ICS_with_PDU_session_success_with_UE_context_above_maxNumOfRrcSA_at_lease_one_Qos_flow_in_arpPrioLevelHpaMin-Max_range
#     [Documentation]
#     ...    A-002 describes RRC connection setup can be successful with priority access cause=MPS or MCS when only PA res
# ...ource headroom is available.
#     ...    A-004 describes RRC connection setup can be successful with priority access cause when numOfRadioResReservFor
# ...Emergency are not fully used
#     ...    A_010 describes Initial Context Setup with PDU session success scenario with UE Context resource shortage when at lease one QoS flow
#     ...          from the request has ARP priority from NRBTS.NRPRIOACC_PROFILE.arpPrioLevelHpaMin/Max but without UE context preemption candidate
#     ...    A-052 describes Initial Context Setup with PDU session success scenario with UE Context resource shortage
#     ...          when at least one QoS flow from the request has ARP priority from NRBTS.NRPRIOACC_PROFILE.arpPrioLevelHpaMin/Max range
#     ...    D-006 describes verification of SIB1 content for high priority UE, if UE supported, MPS UE can use power ramping step of
#     ...          powerRampingStepHighPriorityCbra at second/third... msg1
#     ...    D-009 describes verification of SIB1 content, PA UE can use different power ramping step at msg1 with aPrioritizationForAI = MPS+MCS
#     ...    D-010 describes verification of SIB1 content, PA UE can use different power ramping step at msg1 with aPrioritizationForAI = MCS
#     ...    A-021 describes Initial Context Setup with PDU session success scenario with DRB resource shortage when at lease one QoS flow from the
#     ...          request has ARP priority from NRBTS.NRPRIOACC_PROFILE.arpPrioLevelHpaMin/Max range
#     ...    A-025 describes Initial Context Setup with PDU session success scenario with DRB and GBR L2 pool limits when at lease one QoS flow from
#     ...          the request has ARP priority from NRBTS.NRPRIOACC_PROFILE.arpPrioLevelMpsMin/Max range
#     ...    RRC--applyPriorityAccess=MPS; ICS--MPS/MCS is PA
#     ...    UE0----normal,wap1/2-NOT preemptable
#     ...    UE1----HPA,Not preemptible
#     ...    UE2----MPS/MCS,Not preemptible
#     [Tags]     CRT_23R1    CRT_TRUNK
#     [Setup]    robot_common_operations.Common Case Setup
#     Set suite variable for 8232_A_052
#     step1 prepare the envrionment
#     step2 test procedures
#     step3 case check point
#     [Teardown]    Run Keywords
#     ...    robot_common_operations.Common Case Teardown    AND
#     ...    Case TearDown
# 
# 
# *** Keywords ***
# step1 prepare the envrionment
#     [Arguments]
#     # modify the NIDD numOfRadioResReservForPa=1 #
#     Common Case TestLine Setup    ModifySCF_Aftercommission=True    #alarm_check=True
#     ...                           Modify_Para_Online=${A_052_Modify_Online}
#     Common Case TestLine Setup    ModifySCF_Aftercommission=True    #alarm_check=True
#     ...                           Add_Para_Online=${A_052_ADD_Para}
#     NRCellid Set suit varaible    cellid=${${cellid}}
#     Adjust the GNB1CELL1 HBTE attenuation value
#     Adjust the GNB1CELL2 HBTE attenuation value
#     Adjust the GNB2CELL1 HBTE attenuation value
#     Adjust the ENB1CELL1 HBTE attenuation value
#     Adjust the ENB2CELL1 HBTE attenuation value
#     Switch APN to Test_need_APN    target_APN=${${target_APN1}}
# 
# step2 test procedures
#     # raPrioritizationForAI=MPS #
#     ${bip_log_01}=    Capture BIPlog with gnb_logs and Download     # MPS+MCS
#     Modify Parameters for Cases    Modify_Para_Online=${raPrio_Modify_MPS}
#     sleep    30s
#     ${bip_log_02}=    Capture BIPlog with gnb_logs and Download     # MPS
#     Modify Parameters for Cases    Modify_Para_Online=${raPrio_Modify_MCS}
#     sleep    30s
#     ${bip_log_03}=    Capture BIPlog with gnb_logs and Download     # MCS
#     sleep    30s
#     BuiltIn.Set Test Variable    ${bip_log_01}
#     BuiltIn.Set Test Variable    ${bip_log_02}
#     BuiltIn.Set Test Variable    ${bip_log_03}
#     ${cpif_log_01}=    Attach UE for 8232 test    wiresharklog=${wiresharklog_01}    ue_index=${0}    DL_PORT=${DL_PORT_1}
#     DL Tput collect and check with nrcellid    cellid=${nrcellid}    dlexpect_tp=${dlexpect_tp}[1]    duration=1m    ue_type=${ue_type}
#     ${cpif_log_02}=    Attach UE for 8232 test    wiresharklog=${wiresharklog_02}    ue_index=${1}    ui_version=S21UI4.0    DL_PORT=${DL_PORT_2}
#     DL Tput collect and check with nrcellid    cellid=${nrcellid}    dlexpect_tp=${dlexpect_tp}[2]    duration=1m    ue_type=${ue_type}
#     ${cpif_log_03}=    Attach UE for 8232 test    wiresharklog=${wiresharklog_03}    ue_index=${2}     DL_PORT=${DL_PORT_3}    ui_version=S21UI4.0
#     BuiltIn.Set Test Variable    ${cpif_log_01}
#     BuiltIn.Set Test Variable    ${cpif_log_02}
#     BuiltIn.Set Test Variable    ${cpif_log_03}
#     DL Tput collect and check with nrcellid    cellid=${nrcellid}    dlexpect_tp=${dlexpect_tp}[0]    duration=1m    ue_type=${ue_type}
#     [Teardown]    Run keywords    Stop Traffic for 3UES with Power UE
#     ...    AND    Run Keyword And Ignore Error    UE Detach With Power UE for 3UES
# 
# 
# step3 case check point
#     ##NIDD---miNrRRCD=5min##
#     Check PM counter for 8232    counter_id=${counter_id_hpa}    counter_dic_path=${counter_dic_path_hpa_GNB1CELL1}
#     ...                          counter_should_value=${hpa_value}
#     Check PM counter for 8232    counter_id=${counter_id_mps}    counter_dic_path=${counter_dic_path_mps_GNB1CELL1}
#     ...                          counter_should_value=${mps_value}
#     Check PM counter for 8232    counter_id=${counter_id_ICS_mps}    counter_dic_path=${counter_dic_path_ICS_mps_GNB1CELL1}
#     ...                          counter_should_value=${ICS_mps}
#     Check PM counter for 8232    counter_id=${counter_id_ICS_hpa}    counter_dic_path=${counter_dic_path_ICS_hpa_GNB1CELL1}
#     ...                          counter_should_value=${ICS_hpa}
#     Check EstablishmentCause from RRC_Setup_Request    file_path=${cpif_log_01}    EstablishmentCause_value=${MO_sig}
#     Check EstablishmentCause from RRC_Setup_Request    file_path=${cpif_log_02}    EstablishmentCause_value=${HPA}
#     Check EstablishmentCause from RRC_Setup_Request    file_path=${cpif_log_03}    EstablishmentCause_value=${MPS}
#     Check ra_Prio from BIP_SIB1    file_path=${bip_log_01}    ra_Prio_value=${ra_P_MPS+MCS}
#     Check ra_Prio from BIP_SIB1    file_path=${bip_log_02}    ra_Prio_value=${ra_P_MPS}
#     Check ra_Prio from BIP_SIB1    file_path=${bip_log_03}    ra_Prio_value=${ra_P_MCS}
# 
# 
# Case TearDown
#     8232 Case TearDown
