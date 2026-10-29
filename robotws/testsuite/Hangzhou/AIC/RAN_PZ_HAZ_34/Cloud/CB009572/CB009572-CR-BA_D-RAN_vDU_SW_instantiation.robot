# *** Settings ***
# Documentation
# ...    author: zhao nana
# ...    contact: nana.zhao@nokia-sbell.com
# ...    squad group: RAN_PZ_3_SG02
# ...    Feature :  CB009572
#  
# #Suite Setup    robot_common_operations.Common Suite Setup
# #Suite Teardown    robot_common_operations.Common Suite Teardown
# 
# Resource    ./resource/CB009572_common_keyword.robot
# Resource    testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/AIC_NetAct.robot
# 
# Force Tags      CRT_TRUNK
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CB009572_instantiation_vDU_with_RANNIC_D-RAN
#     [Documentation]
#     ...   The purpose of this test is to verify vDU install via netact
#     [Tags]    CRT_TRUNK
#     [Setup]    case setup
#     Preconditions
#     Get Cloud Release
#     Run Keyword If  '${du_release}'=='0.300'
#     ...    Run keywords    netact.deploy_cnf    plan_name=${plan_name}    alias=${NETACT_NAME}    distribution=${True}    AND
#     ...        cloud_vdu.vDU Full Commission SCF    scf_file=${SCF_Template_path_DU}/SCF_0.300.xml
#     ...    ELSE    Run keywords    netact.deploy_cnf    plan_name=${plan_name_23R4}
# 	...        alias=${NETACT_NAME}    distribution=${True}    AND
#     ...            cloud_vdu.vDU Full Commission SCF    scf_file=${SCF_Template_path_DU}/SCF_20.300.xml
# 
#     [Teardown]    case teardown
# 	
# [1]CB009572_upgrade_vDU_with_RANNIC_D-RAN
#     [Documentation]
# 	...   The purpose of this test is to verify vDU upgrade via netact
#     [Tags]    CRT_TRUNK
#     [Setup]    case setup
#     Preconditions
#     Get Cloud Release
#     #Run Keyword If  '${du_release}'=='0.300'
#     #...    Run keywords    AIC_NetAct.NetAct Create Cnf Upgrade Plan      plan_name=${upgrade_plan_name}
#     #...        dist_names=${dist_names}    cnf_sw_id=vDUCNF00_${target_version}  alias=${NETACT_NAME}        AND
#     #...            NetAct Upgrade Cnf    plan_name=${upgrade_plan_name}    rollback_plan_name=${rollback_plan_name}
#     #...                alias=${NETACT_NAME}    distribution={True}
#     #...    ELSE    Run keywords    AIC_NetAct.NetAct Create Cnf Upgrade Plan      plan_name=${upgrade_plan_name_23R4}
#     #...        dist_names=${dist_names}    cnf_sw_id=vDUCNF23R4_${target_version}    alias=${NETACT_NAME}    distribution={True}    AND
#     #...            NetAct Upgrade Cnf    plan_name=${upgrade_plan_name_23R4}    rollback_plan_name=${rollback_plan_name_23R4}
#     #...                alias=${NETACT_NAME}    distribution={True}
# 
#    [Teardown]    case teardown
# 
# 	
# [1]CB009572_rollback_vDU_with_RANNIC_D-RAN
#     [Documentation]
#     ...   The purpose of this test is to verify vDU rollback via netact
#     [Tags]    CRT_TRUNK
#     [Setup]    case setup
#     Preconditions
#     Get Cloud Release
#     #Run Keyword If  '${du_release}'=='0.300'
#     #...    netAct rollback cnf CB009572      plan_name=${rollback_plan_name}    dist_names=${dist_names}    alias=${NETACT_NAME}
#     #...    ELSE    netAct rollback cnf CB009572      plan_name=${rollback_plan_name_23R4}    dist_names=${dist_names}    alias=${NETACT_NAME}
# 
#     [Teardown]    case teardown
# 
# *** Keywords ***
# 
# Preconditions
#     [Documentation]   this kw is used for precondition
#     ${START_TIME}=    Get time    exclude_millis=yes
#     Set Suite Variable    ${START_TIME}
# 
# case setup
#     #robot_common_operations.Common Case Setup
#     #wait until keyword succeeds   60  30   cloud_state.vDU Verify All Cells Status Should Be Onair
#     Add Node    cmwas    ${HOSTNAME}    ${USERNAME}    ${PASSWORD}    alias=${NETACT_NAME}
#     ${web_url}=    Detect WEB URL    alias=${NETACT_NAME}
#     Add WEB URL    ${web_url}    ${USERNAME}    ${PASSWORD}    alias=${NETACT_NAME}
#  
# case teardown
#     robot_common_operations.Common Case Teardown
#     Delete Node    cmwas    alias=${NETACT_NAME}
#     Clean All    alias=${NETACT_NAME}
#     Run keyword and ignore error    cloud_vdu.vDU Logout
#     wait until keyword succeeds   1800  60   cloud_state.vDU Verify All Cells Status Should Be Onair
# 
# Get Cloud Release
#     ${str_list}   Split String   ${target_version}   .
#     ${release}   Set Variable   ${str_list[0]}
#     Set Suite Variable   ${du_release}   ${release}.300
# 	
# NetAct Rollback Cnf CB009572
#     [Arguments]   ${plan_name}    ${dist_names}    ${helm_test}=${True}    ${ignore_errors}=${False}
#     ...           ${verbose}=${True}    ${timeout}=${7200}    ${alias}=${None}        
#     ${output}=    netact.rollback_cnf      plan_name=${plan_name}    dist_names=${dist_names}    alias=${alias}
#     ${output}    Replace String Using Regexp    ${output}    \\n\\t    ${EMPTY}
#     Should Contain    ${output}    Uninstall helm release success
#     Should Contain    ${output}    Install main chart success
#     log to console    **** NetAct rollback CNF Successfull ****
# 
# 
# 
# 
