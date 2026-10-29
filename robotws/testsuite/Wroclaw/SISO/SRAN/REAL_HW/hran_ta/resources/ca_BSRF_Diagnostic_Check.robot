*** Settings ***
Documentation    Maintainer: lukasz.wystup@nokia.com
...  Resource for Diagnostic Check

*** Keywords ***

Check If RMOD Is Avaliable In Config And Prepare Distname For Diagnostic Check

    Run Keyword If  '${RMOD_SN}'=='${EMPTY}'
    ...  Fail  Variable RMOD_SN cannot be empty !
    ${rmods_info}  admin.Get FRM  60  ${node}

    FOR  ${rmod}  IN  @{rmods_info}
        ${RMOD_DISTNAME_ID}  Set Variable If
        ...  '${rmod['serialNumber']}'=='${RMOD_SN}'   ${rmod['id']['internal']}  ${EMPTY}
        Exit For Loop If  '${RMOD_DISTNAME_ID}'!='${EMPTY}'
    END

    Run Keyword If  '${RMOD_DISTNAME_ID}'=='${EMPTY}'
    ...  Fail  Serial Number ${RMOD_SN} not found in HW Configuration!
    ...  ELSE  Log to console  RMOD with SN ${RMOD_SN} found in configuration!${\n}

    ${rmod_distname}  Fetch From Right  ${RMOD_DISTNAME_ID}  /
    Set Test Variable  ${RMOD_DISTNAME_DC}  ${rmod_distname}
    Set Test Variable  ${RMOD_DISTNAME_ID}

Get DC Report And Check CP Result
    [Documentation]
    ...  This keyword verifies if checkpoint has expected status in latest diagnostic check report.
    ...  Due to pronto 04237743 starting from builds SBTS25R1_ENB_0000_000600_000000
    ...  and SBTS25R2_ENB_9999_241210_000011 there were changes in diagnostic check report output.
    [Arguments]  ${checkpoint}  ${expected_status}  ${connection}  ${precondition}=${FALSE}

    Log to console  \nVerifying if CP '${checkpoint}' has expected status '${expected_status}' in DC Report.
    ${diagnostic_report}  admin.Get Diagnostic Report  connection=${connection}
    ${release}  admin.Get Sw Release Name  connection=${connection}
    ${sw_release}  Run Keyword If  "${release}"=="SBTS25R1"  Check build for 25R1
    ...  ELSE  Check If Current Build Is Newer Than  SBTS25R2_ENB_9999_241210_000011
    ${found_checkpoint}  Get Single Checkpoint Results By ID  ${diagnostic_report}  ${checkpoint}  ${RMOD_DISTNAME_DC}  ${sw_release}
    Verify CP Status  ${found_checkpoint}  ${expected_status}  ${precondition}  ${sw_release}

Check build for 25R1
    [Arguments]    ${alias}=default
    [Documentation]
    ...  KW checks if given 25R1 build is valid for changes done in pronto 04237743
    ...  Starting from build   SBTS25R1_ENB_0000_000541_000000 checkpoints changed
    ...  Starting from build SBTS25R1_ENB_0000_000509_000005 checkpoints changed
    ...
    ...  | **Author:** anna.maciejewska@nokia.com
    ...  | **Maintainer:** anna.maciejewska@nokia.com

    ${current_sw}  Get Software Release  Active    only_release=False    alias=${alias}
    ${current_sw}  Get Regexp Matches  ${current_sw}  \\d+
    ${curr}    Evaluate    [int(number) for number in ${current_sw}]

    Return From Keyword If  ${curr}[3]>=509 and ${curr}[4]>=5   ${TRUE}
    Return From Keyword If  ${curr}[3]>=541 and ${curr}[4]==0   ${TRUE}
    ${verdict}    Set Variable  ${FALSE}


    [Return]    ${verdict}


Get Single Checkpoint Results By ID
    [Documentation]
    ...  This keyword returns needed Checkpoint results from Diagnostic Check Report (parameter dc_result in keyword arguments).
    ...  Searched checkpoint is defined in argument cp_name.

    [Arguments]  ${dc_result}  ${cp_name}  ${rmod_distname}  ${new_sw}
    ${found_checkpoints}  Set Variable  None

    FOR  ${CP}  IN  @{dc_result}
        ${checkpoint_name}  Run Keyword If  ${new_sw}  Get From Dictionary  ${CP}  checkpoint
        ...  ELSE  Get From Dictionary  ${CP}  checkpointId
        ${dist_name}  Run Keyword If  ${new_sw}  Get From Dictionary  ${CP}  targetDistinguishedName
        ...  ELSE  Get From Dictionary  ${CP}  distName
        ${dist_name}  Fetch From Right  ${dist_name}  /
        Log to console  Checkpoint under check: ${checkpoint_name}
        Run Keyword If  '${checkpoint_name}' == '${cp_name}'
        ...  Run Keyword If  '${dist_name}' == '${rmod_distname}'
        ...  Return From Keyword  ${CP}
    END

Verify CP Status
    [Documentation]
    ...  This KW checks that result of checkpoint execution is as expected (OK or NOK - defined in argument: expected_status).

    [Arguments]  ${checkpoint_under_check}  ${expected_status}  ${precondition}  ${new_sw}
    ${cp_result}  Run Keyword If  ${new_sw}  Get From Dictionary  ${checkpoint_under_check}  lastDefinitiveCheckStatus
    ...  ELSE  Get From Dictionary  ${checkpoint_under_check}  lastResult
    ${expected_status}  Run Keyword If  ${new_sw}  Set Variable If  "${expected_status}"=="OK"  Check point successful  Check point failure
    ...  ELSE  Set Variable  ${expected_status}
    ${result_status}  Run Keyword And Ignore Error  Should Match  ${cp_result}  ${expected_status}
    Run Keyword If  '${result_status[0]}'=='PASS'
    ...  Log to console  Last checkpoint execution result is correct: ${cp_result}.
    ...  ELSE IF  ${precondition}  Fail  Incorrect result of last CP execution: ${cp_result} in precondition.
    ...  ELSE  Run Keyword And Continue On Failure  Fail  Incorrect result of last CP execution: ${cp_result}.

Check Diagnostic Check Error Status
    [Arguments]    ${fault_status}

    Log To Console  Checking FID 4681 Diagnostic Check Error Minor is ${fault_status}.

    ${4681}  Run Keyword If  '${fault_status}'=='Active' and "${PRECOND_FOR_CNI}"=="False"
    ...  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=4681  severity=Minor  timeout=120  connection=${connection}
    ...  ELSE  Run Keyword And Return Status  admin.Assert Alarm Inactive  faultId=4681  severity=Minor  connection=${connection}
    Run Keyword If  ${4681} and '${fault_status}'=='Active'
    ...  Log To Console  ${\n}Active FID 4681 Minor Diagnostic Check Error.
    ...  ELSE IF  ${4681} and '${fault_status}'=='Inactive'  Log To Console  ${\n}InActive FID 4681 Minor Diagnostic Check Error.
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Alarm Diagnostic Check Error has unexpected status!
