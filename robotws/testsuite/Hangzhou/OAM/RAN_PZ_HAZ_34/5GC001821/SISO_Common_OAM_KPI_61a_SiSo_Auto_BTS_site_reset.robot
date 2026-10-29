# *** Settings ***
# Documentation    OAM_KPI_61a_SiSo_Auto_BTS_site_reset
# Resource   ./Resource/702.robot
# Resource   ./Resource/common.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Library   taf.transport.ssh   WITH NAME   csn
# Library   Collections
# Force Tags   SG_08   CA_5G_Siso         CRT   AUTHOR_yin.4.chen@nokia-sbell.com
# ...    PY36
# Suite Setup   Suite Setup Steps
# Suite Teardown   Suite Teardown Steps
# 
# *** Variables ***
# ${reset_times}   2
# 
# *** Test Cases ***
# [1]OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call
#     [Setup]   Case Setup
# #    Set Common Test Tag   case_key=kpi_bts_reset
# 
#     Log To Console   BTS Site Reset Start ...
#     :FOR   ${index}    IN RANGE    ${reset_times}
#         COAM WEBUI Whether Close Start Up View Window
#         selenium_coam.reset_site
#         Sleep   5m
#         Wait Until Keyword Succeeds   20m   1m   COAM Check All Cells Onair
#         Log To Console   BTS Site Reset Number: ${index + 1}
#     END
#     Log To Console   BTS Site Reset Finish...
# 
#     Wait Until Keyword Succeeds   3x   10s   Data Transfer Conducted    cell_index=${L3CALL_cellid}
#     [Teardown]   Case Teardown: OAM_KPI_BTS_Site_Reset
# 
# *** Keywords ***
# Case Teardown: OAM_KPI_BTS_Site_Reset
#     Run Keyword And Ignore Error   COAM Logout
#     Run Keyword And Ignore Error   Wait Until Keyword Succeeds   10m   1m   COAM Login
#     Run Keyword And Ignore Error   Wait Until Keyword Succeeds   15m   1m   COAM Check BTS OnAir
#     Run Keyword And Ignore Error   Catch Snapshot COAM
#     Run Keyword And Ignore Error   SISO Common Teardown
