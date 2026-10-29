*** Settings ***

Resource   resources/ca_BSRF_general.robot

*** Keywords ***
TC__SiSo_PM_PIMC_Counters
  [Documentation]
  ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-21420
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...  TC for feature: 5GC001240-B-SyVe- PIM Cancellation - PM Counters
  ...  The purpose of this test is to ensure that with feature 5GC001240 (PIM Cancellation) enabled
  ...  values of Passive Intermodulation (PIM) related PM counters are correctly reported in WebEM.
  ...  Power Meter is capable of measure power consumption (DC voltage and amperage) in RFM, SM and whole BTS.
  ...  TC verifies if all counters for feature are correctly gathered.
  ...  The counters RX1...RX8 depend on the number of Radio Antenna Ports, these can vary between 4, 6 and 8 RX Antenna Ports.
  ...  The structure is given by the L3 SM-RM Interface spec. MIN, MAX, SUM, NUM to request the measurement reports.
  ...  Minimum PIM measurement for RRH : M55303C2400x (x=1...8)
  ...  Maximum PIM measurement for RRH : M55303C2500x (x=1...8)
  ...  Sum of PIM measurements for RRH : M55303C2600x (x=1...8)
  ...  Number of PIM measurements for RRH : M55303C2700x (x=1...8)
  ...
  ...  ***  VARIABLES ***
  ...  RMOD_SN  - RU serial number
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 02.06.2021 - https://jira3.int.net.nokia.com/browse/TAT-21420 - Initial creation
  ...  - 14.07.2021 - https://jira3.int.net.nokia.com/browse/TAT-21578 - Verify values for PIMC counters

  Set Tags    OWNER-mateusz.kawka@nokia.com
  ...         AUTHOR-mateusz.kawka@nokia.com
  ...         MAINTAINER-mateusz.kawka@nokia.com
  ...         PHASE-CRT
  Common Test Setup
  Logging With Timestamp
  ...  message=TC__SiSo_PM_PIMC_Counters will be executed
  ...  style=ONGOING
  SiSo_PM_PIMC_Counters.step1: Preconditions
  step2: Check PIM Counters When Enabled
  step3: Check PIM Counters When Disabled
  [Teardown]    Common Test Teardown


