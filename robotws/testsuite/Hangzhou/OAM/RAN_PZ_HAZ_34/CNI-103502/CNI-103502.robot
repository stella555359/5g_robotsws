*** Settings ***
Documentation
...    Author: yin.4.chen@nokia-sbell.com
...    Feature CNI-103502 Automation

Resource   ./Resource/Common.robot

Suite Setup   Common Suite Setup
Suite Teardown   Common Suite Teardown


*** Test Cases ***
CNI_103502_IMS2_pm1_resistance_to_FPGA_update_Power-On_Reset_after_SW_Activation
    [Setup]   robot_common_operations.Common Case Setup
    Test_Case_CNI_103502
    [Teardown]   Run Keywords
    ...   CNI-103502 Catch All Logs
    ...   AND
    ...   robot_common_operations.Common Case Teardown


*** Keywords ***
Test_Case_CNI_103502
    Log To Console   ${EMPTY}
    Run Keyword If   ${isSameFPGA}   Log To Console   FPGA Version Same. Skip To Run The Test Cases.
    Return From Keyword If   ${isSameFPGA}

    ${new_package_path}   Download Classical Common Package   package_version=${NEW_SW_VERSION}
    Set Suite Variable   ${NEW_PACKAGE_PATH}

    COAM Update qRxLevMin
    CNI-103502 Update Software
    Get IMS2 PM1
    # COAM Transfer IMS2 To SCF
    Selenium Transfer IMS2 To SCF
    Check IMS2 PM1


CNI-103502 Update Software
    COAM Login
    coam.update_software   sw_package=${NEW_PACKAGE_PATH}   should_activate=${True}   timeout=${3600}   connection=COAM
    Sleep   5m
    Run Keyword And Ignore Error   COAM Logout
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    Wait Until Keyword Succeeds   20m   1m   COAM ADMIN Check Cell Onair
    [Teardown]   Run Keyword And Ignore Error   COAM Logout


CNI-103502 Catch All Logs
    ${log_status}   Get Variable Value   ${TEST_STATUS}   ${KEYWORD_STATUS}
    Return From Keyword If   "${log_status}"=="PASS"

    Run Keyword And Continue On Failure   CNI-103502 Catch Snapshot


CNI-103502 Catch Snapshot
    [Arguments]   ${log_dir}=${OUTPUT_DIR}   ${timeout}=5400

    Wait Until Keyword Succeeds   10m   1m   COAM Login

    ${time}   DateTime.Get Current Date   UTC   + 8 hours   result_format=%Y-%m-%d-%H_%M_%S
    Log To Console  Start To Collect Snapshot!
    ${snapshot_name}   Set Variable   Snapshot_${time}.zip

    Run Keyword And Ignore Error   coam.Collect snapshot
    ...      target_file_name=${log_dir}/${snapshot_name}   coverage=Full   force=True   timeout=${timeout}   connection=COAM

    [Return]   ${log_dir}/${snapshot_name}
    [Teardown]   Run Keyword And Ignore Error   COAM Logout
