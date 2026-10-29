*** Settings ***
Documentation
...    Note: Please DO NOT call functions in this file again, except some special functions. The suggsetion is to call
...          relevant  fuctions in DevNJ_sbts_keywords.py and DevNJ_ASIR_Selenium.py files.
...    Note: Please DO NOT call functions in this file again, except some special functions. The suggsetion is to call
...          relevant  fuctions in DevNJ_sbts_keywords.py and DevNJ_ASIR_Selenium.py files.
...    Note: Please DO NOT call functions in this file again, except some special functions. The suggsetion is to call
...          relevant  fuctions in DevNJ_sbts_keywords.py and DevNJ_ASIR_Selenium.py files.
...    author: Fuzeng Zhu
...    contact: fuzeng.zhu@nokia-sbell.com
...    Generic Robot keywords for OAM.

Library    taf.ul.sc.tl_config.TestLineConfiguration
Library    taf.gnb.oam.coam.admin   WITH NAME  admin
Library    taf.sbts.oam.coam.admin    WITH NAME    SbtsAdmin
Library    taf.ul.sc.asimgr.AsiMgr  WITH NAME  AsiMgr
Library    ../python/DevNJ_5GOAM_keywords.py
Library    ../python/DevNJ_DSS_keywords.py
Library    String
Library    Collections
Resource    ./DevNJ_5GOAM_keywords.robot
Resource    ./DevNJ_4GOAM_keywords.robot
Resource    taf/rfrl/common_resources/robot/coam.robot
Library    ../python/DevNJ_ASIR_Selenium.py
*** Keywords ***


Check Xp Link Status
    [Documentation]  Check Xp Link Status
    ...  Description: Check Xp Link Status, by judge the status
    ...  Arguments:
    ...     _xp_name_: The XPIF shown on the WebEM Site View, default value is XPIFREMOTE_R-1
    ...     _xp_status_: The XP link status, on the WebEM site View, default value is available
    ...     _virtual_enable_: If using virtual display, default value is ${TRUE}
    ...
    ...  Examples:
    ...  | Check Xp Link Status | xp_name=XPIFREMOTE_R-1 | xp_status=available | virtual_enable=${FALSE} |
    ...    Return value:
    ...    - None
    [Arguments]    ${xp_name}=XPIFREMOTE_R-1  ${xp_status}=available  ${virtual_enable}=${TRUE}
    WebEM Login  virtual_enable=${virtual_enable}
    Log To Console  Try to get_hw_info ${xp_name}
    ${xp_info}  selenium_coam.get_hw_info  hw_name=${xp_name}
    Log To Console  XP Link Info:${xp_info}
    Log To Console  XP link status:${xp_info['XP link status']}, should be ${xp_status}
    Should Be Equal   ${xp_info['XP link status']}  ${xp_status}
    [Teardown]  WebEM Logout  virtual_enable=${virtual_enable}

Get LTE DSS Cell ID From NR Cell ID
    [Documentation]  Get LTE DSS Cell ID From NR Cell ID
    ...  Description: Get LTE DSS Cell ID From a given 5G NR Cell ID, and return the LTE DSS cell ID
    ...  Arguments:
    ...     _cell_id_: 5G DSS cell ID
    ...     _virtual_enable_: If using virtual display, default value is ${TRUE}
    ...  Examples:
    ...  | Get LTE DSS Cell ID From NR Cell ID | cell_id=1 | virtual_enable=${FALSE} |
    ...    Return value:
    ...    - None
    [Arguments]    ${cell_id}  ${virtual_enable}=${TRUE}
    WebEM Login  virtual_enable=${virtual_enable}
    ${MRBTS_ID}  Set Variable  MRBTS-${tl.gnbs[0].instance_id}
    ${NRBTS_ID}  Set Variable  NRBTS-${tl.gnbs[0].global_bts_id}
    ${lcrId}  selenium_coam.get_parameter_value  dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_id}/NRDSSLTE-1
    ...  filter_param=Local cell resource ID    abbr=lcrId
    [Return]  ${lcrId}
    [Teardown]  WebEM Logout  virtual_enable=${virtual_enable}

Lock 5G Cell
    [Documentation]  Lock 5G Cell
    ...  Description: Lock 5G Cell via Selenium
    ...  Arguments:
    ...     _cell_id_: 5G cell ID list, string or an array
    ...     _virtual_enable_: If using virtual display, default value is ${TRUE}
    ...  Examples:
    ...  Example 1:
    ...  | Lock 5G Cell | cell_id=1 2 3 | virtual_enable=${FALSE} |
    ...  Example 2:
    ...  | @{cell_id_list} | create list   1  2  3 |
    ...  | Lock 5G Cell | cell_id=${cell_id_list} | virtual_enable=${FALSE} |
    ...    Return value:
    ...    - None
    [Arguments]    ${cell_id}  ${virtual_enable}=${TRUE}
    ${is_cell_id_list}  Evaluate  isinstance($cell_id,list)
    ${cell_id_list}  run keyword if   ${is_cell_id_list}==${FALSE}  string.split string  ${cell_id}
    ${cell_id_list}  set variable if   ${cell_id_list} is ${None}    ${cell_id}    ${cell_id_list}
    log to console  cell_id_list ${cell_id_list}

    WebEM Login  virtual_enable=${virtual_enable}
    FOR  ${c_id}  IN  @{cell_id_list}
        Log To Console  Try to lock cell ${c_id}
        Run Keyword and Continue On Failure   selenium_coam.block_cell  cell_idx=${c_id}
    END

    [Teardown]  WebEM Logout  virtual_enable=${virtual_enable}

