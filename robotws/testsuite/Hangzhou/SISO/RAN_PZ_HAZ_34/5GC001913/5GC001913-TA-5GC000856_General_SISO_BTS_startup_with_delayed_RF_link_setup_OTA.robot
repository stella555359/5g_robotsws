# *** Settings ***
# Documentation    Suite description
# ...   author: kaijia.chen@nokia-sbell.com
# ...   contact: kaijia.chen@nokia-sbell.com
# ...   squad group: MMW_SG_04
# 
# Suite Setup       Suite Setup
# Suite Teardown    Suite Teardown
# 
# Resource   resources/trans_comm.robot
# #Resource   resources/5GC002118_common_KW.robot
# #Resource   resources/siso_resource.robot
# #Resource   resources/coam_siso_common.robot
# #Resource   resources/5GC002118_common_KW.robot
# Resource   taf/rfrl/common_resources/robot/gnb_classical.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Library    taf.sbts.oam.coam.admin    WITH NAME    ccoam
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Test Timeout    20 minutes
# 
# *** Variables ***
# ${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
# 
# *** Test Cases ***
# [1]5GC000856_General_SISO_BTS_startup_with_delayed_RF_link_setup_OTA
#     [Tags]    CRT_TRUNK
#     [Setup]    Check BTS Should Be Normal
#     Step1: Perform RU Power Off
#     Step2: Check BTS not Reset Site
#     Step3: Perform RU Power On
#     [Teardown]     CI_interface.Common Case Teardown
# 
# *** Keywords ***
# Check BTS Should Be Normal
#     Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
#     Wait Until BTS Should Be Normal
#     [Teardown]    COAM Teardown gnb connections
# 
# Step1: Perform RU Power Off
#     log to console    \n Step1: Perform RAU Power Off
#     Perform RU Power Off    ru_index=1    model=${pb_model_ru}
#     WEBUI Login
#     Check RU Disabled
# 
# Step2: Check BTS not Reset Site
#     log to console    \n Step2: Check BTS not Reset Site
#     Check ASOD is UP
#     ${led_ASOD}    run keyword and ignore error       Check Given ASOD Led State    asod=1
#     Run keyword and continue on failure    should be equal   ${led_ASOD[1]}   Enabled
#     Check ASOD is OK
# 
# 
# Step3: Perform RU Power On
#     log to console    \n Step3: Perform RU Power On
#     Perform RU Power On    ru_index=1        model=${pb_model_ru}
#     Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
#     Wait Until BTS Should Be Normal
#     [Teardown]    COAM Teardown gnb connections
# 
# Suite Setup
#     TRANS Common Setup
#     robot_common_operations.Common Suite Setup
# 
# Suite Teardown
#     TRANS Common Teardown
#     robot_common_operations.Common Suite Teardown
# 
# Check Given ASOD Led State
#     [Arguments]    ${asod}
#     ${ASOD_state}       selenium_coam.get_led_status_of_an_unit     unit=SMOD-${asod}
#     Log to console      ASOD state: ${ASOD_state}
#     [Return]            ${ASOD_state}
# 
# Check ASOD is OK
#     [Documentation]  Author: Ding Binmei
#     ...              Description: Wait until GNB status ready.
#     [Timeout]  30 min
#     [Arguments]  ${timeout}=10 min    ${connection}=GNB_OAM    ${gnb_type}='NSA'
#     Cloud DU connect to gnb    connection=${connection}
#     COAM Check GNB ASOD status    connection=${connection}
# 
# COAM Check GNB ASOD status
#     [Documentation]  Author: Ding Binmei
#     ...              Description: Support to check multiple ASODs
#     [Arguments]    ${connection}=GNB_OAM
#     Log to console    Check GNB ASOD status
#     ${hw_info}    ccoam.get_detected_hw_info    connection=${connection}
#     @{list_asods}    Set variable    ${hw_info['systemModules']}
#     ${count_asods}    Get length    ${list_asods}
#     Should be true    ${count_asods}>=${1}    msg=Check ASOD status failed as total ASOD number is less than 1
#     FOR  ${asod}  IN  @{list_asods}
#          Run keyword and continue on failure    Should be equal as strings    ${asod['status']['administrativeState']}    Unlocked
#                                       ...    msg=Current ASOD administrativeState is not in Unlocked status    ignore_case=${True}
#           Run keyword and continue on failure    Should be equal as strings    ${asod['status']['operationalState']}    Enabled
#                                       ...    msg=Current ASOD operationalState is not in Enabled status    ignore_case=${True}
#          Run keyword and continue on failure    Should be equal as strings    ${asod['status']['proceduralStatus']}    configured
#                                       ...    msg=Current ASOD proceduralStatus is not in configured status    ignore_case=${True}
#     END
# 
# Cloud DU connect to gnb
#     [Documentation]    Author: Wang Yixiang
#     [Arguments]  ${connection}=GNB_OAM    ${bts_host}=${tl.gnbs[0].dus[0].f1_m_ip_addr}
#     ...    ${username}=Nemuadmin
#     ...    ${password}=nemuuser
#     ccoam.Connect To    bts_host=${bts_host}    bts_port=${443}    username=${username}    password=${password}
#     ...   name=${connection}
