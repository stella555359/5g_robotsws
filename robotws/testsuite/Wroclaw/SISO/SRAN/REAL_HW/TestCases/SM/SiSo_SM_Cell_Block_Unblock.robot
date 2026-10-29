*** Settings ***
Documentation
    ...  AUTHOR-izabela.wencel@nokia.com  MAINTAINER-izabela.wencel@nokia.com
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-8108
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...  Step 1 Preconditions For Block Unblock
    ...
    ...  Steps 2-6 performed in a loop for as many bands as chosen by the tester or available on the test line
    ...  Choice of a band with a global variable set in the test suite, e.g.
    ...  ...  AND  Set Test Variable  @{CHOSEN_BANDS}    4  71
    ...  *Steps with call are optional - turned on with a flag
    ...  *Step 2 Perform L3 Call Before Block
    ...  Step 3 Block Cells On Single Band
    ...  *Step 4 Perform L3 Call After Block
    ...  Step 5 Unblock Cells On Single Band
    ...  *Step 6 Perform L3 Call After Unblock
    ...
    ...  Steps 7-11 performed in a loop for as many rats as chosen by the tester or available on the test line
    ...  *Step 7 Perform L3 Call On Available Cells
    ...  Step 8 Block Cells On Single RAT
    ...  *Step 9 Perform L3 Call After Block
    ...  Step 10 Unblock Cells On Single RAT
    ...  *Step 11 Perform L3 Call After Unblock RAT
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.10.2024 - Initial creation

Resource  ./../../Resources/Robot/SM.robot
Resource  ./../../Resources/Robot/variables_preparation.robot

*** Variables ***
${CONFIGURATION_STARTUP_TIMEOUT}
${CUSTOM_KPI_CALCULATION}=  ${TRUE}
${CHOSEN_BANDS}=  ${EMPTY}            # Optional, possible values: all, no_bands, number of chosen band
${CHOSEN_RATS}                        # Mandatory, possible values: all, NR, LTE, WCDMA, GSM
${RNC_DICT}=  ${EMPTY}                # Mandatory if WCDMA is tested: rnc_id=xx  oms_ip=xxx.xxx.xxx.xxx  rnc_user=xxxxxxxxx  rnc_password=xxxxxxxxxx
${BSC_DICT}=  ${EMPTY}                # Mandatory if GSM is tested: bsc_id=xx  bsc_ip=xxx.xxx.xxx.xxx  bsc_user=xxxxxxxxx  bsc_password=xxxxxxxxxx
${RMODS_CHOSEN_FOR_POWER}             # Mandatory, possible values: no_power_check, all rmods power check,
                                      # if empty - none rmods power check, if SN(s) given - chosen power check

*** Keywords ***
Automated SiSo SM Cell Block Unblock
    Set Tags  AUTHOR-izabela.wencel@nokia.com  MAINTAINER-izabela.wencel@nokia.com
    Common Test Setup
    Logging With Timestamp
    ...  message=Automated SiSo SM Cell Block Unblock for every node on list : @{CFG.active_bts_list} will be executed
    ...  style=ONGOING

    Step 1 Preconditions For Cell Block Unblock
    ${bts_id}=  Set Variable  ${CFG.active_bts_list[0]}

    FOR  ${band}  IN  @{TESTED_BANDS}
      Step 2 Perform L3 Call Before Cell Block  #${bts_id}  ${band}
      Step 3 Block Cells On Single Band  ${bts_id}  ${band}
      Step 4 Perform L3 Call After Cell Block  #${bts_id}  ${band}
      Step 5 Unblock Cells On Single Band  ${bts_id}  ${band}
      Step 6 Perform L3 Call After Cell Unblock  #${bts_id}  ${band}
    END

    FOR  ${rat}  IN  @{RATS_TO_TEST}
      Step 7 Perform L3 Call On Available Cells  #${bts_id}  ${rat}
      Step 8 Block Cells On Single RAT  ${bts_id}  ${rat}
      Step 9 Perform L3 Call After RAT Block  #${bts_id}  ${rat}
      Step 10 Unblock Cells On Single RAT  ${bts_id}  ${rat}
      Step 11 Perform L3 Call After RAT Unblock  #${bts_id}  ${rat}
    END

    Run Keyword And Ignore Error  Run Keyword If  ${NR_OR_LTE_EXISTS}==True
    ...  Step 12 Cell Block Unblock Counters For LTE And NR  ${bts_id}  ${RATS_ON_TL}  ${CELL_MCC_MNC_DICT}  ${node_cells_dict}

    [Teardown]  Run Keywords
    ...  Run Keyword If  "${KEYWORD STATUS}"=="FAIL"
    ...  Run Keyword And Ignore Error  SM Recovery Unblock Cells On Chosen RAT  ${CFG.active_bts_list[0]}  ${RATS_TO_TEST}
    ...  AND
    ...  Run Keyword If  "${KEYWORD STATUS}"=="FAIL"
    ...  Run Keyword And Ignore Error  SM Recovery Unblock Cells On Chosen RAT  ${CFG.active_bts_list[1]}  ${RATS_TO_TEST}
    ...  AND
    ...  Common Test Teardown

