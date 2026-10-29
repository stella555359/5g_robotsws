# *** Settings ***
# Documentation
# ...    author: y6lu
# ...    contact: lu.yu@nokia-sbell.com
# ...    Description:
# 
# 
# Resource          ./Resources/CNI85020_Common_KW.robot
# 
# Suite Setup    robot_common_operations.Common Suite Setup
# Suite Teardown    robot_common_operations.Common Suite Teardown
# 
# Force Tags
# Test Timeout
# 
# Resource    ../common/taf_coam.robot
# *** Variables ***
# ${WEBUI_ADDR}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
# ${WEBUI_USER}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
# 
# #${ul}    [BBMOD_R-1(ABIN)] [PCI: 112]NRCELL-2: Subcell 1
# #${dl}    [BBMOD_R-1(ABIN)] [PCI: 112]NRCELL-2: Subcell 1
# #
# #${BBMOD}   BBMOD_R-1(ABIN)
# ${NRBTS_ID}           ${tl.gnbs[0].global_bts_id}
# 
# ###L3 Call###
# ${UE_TYPE}    ${tl.ues[0].capabilities[-1]}
# ${attach_mode}    5G_SA
# ${nettype}    SA+NSA
# ${UE_MODE}    SA
# ${apn_address}    wap2.nokia.com
# ${data_tranfer}     20Mbits/sec
# *** Test Cases ***
# [1]CNI-85020_21_Loner_Start and stop parallel L1-L2 Mirroring via webEM
#     [Tags]
#     [Documentation]    *****************
#     ...    The purpose of this test case is to verify that Activate and deactivate collect BIP log along with
#     ...    event trigger IQ snapshot via webEM.
#     ...    *******************
#     [Setup]    Precondition
#     #[Teardown]    Teardown
# 	@{ul}    Create List    [BBMOD_R-1(ABIL)] [PCI: 81][N71-1]NRCELL-1: Subcell 0
# 	@{dl}    Create List    [BBMOD_R-1(ABIL)] [PCI: 81][N71-1]NRCELL-1: Subcell 0
#     Start Parallel L1-L2 Mirroring From WEBUI    ul=@{ul}    dl=@{dl}
#     sleep    10s
# 
# [1]CNI-85020_23_Loner_Stop log collection via webEM
#     [Tags]
#     [Documentation]    *****************
#     ...    The purpose of this test case is to verify that Stop log collection after event trigger via webEM.
#     ...    *******************
#     [Setup]
#     Stop BIP Log
# 
# [1]CNI-85020_24_Loner_Update capture config via CLI
#     [Tags]
#     [Documentation]    *****************
#     ...    The purpose of this test case is to verify that Update capture config via CLI.
#     ...    *******************
#     [Setup]
#     [Teardown]    Run Keywords    Teardown    AND    stop traffic and ue detach
#     Collect Snapshot To Clear Event Alarm
#     Config Loner Event RAD parameter
# 	#@{ul}    Create List    [BBMOD_R-1(ABIL)] [PCI: 81][N71-1]NRCELL-1: Subcell 0
# 	#@{dl}    Create List    [BBMOD_R-1(ABIL)] [PCI: 81][N71-1]NRCELL-1: Subcell 0
#     Start Parallel L1-L2 Mirroring From cli    subcellId=${0}    nrcellId=${1}
#     Make L3 Call To Trigger Alarm
#     check Log
# 
# *** Keywords ***
# Config Loner Event RAD parameter
#     csn.Connect to   hostname=${asib_addr}   username=${asib_username}   password=${asib_password}    alias=gnb
#     ${trigger_type}   csn.execute   command=bsh 2:2 confmgmtbrowser write l1sw_trbl l1_event_trigger_type${SPACE}1
#     ...   connection=gnb
#     ${check_trigger_type}   csn.execute   command=bsh 2:2 confmgmtbrowser read l1sw_trbl l1_event_trigger_type
#     ...   connection=gnb
#     ${prach_preamble_detection_enabled}   csn.execute   command=bsh 2:2 confmgmtbrowser write LonerNrTrbl prach_preamble_detection_enabled${SPACE}1
#     ...   connection=gnb
#     ${check_prach_preamble_detection_enabled}   csn.execute   command=bsh 2:2 confmgmtbrowser read LonerNrTrbl prach_preamble_detection_enabled
#     ...   connection=gnb
#     ${prach_peak_metric}   csn.execute   command=bsh 2:2 confmgmtbrowser write LonerNrTrbl prach_peak_metric${SPACE}1.0
#     ...   connection=gnb
#     ${check_prach_peak_metric}   csn.execute   command=bsh 2:2 confmgmtbrowser read LonerNrTrbl prach_peak_metric
#     ...   connection=gnb
#     ${trigger_delay}   csn.execute   command=bsh 2:2 confmgmtbrowser write LonerNrTrbl trigger_delay${SPACE}20
#     ...   connection=gnb
#     ${check_trigger_delay}   csn.execute   command=bsh 2:2 confmgmtbrowser read LonerNrTrbl trigger_delay
#     ...   connection=gnb
#     [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=gnb
# 
# Make L3 Call To Trigger Alarm
#     Make Spark Attach
#     Wait Until Keyword Succeeds    3min    30s    Check FID:6450 Raised
# 
# check Log
#     Local Collect snapshot coam And Check
# 
# Collect Snapshot To Clear Event Alarm
#     admin_cli.disable_uplane_l1_iq_capture    connection=${connection}
#     ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
#     ${local_file_path}   Set Variable    ${OUTPUT_DIR}/snapshot_coam_${curr_data}.zip
#     Run Keyword And Ignore Error   admin_cli.collect_snapshot   target_file_name=${local_file_path}   timeout=${2100}   connection=${connection}
#     sleep    30s
#     Check FID:6450 not Exist
# 
# Check FID:${FID} not Exist
#     ${FID}    Convert To Integer    ${FID}
#     @{fault_list}    create list
#     ${active_alarms}    admin_cli.get_active_alarms    connection=${connection}
#     FOR    ${alarms}    IN    @{active_alarms}
#         Append To List    ${fault_list}    &{alarms}[additionalFaultID]
#     END
#     should not contain    ${fault_list}    ${FID}
