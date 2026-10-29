*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
Library     taf.selenium.sbts   WITH NAME   selenium_sbts

Documentation
...   author: Chen Tong
...   contact: tong.chen@nokia-sbell.com
...   squad group: SG_02


*** Variables ***
&{fault_61524}    faultId=${61524}    source=-    #faultId:SSH_ENABLED  source:RU1
&{fault_61652}    faultId=${61652}    source=-    #faultId:R&D_SERVICE_PORT_ENABLED  source:RU1
&{fault_4681}    faultId=${4681}    source=-    #Sanity Check Error

${AQHA_SOAP}    cat /ram/UnitOAM_SOAP_Startup_LBTS_OM_EA211854170_Log/UnitOAM_SOAP_Startup_LBTS_OM_EA211854170_Log0.xml
@{faults_list}       2934    2919    10

*** Keywords ***
CB011039 Test Case Suit Setup
    SG2_Common_setup_teardown.Common Suite setup    if_commissioning=${True}
    Connect to gnb coam via ssl
    ${testline_name}    String.Fetch From Right    string=${CONFIGURATION}    marker=.
	Set Suite Variable    ${testline_name}
    COAM Commission with scf file    scf_file_path=${tl_scf_dir_path}/${testline_name}/SBTS24R3_11039.xml
    ...                              timeout=500    is_pdl_checking_needed=${False}
    COAM Teardown gnb connections
    COAM Wait for gnb ready and cell setup    gnb_type='SA'

CB011039_Enable_fail_safe_mode_via_enable_command
    [Arguments]    ${ru_index}=2
    ${localhost_login}    Set Variable    frmonShellClient localhost 2000
    ${cmd}    Set Variable  echo '/ action create ResetControl /CI/resetControl/module /module'|${localhost_login}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd}   Set Variable  echo '/CI/resetControl/module action enable_fail_safe_mode'|${localhost_login}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    5s
    Perform RU Reset    ru_index=${ru_index}
    Check Fail Safe Mode with Gnb Fault
    csn.reset_cache

CB011039_Enable_fail_safe_mode_via_suspend_node
    [Arguments]    ${ru_index}=1
    ${localhost_login}    Set Variable    frmonShellClient localhost 2000
    ${cmd}    Set Variable  echo '/ action create SoftwareService /softwareservice'|${localhost_login}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd}   Set Variable  echo '/softwareservice action service_keep_suspend "fans::instance1"'|${localhost_login}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    5s
    Perform RU Reset    ru_index=${ru_index}
    Check Fail Safe Mode with Gnb Fault    ru_index=${ru_index}    timeout=${840}
    csn.reset_cache

Check Fail Safe Mode with Gnb Fault
    [Arguments]    ${ru_index}=2    ${timeout}=${300}
    Wait For Expect Fault Present    faultId=2934    timeout=${timeout}    source=RMOD_R-${ru_index}
    #Wait For Expect Fault Present    faultId=1850    timeout=${timeout}    source=RMOD_R-${ru_index}

Check Logs Detail when RU in Fail Safe Mode
    [Arguments]    ${ru_index}=2
    Connect to gnb coam via ssl
    Connect to Common Unit Master    alias=ASIK Master
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}   asik_alias=ASIK Master
    ${localhost_login}    Set Variable    frmonShellClient localhost 2000
    ${cmd}   Set Variable  echo '/ action create ResetControl /CI/resetControl/module /module'|${localhost_login}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd}   Set Variable  echo '/CI/resetControl/module get fail_safe_mode'|${localhost_login}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
	${mode}    Set Variable If    ${ru_index} == 2    done ok "ACTIVE"    done ok ACTIVE
    Should Contain    ${output}    ${mode}
    ${cmd}   Set Variable If    ${ru_index} == 2  cat /ram/fault_history_log.txt |grep -i 'Fault report' -A 8
	...                                           cat /ram/fault_history_log_temp.txt |grep -i 'Fault report' -A 8
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    EFaultId_FailSafeMode
    ${cmd}   Set Variable If    ${ru_index} == 2  cat /ram/UnitOAM_SOAP_Log0.xml |grep -i '<bldName>?</bldName><bldVersion>?</bldVersion>'
	...      ${AQHA_SOAP} |grep -i '<bldName>?</bldName><bldVersion>?</bldVersion>'
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Not Be Empty    ${output}
    ${hw_info}    coam.get_detected_hw_info    connection=GNB_OAM    timeout=900
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${ru_item}    Set variable    ${0}
    ${rmod_sn}    Set variable    ${tl.gnbs[0].dus[0].rus[${ru_index}-1].serial_number}
    FOR  ${ru}  IN  @{list_RUs}
        Run keyword if    '${rmod_sn}'!='${ru['serialNumber']}'    continue for loop
        ${ru_item}=    evaluate    ${ru_item}+1
        Run keyword and continue on failure
        ...    Should be equal as strings    ${ru['status']['administrativeState']}    Unlocked
        ...    msg=Current RU administrativeState is not in Unlocked status
        Run keyword and continue on failure
        ...    Should be equal as strings    ${ru['status']['operationalState']}    disabled
        ...    msg=Current RU operationalState is not in disabled status
        Run keyword and continue on failure
        ...    Should Not Contain    ${ru}    proceduralStatus
        ...    msg=Current RU proceduralStatus is not empty
        Run keyword and continue on failure
        ...    Should be equal as strings    ${ru['status']['availabilityStatus']}    failed
        ...    msg=Current RU availabilityStatus is not in Failed status
    END
    should be true    ${ru_item}>${0}    msg=Check RU status failed as no RU found !!!