Step 1 Preconditions For Cell Block Unblock
    Logging With Timestamp
    ...  message=Step 1 Preconditions For Block Unblock
    ...  style=STEP
    ...  frame=${TRUE}
    Run Keyword And Continue On Failure
    ...  Prepare Test Variables For Block Unblock
    Logging With Timestamp
    ...  message=Step 1 Preconditions For Block Unblock finished.
    ...  style=DONE

Step 2 Perform L3 Call Before Cell Block
#    [Arguments]  ${bts_id}  ${band}
    Logging With Timestamp
    ...  message=Step 2 L3 call to be introduced
    ...  style=STEP
    ...  frame=${TRUE}

Step 3 Block Cells On Single Band
    [Arguments]  ${bts_id}  ${band_name}
    Logging With Timestamp
    ...  message=Step 3 Block Cells On Single Band ${band_name}.
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Blocking cells on single band ${band_name}.
    ...  style=ONGOING
    ${all_unchanged_cells}=  Run Keyword And Continue On Failure
    ...  SM Block Cells On Chosen Band
    ...  ${band_name}  ${ALL_CELLS_WITHOUT_GUARDBAND}  ${NODE_CELLS_DICT}
    Logging With Timestamp
    ...  message=Checking states after blocking cells on single band ${band_name}.
    ...  style=ONGOING
    ${name}  ${band}  Split String  ${band_name}  separator=_  max_split=1
    ${cellson_band}=  Catenate  SEPARATOR=_  cellson  ${band}
    ${blockig_status}  ${all_blocked_cells}=  Run Keyword And Ignore Error
    ...  SM Verify Whether Correct Cells Blocked
    ...  ${bts_id}  ${${cellson_band}}  ${RMODS_TO_BE_TESTED}  ${NODE_CELLS_DICT}
    Set Test Variable  ${ALL_BLOCKED_CELLS}  ${all_blocked_cells}
    ${unchanged_cells_status}=  Run Keyword And Return Status
	...  SM Verify Whether Correct Cells Unchanged
    ...  ${bts_id}  ${all_unchanged_cells}  ${RMODS_TO_BE_TESTED}  ${NODE_CELLS_DICT}
    ${alarm_unexpected_status}=  Run Keyword And Return Status
    ...  admin.Assert No Unexpected Active Alarms  alias=${bts_id}
    Run Keyword If  "${alarm_unexpected_status}"=="${EMPTY}"
    ...  Log  \nList of unexpected alarms detected:${\n}${alarm_unexpected_status}  console=True  level=WARN
    ...  ELSE  Log  \nNo unexpected alarms detected  console=True
    Run Keyword If  '${blockig_status}'=='PASS' and ${unchanged_cells_status}==True
    ...  Log  All statuses of blocking are True. Continue to unlocking.  console=True
    ...  ELSE  Fail  Not all statuses are True. Please investigate.
    Logging With Timestamp
    ...  message=Step 3 Block Cells On Single Band ${band} and checking states - finished.
    ...  style=DONE

Step 4 Perform L3 Call After Cell Block
#    [Arguments]  ${bts_id}  ${band}
    Logging With Timestamp
    ...  message=Step 4 L3 call to be introduced
    ...  style=STEP
    ...  frame=${TRUE}