Unlock 5G Cell
    [Documentation]  Unlock 5G Cell
    ...  Description: Unlock 5G Cell via Selenium
    ...  Arguments:
    ...     _cell_id_: 5G cell ID list, string or an array
    ...     _virtual_enable_: If using virtual display, default value is ${TRUE}
    ...  Examples:
    ...  Example 1:
    ...  | Unlock 5G Cell | cell_id=1 2 3 | virtual_enable=${FALSE} |
    ...  Example 2:
    ...  | @{cell_id_list} | create list   1  2  3 |
    ...  | Unlock 5G Cell | cell_id=${cell_id_list} | virtual_enable=${FALSE} |
    ...    Return value:
    ...    - None
    [Arguments]    ${cell_id}  ${virtual_enable}=${TRUE}
    ${is_cell_id_list}  Evaluate  isinstance($cell_id,list)
    ${cell_id_list}  run keyword if   ${is_cell_id_list}==${FALSE}  string.split string  ${cell_id}
    ${cell_id_list}  set variable if   ${cell_id_list} is ${None}    ${cell_id}    ${cell_id_list}
    log to console  cell_id_list ${cell_id_list}

    WebEM Login  virtual_enable=${virtual_enable}
    FOR  ${c_id}  IN  @{cell_id_list}
        Log To Console  Try to unlock cell ${c_id}
        Run Keyword and Continue On Failure  selenium_coam.unblock_cell  cell_idx=${c_id}
    END
    [Teardown]  WebEM Logout  virtual_enable=${virtual_enable}

Lock LTE Cell
    [Documentation]  Lock LTE cell
    ...  Description: Lock LTE Cell via Selenium, need to specify the LTE WebEM IP
    ...  Arguments:
    ...     _lte_webem_ip_: LTE WebEM IP on 5G ute, usually be 172.30.1.10
    ...     _cell_id_: 5G cell ID list, string or an array
    ...     _virtual_enable_: If using virtual display, default value is ${TRUE}
    ...  Examples:
    ...  Example 1:
    ...  | Lock LTE Cell | lte_webem_ip=172.30.1.10 | cell_id=1 2 3 |  virtual_enable=${FALSE} |
    ...  Example 2:
    ...  | @{cell_id_list} | create list   1  2  3 |
    ...  |  Lock LTE Cell | lte_webem_ip=172.30.1.10 | cell_id=${cell_id_list} | virtual_enable=${FALSE} |
    ...    Return value:
    ...    - None
    [Arguments]      ${lte_webem_ip}  ${cell_id}  ${virtual_enable}=${TRUE}
    ${is_cell_id_list}  Evaluate  isinstance($cell_id,list)
    ${cell_id_list}  run keyword if   ${is_cell_id_list}==${FALSE}  string.split string  ${cell_id}
    ${cell_id_list}  set variable if   ${cell_id_list} is ${None}    ${cell_id}    ${cell_id_list}
    log to console  cell_id_list ${cell_id_list}

    WebEM Login  webem_ip=${lte_webem_ip}  virtual_enable=${virtual_enable}
    FOR  ${c_id}  IN  @{cell_id_list}
        Log To Console  Try to lock cell ${c_id}
        Run Keyword and Continue On Failure   selenium_coam.block_cell  cell_idx=${c_id}  technology=LTE
    END
    [Teardown]  WebEM Logout    virtual_enable=${virtual_enable}

Unlock LTE Cell
    [Documentation]  Unlock LTE cell
    ...  Description: Unlock LTE Cell via Selenium, need to specify the LTE WebEM IP
    ...  Arguments:
    ...     _lte_webem_ip_: LTE WebEM IP on 5G ute, usually be 172.30.1.10
    ...     _cell_id_: 5G cell ID list, string or an array
    ...     _virtual_enable_: If using virtual display, default value is ${TRUE}
    ...  Examples:
    ...  Example 1:
    ...  | Unlock LTE Cell | lte_webem_ip=172.30.1.10 | cell_id=1 2 3 |  virtual_enable=${FALSE} |
    ...  Example 2:
    ...  | @{cell_id_list} | create list   1  2  3 |
    ...  |  Unlock LTE Cell | lte_webem_ip=172.30.1.10 | cell_id=${cell_id_list} | virtual_enable=${FALSE} |
    ...    Return value:
    ...    - None
    [Arguments]      ${lte_webem_ip}  ${cell_id}  ${virtual_enable}=${TRUE}
    ${is_cell_id_list}  Evaluate  isinstance($cell_id,list)
    ${cell_id_list}  run keyword if   ${is_cell_id_list}==${FALSE}  string.split string  ${cell_id}
    ${cell_id_list}  set variable if   ${cell_id_list} is ${None}    ${cell_id}    ${cell_id_list}
    log to console  cell_id_list ${cell_id_list}

    WebEM Login  webem_ip=${lte_webem_ip}  virtual_enable=${virtual_enable}
    FOR  ${c_id}  IN  @{cell_id_list}
        Log To Console  Try to unlock cell ${c_id}
        Run Keyword and Continue On Failure   selenium_coam.unblock_cell  cell_idx=${c_id}  technology=LTE
    END
    [Teardown]  WebEM Logout    virtual_enable=${virtual_enable}

Check Cell Alarm
    [Documentation]  Check Cell Alarm Appear or disappear
    ...  Description: Check Cell Alarm, by specify cell id, alarm filter and a flag for appear/disappear
    ...  Arguments:
    ...     _cell_id_:  cell ID
    ...     _alarm_filter_: usually alarm id for a cell alarm
    ...     _should_appear_: bool flag, indicates whether the alarm should appear or not
    ...     _virtual_enable_: If using virtual display, default value is ${TRUE}
    ...  Examples:
    ...  Example 1:
    ...  | Check Cell Alarm | cell_id=1 | alarm_filter=7401 | should_appear=${TRUE} | virtual_enable=${FALSE} |
    ...  Example 2:
    ...  | Check Cell Alarm | cell_id=2 | alarm_filter=major | should_appear=${FALSE} | virtual_enable=${FALSE} |
    ...    Return value:
    ...    - None
    [Arguments]    ${cell_id}  ${alarm_filter}  ${should_appear}
    ${alarms}   selenium_coam.get_active_alarm_info    ${alarm_filter}
    Log To Console  All Alarm List: ${alarms}
    ${alarms_of_the_cell}  Create List
    FOR   ${alarm}   IN   @{alarms}
        ${alarm_belong_to_cell}  is_alarm_belong_to_cell  ${alarm}  ${cell_id}
        run keyword if  ${alarm_belong_to_cell}  Append To List  ${alarms_of_the_cell}  ${alarm}
    END
    Log To Console  Cell ${cell_id} Alarm List: ${alarms_of_the_cell}
    run keyword if   ${should_appear}  Should Not Be Empty   ${alarms_of_the_cell}
    ...  ELSE  Should Be Empty   ${alarms_of_the_cell}

