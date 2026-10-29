# *** Settings ***
# Suite Setup       Run Keywords  robot_common_operations.Common Suite Setup    cOAM Common Suite Setup
# Suite Teardown    Run Keywords  robot_common_operations.Common Suite Teardown    step7:logout webui    CI_interface.Common Case Teardown
# Test Teardown     Run Keywords  robot_common_operations.Common case Teardown   AND    
# ...               Run Keyword And Ignore Error    Common Case Teardown    is_save_snapshot=True
# Test Setup        Run Keyword  robot_common_operations.Common case Setup
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
# #Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/None_Feature_SG3/Resource/common_KW.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Library           taf.transport.ssh    WITH NAME    csn
# Library           taf.sbts.oam.coam.admin   WITH NAME   coam
# Resource    ./resources/comm_case_keyword.robot
# 
# Documentation
# ...    author: shenrao
# ...    contact: shengrong.rao@nokia-sbell.com
# ...    squad group: RAN3_SG_04
# ...    Feature Upgrade loops - WebUI  UUF4ALL
# 
# 
# Force Tags      RAN3_SG_04
# *** Variables ***
# 
# 
# *** Test Cases ***
# [1]TC13_OAM_gNB_SW_Upgrade_success_L3Call
#     [Documentation]    *****************
#     ...    Basic information
#     ...    *****************
#     ...    this case is to verify gNB can download and Rollback a new version SW build package successfully
#     ...    *******************
#     ...    Test case flowchart
#     ...    *******************
#     [Tags]    CDRT_TRUNK
#     Set Test Variable    ${test_round}    1
#     FOR    ${count}    IN RANGE    ${test_round}
#         Run Keyword And Continue On Failure    SWM supports provision SW build package via WebUI
#         sleep    50s
#         Run Keyword And Continue On Failure    Classical gNB Software Rollback successfully via WebUI
#     END
# 
# *** Keywords ***
