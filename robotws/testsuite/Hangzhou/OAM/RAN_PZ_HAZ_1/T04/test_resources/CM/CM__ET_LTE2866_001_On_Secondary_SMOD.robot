*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot
Library           taf.fdsw.rc    WITH NAME    fdswrc

*** Variables ***
${COMMISSIONING_RIGHT_CORE_PATH}    /home/ute/testline_configuration/10_5_UTESRAN1894/commissioning/SCF_Right_Core.xml

*** Keywords ***
CM__ET_LTE2866_001_On_Secondary_SMOD
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    TC for RAN_ET_LTE2866_001_CM_Uncommissioned HW view and Dual single core commissioning - ASIM.docx
    ...    This script is remote executed by script CM__Uncommissioned_HW_View_And_Dual_Single_Core_Commissioning_ET_LTE2866_001.robot
    ...    ******************
    ...    History of changes
    ...    ******************
    ...  - 28.08.2023 - New TC create.

    Set Tags    CM    AUTHOR-bin.7.Liu@nokia-sbell.com    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    LOG    ${TEST_NAME} start.    console=${True}
    Step 1: Check Sync And UnSync SMOD
    Step 2: Commission To Single Core
    Step 3: Reset Configuration

CaseTearDown
    LOG    TestTearDown    console=${True}
    ${time}    Get Time    epoch
    Selenium2Library . Capture Page Screenshot    ${time}.png
    Selenium2Library . Close All Browsers
    coam.Teardown All Aliases For Admin

Step ${index}: Check Sync And UnSync SMOD
    Log To Console    Step ${index}: Check Sync And UnSync SMOD
    SBTS WebEM Logon Uncommissioned SBTS    https://192.168.255.129
    Sync SMOD
    UnSync SMOD
    Reconnect WebEM

Step ${index}: Commission To Single Core
    Log To Console    Step ${index}: Commission To Single Core
    SBTS WEM Load SCF File    ${COMMISSIONING_RIGHT_CORE_PATH}
    SBTS WEM Activate Plan
    Wait Until Keyword Succeeds    300s    30s    SBTS WEM Status Bar Should Be Loading
    Log To Console    SBTS is offline.Wait for SBTS online.
    Wait Until Keyword Succeeds    300s    30s    SBTS WEM Status Bar Should Be Loaded Completed
    Wait Until Keyword Succeeds    600s    30s    Check Rat Status
    Selenium2Library . Close All Browsers

Step ${index}: Reset Configuration
    Log To Console    Step ${index}: Reset Configuration
    Set Test Variable    ${BTS Files}    /home/ute/test_results
    Start Admin    bts_host=192.168.255.129
    Should Be True    ${admin_started}
    rfrlrestconfig.reset_bts_configuration    False    False    False    500    default    False
    ...    Configuration    192.168.255.129    Nemuadmin    nemuuser
    ${is_setup}    Set Variable    ${False}
    FOR    ${i}    IN RANGE    ${0}    ${10}
        Sleep    30s
        ${ret}    ${btsState}    Run Keyword And Ignore Error    coam.Get Mrbts State    timeout=30s
        Continue For Loop If    "${ret}"=="FAIL"
        Continue For Loop If    "${btsState}"!="NotCommissioned"
        ${is_setup}    Set Variable    ${True}
        Exit For Loop
    END
    Should Be True    ${is_setup}
    SBTS WebEM Logon Uncommissioned SBTS    https://192.168.255.129
    ${smod_detected}    Run Keyword And Return Status
    ...    Wait Until WebElement Exist    //common-modal//h4[text()="Additional hardware detected"]    300s    30s
    Run Keyword If    ${smod_detected}    Click Button    //common-modal//ui-button[@a-text="Close"]/button
    SBTS WEM Open RunTime View    SV
    ${titles_elements}    SBTS WEM Filt Object On Navigation Panel Under Runtime View    SMOD_R-
    Should Be Equal As Integers    ${titles_elements.__len__()}    ${1}

Sync SMOD
    ${status}    Run Keyword And Return Status
    ...    Wait Until WebElement Exist    //common-modal//h4[text()="Additional hardware detected"]    60s    10s
    Element Should Be Visible    //sync-control-button//button