step1: Preconditions

    Log To Console  step1: Preconditions

    # list with counters definition
    @{MIN_NR_PIM_RX}  Create List
    @{MAX_NR_PIM_RX}  Create List
    @{SUM_NR_PIM_RX}  Create List
    @{NUM_NR_PIM_RX}  Create List

    # setting lists to test variable
    Set Test Variable  ${MIN_NR_PIM_RX}
    Set Test Variable  ${MAX_NR_PIM_RX}
    Set Test Variable  ${SUM_NR_PIM_RX}
    Set Test Variable  ${NUM_NR_PIM_RX}

    ${bts_params} =  Get parameters for all  BTS  alias=${node}
    Set Test Variable  ${BTS_ID}  ${bts_params[0].btsId}

    ${rmods}=  Get Parameters For All  RMOD  alias=${node}

    FOR  ${rmod}  IN  @{rmods}
        Continue For Loop If  '${rmod.serialNumber}'!='${RMOD_SN}'
        ${rmod_distname}  Set Variable  ${rmod.id}
    END

    Variable Should Exist  ${rmod_distname}
    ...  RU Serial number not found in HW Configuration ! \nMake sure that correct RMOD_SN variable has been provided !

    ${rmods_info}  Get FRM  60  ${node}

    FOR  ${rmod}  IN  @{rmods_info}
        Continue For Loop If  '${rmod['serialNumber']}'!='${RMOD_SN}'
        ${rmod_config_id}  Set Variable  ${rmod['id']['configuration']}
        ${rmod_runtime_id}  Set Variable  ${rmod['id']['internal']}
        ${ports}  Set Variable  ${rmod['ports']}
    END

    ${nrcells_list}  Get Cells Mapping By RMOD Id    rat=NR  radio_id=${rmod_runtime_id}  alias=${node}
    ${nrcel_nr}  Get Length  ${nrcells_list}
    Set Test Variable  ${NRCEL_NR}

    Run Keyword If  ${NRCEL_NR}==0
    ...  Fail  No NRCEL on RMOD ${RMOD_SN}

    ${rmod_number}  Evaluate  '${rmod_config_id}'.rsplit('-',1)[1]
    ${query_path}  Set Variable  /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/EQM_A-*/APEQM_A-*/RMOD_A-${rmod_number}

    #Set Test Variable  ${object_mtPimCancellation}  MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/PMRNL-1
    Set Test Variable  ${PIMC_OBJECT}  MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${rmod_number}

    ${rmod_object}  admin_im.Query Infomodel  get object ${query_path}   allow_negative_result=True  alias=${node}
    ${act_pim_can}  Set Variable  ${rmod_object.actPimCancellation}
    ${pim_can_ena}  Set Variable  ${rmod_object.pimCancellingEnabled}

    Should Be Equal As Strings  ${act_pim_can}  False  actPimCancellation must be set to False before TC run !  values=False
    ${status}  Run Keyword And Return Status  Should Be Equal As Strings  ${pim_can_ena}  False
    ...  pimCancellingEnabled must be set to False before TC run !  values=False
    Run Keyword If  '${status}'=='False'  Run Keywords
    ...  Log to console  pimCancellingEnabled now is set to True, recommissioning to False !${\n}
    ...  AND  Perform Parameter Recommissioning  ${PIMC_OBJECT}  pimCancellingEnabled  update  false  alias=${node}

    Set Test Variable  ${PIMC_ENABLED_STATUS}  ${pim_can_ena}
    Set Test Variable  ${QUERY_PATH}

    ${ports_count}  Set Variable  ${0}
    FOR  ${port}  IN  @{ports}
        Continue For Loop If  'ANT' not in '${port['label']}'
        ${ports_count}  Evaluate  ${ports_count}+1
    END
    Set Test Variable  ${PORTS_COUNT}

    Log to console  Found ${PORTS_COUNT} RX ports for RMOD ${RMOD_SN}${\n}Now setting lists with counters!${\n}

    FOR  ${port}  IN RANGE  1  ${PORTS_COUNT+1}
        ${MIN_name}  Evaluate  'M55303C2400'+'${port}'
        ${MAX_name}  Evaluate  'M55303C2500'+'${port}'
        ${SUM_name}  Evaluate  'M55303C2600'+'${port}'
        ${NUM_name}  Evaluate  'M55303C2700'+'${port}'
        Append To list  ${MIN_NR_PIM_RX}  ${MIN_name}
        Append To list  ${MAX_NR_PIM_RX}  ${MAX_name}
        Append To list  ${SUM_NR_PIM_RX}  ${SUM_name}
        Append To list  ${NUM_NR_PIM_RX}  ${NUM_name}
    END

    ${new_counters_path}    Check If Current Build Is Newer Than    SBTS24R2_ENB_9999_231220_000004  alias=${node}
    Set Test Variable    ${NEW_COUNTERS_PATH}

    Log to console  All preconditions are met, going to next step !${\n}

step2: Check PIM Counters When Enabled

    Log to console  -----------------------------------------------
    Log to console  Step2: Check Counters When Enabled
    Log to console  -----------------------------------------------${\n}

    Log To Console  Updating actPimCancellation and pimCancellingEnabled parameter to true ...
    SiSo_PM_PIMC_Counters.Perform Recommissioning For PIMC  true

    Log to console  Recommissioning done, checking cells state !${\n}
    ${status}  Run Keyword And Return Status  Check If All Cells Are onAir  alias=${node}
    Run Keyword If  '${status}'=='False'  Run Keywords
    ...  SiSo_PM_PIMC_Counters.Perform Recommissioning For PIMC  false
    ...  AND  Fail  Cells are not onAir after recommissioning! Feature deactivated and set test fail !
    ...  ELSE
    ...  Log to console  All cells are onAir !${\n}

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  15
    Log To Console  Waiting for ${time_to_sleep} minutes to Get PM Counters ! ${\n}Verdict will be released at *${time_to_verdict}* !${\n}
    Sleep  ${time_to_sleep} minutes

    ${MIN_PIM_ENABLED}  Verify PIM Counters And Return Length  ${MIN_NR_PIM_RX}
    ${MAX_PIM_ENABLED}  Verify PIM Counters And Return Length  ${MAX_NR_PIM_RX}
    ${SUM_PIM_ENABLED}  Verify PIM Counters And Return Length  ${SUM_NR_PIM_RX}
    ${NUM_PIM_ENABLED}  Verify PIM Counters And Return Length  ${NUM_NR_PIM_RX}

    ${equal}  Evaluate  ${MIN_PIM_ENABLED}==${MAX_PIM_ENABLED}==${SUM_PIM_ENABLED}==${NUM_PIM_ENABLED}

    Set Test Variable  ${MIN_PIM_ENABLED}
    Set Test Variable  ${MAX_PIM_ENABLED}
    Set Test Variable  ${SUM_PIM_ENABLED}
    Set Test Variable  ${NUM_PIM_ENABLED}

    Run Keyword If  '${equal}'=='False'  Run Keyword And Continue On Failure  Fail  One of counters return wrong number of measurements rows !
    ...  ELSE  Log to console  All counters return the same number of measurements, going to next step !${\n}