Step 5 Unblock Cells On Single Band
    [Arguments]  ${bts_id}  ${band_name}
    Logging With Timestamp
    ...  message=Step 5 Unblock Cells On Single Band ${band_name}.
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Unblocking cells on a single band ${band_name}.
    ...  style=ONGOING
    SM Unblock Cells On Chosen Band  ${bts_id}  ${band_name}  ${NODE_CELLS_DICT}
    Logging With Timestamp
    ...  message=Step 5 Unblock Cells On Single Band ${band_name} finished.
    ...  style=DONE
    ${name}  ${band}  Split String  ${band_name}  separator=_  max_split=1
    ${cellson_band}=  Catenate  SEPARATOR=_  cellson  ${band}
    FOR  ${cell}  IN  @{ALL_CELLS_ON_TL}
      ${bts_id}  ${bts_name}  ${class}  ${global_cell_id}  ${cell_r_number}=  Extract Variables From Cell Dist Name  ${cell}  ${NODE_CELLS_DICT}
      Wait Until Keyword Succeeds  3x  30s  STATE Verify States For All  ${class}  ${bts_id}  timeout=120
    END
    SM Verify Alarm And KPI  ${bts_id}  ${ALL_BLOCKED_CELLS}
    ${no_power_check_to_test}=  Run Keyword And Return Status
    ...  List Should Contain Value  ${RMODS_CHOSEN_FOR_POWER}  no_power_check
    Run Keyword If  ${no_power_check_to_test}==False  SM Verify Power Of The Carriers  ${RMODS_TO_BE_TESTED}

Step 6 Perform L3 Call After Cell Unblock
#    [Arguments]  ${bts_id}  ${band}
    Logging With Timestamp
    ...  message=Step 6 L3 call to be introduced
    ...  style=STEP
    ...  frame=${TRUE}

Step 7 Perform L3 Call On Available Cells
#    [Arguments]  ${bts_id}  ${band}
    Logging With Timestamp
    ...  message=Step 7 L3 call to be introduced
    ...  style=STEP
    ...  frame=${TRUE}

Step 8 Block Cells On Single RAT
    [Arguments]  ${bts_id}  ${rat}
    Logging With Timestamp
    ...  message=Step 8 Block Cells On Single RAT ${rat}
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Blocking cells on a single rat ${rat}.
    ...  style=ONGOING
    ${cells_on_rat}=  Set Variable If  '${rat}'=='NR'  ${CELLS_NR}
    ...  '${rat}'=='LTE'  ${CELLS_LTE}
    ...  '${rat}'=='WCDMA'  ${CELLS_WCDMA}
    ...  '${rat}'=='GSM'  ${CELLS_GSM}
    ${bts_list}=  SM Get BTS_ID For Block Or Lock Cells On Single RAT  ${cells_on_rat}
    ${all_unchanged_cells}=  Run Keyword And Continue On Failure
    ...  SM Block Cells On Chosen RAT  ${bts_list}  ${rat}  ${ALL_CELLS_WITHOUT_GUARDBAND}
    Sleep  15s
    Logging With Timestamp
    ...  message=Step 8 Block Cells On Single RAT ${rat} finished.
    ...  style=DONE
    Logging With Timestamp
    ...  message=Checking states of cells blocked on a single rat.
    ...  style=ONGOING
    ${all_blocked_cells}=  Run Keyword And Continue On Failure
    ...  SM Verify Whether Correct Cells Blocked
    ...  ${bts_list}  ${cells_on_rat}  ${RMODS_TO_BE_TESTED}  ${NODE_CELLS_DICT}
    Set Test Variable  ${ALL_BLOCKED_CELLS}  ${all_blocked_cells}
    ${no_unchanged_cells_status}=  Run Keyword And Return Status  Should Not Be Empty  ${all_unchanged_cells}
    Run Keyword If  ${no_unchanged_cells_status}==True  Run Keyword And Continue On Failure
    ...  SM Verify Whether Correct Cells Unchanged
    ...  ${bts_id}  ${all_unchanged_cells}  ${RMODS_TO_BE_TESTED}  ${NODE_CELLS_DICT}
    ...  ELSE  Log  No unchanged cells to be checked - all cells on test line have been blocked.
    Logging With Timestamp
    ...  message=Checking states of cells blocked on a single rat.
    ...  style=DONE

Step 9 Perform L3 Call After RAT Block
#    [Arguments]  ${bts_id}  ${band}
    Logging With Timestamp
    ...  message=Step 9 L3 call to be introduced
    ...  style=STEP
    ...  frame=${TRUE}

