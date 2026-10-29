# *** Settings ***
# Documentation    OAM_KPI_61a_SiSo_Auto_BTS_site_reset
# Resource   ./Resource/702.robot
# Resource   ./Resource/common.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Library   taf.transport.ssh   WITH NAME   csn
# Library   Collections
# Force Tags   SG_07   CA_5G_Siso    CIT_22R1     CRT   AUTHOR_yin.4.chen@nokia-sbell.com
# ...    PY36
# Suite Setup   Suite Setup Steps
# Suite Teardown   Suite Teardown Steps
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]General_SiSo_E2E_system_setup_with_data_transfer_conducted
#     [Setup]   Case Setup
# #    Set Common Test Tag   case_key=simple_call
#     Wait Until Keyword Succeeds   3x   10s   Data Transfer Conducted
#     [Teardown]   Run Keyword And Ignore Error   Case Teardown
# 
# *** Keywords ***