step3: Check PIM Counters When Disabled

    Log to console  ${\n}----------------------------------------
    Log To Console  step3: Check PIM Counters When Disabled
    Log to console  ----------------------------------------${\n}

    Log To Console  Updating actPimCancellation and pimCancellingEnabled parameter to false ...
    SiSo_PM_PIMC_Counters.Perform Recommissioning For PIMC  false

    ${status}  Run Keyword And Return Status  Check If All Cells Are onAir  alias=${node}
    Run Keyword If  '${status}'=='False'
    ...  Fail  Cells are not onAir after recommissioning! Feature deactivated and set test fail !
    ...  ELSE
    ...  Log to console  All cells are onAir !${\n}

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  15  additional_offset=15
    Log To Console  Waiting ${time_to_sleep} minutes for re-collect PM counters to check if feature was correctly deactivated !
    Log To Console  Verdict will be released at *${time_to_verdict}* !${\n}
    Sleep  ${time_to_sleep} minutes

    ${MIN_PIM_DISABLED}  Verify PIM Counters And Return Length  ${MIN_NR_PIM_RX}
    ${MAX_PIM_DISABLED}  Verify PIM Counters And Return Length  ${MAX_NR_PIM_RX}
    ${SUM_PIM_DISABLED}  Verify PIM Counters And Return Length  ${SUM_NR_PIM_RX}
    ${NUM_PIM_DISABLED}  Verify PIM Counters And Return Length  ${NUM_NR_PIM_RX}

    ${equal}  Evaluate  ${MIN_PIM_DISABLED}==${MAX_PIM_DISABLED}==${SUM_PIM_DISABLED}==${NUM_PIM_DISABLED}

    Run Keyword If  '${equal}'=='False'  Run Keyword And Continue On Failure  Fail  One of counters return wrong number of measurements rows !
    ...  ELSE  Log to console  All counters return the same number of measurements, comparing with previous step... !${\n}

    ${min_counter_verdict}  Evaluate  ${MIN_PIM_ENABLED} <= ${MIN_PIM_DISABLED} <= ${MIN_PIM_ENABLED+(${PORTS_COUNT}*${NRCEL_NR})}
    ${max_counter_verdict}  Evaluate  ${MAX_PIM_ENABLED} <= ${MAX_PIM_DISABLED} <= ${MAX_PIM_ENABLED+(${PORTS_COUNT}*${NRCEL_NR})}
    ${sum_counter_verdict}  Evaluate  ${SUM_PIM_ENABLED} <= ${SUM_PIM_DISABLED} <= ${SUM_PIM_ENABLED+(${PORTS_COUNT}*${NRCEL_NR})}
    ${num_counter_verdict}  Evaluate  ${NUM_PIM_ENABLED} <= ${NUM_PIM_DISABLED} <= ${NUM_PIM_ENABLED+(${PORTS_COUNT}*${NRCEL_NR})}

    Run Keyword If  (${min_counter_verdict} and ${max_counter_verdict} and ${sum_counter_verdict} and ${num_counter_verdict})==True
    ...  Log To Console  PIM Cancellation feature deactivation was successfull !
    ...  ELSE  Fail  PIM Cancellation feature deactivation wasn't successfull !

