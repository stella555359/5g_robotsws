#  *** Settings ***
#  Documentation    OAM_KPI_61a_SiSo_Auto_BTS_site_reset
#  Resource   ./Resource/702.robot
#  Resource   ./Resource/common.robot
#  Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
#  Library   taf.transport.ssh   WITH NAME   csn
#  Library   Collections
#  Force Tags   SG_08   CA_5G_Siso         CRT     CIT_TRUNK   AUTHOR_johnny.1.jiang@nokia-sbell.com
#  ...    PY36
#  Suite Setup   Suite Setup Steps
#  Suite Teardown   Suite Teardown Steps
# 
#  *** Variables ***
#  ${coam_alias}   cell_info
#  @{index_box}   4   9   14   19
# 
#  *** Test Cases ***
#  [1]OAM_KPI_61a_SiSo_Auto_BTS_site_reset
#      [Timeout]    10h
#      [Setup]   Case Setup
#  #    Set Common Test Tag   case_key=kpi_bts_reset
#      Site Reset Repetition
#      [Teardown]   Case Teardown
# 
#  *** Keywords ***
#  Site Reset Repetition
#      :FOR    ${index}    IN RANGE    20
#         BTS Reset
#         Run keyword If   '${index}' in ${index_box}
#          ...   run keyword and continue on failure    Wait Until Keyword Succeeds   3x   1m
#          ...   Data Transfer Conducted    cell_index=${L3CALL_cellid}
#      END
# 
# 
#  BTS Reset
#       COAM Reset Site    wait_for_reconnection=${true}
#       run keyword if  '${tl.gnbs[0].global_bts_id}' == '835' or '${tl.gnbs[0].global_bts_id}' == '833'
#       ...   run keyword and ignore error   wait until keyword succeeds    5min    1min   Enable LMI RU at ControlPC
#       wait until keyword succeeds   20m   30s   COAM Check All Cells Onair
