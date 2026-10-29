# #*** Settings ***
# #Force Tags    PY36
# #Documentation    Suite description
# #Suite Setup       PM Suite Setup
# #Suite Teardown    TRANS Common Teardown
# #Resource    resources/trans_comm.robot
# #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# #Library    String
# #Library    OperatingSystem
# #
# #*** Variables ***
# #
# #${DU_OAM_IP}                 ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
# #${DU_OAM_WEBUI_USER}         ${tl.gnbs[0].cu.oam_http_connection_details.username}
# #${DU_OAM_WEBUI_PASSWORD}     ${tl.gnbs[0].cu.oam_http_connection_details.password}
# #${DU_OAM_SSH_USERNAME}       ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
# #${DU_OAM_SSH_PASSWORD}       ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
# #${pm_value}                  15min
# #${dist_name}                 MRBTS-${tl.gnbs[0].global_bts_id}/MNL-1/MNLENT-1/PMCADM-1
# #${parameter}                 reportingIntervalPm
# #
# #@{LIST_COUNTER_INFO_M51326}
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51326C0,3
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51326C1,300
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51326C2,3
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51326C3,300
# ##-------- End of M51326  ---------------
# #
# #*** Test Cases ***
# #[1]5GC002236_5GC000349_08_SCTP_Statistics_Measurement_Data
# #    [Documentation]    this case is to verify SCTP Statistics Measurement Data
# #    [Tags]      CRT_20B
# #    [Setup]     PM Test Setup General    counter_table_name=${LIST_COUNTER_INFO_M51326}
# #    Step1: modify para_pm_counter
# #    Step2: Sync To PM Timer Clock   estimated_traffic_generating_duration=9
# #    Step3: Generate Traffic Waiting  duration=2
# #    Step4: Get Counters After Traffic And Verify Them   counter_table_name=${LIST_COUNTER_INFO_M51326}
# #    StepN: Check BTS Should Be Normal
# #    [Teardown]    CI_interface.Common Case Teardown
# #
# #*** Keywords ***
# #Step1: modify para_pm_counter
# #     ${conn}    Connect to DU
# #     ${get_managed_objects}=    coam.get_managed_objects    class_name=PMCADM_A    connection=${conn}
# #     ${repot_parameters}    get from dictionary    @{get_managed_objects}[0]    parameters
# #     ${reportingIntervalPm}    get from dictionary    ${repot_parameters}    reportingIntervalPm
# #     coam.perform_parameter_recommissioning     dist_name=${dist_name}
# #    ...                                        parameter=reportingIntervalPm
# #    ...                                        operation=update
# #    ...                                        value=${pm_value}
# #    ...                                        skip_parameter_relation_errors=${True}
# #    ...                                        should_activate=${True}
# #    ...                                        connection=${conn}
# #    [Teardown]   Disconnect from Du
# #
# #Connect to DU
# #    [Arguments]    ${alias}=cOAM_admin
# #    ${conn}=    coam.connect_to
# #    ...    bts_host=${DU_OAM_IP}
# #    ...    username=${DU_OAM_WEBUI_USER}
# #    ...    password=${DU_OAM_WEBUI_PASSWORD}
# #    ...    name=${alias}
# #    [Return]    ${conn}
# #
# #Disconnect from DU
# #    [Arguments]    ${alias}=cOAM_admin
# #    coam.teardown     connection=${alias}
# #
# #Active New Parameter Value
# #    selenium_coam.validate plan
# #    ${activate_result}    selenium_coam.activate plan    activate_plan_despite_errors=True    timeout=720
# #    #Should be true    ${activate_result}
# #    [Teardown]    run keyword and ignore error    selenium_oam.logout
# #
# #PM Suite Setup
# #    Trans Common Setup
# #    ${PM_FILE_LOCATION}   Set Variable  ${DU_PM_FILE_LOCATION}
# #    Set Suite Variable  ${PM_FILE_LOCATION}
# #    ${PM_FILE_PATTERN}   Set Variable  ${DU_PM_FILE_PATTERN}
# #    Set Suite Variable  ${PM_FILE_PATTERN}
# #
# #PM Test Teardown General
# #    TRANS Test Common Teardown
# #
# #
# #
# #Step3: Generate Traffic Waiting
# #    [Arguments]  ${duration}=2
# #    Log To Console  Step3: Generate Traffic Waiting with duration(wait: ${duration} minutes)
# #    Sleep   ${duration}min
# #
# #Step4: Get Counters After Traffic And Verify Them
# #    [Arguments]  ${counter_table_name}
# #    Log To Console   Step4:Get Counters After Traffic And Verify Them
# #    Get Next Counters And Verify Them   counter_table_name=${counter_table_name}    CounterCollectionInterval=15