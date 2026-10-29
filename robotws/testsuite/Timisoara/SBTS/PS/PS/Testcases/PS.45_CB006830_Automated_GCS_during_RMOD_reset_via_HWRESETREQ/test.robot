*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot


Documentation
...  TEST NAME:     PS.45_CB006830_Automated_GCS_during_RMOD_reset_via_HWRESETREQ
...  AUTHORS:       pawel.bartkowiak@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of the test is to check if cells are shutdown gracefully when
...  RMOD reset is triggered via creation of HWRESETREQ object with
...  HWRESETREQ.GracefulCellShutdown parameter set to True.
...
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  31.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-364 - First draft created
...  11.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-364 - TC commit and review
...  11.10.2023 - Changed KW name from NR/LTE/GSM variant to Check Graceful NR/LTE/GSM variant
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.45_CB006830_Automated_GCS_during_RMOD_reset_via_HWRESETREQ
    PS.45_CB006830_Automated_GCS_during_RMOD_reset_via_HWRESETREQ.Test_Step:0 Test Preparation
    PS.45_CB006830_Automated_GCS_during_RMOD_reset_via_HWRESETREQ.Test_Step:1 Disable feature LTE914/5GC000501 flag
    PS.45_CB006830_Automated_GCS_during_RMOD_reset_via_HWRESETREQ.Test_Step:2 Creating HWRESETREQ object and RMOD reset
    PS.45_CB006830_Automated_GCS_during_RMOD_reset_via_HWRESETREQ.Test_Step:3 Final Recovery and Checkpoint


PS.45_CB006830_Automated_GCS_during_RMOD_reset_via_HWRESETREQ.Test_Step:0 Test Preparation
    Log To Console  \n========================================
    Log  Step: 0 Test Preparation  console=true
    Log To Console  ========================================
    Log  Checking if HWRESETREQ Object Exists  console=true
    Log To Console  ========================================
    Remove HWRESETREQ Object If Exists
    ${pre_action_reset_number}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${TRUE}
    Log To Console  ========================================
    Log  Random RMOD selection  console=true
    Get RMODS
    ${RANDOM_RMOD}  Evaluate  random.choice(${rmods})  random
    Set Test Variable  ${RANDOM_RMOD}
    Log To Console  \n======
    Log  ==Selected RMOD is ${RANDOM_RMOD}==  console=true
    Log To Console  ========================================
    ${randomrmod_id}  Get Regexp Matches  ${RANDOM_RMOD}  RMOD-\\d+
    ${channels}  admin.Get Managed Objects  CHANNEL_A
    ${WNCELS_A}  admin.Get Managed Objects  WNCEL_A
    Set Test variable  ${WNCELS_A}
    ${wncel_a_to_lcelw_a}  Mapping WNCEL_A ID From LCELW_A
    Log To Console  \n========================================
    Log  Checking which cells are affected by RMOD reset  console=true
    Log To Console  ========================================
    ${SELECTED_ALIAS_CELLS}  Create List
    Set Test variable  ${SELECTED_ALIAS_CELLS}
    ${GRACEFUL_CELLS}  Create List
    Set Test variable  ${GRACEFUL_CELLS}
    FOR  ${channel}  IN  @{channels}
         ${CHANNEL_NAME}  Get From Dictionary  ${channel}  distName
         Set Test Variable  ${CHANNEL_NAME}
         ${antl}  Get From Dictionary  ${channel['parameters']}  antlDN
         ${resourceDN}  Get From Dictionary  ${channel['parameters']}  resourceDN
         ${rmod_data}=  IF  '${antl}'!='None'  Set Variable  ${antl}  ELSE  Set Variable  ${resourceDN}
         ${rmod_id}  Get Regexp Matches  ${rmod_data}  RMOD_A-\\d+
         ${rmod_id_without_A}  Remove String  '${rmod_id[0]}'  _A
         IF  '${randomrmod_id[0]}' == ${rmod_id_without_A}  Get Cells From CHANNEL_A
    END
    ${SELECTED_ALIAS_CELLS}  Remove Duplicates  ${SELECTED_ALIAS_CELLS}
    ${GRACEFUL_CELLS}  Remove Duplicates  ${GRACEFUL_CELLS}
    Log  Cells affected by RMOD reset: ${SELECTED_ALIAS_CELLS}  console=true
    Log  Cells which should be shut down gracefully: ${GRACEFUL_CELLS}  console=true
    #WCDMA cells will shut down immediately when there is no traffic on them
    Set Test variable  ${SELECTED_ALIAS_CELLS}
    Set Test variable  ${GRACEFUL_CELLS}
    Log To Console  Checking which cells should be unaffected
    ${cells_list}  Get Cell List
    ${cells_list['cells']['lte']}  Ignore IoT Cells
    ${CELLS}  Combine Lists
    ...  ${cells_list['cells']['lte']}
    ...  ${cells_list['cells']['wcdma']}
    ...  ${cells_list['cells']['gsm']}
    ...  ${cells_list['cells']['nr']}
    Set test variable  ${CELLS}
    FOR  ${cell}  IN  @{CELLS}
        ${cell_id}  Set variable  /${cell['id']['configuration']}
        ${cell_id2}  Get matches  ${SELECTED_ALIAS_CELLS}  ${cell_id}
        IF  ${cell_id2}!=[]  Remove Values From List  ${CELLS}  @{cell}
    END


