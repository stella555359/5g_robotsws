*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
*** Variables ***

*** Keywords ***
General_SiSo_SOAP_RP1_verification
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify basic configuration of RU using RP1.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 03.09.2020 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    Connect to Common Unit Master
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Reset    ru_index=${ru_index}
        Wait Until Keyword Succeeds    8min    30s    RU Should Be Offline    ru_index=${ru_index}
        sleep  10
        Wait Until Keyword Succeeds    8min    30s    verify all cells should be onair
        Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}
        ${ru_type}    get ru type    ru_index=${ru_index}
        Verify SOAP RP1  ru_index=${ru_index}    ru_type=${ru_type}
        csn.Disconnect  connection=RU_${ru_index}
    END
    [Teardown]  csn.Disconnect  connection=ASIK Master
