*** Settings ***
Documentation
...   contact: Szymon Startek

*** Keywords ***

Check If RMOD Is Avaliable In Config And Prepare Distname For Diagnostic Check
    [Documentation]
    ...  This keyword verifies if test variable RMOD_SN is set and can match existing RMOD serial number.
    ...
    ...  | **Author of description:** krzysztof.mirecki@nokia.com, code of keyword from SISO resources ca_BSRF_Diagnostic_Check.robot
    ...
    ...  **Full Description:**
    ...
    ...  Test variable RMOD_SN has to be not empty and matching one of RMOD serial numbers.
    ...
    ...  List of actions:
    ...    - Checks if test vaiable RMOD_SN is not empty and fail test with proper information print in case it is empty.
    ...    - Connects to admin and reads information about all avaliable RMODs.
    ...    - Compares value of RMOD_SN variable with serial number of each RMOD in loop FOR and set variable ${rmod_distname_id}
    ...      with string of whole RMOD distname (/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-4) in case of matching.
    ...    - Prints information if RMOD_SN match to any RMOD serial number in used configuration or not.
    ...    - In case of matching set vaiable ${rmod_distname} to last right part of found RMOD distname, e.g.
    ...      e.g.  /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-4 -> RMOD_R-4
    ...    - Set Test Variable ${RMOD_DISTNAME_DC} with value from variable ${rmod_distname}
    ...
    ...  **Input Parameters:**
    ...   No arguments for keyword but test variable RMOD_SN is mandatory.
    ...
    ...  **Test Variable:**
    ...
    ...  +-------------------------------+------+--------------------------------------------------------+
    ...  | Used test variables           | Description                                                   |
    ...  +===============================+======+========================================================+
    ...  | RMOD_SN                       | Test variable defined in test suite                           |
    ...  +-------------------------------+------+--------------------------------------------------------+
    ...  | CONNECTION                    | Test variable used by admin                                   |
    ...  +-------------------------------+------+--------------------------------------------------------+
    ...  | RMOD_DISTNAME_DC              | Test variable defined by keyword with string of last          |
    ...  |                               | part of found RMOD distname, e.g. RMOD_R-4                    |
    ...  +-------------------------------+------+--------------------------------------------------------+
    Run Keyword If  '${RMOD_SN}'=='${EMPTY}'
    ...  Fail  Variable RMOD_SN cannot be empty !
    ${rmods_info}  Get FRM  60  connection=${CONNECTION}
    FOR  ${rmod}  IN  @{rmods_info}
        ${rmod_distname_id}  Set Variable If
        ...  '${rmod['serialNumber']}'=='${RMOD_SN}'   ${rmod['id']['internal']}  ${EMPTY}
        Exit For Loop If  '${rmod_distname_id}'!='${EMPTY}'
    END

    Run Keyword If  '${rmod_distname_id}'=='${EMPTY}'
    ...  Fail  Serial Number ${RMOD_SN} not found in HW Configuration!
    ...  ELSE  Log To Console  RMOD with SN ${RMOD_SN} found in configuration!${\n}

    ${rmod_distname}  Fetch From Right  ${rmod_distname_id}  /
    Set Test Variable  ${RMOD_DISTNAME_DC}  ${rmod_distname}


