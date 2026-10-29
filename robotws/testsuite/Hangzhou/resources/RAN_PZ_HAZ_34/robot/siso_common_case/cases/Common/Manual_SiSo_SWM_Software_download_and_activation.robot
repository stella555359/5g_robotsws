*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/csn.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot

*** Variables ***

*** Keywords ***
Manual_SiSo_SWM_Software_download_and_activation
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify that SW download with activation are successful.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.08.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]   ${new_software}=SBTS22R3_ENB_9999_220412_000018
    ${sw_name}    ${sw_full_url}    get sw name    SW=${new_software}
    log to console  NEW_SW_PKG:${sw_name}
    Download software to VM    sw_name=${sw_name}    sw_full_url=${sw_full_url}    package_store_path=${CASE_LOG_PATH}
    log to console  start deploy to NEW_SW_PKG:${sw_name}
    Perform SW Update  package=${CASE_LOG_PATH}/${sw_name}
    Wait until keyword succeeds    10min    30s    RU Should Be Online
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    ${current_SW_version}    Get Active SW Version
    should be true    '${new_software}'=='${current_SW_version}'
