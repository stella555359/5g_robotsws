*** Settings ***
Documentation
...  author: Jiang Johnny 1
...  contact: johnny.1.jiang@nokia-sbell.com
Library   taf.sbts.oam.coam.admin   WITH NAME   coam_client
Variables   ../libraries/1808_qc_id.py
Variables    ../../libraries/global_vars.py
Resource   ../../common/taf_coam.robot
Resource   ../../common/gnb.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***

*** Keywords ***
Common Setup
    [Arguments]   ${netact}=${true}   ${server}=gansu
    robot_common_operations.Common Suite Setup
    COAM Try Connect gNB
    Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair

Set Output Log Path
    ${case_exist}   Run Keyword and Return Status   Log   ${TEST_NAME}
    Run Keyword If   ${case_exist}   Create Case Name Folder
    ...   ELSE   Set Suite Variable   ${OUTPUT_LOG_PATH}   ${OUTPUT_DIR}

Create Case Name Folder
   ${remove_empty_name}    Replace String Using Regexp     ${TEST_NAME}    \\s+    _
   RUN   mkdir ${OUTPUT_DIR}/${remove_empty_name}
   Set Test Variable   ${OUTPUT_LOG_PATH}   ${OUTPUT_DIR}/${remove_empty_name}