Get DC Report And Check CP Result
    [Documentation]
    ...  This keyword verifies if checkpoint has expected status in latest diagnostic check report.
    ...
    ...  | **Author of description:** krzysztof.mirecki@nokia.com, code of keyword from SISO resources ca_BSRF_Diagnostic_Check.robot
    ...
    ...  **Full Description:**
    ...
    ...  Getting Diagnostic Check report, finding status of given checkpoint and verification if checkpoint status has expected value.
    ...
    ...  List of actions:
    ...    - Prints information about id of checkpoint where status is compered with expected status.
    ...    - Connects to admin and gets diagnostic report.
    ...    - Gets from diagnostic reports status of signle checkpoint by checkpoint id for defined RMOD distname
    ...      with string of whole RMOD distname (/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-4) in case of matching.
    ...    - Verifies if status of checkpoint is as expected
    ...
    ...  **Input Parameters:**
    ...
    ...  +-------------------------------+------+--------------------------------------------------------+
    ...  | Parameters                    | Man. | Description                                            |
    ...  +===============================+======+========================================================+
    ...  |  checkpoint                   | Yes  | Checkpoint id for which status should be verified      |
    ...  +-------------------------------+------+--------------------------------------------------------+
    ...
    ...  **Test Variable:**
    ...
    ...  +-------------------------------+----------------------------------------------------------------------+
    ...  | Used test variables           | Description                                                          |
    ...  +===============================+======================================================================+
    ...  | CONNECTION                    | Test variable used by admin                                          |
    ...  +-------------------------------+----------------------------------------------------------------------+
    ...  | RMOD_DISTNAME_DC              | Test variable defined already by previous keyword with part          |
    ...  |                               | of found RMOD distname, e.g. RMOD_R-4                                |
    ...  +-------------------------------+----------------------------------------------------------------------+
    ...  | EXPECTED_STATUS               | Expected status of given checkpoint.                                 |
    ...  |                               | For releases older than 25R2 status if everything is correct is 'OK' |
    ...  |                               | For releases 25R2 and newer this status is 'Check point successful'  |
    ...  +-------------------------------+----------------------------------------------------------------------+

    [Arguments]  ${checkpoint}

    Log To Console  \nVerifying if CP '${checkpoint}' has expected status '${EXPECTED_STATUS}' in DC Report.
    ${diagnostic_report}  Get Diagnostic Report  connection=${CONNECTION}
    ${found_checkpoint}  Get Single Checkpoint Results By ID  ${diagnostic_report}  ${checkpoint}  ${RMOD_DISTNAME_DC}
    Verify CP Status  ${found_checkpoint}


Get Single Checkpoint Results By ID
    [Documentation]
    ...  This KW returns all data (check_point_row_data) assigned with specific signle check point from Diagnostic Check Report.
    ...
    ...  | **Author of description:** krzysztof.mirecki@nokia.com, code of keyword from SISO resources ca_BSRF_Diagnostic_Check.robot
    ...
    ...  **Full Description:**
    ...
    ...  This keyword returns needed Checkpoint results from Diagnostic Check Report (parameter dc_result in keyword arguments).
    ...
    ...  List of actions:
    ...    - Searches in all checkpoints from Diagnostic Check report checking one by one in loop FOR to find the one with
    ...      proper id and RMOD distname
    ...    - Prints information about id of checkpoint under verification.
    ...    - Returns checkpoint_row_data for checkpoint data matching to defined checkpoint if checkpoint id from loop FOR
    ...      matches searched checkpoint and RMOD distname id is as searched.
    ...
    ...  **Input Parameters:**
    ...
    ...  +-------------------------------+------+--------------------------------------------------------+
    ...  | Parameters                    | Man. | Description                                            |
    ...  +===============================+======+========================================================+
    ...  |  diagnostic_check_result      | Yes  | All results from Diagnostic Check report.              |
    ...  +-------------------------------+------+--------------------------------------------------------+
    ...  | checkpoint_searched_name      | Yes  | Id of checkpoint (e.g. 41) to be verified in Diagnostic|
    ...  |                               |      | Check report.                                         |
    ...  +-------------------------------+------+--------------------------------------------------------+
    ...  | rmod_distname                 | Yes  | Last part of RMOD distname assigned to RMOD with       |
    ...  |                               |      | defined RMOD serial number. e.g. RMOD_R-4              |
    ...  +-------------------------------+------+--------------------------------------------------------+
    ...
    ...  **Test Variable:**
    ...
    ...  +-------------------------------+-----------------------------------------------------------------+
    ...  | Parameters                    | Description                                                     |
    ...  +-------------------------------+-----------------------------------------------------------------+
    ...  | CHECKPOINT_ID                 | Key of dictionary ${checkpoint_row_data} to id of checkpoint    |
    ...  |                               | For releases older than 25R2 is 'checkpointId'                  |
    ...  |                               | For releases 25R2 and newer is 'checkpoint'                     |
    ...  +-------------------------------+------+----------------------------------------------------------+
    ...  | DISTINGUISHED_NAME            | Key of dictionary ${checkpoint_row_data} to path to rmod        |
    ...  |                               | of given checkpoint                                             |
    ...  |                               | For releases older than 25R2 is 'distName'                      |
    ...  |                               | For releases 25R2 and newer is 'targetDistinguishedName'        |
    ...  +-------------------------------+------+----------------------------------------------------------+

    [Arguments]  ${diagnostic_check_result}  ${checkpoint_searched_name}  ${rmod_distname}

    ${found_checkpoints}  Set Variable  None
    FOR  ${checkpoint_row_data}  IN  @{diagnostic_check_result}
        ${checkpoint_name}  Get From Dictionary  ${checkpoint_row_data}  ${CHECKPOINT_ID}
        ${dist_name}  Get From Dictionary  ${checkpoint_row_data}  ${DISTINGUISHED_NAME}
        ${dist_name}  Fetch From Right  ${dist_name}  /
        Log To Console  Checkpoint under check: ${checkpoint_name}
        Run Keyword If  '${checkpoint_name}' == '${checkpoint_searched_name}' and '${dist_name}' == '${rmod_distname}'
        ...  Return From Keyword  ${check_point_row_data}
    END


