*** Settings ***
Documentation
    ...  AUTHOR-kamil.adamowski@nokia.com  MAINTAINER-kamil.adamowski@nokia.com
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-34809
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...  PRECONDITIONS:
    ...  The test requires SCF prepared so that only recommissioning of activating parameters
    ...  is required from the test:
    ...  - for 5GC000431 actNrLBPowerSaving = True
    ...  To activate actNrLBPowerSaving parameter, the following steps are required
    ...  (the test only chacks if they were commissioned):
    ...  - creating at least one NRPGRP (MRBTS-xxxx/NRBTS-xxxx/NRPGRP-x)
    ...  - creating a Structure-x under lbpsPeriodList
    ...    for each cell on tested RMOD and day of the week when testing
    ...    - if testing should be possible 24/7 create seven structures,
    ...      for each choose different lbpsCellDayOfWeek "Mon" (Possible: Mon, Tue, Wed, Thu, Fri, Sat, Sun)
    ...      for each set llbpsCellDuration to "1440" min (=24h)
    ...      set llbpsSOMethod to "cell switch off"
    ...      lbpsStartTimeHour leave with "0" h
    ...      lbpsStartTimeMinute leave with "0" min
    ...      nrCellId must be set to the tested cell number
    ...  - creating Strucuture-x under Load-based power saving cell list (lbpsCellList)
    ...    for each cell on tested RMOD
    ...    - leave lbpsUseExtConfig to "false"
    ...    - nrCellId to cell number
    ...  - for CB013099 need to added allowed fault lbpsFaultToleranceList - please set FID10 as starter
    ...    Additionally NRPGRP-0 group must be set on the two radio.
    ...    One of them must be radio where fault will be generated on the second one cells will be checked

    ...  Step 1: Preconditions
    ...  Select tested RMOD, verify FAULTY_RMOD_SN, check NRCELLs
    ...  Check if actPowerMeter is Active

    ...  Step 2: Activate EE parameters
    ...  Set actNrLBPowerSaving=True

    ...  Step 3: Wait for cell switch-off
    ...  Monitor NRCELL states

    ...  Step 4: Enable allowed fault (CB013099)
    ...  Change FID from 10 to 2900 in lbpsFaultToleranceList

    ...  Step 5: Trigger PIM fault (FID 2900)
    ...  Set PIMC thresholds (minor=-180, major=-179)
    ...  Wait for alarms 1999 (Minor) and 2900 (Major)
    ...  Fail if 2900 not Active

    ...  Step 6: Verify cells under degradation
    ...  Soft reset RU
    ...  Verify if NRCELL could go to EE states

    ...  Step 7: Deactivate allowed fault
    ...  Change allowed FID from 2900 to 10
    ...  Verify cells are onAir

    ...  Step 8: Deactivate PIM fault
    ...  Restore/clear PIMC thresholds
    ...  Verify no active alarms on TX lines

    ...  Step 9: Deactivate EE
    ...  Set actNrLBPowerSaving=False
    ...  Confirm parameter state and all cells onAir

    ...  Teardown
    ...  If test FAIL and TEARDOWN_RECOMMISSIONING=True, restore baseline from initial_scf.xml



Resource  ../../Resources/Robot/SM.robot
Resource  ../../Resources/Robot/variables_preparation.robot
Resource  ../../Resources/variables_custom.robot
Resource  ../../TestCases/PM/PM_Radio_Module_Thermal_Counters_Monitoring_And_Alarm_Triggering.robot

*** Variables ***
${RMOD_SN}=               # Mandatory, provide one SN of an RMOD to be tested
${FAULTY_RMOD_SN}=        # Mandatory, provide one SN of and RMOD where fault will be generated
${MTSBTSRFM_INTERVAL}=  5min  # Optional, possible values: disabled, 5min, 15min, 30min, 60min, 360min, 720min, 1440min
${INTERVAL}=  5
${LNCEL_sleep_states}=  administrativeState=regex"(?i)unlocked", operationalState=regex"(?i)disabled", blockingState=regex"(?i)Unblocked"
${NRCEL_sleep_states}=  administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Disabled", blockingState=regex"(?i)Unblocked"

