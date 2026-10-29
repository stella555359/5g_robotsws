# *** Settings ***
# Documentation     author: deng xueqin
# ...               contact: xueqin.deng@nokia-sbell.com
# ...               squad group: 5G_PZ_MMW_HZ_2_SG
# Force Tags        5G_RAN_TDD    STATE_GNB_NOT_COMMISSIONED   CLOUD_5G_ANDROID_ASOD_AEUB_ENB            master_pDU
# ...    PY36
# ...               RAN_5G    RAN_5G_TDD
# Suite Setup       Test_suite_setup
# Suite Teardown    Test_suite_teardown
# 
# Resource          Resources/common_keyword.robot
# 
# *** Variables ***
# ${filter_expression}=    vlan.id == 295
# ${field_name}=    vlan.priority
# ${testline_name}    null
# ${CONFIGURATION}    null
# 
# *** Test Cases ***
# [2][1.0] 5GC000553-E_Prioritized_packet_classification_and_scheduling_MPLANE
#     [Documentation]    5GC000553-E_Prioritized_packet_classification_and_scheduling_MPLANE
#     [Tags]    pDU22R2    CRT_UTE    5G_RAN    21B_pDU
#     [Setup]
#     #Connect to ASOD    alias=DU
#     Connect to ASIK via ssh    alias=DU
#     ${ru_log_path}    Collect RF Tcpdump Logs To TestPC    du_alias=DU
#     Verify MPlane L2 QoS Priority    pcap_file=${ru_log_path}
#     Delete Log Dir    log_dir=${ru_log_path}
#     [Teardown]
#     
# *** Keywords ***
# Test_suite_setup
#     CI_interface.Common Suite Setup
#     Du Check cell on air via WebUI
#     
# Test_suite_teardown
#     Du Check cell on air via WebUI
#     CI_interface.Common Case Teardown
