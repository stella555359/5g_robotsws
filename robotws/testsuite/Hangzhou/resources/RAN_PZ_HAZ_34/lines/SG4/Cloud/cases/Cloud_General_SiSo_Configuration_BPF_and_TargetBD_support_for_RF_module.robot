*** Settings ***
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG4/Cloud/step_keywords/Cloud_Rmods.robot

*** Keywords ***
Cloud_General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] Purpose of this case it to check RF module support in SW build.
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 13.03.2024 - - Created
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${with_call}=${True}    ${suite_name}=default    ${test_name}=default
    ${rmods}    Get Rmod List
    FOR    ${ru_index}    IN     @{rmods}
        ${targetdb_filename}    Cloud Check TargetBD exist and match
        Cloud Check RU registration info   targetdb_filename=${targetdb_filename}    ru_index=${ru_index}
        ${bpf_filename}    Cloud Check BPF file exist and match    ru_index=${ru_index}
        Cloud verify BPF params    bpf_filename=${bpf_filename}    ru_index=${ru_index}
    END
