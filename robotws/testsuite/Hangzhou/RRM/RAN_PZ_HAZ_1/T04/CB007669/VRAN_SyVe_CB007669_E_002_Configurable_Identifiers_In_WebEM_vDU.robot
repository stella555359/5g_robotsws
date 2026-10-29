*** Settings ***
Documentation     author: Chu Jialiang
...               contact: bin.7.liu@nokia-sbell.com
...               Feature CB007669 in 5G_23R2 program
Resource          ../../Resources/Cloud/AIC_Common_Resource.robot

*** Keywords ***
VRAN_SyVe_CB007669_E_002_configurable_identifiers_in_WebEM_vDU
    [Documentation]
    ...    history change: <date>,<who>,<what and how>
    ...    28.12.2023, bin.7.liu@nokia-sbell.com ,
    ...    Transfer from BOAM ET case: VRAN_SyVe_CB007669_E_case2_Configurable_Identifiers_In_WebEM_vDU ,
    ...    Remove BOAM resource(aic_vdu_*.robot), replaced by tribe resource AIC_BTS.robot .
    Step1 Modify Cellname
    Step2 Block Cell-1 Via Webem
    Step3 Check Alarm For Cell-1
    Step4 Unblock Cell-1 Via Webem
    Step5 Check History Alarm For Cell-1
    Step6 Add AND Check PM Counter

Case Precondition
    log to console    Case Precondition deploy vDU and onair
    ${random_str}    Generate Random String    4    [LETTERS]
    set test variable    ${G_USER}    ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    set test variable    ${G_VDU_NAME}    ${tl.gnbs[0].dus[0].cloud_deployment.vnfs[0].name}
    set test variable    ${MRBTS_ID}    ${tl.gnbs[0].global_bts_id}
    set test variable    ${NRBTS_ID}    ${tl.gnbs[0].dus[0].instance_id}
    set test variable    ${WEBUI_URL}    ${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
    set test variable    ${SCF_FILE}    MRBTS_${MRBTS_ID}_scf_file.xml
    set test variable    ${cellname}    CB007669_E_Case2_${random_str}
    Common Test Setup For AIC
    Open WEBEM and Login    https://${WEBUI_URL}

Case Postcondition
    log to console    \n Case Postcondition
    @{para_list_du}    Create List    cellName
    @{mo_list_du}     Create List    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    @{value_list_du}    Create List    ${origin_value_du}
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list_du}    mo_list=@{mo_list_du}    value_list=@{value_list_du}
    Capture Page Screenshot
    Common Test Teardown For AIC
    Logout And Close WEBEM

Step1 Modify Cellname
    log to console    Step1 Modify Cellname
    vDU Login By Rest
    @{para_list_du}    Create List    cellName
    @{mo_list_du}     Create List    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    @{value_list_du}    Create List    ${cellname}
    ${out}    Parameter Operation    operation=parameter_value_check    product_type=vdu
    ...    para_list=@{para_list_du}    mo_list=@{mo_list_du}
    ${origin_value_du}    Set Variable    ${out["${mo_list_du[0]}"]["${para_list_du[0]}"]}
    Set Test Variable    ${origin_value_du}
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list_du}    mo_list=@{mo_list_du}    value_list=@{value_list_du}
    log to console    cellName online update successful
    ${out}    Parameter Operation    operation=parameter_value_check    product_type=vdu
    ...    para_list=@{para_list_du}    mo_list=@{mo_list_du}
    ${update_value_du}    Set Variable    ${out["${mo_list_du[0]}"]["${para_list_du[0]}"]}
    Should Be Equal As Strings    ${update_value_du}    ${cellname}

Step2 Block Cell-1 Via Webem
    log to console    Step3 Block Cell-1 Via Webem
    Go To Cell Status Page
    log to console    block cell-1
    Block Cell    cell_id=1

Step3 Check Alarm For Cell-1
    log to console    Step4 Check Alarm For Cell-1
    wait until keyword succeeds    1min    10s    Check Expected Alarms Is Appear
    Wait Element Visible And Click    locator=${DASHBOARD_SIDEBAR_ALARM}    time_out=1min
    Wait Element Visible And Click    locator=${ACTIVE_ALARMS}
    sleep    3s
    ${lineNumber}    Selenium2Library.get element count    //table//tr
    ${lineNumber}    evaluate    ${lineNumber}+1
    FOR    ${row}    IN RANGE    2    ${lineNumber}
        ${fault_id}    get table cell    xpath=//table    ${row}    5
        ${alarming_object}    get table cell    xpath=//table    ${row}    7
        run keyword if    """${fault_id}"""=="""49"""    should contain    ${alarming_object}    ${cellname}
    END
    log to console    fault 49 with cellname have been reported for cell-1

Step4 Unblock Cell-1 Via Webem
    log to console    Step5 Unblock Cell-1 Via Webem
    Go To Cell Status Page
    log to console    unblock cell-1
    Unblock Cell    cell_id=1
    sleep    5s

Step5 Check History Alarm For Cell-1
    log to console    Step6 Check History Alarm For Cell-1
    vDU Login By Rest
    ${vdu_get_historical_alarms}    vdu.vdu_get_historical_alarms
    ${alarm_list}    Get From Dictionary    ${vdu_get_historical_alarms}    alarms
    should contain    '@{alarm_list}'    'fault_id': '49'
    Wait Element Visible And Click    locator=${DASHBOARD_SIDEBAR_ALARM}    time_out=1min
    Wait Element Visible And Click    locator=${HISTORICAL_ALARMS}
    sleep    3s
    input text    //alarm-history-home//ui-webem-filter-input//input    49
    sleep    5s
    ${lineNumber}    Selenium2Library.get element count    //table//tr
    ${lineNumber}    evaluate    ${lineNumber}+1
    FOR    ${row}    IN RANGE    2    ${lineNumber}
        ${fault_id}    get table cell    xpath=//table    ${row}    6
        ${alarming_object}    get table cell    xpath=//table    ${row}    8
        run keyword if    """${fault_id}"""=="""49"""    should contain    ${alarming_object}    ${cellname}
    END
    log to console    fault 49 with cellname have been reported for cell-1

Step6 Add AND Check PM Counter
    log to console    Step7 Add AND Check PM Counter
    Wait Element Visible And Click    xpath=//i[contains(@class,'mdi-chart-bar')]    time_out=60s
    Wait Element Visible And Click    xpath=//span[contains(text(),'Select Counters')]    time_out=60s
    Wait Element Visible And Click    xpath=//span[contains(text(),'NRCELL')]    time_out=60s
    Wait Element Visible And Click    xpath=//span[contains(text(),'(NECUP)')]    time_out=60s
    Wait Element Visible And Click    xpath=//span[contains(text(),'M55318C00002')]
    Wait Element Visible And Click    xpath=//p[contains(text(),'NRCELL-1')]
    Wait Element Visible And Click    xpath=//span[contains(text(),'OK')]
    ${xpath}    set variable    //*[contains(text(),'[${cellname}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NECUP')]
    wait until element is visible    xpath=${xpath}    10s