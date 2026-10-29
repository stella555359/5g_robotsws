*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_csn.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
*** Variables ***

*** Keywords ***
General_SiSo_CPRI_link_configuration
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test is to check if Common Public Radio Interface link is configured properly
    ...    after BTS power up with RU connected. CPRI link state is verified on Radio Access Unit and Radio Unit side.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.16.2020 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    Perform BTS Site Reset
    sleep  60
    log to console    \nCheck CPRI links status
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    ${output_links}=    Get cpri Link State from BTSOM
    Check cpri link state from BTSOM    ${output_links}
