*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
*** Variables ***

*** Keywords ***
General_SiSo_ALD_Configuration_Management_RAE_downloading_beamforming_weight_factor_file
    [Documentation]
    ...  :author  linjiangjing
    ...  :param  RAE_download_path_list: E.G
    ...          [
    ...              {
    ...                  'file_path': /xx/xx/xx/xx.bin
    ...              }
    ...          ]
    [Arguments]    ${RAE_download_path_list}=${None}    ${ALD_num}=${1}
    COAM Navigate to login page via webUI
    FOR    ${i}    IN RANGE   ${1}    ${ALD_num}+1
        ${RAE_unit}    set variable    ALD_R-${i} (RAEU_R-${i})
        ${file_path}    set variable    ${RAE_download_path_list[${i}-1]['file_path']}
        ${file_name}    Fetch From Right    ${file_path}    /
        ${result}    Wait Until Keyword Succeeds   10min     10s    selenium_coam.save_weight_factor_file    rae_unit=${RAE_unit}
        ...    file_name=${file_name}
        Should Be Equal    ${result[0]}    File saved from RAE
#        ${saved_path}    set variable    ${result[1]}
    END
    [Teardown]    selenium_coam.logout
