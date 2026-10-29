# *** Settings ***
# Documentation     author: deng xueqin
# ...               contact: xueqin.deng@nokia-sbell.com
# ...               squad group: 5G_PZ_MMW_HZ_2_SG
# Force Tags            
# ...    PY36
# Suite Setup       Test_suite_setup
# Suite Teardown    Test_suite_teardown
# 
# Resource          Resources/common_keyword.robot
# 
# *** Variables ***
# ${filter_expression}=    vlan.id == 295
# ${field_name}=    vlan.priority
# 
# *** Test Cases ***
# [1][1.0] 5GC000553-E_Prioritized_packet_classification_and_scheduling_MPLANE
#     [Documentation]    5GC000553-E_Prioritized_packet_classification_and_scheduling_MPLANE
#     [Tags]    CIT_22R2
#     [Setup]
#     Connect to ASIK via ssh    alias=DU
#     ${ru_log_path}    Collect RF Tcpdump Logs To TestPC    du_alias=DU
#     Verify MPlane L2 QoS Priority    pcap_file=${ru_log_path}
#     Delete Log Dir    log_dir=${ru_log_path}
#     [Teardown]
#     
# *** Keywords ***
# Test_suite_setup
#     Run Keyword And Ignore Error
#     ...    run    command=ps -ef | grep firefox | grep -v grep | awk '{print $2}' | xargs kill -9
#     Du Check cell on air via WebUI
#     
# Test_suite_teardown
#     #Du Check cell on air via WebUI
#     CI_interface.Common Case Teardown