Loop Check Cell Alarm
    [Arguments]  ${cell_id_list}  ${alarm_filter}  ${should_appear}  ${virtual_enable}
    FOR  ${c_id}  IN  @{cell_id_list}
        Log To Console  Check Cell Alarm ${c_id}
        Run Keyword and Continue On Failure
        ...  Check Cell Alarm  cell_id=${c_id}  alarm_filter=${alarm_filter}  should_appear=${should_appear}
    END

Check 5G Cell Alarm Appear
    [Documentation]  Check 5G Cell Alarm Appear
    ...  Description: Check 5G Cell Alarm Appear, by specify cell id, alarm filter and timeout seconds for alarm appear
    ...  Arguments:
    ...     _cell_id_:  cell ID
    ...     _alarm_filter_: usually alarm id for a cell alarm
    ...     _timeout_: timeout seconds, during that the alarm should appear
    ...     _virtual_enable_: If using virtual display, default value is ${TRUE}
    ...  Examples:
    ...  Example 1:
    ...  | Check 5G Cell Alarm Appear | cell_id=1 2 3 | alarm_filter=7114 | timeout=60 | virtual_enable=${FALSE} |
    ...  Example 2:
    ...  | @{cell_id_list} | create list   1  2  3 |
    ...  | Check 5G Cell Alarm Appear | cell_id=${cell_id} | alarm_filter=7114 | timeout=60 |virtual_enable=${FALSE} |
    ...    Return value:
    ...    - None
    [Arguments]    ${cell_id}  ${alarm_filter}=7114  ${timeout}=60  ${virtual_enable}=${TRUE}
    ${is_cell_id_list}  Evaluate  isinstance($cell_id,list)
    ${cell_id_list}  run keyword if   ${is_cell_id_list}==${FALSE}  string.split string  ${cell_id}
    ${cell_id_list}  set variable if   ${cell_id_list} is ${None}    ${cell_id}    ${cell_id_list}
    log to console  cell_id_list ${cell_id_list}
    WebEM Login  virtual_enable=${virtual_enable}
    Wait Until Keyword Succeeds  ${timeout}s  2s  Run Keyword  Loop Check Cell Alarm
    ...   cell_id_list=${cell_id_list}  alarm_filter=${alarm_filter}  should_appear=${TRUE}  virtual_enable=${virtual_enable}
    [Teardown]  WebEM Logout  virtual_enable=${virtual_enable}

Check 5G Cell Alarm Disappear
    [Documentation]  Check 5G Cell Alarm Disappear
    ...  Description: Check 5G Cell Alarm Disappear, by specify cell id, alarm filter and timeout seconds for alarm Disappear
    ...  Arguments:
    ...     _cell_id_:  cell ID
    ...     _alarm_filter_: usually alarm id for a cell alarm
    ...     _timeout_: timeout seconds, during that the alarm should Disappear
    ...     _virtual_enable_: If using virtual display, default value is ${TRUE}
    ...  Examples:
    ...  Example 1:
    ...  | Check 5G Cell Alarm Disappear | cell_id=1 2 3 | alarm_filter=7114 | timeout=60 | virtual_enable=${FALSE} |
    ...  Example 2:
    ...  | @{cell_id_list} | create list   1  2  3 |
    ...  | Check 5G Cell Alarm Disappear | cell_id=${cell_id} | alarm_filter=7114 | timeout=60 | virtual_enable=${FALSE} |
    ...    Return value:
    ...    - None
    [Arguments]    ${cell_id}  ${alarm_filter}=7114  ${timeout}=60  ${virtual_enable}=${TRUE}
    ${is_cell_id_list}  Evaluate  isinstance($cell_id,list)
    ${cell_id_list}  run keyword if   ${is_cell_id_list}==${FALSE}  string.split string  ${cell_id}
    ${cell_id_list}  set variable if   ${cell_id_list} is ${None}    ${cell_id}    ${cell_id_list}
    log to console  cell_id_list ${cell_id_list}
    WebEM Login  virtual_enable=${virtual_enable}
    Wait Until Keyword Succeeds  ${timeout}s  2s  Run Keyword  Loop Check Cell Alarm
    ...   cell_id_list=${cell_id_list}  alarm_filter=${alarm_filter}  should_appear=${FALSE}  virtual_enable=${virtual_enable}
    [Teardown]  WebEM Logout  virtual_enable=${virtual_enable}

