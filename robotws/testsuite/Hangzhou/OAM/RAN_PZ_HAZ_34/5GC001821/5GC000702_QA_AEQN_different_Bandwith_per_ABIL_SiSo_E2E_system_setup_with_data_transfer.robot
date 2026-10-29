# *** Settings ***
# Documentation
# ...   author: He Jingmin
# ...   contact: jingmin.he@nokia-sbell.com
# 
# Resource   ./Resource/common.robot
# Resource   ./Resource/702.robot
# Suite Setup   Suite Setup Steps
# Suite Teardown   Suite Teardown Steps
# Force Tags   SG_08   CA_5G_Siso         CIT
# ...    PY36
# Test Teardown   CI_interface.Common Case Teardown
# 
# *** Variables ***
# @{bandswith}   80   100
# ${cell_index}   2
# ${dist_name}   MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-${cell_index}
# 
# *** Test Cases ***
# [1]5GC000702_QA_AEQN_008_Configuration_Of_6S_1CC_4DL_2UL_1ABIL_different_Bandwith_per_ABIL_SiSo_E2E_system_setup_with_data_transfer
#     [Setup]   Case Setup
# #    Set Common Test Tag   case_key=simple_call
#     wait until keyword succeeds   10m   1m   COAM Check All Cells Onair
#     Change bandwith and Verify Traffic
#     [Teardown]  Case Teardown
# 
# *** Keywords ***
# Change bandwith and Verify Traffic
#     :FOR   ${band_request}   IN   @{bandswith}
#        Change All Cells Bandwith   new_band=${band_request}
#        Run Keyword and Continue on Failure   Wait Until Keyword Succeeds   3x   30s
#        ...   Data Transfer Conducted
#     END
#     [Teardown]   Change Bandwith   cell_index=${cell_index}   new_band=100   pair_cell_change=${true}
# #
# #Change Bandwith
# #    [Arguments]   ${new_band}
# #    #COAM WEBUI Login
# #    ${curr_band}   selenium_coam.Get Parameter Value   dist_name=${dist_name}   filter_param=Channel bandwidth
# #    Return From Keyword If   '${new_band}MHz'=='${curr_band}'
# #    selenium_coam.set_parameter_value     dist_name=${dist_name}     filter_param=Channel bandwidth    new_value=${new_band}MHz
# #    selenium_coam.validate_plan
# #    selenium_coam.activate_plan
# #    wait until keyword succeeds   10m   1m   Try Connect gNB
# #    wait until keyword succeeds   20m   1m   COAM Check All Cells Onair
# #    #[Teardown]   COAM WEBUI Logout
# #
# #Restore Band
# #    ${bandwidth}   selenium_coam.Get Parameter Value   dist_name=${dist_name}   filter_param=Channel bandwidth
# #    Run Keyword If   ${bandwidth.startswith("100")}   Change Bandwith   cell_index=${cell_index}   new_band=100   pair_cell_change=${true}
# #
# #Get Bandwith Setting
# #    ${bandwidth}   selenium_coam.Get Parameter Value   dist_name=${dist_name}   filter_param=Channel bandwidth
# #    [Return]   ${bandwidth}