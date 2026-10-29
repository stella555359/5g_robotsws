*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Keywords ***
CM__Reset_WCDMA_RAT
    [Documentation]    CM__Reset_WCDMA_RAT
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...
    ...    Reset WCDMA RAT.
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 05.02.2024 - Bin.7.Liu - Commit to robotws.
    Step 1: Reset WCDMA RAT

Step ${index}: Reset WCDMA RAT
    LOG    Step ${index}: Reset WCDMA RAT    console=${True}
    Reset WCDMA RAT

Reset WCDMA RAT
    SBTS WEM Open RunTime View    SV
    Wait Until WebElement Exist    //div[contains(@class,"status-bar-right")]//ui-button[contains(@a-title,"Reset WCDMA")]    30s    3s
    Click Element    //div[contains(@class,"status-bar-right")]//ui-button[contains(@a-title,"Reset WCDMA")]
    ${except_warning}    Run Keyword And Return Status    Wait Until WebElement Exist    //div[@uib-modal-transclude]    30s    3s
    Run Keyword If    ${except_warning}    Click Button    //div[@uib-modal-transclude]//button[text()=" Reset"]
    @{RAT_list}    Create List    WCDMA
    SBTS WEM Check RATs Has Reseted Successful    ${RAT_list}    240

Set Up
    SBTS WEM Logon    https://${MPLANE_IP}    skip_error=${True}    setup_param=${False}

Tear Down
    Run Keyword If Test Failed    Capture Page Screenshot    ${TEST_NAME}_FAIL.JPEG
    SBTS WEM Download Chrome Console Log
    Close All Browsers