CB011039_Disable_fail_safe_mode_via_disable_command
    [Arguments]    ${ru_index}=2
    ${localhost_login}    Set Variable    frmonShellClient localhost 2000
    ${cmd}    Set Variable  echo '/ action create ResetControl /CI/resetControl/module /module'|${localhost_login}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable  echo '/CI/resetControl/module action disable_fail_safe_mode'|${localhost_login}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    5s
    Perform RU Reset    ru_index=${ru_index}
    csn.reset_cache
    COAM Wait for gnb ready and cell setup    gnb_type='SA'
    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT_LIST}
    Connect to gnb coam via ssl
    Connect to Common Unit Master    alias=ASIK Master
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}   asik_alias=ASIK Master
    ${localhost_login}    Set Variable    frmonShellClient localhost 2000
    ${cmd}   Set Variable  echo '/ action create ResetControl /CI/resetControl/module /module'|${localhost_login}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd}   Set Variable  echo '/CI/resetControl/module get fail_safe_mode'|${localhost_login}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok "INACTIVE"

CB011039_Disable_fail_safe_mode_via_restore_node
    [Arguments]    ${ru_index}=1
    ${localhost_login}    Set Variable    frmonShellClient localhost 2000
    ${cmd}    Set Variable  echo '/ action create SoftwareService /softwareservice'|${localhost_login}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable  echo '/softwareservice action service_restore "fans::instance1"'|${localhost_login}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    5s
    Perform RU Reset    ru_index=${ru_index}
    csn.reset_cache
    COAM Wait for gnb ready and cell setup    gnb_type='SA'
    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT_LIST}
    Connect to gnb coam via ssl
    Connect to Common Unit Master    alias=ASIK Master
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}   asik_alias=ASIK Master
    ${localhost_login}    Set Variable    frmonShellClient localhost 2000
    ${cmd}   Set Variable  echo '/ action create ResetControl /CI/resetControl/module /module'|${localhost_login}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd}   Set Variable  echo '/CI/resetControl/module get fail_safe_mode'|${localhost_login}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok INACTIVE

CB011039_Case_Teardown_via_disable_command
    Run keyword and continue on failure    CB011039_Disable_fail_safe_mode_via_disable_command
    AlarmWatchdog.remove_allow_alarms    fault_id=${faults_list}
    Run keyword and ignore error    SG2_Common_setup_teardown.Common Case teardown    need_Btslog=${True}

CB011039_Case_Teardown_via_restore_node
    Run keyword and continue on failure    CB011039 trigger RU Input Voltage High    vol_value=0
    Run keyword and continue on failure    CB011039_Disable_fail_safe_mode_via_restore_node
    AlarmWatchdog.remove_allow_alarms    fault_id=${faults_list}
    Run keyword and ignore error    SG2_Common_setup_teardown.Common Case teardown    need_Btslog=${True}

CB011039 Check All CPs from RU Report
    [Arguments]    ${RUreport}     ${checkPoints}
	Set Test Variable    ${report}    ${RUreport}
    FOR  ${cp}  IN  @{checkPoints}
        CB011039 Check CP from RU Report    checkPoint=${cp}
    END

CB011039 Check CP from RU Report
    [Arguments]    ${checkPoint}
    FOR  ${item}  IN  @{report}
        ${Status}    Run Keyword And Return Status    Dictionary Should Contain Sub Dictionary    ${item}    ${checkPoint}
        Run Keyword If    ${Status}    Remove Values From List    ${report}    ${item}
		...       ELSE    Continue For Loop
        Exit For Loop
    END

CB011039 Diagnostic Check
    [Arguments]    ${checkPoints}=${CB011039_CheckPoint}
	COAM Navigate to login page via webUI    version=SBTS25R1
	selenium_sbts.start_diagnostic_check   scope=Full diagnostic check    allow_service_impact=${True}
	Sleep    3min
	${full_diagnostic_report}   selenium_sbts.get_report
    ${RUfullreport}    set variable    ${full_diagnostic_report['RU diagnostic check report']}
	CB011039 Check All CPs from RU Report    RUreport=${RUfullreport}    checkPoints=${checkPoints}
    [Teardown]    COAM selenium logout

CB011039 trigger RU Input Voltage High
    [Arguments]    ${ru_index}=1    ${vol_value}=57001
    #Connect to gnb coam via ssl
    #Connect to Common Unit Master    alias=ASIK Master
    #Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}   asik_alias=ASIK Master
    ${cmd}    Set Variable    ccsShell.sh rad -mw 0x110032 ${vol_value}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
	Sleep    30s


