#  *** Settings ***
#  Documentation
#  ...   author: Jiang Johnny
#  ...   contact: johnny.1.jiang@nokia-sbell.com
# 
#  Resource   ./Resource/common.robot
#  Resource   ./Resource/702.robot
#  Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
#  Suite Setup   Suite Setup Steps
#  Suite Teardown   Suite Teardown Steps
#  Force Tags   SG_08   CA_5G_Siso         CIT_22R1
#  ...    PY36
# 
#  *** Variables ***
#  #${ue_type}    huawei
#  &{ue_0}   cell_index=2   abil_index=1
#  &{ue_1}   cell_index=5   abil_index=3
#  ${Send_Tput_DL}      200M
#  ${Expect_Tput_DL}      50
#  ${traffic_duration}        90
# 
#  *** Test Cases ***
#  [1]5GC000702_AAHF_AAHJ_General_SiSo_E2E_system_setup_with_data_transfer_conducted
#      [Timeout]    5h
#      [Tags]    AUTHOR_johnny.1.jiang@nokia-sbell.com
#      [Setup]   Case Setup
#  #    Set Common Test Tag   case_key=simple_call
#      Wait Until Keyword Succeeds   3x   1m    Data Transfer Conducted   cell_index=${L3CALL_cellid}
#      [Teardown]   run keywords    Case Teardown    AND    Check Unexpected History Faults
