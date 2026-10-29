*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
*** Variables ***

*** Keywords ***
OAM_KPI_61a_SiSo_Auto_BTS_site_reset
    FOR    ${TEST_LOOP}    IN RANGE    0    ${MAX_LOOP}
        Set Global Variable    ${TEST_LOOP}
        ${date}=    Get Current Date        result_format=%Y-%m-%d_%H:%M:%S
        Log To Console    \n GNB Reset Iteration ${TEST_LOOP} in progress at: ${date}
        Perform BTS Site Reset
        Sleep    30s
        COAM Wait gnb And Cells ready    timeout=15min    gnb_type='${gNb_CuType}'
        Run Keyword And Ignore Error    COAM Teardown gnb connections
    END