PS.45_CB006830_Automated_GCS_during_RMOD_reset_via_HWRESETREQ.Test_Step:1 Disable feature LTE914/5GC000501 flag
    Check which RAT are on given TestLine
    IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='EXIST'
        Log To Console  \n========================================
        Log  Step: 1a Disable feature LTE914 flag  console=true
        Log  Step: 1a Set shutdownStepAmount for LTE to 6  console=true
        Log  Step: 1a Set shutdownWindow for LTE to 60s  console=true
        Log To Console  ========================================
        Set Parameters For LTE Graceful Cell Shutdown  enableGrflShdn=Disabled  shutdownStepAmount=6  shutdownWindow=60s
        Log To Console  \n========================================
        Log  Step: 1b Disable feature 5GC000501 flag  console=true
        Log  Step: 1a Set shutdownStepAmount for NR to 6  console=true
        Log  Step: 1a Set shutdownWindow for NR to 60s  console=true
        Log To Console  ========================================
        Set Parameters For NR Graceful Cell Shutdown  actGrflShdn=false  shutdownStepAmount=6  shutdownWindow=60s
    ELSE IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='NO'
        Log To Console  \n========================================
        Log  Step: 1a Disable feature LTE914 flag  console=true
        Log  Step: 1a Set shutdownStepAmount for LTE to 6  console=true
        Log  Step: 1a Set shutdownWindow for LTE to 60s  console=true
        Log To Console  ========================================
        Set Parameters For LTE Graceful Cell Shutdown  enableGrflShdn=Disabled  shutdownStepAmount=6  shutdownWindow=60s
    ELSE IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='NO'
        Log To Console  \n========================================
        Log  Step: 1b Disable feature 5GC000501 flag  console=true
        Log  Step: 1a Set shutdownStepAmount for NR to 6  console=true
        Log  Step: 1a Set shutdownWindow for NR to 60s  console=true
        Log To Console  ========================================
        Set Parameters For NR Graceful Cell Shutdown  actGrflShdn=false  shutdownStepAmount=6  shutdownWindow=60s
    END


PS.45_CB006830_Automated_GCS_during_RMOD_reset_via_HWRESETREQ.Test_Step:2 Creating HWRESETREQ object and RMOD reset
    Log To Console  \n========================================
    Log  Step: 2 Create HWRESETREQ  console=true
    Log To Console  ========================================
    ${time_before}  Get Current Date
    Create And Activate HWRESETREQ For CB006830  ${RANDOM_RMOD}  HWRESETREQ-1
    ${time_after}  Get Current Date
    ${diff}  Subtract Date From Date  ${time_after}  ${time_before}
    Should Be True  ${diff}<320  #OM_GEN_SFS_PERF_CAP.26569
    Log  ==Reset time is ${diff}==  console=true
    Log  Cells affected by RMOD reset: ${SELECTED_ALIAS_CELLS}  console=true
    ${time_before}  Get Current Date
    Check Graceful NR/LTE/GSM variant  ${time_before}  ${GRACEFUL_CELLS}
    Wait Until Keyword Succeeds  5min  10s  Check If Random RMOD Is Disabled
    Log To Console   Checking not affected cells
    Check Not Affected Cells Operational State  ${CELLS}  enabled


