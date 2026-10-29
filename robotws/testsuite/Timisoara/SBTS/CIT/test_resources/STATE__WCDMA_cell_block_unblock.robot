*** Settings ***
Documentation
    ...  Test is to verify that WCDMA cell block followed by unblock operations cause SBTS functionality restoration
    ...  to the same state as before the execution of these operations.

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${CELL_ID}  ${EMPTY}  # ID of a cell to be tested (if not provided, all WCDMA cells are tested)


*** Keywords ***
TC__STATE__WCDMA_cell_block_unblock
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-5065
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-10649 - change KW Log TX-Power to Log all tx-power
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 10.03.2017 - https://jira3.int.net.nokia.com/browse/TAT-5065 - New TC available
    ...  - 08.09.2017 - https://jira3.int.net.nokia.com/browse/TAT-7594 - Changes in Infomodel queries to use
    ...  ADMIN Abstract Layer, plus changes in how alarms after cell block operations are checked
    ...  - 15.05.2019 - https://jira3.int.net.nokia.com/browse/TAT-16184 - Updated Collect Files From BTS keyword
    ...  - 13.04.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21188 - Align "FOR loop" to python3 migration
    ...  - 25.05.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21353 - Replacing KW block to TAF library
    ...  - 14.06.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21467 - Change alarming object from notifier to configuration object
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-5065.png

    Set Tags  CA-STATE  OWNER-grzegorz.gulaj@nokia.com  MAINTAINER-vlad.slivilescu@nokia.com  AUTHOR-andrzej.cichon@nokia.com  PHASE-CR1  SW-SBTS17
    ...  FEATURE-RP001498_RP000923  FEATURE-RP001621_RP000923  FEATURE-RP001486_RP000923  FEATURE-RP0001145_RP000923

    Pre-Test Actions
    Step 0: Make A List Of WCDMA Cells To Be Tested And Check Their States
    Step 0a: Make A List Of Non-WCDMA Cells And Check Their States
    Step 1: WCDMA Cell Block Is Executed
    Step 2: WCDMA Cell Unblock Is Executed


Pre-Test Actions
    Store List Of Preexisting Alarms FaultIDs


Step 0: Make A List Of WCDMA Cells To Be Tested And Check Their States
    [Documentation]
    ...  Create a list of WCDMA cells to be tested.
    ...  By default all WCDMA cells are tested unless a specific cell ID (e.g. 40701) is provided as a parameter.
    ...  Expected state for each cell: operationalState = Enabled, blockingState = Unblocked.

    Log  \n----- Step 0: Make a list of WCDMA cells to be tested -----  console=true
    Run Keyword If  '${CELL_ID}'=='${EMPTY}'
    ...  Select All WCDMA Cells For Testing
    ...  ELSE
    ...  Select A Single WCDMA Cell For Testing  ${CELL_ID}
    ${n}  Get Length  ${WCDMA_CELLS_DN_LIST}
    Log  \n${n} WCDMA cell(s) will be tested:  console=true
    Log List To Console  ${WCDMA_CELLS_DN_LIST}
    Run Keyword And Ignore Error
    ...  Log All Tx Power


Step 0a: Make A List Of Non-WCDMA Cells And Check Their States
    Get List Of Non-WCDMA Cells
    ${length}  Get Length  ${NON_WCDMA_CELLS_DN_LIST}
    Run Keyword If  ${length}==0
    ...  Log  \nNon-WCDMA cells were not found.\n  console=true
    ...  ELSE
    ...  Run Keywords
    ...  Log  Non-WCDMA cells found:  console=true
    ...  AND
    ...  Log List To Console  ${NON_WCDMA_CELLS_DN_LIST}


