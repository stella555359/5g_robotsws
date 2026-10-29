*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/gnb_sync.robot
*** Variables ***

*** Keywords ***
General_SiSo_Collect_RFSW_Logs_from_RRU_into_BTS_Snapshot_PTP_Failure
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify that PTP Failure we can check the information in FF Logs.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 03.03.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]    ${ru_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    Selenium Login And Disable Screen Lock
    ${pre_log_num}    ${clks_num}    get ru log id by synchronization OPT_IF
    ${origin_params}    Set ptp only to true
    @{clock_class_list}    create list    7
    Modify Accepted clock class list    acceptedClockClass=${clock_class_list}
    log to console  \n Wait For Fault 16 Present
    Wait For Expect Fault Present    faultId=${16}    timeout=300
    ${clkstartup_path}    ${clks_path}    Check PtpState in startup default log    ru_index=${ru_index}    download_dir=${download_dir}
    ...    pre_log_num=${pre_log_num}    clks_num=${clks_num}
    [Teardown]    Run keywords    Commissioning SCF And Check On Air      scf_path=${Case_SCF_Path}
    ...    AND   Selenium Logout And Close Browser