Check LTE Cell Alarm Appear
    [Documentation]  Check LTE Cell Alarm Appear
    ...  Description: Check LTE Cell Alarm Appear, by specify LTE WebEM IP, cell id, alarm filter and timeout seconds for alarm appear
    ...  Arguments:
    ...     _lte_webem_ip_: LTE WebEM IP on 5G ute, usually be 172.30.1.10
    ...     _cell_id_:  cell ID
    ...     _alarm_filter_: usually alarm id for a cell alarm
    ...     _timeout_: timeout seconds, during that the alarm should appear
    ...     _virtual_enable_: If using virtual display, default value is ${TRUE}
    ...  Examples:
    ...  | Check LTE Cell Alarm Appear | cell_id=1 2 3 | alarm_filter=7114 | timeout=60 | virtual_enable=${FALSE} |
    ...  Example 2:
    ...  | @{cell_id_list} | create list   1  2  3 |
    ...  | Check LTE Cell Alarm Appear | cell_id=${cell_id} | alarm_filter=7114 | timeout=60 | virtual_enable=${FALSE} |
    ...    Return value:
    ...    - None
    [Arguments]   ${lte_webem_ip}  ${cell_id}  ${alarm_filter}=7665  ${timeout}=60  ${virtual_enable}=${TRUE}
    ${is_cell_id_list}  Evaluate  isinstance($cell_id,list)
    ${cell_id_list}  run keyword if   ${is_cell_id_list}==${FALSE}  string.split string  ${cell_id}
    ${cell_id_list}  set variable if   ${cell_id_list} is ${None}    ${cell_id}    ${cell_id_list}
    log to console  cell_id_list ${cell_id_list}
    WebEM Login  webem_ip=${lte_webem_ip}  virtual_enable=${virtual_enable}
    Wait Until Keyword Succeeds  ${timeout}s  2s  Run Keyword  Loop Check Cell Alarm
    ...   cell_id_list=${cell_id_list}  alarm_filter=${alarm_filter}  should_appear=${TRUE}  virtual_enable=${virtual_enable}
    [Teardown]  WebEM Logout  virtual_enable=${virtual_enable}

Check LTE Cell Alarm Disappear
     [Documentation]  Check LTE Cell Alarm Disappear
    ...  Description: Check LTE Cell Alarm Disappear, by specify LTE WebEM IP, cell id, alarm filter and timeout seconds for alarm disappear
    ...  Arguments:
    ...     _lte_webem_ip_: LTE WebEM IP on 5G ute, usually be 172.30.1.10
    ...     _cell_id_:  cell ID
    ...     _alarm_filter_: usually alarm id for a cell alarm
    ...     _timeout_: timeout seconds, during that the alarm should disappear
    ...     _virtual_enable_: If using virtual display, default value is ${TRUE}
    ...  Examples:
    ...  | Check LTE Cell Alarm Disappear | cell_id=1 2 3 | alarm_filter=7114 | timeout=60 | virtual_enable=${FALSE} |
    ...  Example 2:
    ...  | @{cell_id_list} | create list   1  2  3 |
    ...  | Check LTE Cell Alarm Disappear | cell_id=${cell_id} | alarm_filter=7114 | timeout=60 | virtual_enable=${FALSE} |
    ...    Return value:
    ...    - None
    [Arguments]   ${lte_webem_ip}  ${cell_id}  ${alarm_filter}=7665  ${timeout}=60  ${virtual_enable}=${TRUE}
    ${is_cell_id_list}  Evaluate  isinstance($cell_id,list)
    ${cell_id_list}  run keyword if   ${is_cell_id_list}==${FALSE}  string.split string  ${cell_id}
    ${cell_id_list}  set variable if   ${cell_id_list} is ${None}    ${cell_id}    ${cell_id_list}
    log to console  cell_id_list ${cell_id_list}
    WebEM Login  webem_ip=${lte_webem_ip}  virtual_enable=${virtual_enable}
    Wait Until Keyword Succeeds  ${timeout}s  2s  Run Keyword  Loop Check Cell Alarm
    ...   cell_id_list=${cell_id_list}  alarm_filter=${alarm_filter}  should_appear=${FALSE}  virtual_enable=${virtual_enable}
    [Teardown]  WebEM Logout  virtual_enable=${virtual_enable}

Check Parameter Value
    [Documentation]  Check Parameter Value via WebEm, judge if the parameter value is equal to expected
    ...  Private keyword, not used directly by test case
    ...
    ...  Arguments:
    ...     _dist_name_: dist name in WebEm parameter editor panel
    ...     _filter_param_:  Parameter full name
    ...     _abbr_: parameter abbr
    ...     _expected_value_: expected value of the parameter
    ...
    ...  Examples:
    ...  | Check Parameter Value | dist_name=MRBTS-34861/LNBTS-34861/LNCEL-2/DSSNR-0/CRMINFO-0 | filter_param=Status of Common Resource Manager |
    ...  ...  abbr=crmStatus | expected_value=running |
    ...    Return value:
    ...    - None
    [Arguments]   ${dist_name}  ${filter_param}  ${abbr}  ${expected_value}
    ${real_value}   selenium_coam.get_parameter_value   dist_name=${dist_name}
        ...  filter_param=${filter_param}   abbr=${abbr}
    Log To Console  ${dist_name} parameter real value is ${real_value} expected value is ${expected_value}
    Should be Equal As Strings      ${real_value}     ${expected_value}      ignore_case=${TRUE}


Loop Check CRM Status
    [Arguments]  ${cell_id_list}  ${MRBTS_ID}  ${LNBTS_ID}  ${expected_status}
    FOR  ${c_id}  IN  @{cell_id_list}
        Log To Console  Check Cell Alarm ${c_id}
        Run Keyword and Continue On Failure  Check Parameter Value  dist_name=${MRBTS_ID}/${LNBTS_ID}/LNCEL-${c_id}/DSSNR-0/CRMINFO-0
        ...   filter_param=Status of Common Resource Manager  abbr=crmStatus  expected_value=${expected_status}
    END