*** Keywords ***
TC__PM_Cell_Degradation_Handling_With_Cell_Switch_Off
    Common Test Setup
    Logging With Timestamp
    ...  message=Executing TC__PM_Cell_Degradation_Handling_With_Cell_Switch_Off
    ...  style=ONGOING
    ${bts_id}  Get From Dictionary  ${CFG}  primary_node_bts_id
    Set Test Variable  ${bts_id}
    Step 1 Preconditions For Cell Switchoff with cell degradation  ${bts_id}
    Step 2 Activate Parameters For EE   ${bts_id}
    Step 3 Wait For Switch Off  ${bts_id}
    Step 4 Activate allowed fault in feature CB013099  ${bts_id}
    Step 5 Trigger the pre-configured tolerated fault 2900  ${bts_id}
    Step 6 Check if the cells are able to enter EE mode  ${bts_id}
    Step 7 Deactivate allowed fault in feature CB013099  ${bts_id}
    Step 8 Deactivate pre-configured fault 2900  ${bts_id}
    Step 9 Deactivate Parameters For EE  ${bts_id}
    [Teardown]  Teardown_PM_cell_degradation_handling_with_cell_switch_off  tc_status=${KEYWORD_STATUS}

Step 1 Preconditions For Cell Switchoff with cell degradation
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 1 Preconditions For Cell Switchoff with cell degradation
    ...  style=STEP
    ...  frame=${TRUE}
    Set Test Variable  ${TEARDOWN_RECOMMISSIONING}  ${False}

    Logging With Timestamp
    ...  message=Looking for the radio where cells will be tested.
    ...  style=ONGOING

    ${rmod_dn}  ${rmod_name}  ${tested_rmod_dn_r}  ${deepsleep_support}=  Get Tested RMOD Details  ${bts_id}
    Set Test Variable  ${TESTED_RMOD_DN}  ${rmod_dn}
    Set Test Variable  ${TESTED_RMOD_NAME}  ${rmod_name}
    Set Test Variable  ${TESTED_RMOD_DN_R}  ${tested_rmod_dn_r}
    Set Test Variable  ${DEEPSLEEP_SUPPORT}  ${deepsleep_support}

    IF  '${FAULTY_RMOD_SN}'=='${NONE}'
      Logging With Timestamp
      ...  message=Serial Number of the radio where fault 2900 should be generated not provided ! Test set to Fail !
      ...  style=ERROR
      Fail  Serial Number of the radio where fault 2900 should be generated not provided ! Test set to Fail !
    ELSE
      Logging With Timestamp
      ...  message=RMOD for generate fault found in configuration!
      ...  style=DONE
    END

    Logging With Timestamp
    ...  message=Looking for the NR cells of the tested radio.
    ...  style=ONGOING

    ${nrcell_list}  Get Ids For All  NRCEL  connection=${bts_id}
    ${nrcel_count}=  Get Length  ${nrcell_list}
    Set Test Variable  ${NRCEL_COUNT}  ${nrcel_count}

    ${tested_cells_dns}=  admin.Get Cell Mapping By Module ID
    ...  module_id=${tested_rmod_dn_r}
    ...  timeout=60
    ...  connection=${bts_id}
    Set Test Variable  ${TESTED_CELLS_DNS}  ${tested_cells_dns}

    ${status_nr}=  Evaluate  ${NRCEL_COUNT} > 0
    IF  ${status_nr}==${True}
      Logging With Timestamp
      ...  message=NR present in the test line, checking whether actNrLBPowerSaving active.
      ...  style=ONGOING
      Check Whether actNrLBPowerSaving Active  ${bts_id}  ${False}
    ELSE
      Logging With Timestamp
      ...  message=NR NOT present in the test line.
      ...  style=ERROR
      Fail  Tested RMOD ${RMOD_SN} don't have NR cells!
    END

    Check Whether actPowerMeter Active  ${bts_id}    #KW below
    Check Whether mtSBTSSmEnergyMonitoring Active  ${bts_id}    #KW below

    STATE Verify States For One
    ...  class=RMOD
    ...  object=${TESTED_RMOD_DN_R}
    ...  node_id=${bts_id}
    ...  onair=${TRUE}
    ...  timeout=60

    FOR  ${tested_cell_dn}  IN  @{tested_cells_dns}
      ${path}  ${bts_r_number}  ${cell_r_number}=   Split String From Right  ${tested_cell_dn}  separator=/  max_split=2
      ${class}=  Fetch From Left  ${cell_r_number}  marker=_
      ${class}=  Set Variable If  '${class}'=='NRCELL'  NRCEL  ${class}
      STATE Verify States For One
      ...  class=${class}
      ...  object=${tested_cell_dn}
      ...  node_id=${bts_id}
      ...  onair=${TRUE}
      ...  timeout=60
    END

    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  20  STATE Verify Multi Node State  scf_check=${FALSE}

    admin.Get Current Scf File
    ...  local_dir_path=${TEST_LOGS_PATH}BTSFiles/${bts_id}/
    ...  file_name=initial_scf.xml
    ...  timeout=30
    ...  connection=${bts_id}
    ...  export_type=configurationAndRuntimeObjects
    ...  parameters_save_variant=None

    Logging With Timestamp
    ...  message=Step 1 Preconditions For Cell Switchoff For Energy
    ...  style=DONE

