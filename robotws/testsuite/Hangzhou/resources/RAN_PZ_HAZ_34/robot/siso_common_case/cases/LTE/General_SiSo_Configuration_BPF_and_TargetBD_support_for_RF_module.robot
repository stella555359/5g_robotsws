*** Settings ***
Documentation    This is common keywords for LTE siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/bpf.robot
*** Variables ***

*** Keywords ***
General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to check RF module support in SW build.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 2022.4.19 - - Created
    ...    *******************
    ...    Owner_jiayi.tang@nokia-sbell.com
    [Arguments]   ${variable_from_CFAM}=${Variables_CFAM}
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${radio_type}    get ru type  ru_index=${ru_index}
        verify content of TargetBD file LTE   ru_index=${ru_index}    radio_type=${radio_type}
        verify content of BPF file LTE    variable_from_CFAM=${variable_from_CFAM}    ru_index=${ru_index}
    END
