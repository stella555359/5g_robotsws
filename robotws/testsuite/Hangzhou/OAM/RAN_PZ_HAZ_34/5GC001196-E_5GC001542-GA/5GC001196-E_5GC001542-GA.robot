# *** Settings ***
# Documentation
# ...  author: Jiang Shengyuan
# 
# Resource   ./Resource/Common.robot
# Resource   ./../../../resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Library    ./../../../resources/RAN_PZ_HAZ_34/python/log.py
# 
# Test Timeout   1h
# 
# Suite Setup   Common Suite Setup
# Suite Teardown   Common Suite Teardown
# 
# Force Tags   SG_07   CA_5G_OAM    CRT_UTE   master_classicalbts_all
# ...   RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED
# ...   CLOUD_5G_CLASSICAL_ANDROID_SA_ASIMR_ABINB4_AHGD    SBTS00    CRT_UTE    PY36
# ...   AUTHOR_fred.li@nokia-sbell.com
# 
# Test Setup        Common Case Setup
# Test Teardown     Common Case Setup Teardown
# 
# 
# *** Variables ***
# 
# *** Test Cases ***
# 5GC001542-GA_Activate_internal_trace_unsucceeded
#    5GC001542-GA_Activate_internal_trace_-_unsucceeded
# 
# 5GC001542-GA_Reconfiguration_of_RCP_Provider_Controller
#    5GC001542-GA_Commission_Plan_with_productVariantPlanned_=_31_and_without_actInternalTrace_parameter
# 
# 5GC001542-GA_Deactivate_internal_trace_unsucceeded
#    5GC001542-GA_Deactivate_internal_trace_-_unsucceeded
# 
# *** Keywords ***
# Common Suite Setup
#    robot_common_operations.Common Suite Setup
#    Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
#     Set Suite Variable   ${MRBTS_ID}   ${tl.gnbs[0].instance_id}
#     Set Suite Variable   ${NRBTS_ID}   ${tl.gnbs[0].global_bts_id}
#     Set Suite Variable   ${MRBTS}   MRBTS-${MRBTS_ID}
#     Set Suite Variable   ${NRBTS}   NRBTS-${NRBTS_ID}
# 
# Common Suite Teardown
#     robot_common_operations.Common Suite Teardown
# 
# Common Case Setup
#    robot_common_operations.Common Case Setup
#     Run Keyword And Ignore Error   Start BTS Syslog Collection
# 
# Common Case Setup Teardown
#    robot_common_operations.Common Case Teardown
#     Run Keyword If Test Failed   Run Keywords   Run Keyword And Ignore Error   Stop BTS Syslog Collection
#     ...   AND   Run Keyword And Ignore Error   Save gNB Snapshot
#     Run Keyword If Test Passed   Remove Syslog From TestVM
