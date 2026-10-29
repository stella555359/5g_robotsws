*** Settings ***
Documentation
    ...  LTE or NR cell lock/unlock from ADMIN TC. If ${RAT_LOCK} is set to LTE, LTE cells will be locked and if
    ...  ${RAT_LOCK} has NR value then NR cells will be locked.
    ...
    ...  If ${LNCEL_ID} or ${NRCELL_ID} parameter is not equal to ${None}, cell with ID specified will be locked.
    ...  Otherwise, all cells on specified RAT will be locked.
    ...
    ...  Step1: Cells Lock
    ...  Lock LTE/NR cells depending on ${RAT_LOCK} value.
    ...  Check WCDMA, GSM and not affected LTE/NR cells states - must be onAir.
    ...  Check affected LTE/NR cells states locked and disabled.
    ...
    ...  Step2: Cells Unlock
    ...  Unlock specified LTE/NR cells
    ...  Check WCDMA, GSM and not affected LTE/NR cells states - must be onAir.
    ...  Check affected LTE/NR cells states unlocked and enabled.
    ...
    ...  In the end of each step there will be executed:
    ...  Log TX power and set restriciton if any alarm is visible.
    ...
    ...  TC fails if cells states don't match.

Resource  ../../common_resources/ca_KPI_general.robot


*** Variables ***
${LNCEL_ID}  ${None}  # Example: 23651. Cannot be ${None} only if ${RAT_LOCK} is LTE.
${NRCELL_ID}  ${None}  # Cannot be ${None} only if ${RAT_LOCK} is NR.
${RAT_LOCK}  ${EMPTY}  # Mandatory!
# If set LTE, 4G cell will be locked.
# If set NR, 5G cell will be locked.
${LOCK_UNLOCK_TIMEOUT}  300


*** Keywords ***
TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-22184
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  09.11.2021 - https://jira3.int.net.nokia.com/browse/TAT-22184 - Initial creation
    ...  22.03.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22843 - Adjust delta results to be collected from single runs
    ...  04.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22932 - Remove Log all TX power
    ...  19.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23154 - Add variable for lock/unlock timeout
    ...  10.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23848 - Migrate from hran_ims to oam_kpi_calculations
    ...  10.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24073 - Log delta to console
    ...  11.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24107 - Save delta in json file after every TC
    ...  18.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24130 - Refactor TC with best practices
    ...  05.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24210 - Move Costum Test Teardown implementation to TC Teardown
    ...  26.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28005 - Change parameters name
    ...  24.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30323 - Drop ute_admin_infomodel usage from KPI test cases
    ...  06.04.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30748 - Fix comparison for cell identification

    Set Tags  CA-KPI  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  SW-SBTS21  SW-SBTS22

    Step0: Set DN For Cells
    Step1: Cells Lock
    Step2: Cells Unlock


Set Dist_name For Cells
    [Arguments]  ${cell_type}
    IF  '${cell_type}'=='NRCELL'
        Set test variable  ${CELL_CLASS}  NRCEL
    ELSE
        Set test variable  ${CELL_CLASS}  LNCEL
    END
    IF  $${cell_type}_ID is not None
        Set Cell Object R Dist_name  ${cell_type}
    ELSE
        Set Cells Object R Dist_name  ${cell_type}
    END
    Set Short Dist_name  ${cell_type}


Step0: Set DN For Cells
    IF  "${RAT_LOCK}"=="${EMPTY}"  Fail  Variable RAT_LOCK must be set to LTE or NR!
    Check Validity  LTE  NRCELL
    Check Validity  NR  LNCEL
    IF  '${RAT_LOCK}'=='LTE'
        Set Test Variable  ${CELL_TYPE_LOCK}  LNCEL
    ELSE
        Set Test Variable  ${CELL_TYPE_LOCK}  NRCELL
    END
    Set Dist_name For Cells  ${CELL_TYPE_LOCK}


Check Validity
    [Arguments]  ${rat_type}  ${cell}

    IF  ${SCF_COUNT_${rat_type}}==0 and '${RAT_LOCK}'=='${rat_type}'  Fail  ${rat_type} RAT does not exist!
    IF  '${RAT_LOCK}'=='${rat_type}' and ${${cell}_ID}!=${None}  Fail  Variable ${cell}_ID must be None because ${rat_type} lock is performing!


Step1: Cells Lock
    Log  \nStep1: ${CELL_TYPE_LOCK} Lock  console=true
    Lock Cells  ${CELL_TYPE_LOCK}
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  60  20
    ...  Verify Cells States  administrative_state_${CELL_TYPE_LOCK}=${LOCKED}
    ...  blocking_state_${CELL_TYPE_LOCK}=${UNBLOCKED}
    ...  operational_state_${CELL_TYPE_LOCK}=${DISABLED}
    IF  ${status}
        Log  ${CELL_TYPE_LOCK} is locked.  console=true
    ELSE
        Fail  Incorrect cells or units states, test fail! Collecting snapshot.
    END
    Admin Check Active Alarms TAF


