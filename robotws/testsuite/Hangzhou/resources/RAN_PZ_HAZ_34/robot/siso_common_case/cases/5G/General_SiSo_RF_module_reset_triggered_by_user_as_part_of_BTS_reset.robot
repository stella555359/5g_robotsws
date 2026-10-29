*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_csn.robot
*** Variables ***

*** Keywords ***
General_SiSo_RF_module_reset_triggered_by_user_as_part_of_BTS_reset
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify Reset site shouldn't be performed after RU power reset
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 03.25.2020 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    Connect to Common Unit Master
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${RU_online_status}    Run Keyword And Return Status    Connect to RU With Allocated IP    ru_alias=RU_${ru_index}
        Should be True    ${RU_online_status}
    END
    COAM Check GNB RU status
    COAM Check GNB ABIL status
    COAM Check GNB ASIK status
    ${start_server_times}    Create Dictionary
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${start_server_time}  ${start_uptime}    Get RU Uptime Result    ru_alias=RU_${ru_index}
        Set To Dictionary    ${start_server_times}    ${ru_index}    ${start_server_time}
    END
    Perform BTS Site Reset    download_dir=${SAVE LOG DIRECTORY}
    sleep  60
    Wait Until Keyword Succeeds    5 min    5 sec    Connect to gnb coam via ssl
    FOR  ${ru_index}  IN  @{ru_index_list}
        Wait until keyword succeeds    5 min    5 sec    RU Should Be Offline    ru_index=${ru_index}
        ${RU_offline_status}    Run Keyword And Return Status    Connect to RU With Allocated IP    ru_alias=RU_${ru_index}
        Should not be True    ${RU_offline_status}
    END
    COAM Wait gnb And Cells ready    timeout=20 min    gnb_type='${gNb_CuType}'
    Connect to Common Unit Master
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${RU_recovery_status}    Run Keyword And Return Status    Connect to RU With Allocated IP    ru_alias=RU_${ru_index}
        Should be True    ${RU_recovery_status}
        ${end_server_time}    ${end_uptime}    Get RU Uptime Result    ru_alias=RU_${ru_index}
        ${start_server_time}    Get From Dictionary    ${start_server_times}    ${ru_index}
        RU Should Be Reset    start_server_time=${start_server_time}    end_server_time=${end_server_time}
        ...    uptime=${end_uptime}
        csn.Disconnect  connection=RU_${ru_index}
    END
    [Teardown]  csn.Disconnect  connection=ASIK Master
