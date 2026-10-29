# *** Settings ***
# Suite Setup          Run Keywords     CBRS Suite Setup    UTECloud=${True}  AND  Case Preparation for CB008498 enable CA
# Suite Teardown       CBRS Suite Teardown
# Test Setup           CBRS Test Setup
# Test Teardown        CBRS Test Teardown
# 
# Resource    ./Resources/CB008498-ET_common_keywords.robot
# Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CBRS/resources/cbrs_common_keywords.robot
# 
# Documentation
# ...    Author:Gao melinda
# ...    contact:melinda.gao@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature CB008498 ET CBRS
# 
# Force Tags    SBTS00    CRT_TRUNK    CRT_23R1    CRT_23R2
# ...   PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# 
# [1]CB008498_44_enableCA_high_priority_cell_not_preempt_best_channel_when_cbrsfreqpriority_increased
#     CB008498_44_enableCA_high_priority_cell_not_preempt_best_channel_when_cbrsfreqpriority_increased
# 
# [1]CB008498_45_enableCA_low_priority_cell_preempt_best_channel_when_desiredpmax_increased
#     CB008498_45_enableCA_low_priority_cell_preempt_best_channel_when_desiredpmax_increased
# 
# [1]CB008498_27_enableCA_high_priority_cell_not_preempt_best_channel_when_heartbeat50X_received
#     CB008498_27_enableCA_high_priority_cell_not_preempt_best_channel_when_heartbeat50X_received
# 
# [1]CB008498_28_enableCA_high_priority_cell_preempt_best_channel_when_ca_disabled_to_enable
#     CB008498_28_enableCA_high_priority_cell_preempt_best_channel_when_ca_disabled_to_enable
# 
# [1]CB008498_25_enableCA_low_priority_cell_preempt_best_channel_when_background_hunting
#     CB008498_25_enableCA_low_priority_cell_preempt_best_channel_when_background_hunting
# 
# [1]CB008498_19_enableCA_high_priority_cell_not_preempt_best_channel_when_one_cell_activated
#     CB008498_19_enableCA_high_priority_cell_not_preempt_best_channel_when_one_cell_activated
# 
# *** Keywords ***
