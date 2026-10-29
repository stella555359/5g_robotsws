*** Settings ***
Documentation
...    Author: roscislaw.szuminski@nokia.com
...    Description: Suite prepared for UUF CLOUD tests execution
...    Group in charge: I_MN_RAN_PZ_3_WRO_1_GMS <I_MN_RAN_PZ_3_WRO_1@internal.nsn.com>
...    Sample execution:
...    robot -V /home/ute/testline_configuration/10_16_UTESRANCLOUD2266/__init__.py -L TRACE -b debug.log -d /home/ute/logs/
...    /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/VRF_WRO3_T01/CLOUD_UUF/Testsuites/UUF_CRT/rfsw.robot


Resource        ../../Testcases/UUF_CLOUD.17_ST_vDU_upgrade_with_failed_Parallel_RFSW_upgrade/test.robot
Resource        ../../Testcases/UUF_CLOUD.19_ST_vDU_upgrade_with_Parallel_RFSW_upgrade_with_locked_shared_RMOD/test.robot
Resource        taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource        taf/rfrl/common_resources/common_step/interface.robot

#Suite Teardown  Suite Teardown


*** Variables ***
${RESULTS}                    /home/ute/results/test

#MANTARAY
${NMS_LAB}                    #example: 5007
${VDU_DP_SW}                  #example: vDUCNF00_0.300.32497
${VDU_SW_VERSION}             #example: vDUCNF00_0.300.32597
${CCR_NAME}                   ccr    #Change if CCR on your lab has other name than ccr
${NMS_LAB_IP}                 ${SRNCLAB${NMS_LAB}}    #Do not change. Declare used lab in ${NMS_LAB} variable
${deploy_deletion}            #example: ${True} or ${False}

*** Test Cases ***
[1][2.0] ST_vDU_upgrade_with_failed_Parallel_RFSW_upgrade-vDU
    [Setup]  Run Keywords    Mantaray vDU Deployment    ${NMS_LAB_IP}  ${NMS_LAB}  ${VDU_DP_SW}  ${CCR_NAME}  ${deploy_deletion}
    ...      AND             common.Common Test Setup Cloud
    UUF_CLOUD.17_ST_vDU_upgrade_with_failed_Parallel_RFSW_upgrade
    [Teardown]  Run Keywords     UUF_CLOUD.17_ST_vDU_upgrade_with_failed_Parallel_RFSW_upgrade.Test Case Teardown
    ...    AND   Run Keyword If Test Failed    Run Keyword And Ignore Error    Collect Logs  ${hw}  ${non_upgraded_cnf}  ${test_name}  ${False}
    ...    AND   Run Keyword If Test Failed    Set Passed Logs Collected
    ...    AND   Collect Logs From Passed Execution If Needed

[1][3.0] ST_vDU_upgrade_with_Parallel_RFSW_upgrade_with_locked_shared_RMOD-vDU
    [Setup]  Run Keywords    Mantaray vDU Deployment    ${NMS_LAB_IP}  ${NMS_LAB}  ${VDU_DP_SW}  ${CCR_NAME}  ${deploy_deletion}
    ...      AND             common.Common Test Setup Cloud
    UUF_CLOUD.19_ST_vDU_upgrade_with_Parallel_RFSW_upgrade_with_locked_shared_RMOD
    [Teardown]    Run Keywords
    ...    Run Keyword If Test Failed    UUF_CLOUD.19_ST_vDU_upgrade_with_Parallel_RFSW_upgrade_with_locked_shared_RMOD:5 Test Specific Teardown
    ...    AND   common.Common Test Teardown Cloud
    ...    AND   Run Keyword If Test Failed    Run Keyword And Ignore Error    Collect Logs  ${hw}  ${non_upgraded_cnf}  ${test_name}  ${False}
    ...    AND   Run Keyword If Test Failed    Set Passed Logs Collected
    ...    AND   Collect Logs From Passed Execution If Needed
