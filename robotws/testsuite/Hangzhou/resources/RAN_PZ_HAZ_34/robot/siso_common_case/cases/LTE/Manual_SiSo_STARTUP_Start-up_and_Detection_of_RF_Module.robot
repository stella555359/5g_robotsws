*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/ru_operation.robot
*** Variables ***

*** Keywords ***
Manual_SiSo_STARTUP_Start-up_and_Detection_of_RF_Module
    [Documentation]
    ...    *****************
    ...    The purpose of this test case is to verify if  RF Module detection procedure is successful after connecting
    ...    to System Module and works as specified in documentation.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 07.04.2020 - - Created
    ...    *******************
    ...    OWNER_shufei.chen@nokia-sbell.com
    [Arguments]    ${loop_times}=2
    ${ru_index_list}  Get All RU Index
    FOR  ${i}  IN RANGE  ${loop_times}
        Perform RU Power Off And On LTE    ru_index_list=${ru_index_list}
    END
    FOR  ${ru_index}  IN  @{ru_index_list}
        Wait Until Keyword Succeeds    10min    1min    RU Should Be Online   ru_index=${ru_index}
        check RU config LTE    ru_index_list=${ru_index_list}
    END
    FOR  ${ru_index}  IN  @{ru_index_list}
        log to console    "get ru ip and ping"
        Get RU IP AND Check Pingable LTE    ru_index=${ru_index}
    END
