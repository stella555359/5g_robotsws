# *** Settings ***
# Force Tags    PY36
# Documentation
# ...    author: jiayi tang
# ...    contact: jiayi.tang@nokia-sbell.com
# ...    squad group: 5G_PZ_MMW_HZ_2_SG
# ...    Feature 5GC002256 program
# 
# Resource    ./Resources/5GC002056_resource_mmw2.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup    robot_common_operations.Common Suite Setup
# Suite Teardown    robot_common_operations.Common Suite Teardown
# 
# *** Variables ***
# ${bts_id}    ${tl.gnbs[0].global_bts_id}
# 
# *** Test Cases ***
# [1][1.0] CB006086_E_004_Transmission_reconfigure_with_feature_disable
#     [Documentation]
#     ...    The purpose of this test is to verify basic configuration of RU RAU OAM configures RU, 
#     ...    configuration not related to synchronization, transport and U-plane.
#     [Tags]
#     [Setup]    robot_common_operations.Common Case Setup
#     Log to Console    *Change Parameter Value*
#     Change Parameter Value    MIMO_value=false
#     sleep    3s
#     Log to Console    *Set EEA2 Value*
#     Set EEA2 Value
#     Log to Console    *Start UL L3call*
#     Start UL L3call
#     Log to Console    *TopYong Attenuation Initial Value set*
#     TopYong Attenuation Initial Value set
#     Log to Console    *Get TcpdumpLogs*
#     Get TcpdumpLogs from Remote machine with local capture
#     Log to Console    *Check Rank Value Disable*
#     Check Rank Value Disable    filter_expression=${maxMIMO_Layers_filter1}
#     [Teardown]    Case Teardown
#        
# *** Keywords ***
# Change Parameter Value
#     [Arguments]    ${MIMO_value}=true
#     Selenium Coam Login And Disable Screen Lock
#     selenium_coam.set_parameter_value
#     ...    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}     filter_param=Activate coverage non-coherent MIMO UEs    new_value=${MIMO_value}
#     selenium_coam.validate_plan
#     selenium_coam.activate_plan    activate_plan_despite_errors=True
#     ${value}    selenium_coam.get_parameter_value    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}
#     ...    filter_param=Activate coverage non-coherent MIMO UEs
#     should be equal    ${value}    ${MIMO_value}
#     [Teardown]    Selenium Coam Logout And Close Browser
#     
# Case Teardown
#     Log to Console    *Case Teardown*
#     Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}
#     Change Parameter Value
#     sleep    2s
#     Recover EEA2 Value
#     Run Keyword And Ignore Error    process.Terminate All Processes    kill=True
#     robot_common_operations.Common Case Teardown
#     Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# Set EEA2 Value
#     [Arguments]
#     Selenium Coam Login And Disable Screen Lock
#     selenium_coam.set_parameter_value
#     ...    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}     filter_param=Null ciphering algorithm    new_value=1
#     sleep    2s
#     selenium_coam.set_parameter_value
#     ...    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}     filter_param=SNOW 3G-based algorithm    new_value=2
#     sleep    2s
#     selenium_coam.set_parameter_value
#     ...    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}     filter_param=AES-based algorithm    new_value=4
#     sleep    2s
#     selenium_coam.set_parameter_value
#     ...    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}     filter_param=ZUC-based algorithm    new_value=3
#     sleep    2s
#     selenium_coam.validate_plan
#     selenium_coam.activate_plan    activate_plan_despite_errors=True
#     [Teardown]    Selenium Coam Logout And Close Browser
#     
# Recover EEA2 Value
#     [Arguments]
#     Selenium Coam Login And Disable Screen Lock
#     selenium_coam.set_parameter_value
#     ...    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}     filter_param=Null ciphering algorithm    new_value=9
#     sleep    2s
#     selenium_coam.set_parameter_value
#     ...    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}     filter_param=SNOW 3G-based algorithm    new_value=0
#     sleep    2s
#     selenium_coam.set_parameter_value
#     ...    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}     filter_param=AES-based algorithm    new_value=0
#     sleep    2s
#     selenium_coam.set_parameter_value
#     ...    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}     filter_param=ZUC-based algorithm    new_value=0
#     sleep    2s
#     selenium_coam.validate_plan
#     selenium_coam.activate_plan    activate_plan_despite_errors=True
#     [Teardown]    Selenium Coam Logout And Close Browser