Step 1: WCDMA Cell Block Is Executed
    [Documentation]
    ...  WCDMA cell block is applied. Expected state for each cell: operationalState = Disabled, blockingState = Blocked.
    ...  Fault 49 reported respectively.

    Log  \n----- Step 1: WCDMA cell block is executed -----  console=true
    FOR  ${cell}  IN  @{WCDMA_CELLS_DN_LIST}
        ${status}  ${msg}  Run Keyword And Ignore Error
        ...  coam.Block Cell  dist_name=${cell}  timeout=200
        Run Keyword If  '${status}'=='FAIL'
        ...  Run Keywords
        ...  Handle Fail
        ...  AND
        ...  Set Test Failed  message=Block procedure failed: ${msg}  fail_fast=${True}
        Run Keyword And Continue On Failure
        ...  Assert  WNCEL  ${cell}  ${STATES_ON_BLOCK_WCDMA}  timeout=20
        Log  Blocked cell ${cell}  console=true
    END
    Sleep  20
    Check If Alarms With Fault 49 Reported
    ${fault_49}  Create List  ${FAULT_49}[fault_id]
    ${expected_fault_ids}  Combine Lists  ${PREEXISTING_ALARMS_FAULT_IDS}  ${fault_49}
    Check If Unexpected Alarms Occurred  expected_faults=${expected_fault_ids}
    Run Keyword And Ignore Error
    ...  Log All Tx Power
    Assert All Cells Are In Expected State  check_wcdma=${FALSE}


Step 2: WCDMA Cell Unblock Is Executed
    [Documentation]
    ...  WCDMA cell unblock is applied. Expected state for each cell: operationalState = Enabled, blockingState = Unblocked.
    ...  Fault 49 cancelled respectively.

    Log  \n----- Step 2: WCDMA cell unblock is executed -----  console=true
    FOR  ${cell}  IN  @{WCDMA_CELLS_DN_LIST}
        ${status}  ${msg}  Run Keyword And Ignore Error
        ...  coam.Unblock Cell  dist_name=${cell}  timeout=200
        Run Keyword If  '${status}'=='FAIL'
        ...  Run Keywords
        ...  Handle Fail
        ...  AND
        ...  Set Test Failed  message=Unblock procedure failed: ${msg}  fail_fast=${True}
        Log  Unblocked cell ${cell}  console=true
    END
    Sleep  120
    Check If Alarms With Fault 49 Cancelled
    Check If Unexpected Alarms Occurred  expected_faults=${PREEXISTING_ALARMS_FAULT_IDS}
    Run Keyword And Ignore Error
    ...  Log All Tx Power
    Assert All Cells Are In Expected State


Store List Of Preexisting Alarms FaultIDs
    ${alarms}  coam.Get Active Alarms  timeout=30
    ${preexisting_alarms_fault_ids}  Create List
    Log List  ${alarms}  level=TRACE
    FOR  ${alarm}  IN  @{alarms}
        ${fault_id}  Convert To String  ${alarm.faultId}
        Append To List  ${preexisting_alarms_fault_ids}  ${fault_id}
    END
    Run Keyword If  len($alarms) > 0
    ...  Run Keywords
    ...  Log  \nFound preexisting alarms:  console=true
    ...  AND
    ...  Prettyprint Alarms  ${alarms}
    Set Suite Variable  ${PREEXISTING_ALARMS_FAULT_IDS}


Get Cell Params
    [Arguments]  ${cell_dn}

    ${rat_abbr}  Create Dictionary  LTE=L  WCDMA=W  GSM=G
    ${cell_obj}  Query Infomodel  get object ${cell_dn}
    ${rat}  Set Variable  ${cell_obj['rat']}
    ${ncel_object}  Query Infomodel  get object ${cell_dn}/${rat_abbr['${rat}']}NCEL_M-*
    ${cell_dn}  ${ncel_name}  Split String From Right  ${ncel_object['dist_name']}  /  1
    ${ncel_name}  Replace String  ${ncel_name}  _M  _${rat_abbr['${rat}']}
    ${cell_params}  Create Dictionary  rat=${rat}  rat_abbr=${rat_abbr['${rat}']}  _ncel_name=${ncel_name}  dist_name=${cell_obj['dist_name']}

    [Return]  ${cell_params}


Select All WCDMA Cells For Testing
    ${wcdma_cells_dn_list}  Get Dist_names For All WNCEL
    Set Suite Variable  ${WCDMA_CELLS_DN_LIST}


