# *** Settings ***
# Documentation   OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_with_L3Call
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
# ${BTS_ID}   ${tl.gnbs[0].instance_id}
# 
# *** Test Cases ***
# [1]OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_with_L3Call
#     [Setup]   Case Setup
# #    Set Common Test Tag   case_key=rf_reset
#     ${frm_info}   coam.get_frm   connection=COAM   timeout=10
#     ${rmod_count}   Get Length   ${frm_info}
#     :FOR   ${index}    IN RANGE    ${reset_times}
#          Log To Console   RMOD Reset round ${index + 1} Start ...
#          Reset All RUs   ru_count=${rmod_count}
#          Wait Until Keyword Succeeds   20m   1m   COAM Check All Cells Onair
#          Log To Console   RMOD Reset round ${index + 1} finshed.
#          Wait Until Keyword Succeeds   3x   10s   Data Transfer Conducted    cell_index=${L3CALL_cellid}
#     END
#     Log To Console   RMOD Reset Finish...
#     [Teardown]   Case Teardown: OAM_KPI_RF_Reset
# 
# *** Keywords ***
# Case Teardown: OAM_KPI_RF_Reset
#     Run Keyword And Ignore Error   COAM Logout
#     Run Keyword And Ignore Error   Wait Until Keyword Succeeds   10m   1m   COAM Login
#     Run Keyword And Ignore Error   Wait Until Keyword Succeeds   15m   1m   COAM Check BTS OnAir
#     Run Keyword And Ignore Error   Catch Snapshot COAM
#     Run Keyword And Ignore Error   SISO Common Teardown
# 
# Reset All RUs
#     [Arguments]   ${ru_count}
#     :FOR   ${index}    IN RANGE    ${ru_count}
#          selenium_coam.reset_ru_from_site_view   ru_index=${index+1}
#          COAM WEBUI Whether Close Start Up View Window
#     END