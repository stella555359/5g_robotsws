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
# @{dlexpect_tp}           80    40
# ${MO_sig}                mo-Signalling
# ${MPS}                   mps-PriorityAccess
# ${HPA}                   highPriorityAccess
# ${pre-emption}           release-due-to-pre-emption
# ${wiresharklog_01}        wiresharklog_01
# ${wiresharklog_02}        wiresharklog_02
# ${wiresharklog_03}        wiresharklog_03
# ${wiresharklog_04}        wiresharklog_04
# ${wiresharklog_05}        wiresharklog_05
# ${wiresharklog_06}        wiresharklog_06
# ${wiresharklog_07}        wiresharklog_07
# ${APN2}                   wap1.nokia.com
# @{hpa_value}        ${1}    ${1}    ${1}    ${1}
# @{mps_value}        ${1}    ${1}    ${1}    ${1}
# @{ICS_mps}          ${1}    ${1}
# @{ICS_hpa}          ${1}    ${1}
# ${ra_P_MPS+MCS}     c0
# ${ra_P_MPS}         80
# ${ra_P_MCS}         40
# ${options}          -i any sctp -s 0
# ${ra_P_MPS+MCS}     c0
# ${ICS_no_resources}     radio-resources-not-available
# 
# ${cpif_log_04}    /home/ute/TAF/rebecca/wiresharklog_04/wiresharklog_04.pcap
# ${cpif_log_05}    /home/ute/TAF/rebecca/wiresharklog_05/wiresharklog_05.pcap
# ${APN1_trunk}       wap1
# ${APN1_23R1}        wap2
# ${phone_number_trunk}    13100010725
# ${phone_number_23R1}     13100012393
# 
# *** Test Cases ***
# [1]CB008232_B_003_Priority_Callback_for_PA_followed_by_InitialContextSetupRequest
#     [Documentation]
#     ...    B-003 describes the gNB behavior for priority callback for Priority Access when RAC limites for UE context resource shortage
#     ...    B-001 describes the gNB behavior for priority callback for Priority Access when RAC limites for normal RRC
#     ...    B-004 describes the gNB behavior for priority callback for Priority Access when RAC limites for UE context resource shortage
#     ...    B-006 describes the gNB behavior failure for priority callback for Priority Access when RAC limites for normal RRC
#     ...    RRC--applyPriorityAccess=HPA; ICS--HPA is PA
#     ...    UE0----normal,wap1-NOT preemptable
#     ...    UE1----HPA,Not preemptible
#     ...    UE2----MPS/MCS,Not preemptible
#     [Tags]     CRT_23R1    CRT_TRUNK
#     [Setup]    robot_common_operations.Common Case Setup
#     Set suite variable for 8232_B_003
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
#     ...                           Modify_Para_Online=${B_003_Modify_Online}
#     ...                           Add_Para_Online=${B_003_ADD_Para}
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
#     ${cpif_log_02}=    Attach UE for 8232 test    wiresharklog=${wiresharklog_02}    ue_index=${2}    ui_version=S21UI4.0    DL_PORT=${DL_PORT_2}
#     ${cpif_log_03}=    Attach UE for 8232 test    wiresharklog=${wiresharklog_03}    ue_index=${1}    ui_version=S21UI4.0    DL_PORT=${DL_PORT_3}
#     ...                                           traffic_need=False
#     DL Tput collect and check with nrcellid    cellid=${nrcellid}    dlexpect_tp=${dlexpect_tp}[0]    duration=1m    ue_type=${ue_type}
#     Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog_04}    options=${options}    gnb_index=${0}
#     Disable Moble_data with adb    ue_index=${1}
#     Sleep    120s
#     Make a VoNR call to another UE    phone_number=${${phone_number}}
#     ${cpif_log_04}    Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog_04}    target_dir=${epc_log_path}
#     DL Tput collect and check with nrcellid    cellid=${nrcellid}    dlexpect_tp=${dlexpect_tp}[0]    duration=1m    ue_type=${ue_type}
#     UE Detach With Power UE Index    ue_index=${1}
#     sleep    5s
#     Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog_05}    options=${options}    gnb_index=${0}
#     UE Attach With Power UE Index    ue_index=${1}
#     sleep    5s
#     Disable Moble_data with adb    ue_index=${1}
#     Common Case TestLine Setup    ModifySCF_Aftercommission=True
#     ...                           Modify_Para_Online=${B_003_Falure_Para}
#     sleep    120s
#     Make a VoNR call with adb    ue_index=${2}    phone_number=${${phone_number}}
#     sleep    10s
#     ${cpif_log_05}    Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog_05}    target_dir=${epc_log_path}
#     Check idle status    file_path=${cpif_log_04}
#     Check idle status    file_path=${cpif_log_05}
#     BuiltIn.Set Test Variable    ${cpif_log_01}
#     BuiltIn.Set Test Variable    ${cpif_log_02}
#     BuiltIn.Set Test Variable    ${cpif_log_03}
#     BuiltIn.Set Test Variable    ${cpif_log_04}
#     BuiltIn.Set Test Variable    ${cpif_log_05}
#     DL Tput collect and check with nrcellid    cellid=${nrcellid}    dlexpect_tp=${dlexpect_tp}[0]    duration=1m    ue_type=${ue_type}
#     [Teardown]    Run keywords    Stop Traffic for 3UES with Power UE
#     ...    AND    Enable Moble_data with adb    ue_index=${1}
#     ...    AND    Run Keyword And Ignore Error    UE Detach With Power UE for 3UES
# 
# 
# step3 case check point
#     Check Failure_Reason from InitialContextSetup    file_path=${cpif_log_05}    Failure_Reason_value=${ICS_no_resources}
#     Check VONR call success    file_path=${cpif_log_04}
#     Check VONR call failure    file_path=${cpif_log_05}
# 
# 
# 
# Check VONR call failure
#     [Arguments]    ${file_path}
#     ${5QI_1}=    Run Keyword And Return Status    Get 5QI_value from pdusession    file_path=${file_path}
#     Should Be True    '${5QI_1}'     'False'
# 
# Check VONR call success
#     [Arguments]    ${file_path}
#     ${5QI_1}=    Get 5QI1_value from pdusession    file_path=${file_path}    pdusession_element=(ngap.procedureCode == 26 && ngap.fiveQI ==1)
#     ${5QI_5}=    Get 5QI_value from pdusession    file_path=${file_path}    pdusession_element=ngap.PDUSessionResourceSetupRequestTransfer_element
#     Should Be True    '${5QI_1[0]}' == '${1}' and '${5QI_5[0]}' == '${5}'
# 
# Case TearDown
#     8232 Case TearDown