Check LTE Cell CRM Status
    [Documentation]  Check LTE Cell CRM Status
    ...  Description: Check LTE Cell CRM Status, if the CRM status turn to be running in given timeout seconds, means the dss ok
    ...  *Notice: in Test Line __init__.py, need specify the eNB BTS ID like below *
    ...  *_lteenb = RealEnb(x2_link_addr=NetworkAddress(v4="172.30.1.10"), instance_id=34851, global_bts_id=34851) *
    ...
    ...  Arguments:
    ...     _lte_webem_ip_: LTE WebEM IP on 5G ute, usually be 172.30.1.10
    ...     _cell_id_:  cell ID list, string or an array
    ...     _expected_status_: expected status of CRM, running startup or failure
    ...     _timeout_: timeout seconds, during that the CRM status should turn to be expected
    ...     _virtual_enable_: If using virtual display, default value is ${TRUE}
    ...
    ...  Examples:
    ...  Example 1:
    ...  | Check LTE Cell CRM Status | lte_webem_ip=172.30.1.10 | cell_id=1 2 3 | expected_status=running | timeout=60 | virtual_enable=${FALSE} |
    ...  Example 2:
    ...  | @{cell_id_list} | create list   1  2  3 |
    ...  | Check LTE Cell CRM Status | lte_webem_ip=172.30.1.10 | cell_id=${cell_id_list} | expected_status=running | timeout=60 |
    ...  | virtual_enable=${FALSE} |
    ...    Return value:
    ...    - None
    [Arguments]   ${lte_webem_ip}  ${cell_id}  ${expected_status}  ${timeout}=60  ${virtual_enable}=${TRUE}
    ${MRBTS_ID}  Set Variable  MRBTS-${tl.enbs[0].instance_id}
    ${LNBTS_ID}  Set Variable  LNBTS-${tl.enbs[0].global_bts_id}
    ${is_cell_id_list}  Evaluate  isinstance($cell_id,list)
    ${cell_id_list}  run keyword if   ${is_cell_id_list}==${FALSE}  string.split string  ${cell_id}
    ${cell_id_list}  set variable if   ${cell_id_list} is ${None}    ${cell_id}    ${cell_id_list}
    log to console  cell_id_list ${cell_id_list}
    WebEM Login  webem_ip=${lte_webem_ip}  virtual_enable=${virtual_enable}

    Wait Until Keyword Succeeds  ${timeout}s  2s  Run Keyword  Loop Check CRM Status
    ...   cell_id_list=${cell_id_list}  MRBTS_ID=${MRBTS_ID}  LNBTS_ID=${LNBTS_ID}  expected_status=${expected_status}

    [Teardown]  WebEM Logout  virtual_enable=${virtual_enable}


Check 5G Cell Availability Status
    [Documentation]  Check 5G Cell Availability Status
    ...  Description: Check 5G Cell Availability Status, by specify cell id, and avaiability status
    ...
    ...  Arguments:
    ...     _cell_id_:  cell ID list, string or an array
    ...     _avail_status_: availability status expected, Online or Degraded
    ...     _virtual_enable_: If using virtual display, default value is ${TRUE}
    ...  Examples:
    ...  Example 1:
    ...  | Check 5G Cell Availability Status | cell_id=1 2 3 | avail_status=Degraded | virtual_enable=${FALSE} |
    ...  Example 2:
    ...  | Check 5G Cell Availability Status | cell_id=1 2 3 | avail_status=Online | virtual_enable=${FALSE} |
    ...  Example 3:
    ...  | @{cell_id_list} | create list   1  2  3 |
    ...  | Check 5G Cell Availability Status | cell_id=${cell_id_list} | avail_status=Online | virtual_enable=${FALSE} |
    ...    Return value:
    ...    - None
    [Arguments]    ${cell_id}  ${avail_status}   ${virtual_enable}=${TRUE}
    ${is_cell_id_list}  Evaluate  isinstance($cell_id,list)
    ${cell_id_list}  run keyword if   ${is_cell_id_list}==${FALSE}  string.split string  ${cell_id}
    ${cell_id_list}  set variable if   ${cell_id_list} is ${None}    ${cell_id}    ${cell_id_list}
    log to console  cell_id_list ${cell_id_list}

    ${avail_status}  Convert To Lower Case  ${avail_status}
    WebEM Login  virtual_enable=${virtual_enable}
    FOR  ${c_id}  IN  @{cell_id_list}
        Log To Console  Try to get_cell_info of cell ${c_id}
        ${cell_info}  selenium_coam.get_cell_info  cell_idx=${c_id}
        ${cell_status}  Set Variable  ${cell_info['Status']}

        ${flag}  ${cell_status['Availability status']}  Run Keyword And Ignore Error  Get From Dictionary  ${cell_status}  Availability status
        ${cell_status['Availability status']}  Run keyword If  '${flag}'=='FAIL'  Set Variable  online
        ...    ELSE  Set Variable  ${cell_status['Availability status']}
        ${cell_status}  Set Variable  ${cell_status['Availability status']}
        ${cell_status}  Convert To Lower Case  ${cell_status}
        ${cell_status}  Run keyword If  '${cell_status}'=='-'  Set Variable  online
        ...    ELSE IF  '${cell_status}'==''  Set Variable  online
        ...    ELSE  Set Variable  ${cell_status}
        Log To Console  cell ${c_id} Status:${cell_status}
        Run Keyword and Continue On Failure  Should Be Equal   ${cell_status}  ${avail_status}
    END
    [Teardown]  WebEM Logout  virtual_enable=${virtual_enable}