Step 2 Activate Parameters For EE
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 2 Activate Parameters For EE
    ...  style=STEP
    ...  frame=${TRUE}
    Set Test Variable  ${TEARDOWN_RECOMMISSIONING}  ${True}

    ${status_nr}=  Evaluate  ${NRCEL_COUNT} > 0
    IF  ${status_nr}==${True}
      Logging With Timestamp
      ...  message=Activating parameter actNrLBPowerSaving for MRBTS-${bts_id}/NRBTS-${bts_id}.
      ...  style=ONGOING
      admin.Perform Parameter Recommissioning
      ...  dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}
      ...  parameter=actNrLBPowerSaving
      ...  operation=update
      ...  value=${True}
      ...  skip_parameter_relation_errors=${True}
      ...  timeout=60
      ...  connection=${bts_id}
      Check Whether actNrLBPowerSaving Active  ${bts_id}  ${True}
    ELSE
      Logging With Timestamp
      ...  message=Parameter actNrLBPowerSaving for MRBTS-${bts_id}/NRBTS-${bts_id} active.
      ...  style=DONE
    END

    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  20  STATE Verify Multi Node State  scf_check=${FALSE}

Step 3 Wait For Switch Off
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 3 Wait For Switch Off
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp
    ...  message=Waiting for cells switch off.
    ...  style=ONGOING
    Sleep  605s  Waiting for cells switch off.

    FOR  ${tested_cell_dn}  IN  @{tested_cells_dns}
      ${path}  ${bts_r_number}  ${cell_r_number}=   Split String From Right  ${tested_cell_dn}  separator=/  max_split=2
      ${class}=  Fetch From Left  ${cell_r_number}  marker=_
      ${class}=  Set Variable If  '${class}'=='NRCELL'  NRCEL  ${class}
      IF  '${class}'=='NRCEL'
        STATE Verify States For One
        ...  class=${class}
        ...  object=${tested_cell_dn}
        ...  node_id=${bts_id}
        ...  states=${${class}_sleep_states}
        ...  onair=${FALSE}
        ...  timeout=310
      END
    END

    STATE Verify States For One
    ...  class=RMOD
    ...  object=${TESTED_RMOD_DN_R}
    ...  node_id=${bts_id}
    ...  onair=${TRUE}
    ...  timeout=60

Step 4 Activate allowed fault in feature CB013099
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 4 Activate allowed fault in feature CB013099
    ...  style=STEP
    ...  frame=${TRUE}

    ${parameter_list}=  Evaluate  [{"parameterName":"lbpsFaultToleranceList","operation":"update","value":[{"lbpsToleratedFaultId":"2900"}]}]

    Logging With Timestamp
    ...  message=Perform recommissioning, please wait!
    ...  style=ONGOING
    Wait Until Keyword Succeeds  300 sec  20 sec  admin.Perform Object Recommissioning
    ...  dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRPGRP-0
    ...  parameter=${parameter_list}
    ...  operation=update
    ...  connection=${bts_id}
    Logging With Timestamp
    ...  message=Perform recommissioning done, set: lbpsToleratedFaultId -> 2900
    ...  style=DONE