Step 10 Unblock Cells On Single RAT
    [Arguments]  ${bts_id}  ${rat}
    Logging With Timestamp
    ...  message=Step 10 Unblock Cells On Single RAT
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Unblocking cells on single rat ${rat}.
    ...  style=ONGOING
    ${cells_on_rat}=  Set Variable If  '${rat}'=='NR'  ${CELLS_NR}
    ...  '${rat}'=='LTE'  ${CELLS_LTE}
    ...  '${rat}'=='WCDMA'  ${CELLS_WCDMA}
    ...  '${rat}'=='GSM'    ${CELLS_GSM}
    ${bts_list}=  SM Get BTS_ID For Block Or Lock Cells On Single RAT  ${cells_on_rat}
    SM Unblock Cells On Chosen RAT  ${bts_list}  ${rat}
    Sleep  15s
    Logging With Timestamp
    ...  message=Unblocking cells on single rat ${rat} finished.
    ...  style=DONE
    Logging With Timestamp
    ...  message=Checking states after unblocking cells on single RAT ${rat}
    ...  style=ONGOING
    FOR  ${cell}  IN  @{ALL_CELLS_ON_TL}
      ${bts_id}  ${bts_name}  ${class}  ${global_cell_id}  ${cell_r_number}=  Extract Variables From Cell Dist Name  ${cell}  ${NODE_CELLS_DICT}
      Wait Until Keyword Succeeds  3x  30s  STATE Verify States For All  ${class}  ${bts_id}  timeout=120
    END
    SM Verify Alarm And KPI  ${bts_id}  ${ALL_BLOCKED_CELLS}
    ${no_power_check_to_test}=  Run Keyword And Return Status
    ...  List Should Contain Value  ${RMODS_CHOSEN_FOR_POWER}  no_power_check
    Run Keyword If  ${no_power_check_to_test}==False  SM Verify Power Of The Carriers  ${RMODS_TO_BE_TESTED}
    Logging With Timestamp
    ...  message=Step 10 Checking states after unblocking cells on single RAT ${rat} finished.
    ...  style=DONE

Step 11 Perform L3 Call After RAT Unblock
#    [Arguments]  ${bts_id}  ${rat}
    Logging With Timestamp
    ...  message=Step 11 L3 call to be introduced
    ...  style=STEP
    ...  frame=${TRUE}

Step 12 Cell Block Unblock Counters For LTE And NR
    [Arguments]   ${bts_id}  ${rats_on_tl}  ${cell_mcc_mnc_dict}  ${node_cells_dict}
    SM Calculate Counters For LTE And NR  ${bts_id}  ${rats_on_tl}  ${cell_mcc_mnc_dict}  ${node_cells_dict}

Prepare Test Variables For Block Unblock
    Logging With Timestamp
    ...  message=Preconditions For Cell Block Unblock is executed, please wait...
    ...  style=ONGOING

    ${all_cells_info}=  Create List From All Get Cells Info
    Set Test Variable  ${ALL_CELLS_INFO}  ${all_cells_info}

    ${current_block_lock_scf_path}=  admin.Get Current Scf File
    ...  local_dir_path=${TEST_LOGS_PATH}Setup/BTSFiles/${CFG.active_bts_list[0]}/
    ...  file_name=scf_${CFG.active_bts_list[0]}_scf_block_wcdma.xml
    ...  timeout=30
    ...  export_type=configurationAndRuntimeObjects
    ...  connection=${CFG.active_bts_list[0]}

    ${all_cells_on_tl}  ${node_cells_dict}  ${cells_nr}  ${cells_lte}  ${cells_wcdma}  ${cells_gsm}=  Create All Cells DNs List
    Set Test Variable  ${ALL_CELLS_ON_TL}  ${all_cells_on_tl}
    Set Test Variable  ${NODE_CELLS_DICT}  ${node_cells_dict}

    ${node_rat_cells_dict}=  Create Cells Dictionary Grouped By Node Rat Band  ${RNC_DICT}  ${BSC_DICT}
    Set Test Variable  ${NODE_RAT_CELLS_DICT}  ${node_rat_cells_dict}