Check LTE Cell Availability Status
    [Documentation]  Check LTE Cell Availability Status
    ...  Description: Check LTE Cell Availability Status, by specify cell id, and avaiability status
    ...
    ...  Arguments:
    ...     _lte_webem_ip_: LTE WebEM IP on 5G ute, usually be 172.30.1.10
    ...     _cell_id_:  cell ID
    ...     _avail_status_: availability status expected, Online or Degraded
    ...     _virtual_enable_: If using virtual display, default value is ${TRUE}
    ...  Examples:
    ...  Example 1:
    ...  | Check LTE Cell Availability Status | lte_webem_ip=172.30.1.10 | cell_id=1 2 3| avail_status=Degraded | virtual_enable=${FALSE} |
    ...  Example 2:
    ...  | Check LTE Cell Availability Status | lte_webem_ip=172.30.1.10 | cell_id=1 2 3 | avail_status=Online | virtual_enable=${FALSE} |
    ...  Example 3:
    ...  | @{cell_id_list} | create list   1  2  3 |
    ...  | Check LTE Cell Availability Status | lte_webem_ip=172.30.1.10 | cell_id=${cell_id_list} | avail_status=Online | virtual_enable=${FALSE} |
    ...    Return value:
    ...    - None
    [Arguments]    ${lte_webem_ip}  ${cell_id}  ${avail_status}   ${virtual_enable}=${TRUE}
    ${is_cell_id_list}  Evaluate  isinstance($cell_id,list)
    ${cell_id_list}  run keyword if   ${is_cell_id_list}==${FALSE}  string.split string  ${cell_id}
    ${cell_id_list}  set variable if   ${cell_id_list} is ${None}    ${cell_id}    ${cell_id_list}
    log to console  cell_id_list ${cell_id_list}

    ${avail_status}  Convert To Lower Case  ${avail_status}
    WebEM Login  webem_ip=${lte_webem_ip}  virtual_enable=${virtual_enable}
    FOR  ${c_id}  IN  @{cell_id_list}
        Log To Console  Try to get_cell_info of cell ${c_id}
        ${cell_info}  selenium_coam.get_cell_info  cell_idx=${c_id}  technology=LTE
        ${cell_status}  Set Variable  ${cell_info['Status']}

        ${flag}  ${cell_status['Availability status']}  Run Keyword And Ignore Error  Get From Dictionary  ${cell_status}  Availability status
        ${cell_status['Availability status']}  Run keyword If  '${flag}'=='FAIL'  Set Variable  online
        ...    ELSE  Set Variable  ${cell_status['Availability status']}
        ${cell_status}  Set Variable  ${cell_status['Availability status']}
        ${cell_status}  Convert To Lower Case  ${cell_status}
        ${cell_status}  Run keyword If  '${cell_status}'=='-'  Set Variable  online
        ...    ELSE IF  '${cell_status}'==''  Set Variable  online
        ...    ELSE  Set Variable  ${cell_status}
        Log To Console  cell ${c_id} Status:${cell_status}
        Run Keyword and Continue On Failure  Should Be Equal   ${cell_status}  ${avail_status}
    END
    [Teardown]  WebEM Logout  virtual_enable=${virtual_enable}

Reset Site 5G
    [Documentation]  Reset Site 5G
    ...  Description: Reset Site 5G
    ...  Arguments:
    ...     virtual_enable: If using virtual display, default value is ${TRUE}
    ...  Example:
    ...  Reset Site 5G   virtual_enable=${FALSE}
    [Arguments]   ${virtual_enable}=${TRUE}
    WebEM Login  virtual_enable=${virtual_enable}
    selenium_coam.reset_site
    [Teardown]  WebEM Logout  virtual_enable=${virtual_enable}

Reset Site LTE
    [Documentation]  Reset Site LTE
    ...  Description: Reset Site LTE, by give a LTE WebEM IP
    ...  Arguments:
    ...     lte_webem_ip: LTE WebEM IP on 5G ute, usually be 172.30.1.10
    ...     virtual_enable: If using virtual display, default value is ${TRUE}
    ...  Example:
    ...  Reset Site LTE  lte_webem_ip=172.30.1.10   virtual_enable=${FALSE}
    [Arguments]   ${lte_webem_ip}  ${virtual_enable}=${TRUE}
    WebEM Login  webem_ip=${lte_webem_ip}  virtual_enable=${virtual_enable}
    selenium_coam.reset_site
    [Teardown]  WebEM Logout  virtual_enable=${virtual_enable}


LTE WebEM ValidateAndActiveParameters
    [Documentation]  LTE WebEM ValidateAndActiveParameters
    ...  Description: LTE WebEM Validate and Activate Parameters
    ...  Because the LTE WebEM's behavior differs from that of 5G WebEm, so can not reuse
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    Log To Console  lte_activate_plan_click_button_execute
    lte_activate_plan_click_button_execute


ASIR Manager Sync For DSS
    [Documentation]  ASIR Manager Sync For DSS
    ...  Description: ASIR Manager Sync For DSS, due to for DSS there are more than 1 BTS IDs need to be filled into HUBMODs
    ...  Arguments:
    ...     virtual_enable: If using virtual display, default value is ${TRUE}
    [Arguments]     ${virtual_enable}=${TRUE}
    Log To Console  Asir Mgr Sync Configuration
    ${WEBUI_USERNAME}  Set Variable   ${tl.gnbs[0].cu.oam_http_connection_details.username}
    ${WEBUI_PASSWORD}  Set Variable  ${tl.gnbs[0].cu.oam_http_connection_details.password}
    ${WEBUI_URL}  Set Variable  https://${tl.gnbs[0].cu.oam_http_connection_details.addr}

    SbtsAdmin.Setup Admin
    ${load_release}  SbtsAdmin.Get Sw Release Name
    SbtsAdmin.Teardown
    ${sync_res}  Run Keyword If  '${load_release}' == 'SBTS22R2' or '${load_release}' == 'SBTS22R1'
    ...   Run Keyword  selenium_asir_webem_sync_dss  ${WEBUI_URL}  ${WEBUI_USERNAME}  ${WEBUI_PASSWORD}   ${virtual_enable}
    ...   ELSE  Run Keyword  selenium_asir_webem_sync  ${WEBUI_URL}  ${WEBUI_USERNAME}  ${WEBUI_PASSWORD}  ${virtual_enable}

    Log To Console  ASIR Manager Sync Result: ${sync_res}
    Should Be True  ${sync_res['res']}


