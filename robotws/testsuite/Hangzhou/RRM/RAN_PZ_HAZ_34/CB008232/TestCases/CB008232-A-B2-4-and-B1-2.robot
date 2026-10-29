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
# @{dlexpect_tp}           130    80
# ${MO_sig}                mo-Signalling
# ${MPS}                   mps-PriorityAccess
# ${HPA}                   highPriorityAccess
# ${EMC}                   emergency
# ${pre-emption}           release-due-to-pre-emption
# ${no-radio-resources}    no-radio-resources-available
# ${wiresharklog_01}        wiresharklog_01
# ${wiresharklog_02}        wiresharklog_02
# ${wiresharklog_03}        wiresharklog_03
# ${wiresharklog_04}        wiresharklog_04
# @{hpa_value}        ${1}    ${1}    ${1}    ${1}
# @{mps_value}        ${1}    ${1}    ${1}    ${1}
# @{ICS_mps}          ${2}    ${2}
# @{ICS_hpa}          ${2}    ${2}
# ${APN1_trunk}       wap1
# ${APN1_23R1}        wap2
# 
# *** Test Cases ***
# [1]CB008232_A_012_ICS_with_PDU_session_success_with_UE_context_reach_maxNumOfRrcCGRPSA
#     [Documentation]
#     ...    A-003 describes RRC connection setup can be successful with priority access cause when numOfRadioResReservForEmergency are not fully
#     ...          used with NRBTS.applyPriorityAccess = none
#     ...    A-012 describes Initial Context Setup with PDU session success scenario with UE Context resource shortage when at lease
#     ...          one QoS flow from the request has ARP priority from NRBTS.NRPRIOACC_PROFILE.arpPrioLevelHpaMin/Max but without UE context
#     ...          preemption candidate
#     ...    A-022 describes Initial Context Setup with PDU session success scenario with maxNumOfNonGBRBearersCGRPSA DRB resource shortage when
#     ...          at lease one QoS flow from the request has ARP priority from NRBTS.NRPRIOACC_PROFILE.arpPrioLevelHpaMin/Max range
#     ...    RRC--applyPriorityAccess=none;ICS--HPA is PA
#     ...    UE0----normal,dxdata1--To be preemptable
#     ...    UE2----MPS/MCS,Not preemptible
#     ...    UE1----HPA,Not preemptible
#     [Tags]     CRT_23R1    CRT_TRUNK
#     [Setup]    robot_common_operations.Common Case Setup
#     Set suite variable for 8232_A_012
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
#     Common Case TestLine Setup    ModifySCF_Aftercommission=True    alarm_check=True
#     ...                           Modify_Para_Online=${A_012_Modify_Online}
#     NRCellid Set suit varaible    cellid=${${cellid}}
#     Adjust the GNB1CELL1 HBTE attenuation value
#     Adjust the GNB1CELL2 HBTE attenuation value
#     Adjust the GNB2CELL1 HBTE attenuation value
#     Adjust the ENB1CELL1 HBTE attenuation value
#     Adjust the ENB2CELL1 HBTE attenuation value
#     Switch APN to Test_need_APN    target_APN=${${target_APN1}}
# 
# step2 test procedures
#     ${cpif_log_01}=    Attach UE for 8232 test    wiresharklog=${wiresharklog_01}    ue_index=${0}    DL_PORT=${DL_PORT_1}
#     ${cpif_log_02}=    Attach UE for 8232 test    wiresharklog=${wiresharklog_02}    ue_index=${2}    ui_version=S21UI4.0    DL_PORT=${DL_PORT_3}
#     ${cpif_log_03}=    Attach UE for 8232 test    wiresharklog=${wiresharklog_03}    ue_index=${1}    DL_PORT=${DL_PORT_2}
#     DL Tput collect and check with nrcellid    cellid=${nrcellid}    dlexpect_tp=${dlexpect_tp}[0]    duration=1m    ue_type=${ue_type}
#     UE Detach With Power UE Index    ue_index=${0}
#     ${cpif_log_04}=    Attach UE for 8232 test    wiresharklog=${wiresharklog_04}    ue_index=${0}    DL_PORT=${DL_PORT_1}    traffic_need=False
#     ...                                           Attach_status=False
#     BuiltIn.Set Test Variable    ${cpif_log_01}
#     BuiltIn.Set Test Variable    ${cpif_log_02}
#     BuiltIn.Set Test Variable    ${cpif_log_03}
#     BuiltIn.Set Test Variable    ${cpif_log_04}
#     DL Tput collect and check with nrcellid    cellid=${nrcellid}    dlexpect_tp=${dlexpect_tp}[1]    duration=1m    ue_type=${ue_type}
#     [Teardown]    Run keywords    Stop Traffic for 3UES with Power UE
#     ...    AND    Run Keyword And Ignore Error    UE Detach With Power UE for 3UES
# 
# 
# 
# step3 case check point
#     Check PM counter for 8232    counter_id=${counter_id_mps}    counter_dic_path=${counter_dic_path_mps_GNB1CELL1}
#     ...    counter_should_value=${mps_value}
#     Check PM counter for 8232    counter_id=${counter_id_hpa}    counter_dic_path=${counter_dic_path_hpa_GNB1CELL1}
#     ...    counter_should_value=${hpa_value}
#     Check PM counter for 8232    counter_id=${counter_id_ICS_mps}    counter_dic_path=${counter_dic_path_ICS_mps_GNB1CELL1}
#     ...                          counter_should_value=${ICS_mps}
#     Check PM counter for 8232    counter_id=${counter_id_ICS_hpa}    counter_dic_path=${counter_dic_path_ICS_hpa_GNB1CELL1}
#     ...                          counter_should_value=${ICS_hpa}
#     Check EstablishmentCause from RRC_Setup_Request    file_path=${cpif_log_01}    EstablishmentCause_value=${MO_sig}
#     Check EstablishmentCause from RRC_Setup_Request    file_path=${cpif_log_02}    EstablishmentCause_value=${MPS}
#     Check EstablishmentCause from RRC_Setup_Request    file_path=${cpif_log_03}    EstablishmentCause_value=${HPA}
#     Check RRC_Reject_Reason from RRC_Reject     file_path=${cpif_log_04}    RejectReason_value=${no-radio-resources}
# 
# 
# Case TearDown
#     8232 Case TearDown
