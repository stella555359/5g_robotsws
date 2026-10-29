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
# @{dlexpect_tp}            40    80
# ${MO_sig}                 mo-Signalling
# ${MPS}                    mps-PriorityAccess
# ${HPA}                    highPriorityAccess
# ${pre-emption}            release-due-to-pre-emption
# ${no-radio-resources}     no-radio-resources-available
# ${ICS_no_resources}       radio-resources-not-available
# ${wiresharklog_A007_01}        wiresharklog_A007_01
# ${wiresharklog_A007_02}        wiresharklog_A007_02
# ${wiresharklog_A018_01}        wiresharklog_A018_01
# ${wiresharklog_A018_02}        wiresharklog_A018_02
# ${wiresharklog_A018_03}        wiresharklog_A018_03
# ${wiresharklog_A026_01}        wiresharklog_A026_01
# ${wiresharklog_A026_02}        wiresharklog_A026_02
# ${wiresharklog_A026_03}        wiresharklog_A026_03
# ${hpa_fail}               ${0}    ${0}
# @{hpa_value}              ${1}    ${1}    ${1}    ${1}
# @{mps_value}              ${1}    ${1}    ${1}    ${1}
# @{ICS_mps}                ${1}    ${1}
# @{ICS_hpa}                ${2}    ${2}
# ${APN1_trunk}       wap1
# ${APN1_23R1}        wap2
# 
# *** Test Cases ***
# [1]CB008232_A_007_RRC_Connection_Reject_with_ESTcause=HPA_and_applyPriorityAccess=MPS_or_MCS
#     [Documentation]
#     ...    A-007 describes RRC connection setup will be rejected with priority access cause is different to applyPriorityAccess when only
#     ...          numOfRadioResReservForPa resource are available
#     ...    A-005 describes RRC connection setup will be rejected with priority access cause when all the rrc resource are fully used
#     ...    A-006 describes RRC connection setup will be rejected with priority access cause is different to applyPriorityAccess when only
#     ...          numOfRadioResReservForPa resource are available
#     ...    A-008 describes RRC connection setup will be rejected with priority access cause when numOfRadioResReservForPa is fully used
#     ...    RRC--applyPriorityAccess=MPS
#     ...    UE2----MPS/MCS,Not preemptible
#     ...    UE1----HPA,Not preemptible,PA
#     [Tags]     CRT_23R1    CRT_TRUNK
#     [Setup]    robot_common_operations.Common Case Setup
#     Set suite variable for 8232_A_007
#     # modify the NIDD applyPriorityAccess=MPS;maxNumOfRrcConUEsPerDU=1; #
#     Common Case TestLine Setup    ModifySCF_Aftercommission=True    #alarm_check=True
#     ...                           Modify_Para_Online=${A_007_Modify_Online}
#     Common Case TestLine Setup    ModifySCF_Aftercommission=True    #alarm_check=True
#     ...                           Add_Para_Online=${A_007_ADD_Para}
#     Adjust the GNB1CELL1 HBTE attenuation value
#     Adjust the GNB1CELL2 HBTE attenuation value
#     Adjust the GNB2CELL1 HBTE attenuation value
#     Adjust the ENB1CELL1 HBTE attenuation value
#     Adjust the ENB2CELL1 HBTE attenuation value
#     sleep    10s
#     NRCellid Set suit varaible    cellid=${${cellid}}
#     ${cpif_log_01}=    Attach UE for 8232 test    wiresharklog=${wiresharklog_A007_01}    ue_index=${2}    ui_version=S2
# ...1UI4.0    DL_PORT=${DL_PORT_3}
#     ${cpif_log_02}=    Attach UE for 8232 test    wiresharklog=${wiresharklog_A007_02}    ue_index=${1}    DL_PORT=${DL_
# ...PORT_2}    traffic_need=False
#     ...                                           Attach_status=False
#     BuiltIn.Set Test Variable    ${cpif_log_01}
#     BuiltIn.Set Test Variable    ${cpif_log_02}
#     DL Tput collect and check with nrcellid    cellid=${nrcellid}    dlexpect_tp=${dlexpect_tp}[0]    duration=1m    ue_type=${ue_type}
#     Stop Traffic for 3UES with Power UE
#     UE Detach With Power UE for 3UES
#     ##NIDD---miNrRRCD=5min##
#     Check PM counter for 8232_failed case     counter_id=${counter_id_hpa_fail}    counter_should_value=${hpa_fail}
#     ...                           counter_dic_path=${counter_dic_path_hpa_fail_GNB1CELL1}
#     Check EstablishmentCause from RRC_Setup_Request    file_path=${cpif_log_01}    EstablishmentCause_value=${MPS}
#     Check EstablishmentCause from RRC_Setup_Request    file_path=${cpif_log_02}    EstablishmentCause_value=${HPA}
#     Check RRC_Reject_Reason from RRC_Reject    file_path=${cpif_log_02}    RejectReason_value=${no-radio-resources}
#     [Teardown]    Run Keywords
#     ...    robot_common_operations.Common Case Teardown    AND
#     ...    Case TearDown
# 
# 
# [1]CB008232_A_018_ICS_with_PDU_session_failure_with_UE_context_reach_maxNumOfRrcConUEsPerDU
#     [Documentation]
#     ...    A-018 describes Initial Context Setup with PDU session success scenario with UE Context resource shortage when none of the QoS flow
#     ...          from the request has ARP priority from NRBTS.NRPRIOACC_PROFILE.arpPrioLevelHpaMin/Max but without UE context preemption candidate
#     ...    A-053 describes Initial Context Setup with PDU session failure scenario with UE Context resource shortage when None of the QoS flow
#     ...          from the request has ARP priority from NRBTS.NRPRIOACC_PROFILE.arpPrioLevelHpaMin/Max range
#     ...    A-017 describes Initial Context Setup with PDU session failure scenario with UE Context resource shortage when none of the QoS flow
#     ...          from the request has ARP priority from NRBTS.NRPRIOACC_PROFILE.arpPrioLevelHpaMin/Max but without UE context preemption candidate
#     ...    RRC--applyPriorityAccess=HPA+MPS; ICS--HPA is PA
#     ...    UE0----normal,dxdata1-not preemptible
#     ...    UE2----MPS/MCS,Not preemptible
#     ...    UE1----HPA,Not preemptible,PA
#     [Tags]     CRT_23R1    CRT_TRUNK
#     [Setup]    robot_common_operations.Common Case Setup
#     Set suite variable for 8232_A_018
#     # modify the NIDD applyPriorityAccess=MPA+MPS;maxNumOfRrcConUEsPerDU=1; #
#     Common Case TestLine Setup    ModifySCF_Aftercommission=True    #alarm_check=True
#     ...                           Modify_Para_Online=${A_018_Modify_Online}
#     Common Case TestLine Setup    ModifySCF_Aftercommission=True    #alarm_check=True
#     ...                           Add_Para_Online=${A_018_ADD_Para}
#     Adjust the GNB1CELL1 HBTE attenuation value
#     Adjust the GNB1CELL2 HBTE attenuation value
#     Adjust the GNB2CELL1 HBTE attenuation value
#     Adjust the ENB1CELL1 HBTE attenuation value
#     Adjust the ENB2CELL1 HBTE attenuation value
#     Switch APN to Test_need_APN    target_APN=${${target_APN1}}
#     sleep    10s
#     NRCellid Set suit varaible    cellid=${${cellid}}
#     ${cpif_log_01}=    Attach UE for 8232 test    wiresharklog=${wiresharklog_A018_01}    ue_index=${0}    DL_PORT=${DL_PORT_1}
#     ${cpif_log_02}=    Attach UE for 8232 test    wiresharklog=${wiresharklog_A018_02}    ue_index=${2}    ui_version=S21UI4.0
#     ...                                              DL_PORT=${DL_PORT_3}
#     ${cpif_log_03}=    Attach UE for 8232 test    wiresharklog=${wiresharklog_A018_03}    ue_index=${1}    DL_PORT=${DL_
# ...PORT_2}    traffic_need=False
#     ...                                           Attach_status=False
#     BuiltIn.Set Test Variable    ${cpif_log_01}
#     BuiltIn.Set Test Variable    ${cpif_log_02}
#     BuiltIn.Set Test Variable    ${cpif_log_03}
#     DL Tput collect and check with nrcellid    cellid=${nrcellid}    dlexpect_tp=${dlexpect_tp}[1]    duration=1m    ue_type=${ue_type}
#     Stop Traffic for 3UES with Power UE
#     UE Detach With Power UE for 3UES
#     ##NIDD---miNrRRCD=5min##
#     Check PM counter for 8232    counter_id=${counter_id_mps}    counter_dic_path=${counter_dic_path_mps_GNB1CELL1}
#     ...    counter_should_value=${mps_value}
#     Check PM counter for 8232    counter_id=${counter_id_ICS_mps}    counter_dic_path=${counter_dic_path_ICS_mps_GNB1CELL1}
#     ...                          counter_should_value=${ICS_mps}
#     Check EstablishmentCause from RRC_Setup_Request    file_path=${cpif_log_01}    EstablishmentCause_value=${MO_sig}
#     Check EstablishmentCause from RRC_Setup_Request    file_path=${cpif_log_02}    EstablishmentCause_value=${MPS}
#     Check EstablishmentCause from RRC_Setup_Request    file_path=${cpif_log_03}    EstablishmentCause_value=${HPA}
#     Check Failure_Reason from InitialContextSetup    file_path=${cpif_log_03}    Failure_Reason_value=${ICS_no_resources}
#     Get normal_release from rrc_release     file_path=${cpif_log_03}
#     [Teardown]    Run Keywords
#     ...    robot_common_operations.Common Case Teardown    AND
#     ...    Case TearDown
# 
# 
# [1]CB008232_A_026_ICS_with_PDU_session_failure_with_DRBs_above_limitation_and_none_of_QoS_flow_in_arpPrioLevelMpsMin-Max_range
#     [Documentation]
#     ...    A-026 describes Initial Context Setup with PDU session failure scenario with DRB resource shortage when no one QoS flow from the request
#     ...          has ARP priority from NRBTS.NRPRIOACC_PROFILE.arpPrioLevelHpaMin/Max range, there is UE context preemption candidate can be found.
#     [Tags]     CRT_23R1    CRT_TRUNK
#     [Setup]    robot_common_operations.Common Case Setup
#     Set suite variable for 8232_A_026
#     Common Case TestLine Setup    ModifySCF_Aftercommission=True    alarm_check=True
#     ...                           Modify_Para_Online=${A_026_Modify_Online}
#     Common Case TestLine Setup    ModifySCF_Aftercommission=True    alarm_check=True
#     ...                           Add_Para_Online=${A_026_ADD_Para}
#     Adjust the GNB1CELL1 HBTE attenuation value
#     Adjust the GNB1CELL2 HBTE attenuation value
#     Adjust the GNB2CELL1 HBTE attenuation value
#     Adjust the ENB1CELL1 HBTE attenuation value
#     Adjust the ENB2CELL1 HBTE attenuation value
#     Switch APN to Test_need_APN    target_APN=${${target_APN1}}
#     sleep    10s
#     NRCellid Set suit varaible    cellid=${${cellid}}
#     ${cpif_log_01}=    Attach UE for 8232 test    wiresharklog=${wiresharklog_A026_01}    ue_index=${0}    DL_PORT=${DL_PORT_1}
#     ${cpif_log_02}=    Attach UE for 8232 test    wiresharklog=${wiresharklog_A026_02}    ue_index=${1}    DL_PORT=${DL_PORT_2}
#     ${cpif_log_03}=    Attach UE for 8232 test    wiresharklog=${wiresharklog_A026_03}    ue_index=${2}    ui_version=S21UI4.0
#     ...                                           DL_PORT=${DL_PORT_3}    traffic_need=False     Attach_status=False
#     BuiltIn.Set Test Variable    ${cpif_log_01}
#     BuiltIn.Set Test Variable    ${cpif_log_02}
#     BuiltIn.Set Test Variable    ${cpif_log_03}
#     DL Tput collect and check with nrcellid    cellid=${nrcellid}    dlexpect_tp=${dlexpect_tp}[1]    duration=1m    ue_type=${ue_type}
#     Stop Traffic for 3UES with Power UE
#     UE Detach With Power UE for 3UES
#     ##NIDD---miNrRRCD=5min##
#     Check counter for counter_id_hpa
#     Check counter for counter_id_ICS_hpa
#     Check EstablishmentCause from RRC_Setup_Request    file_path=${cpif_log_01}    EstablishmentCause_value=${MO_sig}
#     Check EstablishmentCause from RRC_Setup_Request    file_path=${cpif_log_02}    EstablishmentCause_value=${HPA}
#     Check Failure_Reason from InitialContextSetup    file_path=${cpif_log_03}    Failure_Reason_value=${ICS_no_resources}
#     Get normal_release from rrc_release     file_path=${cpif_log_03}
#     [Teardown]    Run Keywords
#     ...    robot_common_operations.Common Case Teardown    AND
#     ...    Case TearDown
# 
# *** Keywords ***
# 
# 
# Case TearDown
#     Run Keyword And Ignore Error     Stop Traffic for 3UES with Power UE
#     Run Keyword And Ignore Error     UE Detach With Power UE for 3UES
#     8232 Case TearDown_
# 
# Check counter for counter_id_hpa
#     [Arguments]   ${gnb_index}=${0}   ${du_index}=${0}    ${common_unit_index}=${0}     ${connection}==du_coam
#     ${var_status}    ${var_dict}    run keyword and ignore error    CI_commssion._Set Variables For Test
#     ...    gnb_index=${gnb_index}   du_index=${du_index}    common_unit_index=${common_unit_index}
#     Run Keyword If    '&{var_dict}[stream]' == 'SBTS00'    Check PM counter for 8232    counter_id=${counter_id_hpa}
#     ...    counter_dic_path=${counter_dic_path_hpa_GNB1CELL1_trunk}    counter_should_value=${hpa_value}
#     ...    ELSE    Check PM counter for 8232    counter_id=${counter_id_hpa}    counter_dic_path=${counter_dic_path_hpa_GNB1CELL1}
#     ...    counter_should_value=${hpa_value}
# 
# Check counter for counter_id_ICS_hpa
#     [Arguments]   ${gnb_index}=${0}   ${du_index}=${0}    ${common_unit_index}=${0}     ${connection}==du_coam
#     ${var_status}    ${var_dict}    run keyword and ignore error    CI_commssion._Set Variables For Test
#     ...    gnb_index=${gnb_index}   du_index=${du_index}    common_unit_index=${common_unit_index}
#     Run Keyword If    '&{var_dict}[stream]' == 'SBTS00'    Check PM counter for 8232    counter_id=${counter_id_ICS_hpa}
#     ...    counter_dic_path=${counter_dic_path_ICS_hpa_GNB1CELL1_trunk}    counter_should_value=${ICS_hpa}
#     ...    ELSE    Check PM counter for 8232    counter_id=${counter_id_ICS_hpa}
#     ...    counter_dic_path=${counter_dic_path_ICS_hpa_GNB1CELL1}    counter_should_value=${ICS_hpa}