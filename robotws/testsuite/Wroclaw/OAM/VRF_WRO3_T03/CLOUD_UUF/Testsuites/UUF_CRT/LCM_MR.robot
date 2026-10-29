*** Settings ***
Documentation
...    Author: marek.starzyk@nokia.com
...    Description: Suite prepared for UUF CLOUD tests execution
...    Group in charge: I_MN_RAN_PZ_3_WRO_1_GMS <I_MN_RAN_PZ_3_WRO_1@internal.nsn.com>
...    Sample execution:
...    robot -V /home/ute/testline_configuration/10_16_UTESRANCLOUD2135/__init__.py -v SW_VCU:vCUCNF00_0.250.26816 -L DEBUG
...    -b debug.log -d /home/ute/logs/ testsuite/Wroclaw/OAM/VRF_WRO3_T01/CLOUD_UUF/Testsuites/UUF_CRT/uuf_crt.robot

Resource        ../../Testcases/UUF_CLOUD.18_ST_vCU_Blue_Green_SW_upgrade_with_scale-in_option_with_max_UPUE_pods/test.robot
Resource        ../../Testcases/UUF_CLOUD.20_ST_vCU_Software_Upgrade_with_N_plus_1_GeoRedundancy/test.robot
Resource        ../../Testcases/UUF_CLOUD.21_ST_vCU_multiple_vCU_Blue_green_SW_upgrade_with_scale_in_same_Cloud/test.robot
Resource        ../../Testcases/UUF_CLOUD.22_ST_vCU_Software_Upgrade_with_N_plus_1_GeoRedundancy_preceded_by_switchover/test.robot
Resource        taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource        taf/rfrl/common_resources/common_step/interface.robot

Suite Teardown  Suite Teardown


*** Variables ***
${RESULTS}    /home/ute/results/test

#MANTARAY
${NMS_LAB}                        #example: 1045
${VCU_DP_SW}                      #example: vCUCNF26R1_27.250.261
${VCU_SW_VERSION}                 #example: vCUCNF26R1_27.250.252
${CNF_LCM_OPERATOR_SW_RELEASE}    #example: cnf-lcm-operator_4.1.0-amd64
${CCR_NAME}                       ccr                     #Change if CCR on your lab has other name than project1
${NMS_LAB_IP}                     ${SRNCLAB${NMS_LAB}}    #Do not change. Declare used lab in ${NMS_LAB} variable.
${lcm_deployment}                 ${True}
${terminate_after_test}           ${True}
${TRUNK_RELEASE}                  26R2


*** Test Cases ***
[1][1.0] ST_vCU_Blue_Green_SW_upgrade_with_scale-in_option_with_max_UPUE_pods-vCU
    [Tags]    vcu_lcm_max_upue
    [Setup]  common.Cloud Setup CNF LCM Operator Blue Green  lcm_deployment=${lcm_deployment}
    UUF_CLOUD.18_ST_vCU_Blue_Green_SW_upgrade_with_scale-in_option_with_max_UPUE_pods
    [Teardown]  Run Keywords
    ...  common.Common Test Teardown Cloud  AND
    ...  Run Keyword If Test Failed    Run Keyword And Ignore Error
    ...  Collect Logs From Blue Green  ${hw}  ${non_upgraded_cnf}  ${BLUE_NAMESPACE}  ${GREEN_NAMESPACE}   AND
    ...  Run Keyword If Test Failed    Set Passed Logs Collected    AND
    ...  Run Keyword And Ignore Error  Run Keyword If    ${terminate_after_test}    RNCNF Cleanup

[1.0] ST_vCU Software Upgrade with N+1 GeoRedundancy-vCU
    [Tags]    vcu_georedundancy
    [Setup]  common.Cloud Setup Geo Redundancy VCU  lcm_deployment=${lcm_deployment}
    UUF_CLOUD.20_ST_vCU_Software_Upgrade_with_N+1_GeoRedundancy
    [Teardown]  Run Keywords
    ...  common.Common Test Teardown Cloud  AND
    ...  Run Keyword And Ignore Error  vcu_admin.disconnect    connection=${admin_connection_vcu2}     AND
    ...  Run Keyword If Test Failed    Run Keyword And Ignore Error
    ...  Collect Logs  hw_type=${hw}   non_upgraded_cnf=${non_upgraded_cnf}  iteration_test_name=vCU_upgrade_via_LCM  second_vcu=${True}  AND
    ...  Run Keyword If Test Failed    Set Passed Logs Collected    AND
    ...  Run Keyword And Ignore Error  Run Keyword If    ${terminate_after_test}    RNCNF Cleanup

[1.0] ST_vCU_multiple_vCU_Blue_green_SW_upgrade_with_scale_in_same_Cloud-vCU
    [Tags]    multiple_vcu_same_cloud
    [Setup]  common.Cloud Setup CNF LCM Operator Blue Green vCU1 and vCU2  lcm_deployment=${lcm_deployment}
    UUF_CLOUD.21_ST_vCU_multiple_vCU_Blue_green_SW_upgrade_with_scale_in_same_Cloud
    [Teardown]  Run Keywords
    ...  common.Common Test Teardown Cloud  AND
    ...  Run Keyword And Ignore Error  vcu_admin.disconnect    connection=${admin_connection_vcu2}     AND
    ...  Run Keyword If Test Failed    Run Keyword And Ignore Error
    ...  Collect Logs From Blue Green  ${hw}  ${non_upgraded_cnf}  ${BLUE_NAMESPACE}  ${GREEN_NAMESPACE}  iteration_test_name=vCU_upgrade_via_LCM  AND
    ...  Run Keyword If Test Failed    Set Passed Logs Collected    AND
    ...  Run Keyword And Ignore Error  Run Keyword If    ${terminate_after_test}    RNCNF Cleanup


[1.0] ST_vCU Software Upgrade with N plus 1 GeoRedundancy preceded by switchover-vCU
    [Tags]    vcu_georedundancy_switchover
    [Setup]  common.Cloud Setup Geo Redundancy VCU  lcm_deployment=${lcm_deployment}
    UUF_CLOUD.22_ST_vCU_Software_Upgrade_with_N_plus_1_GeoRedundancy_preceded_by_switchover
    [Teardown]  Run Keywords
    ...  common.Common Test Teardown Cloud  AND
    ...  Run Keyword And Ignore Error  vcu_admin.disconnect    connection=${admin_connection_vcu2}     AND
    ...  Run Keyword If Test Failed    Run Keyword And Ignore Error
    ...  Collect Logs  hw_type=${hw}   non_upgraded_cnf=${non_upgraded_cnf}  iteration_test_name=vCU_upgrade_via_LCM  second_vcu=${True}  AND
    ...  Run Keyword If Test Failed    Set Passed Logs Collected    AND
    ...  Run Keyword And Ignore Error  Run Keyword If    ${terminate_after_test}    RNCNF Cleanup

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...                             team_name=PZ3WRO1
    ...                             input_logs_dir=${None}
    ...                             remote_host_vDU=${LMP_VDU_IP}
    ...                             remote_host_vCU=${LMP_VCU_IP}
    ...                             mandatory_log_types=__snapshot_vDU__,__snapshot_vCU__