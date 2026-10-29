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
# ${pre-emption}           release-due-to-pre-emption
# ${wiresharklog_01}        wiresharklog_01
# ${wiresharklog_02}        wiresharklog_02
# ${wiresharklog_03}        wiresharklog_03
# ${wiresharklog_04}        wiresharklog_04
# ${APN2}                   wap1.nokia.com
# @{hpa_value}        ${1}    ${1}    ${1}    ${1}
# @{mps_value}        ${1}    ${1}    ${1}    ${1}
# @{ICS_mps}          ${1}    ${1}
# @{ICS_hpa}          ${1}    ${1}
# ${ra_P_MPS+MCS}     c0
# ${ra_P_MPS}         80
# ${ra_P_MCS}         40
# ${options}          -i any sctp -s 0
# ${HO_failure_expect}    no-radio-resources-available-in-target-cell
# ${ra_P_MPS+MCS}     c0
# ${cpif_log_04}    /home/ute/TAF/rebecca/wiresharklog_04.pcap
# ${APN1_trunk}       wap1
# ${APN1_23R1}        wap2
# ${drb-Identity_trunk}    drb-Identity: 7
# ${drb-Identity_23R1}     drb-Identity: 6
# 
# 
# *** Test Cases ***
# [1]CB008232_A_060_PDU_session_modification_success_with_APR_change_to_PA_range_by_CN
#     [Documentation]
#     ...    A-060 describes successful PDU Session Resource Modification procedure with at lease one QoS flow from the request has ARP priority
#     ...          from NRBTS.NRPRIOACC_PROFILE.arpPrioLevelHpaMin/Max range after modify
#     ...    A-057 describes PDU session resource setup procudure success scenario with maximumNumberOfDRBsPerDU DRB resource shortage when at
#     ...          lease one QoS flow from the request has ARP priority from NRBTS.NRPRIOACC_PROFILE.arpPrioLevelHpaMin/Max range, at least one
#     ...          PDU session has been already established
#     ...    RRC--applyPriorityAccess=HPA+MPS; ICS--5QI1and5QI5
#     ...    UE0----normal,wap1-NOT preemptable
#     ...    UE1----normal,Not preemptible
#     ...    UE2----MPS/MCS,Not preemptible
#     [Tags]     CRT_23R1    CRT_TRUNK
#     [Setup]    robot_common_operations.Common Case Setup
#     Set suite variable for 8232_A_060
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
#     Common Case TestLine Setup    ModifySCF_Aftercommission=True    #alarm_check=True
#     ...                           Modify_Para_Online=${${Modify_Para_Online}}
#     Common Case TestLine Setup    ModifySCF_Aftercommission=True    #alarm_check=True
#     ...                           Add_Para_Online=${A_060_ADD_Para}
#     NRCellid Set suit varaible    cellid=${${cellid}}
#     Adjust the GNB1CELL1 HBTE attenuation value
#     Adjust the GNB1CELL2 HBTE attenuation value
#     Adjust the GNB2CELL1 HBTE attenuation value
#     Adjust the ENB1CELL1 HBTE attenuation value
#     Adjust the ENB2CELL1 HBTE attenuation value
#     Switch APN to Test_need_APN    ${${target_APN1}}
# 
# step2 test procedures
#     ${cpif_log_01}=    Attach UE for 8232 test    wiresharklog=${wiresharklog_01}    ue_index=${0}    DL_PORT=${DL_PORT_1}
#     ${cpif_log_02}=    Attach UE for 8232 test    wiresharklog=${wiresharklog_02}    ue_index=${1}    ui_version=S21UI4.0    DL_PORT=${DL_PORT_2}
#     ${cpif_log_03}=    Attach UE for 8232 test    wiresharklog=${wiresharklog_03}    ue_index=${2}    ui_version=S21UI4.0    DL_PORT=${DL_PORT_3}
#     DL Tput collect and check with nrcellid    cellid=${nrcellid}    dlexpect_tp=${dlexpect_tp}[0]    duration=1m    ue_type=${ue_type}
#     Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog_04}    options=${options}    gnb_index=${0}
#     Make an EMC call dial 911 with adb    ue_index=${2}
#     sleep    20s
#     End a call on UE with adb    ue_index=${2}
#     ${cpif_log_04}    Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog_04}    target_dir=${epc_log_path}
#     DL Tput collect and check with nrcellid    cellid=${nrcellid}    dlexpect_tp=${dlexpect_tp}[0]    duration=1m    ue_type=${ue_type}
#     BuiltIn.Set Test Variable    ${cpif_log_01}
#     BuiltIn.Set Test Variable    ${cpif_log_02}
#     BuiltIn.Set Test Variable    ${cpif_log_03}
#     BuiltIn.Set Test Variable    ${cpif_log_04}
#     [Teardown]    Run keywords    Stop Traffic for 3UES with Power UE
#     ...    AND    Run Keyword And Ignore Error    UE Detach With Power UE for 3UES
# 
# 
# step3 case check point
#     Check 5QI1 and 5QI5 both exist    file_path=${cpif_log_04}    drb-Identity_value=${${drb-Identity_value}}
#     Check Call normal release    file_path=${cpif_log_04}
#     Check No_failure and reject MSG    file_path=${cpif_log_04}
# 
# 
# Case TearDown
#     8232 Case TearDown