Select A Single WCDMA Cell For Testing
    [Arguments]  ${cell_id}

    ${cell_dn}  Get Cell ID By Configuration ID  WCDMA  ${cell_id}
    ${wcdma_cells_dn_list}  Create List  ${cell_dn}
    Set Suite Variable  ${WCDMA_CELLS_DN_LIST}


Get List Of Non-WCDMA Cells
    ${lte_cells_dn_list}  Get Dist_names For All LNCEL
    ${gsm_cells_dn_list}  Infomodel Get Objects Parameter  //GNCEL_R-*  dist_name  allow_negative_result=${True}
    Sort List  ${gsm_cells_dn_list}
    ${non_wcdma_cells_dn_list}  Combine Lists  ${gsm_cells_dn_list}  ${lte_cells_dn_list}
    Set Suite Variable  ${NON_WCDMA_CELLS_DN_LIST}


Get Dist_names For All ${type}
    [Documentation]
    ...  The ${type} can be any object type supported by ADMIN Abstract Layer interface, particularly
    ...  by `Get Parameters For All` keyword: [RMOD|SMOD|BBU|ALD|LNCEL|WNCEL|GNCEL|BTS]

    ${tmp_list}  Get Parameters For All  ${type}
    ${dn_list}  Create List
    FOR  ${object}  IN  @{tmp_list}
        Append To List  ${dn_list}  ${object['id']}
    END
    Sort List  ${dn_list}

    [Return]  ${dn_list}


Check If Alarms With Fault 49 Reported
    ${wcels_dn}  Find Cells Reporting Alarm With FaultID  ${FAULT_49}[fault_id]
    ${wcels_id}  Create List
    ${wncels_id}  Create List
    FOR  ${wcel}  ${wncel}  IN ZIP  ${wcels_dn}  ${WCDMA_CELLS_DN_LIST}
        ${id}  Fetch From Right  ${wcel}  -
        Append To List  ${wcels_id}  ${id}
        ${id}  Fetch From Right  ${wncel}  -
        Append To List  ${wncels_id}  ${id}
    END
    ${length}  Get Length  ${wcels_id}

    ${status}  Run Keyword And Return Status
    ...  Lists Should Be Equal  ${wcels_id}  ${wncels_id}
    Run Keyword If  '${status}'=='True'
    ...  Log  \nAll blocked WCDMA cells reported alarms with faultId 49  console=true
    ...  ELSE
    ...  Run Keywords
    ...  Log  \n${length} cell(s) reported alarms with faultId 49:  console=true
    ...  AND
    ...  Log List To Console  ${wcels_id}
    ...  AND
    ...  Handle Fail
    ...  AND
    ...  Set Test Failed  message=${length} cell(s) reported alarms with faultId 49  fail_fast=${True}


Check If Alarms With Fault 49 Cancelled
    ${cells}  Find Cells Reporting Alarm With FaultID  ${FAULT_49}[fault_id]
    Run Keyword If  len($cells)==0
    ...  Log  \nAlarms with faultId 49 cancelled on all WCDMA cells.  console=true
    ...  ELSE
    ...  Run Keywords
    ...  Log  \nAlarms with faultId 49 still reporting on cells:  console=true
    ...  AND
    ...  Log List  ${cells}


Check If Unexpected Alarms Occurred
    [Arguments]  ${igonred_faults}=@{EMPTY}

    ${unexpected_alarms_list}  Create List
    ${alarms}  coam.Get Active Alarms  timeout=30
    Log List  ${alarms}  level=TRACE
    FOR  ${alarm}  IN  @{alarms}
        ${fault_id}  Convert To String  ${alarm.faultId}
        ${status}  Run Keyword And Return Status
        ...  List Should Not Contain Value  ${igonred_faults}  ${fault_id}
        Run Keyword If  '${status}'=='True'
        ...  Append To List  ${unexpected_alarms_list}  ${alarm}
    END
    Run Keyword If  len($unexpected_alarms_list) > 0
    ...  Run Keywords
    ...  Log  \nFound unexpected alarms:  console=true
    ...  AND
    ...  Prettyprint Alarms  ${unexpected_alarms_list}
    ...  AND
    ...  Handle Fail
    ...  AND
    ...  Set Test Failed  message=Found unexpected alarm(s).  fail_fast=${True}
    ...  ELSE
    ...  Log  \nNo unexpected alarms were found.  console=true