Perform Recommissioning For PIMC
    [Arguments]  ${activate_flag}

    Perform Parameter Recommissioning  ${PIMC_OBJECT}  actPimCancellation  update   ${activate_flag}  alias=${node}
    Perform Parameter Recommissioning  ${PIMC_OBJECT}  pimCancellingEnabled  update  ${activate_flag}  alias=${node}

Verify PIM Counters And Return Length
  [Arguments]  ${list_of_counters}

  ${counters_list_string}  Evaluate  ','.join(${list_of_counters})

  ${api_pm_counters}  Get Pm Counters  ${counters_list_string}  alias=${node}

   Log to console  Checking counters -> ${list_of_counters}!${\n}
  ${counter_length}  Verify Values Of Counters  ${api_pm_counters}  ${list_of_counters}

    [Return]  ${counter_length}

Verify Values Of Counters
    [Arguments]  ${api_pm_counters}  ${list_of_counters}

    ${cell_dict}  Set Variable If
    ...    ${NEW_COUNTERS_PATH}
    ...    ${api_pm_counters['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']}
    ...    ${api_pm_counters['BTS']['CELLS']}

    ${counter_length}  Set Variable  0
    FOR  ${cell}  ${counters}  IN ZIP  ${cell_dict.keys()}  ${cell_dict.values()}
        Log to console  Checking counters for ${cell}!
        ${counter_name}  Set Variable  ${counters['NULSQ']}
        ${keys}  Get Dictionary Keys  ${counter_name}
        ${req_counters_status}  Run Keyword And Return Status  Lists Should be equal  ${list_of_counters}  ${keys}
        Run Keyword If  '${req_counters_status}'=='True'  Log to console
        ...  Counters was successfull collected, now going to check values !
        ...  ELSE  Run Keywords  Log to console  Collected PM Counters don't contain expected counters !
        ...  AND  Run Keyword And Continue on Failure  Fail  Collected PM Counters don't contain expected counters !
        ${values}  Get Dictionary Values  ${counter_name}
        ${counter_values}  _Unzip List Of Dicts  ${values}
        Run Keyword If  ${list_of_counters}==${NUM_NR_PIM_RX}  Check If Counter Values Are Natural Number  ${counter_values}
        ...  ELSE  Check If Counter Values Are In Range  ${counter_values}

        ${length}  Get Length  ${counter_values}
        ${counter_length}  Evaluate  ${counter_length}+${length}
    END

    [Return]  ${counter_length}

_Unzip List Of Dicts
    [Arguments]  ${values}

    ${raw_list_all_values}  Create List
    FOR  ${item}  IN  @{values}
        ${all_values}  Get Dictionary Values  ${item}
        Append To List  ${raw_list_all_values}  ${all_values}
    END

    ${list_all_values}  Evaluate  [item for sublist in ${raw_list_all_values} for item in sublist]

    [Return]  ${list_all_values}

Check If Counter Values Are In Range
    [Arguments]  ${values}

    ${in_range_status_list}  Create List
    FOR  ${value}  IN  @{values}
        ${in_range}  Evaluate  (-83.67>=${value}>=-180 or ${value}==0)
        Append to list  ${in_range_status_list}  ${in_range}
    END

    Run Keyword If  'False' in '${in_range_status_list}'  Run Keywords
    ...  Run Keyword And Continue on failure  Fail  At least one of value is not in range <-180; -83.67> or is not NULL !
    ...  AND  Log to console  At least one of value is not in range <-180; -83.67> or is not NULL !
    ...  ELSE  Log to console  All values are in range !${\n}

Check If Counter Values Are Natural Number
    [Arguments]  ${values}

    ${nn_status_list}  Create List
    FOR  ${value}  IN  @{values}
        ${in_range}  Evaluate  (0<=${value}<=65535)
        Append to list  ${nn_status_list}  ${in_range}
    END

    Run Keyword If  'False' in '${nn_status_list}'  Run Keywords
    ...  Run Keyword And Continue on failure  Fail  At least one of value is not natural number !
    ...  AND  Log to console  At least one of value is not natural number !
    ...  ELSE  Log to console  All values are natural numbers !${\n}