Step 5 Trigger the pre-configured tolerated fault 2900
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 5 Trigger the pre-configured tolerated fault 2900
    ...  style=STEP
    ...  frame=${TRUE}

    #Below code is based on test SiSo_FM_NR_PIMC_Faults_Triggering

    Logging With Timestamp
    ...  message=Get information about radio where fault should be triggered
    ...  style=ONGOING

    ${rmods_info}  admin.Get FRM  60  ${bts_id}
    FOR  ${rmod}  IN  @{rmods_info}
        Continue For Loop If  '${rmod['serialNumber']}'!='${FAULTY_RMOD_SN}'
        ${rmod_config_id}  Set Variable  ${rmod['id']['configuration']}
        ${txrx_ants}  Set Variable  ${rmod['antenaUsageInfo']}
        ${carrier_list}  Set Variable  ${rmod['carrierList']}
    END

    ${TXRX_ANTS_LIST}  Create List
    FOR  ${ants}  IN  @{txrx_ants}
        Run Keyword If  '${ants['direction']}'=='TX/RX'  Append To List  ${TXRX_ANTS_LIST}  ${ants['id']['runtime']}
    END
    Set Test Variable  ${TXRX_ANTS_LIST}

    ${rmod_number}  Evaluate  '${rmod_config_id}'.rsplit('-',1)[1]
    ${query_path}  Set Variable  /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/EQM_A-*/APEQM_A-*/RMOD_A-${rmod_number}
    Set Test Variable  ${PIMC_OBJECT}  MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${rmod_number}

    ${rmod_object}  admin_im.Query Infomodel  get object ${query_path}   allow_negative_result=True  alias=${bts_id}
    ${act_pim_can}  Set Variable  ${rmod_object.actPimCancellation}
    ${pim_can_ena}  Set Variable  ${rmod_object.pimCancellingEnabled}

    Logging With Timestamp
    ...  message=Change parameters actPimCancellation and pimCancellingEnabled
    ...  style=ONGOING

    ${status}  Run Keyword And Return Status  Should Be Equal As Strings  ${act_pim_can}  True
    ...  actPimCancellation must be set to False before TC run !  values=False
    Run Keyword If  '${status}'=='False'  Run Keywords
    ...  Log to console  actPimCancellation now is set to False, recommissioning to True !${\n}
    ...  AND  Perform Parameter Recommissioning  ${PIMC_OBJECT}  actPimCancellation  update  true  alias=${bts_id}

    Sleep  3s
    ${status}  Run Keyword And Return Status  Should Be Equal As Strings  ${pim_can_ena}  True
    ...  pimCancellingEnabled must be set to False before TC run !  values=False
    Run Keyword If  '${status}'=='False'  Run Keywords
    ...  Log to console  pimCancellingEnabled now is set to False, recommissioning to True !${\n}
    ...  AND  Perform Parameter Recommissioning  ${PIMC_OBJECT}  pimCancellingEnabled  update  true  alias=${bts_id}

    ${rmod_object}  admin_im.Query Infomodel  get object ${query_path}   allow_negative_result=True  alias=${bts_id}
    ${pim_can_ena}  Set Variable  ${rmod_object.pimCancellingEnabled}

    ${status}  Run Keyword And Return Status  Should Be Equal As Strings  ${pim_can_ena}  True
    ...  pimCancellingEnabled cannot be set to True via API !  values=False
    Run Keyword If  '${status}'=='False'  Run Keywords
    ...  Perform Parameter Recommissioning  ${PIMC_OBJECT}  actPimCancellation  update  false  alias=${bts_id}
    ...  AND  Fail  Cannot set pimCancellingEnabled to true via API ! Set TC fail !

    Logging With Timestamp
    ...  message=All preconditions met, going to generate FID 2900!
    ...  style=DONE

    #Generating FID2900

    Logging With Timestamp
    ...  message=Setting PIMC Thresholds: minor=-180 and major=-179 ...
    ...  style=ONGOING
    Set PIMc Thresholds  minor=-180  major=-179  bts_id=${bts_id}

    Logging With Timestamp
    ...  message=Waiting 3600s for active alarm 2900 in a minute intervals, please wait!
    ...  style=ONGOING

    ${alarm1_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  3600s  60s
    ...  Wait For Alarm  Active  ${TXRX_ANTS_LIST}  1999  Minor

    ${alarm2_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  3600s  60s
    ...  Wait For Alarm  Active  ${TXRX_ANTS_LIST}  2900  Major   #KW below

    IF  '${alarm2_status}'=='True'
        Logging With Timestamp
        ...  message=Minor alarm 2900 is active for TX antenna lines
        ...  style=DONE
    ELSE
        Logging With Timestamp
        ...  message=Minor alarm 2900 is NOT active for TX antenna line
        ...  style=ERROR
        FAIL  Minor alarm 2900 is NOT active for TX antenna line(s)
    END

Step 6 Check if the cells are able to enter EE mode
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 6 Check if the cells are able to enter EE mode
    ...  style=STEP
    ...  frame=${TRUE}

    ${rmods_info}  admin.Get FRM  timeout=60  connection=${bts_id}

    FOR  ${rmod}  IN  @{rmods_info}
        Continue For Loop If  '${rmod['serialNumber']}'!='${RMOD_SN}'
        Set Test Variable  ${RMOD_DISTNAME_ID}  ${rmod['id']['internal']}
    END

    Logging With Timestamp
    ...  message=Soft resetting RU to check if the cells are able to enter EE
    ...  style=ONGOING
    admin.Reset Unit  ${RMOD_DISTNAME_ID}  timeout=320  connection=${bts_id}

    Logging With Timestamp
    ...  message=Waiting for cells switch off.
    ...  style=ONGOING
    Sleep  605s  Waiting for cells switch off.

    FOR  ${tested_cell_dn}  IN  @{tested_cells_dns}
      ${path}  ${bts_r_number}  ${cell_r_number}=   Split String From Right  ${tested_cell_dn}  separator=/  max_split=2
      ${class}=  Fetch From Left  ${cell_r_number}  marker=_
      ${class}=  Set Variable If  '${class}'=='NRCELL'  NRCEL  ${class}
      IF  '${class}'=='NRCEL'
        STATE Verify States For One
        ...  class=${class}
        ...  object=${tested_cell_dn}
        ...  node_id=${bts_id}
        ...  states=${${class}_sleep_states}
        ...  onair=${FALSE}
        ...  timeout=310
      END
    END

    STATE Verify States For One
    ...  class=RMOD
    ...  object=${TESTED_RMOD_DN_R}
    ...  node_id=${bts_id}
    ...  onair=${TRUE}
    ...  timeout=60

Step 7 Deactivate allowed fault in feature CB013099
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 7 Deactivate allowed fault in feature CB013099
    ...  style=STEP
    ...  frame=${TRUE}

    ${parameter_list}=  Evaluate  [{"parameterName":"lbpsFaultToleranceList","operation":"update","value":[{"lbpsToleratedFaultId":"10"}]}]

    Logging With Timestamp
    ...  message=Perform recommissioning, please wait!
    ...  style=ONGOING
    Wait Until Keyword Succeeds  300 sec  20 sec  admin.Perform Object Recommissioning
    ...  dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRPGRP-0
    ...  parameter=${parameter_list}
    ...  operation=update
    ...  connection=${bts_id}
    Logging With Timestamp
    ...  message=Perform recommissioning done, set: lbpsToleratedFaultId -> 10
    ...  style=DONE

    Logging With Timestamp
    ...  message=Check if the cells turn on and deactivated EE state
    ...  style=ONGOING

    FOR  ${tested_cell_dn}  IN  @{tested_cells_dns}
      ${path}  ${bts_r_number}  ${cell_r_number}=   Split String From Right  ${tested_cell_dn}  separator=/  max_split=2
      ${class}=  Fetch From Left  ${cell_r_number}  marker=_
      ${class}=  Set Variable If  '${class}'=='NRCELL'  NRCEL  ${class}
      IF  '${class}'=='NRCEL'
        STATE Verify States For One
        ...  class=${class}
        ...  object=${tested_cell_dn}
        ...  node_id=${bts_id}
        # ...  states=${${class}_sleep_states}
        ...  onair=${TRUE}
        ...  timeout=310
      END
    END

    Logging With Timestamp
    ...  message=Waiting 10 min to double check for cells could switch off.
    ...  style=ONGOING
    Sleep  605s  Waiting to check if the cells could switch off.

    FOR  ${tested_cell_dn}  IN  @{tested_cells_dns}
      ${path}  ${bts_r_number}  ${cell_r_number}=   Split String From Right  ${tested_cell_dn}  separator=/  max_split=2
      ${class}=  Fetch From Left  ${cell_r_number}  marker=_
      ${class}=  Set Variable If  '${class}'=='NRCELL'  NRCEL  ${class}
      IF  '${class}'=='NRCEL'
        STATE Verify States For One
        ...  class=${class}
        ...  object=${tested_cell_dn}
        ...  node_id=${bts_id}
        # ...  states=${${class}_sleep_states}
        ...  onair=${TRUE}
        ...  timeout=310
      END
    END

Step 8 Deactivate pre-configured fault 2900
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 8 Deactivate pre-configured fault
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp
    ...  message=Setting PIMc Thresholds: minor=-31 and major=-30
    ...  style=ONGOING
    Set PIMc Thresholds  minor=-31  major=-30  bts_id=${bts_id}

    Logging With Timestamp
    ...  message=Waiting 3600s for inactive alarm 2900 in 60s intervals, please wait!
    ...  style=ONGOING
    ${alarm2_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  3600s  60s
    ...  Wait For Alarm  Inactive  ${TXRX_ANTS_LIST}  2900  Major   #KW below

    IF  '${alarm2_status}'=='True'
        Logging With Timestamp
        ...  message=Minor alarm 2900 is inactive for TX antenna lines
        ...  style=DONE
    ELSE
        Logging With Timestamp
        ...  message=Minor alarm 2900 is STILL active for TX antenna line
        ...  style=ERROR
        FAIL  Minor alarm 2900 is STILL active for TX antenna line(s)
    END

Step 9 Deactivate Parameters For EE
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 9 Deactivate Parameters For EE
    ...  style=STEP
    ...  frame=${TRUE}

    ${status_nr}=  Evaluate  ${NRCEL_COUNT} > 0
    IF  ${status_nr}==${True}
      Logging With Timestamp
      ...  message=Deactivating parameter actNrLBPowerSaving for MRBTS-${bts_id}/NRBTS-${bts_id}.
      ...  style=ONGOING
      admin.Perform Parameter Recommissioning
      ...  dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}
      ...  parameter=actNrLBPowerSaving
      ...  operation=update
      ...  value=${False}
      ...  skip_parameter_relation_errors=${True}
      ...  timeout=60
      ...  connection=${bts_id}
      Check Whether actNrLBPowerSaving Active  ${bts_id}  ${False}
    ELSE
      Logging With Timestamp
      ...  message=Parameter actNrLBPowerSaving for MRBTS-${bts_id}/NRBTS-${bts_id} inactive.
      ...  style=DONE
    END

Get Tested RMOD Details
    [Arguments]  ${bts_id}
    [Documentation]  This keyword retrieves details of the tested RMOD based on its serial number.
    ...
    ...  It verifies if the RMOD is present in the configuration, retrieves its details, and checks if it supports DeepSleep.
    ...
    ...  Arguments:
    ...  +========================+======+==========================================================+
    ...  | Argument               | Man. | Description                                              |
    ...  +========================+======+==========================================================+
    ...  | bts_id                 | Yes  | The BTS ID to which the RMOD is connected.               |
    ...  +------------------------+------+----------------------------------------------------------+
    ...
    ...  Behavior:
    ...  - Checks if the tested RMOD is present in the configuration.
    ...  - Retrieves the RMOD's distinguished name (DN) and variant name.
    ...  - Identifies the RMOD's distribution name for testing.
    ...  - Verifies if the RMOD supports DeepSleep.
    ...
    ...  Returns:
    ...  - The RMOD's distinguished name (DN).
    ...  - The RMOD's variant name.
    ...  - The RMOD's distribution name for testing.
    ...  - A boolean indicating whether the RMOD supports DeepSleep.
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    ${rmods_sns}=  Get Dictionary Keys  ${CFG.RF_INFO}
    ${chosen_rmod_in_tl_status}=  Run Keyword And Return Status  List Should Contain Value  ${rmods_sns}  ${RMOD_SN}

    IF  ${chosen_rmod_in_tl_status}==${False}
      Logging With Timestamp
      ...  message=Tested RMOD ${RMOD_SN} NOT found in CFG. Check SN and configuration files!
      ...  style=ERROR
      Fail  Tested RMOD ${RMOD_SN} NOT found in CFG. Check SN and configuration files!
    ELSE
      Logging With Timestamp
      ...  message=Tested RMOD ${RMOD_SN} found in CFG. Continue testing.
      ...  style=DONE
    END

    ${rmod_dn}=  Get From Dictionary  ${CFG.RF_INFO['${RMOD_SN}']}  scf_dist_name_primary
    ${rmod_name}=  Get From Dictionary  ${CFG.RF_INFO['${RMOD_SN}']}  scf_variant
    &{sfp_links}=  admin.Get Sfp Links  connection=${bts_id}
    FOR  ${link}  IN  @{sfp_links['connected']}
      Continue For Loop If  '${RMOD_SN}'!='${link['parent']['source']['parameters']['serialNumber']}'
      ${tested_rmod_dn_r}=  Set Variable  ${link['parent']['source']['distName']}
      Exit For Loop
    END

    ${deepsleep_list_exist}=  Run Keyword And Return Status  Variable Should Exist  ${RMODS_SUPPORTING_DEEP_SLEEP}
    IF  ${deepsleep_list_exist}==${True}
      ${deepsleep_support}=  Run Keyword And Return Status  List Should Contain Value  ${RMODS_SUPPORTING_DEEP_SLEEP}  ${rmod_name}
    ELSE
      Logging With Timestamp
      ...  message=List ${RMODS_SUPPORTING_DEEP_SLEEP} does not exist. Check resources!
      ...  style=ERROR
      Fail  List ${RMODS_SUPPORTING_DEEP_SLEEP} does not exist. Check resources!
    END

    [Return]  ${rmod_dn}  ${rmod_name}  ${tested_rmod_dn_r}  ${deepsleep_support}

Check Whether actNrLBPowerSaving Active
    [Arguments]  ${bts_id}  ${is_active}=${False}
    [Documentation]  This keyword verifies whether the `actNrLBPowerSaving` parameter is active for the specified BTS.
    ...
    ...  It retrieves the `actNrLBPowerSaving` parameter value and compares it with the expected state.
    ...  If the parameter value does not match the expected state, the test fails with an appropriate error message.
    ...
    ...  Arguments:
    ...  +========================+======+==========================================================+
    ...  | Argument               | Man. | Description                                              |
    ...  +========================+======+==========================================================+
    ...  | bts_id                 | Yes  | The BTS ID to which the parameter belongs.               |
    ...  | is_active              | No   | Expected state of the `actNrLBPowerSaving` parameter.    |
    ...  +------------------------+------+----------------------------------------------------------+
    ...
    ...  Behavior:
    ...  - Retrieves the `actNrLBPowerSaving` parameter value for the specified BTS.
    ...  - Compares the parameter value with the expected state (`is_active`).
    ...  - Logs whether the parameter value matches the expected state.
    ...  - Fails the test if the parameter value does not match the expected state.
    ...
    ...  Returns:
    ...  - None
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    ${nrbts_info}=  admin.Get Parameter By Distname  MRBTS-${bts_id}/NRBTS-${bts_id}  connection=${bts_id}
    ${act_nr_lb_power_param}=  Get From Dictionary  ${nrbts_info[0]['parameters']}  actNrLBPowerSaving
    IF  ${is_active}==${False}
      IF  ${act_nr_lb_power_param}==${True}
        Logging With Timestamp
        ...  message=Parameter actNrLBPowerSaving for MRBTS-${bts_id}/NRBTS-${bts_id} activated. Check SCF!
        ...  style=ERROR
        Fail  Parameter actNrLBPowerSaving for MRBTS-${bts_id}/NRBTS-${bts_id} activated. Check SCF!
      ELSE
        Logging With Timestamp
        ...  message=Parameter actNrLBPowerSaving for MRBTS-${bts_id}/NRBTS-${bts_id} NOT activated. Expected value.
        ...  style=DONE
      END
    ELSE
      IF  ${act_nr_lb_power_param}==${False}
        Logging With Timestamp
        ...  message=Parameter actNrLBPowerSaving for MRBTS-${bts_id}/NRBTS-${bts_id} NOT activated. Unexpected value!
        ...  style=ERROR
        Fail  Parameter actNrLBPowerSaving for MRBTS-${bts_id}/NRBTS-${bts_id} NOT activated. Unexpected value!
      ELSE
        Logging With Timestamp
        ...  message=Parameter actNrLBPowerSaving for MRBTS-${bts_id}/NRBTS-${bts_id} activated. Expected value.
        ...  style=DONE
      END
    END

Check Whether actPowerMeter Active
    [Arguments]  ${bts_id}
    [Documentation]  This keyword verifies whether the `actPowerMeter` parameter is active for the specified BTS.
    ...
    ...  It retrieves the `actPowerMeter` parameter value and checks if it is activated.
    ...  If the parameter is not activated, the test fails and attempts to activate it.
    ...
    ...  Arguments:
    ...  +========================+======+==========================================================+
    ...  | Argument               | Man. | Description                                              |
    ...  +========================+======+==========================================================+
    ...  | bts_id                 | Yes  | The BTS ID to which the parameter belongs.               |
    ...  +------------------------+------+----------------------------------------------------------+
    ...
    ...  Behavior:
    ...  - Retrieves the `actPowerMeter` parameter value for the specified BTS.
    ...  - Logs whether the parameter is activated or not.
    ...  - Fails the test if the parameter is not activated and attempts to activate it.
    ...
    ...  Returns:
    ...  - None
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    ${featcadm_parameter}  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1  connection=${bts_id}
    ${act_power_meter_value}  Get From Dictionary  ${featcadm_parameter[0]['parameters']}  actPowerMeter
    IF  ${act_power_meter_value}==${False}
      Logging With Timestamp
      ...  message=Parameter actPowerMeter for MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1 NOT activated. Check SCF!
      ...  style=WARNING
      Fail  Parameter actPowerMeter for MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1 NOT activated. Check SCF!
      admin.Perform Parameter Recommissioning
      ...  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
      ...  parameter=actPowerMeter
      ...  operation=update
      ...  value=${TRUE}
      ...  skip_parameter_relation_errors=${True}
      ...  timeout=60
      ...  connection=${bts_id}
    ELSE
      Logging With Timestamp
      ...  message=Parameter actPowerMeter for MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1 activated.
      ...  style=DONE
    END

Check Whether mtSBTSSmEnergyMonitoring Active
    [Arguments]  ${bts_id}
    [Documentation]  This keyword verifies whether the `mtSBTSSmEnergyMonitoring` parameter is active for the specified BTS.
    ...
    ...  It retrieves the `mtSBTSSmEnergyMonitoring` parameter value and updates it if necessary.
    ...  If the parameter is not found or has an unexpected value, the test fails with an appropriate error message.
    ...
    ...  Arguments:
    ...  +========================+======+==========================================================+
    ...  | Argument               | Man. | Description                                              |
    ...  +========================+======+==========================================================+
    ...  | bts_id                 | Yes  | The BTS ID to which the parameter belongs.               |
    ...  +------------------------+------+----------------------------------------------------------+
    ...
    ...  Behavior:
    ...  - Retrieves the `mtSBTSSmEnergyMonitoring` parameter value for the specified BTS.
    ...  - Updates the parameter value if it does not match the expected value.
    ...  - Logs whether the parameter value matches the expected value.
    ...  - Fails the test if the parameter is not found or has an unexpected value.
    ...
    ...  Returns:
    ...  - None
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    ${pmmnl_parameter}=  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1  connection=${bts_id}
    ${status}  ${mtSBTSSmEnergyMonitoring_value}=  Run Keyword And Ignore Error
    ...  Get From Dictionary  ${pmmnl_parameter[0]['parameters']}  mtSBTSSmEnergyMonitoring
    IF  '${status}'=='FAIL'
      Logging With Timestamp
      ...  message=Parameter mtSBTSSmEnergyMonitoring for MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1 NOT found. Check SCF!
      ...  style=ERROR
      Fail  Parameter mtSBTSSmEnergyMonitoring for MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1 NOT found. Check SCF!
    ELSE
      Logging With Timestamp
      ...  message=Updating parameter mtSBTSSmEnergyMonitoring for MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1.
      ...  style=ONGOING
      admin.Perform Parameter Recommissioning
        ...  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1
        ...  parameter=mtSBTSSmEnergyMonitoring
        ...  operation=update
        ...  value=${MTSBTSRFM_INTERVAL}
        ...  skip_parameter_relation_errors=${True}
        ...  timeout=60
        ...  connection=${bts_id}
      ${pmmnl_parameter2}=  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1  connection=${bts_id}
      ${mtSBTSSmEnergyMonitoring_value2}=  Get From Dictionary  ${pmmnl_parameter2[0]['parameters']}  mtSBTSSmEnergyMonitoring
      ${mtSBTSSmEnergyMonitoring_status2}=  Run Keyword And Return Status  Should Be Equal  ${mtSBTSSmEnergyMonitoring_value2}  ${MTSBTSRFM_INTERVAL}
      IF  ${mtSBTSSmEnergyMonitoring_status2}==${False}
        Logging With Timestamp
        ...  message=Parameter mtSBTSSmEnergyMonitoring for MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1 with UNexpected value! Please investigate!
        ...  style=ERROR
        Fail  Parameter mtSBTSSmEnergyMonitoring for MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1 with UNexpected value! Please investigate!
      ELSE
        Logging With Timestamp
        ...  message=Parameter mtSBTSSmEnergyMonitoring for MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1 with expected value ${MTSBTSRFM_INTERVAL}.
        ...  style=DONE
      END
    END

Set PIMc Thresholds
    [Arguments]  ${minor}  ${major}  ${bts_id}

    admin.Create Delta
    admin.Append Parameter Update To Delta  ${PIMC_OBJECT}  intPIMLevelMeasurementMajorThreshold  ${major}
    admin.Append Parameter Update To Delta  ${PIMC_OBJECT}  intPIMLevelMeasurementMinorThreshold  ${minor}
    ${delta}  admin.Get Delta
    admin.Perform Delta Recommissioning     ${delta}
    ...                               alias=${bts_id}
    admin.Remove Delta

Wait For Alarm
    [Arguments]  ${active_state}  ${NOTIFIER_LIST}  ${faultId}  ${severity}

    ${status_list}  Create List
    admin.Add Allowed Alarm  faultId=${faultId}  connection=${bts_id}
    FOR  ${ant}  IN  @{NOTIFIER_LIST}
        ${status}  Run Keyword And Return Status  admin.Assert alarm ${active_state}
        ...  faultId=${faultId}, severity=${severity}, notifier=regex".*${ant}.*"  timeout=5  alias=${bts_id}
        Run Keyword If  '${status}'=='False'
        ...  Append To List  ${status_list}  ${status}
    END

    Log To Console  Still waiting for ${active_state.lower()} alarm ${faultId}...

    Should be empty  ${status_list}

Teardown_PM_cell_degradation_handling_with_cell_switch_off
    [Arguments]  ${tc_status}
    [Documentation]  Teardown procedures
    ...  Arguments:
    ...  +========================+======+==========================================================+
    ...  | Argument               | Man. | Description                                              |
    ...  +========================+======+==========================================================+
    ...  | tc_status              | Yes  | TC status                                                |
    ...  +------------------------+------+----------------------------------------------------------+
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com
    Logging With Timestamp
    ...  message=PM_cell_degradation_handling_with_cell_switch_off teardown started
    ...  style=STEP
    ...  frame=${TRUE}

    IF  "${tc_status}"=="FAIL" and ${TEARDOWN_RECOMMISSIONING}==${True}
      Run Keyword And Continue On Failure  admin.Perform Commissioning
      ...  bts_id=${CFG.active_bts_list[0]}  scf_file=${TEST_LOGS_PATH}BTSFiles/${CFG.active_bts_list[0]}/initial_scf.xml
      ...  skip_parameter_relation_errors=True  should_activate=True  timeout=300  connection=${CFG.active_bts_list[0]}
      Run Keyword And Continue On Failure
      ...  Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  20  STATE Verify Multi Node State  scf_check=${FALSE}
    END
    Common Test Teardown