Verify CP Status
    [Documentation]
    ...  This KW checks that result of checkpoint execution is as expected.
    ...
    ...  | **Author of description:** krzysztof.mirecki@nokia.com, code of keyword from SISO resources ca_BSRF_Diagnostic_Check.robot
    ...
    ...  **Full Description:**
    ...
    ...  This KW checks latest value for given checkpoint number and matches it status with expected status.
    ...
    ...  List of actions:
    ...    - Checks last result of defined checkpoint.
    ...    - Matches last result of defined checkpoint and defined expected status for checkpoint.
    ...    - Prints information about last checkpoint status and expected status.
    ...    - Check if status of matching is PASS, which means status is as expected.
    ...    - Prints information about correct status of given checkpoint.
    ...
    ...  **Input Parameters:**
    ...
    ...  +-------------------------------+------+--------------------------------------------------------+
    ...  | Parameters                    | Man. | Description                                            |
    ...  +===============================+======+========================================================+
    ...  | checkpoint_under_check        | Yes  | Checkpoint number which should be verified             |
    ...  +-------------------------------+------+--------------------------------------------------------+
    ...
    ...  **Test Variable:**
    ...
    ...  +-------------------------------+----------------------------------------------------------------------+
    ...  | Parameters                    | Description                                                          |
    ...  +-------------------------------+----------------------------------------------------------------------+
    ...  | LAST_RESULT                   | Key of dictionary ${checkpoint_under_check} to value                 |
    ...  |                               | of status of given checkpoint                                        |
    ...  |                               | For releases older than 25R2 is 'lastResult'                         |
    ...  |                               | For releases 25R2 and newer is 'lastDefinitiveCheckStatus'           |
    ...  +-------------------------------+----------------------------------------------------------------------+
    ...  | EXPECTED_STATUS               | Expected status of given checkpoint.                                 |
    ...  |                               | For releases older than 25R2 status if everything is correct is 'OK' |
    ...  |                               | For releases 25R2 and newer this status is 'Check point successful'  |
    ...  +-------------------------------+----------------------------------------------------------------------+

    [Arguments]  ${checkpoint_under_check}

    ${checkpoint_result}  Get From Dictionary  ${checkpoint_under_check}  ${LAST_RESULT}
    ${result_status}  Run Keyword And Ignore Error  Should Match  ${checkpoint_result}  ${EXPECTED_STATUS}
    Log To Console  cp_result: ${checkpoint_result}
    Log To Console  expected_status: ${EXPECTED_STATUS}
    Run Keyword If  '${result_status[0]}'=='PASS'
    ...  Log To Console  Last checkpoint execution result is correct: ${checkpoint_result}.
    ...  ELSE  Run Keyword And Continue On Failure  Fail  Incorrect result of last CP execution: ${checkpoint_result}.
