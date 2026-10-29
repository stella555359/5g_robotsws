# *** Settings ***
# Suite Setup          5GC001321-E CBRS Suite Setup    delta_file_trunk=${B3_deltplan_Trunk}    delta_file=${B3_deltplan}
# Suite Teardown       CBRS Suite Teardown
# Test Setup           CBRS Test Setup
# Test Teardown        CBRS Test Teardown
# 
# 
# Resource    ../Resources/5GC001321_E_ET_common_keywords.robot
# 
# 
# Documentation
# ...    Author:wangqingqing
# ...    contact:qingqing.wang@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature 5GC001321
# 
# Force Tags    SBTS00    CRT_23R1
# ...   PY36    CRT_TRUNK    CRT_UTE    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AZQC    STATE_SW_UPLOADED
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]5GC001321-E-B3_19_DP_switchover_is_triggered_by_fault6832_due_to_registrationResponse_timeout
#     [Tags]    CRT_TRUNK
#     5GC001321-E-B3_19_DP_switchover_is_triggered_by_fault6832_due_to_registrationResponse_timeout
# 
# [1]5GC001321-E-B3_5_DP_switchover_is_triggered_when_non_first_heartbeatResponse_with_91930000_and_long_transmitTimer
#     [Tags]    CRT_TRUNK
#     5GC001321-E-B3_5_DP_switchover_is_triggered_when_non_first_heartbeatResponse_with_91930000_and_long_transmitTimer
# 
# [1]5GC001321-E-B3_1_DP_switchover_is_triggered_when_registartionResponse_with_91930000
#     [Tags]    CRT_TRUNK
#     5GC001321-E-B3_1_DP_switchover_is_triggered_when_registartionResponse_with_91930000
