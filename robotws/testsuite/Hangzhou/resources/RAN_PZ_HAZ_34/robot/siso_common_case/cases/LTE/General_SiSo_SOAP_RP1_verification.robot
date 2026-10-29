*** Settings ***
Documentation    This is common keywords for LTE siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/sync_startup.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/ru_operation.robot

*** Variables ***

*** Keywords ***
General_SiSo_SOAP_RP1_verification
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify basic configuration of RU using RP1.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 2022.5.15 - - Created
    ...    *******************
    ...    jiayi.tang@nokia-sbell.com
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}     alias=ASIK Master
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        selenium_coam.reset_ru  ru_index=${ru_index}
        #Perform RU Power Off LTE    ru_index=${ru_index}
        Wait Until Keyword Succeeds    8min    5s    RU Should Be Power Off    ru_index=${ru_index}
        sleep  3s
        #Perform RU Power On LTE    ru_index=${ru_index}
        Wait until keyword succeeds    15 min    5 sec   verify all cells should be onair    cell_type=${cell_type}
        Close Start Up View Window    timeout=60
        Connect to RU With Allocated IP LTE    ru_index=${ru_index}  ru_alias=RU_${ru_index}
        ${ru_type}    get ru type    ru_index=${ru_index}
        Verify SOAP RP1 LTE  ru_index=${ru_index}    ru_type=${ru_type}
        csn.Disconnect  connection=RU_${ru_index}
    END
    [Teardown]  csn.Disconnect  connection=ASIK Master