##### ========= Those three could be done at the same time - would it be better to combine?
    ${bands_on_tl_list}=  Create Bands On Tl List  ${node_rat_cells_dict}
    Set Test Variable  ${BANDS_ON_TL_LIST}  ${bands_on_tl_list}

    ${all_cells_class_on_tl}=  Create All Available On TL Cells Class Names  ${all_cells_on_tl}
    Set Test Variable  ${ALL_CELLS_CLASS_ON_TL}  ${all_cells_class_on_tl}

    ${iot_cells}  ${iot_bands}=  Get Guardband Cells From Cells Info Dictionary  ${node_rat_cells_dict}
    Set Test Variable  ${IOT_CELLS}  ${iot_cells}
    Set Test Variable  ${IOT_BANDS}  ${iot_bands}
##### ========= Those three could be done at the same time - would it be better to combine?


    ${all_cells_without_guardband}=  Remove Guardband Cells From All Cells List  ${ALL_CELLS_ON_TL}  ${iot_cells}
    Set Test Variable  ${ALL_CELLS_WITHOUT_GUARDBAND}  ${all_cells_without_guardband}

    ${rats_upper_case}  ${cells_nr}  ${cells_lte}  ${cells_wcdma}  ${cells_gsm}=
    ...  Create Cells By Rat And Rats To Test  ${iot_cells}  ${cells_nr}  ${cells_lte}  ${cells_wcdma}  ${cells_gsm}
    Set Test Variable  ${RATS_ON_TL}  ${rats_upper_case}
    Set Test Variable  ${CELLS_NR}  ${cells_nr}
    Set Test Variable  ${CELLS_LTE}  ${cells_lte}
    Set Test Variable  ${CELLS_WCDMA}  ${cells_wcdma}
    Set Test Variable  ${CELLS_GSM}  ${cells_gsm}

    ${rats_to_be_tested}=  Select Rats To Be Tested  ${rats_upper_case}  ${CHOSEN_RATS}
    Set Test Variable  ${RATS_TO_TEST}  ${rats_to_be_tested}

    ${nr_exists}=  Run Keyword And Return Status  List Should Contain Value  ${RATS_ON_TL}  NR
    ${lte_exists}=  Run Keyword And Return Status  List Should Contain Value  ${RATS_ON_TL}  LTE
    ${nr_or_lte_exists}=  Run Keyword And Return Status  Set Variable If  ${nr_exists}==True or ${lte_exists}==True  ${True}  ${False}
    Set Test Variable  ${NR_OR_LTE_EXISTS}  ${nr_or_lte_exists}

    ${tested_bands}=  SM Select Cells To Be Blocked Or Locked By Band  ${IOT_BANDS}  ${ALL_CELLS_INFO}  ${CHOSEN_BANDS}  ${BANDS_ON_TL_LIST}
    Set Test Variable  ${TESTED_BANDS}  ${tested_bands}

    Logging With Timestamp
    ...  message=Prepare Test Variables For Block Unblock finished
    ...  style=DONE

    ${rmod_sn_dn_dict}=  Create RMOD Serial Number Dist Name Dictionary
    Set Test Variable  ${RMOD_SN_DN_DICT}  ${rmod_sn_dn_dict}

    ${rmods_to_be_tested}=  Create List Of RMODs For Power Verification  ${rmod_sn_dn_dict}  ${RMODS_CHOSEN_FOR_POWER}
    ${rmod_list_not_empty}=  Run Keyword And Return Status  Should Not Be Empty  ${rmods_to_be_tested}
    Set Test Variable  ${RMODS_TO_BE_TESTED}  ${rmods_to_be_tested}
    Logging With Timestamp
    ...  message=Checking FMCADM parameters for block unblock, please wait...
    ...  style=ONGOING
    SM Check FMCADM Parameters


    ${perform_call_status}  Run Keyword And Return Status  Variable Should Exist  ${PERFORM CALL}
    ${should_perform_call}=  Run Keyword If  ${perform_call_status}==True  Run Keywords
    ...  Check If L3 Call Should Be Performed  ${PERFORM_CALL}  AND
    ...  Set Test Variable  ${SHOULD_PERFORM_CALL}  ${should_perform_call}
    ...  ELSE  Set Variable  False

    ${cell_mcc_mnc_dict}=  Get MCC And MNC From SCF  ${current_block_lock_scf_path}  ${CELLS_LTE}
    Set Test Variable  ${CELL_MCC_MNC_DICT}  ${cell_mcc_mnc_dict}
