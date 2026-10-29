# *** Settings ***
# Suite Setup          Dedicate_Suite_Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           Dedicate_Case_Setup
# Test Teardown        Dedicate_Case_Teardown
# 
# #Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/Rjio_HAZ3_SG2/Resources/made_variable.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
# Library    taf.nms.netact
# Library    DateTime
# 
# #Suite Setup    Suite Precondition
# #Suite Teardown    Suite Postcondition
# 
# *** Variables ***
# ${NETACT_NAME}    ${tl.gnbs[0].instance_id}_alias
# ${HOSTNAME}    ${tl.nms.nom.neo_endpoints_ip}
# ${USERNAME}    ${tl.nms.nom.https_main_info.username}
# ${PASSWORD}    ${tl.nms.nom.https_main_info.password}
# ${DIST_NAME}    PLMN-PLMN/MRBTS-${tl.gnbs[0].instance_id}
# ${LOCAL_DIR}    /home/ute
# ${plan_name}    ${tl.gnbs[0].instance_id}_plan
# ${reset_number}    1
# ${if_commissioning}    False
# 
# *** Test Cases ***
# [1]General_SiSo_full_configuration_plan_commission_via_NetAct
#     FOR    ${index}    IN RANGE    0    ${reset_number}
#         Netact Test
#     END
# 
# *** Keywords ***   
# Dedicate_Suite_Setup
#     Import Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/TLData/${testline_name}/TLConfiguration.py
#     SISO Coam Suite Setup
# 
# Dedicate_Case_Setup
#     SISO Coam Test Setup
#     sleep    10s
#     Suite Precondition
# 
# Dedicate_Case_Teardown
#     Suite Postcondition
#     sleep    10s
#     SISO Coam Test Teardown
# 
# Suite Precondition
#     Add Node    cmwas    ${HOSTNAME}    ${USERNAME}    ${PASSWORD}    alias=${NETACT_NAME}
#     ${web_url}=    Detect WEB URL    alias=${NETACT_NAME}
#     Add WEB URL    ${web_url}    ${USERNAME}    ${PASSWORD}    alias=${NETACT_NAME}
# 
# Suite Postcondition
#     Delete Node    cmwas    alias=${NETACT_NAME}
#     Clean All    alias=${NETACT_NAME}
# 
# #Check Cell Onair
# #    Connect to gnb coam via ssl
# #    Wait Until Keyword Succeeds    10min     30s     verify all cells should be onair
# #    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections
# 
# Netact Test
#     Log to console    Test CM Operations Upload Configuration
#     ${parameters_1}=   Create Dictionary    -lteHwContentInUse=${TRUE}    -sranBtsHwContentInUse=${TRUE}
#     Upload Configuration    ${DIST_NAME}    parameters=${parameters_1}    alias=${NETACT_NAME}
#     
#     Log to console    Test CM Operations Export Actual Configuration
#     Export Configuration    166_actual_config.xml    local_dir=${LOCAL_DIR}
#     ...                     dist_names=${DIST_NAME}    alias=${NETACT_NAME}    class_filter_exclude=NeIdentificationResult
# 
#     Log to console    Test CM Operations Delete Plan
#     Run keyword and ignore error    Delete Plan    ${plan_name}    alias=${NETACT_NAME}
#         
#     Log to console    Test CM Operations Import Configuration
#     Import Configuration    166_actual_config.xml    local_dir=${LOCAL_DIR}   plan_name=${plan_name}    alias=${NETACT_NAME}
#     
#     Log to console    Delete NE data
#     Run keyword and ignore error    delete_ne_data_from_configurator
#     ...    dist_names=${DIST_NAME}/AgentDiscovery-1/NeIdentificationResult-1    alias=${NETACT_NAME}
#     
#     Log to console    Test CM Operations Provision Plan
#     Provision Plan    ${plan_name}    ${DIST_NAME}    backup_plan_name=166_backup
#     ...               create_backup_plan=${False}    provisioning_operation=preactivate    alias=${NETACT_NAME}
#     taf.nms.netact.Validate Plan    ${plan_name}    ${DIST_NAME}    alias=${NETACT_NAME}
#     taf.nms.netact.Activate Preactivated Plan    ${plan_name}    ${DIST_NAME}    alias=${NETACT_NAME}
#     
#     #Log to console    Check cell onair
#     #Sleep    300s
#     #Check Cell Onair