ASIR Manager Sync For DSS Directly
    [Documentation]  ASIR Manager Sync For DSS
    ...  Description: ASIR Manager Sync For DSS, due to for DSS there are more than 1 BTS IDs need to be filled into HUBMODs
    ...  Arguments:
    ...     virtual_enable: If using virtual display, default value is ${TRUE}
    [Arguments]     ${virtual_enable}=${TRUE}
    Log To Console  Asir Mgr Sync Configuration
    ${WEBUI_USERNAME}  Set Variable   ${tl.gnbs[0].cu.oam_http_connection_details.username}
    ${WEBUI_PASSWORD}  Set Variable  ${tl.gnbs[0].cu.oam_http_connection_details.password}
    ${WEBUI_URL}  Set Variable  https://${tl.gnbs[0].cu.oam_http_connection_details.addr}

    DevNJ_ASIR_Selenium.clean_browser
    DevNJ_ASIR_Selenium.set_virtual_enable   ${virtual_enable}
    DevNJ_ASIR_Selenium.login  url=${WEBUI_URL}:3601  user_name=${WEBUI_USERNAME}  user_password=${WEBUI_PASSWORD}
    DevNJ_ASIR_Selenium.enter_config_man   overwrite=$True

    SbtsAdmin.Setup Admin
    ${load_release}  SbtsAdmin.Get Sw Release Name
    SbtsAdmin.Teardown
    ${sync_res}  Run Keyword If  '${load_release}' == 'SBTS22R2' or '${load_release}' == 'SBTS22R1'
    ...   Run Keyword  DevNJ_ASIR_Selenium.sync_config_with_gnb_dss
    ...   ELSE  Run Keyword  DevNJ_ASIR_Selenium.sync_config_with_gnb

    Should Be True  ${sync_res['res']}
    [Teardown]  DevNJ_ASIR_Selenium.logout

