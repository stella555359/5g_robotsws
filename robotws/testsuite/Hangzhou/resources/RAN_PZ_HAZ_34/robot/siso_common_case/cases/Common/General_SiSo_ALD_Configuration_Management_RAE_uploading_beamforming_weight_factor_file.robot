*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
*** Variables ***

*** Keywords ***
General_SiSo_ALD_Configuration_Management_RAE_uploading_beamforming_weight_factor_file
    [Documentation]
    ...  :author  linjiangjing
    ...  :param  RAE_upload_path_list: E.G
    ...          [
    ...              {
    ...                  'file_path': '/xx/xx/xx/xx.bin'
    ...              }
    ...          ]
    [Arguments]    ${RAE_upload_path_list}=${None}    ${ALD_num}=${1}
    COAM Navigate to login page via webUI
    FOR    ${i}    IN RANGE   ${1}    ${ALD_num}+1
        ${RAE_unit}    set variable    ALD_R-${i} (RAEU_R-${i})
        ${result}    Wait Until Keyword Succeeds   10min     10s    selenium_coam.update_weight_factor_file
        ...    file_path=${RAE_upload_path_list[${i}-1]['file_path']}
        Should Be Equal    ${result}    Weight factor file updated
    END
    [Teardown]    selenium_coam.logout
