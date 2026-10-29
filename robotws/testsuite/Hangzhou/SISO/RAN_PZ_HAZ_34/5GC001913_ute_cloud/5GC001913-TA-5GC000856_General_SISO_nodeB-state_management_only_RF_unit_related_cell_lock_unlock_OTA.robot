# # #*** Settings ***
# # #Force Tags    PY36
# # #Documentation     author: shanshan zhang
# # #...               contact: shanshan.zhang@nokia-sbell.com
# # #...               squad group: mmw_SG_04
# # #
# # #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# # ##Resource          ../../../Resource/robot/UTE_CLOUD_CommonKeywords.robot
# # #Resource          ./resources/5GC001913_YA_common_keyword.robot
# # #Library           taf.sbts.oam.coam.admin    WITH NAME    coam
# # #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# # #
# # #
# # #*** Variables ***
# # #${global_bts_id}           ${tl.gnbs[0].global_bts_id}
# # #${WEBUI_HOST}              ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# # #${WEBUI_USER}              ${tl.gnbs[0].cu.oam_http_connection_details.username}
# # #${WEBUI_PWD}               ${tl.gnbs[0].cu.oam_http_connection_details.password}
# # #${DST_FOR_FRM}             MRBTS-${global_bts_id}/EQM_R-1/APEQM_R-1/RMOD_R-1
# # #${DST_FOR_FRM_1}           MRBTS-${global_bts_id}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
# # #${DST_FOR_FRM_2}           MRBTS-${global_bts_id}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/GNSSE_R-1
# # #${DST_FOR_FRM_3}           MRBTS-${global_bts_id}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/POWERGROUP_R-1
# # #${DST_FOR_FRM_4}           MRBTS-${global_bts_id}/EQM_R-1/APEQM_R-1/RMOD_R-1
# # #${DST_FOR_FRM_5}           MRBTS-${global_bts_id}/EQM_R-1/HWTOP_R-1/CABLINK_R-1001
# # #
# # #
# # #*** Test Cases ***
# # #5GC001913-TA-5GC000856_General_SISO_nodeB-state_management_only_RF_unit_related_cell_lock_unlock_OTA
# # #    [Tags]    CRT_20B     CRT_TRUNK    5GC000856     5GC000959    5GC001591    5GC001913
# # #    Step1:Lock Ru and check Status
# # #    Step2:UnLock Ru and check Status
# # #    [Teardown]    Case Teardown
# # #
# # #*** Keywords ***
# # #Step1:Lock Ru and check Status
# # #    [Arguments]      ${connection}=ASIK Master
# # #    Cloud DU connect to gnb coam via ssl     connection=${connection}
# # #    Perform RU lock via rest api     connection=${connection}
# # #    RU Should Be Locked     connection=${connection}
# # #    Wait Until Keyword Succeeds   5 min  5 sec   check Cell after Locked    connection=${connection}
# # #    login webui and get parameter and check      expect_usage_status=Active     expect_operational_state=enabled
# # #    run keyword and expect error    *    attach multi power ue    ue_num=${1}
# # #    COAM Teardown gnb connections    connection=${connection}
# # #
# # #Step2:UnLock Ru and check Status
# # #    [Arguments]      ${connection}=ASIK Master
# # #    Cloud DU connect to gnb coam via ssl     connection=${connection}
# # #    Perform RU unlock via rest api     connection=${connection}
# # #    RU Should Be Unlocked         connection=${connection}
# # #    Wait Until Keyword Succeeds    5 min    3 sec     Cell Should Be Unlocked    cell_idx=${1}    connection=${connection}
# # #    Wait Until Keyword Succeeds    6 min    5 sec     COAM Check GNB cell on air    connection=${connection}
# # #    login webui and get parameter and check       expect_usage_status=Active     expect_operational_state=enabled
# # #    attach multi power ue    ue_num=${1}
# # #
# # #Perform RU lock via rest api
# # #    [Documentation]   Author: Liu Zheng
# # #    ...               Description: If selenium method is not stable can switch to this method instead
# # #    [Arguments]    ${ru_idx}=${1}    ${eqm_idx}=${1}    ${apeqm_idx}=${1}    ${connection}=GNB_OAM    ${timeout}=60
# # #    ${mr_bts_id}    Set variable    ${global_bts_id}
# # #    coam.lock_ru    dist_name=MRBTS-${mr_bts_id}/EQM-1/APEQM-1/RMOD-${ru_idx}    timeout=${timeout}    connection=${connection}
# # #
# # #Perform RU unlock via rest api
# # #    [Documentation]   Author: Liu Zheng
# # #    ...               Description: If selenium method is not stable can switch to this method instead
# # #    [Arguments]    ${ru_idx}=${1}    ${eqm_idx}=${1}    ${apeqm_idx}=${1}   ${connection}=GNB_OAM    ${timeout}=60
# # #    ${mr_bts_id}    Set variable    ${global_bts_id}
# # #    coam.unlock_ru    dist_name=MRBTS-${mr_bts_id}/EQM-1/APEQM-1/RMOD-${ru_idx}    timeout=${timeout}    connection=${connection}
# # #
# # #
# # #login webui and get parameter and check
# # #    [Arguments]      ${expect_usage_status}    ${expect_operational_state}
# # #    log to console    login webui and get parameter and check
# # #    Login Page Via WebUI
# # #    ${usage_status}    selenium_coam.get parameter value    dist_name=${DST_FOR_FRM}    filter_param=Usage state    abbr=usageState
# # #    ${operational_state1}    selenium_coam.get parameter value    dist_name=${DST_FOR_FRM_1}
# # #    ...     filter_param=Operational state    abbr=operationalState
# # #    ${operational_state2}    selenium_coam.get parameter value    dist_name=${DST_FOR_FRM_2}
# # #    ...     filter_param=Operational state    abbr=operationalState
# # #    ${operational_state3}    selenium_coam.get parameter value    dist_name=${DST_FOR_FRM_3}
# # #    ...     filter_param=Operational state    abbr=operationalState
# # #    ${operational_state4}    selenium_coam.get parameter value    dist_name=${DST_FOR_FRM_4}
# # #    ...     filter_param=Operational state    abbr=operationalState
# # #    ${operational_state5}    selenium_coam.get parameter value    dist_name=${DST_FOR_FRM_5}
# # #    ...     filter_param=Operational state    abbr=operationalState
# # #    should be equal as strings     ${usage_status}    ${expect_usage_status}
# # #    should be equal as strings     ${operational_state1}    ${expect_operational_state}
# # #    should be equal as strings     ${operational_state2}    ${expect_operational_state}
# # #    should be equal as strings     ${operational_state3}    ${expect_operational_state}
# # #    should be equal as strings     ${operational_state4}    ${expect_operational_state}
# # #    should be equal as strings     ${operational_state5}    ${expect_operational_state}
# # #
# # #    [Teardown]    selenium_coam.logout
# # #
# # #Login Page Via WebUI
# # #    #selenium_coam.enable_virtual_display
# # #    selenium_coam.login    url=https://${WEBUI_HOST}    username=${WEBUI_USER}    password=${WEBUI_PWD}
# # #    selenium_coam.disable_message_box
# # #    selenium_coam.disable_screen_lock
# # #    selenium_coam.refresh_page
# # #    sleep    15sec
# # #
# # #check Cell after Locked
# # #    [Documentation]   Auther: Stella.lin@nokia-sbell.com
# # #    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=GNB_OAM
# # #    ${subcell_status}=  Get Cell Status      cell_idx=${cell_idx}
# # #    ...                                      cell_group_idx=${cell_group_idx}
# # #    ...                                      timeout=${timeout}
# # #    ...                                      connection=${connection}
# # #    Should Be Equal As Strings  ${subcell_status["operationalState"]}   Disabled
# # #    Should Be Equal As Strings  ${subcell_status["availabilityStatus"]}  Dependency
# # #    Should Be Equal As Strings  ${subcell_status["administrativeState"]}  Unlocked
# # #
# # #Recover the test ENV
# # #    [Arguments]     ${connection}=ASIK Master    ${ue_num}=${1}
# # #    ${status}     run keyword and return status      RU Should Be Unlocked        connection=${connection}
# # #    run keyword if    ${status}==${False}   Wait Until Keyword Succeeds   5 min  5 sec    Perform RU unlock via rest 
# ...api   connection=${connection
# # }
# # #    COAM Teardown gnb connections    connection=${connection}
# # #    detach multi power ue    ue_num=${ue_num}
# # #
# # #Case Teardown
# # #    Run Keyword And Ignore Error    Recover the test ENV
# # #    CI_interface.Common Case Teardown