#    Run Keyword Unless    ${status}    Click Button    //sync-control-button//button
    Run Keyword If    not ${status}    Click Button    //sync-control-button//button
    Wait Until WebElement Exist    //common-modal//h4[text()="Additional hardware detected"]    30s    5s
    Click Button    //common-modal//ui-button[@a-text="Start sync"]/button
    ${sync_text}    Set Variable    Start sync operation was completed. You could stop sync in Site Runtime View if needed.
    Wait Until WebElement Exist    //common-modal//modal-body//span[text()=" ${sync_text}"]    600s    30s
    Click Button    //common-modal//ui-button[@a-text="Close"]/button
    SBTS WEM Open RunTime View    SV
    ${titles_elements}    SBTS WEM Filt Object On Navigation Panel Under Runtime View    SMOD_R-
    Should Be Equal As Integers    ${titles_elements.__len__()}    ${2}

UnSync SMOD
    Wait Until Element Is Visible    //sync-control-button//button
    Click Button    //sync-control-button//button
    Wait Until WebElement Exist    //stop-data-sync-buttons//ui-button[@a-text="Stop Sync"]/button
    Click Button    //stop-data-sync-buttons//ui-button[@a-text="Stop Sync"]/button
    Wait Until Element Is Visible    //common-modal//span[text()="Stop sync operation was completed."]
    Click Button    //stop-data-sync-buttons//ui-button[@a-text="Close"]/button
    SBTS WEM Open RunTime View    SV
    ${titles_elements}    SBTS WEM Filt Object On Navigation Panel Under Runtime View    SMOD_R-
    Should Be Equal As Integers    ${titles_elements.__len__()}    ${1}

Reconnect WebEM
    Wait Until Element Is Visible    //div[@class="status-bar-menu"]/button
    Click Button    //div[@class="status-bar-menu"]/button
    Wait Until Element Is Visible    //div[contains(@class,"status-bar-menu")]//connection/a[text()=" Disconnect"]
    Click Element    //div[contains(@class,"status-bar-menu")]//connection/a[text()=" Disconnect"]
    ${tmp1}    Set Variable    //main-view//div[@status-bar]//div[contains(@class,"status-bar-bts-element")]//
    ${tmp2}    Set Variable    div[contains(@class,"status-bar-text-overflow") and contains(text(),"--")]
    Wait Until WebElement Exist    ${tmp1}${tmp2}
    Click Button    //div[@class="status-bar-menu"]/button
    Wait Until Element Is Visible    //div[contains(@class,"status-bar-menu")]//connection/a[text()=" Connect"]
    Click Element    //div[contains(@class,"status-bar-menu")]//connection/a[text()=" Connect"]
    Wait Until WebElement Exist    //common-modal//h4[text()="Additional hardware detected"]
    Click Button    //common-modal//ui-button[@a-text="Close"]/button
    SBTS WEM Open RunTime View    SV
    ${titles_elements}    SBTS WEM Filt Object On Navigation Panel Under Runtime View    SMOD_R-
    Should Be Equal As Integers    ${titles_elements.__len__()}    ${1}

SBTS WebEM Logon Uncommissioned SBTS
    [Arguments]    ${url}
    SBTS WEM Accessing    ${url}
    ${except_warning}    Run Keyword And Return Status    Wait Until WebElement Exist    //div[@uib-modal-transclude]    30s    3s
    ${tmp1}    Set Variable    //div[@uib-modal-transclude]//button[contains(text(),"Confirm") or
    ${tmp2}    Set Variable    contains(text(),"Continue") or contains(text(),"OK") or contains(text(),"Yes")]
    ${btn_element}    Run Keyword If    ${except_warning}    Get WebElement    ${tmp1} ${tmp2}
    Run Keyword If    ${except_warning}    Click Button    ${btn_element}

Check Rat Status
    ${rat_status}    SBTS WEM Get RAT Status
    ${rats}    Get Dictionary Keys    ${rat_status}
    FOR    ${rat}    IN    @{rats}
        Should Be True    "${rat_status['${rat}']['rat_state']}"=="On air" or "${rat_status['${rat}']['rat_state']}"=="Not commissioned"
        Should Be True
        ...    "${rat_status['${rat}']['cell_state']}"=="All cells enabled" or "${rat_status['${rat}']['cell_state']}"=="No cells available"
    END