Prettyprint Alarms
    [Arguments]  ${alarms}

    FOR  ${alarm}  IN  @{alarms}
        Log  >>> faultId=${alarm.faultId} | severity=${alarm.severity} | faultName=${alarm.faultName} |  console=true
        Log  notifier=${alarm.notifier} | configObjectName=${alarm.configObjectName}  console=true
    END
    Log  \n  console=true


Log List To Console
    [Arguments]  ${list}

    FOR  ${element}  IN  @{list}
        Log  ${element}  console=true
    END
    Log To Console  \n


Handle Fail
    Log  \nHandling fail.  console=true
    Collect Files From BTS
    Run Keyword And Ignore Error
    ...  Log All TX Power


Collect Files From BTS
    Get Dir From BTS  /var/log
    ${folder_collected}  Run Keyword And Ignore Error
    ...  Get Dir From BTS  /flash/config
    Run Keyword If  "${folder_collected}"=="FAILED"
    ...  Get Dir From BTS  /rom/config


Get Dir From BTS
    [Documentation]
    ...  Collect a directory from BTS, zip it and move to log folder (BTS Files)
    ...
    ...  *AUTHOR*
    ...  andrzej.cichon@nokia.com
    ...
    ...  *EXAMPLE*
    ...  Get Dir From BTS    /var/log
    ...  => ${BTSFiles}/var_log.zip
    ...
    ...  *RETURN VALUE*
    ...  None
    [Arguments]  ${dir_path}

    ${exit_code}  ${temp_path}  Run And Return Rc And Output  mktemp -d
    ${temp_path}  Strip String  ${temp_path}
    ${target_dir_name}  Replace String  ${dir_path}  search_for=/  replace_with=_
    ${target_dir_name}  Get Substring  ${target_dir_name}  start=1
    ${exit_code}  ${output}  Run And Return Rc And Output
    ...  sshpass -p '${SMOD1['PASSWORD']}' scp -r ${SMOD1['USERNAME']}@${SMOD1['IP']}:${dir_path} ${temp_path}/${target_dir_name}
    Run Keyword If  ${exit_code}==0
    ...  Run Keywords
    ...  Run  cd ${temp_path}; zip -r ${target_dir_name}.zip ${target_dir_name}
    ...  AND
    ...  Run  mv ${temp_path}/${target_dir_name}.zip ${BTS_FILES}
    ...  AND
    ...  Run  rm -rf ${temp_path}
    ...  ELSE
    ...  Set Test Restriction  Could not get ${dir_path}.


Get File From BTS
    [Documentation]
    ...  *AUTHOR*
    ...  andrzej.cichon@nokia.com
    [Arguments]  ${file_path}

    ${exit_code}  ${output}  Run And Return Rc And Output
    ...  sshpass -p '${SMOD1['PASSWORD']}' scp -r ${SMOD1['USERNAME']}@${SMOD1['IP']}:${file_path} ${BTS_FILES}
    Run Keyword If  ${exit_code}!=0
    ...  Set Test Restriction  Could not get ${file_path}. File may not exist.


Find Cells Reporting Alarm With FaultID
    [Documentation]
    ...  Return a list of WCELs which report alarms with a given faultID
    ...  e.g.,
    ...  [/MRBTS-1/RAT-1/WTS-1/RNC-38/WBTS-320/WCEL-32002, /MRBTS-1/RAT-1/WTS-1/RNC-38/WBTS-320/WCEL-32003]
    [Arguments]  ${fault_id}

    ${alarms}  coam.Get Active Alarms  timeout=30
    Log List  ${alarms}  level=TRACE
    ${cells_reporting_fault}  Create List
    FOR  ${alarm}  IN  @{alarms}
        Run Keyword If  ${alarm.faultId}==${fault_id}
        ...  Append To List  ${cells_reporting_fault}  ${alarm.configObjectName}
    END

    Sort List  ${cells_reporting_fault}
    [Return]  ${cells_reporting_fault}


TC Setup
    Common Test Setup  tc_name=STATE__WCDMA_cell_block_unblock


TC Teardown
    Common Test Teardown
