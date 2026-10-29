# *** Settings ***
# Documentation     author: Chen Kaijia
# ...               contact: kaijia.chen@nokia-sbell.com
# ...               squad group: MMW_SG_04
# 
# Force Tags    SBTS00    RAN_5G    RAN_5G_TDD    CRT_UTE    CLOUD_5G_CLASSICAL_ASOE_AEQY_ENB    STATE_SW_UPLOADED
# ...   PY36
# 
# Resource          ./Resources/CB007308-5G-AB_FID4657_keywords.robot
# Resource          ./Resources/CB007308-5G-AB_common_keywords.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup       Case Suite Setup
# Suite Teardown    Case Suite Teardown
# 
# *** Test Cases ***
# [1]CB007308-5G-AB_CB006942_5_BTS_startup_SFP+_or_SFP28_transceivers_cold_start_up_support_for_backhaul_interface
#     [Tags]    CRT_22R1    CRT_22R2    CRT_TRUNK
#     [Setup]    Case Setup
#     Check BTS is in On Air
#     Check BTS startup
#     BTS detects cold SFP+/SFP28 startup and compare the temperature
#     [Teardown]    Common Case Teardown
# 
# [2]CB007308-5G-AB_CB006942_7_BTS_startup_SFP+_or_SFP28_transceivers_support_for_fronthaul_and_backhaul_interface
#     [Tags]    CRT_22R1    CRT_22R2    CRT_TRUNK
#     [Setup]    Case Setup
#     Set SFPWhiteList File Name
#     Create dir
#     Download whitelist file
#     Delete parameter in sfpwhitelist    sfp_model=AOSD
#     Delete parameter in sfpwhitelist    sfp_model=FOTB
#     Upload whitelist file    upload_whitelist_path=${SFPwhitelist_PATH}${SFPwhitelist_NAME}
#     Reset DU
#     sleep    10s
#     run keyword and continue on failure    check fault 4657
#     ${i}    Get EIF1 distname
#     ${ii}    Get RF2 distname
#     ${EIF1_SFP_status}    ${RF2_SFP_status}    ${RMOD_SFP_status}    Get Availability status for SFP    i=${i}    ii=${ii}
#     Check SFP availability status
#     ...    EIF1_SFP_status=${EIF1_SFP_status}    RF2_SFP_status=${RF2_SFP_status}
#     ...    RMOD_SFP_status=${RMOD_SFP_status}    expected_status=Degraded
#     change sfpOperatorMode to true
#     sleep    2s
#     run keyword and continue on failure    check none fault 4657
#     ${i}    Get EIF1 distname
#     ${ii}    Get RF2 distname
#     ${EIF1_SFP_status}    ${RF2_SFP_status}    ${RMOD_SFP_status}    Get Availability status for SFP    i=${i}    ii=${ii}
#     Check SFP availability status
#     ...    EIF1_SFP_status=${EIF1_SFP_status}    RF2_SFP_status=${RF2_SFP_status}
#     ...    RMOD_SFP_status=${RMOD_SFP_status}    expected_status=Online
#     sleep    60s
#     ${i}    Get EIF1 distname
#     ${ii}    Get RF2 distname
#     ${EIF1_SFP_status}    ${RF2_SFP_status}    ${RMOD_SFP_status}    Get Availability status for SFP    i=${i}    ii=${ii}
#     Check SFP availability status
#     ...    EIF1_SFP_status=${EIF1_SFP_status}    RF2_SFP_status=${RF2_SFP_status}
#     ...    RMOD_SFP_status=${RMOD_SFP_status}    expected_status=Online
#     Reset DU
#     run keyword and continue on failure    check none fault 4657
#     sleep    10s
#     ${i}    Get EIF1 distname
#     ${ii}    Get RF2 distname
#     ${EIF1_SFP_status}    ${RF2_SFP_status}    ${RMOD_SFP_status}    Get Availability status for SFP    i=${i}    ii=${ii}
#     Check SFP availability status
#     ...    EIF1_SFP_status=${EIF1_SFP_status}    RF2_SFP_status=${RF2_SFP_status}
#     ...    RMOD_SFP_status=${RMOD_SFP_status}    expected_status=Online
#     sleep    5s
#     change sfpOperatorMode to false
#     sleep    20s
#     run keyword and continue on failure    check fault 4657
#     sleep    2s
#     ${i}    Get EIF1 distname
#     ${ii}    Get RF2 distname
#     ${EIF1_SFP_status}    ${RF2_SFP_status}    ${RMOD_SFP_status}    Get Availability status for SFP    i=${i}    ii=${ii}
#     Check SFP availability status
#     ...    EIF1_SFP_status=${EIF1_SFP_status}    RF2_SFP_status=${RF2_SFP_status}
#     ...    RMOD_SFP_status=${RMOD_SFP_status}    expected_status=Degraded
#     sleep    60s
#     ${i}    Get EIF1 distname
#     ${ii}    Get RF2 distname
#     ${EIF1_SFP_status}    ${RF2_SFP_status}    ${RMOD_SFP_status}    Get Availability status for SFP    i=${i}    ii=${ii}
#     Check SFP availability status
#     ...    EIF1_SFP_status=${EIF1_SFP_status}    RF2_SFP_status=${RF2_SFP_status}
#     ...    RMOD_SFP_status=${RMOD_SFP_status}    expected_status=Degraded
#     [Teardown]    Case Teardown
# 
# [2]CB007308-5G-AB_CB006942_9_The_BTS_shall_support_NIDD_parameter_SFPOperatorMode_to_enable_and_disable_SFP+_or_SFP28_compliance_validation
#     [Tags]    CRT_22R1    CRT_22R2    CRT_TRUNK
#     [Setup]    Case Setup
#     Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
#     [Teardown]    Common Case Teardown 
# 
# *** Keywords ***
# Case Teardown
#     CI_interface.Common Case Teardown
#     robot_common_operations.Common case Teardown
#     sleep    15s
#     Upload whitelist file    upload_whitelist_path=${SFPwhitelist_PATH}SFPwhitelist.xml
#     Reset DU
#     run keyword and continue on failure    check none fault 4657
#     sleep    3s
#     ssh.Connect to    hostname=${test_pc_host}    username=${test_pc_username}
#     ...   password=${test_pc_password}    alias=test_pc
#     ssh.send command    command=rm -rf ${SFPwhitelist_PATH}${SFPwhitelist_NAME}
#     ...    connection=test_pc    timeout=15 s
#     ssh.send command    command=rm -rf ${SFPwhitelist_PATH}log
#     ...    connection=test_pc    timeout=15 s
#     [Teardown]    ssh.Disconnect    connection=test_pc
# 
# Common Case Teardown   
#      CI_interface.Common Case Teardown
#      robot_common_operations.Common case Teardown
# 
# Case Setup
#     robot_common_operations.Common case Setup
# 
# Case Suite Setup
#     CI_interface.Common Suite Setup
#     robot_common_operations.Common Suite Setup
# 
# Case Suite Teardown
#     CI_interface.Common Case Teardown
#     robot_common_operations.Common Suite Teardown
# 
