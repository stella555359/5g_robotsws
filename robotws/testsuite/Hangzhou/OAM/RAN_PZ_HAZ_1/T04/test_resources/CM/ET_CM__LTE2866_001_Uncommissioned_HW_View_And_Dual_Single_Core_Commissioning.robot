*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${COMMISSIONING_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
${COMMISSIONING_LEFT_CORE_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_Left_Core.xml
${COMMISSIONING_RIGHT_CORE_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_Right_Core.xml
${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}    # Should relation errors be skipped (True, False)
${COMMISSIONING_TIMEOUT}    600    # Timeout for commissioning procedure (scf upload, reset indication, wait for reconnection after reset)

*** Keywords ***
ET_CM__LTE2866_001_Uncommissioned_HW_View_And_Dual_Single_Core_Commissioning
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...
    ...    TC for RAN_ET_LTE2866_001_CM_Uncommissioned HW view and Dual single core commissioning - ASIM.docx
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...  - 28.08.2023 - New TC create.

    Set Tags    CM    AUTHOR-bin.7.Liu@nokia-sbell.com    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    LOG    ${TEST_NAME} start.    console=${True}
    Log Variables
    Step 1: Power Reset SBTS
    Step 2: Check Sync And UnSync SMOD
    Step 3: Commission Secondary SMOD To Single Core
    Step 4: Commission Master SMOD To Single Core
    Step 5: Commission To Dual Core

CaseSetUp
    Set Test Variable    ${NEED_RECOVER}    ${False}
    Common Test Setup SBTS    scf_check=${FALSE}
    SBTS Admin Reset Configuration
    Set Test Variable    ${NEED_RECOVER}    ${True}

CaseTearDown
    LOG    TestTearDown    console=${True}
    ${time}    Get Time    epoch
    Run Keyword If Test Failed    Selenium2Library . Capture Page Screenshot    ${time}.png
    Selenium2Library . Close All Browsers
    Run Keyword If    ${NEED_RECOVER}
    ...    Admin Get bts_id and perform commissioning    ${COMMISSIONING_PATH}    ${SKIP_PARAM_RELATION_ERRORS}    timeout=600
    Run Keyword If    ${NEED_RECOVER}    Wait Until Keyword Succeeds    20 min    60 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Common Test Teardown SBTS

SBTS Admin Reset Configuration
    Log To Console    Starting Configuration Reset
    Run Keyword If    '${SMOD1['HW_TYPE']}'=='FSMF'    SBTS Admin Reset Configuration FSMF
    ...    ELSE    SBTS Admin Reset Configuration AirScale

Step ${index}: Power Reset SBTS
    Log To Console    Step ${index}: Power Reset SBTS
    FOR    ${dic_pdu}    IN    @{PDU}
        Power Off Via PB    ${dic_pdu}
    END
    Sleep    10s
    FOR    ${dic_pdu}    IN    @{PDU}
        Power On Via PB    ${dic_pdu}
    END
    Wait Until Keyword Succeeds    20x    30s    Check IP Is Pingable    192.168.255.129
    ${btsState}    Wait Until Keyword Succeeds    20x    30s    coam.Get Mrbts State    timeout=30s
    Should Be Equal As Strings    ${btsState}    NotCommissioned

Step ${index}: Check Sync And UnSync SMOD
    Log To Console    Step ${index}: Check Sync And UnSync SMOD
    SBTS WebEM Logon Uncommissioned SBTS    https://192.168.255.129
    Sync SMOD
    UnSync SMOD
    Reconnect WebEM

Step ${index}: Commission Secondary SMOD To Single Core
    Log To Console    Step ${index}: Commission Secondary SMOD To Single Core
    SSHLibrary.Open Connection    ${PC_IP2}
    SSHLibrary.Login    ute    uteUTE!
    ${tmp_cmd1}    Set Variable    -d /home/ute/test_results/CM__ET_LTE2866_001_On_Secondary_SMOD
    ${tmp_cmd2}    Set Variable    -v COMMISSIONING_RIGHT_CORE_PATH:${COMMISSIONING_RIGHT_CORE_PATH}
    ${base_dir}    Set Variable    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM
    ${tmp_cmd6}    Set Variable    ${base_dir}/RAN_PZ_HAZ_1/HAZ11/CM/CM__ET_LTE2866_001_On_Secondary_SMOD.robot
    SSHLibrary.Execute Command    source /home/ute/test_repo/bin/activate
    SSHLibrary.Execute Command    rm -rf /home/ute/test_results/CM__ET_LTE2866_001_On_Secondary_SMOD/*.*
    Log To Console    \nExecute command on ${PC_IP2}:\nrobot -L TRACE ${tmp_cmd1} ${tmp_cmd2} ${tmp_cmd6}
    SSHLibrary.Write    robot -L TRACE ${tmp_cmd1} ${tmp_cmd2} ${tmp_cmd6}
    Wait Until Keyword Succeeds    60m    30s
    ...    SSHLibrary.File Should Exist    /home/ute/test_results/CM__ET_LTE2866_001_On_Secondary_SMOD/log.html
    Log To Console    \nExecute command on ${PC_IP2} finised.
    ${target_log_file_path}    Set Variable    ${Test Results Dir}/TestFiles/
    SSHLibrary.Get File
    ...    /home/ute/test_results/CM__ET_LTE2866_001_On_Secondary_SMOD/log.html
    ...    ${target_log_file_path}CM__ET_LTE2866_001_On_Secondary_SMOD.html
    SSHLibrary.Get File    /home/ute/test_results/CM__ET_LTE2866_001_On_Secondary_SMOD/*.png    ${target_log_file_path}
    OperatingSystem.File Should Exist    ${target_log_file_path}CM__ET_LTE2866_001_On_Secondary_SMOD.html
    ${file_content}    OperatingSystem.Get File    ${target_log_file_path}CM__ET_LTE2866_001_On_Secondary_SMOD.html
    Should Contain    ${file_content}    "All Tests","pass":1

Step ${index}: Commission Master SMOD To Single Core
    Log To Console    Step ${index}: Commission Master SMOD To Single Core
    ${bts_id}    Admin Get BTS ID
    coam.Perform Commissioning    ${bts_id}    ${COMMISSIONING_LEFT_CORE_PATH}
    ...    skip_parameter_relation_errors=${SKIP_PARAM_RELATION_ERRORS}    timeout=${COMMISSIONING_TIMEOUT}
    Log    Commissioning done. Check BTS states will be performed    console=True
    Wait Until Keyword Succeeds    20 min    60 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    SBTS WEM Re-Logon
    SBTS WEM Open RunTime View    SV
    ${titles_elements}    SBTS WEM Filt Object On Navigation Panel Under Runtime View    SMOD-
    Should Be Equal As Integers    ${titles_elements.__len__()}    ${1}
    ${response}    Run Keyword And Return Status    coam.reset_configuration
    ...    reset_type=ConfigurationWithDiagnosticAndRecoverySw    timeout=300
    Wait Until Keyword Succeeds    10x    1m    fdswrc.Connect To    192.168.255.129    443    Nemuadmin
    ...    nemuuser    name=fdswcon
    ${sw_inventory}    fdswrc.Get All Software Inventory    connection=fdswcon
    Log To Console    ${sw_inventory}
    ${target_slot_id}    fdswrc.Get Active SW Partition    connection=fdswcon
    ${rollback_restType}    Get Proper Reset Type
    fdswrc.Software Rollback
    ...    sw_slot_id=${target_slot_id}    reset_type=${rollback_restType}    timeout=500    connection=fdswcon
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

Step ${index}: Commission To Dual Core
    Log To Console    Step ${index}: Commission To Dual Core
    Sync SMOD
    ${bts_id}    Admin Get BTS ID
    coam.Perform Commissioning    ${bts_id}    ${COMMISSIONING_PATH}
    ...    skip_parameter_relation_errors=${SKIP_PARAM_RELATION_ERRORS}    timeout=${COMMISSIONING_TIMEOUT}
    Log To Console    Commissioning done. Check BTS states will be performed
    Wait Until Keyword Succeeds    20 min    60 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    SBTS WEM Re-Logon
    SBTS WEM Open RunTime View    SV
    ${titles_elements}    SBTS WEM Filt Object On Navigation Panel Under Runtime View    SMOD-
    Should Be Equal As Integers    ${titles_elements.__len__()}    ${2}

Power Off Via PB
    [Arguments]    ${dic_pdu}
    pdu.setup_pdu    model=${dic_pdu["model"]}    host=${dic_pdu["IP"]}
    FOR    ${port}    IN    @{dic_pdu["ports"]}
        pdu.power_off    ${port}
    END
    Sleep    10s
    FOR    ${port}    IN    @{dic_pdu["ports"]}
        ${PDU_status}    PDU.get_port_status    port=${port}
        Should Be Equal    ${PDU_status}    off
    END
    [Teardown]    pdu.teardown_pdu

Power On Via PB
    [Arguments]    ${dic_pdu}
    pdu.setup_pdu    model=${dic_pdu["model"]}    host=${dic_pdu["IP"]}
    FOR    ${port}    IN    @{dic_pdu["ports"]}
        pdu.power_on    ${port}
    END
    Sleep    10s
    FOR    ${port}    IN    @{dic_pdu["ports"]}
        ${PDU_status}    PDU.get_port_status    port=${port}
        Should Be Equal    ${PDU_status}    on
    END
    [Teardown]    pdu.teardown_pdu

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