PS.45_CB006830_Automated_GCS_during_RMOD_reset_via_HWRESETREQ.Test_Step:3 Final Recovery and Checkpoint
    Log To Console  \n========================================
    Log  Step: 3 Final Recovery and Checkpoint  console=true
    Log To Console    ========================================
    Check RMODs State  ${RMOD_expected_states}
    Disallow Fault In Watchdog  faultID=49
    Check If NLWG Cells Are OnAir
    Check HWRESETREQ Result
    IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='EXIST'
        Set Feature Under Given Object  ${LNBTS_DistName}  enableGrflShdn  Disabled
        Set Feature Under Given Object  ${LNBTS_DistName}  shutdownWindow  180
        Set Feature Under Given Object  ${NRBTS_DistName}  actGrflShdn  false
        Set Feature Under Given Object  ${NRBTS_DistName}  shutdownWindow  180
    ELSE IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='NO'
        Set Feature Under Given Object  ${LNBTS_DistName}  enableGrflShdn  Disabled
        Set Feature Under Given Object  ${LNBTS_DistName}  shutdownWindow  180
    ELSE IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='NO'
        Set Feature Under Given Object  ${NRBTS_DistName}  actGrflShdn  false
        Set Feature Under Given Object  ${NRBTS_DistName}  shutdownWindow  180
    END
    Check If Unexpected Alarms Are Raised  ${skip_fault}

PS.45_CB006830_Automated_GCS_during_RMOD_reset_via_HWRESETREQ.Test Case Teardown
    Common Test Teardown


Create And Activate HWRESETREQ For CB006830
    [Documentation]
    ...  **Example of simple usage:**
    ...  Create And Activate HWRESETREQ For CB006830  ${random_RMOD}  ${HWRESETREQ_id}
    [Arguments]  ${random_RMOD}  ${HWRESETREQ_id}

    ${delta_create_HWRESET}  Set Variable  hwresetreq_create
    ${hwresetreq_dn}  Set Variable  MRBTS-${MRBTS_ID}/MNL-$1/CMD-1/${HWRESETREQ_id}
    admin.Create Delta  ${delta_create_HWRESET}
    admin.Append Managed Object To Delta  MRBTS-${MRBTS_ID}/MNL-1/CMD-1/${HWRESETREQ_id}  create  ${delta_create_HWRESET}
    admin.Append Parameter Update To Delta  MRBTS-${MRBTS_ID}/MNL-1/CMD-1/${HWRESETREQ_id}  targetHwResetUDN  ${random_RMOD}  ${delta_create_HWRESET}
    admin.Append Parameter Update To Delta  MRBTS-${MRBTS_ID}/MNL-1/CMD-1/${HWRESETREQ_id}  gracefulCellShutdown  true  ${delta_create_HWRESET}
    admin.Get Delta  ${delta_create_HWRESET}
    admin.Save Delta  ${RESULTS}/delta_create_HWRESETREQ_${HWRESETREQ_id}_CB006830.json  ${delta_create_HWRESET}
    Log  Activate HWRESETREQ under MRBTS-${MRBTS_ID}/MNL-1/CMD-1/${HWRESETREQ_id}  console=true
    admin.Perform Delta Recommissioning  ${RESULTS}/delta_create_HWRESETREQ_${HWRESETREQ_id}_CB006830.json  ${delta_create_HWRESET}
    Log  Affected RMOD is ${random_RMOD}  console=true


