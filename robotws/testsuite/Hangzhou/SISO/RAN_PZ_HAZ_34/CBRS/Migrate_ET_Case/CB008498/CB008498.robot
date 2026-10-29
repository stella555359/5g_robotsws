# *** Settings ***
# Suite Setup          Run Keywords     CBRS Suite Setup    UTECloud=${True}  AND  Case Preparation for CB008498 disable CA
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
# Force Tags    5G_RAN_TDD    SBTS00    CRT_22R4    CRT_23R1    STATE_SW_UPLOADED    CRT_UTE    RAN_5G
# ...           RAN_5G_TDD    CLOUD_5G_CLASSICAL_ASIKR_ABILB4_AZQC    SBTS23R1
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CB008498_02_disableCA_low_priority_cell_preempt_best_channel_when_two_cells_activated
#     CB008498_02_disableCA_low_priority_cell_preempt_best_channel_when_two_cells_activated
# 
# [1]CB008498_39_disableCA_low_priority_cell_preempt_best_channel_when_new_channel_added
#     CB008498_39_disableCA_low_priority_cell_preempt_best_channel_when_new_channel_added
# 
# [1]CB008498_36_disableCA_low_priority_cell_preempt_best_channel_when_used_channel_removed
#     CB008498_36_disableCA_low_priority_cell_preempt_best_channel_when_used_channel_removed
# 
# [1]CB008498_05_disableCA_high_priority_cell_preempt_best_channel_when_one_cell_activated
#     CB008498_05_disableCA_high_priority_cell_preempt_best_channel_when_one_cell_activated
# 
# [1]CB008498_11_disableCA_high_priority_cell_not_preempt_best_channel_when_background_hunting
#     CB008498_11_disableCA_high_priority_cell_not_preempt_best_channel_when_background_hunting
# 
# [1]CB008498_70_second_grant_abort_relinquish102
#     CB008498_70_second_grant_abort_relinquish102
# 
# [1]CB008498_77_heartbeat501_second_grant_no_available_channel
#     CB008498_77_heartbeat501_second_grant_no_available_channel
# 
# [1]CB008498_68_second_grant_abort_heartbeat105
#     CB008498_68_second_grant_abort_heartbeat105
# 
# [1]CB008498_64_second_grant_abort_grant100
#     CB008498_64_second_grant_abort_grant100
# 
# [1]CB008498_55_pal_gaa_out_of_110mhz_range
#     CB008498_55_pal_gaa_out_of_110mhz_range
# 
# *** Keywords ***
