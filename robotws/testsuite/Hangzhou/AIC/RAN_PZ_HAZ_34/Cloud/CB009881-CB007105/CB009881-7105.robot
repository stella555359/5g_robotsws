# *** Settings ***
# Documentation
# ...   author: ruiyu.han@nokia-sbell.com
# ...   contact: ruiyu.han@nokia-sbell.com
# ...   Description:
# ...   This test case is used to check vCU & vDU M55601 PM counters
# 
# 
# Suite Setup    AiC Common Suite Setup
# Suite Teardown    AiC Common Suite Teardown
# 
# 
# Force Tags
# ...    CLOUD_5G_AIC                               #TL_TYPE
# ...    STATE_ON_AIR                               #gNB_STATE
# ...    TA_LEVEL_22_FULL_AUTOMATED_CIT_CRT         #Detailed Automation Level
# 
# Test Timeout    120 minutes
# 
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB009881-CB007105/Resource/CB007105_resource.robot
# Library           Collections
# Library           json
# Library           OperatingSystem
# Library           Process
# Library           String
# Library           taf.config.scf                        WITH NAME    scf
# Library           taf.gnb.oam.coam.cu.interface.cu      WITH NAME    cu
# Library           taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
# Library           taf.hw.fhgw.cli                       WITH NAME    issh
# Library           taf.transport.ssh                     WITH NAME    tafssh
# Library           taf.selenium.gnb.oam.coam.cu          WITH NAME    scu
# Library           taf.selenium.gnb.oam.coam.vdu         WITH NAME    svdu
# Library           taf.nms.nom                           WITH NAME    nom_rest
# Library           testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/py_tool/utils.py
# Library           testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/py_tool/global_variables.py
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/cu_oam_fm.robot
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vdu_oam_fm.robot
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/variables.robot
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/common_pre_post_condition.robot
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/common_setup_teardown.robot
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vdu_trs_conn.robot
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vran_others.robot
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/nom_oam_cm.robot
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/cu_testline_configuration.robot
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/cu_oam_state.robot
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/cu_oam_cm.robot
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/cu_oam_pm.robot
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vdu_testline_configuration.robot
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vdu_oam_state.robot
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vdu_oam_cm.robot
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vdu_oam_pm.robot
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vdu_cloud_deployment.robot
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/nom_testline_configuration.robot
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/common_log.robot
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vdu_log_other.robot
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/kw_to_be_optimized.robot
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/aic_common_resources_new.robot
# Library           testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/py_tool/vdu_create_multi_cells_scf.py
# 
# 
# 
# 
# *** Test Cases ***
# [1]CB009881-A_01_CELL_ONAIR_Enable_Cellslot_pooling_with_TDD_3S_4DL4UL_SA_VRAN4.0
#     [Documentation]    *****************
#     ...    check cell onair after 4cell 4dl4ul SCF commission
#     ...    *****************
#     [Tags]  CRT_TRUNK
#     CU Verify All Cells Status Are Onair
#     vDU Verify All Cells Status Should Be Onair
# 
# [1]CB009881-A_03_ flexible_cell_addition_deletion_Enable_Cellslot_pooling_with_TDD_3S_4DL4UL_SA_VRAN4.0
#     [Documentation]    *****************
#     ...    check cell onair after cell addition/deletion
#     ...    *****************
#     [Tags]  CRT_TRUNK
#     Vdu Delete Cell    nrcell_id=2
#     vDU Verify All Cells Status Should Be Onair
#     Vdu Delete Cell    nrcell_id=3
#     vDU Verify All Cells Status Should Be Onair
#     ${cell_dict}     ${channel_group}    Set Variables for Adding Cell    cell_index=2
#     Vdu Copy Cell    added_cell_id=2   base_cell_id=1   cell_dict=${cell_dict}    channel_group=${channel_group}
#     vDU Verify All Cells Status Should Be Onair
#     ${cell_dict}     ${channel_group}    Set Variables for Adding Cell    cell_index=3
#     Vdu Copy Cell    added_cell_id=3   base_cell_id=1   cell_dict=${cell_dict}    channel_group=${channel_group}
#     vDU Verify All Cells Status Should Be Onair