Remove HWRESETREQ Object If Exists
    ${gpoup_obj_all}  admin.Get Managed Objects  HWRESETREQ_A
    IF  ${gpoup_obj_all}!=[]
        Log  HWRESETREQ object exist and will be deleted  console=true
        Delete Old HWRESETREQ Object  ${gpoup_obj_all}
    ELSE
        Log  There is no HWRESETREQ object on testline
    END


Delete Old HWRESETREQ Object
    [Documentation]  Remove old HWRESETREQ object from BTS.
    [Arguments]  ${gpoup_obj_all}

    ${gpoup_path_list}  Create List
    FOR  ${i}  IN  @{gpoup_obj_all}
        ${gpoup_distName}  Set Variable  ${i['distName']}
        ${ignore}  ${gpoup_path}  Split String From Right  ${gpoup_distName}  separator=SCF-1/
        ${gpoup}  Replace String  ${gpoup_path}  search_for=_A  replace_with=
        Append To List  ${gpoup_path_list}  ${gpoup}
    END
    ${delta_gpoup_obj}  Set Variable  gpoup_del
    Create Delta  ${delta_gpoup_obj}
    FOR  ${i}  IN  @{gpoup_path_list}
        Append Managed Object To Delta  ${i}  delete  delta_id=${delta_gpoup_obj}
    END
    Get Delta  ${delta_gpoup_obj}
    Save Delta  ${RESULTS}/delete_gpoup_obj.json  delta_id=${delta_gpoup_obj}
    Perform Delta Recommissioning  ${RESULTS}/delete_gpoup_obj.json  ${SKIP_PARAMETER_RELATION_ERRORS}


Check HWRESETREQ Result
    Sleep  130s       #if necessary, time should be increased because the object:HWRESETRES needs time to create
    Log  == Checking if reset is done ==   console=true
    ${HWRESETRES_parameters}  admin.Get Managed Objects  HWRESETRES_R
    IF  '${HWRESETRES_parameters[0]['parameters']['hwResetResult']}'=='success'
        Log  == Reset is done ==  console=true
    ELSE
        Fail  msg=RMOD reset Failed
    END


Check Graceful NR/LTE/GSM variant
    [Arguments]  ${time_before}  ${graceful_cells}

    FOR  ${i}  IN RANGE  0  50
        ${current_date}  Get Current Date
        ${result}  Subtract Date From Date  ${current_date}  ${time_before}
        IF  ${result} >= 50  BREAK
        Check Operational State  ${graceful_cells}
        Sleep  1 s
    END
    Log To Console  Checking  NR/LTE/GSM variant

Check Operational State
    [Arguments]  ${graceful_cells}

    FOR  ${cell}  IN  @{graceful_cells}
        Check cell_m operational state  ${cell}  Enabled
    END


Check Not Affected Cells Operational State
    [Documentation]  Find cells whose operational states should be checked.
    [Arguments]  ${target_cells}  ${expected_operational_state}

    FOR  ${cell}  IN  @{target_cells}   # get cell from given technology, e.g. lte
        ${cell_operational_state}  Get From Dictionary  ${cell['status']}  operationalState
        Should Be Equal  ${cell_operational_state}  ${expected_operational_state}
    END


Check If Random RMOD Is Disabled
    [Documentation]  Waits until chosen RMOD becomes disabled.

    ${bts_info}  admin.Get Bts Info
    ${rmods_all}  Set variable  ${bts_info['radioModules']['rmod']}
    FOR  ${rmod}  IN  @{rmods_all}
        ${rmod_states}  Get From Dictionary  ${rmod}  status
        ${operational_state}  Get From Dictionary  ${rmod_states}  operationalState
        IF  '${rmod['id']['configuration']}' == '${RANDOM_RMOD}'
            Should Be Equal As Strings  ${operational_state}  disabled  ignore_case=True
        ELSE
            Should Be Equal As Strings  ${operational_state}  enabled  ignore_case=True
        END
        ${administrative_state}  Get From Dictionary  ${rmod_states}  administrativeState
        Should Be Equal As Strings  ${administrative_state}  Unlocked  ignore_case=True
    END
    Log To Console  ${RANDOM_RMOD} is disabled
