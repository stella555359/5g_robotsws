*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/nrarfcn_and_gscn.robot
*** Variables ***

*** Keywords ***
General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] To verify that 5G BTS can report fault 1900: EFaultId_FrConfiguringFailed
    ...      after configuring pmax to out of range value of supported power.
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 01.16.2019  - Created
    ...    - 02.23.2021  - Update fault 4008
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    Owner_aaron.deng@nokia-sbell.com
    [Arguments]  ${cell_id}=1    ${ru_index}=1    ${variable_from_CFAM}=${Variables_CFAM}
    Selenium Login And Disable Screen Lock
    ${origin_params}  Modify pMax to tirgger fault    cell_id=${cell_id}  ru_index=${ru_index}  variable_from_CFAM=${variable_from_CFAM}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    10min    30s    Alarm in Given Alarm list Present
    [Teardown]  run keywords    Close Start Up View    timeout=60    AND
    ...    Modify Parameters On Webem  ${origin_params}              AND
    ...    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'    AND
    ...    Selenium Logout And Close Browser