Step2: Cells Unlock
    Log  \nStep2: ${CELL_TYPE_LOCK} Unlock  console=true
    Unlock Cells  ${CELL_TYPE_LOCK}
    ${status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  60  20  Verify Cells States
    IF  ${status}
        Log  ${CELL_TYPE_LOCK} is unlocked.  console=true
    ELSE
        Fail  Incorrect cells or units states, test fail! Collecting snapshot.
    END
    Admin Check Active Alarms TAF


Lock Cells
    [Arguments]  ${cell_type}

    IF  '${cell_type}'=='LNCEL'
        ${new_value}  Set Variable  locked
    ELSE
        ${new_value}  Set Variable  Locked
    END
    FOR  ${cell}  IN  @{${cell_type}_SHORT_DN}
        Perform Parameter Recommissioning  ${cell}  administrativeState  update  ${new_value}  skip_parameter_relation_errors=${True}
        ...  timeout=${LOCK_UNLOCK_TIMEOUT}
        ${cell_r_dn}  Get Correspondent R Dist Name  ${cell}
        ${cell_type}  Get Regexp Matches  ${cell_r_dn}  [A-Z]{2}CEL
        Assert  ${cell_type}[0]  ${cell_r_dn}  administrativeState=${LOCKED}, operationalState=${DISABLED}  timeout=300
    END


Get Correspondent R Dist Name
    [Arguments]  ${cell_short_dn}

    ${cell_segment}  Fetch From Right  ${cell_short_dn}  /
    ${cell_id}  Fetch From Right  ${cell_segment}  -
    FOR  ${cell}  IN  @{${CELL_TYPE_LOCK}_R_DN}
        ${match}  Get Regexp Matches  ${cell}  ${CELL_CLASS}_R-${cell_id}$
        IF  $match  RETURN  ${cell}
    END


Unlock Cells
    [Arguments]  ${cell_type}

    IF  '${cell_type}'=='LNCEL'
        ${new_value}  Set Variable  unlocked
    ELSE
        ${new_value}  Set Variable  Unlocked
    END
    FOR  ${cell}  IN  @{${cell_type}_SHORT_DN}
        Perform Parameter Recommissioning  ${cell}  administrativeState  update  ${new_value}  skip_parameter_relation_errors=${True}
        ...  timeout=${LOCK_UNLOCK_TIMEOUT}
        ${cell_r_dn}  Get Correspondent R Dist Name  ${cell}
        ${cell_type}  Get Regexp Matches  ${cell_r_dn}  [A-Z]{2}CEL
        Assert  ${cell_type}[0]  ${cell_r_dn}  administrativeState=${UNLOCKED}, operationalState=${ENABLED}  timeout=300
    END


Verify Cells States
    [Arguments]
    ...  ${administrative_state_LNCEL}=${UNLOCKED}
    ...  ${blocking_state_LNCEL}=${UNBLOCKED}
    ...  ${operational_state_LNCEL}=${ENABLED}
    ...  ${administrative_state_NRCELL}=${UNLOCKED}
    ...  ${blocking_state_NRCELL}=${UNBLOCKED}
    ...  ${operational_state_NRCELL}=${ENABLED}

    IF  ${SCF_COUNT_GSM}  coam.Assert Every  GNCEL  administrativeState=${UNLOCKED}, blockingState=${UNBLOCKED}, operationalState=${ENABLED}
    IF  ${SCF_COUNT_WCDMA}  coam.Assert Every  WNCEL  blockingState=${UNBLOCKED}, operationalState=${ENABLED}
    IF  ${SCF_COUNT_LTE}
    ...  Check LTE Cells  administrative_state=${administrative_state_LNCEL}
    ...  blocking_state=${blocking_state_LNCEL}
    ...  operational_state=${operational_state_LNCEL}
    IF  ${SCF_COUNT_NR}
    ...  Check NR Cells  administrative_state=${administrative_state_NRCELL}
    ...  blocking_state=${blocking_state_NRCELL}
    ...  operational_state=${operational_state_NRCELL}


Check LTE Cells
    [Arguments]  ${administrative_state}  ${blocking_state}  ${operational_state}

    IF  $LNCEL_ID is not None
        Verify Specific Cell States  LNCEL  ${LNCEL_ID}  ${administrative_state}  ${blocking_state}  ${operational_state}
    ELSE
        coam.Assert Every  LNCEL  administrativeState=${administrative_state}, blockingState=${blocking_state}, operationalState=${operational_state}
    END


Check NR Cells
    [Arguments]  ${administrative_state}  ${blocking_state}  ${operational_state}

    IF  $NRCELL_ID is not None
        Verify Specific Cell States  NRCELL  ${NRCELL_ID}  ${administrative_state}  ${blocking_state}  ${operational_state}
    ELSE
        coam.Assert Every  NRCEL  administrativeState=${administrative_state}, blockingState=${blocking_state}, operationalState=${operational_state}
    END


Verify Specific Cell States
    [Arguments]  ${cell_type}  ${cell_id}  ${administrative_state}  ${blocking_state}  ${operational_state}

    ${cell_info}  Get Cell Specific Info  ${${cell_type}_R_DN}[0]
    ${status_administrative}  Run Keyword And Return Status  Should Match Regexp  ${cell_info}[status][administrativeState]  ${administrative_state}
    ${status_blocking}  Run Keyword And Return Status  Should Match Regexp  ${cell_info}[status][blockingState]  ${blocking_state}
    ${status_operational}  Run Keyword And Return Status  Should Match Regexp  ${cell_info}[status][operationalState]  ${blocking_state}
    IF  ${status_administrative} and ${status_blocking} and ${status_operational}
        Log  \Cell:${${cell_type}_R_DN}[0] is ${administrative_state}, ${blocking_state}, ${operational_state} [OK]  console=true
    END
    ${cell_r_objects}  Get All Cells On Bts
    Check Other Cells States  ${cell_r_objects}  ${cell_type}  ${cell_id}


Check Other Cells States
    [Arguments]  ${cell_r_objects}  ${cell_type}  ${cell_id}

    FOR  ${cell}  IN  @{cell_r_objects}
        ${cell_id_from_obj}  Remove String Using Regexp  ${cell}  .*/${cell_type}_R-
        ${status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${cell_id_from_obj}  ${cell_id}
        IF  ${status}  CONTINUE
        ${cell_info}  Get Cell Specific Info  ${cell}
        ${status_administrative}  Run Keyword And Return Status  Should Match Regexp  ${cell_info}[status][administrativeState]  ${UNLOCKED}
        ${status_blocking}  Run Keyword And Return Status  Should Match Regexp  ${cell_info}[status][blockingState]  ${UNBLOCKED}
        ${status_operational}  Run Keyword And Return Status  Should Match Regexp  ${cell_info}[status][operationalState]  ${ENABLED}
        IF  ${status_administrative} and ${status_blocking} and ${status_operational}
            Log  \Cell:${${cell_type}_R_DN}[0] is ${administrative_state}, ${blocking_state}, ${operational_state} [OK]  console=true
        END
    END


Set Cell Object R Dist_name
    [Arguments]  ${cell_type}

    ${cells_object}  Get Parameters For All  ${CELL_CLASS}
    FOR  ${cell_obj}  IN  @{cells_object}
        ${match}  Get Regexp Matches  ${cell_obj}[id]  ${CELL_CLASS}_R-${${cell_type}_ID}$
        IF  $match
            ${cell_dist_name}  Create List  ${cell_obj}[id]
            BREAK
        END
    END
    Variable Should Exist  ${cell_dist_name}  There is no ${CELL_CLASS} cell with provided ID.
    Set Test Variable  ${${cell_type}_R_DN}  ${cell_dist_name}


Set Cells Object R Dist_name
    [Arguments]  ${cell_type}

    ${cells_object}  Get Parameters For All  ${CELL_CLASS}
    ${cells_r_dist_name}  Create List
    FOR  ${cell_obj}  IN  @{cells_object}
        Append To List  ${cells_r_dist_name}  ${cell_obj}[id]
    END
    Set Test Variable  ${${cell_type}_R_DN}  ${cells_r_dist_name}


Set Short Dist_name
    [Arguments]  ${cell_type}

    ${cells_dn_list}  Create List
    ${bts_id}  Admin Get BTS ID
    FOR  ${cell}  IN  @{${cell_type}_R_DN}
        ${cell_dn}  Remove String Using Regexp  ${cell}  .*VIEW-\\d/
        ${cell_dn}  Replace String Using Regexp  ${cell_dn}  _R  ${EMPTY}
        ${cell_dn}  Replace String Using Regexp  ${cell_dn}  MRBTS-\\d  MRBTS-${bts_id}
        Append To List  ${cells_dn_list}  ${cell_dn}
    END
    Set Test Variable  ${${cell_type}_SHORT_DN}  ${cells_dn_list}


Recovery Action
    [Documentation]  Will try to unlock all LTE and NR cells under test.

    Unlock Cells  ${CELL_TYPE_LOCK}


TC Setup
    Set Log Level  INFO
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  infomodel_launch=${FALSE}


TC Teardown
    Run Keyword If Test Failed
    ...  Recovery Action
    Common Test Teardown
    ${kpi16}  Calculate Kpis  kpi16a kpi16b  ${BTS_FILES}/IM/InfoModel_log.ims2
    Log Delta In Seconds  ${kpi16}[kpi16a][-1][delta]  kpi16a
    Log Delta In Seconds  ${kpi16}[kpi16b][-1][delta]  kpi16b
    Save Delta Results  kpi16a
    Save Delta Results  kpi16b
    Set Log Level  TRACE
