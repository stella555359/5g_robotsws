# *** Settings ***
# Documentation     author: meiya.cheng
# ...               contact: meiya.cheng@nokia-sbell.com
# ...               squad group: SG_07
# 
# Force Tags        SBTS22R1
# ...    PY36
# Library         OperatingSystem
# Library         Process
# Library         Collections
# Library         String
# Library         DateTime
# 
# 
# Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
# Resource        ../../../resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
# Resource        ../../../resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource        ../../../resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
# Resource        ./resources/common_1732.robot
# Resource        ../5GC001937_OTA/resources/5GC001937_AEWB.robot
# Resource        ../../../resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
# 
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
# 
# *** Variables ***
# 
# ${ultp}    10
# ${dltp}    100
# ${tshark_path}       /usr/bin/tshark
# ${luashark_path}    /home/ute/generated_luashark/luashark.lua
# ${log_namex2}       x2_AHAX.pcap
# ${pcap_path}        ${logPath}
# ${scf_timeout}     300
# #${LTEscf_path}     /home/ute/CB007608/2CC_TL334_lte_onair.xml
# ${x2_filter}     nr-rrc.measGapConfig == 1
# ${x2_check}    .//nr-rrc.measConfigMN_element//nr-rrc.measGapConfig
# ${x2_filter_release}     nr-rrc.drx_Config == 0
# ${x2_checkrelease}    .//nr-rrc.mac_CellGroupConfig_element//nr-rrc.drx_Config
# ${tl_scf_dir_path2}    /home/ute/CB007608/LTE_original_TL334.xml
# ${tl_scf_dir_path}    /home/ute/CB007608/2CC_TL334_lte_onair.xml
# ${enb_BTS}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
# *** Test Cases ***
# [1.0] 5GC002056_AHAX_1_Measurement_Gap_setup_during_SgNB_Modification_DRX_is_activated
#     [Documentation]    This user scenario describes the configuration of Measurement Gap (MG) during SgNB modification procedure.
# 	...              In this case DRX is configured.
#     [Tags]          SBTS22R1
#     [Setup]    SISO Coam Test Setup
#     Prepare with COAM classical enb cell onair
# 	Du login page via webUI
# 	Modify parameters in webui
# 	DU COAM selenium logout
# 	Start to collect X2log on eNB    log_name=${log_namex2}
#     ${list_of_cell_ids}    Create List    16385
#     step3: Prepare UE
#     Step4: UE Attach
# 	Stop and get X2Logs on eNB    log_name=${log_namex2}
# 	Check SgNBdrx in x2 log    pcap_file=${pcap_path}${/}${log_namex2}    filter=${x2_filter}
#     Check drxConfig in x2 log    pcap_file=${pcap_path}${/}${log_namex2}    filter=${x2_filter_release}
#     Cases Common teardown
# 	[Teardown]    run keywords    selenium logout and close browser    AND    SISO Coam Test Teardown
# 
# *** Keywords ***
# Restore LTE config
#     [Arguments]    ${enb_BTS}=${enb_BTS}    ${scf_file_path_enb2}=${tl_scf_dir_path2}
#     #Connect to gnb coam via ssl    connection=enblte    bts_host=${enb_BTS}
# 	Connect to eNB via ssl    connection=enblte
#     COAM Commission with scf file    scf_file_path=${scf_file_path_enb2}    timeout=600    connection=enblte
#     [Teardown]    COAM Teardown gnb connections    connection=enblte
# 
# Prepare with COAM classical enb cell onair
#     Perform full commission for COAM enb BTS
# 	sleep    120s
#     #Check the enb cell status onair
# 	#Check the enb cell onAir
# 
# Perform full commission for COAM enb BTS
#     [Arguments]    ${enb_BTS}=${enb_BTS}    ${scf_file_path_enb}=${tl_scf_dir_path}
#     #Connect to gnb coam via ssl    connection=enblte    bts_host=${enb_BTS}
# 	Connect to eNB via ssl    connection=enblte
#     COAM Commission with scf file    scf_file_path=${scf_file_path_enb}    timeout=600    connection=enblte
#     [Teardown]    COAM Teardown gnb connections    connection=enblte
# 
# Check the enb cell status onair
#     [Arguments]    ${enb_BTS}=${enb_BTS}
#     Connect to gnb coam via ssl    connection=enblte    bts_host=${enb_BTS}
#     wait until keyword succeeds    5min   30s    COAM Check GNB cell on air    connection=enblte
#     [Teardown]    COAM Teardown gnb connections    connection=enblte
# 
# Check SgNBdrx in x2 log
#     [Documentation]    Author: cheng meiya
#     ...                Description: Check SgNBdrx value in x2 log
#     [Arguments]    ${pcap_file}    ${filter}
#     ${filtered_packets}=    Load pcap with filter    pcap_file=${pcap_file}    filter_expression=${filter}
# 	${x2_result}=    Get field value by xpath    packets=${filtered_packets}    xpath=${x2_check}    attribute_name=show
# 	${length}    Get Length    ${x2_result}
#     :FOR    ${i}    IN RANGE    ${length}
#     \     Should be true    @{x2_result}[${i}] == 1
# 
# Check drxConfig in x2 log
#     [Documentation]    Author: cheng meiya
#     ...                Description: Check drxConfig value in x2 log
#     [Arguments]    ${pcap_file}    ${filter}
#     ${filtered_packets}=    Load pcap with filter    pcap_file=${pcap_file}    filter_expression=${filter}
# 	${x2_result}=    Get field value by xpath    packets=${filtered_packets}    xpath=${x2_checkrelease}    attribute_name=show
# 	${length}    Get Length    ${x2_result}
#     :FOR    ${i}    IN RANGE    ${length}
#     \     Should be true    @{x2_result}[${i}] == 0
# 
# 
# 
# Restore actCDrx in webui
#     [Documentation]  Author:meiya.cheng
#     ...              Description: restore actCDrx value
# 	${MRBTS_ID}=    Get MRBTS Id in COAM WebEM
# 	selenium_coam.set_parameter_value
#     ...    dist_name=${MRBTS_ID}/NRBTS-1/NRCELL-1
#     ...    abbr=actCDrx
#     ...    new_value=false
#     ...    filter_param=Activate connected DRX
#     sleep    1s
#     selenium_coam.validate_plan
#     sleep    8s
#     selenium_coam.activate_plan    activate_plan_despite_errors=True
# 
# Modify parameters in webui
#     [Documentation]  Author: meiya.cheng
#     ...              Description: modify actDlDataDmrsFdm value
# 	${MRBTS_ID}=    Get MRBTS Id in COAM WebEM
#     selenium_coam.set_parameter_value
#     ...    dist_name=${MRBTS_ID}/NRBTS-1/NRCELL-1
#     ...    abbr=enDcSyncStatus
#     ...    new_value=synchronous
#     ...    filter_param=EN-DC synchronization status indication
# 	selenium_coam.set_parameter_value
#     ...    dist_name=${MRBTS_ID}/NRBTS-1/NRCELL-1
#     ...    abbr=actCDrx
#     ...    new_value=true
#     ...    filter_param=Activate connected DRX
# 	selenium_coam.set_parameter_value
#     ...    dist_name=${MRBTS_ID}/NRBTS-1
#     ...    abbr=srb3SupportEnabled
#     ...    new_value=false
#     ...    filter_param=SRB3 Support Enabled
#     selenium_coam.validate_plan
#     selenium_coam.activate_plan    activate_plan_despite_errors=True
# 
# 
# 
# Cases Common teardown
#     [Documentation]    Author: meiya.cheng
#     ...                Description: case common teardown
# 	#Run Keyword And Ignore Error    Step7: Stop traffic
#     Run Keyword And Ignore Error    Step8: UE Detach
#     Du login page via webUI
# 	Restore actCDrx in webui
#     DU COAM selenium logout
# 	Restore LTE config
#     Run Keyword And Ignore Error    Delete log    log_file=${logPath}${/}*
# 