LTE Delete Cell
    [Documentation]  LTE Delete Cell
    ...  Description: LTE Delete a cell, according to a given cell id
    ...  Arguments:
    ...     webem_ip: LTE WebEM IP on 5G ute, usually be 172.30.1.10
    ...     cell_id:  cell ID
    ...     virtual_enable: If using virtual display, default value is ${TRUE}
    ...  Example 1: LTE Delete Cell 2, showing internet explorer procdure for debug
    ...    LTE Delete Cell  webem_ip=172.30.1.10  cell_id=2  virtual_enable=${FALSE}
    ...  Example 2: LTE Delete Cell 2, without virtual display
    ...    LTE Delete Cell  webem_ip=172.30.1.10  cell_id=2  virtual_enable=${TRUE}
    [Arguments]    ${webem_ip}   ${cell_id}   ${virtual_enable}=${TRUE}
    ${MRBTS_ID}  Set Variable  MRBTS-${tl.gnbs[0].instance_id}
    ${NRBTS_ID}  Set Variable  NRBTS-${tl.gnbs[0].global_bts_id}
    WebEM Login   webem_ip=${webem_ip}  virtual_enable=${virtual_enable}
    selenium_coam.remove_object    object_name=${MRBTS_ID}/${NRBTS_ID}/LNCEL-${cell_id}

    selenium_coam.remove_object    object_name=${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-${cell_id}
    Log To Console  Validate And Activate parameters
    LTE WebEM ValidateAndActiveParameters
    run keyword and ignore error  WebEM Logout

    sleep  10s
    Log To Console   ASIR Manager Sync
    ASIR Manager Sync For DSS      virtual_enable=${virtual_enable}

Enable or Disable DSS on eNB
    [Documentation]    Enable or Disable DSS on eNB, specifying WebEM IP of eNB, eNB BTS ID, flag for Enable/Disable DSS,
    ...                and SCF template file path.
    ...
    ...    Arguments:
    ...    - _enb_webem_ip_: eNB WebEM IP
    ...    - _enb_bts_id_: BTS ID of eNB
    ...    - _to_enable_: *true* to activate DSS, or *false* to deactivate DSS
    ...    - _delta_template_path_: Delta SCF template file path
    ...
    ...    Examples:
    ...    - Enable DSS on eNB
    ...    | Enable or Disable DSS on eNB | enb_webem_ip=172.30.1.10 | enb_bts_id=34861 | to_enable=true
    ...    ... | delta_template_path=/home/ute/robotws5g/testsuite/OAM/Nanjing/Resources/python/delta_templates/enb_enable_dss_template.xml |
    ...    - Disable DSS on eNB
    ...    | Enable or Disable DSS on eNB | enb_webem_ip=172.30.1.10 | enb_bts_id=34861 | to_enable=false
    ...    ... | delta_template_path=/home/ute/robotws5g/testsuite/OAM/Nanjing/Resources/python/delta_templates/enb_enable_dss_template.xml |
    ...    Return value:
    ...    - None
    [Arguments]    ${enb_webem_ip}  ${enb_bts_id}  ${to_enable}  ${delta_template_path}
    ${act_lte_nr_dss}  Convert To Lower Case  ${to_enable}
    ${dict_scf_para_rep}  create Dictionary  enb_bts_id=${enb_bts_id}  act_lte_nr_dss=${act_lte_nr_dss}
    ${delta_scf_path}  generate_scf_from_template   delta_template_path=${delta_template_path}  dict_scf_para_replace=${dict_scf_para_rep}
    Log To Console  delta xml path:${delta_scf_path}
    Teardown cOAM session
    Log To Console   Connect to eNB ${enb_webem_ip} ...
    Wait Until Keyword Succeeds    6x   5s    coam.connect to   bts_host=${enb_webem_ip}     name=cOAM
    ${convert_status}    coam_parameter.convert_delta_scf_xml_multi_operation  delta_xml_path=${delta_scf_path}
    Log To Console   delta_file:${convert_status['updated']}
    ${res}   coam_parameter.perform_scf_delta_commission  delta_file=${convert_status['updated']}  timeout=900  connection=cOAM
    [Teardown]  Teardown cOAM session

Enable or Disable DSS on gNB
    [Documentation]    Enable or Disable DSS on gNB, specifying flag for Enable/Disable DSS,
    ...                and SCF template file path.
    ...
    ...    Arguments:
    ...    - _gnb_bts_id_: BTS ID of gNB
    ...    - _to_enable_: *true* to activate DSS, or *false* to deactivate DSS
    ...    - _delta_template_path_: Delta SCF template file path
    ...
    ...    Examples:
    ...    - Enable DSS on gNB
    ...    | Enable or Disable DSS on gNB | gnb_bts_id=3486 | to_enable=true
    ...    ... | delta_template_path=/home/ute/robotws5g/testsuite/OAM/Nanjing/Resources/python/delta_templates/gnb_enable_dss_template.xml |
    ...    - Disable DSS on gNB
    ...    | Enable or Disable DSS on gNB | gnb_bts_id=3486 | to_enable=false
    ...    ... | delta_template_path=/home/ute/robotws5g/testsuite/OAM/Nanjing/Resources/python/delta_templates/gnb_enable_dss_template.xml |
    ...    Return value:
    ...    - None
    [Arguments]    ${gnb_bts_id}  ${to_enable}  ${delta_template_path}
    ${act_lte_nr_dss}  Convert To Lower Case  ${to_enable}
    ${dict_scf_para_rep}  create Dictionary  gnb_bts_id=${gnb_bts_id}  act_lte_nr_dss=${act_lte_nr_dss}
    ${delta_scf_path}  generate_scf_from_template   delta_template_path=${delta_template_path}  dict_scf_para_replace=${dict_scf_para_rep}
    Log To Console  delta xml path:${delta_scf_path}
    Teardown cOAM session
    Wait Until Keyword Succeeds    6x    5s    coam.connect to  name=cOAM
    ${convert_status}    coam_parameter.convert_delta_scf_xml_multi_operation  delta_xml_path=${delta_scf_path}
    Log To Console   delta_file:${convert_status['updated']}
    ${res}   coam_parameter.perform_scf_delta_commission  delta_file=${convert_status['updated']}  timeout=900  connection=cOAM
    [Teardown]  Teardown cOAM session

Get Counter Value Of gNB
    [Documentation]    Get Counter Value Of gNB, specifying counter's ID and number of latest counter values
    ...
    ...    Arguments:
    ...    - _counter_id_: counter's ID
    ...    - _number_of_returned_: last number of values of the counters
    ...    - _virtual_enable_: If using virtual display, default value is ${TRUE}
    ...
    ...    Examples:
    ...    - Get Lastest 3 value of counter with id M55147C00001
    ...    | ${counter_values} | Get Counter Value Of gNB | counter_id=M55147C00001 | number_of_returned=3 | virtual_enable=${FALSE} |
    ...    Return value:
    ...    - List of counter values

    [Arguments]    ${counter_id}   ${number_of_returned}   ${virtual_enable}=${TRUE}
    WebEM Login  virtual_enable=${virtual_enable}
    ${dict_counter_info}   selenium_coam.get_bts_counters_info   counter_id=${counter_id}
    Log To Console  Get Counter ${counter_id} info dict:${dict_counter_info}
    ${values_counter_info}  get dictionary values   ${dict_counter_info}
    ${values_counter_info}  Get Slice From List  ${values_counter_info}  start=-${number_of_returned}
    [Return]   ${values_counter_info}
    [Teardown]  WebEM Logout  virtual_enable=${virtual_enable}

lock LTE BTS
    [Documentation]  lock LTE BTS
    ...  Description: LTE Block Site via Selenium, need to specify the LTE WebEM IP
    ...  Arguments:
    ...     lte_webem_ip: LTE WebEM IP on 5G ute, usually be 172.30.1.10
    ...     virtual_enable: If using virtual display, default value is ${TRUE}
    ...  Example:
    ...  lock LTE BTS  lte_webem_ip=172.30.1.10  virtual_enable=${FALSE}
    [Arguments]      ${lte_webem_ip}  ${virtual_enable}=${TRUE}
    WebEM Login  webem_ip=${lte_webem_ip}  virtual_enable=${virtual_enable}
    Log To Console  Try to lock LTE BTS
    lock_bts_lte  timeout=60
    [Teardown]  WebEM Logout    virtual_enable=${virtual_enable}

unlock LTE BTS
    [Documentation]  unlock LTE BTS
    ...  Description: LTE Unblock Site via Selenium, need to specify the LTE WebEM IP
    ...  Arguments:
    ...     lte_webem_ip: LTE WebEM IP on 5G ute, usually be 172.30.1.10
    ...     virtual_enable: If using virtual display, default value is ${TRUE}
    ...  Example:
    ...  unlock LTE BTS  lte_webem_ip=172.30.1.10  virtual_enable=${FALSE}
    [Arguments]      ${lte_webem_ip}  ${virtual_enable}=${TRUE}
    WebEM Login  webem_ip=${lte_webem_ip}  virtual_enable=${virtual_enable}
    Log To Console  Try to unlock LTE BTS
    unlock_bts_lte  timeout=60
    [Teardown]  WebEM Logout    virtual_enable=${virtual_enable}


Get LTE BTS Lock or Unlock
    [Documentation]  Get LTE BTS Lock or Unlock
    ...  Description: Get LTE Block/Unblock Site Button's text via Selenium, need to specify the LTE WebEM IP
    ...  Arguments:
    ...     lte_webem_ip: LTE WebEM IP on 5G ute, usually be 172.30.1.10
    ...     virtual_enable: If using virtual display, default value is ${TRUE}
    ...  Example:
    ...  ${bts_lock_unlock_status}  Get LTE BTS Lock or Unlock  lte_webem_ip=172.30.1.10  virtual_enable=${FALSE}
    [Arguments]      ${lte_webem_ip}  ${virtual_enable}=${TRUE}
    WebEM Login  webem_ip=${lte_webem_ip}  virtual_enable=${virtual_enable}
    Log To Console  Try to Get LTE BTS Lock or Unlock
    ${bts_status}  get_bts_lock_or_unlock_lte  timeout=60
    [Return]   ${bts_status}
    [Teardown]  WebEM Logout    virtual_enable=${virtual_enable}

