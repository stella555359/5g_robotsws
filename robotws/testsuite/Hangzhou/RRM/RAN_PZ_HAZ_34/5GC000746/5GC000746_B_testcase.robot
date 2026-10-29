# *** Settings ***
# Library    OperatingSystem
# Library    Collections
# Library    BuiltIn
# Library    String
# Resource    Resources/5GC000746_common_keyword.robot
# Variables    Resources/5GC000746_A_variables.py
# 
# Documentation
# ...   author: Chen Tong
# ...   contact: tong.chen@nokia-sbell.com
# ...   squad group: SG_02
# 
# Force Tags    5G_RRM      
# ...    PY36
# 
# Suite Setup     Suite preparation
# 
# *** Variables ***
# @{amfs}    feng_amf    han_amf    sui_amf    zhou_amf    liang_amf    tang_amf    chu_amf
# 
# *** Test Cases ***
# [1][1.0] 5GC000746_B_001_Verify PWS CANCEL REQUEST when actCMAS is set to false
#     [Tags]    case1    CIT_TRUNK    CIT_22R3    CIT_22R2    CIT_22R4
#     [Setup]    5GC000746 Case Setup
#     COAM Update several parameters via webUI    parameters_to_update_via_webui=${PARAM_746_DISABLE_CMAS}
#     ...                                         download_dir=${TS_CASE_LOG_PATH}
#     ...                                         is_need_to_check_validation_errors=${False}
#     ${ngap_log}    ${bip_log}    Trigger CMAS Notification and Capture Logs    amf=${current_amf}
#     ...                                         warning_area_list_id=&{warning_area_list}[warning_area_cgi_list_1cell]
#     Check Error Ind Message with Message Not Compatiable With Receiver State Cause    ngap_log=${ngap_log}    bip_log=${bip_log}
#     COAM Update several parameters via webUI    parameters_to_update_via_webui=${PARAM_746_ENABLE_CMAS}
#     ...                                         download_dir=${TS_CASE_LOG_PATH}
#     ...                                         is_need_to_check_validation_errors=${False}
#     [Teardown]    5GC000746 Case Teardown
# 
# [1][1.0] 5GC000746_B_005_Vierfy PWS CANCEL REQUEST with WarningAreaList not belong to the serving gNB
#     [Tags]    case5    CIT_TRUNK    CIT_22R3    CIT_22R2    CIT_22R4
#     [Setup]    5GC000746 Case Setup
#     Trigger CMAS Notification and Capture Logs    amf=${current_amf}
#     ...                                           warning_area_list_id=&{warning_area_list}[warnig_area_list_none]
#     ...                                           number_of_broadcasts_requested=${0}
#     ${ngap_log}    ${bip_log}    Trigger CMAS PWS Cancel and Capture Logs    amf=${current_amf}
#     ...                                              warning_area_list_id=&{warning_area_list}[warnig_area_list_none]
#     Check Complete Cancel Procedure in NGAP Log    ngap_log=${ngap_log}    amf=${current_amf}
#     ...                                            warningarealist_type=None
#     Check CMAS Broadcasting is Interrupted
#     Trigger CMAS Notification and Capture Logs    amf=${current_amf}
#     ...                                           warning_area_list_id=&{warning_area_list}[warning_area_cgi_list_1cell]
#     ...                                           number_of_broadcasts_requested=${0}
#     ${ngap_log}    ${bip_log}    Trigger CMAS PWS Cancel and Capture Logs    amf=${current_amf}
#     ...                                              warning_area_list_id=&{warning_area_list}[warning_area_cgi_list_2cell]
#     Check PWS Cancel Response without Broadcaset Cancelled Area List    ngap_log=${ngap_log}
#     ${ngap_log}    ${bip_log}    Trigger CMAS PWS Cancel and Capture Logs    amf=${current_amf}
#     ...                                              warning_area_list_id=&{warning_area_list}[warning_area_cgi_list_1cell]
#     Check Complete Cancel Procedure in NGAP Log    ngap_log=${ngap_log}    amf=${current_amf}
#     ...                                            warningarealist_type=None
#     Check CMAS Broadcasting is Interrupted
#     [Teardown]    5GC000746 Case Teardown
# 
# [1][1.0] 5GC000746_B_006_Verify multiple PWS CANCEL REQUEST concurrency
#     [Tags]    case6    CIT_TRUNK    CIT_22R3    CIT_22R2    CIT_22R4
#     [Setup]    5GC000746 Case Setup
#     ssh.Disconnect    connection=ASIK Master
#     COAM commission scf and wait cell setup    scf_file_path=${3amf_scf_path}
#     Connect to Common Unit Master
#     Connect to Common Unit Slave
#     FOR  ${item}    IN RANGE    2
#         ${ngap_log}    ${bip_log}    Trigger CMAS Notification and Capture Logs
#         ...                                         amf=${${amfs[${item}]}}
#         ...                                         warning_area_list_id=&{warning_area_list}[tai_warning_area_list]
#         ...                                         serial_number=${item}
#         ...                                         number_of_broadcasts_requested=${0}
#         Check Complete Procedure for CMAS broadcasting    ngap_log=${ngap_log}
#         ...                                               bip_log=${bip_log}
#         ...                                               serial_number=${item}
#         ...                                               number_of_broadcasts_requested=${0}
#         ${ngap_log}    ${bip_log}    Trigger CMAS PWS Cancel and Capture Logs    amf=${${amfs[${item}]}}
#         ...                                              warning_area_list_id=&{warning_area_list}[tai_warning_area_list]
#         ...                                              serial_number=${item}
#         Check Complete Cancel Procedure in NGAP Log    ngap_log=${ngap_log}
#         ...                                            amf=${${amfs[${item}]}}
#         ...                                            serial_number=${item}
#         ...                                            warningarealist_type=tailist
#         Check CMAS Broadcasting is Interrupted
#     END
#     [Teardown]    5GC000746 Case Teardown to Recover Configuration
# 
# [1][1.0] 5GC000746_B_008_Verify counter NNGCC_PWSCAN_RESP_SENT
#     [Tags]    case8    CIT_TRUNK    CIT_22R3    CIT_22R2    CIT_22R4
#     [Setup]    5GC000746 Case Setup
#     ssh.Disconnect    connection=ASIK Master
#     Perform BTS Site Reset
#     Sleep    5min
#     COAM Wait for gnb ready and cell setup    gnb_type='SA'
#     Connect to Common Unit Master
#     Connect to Common Unit Slave
#     FOR  ${item}  IN RANGE  51  56
#         Trigger CMAS Notification and Capture Logs    amf=${current_amf}
#         ...                                           warning_area_list_id=&{warning_area_list}[warning_area_cgi_list_1cell]
#         ...                                           serial_number=${item}
#         ...                                           number_of_broadcasts_requested=${0}
#     END
#     FOR  ${item}  IN RANGE  51  56
#         Trigger CMAS PWS Cancel and Capture Logs    amf=${current_amf}
#         ...                                         warning_area_list_id=&{warning_area_list}[warning_area_cgi_list_1cell]
#         ...                                         serial_number=${item}
#     END
#     Sleep    6min
#     ${cnt_list}    COAM Get BTS Counters via webUI    counter_id=&{COUNTERS_746[3]}[counter_id]
#     ${counter_sum}    Sum Value in Counter list    cnt_list=${cnt_list}
#     Should Be Equal    ${counter_sum}    ${5}
#     ${cnt_list}    COAM Get BTS Counters via webUI    counter_id=&{COUNTERS_746[4]}[counter_id]
#     ${counter_sum}    Sum Value in Counter list    cnt_list=${cnt_list}
#     Should Be Equal    ${counter_sum}    ${5}
#     [Teardown]    5GC000746 Case Teardown
