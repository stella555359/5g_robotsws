# *** Settings ***
# Documentation
# ...   author: Jiang Johnny
# ...   contact: johnny.1.jiang@nokia-sbell.com
# 
# Resource   ./Resource/common.robot
# Resource   ./Resource/702.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Suite Setup   Suite Setup Steps
# Suite Teardown   Suite Teardown Steps
# Force Tags   SG_08   CA_5G_Siso         CRT
# ...    PY36
# 
# *** Variables ***
# ${ue_type}    huawei
# 
# *** Test Cases ***
# [1]FGCR-6373_Increase_PSD_on_AAHF_for_non_FCC_markets_full_mode_40M_performance
#     [Tags]    AUTHOR_johnny.1.jiang@nokia-sbell.com
#     [Setup]   Run Keywords    COAM Login   alias=${coam_alias}
#     ...   AND   COAM Check BTS OnAir
#     Log to console   pass
# #    Run keyword and ignore error   Set up Call Mate30    dl_traffic=120   mode=Peak
#     [Teardown]   COAM Logout   connection=${coam_alias}
# 
# *** Keywords ***
# Set up Call Mate30
#     [Arguments]    ${dl_traffic}   ${mode}=${EMPTY}
#     Check UE device exist
#     power_ue.Prepare UE   ue_type=${ue_type}
#     Attach and Retry if Failed
#     Run Keyword and Continue on Failure   Start DL Traffic with ${mode}Throughput ${dl_traffic}